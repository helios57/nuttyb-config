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

    // Aggressive Post-Processing Minification
    // Remove comments
    lua = lua.replace(/--.*$/gm, '');

    // Split by strings to avoid modifying them
    const parts = lua.split(/("(?:\\[\s\S]|[^"])*"|'(?:\\[\s\S]|[^'])*')/g);

    for (let i = 0; i < parts.length; i += 2) {
        let code = parts[i];

        // Remove spaces around operators
        code = code.replace(/[ \t]*([=+\-*/,<>^])[ \t]*/g, '$1');

        // Remove spaces around parentheses/brackets/braces
        code = code.replace(/[ \t]*([()\[\]{}])[ \t]*/g, '$1');

        // Normalize whitespace (keep newlines)
        code = code.replace(/[ \t]+/g, ' ');

        parts[i] = code;
    }

    lua = parts.join('');

    // Remove empty lines and trim
    lua = lua.split('\n').map(l => l.trim()).filter(l => l).join('\n');

    fs.writeFileSync(OUTPUT_PATH, lua);
    console.log(`Lua code generated at ${OUTPUT_PATH} (${lua.length} bytes)`);
}

main();
