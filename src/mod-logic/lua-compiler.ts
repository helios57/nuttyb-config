import { TweakDefinition, TweakCondition, MutationOperation, ValueSource } from './tweak-dsl';

// Try to require luamin, handle if not present (e.g. in some dev environments)
let luamin: any;
try {
    // @ts-ignore
    luamin = require('../../luamin.js');
} catch (e) {
    console.warn("luamin.js not found, minification disabled");
}

function jsonToLua(obj: any): string {
    if (obj === null || obj === undefined) return 'nil';
    if (typeof obj === 'string') return `"${obj}"`;
    if (typeof obj === 'number') return obj.toString();
    if (typeof obj === 'boolean') return obj ? 'true' : 'false';
    if (Array.isArray(obj)) {
        const parts = obj.map(v => jsonToLua(v));
        return `{ ${parts.join(', ')} }`;
    }
    if (typeof obj === 'object') {
        const parts: string[] = [];
        for (const [k, v] of Object.entries(obj)) {
            // Handle valid Lua identifiers as keys without quotes
            if (/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(k)) {
                parts.push(`${k} = ${jsonToLua(v)}`);
            } else {
                parts.push(`["${k}"] = ${jsonToLua(v)}`);
            }
        }
        return `{ ${parts.join(', ')} }`;
    }
    return 'nil';
}

function resolveValue(val: ValueSource): string {
    if (typeof val === 'object' && val !== null) {
        if ('type' in val) {
            if (val.type === 'mod_option') {
                // Assuming Spring is available or we localize it
                return `(Spring_GetModOptions().${val.key} or ${jsonToLua(val.default)})`;
            } else if (val.type === 'math') {
                let expr = val.expression;
                for (const [k, v] of Object.entries(val.variables)) {
                    // Simple replacement - could be more robust with a parser but sufficient for now
                    expr = expr.split(k).join(resolveValue(v));
                }
                // Map common math functions to localized versions
                expr = expr.replace(/\bmax\(/g, 'math_max(')
                           .replace(/\bmin\(/g, 'math_min(')
                           .replace(/\bceil\(/g, 'math_ceil(')
                           .replace(/\bfloor\(/g, 'math_floor(');
                return `(${expr})`;
            }
        }
        // It's a plain object (table)
        return jsonToLua(val);
    }
    return jsonToLua(val);
}

export class LuaBlockBuilder {
    private lines: string[] = [];
    private indentLevel: number = 0;

    private getIndent(): string {
        return '    '.repeat(this.indentLevel);
    }

    addLocal(name: string, value: string) {
        this.lines.push(`${this.getIndent()}local ${name} = ${value}`);
    }

    startLoop(iterator: string) {
        this.lines.push(`${this.getIndent()}${iterator} do`);
        this.indentLevel++;
    }

    startIf(condition: string) {
        this.lines.push(`${this.getIndent()}if ${condition} then`);
        this.indentLevel++;
    }

    startElseIf(condition: string) {
        if (this.indentLevel > 0) {
            this.indentLevel--;
            this.lines.push(`${this.getIndent()}elseif ${condition} then`);
            this.indentLevel++;
        }
    }

    startBlock(header: string) {
        this.lines.push(`${this.getIndent()}${header}`);
        this.indentLevel++;
    }

    addElse() {
        if (this.indentLevel > 0) {
            this.indentLevel--;
            this.lines.push(`${this.getIndent()}else`);
            this.indentLevel++;
        }
    }

    addStatement(stmt: string) {
        this.lines.push(`${this.getIndent()}${stmt}`);
    }

    endBlock() {
        if (this.indentLevel > 0) {
            this.indentLevel--;
            this.lines.push(`${this.getIndent()}end`);
        }
    }

    build(): string {
        return this.lines.join('\n');
    }
}

export function compileTweak(tweakOrTweaks: TweakDefinition | TweakDefinition[]): string {
    const tweaks = Array.isArray(tweakOrTweaks) ? tweakOrTweaks : [tweakOrTweaks];
    const builder = new LuaBlockBuilder();

    // 1. Global Optimization: Localize standard library functions
    const usedGlobals = new Set<string>();
    
    // Always localize common ones for performance
    usedGlobals.add('pairs');
    usedGlobals.add('ipairs');
    usedGlobals.add('string.sub');
    usedGlobals.add('string.match');
    usedGlobals.add('table.insert');
    usedGlobals.add('table.remove');
    usedGlobals.add('math.floor');
    usedGlobals.add('math.ceil');
    usedGlobals.add('math.max');
    usedGlobals.add('math.min');
    
    // Check for specific needs
    let needsSpring = false;
    let needsTableMerge = false;

    const checkValueSource = (val: ValueSource) => {
        if (typeof val === 'object' && val !== null && 'type' in val) {
            if (val.type === 'mod_option') needsSpring = true;
            if (val.type === 'math') {
                Object.values(val.variables).forEach(checkValueSource);
            }
        }
    };

    for (const tweak of tweaks) {
        for (const mut of tweak.mutations) {
            if (mut.op === 'clone_unit' || mut.op === 'table_merge') needsTableMerge = true;
            if (mut.op === 'set' || mut.op === 'multiply' || mut.op === 'list_append') {
                if (mut.value) checkValueSource(mut.value);
            }
            if (mut.op === 'assign_math_floor') {
                if (mut.factor) checkValueSource(mut.factor);
            }
        }
    }

    // Emit Localizations
    builder.addLocal('pairs', 'pairs');
    builder.addLocal('ipairs', 'ipairs');
    builder.addLocal('string_sub', 'string.sub');
    builder.addLocal('string_match', 'string.match');
    builder.addLocal('table_insert', 'table.insert');
    builder.addLocal('table_remove', 'table.remove');
    builder.addLocal('math_floor', 'math.floor');
    builder.addLocal('math_ceil', 'math.ceil');
    builder.addLocal('math_max', 'math.max');
    builder.addLocal('math_min', 'math.min');
    
    if (needsSpring) {
        builder.addLocal('Spring_GetModOptions', 'Spring.GetModOptions');
    }
    if (needsTableMerge) {
        // Assume table.merge exists in Spring Lua environment, or define it if not.
        // For safety in BAR environment, table.merge is usually global or in table.
        builder.addLocal('table_merge', 'table.merge'); 
    }

    builder.addStatement('');

    // Helpers
    const getFieldRead = (defVar: string, fieldPath: string): string => {
        const parts = fieldPath.split('.');
        if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
            const paramKey = parts[1];
            return `((${defVar}.customParams and ${defVar}.customParams["${paramKey}"]) or (${defVar}.customparams and ${defVar}.customparams["${paramKey}"]))`;
        }
        return `${defVar}.${fieldPath}`;
    };

    const addFieldWrite = (defVar: string, fieldPath: string, valueExpr: string) => {
        const parts = fieldPath.split('.');
        if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
            const paramKey = parts[1];
            builder.startIf(`${defVar}.customparams`);
            builder.addStatement(`${defVar}.customparams["${paramKey}"] = ${valueExpr}`);
            builder.addElse();
            builder.addStatement(`if not ${defVar}.customParams then ${defVar}.customParams = {} end`);
            builder.addStatement(`${defVar}.customParams["${paramKey}"] = ${valueExpr}`);
            builder.endBlock();
        } else {
            builder.addStatement(`${defVar}.${fieldPath} = ${valueExpr}`);
        }
    };

    const generateMutations = (mutations: MutationOperation[], defVar: string) => {
        // Sort mutations: clone first, then sets/multiplies, then math_floor
        const sorted = [...mutations].sort((a, b) => {
            const score = (op: string) => {
                if (op === 'clone_unit') return 0;
                if (op === 'set') return 1;
                if (op === 'multiply') return 2;
                if (op === 'assign_math_floor') return 3;
                return 4;
            };
            return score(a.op) - score(b.op);
        });

        for (const mut of sorted) {
            if (mut.op === 'multiply') {
                const readExpr = getFieldRead(defVar, mut.field);
                builder.startIf(readExpr);
                addFieldWrite(defVar, mut.field, `${readExpr} * ${resolveValue(mut.factor)}`);
                builder.endBlock();
            } else if (mut.op === 'set') {
                addFieldWrite(defVar, mut.field, resolveValue(mut.value));
            } else if (mut.op === 'remove') {
                addFieldWrite(defVar, mut.field, 'nil');
            } else if (mut.op === 'assign_math_floor') {
                const readExpr = getFieldRead(defVar, mut.source);
                builder.startIf(readExpr);
                addFieldWrite(defVar, mut.target, `math_floor(${readExpr} * ${resolveValue(mut.factor)})`);
                builder.endBlock();
            } else if (mut.op === 'list_append') {
                const val = resolveValue(mut.value);
                builder.addLocal('target_list', getFieldRead(defVar, mut.field));
                builder.startIf('not target_list');
                // Create list if missing
                const parts = mut.field.split('.');
                if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
                     // Simplified creation for customparams
                     builder.addStatement(`${defVar}.customparams = ${defVar}.customparams or {}`);
                     builder.addStatement(`${defVar}.customparams["${parts[1]}"] = {}`);
                     builder.addStatement(`target_list = ${defVar}.customparams["${parts[1]}"]`);
                } else {
                     builder.addStatement(`${defVar}.${mut.field} = {}`);
                     builder.addStatement(`target_list = ${defVar}.${mut.field}`);
                }
                builder.endBlock();
                builder.addStatement(`table_insert(target_list, ${val})`);
            } else if (mut.op === 'list_remove') {
                const val = resolveValue(mut.value);
                builder.addLocal('target_list', getFieldRead(defVar, mut.field));
                builder.startIf('target_list');
                builder.startLoop('for i, v in ipairs(target_list)');
                builder.startIf(`v == ${val}`);
                builder.addStatement('table_remove(target_list, i)');
                builder.addStatement('break');
                builder.endBlock();
                builder.endBlock();
                builder.endBlock();
            } else if (mut.op === 'table_merge') {
                const luaTable = resolveValue(mut.value);
                builder.addLocal('target_table', getFieldRead(defVar, mut.field));
                builder.startIf('not target_table');
                // Create table if missing
                const parts = mut.field.split('.');
                if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
                     builder.addStatement(`${defVar}.customparams = ${defVar}.customparams or {}`);
                     builder.addStatement(`${defVar}.customparams["${parts[1]}"] = {}`);
                     builder.addStatement(`target_table = ${defVar}.customparams["${parts[1]}"]`);
                } else {
                     builder.addStatement(`${defVar}.${mut.field} = {}`);
                     builder.addStatement(`target_table = ${defVar}.${mut.field}`);
                }
                builder.endBlock();
                // Use table_merge if available or loop
                builder.addStatement(`table_merge(target_table, ${luaTable})`);
            } else if (mut.op === 'modify_weapon') {
                const weaponName = mut.weaponName || '*';
                builder.startIf(`${defVar}.weapondefs`);
                builder.startLoop(`for wName, wDef in pairs(${defVar}.weapondefs)`);
                if (weaponName !== '*') {
                    builder.startIf(`wName == "${weaponName}"`);
                }
                generateMutations(mut.mutations, 'wDef');
                if (weaponName !== '*') {
                    builder.endBlock();
                }
                builder.endBlock();
                builder.endBlock();
            } else if (mut.op === 'clone_unit') {
                const source = mut.source === 'SELF' ? defVar : `UnitDefs["${mut.source}"]`;
                const targetName = mut.target ? `"${mut.target}"` : (mut.targetSuffix ? `${defVar}.name .. "${mut.targetSuffix}"` : 'nil');
                
                builder.startIf(source);
                builder.addLocal('newDef', `table_merge({}, ${source})`); // Shallow copy first via merge into empty
                // Deep copy is better but table_merge usually handles it or we assume shallow is enough for base props
                // Actually table.merge in Spring is usually deep.
                
                if (mut.mutations) {
                    generateMutations(mut.mutations, 'newDef');
                }
                
                builder.addStatement(`UnitDefs[${targetName}] = newDef`);
                builder.endBlock();
            } else if (mut.op === 'raw_lua') {
                builder.addStatement(mut.code);
            }
        }
    };

    const generateConditions = (conditions: TweakCondition[], unitNameVar: string, defVar: string): string[] => {
        const conds: string[] = [];
        for (const cond of conditions) {
            switch (cond.type) {
                case 'nameMatch':
                    conds.push(`string_match(${unitNameVar}, "${cond.regex}")`);
                    break;
                case 'nameNotMatch':
                    conds.push(`not string_match(${unitNameVar}, "${cond.regex}")`);
                    break;
                case 'nameStartsWith':
                    conds.push(`string_sub(${unitNameVar}, 1, ${cond.prefix.length}) == "${cond.prefix}"`);
                    break;
                case 'nameEndsWith':
                    conds.push(`string_sub(${unitNameVar}, -${cond.suffix.length}) == "${cond.suffix}"`);
                    break;
                case 'nameInList':
                    // Optimize: create a set check or multiple ORs
                    // For Lua, a helper table is best if list is long, but ORs are faster for short lists.
                    // Let's use ORs for simplicity and speed for small lists.
                    const checks = cond.names.map(n => `${unitNameVar} == "${n}"`);
                    conds.push(`(${checks.join(' or ')})`);
                    break;
                case 'customParam':
                    const val = typeof cond.value === 'string' ? `"${cond.value}"` : cond.value;
                    conds.push(`((${defVar}.customParams and ${defVar}.customParams["${cond.key}"] == ${val}) or (${defVar}.customparams and ${defVar}.customparams["${cond.key}"] == ${val}))`);
                    break;
                case 'customParamMatch':
                    conds.push(`((${defVar}.customParams and string_match(${defVar}.customParams["${cond.key}"], "${cond.regex}")) or (${defVar}.customparams and string_match(${defVar}.customparams["${cond.key}"], "${cond.regex}")))`);
                    break;
                case 'fieldValue':
                    const fVal = typeof cond.value === 'string' ? `"${cond.value}"` : cond.value;
                    conds.push(`${defVar}.${cond.field} == ${fVal}`);
                    break;
                case 'category':
                    conds.push(`${defVar}.category == "${cond.value}"`);
                    break;
            }
        }
        return conds;
    };

    // 2. Logic Generator
    const loopTweaks = tweaks.filter(t => t.scope === 'UnitDefsLoop');
    const postTweaks = tweaks.filter(t => t.scope === 'UnitDef_Post');
    const globalTweaks = tweaks.filter(t => t.scope === 'Global');

    if (globalTweaks.length > 0) {
        for (const tweak of globalTweaks) {
            builder.addStatement(`-- ${tweak.name}`);
            generateMutations(tweak.mutations, 'nil'); // Global scope, no unit var
        }
    }

    if (loopTweaks.length > 0) {
        builder.startLoop('for id, def in pairs(UnitDefs)');
        builder.addLocal('name', 'def.name or id'); // Fallback to id if name missing
        
        // Loop Fusion with if-elseif optimization attempt
        // We can't easily merge arbitrary conditions into a single if-elseif tree without analyzing overlap.
        // But we can group them sequentially.
        
        for (const tweak of loopTweaks) {
            const conds = generateConditions(tweak.conditions, 'name', 'def');
            if (conds.length > 0) {
                builder.startIf(conds.join(' and '));
                generateMutations(tweak.mutations, 'def');
                builder.endBlock();
            } else {
                // Unconditional tweak in loop
                generateMutations(tweak.mutations, 'def');
            }
        }
        builder.endBlock();
    }

    if (postTweaks.length > 0) {
        const funcName = `ApplyTweaks_Post`;
        builder.startBlock(`local function ${funcName}(name, def)`);
        for (const tweak of postTweaks) {
            const conds = generateConditions(tweak.conditions, 'name', 'def');
            if (conds.length > 0) {
                builder.startIf(conds.join(' and '));
                generateMutations(tweak.mutations, 'def');
                builder.endBlock();
            } else {
                generateMutations(tweak.mutations, 'def');
            }
        }
        builder.endBlock();
        builder.addStatement('');
        builder.startIf('UnitDef_Post');
        builder.addLocal('prev_UnitDef_Post', 'UnitDef_Post');
        builder.startBlock('UnitDef_Post = function(name, def)');
        builder.addStatement('prev_UnitDef_Post(name, def)');
        builder.addStatement(`${funcName}(name, def)`);
        builder.endBlock();
        builder.addElse();
        builder.addStatement(`UnitDef_Post = ${funcName}`);
        builder.endBlock();
    }

    let luaCode = builder.build();

    // 3. Minification & Verification
    if (luamin) {
        try {
            luaCode = luamin.Minify(luaCode, { RenameVariables: true, RenameGlobals: false, SolveMath: true });
        } catch (e) {
            console.error("Minification/Verification failed:", e);
            throw new Error(`Lua generation failed validation: ${e}`);
        }
    }

    return luaCode;
}
