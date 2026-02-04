import { Page } from '@playwright/test';
import { LuaEngine } from 'wasmoon';
import { getMockUnitDefsLua } from './mock-spring';

export function decodeCommand(command: string): string {
    const match = command.match(/!bset\s+tweak(?:defs|units)\d+\s+(.+)/);
    if (!match) {
        throw new Error(`Command does not match expected format: ${command}`);
    }
    const base64 = match[1];

    let b64 = base64.replace(/-/g, '+').replace(/_/g, '/');
    while (b64.length % 4) {
        b64 += '=';
    }

    return Buffer.from(b64, 'base64').toString('utf-8');
}

export async function getDecodedTweak(page: Page): Promise<string> {
    // Scan all command-output-X textareas
    let foundBset = '';

    for (let i = 1; i <= 9; i++) {
        const locator = page.locator(`#command-output-${i}`);
        if (await locator.isVisible()) {
            const text = await locator.inputValue();
            if (text.includes('!bset tweakdefs')) {
                const lines = text.split('\n');
                for (const line of lines) {
                    if (line.startsWith('!bset tweakdefs')) {
                        // We use the last found one to match typical behavior of overriding or latest tweak
                        foundBset = line;
                    }
                }
            }
        }
    }

    if (!foundBset) {
        throw new Error('No !bset tweakdefs command found in output.');
    }

    return decodeCommand(foundBset);
}

export async function getAllDecodedTweaks(page: Page): Promise<string[]> {
    const scripts: string[] = [];
    for (let i = 1; i <= 9; i++) {
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
