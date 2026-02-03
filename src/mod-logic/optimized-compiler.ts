import { TweakDefinition, TweakCondition, MutationOperation, ValueSource, UnitDefField } from './tweak-dsl';

interface CompilerInput {
    tweak: TweakDefinition;
    variables: Record<string, any>;
}

export class OptimizedLuaCompiler {
    private builder: string[] = [];
    private indentLevel: number = 0;
    private usedGlobals = new Set<string>();

    compile(inputs: CompilerInput[]): string {
        this.builder = [];
        this.indentLevel = 0;
        this.usedGlobals = new Set<string>();

        // 1. Pre-scan for globals
        this.scanGlobals(inputs);

        // 2. Emit Localized Globals
        this.emitGlobals();

        this.addStatement('');

        // 3. Process Scopes
        const loopTweaks = inputs.filter(i => i.tweak.scope === 'UnitDefsLoop');
        const postTweaks = inputs.filter(i => i.tweak.scope === 'UnitDef_Post');
        const globalTweaks = inputs.filter(i => i.tweak.scope === 'Global');

        // 4. Generate Global Tweaks
        if (globalTweaks.length > 0) {
            this.addStatement('-- Global Tweaks');
            for (const input of globalTweaks) {
                for (const mut of input.tweak.mutations) {
                    this.generateMutation(mut, 'nil', input.variables);
                }
            }
        }

        // 5. Generate UnitDefs Loop (Loop Fusion)
        if (loopTweaks.length > 0) {
            this.addStatement('-- UnitDefs Loop');
            this.startLoop('for id, def in pairs(UnitDefs)');
            this.addLocal('name', 'def.name or id');

            let currentGroup: { inputs: CompilerInput[], conditions: string[] } | null = null;

            for (const input of loopTweaks) {
                const conds = this.generateConditions(input.tweak.conditions, 'name', 'def', input.variables);
                const condKey = conds.join(' && ');

                if (currentGroup && currentGroup.conditions.join(' && ') === condKey) {
                    currentGroup.inputs.push(input);
                } else {
                    if (currentGroup) {
                        this.emitGroup(currentGroup, 'def');
                    }
                    currentGroup = { inputs: [input], conditions: conds };
                }
            }
            if (currentGroup) {
                this.emitGroup(currentGroup, 'def');
            }

            this.endBlock();
        }

        // 6. Generate Post Tweaks
        if (postTweaks.length > 0) {
            this.addStatement('-- UnitDef_Post Tweaks');
            const funcName = `ApplyTweaks_Post`;
            this.startBlock(`local function ${funcName}(name, def)`);

            let currentGroup: { inputs: CompilerInput[], conditions: string[] } | null = null;

            for (const input of postTweaks) {
                const conds = this.generateConditions(input.tweak.conditions, 'name', 'def', input.variables);
                const condKey = conds.join(' && ');

                if (currentGroup && currentGroup.conditions.join(' && ') === condKey) {
                    currentGroup.inputs.push(input);
                } else {
                    if (currentGroup) {
                        this.emitGroup(currentGroup, 'def');
                    }
                    currentGroup = { inputs: [input], conditions: conds };
                }
            }
            if (currentGroup) {
                this.emitGroup(currentGroup, 'def');
            }

            this.endBlock();
            this.addStatement('');
            this.startIf('UnitDef_Post');
            this.addLocal('prev_UnitDef_Post', 'UnitDef_Post');
            this.startBlock('UnitDef_Post = function(name, def)');
            this.addStatement('prev_UnitDef_Post(name, def)');
            this.addStatement(`${funcName}(name, def)`);
            this.endBlock();
            this.addElse();
            this.addStatement(`UnitDef_Post = ${funcName}`);
            this.endBlock();
        }

        return this.builder
            .map(l => l.trim())
            .filter(l => l !== '' && !l.startsWith('--'))
            .join('\n');
    }

    private emitGroup(group: { inputs: CompilerInput[], conditions: string[] }, defVar: string) {
        if (group.conditions.length > 0) {
            this.startIf(group.conditions.join(' and '));
        }

        // Flatten all mutations in the group
        const allMutations: { mut: MutationOperation, vars: Record<string, any> }[] = [];
        group.inputs.forEach(i => i.tweak.mutations.forEach(m => allMutations.push({ mut: m, vars: i.variables })));

        // Merge logic
        const mergedMutations: { mut: MutationOperation, vars: Record<string, any> }[] = [];

        for (const item of allMutations) {
            const last = mergedMutations.length > 0 ? mergedMutations[mergedMutations.length - 1] : null;

            if (last && last.mut.op === 'multiply' && item.mut.op === 'multiply' && last.mut.field === item.mut.field) {
                // We create a new "math" ValueSource on the fly that represents (factor1 * factor2)
                // Note: resolveValueSource needs to handle the output format if we nest it.
                // Since we are constructing AST, we can't easily nest "result of resolve" (string) into ValueSource.
                // However, we can disable merging for complex cases and only support basic merging,
                // or we just rely on pendingMultiplies logic below which IS robust.
                // The pendingMultiplies logic below handles the "single calculation line" requirement.
                // So I don't need to merge AST here.
                mergedMutations.push(item);
            } else {
                mergedMutations.push(item);
            }
        }

        // Use pendingMultiplies to group consecutive multiplies
        const pendingMultiplies = new Map<string, string[]>();

        const flushPending = (field?: string) => {
            if (field) {
                if (pendingMultiplies.has(field)) {
                    const factors = pendingMultiplies.get(field)!;
                    const factorExpr = factors.join(' * ');
                    this.addStatement(`${defVar}.${field} = ${defVar}.${field} * (${factorExpr})`);
                    pendingMultiplies.delete(field);
                }
            } else {
                for (const [f, factors] of pendingMultiplies) {
                    const factorExpr = factors.join(' * ');
                    this.addStatement(`${defVar}.${f} = ${defVar}.${f} * (${factorExpr})`);
                }
                pendingMultiplies.clear();
            }
        };

        for (const item of mergedMutations) {
            const { mut, vars } = item;

            if (mut.op === 'set' || mut.op === 'assign_math_floor' || mut.op === 'remove') {
                if ('field' in mut) flushPending(mut.field as string);
                if ('target' in mut) flushPending(mut.target as string);
            }

            if (mut.op === 'multiply') {
                const val = this.resolveValueSource(mut.factor, vars);
                if (!pendingMultiplies.has(mut.field)) {
                    pendingMultiplies.set(mut.field, []);
                }
                pendingMultiplies.get(mut.field)!.push(val);
            } else {
                flushPending();
                this.generateMutation(mut, defVar, vars);
            }
        }
        flushPending();

        if (group.conditions.length > 0) {
            this.endBlock();
        }
    }

    private generateMutation(mut: MutationOperation, defVar: string, variables: Record<string, any>) {
         if (mut.op === 'set') {
             this.addFieldWrite(defVar, mut.field, this.resolveValueSource(mut.value, variables));
         } else if (mut.op === 'remove') {
             this.addFieldWrite(defVar, mut.field, 'nil');
         } else if (mut.op === 'assign_math_floor') {
             const readExpr = this.getFieldRead(defVar, mut.source);
             this.startIf(readExpr);
             const factor = this.resolveValueSource(mut.factor, variables);
             this.addFieldWrite(defVar, mut.target, `math_floor(${readExpr} * ${factor})`);
             this.endBlock();
         } else if (mut.op === 'list_append') {
             const val = this.resolveValueSource(mut.value, variables);
             const listVar = 'target_list';
             this.addLocal(listVar, this.getFieldRead(defVar, mut.field));
             this.startIf(`not ${listVar}`);
             const parts = mut.field.split('.');
             if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
                 this.addStatement(`${defVar}.customparams = ${defVar}.customparams or {}`);
                 this.addStatement(`${defVar}.customparams["${parts[1]}"] = {}`);
                 this.addStatement(`${listVar} = ${defVar}.customparams["${parts[1]}"]`);
             } else {
                 this.addStatement(`${defVar}.${mut.field} = {}`);
                 this.addStatement(`${listVar} = ${defVar}.${mut.field}`);
             }
             this.endBlock();
             this.addStatement(`table_insert(${listVar}, ${val})`);
         }
         else if (mut.op === 'modify_weapon') {
             const weaponName = mut.weaponName || '*';
             this.startIf(`${defVar}.weapondefs`);
             this.startLoop(`for wName, wDef in pairs(${defVar}.weapondefs)`);
             if (weaponName !== '*') {
                 this.startIf(`wName == "${weaponName}"`);
             }
             for(const subMut of mut.mutations) {
                 this.generateMutation(subMut, 'wDef', variables);
             }
             if (weaponName !== '*') {
                 this.endBlock();
             }
             this.endBlock();
             this.endBlock();
         }
         else if (mut.op === 'clone_unit') {
             const source = mut.source === 'SELF' ? defVar : `UnitDefs["${mut.source}"]`;
             const targetName = mut.target ? `"${mut.target}"` : (mut.targetSuffix ? `${defVar}.name .. "${mut.targetSuffix}"` : 'nil');
             this.startIf(source);
             this.addLocal('newDef', `table_merge({}, ${source})`);
             if (mut.mutations) {
                 for(const subMut of mut.mutations) {
                     this.generateMutation(subMut, 'newDef', variables);
                 }
             }
             this.addStatement(`UnitDefs[${targetName}] = newDef`);
             this.endBlock();
         }
    }

    private generateConditions(conditions: TweakCondition[], unitNameVar: string, defVar: string, variables: Record<string, any>): string[] {
        const conds: string[] = [];
        for (const cond of conditions) {
            switch (cond.type) {
                case 'nameMatch':
                    conds.push(`string_match(${unitNameVar}, "${cond.regex}")`);
                    break;
                case 'nameNotMatch':
                    conds.push(`not string_match(${unitNameVar}, "${cond.regex}")`);
                    break;
                case 'nameStartsWith': {
                    const prefix = typeof cond.prefix === 'string' ? cond.prefix : this.resolveValueSource(cond.prefix, variables).replace(/"/g, '');
                    if (typeof cond.prefix !== 'string') {
                         const pVal = this.resolveValueSource(cond.prefix, variables);
                         conds.push(`string_sub(${unitNameVar}, 1, string_len(${pVal})) == ${pVal}`);
                    } else {
                        conds.push(`string_sub(${unitNameVar}, 1, ${cond.prefix.length}) == "${cond.prefix}"`);
                    }
                    break;
                }
                case 'nameEndsWith': {
                     if (typeof cond.suffix !== 'string') {
                         const sVal = this.resolveValueSource(cond.suffix, variables);
                         conds.push(`string_sub(${unitNameVar}, -string_len(${sVal})) == ${sVal}`);
                    } else {
                        conds.push(`string_sub(${unitNameVar}, -${cond.suffix.length}) == "${cond.suffix}"`);
                    }
                    break;
                }
                case 'customParam':
                    const val = typeof cond.value === 'object' ? this.resolveValueSource(cond.value, variables) : (typeof cond.value === 'string' ? `"${cond.value}"` : cond.value);
                    conds.push(`((${defVar}.customParams and ${defVar}.customParams["${cond.key}"] == ${val}) or (${defVar}.customparams and ${defVar}.customparams["${cond.key}"] == ${val}))`);
                    break;
                case 'nameInList':
                     const checks = cond.names.map(n => `${unitNameVar} == "${n}"`);
                     conds.push(`(${checks.join(' or ')})`);
                     break;
            }
        }
        return conds;
    }

    private resolveValueSource(val: ValueSource | object, variables: Record<string, any>): string {
        if (typeof val === 'object' && val !== null) {
            if ('type' in val) {
                const typedVal = val as any;
                if (typedVal.type === 'variable') {
                    const v = variables[typedVal.key];
                    if (v === undefined) throw new Error(`Variable ${typedVal.key} not found`);
                    return this.jsonToLua(v);
                }
                if (typedVal.type === 'mod_option') {
                    return `(Spring_GetModOptions().${typedVal.key} or ${this.jsonToLua(typedVal.default)})`;
                }
                if (typedVal.type === 'math') {
                    let expr = typedVal.expression;
                    for (const [k, v] of Object.entries(typedVal.variables)) {
                         expr = expr.split(k).join(this.resolveValueSource(v as ValueSource, variables));
                    }
                    // Map common math functions to localized versions
                    // Note: This relies on emitGlobals picking up 'math.max' if referenced implicitly?
                    // No, emitGlobals scans ValueSource.
                    expr = expr.replace(/\bmax\(/g, 'math_max(')
                        .replace(/\bmin\(/g, 'math_min(')
                        .replace(/\bceil\(/g, 'math_ceil(')
                        .replace(/\bfloor\(/g, 'math_floor(')
                        .replace(/\babs\(/g, 'math_abs(')
                        .replace(/\brandom\(/g, 'math_random(')
                        .replace(/\bsqrt\(/g, 'math_sqrt(');
                    return `(${expr})`;
                }
            }
            return this.jsonToLua(val);
        }
        return this.jsonToLua(val);
    }

    private jsonToLua(obj: any): string {
        if (obj === null || obj === undefined) return 'nil';
        if (typeof obj === 'string') {
            return `"${obj.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n')}"`;
        }
        if (typeof obj === 'number') return obj.toString();
        if (typeof obj === 'boolean') return obj ? 'true' : 'false';
        if (Array.isArray(obj)) {
            return `{ ${obj.map(v => this.jsonToLua(v)).join(', ')} }`;
        }
        return '{}';
    }

    private scanGlobals(inputs: CompilerInput[]) {
        this.usedGlobals.add('pairs');
        this.usedGlobals.add('ipairs');
        this.usedGlobals.add('string.sub');
        this.usedGlobals.add('string.match');
        this.usedGlobals.add('string.len');
        this.usedGlobals.add('table.insert');
        this.usedGlobals.add('math.floor');

        for(const input of inputs) {
            this.scanValueSource(input.tweak, input.variables);
        }
    }

    private scanValueSource(obj: any, vars: Record<string, any>) {
        if (!obj || typeof obj !== 'object') return;
        if (obj.type === 'mod_option') this.usedGlobals.add('Spring.GetModOptions');
        if (obj.type === 'math') {
             // If math expression uses functions, we should add them to usedGlobals
             // Heuristic scan of expression string?
             const expr = obj.expression as string;
             if (expr.includes('max(')) this.usedGlobals.add('math.max');
             if (expr.includes('min(')) this.usedGlobals.add('math.min');
             if (expr.includes('ceil(')) this.usedGlobals.add('math.ceil');
             if (expr.includes('floor(')) this.usedGlobals.add('math.floor');
             if (expr.includes('abs(')) this.usedGlobals.add('math.abs');
             if (expr.includes('random(')) this.usedGlobals.add('math.random');
             if (expr.includes('sqrt(')) this.usedGlobals.add('math.sqrt');
        }
        if (obj.type === 'table_merge' || obj.type === 'clone_unit' || obj.op === 'table_merge' || obj.op === 'clone_unit') {
             this.usedGlobals.add('table.merge');
        }
        for (const k in obj) {
            this.scanValueSource(obj[k], vars);
        }
    }

    private emitGlobals() {
        if (this.usedGlobals.has('Spring.GetModOptions')) {
            this.addLocal('Spring_GetModOptions', 'Spring.GetModOptions');
        }
        if (this.usedGlobals.has('table.merge')) {
             this.addLocal('table_merge', 'table.merge');
        }

        const mapping: Record<string, string> = {
            'pairs': 'pairs',
            'ipairs': 'ipairs',
            'string.sub': 'string_sub',
            'string.match': 'string_match',
            'string.len': 'string_len',
            'table.insert': 'table_insert',
            'math.floor': 'math_floor',
            'math.ceil': 'math_ceil',
            'math.max': 'math_max',
            'math.min': 'math_min',
            'math.abs': 'math_abs',
            'math.random': 'math_random',
            'math.sqrt': 'math_sqrt'
        };

        for (const g of this.usedGlobals) {
            if (mapping[g]) {
                this.addLocal(mapping[g], g);
            }
        }
    }

    // Helper methods
    private getIndent(): string { return '    '.repeat(this.indentLevel); }
    private addStatement(stmt: string) { this.builder.push(this.getIndent() + stmt); }
    private addLocal(name: string, value: string) { this.builder.push(`${this.getIndent()}local ${name} = ${value}`); }
    private startLoop(iterator: string) { this.builder.push(`${this.getIndent()}${iterator} do`); this.indentLevel++; }
    private startIf(condition: string) { this.builder.push(`${this.getIndent()}if ${condition} then`); this.indentLevel++; }
    private addElse() { this.indentLevel--; this.builder.push(`${this.getIndent()}else`); this.indentLevel++; }
    private startBlock(header: string) { this.builder.push(`${this.getIndent()}${header}`); this.indentLevel++; }
    private endBlock() { this.indentLevel--; this.builder.push(`${this.getIndent()}end`); }

    private getFieldRead(defVar: string, fieldPath: string): string {
        const parts = fieldPath.split('.');
        if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
            const paramKey = parts[1];
            return `((${defVar}.customParams and ${defVar}.customParams["${paramKey}"]) or (${defVar}.customparams and ${defVar}.customparams["${paramKey}"]))`;
        }
        return `${defVar}.${fieldPath}`;
    }

    private addFieldWrite(defVar: string, fieldPath: string, valueExpr: string) {
        const parts = fieldPath.split('.');
        if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
            const paramKey = parts[1];
            this.startIf(`${defVar}.customparams`);
            this.addStatement(`${defVar}.customparams["${paramKey}"] = ${valueExpr}`);
            this.addElse();
            this.addStatement(`if not ${defVar}.customParams then ${defVar}.customParams = {} end`);
            this.addStatement(`${defVar}.customParams["${paramKey}"] = ${valueExpr}`);
            this.endBlock();
        } else {
            this.addStatement(`${defVar}.${fieldPath} = ${valueExpr}`);
        }
    }
}
