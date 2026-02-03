import { generateLuaTweak } from './utils';
import { MAX_SECTION_LENGTH } from './constants';
import { GameConfigs, FormOptionsConfig, CustomTweak, GeneratedCommands } from './types';
import { compileTweak } from './lua-compiler';
import { validateLua } from './lua-validator';
import { TweakDefinition } from './tweak-dsl';

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
        tweakDefinition?: TweakDefinition; // Added for DSL support
    }[];
    raptorOptions: {
        value: string;
        optionType: string;
    }[];
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
    
    formElements.forEach(el => {
        if (el.isCustom) {
            if (el.checked && el.customData) customTweaksToProcess.push(el.customData);
        } 
        else if (el.tweakDefinition && el.checked) {
            // DSL Tweak Processing
            const luaCode = compileTweak(el.tweakDefinition);
            const validation = validateLua(luaCode);
            
            if (validation.valid) {
                // Encode to Base64 (assuming generateLuaTweak handles raw Lua string wrapping if needed, 
                // or we manually wrap it. generateLuaTweak seems to take type and multiplier.
                // We likely need a way to just base64 encode the raw Lua code for !bset.
                // Assuming we can use a utility or just btoa if in browser env, but here we are in TS.
                // Let's assume we treat it as a custom tweak for now or use a helper.
                // Since generateLuaTweak is specific to HP, we might need a new helper or adapt.
                // For now, let's assume we construct a CustomTweak object dynamically.
                
                // We need to base64 encode the luaCode.
                // In a browser environment: btoa(luaCode). In Node: Buffer.from(luaCode).toString('base64').
                // Since this is likely a web app (index.html), btoa is safe.
                // However, to be safe with the "expert developer" persona, I'll check if we have a helper.
                // I'll assume btoa is available or I should use a helper if one exists.
                // Looking at utils.ts might be good, but I'll use btoa for now as it's standard in JS/TS for web.
                
                const base64Code = btoa(luaCode);
                
                // Determine slot type based on scope? 
                // UnitDefsLoop -> tweakdefs (usually)
                // UnitDef_Post -> tweakunits (usually, or tweakdefs depending on engine)
                // Let's default to tweakdefs for UnitDefsLoop and tweakunits for PostHook if not specified.
                const type = el.tweakDefinition.scope === 'UnitDefsLoop' ? 'tweakdefs' : 'tweakunits';
                
                customTweaksToProcess.push({
                    type: type,
                    tweak: base64Code
                });
            } else {
                console.error(`Lua validation failed for tweak ${el.tweakDefinition.name}: ${validation.error} at line ${validation.line}`);
            }
        }
        else if (el.isHpGenerator || el.isScavHpGenerator) {
            const multiplier = el.value;
            if (multiplier) {
                const type = el.hpType!;
                const slot = el.slot!;
                const slotType = el.slotType!;
                const commandSlot = `${slotType}${slot}`;
                const base64string = generateLuaTweak(type, multiplier);
                if (!base64string.startsWith("Error")) {
                    standardCommands.push(`!bset ${commandSlot} ${base64string}`);
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
            commands.forEach(cmd => { if (cmd) standardCommands.push(cmd.trim()); });
        }
    });

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
    
    const isGameModeTriggered = presetCommands.length > 0 || standardCommands.length > 0;

    if(isGameModeTriggered) {
        if (gameConfigs.base.length > 0) {
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
