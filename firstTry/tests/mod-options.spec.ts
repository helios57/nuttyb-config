import { test, expect } from '@playwright/test';
import { LuaFactory } from 'wasmoon';
import * as fs from 'fs';
import * as path from 'path';
import { getMockUnitDefsLua } from './mock-spring';

test.describe('MasterGadget Mod Options Verification', () => {
    let luaFactory: LuaFactory;
    let lua: any;

    test.beforeEach(async () => {
        luaFactory = new LuaFactory();
        lua = await luaFactory.createEngine();
        await lua.doString(getMockUnitDefsLua());

        // Basic Mocks
        await lua.doString(`
            gadgetHandler = { IsSyncedCode = function() return true end }
            gadget = {}
            Json = { decode = function(str) return { units = { names = {}, descriptions = {} } } end }
            VFS = { LoadFile = function(path) return "{}" end, Include = function(path) end }
            if not table.merge then
                table.merge = function(t1, t2) for k,v in pairs(t2) do t1[k] = v end return t1 end
            end
            Spring = {
                GetModOptions = function() return {} end,
                Echo = function(msg) end,
                GetGaiaTeamID = function() return 100 end,
                GetUnitDefID = function() return 1 end,
                GetUnitCount = function() return 0 end,
                GetGameSpeed = function() return 1.0, 1.0 end,
                GetFPS = function() return 60 end
            }
        `);
    });

    test.afterEach(() => {
        lua.global.close();
    });

    test('Applies Build Power Multiplier', async () => {
        // Setup Mod Options with Build Power Multiplier = 2.0
        await lua.doString(`
            Spring.GetModOptions = function() return { buildpower_mult = "2.0" } end
        `);

        const masterPath = path.join(__dirname, '../lua/MasterGadget.lua');
        if (!fs.existsSync(masterPath)) {
             test.skip('MasterGadget.lua missing', () => {});
             return;
        }
        const masterCode = fs.readFileSync(masterPath, 'utf-8');
        await lua.doString(masterCode);

        // Verify UnitDefs
        const unitDefs = lua.global.get('UnitDefs');

        // raptor_land_swarmer_heal has buildSpeed=10 in mock.
        // With mult=2.0, it should be 20.
        // But wait, StaticTweaks also modifies raptor_land_swarmer_heal:
        // def.buildSpeed = def.buildSpeed * (0.5)
        // Order matters: StaticTweaks loops and applies base tweaks, THEN applies mod options (because I added Mod Options block at the end).
        // So base: 10 * 0.5 = 5.
        // Then Mod Option: 5 * 2.0 = 10.
        // Expect 10? Or does it accumulate?

        // Let's trace StaticTweaks logic:
        // 1. "if sm(name, "^raptor_land_swarmer_heal") then ... def.buildSpeed = def.buildSpeed * (0.5) ..."
        // 2. "if Spring.GetModOptions ... if buildPowerMult ~= 1.0 ... def.buildSpeed = def.buildSpeed * buildPowerMult"

        // Yes, 10 -> 5 -> 10.

        const healer = unitDefs.raptor_land_swarmer_heal;
        expect(healer.buildSpeed).toBe(10);
    });

    test('Applies Queen Count Limit', async () => {
        await lua.doString(`
            Spring.GetModOptions = function() return { queen_max_count = "5" } end
        `);

        const masterPath = path.join(__dirname, '../lua/MasterGadget.lua');
        if (!fs.existsSync(masterPath)) {
             test.skip('MasterGadget.lua missing', () => {});
             return;
        }
        const masterCode = fs.readFileSync(masterPath, 'utf-8');
        await lua.doString(masterCode);

        const unitDefs = lua.global.get('UnitDefs');
        const queen = unitDefs.raptor_queen_v1;
        expect(queen.maxThisUnit).toBe(5);
    });
});
