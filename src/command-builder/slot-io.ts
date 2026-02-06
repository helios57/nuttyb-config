// src/command-builder/slot-io.ts

import { normalizeSectionName } from '../helpers/slot-utils';
import { getPriorityMeta } from '../helpers/priority-utils';
import { encodeBase64Url } from '../utils';
import { minifySlotBody } from './compression';

// Global array to collect slot files for batch saving
let pendingSlotFiles: any[] = [];

export function isLocalSlotWriterAvailable() {
    if (typeof window === 'undefined' || !window.location || !window.location.hostname) {
        return false;
    }

    const host = window.location.hostname;
    return host === 'localhost' || host === '127.0.0.1';
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

export function clearTempSlotFiles() {
    pendingSlotFiles = [];
    console.log(`ðŸ—‘ï¸  Cleared pending slot files queue`);
}

export function encodeAndValidateSlot(slotType: string, slotNum: number, sections: any[], commands: string[], usedSlots: any, options: any = {}) {
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

export async function writeTempSlotFilesToDisk() {
    if (pendingSlotFiles.length === 0) {
        console.log('No pending slot files to write');
        return;
    }

    if (!isLocalSlotWriterAvailable()) {
        console.log('â„¹ï¸  Skipping temp slot writer (not running on localhost).');
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
        console.warn(`âš ï¸  Could not write temp slot files to disk. Make sure temp-slot-writer.js is running.`);
        console.warn(`   Run: node bar-configurator/temp-slot-writer.js`);
        console.warn(`   Error: ${error.message}`);

        // Fallback: log the files that would have been written
        console.log('Files that would have been written:');
        pendingSlotFiles.forEach(file => {
            console.log(`  - ${file.name}.lua (${file.content.length} chars)`);
        });
    }
}
