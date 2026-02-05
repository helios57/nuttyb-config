import { LuaFactory } from 'wasmoon';
import * as fs from 'fs';
import * as path from 'path';

describe('Static Tweaks Verification', () => {
    let luaFactory: LuaFactory;
    let lua: any;

    beforeEach(async () => {
        luaFactory = new LuaFactory();
        lua = await luaFactory.createEngine();

        await lua.doString(`
            _G.UnitDefs = {}
            _G.UnitDefNames = {}

            -- Polyfill table.merge (simple version)
            table.merge = function(dest, src)
                local res = {}
                for k,v in pairs(dest) do res[k] = v end
                for k,v in pairs(src) do res[k] = v end
                return res
            end

            -- Mock base units
            UnitDefs["armsolar"] = {
                health = 100, metalCost = 100, energyCost = 1000, buildTime = 100,
                mass = 100, -- Added mass
                energyMake = 10, metalMake = 0, windGenerator = 0,
                footprintX = 2, footprintZ = 2,
                name = "Solar Collector",
                customParams = { is_something = "yes" }
            }
            UnitDefs["raptor_land_swarmer_basic_t1_v1"] = {
                health = 50, metalCost = 10, energyCost = 50, buildTime = 20,
                mass = 10, energyMake = 0, metalMake = 0, windGenerator = 0,
                name = "Raptor Swarmer",
                footprintX = 1, footprintZ = 1,
                weapondefs = {
                    w1 = { damage = { default = 10 }, areaOfEffect = 8 }
                }
            }
        `);
    });

    afterEach(() => {
        lua.global.close();
    });

    test('Generates Tiered Units', async () => {
        const tweaksPath = path.join(__dirname, '../lua/StaticTweaks.lua');
        const tweaksCode = fs.readFileSync(tweaksPath, 'utf-8');
        await lua.doString(tweaksCode);

        // Check T2
        const t2 = await lua.doString(`return UnitDefs["armsolar_t2"]`);
        expect(t2).toBeDefined();
        expect(t2.health).toBe(1600); // 100 * 16
        expect(t2.name).toBe("Solar Collector T2");
        expect(t2.customparams.is_fusion_unit).toBe(true);
        expect(t2.customparams.fusion_tier).toBe(2);

        // Check T3
        const t3 = await lua.doString(`return UnitDefs["armsolar_t3"]`);
        expect(t3).toBeDefined();
        expect(t3.health).toBe(1600 * 16);
        expect(t3.name).toBe("Solar Collector T3");
        expect(t3.customparams.fusion_tier).toBe(3);
    });

    test('Generates Compressed Units', async () => {
        const tweaksPath = path.join(__dirname, '../lua/StaticTweaks.lua');
        const tweaksCode = fs.readFileSync(tweaksPath, 'utf-8');
        await lua.doString(tweaksCode);

        // Check x10 Solar
        const x10 = await lua.doString(`return UnitDefs["armsolar_compressed_x10"]`);
        expect(x10).toBeDefined();
        expect(x10.health).toBe(1000); // 100 * 10
        expect(x10.customparams.is_compressed_unit).toBe(true);
        expect(x10.customparams.compression_factor).toBe(10);
        expect(x10.name).toBe("Solar Collector x10");

        // Check x2 Raptor
        const r2 = await lua.doString(`return UnitDefs["raptor_land_swarmer_basic_t1_v1_compressed_x2"]`);
        expect(r2).toBeDefined();
        expect(r2.health).toBe(100); // 50 * 2
        expect(r2.name).toBe("raptor_land_swarmer_basic_t1_v1 x2");
    });
});
