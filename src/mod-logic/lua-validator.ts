import { parse } from 'luaparse';

export interface ValidationResult {
    valid: boolean;
    error?: string;
    line?: number;
}

export function validateLua(code: string): ValidationResult {
    try {
        parse(code);
        return { valid: true };
    } catch (e: any) {
        // luaparse errors usually have line and column properties
        const line = e.line !== undefined ? e.line : -1;
        const message = e.message || 'Unknown Lua syntax error';
        return { valid: false, error: message, line: line };
    }
}
