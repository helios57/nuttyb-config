import * as fs from 'fs';
import * as path from 'path';

function maskStrings(content: string): { masked: string, store: string[] } {
    const store: string[] = [];
    const masked = content.replace(/("(\\.|[^"\\])*"|'(\\.|[^'\\])*'|\[(=*)\[[\s\S]*?\]\4\])/g, (match) => {
        store.push(match);
        return `__STR_${store.length - 1}__`;
    });
    return { masked, store };
}

function restoreStrings(content: string, store: string[]): string {
    return content.replace(/__STR_(\d+)__/g, (_, index) => store[parseInt(index)]);
}

function MinifyLua(content: string): string {
    const { masked, store } = maskStrings(content);
    let cleaned = masked;
    // 1. Remove block comments
    cleaned = cleaned.replace(/--\[(=*)\[[\s\S]*?\]\1\]/g, ' ');
    // 2. Remove single line comments
    cleaned = cleaned.replace(/--.*$/gm, ' ');
    // 3. Normalize whitespace
    cleaned = cleaned.replace(/\s+/g, ' ');
    // 4. Trim
    cleaned = cleaned.trim();
    return restoreStrings(cleaned, store);
}

const tweaksPath = 'lua/imported_tweaks/UnifiedTweaks.lua';
const content = fs.readFileSync(tweaksPath, 'utf-8');
const minified = MinifyLua(content);

console.log(minified);
