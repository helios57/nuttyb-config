// src/command-builder/index.ts

import { packIntoSlots } from '../slot-packer';
import { generateLuaTweakRaw } from '../multiplier-handler';
import {
    getMaxThisUnitOverrides,
    formatMultiplierForMarker,
    applyMaxThisUnitOverride,
    calculateEncodedSize
} from './overrides';
import {
    clearTempSlotFiles,
    encodeAndValidateSlot,
    writeTempSlotFilesToDisk
} from './slot-io';

export interface CommandResult {
    commands: string[];
    sections: string[];
    usedSlots: any;
    slotUsage: {
        tweakdefs: number[];
        tweakunits: number[];
    };
    slotDetails: any[];
    lobbyName: string;
}

/**
 * Generate dynamic slot commands from checked section checkboxes
 * @param {Object} tweakFileCache - Cached tweak file data (file path -> sections array)
 * @returns {Promise<Object>} Commands and used slots
 */
export async function generateCommandsImpl(tweakFileCache: any): Promise<CommandResult | null> {
    console.log("Generating dynamic slot commands...");

    // Use dynamic packing if file cache is available
    if (!tweakFileCache) {
        console.log("Dynamic slot generation not available - file cache not loaded");
        return null;
    }

    const selectedSections: any[] = [];

    const maxThisUnitOverrides = getMaxThisUnitOverrides();

    // Separate Main files from other selections (now includes HP multipliers)
    const mainSections: any = { units: [], defs: [] };  // Arrays to collect multiple sections
    const regularSections: any[] = [];
    const hpSections: any[] = [];

    // 1. CHECK FOR HP MULTIPLIERS FIRST (priority ordering decides placement)
    const hpGenerators = document.querySelectorAll('[data-is-hp-generator="true"]');
    hpGenerators.forEach((el: any) => {
        const multiplier = el.value;
        if (multiplier && multiplier !== "" && multiplier !== "1") {  // Don't include 1x (no change)
            const type = el.dataset.hpType;

            if (typeof generateLuaTweakRaw === 'function') {
                const luaCode = generateLuaTweakRaw(type, multiplier);

                const markerMultiplier = formatMultiplierForMarker(multiplier);
                const markerName = `${type.toUpperCase()}_${markerMultiplier}X_START`;
                const markerEnd = markerName.replace('_START', '_END');

                // Pack HP multipliers as synthetic defs (priority handles placement)
                hpSections.push({
                    name: markerName,
                    code: `--${markerName}\n${luaCode}\n--${markerEnd}`,
                    type: 'defs',
                    lines: luaCode.split('\n').length,
                    rawChars: luaCode.length,
                    encodedChars: calculateEncodedSize(luaCode),
                    file: 'generated-hp-multiplier',
                    marker: markerName,
                    isSynthetic: true,
                    isHpMultiplier: true
                });

                console.log(`Added HP multiplier to defs pool: ${type.toUpperCase()} ${multiplier}x`);
            } else {
                console.warn("generateLuaTweakRaw not available - HP multiplier skipped");
            }
        }
    });

    // Check for Raptor Wave Mode selection (radio group)
    const raptorWaveSelected = document.querySelector('input[name="raptor-wave-mode"]:checked') as HTMLInputElement;
    const raptorWaveValue = raptorWaveSelected ? raptorWaveSelected.value : 'none';
    const primaryModeSelectEl = document.getElementById('primary-mode-select') as HTMLSelectElement;
    const isScavengersMode = primaryModeSelectEl && primaryModeSelectEl.value === 'Scavengers';
    if (!isScavengersMode && raptorWaveValue !== 'none') {
        let fileName = '';
        let sectionName = '';

        if (raptorWaveValue === 'mini_bosses') {
            fileName = 'tweaks/Defs_Waves_Mini_Bosses.lua';
            sectionName = 'MINI_BOSSES';
        } else if (raptorWaveValue === 'experimental_wave') {
            fileName = 'tweaks/Defs_Waves_Experimental_Wave_Challenge.lua';
            sectionName = 'EXP_WAVE';
        }

        if (fileName && tweakFileCache[fileName]) {
            const sections = tweakFileCache[fileName];
            sections.forEach((section: any) => {
                if (section.name.includes(sectionName)) {
                    regularSections.push({
                        ...section,
                        file: fileName
                    });
                    console.log(`Added Raptor Wave Mode: ${raptorWaveValue} - ${section.name}`);
                }
            });
        }
    }

    // Also check for Scavenger HP multipliers (pack as regular defs)
    const scavHpGenerators = document.querySelectorAll('[data-is-scav-hp-generator="true"]');
    scavHpGenerators.forEach((el: any) => {
        const multiplier = el.value;
        if (multiplier && multiplier !== "" && multiplier !== "1") {
            const type = el.dataset.hpType;

            if (typeof generateLuaTweakRaw === 'function') {
                const luaCode = generateLuaTweakRaw(type, multiplier);

                const markerMultiplier = formatMultiplierForMarker(multiplier);
                const markerName = `SCAV_HP_${markerMultiplier}X_START`;
                const markerEnd = markerName.replace('_START', '_END');

                // Pack Scav HP multipliers as synthetic defs (priority handles placement)
                hpSections.push({
                    name: markerName,
                    code: `--${markerName}\n${luaCode}\n--${markerEnd}`,
                    type: 'defs',
                    lines: luaCode.split('\n').length,
                    rawChars: luaCode.length,
                    encodedChars: calculateEncodedSize(luaCode),
                    file: 'generated-scav-hp-multiplier',
                    marker: markerName,
                    isSynthetic: true,
                    isHpMultiplier: true
                });

                console.log(`Added Scav HP multiplier to defs pool: ${type.toUpperCase()} ${multiplier}x`);
            } else {
                console.warn("generateLuaTweakRaw not available - Scav HP multiplier skipped");
            }
        }
    });

    // 2. THEN CHECK MARKER-BASED CHECKBOXES
    const checkedBoxes = document.querySelectorAll('.tweak-checkbox:checked');
    const checkedMarkers = new Set(Array.from(checkedBoxes).map((cb: any) => cb.dataset.marker));
    const hasEvoCommander = ['ARMADA_COMMANDER', 'CORTEX_COMMANDER', 'LEGION_COMMANDER']
        .some(marker => checkedMarkers.has(marker));
    console.log(`Found ${checkedBoxes.length} checked sections`);

    const epicUnitMarkers = ['RAGNAROK', 'CALAMITY', 'STARFALL', 'BASTION', 'SENTINEL', 'FORTRESS'];

    // For each checked section, get section data
    checkedBoxes.forEach((checkbox: any) => {
        const filePath = checkbox.dataset.file;
        const markerName = checkbox.dataset.marker;
        const type = checkbox.dataset.type;

        if (markerName === 'EVO_XP' && !hasEvoCommander) {
            return;
        }

        // Check if this is an epic unit
        if (epicUnitMarkers.some(marker => markerName.includes(marker))) {
            console.log(`Epic unit detected: ${markerName}`);
        }

        // Find section in cache
        if (tweakFileCache[filePath]) {
            const section = tweakFileCache[filePath].find((s: any) => s.name === markerName);
            if (section) {
                let sectionData = {
                    ...section,
                    file: filePath,
                    type: type
                };

                sectionData = applyMaxThisUnitOverride(sectionData, maxThisUnitOverrides);

                // Check if this is a Main file (should go to slot 0)
                if (filePath.includes('Units_Main.lua') || filePath.includes('Defs_Main.lua')) {
                    if (type === 'units') {
                        mainSections.units.push(sectionData);  // Add to array instead of replacing
                    } else if (type === 'defs') {
                        mainSections.defs.push(sectionData);  // Add to array instead of replacing
                    }
                    console.log(`Main section selected: ${markerName} from ${filePath}`);
                } else {
                    regularSections.push(sectionData);
                    console.log(`Selected: ${markerName} from ${filePath}`);
                }
            }
        }
    });

    if (hasEvoCommander) {
        const evoXpAlreadySelected = regularSections.some((section: any) => section.name === 'EVO_XP')
            || mainSections.units.some((section: any) => section.name === 'EVO_XP')
            || mainSections.defs.some((section: any) => section.name === 'EVO_XP');

        if (!evoXpAlreadySelected) {
            let evoSection = null;
            let evoFilePath = null;

            for (const [filePath, sections] of Object.entries(tweakFileCache) as any) {
                const found = (sections as any[]).find(section => section.name === 'EVO_XP');
                if (found) {
                    evoSection = found;
                    evoFilePath = filePath;
                    break;
                }
            }

            if (evoSection && evoFilePath) {
                const sectionData = applyMaxThisUnitOverride({
                    ...evoSection,
                    file: evoFilePath,
                    type: (evoSection as any).type
                }, maxThisUnitOverrides);
                regularSections.push(sectionData);
                console.log('Auto-enabled EVO_XP for evolving commanders');
            } else {
                console.warn('EVO_XP section not found; skipping auto-enable');
            }
        }
    }

    // Add HP multipliers and regular sections to selectedSections
    selectedSections.push(...hpSections, ...regularSections);

    // Check if we have any selections (Main, HP, or regular)
    if (selectedSections.length === 0 && mainSections.units.length === 0 && mainSections.defs.length === 0) {
        console.warn("No sections selected for slot packing");
        return {
            commands: [],
            sections: [],
            usedSlots: { tweakdefs: new Set(), tweakunits: new Set() },
            slotUsage: { tweakdefs: [], tweakunits: [] },
            slotDetails: [],
            lobbyName: ''
        };
    }

    const commands: string[] = [];
    const usedSlots: { tweakdefs: Set<number>; tweakunits: Set<number> } = { tweakdefs: new Set(), tweakunits: new Set() };
    const slotMetadata: any[] = [];

    // Clear old temp files before generating new ones
    clearTempSlotFiles();

    // First, handle Main sections (slot 0)
    if (mainSections.units.length > 0) {
        const unitMainMeta = encodeAndValidateSlot('tweakunits', 0, mainSections.units, commands, usedSlots);
        if (unitMainMeta) {
            slotMetadata.push(unitMainMeta);
        }
    }

    if (mainSections.defs.length > 0) {
        const defMainMeta = encodeAndValidateSlot('tweakdefs', 0, mainSections.defs, commands, usedSlots);
        if (defMainMeta) {
            slotMetadata.push(defMainMeta);
        }
    }

    // Then pack regular sections into numbered slots
    let packed: any = { tweakunits: [], tweakdefs: [] };

    const limits = {
        maxLines: 700,
        maxRaw: 22000,
        maxEncoded: 12000,  // Target ~12k to leave headroom under 13k cap
        bufferPct: 0.9
    };

    if (selectedSections.length > 0) {
        console.log(`Packing ${selectedSections.length} regular sections into numbered slots...`);

        // Load slot distribution schema if available
        let slotDistribution = null;
        try {
            if (typeof (window as any).slotDistributionData !== 'undefined' && (window as any).slotDistributionData) {
                slotDistribution = (window as any).slotDistributionData;
                console.log("Using slot distribution schema from slotDistributionData");
            }
        } catch (e) {
            console.warn("Could not load slot distribution schema:", e);
        }

        // Load dependency table if available
        const dependencyTable = (typeof (window as any).tweakDependencyTable !== 'undefined' && (window as any).tweakDependencyTable)
            ? (window as any).tweakDependencyTable
            : null;
        const dependencyMap = dependencyTable && dependencyTable.deps ? dependencyTable.deps : null;
        const packerDeps = dependencyMap ? { dependencyMap } : null;

        packed = packIntoSlots(selectedSections, limits, slotDistribution, packerDeps);
    } else {
        // No regular sections to pack
        console.log("No regular sections to pack into numbered slots");
    }

    // Sort slots by slot number for sequential display
    packed.tweakunits.sort((a: any, b: any) => a.slotNum - b.slotNum);
    packed.tweakdefs.sort((a: any, b: any) => a.slotNum - b.slotNum);

    // Generate commands for all packed slots using the helper function
    for (const slot of packed.tweakunits) {
        const unitMeta = encodeAndValidateSlot('tweakunits', slot.slotNum, slot.sections, commands, usedSlots, { slotLabel: slot.label });
        if (unitMeta) {
            slotMetadata.push(unitMeta);
        }
    }

    for (const slot of packed.tweakdefs) {
        const defMeta = encodeAndValidateSlot('tweakdefs', slot.slotNum, slot.sections, commands, usedSlots, { slotLabel: slot.label });
        if (defMeta) {
            slotMetadata.push(defMeta);
        }
    }

    // Write all queued temp slot files to disk
    await writeTempSlotFilesToDisk();

    return {
        commands,
        sections: commands,
        usedSlots,
        slotUsage: {
            tweakdefs: Array.from(usedSlots.tweakdefs).sort((a: any, b: any) => a - b),
            tweakunits: Array.from(usedSlots.tweakunits).sort((a: any, b: any) => a - b)
        },
        slotDetails: slotMetadata,
        lobbyName: '' // Placeholder
    };
}
