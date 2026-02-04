import { test, expect } from '@playwright/test';
import { verifyModOptionInjection } from './e2e-utils';

test.describe('Feature: Adaptive Scaling', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('/');
        await expect(page.locator('#options-form-columns')).toBeVisible();
    });

    test('Adaptive Spawner Enable Checkbox generates mod option', async ({ page }) => {
        const checkbox = page.locator('input[data-option-label="Enable Adaptive Spawner"]');
        await expect(checkbox).toBeVisible();

        await checkbox.check();
        await verifyModOptionInjection(page, 'adaptive_spawner', '1');

        await checkbox.uncheck();
        await verifyModOptionInjection(page, 'adaptive_spawner', '0');
    });

    test('Max Compression Factor generates mod option', async ({ page }) => {
        const input = page.locator('input[data-mod-option="adaptive_compression_max"]');
        await expect(input).toBeVisible();

        await input.fill('5');
        await verifyModOptionInjection(page, 'adaptive_compression_max', '5');
    });

    test('Vampire Merge Enable Checkbox generates mod option', async ({ page }) => {
        const checkbox = page.locator('input[data-option-label="Enable Vampire Merge"]');
        await expect(checkbox).toBeVisible();

        await checkbox.check();
        await verifyModOptionInjection(page, 'adaptive_vampire', '1');
    });

    test('Boss Tint Enable Checkbox generates mod option', async ({ page }) => {
        const checkbox = page.locator('input[data-option-label="Enable Boss Tint"]');
        await expect(checkbox).toBeVisible();

        await checkbox.check();
        await verifyModOptionInjection(page, 'adaptive_boss_tint', '1');
    });
});
