import { test, expect } from '@playwright/test';
import { verifyModOptionInjection } from './e2e-utils';

test.describe('Feature: Auto-Culling', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('/');
        await expect(page.locator('#options-form-columns')).toBeVisible();
    });

    test('Culling Enable Checkbox generates mod option', async ({ page }) => {
        const checkbox = page.locator('input[data-option-label="Enable Auto-Culling"]');
        await expect(checkbox).toBeVisible();

        await checkbox.check();
        await verifyModOptionInjection(page, 'cull_enabled', '1');

        await checkbox.uncheck();
        await verifyModOptionInjection(page, 'cull_enabled', '0');
    });

    test('Culling Safe Zone Radius generates mod option', async ({ page }) => {
        const input = page.locator('input[data-mod-option="cull_radius"]');
        await expect(input).toBeVisible();

        await input.fill('3000');
        await verifyModOptionInjection(page, 'cull_radius', '3000');
    });
});
