import { compileTweak } from '../src/mod-logic/lua-compiler';
import { TweakDefinition } from '../src/mod-logic/tweak-dsl';

describe('Lua Compiler Performance & Optimization', () => {
    const tweak1: TweakDefinition = {
        name: 'Tweak1',
        description: 'Test Tweak 1',
        scope: 'UnitDefsLoop',
        conditions: [{ type: 'nameStartsWith', prefix: 'arm' }],
        mutations: [{ op: 'multiply', field: 'health', factor: 1.5 }]
    };

    const tweak2: TweakDefinition = {
        name: 'Tweak2',
        description: 'Test Tweak 2',
        scope: 'UnitDefsLoop',
        conditions: [{ type: 'nameEndsWith', suffix: 'com' }],
        mutations: [{ op: 'assign_math_floor', target: 'metalCost', source: 'metalCost', factor: 0.9 }]
    };

    const tweak3: TweakDefinition = {
        name: 'Tweak3',
        description: 'Test Tweak 3',
        scope: 'UnitDef_Post',
        conditions: [],
        mutations: [{ op: 'list_append', field: 'buildoptions', value: 'armwar' }]
    };

    test('should compile multiple tweaks into a single script with optimized structure', () => {
        // @ts-ignore - explicitly testing the new array signature before implementation is fully typed if needed, 
        // but we will update the implementation to match.
        const lua = compileTweak([tweak1, tweak2, tweak3]);

        // 1. Localize Globals
        expect(lua).toContain('local math_floor = math.floor');
        expect(lua).toContain('local string_sub = string.sub');
        // Check for duplicates (should not exist)
        const mathFloorMatches = lua.match(/local math_floor = math\.floor/g);
        expect(mathFloorMatches?.length).toBe(1);

        // 2. UnitDefsLoop Aggregation
        // Should have exactly one main loop
        const loopMatches = lua.match(/for id, def in pairs\(UnitDefs\) do/g);
        expect(loopMatches?.length).toBe(1);

        // 3. JIT Optimization (string.sub)
        // nameStartsWith 'arm' -> string.sub(..., 1, 3) == "arm"
        expect(lua).toContain('string_sub(name, 1, 3) == "arm"');
        // nameEndsWith 'com' -> string.sub(..., -3) == "com"
        expect(lua).toContain('string_sub(name, -3) == "com"');

        // 4. Memory Efficiency (list_append check)
        // Should check if target list exists
        expect(lua).toContain('if not target_list then');
        expect(lua).toContain('table_insert(target_list, "armwar")');

        // 5. UnitDef_Post Hook
        // Should have a single hook setup
        expect(lua).toContain('local prev_UnitDef_Post = UnitDef_Post');
        // Should call the previous one
        expect(lua).toContain('prev_UnitDef_Post(name, def)');
    });
});
