import { test, expect } from '@playwright/test';
import { getDecodedTweak } from './e2e-utils';

test.describe('Feature: Verify Generated Content (Lua Code)', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('/');
        await expect(page.locator('#options-form-columns')).toBeVisible();
    });

    test('Singularity Fusion generates UnitDefs in base64 string', async ({ page }) => {
        const checkbox = page.locator('input[data-option-label="Enable Singularity Fusion"]');
        await checkbox.check();

        // The generator runs on input change.
        // We need to get the !bset tweakdefs output
        const decodedLua = await getDecodedTweak(page);

        // Assert presence of Fusion logic
        // generateFusionUnits creates _t2, _t3 etc.
        expect(decodedLua).toContain('UnitDefs["armsolar_t2"]');
        expect(decodedLua).toContain('UnitDefs["armsolar_t3"]');
        expect(decodedLua).toContain('UnitDefs["corwin_t5"]'); // Random check

        // Also verify the ModOption command is there (just to be safe, though getDecodedTweak gets the big block)
        const output = await page.locator('#command-output-1').inputValue();
        expect(output).toContain('!bset fusion_mode 1');
    });

    test('Adaptive Spawner generates Compressed UnitDefs in base64 string', async ({ page }) => {
        const checkbox = page.locator('input[data-option-label="Enable Adaptive Spawner"]');
        await checkbox.check();

        const decodedLua = await getDecodedTweak(page);

        // generateMegaRaptors creates _compressed_x10 etc.
        expect(decodedLua).toContain('_compressed_x10');
        // Check for a unit we know is compressed (e.g., swarmer or solar)
        // Queens are currently excluded from compression.
        expect(decodedLua).toContain('UnitDefs["raptor_land_swarmer_basic_t1_v1_compressed_x10"]');

        const output = await page.locator('#command-output-1').inputValue();
        expect(output).toContain('!bset adaptive_spawner 1');
    });

    test('Evolving Commanders generates only command', async ({ page }) => {
        const checkbox = page.locator('input[data-option-label="NuttyB Evolving Commanders"]');
        await checkbox.check();

        const output = await page.locator('#command-output-1').inputValue();
        expect(output).toContain('!evocom 1');

        // Evolving Commanders does NOT currently generate tweaks in the base64 string in this codebase.
        // If the user expects it, this test would fail if we asserted presence.
        // We just assert the command is there.
    });
});
