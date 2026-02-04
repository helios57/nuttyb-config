import { LuaFactory } from 'wasmoon';
import * as fs from 'fs';
import * as path from 'path';

describe('Performance Stress Test: Raptor AI', () => {
    let luaFactory: LuaFactory;
    let lua: any;

    beforeEach(async () => {
        luaFactory = new LuaFactory();
        lua = await luaFactory.createEngine();

        // Setup Call Counters
        lua.global.set('trackOrder', (cmd: number) => {
             // Will be accessed via global in Lua
        });

        // Mock Spring and Globals
        await lua.doString(`
            pathingCalls = 0
            cheapCalls = 0

            function trackOrder(cmd)
                 if cmd == 10 or cmd == 20 then
                     pathingCalls = pathingCalls + 1
                 elseif cmd == 30 then
                     cheapCalls = cheapCalls + 1
                 end
            end

            Spring = {
                GetGaiaTeamID = function() return 100 end,
                GetUnitPosition = function(uID) return uID * 10, 0, uID * 10 end,
                GetUnitDefID = function(uID) return 1 end,
                GiveOrderToUnit = function(uID, cmd, params, opts)
                    trackOrder(cmd)
                end,
                GetGameFrame = function() return 0 end,
                GetUnitsInCylinder = function() return {} end,
                GetTeamUnits = function(teamID) return {} end,
                GetTeamList = function() return {100, 0} end,
                ValidUnitID = function(uID) return true end,
                GetModOptions = function() return {} end
            }
            CMD = { ATTACK = 10, FIGHT = 20, MOVE = 30 }
            Game = { mapSizeX = 10000, mapSizeZ = 10000 }
            gadgetHandler = {
                IsSyncedCode = function() return true end
            }
            gadget = {}
            math.random = function(min, max) return min end
        `);
    });

    afterEach(() => {
        lua.global.close();
    });

    test('Squad Logic reduces expensive pathing calls', async () => {
        // Load Gadget
        const gadgetPath = path.join(__dirname, '../lua/gadget_raptor_ai_optimized.lua');
        const gadgetCode = fs.readFileSync(gadgetPath, 'utf-8');
        await lua.doString(gadgetCode);

        // Spawn 100 Units
        for(let i=1; i<=100; i++) {
            await lua.doString(`gadget:UnitCreated(${i}, 1, 100)`);
        }

        // Run GameFrame for 30 frames
        for(let f=0; f<30; f++) {
             await lua.doString(`gadget:GameFrame(${f})`);
        }

        // Get counters from Lua
        const pathingCalls = await lua.global.get('pathingCalls');
        const cheapCalls = await lua.global.get('cheapCalls');

        console.log(`Pathing Calls (Leader): ${pathingCalls}`);
        console.log(`Cheap Calls (Follower): ${cheapCalls}`);

        expect(pathingCalls).toBe(5);
        expect(cheapCalls).toBe(95);
    });
});
