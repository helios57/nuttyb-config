import { LuaFactory } from 'wasmoon';
import { OptimizedLuaCompiler } from '../src/mod-logic/optimized-compiler';
import { TweakDefinition } from '../src/mod-logic/tweak-dsl';

describe('OptimizedLuaCompiler Robustness', () => {
    let luaFactory: LuaFactory;
    let lua: any;
    let compiler: OptimizedLuaCompiler;

    beforeEach(async () => {
        luaFactory = new LuaFactory();
        lua = await luaFactory.createEngine();
        compiler = new OptimizedLuaCompiler();

        await lua.doString(`
            Spring = { GetModOptions = function() return {} end }
            math.random = function() return 0.5 end
            UnitDefs = { armcom = { name = "armcom", health = 1000 } }
            if not table then table = {} end
            table.merge = function(t1, t2) for k,v in pairs(t2) do t1[k] = v end return t1 end
        `);
    });

    afterEach(() => {
        lua.global.close();
    });

    test('Math Parsing: Whitespace variants', async () => {
        const tweak: TweakDefinition = {
            name: "Math Whitespace", description: "", scope: "UnitDefsLoop",
            conditions: [],
            mutations: [
                {
                    op: 'set', field: 'health',
                    value: {
                        type: 'math', expression: 'max ( 100, 200 )', variables: {}
                    }
                }
            ]
        };
        const code = compiler.compile([{ tweak, variables: {} }]);
        expect(code).toContain('local math_max = math.max');
        expect(code).toContain('math_max ( 100, 200 )');

        await lua.doString(code);
        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armcom.health).toBe(200);
    });

    test('Math Parsing: Mixed usage (String and Code)', async () => {
        const tweak: TweakDefinition = {
            name: "Math String 2", description: "", scope: "UnitDefsLoop",
            conditions: [],
            mutations: [
                {
                    op: 'set', field: 'description',
                    value: {
                        type: 'math', expression: '"Max health is " .. max(10, 20)', variables: {}
                    }
                }
            ]
        };

        const code = compiler.compile([{ tweak, variables: {} }]);
        expect(code).toContain('local math_max = math.max');
        expect(code).toContain('"Max health is "');
        expect(code).toContain('math_max(10, 20)');

        await lua.doString(code);
        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armcom.description).toBe("Max health is 20");
    });

    test('Math Parsing: False positive inside string only', async () => {
        const tweak: TweakDefinition = {
            name: "Math String Only", description: "", scope: "UnitDefsLoop",
            conditions: [],
            mutations: [
                {
                    op: 'set', field: 'description',
                    value: {
                        type: 'math', expression: '"Use max(speed) setting"', variables: {}
                    }
                }
            ]
        };

        const code = compiler.compile([{ tweak, variables: {} }]);
        // Should NOT define math_max because it's not used in code
        expect(code).not.toContain('local math_max = math.max');
        expect(code).toContain('"Use max(speed) setting"');

        await lua.doString(code);
        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armcom.description).toBe("Use max(speed) setting");
    });

    test('String Escaping', async () => {
        const val = 'Line1\nLine2 "Quote" \\Backslash';
        const tweak: TweakDefinition = {
            name: "Escape", description: "", scope: "UnitDefsLoop",
            conditions: [],
            mutations: [
                { op: 'set', field: 'description', value: val }
            ]
        };

        const code = compiler.compile([{ tweak, variables: {} }]);
        await lua.doString(code);
        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armcom.description).toBe(val);
    });
});
