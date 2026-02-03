import { TweakDefinition } from './tweak-dsl';

export function getQhpTweak(multiplier: number, multiplierText: string): TweakDefinition {
    return {
        name: `NuttyB v1.52 ${multiplierText}X QHP`,
        description: 'Queen Health & Repair Adjustments',
        scope: 'UnitDefsLoop',
        conditions: [
            { type: 'nameStartsWith', prefix: 'raptor_queen_' }
        ],
        mutations: [
            { op: 'set', field: 'repairable', value: false },
            { op: 'set', field: 'canbehealed', value: false },
            { op: 'set', field: 'buildTime', value: 9999999 },
            { op: 'set', field: 'autoHeal', value: 2 },
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
                { op: 'set', field: 'reclaimSpeed', value: 100 },
                { op: 'set', field: 'stealth', value: false },
                { op: 'set', field: 'builder', value: false },
                { op: 'multiply', field: 'buildSpeed', factor: workertimeMultiplier },
                { op: 'set', field: 'canAssist', value: false },
                { op: 'set', field: 'maxThisUnit', value: 0 }
            ]
        },
        {
            name: `NuttyB v1.52 ${multiplierText}X HP - Raptors`,
            description: 'Raptor Health adjustments',
            scope: 'UnitDefsLoop',
            conditions: [
                { type: 'customParam', key: 'subfolder', value: 'other/raptors' },
                { type: 'nameNotMatch', regex: '^raptor_queen_.*' } 
            ],
            mutations: [
                { op: 'multiply', field: 'health', factor: healthMultiplier }
            ]
        },
        {
            name: `NuttyB v1.52 ${multiplierText}X HP - Metal & Chase`,
            description: 'Metal Cost and NoChase',
            scope: 'UnitDefsLoop',
            conditions: [
                { type: 'customParam', key: 'subfolder', value: 'other/raptors' }
            ],
            mutations: [
                { op: 'set', field: 'noChaseCategory', value: 'OBJECT' },
                { op: 'assign_math_floor', target: 'metalCost', source: 'health', factor: metalCostFactor }
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
            { type: 'nameStartsWith', prefix: 'scavengerbossv4' }
        ],
        mutations: [
            { op: 'multiply', field: 'health', factor: multiplier }
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
                { type: 'nameEndsWith', suffix: '_scav' },
                { type: 'nameNotMatch', regex: '^scavengerbossv4' }
            ],
            mutations: [
                 { op: 'assign_math_floor', target: 'health', source: 'health', factor: multiplier }
            ]
        },
        {
            name: `Scavengers HP ${multiplierText}X - Metal & Category`,
            description: 'Scavenger Metal Cost and Category',
            scope: 'UnitDef_Post',
            conditions: [
                { type: 'nameEndsWith', suffix: '_scav' }
            ],
            mutations: [
                { op: 'assign_math_floor', target: 'metalcost', source: 'metalcost', factor: multiplier },
                { op: 'set', field: 'nochasecategory', value: 'OBJECT' }
            ]
        }
    ];
}
