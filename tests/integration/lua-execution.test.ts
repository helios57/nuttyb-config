import { LuaFactory } from 'wasmoon';
import { OptimizedLuaCompiler } from '../../src/mod-logic/optimized-compiler';
import * as fs from 'fs';
import * as path from 'path';
import { TweakDefinition } from '../../src/mod-logic/tweak-dsl';

const VARIABLES = {
    multiplier: 2.0,
    healthMultiplier: 1.5,
    workertimeMultiplier: 1.2,
    metalCostFactor: 0.9,
    factoryPrefix: "arm",
    unitName: "armwar"
};

describe('Lua Execution Integration', () => {
    let lua: any;
    let factory: LuaFactory;
    let compiledCode: string;

    beforeAll(async () => {
        factory = new LuaFactory();

        // Load config dynamically
        const configPath = path.resolve(__dirname, '../../master_config_normalized.json');
        const configContent = fs.readFileSync(configPath, 'utf-8');
        let config = JSON.parse(configContent) as TweakDefinition[];

        // Deduplicate by name (safety guard)
        const seen = new Set();
        config = config.filter(c => {
            if (seen.has(c.name)) return false;
            seen.add(c.name);
            return true;
        });

        // Compile logic once
        const compiler = new OptimizedLuaCompiler();
        const inputs = config.map(tweak => ({
            tweak,
            variables: VARIABLES
        }));
        compiledCode = compiler.compile(inputs);
    });

    beforeEach(async () => {
        lua = await factory.createEngine();
        // Common Lua Setup
        await lua.doString(`
            UnitDefs = {}
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
    });

    afterEach(() => {
        if (lua) lua.global.close();
    });

    test('Should execute compiled tweaks without errors', async () => {
        // Setup Test Units
        await lua.doString(`
            UnitDefs["alpha_unit"] = {
                name = "alpha_unit",
                repairable = true,
                canbehealed = true,
                buildTime = 100,
                autoHeal = 0,
                canSelfRepair = true,
                health = 1000
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
        `);

        // Execute generated code
        try {
            await lua.doString(compiledCode);
        } catch (e) {
            console.error("Lua execution error:", e);
            console.log("Compiled Code:", compiledCode);
            throw e;
        }

        // Assertions
        const qHealth = await lua.doString('return UnitDefs["alpha_unit"].health');
        expect(qHealth).toBe(2000); // 1000 * 2.0 (multiplier)

        const qRepairable = await lua.doString('return UnitDefs["alpha_unit"].repairable');
        expect(qRepairable).toBe(false);

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
            for i = 1, 5000 do
                UnitDefs["unit_" .. i] = {
                    name = "Unit " .. i,
                    health = 1000,
                    customparams = {}
                }
            end

            -- Add some targets that match filters
            UnitDefs["alpha_unit_bench"] = { name = "alpha_unit_bench", health = 1000 }
        `);

        const start = performance.now();
        await lua.doString(compiledCode);
        const end = performance.now();

        const duration = end - start;
        console.log(`Execution time for 5000 units: ${duration.toFixed(2)}ms`);
        // 200ms is a safe upper bound for local execution
        expect(duration).toBeLessThan(500);
    });
});
