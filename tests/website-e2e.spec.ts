import { test, expect } from '@playwright/test';
import { LuaFactory } from 'wasmoon';
import { getMockUnitDefsLua } from './mock-spring';

// Helper to decode base64 command (reused from previous attempt but corrected)
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

test('Website to Lua E2E Flow: Scavengers Mode', async ({ page }) => {
    // 1. Initialize Wasmoon
    const luaFactory = new LuaFactory();
    const lua = await luaFactory.createEngine();

    try {
        await lua.doString(getMockUnitDefsLua());
        await lua.doString(`
            Spring = {
                GetModOptions = function() return {} end
            }
            if not table then table = {} end
            table.merge = function(t1, t2)
                for k,v in pairs(t2) do t1[k] = v end
                return t1
            end

            -- Shim for UnitDef_Post if needed, usually called by engine
             if not UnitDef_Post then UnitDef_Post = nil end
        `);

        // 2. Navigate to website
        await page.goto('/');

        // 3. Select Scavengers Mode
        // "primary-mode-select" is the ID for the mode selector
        await page.selectOption('#primary-mode-select', 'Scavengers');

        // 4. Select Scavenger HP Multiplier "2"
        // The ID is "scav-hp-select"
        await page.selectOption('#scav-hp-select', '2');

        // Wait a bit for UI update if debounced (code says updateOutput calls immediately)
        // But let's wait for output to appear.
        // The output is in textareas id="command-output-1" etc.
        // We expect !bset command in one of them.

        let foundBset = false;
        let bsetCommand = '';

        // Iterate through output textareas to find the command
        for (let i = 1; i <= 7; i++) {
            const locator = page.locator(`#command-output-${i}`);
            if (await locator.isVisible()) {
                const text = await locator.inputValue();
                if (text.includes('!bset tweakdefs')) {
                    const lines = text.split('\n');
                    const cmd = lines.find(l => l.startsWith('!bset tweakdefs'));
                    if (cmd) {
                        bsetCommand = cmd;
                        foundBset = true;
                        break;
                    }
                }
            }
        }

        expect(foundBset).toBeTruthy();

        // 5. Decode Lua
        const decodedLua = decodeCommand(bsetCommand);
        // console.log("Decoded Lua:", decodedLua);

        // 6. Run in Lua
        await lua.doString(decodedLua);

        // Simulate Engine Post-Tweak Logic if the tweak defines UnitDef_Post
        await lua.doString(`
            if UnitDef_Post then
                for name, def in pairs(UnitDefs) do
                    UnitDef_Post(name, def)
                end
            end
        `);

        // 7. Verify
        const unitDefs = lua.global.get('UnitDefs');

        // library.scav_hp_health -> targets nameEndsWith "_scav"
        // UnitDefs.some_scav health should be 500 * 2 = 1000
        const someScavHealth = unitDefs.some_scav.health;
        expect(someScavHealth).toBe(1000);

    } finally {
        lua.global.close();
    }
});

test('Website to Lua E2E Flow: Raptors Mode', async ({ page }) => {
     // 1. Initialize Wasmoon
    const luaFactory = new LuaFactory();
    const lua = await luaFactory.createEngine();

    try {
        await lua.doString(getMockUnitDefsLua());
        await lua.doString(`
            Spring = {
                GetModOptions = function() return {} end
            }
            if not table then table = {} end
            table.merge = function(t1, t2)
                for k,v in pairs(t2) do t1[k] = v end
                return t1
            end
        `);

        await page.goto('/');

        // Default is usually Raptors, but ensure it
        await page.selectOption('#primary-mode-select', 'Raptors');

        // Select Raptor HP "2" (ID usually #boss-hp-select for Boss, but let's check code...
        // app.ts: updateOutput... raptorOnlyContainer has selects.
        // Need to identify the Raptor HP select.
        // In previous test I used 'isHpGenerator' with 'hpType': 'hp'.
        // Looking at app.ts, we need to know the ID of that select.
        // app.ts doesn't explicitly name IDs for generated options, but `renderOptions` creates them.
        // `renderOptions` isn't fully visible here but `app.ts` queries `select[data-is-hp-generator="true"]`.
        // I can verify ID in `app.ts` logic if it exists, OR just search by label.
        // But app.ts shows: const scavHpSelect = document.getElementById('scav-hp-select')
        // It doesn't show raptor hp select ID.
        // However, I can use a locator based on dataset or label.

        // Let's assume the renderOptions logic creates consistent IDs or I can find by label "Raptor Health".
        // Or I can select by Attribute.

        // Using attribute selector
        // "options-form-columns" contains these.
        // Let's inspect "Raptor Health" dropdown.
        // Assuming label is "Raptor Health", I can find the select near it or inside.
        // Or select by data attribute: page.locator('select[data-hp-type="hp"]')

        const raptorHpSelect = page.locator('select[data-hp-type="hp"]');
        await expect(raptorHpSelect).toBeVisible();
        await raptorHpSelect.selectOption('2');

        // Find Output
        let foundBset = false;
        let bsetCommand = '';

        for (let i = 1; i <= 7; i++) {
            const locator = page.locator(`#command-output-${i}`);
             if (await locator.isVisible()) {
                const text = await locator.inputValue();
                 if (text.includes('!bset tweakdefs')) {
                    const lines = text.split('\n');
                    const cmd = lines.find(l => l.startsWith('!bset tweakdefs'));
                    if (cmd) {
                        bsetCommand = cmd;
                        foundBset = true;
                        break;
                    }
                }
            }
        }
        expect(foundBset).toBeTruthy();

        // Run
        const decodedLua = decodeCommand(bsetCommand);
        await lua.doString(decodedLua);

        const unitDefs = lua.global.get('UnitDefs');
        // raptor_land_swarmer_heal -> 200 * 2 = 400
        expect(unitDefs.raptor_land_swarmer_heal.health).toBe(400);

    } finally {
        lua.global.close();
    }
});
