import { LuaFactory } from 'wasmoon';
import * as fs from 'fs';
import * as path from 'path';
import { getMockUnitDefsLua } from './mock-spring';

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

        // Load UnitDefs
        await lua.doString(getMockUnitDefsLua());

        // Setup Spring Mock
        await lua.doString(`
            events = {}
            function log(msg) logEvent(msg) table.insert(events, msg) end

            _G.mockSimSpeed = 1.0
            _G.mockFPS = 60
            _G.mockUnitsInCylinder = {}
            _G.mockUnitPositions = {}
            _G.mockUnitTeams = {}
            _G.mockModOptions = { adaptive_spawner = "1", fusion_mode = "1" }

            Spring = {
                GetModOptions = function() return _G.mockModOptions end,
                GetGaiaTeamID = function() return 100 end,
                GetUnitCount = function() return 100 end,
                GetGameSpeed = function() return 1.0, _G.mockSimSpeed end,
                GetFPS = function() return _G.mockFPS end,
                DestroyUnit = function(uID) log("DestroyUnit:" .. uID) end,
                CreateUnit = function(defID) log("CreateUnit:" .. defID) return 9999 end,
                GetUnitTeam = function(uID) return _G.mockUnitTeams[uID] or 100 end,
                GetUnitPosition = function(uID)
                    if _G.mockUnitPositions[uID] then
                        return _G.mockUnitPositions[uID][1], 0, _G.mockUnitPositions[uID][2]
                    end
                    return 0,0,0
                end,
                GetUnitDefID = function(uID) return 10 end,
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
                AddTeamResource = function() return true end,
                SendMessage = function() end,
                GetTeamStartPosition = function() return 0,0,0 end,
                GiveOrderToUnit = function() end,
                SetUnitLabel = function() end,
                GetUnitNearestEnemy = function() return nil end,
                SetUnitColor = function() end
            }
            gadgetHandler = {
                IsSyncedCode = function() return true end,
                RegisterGadget = function() end
            }
            gadget = {}

            -- Mock Helper
            function MockUnit(id, name, cp, props)
                local defId = id
                local def = { id = defId, name = name, customParams = cp, footprintX=2, footprintZ=2 }
                if props then
                    for k,v in pairs(props) do def[k] = v end
                end
                UnitDefs[defId] = def
                UnitDefNames[name] = UnitDefs[defId]
            end

            UnitDefNames = {}
            for k,v in pairs(UnitDefs) do
                UnitDefNames[v.name] = v
            end
        `);
    });

    afterEach(() => {
        lua.global.close();
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

        // Advance GameFrame to process queue (101 % 30 = 11)
        await lua.doString(`gadget:GameFrame(11)`);

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

    test('Adaptive Spawning triggers compression at low SimSpeed', async () => {
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

        // Expectation:
        // Input: 10 creation attempts of ID 1.
        // Logic:
        // 1. SimSpeed low -> Activate Compression.
        // 2. UnitCreated(1) -> Spawner intercepts.
        // 3. Spawner accumulates count. When count >= 10, it creates ONE compressed unit (ID 2).
        // 4. It DESTROYS the original units (10 of them) immediately/soon.

        // Wait, normally Adaptive Spawner works by intercepting creation or handling spawns.
        // If it's `UnitCreated` event, the unit already exists.
        // So the gadget destroys the unit and increments a counter.
        // When counter hits 10, it creates the compressed unit.
        // So 10 destroys, 1 create.

        expect(result).toBe("1:10");
    });

    test('Tweak Application applies global modifiers', async () => {
        // Setup Mod Options
        await lua.doString(`
            _G.mockModOptions = {
                buildpower_mult = "4.0",
                queen_max_count = "10"
            }
        `);

        // Load MasterGadget (which includes UnifiedTweaks)
        const gadgetPath = path.join(__dirname, '../lua/MasterGadget.lua');
        const gadgetCode = fs.readFileSync(gadgetPath, 'utf-8');
        await lua.doString(gadgetCode);

        // Verification Script
        const result = await lua.doString(`
            local results = {}

            -- 1. Check maxThisUnit override
            results.constLimit = UnitDefs['armconst3'].maxThisUnit

            -- 2. Check buildoptions injection
            local hasMeatball = false
            if UnitDefs['armavp'] and UnitDefs['armavp'].buildoptions then
                for _, opt in pairs(UnitDefs['armavp'].buildoptions) do
                    if opt == "armmeatball" then hasMeatball = true break end
                end
            end
            results.hasMeatball = hasMeatball

            -- 3. Check health modifier (raptor_land_swarmer_heal: 200 -> 260)
            results.healHealth = UnitDefs['raptor_land_swarmer_heal'].health

            -- 4. Check buildpower_mult (raptor_land_swarmer_heal buildSpeed)
            -- Base: 10. Tweak: *0.5 -> 5. ModOption: *4.0 -> 20.
            results.healBuildSpeed = UnitDefs['raptor_land_swarmer_heal'].buildSpeed

            return results
        `);

        // Assertions
        expect(result.constLimit).toBe(10);
        expect(result.hasMeatball).toBe(true);
        expect(result.healHealth).toBe(260);
        expect(result.healBuildSpeed).toBe(20);
    });
});
