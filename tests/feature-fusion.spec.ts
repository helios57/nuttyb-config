import { test, expect } from '@playwright/test';
import { verifyModOptionInjection } from './e2e-utils'; // We'll move the helper here or redefine it

test.describe('Feature: Fusion Protocol', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('/');
        await expect(page.locator('#options-form-columns')).toBeVisible();
    });

    test('Fusion Enable Checkbox generates mod option', async ({ page }) => {
        const checkbox = page.locator('input[data-option-label="Enable Singularity Fusion"]');
        await expect(checkbox).toBeVisible();

        // Check it
        await checkbox.check();

        // Output should contain !bset fusion_mode 1
        await verifyModOptionInjection(page, 'fusion_mode', '1');

        // Uncheck it
        await checkbox.uncheck();
        await verifyModOptionInjection(page, 'fusion_mode', '0');
    });

    test('Fusion Min Tier slider generates mod option', async ({ page }) => {
        const input = page.locator('input[data-mod-option="fusion_mintier"]');
        await expect(input).toBeVisible();

        await input.fill('3');
        await verifyModOptionInjection(page, 'fusion_mintier', '3');
    });

    test('Fusion Efficiency Bonus generates mod option', async ({ page }) => {
        const input = page.locator('input[data-mod-option="fusion_efficiency"]');
        await expect(input).toBeVisible();

        await input.fill('1.25');
        await verifyModOptionInjection(page, 'fusion_efficiency', '1.25');
    });
});
