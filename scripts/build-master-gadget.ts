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

// Mapping: filename -> modOption key
const TWEAK_FILES: Record<string, string> = {
    'Defs_Cross_Faction_T2.lua': 'nuttyb_cross_faction_t2',
    'Defs_Main.lua': 'nuttyb_main_defs',
    'Defs_Mega_Nuke.lua': 'meganuke',
    'Defs_T3_Builders.lua': 'nuttyb_t3_builders',
    'Defs_T3_Eco.lua': 'nuttyb_t3_eco',
    'Defs_T4_Air.lua': 'nuttyb_t4_air',
    'Defs_T4_Defenses.lua': 'nuttyb_t4_defenses',
    'Defs_T4_Eco.lua': 'nuttyb_t4_eco',
    'Defs_T4_Epics.lua': 'nuttyb_t4_epics',
    'Defs_Unit_Launchers.lua': 'nuttyb_unit_launchers',
    'Defs_Waves_Experimental_Wave_Challenge.lua': 'nuttyb_wave_mode_exp',
    'Defs_Waves_Mini_Bosses.lua': 'nuttyb_wave_mode_mini',
    'Units_EVO_XP.lua': 'nuttyb_evo_xp',
    'Units_LRPC_v2.lua': 'nuttyb_lrpc_v2',
    'Units_Main.lua': 'nuttyb_main_units',
    'Units_NuttyB_Evolving_Commanders_Armada.lua': 'nuttyb_evo_com_arm',
    'Units_NuttyB_Evolving_Commanders_Cortex.lua': 'nuttyb_evo_com_cor',
    'Units_NuttyB_Evolving_Commanders_Legion.lua': 'nuttyb_evo_com_leg',
};

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

-- Polyfill table.merge and table.mergeInPlace if missing
if not table.merge then table.merge = table_merge end
if not table.mergeInPlace then table.mergeInPlace = table_mergeInPlace end
`;
}

function processImportedTweaks(): string {
    if (!fs.existsSync(IMPORTED_TWEAKS_DIR)) {
        console.warn(`Imported tweaks directory not found: ${IMPORTED_TWEAKS_DIR}`);
        return "";
    }

    let result = "";

    // Sort keys to ensure deterministic order (Defs before Units usually implies D < U, which works)
    const files = Object.keys(TWEAK_FILES).sort();

    for (const file of files) {
        const modOption = TWEAK_FILES[file];
        const filePath = path.join(IMPORTED_TWEAKS_DIR, file);

        if (fs.existsSync(filePath)) {
            console.log(`Processing tweak: ${file} (ModOption: ${modOption})`);
            let content = fs.readFileSync(filePath, 'utf-8');

            // Check if file returns a table (heuristic: starts with { after comments)
            // Strip comments to check
            const stripped = content.replace(/--.*$/gm, '').trim();
            if (stripped.startsWith('{')) {
                // Wrap in table merge logic
                content = `
                local newUnits = ${content}
                if UnitDefs and newUnits then
                    for name, def in pairs(newUnits) do
                        UnitDefs[name] = def -- Simple assignment, assumes full def or later processing
                    end
                end
                `;
            }

            result += `
-- Tweak: ${file}
if (tonumber(Spring.GetModOptions().${modOption}) == 1) then
    ${content}
end
`;
        } else {
             console.warn(`Tweak file missing: ${file}`);
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
    varName: string;
    usedGlobals: Set<string>;
}

function processGadget(filename: string): ProcessedGadget {
    console.log(`Processing gadget: ${filename}`);
    const raw = fs.readFileSync(path.join(GADGETS_DIR, filename), 'utf-8');
    const baseName = filename.replace('gadget_', '').replace('.lua', '');
    const prefix = baseName.replace(/_/g, '') + '_';
    const varName = baseName.split('_').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join('');

    // Remove GetInfo
    let content = raw.replace(/function\s+gadget:GetInfo\(\)([\s\S]*?)end/g, '');

    // Remove SyncedCode check
    content = content.replace(/if\s*\(?\s*not\s+gadgetHandler:IsSyncedCode\(\)\s*\)?\s*then[\s\S]*?end/g, '');

    // Identify globals
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
        prefix: prefix,
        varName: varName,
        usedGlobals: usedGlobals
    };
}

async function main() {
    console.log('Starting MasterGadget build...');

    const commonLua = generateCommonLua();
    const importedTweaksLua = processImportedTweaks();
    const staticTweaksLua = processStaticTweaks();

    const gadgets = GADGET_FILES.map(processGadget);

    const allGlobals = new Set<string>();
    gadgets.forEach(g => g.usedGlobals.forEach(gl => allGlobals.add(gl)));

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

-- Localized Globals (Performance Optimization)
`;

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

    finalFile += `\n-- Imported Tweaks Logic (Configurable)\n`;
    finalFile += importedTweaksLua;

    finalFile += `\n-- Static Tweaks Logic (Base)\n`;
    finalFile += staticTweaksLua;

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
