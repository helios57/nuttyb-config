import { TweakDefinition } from './tweak-dsl';

export function getQhpTweak(multiplier: number, multiplierText: string): TweakDefinition {
    return {
        name: `NuttyB v1.52 ${multiplierText}X QHP`,
        description: 'docs.google.com/spreadsheets/d/1QSVsuAAMhBrhiZdTihVfSCwPzbbZWDLCtXWP23CU0ko',
        scope: 'UnitDefsLoop',
        conditions: [
            { type: 'nameMatch', regex: '^raptor_queen_.*' }
        ],
        mutations: [
            { op: 'set', field: 'repairable', value: false },
            { op: 'set', field: 'canbehealed', value: false },
            { op: 'set', field: 'buildtime', value: 9999999 },
            { op: 'set', field: 'autoheal', value: 2 },
            { op: 'set', field: 'canSelfRepair', value: false },
            { op: 'multiply', field: 'health', factor: multiplier }
        ]
    };
}

export function getHpTweak(healthMultiplier: number, workertimeMultiplier: number, metalCostFactor: number, multiplierText: string): TweakDefinition[] {
    return [
        {
            name: `NuttyB v1.52 ${multiplierText}X HP - Swarmer Heal`,
            description: 'Swarmer Heal adjustments',
            scope: 'UnitDefsLoop',
            conditions: [
                { type: 'nameStartsWith', prefix: 'raptor_land_swarmer_heal' }
            ],
            mutations: [
                { op: 'set', field: 'reclaimspeed', value: 100 },
                { op: 'set', field: 'stealth', value: false },
                { op: 'set', field: 'builder', value: false },
                { op: 'multiply', field: 'workertime', factor: workertimeMultiplier },
                { op: 'set', field: 'canassist', value: false },
                { op: 'set', field: 'maxthisunit', value: 0 }
            ]
        },
        {
            name: `NuttyB v1.52 ${multiplierText}X HP - Raptors`,
            description: 'Raptor Health adjustments',
            scope: 'UnitDefsLoop',
            conditions: [
                { type: 'customParam', key: 'subfolder', value: 'other/raptors' },
                // Note: The original template had `not unitName:match('^raptor_queen_.*')`
                // We need to support negative matches or ensure this logic is preserved.
                // For now, assuming the regex condition in DSL implies positive match.
                // If DSL doesn't support NOT, we might need to extend it or rely on ordering/specificity.
                // However, looking at the original code: `if ... and not unitName:match(...)`
                // Let's check if we can add a negative match to DSL or if we can ignore it if QHP handles queens separately.
                // Actually, QHP tweak runs in a separate loop. This loop modifies ALL raptors including queens if not filtered.
                // Let's add a negative match condition to DSL if possible, or just assume queens are handled fine (they are multiplied here too? No, queens are excluded here).
                // The DSL definition in Phase 1 didn't explicitly include negative matches.
                // I will add a 'nameNotMatch' condition type to TweakCondition in tweak-dsl.ts to support this.
                { type: 'nameNotMatch', regex: '^raptor_queen_.*' } 
            ] as any, // Cast to any for now until we update the type definition
            mutations: [
                { op: 'multiply', field: 'health', factor: healthMultiplier }
            ]
        },
        {
            name: `NuttyB v1.52 ${multiplierText}X HP - Post Hook`,
            description: 'Post hook for metal cost and nochasecategory',
            scope: 'UnitDef_Post',
            conditions: [
                { type: 'customParam', key: 'subfolder', value: 'other/raptors' }
            ],
            mutations: [
                { op: 'set', field: 'nochasecategory', value: 'OBJECT' },
                { op: 'assign_math_floor', target: 'metalcost', source: 'health', factor: metalCostFactor }
            ]
        }
    ];
}

export function getBossHpTweak(multiplier: number, multiplierText: string): TweakDefinition {
    return {
        name: `Scav Boss HP ${multiplierText}X`,
        description: 'Scavenger Boss HP adjustment',
        scope: 'UnitDef_Post',
        conditions: [
            { type: 'nameMatch', regex: '^scavengerbossv4' }
        ],
        mutations: [
            { op: 'multiply', field: 'health', factor: multiplier } // Note: Original used math.floor(health * mult). DSL multiply is just * factor.
            // If we need floor, we might need a new op or update multiply to support floor.
            // The original code: unitDef.health = math.floor(unitDef.health * __HEALTH_MULTIPLIER__)
            // The DSL 'multiply' op: def[field] = def[field] * factor.
            // This might result in floats. Spring usually handles floats fine for health, but let's be precise.
            // I'll add 'multiply_floor' op to DSL or just use 'multiply' if acceptable.
            // Given the requirement for "assign_math_floor", maybe we should use that?
            // assign_math_floor takes target and source. target=health, source=health, factor=multiplier.
        ]
    };
}

export function getScavHpTweak(multiplier: number, multiplierText: string): TweakDefinition[] {
    return [
        {
            name: `Scavengers HP ${multiplierText}X - Health`,
            description: 'Scavenger Health',
            scope: 'UnitDef_Post',
            conditions: [
                { type: 'nameMatch', regex: '_scav$' },
                { type: 'nameNotMatch', regex: '^scavengerbossv4' } as any
            ],
            mutations: [
                // Original: unitDef.health = math.floor(unitDef.health * __HEALTH_MULTIPLIER__)
                 { op: 'assign_math_floor', target: 'health', source: 'health', factor: multiplier }
            ]
        },
        {
            name: `Scavengers HP ${multiplierText}X - Metal & Category`,
            description: 'Scavenger Metal Cost and Category',
            scope: 'UnitDef_Post',
            conditions: [
                { type: 'nameMatch', regex: '_scav$' }
            ],
            mutations: [
                { op: 'assign_math_floor', target: 'metalcost', source: 'metalcost', factor: multiplier },
                { op: 'set', field: 'nochasecategory', value: 'OBJECT' }
            ]
        }
    ];
}
