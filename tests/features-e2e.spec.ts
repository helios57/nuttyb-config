import { test, expect } from '@playwright/test';
import { LuaFactory } from 'wasmoon';
import { getMockUnitDefsLua } from './mock-spring';

function decodeCommand(command: string): string {
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

test('Feature: Limit Max Allowed (T3 Builders)', async ({ page }) => {
    const luaFactory = new LuaFactory();
    const lua = await luaFactory.createEngine();

    try {
        await lua.doString(getMockUnitDefsLua());
        await lua.doString(`
            Spring = { GetModOptions = function() return {} end }
            if not table then table = {} end
            table.merge = function(t1, t2) for k,v in pairs(t2) do t1[k] = v end return t1 end
        `);

        await page.goto('/');

        // Find "Limit Max Allowed" inputs
        // T3 Builders. Label is "T3 Builders".
        // It's a numeric-tweak. Input is inside label.
        // ID not guaranteed, but we can search by text or dataset if we knew it.
        // We added dataset.tweakTemplateId="tweak_limit_t3builders".
        const input = page.locator('input[data-tweak-template-id="tweak_limit_t3builders"]');
        await expect(input).toBeVisible();

        await input.fill('5');

        // Check output
        // It generates a !bset tweakdefsX command.
        let foundBset = false;
        let bsetCommand = '';

        for (let i = 1; i <= 7; i++) {
            const locator = page.locator(`#command-output-${i}`);
            if (await locator.isVisible()) {
                const text = await locator.inputValue();
                if (text.includes('!bset tweakdefs')) {
                    const lines = text.split('\n');
                    const cmd = lines.find(l => l.includes('!bset tweakdefs') && l.includes(input.getAttribute('data-tweak-template-id') || 'XXX'));
                    // Wait, the command itself is base64 encoded. We can't see template ID in it easily unless we decode all.
                    // But we can decode the LAST !bset command if multiple.
                    // Or just decode any !bset tweakdefs.
                    // Let's decode all found.
                    for (const line of lines) {
                         if (line.startsWith('!bset tweakdefs')) {
                             const decoded = decodeCommand(line);
                             // Check if decoded contains "maxThisUnit" and "5"
                             if (decoded.includes('maxThisUnit = 5')) {
                                 bsetCommand = line;
                                 foundBset = true;
                                 break;
                             }
                         }
                    }
                }
            }
            if (foundBset) break;
        }

        expect(foundBset).toBeTruthy();

    } finally {
        lua.global.close();
    }
});

test('Feature: Game Multipliers (Resource Income)', async ({ page }) => {
    await page.goto('/');

    // Resource Income input
    const input = page.locator('input[data-mod-option="multiplier_resourceincome"]');
    await expect(input).toBeVisible();

    await input.fill('3.5');

    // Check output for !bset multiplier_resourceincome 3.5
    // This is NOT base64 encoded, it's direct !bset
    let foundCmd = false;

    for (let i = 1; i <= 7; i++) {
        const locator = page.locator(`#command-output-${i}`);
        if (await locator.isVisible()) {
            const text = await locator.inputValue();
            if (text.includes('!bset multiplier_resourceincome 3.5')) {
                foundCmd = true;
                break;
            }
        }
    }

    expect(foundCmd).toBeTruthy();
});

test('Feature: Raptor Settings (Queen Quantity)', async ({ page }) => {
    await page.goto('/');

    const input = page.locator('input[data-mod-option="raptor_queen_count"]');
    await expect(input).toBeVisible();

    await input.fill('12');

    let foundCmd = false;
    for (let i = 1; i <= 7; i++) {
        const locator = page.locator(`#command-output-${i}`);
        if (await locator.isVisible()) {
            const text = await locator.inputValue();
            if (text.includes('!bset raptor_queen_count 12')) {
                foundCmd = true;
                break;
            }
        }
    }
    expect(foundCmd).toBeTruthy();
});

test('Feature: Unit Launchers (Enable + Limit)', async ({ page }) => {
    const luaFactory = new LuaFactory();
    const lua = await luaFactory.createEngine();

    try {
        await lua.doString(getMockUnitDefsLua());
        await lua.doString(`
            Spring = { GetModOptions = function() return {} end }
            if not table then table = {} end
            table.merge = function(t1, t2) for k,v in pairs(t2) do t1[k] = v end return t1 end
            table.insert = function(t, v) t[#t+1] = v end
        `);

        // Mock armavp
        await lua.doString(`
            UnitDefs.armavp = { buildoptions = {} }
            UnitDefs.armmeatball = { maxThisUnit = 999 }
        `);

        await page.goto('/');

        // 1. Enable Unit Launchers
        // Checkbox. Label "Unit Launchers". dataset.tweakTemplateId="tweak_enable_unit_launchers"
        // Need to find the checkbox.
        // It is a checkbox input.
        const checkbox = page.locator('input[type="checkbox"][data-tweak-template-id="tweak_enable_unit_launchers"]');
        await expect(checkbox).toBeVisible();
        await checkbox.check();

        // 2. Limit Unit Launchers
        const limitInput = page.locator('input[data-tweak-template-id="tweak_limit_unit_launchers"]');
        await expect(limitInput).toBeVisible();
        await limitInput.fill('15');

        // Check outputs
        // We expect two tweaks. One for enabling, one for limit.
        // They might be combined into one Optimized Config if generated together?
        // command-generator combines all tweaks into one OptimizedLuaCompiler run.
        // So we expect ONE !bset tweakdefsX containing both logic.

        let foundBset = false;
        let bsetCommand = '';

        for (let i = 1; i <= 7; i++) {
            const locator = page.locator(`#command-output-${i}`);
            if (await locator.isVisible()) {
                const text = await locator.inputValue();
                if (text.includes('!bset tweakdefs')) {
                     const lines = text.split('\n');
                     for (const line of lines) {
                         if (line.startsWith('!bset tweakdefs')) {
                             bsetCommand = line; // Use the last one found or check content
                             // We assume one big tweak
                             foundBset = true;
                         }
                     }
                }
            }
        }
        expect(foundBset).toBeTruthy();

        const decodedLua = decodeCommand(bsetCommand);
        // console.log("Decoded Lua:", decodedLua);

        // Run Lua
        await lua.doString(decodedLua);

        // Verify effects
        const unitDefs = lua.global.get('UnitDefs');

        // Check buildoptions on armavp
        const armavp = unitDefs.armavp;
        // buildoptions should contain "armmeatball" and "corclogger"
        // Wasmoon maps tables to objects/arrays.
        // buildoptions is array-like table.
        // values in lua table: { [1]="armmeatball", [2]="corclogger" }
        // Let's check values.
        const bo = armavp.buildoptions;
        const boValues = Object.values(bo);
        expect(boValues).toContain("armmeatball");
        expect(boValues).toContain("corclogger");

        // Check limit on armmeatball
        const meatball = unitDefs.armmeatball;
        expect(meatball.maxThisUnit).toBe(15);

    } finally {
        lua.global.close();
    }
});

test('Feature: NuttyB Special Options', async ({ page }) => {
    await page.goto('/');

    // Check if the special options are visible
    // Note: The label text has a leading space in the DOM due to ' ' + optionGroup.label in ui-renderer.ts
    // So we look for text containing the label or use getByText with exact=false
    await expect(page.getByText('NuttyB Main Tweaks', { exact: false })).toBeVisible();
    await expect(page.getByText('NuttyB Evolving Commanders', { exact: false })).toBeVisible();

    // Toggle Evolving Commanders
    // The label text contains the input.
    const evoComCheckbox = page.locator('label').filter({ hasText: 'NuttyB Evolving Commanders' }).locator('input[type="checkbox"]');
    await expect(evoComCheckbox).toBeVisible();
    await evoComCheckbox.check();

    // Verify command generation for evocom
    // Should produce !evocom 1
    let foundCmd = false;
    for (let i = 1; i <= 7; i++) {
        const locator = page.locator(`#command-output-${i}`);
        if (await locator.isVisible()) {
            const text = await locator.inputValue();
            if (text.includes('!evocom 1')) {
                foundCmd = true;
                break;
            }
        }
    }
    expect(foundCmd).toBeTruthy();
});
