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
    }
};

export function getMockUnitDefsLua(): string {
    // Convert the JS object to a Lua table string
    const parts: string[] = [];
    for (const [key, val] of Object.entries(mockUnitDefs)) {
        parts.push(`${key} = ${JSON.stringify(val).replace(/"/g, '').replace(/,/g, ', ').replace(/:/g, '=')}`);
        // Simple JSON to Lua conversion hack: remove quotes from keys (implicit), use = instead of :
        // But JSON stringify quotes keys. "{ "name": "armcom" }" -> { name = "armcom" }
        // Better: use a proper serializer or just manual string for test.
    }

    // Let's write a robust serializer for test data
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
