// src/command-builder/compression.ts

import { minify } from '../lua-minifier';

export function compressSlotSection(section: string) {
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

export function minifySlotBody(content: string) {
    let contentToSave = content || '';

    try {
        contentToSave = minify(contentToSave);
    } catch (e: any) {
        console.warn(`Could not minify slot body: ${e.message}`);
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
