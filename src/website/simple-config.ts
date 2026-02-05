export interface ConfigOption {
    label: string;
    type: 'checkbox';
    default: boolean;
    modOption: string;
    description: string;
}

export const simpleConfig: ConfigOption[] = [
    {
        label: 'Main Gameplay Tweaks (Defs)',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_main_defs',
        description: 'Core gameplay tweaks and improvements (definitions).'
    },
    {
        label: 'Main Gameplay Tweaks (Units)',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_main_units',
        description: 'Core gameplay tweaks and improvements (units).'
    },
    {
        label: 'Cross Faction T2 Units',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_cross_faction_t2',
        description: 'Enables cross-faction T2 units (70% taxed versions).'
    },
    {
        label: 'T3 Economy',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_t3_eco',
        description: 'Tier 3 economy structures and upgrades.'
    },
    {
        label: 'T3 Builders',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_t3_builders',
        description: 'Tier 3 construction units and taxed factories.'
    },
    {
        label: 'T4 Economy',
        type: 'checkbox',
        default: false,
        modOption: 'nuttyb_t4_eco',
        description: 'T4 cold energy converters and fusion reactors (Safe).'
    },
    {
        label: 'T4 Defenses',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_t4_defenses',
        description: 'Experimental tier 4 defensive buildings (Pulsar, Bulwark, Bastion).'
    },
    {
        label: 'T4 Air Rework',
        type: 'checkbox',
        default: false,
        modOption: 'nuttyb_t4_air',
        description: 'Reworked tier 4 aircraft.'
    },
    {
        label: 'T4 Epics',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_t4_epics',
        description: 'Massive legendary units for each faction.'
    },
    {
        label: 'Unit Launchers',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_unit_launchers',
        description: 'Buildings that launch units (Meatball, Assimilator, etc.).'
    },
    {
        label: 'LRPC Rebalance v2',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_lrpc_v2',
        description: 'Rebalanced long-range plasma cannons.'
    },
    {
        label: 'Mega Nuke',
        type: 'checkbox',
        default: false,
        modOption: 'meganuke',
        description: 'Enables the Mega Nuke weapon (Atomic Blast on high-tier fusion destruction).'
    },
    {
        label: 'Evolving Commander (Armada)',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_evo_com_arm',
        description: 'Enable evolving commander for Armada.'
    },
    {
        label: 'Evolving Commander (Cortex)',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_evo_com_cor',
        description: 'Enable evolving commander for Cortex.'
    },
    {
        label: 'Evolving Commander (Legion)',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_evo_com_leg',
        description: 'Enable evolving commander for Legion.'
    },
    {
        label: 'Evo XP (Auto)',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_evo_xp',
        description: 'Evo XP Logic (Required for Evolving Commanders).'
    },
    {
        label: 'Wave Mode: Mini Bosses',
        type: 'checkbox',
        default: true,
        modOption: 'nuttyb_wave_mode_mini',
        description: 'Enable Mini Bosses wave mode.'
    },
    {
        label: 'Wave Mode: Experimental',
        type: 'checkbox',
        default: false,
        modOption: 'nuttyb_wave_mode_exp',
        description: 'Enable Experimental Wave Challenge mode.'
    }
];
