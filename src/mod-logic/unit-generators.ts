import { TweakDefinition, MutationOperation } from './tweak-dsl';

const FUSION_TIERS = [
    { tier: 2, hpMult: 4.4, outputMult: 4.2, costMult: 4.0, prevSuffix: '' },
    { tier: 3, hpMult: 4.4, outputMult: 4.2, costMult: 4.0, prevSuffix: '_t2' },
    { tier: 4, hpMult: 4.4, outputMult: 4.2, costMult: 4.0, prevSuffix: '_t3' },
    { tier: 5, hpMult: 4.4, outputMult: 4.2, costMult: 4.0, prevSuffix: '_t4' }
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

const MEGA_RAPTOR_VARIANTS = [
    { suffix: '_compressed_x2', mult: 2, label: 'x2' },
    { suffix: '_compressed_x5', mult: 5, label: 'x5' },
    { suffix: '_compressed_x10', mult: 10, label: 'x10' }
];

// List of raptors to create variants for
const BASE_RAPTORS = [
    'raptor_land_swarmer_basic_t1_v1',
    'raptor_land_assault_basic_t2_v1',
    'raptor_air_fighter_basic',
    'raptor_hive_swarmer_basic', // From master_config
    'raptor_hive_assault_basic'  // From master_config
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
                { op: 'multiply', field: 'buildTime', factor: tierData.costMult }, // Scale buildtime too? Usually yes.

                // Scale Output/Input
                { op: 'multiply', field: 'energyMake', factor: tierData.outputMult },
                { op: 'multiply', field: 'metalMake', factor: tierData.outputMult },
                // Wind specific
                { op: 'multiply', field: 'windGenerator', factor: tierData.outputMult },

                // Scale Weapon Damage (for Turrets)
                {
                    op: 'modify_weapon',
                    weaponName: '*',
                    mutations: [
                        { op: 'multiply', field: 'damage.default', factor: tierData.outputMult } // Using output mult for damage? Or cost mult? Plan doesn't specify dmg scaling for buildings.
                        // Assuming 4x effectiveness, so maybe outputMult (4.2) or just 4.
                        // Plan says: "HP to 4 * PreviousTier * 1.1... Output to 4 * PreviousTier * 1.05".
                        // Turrets "Output" implies Damage.
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

export function generateMegaRaptors(): TweakDefinition[] {
    const tweaks: TweakDefinition[] = [];

    for (const raptor of BASE_RAPTORS) {
        for (const variant of MEGA_RAPTOR_VARIANTS) {
            const targetName = `${raptor}${variant.suffix}`;

            const mutations: MutationOperation[] = [
                { op: 'multiply', field: 'health', factor: variant.mult },
                { op: 'multiply', field: 'metalCost', factor: variant.mult }, // Value for kill?
                { op: 'multiply', field: 'mass', factor: variant.mult },

                // Damage scaling
                {
                    op: 'modify_weapon',
                    weaponName: '*',
                    mutations: [
                        { op: 'multiply', field: 'damage.default', factor: variant.mult }
                    ]
                },

                // Visual distinction
                {
                    op: 'table_merge',
                    field: 'customParams',
                    value: {
                         // Red tint for compressed units? Or just a param for the gadget to read?
                         // "Visuals: Add a red color tint or CEG"
                         // We can try setting RGB color if supported, usually 'rgbcolor' field on unitdef.
                         // But for now let's just mark it.
                         is_compressed_unit: true,
                         compression_factor: variant.mult
                    }
                }
            ];

            // If it's a very high compression, maybe increase size slightly?
            if (variant.mult >= 5) {
                 mutations.push({ op: 'multiply', field: 'footprintX', factor: 1.5 });
                 mutations.push({ op: 'multiply', field: 'footprintZ', factor: 1.5 });
            }

            tweaks.push({
                name: `Generate ${targetName}`,
                description: `Generates ${variant.label} compressed variant of ${raptor}`,
                scope: 'Global',
                conditions: [],
                mutations: [
                    {
                        op: 'clone_unit',
                        source: raptor,
                        target: targetName,
                        mutations: mutations
                    }
                ]
            });
        }
    }

    return tweaks;
}
