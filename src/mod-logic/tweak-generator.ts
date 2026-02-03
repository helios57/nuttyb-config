import { compileTweak } from './lua-compiler';
import { TweakDefinition } from './tweak-dsl';
import * as Definitions from './tweak-definitions';

export function generateTweak(config: any): string {
    if (config.generator === 'lua-table') {
        return generateLuaTable(config.description, config.data);
    }
    if (config.generator === 'tweak-function') {
        const func = (Definitions as any)[config.functionId];
        if (typeof func !== 'function') return `-- Error: Function ${config.functionId} not found`;
        try {
            const values = config.values || {};
            // Assuming function might take values or not.
            // Our standard signature for legacy tweaks is often () => TweakDefinition
            // But some take params (hp tweaks).
            // For now, call it with no args or args if provided?
            // If it expects args, we should pass them.
            // Simple approach: pass values object if function accepts arguments?
            // But our HP functions take specific args, not an object.
            // Let's assume for now legacy tweaks are parameterless or we adapt them.
            const tweak = func();
            return compileTweak(tweak);
        } catch (e: any) {
            return `-- Error generating tweak from function: ${e.message}`;
        }
    }
    if (config.generator === 'tweak-definition') {
        try {
            // Hydrate using provided values or defaults
            // config.values should contain the UI selections or defaults
            const values = config.values || {}; 
            const hydrated = hydrate(config.tweaks, values);
            return compileTweak(hydrated);
        } catch (e: any) {
            return `-- Error compiling tweak: ${e.message}`;
        }
    }
    return `-- Error: Unknown generator ${config.generator}`;
}

function hydrate(obj: any, values: Record<string, any>): any {
    if (typeof obj === 'string') {
        const replaced = obj.replace(/\{\{([^}]+)\}\}/g, (_, key) => {
            return values[key] !== undefined ? values[key] : `{{${key}}}`;
        });
        // Try to convert to number if it was a placeholder replacement and looks like a number
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
        // Escape single quotes
        return `'${obj.replace(/'/g, "\\'")}'`; 
    }
    if (typeof obj === 'number') return obj.toString();
    if (typeof obj === 'boolean') return obj ? 'true' : 'false';
    
    if (Array.isArray(obj)) {
        // Check if it's empty
        if (obj.length === 0) return '{}';
        const items = obj.map(v => tableToLua(v)).join(',');
        return `{${items}}`;
    }
    
    if (typeof obj === 'object') {
        const parts: string[] = [];
        const keys = Object.keys(obj);
        if (keys.length === 0) return '{}';
        
        for (const k of keys) {
            // Check if key is a valid identifier (alphanumeric + underscore, not starting with digit)
            // Lua identifiers: ^[a-zA-Z_][a-zA-Z0-9_]*$
            const isValidId = /^[a-zA-Z_][a-zA-Z0-9_]*$/.test(k);
            const key = isValidId ? k : `['${k}']`;
            parts.push(`${key}=${tableToLua(obj[k])}`);
        }
        return `{${parts.join(',')}}`;
    }
    return 'nil';
}
