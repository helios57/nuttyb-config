export interface GameConfigs {
    maps: { name: string; commands: string[] }[];
    modes: { name: string; commands: string[] }[];
    base: string[];
    scavengers: string[];
}

export interface RawOptionsData {
    label: string;
    commandBlock: string;
    status: string;
    summary: string;
}

export interface FormOptionsConfig {
    label: string;
    type: string;
    commandBlocks?: string[];
    default?: boolean;
    disabled?: boolean;
    column: string;
    choices?: { label: string; value: string; shortLabel?: string }[];
    defaultValue?: string;
    isHpGenerator?: boolean;
    hpType?: string;
    slot?: string | number;
    slotType?: string;
}

export interface CustomTweak {
    id: number;
    desc: string;
    type: string;
    tweak: string;
}

export interface GeneratedCommands {
    lobbyName: string;
    sections: string[];
}

export interface GroupedOptions {
    mainTweaks: FormOptionsConfig;
    evolvingCommanders: FormOptionsConfig;
    extraRaptors: FormOptionsConfig;
    otherCheckboxes: { type: string; options: FormOptionsConfig[]; column: string };
}
