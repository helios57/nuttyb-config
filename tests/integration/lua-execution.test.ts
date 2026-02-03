import { LuaFactory } from 'wasmoon';
import * as fs from 'fs';
import * as path from 'path';

const TWEAK_DATA_PATH = path.join(__dirname, '../../dist/tweakdata.lua');

describe('Lua Execution Integration', () => {
    let lua: any;
    let factory: LuaFactory;

    beforeAll(async () => {
        factory = new LuaFactory();
        lua = await factory.createEngine();
    });

    afterAll(() => {
        if (lua) lua.global.close();
    });

    test('Should execute tweakdata.lua without errors', async () => {
        // Setup Environment
        await lua.doString(`
            UnitDefs = {}

            UnitDefs["raptor_queen_test"] = {
                name = "raptor_queen_test",
                repairable = true,
                canbehealed = true,
                buildTime = 100,
                autoHeal = 0,
                canSelfRepair = true,
                health = 1000
            }

            UnitDefs["raptor_land_swarmer_heal"] = {
                name = "raptor_land_swarmer_heal",
                reclaimSpeed = 10,
                stealth = true,
                builder = true,
                buildSpeed = 100,
                canAssist = true,
                maxThisUnit = 10
            }

            UnitDefs["raptor_land_swarmer_basic_t1_v1"] = {
                name = "raptor_land_swarmer_basic_t1_v1",
                health = 100
            }

            UnitDefs["armcom"] = {
                name = "armcom",
                customparams = {
                    existing_param = 1
                },
                featuredefs = {}
            }

            UnitDefs["armannit3"] = {
                name = "armannit3",
                health = 1000,
                weapondefs = {
                    tachyon_burst_cannon = {
                        name = "Old Cannon",
                        damage = { default = 100 }
                    }
                }
            }

            UnitDefs["arm_taxed_test"] = {
                name = "arm_taxed_test",
                customparams = {
                    techlevel = 2,
                    subfolder = "labs/arm_Lab",
                    i18n_en_humanname = "Armada Lab"
                },
                metalCost = 100,
                energyCost = 1000
            }

            Spring = {
                GetModOptions = function()
                    return {
                        raptor_spawncountmult = 3
                    }
                end
            }

            table.merge = function(dest, src)
                for k, v in pairs(src) do
                    if type(v) == "table" and type(dest[k]) == "table" then
                        table.merge(dest[k], v)
                    else
                        dest[k] = v
                    end
                end
                return dest
            end
        `);

        // Execute generated code
        const code = fs.readFileSync(TWEAK_DATA_PATH, 'utf-8');
        await lua.doString(code);

        // Assertions
        const qHealth = await lua.doString('return UnitDefs["raptor_queen_test"].health');
        expect(qHealth).toBe(2000); // 1000 * 2.0 (multiplier)

        const qRepairable = await lua.doString('return UnitDefs["raptor_queen_test"].repairable');
        expect(qRepairable).toBe(false);

        const swarmerReclaim = await lua.doString('return UnitDefs["raptor_land_swarmer_heal"].reclaimSpeed');
        expect(swarmerReclaim).toBe(100);

        const hiveSpawnName = await lua.doString('return UnitDefs["raptor_hive_swarmer_basic"] and UnitDefs["raptor_hive_swarmer_basic"].name');
        expect(hiveSpawnName).toBe("Hive Spawn");

        const armComCombatRadius = await lua.doString('return UnitDefs["armcom"].customparams.combatradius');
        expect(armComCombatRadius).toBe(0);

        const armComExisting = await lua.doString('return UnitDefs["armcom"].customparams.existing_param');
        expect(armComExisting).toBe(1);

        const pulsarHealth = await lua.doString('return UnitDefs["legendary_pulsar"].health');
        expect(pulsarHealth).toBe(30000);

        const weaponRange = await lua.doString('return UnitDefs["legendary_pulsar"].weapondefs["tachyon_burst_cannon"].range');
        expect(weaponRange).toBe(1800);

        // Verify Taxed Unit (String concat and recursive resolution)
        const taxedName = await lua.doString('return UnitDefs["arm_taxed_test_taxed"] and UnitDefs["arm_taxed_test_taxed"].name');
        expect(taxedName).toBe("arm_taxed_test (Taxed)");

        const taxedHumanName = await lua.doString('return UnitDefs["arm_taxed_test_taxed"].customparams.i18n_en_humanname');
        expect(taxedHumanName).toBe("Armada Lab (Taxed)");

        // Verify it didn't tax the taxed unit again
        const doubleTaxedName = await lua.doString('return UnitDefs["arm_taxed_test_taxed_taxed"]');
        expect(doubleTaxedName).toBe(null);
    });

    test('Performance Benchmark', async () => {
        // Setup 5000 units
        await lua.doString(`
            UnitDefs = {}
            for i = 1, 5000 do
                UnitDefs["unit_" .. i] = {
                    name = "Unit " .. i,
                    health = 1000,
                    customparams = {}
                }
            end

            -- Add some targets that match filters
            UnitDefs["raptor_queen_bench"] = { name = "raptor_queen_bench", health = 1000 }
        `);

        const code = fs.readFileSync(TWEAK_DATA_PATH, 'utf-8');

        const start = performance.now();
        await lua.doString(code);
        const end = performance.now();

        const duration = end - start;
        console.log(`Execution time for 5000 units: ${duration.toFixed(2)}ms`);
        // 200ms is a safe upper bound for local execution
        expect(duration).toBeLessThan(500);
    });
});
