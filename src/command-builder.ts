// Command Builder module for BAR Configurator
// Generates final commands from user selections and splits into sections

import { normalizeSectionName } from './helpers/slot-utils';
import { getPriorityMeta } from './helpers/priority-utils';
import { encodeBase64Url } from './utils';
import { packIntoSlots, getSlotSummary } from './slot-packer';

// Global array to collect slot files for batch saving
let pendingSlotFiles: any[] = [];

// Only allow the temp slot writer when running locally
function isLocalSlotWriterAvailable() {
    if (typeof window === 'undefined' || !window.location || !window.location.hostname) {
        return false;
    }

    const host = window.location.hostname;
    return host === 'localhost' || host === '127.0.0.1';
}

function formatMultiplierForMarker(multiplier: any) {
    return String(multiplier || '')
        .toUpperCase()
        .replace(/[^0-9A-Z]/g, '_');
}

function compressSlotSection(section: string) {
    // String-aware compaction: preserve string literals, trim around punctuation elsewhere
    let result = '';
    let inString = false;
    let stringChar = '';
    let buffer = '';

    const flushBuffer = () => {
        if (!buffer) return;
        // trim whitespace runs and spaces around punctuation in buffer (non-string code only)
        const compacted = buffer
            .replace(/\s*([{}(),=;])\s*/g, '$1')
            .replace(/\s+/g, ' ')
            .trim();
        result += compacted;
        buffer = '';
    };

    for (let i = 0; i < section.length; i++) {
        const ch = section[i];
        const prev = i > 0 ? section[i - 1] : '';

        if ((ch === '"' || ch === "'") && prev !== '\\') {
            if (!inString) {
                flushBuffer();
                inString = true;
                stringChar = ch;
                result += ch;
            } else if (ch === stringChar) {
                inString = false;
                stringChar = '';
                result += ch;
            } else {
                result += ch;
            }
            continue;
        }

        if (inString) {
            result += ch;
            continue;
        }

        // Outside strings: accumulate for compaction
        if (ch === '\n') {
            buffer += ' ';
        } else {
            buffer += ch;
        }
    }

    flushBuffer();
    return result.trim();
}

function minifySlotBody(content: string) {
    let contentToSave = content || '';

    if (contentToSave && (window as any).LuaMinifier && typeof (window as any).LuaMinifier.minify === 'function') {
        try {
            contentToSave = (window as any).LuaMinifier.minify(contentToSave);
        } catch (e: any) {
            console.warn(`Could not minify slot body: ${e.message}`);
        }
    }

    const sections = contentToSave.split('\n\n');
    const processedSections: string[] = [];

    for (const section of sections) {
        if (!section) continue;

        const markerMatch = section.match(/^(--\s*[A-Z_][A-Z0-9_]*(?:_START|_END)?)\s*\n([\s\S]*)$/);
        if (markerMatch) {
            const marker = markerMatch[1];
            const code = compressSlotSection(markerMatch[2]);
            processedSections.push(code ? `${marker}\n${code}` : marker);
        } else {
            const minified = compressSlotSection(section);
            if (minified) {
                processedSections.push(minified);
            }
        }
    }

    return processedSections.join('\n\n');
}

function deriveSlotLabelFromSections(sections: any[]) {
    if (!sections || sections.length === 0) {
        return 'EMPTY';
    }

    const uniqueNames = Array.from(new Set(
        sections
            .map(section => section && section.name)
            .filter(Boolean)
    ));

    if (uniqueNames.length === 0) {
        return 'EMPTY';
    }

    const mapped = uniqueNames
        .map(normalizeSectionName)
        .filter((name): name is string => !!name);
    const uniqueLabels = Array.from(new Set(mapped));

    return uniqueLabels.join('_') || 'EMPTY';
}

const SLOT_LABEL_MAX_LENGTH = 12;

function sanitizeSlotLabel(label: string) {
    if (!label) {
        return 'EMPTY';
    }

    const normalized = label
        .toUpperCase()
        .replace(/[^A-Z0-9]+/g, '_')
        .replace(/^_+|_+$/g, '');

    if (!normalized) {
        return 'EMPTY';
    }

    if (normalized.length <= SLOT_LABEL_MAX_LENGTH) {
        return normalized;
    }

    const parts = normalized.split('_').filter(Boolean);
    if (parts.length === 0) {
        return normalized.slice(0, SLOT_LABEL_MAX_LENGTH);
    }

    let result = '';
    for (const part of parts) {
        const needsJoin = result.length > 0;
        const available = SLOT_LABEL_MAX_LENGTH - result.length - (needsJoin ? 1 : 0);
        if (available <= 0) {
            break;
        }

        const chunk = part.slice(0, available);
        if (!chunk) {
            continue;
        }

        result += (needsJoin ? '_' : '') + chunk;

        if (result.length >= SLOT_LABEL_MAX_LENGTH) {
            break;
        }
    }

    return result || normalized.slice(0, SLOT_LABEL_MAX_LENGTH);
}

const MAXTHISUNIT_OVERRIDE_INPUTS = [
    { id: 'maxthisunit-t3-builders', section: 'T3_BUILDERS' },
    { id: 'maxthisunit-unit-launchers', section: 'UNIT_LAUNCHERS' },
    { id: 'maxthisunit-epic-ragnarok', section: 'RAGNAROK' },
    { id: 'maxthisunit-epic-calamity', section: 'CALAMITY' },
    { id: 'maxthisunit-epic-tyrannus', section: 'T4_AIR' },
    { id: 'maxthisunit-epic-starfall', section: 'STARFALL' }
];

const WELCOME_MESSAGE_CMD = '$welcome-message NuttyB ModSettings made with https://relicus.github.io/pyrem-bar-nuttyconfigurator';

function getMaxThisUnitOverrides() {
    const overrides: any = {};

    MAXTHISUNIT_OVERRIDE_INPUTS.forEach(cfg => {
        const input = document.getElementById(cfg.id) as HTMLInputElement;
        if (!input) {
            return;
        }

        const rawValue = (input.value || '').trim();
        const effectiveValue = (input.dataset.effectiveValue || '').trim();
        const candidate = effectiveValue || rawValue;
        if (candidate === '') {
            return;
        }

        const normalized = candidate === '∞' ? '0' : candidate;
        const parsed = Number.parseInt(normalized, 10);
        if (Number.isFinite(parsed) && parsed >= 0) {
            overrides[cfg.section] = parsed;
        }
    });

    return overrides;
}

function buildSlotSummaryLine(slotType: string, slotNum: number, sections: any[], slotLabel?: string) {
    const normalizeMarker = (m: string) => m.replace(/_(START|END)$/, '');

    const syntheticMarkers = sections
        .filter(s => s && s.isSynthetic && s.marker)
        .map(s => normalizeMarker(s.marker));
    if (syntheticMarkers.length > 0) {
        return `--${sanitizeSlotLabel(syntheticMarkers.join('_'))}`;
    }

    const labelSource = slotLabel || deriveSlotLabelFromSections(sections);
    const summaryLabel = sanitizeSlotLabel(labelSource);

    return `--${summaryLabel}`;
}

function isHpPrioritySection(section: any) {
    if (!section) {
        return false;
    }

    const marker = typeof section.marker === 'string' ? section.marker : '';
    const name = typeof section.name === 'string' ? section.name : '';
    const key = marker || name;

    return /^(HP|QHP|SCAV_HP|BOSS_HP)_/i.test(key);
}

function orderSectionsForSlotExecution(sections: any[]) {
    if (!Array.isArray(sections) || sections.length <= 1) {
        return Array.isArray(sections) ? sections : [];
    }

    const fallbackPriority = (section: any) => (isHpPrioritySection(section) ? 0 : 10);
    const getPriority = (section: any) => {
        if (section && typeof section.priorityRank === 'number') {
            return section.priorityRank;
        }
        const meta = getPriorityMeta(section, section.type || 'defs');
        if (meta && typeof meta.priorityRank === 'number') {
            return meta.priorityRank;
        }
        return fallbackPriority(section);
    };
    const getTier = (section: any) => {
        if (section && typeof section.tierRank === 'number') {
            return section.tierRank;
        }
        const meta = getPriorityMeta(section, section.type || 'defs');
        if (meta && typeof meta.tierRank === 'number') {
            return meta.tierRank;
        }
        return 99;
    };

    return [...sections].sort((a, b) => {
        const aPriority = getPriority(a);
        const bPriority = getPriority(b);
        if (aPriority !== bPriority) {
            return aPriority - bPriority;
        }

        const aTier = getTier(a);
        const bTier = getTier(b);
        if (aTier !== bTier) {
            return aTier - bTier;
        }

        const aLine = typeof a.startLine === 'number' ? a.startLine : 0;
        const bLine = typeof b.startLine === 'number' ? b.startLine : 0;
        if (aLine !== bLine) {
            return aLine - bLine;
        }

        const aName = String(a?.name || '');
        const bName = String(b?.name || '');
        return aName.localeCompare(bName);
    });
}

/**
 * Queue slot content for saving to temporary file
 * @param {string} slotName - Name of the slot (e.g., 'tweakdefs0', 'tweakunits1')
 * @param {string} content - Raw Lua content to save
 * @param {Object} options - Additional options ({ summaryLine, preMinified })
 */
function saveTempSlotFile(slotName: string, content: string, options: any = {}) {
    const { summaryLine = null, preMinified = false } = options;
    const rawLength = content ? content.length : 0;

    let contentToSave = preMinified ? (content || '') : minifySlotBody(content || '');

    if (summaryLine) {
        const summary = summaryLine.trim();
        if (summary) {
            contentToSave = contentToSave ? `${summary}\n${contentToSave}` : summary;
        }
    }

    pendingSlotFiles.push({
        name: slotName,
        content: contentToSave
    });

    console.log(`Queued ${slotName} for saving (${contentToSave.length} chars from ${rawLength} raw chars)`);

    return contentToSave;
}

/**
 * Clear pending slot files array
 */
function clearTempSlotFiles() {
    pendingSlotFiles = [];
    console.log(`ðŸ—‘ï¸ Cleared pending slot files queue`);
}

/**
 * Helper function to encode and validate a slot
 * @param {string} slotType - Type of slot ('tweakunits' or 'tweakdefs')
 * @param {number|string} slotNum - Slot number (0 for main, 1+ for others)
 * @param {Array} sections - Array of section objects with code property
 * @param {Object} commands - Array to push commands to
 * @param {Object} usedSlots - Object tracking used slots
 * @param {Object} [options] - Additional metadata (e.g., slotLabel)
 * @returns {boolean} Success status
 */
function encodeAndValidateSlot(slotType: string, slotNum: number, sections: any[], commands: string[], usedSlots: any, options: any = {}) {
    try {
        const orderedSections = orderSectionsForSlotExecution(sections);

        // Combine all sections (ordered for execution)
        const combinedCode = orderedSections.map(s => s.code).join('\n\n');
        const rawCombinedLength = combinedCode.length;

        // Save temp file before encoding
        const slotName = slotNum === 0 ? slotType : `${slotType}${slotNum}`;
        const summaryLine = buildSlotSummaryLine(slotType, slotNum, orderedSections, options.slotLabel);
        const finalContent = saveTempSlotFile(slotName, combinedCode, { summaryLine });

        // Encode to base64
        const base64url = encodeBase64Url(finalContent, true);
        const actualEncodedSize = base64url.length;
        const utilizationPct = Math.round(actualEncodedSize / 13000 * 100);

        // Validate final encoded size (13k limit)
        const isArmadaCommander = sections.length === 1 && sections[0].name === 'ARMADA_COMMANDER';

        if (!isArmadaCommander && actualEncodedSize > 13000) {
            const errMsg = `SLOT SIZE ERROR: ${slotName} exceeds 13k limit (${actualEncodedSize}/13000). Split sections further.`;
            console.error(errMsg);
            console.error(`   Sections: ${sections.map(s => s.name).join(', ')}`);
            throw new Error(errMsg);
        } else {
            if (actualEncodedSize > 12000) {
                console.warn(`- ${slotName}: ${actualEncodedSize}/13000 chars (${utilizationPct}%) â€” approaching 13k limit, consider splitting.`);
            } else {
                console.log(`- ${slotName}: ${sections.length} sections - Final: ${actualEncodedSize}/${13000} chars (${utilizationPct}%)`);
            }
        }

        // Generate command
        const command = slotNum === 0
            ? `!bset ${slotType} ${base64url}`  // No number for slot 0
            : `!bset ${slotType}${slotNum} ${base64url}`;

        commands.push(command);
        usedSlots[slotType].add(slotNum);

        const sectionNames = orderedSections.map(s => s.name || 'UNKNOWN');
        const sectionFiles = Array.from(new Set(orderedSections.map(s => s.file || 'unknown')));

        return {
            slotType,
            slotNum,
            slotName,
            slotLabel: (summaryLine || '').replace(/^--/, '') || 'EMPTY',
            summaryLine,
            sectionCount: sections.length,
            sectionNames,
            sectionFiles,
            rawSectionChars: rawCombinedLength,
            minifiedLength: finalContent.length,
            encodedSize: actualEncodedSize,
            utilizationPct,
            command
        };
    } catch (error) {
        const slotName = slotNum === 0 ? slotType : `${slotType}${slotNum}`;
        console.error(`Error encoding ${slotName}:`, error);
        return null;
    }
}

/**
 * Write all pending slot files to disk via the temp-slot-writer server
 */
async function writeTempSlotFilesToDisk() {
    if (pendingSlotFiles.length === 0) {
        console.log('No pending slot files to write');
        return;
    }

    if (!isLocalSlotWriterAvailable()) {
        console.log('â„¹ï¸ Skipping temp slot writer (not running on localhost).');
        console.log('Files that would have been written:');
        pendingSlotFiles.forEach(file => {
            console.log(`  - ${file.name}.lua (${file.content.length} chars)`);
        });
        return;
    }

    try {
        const response = await fetch('http://localhost:3456/save-slots', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                clearFirst: true,  // Clear old files before writing new ones
                slots: pendingSlotFiles
            })
        });

        if (response.ok) {
            const result = await response.json();
            console.log(`âœ… ${result.message}`);
            pendingSlotFiles = [];  // Clear the queue
        } else {
            throw new Error(`Server responded with ${response.status}`);
        }
    } catch (error: any) {
        console.warn(`âš ï¸ Could not write temp slot files to disk. Make sure temp-slot-writer.js is running.`);
        console.warn(`   Run: node bar-configurator/temp-slot-writer.js`);
        console.warn(`   Error: ${error.message}`);

        // Fallback: log the files that would have been written
        console.log('Files that would have been written:');
        pendingSlotFiles.forEach(file => {
            console.log(`  - ${file.name}.lua (${file.content.length} chars)`);
        });
    }
}

/**
 * Generate dynamic slot commands from checked section checkboxes
 * @param {Object} tweakFileCache - Cached tweak file data (file path -> sections array)
 * @param {Function} packIntoSlots - Slot packing function
 * @param {Function} getSlotSummary - Get summary of slot usage
 * @returns {Promise<Object>} Commands and used slots
 */
export async function generateCommandsImpl(tweakFileCache: any) {
    console.log("Generating dynamic slot commands...");

    // Use dynamic packing if file cache is available
    if (!tweakFileCache) {
        console.log("Dynamic slot generation not available - file cache not loaded");
        return null;
    }

    const selectedSections: any[] = [];

    // Helper function to calculate encoded size
    function calculateEncodedSize(code: string) {
        try {
            return encodeBase64Url(code).length;
        } catch (e) {
            console.error("Error calculating encoded size:", e);
            return code.length * 1.4; // Estimate
        }
    }

    const maxThisUnitOverrides = getMaxThisUnitOverrides();

    const applyEpicMaxOverride = (code: string, sectionName: string, numericValue: number) => {
        const epicUnitMap: any = {
            RAGNAROK: 'epic_ragnarok',
            CALAMITY: 'epic_calamity',
            STARFALL: 'epic_starfall'
        };
        const unitId = epicUnitMap[sectionName] || 'epic_calamity';
        const valueStr = String(numericValue);
        const valueLine = `maxthisunit=${valueStr},`;

        let replaced = false;
        const updated = code.replace(/maxthisunit\s*=\s*\d+,?/i, match => {
            if (replaced) return match;
            replaced = true;
            return valueLine;
        });
        if (replaced) {
            return updated;
        }

        const insertIntoUnitTable = (input: string) => {
            const insertAfterLine = (pattern: RegExp) => {
                if (!pattern.test(input)) return null;
                return input.replace(pattern, (match, line, indent = '') => {
                    return `${line}${indent}${valueLine}\n`;
                });
            };

            const descPattern = /(\bdescription\s*=\s*.*?,\s*\r?\n)([ \t]*)/i;
            const namePattern = /(\bname\s*=\s*.*?,\s*\r?\n)([ \t]*)/i;

            let next = insertAfterLine(descPattern);
            if (next) return next;

            next = insertAfterLine(namePattern);
            if (next) return next;

            const tableStartPattern = new RegExp(`(a\\.${unitId}\\s*=\\s*b\\([^\\{]*\\{\\s*\\r?\\n)([ \\t]*)`, 'i');
            if (tableStartPattern.test(input)) {
                return input.replace(tableStartPattern, (match, start, indent = '  ') => {
                    return `${start}${indent}${valueLine}\n`;
                });
            }

            return null;
        };

        const injected = insertIntoUnitTable(code);
        if (injected) {
            return injected;
        }

        const ensureRegex = new RegExp(`(ensureBuildOptions\\([^\\)]*'${unitId}'\\))`, 'i');
        if (ensureRegex.test(code)) {
            return code.replace(ensureRegex, `$1\n a.${unitId}.maxthisunit=${valueStr}`);
        }

        const endRegex = new RegExp(`(\\nend\\s*\\n--\\s*${sectionName}_END)`, 'i');
        if (endRegex.test(code)) {
            return code.replace(endRegex, `\n a.${unitId}.maxthisunit=${valueStr}$1`);
        }

        return `${code}\n a.${unitId}.maxthisunit=${valueStr}`;
    };

    
    const appendMaxSuffix = (text: string, limit: number) => {
        const base = (text || '').replace(/\s*(?:x\d+\s*Max|-?\s*Max\s*\d+)\s*$/i, '').replace(/\s+$/g, '');
        if (!Number.isFinite(limit) || limit <= 0) {
            return base;
        }
        return `${base} x${limit} Max`;
    };

    const updateTextFieldWithMax = (code: string, fieldName: string, limit: number) => {
        if (!code || !fieldName) return code;
        const regex = new RegExp(`(${fieldName}\\s*=\\s*)(\\[\\[(.*?)\\]\\]|(['"\`])((?:[^\\\\]|\\\\.|\\n)*?)\\4)`, 'gis');
        return code.replace(regex, (match, prefix, fullValue, multiContent, quote, quotedContent) => {
            const content = typeof multiContent === 'string' ? multiContent : quotedContent;
            const updated = appendMaxSuffix(content, limit);
            if (typeof multiContent === 'string') {
                return `${prefix}[[${updated}]]`;
            }
            const q = quote || '"';
            return `${prefix}${q}${updated}${q}`;
        });
    };

    const injectAideMaxOverrides = (code: string, numericValue: number | null) => {
        // Only adjust the T3 ground aide (m..'t3aide') and air aide (m..'t3airaide') blocks in-place
        const updateBlock = (input: string, callPattern: string) => {
            const replaceRegex = new RegExp(`(${callPattern}[\\s\\S]*?maxthisunit\\s*=\\s*)\\d+`, 'g');
            if (numericValue === null) {
                return input.replace(replaceRegex, (match) => match.replace(/maxthisunit\\s*=\\s*\\d+/i, ''));
            }
            return input.replace(replaceRegex, `$1${numericValue}`);
        };

        // Keep Aide tooltips/descriptions aligned with the applied limit
        const updateAideText = (input: string, callPattern: string) => {
            const blockRegex = new RegExp(`(${callPattern}[\\s\\S]*?\\}\\))`, 'i');
            return input.replace(blockRegex, (block) => {
                let updatedBlock = updateTextFieldWithMax(block, 'i18n_en_tooltip', numericValue!);
                updatedBlock = updateTextFieldWithMax(updatedBlock, 'description', numericValue!);
                return updatedBlock;
            });
        };

        let updated = code;
        updated = updateBlock(updated, "h\\(m\\.\\.\\'decom\\',j,\\s*\\{");      // ground aide
        updated = updateBlock(updated, "h\\('armfify',j,\\s*\\{");            // air aide
        updated = updateAideText(updated, "h\\(m\\.\\.\\'decom\\',j,\\s*\\{"); // ground aide text
        updated = updateAideText(updated, "h\\('armfify',j,\\s*\\{");         // air aide text

        if (numericValue === null) {
            updated = updated
                .replace(/,\\s*,/g, ',')
                .replace(/,\\s*}/g, '}')
                .replace(/(\\r?\\n)\\s*(\\r?\\n)+/g, '$1');
        }

        return updated;
    };

    const applyMaxThisUnitOverride = (sectionObj: any) => {
        if (!sectionObj || !sectionObj.code || !sectionObj.name) {
            return sectionObj;
        }

        const overrideValue = maxThisUnitOverrides[sectionObj.name];
        if (!Number.isFinite(overrideValue)) {
            return sectionObj;
        }

        const numericValue = Math.max(0, Math.floor(overrideValue));
        const appliedValue = numericValue === 0 ? 9999 : numericValue;
        let updatedCode = sectionObj.code;

        if (sectionObj.name === 'T3_BUILDERS') {
            updatedCode = injectAideMaxOverrides(updatedCode, appliedValue);
        } else if (sectionObj.name === 'UNIT_LAUNCHERS' || sectionObj.name === 'T4_AIR') {
            const pattern = /maxthisunit\s*=\s*\d+,?/gi;
            const hasMaxThisUnit = pattern.test(updatedCode);
            if (!hasMaxThisUnit) {
                return sectionObj;
            }

            const replacement = `maxthisunit=${appliedValue},`;
            updatedCode = updatedCode.replace(pattern, replacement);
        } else if (sectionObj.name === 'RAGNAROK' || sectionObj.name === 'CALAMITY' || sectionObj.name === 'STARFALL') {
            updatedCode = applyEpicMaxOverride(updatedCode, sectionObj.name, appliedValue);
        } else {
            return sectionObj;
        }

        // Append or strip the max info in user-facing descriptions/tooltips (skip complex multi-unit T3 builder section)
        if (sectionObj.name !== 'T3_BUILDERS') {
            updatedCode = updateTextFieldWithMax(updatedCode, 'i18n_en_tooltip', appliedValue);
            updatedCode = updateTextFieldWithMax(updatedCode, 'description', appliedValue);
        }

        if (updatedCode === sectionObj.code) {
            return sectionObj;
        }

        return {
            ...sectionObj,
            code: updatedCode,
            lines: updatedCode.split('\n').length,
            rawChars: updatedCode.length,
            encodedChars: calculateEncodedSize(updatedCode)
        };
    };

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

            if (typeof (window as any).generateLuaTweakRaw === 'function') {
                const luaCode = (window as any).generateLuaTweakRaw(type, multiplier);

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

            if (typeof (window as any).generateLuaTweakRaw === 'function') {
                const luaCode = (window as any).generateLuaTweakRaw(type, multiplier);

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

                sectionData = applyMaxThisUnitOverride(sectionData);

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
        const evoXpAlreadySelected = regularSections.some(section => section.name === 'EVO_XP')
            || mainSections.units.some(section => section.name === 'EVO_XP')
            || mainSections.defs.some(section => section.name === 'EVO_XP');

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
                });
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
        return { commands: [], usedSlots: { tweakdefs: new Set(), tweakunits: new Set() }, slotDetails: [] };
    }

    const commands: string[] = [];
    const usedSlots: any = { tweakdefs: new Set(), tweakunits: new Set() };
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

    return { commands, usedSlots, slotDetails: slotMetadata };
}
