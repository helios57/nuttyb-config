
import { generateCommands, CommandGeneratorInput } from '../src/mod-logic/command-generator';
import { GameConfigs, FormOptionsConfig } from '../src/mod-logic/types';
import { TweakDefinition } from '../src/mod-logic/tweak-dsl';
import { decodeBase64Url } from '../src/mod-logic/utils';

// Mock Data
const mockGameConfigs: GameConfigs = {
    base: ['!bset base 1'],
    scavengers: ['!bset scav 1'],
    maps: [{ name: 'TestMap', commands: ['!bset map 1'] }],
    modes: [{ name: 'TestMode', commands: ['!bset mode 1'] }]
};

const mockFormOptionsConfig: FormOptionsConfig[] = [];

function createLargeTweakDef(id: number): TweakDefinition {
    return {
        name: `Tweak ${id}`,
        description: `Description ${id}`,
        scope: 'UnitDefsLoop',
        conditions: [
            { type: 'nameMatch', regex: `arm.*${id}` }
        ],
        mutations: [
            { op: 'multiply', field: 'health', factor: 2 },
            { op: 'set', field: 'buildTime', value: 1000 },
            // Add some padding to make the string larger
            { op: 'set', field: `customParams.large_field_${id}`, value: "x".repeat(500) }
        ]
    };
}

describe('Command Generator', () => {
    it('should split huge tweakdefs into multiple chunks', () => {
        // Create enough tweaks to exceed the chunk limit (e.g. 10KB)
        // Each tweak is roughly 500+ chars of code + base64 overhead.
        // 20 tweaks * 500 chars = 10000 chars.
        // Let's create 50 tweaks to be sure.

        const largeTweaks = Array.from({ length: 50 }, (_, i) => ({
            id: `input_${i}`,
            tagName: 'INPUT',
            type: 'checkbox',
            checked: true,
            isCustom: false,
            dataset: {} as DOMStringMap,
            tweakDefinition: createLargeTweakDef(i)
        }));

        const input: CommandGeneratorInput = {
            gameConfigs: mockGameConfigs,
            formOptionsConfig: mockFormOptionsConfig,
            mapsSelectValue: "",
            modesSelectValue: "",
            primaryModeSelectValue: "Raptors",
            scavHpSelectValue: "",
            scavHpSelectText: "",
            bossHpSelectValue: "",
            bossHpSelectText: "",
            formElements: largeTweaks,
            raptorOptions: []
        };

        const result = generateCommands(input);

        // Flatten all commands from sections
        const allCommands = result.sections.join('\n').split('\n');

        // Find all tweakdefs commands
        const tweakDefsCommands = allCommands.filter(cmd => cmd.includes('!bset tweakdefs'));

        // We expect multiple tweakdefs commands (e.g. tweakdefs1, tweakdefs2...)
        // With 50 * 500 chars = 25000 chars, and 10000 char limit, we expect ~3 chunks.
        console.log(`Generated ${tweakDefsCommands.length} tweakdefs chunks.`);

        expect(tweakDefsCommands.length).toBeGreaterThan(1);

        // Verify slots
        const slots = tweakDefsCommands.map(cmd => {
            const match = cmd.match(/!bset tweakdefs(\d+)/);
            return match ? parseInt(match[1]) : 0;
        }).sort((a, b) => a - b);

        // Should use consecutive slots starting from 1 (or whatever is available)
        // Since we didn't use any slots, it should start at 1.
        expect(slots[0]).toBe(1);
        expect(slots[1]).toBe(2);

        // Verify ordering: Tweakdefs should come BEFORE other commands (if any)
        // Add a standard command to verify order
        const inputWithStandard = {
            ...input,
            formElements: [
                ...largeTweaks,
                { tagName: 'INPUT', type: 'checkbox', checked: true, dataset: { modOption: 'test_opt' } as unknown as DOMStringMap, value: '1', id: 'std_opt', isCustom: false }
            ]
        };

        const result2 = generateCommands(inputWithStandard);
        const allCommands2 = result2.sections.join('\n').split('\n');

        const firstCommand = allCommands2.find(c => c.trim().length > 0);
        const standardCommandIndex = allCommands2.findIndex(c => c.includes('!bset test_opt'));
        const firstTweakIndex = allCommands2.findIndex(c => c.includes('!bset tweakdefs'));

        // Expect tweakdefs to appear before standard commands
        expect(firstTweakIndex).toBeLessThan(standardCommandIndex);
        expect(firstTweakIndex).toBe(0); // Should be the very first thing (ignoring empty lines or section headers if any)
    });

    it('should generate valid Lua in each chunk', () => {
        const tweaks = Array.from({ length: 5 }, (_, i) => ({
            id: `input_${i}`,
            tagName: 'INPUT',
            type: 'checkbox',
            checked: true,
            isCustom: false,
            dataset: {} as DOMStringMap,
            tweakDefinition: createLargeTweakDef(i)
        }));

        const input: CommandGeneratorInput = {
            gameConfigs: mockGameConfigs,
            formOptionsConfig: mockFormOptionsConfig,
            mapsSelectValue: "",
            modesSelectValue: "",
            primaryModeSelectValue: "Raptors",
            scavHpSelectValue: "",
            scavHpSelectText: "",
            bossHpSelectValue: "",
            bossHpSelectText: "",
            formElements: tweaks,
            raptorOptions: []
        };

        const result = generateCommands(input);
        const allCommands = result.sections.join('\n').split('\n');
        const tweakDefsCommands = allCommands.filter(cmd => cmd.includes('!bset tweakdefs'));

        tweakDefsCommands.forEach(cmd => {
            const base64 = cmd.split(' ')[2];
            const lua = decodeBase64Url(base64);

            // Check for basic Lua validity markers
            expect(lua).toContain('local pairs = pairs'); // Globals should be emitted in EACH chunk
            // The code should contain: for id, def in pairs(UnitDefs) do
            expect(lua).toContain('for id, def in pairs(UnitDefs) do');
        });
    });
});
