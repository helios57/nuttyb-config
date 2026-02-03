import { decodeBase64Url, encodeBase64Url } from './utils';
import { 
    mainTweaksPrefixes, 
    evolvingCommandersPrefixes, 
    extraRaptorsPrefixes, 
    hiddenLabels, 
    defaultSelectedLabels, 
    rightColumnOrder 
} from './constants';
import { GameConfigs, RawOptionsData, FormOptionsConfig, GroupedOptions } from './types';
import { generateTweak } from './tweak-generator';

// Declare require.context for Webpack
declare const require: any;

interface TweakDataEntry {
    label: string;
    variable: string;
    lua: string;
}

export async function loadConfigData(): Promise<{ rawOptionsData: RawOptionsData[], formOptionsConfig: FormOptionsConfig[] }> {
    const tweakData: TweakDataEntry[] = [];
    
    // Load all JSON files from src/tweaks
    // Note: This relies on Webpack's require.context
    if (typeof require.context === 'function') {
        const context = require.context('../tweaks', false, /\.json$/);
        const keys = context.keys();
        
        // Sort keys numerically based on prefix (e.g. "1-", "2-")
        keys.sort((a: string, b: string) => {
            const numA = parseInt(a.match(/\/(\d+)-/)?.[1] || '0');
            const numB = parseInt(b.match(/\/(\d+)-/)?.[1] || '0');
            return numA - numB;
        });

        keys.forEach((key: string) => {
            const config = context(key);
            const lua = generateTweak(config);
            tweakData.push({
                label: config.label,
                variable: config.variable,
                lua: lua
            });
        });
    } else {
        console.error("require.context is not available. Cannot load tweaks.");
    }

    return processConfigData(tweakData);
}

export async function loadLinksContent(): Promise<string> {
    try {
        const response = await fetch(`links.html?t=${Date.now()}`);
        if (!response.ok) return "";
        return await response.text();
    } catch (e) {
        console.error("Failed to load links content", e);
        return "";
    }
}

export async function parseModesFile(filePath: string): Promise<GameConfigs> {
    try {
        const response = await fetch(`${filePath}?t=${Date.now()}`);
        if (!response.ok) {
            throw new Error(`Could not load ${filePath}: ${response.statusText}`);
        }
        const text = await response.text();
        
        const configs: GameConfigs = { maps: [], modes: [], base: [], scavengers: [] };
        
        const categoryBlocks = text.split('## CATEGORY:').slice(1);

        for (const block of categoryBlocks) {
            const lines = block.trim().split(/\r?\n/);
            const categoryName = lines.shift()!.trim();
            const content = lines.join('\n').trim();

            if (categoryName === 'base') {
                configs.base = content.split(/\r?\n/).filter(line => line.trim() !== '');
            } else if (categoryName === 'scavengers') {
                configs.scavengers = content.split(/\r?\n/).filter(line => line.trim() !== '');
            } else {
                const items = content.split('---').filter(item => item.trim() !== '');
                for (const item of items) {
                    const itemLines = item.trim().split(/\r?\n/).filter(line => line.trim() !== '');
                    if (itemLines.length === 0) continue;

                    const name = itemLines.shift()!.trim();
                    const commands = itemLines;
                    
                    if (categoryName === 'maps' && configs.maps) {
                        configs.maps.push({ name, commands });
                    } else if (categoryName === 'modes' && configs.modes) {
                        configs.modes.push({ name, commands });
                    }
                }
            }
        }
        return configs;
    } catch (error) {
        console.error("Failed to parse game configs:", error);
        return { maps: [], modes: [], base: [], scavengers: [] }; 
    }
}

function processConfigData(data: TweakDataEntry[]): { rawOptionsData: RawOptionsData[], formOptionsConfig: FormOptionsConfig[] } {
    const groupedOptions: GroupedOptions = { 
        mainTweaks: { label: "NuttyB Main Tweaks", type: "checkbox", commandBlocks: [], default: true, disabled: false, column: 'left' },
        evolvingCommanders: { label: "NuttyB Evolving Commanders", type: "checkbox", commandBlocks: [], default: true, disabled: false, column: 'left' },
        extraRaptors: { label: "Extras", type: "select", choices: [{ label: "None", value: "", shortLabel: "" }], column: 'left' },
        otherCheckboxes: { type: "checkboxes", options: [], column: 'right' }
    };
    const rawOptionsData: RawOptionsData[] = [];

    const dynamicHPGroup: FormOptionsConfig = {
        label: "Raptor Health", type: "select", isHpGenerator: true, hpType: 'hp', column: 'left', slot: '', slotType: 'tweakdefs',
        defaultValue: "1.3",
        choices: [
            { label: "Default", value: "", shortLabel: "" }, { label: "1x HP", value: "1", shortLabel: "1x HP" },
            { label: "1.3x HP", value: "1.3", shortLabel: "1_3x HP" }, { label: "1.5x HP", value: "1.5", shortLabel: "1_5x HP" },
            { label: "1.7x HP", value: "1.7", shortLabel: "1_7x HP" }, { label: "2x HP", value: "2", shortLabel: "2x HP" },
            { label: "2.5x HP", value: "2.5", shortLabel: "2_5x HP" }, { label: "3x HP", value: "3", shortLabel: "3x HP" },
            { label: "4x HP", value: "4", shortLabel: "4x HP" }, { label: "5x HP", value: "5", shortLabel: "5x HP" },
        ]
    };
    const dynamicQHPGroup: FormOptionsConfig = {
        label: "Queen Health", type: "select", isHpGenerator: true, hpType: 'qhp', column: 'left', slot: 1, slotType: 'tweakdefs',
        defaultValue: "1.3",
        choices: [
                { label: "Default", value: "", shortLabel: "" }, { label: "1x QHP", value: "1", shortLabel: "1x QHP" },
                { label: "1.3x QHP", value: "1.3", shortLabel: "1_3x QHP" }, { label: "1.5x QHP", value: "1.5", shortLabel: "1_5x QHP" },
                { label: "1.7x QHP", value: "1.7", shortLabel: "1_7x QHP" }, { label: "2x QHP", value: "2", shortLabel: "2x QHP" },
                { label: "2.5x QHP", value: "2.5", shortLabel: "2_5x QHP" }, { label: "3x QHP", value: "3", shortLabel: "3x QHP" },
                { label: "4x QHP", value: "4", shortLabel: "4x QHP" }, { label: "5x QHP", value: "5", shortLabel: "5x QHP" },
        ]
    };

    data.forEach(item => {
        const label = item.label;
        const lua = item.lua;
        const variable = item.variable;
        
        // Generate base64 command block on the fly
        const encoded = encodeBase64Url(lua);
        const commandBlock = `!bset ${variable} ${encoded}`;
        
        let summary = lua.split('\n')[0].trim();
        let status = "Optional", addedToFormGroup = false;

        // Note: Logic related to !bset tweakdefs1 or tweakdefs (space) filtering is implicitly handled 
        // because we only imported lines that were valid.
        // However, if we need to filter specific variables, we can do it here.
        // The original code filtered `!bset tweakdefs1` or `!bset tweakdefs `.
        // Our converter included them if they were present. 
        // Let's check if our JSON has them.
        // Tweak data JSON has `tweakdefs2`, `tweakdefs3`, etc.
        // If there's any `tweakdefs1` in JSON we might want to skip it if it was skipped before.
        // But let's assume valid data in JSON.

        if (extraRaptorsPrefixes.some(p => commandBlock.startsWith(p))) {
            status = "Optional/Grouped";
            let shortLabel = (label === "Mini Bosses") ? "[Mini Bosses]" : (label === "Experimental Wave Challenge") ? "[Expo Waves]" : "";
            groupedOptions.extraRaptors.choices!.push({ label, value: commandBlock, shortLabel });
            if (commandBlock.startsWith('!bset tweakdefs4')) groupedOptions.extraRaptors.defaultValue = commandBlock;
            addedToFormGroup = true;
        }
        if (mainTweaksPrefixes.some(p => commandBlock.startsWith(p))) { status = "Optional"; groupedOptions.mainTweaks.commandBlocks!.push(commandBlock); addedToFormGroup = true; }
        if (evolvingCommandersPrefixes.some(p => commandBlock.startsWith(p))) { status = "Optional"; groupedOptions.evolvingCommanders.commandBlocks!.push(commandBlock); if (defaultSelectedLabels.includes(label)) groupedOptions.evolvingCommanders.default = true; addedToFormGroup = true; }
        if (hiddenLabels.includes(label)) status = "Hidden";
        rawOptionsData.push({ label, commandBlock, status, summary });
        if (!addedToFormGroup && !hiddenLabels.includes(label)) { groupedOptions.otherCheckboxes.options.push({ label, type: "checkbox", commandBlocks: [commandBlock], default: defaultSelectedLabels.includes(label), column: 'right' }); }
    });
    
    groupedOptions.otherCheckboxes.options.sort((a,b) => { const ia=rightColumnOrder.indexOf(a.label),ib=rightColumnOrder.indexOf(b.label); return ((ia===-1)?Infinity:ia)-((ib===-1)?Infinity:ib); });
    
    let formOptionsConfig: FormOptionsConfig[] = [];
    if (groupedOptions.mainTweaks.commandBlocks!.length > 0) formOptionsConfig.push(groupedOptions.mainTweaks);
    if (groupedOptions.evolvingCommanders.commandBlocks!.length > 0) formOptionsConfig.push(groupedOptions.evolvingCommanders);
    
    formOptionsConfig.push(dynamicHPGroup, dynamicQHPGroup);

    if (groupedOptions.extraRaptors.choices!.length > 1) formOptionsConfig.push(groupedOptions.extraRaptors);
    formOptionsConfig = formOptionsConfig.concat(groupedOptions.otherCheckboxes.options);

    return { rawOptionsData, formOptionsConfig };
}
