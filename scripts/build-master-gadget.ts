import * as fs from 'fs';
import * as path from 'path';

const IMPORTED_TWEAKS_DIR = path.join(__dirname, '../lua/imported_tweaks');
const GADGETS_DIR = path.join(__dirname, '../lua');
const OUTPUT_FILE = path.join(__dirname, '../lua/MasterGadget.lua');

const GADGET_FILES = [
    'gadget_adaptive_spawner.lua',
    'gadget_culling.lua',
    'gadget_fusion_core.lua',
    'gadget_raptor_ai_optimized.lua'
];

// Unified Tweaks is the only file we need from imported_tweaks now
const UNIFIED_TWEAKS_FILE = 'UnifiedTweaks.lua';

const MANDATORY_GLOBALS = [
    'pairs', 'ipairs', 'next', 'tostring', 'tonumber', 'type', 'assert', 'error', 'select', 'unpack',
    'table.insert', 'table.remove', 'table.sort', 'table.concat',
    'math.max', 'math.min', 'math.floor', 'math.ceil', 'math.random', 'math.abs', 'math.sqrt',
    'string.find', 'string.match', 'string.sub', 'string.len', 'string.format',
    'Spring.GetModOptions', 'Spring.GetUnitDefID', 'Spring.GetUnitCount', 'Spring.GetGameSpeed',
    'Spring.GetFPS', 'Spring.GetUnitPosition', 'Spring.DestroyUnit', 'Spring.CreateUnit',
    'Spring.SetUnitColor', 'Spring.GetUnitHealth', 'Spring.SetUnitHealth', 'Spring.GetUnitExperience',
    'Spring.SetUnitExperience', 'Spring.GetGaiaTeamID', 'Spring.GetTeamList', 'Spring.GetTeamUnits',
    'Spring.AddTeamResource', 'Spring.ValidUnitID', 'Spring.SpawnCEG', 'Spring.SendMessage',
    'Spring.GetTeamStartPosition', 'Spring.GetUnitsInCylinder', 'Spring.GiveOrderToUnit',
    'Spring.SetUnitLabel', 'Spring.SetUnitNeutral', 'Spring.GetUnitNearestEnemy'
    // 'UnitDefs', 'UnitDefNames' -- Removed to ensure global access and avoid shadowing issues
];

// Helper to mask strings to protect them during regex operations
function maskStrings(content: string): { masked: string, store: string[] } {
    const store: string[] = [];
    // Match double quotes, single quotes, and long strings [[ ... ]] or [=[ ... ]=]
    const masked = content.replace(/("(\\.|[^"\\])*"|'(\\.|[^'\\])*'|\[(=*)\[[\s\S]*?\]\4\])/g, (match) => {
        store.push(match);
        return `__STR_${store.length - 1}__`;
    });
    return { masked, store };
}

function restoreStrings(content: string, store: string[]): string {
    return content.replace(/__STR_(\d+)__/g, (_, index) => store[parseInt(index)]);
}

function stripDebugPrints(content: string): string {
    // Mask strings first so we don't mess up parens inside strings
    const { masked, store } = maskStrings(content);

    let cleaned = masked;

    // Remove Spring.Echo(...) and print(...)
    // Handles one level of nested parentheses: ( ... ( ... ) ... )
    const debugRegex = /\b(Spring\.Echo|print)\s*\((?:[^()]*|\([^()]*\))*\)/g;

    cleaned = cleaned.replace(debugRegex, '');

    return restoreStrings(cleaned, store);
}

function MinifyLua(content: string): string {
    const { masked, store } = maskStrings(content);

    let cleaned = masked;

    // 1. Remove block comments --[[ ... ]]
    // Note: Lua block comments can have equals signs: --[==[ ... ]==]
    cleaned = cleaned.replace(/--\[(=*)\[[\s\S]*?\]\1\]/g, ' ');

    // 2. Remove single line comments
    cleaned = cleaned.replace(/--.*$/gm, ' ');

    // 3. Normalize whitespace
    // Replace tabs/newlines with space, then collapse multiple spaces
    cleaned = cleaned.replace(/\s+/g, ' ');

    // 4. Trim
    cleaned = cleaned.trim();

    return restoreStrings(cleaned, store);
}

function generateCommonLua(): string {
    const code = `
-- Common Utilities
local function table_merge(dest, src)
    if not dest then dest = {} end
    for k, v in pairs(src) do
        if (type(v) == "table") and (type(dest[k]) == "table") then
            table_merge(dest[k], v)
        else
            dest[k] = v
        end
    end
    return dest
end

local function table_mergeInPlace(dest, src)
    if not dest or not src then return end
    for k, v in pairs(src) do
        if (type(v) == "table") and (type(dest[k]) == "table") then
            table_mergeInPlace(dest[k], v)
        else
            dest[k] = v
        end
    end
end

local function table_copy(t)
    if type(t) ~= "table" then return t end
    local res = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            res[k] = table_copy(v)
        else
            res[k] = v
        end
    end
    return res
end

-- Polyfill table.merge and table.mergeInPlace if missing
if not table.merge then table.merge = table_merge end
if not table.mergeInPlace then table.mergeInPlace = table_mergeInPlace end
if not table.copy then table.copy = table_copy end
`;
    // We don't strip debug prints from common lua (there shouldn't be any), but we minify
    return MinifyLua(code);
}

function processImportedTweaks(): string {
    const filePath = path.join(IMPORTED_TWEAKS_DIR, UNIFIED_TWEAKS_FILE);
    if (!fs.existsSync(filePath)) {
        console.warn(`Unified tweaks file not found: ${filePath}`);
        return "";
    }
    console.log(`Processing tweak: ${UNIFIED_TWEAKS_FILE}`);
    let content = fs.readFileSync(filePath, 'utf-8');

    content = stripDebugPrints(content);

    // Minify
    // return MinifyLua(content);
    return content;
}

interface ProcessedGadget {
    name: string;
    events: string[];
    content: string;
    prefix: string;
}

function processGadget(filename: string): ProcessedGadget {
    console.log(`Processing gadget: ${filename}`);
    let raw = fs.readFileSync(path.join(GADGETS_DIR, filename), 'utf-8');

    // Strip debug prints
    raw = stripDebugPrints(raw);

    const baseName = filename.replace('gadget_', '').replace('.lua', '');
    const prefix = baseName.replace(/_/g, '') + '_';

    // Remove GetInfo
    let content = raw.replace(/function\s+gadget:GetInfo\(\)([\s\S]*?)end/g, '');

    // Remove SyncedCode check (we wrap strictly in MasterGadget)
    // content = content.replace(/if\s*\(?\s*not\s+gadgetHandler:IsSyncedCode\(\)\s*\)?\s*then[\s\S]*?end/g, '');

    // Minify partial
    // content = MinifyLua(content);

    // Identify events
    const events: string[] = [];
    const eventRegex = /function\s+gadget:([a-zA-Z0-9_]+)\s*\(/g;
    let match;
    while ((match = eventRegex.exec(content)) !== null) {
        if (!events.includes(match[1])) {
            events.push(match[1]);
        }
    }

    // Rename events
    content = content.replace(/function\s+gadget:([a-zA-Z0-9_]+)\s*\(/g, (m, eventName) => {
        return `${prefix}${eventName} = function(`;
    });

    const initFuncName = `Initialize_${prefix.slice(0, -1)}`;

    // Wrap
    content = ` local function ${initFuncName}() ${content} end ${initFuncName}() `;

    return {
        name: filename,
        events: events,
        content: content,
        prefix: prefix
    };
}

function scanContent(content: string): Set<string> {
    const globals = new Set<string>();
    const { masked } = maskStrings(content);

    // Scan for globals
    const regex = /\b(Spring\.[a-zA-Z0-9_]+|math\.[a-zA-Z0-9_]+|table\.[a-zA-Z0-9_]+|string\.[a-zA-Z0-9_]+|pairs|ipairs|next|type|tostring|tonumber|assert|error|select|unpack|UnitDefs|UnitDefNames)\b/g;

    let match;
    while ((match = regex.exec(masked)) !== null) {
        globals.add(match[1]);
    }
    return globals;
}

function generateLocalName(globalName: string): string {
    if (globalName === 'UnitDefs') return 'UnitDefs';
    if (globalName === 'UnitDefNames') return 'UnitDefNames';
    if (!globalName.includes('.')) return globalName;

    const parts = globalName.split('.');
    if (parts[0] === 'Spring') return 'sp' + parts[1];
    if (parts[0] === 'math') return 'math_' + parts[1];
    if (parts[0] === 'table') return 'table_' + parts[1];
    if (parts[0] === 'string') return 'string_' + parts[1];

    return parts.join('_');
}

function localizeContent(content: string, globals: string[]): string {
    // We must mask strings to avoid replacement inside strings
    const { masked, store } = maskStrings(content);

    let result = masked;

    const sortedGlobals = [...globals].sort((a, b) => b.length - a.length);

    for (const g of sortedGlobals) {
        const localName = generateLocalName(g);
        if (localName === g) continue;

        // Use word boundary to avoid partial replacement, escape dot
        const escapedG = g.replace(/\./g, '\\.');
        const regex = new RegExp(`\\b${escapedG}\\b`, 'g');
        result = result.replace(regex, localName);
    }

    // Special case for table.merge/mergeInPlace from CommonLua
    result = result.replace(/\btable\.merge\b/g, 'table_merge');
    result = result.replace(/\btable\.mergeInPlace\b/g, 'table_mergeInPlace');
    result = result.replace(/\btable\.copy\b/g, 'table_copy');

    return restoreStrings(result, store);
}

async function main() {
    console.log('Starting MasterGadget build...');

    const commonLua = generateCommonLua();
    const importedTweaksLua = processImportedTweaks();
    // Static Tweaks removed/merged

    const gadgets = GADGET_FILES.map(processGadget);

    // Scan for globals
    const allGlobals = new Set<string>(MANDATORY_GLOBALS);

    // Scan all content
    // Note: We don't scan commonLua because it defines its own locals and polyfills
    const allContentToScan = [importedTweaksLua, ...gadgets.map(g => g.content)];
    allContentToScan.forEach(c => {
        scanContent(c).forEach(g => allGlobals.add(g));
    });

    // Generate Localized Globals Block
    let localizedGlobalsBlock = `-- Localized Globals\n`;
    const sortedGlobals = Array.from(allGlobals).sort();

    const localizedMap: string[] = [];

    sortedGlobals.forEach(g => {
        if (g === 'table.merge' || g === 'table.mergeInPlace' || g === 'table.copy') return;

        const localName = generateLocalName(g);
        // Only generate if different (e.g. pairs -> pairs doesn't need alias unless we want local pairs = pairs)
        // Creating local alias for built-ins is good for upvalue perf.
        localizedGlobalsBlock += `local ${localName} = ${g}; `;
        localizedMap.push(g);
    });
    localizedGlobalsBlock += '\n';

    // Localize Content
    // Wrap in do ... end to ensure scope isolation and block closure
    const localizedImportedTweaks = " do " + localizeContent(importedTweaksLua, localizedMap) + " end ";

    gadgets.forEach(g => {
        g.content = localizeContent(g.content, localizedMap);
    });

    // Header
    let finalFile = `function gadget:GetInfo() return { name="NuttyB Master Gadget", desc="Combined logic and tweaks for NuttyB Mod", author="NuttyB Team (Generated)", date="${new Date().getFullYear()}", license="GPL", layer=0, enabled=true } end if (not gadgetHandler:IsSyncedCode()) then return end `;

    finalFile += localizedGlobalsBlock;

    // Events Declarations
    const allEvents = new Set<string>();
    gadgets.forEach(g => {
        g.events.forEach(e => allEvents.add(e));
        g.events.forEach(e => {
             finalFile += `local ${g.prefix}${e}; `;
        });
    });

    finalFile += commonLua + " ";
    finalFile += localizedImportedTweaks + " ";

    gadgets.forEach(g => {
        finalFile += g.content + " ";
    });

    // Events Dispatch
    allEvents.forEach(evt => {
        finalFile += `function gadget:${evt}(...)\n`;
        gadgets.forEach(g => {
            if (g.events.includes(evt)) {
                 finalFile += `if ${g.prefix}${evt} then ${g.prefix}${evt}(...) end\n`;
            }
        });
        finalFile += `end\n`;
    });

    // Final minification pass to ensure everything is compact (Using Safe Minify)
    // We mask strings again because assembly introduced newlines/spaces between blocks
    // finalFile = MinifyLua(finalFile);

    fs.writeFileSync(OUTPUT_FILE, finalFile);
    console.log(`Generated ${OUTPUT_FILE} (${finalFile.length} chars)`);
}

main().catch(err => {
    console.error(err);
    process.exit(1);
});
