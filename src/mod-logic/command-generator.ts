import { MAX_SECTION_LENGTH } from './constants';
import { GameConfigs, FormOptionsConfig, CustomTweak, GeneratedCommands } from './types';
import { validateLua } from './lua-validator';
import { TweakDefinition } from './tweak-dsl';
import tweakLibrary from './tweak-library.json';
import { OptimizedLuaCompiler } from './optimized-compiler';
import { generateFusionUnits, generateMegaRaptors } from './unit-generators';

// Type assertion for the JSON library
const library = tweakLibrary as Record<string, TweakDefinition>;

export interface CommandGeneratorInput {
    gameConfigs: GameConfigs;
    formOptionsConfig: FormOptionsConfig[];
    mapsSelectValue: string;
    modesSelectValue: string;
    primaryModeSelectValue: string;
    scavHpSelectValue: string;
    scavHpSelectText: string;
    bossHpSelectValue: string;
    bossHpSelectText: string;
    formElements: {
        isCustom: boolean;
        customData?: CustomTweak;
        isHpGenerator?: boolean;
        isScavHpGenerator?: boolean;
        value?: string;
        checked?: boolean;
        hpType?: string;
        slot?: string;
        slotType?: string;
        tagName: string;
        id: string;
        dataset: any;
        commandBlocks?: string[];
        tweakDefinition?: TweakDefinition; // Legacy support or direct injection
    }[];
    raptorOptions: {
        value: string;
        optionType: string;
    }[];
    isMainTweaksEnabled?: boolean;
}

interface CompilerInput {
    tweak: TweakDefinition;
    variables: Record<string, any>;
}

export function generateCommands(input: CommandGeneratorInput): GeneratedCommands {
    const {
        gameConfigs,
        formOptionsConfig,
        mapsSelectValue,
        modesSelectValue,
        primaryModeSelectValue,
        scavHpSelectValue,
        scavHpSelectText,
        bossHpSelectValue,
        bossHpSelectText,
        formElements,
        raptorOptions
    } = input;

    const presetCommands: string[] = [];

    if (mapsSelectValue !== "") {
        const selectedMap = gameConfigs.maps[parseInt(mapsSelectValue)];
        if (selectedMap && selectedMap.commands) presetCommands.push(...selectedMap.commands);
    }
    if (modesSelectValue !== "") {
        const selectedMode = gameConfigs.modes[parseInt(modesSelectValue)];
        if (selectedMode && selectedMode.commands) presetCommands.push(...selectedMode.commands);
    }

    const standardCommands: string[] = [];
    const customTweaksToProcess: CustomTweak[] = [];
    const compilerInputs: CompilerInput[] = [];

    // Process Form Elements
    formElements.forEach(el => {
        if (el.isCustom) {
            if (el.checked && el.customData) customTweaksToProcess.push(el.customData);
        }
        else if (el.tweakDefinition && el.checked) {
            // Support direct definition injection if still used
             compilerInputs.push({ tweak: el.tweakDefinition, variables: {} });
        }
        else if (el.isHpGenerator || el.isScavHpGenerator) {
            const multiplier = parseFloat(el.value || "0");
            if (multiplier > 0) {
                const type = el.hpType!;
                if (type === 'qhp') {
                    if (library.qhp) {
                        compilerInputs.push({
                            tweak: library.qhp,
                            variables: { multiplier, multiplierText: el.value! }
                        });
                    }
                } else if (type === 'hp') {
                    let metalCostFactor = 1;
                    let workerTimeMultiplier = 0.5;

                    switch (multiplier) {
                        case 1.3: metalCostFactor = 0.576923077; workerTimeMultiplier = 0.5; break;
                        case 1.5: metalCostFactor = 0.466666667; workerTimeMultiplier = 0.5; break;
                        case 1.7: metalCostFactor = 0.411764706; workerTimeMultiplier = 0.5; break;
                        case 2:   metalCostFactor = 0.35;        workerTimeMultiplier = 0.5; break;
                        case 2.5: metalCostFactor = 0.3;         workerTimeMultiplier = 0.6; break;
                        case 3:   metalCostFactor = 0.25;        workerTimeMultiplier = 0.55; break;
                        case 4:   metalCostFactor = 0.1875;      workerTimeMultiplier = 0.45; break;
                        case 5:   metalCostFactor = 0.15;        workerTimeMultiplier = 0.25; break;
                        default:  metalCostFactor = 1;           workerTimeMultiplier = 0.5; break;
                    }

                    if (library.raptor_swarmer_heal) compilerInputs.push({ tweak: library.raptor_swarmer_heal, variables: { workertimeMultiplier: workerTimeMultiplier, multiplierText: el.value! } });
                    if (library.raptor_health) compilerInputs.push({ tweak: library.raptor_health, variables: { healthMultiplier: multiplier, multiplierText: el.value! } });
                    if (library.raptor_metal_chase) compilerInputs.push({ tweak: library.raptor_metal_chase, variables: { metalCostFactor, multiplierText: el.value! } });

                } else if (type === 'boss') {
                    if (library.boss_hp) compilerInputs.push({ tweak: library.boss_hp, variables: { multiplier, multiplierText: el.value! } });
                } else if (type === 'scav') {
                    if (library.scav_hp_health) compilerInputs.push({ tweak: library.scav_hp_health, variables: { multiplier, multiplierText: el.value! } });
                    if (library.scav_hp_metal) compilerInputs.push({ tweak: library.scav_hp_metal, variables: { multiplier, multiplierText: el.value! } });
                }
            }
        }
        else {
            let commands: string[] = [];
            if (el.tagName === 'SELECT' && !el.id.includes('maps-select') && !el.id.includes('modes-select') && !el.id.includes('primary-mode-select')) {
                if (el.value) commands.push(el.value);
            }
            else if (el.checked && el.commandBlocks) {
                commands = el.commandBlocks;
            }

            // Check for Build Menu Tweaks logic which might be embedded in commandBlocks or dataset
            if (el.dataset.tweakTemplateId) {
                const templateId = el.dataset.tweakTemplateId;
                if (library[templateId]) {
                    // Variables from dataset?
                    // Supports both JSON object in tweakVars or single variable mapping via tweakVar + value
                    let vars = {};
                    if (el.dataset.tweakVars) {
                        try {
                            vars = JSON.parse(el.dataset.tweakVars);
                        } catch (e) {
                            console.error("Error parsing tweakVars JSON:", e);
                        }
                    } else if (el.dataset.tweakVar && el.value) {
                         vars = { [el.dataset.tweakVar]: parseFloat(el.value) || el.value };
                    }
                    compilerInputs.push({ tweak: library[templateId], variables: vars });
                }
            }

            if (el.dataset.modOption && el.value) {
                commands.push(`!bset ${el.dataset.modOption} ${el.value}`);
            }

            commands.forEach(cmd => { if (cmd) standardCommands.push(cmd.trim()); });
        }
    });

    if (standardCommands.includes('!bset fusion_mode 1')) {
        const fusionTweaks = generateFusionUnits();
        fusionTweaks.forEach(t => compilerInputs.push({ tweak: t, variables: {} }));
    }

    if (standardCommands.includes('!bset adaptive_spawner 1')) {
        const raptorTweaks = generateMegaRaptors();
        raptorTweaks.forEach(t => compilerInputs.push({ tweak: t, variables: {} }));
    }

    // Compile Generated Tweaks
    if (compilerInputs.length > 0) {
        const compiler = new OptimizedLuaCompiler();
        const luaCode = compiler.compile(compilerInputs);

        // Validation
        const validation = validateLua(luaCode);
        if (validation.valid) {
            const utf8SafeString = unescape(encodeURIComponent(luaCode));
            const base64Code = btoa(utf8SafeString).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');

            // Add as a 'tweakdefs' custom tweak (slot preference handled later)
            customTweaksToProcess.unshift({
                id: 0, // System generated
                desc: 'Optimized Config',
                type: 'tweakdefs',
                tweak: base64Code
            });
        } else {
             console.error(`Lua validation failed for generated config: ${validation.error}`);
        }
    }

    const usedTweakDefs = new Set<number>();
    const usedTweakUnits = new Set<number>();
    const slotRegex = /!bset\s+(tweakdefs|tweakunits)([1-9])\b/;

    [...standardCommands].forEach(cmd => {
        const match = cmd.match(slotRegex);
        if (match) {
            const slotNum = parseInt(match[2], 10);
            if (match[1] === 'tweakdefs') usedTweakDefs.add(slotNum);
            else if (match[1] === 'tweakunits') usedTweakUnits.add(slotNum);
        }
    });

    const customCommands: string[] = [];
    customTweaksToProcess.forEach(tweak => {
        const targetSet = (tweak.type === 'tweakdefs') ? usedTweakDefs : usedTweakUnits;
        let availableSlot: number | null = null;
        for (let i = 1; i <= 9; i++) { if (!targetSet.has(i)) { availableSlot = i; break; } }
        if (availableSlot !== null) {
            customCommands.push(`!bset ${tweak.type}${availableSlot} ${tweak.tweak}`);
            targetSet.add(availableSlot);
        } else { console.warn(`All slots for '${tweak.type}' are full. Could not add custom tweak.`); }
    });

    const anyOptionSelected = presetCommands.length > 0 || standardCommands.length > 0 || customCommands.length > 0;
    const finalCommands: string[] = [];

    const isGameModeTriggered = presetCommands.length > 0 || standardCommands.length > 0 || customCommands.length > 0;
    // Default to true if not provided (legacy/fallback)
    const isMainTweaksEnabled = input.isMainTweaksEnabled !== false;

    if(isGameModeTriggered) {
        if (isMainTweaksEnabled && gameConfigs.base.length > 0) {
            finalCommands.push(...gameConfigs.base);
        }
        if (primaryModeSelectValue === 'Scavengers' && gameConfigs.scavengers.length > 0) {
            finalCommands.push(...gameConfigs.scavengers);
        }
    }

    finalCommands.push(...presetCommands, ...standardCommands, ...customCommands);

    const isScavengers = primaryModeSelectValue === 'Scavengers';

    let renameCommand = isScavengers ? `$rename [Mod] NuttyB Scavengers ` : `$rename [Mod] NuttyB Raptors `;
    const renameParts: string[] = [];

    if (isScavengers) {
        const combinedScavHp = [scavHpSelectText, bossHpSelectText].filter(Boolean).join(' ');
        if (combinedScavHp) {
            const formattedHpPart = combinedScavHp.replace(/\./g, '_');
            renameParts.push(`[${formattedHpPart}]`);
        }

    } else {
        let extraRaptorsPart = "", raptorHealthPart = "", queenHealthPart = "";
        raptorOptions.forEach(opt => {
            if (opt.value) {
                const g = formOptionsConfig.find(gr => gr.label === opt.optionType);
                if (g && g.choices) {
                    const c = g.choices.find(ch => ch.value === opt.value);
                    if (c && c.shortLabel !== undefined) {
                        if (g.label === "Extras") extraRaptorsPart = c.shortLabel;
                        else if (g.label === "Raptor Health") raptorHealthPart = c.shortLabel;
                        else if (g.label === "Queen Health") queenHealthPart = c.shortLabel;
                    }
                }
            }
        });

        if (extraRaptorsPart) renameParts.push(extraRaptorsPart);

        const combinedRaptorHp = [queenHealthPart, raptorHealthPart].filter(Boolean).join(' ');
        if (combinedRaptorHp) renameParts.push(`[${combinedRaptorHp}]`);
    }

    const noMexCommand = '!unit_restrictions_noextractors 1';
    const allowMexCommand = '!unit_restrictions_noextractors 0';
    const lastNoMexIndex = finalCommands.lastIndexOf(noMexCommand);
    const lastAllowMexIndex = finalCommands.lastIndexOf(allowMexCommand);
    const noMexEnabled = lastNoMexIndex > -1 && lastNoMexIndex > lastAllowMexIndex;

    if (renameParts.length > 0) {
        renameCommand += renameParts.join('');
    }
    if (noMexEnabled) {
        renameCommand += `[No Mex]`;
    }

    const sectionsData: { commands: string[], length: number }[] = [];
    const allCommandsToSection = finalCommands;

    for (const cmd of allCommandsToSection) {
        if (!cmd) continue;
        let placed = false;
        for (const section of sectionsData) {
            const neededLength = section.length === 0 ? cmd.length : cmd.length + 1;
            if (section.length + neededLength <= MAX_SECTION_LENGTH) {
                section.commands.push(cmd);
                section.length += neededLength;
                placed = true;
                break;
            }
        }
        if (!placed) {
            sectionsData.push({ commands: [cmd], length: cmd.length });
        }
    }

    if (anyOptionSelected) {
        if (sectionsData.length === 0) {
            sectionsData.push({ commands: [renameCommand], length: renameCommand.length });
        } else {
            const lastSection = sectionsData[sectionsData.length - 1];
            const neededLength = lastSection.length === 0 ? renameCommand.length : renameCommand.length + 1;

            if (lastSection.length + neededLength <= MAX_SECTION_LENGTH) {
                lastSection.commands.push(renameCommand);
                lastSection.length += neededLength;
            } else {
                sectionsData.push({ commands: [renameCommand], length: renameCommand.length });
            }
        }
    }

    const finalSections = sectionsData.map(section => section.commands.join('\n'));

    return { lobbyName: (anyOptionSelected ? renameCommand : 'No Options Selected'), sections: finalSections };
}
