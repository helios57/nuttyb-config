import * as fs from 'fs';
import * as path from 'path';
// We use require for luamin because it likely lacks types or is a CJS module
const luamin = require('luamin');

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
        varName: varName
    };
}

// Base64 Decoder implementation to include in the output
const BASE64_DECODER_LUA = `
local function Base64Decode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end
`;

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

    // Construct Master Body
    let masterBody = commonLua;
    masterBody += "\n-- Tweaks \n";
    masterBody += tweakLua; // Apply tweaks immediately (assumed to be UnitDef mods or safe to run)

    masterBody += "\n-- Gadgets \n";

    // Forward declarations for gadget events
    const allEvents = new Set<string>();
    gadgets.forEach(g => {
        g.events.forEach(e => allEvents.add(e));
        g.events.forEach(e => {
             masterBody += `local ${g.prefix}${e}\n`;
        });
    });

    gadgets.forEach(g => {
        masterBody += g.content;
    });

    masterBody += "\n-- Master Dispatcher \n";
    allEvents.forEach(evt => {
        masterBody += `function gadget:${evt}(...)\n`;
        gadgets.forEach(g => {
            if (g.events.includes(evt)) {
                 // e.g. if AdaptiveSpawner_GameFrame then AdaptiveSpawner_GameFrame(...) end
                 masterBody += `    if ${g.prefix}${evt} then ${g.prefix}${evt}(...) end\n`;
            }
        });
        masterBody += `end\n`;
    });

    console.log(`Generated Master Logic: ${masterBody.length} chars`);

    // fs.writeFileSync(path.join(__dirname, 'debug_master_body.lua'), masterBody);

    // Minify
    console.log("Minifying...");
    let minified;
    try {
        minified = luamin.minify(masterBody);
    } catch (e: any) {
        console.error("Minification failed:", e);
        if (e.line) {
             const lines = masterBody.split('\n');
             const start = Math.max(0, e.line - 5);
             const end = Math.min(lines.length, e.line + 5);
             console.log("Context:");
             for(let i = start; i < end; i++) {
                 console.log(`${i+1}: ${lines[i]}`);
             }
        }
        process.exit(1);
    }
    console.log(`Minified size: ${minified.length} chars`);

    // Base64 Encode
    console.log("Encoding...");
    const encoded = Buffer.from(minified).toString('base64');

    // Chunking
    const CHUNK_SIZE = 64000; // Safe limit
    const chunks: string[] = [];
    for (let i = 0; i < encoded.length; i += CHUNK_SIZE) {
        chunks.push(encoded.slice(i, i + CHUNK_SIZE));
    }
    console.log(`Created ${chunks.length} chunks.`);

    // Generate MasterGadget.lua
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

-- Configuration Flags (Global for chunk access)
`;
    gadgets.forEach(g => {
        finalFile += `ENABLE_${g.varName.toUpperCase()} = true\n`;
    });

    finalFile += `
if (not gadgetHandler:IsSyncedCode()) then
  return
end

${BASE64_DECODER_LUA}

local chunks = {
`;
    chunks.forEach(c => {
        finalFile += `    "${c}",\n`;
    });
    finalFile += `}

local encoded = table.concat(chunks)
local decoded = Base64Decode(encoded)
local func, loadErr = loadstring(decoded)
if func then
    local status, err = pcall(func)
    if not status then
        Spring.Echo("Runtime Error in MasterGadget: " .. tostring(err))
    end
else
    Spring.Echo("Syntax Error loading MasterGadget logic: " .. tostring(loadErr))
end
`;

    fs.writeFileSync(OUTPUT_FILE, finalFile);
    console.log(`Written to ${OUTPUT_FILE}`);
}

main().catch(err => {
    console.error(err);
    process.exit(1);
});
