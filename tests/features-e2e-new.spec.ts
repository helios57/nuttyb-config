import { test, expect } from '@playwright/test';

test('Feature: Fusion Settings (Min Tier)', async ({ page }) => {
    await page.goto('/');

    // Look for "Fusion - Min Tier" input
    // The label text might be split or contain the input.
    // Based on ui-renderer logic, numeric-tweak usually renders an input with data-mod-option if specified.
    const input = page.locator('input[data-mod-option="fusion_mintier"]');
    await expect(input).toBeVisible();

    await input.fill('3');

    // Verify output
    let foundCmd = false;
    for (let i = 1; i <= 7; i++) {
        const locator = page.locator(`#command-output-${i}`);
        if (await locator.isVisible()) {
            const text = await locator.inputValue();
            if (text.includes('!bset fusion_mintier 3')) {
                foundCmd = true;
                break;
            }
        }
    }
    expect(foundCmd).toBeTruthy();
});

test('Feature: Culling Settings (Min SimSpeed)', async ({ page }) => {
    await page.goto('/');

    const input = page.locator('input[data-mod-option="cull_simspeed"]');
    await expect(input).toBeVisible();

    await input.fill('0.5');

    let foundCmd = false;
    for (let i = 1; i <= 7; i++) {
        const locator = page.locator(`#command-output-${i}`);
        if (await locator.isVisible()) {
            const text = await locator.inputValue();
            if (text.includes('!bset cull_simspeed 0.5')) {
                foundCmd = true;
                break;
            }
        }
    }
    expect(foundCmd).toBeTruthy();
});

test('Feature: Adaptive Spawner (Enable)', async ({ page }) => {
    await page.goto('/');

    // Checkbox for "Enable Adaptive Spawner"
    // Label: "Enable Adaptive Spawner"
    const checkbox = page.locator('label').filter({ hasText: 'Enable Adaptive Spawner' }).locator('input[type="checkbox"]');
    await expect(checkbox).toBeVisible();

    // It defaults to false. Check it.
    await checkbox.check();

    let foundCmd = false;
    for (let i = 1; i <= 7; i++) {
        const locator = page.locator(`#command-output-${i}`);
        if (await locator.isVisible()) {
            const text = await locator.inputValue();
            // Defined in config-data as commandBlocks: ['!bset adaptive_spawner 1']
            if (text.includes('!bset adaptive_spawner 1')) {
                foundCmd = true;
                break;
            }
        }
    }
    expect(foundCmd).toBeTruthy();
});
