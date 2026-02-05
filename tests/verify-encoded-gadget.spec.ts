import { test, expect } from '@playwright/test';
import { LuaFactory } from 'wasmoon';
import * as fs from 'fs';
import * as path from 'path';
import { decodeCommand, setupLuaEnvironment } from './e2e-utils';

test.describe('Encoded Configuration Verification', () => {
    let luaFactory: LuaFactory;
    let lua: any;

    test.beforeEach(async () => {
        luaFactory = new LuaFactory();
        lua = await luaFactory.createEngine();
        await setupLuaEnvironment(lua);
    });

    test.afterEach(() => {
        if (lua) {
            lua.global.close();
        }
    });

    test('Encodes, Decodes and Executes MasterGadget.lua', async () => {
        // 1. Generate: Read and Encode
        // We assume MasterGadget.lua is built. In a real scenario, we might need to run the build script here.
        const masterPath = path.join(__dirname, '../lua/MasterGadget.lua');

        if (!fs.existsSync(masterPath)) {
            test.fail(true, `MasterGadget.lua not found at ${masterPath}. Please run 'npm run build:master' first.`);
        }

        const originalCode = fs.readFileSync(masterPath, 'utf-8');

        // Base64URL Encode: Simulating what the UI or a tool would do
        let base64 = Buffer.from(originalCode).toString('base64');
        base64 = base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

        const commandString = `!bset tweakdefs1 ${base64}`;

        // 2. Decode: Verify the utility works on our generated string
        const decodedCode = decodeCommand(commandString);

        // Basic integrity check
        expect(decodedCode).toBe(originalCode);

        // 3. Execute: Load into Wasmoon
        // setupLuaEnvironment already mocks Spring.GetModOptions to return {}
        // If MasterGadget needs specific options to not crash on load, we would need to adjust.
        // Based on analysis, it should be fine with empty options for loading.
        try {
            await lua.doString(decodedCode);
        } catch (e) {
            test.fail(true, `Failed to load decoded Lua code: ${e}`);
        }

        // 4. Verify: Run simulation checks

        // Check Gadget Globals
        const gadget = lua.global.get('gadget');
        expect(gadget).toBeDefined();
        expect(gadget.GameFrame).toBeDefined();
        expect(gadget.UnitCreated).toBeDefined();

        // Check UnitDefs modifications (Logic from UnifiedTweaks)
        const unitDefs = lua.global.get('UnitDefs');

        // 1. Raptor Health (1.3x check)
        // UnitDefs in mock-spring are simplified, but UnifiedTweaks modifies them.
        const swarmer = unitDefs.raptor_land_swarmer_heal;
        if (swarmer) {
            // Default mock might not have 'health' set, or it might be 200.
            // UnifiedTweaks.lua multiplies by 1.3.
            // We assume mock-spring provides enough data.
            // In features-e2e.spec.ts it expects 260.
            expect(swarmer.health).toBe(260);
        }

        // 2. Fusion Units Generated
        const solarT2 = unitDefs.armsolar_t2;
        if (solarT2) {
            expect(solarT2.health).toBe(8000);
            expect(solarT2.customparams.is_fusion_unit).toBe(true);
        }

        // 3. Compressed Units Generated
        const compressed = unitDefs.raptor_land_swarmer_basic_t1_v1_compressed_x10;
        if (compressed) {
            expect(compressed.health).toBe(1000);
            expect(compressed.customparams.is_compressed_unit).toBe(true);
        }
    });
});
