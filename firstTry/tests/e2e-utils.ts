import { Page } from '@playwright/test';
import { LuaEngine } from 'wasmoon';
import { getMockUnitDefsLua } from './mock-spring';

export function decodeCommand(command: string): string {
    const match = command.match(/!bset\s+tweak(?:defs|units)\d*\s+(.+)/);
    if (!match) {
        throw new Error(`Command does not match expected format: ${command}`);
    }
    let base64 = match[1];

    // Remove surrounding quotes if present
    if (base64.startsWith('"') && base64.endsWith('"')) {
        base64 = base64.slice(1, -1);
    }

    let b64 = base64.replace(/-/g, '+').replace(/_/g, '/');
    while (b64.length % 4) {
        b64 += '=';
    }

    return Buffer.from(b64, 'base64').toString('utf-8');
}

export async function getDecodedTweak(page: Page): Promise<string> {
    const scripts = await getAllDecodedTweaks(page);
    if (scripts.length === 0) {
        throw new Error('No !bset tweakdefs command found in output.');
    }
    return scripts.join('');
}

export async function getAllDecodedTweaks(page: Page): Promise<string[]> {
    const scripts: string[] = [];
    for (let i = 1; i <= 15; i++) {
        const locator = page.locator(`#command-output-${i}`);
        if (await locator.isVisible()) {
            const text = await locator.inputValue();
            const lines = text.split('\n');
            for (const line of lines) {
                if (line.startsWith('!bset tweakdefs')) {
                    scripts.push(decodeCommand(line));
                }
            }
        }
    }
    return scripts;
}

import { expect } from '@playwright/test';

export async function setupLuaEnvironment(lua: LuaEngine) {
    // Load Mock UnitDefs
    await lua.doString(getMockUnitDefsLua());

    // Mock Spring API and table extensions used by compiler
    await lua.doString(`
        Spring = {
            GetModOptions = function() return {} end
        }

        if not table then table = {} end

        table.merge = function(t1, t2)
            if not t2 then return t1 end
            for k,v in pairs(t2) do t1[k] = v end
            return t1
        end

        if not table.insert then
            table.insert = function(t, v) t[#t+1] = v end
        end
    `);
}

export async function verifyModOptionInjection(page: Page, optionName: string, expectedValue: string | number | null) {
    let found = false;
    for (let i = 1; i <= 15; i++) {
        const locator = page.locator(`#command-output-${i}`);
        if (await locator.isVisible()) {
            const text = await locator.inputValue();
            const pattern = `!bset\\s+${optionName}\\s+${expectedValue}\\b`;
            const regex = new RegExp(pattern);
            if (regex.test(text)) {
                found = true;
                break;
            }
        }
    }

    if (expectedValue !== null) {
        expect(found, `Expected !bset ${optionName} ${expectedValue} to be present in output`).toBeTruthy();
    }
}
