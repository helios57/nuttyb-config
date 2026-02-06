// src/slot-packer/sizing.ts

import { normalizeSectionName } from '../helpers/slot-utils';
import { encodeBase64Url } from '../utils';

// Allow a small tolerance when using minified size estimates to avoid rejecting
// sections that will fit after final slot minification.
export const MINIFIED_SIZE_TOLERANCE = 1.01; // ~1% headroom to reduce overflow risk

const COMMANDER_SECTION_IDS = new Set([
    'ARMADA_COMMANDER',
    'CORTEX_COMMANDER',
    'LEGION_COMMANDER'
]);

export function isCommanderSection(section: any) {
    return !!(section && COMMANDER_SECTION_IDS.has(section.name));
}

export function slotHasCommander(slot: any) {
    return Array.isArray(slot?.sections) && slot.sections.some(isCommanderSection);
}

export function bundleHasCommander(bundle: any) {
    return Array.isArray(bundle?.sections) && bundle.sections.some(isCommanderSection);
}

export function getSectionMinifiedEstimate(section: any) {
    if (!section) return 0;
    if (typeof section.minifiedEncodedEstimate === 'number') {
        return section.minifiedEncodedEstimate;
    }
    const estimate = estimateMinifiedEncoded(section.code || '');
    section.minifiedEncodedEstimate = estimate;
    return estimate;
}

export function formatSizeInfo(lines: number, raw: number, enc: number, minEnc: number, limits: any) {
    const parts = [];
    if (typeof lines === 'number') parts.push(`lines ${lines}/${limits.maxLines}`);
    if (typeof raw === 'number') parts.push(`raw ${raw}/${limits.maxRaw}`);
    if (typeof enc === 'number') parts.push(`enc ${enc}/${limits.maxEncoded}`);
    if (typeof minEnc === 'number') parts.push(`minEnc ${minEnc}/${Math.round(limits.maxEncoded * MINIFIED_SIZE_TOLERANCE)}`);
    return parts.join(', ');
}

/**
 * Get display label for a slot based on sections it contains
 * @param {Array} sections - Array of section objects with name property
 * @returns {string} Label for slot - concatenated section names
 */
export function getSlotLabel(sections: any[]) {
    if (!sections || sections.length === 0) {
        return 'EMPTY';
    }

    // Collect all unique section names directly (no label mapping)
    const sectionNames = new Set<string>();

    for (const section of sections) {
        sectionNames.add(section.name);
    }

    // Convert Set to array and sort for consistency
    const uniqueNames = Array.from(sectionNames).sort();

    const mappedNames = uniqueNames
        .map(normalizeSectionName)
        .filter((name): name is string => !!name);
    const uniqueLabels = Array.from(new Set(mappedNames));

    if (uniqueLabels.length === 1) {
        return uniqueLabels[0];
    }

    // Multiple sections - concatenate them with underscores
    const concatenated = uniqueLabels.join('_');

    // If too long (>50 chars), use abbreviated form
    if (concatenated.length > 50) {
        return uniqueLabels.map(name => name.substring(0, 4)).join('_');
    }

    return concatenated;
}

/**
 * Estimate base64url encoded length after light minification (mirrors command-builder fallback)
 * @param {string} code - Lua code to estimate
 * @returns {number} Estimated encoded length
 */
export function estimateMinifiedEncoded(code: string) {
    if (!code) return 0;

    let minified = code;

    if (typeof window !== 'undefined' &&
        (window as any).LuaMinifier &&
        typeof (window as any).LuaMinifier.minify === 'function') {
        try {
            minified = (window as any).LuaMinifier.minify(code);
        } catch (e) {
            // fall through to manual compression
        }
    }

    minified = minified
        .replace(/--(?!\s*[A-Z_][A-Z0-9_]*(?:_START|_END)?)[^\n\r]*/g, '')
        .replace(/\n+/g, ' ')
        .replace(/\s+/g, ' ')
        .replace(/\s*([{}(),=;])\s*/g, '$1')
        .trim();

    try {
        if (typeof window !== 'undefined' && typeof encodeBase64Url === 'function') {
            return encodeBase64Url(minified, true).length;
        }
    } catch (e) {
        // ignore and fallback
    }

    try {
        if (typeof Buffer !== 'undefined') {
            return Buffer.from(minified).toString('base64').replace(/=+$/, '').length;
        }
    } catch (e) {
        // ignore and fallback
    }

    return Math.ceil(minified.length * 4 / 3);
}

/**
 * Check if an entire bundle can fit into a slot
 * @param {Object} slot - Slot object
 * @param {Object} bundle - Bundle with aggregated metrics
 * @param {Object} limits - Limit configuration
 * @returns {boolean} True if bundle fits
 */
export function canBundleFitInSlot(slot: any, bundle: any, limits: any) {
    const slotContainsCommander = slotHasCommander(slot);
    const bundleContainsCommander = bundleHasCommander(bundle);

    if (slotContainsCommander) {
        return false; // Commander slots cannot accept additional sections
    }

    if (bundleContainsCommander && slot.sections.length > 0) {
        return false; // Commanders must occupy a dedicated slot
    }

    const newLines = slot.lines + bundle.lines;
    const newRaw = slot.rawChars + bundle.rawChars;
    const newEncoded = slot.encodedChars + bundle.encodedChars;
    const newMinifiedEncoded = slot.minifiedEncodedChars + (bundle.minifiedEncodedChars || bundle.encodedChars);

    if (newLines > limits.maxLines || newRaw > limits.maxRaw) {
        return false;
    }

    if (newEncoded <= limits.maxEncoded) {
        return true;
    }

    return newMinifiedEncoded <= limits.maxEncoded * MINIFIED_SIZE_TOLERANCE;
}

/**
 * Add an entire bundle to a slot (aggregated to reduce per-section math)
 * @param {Object} slot - Slot object
 * @param {Object} bundle - Bundle to add
 */
export function addBundleToSlot(slot: any, bundle: any) {
    bundle.sections.forEach((section: any) => {
        slot.sections.push(section);
    });
    slot.lines += bundle.lines;
    slot.rawChars += bundle.rawChars;
    slot.encodedChars += bundle.encodedChars;
    slot.minifiedEncodedChars += bundle.minifiedEncodedChars || bundle.encodedChars;
}

/**
 * Check dependencies for a full bundle against existing slot assignments
 * @param {number} targetSlotNumber - Slot number we plan to place the bundle in
 * @param {Object} bundle - Bundle to validate
 * @param {Object} slotAssignments - Map of section name -> slot number
 * @param {Object} dependencyMap - Map of dependencies
 * @returns {boolean} True if dependencies are satisfied
 */
export function canBundleRespectDependencies(targetSlotNumber: number, bundle: any, slotAssignments: any, dependencyMap: any) {
    for (const section of bundle.sections) {
        const deps = dependencyMap[section.name] || [];
        for (const dep of deps) {
            const depSlot = slotAssignments[dep];
            if (depSlot !== undefined && depSlot > targetSlotNumber) {
                return false;
            }
        }
    }
    return true;
}

/**
 * Check if adding section to slot respects dependency constraints
 * Dependencies must be in same or earlier slot than the dependent
 * @param {Object} slot - Current slot
 * @param {Object} section - Section to add
 * @param {Object} slotAssignments - Map of section name -> slot number
 * @param {Object} dependencyMap - Map of dependencies
 * @returns {boolean} True if dependencies are respected
 */
export function canRespectDependencies(slot: any, section: any, slotAssignments: any, dependencyMap: any) {
    const deps = dependencyMap[section.name] || [];
    const currentSlotNum = Math.max(...slot.sections.map((s: any) => slotAssignments[s.name] || 0), 0) + 1;

    for (const dep of deps) {
        const depSlot = slotAssignments[dep];
        if (depSlot !== undefined && depSlot > currentSlotNum) {
            // Dependency is in a later slot - violation!
            return false;
        }
    }

    return true;
}

/**
 * Create empty slot object
 * @returns {Object} Empty slot
 */
export function createEmptySlot() {
    return {
        slotNum: 0,
        sections: [],
        lines: 0,
        rawChars: 0,
        encodedChars: 0,
        minifiedEncodedChars: 0,
        label: 'EMPTY'  // Will be calculated when slot is finalized
    };
}

/**
 * Check if section can fit in slot
 * @param {Object} slot - Slot object
 * @param {Object} section - Section metadata
 * @param {Object} limits - Limit configuration
 * @returns {boolean} True if fits
 */
export function canFitInSlot(slot: any, section: any, limits: any) {
    const slotContainsCommander = slotHasCommander(slot);
    const sectionIsCommander = isCommanderSection(section);

    if (slotContainsCommander) {
        return false; // Do not mix anything into a commander slot
    }

    if (sectionIsCommander && slot.sections.length > 0) {
        return false; // Commanders must be alone
    }

    const newLines = slot.lines + section.lines;
    const newRaw = slot.rawChars + section.rawChars;
    const newEncoded = slot.encodedChars + section.encodedChars;
    const newMinifiedEncoded = slot.minifiedEncodedChars + getSectionMinifiedEstimate(section);

    if (newLines > limits.maxLines || newRaw > limits.maxRaw) {
        return false;
    }

    if (newEncoded <= limits.maxEncoded) {
        return true;
    }

    return newMinifiedEncoded <= limits.maxEncoded * MINIFIED_SIZE_TOLERANCE;
}

/**
 * Add section to slot
 * @param {Object} slot - Slot object
 * @param {Object} section - Section metadata
 */
export function addToSlot(slot: any, section: any) {
    slot.sections.push(section);
    slot.lines += section.lines;
    slot.rawChars += section.rawChars;
    slot.encodedChars += section.encodedChars;
    slot.minifiedEncodedChars += getSectionMinifiedEstimate(section);
}

/**
 * Validate slot against limits AFTER final encoding
 * @param {Object} slot - Slot object
 * @param {Array} sections - Sections to combine and encode
 * @param {Object} limits - Limit configuration
 * @param {Function} encodeFunc - Function to perform final encoding (e.g., window.encodeBase64Url)
 * @returns {Object} Validation result { valid: boolean, violations: [], finalEncodedSize: number }
 */
export function validateSlotAfterEncoding(slot: any, sections: any[], limits: any, encodeFunc: (s: string) => string) {
    const violations = [];
    let finalEncodedSize = 0;

    // First check pre-encoding limits
    if (slot.lines > limits.maxLines) {
        violations.push(`Lines: ${slot.lines} > ${limits.maxLines}`);
    }
    if (slot.rawChars > limits.maxRaw) {
        violations.push(`Raw chars: ${slot.rawChars} > ${limits.maxRaw}`);
    }
    if (slot.encodedChars > limits.maxEncoded) {
        violations.push(`Estimated encoded chars: ${slot.encodedChars} > ${limits.maxEncoded}`);
    }

    // If encoding function provided, check actual final encoded size
    if (encodeFunc && sections && sections.length > 0) {
        try {
            const combinedCode = sections.map(s => s.code).join('\n\n');
            const actualEncoded = encodeFunc(combinedCode);
            finalEncodedSize = actualEncoded.length;

            if (finalEncodedSize > limits.maxEncoded) {
                violations.push(`CRITICAL - Final encoded size: ${finalEncodedSize} > ${limits.maxEncoded} (game limit)`);
            }
        } catch (e: any) {
            violations.push(`Error during final encoding validation: ${e.message}`);
        }
    }

    return {
        valid: violations.length === 0,
        violations,
        finalEncodedSize
    };
}

/**
 * Validate slot against limits
 * @param {Object} slot - Slot object
 * @param {Object} limits - Limit configuration
 * @returns {Object} Validation result { valid: boolean, violations: [] }
 */
export function validateSlot(slot: any, limits: any) {
    const violations = [];

    if (slot.lines > limits.maxLines) {
        violations.push(`Lines: ${slot.lines} > ${limits.maxLines}`);
    }
    if (slot.rawChars > limits.maxRaw) {
        violations.push(`Raw chars: ${slot.rawChars} > ${limits.maxRaw}`);
    }
    if (slot.encodedChars > limits.maxEncoded) {
        violations.push(`Encoded chars: ${slot.encodedChars} > ${limits.maxEncoded}`);
    }

    return {
        valid: violations.length === 0,
        violations
    };
}

/**
 * Combine code from multiple sections
 * @param {Array} sections - Array of section metadata
 * @returns {string} Combined code
 */
export function combineCodeSections(sections: any[]) {
    return sections.map(s => s.code).join('\n\n');
}

/**
 * Generate slot summary for logging
 * @param {Object} slot - Slot object
 * @param {string} slotType - 'tweakunits' or 'tweakdefs'
 * @param {number} [maxEncodedOverride] - Optional encoded cap to compute utilization
 * @returns {string} Summary string
 */
export function getSlotSummary(slot: any, slotType: string, maxEncodedOverride?: number) {
    const sectionNames = slot.sections.map((s: any) => s.name).join(', ');
    const MAX_ENCODED_SIZE = typeof maxEncodedOverride === 'number' ? maxEncodedOverride : 13000;
    const utilization = Math.round(slot.encodedChars / MAX_ENCODED_SIZE * 100);

    return `${slotType}${slot.slotNum}: ${slot.sections.length} sections (${sectionNames}) - ${slot.lines}L, ${slot.rawChars}R, ${slot.encodedChars}E (${utilization}%)`;
}

/**
 * Apply labels to all slots
 * @param {Array} slots - Slots to label
 */
export function labelSlots(slots: any[]) {
    slots.forEach(slot => {
        slot.label = getSlotLabel(slot.sections);
    });
}

/**
 * Log slot allocation summary
 * @param {Array} slots - Slots
 * @param {Object} config - Limit configuration
 * @param {string} type - Slot type label
 */
export function logSlotAllocation(slots: any[], config: any, type: string) {
    if (typeof window !== 'undefined' && !(window as any).DEBUG_SLOT_PACKER) {
        return;
    }
    const lastSlotNumber = slots.length > 0 ? slots[slots.length - 1].slotNum : 0;
    console.log(`Dynamic packing for ${type}: ${slots.length} slots allocated (1-${lastSlotNumber})`);
    slots.forEach(slot => {
        console.log(`  Slot ${slot.slotNum} [${slot.label}]: ${getSlotSummary(slot, type, config.maxEncoded)}`);
    });
}
