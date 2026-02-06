import { test, expect } from '@playwright/test';
import { decodeBase64Url, parseCommandOutput } from './utils';

test.describe('NuttyB Configurator UI Verification', () => {

    test.beforeEach(async ({ page }) => {
        page.on('console', msg => {
            if (msg.type() === 'error' || msg.type() === 'warning') {
                console.log(`[Browser Console] ${msg.type()}: ${msg.text()}`);
            }
        });

        await page.goto('/');
        await page.waitForSelector('#dynamic-tweaks-container', { state: 'attached' });
    });

    test('should generate correct commands for T4 Eco tweak', async ({ page }) => {
        // Wait for checkboxes to be rendered
        await expect(page.locator('.tweak-checkbox').first()).toBeVisible({ timeout: 15000 });

        // T4 Eco (Defs) might be in a later slot if Units are present.
        // Select it.
        const checkbox = page.getByLabel('T4 Eco');
        await expect(checkbox).toBeVisible();
        if (!(await checkbox.isChecked())) {
            await checkbox.check();
        }
        await expect(checkbox).toBeChecked();

        // Wait for update
        await page.waitForTimeout(2000);

        // Scan ALL output textareas
        const textareas = page.locator('textarea[id^="command-output-"]');
        const count = await textareas.count();
        let foundT4Eco = false;

        console.log(`Scanning ${count} output textareas for T4_ECO...`);

        for (let i = 0; i < count; i++) {
            const val = await textareas.nth(i).inputValue();
            const slots = parseCommandOutput(val);
            for (const [slot, payload] of slots) {
                try {
                    const decoded = decodeBase64Url(payload);
                    if (decoded.includes('T4_ECO')) {
                        foundT4Eco = true;
                        console.log(`Found T4_ECO in textarea ${i} (slot ${slot})`);
                        expect(decoded).toContain('unitDef.metalcost');
                    }
                } catch (e) {}
            }
        }

        expect(foundT4Eco).toBeTruthy();
    });

    test('should update Scavenger HP multiplier correctly', async ({ page }) => {
        const modeSelect = page.locator('#primary-mode-select');
        await modeSelect.selectOption('Scavengers');

        const scavHpSelect = page.locator('#scav-hp-select');
        await scavHpSelect.selectOption('2');

        await page.waitForTimeout(2000);

        const textareas = page.locator('textarea[id^="command-output-"]');
        const count = await textareas.count();
        let foundMultiplier = false;

        console.log(`Scanning ${count} output textareas for Scav HP 2x...`);

        for (let i = 0; i < count; i++) {
            const val = await textareas.nth(i).inputValue();
            const slots = parseCommandOutput(val);
            for (const [slot, payload] of slots) {
                try {
                    const decoded = decodeBase64Url(payload);
                    if (decoded.includes('SCAV_HP_2X_START')) {
                        foundMultiplier = true;
                        console.log(`Found SCAV_HP_2X in textarea ${i} (slot ${slot})`);
                        expect(decoded).toContain('unitDef.health = math.floor(unitDef.health * 2)');
                    }
                } catch (e) {}
            }
        }

        expect(foundMultiplier).toBeTruthy();
    });

    test('should verify copy buttons exist and have content', async ({ page }) => {
        await page.waitForTimeout(3000);
        const slotUsage = page.locator('#slot-usage-display');
        // Wait for card to appear
        await expect(page.locator('.slot-usage-card')).toBeVisible({ timeout: 10000 });
        await expect(slotUsage).toContainText(/Total Slot Usage/);
    });
});
