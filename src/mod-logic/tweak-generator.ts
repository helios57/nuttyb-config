import { OptimizedLuaCompiler } from './optimized-compiler';
import { TweakDefinition, MutationOperation } from './tweak-dsl';

export function generateTweak(config: any): string {
    if (config.generator === 'lua-table') {
        return generateLuaTable(config.description, config.data);
    }

    if (config.generator === 'tweak-definition' || config.generator === 'json-schema') {
        try {
            const definitions: any[] = config.generator === 'json-schema' ? config.definitions : config.tweaks;
            const values = config.values || {};

            // Adapt definitions to strict TweakDefinition
            const adaptedDefs = definitions.map(def => adaptLegacyDefinition(def, values));

            // Compile
            const compiler = new OptimizedLuaCompiler();
            const inputs = adaptedDefs.map(d => ({ tweak: d, variables: {} })); // Variables already hydrated
            return compiler.compile(inputs);
        } catch (e: any) {
            return `-- Error compiling tweak: ${e.message}`;
        }
    }

    if (config.generator === 'tweak-function') {
        return `-- Error: Legacy tweak-function generator is no longer supported for ${config.label || 'unknown'}`;
    }

    return `-- Error: Unknown generator ${config.generator}`;
}

function adaptLegacyDefinition(def: any, values: Record<string, any>): TweakDefinition {
    // Hydrate fields
    const hydratedDef = hydrate(def, values);

    // Map legacy fields
    const mutations: MutationOperation[] = hydratedDef.mutations.map((m: any) => adaptLegacyMutation(m));

    return {
        name: hydratedDef.name,
        description: hydratedDef.description,
        scope: hydratedDef.scope,
        conditions: hydratedDef.conditions,
        mutations: mutations
    };
}

function adaptLegacyMutation(m: any): MutationOperation {
    if (m.weapon_target) {
        // Legacy: { op: 'set', weapon_target: 'all', target: 'name', value: 'Spike' }
        // New: { op: 'modify_weapon', weaponName: '*', mutations: [{ op: 'set', field: 'name', value: 'Spike' }] }
        const subOp = { ...m };
        delete subOp.weapon_target;
        const adaptedSub = adaptLegacyMutation(subOp);

        return {
            op: 'modify_weapon',
            weaponName: m.weapon_target === 'all' ? '*' : m.weapon_target,
            mutations: [adaptedSub]
        };
    }

    if (m.target) {
        // Legacy 'target' -> 'field'
        return {
            ...m,
            field: m.target,
            target: undefined // Remove legacy
        } as any;
    }

    // For assign_math_floor, it uses 'target' and 'source'.
    if (m.op === 'assign_math_floor') {
        // No change needed for properties except if 'target' was used as field name
        // My DSL uses 'target' for destination.
        // So it matches?
        // DSL: target: UnitDefField
        // Legacy: target: string
        // Matches.
    }

    return m;
}

function hydrate(obj: any, values: Record<string, any>): any {
    if (typeof obj === 'string') {
        const replaced = obj.replace(/\{\{([^}]+)\}\}/g, (_, key) => {
            return values[key] !== undefined ? values[key] : `{{${key}}}`;
        });
        if (replaced !== obj && !isNaN(Number(replaced)) && replaced.trim() !== '') {
            return Number(replaced);
        }
        return replaced;
    }
    if (Array.isArray(obj)) {
        return obj.map(v => hydrate(v, values));
    }
    if (typeof obj === 'object' && obj !== null) {
        const result: any = {};
        for (const k of Object.keys(obj)) {
            result[k] = hydrate(obj[k], values);
        }
        return result;
    }
    return obj;
}

function generateLuaTable(description: string, data: any): string {
    let lua = '';
    if (description) {
        lua += description + '\n';
    }
    lua += tableToLua(data);
    return lua;
}

function tableToLua(obj: any): string {
    if (obj === undefined) return 'nil';
    if (obj === null) return 'nil';
    
    if (typeof obj === 'string') {
        return `'${obj.replace(/'/g, "\\'")}'`; 
    }
    if (typeof obj === 'number') return obj.toString();
    if (typeof obj === 'boolean') return obj ? 'true' : 'false';
    
    if (Array.isArray(obj)) {
        if (obj.length === 0) return '{}';
        const items = obj.map(v => tableToLua(v)).join(',');
        return `{${items}}`;
    }
    
    if (typeof obj === 'object') {
        const parts: string[] = [];
        const keys = Object.keys(obj);
        if (keys.length === 0) return '{}';
        
        for (const k of keys) {
            const isValidId = /^[a-zA-Z_][a-zA-Z0-9_]*$/.test(k);
            const key = isValidId ? k : `['${k}']`;
            parts.push(`${key}=${tableToLua(obj[k])}`);
        }
        return `{${parts.join(',')}}`;
    }
    return 'nil';
}
