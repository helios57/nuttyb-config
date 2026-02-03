import { TweakDefinition, TweakCondition, MutationOperation } from './tweak-dsl';

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
            parts.push(`["${k}"] = ${jsonToLua(v)}`);
        }
        return `{ ${parts.join(', ')} }`;
    }
    return 'nil';
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
    
    for (const tweak of tweaks) {
        for (const cond of tweak.conditions) {
            if (cond.type === 'nameMatch' || cond.type === 'nameNotMatch') usedGlobals.add('string.match');
            if (cond.type === 'nameStartsWith' || cond.type === 'nameEndsWith') usedGlobals.add('string.sub');
        }
        
        for (const mut of tweak.mutations) {
            if (mut.op === 'assign_math_floor') usedGlobals.add('math.floor');
            if (mut.op === 'list_append' || mut.op === 'list_remove') usedGlobals.add('table.insert');
        }
    }

    if (usedGlobals.has('string.match')) builder.addLocal('string_match', 'string.match');
    if (usedGlobals.has('string.sub')) builder.addLocal('string_sub', 'string.sub');
    if (usedGlobals.has('math.floor')) builder.addLocal('math_floor', 'math.floor');
    if (usedGlobals.has('table.insert')) {
        builder.addLocal('table_insert', 'table.insert');
        builder.addLocal('table_remove', 'table.remove');
    }
    
    if (usedGlobals.size > 0) builder.addStatement('');

    // Helpers for customParams handling
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

    // Helper to sort mutations to prevent rounding drift
    const sortMutations = (mutations: MutationOperation[]): MutationOperation[] => {
        const order = { 'set': 1, 'multiply': 2, 'assign_math_floor': 3 };
        return [...mutations].sort((a, b) => {
            const oa = (order as any)[a.op] || 99;
            const ob = (order as any)[b.op] || 99;
            return oa - ob;
        });
    };

    // 2. Logic Generator
    const generateBody = (tweak: TweakDefinition, unitNameVar: string, defVar: string) => {
        const conditionsLua: string[] = [];
        
        for (const cond of tweak.conditions) {
            switch (cond.type) {
                case 'nameMatch':
                    conditionsLua.push(`string_match(${unitNameVar}, "${cond.regex}")`);
                    break;
                case 'nameNotMatch':
                    conditionsLua.push(`not string_match(${unitNameVar}, "${cond.regex}")`);
                    break;
                case 'nameStartsWith':
                    conditionsLua.push(`string_sub(${unitNameVar}, 1, ${cond.prefix.length}) == "${cond.prefix}"`);
                    break;
                case 'nameEndsWith':
                    conditionsLua.push(`string_sub(${unitNameVar}, -${cond.suffix.length}) == "${cond.suffix}"`);
                    break;
                case 'customParam':
                    const val = typeof cond.value === 'string' ? `"${cond.value}"` : cond.value;
                    conditionsLua.push(`((${defVar}.customParams and ${defVar}.customParams["${cond.key}"] == ${val}) or (${defVar}.customparams and ${defVar}.customparams["${cond.key}"] == ${val}))`);
                    break;
                case 'category':
                    conditionsLua.push(`${defVar}.category == "${cond.value}"`);
                    break;
            }
        }

        if (conditionsLua.length > 0) {
            builder.startIf(conditionsLua.join(' and '));
        }

        const sortedMutations = sortMutations(tweak.mutations);

        for (const mut of sortedMutations) {
            if (mut.op === 'multiply') {
                const readExpr = getFieldRead(defVar, mut.field);
                builder.startIf(readExpr);
                addFieldWrite(defVar, mut.field, `${readExpr} * ${mut.factor}`);
                builder.endBlock();
            } else if (mut.op === 'set') {
                const val = typeof mut.value === 'string' ? `"${mut.value}"` : mut.value;
                addFieldWrite(defVar, mut.field, val.toString());
            } else if (mut.op === 'remove') {
                addFieldWrite(defVar, mut.field, 'nil');
            } else if (mut.op === 'assign_math_floor') {
                const readExpr = getFieldRead(defVar, mut.source);
                builder.startIf(readExpr);
                addFieldWrite(defVar, mut.target, `math_floor(${readExpr} * ${mut.factor})`);
                builder.endBlock();
            } else if (mut.op === 'list_append') {
                const val = typeof mut.value === 'string' ? `"${mut.value}"` : mut.value;
                builder.addLocal('target_list', getFieldRead(defVar, mut.field));
                builder.startIf('not target_list');
                const parts = mut.field.split('.');
                if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
                     builder.startIf(`${defVar}.customparams`);
                     builder.addStatement(`${defVar}.customparams["${parts[1]}"] = {}`);
                     builder.addStatement(`target_list = ${defVar}.customparams["${parts[1]}"]`);
                     builder.addElse();
                     builder.addStatement(`if not ${defVar}.customParams then ${defVar}.customParams = {} end`);
                     builder.addStatement(`${defVar}.customParams["${parts[1]}"] = {}`);
                     builder.addStatement(`target_list = ${defVar}.customParams["${parts[1]}"]`);
                     builder.endBlock();
                } else {
                     builder.addStatement(`${defVar}.${mut.field} = {}`);
                     builder.addStatement(`target_list = ${defVar}.${mut.field}`);
                }
                builder.endBlock();
                builder.addStatement(`table_insert(target_list, ${val})`);
            } else if (mut.op === 'list_remove') {
                const val = typeof mut.value === 'string' ? `"${mut.value}"` : mut.value;
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
                const luaTable = jsonToLua(mut.value);
                builder.addLocal('target_table', getFieldRead(defVar, mut.field));
                builder.startIf('not target_table');
                const parts = mut.field.split('.');
                if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
                     builder.startIf(`${defVar}.customparams`);
                     builder.addStatement(`${defVar}.customparams["${parts[1]}"] = {}`);
                     builder.addStatement(`target_table = ${defVar}.customparams["${parts[1]}"]`);
                     builder.addElse();
                     builder.addStatement(`if not ${defVar}.customParams then ${defVar}.customParams = {} end`);
                     builder.addStatement(`${defVar}.customParams["${parts[1]}"] = {}`);
                     builder.addStatement(`target_table = ${defVar}.customParams["${parts[1]}"]`);
                     builder.endBlock();
                } else {
                     builder.addStatement(`${defVar}.${mut.field} = {}`);
                     builder.addStatement(`target_table = ${defVar}.${mut.field}`);
                }
                builder.endBlock();
                builder.startLoop(`for k, v in pairs(${luaTable})`);
                builder.addStatement('target_table[k] = v');
                builder.endBlock();
            } else if (mut.op === 'raw_lua') {
                builder.addStatement(mut.code);
            }
        }

        if (conditionsLua.length > 0) {
            builder.endBlock();
        }
    };

    const loopTweaks = tweaks.filter(t => t.scope === 'UnitDefsLoop');
    const postTweaks = tweaks.filter(t => t.scope === 'UnitDef_Post');
    const globalTweaks = tweaks.filter(t => t.scope === 'Global');

    if (globalTweaks.length > 0) {
        for (const tweak of globalTweaks) {
            generateBody(tweak, 'nil', 'nil'); // Unit vars not available in Global scope
        }
    }

    if (loopTweaks.length > 0) {
        builder.startLoop('for id, def in pairs(UnitDefs)');
        builder.addLocal('name', 'def.name');
        for (const tweak of loopTweaks) {
            generateBody(tweak, 'name', 'def');
        }
        builder.endBlock();
    }

    if (postTweaks.length > 0) {
        const funcName = `ApplyTweaks_Post`;
        builder.startBlock(`local function ${funcName}(name, def)`);
        for (const tweak of postTweaks) {
            generateBody(tweak, 'name', 'def');
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

    return builder.build();
}
