import { test, expect } from '@playwright/test';
import { LuaFactory } from 'wasmoon';
import * as fs from 'fs';
import * as path from 'path';
import { getMockUnitDefsLua } from './mock-spring';

test.describe('MasterGadget Static Verification', () => {
    let luaFactory: LuaFactory;
    let lua: any;

    test.beforeEach(async () => {
        luaFactory = new LuaFactory();
        lua = await luaFactory.createEngine();

        // Setup Mock Environment
        await lua.doString(getMockUnitDefsLua());

        // Mock Spring and GadgetHandler
        await lua.doString(`
            Spring = {
                GetModOptions = function() return { meganuke = "1" } end,
                Echo = function(msg) end,
                Utilities = {
                    Gametype = {
                        IsRaptors = function() return false end
                    }
                },
                GetGaiaTeamID = function() return 100 end,
                GetUnitCount = function() return 0 end,
                GetGameSpeed = function() return 1.0, 1.0 end,
                GetFPS = function() return 60 end,
                DestroyUnit = function() end,
                CreateUnit = function() return 1 end,
                GetUnitPosition = function() return 0,0,0 end,
                GetUnitHealth = function() return 100 end,
                SetUnitHealth = function() end,
                GetUnitExperience = function() return 0 end,
                SetUnitExperience = function() end,
                GetUnitsInCylinder = function() return {} end,
                SetUnitNeutral = function() end,
                SpawnCEG = function() end,
                GetTeamUnits = function() return {} end,
                GetUnitDefID = function() return 1 end,
                GetTeamList = function() return {} end,
                ValidUnitID = function() return true end,
                SendMessage = function() end,
                GetTeamStartPosition = function() return 0,0,0 end,
                AddTeamResource = function() end,
                GetGameFrame = function() return 0 end,
                SetUnitColor = function() end
            }
            gadgetHandler = {
                IsSyncedCode = function() return true end
            }
            gadget = {}

            -- Mock Json and VFS
            Json = {
                decode = function(str) return { units = { names = {}, descriptions = {} } } end
            }
            VFS = {
                LoadFile = function(path) return "{}" end
            }

            -- Utils often used
            if not table.merge then
                table.merge = function(t1, t2)
                    for k,v in pairs(t2) do t1[k] = v end
                    return t1
                end
            end
        `);
    });

    test.afterEach(() => {
        lua.global.close();
    });

    test('Loads MasterGadget.lua and applies Static Tweaks', async () => {
        const masterPath = path.join(__dirname, '../lua/MasterGadget.lua');
        if (!fs.existsSync(masterPath)) {
            test.skip('MasterGadget.lua not found, skipping test');
            return;
        }
        const masterCode = fs.readFileSync(masterPath, 'utf-8');

        // Execute Master Gadget
        // Note: MasterGadget creates locals at top level and defines gadget functions.
        // It should run without error.
        await lua.doString(masterCode);

        // Verify UnitDefs modifications (Static Tweaks)
        const unitDefs = lua.global.get('UnitDefs');

        // 1. Raptor Health (1.3x)
        // raptor_land_swarmer_heal default hp is 200 in mock?
        // Let's check a standard unit or mock unit.
        // MockSpring defines: raptor_land_swarmer_heal with health=200.
        // Tweak: 1.3x -> 260.
        const swarmer = unitDefs.raptor_land_swarmer_heal;
        expect(swarmer.health).toBe(260);

        // 2. Fusion Units Generated
        const solarT2 = unitDefs.armsolar_t2;
        expect(solarT2).toBeDefined();
        // Base solar hp=500 (mock). T2 should be 500 * 16 = 8000.
        expect(solarT2.health).toBe(8000);
        expect(solarT2.customparams.is_fusion_unit).toBe(true);

        // 3. Compressed Units Generated
        // raptor_land_swarmer_basic_t1_v1 (mock hp=100) -> x10 -> 1000
        const compressed = unitDefs.raptor_land_swarmer_basic_t1_v1_compressed_x10;
        expect(compressed).toBeDefined();
        expect(compressed.health).toBe(1000);
        expect(compressed.customparams.is_compressed_unit).toBe(true);

        // 4. Limits (T3 Builders)
        const armconst3 = unitDefs.armconst3;
        expect(armconst3.maxThisUnit).toBe(10);
    });

    test('Initializes Gadgets (Adaptive Spawner, Fusion Core)', async () => {
        const masterPath = path.join(__dirname, '../lua/MasterGadget.lua');
        const masterCode = fs.readFileSync(masterPath, 'utf-8');
        await lua.doString(masterCode);

        // Check if gadget event handlers are defined
        // The build script registers events like gadget:GameFrame, gadget:UnitCreated
        const gadget = lua.global.get('gadget');
        expect(gadget.GameFrame).toBeDefined();
        expect(gadget.UnitCreated).toBeDefined();
        expect(gadget.UnitDestroyed).toBeDefined();
    });
});
