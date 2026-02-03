import { LuaFactory } from 'wasmoon';
import { compileTweak } from '../src/mod-logic/lua-compiler';
import { getQhpTweak, getHpTweak, getScavHpTweak } from '../src/mod-logic/tweak-definitions';
import { RaptorTweakConfig } from '../src/mod-logic/presets';

// Mock luamin global for the test environment as lua-compiler might look for it
(global as any).luamin = {
    minify: (code: string) => code
};

describe('Lua Execution Tests', () => {
    let luaFactory: LuaFactory;

    beforeAll(async () => {
        luaFactory = new LuaFactory();
    });

    test('should execute QHP tweak correctly', async () => {
        const lua = await luaFactory.createEngine();

        await lua.doString(`
            UnitDefs = {
                raptor_queen_1 = {
                    name = 'raptor_queen_1',
                    health = 1000,
                    repairable = true,
                    canbehealed = true,
                    buildTime = 100,
                    autoHeal = 0,
                    canSelfRepair = true
                },
                arm_peewee = {
                    name = 'arm_peewee',
                    health = 500,
                    repairable = true
                }
            }
            Spring = {
                GetModOptions = function() return {} end
            }
        `);

        // Generate Lua Code
        const tweak = getQhpTweak(2.5, "2.5");
        const code = compileTweak(tweak);

        // Execute
        await lua.doString(code);

        // Verify
        const queen = await lua.doString(`return UnitDefs.raptor_queen_1`);
        const peewee = await lua.doString(`return UnitDefs.arm_peewee`);

        expect(queen.health).toBe(2500); // 1000 * 2.5
        expect(queen.repairable).toBe(false);
        expect(queen.canbehealed).toBe(false);
        expect(queen.buildTime).toBe(9999999);
        expect(queen.autoHeal).toBe(2);
        expect(queen.canSelfRepair).toBe(false);

        // Peewee should be untouched
        expect(peewee.health).toBe(500);
        expect(peewee.repairable).toBe(true);
    });

    test('should execute HP tweak correctly', async () => {
        const lua = await luaFactory.createEngine();

        await lua.doString(`
            UnitDefs = {
                raptor_land_swarmer_heal = {
                    name = 'raptor_land_swarmer_heal',
                    reclaimSpeed = 10,
                    stealth = true,
                    builder = true,
                    buildSpeed = 100,
                    canAssist = true,
                    maxThisUnit = 10
                },
                raptor_other = {
                    name = 'raptor_other',
                    customParams = { subfolder = 'other/raptors' },
                    health = 1000,
                    metalCost = 100
                },
                raptor_queen_ignored = {
                    name = 'raptor_queen_ignored',
                    customParams = { subfolder = 'other/raptors' },
                    health = 5000
                }
            }
            Spring = {
                GetModOptions = function() return {} end
            }
        `);

        const config: RaptorTweakConfig = {
            healthMultiplier: 2,
            workertimeMultiplier: 0.5,
            metalCostFactor: 0.35,
            multiplierText: "2"
        };
        const tweaks = getHpTweak(config);
        const code = compileTweak(tweaks);

        await lua.doString(code);

        const swarmer = await lua.doString(`return UnitDefs.raptor_land_swarmer_heal`);
        expect(swarmer.reclaimSpeed).toBe(100);
        expect(swarmer.stealth).toBe(false);
        expect(swarmer.builder).toBe(false);
        expect(swarmer.buildSpeed).toBe(50); // 100 * 0.5
        expect(swarmer.canAssist).toBe(false);
        expect(swarmer.maxThisUnit).toBe(0);

        const other = await lua.doString(`return UnitDefs.raptor_other`);
        expect(other.health).toBe(2000); // 1000 * 2
        // math.floor(2000 * 0.35) = 700
        expect(other.metalCost).toBe(700);
        expect(other.noChaseCategory).toBe('OBJECT');

        const queen = await lua.doString(`return UnitDefs.raptor_queen_ignored`);
        // Queen excluded by regex '^raptor_queen_.*'
        expect(queen.health).toBe(5000);
    });

    test('should execute Scavenger HP tweak correctly', async () => {
        const lua = await luaFactory.createEngine();

        await lua.doString(`
            UnitDefs = {
                some_scav = {
                    name = 'some_scav',
                    health = 100,
                    metalCost = 50
                },
                scavengerbossv4 = {
                    name = 'scavengerbossv4',
                    health = 10000
                },
                normal_unit = {
                    name = 'normal_unit',
                    health = 100
                }
            }
            Spring = {
                GetModOptions = function() return {} end
            }
        `);

        const tweaks = getScavHpTweak(2, "2");
        const code = compileTweak(tweaks);

        await lua.doString(code);

        // The code defines UnitDef_Post (or wraps it).
        // We need to call it manually for each unit to simulate engine behavior
        await lua.doString(`
            if UnitDef_Post then
                UnitDef_Post(UnitDefs.some_scav.name, UnitDefs.some_scav)
                UnitDef_Post(UnitDefs.scavengerbossv4.name, UnitDefs.scavengerbossv4)
                UnitDef_Post(UnitDefs.normal_unit.name, UnitDefs.normal_unit)
            end
        `);

        const scav = await lua.doString(`return UnitDefs.some_scav`);
        expect(scav.health).toBe(200); // 100 * 2
        expect(scav.metalCost).toBe(100); // 50 * 2
        expect(scav.noChaseCategory).toBe('OBJECT');

        const boss = await lua.doString(`return UnitDefs.scavengerbossv4`);
        expect(boss.health).toBe(10000); // Excluded by regex

        const normal = await lua.doString(`return UnitDefs.normal_unit`);
        expect(normal.health).toBe(100);
    });
});
