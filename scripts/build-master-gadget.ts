import * as fs from 'fs';
import * as path from 'path';
// Remove luamin requirement as we output plain text
// const luamin = require('luamin');

// Imports from src - we need to ensure ts-node can resolve these
import { generateTweak } from '../src/mod-logic/tweak-generator';

const TWEAKS_DIR = path.join(__dirname, '../src/tweaks');
const GADGETS_DIR = path.join(__dirname, '../lua');
const OUTPUT_FILE = path.join(__dirname, '../lua/MasterGadget.lua');

const GADGET_FILES = [
    'gadget_adaptive_spawner.lua',
    'gadget_culling.lua',
    'gadget_fusion_core.lua',
    'gadget_raptor_ai_optimized.lua'
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

local function ApplyTweakUnits(data)
    if not data then return end
    for name, defData in pairs(data) do
        if UnitDefs[name] then
            table_merge(UnitDefs[name], defData)
        end
    end
end
`;
}

async function processTweaks(files: string[]): Promise<string> {
    let luaOutput = "";

    // Sort files to ensure deterministic order
    files.sort((a, b) => {
        const numA = parseInt(a.split('-')[0]) || 999;
        const numB = parseInt(b.split('-')[0]) || 999;
        return numA - numB;
    });

    for (const file of files) {
        console.log(`Processing tweak: ${file}`);
        const content = fs.readFileSync(path.join(TWEAKS_DIR, file), 'utf-8');
        let config;
        try {
            config = JSON.parse(content);
        } catch (e: any) {
            console.error(`Failed to parse JSON for ${file}: ${e.message}`);
            continue;
        }

        try {
            const generated = generateTweak(config);

            if (config.generator === 'lua-table') {
                 // It's a data table (tweakunits)
                 luaOutput += `
do
    -- Tweak file: ${file}
    local data = ${generated}
    if data then
        ApplyTweakUnits(data)
    end
end
`;
            } else {
                 // It's logic/definitions (tweakdefs)
                 // generateTweak returns code that usually iterates UnitDefs
                 luaOutput += `
do
    -- Tweak file: ${file}
    ${generated}
end
`;
            }
        } catch (e: any) {
            console.error(`Failed to generate tweak for ${file}: ${e.message}`);
        }
    }
    return luaOutput;
}

interface ProcessedGadget {
    name: string;
    events: string[];
    content: string;
    prefix: string;
    varName: string; // The PascalCase name for flags
    usedGlobals: Set<string>;
}

function processGadget(filename: string): ProcessedGadget {
    console.log(`Processing gadget: ${filename}`);
    const raw = fs.readFileSync(path.join(GADGETS_DIR, filename), 'utf-8');
    const baseName = filename.replace('gadget_', '').replace('.lua', '');
    const prefix = baseName.replace(/_/g, '') + '_';
    // PascalCase for flags (adaptive_spawner -> AdaptiveSpawner)
    const varName = baseName.split('_').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join('');

    // Remove GetInfo
    let content = raw.replace(/function\s+gadget:GetInfo\(\)([\s\S]*?)end/g, '');

    // Remove SyncedCode check
    content = content.replace(/if\s*\(?\s*not\s+gadgetHandler:IsSyncedCode\(\)\s*\)?\s*then[\s\S]*?end/g, '');

    // Identify globals used (Spring.*, math.*) for potential hoisting (optional but good practice)
    const usedGlobals = new Set<string>();
    const globalRegex = /\b(Spring\.[a-zA-Z0-9_]+|math\.[a-zA-Z0-9_]+)\b/g;
    let gMatch;
    while ((gMatch = globalRegex.exec(content)) !== null) {
        usedGlobals.add(gMatch[1]);
    }

    // Identify events
    const events: string[] = [];
    const eventRegex = /function\s+gadget:([a-zA-Z0-9_]+)\s*\(/g;
    let match;
    while ((match = eventRegex.exec(content)) !== null) {
        if (!events.includes(match[1])) {
            events.push(match[1]);
        }
    }

    // Replace function gadget:Event(...) -> Prefix_Event = function(...)
    content = content.replace(/function\s+gadget:([a-zA-Z0-9_]+)\s*\(/g, (m, eventName) => {
        return `${prefix}${eventName} = function(`;
    });

    const initFuncName = `Initialize_${prefix.slice(0, -1)}`;

    // Wrap content in a closure to avoid scope pollution, but allow events to escape via upvalues
    content = `
local function ${initFuncName}()
${content}
end
if ENABLE_${varName.toUpperCase()} then
    ${initFuncName}()
end
`;

    return {
        name: filename,
        events: events,
        content: content,
        prefix: prefix,
        varName: varName,
        usedGlobals: usedGlobals
    };
}

async function main() {
    console.log('Starting MasterGadget build...');

    if (!fs.existsSync(TWEAKS_DIR)) {
        console.error(`Tweaks directory not found: ${TWEAKS_DIR}`);
        process.exit(1);
    }

    const files = fs.readdirSync(TWEAKS_DIR).filter(f => f.endsWith('.json'));

    const commonLua = generateCommonLua();
    const tweakLua = await processTweaks(files);

    const gadgets = GADGET_FILES.map(processGadget);

    // Collect all used globals
    const allGlobals = new Set<string>();
    gadgets.forEach(g => g.usedGlobals.forEach(gl => allGlobals.add(gl)));

    // Generate Master File Content
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

-- Configuration Flags
`;
    gadgets.forEach(g => {
        finalFile += `ENABLE_${g.varName.toUpperCase()} = true\n`;
    });
    finalFile += `ENABLE_MEGANUKE = true\n`; // Add Mega Nuke toggle explicitly

    finalFile += `
if (not gadgetHandler:IsSyncedCode()) then
  return
end

-- Localized Globals (Performance Optimization)
`;
    // We create locals for Spring.* and math.*
    // Naming convention: Spring.GetUnitHealth -> spGetUnitHealth, math.floor -> math_floor
    // But note: Gadgets internal code uses their own locals or raw calls.
    // If gadgets use `Spring.GetUnitHealth`, having `local spGetUnitHealth` here doesn't affect them inside the closure unless we replace calls.
    // However, if we define `local Spring = Spring` etc, that's redundant.
    // The prompt asked to "localize them at the very top".
    // This is most effective if the code actually USES them.
    // Since we are not rewriting the inner gadget code to use these specific local names (unless we do advanced regex replace),
    // this header is mostly for the dispatcher and tweaks.
    // However, if we do define `local spGetUnitHealth = Spring.GetUnitHealth`, we can at least provide them.

    // Let's iterate and generate them.
    const sortedGlobals = Array.from(allGlobals).sort();
    sortedGlobals.forEach(g => {
        const parts = g.split('.');
        let localName = "";
        if (parts[0] === 'Spring') localName = 'sp' + parts[1];
        else if (parts[0] === 'math') localName = 'math_' + parts[1];
        else localName = parts.join('_');

        finalFile += `local ${localName} = ${g}\n`;
    });

    finalFile += `\n-- Forward Declarations for Gadget Events\n`;
    const allEvents = new Set<string>();
    gadgets.forEach(g => {
        g.events.forEach(e => allEvents.add(e));
        g.events.forEach(e => {
             finalFile += `local ${g.prefix}${e}\n`;
        });
    });

    finalFile += `\n-- Common Utilities\n`;
    finalFile += commonLua;

    finalFile += `\n-- Tweaks Logic\n`;
    finalFile += tweakLua;

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
