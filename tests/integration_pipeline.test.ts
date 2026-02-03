import { generateTweak } from '../src/mod-logic/tweak-generator';
import { compileTweak } from '../src/mod-logic/lua-compiler';
import { TweakDefinition } from '../src/mod-logic/tweak-dsl';

// Mock Scripts index if needed, but we are testing tweak-definition
jest.mock('../src/mod-logic/generators/scripts-index', () => ({}));

describe('Integration Pipeline & Validation', () => {

    describe('Hydration & Tweak Generation', () => {
        test('should hydrate placeholders with values and compile to Lua', () => {
            const config = {
                generator: 'tweak-definition',
                values: { multiplier: 2.5, unitName: 'armcom' },
                tweaks: [{
                    name: 'HydratedTweak',
                    scope: 'UnitDefsLoop',
                    conditions: [{ type: 'nameMatch', regex: '{{unitName}}' }],
                    mutations: [{ op: 'multiply', field: 'health', factor: '{{multiplier}}' }]
                }]
            };

            const lua = generateTweak(config);
            
            expect(lua).toContain('string_match(name, "armcom")');
            // Check if 2.5 was used. The compiler generates `val * 2.5`
            expect(lua).toContain('* 2.5');
        });

        test('should handle missing values by keeping placeholder or failing gracefully', () => {
            const config = {
                generator: 'tweak-definition',
                values: {}, // No multiplier
                tweaks: [{
                    name: 'BrokenTweak',
                    scope: 'UnitDefsLoop',
                    conditions: [],
                    mutations: [{ op: 'multiply', field: 'health', factor: '{{multiplier}}' }]
                }]
            };

            const lua = generateTweak(config);
            // Since {{multiplier}} remains a string, the compiler might output `* "{{multiplier}}"` or fail if it strictly checks number.
            // In my implementation, it remains string. Lua allows `x * "str"`.
            // But let's check what happened.
            expect(lua).toContain('* {{multiplier}}');
            expect(lua).not.toContain('Error compiling'); // Should not crash
        });

        test('should return error string on validation failure (malformed JSON)', () => {
            const config = {
                generator: 'tweak-definition',
                tweaks: "This is not an array" // Invalid tweaks
            };
            const result = generateTweak(config);
            expect(result).toContain('-- Error compiling tweak');
        });
    });

    describe('Lua Compiler BAR Alignment', () => {
        test('should sort mutations to prevent rounding drift (multiply before floor)', () => {
            const tweak: TweakDefinition = {
                name: 'OrderTest',
                description: '',
                scope: 'UnitDefsLoop',
                conditions: [],
                mutations: [
                    { op: 'assign_math_floor', target: 'metalCost', source: 'metalCost', factor: 1 },
                    { op: 'multiply', field: 'metalCost', factor: 1.5 }
                ]
            };
            // Input order: Floor then Multiply
            // Expected Output order: Multiply then Floor (based on my sort logic)

            const lua = compileTweak(tweak);
            const multIndex = lua.indexOf('def.metalCost = def.metalCost * 1.5');
            const floorIndex = lua.indexOf('def.metalCost = math_floor');

            expect(multIndex).toBeGreaterThan(-1);
            expect(floorIndex).toBeGreaterThan(-1);
            expect(multIndex).toBeLessThan(floorIndex);
        });

        test('should handle customParams case-insensitivity correctly', () => {
            const tweak: TweakDefinition = {
                name: 'CPTest',
                description: '',
                scope: 'UnitDefsLoop',
                conditions: [],
                mutations: [
                    { op: 'set', field: 'customParams.isupgraded', value: 1 }
                ]
            };

            const lua = compileTweak(tweak);
            
            // Check for the complex write logic
            expect(lua).toContain('if def.customparams then');
            expect(lua).toContain('def.customparams["isupgraded"] = 1');
            expect(lua).toContain('if not def.customParams then def.customParams = {} end');
            expect(lua).toContain('def.customParams["isupgraded"] = 1');
        });
    });
});
