// src/command-builder/overrides.ts

import { encodeBase64Url } from '../utils';

export const MAXTHISUNIT_OVERRIDE_INPUTS = [
    { id: 'maxthisunit-t3-builders', section: 'T3_BUILDERS' },
    { id: 'maxthisunit-unit-launchers', section: 'UNIT_LAUNCHERS' },
    { id: 'maxthisunit-epic-ragnarok', section: 'RAGNAROK' },
    { id: 'maxthisunit-epic-calamity', section: 'CALAMITY' },
    { id: 'maxthisunit-epic-tyrannus', section: 'T4_AIR' },
    { id: 'maxthisunit-epic-starfall', section: 'STARFALL' }
];

export function getMaxThisUnitOverrides() {
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

export function formatMultiplierForMarker(multiplier: any) {
    return String(multiplier || '')
        .toUpperCase()
        .replace(/[^0-9A-Z]/g, '_');
}

export function appendMaxSuffix(text: string, limit: number) {
    const base = (text || '').replace(/\s*(?:x\d+\s*Max|-?\s*Max\s*\d+)\s*$/i, '').replace(/\s+$/g, '');
    if (!Number.isFinite(limit) || limit <= 0) {
        return base;
    }
    return `${base} x${limit} Max`;
}

export function updateTextFieldWithMax(code: string, fieldName: string, limit: number) {
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
}

export function injectAideMaxOverrides(code: string, numericValue: number | null) {
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
}

export function applyEpicMaxOverride(code: string, sectionName: string, numericValue: number) {
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
}

// Helper function to calculate encoded size
export function calculateEncodedSize(code: string) {
    try {
        return encodeBase64Url(code).length;
    } catch (e) {
        console.error("Error calculating encoded size:", e);
        return code.length * 1.4; // Estimate
    }
}

export function applyMaxThisUnitOverride(sectionObj: any, maxThisUnitOverrides: any) {
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
}
