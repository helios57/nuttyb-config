
const fs = require('fs');
const config = require('./master_config_normalized.json');

const unitName = "alpha_unit";
const def = { name: "alpha_unit", health: 1000 };

const matches = config.filter(tweak => {
    // Only check UnitDefsLoop scopes as that's where the issue likely is
    if (tweak.scope !== 'UnitDefsLoop') return false;

    return tweak.conditions.every(cond => {
        if (cond.type === 'nameMatch') {
            return new RegExp(cond.regex).test(unitName);
        }
        if (cond.type === 'nameNotMatch') {
            return !new RegExp(cond.regex).test(unitName);
        }
        if (cond.type === 'nameStartsWith') {
            const prefix = cond.prefix; // Assuming string for simplicity
            if (typeof prefix === 'string') return unitName.startsWith(prefix);
            return false; // Skip variable resolution
        }
        if (cond.type === 'nameEndsWith') {
             const suffix = cond.suffix;
             if (typeof suffix === 'string') return unitName.endsWith(suffix);
             return false;
        }
        if (cond.type === 'customParam') return false; // alpha_unit has no customParams
        if (cond.type === 'customParamMatch') return false;
        if (cond.type === 'fieldValue') return false; // defaults to false
        if (cond.type === 'nameInList') return cond.names.includes(unitName);
        return false;
    });
});

console.log("Matching tweaks:", matches.map(m => m.name));
