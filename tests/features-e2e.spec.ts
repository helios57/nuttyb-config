import { test, expect } from '@playwright/test';
import { LuaFactory } from 'wasmoon';
import { getDecodedTweak, getAllDecodedTweaks, setupLuaEnvironment } from './e2e-utils';
import { validateLua } from '../src/mod-logic/lua-validator';

test('Feature: Limit Max Allowed (T3 Builders)', async ({ page }) => {
    const luaFactory = new LuaFactory();
    const lua = await luaFactory.createEngine();

    try {
        await setupLuaEnvironment(lua);

        await page.goto('/');

        const input = page.locator('input[data-tweak-template-id="tweak_limit_t3builders"]');
        await expect(input).toBeVisible();

        await input.fill('5');

        const decodedLua = await getDecodedTweak(page);

        // Execute Generated Lua
        await lua.doString(decodedLua);

        // Verify effects on UnitDefs
        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armconst3.maxThisUnit).toBe(5);
        expect(unitDefs.corconst3.maxThisUnit).toBe(5);
        expect(unitDefs.legconst3.maxThisUnit).toBe(5);

    } finally {
        lua.global.close();
    }
});

test('Feature: Mode Specific Logic (Scavengers vs Raptors)', async ({ page }) => {
    const luaFactory = new LuaFactory();

    // 1. Scavengers Mode
    {
        const lua = await luaFactory.createEngine();
        try {
            await setupLuaEnvironment(lua);

            await page.goto('/');

            const primaryMode = page.locator('#primary-mode-select');
            await primaryMode.selectOption('Scavengers');

            const scavHp = page.locator('#scav-hp-select');
            await expect(scavHp).toBeVisible();
            await scavHp.selectOption('1.3');

            const scavLua = await getDecodedTweak(page);
            // Verify Lua generated contains multiplier
            expect(scavLua).toContain('1.3');
            await lua.doString(scavLua);

            // Simulate Spring behavior for UnitDef_Post tweaks
            await lua.doString(`
                if UnitDef_Post then
                    for id, def in pairs(UnitDefs) do
                        UnitDef_Post(id, def)
                    end
                end
            `);

            const unitDefs = lua.global.get('UnitDefs');
            const someScav = unitDefs.some_scav;
            // health=500 -> 650
            // metalCost=50 -> 65
            expect(someScav.health).toBe(Math.floor(500 * 1.3));
            expect(someScav.metalCost).toBe(Math.floor(50 * 1.3));

        } finally {
            lua.global.close();
        }
    }

    // 2. Raptors Mode
    {
        const lua = await luaFactory.createEngine();
        try {
            await setupLuaEnvironment(lua);

            // Switching mode on same page instance
            const primaryMode = page.locator('#primary-mode-select');
            await primaryMode.selectOption('Raptors');

            const raptorHealth = page.locator('select[data-option-type="Raptor Health"]');
            await expect(raptorHealth).toBeVisible();
            await raptorHealth.selectOption('2');

            const raptorLua = await getDecodedTweak(page);
            await lua.doString(raptorLua);

            const unitDefs = lua.global.get('UnitDefs');
            const swarmer = unitDefs.raptor_land_swarmer_heal;

            // 2x HP: Health 200 -> 400
            // Metal Factor 0.35: Metal = floor(400 * 0.35) = 140
            // WorkerTime 0.5: BuildSpeed 10 -> 5

            expect(swarmer.health).toBe(400);
            expect(swarmer.metalCost).toBe(140);
            expect(swarmer.buildSpeed).toBe(5);

        } finally {
            lua.global.close();
        }
    }
});

test('Feature: Stress Test - Complex Aggregation', async ({ page }) => {
    const luaFactory = new LuaFactory();
    const lua = await luaFactory.createEngine();

    try {
        await setupLuaEnvironment(lua);

        await page.goto('/');

        // 1. Enable Unit Launchers
        await page.locator('label').filter({ hasText: 'Unit Launchers' }).locator('input[type="checkbox"]').check();

        // 2. Limit Unit Launchers
        await page.locator('input[data-tweak-template-id="tweak_limit_unit_launchers"]').fill('15');

        // 3. Limit T3 Builders
        await page.locator('input[data-tweak-template-id="tweak_limit_t3builders"]').fill('5');

        // 4. Raptor Health (2x)
        await page.locator('select[data-option-type="Raptor Health"]').selectOption('2');

        // 5. Queen Health (2x)
        await page.locator('select[data-option-type="Queen Health"]').selectOption('2');

        // 6. Epic Ragnarok
        await page.locator('input[data-tweak-template-id="tweak_limit_epic_ragnarok"]').fill('1');

        // 7. Custom Tweak
        await page.click('button[data-tab="custom"]');
        await page.locator('#custom-option-desc').fill('My Custom Tweak');
        await page.locator('#custom-option-type').selectOption('tweakdefs');

        // Encode "UnitDefs.armcom.health = 1"
        const customLua = 'UnitDefs.armcom.health = 1';
        const customEncoded = Buffer.from(customLua).toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');

        await page.locator('#custom-tweak-code').fill(customEncoded);
        await page.click('#custom-tweak-form button[type="submit"]');

        // Go back to config and enable
        await page.click('button[data-tab="config"]');
        await page.locator('input[data-is-custom="true"]').check();

        const decodedTweaks = await getAllDecodedTweaks(page);

        // Validate and Execute all found tweaks
        for (const script of decodedTweaks) {
            const validation = validateLua(script);
            expect(validation.valid).toBeTruthy();
            await lua.doString(script);
        }

        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armmeatball.maxThisUnit).toBe(15);
        expect(unitDefs.armconst3.maxThisUnit).toBe(5);
        expect(unitDefs.raptor_land_swarmer_heal.health).toBe(400); // 2x
        expect(unitDefs.raptor_queen_v1.health).toBe(100000); // 2x of 50000
        expect(unitDefs.ragnarok.maxThisUnit).toBe(1);
        expect(unitDefs.armcom.health).toBe(1);

    } finally {
        lua.global.close();
    }
});

test('Feature: Game Multipliers (Resource Income)', async ({ page }) => {
    await page.goto('/');

    const input = page.locator('input[data-mod-option="multiplier_resourceincome"]');
    await expect(input).toBeVisible();

    await input.fill('3.5');

    // This checks simple command output, not tweakdefs
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
        await setupLuaEnvironment(lua);

        await page.goto('/');

        // 1. Enable Unit Launchers
        const checkbox = page.locator('input[type="checkbox"][data-tweak-template-id="tweak_enable_unit_launchers"]');
        await expect(checkbox).toBeVisible();
        await checkbox.check();

        // 2. Limit Unit Launchers
        const limitInput = page.locator('input[data-tweak-template-id="tweak_limit_unit_launchers"]');
        await expect(limitInput).toBeVisible();
        await limitInput.fill('15');

        const decodedLua = await getDecodedTweak(page);

        // Run Lua
        await lua.doString(decodedLua);

        // Verify effects
        const unitDefs = lua.global.get('UnitDefs');

        // Check buildoptions on armavp
        const armavp = unitDefs.armavp;
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

    await expect(page.getByText('NuttyB Main Tweaks', { exact: false })).toBeVisible();
    await expect(page.getByText('NuttyB Evolving Commanders', { exact: false })).toBeVisible();

    const evoComCheckbox = page.locator('label').filter({ hasText: 'NuttyB Evolving Commanders' }).locator('input[type="checkbox"]');
    await expect(evoComCheckbox).toBeVisible();
    await evoComCheckbox.check();

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

test('Feature: Comprehensive Coverage (Fusion, Compressed, Limits)', async ({ page }) => {
    const luaFactory = new LuaFactory();
    const lua = await luaFactory.createEngine();

    try {
        await setupLuaEnvironment(lua);

        await page.goto('/');

        // 1. Enable Singularity Fusion
        const fusionCheck = page.locator('label').filter({ hasText: 'Enable Singularity Fusion' }).locator('input[type="checkbox"]');
        await expect(fusionCheck).toBeVisible();
        await fusionCheck.check();

        // 2. Enable Adaptive Spawner
        const adaptiveCheck = page.locator('label').filter({ hasText: 'Enable Adaptive Spawner' }).locator('input[type="checkbox"]');
        await expect(adaptiveCheck).toBeVisible();
        await adaptiveCheck.check();

        // 3. Set Epic Ragnarok Limit
        const ragnarokInput = page.locator('input[data-tweak-template-id="tweak_limit_epic_ragnarok"]');
        await expect(ragnarokInput).toBeVisible();
        await ragnarokInput.fill('50');

        const decodedLua = await getDecodedTweak(page);

        // Run Lua
        await lua.doString(decodedLua);

        // Verify Fusion (armsolar_t2)
        const unitDefs = lua.global.get('UnitDefs');
        const solarT2 = unitDefs.armsolar_t2;
        expect(solarT2).toBeTruthy();
        expect(solarT2.name).toContain('Solar Collector T2');
        expect(solarT2.health).toBe(500 * 16.0); // 8000

        // Verify Compressed Unit (raptor_..._x5)
        const raptorX5 = unitDefs.raptor_land_swarmer_basic_t1_v1_compressed_x5;
        expect(raptorX5).toBeTruthy();
        expect(raptorX5.health).toBe(100 * 5);
        // Accessing table properties via wasmoon object wrapper can be tricky if they are not exposed directly
        // but wasmoon usually proxies.
        // customParams might be undefined if not initialized in Lua or if proxy issues.
        // We set customParams = {} in mock.
        // The generator merges: { is_compressed_unit: true, ... }
        expect(raptorX5.customParams).toBeTruthy();
        // Wasmoon tables usually come back as objects.
        expect(raptorX5.customParams.is_compressed_unit).toBeTruthy();

        // Verify Limit
        const ragnarok = unitDefs.ragnarok;
        expect(ragnarok.maxThisUnit).toBe(50);

    } finally {
        lua.global.close();
    }
});
