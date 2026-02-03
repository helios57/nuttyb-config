const { chromium } = require('@playwright/test');
const fs = require('fs');

(async () => {
    if (!fs.existsSync('verification')) {
        fs.mkdirSync('verification');
    }

    const browser = await chromium.launch();
    const page = await browser.newPage();

    // Serve usually runs on port 3000
    try {
        await page.goto('http://localhost:3000');

        // Wait for config loading
        await page.waitForSelector('#left-column label');

        // Find "NuttyB Main Tweaks"
        const checkbox = page.getByLabel('NuttyB Main Tweaks');
        await checkbox.scrollIntoViewIfNeeded();

        // Take screenshot
        await page.screenshot({ path: 'verification/nuttyb_tweaks.png' });
        console.log('Screenshot taken at verification/nuttyb_tweaks.png');
    } catch (e) {
        console.error(e);
    } finally {
        await browser.close();
    }
})();
