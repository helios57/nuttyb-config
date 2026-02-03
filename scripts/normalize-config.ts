import * as fs from 'fs';
import * as path from 'path';
import { TweakDefinition, MutationOperation, TweakCondition, UnitDefField, ValueSource } from '../src/mod-logic/tweak-dsl';

const TWEAK_LIB_PATH = path.join(__dirname, '../src/mod-logic/tweak-library.json');
const TWEAKS_DIR = path.join(__dirname, '../src/tweaks');
const OUTPUT_PATH = path.join(__dirname, '../master_config_normalized.json');

// Types for legacy support
interface LegacyMutation {
    op: string;
    target?: string; // Maps to field
    field?: string;
    value?: any;
    factor?: any;
    weapon_target?: string;
    mutations?: LegacyMutation[];
    source?: string; // For clone_unit
    targetSuffix?: string; // For clone_unit
    [key: string]: any;
}

interface LegacyDefinition {
    name: string;
    description: string;
    scope: string; // strict check needed
    conditions: any[];
    mutations: LegacyMutation[];
}

function normalizeMutation(mut: LegacyMutation): MutationOperation {
    let op = mut.op;

    // Map legacy 'target' to 'field'
    let field: UnitDefField | undefined = (mut.field || mut.target) as UnitDefField;

    // Handle weapon_target wrapper
    if (mut.weapon_target) {
        const subMutation: any = { ...mut };
        delete subMutation.weapon_target;
        // The sub-mutation is strictly the operation itself
        const normalizedSub = normalizeMutation(subMutation);

        return {
            op: 'modify_weapon',
            weaponName: mut.weapon_target === 'all' ? undefined : mut.weapon_target,
            mutations: [normalizedSub]
        } as MutationOperation;
    }

    // Normalization based on op
    switch (op) {
        case 'set':
            if (!field) throw new Error(`Mutation '${op}' missing field/target`);
            return {
                op: 'set',
                field: field,
                value: mut.value
            };

        case 'multiply':
            if (!field) throw new Error(`Mutation '${op}' missing field/target`);
            return {
                op: 'multiply',
                field: field,
                factor: mut.factor !== undefined ? mut.factor : mut.value
            };

        case 'list_append':
            if (!field) throw new Error(`Mutation '${op}' missing field/target`);
            return {
                op: 'list_append',
                field: field,
                value: mut.value
            };

        case 'list_remove':
             if (!field) throw new Error(`Mutation '${op}' missing field/target`);
             return {
                 op: 'list_remove',
                 field: field,
                 value: mut.value
             };

        case 'assign_math_floor':
             // Assuming structure: target, source, factor (or value)
             return {
                 op: 'assign_math_floor',
                 target: field,
                 source: (mut.source || field) as UnitDefField,
                 factor: mut.factor !== undefined ? mut.factor : mut.value
             };

        case 'table_merge':
            if (!field) throw new Error(`Mutation '${op}' missing field/target`);
            return {
                op: 'table_merge',
                field: field,
                value: mut.value
            };

        case 'clone_unit':
             return {
                 op: 'clone_unit',
                 source: mut.source,
                 target: mut.target, // Note: For clone_unit, target is the new unit name, which maps to 'target' prop in DSL
                 targetSuffix: mut.targetSuffix,
                 mutations: mut.mutations ? mut.mutations.map(normalizeMutation) : []
             };

        case 'modify_weapon':
            return {
                op: 'modify_weapon',
                weaponName: mut.weaponName,
                mutations: mut.mutations ? mut.mutations.map(normalizeMutation) : []
            };

        case 'remove':
             if (!field) throw new Error(`Mutation '${op}' missing field/target`);
             return {
                 op: 'remove',
                 field: field
             };

        default:
            throw new Error(`Unknown mutation op: ${op}`);
    }
}

function normalizeDefinition(def: LegacyDefinition): TweakDefinition {
    if (!['UnitDefsLoop', 'UnitDef_Post', 'Global'].includes(def.scope)) {
        throw new Error(`Invalid scope: ${def.scope}`);
    }

    return {
        name: def.name,
        description: def.description,
        scope: def.scope as any,
        conditions: def.conditions as TweakCondition[], // Assume conditions are mostly compatible
        mutations: def.mutations.map(normalizeMutation)
    };
}

function main() {
    const allTweaks: TweakDefinition[] = [];

    // 1. Process tweak-library.json
    if (fs.existsSync(TWEAK_LIB_PATH)) {
        console.log(`Processing ${TWEAK_LIB_PATH}...`);
        const libContent = JSON.parse(fs.readFileSync(TWEAK_LIB_PATH, 'utf-8'));
        // libContent is Record<string, TweakDefinition>
        for (const key of Object.keys(libContent)) {
            const def = libContent[key];
            try {
                // Ensure name is set if missing (using key)
                if (!def.name) def.name = key;
                allTweaks.push(normalizeDefinition(def));
            } catch (e: any) {
                console.error(`Error processing library entry ${key}: ${e.message}`);
                process.exit(1);
            }
        }
    }

    // 2. Process src/tweaks/*.json
    if (fs.existsSync(TWEAKS_DIR)) {
        const files = fs.readdirSync(TWEAKS_DIR).filter(f => f.endsWith('.json'));
        for (const file of files) {
            console.log(`Processing ${file}...`);
            const content = JSON.parse(fs.readFileSync(path.join(TWEAKS_DIR, file), 'utf-8'));
            if (content.definitions && Array.isArray(content.definitions)) {
                for (const def of content.definitions) {
                    try {
                        allTweaks.push(normalizeDefinition(def));
                    } catch (e: any) {
                        console.error(`Error processing definition '${def.name}' in ${file}: ${e.message}`);
                        process.exit(1);
                    }
                }
            }
        }
    }

    // 3. Output
    fs.writeFileSync(OUTPUT_PATH, JSON.stringify(allTweaks, null, 2));
    console.log(`Successfully wrote ${allTweaks.length} definitions to ${OUTPUT_PATH}`);
}

main();
