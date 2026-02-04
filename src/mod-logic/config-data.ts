import { GameConfigs, FormOptionsConfig } from './types';

export const gameConfigs: GameConfigs = {
    maps: [
        {
            name: 'Full Metal Plate (12P)',
            commands: ['!map Full Metal Plate', '!addbox 82 82 117 117 2', '!clearbox 1']
        },
        {
            name: 'Raptor Crater (16P)',
            commands: ['!map Raptor Crater', '!addbox 84 81 119 116 2', '!clearbox 1', '!teamsize 16']
        },
        {
            name: 'Raptor Crater Inverted (16P)',
            commands: ['!map Raptor Crater', '!disablemapdamage 0', '!debugcommands invertmap', '!addbox 84 81 119 116 2', '!clearbox 1', '!teamsize 16']
        },
        {
            name: 'Special Hotstepper (16P)',
            commands: ['!map Special Hotstepper', '!addbox 83 81 118 116 2', '!clearbox 1', '!map_lavatiderhythm disabled', '!teamsize 16']
        },
        {
            name: 'To Kill The Middle (12P)',
            commands: ['!map To Kill The Middle', '!addbox 82 82 117 117 2', '!clearbox 1', '!teamsize 12']
        },
        {
            name: 'Ancient Bastion Remake (8P)',
            commands: ['!map Ancient Bastion Remake', '!addbox 0 0 100 200 1', '!addbox 175 0 200 200 2', '!teamsize 8']
        },
        {
            name: 'Ancient Vault (12P)',
            commands: ['!map Ancient Vault', '!addbox 0 0 200 120 1', '!addbox 0 180 200 200 2', '!teamsize 12']
        },
        {
            name: 'Bismuth Valley (8P)',
            commands: ['!map Bismuth Valley', '!addbox 0 0 64 200 1', '!addbox 175 0 200 200 2', '!teamsize 8']
        },
        {
            name: 'Darkside (12P)',
            commands: ['!map Darkside', '!addbox 0 0 64 200 1', '!addbox 175 0 200 200 2', '!teamsize 12']
        },
        {
            name: 'Flats and Forests (12P)',
            commands: ['!map Flats and Forests', '!addbox 0 0 64 200 1', '!addbox 175 0 200 200 2', '!teamsize 12']
        },
        {
            name: 'Special Creek (12P)',
            commands: ['!map Special Creek', '!addbox 158 0 200 200 2', '!teamsize 12']
        },
        {
            name: 'Starwatcher (8P)',
            commands: ['!map Starwatcher', '!addbox 0 0 64 200 1', '!addbox 175 0 200 200 2', '!teamsize 8']
        }
    ],
    modes: [
        {
            name: 'No Rush',
            commands: ['!raptor_queentimemult 1.3', '!raptor_spawncountmult 3', '!raptor_firstwavesboost 6', '!raptor_graceperiodmult 3']
        },
        {
            name: 'No Rush Solo',
            commands: ['!raptor_queentimemult 1.3', '!raptor_spawncountmult 3', '!raptor_firstwavesboost 3', '!raptor_graceperiodmult 2.7']
        },
        {
            name: 'Zero Grace',
            commands: ['!raptor_queentimemult 1.4', '!raptor_spawncountmult 3', '!raptor_firstwavesboost 3', '!raptor_graceperiodmult 0.1']
        },
        {
            name: 'Surrounded',
            commands: ['!raptor_queentimemult 1.3', '!raptor_spawncountmult 3', '!raptor_firstwavesboost 6', '!raptor_graceperiodmult 3', '!addbox 60 60 140 140 1', '!raptor_raptorstart avoid', '!clearbox 2']
        }
    ],
    base: [
        '!preset coop',
        '!teamsize 12',
        '!autobalance off',
        '!assistdronesbuildpowermultiplier 1',
        '!assistdronesenabled enabled',
        '!commanderbuildersbuildpower 1000',
        '!commanderbuildersenabled enabled',
        '!commanderbuildersrange 1000',
        '!disablemapdamage 1',
        '!experimentalextraunits 1',
        '!experimentallegionfaction 1',
        '!experimentalshields bounceeverything',
        '!maxunits 10000',
        '!multiplier_builddistance 1.5',
        '!multiplier_buildpower 1',
        '!multiplier_buildtimecost 1',
        '!multiplier_energyconversion 1',
        '!multiplier_energycost 1',
        '!multiplier_energyproduction 1',
        '!multiplier_losrange 1',
        '!multiplier_maxdamage 1',
        '!multiplier_maxvelocity 1',
        '!multiplier_metalcost 1',
        '!multiplier_metalextraction 1',
        '!multiplier_radarrange 1',
        '!multiplier_resourceincome 1',
        '!multiplier_shieldpower 2',
        '!multiplier_turnrate 1',
        '!multiplier_weapondamage 1',
        '!multiplier_weaponrange 1',
        '!raptor_difficulty epic',
        '!raptor_spawntimemult 1',
        '!releasecandidates 1',
        '!startenergy 10000',
        '!startenergystorage 10000',
        '!startmetal 10000',
        '!startmetalstorage 10000',
        '!scavunitsforplayers 1',
        '!forceallunits 1',
        '!unit_restrictions_noair 0',
        '!unit_restrictions_noendgamelrpc 0',
        '!unit_restrictions_noextractors 1',
        '!unit_restrictions_nolrpc 0',
        '!unit_restrictions_nonukes 0',
        '!draft_mode disabled',
        '!unit_restrictions_notacnukes 0',
        '$welcome-message Settings made with NuttyB Configurator https://rcorex.github.io/nuttyb-config/',
        '!unit_market 0',
        '!evocom 0',
        '!nowasting all',
        '!bSet unit_restrictions_nonukes 1',
        '!bSet raptor_queen_count 8',
        '!balance'
    ],
    scavengers: [
        '!scav_boss_count 8',
        '!scav_bosstimemult 1.3',
        '!scav_difficulty epic',
        '!scav_spawncountmult 2',
        '!bSet ruins disabled',
        '!shieldsrework 1',
        '!unit_restrictions_noextractors 0'
    ]
};

export const formOptionsConfig: FormOptionsConfig[] = [
    { label: 'NuttyB Main Tweaks', type: 'checkbox', column: 'left', default: true, commandBlocks: [] },
    { label: 'NuttyB Evolving Commanders', type: 'checkbox', column: 'left', default: false, commandBlocks: ['!evocom 1'] },
    {
        label: "Optimization & Scaling",
        type: "header",
        column: "left"
    },
    { label: 'Enable Singularity Fusion', type: 'checkbox', column: 'left', default: false, modOption: 'fusion_mode', commandBlocks: [] },
    { label: "Fusion - Min Tier", type: "numeric-tweak", column: "left", defaultValue: "1", min: 1, step: 1, modOption: "fusion_mintier" },
    { label: "Fusion Efficiency Bonus", type: "numeric-tweak", column: "left", defaultValue: "1.10", min: 1.0, step: 0.05, modOption: "fusion_efficiency" },
    { label: 'Enable Adaptive Spawner', type: 'checkbox', column: 'left', default: false, modOption: 'adaptive_spawner', commandBlocks: [] },
    { label: "Max Compression Factor", type: "numeric-tweak", column: "left", defaultValue: "10", min: 1, max: 10, step: 1, modOption: "adaptive_compression_max" },
    { label: 'Enable Vampire Merge', type: 'checkbox', column: 'left', default: false, modOption: 'adaptive_vampire', commandBlocks: [] },
    { label: 'Enable Boss Tint', type: 'checkbox', column: 'left', default: false, modOption: 'adaptive_boss_tint', commandBlocks: [] },
    { label: 'Enable Auto-Culling', type: 'checkbox', column: 'left', default: false, modOption: 'cull_enabled', commandBlocks: [] },
    { label: "Culling - Min SimSpeed", type: "numeric-tweak", column: "left", defaultValue: "0.9", min: 0.1, step: 0.1, modOption: "cull_simspeed" },
    { label: "Culling - Max Units", type: "numeric-tweak", column: "left", defaultValue: "5000", min: 100, step: 100, modOption: "cull_maxunits" },
    { label: "Safe Zone Radius", type: "numeric-tweak", column: "left", defaultValue: "2000", min: 500, step: 100, modOption: "cull_radius" },
    {
        label: "Mechanics & Balance",
        type: "checkbox",
        column: "left",
        default: true,
        commandBlocks: []
    },
    // Mechanics & Balance Checkboxes
    { label: 'Cross Faction T2', type: 'checkbox', column: 'left', default: false, commandBlocks: [] },
    { label: 'T3 Eco', type: 'checkbox', column: 'left', default: false, commandBlocks: [] },
    { label: 'T3 Builders', type: 'checkbox', column: 'left', default: false, commandBlocks: [] },
    { label: 'Unit Launchers', type: 'checkbox', column: 'left', default: false, commandBlocks: [], tweakTemplateId: "tweak_enable_unit_launchers" },
    { label: 'LRPC Rebalance v2', type: 'checkbox', column: 'left', default: false, commandBlocks: [] },
    { label: 'T4 Defences Test', type: 'checkbox', column: 'left', default: false, commandBlocks: [] },
    { label: 'T4 Air Rework', type: 'checkbox', column: 'left', default: false, commandBlocks: [] },
    { label: 'Mega Nuke', type: 'checkbox', column: 'left', default: false, commandBlocks: [] },

    // Raptor & Queen Health
    {
        label: "Raptor Health",
        type: "select",
        isHpGenerator: true,
        hpType: 'hp',
        column: 'left',
        slot: '',
        slotType: 'tweakdefs',
        defaultValue: "1.3",
        choices: [
            { label: "Default", value: "", shortLabel: "" },
            { label: "1x HP", value: "1", shortLabel: "1x HP" },
            { label: "1.3x HP", value: "1.3", shortLabel: "1_3x HP" },
            { label: "1.5x HP", value: "1.5", shortLabel: "1_5x HP" },
            { label: "1.7x HP", value: "1.7", shortLabel: "1_7x HP" },
            { label: "2x HP", value: "2", shortLabel: "2x HP" },
            { label: "2.5x HP", value: "2.5", shortLabel: "2_5x HP" },
            { label: "3x HP", value: "3", shortLabel: "3x HP" },
            { label: "4x HP", value: "4", shortLabel: "4x HP" },
            { label: "5x HP", value: "5", shortLabel: "5x HP" }
        ]
    },
    {
        label: "Queen Health",
        type: "select",
        isHpGenerator: true,
        hpType: 'qhp',
        column: 'left',
        slot: 1,
        slotType: 'tweakdefs',
        defaultValue: "1.3",
        choices: [
            { label: "Default", value: "", shortLabel: "" },
            { label: "1x QHP", value: "1", shortLabel: "1x QHP" },
            { label: "1.3x QHP", value: "1.3", shortLabel: "1_3x QHP" },
            { label: "1.5x QHP", value: "1.5", shortLabel: "1_5x QHP" },
            { label: "1.7x QHP", value: "1.7", shortLabel: "1_7x QHP" },
            { label: "2x QHP", value: "2", shortLabel: "2x QHP" },
            { label: "2.5x QHP", value: "2.5", shortLabel: "2_5x QHP" },
            { label: "3x QHP", value: "3", shortLabel: "3x QHP" },
            { label: "4x QHP", value: "4", shortLabel: "4x QHP" },
            { label: "5x QHP", value: "5", shortLabel: "5x QHP" }
        ]
    },

    // Limit Max Allowed
    { label: "Limit Max Allowed", type: "header", column: "left" },
    {
        label: "T3 Builders", type: "numeric-tweak", column: "left",
        defaultValue: "10", min: 0, unitLabel: "max/unit",
        tweakTemplateId: "tweak_limit_t3builders", tweakVar: "limit"
    },
    {
        label: "Unit Launchers", type: "numeric-tweak", column: "left",
        defaultValue: "20", min: 0, unitLabel: "max/unit",
        tweakTemplateId: "tweak_limit_unit_launchers", tweakVar: "limit"
    },
    {
        label: "Epic Ragnarok", type: "numeric-tweak", column: "left",
        defaultValue: "80", min: 0, unitLabel: "max/unit",
        tweakTemplateId: "tweak_limit_epic_ragnarok", tweakVar: "limit"
    },
    {
        label: "Epic Calamity", type: "numeric-tweak", column: "left",
        defaultValue: "80", min: 0, unitLabel: "max/unit",
        tweakTemplateId: "tweak_limit_epic_calamity", tweakVar: "limit"
    },
    {
        label: "Epic Tyrannus", type: "numeric-tweak", column: "left",
        defaultValue: "80", min: 0, unitLabel: "max/unit",
        tweakTemplateId: "tweak_limit_epic_tyrannus", tweakVar: "limit"
    },
    {
        label: "Epic Starfall", type: "numeric-tweak", column: "left",
        defaultValue: "80", min: 0, unitLabel: "max/unit",
        tweakTemplateId: "tweak_limit_epic_starfall", tweakVar: "limit"
    },

    // Game Multipliers
    { label: "Game Multipliers", type: "header", column: "left" },
    { label: "Resource Income", type: "numeric-tweak", column: "left", defaultValue: "1", min: 0, step: 0.1, modOption: "multiplier_resourceincome" },
    { label: "Shield Power", type: "numeric-tweak", column: "left", defaultValue: "2", min: 0, step: 0.1, modOption: "multiplier_shieldpower" },
    { label: "Build Range", type: "numeric-tweak", column: "left", defaultValue: "1.5", min: 0, step: 0.1, modOption: "multiplier_builddistance" },
    { label: "Build Power", type: "numeric-tweak", column: "left", defaultValue: "1", min: 0, step: 0.1, modOption: "multiplier_buildpower" },

    // Raptor Settings
    { label: "Raptor Settings", type: "header", column: "left" },
    { label: "Queen Quantity", type: "numeric-tweak", column: "left", defaultValue: "8", min: 0, step: 1, modOption: "raptor_queen_count" },
    { label: "Wave Multiplier", type: "numeric-tweak", column: "left", defaultValue: "1", min: 0, step: 0.1, modOption: "raptor_spawncountmult" },
    { label: "First Waves Boost", type: "numeric-tweak", column: "left", defaultValue: "0", min: 0, step: 1, modOption: "raptor_firstwavesboost" },
    { label: "Grace Period Multiplier", type: "numeric-tweak", column: "left", defaultValue: "1", min: 0, step: 0.1, modOption: "raptor_graceperiodmult" }
];
