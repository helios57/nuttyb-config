import * as fs from 'fs';
import * as path from 'path';
import { OptimizedLuaCompiler } from '../src/mod-logic/optimized-compiler';
import { TweakDefinition } from '../src/mod-logic/tweak-dsl';

const CONFIG_PATH = path.join(__dirname, '../master_config_normalized.json');
const OUTPUT_DIR = path.join(__dirname, '../dist');
const OUTPUT_PATH = path.join(OUTPUT_DIR, 'tweakdata.lua');

// Mock variables for generation
const VARIABLES = {
    multiplier: 2.0,
    healthMultiplier: 1.5,
    workertimeMultiplier: 1.2,
    metalCostFactor: 0.9,
    factoryPrefix: "arm",
    unitName: "armwar"
};

function main() {
    if (!fs.existsSync(CONFIG_PATH)) {
        console.error(`Config file not found: ${CONFIG_PATH}`);
        process.exit(1);
    }

    if (!fs.existsSync(OUTPUT_DIR)) {
        fs.mkdirSync(OUTPUT_DIR, { recursive: true });
    }

    console.log(`Loading config from ${CONFIG_PATH}...`);
    const config = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf-8')) as TweakDefinition[];

    console.log(`Compiling ${config.length} tweaks...`);
    const compiler = new OptimizedLuaCompiler();

    // Map tweaks to inputs with variables
    const inputs = config.map(tweak => ({
        tweak,
        variables: VARIABLES
    }));

    let lua = compiler.compile(inputs);

    // Basic Post-Processing Minification
    // Remove comments (already removed in compiler, but just in case)
    lua = lua.replace(/--.*$/gm, '');
    // Remove empty lines
    lua = lua.replace(/^\s*[\r\n]/gm, '');
    // Trim lines
    lua = lua.split('\n').map(l => l.trim()).filter(l => l).join('\n');

    fs.writeFileSync(OUTPUT_PATH, lua);
    console.log(`Lua code generated at ${OUTPUT_PATH} (${lua.length} bytes)`);
}

main();
