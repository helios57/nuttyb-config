import * as Scripts from './generators/scripts-index';

export function generateTweak(config: any): string {
    if (config.generator === 'static-script') {
        const script = (Scripts as any)[config.scriptId];
        if (!script) return `-- Error: Script ${config.scriptId} not found`;
        return script;
    }
    if (config.generator === 'lua-table') {
        return generateLuaTable(config.description, config.data);
    }
    return `-- Error: Unknown generator ${config.generator}`;
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
