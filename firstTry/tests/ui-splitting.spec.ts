import { test, expect } from '@playwright/test';

test('Verify Command Splitting UI - Compact Chunks', async ({ page }) => {
    // 1. Go to page
    await page.goto('/');

    // 2. Wait for initial rendering
    const output1 = page.locator('#command-output-1');
    await expect(output1).toBeVisible();

    // 3. Check splitting logic with larger chunks (40000 chars)
    // MasterGadget is ~112KB Base64.
    // 112000 / 40000 ≈ 2.8 chunks.
    // Expect Parts 1, 2, 3 to be visible.
    // Expect Part 4 to be hidden.

    const section3 = page.locator('#part-3-section');
    const output3 = page.locator('#command-output-3');
    
    // Check if Part 3 is visible
    await expect(section3).toBeVisible({ timeout: 5000 });
    
    const text3 = await output3.inputValue();
    console.log(`Part 3 content length: ${text3.length}`);
    expect(text3.length).toBeGreaterThan(0);
    
    // Check Part 4 should be hidden
    const section4 = page.locator('#part-4-section');
    await expect(section4).toBeHidden();
});
