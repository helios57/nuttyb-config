// slot-scanner.js
// Scans tweak files for marker-delimited sections and calculates sizes

import { encodeBase64Url } from './utils';

function getCacheBuster() {
    if (typeof window !== 'undefined' && (window as any).ASSET_CACHE_BUSTER) {
        return (window as any).ASSET_CACHE_BUSTER;
    }
    return Date.now();
}

/**
 * Scans a file for START/END marker pairs and returns file metadata
 * @param {string} filePath - Relative path to file
 * @param {string} content - File content
 * @returns {Object} File metadata with sections for display and fullContent for packing
 */
export function scanFileForMarkers(filePath: string, content: string) {
    const sections: any[] = [];
    const lines = content.split('\n');

    // Regex patterns for markers
    const startPattern = /--\s*(\w+)_START/;
    const endPattern = /--\s*(\w+)_END/;

    let currentSection: string | null = null;
    let currentStartLine = 0;
    let currentContent: string[] = [];

    lines.forEach((line, index) => {
        const startMatch = line.match(startPattern);
        const endMatch = line.match(endPattern);

        if (startMatch) {
            // Found start marker
            currentSection = startMatch[1];
            currentStartLine = index + 1; // 1-indexed
            currentContent = [line];
        } else if (endMatch && currentSection === endMatch[1]) {
            // Found matching end marker
            currentContent.push(line);

            const sectionCode = currentContent.join('\n');
            const stats = calculateSectionStats(sectionCode);

            sections.push({
                name: currentSection,
                file: filePath,
                type: filePath.includes('Units_') ? 'units' : 'defs',
                startLine: currentStartLine,
                endLine: index + 1,
                lines: currentContent.length,
                rawChars: stats.rawChars,
                encodedChars: stats.encodedChars,
                code: sectionCode
            });

            currentSection = null;
            currentContent = [];
        } else if (currentSection) {
            // Inside a section
            currentContent.push(line);
        }
    });

    // Return sections array directly (no fullContent)
    return sections;
}

/**
 * Calculate section statistics (lines, raw chars, encoded chars)
 * NO MINIFICATION - marker-delimited fragments cause SyntaxError
 * @param {string} code - Section code
 * @returns {Object} Stats object with rawChars and encodedChars
 */
export function calculateSectionStats(code: string) {
    const rawChars = code.length;

    // Calculate base64url encoded size for RAW code (no minification, simplified - no UTF-8 step)
    const base64url = encodeBase64Url(code);
    const encodedChars = base64url.length;

    return { rawChars, encodedChars };
}

/**
 * Load tweak file list from dynamic-tweaks.json to avoid hardcoded paths.
 * Falls back to the legacy static list if the manifest is unavailable.
 * @returns {Promise<string[]>}
 */
async function loadTweakFileList() {
    try {
        const response = await fetch(`dynamic-tweaks.json?v=${getCacheBuster()}`);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status} ${response.statusText}`);
        }

        const data = await response.json();
        const files = new Set<string>();
        const tweaks = data.dynamic_tweaks || {};

        Object.values(tweaks).forEach((config: any) => {
            if (config && typeof config.source_file === 'string') {
                files.add(config.source_file);
            }

            if (Array.isArray(config.options)) {
                config.options.forEach((option: any) => {
                    if (option && typeof option.source_file === 'string') {
                        files.add(option.source_file);
                    }
                });
            }

            if (Array.isArray(config.dropdown_options)) {
                config.dropdown_options.forEach((option: any) => {
                    if (option && typeof option.source_file === 'string') {
                        files.add(option.source_file);
                    }
                });
            }
        });

        const fileList = Array.from(files);
        if (fileList.length > 0) {
            return fileList;
        }
        console.warn('dynamic-tweaks.json did not provide any source files; using fallback list.');
    } catch (error) {
        console.warn('Could not load dynamic tweak manifest; using fallback file list.', error);
    }

    return [
        'tweaks/Defs_Main.lua',
        'tweaks/Defs_T4_Epics.lua',
        'tweaks/Defs_Waves_Mini_Bosses.lua',
        'tweaks/Defs_Unit_Launchers.lua',
        'tweaks/Defs_T4_Defenses.lua',
        'tweaks/Defs_T3_Builders.lua',
        'tweaks/Defs_Waves_Experimental_Wave_Challenge.lua',
        'tweaks/Defs_T4_Air.lua',
        'tweaks/Defs_Mega_Nuke.lua',
        'tweaks/Units_LRPC_v2.lua',
        'tweaks/Defs_T3_Eco.lua',
        'tweaks/Defs_T4_Eco.lua',
        'tweaks/Units_NuttyB_Evolving_Commanders_Armada.lua',
        'tweaks/Units_NuttyB_Evolving_Commanders_Cortex.lua',
        'tweaks/Units_NuttyB_Evolving_Commanders_Legion.lua',
        'tweaks/Units_EVO_XP.lua',
        'tweaks/Units_Main.lua',
        'tweaks/Defs_Cross_Faction_T2.lua'
    ];
}

let encodedTweaksCache: any = null;
const ENCODED_TWEAKS_SECRET = "some-secret"; // Placeholder, needs to be defined or imported

async function loadEncodedTweaks() {
    if (encodedTweaksCache !== null) return encodedTweaksCache;
    console.log('AES decoding disabled; using plaintext tweaks.');
    encodedTweaksCache = false;
    return null;
}

async function decodeAesCtrBase64(payloadBase64: string, secret: string) {
    const raw = Uint8Array.from(atob(payloadBase64), c => c.charCodeAt(0));
    const iv = raw.slice(0, 16);
    const ciphertext = raw.slice(16);
    const enc = new TextEncoder();
    const keyMaterial = await crypto.subtle.digest('SHA-256', enc.encode(secret));
    const key = await crypto.subtle.importKey('raw', keyMaterial, { name: 'AES-CTR' }, false, ['decrypt']);
    const plaintextBuffer = await crypto.subtle.decrypt(
        { name: 'AES-CTR', counter: iv, length: 64 },
        key,
        ciphertext
    );
    return new TextDecoder().decode(plaintextBuffer);
}

/**
 * Scan all tweak files from slot-distribution.json
 * @returns {Promise<Object>} File path -> sections array mapping
 */
export async function scanAllTweakFiles() {
    console.log("Starting auto-scan of all tweak files...");

    const fileCache: any = {};
    const encodedMap = await loadEncodedTweaks();

    const filesToScan = await loadTweakFileList();

    // Scan each file
    for (const filePath of filesToScan) {
        console.log(`Scanning ${filePath}...`);

        try {
            let content = null;

            // Prefer encoded tweaks if present
            if (encodedMap && encodedMap[filePath]) {
                content = await decodeAesCtrBase64(encodedMap[filePath], ENCODED_TWEAKS_SECRET);
            } else {
                const response = await fetch(`${filePath}?v=${getCacheBuster()}`);
                if (!response.ok) {
                    console.warn(`Failed to load ${filePath}`);
                    continue;
                }
                content = await response.text();
            }

            const sections = scanFileForMarkers(filePath, content);

            if (sections.length > 0) {
                fileCache[filePath] = sections;
                console.log(`  Found ${sections.length} sections:`, sections.map(s => s.name).join(', '));
            } else {
                console.log(`  No marker-delimited sections found`);
            }
        } catch (error) {
            console.error(`Error scanning ${filePath}:`, error);
        }
    }

    console.log("Auto-scan complete. Total files with sections:", Object.keys(fileCache).length);
    return fileCache;
}

/**
 * Find a section by ID in the file cache
 * @param {Object} fileCache - Cache from scanAllTweakFiles()
 * @param {string} sectionId - Section identifier (e.g., "ARMADA_COMMANDER")
 * @returns {Object|null} Section metadata or null
 */
export function findSectionInCache(fileCache: any, sectionId: string) {
    for (const sections of Object.values(fileCache) as any[]) {
        const section = sections.find((s: any) => s.name === sectionId);
        if (section) return section;
    }
    return null;
}
