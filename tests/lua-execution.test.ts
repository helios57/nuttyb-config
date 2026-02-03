import { LuaFactory } from 'wasmoon';
import { compileTweak } from '../src/mod-logic/lua-compiler';
import { TweakDefinition } from '../src/mod-logic/tweak-dsl';

describe('Lua Execution Tests', () => {
    let luaFactory: LuaFactory;
    let lua: any;

    beforeEach(async () => {
        luaFactory = new LuaFactory();
        lua = await luaFactory.createEngine();
    });

    afterEach(() => {
        lua.global.close();
    });

    test('UnitDefsLoop: Multiply Health', async () => {
        // Setup environment
        await lua.doString(`
            UnitDefs = {
                armcom = { name = "armcom", health = 1000, customParams = {} },
                corcom = { name = "corcom", health = 1000, customParams = {} }
            }
            Spring = {
                GetModOptions = function() return {} end
            }
            table.merge = function(t1, t2)
                for k,v in pairs(t2) do t1[k] = v end
                return t1
            end
        `);

        const tweak: TweakDefinition = {
            name: "Double Health",
            description: "Doubles health of all units",
            scope: "UnitDefsLoop",
            conditions: [], // Apply to all
            mutations: [
                { op: 'multiply', field: 'health', factor: 2 }
            ]
        };

        const code = compileTweak(tweak);
        await lua.doString(code);

        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armcom.health).toBe(2000);
        expect(unitDefs.corcom.health).toBe(2000);
    });

    test('UnitDefsLoop: Conditional Tweak', async () => {
        await lua.doString(`
            UnitDefs = {
                armcom = { name = "armcom", health = 1000 },
                armzeus = { name = "armzeus", health = 500 }
            }
        `);

        const tweak: TweakDefinition = {
            name: "Buff Commander",
            description: "Buffs commander health",
            scope: "UnitDefsLoop",
            conditions: [{ type: 'nameMatch', regex: 'com$' }],
            mutations: [
                { op: 'set', field: 'health', value: 9999 }
            ]
        };

        const code = compileTweak(tweak);
        await lua.doString(code);

        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.armcom.health).toBe(9999);
        expect(unitDefs.armzeus.health).toBe(500); // Should be unchanged
    });

    test('UnitDefsLoop: List Append', async () => {
         await lua.doString(`
            UnitDefs = {
                armcom = { name = "armcom", buildoptions = {} }
            }
            -- polyfill table.insert if needed, but wasmoon has it
        `);

        const tweak: TweakDefinition = {
            name: "Add Build Option",
            description: "",
            scope: "UnitDefsLoop",
            conditions: [],
            mutations: [
                { op: 'list_append', field: 'buildoptions', value: 'armwar' }
            ]
        };

        const code = compileTweak(tweak);
        await lua.doString(code);

        // Access via Lua to verify list content easily
        const result = await lua.doString(`return UnitDefs.armcom.buildoptions[1]`);
        expect(result).toBe('armwar');
    });

    test('UnitDef_Post: Modify field after definition', async () => {
         await lua.doString(`
            UnitDefs = {} -- Empty initially for Post scope usage usually, but here we just need the hook
            UnitDef_Post = nil
        `);

        const tweak: TweakDefinition = {
            name: "Post Tweak",
            description: "",
            scope: "UnitDef_Post",
            conditions: [{ type: 'nameMatch', regex: 'armcom' }],
            mutations: [
                { op: 'set', field: 'metalCost', value: 100 }
            ]
        };

        const code = compileTweak(tweak);
        await lua.doString(code);

        // Mock calling UnitDef_Post
        await lua.doString(`
            local def = { name = "armcom", metalCost = 500 }
            UnitDef_Post("armcom", def)
            TEST_RESULT = def.metalCost
        `);

        const result = lua.global.get('TEST_RESULT');
        expect(result).toBe(100);
    });

    test('Clone Unit', async () => {
         await lua.doString(`
            UnitDefs = {
                armcom = { name = "armcom", health = 1000 }
            }
            table.merge = function(t1, t2)
                for k,v in pairs(t2) do t1[k] = v end
                return t1
            end
        `);

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

        const code = compileTweak(tweak);
        await lua.doString(code);

        const unitDefs = lua.global.get('UnitDefs');
        expect(unitDefs.super_com).toBeDefined();
        expect(unitDefs.super_com.health).toBe(5000);
        expect(unitDefs.super_com.name).toBe("Super Commander");
        expect(unitDefs.armcom.health).toBe(1000); // Original unchanged
    });
});
