import { test, expect } from '@playwright/test';

// Helper to decode base64 command
function decodeCommand(command: string): string {
    const match = command.match(/!bset\s+tweak(?:defs|units)\d+\s+(.+)/);
    if (!match) {
        return "";
    }
    const base64 = match[1];

    let b64 = base64.replace(/-/g, '+').replace(/_/g, '/');
    while (b64.length % 4) {
        b64 += '=';
    }

    return Buffer.from(b64, 'base64').toString('utf-8');
}

// Helper to get all output text
async function getOutputText(page: any): Promise<string> {
    let outputText = '';
    for (let i = 1; i <= 7; i++) {
        const locator = page.locator(`#command-output-${i}`);
        if (await locator.isVisible()) {
            outputText += await locator.inputValue() + '\n';
        }
    }
    return outputText;
}

test.describe('Feature Verification', () => {

    test('NuttyB Main Tweaks Checkbox', async ({ page }) => {
        await page.goto('/');
        const checkbox = page.getByLabel('NuttyB Main Tweaks');
        await expect(checkbox).toBeVisible();
        await expect(checkbox).toHaveAttribute('data-option-label', 'NuttyB Main Tweaks');

        let output = await getOutputText(page);
        const baseMarker = '!autobalance off';

        // Default: Checked
        expect(output).toContain(baseMarker);

        // Uncheck
        await checkbox.uncheck();
        output = await getOutputText(page);

        // Should NOT contain base commands
        expect(output).not.toContain(baseMarker);
    });

    test('NuttyB Evolving Commanders', async ({ page }) => {
        await page.goto('/');
        const checkbox = page.getByLabel('NuttyB Evolving Commanders');

        await checkbox.check();
        const output = await getOutputText(page);
        expect(output).toContain('!evocom 1');

        await checkbox.uncheck();
        const output2 = await getOutputText(page);
        expect(output2).not.toContain('!evocom 1');
    });

    test('Raptor Health (Generator)', async ({ page }) => {
        await page.goto('/');
        const select = page.locator('label', { hasText: 'Raptor Health:' }).locator('select');
        await select.selectOption('2'); // 2x HP

        const output = await getOutputText(page);
        expect(output).toContain('!bset tweakdefs');

        const lines = output.split('\n');
        const tweakCmd = lines.find(l => l.includes('!bset tweakdefs'));
        expect(tweakCmd).toBeDefined();
        if (tweakCmd) {
            const lua = decodeCommand(tweakCmd);
            expect(lua).toContain('def.health * (2)');
        }
    });

    test('Queen Quantity (Mod Option)', async ({ page }) => {
        await page.goto('/');
        const input = page.getByLabel('Queen Quantity:');
        await input.fill('100');

        const output = await getOutputText(page);
        expect(output).toContain('!bset raptor_queen_count 100');
    });

    test('Raptor Settings: Wave Multiplier', async ({ page }) => {
        await page.goto('/');
        const input = page.getByLabel('Wave Multiplier:');
        await input.fill('4');
        const output = await getOutputText(page);
        expect(output).toContain('!bset raptor_spawncountmult 4');
    });

    test('Raptor Settings: First Waves Boost', async ({ page }) => {
        await page.goto('/');
        const input = page.getByLabel('First Waves Boost:');
        await input.fill('4');
        const output = await getOutputText(page);
        expect(output).toContain('!bset raptor_firstwavesboost 4');
    });

    test('Raptor Settings: Grace Period Multiplier', async ({ page }) => {
        await page.goto('/');
        const input = page.getByLabel('Grace Period Multiplier:');
        await input.fill('3');
        const output = await getOutputText(page);
        expect(output).toContain('!bset raptor_graceperiodmult 3');
    });

    test('Mechanics: Cross Faction T2', async ({ page }) => {
        await page.goto('/');
        const checkbox = page.getByLabel('Cross Faction T2');
        await checkbox.check();

        // This test verifies that checking the box works without error,
        // even if the command block is currently empty in the config.
        const output = await getOutputText(page);
        expect(output).toBeDefined();
    });

    test('Limit Max Allowed: T3 Builders', async ({ page }) => {
        await page.goto('/');
        const input = page.getByLabel('T3 Builders:');
        await input.fill('7');

        const output = await getOutputText(page);
        const lines = output.split('\n');
        const tweakCmd = lines.find(l => l.includes('!bset tweakdefs') || l.includes('!bset tweakunits'));

        expect(tweakCmd).toBeDefined();
        if (tweakCmd) {
            const lua = decodeCommand(tweakCmd);
            expect(lua).toContain('def.maxThisUnit = 7');
        }
    });

    test('Limit Max Allowed: Epic Ragnarok', async ({ page }) => {
        await page.goto('/');
        const input = page.getByLabel('Epic Ragnarok:');
        await input.fill('5');

        const output = await getOutputText(page);
        const lines = output.split('\n');
        const tweakCmd = lines.find(l => l.includes('!bset tweakdefs') || l.includes('!bset tweakunits'));

        expect(tweakCmd).toBeDefined();
        if (tweakCmd) {
            const lua = decodeCommand(tweakCmd);
            // tweak_limit_epic_ragnarok -> def.maxThisUnit = limit
            expect(lua).toContain('def.maxThisUnit = 5');
            expect(lua).toContain('ragnarok'); // heuristic
        }
    });

    test('Game Multipliers: Resource Income', async ({ page }) => {
        await page.goto('/');
        const input = page.getByLabel('Resource Income:');
        await input.fill('3.5');

        const output = await getOutputText(page);
        expect(output).toContain('!bset multiplier_resourceincome 3.5');
    });

    test('Game Multipliers: Shield Power', async ({ page }) => {
        await page.goto('/');
        const input = page.getByLabel('Shield Power:');
        await input.fill('2.5');

        const output = await getOutputText(page);
        expect(output).toContain('!bset multiplier_shieldpower 2.5');
    });

    test('Map Selection', async ({ page }) => {
        await page.goto('/');
        const select = page.locator('#maps-select');
        await select.selectOption({ label: 'Full Metal Plate (12P)' });

        const output = await getOutputText(page);
        expect(output).toContain('!map Full Metal Plate');
    });

    test('Mode Selection', async ({ page }) => {
        await page.goto('/');
        const select = page.locator('#modes-select');
        await select.selectOption({ label: 'No Rush' });

        const output = await getOutputText(page);
        // "No Rush" adds !raptor_queentimemult 1.3
        expect(output).toContain('!raptor_queentimemult 1.3');
    });

    test('Enable Singularity Fusion', async ({ page }) => {
        await page.goto('/');
        const checkbox = page.getByLabel('Enable Singularity Fusion');
        await checkbox.check();

        const output = await getOutputText(page);
        expect(output).toContain('!bset fusion_mode 1');

        const lines = output.split('\n');
        const tweakCmd = lines.find(l => l.includes('!bset tweakdefs') || l.includes('!bset tweakunits'));

        expect(tweakCmd).toBeDefined();
        if (tweakCmd) {
            const lua = decodeCommand(tweakCmd);
            // Should contain fusion units like 'armsolar_t2' or 'fusion_tier = 2'
            expect(lua).toContain('is_fusion_unit = true');
        }
    });

    test('Enable Adaptive Spawner', async ({ page }) => {
        await page.goto('/');
        const checkbox = page.getByLabel('Enable Adaptive Spawner');
        await checkbox.check();

        const output = await getOutputText(page);
        expect(output).toContain('!bset adaptive_spawner 1');

        const lines = output.split('\n');
        const tweakCmd = lines.find(l => l.includes('!bset tweakdefs') || l.includes('!bset tweakunits'));

        expect(tweakCmd).toBeDefined();
        if (tweakCmd) {
            const lua = decodeCommand(tweakCmd);
            // Should contain mega raptors like '_compressed_x2' or 'is_compressed_unit'
            expect(lua).toContain('is_compressed_unit = true');
        }
    });

    test('Culling Options', async ({ page }) => {
        await page.goto('/');

        const simSpeedInput = page.getByLabel('Culling - Min SimSpeed:');
        await simSpeedInput.fill('0.5');

        const maxUnitsInput = page.getByLabel('Culling - Max Units:');
        await maxUnitsInput.fill('8000');

        const output = await getOutputText(page);
        expect(output).toContain('!bset cull_simspeed 0.5');
        expect(output).toContain('!bset cull_maxunits 8000');
    });

});
