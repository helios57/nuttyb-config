import { TweakDefinition, TweakCondition, MutationOperation } from './tweak-dsl';

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

export function compileTweak(tweak: TweakDefinition): string {
    const builder = new LuaBlockBuilder();

    // 1. Global Optimization: Localize standard library functions
    const usedGlobals = new Set<string>();
    
    for (const cond of tweak.conditions) {
        if (cond.type === 'nameMatch' || cond.type === 'nameNotMatch') usedGlobals.add('string.match');
        if (cond.type === 'nameStartsWith' || cond.type === 'nameEndsWith') usedGlobals.add('string.sub');
    }
    
    for (const mut of tweak.mutations) {
        if (mut.op === 'assign_math_floor') usedGlobals.add('math.floor');
    }

    if (usedGlobals.has('string.match')) builder.addLocal('string_match', 'string.match');
    if (usedGlobals.has('string.sub')) builder.addLocal('string_sub', 'string.sub');
    if (usedGlobals.has('math.floor')) builder.addLocal('math_floor', 'math.floor');
    
    if (usedGlobals.size > 0) builder.addStatement('');

    // 2. Logic Generator
    const generateBody = (unitNameVar: string, defVar: string) => {
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
                    // string.sub(name, 1, len) == "prefix"
                    conditionsLua.push(`string_sub(${unitNameVar}, 1, ${cond.prefix.length}) == "${cond.prefix}"`);
                    break;
                case 'nameEndsWith':
                    // string.sub(name, -len) == "suffix"
                    conditionsLua.push(`string_sub(${unitNameVar}, -${cond.suffix.length}) == "${cond.suffix}"`);
                    break;
                case 'customParam':
                    const val = typeof cond.value === 'string' ? `"${cond.value}"` : cond.value;
                    // Robust check: BAR uses customParams (CamelCase) in UnitDefs, but sometimes customparams (lower) in Post
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

        for (const mut of tweak.mutations) {
            // Helper to get safe field access or defaults if needed
            const field = mut.field || (mut as any)['target']; // handle both types
            
            if (mut.op === 'multiply') {
                builder.startIf(`${defVar}.${mut.field}`);
                builder.addStatement(`${defVar}.${mut.field} = ${defVar}.${mut.field} * ${mut.factor}`);
                builder.endBlock();
            } else if (mut.op === 'set') {
                const val = typeof mut.value === 'string' ? `"${mut.value}"` : mut.value;
                builder.addStatement(`${defVar}.${mut.field} = ${val}`);
            } else if (mut.op === 'remove') {
                builder.addStatement(`${defVar}.${mut.field} = nil`);
            } else if (mut.op === 'assign_math_floor') {
                builder.startIf(`${defVar}.${mut.source}`);
                builder.addStatement(`${defVar}.${mut.target} = math_floor(${defVar}.${mut.source} * ${mut.factor})`);
                builder.endBlock();
            }
        }

        if (conditionsLua.length > 0) {
            builder.endBlock();
        }
    };

    if (tweak.scope === 'UnitDefsLoop') {
        // TweakDefs context: Iterating the final engine table
        builder.startLoop('for name, def in pairs(UnitDefs)');
        generateBody('name', 'def');
        builder.endBlock();
    } else if (tweak.scope === 'UnitDef_Post') {
        // Post context: Hooking into unit loading
        // Sanitized function name to prevent collisions
        const funcName = `ApplyTweak_${tweak.name.replace(/[^a-zA-Z0-9_]/g, '_')}`;

        builder.startBlock(`local function ${funcName}(name, def)`);
        generateBody('name', 'def');
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
