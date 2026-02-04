export const mockUnitDefs = {
    armcom: {
        name: 'armcom',
        health: 1000,
        metalCost: 1000,
        buildoptions: [],
        customParams: {
            subfolder: 'other/arm'
        }
    },
    raptor_queen_v1: {
        name: 'raptor_queen_v1',
        health: 50000,
        metalCost: 5000,
        customParams: {}
    },
    raptor_land_swarmer_heal: {
        name: 'raptor_land_swarmer_heal',
        health: 200,
        metalCost: 100,
        buildSpeed: 10,
        customParams: {
            subfolder: 'other/raptors'
        }
    },
    scavengerbossv4: {
        name: 'scavengerbossv4',
        health: 100000,
        customParams: {}
    },
    some_scav: {
        name: 'some_scav',
        health: 500,
        metalCost: 50,
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
