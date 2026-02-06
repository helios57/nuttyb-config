export const MockUnitDefs = {
    "armcom": {
        name: "armcom",
        humanName: "Commander",
        metalCost: 1000,
        energyCost: 1000,
        health: 3000,
        category: "COMMANDER",
        customparams: {
            iscommander: "1",
            paratrooper: "0"
        },
        weapondefs: {
            "laser": {
                damage: { default: 100 }
            }
        }
    },
    "corcom": {
        name: "corcom",
        humanName: "Commander",
        metalCost: 1000,
        energyCost: 1000,
        health: 3000,
        category: "COMMANDER",
        customparams: {
            iscommander: "1"
        }
    },
    "raptor_land_swarmer_heal": {
        name: "raptor_land_swarmer_heal",
        health: 500,
        buildSpeed: 10,
        reclaimSpeed: 0,
        stealth: true,
        builder: true,
        canAssist: true,
        maxThisUnit: 100
    },
    "raptor_queen_acid": {
        name: "raptor_queen_acid",
        health: 50000,
        repairable: true
    },
    "cortron": {
        name: "cortron",
        metalcost: 100,
        energycost: 1000,
        weapondefs: {
            "cortron_weapon": {
                range: 100,
                damage: { default: 100 }
            }
        }
    },
    "armmeatball": {
        name: "armmeatball",
        buildoptions: []
    },
    "cor": {
        name: "cor",
        buildoptions: []
    }
};
