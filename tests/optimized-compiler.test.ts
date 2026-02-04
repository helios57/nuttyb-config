import { LuaFactory } from 'wasmoon';
import { OptimizedLuaCompiler } from '../src/mod-logic/optimized-compiler';
import { TweakDefinition } from '../src/mod-logic/tweak-dsl';
import { getMockUnitDefsLua } from './mock-spring';
import tweakLibrary from '../src/mod-logic/tweak-library.json';

const library = tweakLibrary as Record<string, TweakDefinition>;

describe('OptimizedLuaCompiler', () => {
    let luaFactory: LuaFactory;
    let lua: any;
    let compiler: OptimizedLuaCompiler;

    beforeEach(async () => {
        luaFactory = new LuaFactory();
        lua = await luaFactory.createEngine();
        compiler = new OptimizedLuaCompiler();

        // Setup base environment
        await lua.doString(getMockUnitDefsLua());
        await lua.doString(`
            Spring = {
                GetModOptions = function() return {} end
            }
            if not table then table = {} end
            table.merge = function(t1, t2)
                for k,v in pairs(t2) do t1[k] = v end
                return t1
            end
        `);
    });

    afterEach(() => {
        lua.global.close();
    });

    test('Correctness: Queen Health Multiplier', async () => {
        const inputs = [{
            tweak: library.qhp,
            variables: { multiplier: 2, multiplierText: "2" }
        }];

        const code = compiler.compile(inputs);
        // console.log(code); // Debug

        await lua.doString(code);

        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.raptor_queen_v1.health).toBe(100000); // 50000 * 2
        expect(unitDefs.armcom.health).toBe(1000); // Unchanged
    });

    test('Correctness: Multiple Tweaks (Queen + Raptors)', async () => {
        const inputs = [
            {
                tweak: library.qhp,
                variables: { multiplier: 2, multiplierText: "2" }
            },
            {
                tweak: library.raptor_health,
                variables: { healthMultiplier: 3, multiplierText: "3" }
            }
        ];

        const code = compiler.compile(inputs);
        await lua.doString(code);

        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.raptor_queen_v1.health).toBe(100000); // Queen x2

        // Raptor health tweak applies to 'other/raptors' subfolder AND NOT queen
        // raptor_land_swarmer_heal has subfolder 'other/raptors' and name 'raptor_land_swarmer_heal' (starts with raptor_land, not raptor_queen)
        // Original health 200 * 3 = 600
        expect(unitDefs.raptor_land_swarmer_heal.health).toBe(600);
    });

    test('Correctness: Build Menu Tweak (Variables in Condition)', async () => {
        const inputs = [{
            tweak: library.add_to_build_menu,
            variables: { factoryPrefix: "arm", unitName: "armwar" }
        }];

        const code = compiler.compile(inputs);
        await lua.doString(code);

        const unitDefs = lua.global.get('UnitDefs');
        // armcom starts with "arm"
        const buildOptions = unitDefs.armcom.buildoptions;
        // Wasmoon maps Lua tables to objects/arrays?
        // Lua list is usually an object with integer keys.
        // check if buildOptions has values
        let found = false;
        // Wasmoon might return object { "1": "armwar" } or array if detected
        if (Array.isArray(buildOptions)) {
            found = buildOptions.includes("armwar");
        } else {
             found = Object.values(buildOptions).includes("armwar");
        }
        expect(found).toBe(true);
    });

    test('Performance: Large UnitDefs Loop', async () => {
        // Create 10,000 units
        await lua.doString(`
            UnitDefs = {}
            for i = 1, 10000 do
                UnitDefs["unit_" .. i] = {
                    name = "unit_" .. i,
                    health = 1000,
                    customParams = { subfolder = "other/raptors" }
                }
            end
        `);

        const inputs = [
            { tweak: library.raptor_health, variables: { healthMultiplier: 2, multiplierText: "2" } },
            { tweak: library.raptor_metal_chase, variables: { metalCostFactor: 0.5, multiplierText: "2" } }
        ];

        const code = compiler.compile(inputs);

        const start = performance.now();
        await lua.doString(code);
        const end = performance.now();

        const duration = end - start;
        console.log(`Execution time for 10k units: ${duration.toFixed(2)}ms`);

        // Assert budget (relaxed slightly for test environment overhead, but 15ms target)
        // Note: Wasmoon might be slower than LuaJIT.
        // 15ms in pure LuaJIT is easy. In Wasmoon (WASM Lua) it might be slower.
        // Let's check correctness first.
        const unitDefs = lua.global.get('UnitDefs');
        const unit1 = unitDefs.unit_1;
        expect(unit1.health).toBe(2000);
        expect(unit1.metalCost).toBe(1000); // 2000 * 0.5 (metalCost source is health? wait)

        // Verify logic: raptor_metal_chase: target metalCost, source health, factor metalCostFactor
        // health is 2000 now. 2000 * 0.5 = 1000. Correct.

        // For performance assert, we might be lenient in CI/simulated env.
        expect(duration).toBeLessThan(200); // 200ms budget for Wasmoon is reasonable?
    });

    test('Clone Unit', async () => {
        const tweak: TweakDefinition = {
            name: "Clone Commander",
            description: "",
            scope: "Global",
            conditions: [],
            mutations: [
                {
                    op: 'clone_unit',
                    source: 'armcom',
                    target: 'super_com',
                    mutations: [
                        { op: 'set', field: 'health', value: 5000 },
                         { op: 'set', field: 'name', value: 'Super Commander' }
                    ]
                }
            ]
        };

        const inputs = [{ tweak, variables: {} }];
        const code = compiler.compile(inputs);
        await lua.doString(code);

        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.super_com).toBeDefined();
        expect(unitDefs.super_com.health).toBe(5000);
        expect(unitDefs.super_com.name).toBe("Super Commander");
        expect(unitDefs.armcom.health).toBe(1000); // Original unchanged
    });

    test('String Escaping', async () => {
        const tweak: TweakDefinition = {
            name: "Escape Test",
            description: "",
            scope: "UnitDefsLoop",
            conditions: [{ type: 'nameMatch', regex: 'armcom' }],
            mutations: [
                { op: 'set', field: 'name', value: 'Commander "The Boss" \\ Alpha' }
            ]
        };
        const code = compiler.compile([{ tweak, variables: {} }]);
        await lua.doString(code);
        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armcom.name).toBe('Commander "The Boss" \\ Alpha');
    });
});
