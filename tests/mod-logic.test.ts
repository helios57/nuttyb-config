import { generateLuaTweak, decodeBase64Url } from '../src/mod-logic/utils';
import { generateCommands, CommandGeneratorInput } from '../src/mod-logic/command-generator';
import { addCustomTweak, deleteCustomTweak, getCustomOptions, saveCustomOptions } from '../src/mod-logic/custom-tweaks';
import { GameConfigs, FormOptionsConfig } from '../src/mod-logic/types';

// Mock luamin global
(global as any).luamin = {
    minify: jest.fn((code: string) => code.replace(/--.*\n/g, '').replace(/\s+/g, ' ').trim())
};

// Mock localStorage
const localStorageMock = (() => {
    let store: Record<string, string> = {};
    return {
        getItem: jest.fn((key: string) => store[key] || null),
        setItem: jest.fn((key: string, value: string) => { store[key] = value.toString(); }),
        clear: jest.fn(() => { store = {}; }),
        removeItem: jest.fn((key: string) => { delete store[key]; })
    };
})();
Object.defineProperty(global, 'localStorage', { value: localStorageMock });

// Mock TextDecoder/TextEncoder
import { TextEncoder, TextDecoder } from 'util';
(global as any).TextEncoder = TextEncoder;
(global as any).TextDecoder = TextDecoder;

describe('Mod Logic Tests', () => {

    describe('Utils', () => {
        test('decodeBase64Url should decode valid base64url string', () => {
            const original = "Hello World";
            const encoded = Buffer.from(original).toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
            expect(decodeBase64Url(encoded)).toBe(original);
        });

        test('generateLuaTweak should generate valid lua code for QHP', () => {
            const multiplier = "2.5";
            const result = generateLuaTweak('qhp', multiplier);
            const decoded = decodeBase64Url(result);
            // Expect generated code to contain health multiplication on 'def' variable
            expect(decoded).toMatch(/def\.health\s*=\s*def\.health\s*\*\s*2\.5/);
        });

        test('generateLuaTweak should handle HP multiplier logic correctly', () => {
            const multiplier = "2";
            const result = generateLuaTweak('hp', multiplier);
            const decoded = decodeBase64Url(result);
            // Check for specific metal cost factor for 2x HP (0.35)
            // The compiler might localize math_floor and use parens, so regex is safer or just checking the number
            expect(decoded).toContain('0.35');
            expect(decoded).toMatch(/def\.health\s*=\s*def\.health\s*\*\s*2/);
        });
    });

    describe('Custom Tweaks', () => {
        beforeEach(() => {
            localStorageMock.clear();
            saveCustomOptions([]);
        });

        test('should add a custom tweak', () => {
            addCustomTweak('My Tweak', 'tweakdefs', 'some_code');
            const options = getCustomOptions();
            expect(options).toHaveLength(1);
            expect(options[0].desc).toBe('My Tweak');
            expect(options[0].type).toBe('tweakdefs');
            expect(localStorageMock.setItem).toHaveBeenCalled();
        });

        test('should delete a custom tweak', () => {
            addCustomTweak('Tweak 1', 'tweakdefs', 'code1');
            const id = getCustomOptions()[0].id;
            deleteCustomTweak(id);
            expect(getCustomOptions()).toHaveLength(0);
        });
    });

    describe('Command Generator', () => {
        const mockGameConfigs: GameConfigs = {
            maps: [{ name: 'Map1', commands: ['!map 1'] }],
            modes: [{ name: 'Mode1', commands: ['!mode 1'] }],
            base: ['!bset base 1'],
            scavengers: ['!bset scav 1']
        };

        const mockFormOptions: FormOptionsConfig[] = [
            { label: 'Option 1', type: 'checkbox', commandBlocks: ['!bset opt1 1'], default: false, column: 'left' },
            { label: 'Raptor Health', type: 'select', isHpGenerator: true, hpType: 'hp', column: 'left', slot: '', slotType: 'tweakdefs', choices: [] }
        ];

        test('should generate commands for selected map and mode', () => {
            const input: CommandGeneratorInput = {
                gameConfigs: mockGameConfigs,
                formOptionsConfig: mockFormOptions,
                mapsSelectValue: "0",
                modesSelectValue: "0",
                primaryModeSelectValue: "Raptors",
                scavHpSelectValue: "",
                scavHpSelectText: "",
                bossHpSelectValue: "",
                bossHpSelectText: "",
                formElements: [],
                raptorOptions: []
            };

            const result = generateCommands(input);
            expect(result.sections[0]).toContain('!map 1');
            expect(result.sections[0]).toContain('!mode 1');
            expect(result.sections[0]).toContain('!bset base 1'); // Base commands added because map/mode selected
        });

        test('should generate commands for standard options', () => {
            const input: CommandGeneratorInput = {
                gameConfigs: mockGameConfigs,
                formOptionsConfig: mockFormOptions,
                mapsSelectValue: "",
                modesSelectValue: "",
                primaryModeSelectValue: "Raptors",
                scavHpSelectValue: "",
                scavHpSelectText: "",
                bossHpSelectValue: "",
                bossHpSelectText: "",
                formElements: [{
                    isCustom: false,
                    checked: true,
                    commandBlocks: ['!bset opt1 1'],
                    tagName: 'INPUT',
                    id: 'opt1',
                    dataset: {}
                }],
                raptorOptions: []
            };

            const result = generateCommands(input);
            expect(result.sections[0]).toContain('!bset opt1 1');
            expect(result.lobbyName).toContain('[Mod] NuttyB Raptors');
        });

        test('should generate commands for HP generator', () => {
            const input: CommandGeneratorInput = {
                gameConfigs: mockGameConfigs,
                formOptionsConfig: mockFormOptions,
                mapsSelectValue: "",
                modesSelectValue: "",
                primaryModeSelectValue: "Raptors",
                scavHpSelectValue: "",
                scavHpSelectText: "",
                bossHpSelectValue: "",
                bossHpSelectText: "",
                formElements: [{
                    isCustom: false,
                    isHpGenerator: true,
                    value: "2",
                    hpType: "hp",
                    slot: "",
                    slotType: "tweakdefs",
                    tagName: 'SELECT',
                    id: 'hp-select',
                    dataset: {}
                }],
                raptorOptions: []
            };

            const result = generateCommands(input);
            // Expect generated command for 2x HP
            expect(result.sections[0]).toMatch(/!bset tweakdefs[0-9]+\s+[a-zA-Z0-9_-]+/);
        });

        test('should handle Scavengers mode correctly', () => {
            const input: CommandGeneratorInput = {
                gameConfigs: mockGameConfigs,
                formOptionsConfig: mockFormOptions,
                mapsSelectValue: "",
                modesSelectValue: "",
                primaryModeSelectValue: "Scavengers",
                scavHpSelectValue: "1.3",
                scavHpSelectText: "1.3x HP",
                bossHpSelectValue: "1.3",
                bossHpSelectText: "1.3x BHP",
                formElements: [
                    // Simulate the scav hp selects being part of the form elements processing if they generate commands
                    {
                        isCustom: false,
                        isScavHpGenerator: true,
                        value: "1.3",
                        hpType: "scav",
                        slot: "",
                        slotType: "tweakdefs",
                        tagName: 'SELECT',
                        id: 'scav-hp',
                        dataset: {}
                    }
                ],
                raptorOptions: []
            };

            const result = generateCommands(input);
            expect(result.lobbyName).toContain('Scavengers');
            expect(result.lobbyName).toContain('[1_3x HP 1_3x BHP]');
            expect(result.sections[0]).toContain('!bset scav 1'); // Scavenger base config
        });
    });
});
