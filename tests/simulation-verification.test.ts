import { LuaFactory } from 'wasmoon';
import * as fs from 'fs';
import * as path from 'path';

describe('Simulation Verification', () => {
    let luaFactory: LuaFactory;
    let lua: any;

    beforeEach(async () => {
        luaFactory = new LuaFactory();
        lua = await luaFactory.createEngine();

        // Global Event Log
        lua.global.set('logEvent', (event: string) => {
             // console.log('Lua Event:', event);
        });

        // Setup Spring Mock
        await lua.doString(`
            events = {}
            function log(msg) logEvent(msg) table.insert(events, msg) end

            _G.mockSimSpeed = 1.0
            _G.mockFPS = 60
            _G.mockUnitsInCylinder = {}
            _G.mockUnitPositions = {}

            Spring = {
                GetModOptions = function() return { adaptive_spawner = "1", fusion_mode = "1" } end,
                GetGaiaTeamID = function() return 100 end,
                GetUnitCount = function() return 100 end,
                GetGameSpeed = function() return 1.0, _G.mockSimSpeed end,
                GetFPS = function() return _G.mockFPS end,
                DestroyUnit = function(uID) log("DestroyUnit:" .. uID) end,
                CreateUnit = function(defID) log("CreateUnit:" .. defID) return 9999 end,
                GetUnitPosition = function(uID)
                    if _G.mockUnitPositions[uID] then
                        return _G.mockUnitPositions[uID][1], 0, _G.mockUnitPositions[uID][2]
                    end
                    return 0,0,0
                end,
                GetUnitDefID = function(uID) return 10 end, -- Default to 10 for Fusion test
                SetUnitNeutral = function() end,
                GetUnitHealth = function() return 100 end,
                SetUnitHealth = function() end,
                GetUnitExperience = function() return 0 end,
                SetUnitExperience = function() end,
                GetUnitsInCylinder = function() return _G.mockUnitsInCylinder end,
                GetGameFrame = function() return 100 end,
                GetTeamUnits = function() return {} end,
                GetTeamList = function() return {100} end,
                ValidUnitID = function() return true end,
                SpawnCEG = function() end,
                AddTeamResource = function() end
            }
            gadgetHandler = { IsSyncedCode = function() return true end }
            gadget = {}
            UnitDefs = {}
            UnitDefNames = {}

            -- Helper to mock unit
            function MockUnit(id, name, cp)
                UnitDefs[id] = { id = id, name = name, customParams = cp, footprintX=2, footprintZ=2 }
                UnitDefNames[name] = UnitDefs[id]
            end
        `);
    });

    afterEach(() => {
        lua.global.close();
    });

    test('Adaptive Spawner triggers compression at low SimSpeed', async () => {
        // Load Gadget
        const gadgetPath = path.join(__dirname, '../lua/gadget_adaptive_spawner.lua');
        const gadgetCode = fs.readFileSync(gadgetPath, 'utf-8');
        await lua.doString(gadgetCode);

        // Setup Units
        await lua.doString(`
            MockUnit(1, "raptor_land_test", {})
            MockUnit(2, "raptor_land_test_compressed_x10", { is_compressed_unit = true })
        `);

        // Force Low SimSpeed
        await lua.doString(`
            _G.mockSimSpeed = 0.7
            _G.mockFPS = 15
            gadget:GameFrame(30) -- Trigger update
        `);

        // Create 10 units
        for(let i=1; i<=10; i++) {
            await lua.doString(`gadget:UnitCreated(${i}, 1, 100)`);
        }

        const result = await lua.doString(`
            local creates = 0
            local destroys = 0
            for _, e in pairs(events) do
                if string.find(e, "CreateUnit:2") then creates = creates + 1 end
                if string.find(e, "DestroyUnit") then destroys = destroys + 1 end
            end
            return creates .. ":" .. destroys
        `);

        expect(result).toBe("1:10");
    });

    test('Fusion Core merges 4 units', async () => {
        // Load Gadget
        const gadgetPath = path.join(__dirname, '../lua/gadget_fusion_core.lua');
        const gadgetCode = fs.readFileSync(gadgetPath, 'utf-8');
        await lua.doString(gadgetCode);

        // Setup Units
        await lua.doString(`
            MockUnit(10, "armsolar", {})
            MockUnit(20, "armsolar_t2", { is_fusion_unit = true })
            gadget:Initialize()
        `);

        // Setup Grid
        // Units at (0,0), (32,0), (0,32), (32,32). footprintX=2 -> 32 elmos.
        await lua.doString(`
            local u1, u2, u3, u4 = 101, 102, 103, 104
            _G.mockUnitPositions = {
                [101] = {0, 0},
                [102] = {32, 0},
                [103] = {0, 32},
                [104] = {32, 32}
            }
            _G.mockUnitsInCylinder = {101, 102, 103, 104}
        `);

        // Trigger Finish on Top-Left unit
        await lua.doString(`gadget:UnitFinished(101, 10, 100)`);

        const result = await lua.doString(`
            local creates = 0
            local destroys = 0
            for _, e in pairs(events) do
                if string.find(e, "CreateUnit:20") then creates = creates + 1 end
                if string.find(e, "DestroyUnit") then destroys = destroys + 1 end
            end
            return creates .. ":" .. destroys
        `);

        expect(result).toBe("1:4");
    });
});
