export const mockUnitDefs = {
    armcom: {
        name: 'armcom',
        health: 1000,
        metalCost: 1000,
        energyCost: 1000,
        buildTime: 1000,
        mass: 1000,
        energyMake: 10,
        metalMake: 10,
        windGenerator: 0,
        buildoptions: [],
        customParams: {
            subfolder: 'other/arm'
        }
    },
    raptor_queen_v1: {
        name: 'raptor_queen_v1',
        health: 50000,
        metalCost: 5000,
        energyCost: 5000,
        buildTime: 5000,
        mass: 5000,
        energyMake: 0,
        metalMake: 0,
        windGenerator: 0,
        customParams: {}
    },
    raptor_land_swarmer_heal: {
        name: 'raptor_land_swarmer_heal',
        health: 200,
        metalCost: 100,
        energyCost: 100,
        buildTime: 100,
        mass: 100,
        energyMake: 0,
        metalMake: 0,
        windGenerator: 0,
        buildSpeed: 10,
        customParams: {
            subfolder: 'other/raptors'
        }
    },
    scavengerbossv4: {
        name: 'scavengerbossv4',
        health: 100000,
        metalCost: 10000,
        energyCost: 10000,
        buildTime: 10000,
        mass: 10000,
        customParams: {}
    },
    some_scav: {
        name: 'some_scav',
        health: 500,
        metalCost: 50,
        energyCost: 50,
        buildTime: 50,
        mass: 50,
        category: 'UNIT',
        customParams: {}
    },
    // T3 Builders
    armconst3: {
        name: 'armconst3',
        maxThisUnit: 9999,
        customParams: {}
    },
    corconst3: {
        name: 'corconst3',
        maxThisUnit: 9999,
        customParams: {}
    },
    legconst3: {
        name: 'legconst3',
        maxThisUnit: 9999,
        customParams: {}
    },
    // Unit Launchers
    armavp: {
        name: 'armavp',
        buildoptions: [],
        customParams: {}
    },
    armmeatball: {
        name: 'armmeatball',
        maxThisUnit: 9999,
        customParams: {}
    },
    corclogger: {
        name: 'corclogger',
        maxThisUnit: 9999,
        customParams: {}
    },
    // Eco / Fusion
    armsolar: {
        name: "armsolar",
        health: 500,
        metalCost: 150,
        energyCost: 1000,
        buildTime: 2000,
        energyMake: 20,
        metalMake: 0,
        windGenerator: 0,
        mass: 200,
        footprintX: 3,
        footprintZ: 3,
        weapondefs: {
           laser: { damage: { default: 100 }, areaOfEffect: 10 }
        },
        customParams: {}
    },
    // Compressed Units Base
    raptor_land_swarmer_basic_t1_v1: {
        name: "raptor_land_swarmer_basic_t1_v1",
        health: 100,
        metalCost: 50,
        energyCost: 500,
        buildTime: 1000,
        mass: 100,
        energyMake: 0,
        metalMake: 0,
        windGenerator: 0,
        footprintX: 2,
        footprintZ: 2,
        weapondefs: {
           bite: { damage: { default: 10 }, areaOfEffect: 10 }
        },
        customParams: {}
    },
    ragnarok: {
        name: "ragnarok",
        maxThisUnit: 999,
        customParams: {}
    },
    // Missing Units for Mini Bosses / Experimental Waves
    raptor_hive_assault_basic: {
        name: "raptor_hive_assault_basic",
        health: 2000,
        metalCost: 1000,
        energyCost: 1000,
        buildTime: 1000,
        mass: 1000,
        energyMake: 0,
        metalMake: 0,
        windGenerator: 0,
        footprintX: 2,
        footprintZ: 2,
        customParams: {}
    },
    raptor_hive_swarmer_basic: {
        name: "raptor_hive_swarmer_basic",
        health: 500,
        metalCost: 200,
        energyCost: 200,
        buildTime: 200,
        mass: 200,
        energyMake: 0,
        metalMake: 0,
        windGenerator: 0,
        footprintX: 2,
        footprintZ: 2,
        customParams: {}
    },
    raptor_consort: {
        name: "raptor_consort",
        health: 10000,
        metalCost: 5000,
        energyCost: 5000,
        buildTime: 5000,
        mass: 5000,
        customParams: {},
        weapondefs: {
            goo: { damage: { default: 100 } }
        }
    },
    raptor_queen_epic: {
        name: "raptor_queen_epic",
        health: 1250000,
        metalCost: 50000,
        energyCost: 50000,
        buildTime: 50000,
        mass: 50000,
        customParams: {},
        weapondefs: {
            goo: { damage: { default: 500 } }
        }
    },
    raptor_matriarch_acid: {
        name: "raptor_matriarch_acid",
        health: 30000,
        metalCost: 30000,
        energyCost: 30000,
        buildTime: 30000,
        mass: 30000,
        customParams: {},
        weapondefs: {
            acidgoo: { damage: { default: 200 } }
        }
    },
    raptor_matriarch_electric: {
        name: "raptor_matriarch_electric",
        health: 30000,
        metalCost: 30000,
        energyCost: 30000,
        buildTime: 30000,
        mass: 30000,
        customParams: {},
        weapondefs: {
            goo: { damage: { default: 200 } }
        }
    },
    raptor_matriarch_basic: {
        name: "raptor_matriarch_basic",
        health: 60000,
        metalCost: 60000,
        energyCost: 60000,
        buildTime: 60000,
        mass: 60000,
        customParams: {}
    }
};

export function getMockUnitDefsLua(): string {
    const toLua = (obj: any): string => {
        if (typeof obj === 'string') return `"${obj}"`;
        if (typeof obj === 'number') return obj.toString();
        if (Array.isArray(obj)) return `{ ${obj.map(toLua).join(', ')} }`;
        if (typeof obj === 'object') {
            const props = Object.entries(obj).map(([k, v]) => `${k} = ${toLua(v)}`).join(', ');
            return `{ ${props} }`;
        }
        return 'nil';
    };

    const defs = Object.entries(mockUnitDefs).map(([k, v]) => `${k} = ${toLua(v)}`).join(',\n');
    return `UnitDefs = {\n${defs}\n}`;
}
