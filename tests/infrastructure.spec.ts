import { test, expect, Page } from '@playwright/test';

// Helper to verify mod option injection
async function verifyModOptionInjection(page: Page, optionName: string, expectedValue: string | number | null) {
    let found = false;
    // Check all potentially visible output areas
    for (let i = 1; i <= 7; i++) {
        const locator = page.locator(`#command-output-${i}`);
        if (await locator.isVisible()) {
            const text = await locator.inputValue();
            // Regex to find !bset <optionName> <value>
            // We use \b to ensure word boundary
            const pattern = `!bset\\s+${optionName}\\s+${expectedValue}\\b`;
            const regex = new RegExp(pattern);
            if (regex.test(text)) {
                found = true;
                break;
            }
        }
    }

    if (expectedValue !== null) {
        expect(found, `Expected !bset ${optionName} ${expectedValue} to be present in output`).toBeTruthy();
    } else {
        // If null, we might expect it to NOT be there, but for now we only use this for positive assertions.
    }
}

test.describe('Infrastructure & ModOption Injection', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('/');
        await expect(page.locator('#options-form-columns')).toBeVisible();
    });

    test('Existing numeric input generates ModOption', async ({ page }) => {
        // "Fusion - Min Tier" is a known numeric input with modOption="fusion_mintier"
        const inputLabel = page.locator('label', { hasText: 'Fusion - Min Tier' });
        await expect(inputLabel).toBeVisible();

        const input = inputLabel.locator('input');

        // Initial value check
        await expect(input).toHaveValue('1');

        // Change value
        await input.fill('3');
        // Trigger output update (input event should handle it for numeric-tweak)

        await verifyModOptionInjection(page, 'fusion_mintier', '3');
    });

    test('Injected checkbox generates ModOption correctly (1/0)', async ({ page }) => {
        // Inject a dummy checkbox with data-mod-option="test_debug"
        await page.evaluate(() => {
            const container = document.getElementById('options-form-columns');
            if (!container) return;

            const label = document.createElement('label');
            label.textContent = 'Test Debug Mode: ';
            const input = document.createElement('input');
            input.type = 'checkbox';
            input.dataset.modOption = 'test_debug';
            input.id = 'test-debug-cb';

            label.appendChild(input);
            container.appendChild(label);
        });

        const checkbox = page.locator('#test-debug-cb');
        await expect(checkbox).toBeVisible();

        // Check the checkbox
        await checkbox.check();

        // Trigger update by toggling "NuttyB Main Tweaks"
        const mainTweaks = page.locator('input[data-option-label="NuttyB Main Tweaks"]');
        await mainTweaks.uncheck();
        await mainTweaks.check();

        // Expect !bset test_debug 1
        await verifyModOptionInjection(page, 'test_debug', '1');

        // Uncheck the checkbox
        await checkbox.uncheck();

        // Trigger update
        await mainTweaks.uncheck();
        await mainTweaks.check();

        // Expect !bset test_debug 0
        await verifyModOptionInjection(page, 'test_debug', '0');
    });
});
