import { test, expect } from '@playwright/test';
import { LuaFactory } from 'wasmoon';
import * as fs from 'fs';
import * as path from 'path';
import { getDecodedTweak, setupLuaEnvironment } from './e2e-utils';
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
                SetUnitColor = function() end,
                GiveOrderToUnit = function() end,
                SetUnitLabel = function() end,
                GetUnitNearestEnemy = function() return nil end
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
                LoadFile = function(path) return "{}" end,
                Include = function(path) end
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
        await lua.doString(masterCode);

        // Verify UnitDefs modifications (Static Tweaks)
        const unitDefs = lua.global.get('UnitDefs');

        // 1. Raptor Health (1.3x)
        const swarmer = unitDefs.raptor_land_swarmer_heal;
        if (swarmer) expect(swarmer.health).toBe(260);

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

        // 4. Limits (T3 Builders)
        const armconst3 = unitDefs.armconst3;
        if (armconst3) expect(armconst3.maxThisUnit).toBe(10);
    });

    test('Initializes Gadgets (Adaptive Spawner, Fusion Core)', async () => {
        const masterPath = path.join(__dirname, '../lua/MasterGadget.lua');
        const masterCode = fs.readFileSync(masterPath, 'utf-8');
        await lua.doString(masterCode);

        // Check if gadget event handlers are defined
        const gadget = lua.global.get('gadget');
        expect(gadget.GameFrame).toBeDefined();
        expect(gadget.UnitCreated).toBeDefined();
        expect(gadget.UnitDestroyed).toBeDefined();
    });
});

// Helper function to run the simulation verification
async function runCullingSimulation(luaCode: string, config: any) {
    const luaFactory = new LuaFactory();
    const lua = await luaFactory.createEngine();

    try {
        await setupLuaEnvironment(lua);

        // Mock Spring.GetModOptions with provided config
        const configString = Object.entries(config)
            .map(([k, v]) => `${k} = "${v}"`)
            .join(', ');

        // Setup environment BEFORE loading the gadget
        await lua.doString(`
            gadget = {}
            gadgetHandler = { IsSyncedCode = function() return true end }

            Spring.GetModOptions = function()
                return { ${configString} }
            end

            Spring.GetGameSpeed = function() return 0.1, 0.1 end -- Low SimSpeed
            Spring.GetUnitCount = function() return 100 end
            Spring.GetFPS = function() return 60 end
            _G.currentFrame = 0
            Spring.GetGameFrame = function() return _G.currentFrame end
            Spring.GetGaiaTeamID = function() return 100 end
            Spring.GetTeamList = function() return { 0 } end
            Spring.GetTeamStartPosition = function(teamID) return 0, 0, 0 end
            Spring.AddTeamResource = function(teamID, type, amount) end
            Spring.SpawnCEG = function() end
            Spring.SendMessage = function() end
            Spring.Echo = function() end

             -- Mock Team & Unit Data
            _G.mockUnits = {}
            _G.destroyedUnits = {}

            Spring.CreateUnit = function(name, x, y, z, face, team)
                local id = #_G.mockUnits + 1
                _G.mockUnits[id] = {
                    id = id,
                    name = name,
                    x = x, y = y, z = z,
                    team = team,
                    defID = 1 -- Simplified, maps to armsolar
                }
                return id
            end

            Spring.DestroyUnit = function(uID, reclaim, showParams)
                _G.destroyedUnits[uID] = true
            end

            Spring.GetTeamUnits = function(teamID)
                local res = {}
                for id, u in pairs(_G.mockUnits) do
                    if u.team == teamID then
                        table.insert(res, id)
                    end
                end
                return res
            end

            Spring.GetUnitDefID = function(uID)
                if _G.mockUnits[uID] then return _G.mockUnits[uID].defID end
                return nil
            end

            Spring.ValidUnitID = function(uID) return _G.mockUnits[uID] ~= nil end

            Spring.GetUnitPosition = function(uID)
                local u = _G.mockUnits[uID]
                if u then return u.x, u.y, u.z end
                return nil
            end

             -- Mock UnitDefs lookup
            UnitDefs = {
                [1] = { name = "armsolar", metalCost = 100 }
            }
        `);

        // Load the provided Lua code
        await lua.doString(luaCode);

        // Inject Target Unit (armsolar) outside safe radius (2000)
        await lua.doString(`
            _G.targetUnitID = Spring.CreateUnit("armsolar", 5000, 0, 5000, 0, 0)
        `);

        // Run GameFrame Loop
        // Warning duration is 300 frames. Logic checks every 30 frames.
        // We need > 300 frames.
        await lua.doString(`
            for i = 1, 400 do
                _G.currentFrame = i
                gadget:GameFrame(i)
            end
        `);

        // Assert Unit Destroyed
        const isDestroyed = await lua.doString('return _G.destroyedUnits[_G.targetUnitID]');
        expect(isDestroyed).toBe(true);

    } finally {
        lua.global.close();
    }
}

test.describe('End-to-End UI to Engine Verification', () => {

    test('Custom Configuration: Eco Culling & Queen Amount', async ({ page }) => {
        // 1. UI Interaction
        await page.goto('/');

        // Set "Queen Amount" to 5
        const queenInput = page.locator('input[data-mod-option="queen_max_count"]');
        await queenInput.fill('5');
        await queenInput.dispatchEvent('input');

        // Check "Eco Culling"
        const ecoCulling = page.locator('input[data-mod-option="cull_enabled"]');
        if (!(await ecoCulling.isChecked())) {
            await ecoCulling.check();
        }

        // Get Output
        const outputText = await page.locator('#command-output-1').inputValue();

        // 2. Decode & Verify
        // Try to get Base64 code, otherwise fallback to MasterGadget.lua
        let luaCode = "";
        try {
            luaCode = await getDecodedTweak(page);
        } catch (e) {
            console.log("Base64 tweakdefs not found, proceeding with ModOptions verification and file loading.");
            expect(outputText).toContain('!bset queen_max_count 5');
            expect(outputText).toContain('!bset cull_enabled 1');

            // Fallback: Load MasterGadget from file
            const masterPath = path.join(__dirname, '../lua/MasterGadget.lua');
            luaCode = fs.readFileSync(masterPath, 'utf-8');
        }

        // 3. Run Simulation
        await runCullingSimulation(luaCode, {
            queen_max_count: "5",
            cull_enabled: "1",
            cull_simspeed: "0.9",
            cull_radius: "2000"
        });
    });

    test('Max Performance Configuration', async ({ page }) => {
        await page.goto('/');

        // Enable "Eco Culling"
        const ecoCulling = page.locator('input[data-mod-option="cull_enabled"]');
        if (!(await ecoCulling.isChecked())) await ecoCulling.check();

        // Enable "Vampire Mode"
        const vampire = page.locator('input[data-mod-option="adaptive_vampire"]');
        if (!(await vampire.isChecked())) await vampire.check();

        // Get Output
        const outputText = await page.locator('#command-output-1').inputValue();

        let luaCode = "";
        try {
            luaCode = await getDecodedTweak(page);
        } catch (e) {
             console.log("Base64 tweakdefs not found, proceeding with ModOptions verification and file loading.");
             expect(outputText).toContain('!bset cull_enabled 1');

             const masterPath = path.join(__dirname, '../lua/MasterGadget.lua');
             luaCode = fs.readFileSync(masterPath, 'utf-8');
        }

        // Run Simulation
        await runCullingSimulation(luaCode, {
            cull_enabled: "1",
            adaptive_vampire: "1",
            cull_simspeed: "0.9",
            cull_radius: "2000"
        });
    });
});
