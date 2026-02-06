// src/slot-packer/packing.ts

import {
    buildDependencyData,
    validateDependencyConstraints,
    assignPriorityMetadata
} from './dependencies';
import {
    createEmptySlot,
    canBundleFitInSlot,
    canFitInSlot,
    canBundleRespectDependencies,
    canRespectDependencies,
    addBundleToSlot,
    addToSlot,
    formatSizeInfo,
    getSectionMinifiedEstimate,
    bundleHasCommander,
    slotHasCommander,
    MINIFIED_SIZE_TOLERANCE,
    labelSlots,
    logSlotAllocation
} from './sizing';
import { getDefaultPriority } from '../helpers/priority-utils';

/**
 * Pack sections into slots with triple-limit enforcement and dependency awareness
 * FULLY DYNAMIC: No hardcoded slot assignments, incremental allocation only
 * @param {Array} selectedSections - Array of section metadata objects
 * @param {Object} limits - Limit configuration
 * @param {Object} slotDistribution - IGNORED - kept for compatibility
 * @param {Object} allTweaks - Optional: tweaks metadata for dependency resolution
 * @returns {Object} Packed slots { tweakunits: [...], tweakdefs: [...] }
 */
export function packIntoSlots(selectedSections: any[], limits: any, slotDistribution: any, allTweaks: any) {
    const defaultLimits = {
        maxLines: 700,
        maxRaw: 22000,
        maxEncoded: 12000, // target under 13k to leave buffer for final encoding
        bufferPct: 0.9 // Target 90% utilization of the 12k target
    };

    const config = { ...defaultLimits, ...limits };

    // Calculate target values (85% of max)
    const targets = {
        lines: Math.floor(config.maxLines * config.bufferPct),
        raw: Math.floor(config.maxRaw * config.bufferPct),
        encoded: Math.floor(config.maxEncoded * config.bufferPct)
    };

    // Separate sections by type (Main sections handled separately in command-builder.js)
    const unitSections = selectedSections.filter(s => s.type === 'units');
    const defSections = selectedSections.filter(s => s.type === 'defs');

    // Pack each type with DYNAMIC incremental allocation and dependency awareness
    const result = {
        tweakunits: packSectionsDynamically(unitSections, config, targets, 'units', allTweaks),
        tweakdefs: packSectionsDynamically(defSections, config, targets, 'defs', allTweaks)
    };

    return result;
}

/**
 * Pack sections dynamically using FFD with dependency-aware slot allocation
 * @param {Array} sections - Sections to pack
 * @param {Object} config - Limit configuration
 * @param {Object} targets - Target utilization values
 * @param {string} type - 'units' or 'defs'
 * @param {Object} allTweaks - Optional: all tweaks object for dependency lookup
 * @returns {Array} Array of slot objects with incremental slot numbers
 */
function packSectionsDynamically(sections: any[], config: any, targets: any, type: string, allTweaks: any) {
    if (sections.length === 0) return [];

    // Build dependency data (deps map + levels + topo ordering)
    const { dependencyMap, sectionLevels, orderedSections } = buildDependencyData(sections, allTweaks);
    assignPriorityMetadata(sections, dependencyMap, type);
    // Independent sections: build bundles per section for maximum packing flexibility
    const bundles = buildFileBundles(sections, sectionLevels, orderedSections, true);

    const slots: any[] = [];
    const state = {
        currentSlot: createEmptySlot(),
        currentSlotNumber: 1, // Start from slot 1 (slot 0 reserved for Main)
        slots,
        slotAssignments: {} as any, // Track which slot each section is assigned to (for dependency validation)
        dependencyMap,
        config,
        type,
        limitHit: false
    };

    for (const bundle of bundles) {
        const forceArmadaCommander = bundle.sections.length === 1 && bundle.sections[0].name === 'ARMADA_COMMANDER';
        const isCommanderBundle = bundleHasCommander(bundle);

        if (isCommanderBundle) {
            if (state.currentSlot.sections.length > 0) {
                finalizeSlot(slots, state.currentSlot, state.currentSlotNumber++);
                if (state.currentSlotNumber > 9) {
                    console.warn(`Warning: Exceeded maximum 9 slots for ${type}. Some sections may not be included.`);
                    break;
                }
                state.currentSlot = createEmptySlot();
            }

            if (state.currentSlotNumber > 9) {
                break;
            }

            let placedCommander = tryPlaceBundleInSlot(state.currentSlot, bundle, state.currentSlotNumber, config, dependencyMap, state.slotAssignments);
            if (!placedCommander && forceArmadaCommander) {
                const sizeInfo = formatSizeInfo(bundle.lines, bundle.rawChars, bundle.encodedChars, bundle.minifiedEncodedChars, config);
                console.warn(`Force-packing ARMADA_COMMANDER into its own slot despite size overage (${sizeInfo}).`);
                placedCommander = tryPlaceBundleInSlot(state.currentSlot, bundle, state.currentSlotNumber, config, dependencyMap, state.slotAssignments, true);
            }

            if (placedCommander) {
                finalizeSlot(slots, state.currentSlot, state.currentSlotNumber++);
                if (state.currentSlotNumber > 9) {
                    console.warn(`Warning: Exceeded maximum 9 slots for ${type}. Some sections may not be included.`);
                    break;
                }
                state.currentSlot = createEmptySlot();
                continue;
            }

            const sizeInfo = formatSizeInfo(bundle.lines, bundle.rawChars, bundle.encodedChars, bundle.minifiedEncodedChars, config);
            console.warn(`Commander bundle ${bundle.file} could not be packed (${sizeInfo}).`);
            continue;
        }

        // Try current slot first
        if (tryPlaceBundleInSlot(state.currentSlot, bundle, state.currentSlotNumber, config, dependencyMap, state.slotAssignments)) {
            continue;
        }

        // Finalize current slot if it had content, then open a fresh slot
        if (state.currentSlot.sections.length > 0) {
            finalizeSlot(slots, state.currentSlot, state.currentSlotNumber++);
            if (state.currentSlotNumber > 9) {
                console.warn(`Warning: Exceeded maximum 9 slots for ${type}. Some sections may not be included.`);
                break;
            }
            state.currentSlot = createEmptySlot();
        }

        if (state.currentSlotNumber > 9) {
            break;
        }

        // Try to fit the bundle in the fresh slot
        let placedFresh = tryPlaceBundleInSlot(state.currentSlot, bundle, state.currentSlotNumber, config, dependencyMap, state.slotAssignments);

        // Armada commander is allowed to ignore the encoded limit and force a dedicated slot
        if (!placedFresh && forceArmadaCommander) {
            const sizeInfo = formatSizeInfo(bundle.lines, bundle.rawChars, bundle.encodedChars, bundle.minifiedEncodedChars, config);
            console.warn(`Force-packing ARMADA_COMMANDER into its own slot despite size overage (${sizeInfo}).`);
            placedFresh = tryPlaceBundleInSlot(state.currentSlot, bundle, state.currentSlotNumber, config, dependencyMap, state.slotAssignments, true);
        }

        if (placedFresh) {
            continue;
        }

        // Last-resort fallback: the bundle itself is too large, so split its sections
        console.warn(`Bundle ${bundle.file} exceeds slot limits; splitting sections as fallback. (${formatSizeInfo(bundle.lines, bundle.rawChars, bundle.encodedChars, bundle.minifiedEncodedChars, config)})`);

        for (const section of bundle.sections) {
            const sectionMinEnc = getSectionMinifiedEstimate(section);
            const placed = placeSectionWithSlotRoll(section, sectionMinEnc, state);
            if (state.limitHit) {
                break;
            }
            if (!placed) {
                console.warn(`Section ${section.name} from ${bundle.file} could not be packed (${formatSizeInfo(section.lines, section.rawChars, section.encodedChars, sectionMinEnc, config)})`);
            }
        }

        if (state.currentSlotNumber > 9 || state.limitHit) {
            break;
        }
    }

    finalizeRemainingSlot(state);
    labelSlots(slots);
    // Skip compaction to preserve priority ordering across slots.
    logSlotAllocation(slots, config, type);
    validateDependencyConstraints(slots, state.slotAssignments, dependencyMap);

    return slots;
}

/**
 * Bundle sections by their source file while preserving ordering and dependency levels
 * @param {Array} sections - Sections to bundle
 * @param {Object} sectionLevels - Map of section name -> dependency level
 * @param {Array} orderedNames - Topologically ordered section names
 * @param {boolean} [splitIntoSections=false] - If true, create bundles per section (no file grouping)
 * @returns {Array} Bundles keyed by file (or per-section), sorted by priority and dependency order
 */
function buildFileBundles(sections: any[], sectionLevels: any = {}, orderedNames: string[] = [], splitIntoSections = false) {
    const bundleMap: any = {};
    const bundles: any[] = [];
    const orderIndex: any = {};

    orderedNames.forEach((name, idx) => {
        if (orderIndex[name] === undefined) {
            orderIndex[name] = idx;
        }
    });

    const addBundle = (bundleKey: string, section: any) => {
        if (!bundleMap[bundleKey]) {
            bundleMap[bundleKey] = {
                file: bundleKey,
                type: section.type,
                sections: [],
                lines: 0,
                rawChars: 0,
                encodedChars: 0,
                minifiedEncodedChars: 0,
                level: Infinity,
                firstOrderIndex: Infinity,
                priorityRank: Number.NEGATIVE_INFINITY,
                tierRank: Number.POSITIVE_INFINITY
            };
            bundles.push(bundleMap[bundleKey]);
        }

        const bundle = bundleMap[bundleKey];
        bundle.sections.push(section);
        bundle.lines += section.lines;
        bundle.rawChars += section.rawChars;
        bundle.encodedChars += section.encodedChars;
        bundle.minifiedEncodedChars += getSectionMinifiedEstimate(section);

        const lvl = sectionLevels[section.name];
        if (typeof lvl === 'number' && lvl < bundle.level) {
            bundle.level = lvl;
        }

        const idx = orderIndex[section.name];
        if (typeof idx === 'number' && idx < bundle.firstOrderIndex) {
            bundle.firstOrderIndex = idx;
        }

        const fallbackPriority = getDefaultPriority(section.type);
        const priority = typeof section.priorityRank === 'number'
            ? section.priorityRank
            : (typeof section.basePriorityRank === 'number' ? section.basePriorityRank : fallbackPriority);
        bundle.priorityRank = Math.max(bundle.priorityRank, priority);

        const tierRank = typeof section.tierRank === 'number' ? section.tierRank : 99;
        if (tierRank < bundle.tierRank) {
            bundle.tierRank = tierRank;
        }
    };

    sections.forEach(section => {
        const fileKey = section.file || '__NO_FILE__';
        const key = splitIntoSections ? `${fileKey}::${section.name}` : fileKey;
        addBundle(key, section);
    });

    bundles.forEach(bundle => {
        bundle.sections.sort((a: any, b: any) => {
            // Force EPICS_BUILDOPTIONS to the end of its bundle to keep epics ahead of the helper
            if (a.name === 'EPICS_BUILDOPTIONS' && b.name !== 'EPICS_BUILDOPTIONS') return 1;
            if (b.name === 'EPICS_BUILDOPTIONS' && a.name !== 'EPICS_BUILDOPTIONS') return -1;

            const aLine = typeof a.startLine === 'number' ? a.startLine : 0;
            const bLine = typeof b.startLine === 'number' ? b.startLine : 0;
            return aLine - bLine;
        });

        bundle.level = bundle.level === Infinity ? 0 : bundle.level;
        if (bundle.firstOrderIndex === Infinity) {
            bundle.firstOrderIndex = bundles.length; // stable fallback
        }
        if (!Number.isFinite(bundle.priorityRank)) {
            bundle.priorityRank = getDefaultPriority(bundle.type);
        }
        if (!Number.isFinite(bundle.tierRank)) {
            bundle.tierRank = 99;
        }
    });

    bundles.sort((a, b) => {
        if (a.priorityRank !== b.priorityRank) {
            return a.priorityRank - b.priorityRank;
        }
        if (a.tierRank !== b.tierRank) {
            return a.tierRank - b.tierRank;
        }
        if (a.level !== b.level) {
            return a.level - b.level;
        }
        return a.firstOrderIndex - b.firstOrderIndex;
    });

    return bundles;
}

/**
 * Try to place an entire bundle into a slot (size + dependency aware)
 * @param {Object} slot - Slot object
 * @param {Object} bundle - Bundle to place
 * @param {number} slotNumber - Slot number being filled
 * @param {Object} config - Limit configuration
 * @param {Object} dependencyMap - Dependency map
 * @param {Object} slotAssignments - Current slot assignments
 * @param {boolean} allowSizeOverride - Skip size check (for forced bundles)
 * @returns {boolean} True if placed
 */
function tryPlaceBundleInSlot(slot: any, bundle: any, slotNumber: number, config: any, dependencyMap: any, slotAssignments: any, allowSizeOverride = false) {
    const fitsLimits = allowSizeOverride || canBundleFitInSlot(slot, bundle, config);
    if (!fitsLimits) return false;
    if (!canBundleRespectDependencies(slotNumber, bundle, slotAssignments, dependencyMap)) return false;
    addBundleToSlot(slot, bundle);
    bundle.sections.forEach((section: any) => {
        slotAssignments[section.name] = slotNumber;
    });
    return true;
}

/**
 * Finalize a slot by assigning its number and storing it
 * @param {Array} slots - Slots collection
 * @param {Object} slot - Slot object
 * @param {number} slotNumber - Slot number to assign
 */
function finalizeSlot(slots: any[], slot: any, slotNumber: number) {
    slot.slotNum = slotNumber;
    slots.push(slot);
}

/**
 * Finalize the current slot if it has content and is within the slot cap
 * @param {Object} state - Packing state
 */
function finalizeRemainingSlot(state: any) {
    if (state.currentSlot.sections.length > 0 && state.currentSlotNumber <= 9) {
        finalizeSlot(state.slots, state.currentSlot, state.currentSlotNumber);
    }
}

/**
 * Try to place a single section, rolling to a new slot if needed
 * @param {Object} section - Section metadata
 * @param {number} sectionMinEnc - Cached minified encoded size
 * @param {Object} state - Packing state (currentSlot, currentSlotNumber, slots, config, dependencyMap, slotAssignments, type, limitHit)
 * @returns {boolean} True if placed
 */
function placeSectionWithSlotRoll(section: any, sectionMinEnc: number, state: any) {
    const { config, dependencyMap, slotAssignments, type } = state;
    const tryPlace = () => canFitInSlot(state.currentSlot, section, config) &&
        canRespectDependencies(state.currentSlot, section, slotAssignments, dependencyMap);

    if (tryPlace()) {
        addToSlot(state.currentSlot, section);
        slotAssignments[section.name] = state.currentSlotNumber;
        return true;
    }

    if (state.currentSlot.sections.length > 0) {
        finalizeSlot(state.slots, state.currentSlot, state.currentSlotNumber++);
        if (state.currentSlotNumber > 9) {
            console.warn(`Warning: Exceeded maximum 9 slots for ${type}. Some sections may not be included.`);
            state.limitHit = true;
            return false;
        }
        state.currentSlot = createEmptySlot();
    }

    if (state.currentSlotNumber > 9) {
        state.limitHit = true;
        return false;
    }

    if (tryPlace()) {
        addToSlot(state.currentSlot, section);
        slotAssignments[section.name] = state.currentSlotNumber;
        return true;
    }

    return false;
}
