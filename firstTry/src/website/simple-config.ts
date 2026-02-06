export interface ConfigOption {
    label: string;
    type: 'checkbox' | 'slider';
    default: boolean | number;
    modOption: string;
    description: string;
    min?: number;
    max?: number;
    step?: number;
}

export interface CustomTweak {
    id: string;
    description: string;
    type: 'tweakdefs' | 'tweakunits';
    code: string;
}

export const simpleConfig: ConfigOption[] = [
    {
        label: "Queen Amount",
        type: 'slider',
        default: 1,
        modOption: "queen_max_count",
        description: "Maximum number of queens allowed (1-10).",
        min: 1,
        max: 10,
        step: 1
    },
    {
        label: "Build Power Multiplier",
        type: 'slider',
        default: 1.0,
        modOption: "buildpower_mult",
        description: "Global multiplier for unit build speeds (0.5x - 5.0x).",
        min: 0.5,
        max: 5.0,
        step: 0.1
    },
    {
        label: "Eco Culling",
        type: 'checkbox',
        default: true,
        modOption: "cull_enabled",
        description: "Automatically destroys inefficient T1 eco structures when laggy."
    },
    {
        label: "Cull Radius",
        type: 'slider',
        default: 2000,
        modOption: "cull_radius",
        description: "Safe radius from start position where culling is disabled.",
        min: 500,
        max: 5000,
        step: 100
    },
    {
        label: "Fusion Efficiency",
        type: 'slider',
        default: 1.1,
        modOption: "fusion_efficiency",
        description: "Efficiency bonus for fused structures (1.0 = 100%, 2.0 = 200%).",
        min: 1.0,
        max: 2.0,
        step: 0.05
    },
    {
        label: "Adaptive Compression",
        type: 'slider',
        default: 10,
        modOption: "adaptive_compression_max",
        description: "Maximum compression factor for raptor waves (1-20).",
        min: 1,
        max: 20,
        step: 1
    },
    {
        label: "Vampire Mode",
        type: 'checkbox',
        default: true,
        modOption: "adaptive_vampire",
        description: "Raptors absorb health and XP from victims when compressed."
    },
    {
        label: "Boss Tint",
        type: 'checkbox',
        default: true,
        modOption: "adaptive_boss_tint",
        description: "Tint compressed 'boss' units red."
    },
    {
        label: "Debug Mode",
        type: 'checkbox',
        default: false,
        modOption: "debug_mode",
        description: "Show debug labels on units."
    }
];
