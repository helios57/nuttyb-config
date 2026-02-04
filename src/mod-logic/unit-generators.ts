import { TweakDefinition, MutationOperation } from './tweak-dsl';

const FUSION_TIERS = [
    { tier: 2, hpMult: 16.0, outputMult: 4.2, costMult: 4.0, prevSuffix: '' },
    { tier: 3, hpMult: 16.0, outputMult: 4.2, costMult: 4.0, prevSuffix: '_t2' },
    { tier: 4, hpMult: 16.0, outputMult: 4.2, costMult: 4.0, prevSuffix: '_t3' },
    { tier: 5, hpMult: 16.0, outputMult: 4.2, costMult: 4.0, prevSuffix: '_t4' }
];

const BASE_BUILDINGS = [
    { name: 'armsolar', label: 'Solar Collector' },
    { name: 'corsolar', label: 'Solar Collector' },
    { name: 'armwin', label: 'Wind Generator' },
    { name: 'corwin', label: 'Wind Generator' },
    { name: 'armmakr', label: 'Metal Maker' },
    { name: 'cormakr', label: 'Metal Maker' },
    { name: 'armllt', label: 'Light Laser Tower' },
    { name: 'corllt', label: 'Light Laser Tower' }
];

const COMPRESSION_VARIANTS = [
    { suffix: '_compressed_x2', mult: 2, label: 'x2' },
    { suffix: '_compressed_x5', mult: 5, label: 'x5' },
    { suffix: '_compressed_x10', mult: 10, label: 'x10' }
];

// List of raptors to create variants for
const BASE_RAPTORS = [
    'raptor_land_swarmer_basic_t1_v1',
    'raptor_land_assault_basic_t2_v1',
    'raptor_air_fighter_basic',
    'raptor_hive_swarmer_basic',
    'raptor_hive_assault_basic'
];

export function generateFusionUnits(): TweakDefinition[] {
    const tweaks: TweakDefinition[] = [];

    for (const unit of BASE_BUILDINGS) {
        for (const tierData of FUSION_TIERS) {
            const sourceName = tierData.tier === 2 ? unit.name : `${unit.name}${tierData.prevSuffix}`;
            const targetName = `${unit.name}_t${tierData.tier}`;

            const mutations: MutationOperation[] = [
                { op: 'multiply', field: 'health', factor: tierData.hpMult },
                { op: 'multiply', field: 'metalCost', factor: tierData.costMult },
                { op: 'multiply', field: 'energyCost', factor: tierData.costMult },
                { op: 'multiply', field: 'buildTime', factor: tierData.costMult },

                // Scale Output/Input
                { op: 'multiply', field: 'energyMake', factor: tierData.outputMult },
                { op: 'multiply', field: 'metalMake', factor: tierData.outputMult },
                { op: 'multiply', field: 'windGenerator', factor: tierData.outputMult },

                // Scale Weapon Damage (for Turrets)
                {
                    op: 'modify_weapon',
                    weaponName: '*',
                    mutations: [
                        { op: 'multiply', field: 'damage.default', factor: tierData.outputMult }
                    ]
                },

                // Scale Footprint and Model
                { op: 'multiply', field: 'footprintX', factor: 1.5 },
                { op: 'multiply', field: 'footprintZ', factor: 1.5 },

                { op: 'set', field: 'name', value: `${unit.label} T${tierData.tier}` },
                {
                    op: 'table_merge',
                    field: 'customParams',
                    value: {
                        is_fusion_unit: true,
                        fusion_tier: tierData.tier,
                        model_scale: 1.5
                    }
                }
            ];

            tweaks.push({
                name: `Generate ${targetName}`,
                description: `Generates T${tierData.tier} variant of ${unit.name}`,
                scope: 'Global',
                conditions: [],
                mutations: [
                    {
                        op: 'clone_unit',
                        source: sourceName,
                        target: targetName,
                        mutations: mutations
                    }
                ]
            });
        }
    }

    return tweaks;
}

export function generateCompressedUnits(): TweakDefinition[] {
    const tweaks: TweakDefinition[] = [];

    // Combine Raptors and Buildings for compression
    // Note: Buildings in BASE_BUILDINGS are objects {name, label}, Raptors are strings
    const targets = [
        ...BASE_RAPTORS.map(name => ({ name, label: name })), // Use name as label for raptors if not localized
        ...BASE_BUILDINGS // Eco structures
    ];

    for (const unit of targets) {
        for (const variant of COMPRESSION_VARIANTS) {
            const targetName = `${unit.name}${variant.suffix}`;
            const modelScale = variant.mult >= 5 ? 1.5 : 1.2;

            const mutations: MutationOperation[] = [
                { op: 'multiply', field: 'health', factor: variant.mult },
                { op: 'multiply', field: 'metalCost', factor: variant.mult },
                { op: 'multiply', field: 'energyCost', factor: variant.mult },
                { op: 'multiply', field: 'buildTime', factor: variant.mult },
                { op: 'multiply', field: 'mass', factor: variant.mult },

                // Scale Eco
                { op: 'multiply', field: 'energyMake', factor: variant.mult },
                { op: 'multiply', field: 'metalMake', factor: variant.mult },
                { op: 'multiply', field: 'windGenerator', factor: variant.mult },

                // Scale Weapons
                {
                    op: 'modify_weapon',
                    weaponName: '*',
                    mutations: [
                        { op: 'multiply', field: 'damage.default', factor: variant.mult },
                        // Scale Area of Effect by sqrt of factor (approximate area scaling)
                        // Need to verify if we can use math expression here?
                        // Tweak DSL supports 'multiply' with factor. Factor must be number or variable.
                        // Can we use expression? No, 'factor' is number.
                        // So we pre-calculate it.
                        { op: 'multiply', field: 'areaOfEffect', factor: Math.sqrt(variant.mult) }
                    ]
                },

                // Visual distinction
                { op: 'set', field: 'name', value: `${unit.label} ${variant.label}` },
                {
                    op: 'table_merge',
                    field: 'customParams',
                    value: {
                         is_compressed_unit: true,
                         compression_factor: variant.mult,
                         model_scale: modelScale,
                         color_tint: "1 0.5 0.5" // Reddish tint
                    }
                }
            ];

            // Footprint scaling for large compression
            if (variant.mult >= 5) {
                 mutations.push({ op: 'multiply', field: 'footprintX', factor: 1.5 });
                 mutations.push({ op: 'multiply', field: 'footprintZ', factor: 1.5 });
            }

            tweaks.push({
                name: `Generate ${targetName}`,
                description: `Generates ${variant.label} compressed variant of ${unit.name}`,
                scope: 'Global',
                conditions: [],
                mutations: [
                    {
                        op: 'clone_unit',
                        source: unit.name,
                        target: targetName,
                        mutations: mutations
                    }
                ]
            });
        }
    }

    return tweaks;
}

// Deprecated alias for backward compatibility if needed, but we will update call sites.
export const generateMegaRaptors = generateCompressedUnits;
