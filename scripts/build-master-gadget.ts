import * as fs from 'fs';
import * as path from 'path';

const STATIC_TWEAKS_FILE = path.join(__dirname, '../lua/StaticTweaks.lua');
const IMPORTED_TWEAKS_DIR = path.join(__dirname, '../lua/imported_tweaks');
const GADGETS_DIR = path.join(__dirname, '../lua');
const OUTPUT_FILE = path.join(__dirname, '../lua/MasterGadget.lua');

const GADGET_FILES = [
    'gadget_adaptive_spawner.lua',
    'gadget_culling.lua',
    'gadget_fusion_core.lua',
    'gadget_raptor_ai_optimized.lua'
];

const MANDATORY_GLOBALS = [
    'pairs', 'ipairs', 'next', 'tostring', 'tonumber', 'type', 'assert', 'error', 'select', 'unpack',
    'table.insert', 'table.remove', 'table.sort', 'table.concat',
    'math.max', 'math.min', 'math.floor', 'math.ceil', 'math.random', 'math.abs', 'math.sqrt',
    'string.find', 'string.match', 'string.sub', 'string.len', 'string.format',
    'Spring.GetModOptions', 'Spring.GetUnitDefID', 'Spring.GetUnitCount', 'Spring.Echo',
    'UnitDefs'
];

function generateCommonLua(): string {
    return `
-- Common Utilities
local function table_merge(dest, src)
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
}

function processImportedTweaks(): string {
    if (!fs.existsSync(IMPORTED_TWEAKS_DIR)) {
        console.warn(`Imported tweaks directory not found: ${IMPORTED_TWEAKS_DIR}`);
        return "";
    }

    let result = "";

    const files = fs.readdirSync(IMPORTED_TWEAKS_DIR)
        .filter(f => f.endsWith('.lua'))
        .sort();

    for (const file of files) {
        const filePath = path.join(IMPORTED_TWEAKS_DIR, file);
        console.log(`Processing tweak: ${file}`);
        let content = fs.readFileSync(filePath, 'utf-8');

        content = content.replace(/^-- Decoded from tweakdata\.txt.*$/gm, '');
        content = content.replace(/^--NuttyB .*$/gm, '');
        content = content.replace(/^-- Authors: .*$/gm, '');
        content = content.replace(/^-- docs\.google\.com.*$/gm, '');
        content = content.replace(/^-- [A-Z0-9_]+_(START|END)$/gm, '');
        content = content.trim();

        const strippedToCheck = content.replace(/--.*$/gm, '').trim();
        let codeBlock = "";

        if (strippedToCheck.startsWith('{')) {
            codeBlock = `
do
    local newUnits = ${content}
    if UnitDefs and newUnits then
        for name, def in pairs(newUnits) do
            if UnitDefs[name] then
                table.mergeInPlace(UnitDefs[name], def)
            else
                UnitDefs[name] = def
            end
        end
    end
end
`;
        } else {
            codeBlock = content;
        }

        result += `\n-- Tweak: ${file}\n`;
        if (file === 'Defs_Mega_Nuke.lua') {
            result += `if (tonumber(Spring.GetModOptions().meganuke) == 1) then\n`;
            result += `${codeBlock}\n`;
            result += `end\n`;
        } else {
            result += `${codeBlock}\n`;
        }
    }
    return result;
}

function processStaticTweaks(): string {
    if (fs.existsSync(STATIC_TWEAKS_FILE)) {
        console.log(`Loading static tweaks from ${STATIC_TWEAKS_FILE}`);
        return fs.readFileSync(STATIC_TWEAKS_FILE, 'utf-8');
    } else {
        console.warn(`Static tweaks file not found: ${STATIC_TWEAKS_FILE}`);
        return "";
    }
}

interface ProcessedGadget {
    name: string;
    events: string[];
    content: string;
    prefix: string;
}

function processGadget(filename: string): ProcessedGadget {
    console.log(`Processing gadget: ${filename}`);
    const raw = fs.readFileSync(path.join(GADGETS_DIR, filename), 'utf-8');
    const baseName = filename.replace('gadget_', '').replace('.lua', '');
    const prefix = baseName.replace(/_/g, '') + '_';

    // Remove GetInfo
    let content = raw.replace(/function\s+gadget:GetInfo\(\)([\s\S]*?)end/g, '');

    // Remove SyncedCode check
    content = content.replace(/if\s*\(?\s*not\s+gadgetHandler:IsSyncedCode\(\)\s*\)?\s*then[\s\S]*?end/g, '');

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
    content = `
local function ${initFuncName}()
${content}
end
-- Always Initialize
${initFuncName}()
`;

    return {
        name: filename,
        events: events,
        content: content,
        prefix: prefix
    };
}

function scanContent(content: string): Set<string> {
    const globals = new Set<string>();
    // Match Spring.*, math.*, table.*, string.*, and exact matches for basic globals
    const regex = /\b(Spring\.[a-zA-Z0-9_]+|math\.[a-zA-Z0-9_]+|table\.[a-zA-Z0-9_]+|string\.[a-zA-Z0-9_]+|pairs|ipairs|next|type|tostring|tonumber|assert|error|select|unpack|UnitDefs)\b/g;

    let match;
    while ((match = regex.exec(content)) !== null) {
        globals.add(match[1]);
    }
    return globals;
}

function generateLocalName(globalName: string): string {
    if (globalName === 'UnitDefs') return 'UnitDefs';
    if (!globalName.includes('.')) return globalName;

    const parts = globalName.split('.');
    if (parts[0] === 'Spring') return 'sp' + parts[1];
    if (parts[0] === 'math') return 'math_' + parts[1];
    if (parts[0] === 'table') return 'table_' + parts[1];
    if (parts[0] === 'string') return 'string_' + parts[1];

    return parts.join('_');
}

function localizeContent(content: string, globals: string[]): string {
    let result = content;

    // Sort globals by length (descending) to avoid partial replacements (e.g. replacing 'math.max' before 'math.maxInteger' if that existed)
    // Also ensures Spring.GetUnitDefID is replaced before Spring.GetUnitDefIDList if needed.
    const sortedGlobals = [...globals].sort((a, b) => b.length - a.length);

    for (const g of sortedGlobals) {
        const localName = generateLocalName(g);
        if (localName === g) continue; // No replacement needed for simple globals like 'pairs'

        // Use word boundary to avoid partial replacement, escape dot
        const escapedG = g.replace(/\./g, '\\.');
        const regex = new RegExp(`\\b${escapedG}\\b`, 'g');
        result = result.replace(regex, localName);
    }

    // Special case: map table.merge to table_merge (which comes from CommonLua)
    // table.merge is likely not in globals list if scanContent didn't find it, or if it matched table.merge
    // If table.merge was found, it generated local name 'table_merge'.
    // However, table.merge might not be in the Localized Globals block if it doesn't exist natively.
    // So we rely on replacement to 'table_merge' which is defined by CommonLua.
    result = result.replace(/\btable\.merge\b/g, 'table_merge');
    result = result.replace(/\btable\.mergeInPlace\b/g, 'table_mergeInPlace');

    return result;
}

async function main() {
    console.log('Starting MasterGadget build...');

    const commonLua = generateCommonLua();
    const importedTweaksLua = processImportedTweaks();
    const staticTweaksLua = processStaticTweaks();

    const gadgets = GADGET_FILES.map(processGadget);

    // Scan for globals
    const allGlobals = new Set<string>(MANDATORY_GLOBALS);

    // Scan all content
    // Note: We don't scan commonLua because it defines its own locals and polyfills
    const allContentToScan = [importedTweaksLua, staticTweaksLua, ...gadgets.map(g => g.content)];
    allContentToScan.forEach(c => {
        scanContent(c).forEach(g => allGlobals.add(g));
    });

    // Generate Localized Globals Block
    let localizedGlobalsBlock = `-- Localized Globals (Performance Optimization)\n`;
    const sortedGlobals = Array.from(allGlobals).sort();

    const localizedMap: string[] = [];

    sortedGlobals.forEach(g => {
        // Skip table.merge/mergeInPlace from top localization as they are polyfilled in CommonLua
        if (g === 'table.merge' || g === 'table.mergeInPlace') return;

        const localName = generateLocalName(g);
        localizedGlobalsBlock += `local ${localName} = ${g}\n`;
        localizedMap.push(g);
    });

    // Localize Content
    // We apply localization to Tweaks and Gadgets.
    // CommonLua is NOT localized because it defines the base functions.
    const localizedImportedTweaks = localizeContent(importedTweaksLua, localizedMap);
    const localizedStaticTweaks = localizeContent(staticTweaksLua, localizedMap);

    gadgets.forEach(g => {
        g.content = localizeContent(g.content, localizedMap);
    });

    let finalFile = `function gadget:GetInfo()
  return {
    name      = "NuttyB Master Gadget",
    desc      = "Combined logic and tweaks for NuttyB Mod",
    author    = "NuttyB Team (Generated)",
    date      = "${new Date().getFullYear()}",
    license   = "GPL",
    layer     = 0,
    enabled   = true
  }
end

if (not gadgetHandler:IsSyncedCode()) then
  return
end

${localizedGlobalsBlock}
-- Forward Declarations for Gadget Events
`;

    const allEvents = new Set<string>();
    gadgets.forEach(g => {
        g.events.forEach(e => allEvents.add(e));
        g.events.forEach(e => {
             finalFile += `local ${g.prefix}${e}\n`;
        });
    });

    finalFile += `\n-- Common Utilities\n`;
    finalFile += commonLua;

    finalFile += `\n-- Imported Tweaks Logic (Configurable)\n`;
    finalFile += localizedImportedTweaks;

    finalFile += `\n-- Static Tweaks Logic (Base)\n`;
    finalFile += localizedStaticTweaks;

    finalFile += `\n-- Gadget Logic\n`;
    gadgets.forEach(g => {
        finalFile += g.content;
    });

    finalFile += `\n-- Master Dispatcher\n`;
    allEvents.forEach(evt => {
        finalFile += `function gadget:${evt}(...)\n`;
        gadgets.forEach(g => {
            if (g.events.includes(evt)) {
                 finalFile += `    if ${g.prefix}${evt} then ${g.prefix}${evt}(...) end\n`;
            }
        });
        finalFile += `end\n`;
    });

    fs.writeFileSync(OUTPUT_FILE, finalFile);
    console.log(`Generated ${OUTPUT_FILE} (${finalFile.length} chars)`);
}

main().catch(err => {
    console.error(err);
    process.exit(1);
});
