import { TweakDefinition, TweakCondition, MutationOperation, ValueSource, UnitDefField } from './tweak-dsl';

interface CompilerInput {
    tweak: TweakDefinition;
    variables: Record<string, any>;
}

export class OptimizedLuaCompiler {
    private builder: string[] = [];
    private indentLevel: number = 0;
    private usedGlobals = new Set<string>();
    private stringFrequency = new Map<string, number>();
    private internedStrings = new Map<string, string>(); // original -> variableName

    private readonly SHORT_GLOBALS: Record<string, string> = {
        'pairs': 'p',
        'ipairs': 'ip',
        'string.sub': 'ss',
        'string.match': 'sm',
        'string.len': 'sl',
        'table.insert': 'ti',
        'table.remove': 'tr',
        'table.merge': 'tm',
        'math.floor': 'mf',
        'math.ceil': 'mc',
        'math.max': 'mM',
        'math.min': 'mm',
        'math.abs': 'ma',
        'math.random': 'mr',
        'math.sqrt': 'ms',
        'Spring.GetModOptions': 'sgmo'
    };

    compile(inputs: CompilerInput[]): string {
        this.builder = [];
        this.indentLevel = 0;
        this.usedGlobals = new Set<string>();
        this.stringFrequency = new Map<string, number>();
        this.internedStrings = new Map<string, string>();

        // 1. Pre-scan for globals and strings
        this.scanGlobals(inputs);
        this.scanStrings(inputs);

        // 2. Emit Localized Globals and Interned Strings
        this.emitGlobalHeader();

        this.addStatement('');

        // 3. Process Scopes
        const directLookups: { input: CompilerInput, names: string[] }[] = [];
        const loopTweaks: CompilerInput[] = [];
        const postTweaks: CompilerInput[] = [];
        const globalTweaks: CompilerInput[] = [];

        for (const input of inputs) {
            if (input.tweak.scope === 'Global') {
                globalTweaks.push(input);
            } else if (input.tweak.scope === 'UnitDef_Post') {
                postTweaks.push(input);
            } else if (input.tweak.scope === 'UnitDefsLoop') {
                const direct = this.isDirectLookup(input);
                if (direct.isDirect) {
                    directLookups.push({ input, names: direct.names });
                } else {
                    loopTweaks.push(input);
                }
            }
        }

        // 4. Generate Global Tweaks
        if (globalTweaks.length > 0) {
            for (const input of globalTweaks) {
                for (const mut of input.tweak.mutations) {
                    this.generateMutation(mut, '_G', input.variables);
                }
            }
        }

        // 5. Generate Direct Lookups
        if (directLookups.length > 0) {
            for (const { input, names } of directLookups) {
                // Filter out the name condition we used for lookup
                const otherConditions = input.tweak.conditions.filter(c =>
                    !(c.type === 'nameInList') &&
                    !(c.type === 'nameMatch' && names.length === 1 && c.regex === `^${names[0]}$`)
                );

                for (const unitName of names) {
                    this.startIf(`UnitDefs["${unitName}"]`);
                    this.addLocal('def', `UnitDefs["${unitName}"]`);
                    this.addLocal('name', `"${unitName}"`);

                    const conds = this.generateConditions(otherConditions, 'name', 'def', input.variables);
                    if (conds.length > 0) {
                        this.startIf(conds.join(' and '));
                    }

                    for (const mut of input.tweak.mutations) {
                        this.generateMutation(mut, 'def', input.variables);
                    }

                    if (conds.length > 0) {
                        this.endBlock();
                    }
                    this.endBlock();
                }
            }
        }

        // 6. Generate UnitDefs Loop (Loop Fusion)
        if (loopTweaks.length > 0) {
            this.startLoop(`for id, def in ${this.getGlobalAlias('pairs')}(UnitDefs)`);
            this.addLocal('name', 'def.name or id');

            let currentGroup: { inputs: CompilerInput[], conditions: string[] } | null = null;

            for (const input of loopTweaks) {
                const conds = this.generateConditions(input.tweak.conditions, 'name', 'def', input.variables);
                const condKey = conds.join(' && ');

                // Prevent duplication by checking if input is already in currentGroup (simple check)
                // Actually, if condKey matches, we append.

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
                mergedMutations.push(item);
            } else {
                mergedMutations.push(item);
            }
        }

        // Use pendingMultiplies to group consecutive multiplies
        const pendingMultiplies = new Map<string, string[]>();

        const emitPendingMultiply = (field: string, factors: string[]) => {
            const factorExpr = factors.join(' * ');
            const parts = field.split('.');
            if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
                 const paramKey = parts[1];
                 const keyAccess = this.getInternedOrLiteral(paramKey);
                 // Using interned key
                 this.startIf(`${defVar}.customparams and ${defVar}.customparams[${keyAccess}]`);
                 this.addStatement(`${defVar}.customparams[${keyAccess}] = ${defVar}.customparams[${keyAccess}] * (${factorExpr})`);
                 this.addElse();
                 this.startIf(`${defVar}.customParams and ${defVar}.customParams[${keyAccess}]`);
                 this.addStatement(`${defVar}.customParams[${keyAccess}] = ${defVar}.customParams[${keyAccess}] * (${factorExpr})`);
                 this.endBlock();
                 this.endBlock();
            } else {
                 this.addStatement(`${defVar}.${field} = ${defVar}.${field} * (${factorExpr})`);
            }
        };

        const flushPending = (field?: string) => {
            if (field) {
                if (pendingMultiplies.has(field)) {
                    emitPendingMultiply(field, pendingMultiplies.get(field)!);
                    pendingMultiplies.delete(field);
                }
            } else {
                for (const [f, factors] of pendingMultiplies) {
                    emitPendingMultiply(f, factors);
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
         } else if (mut.op === 'multiply') {
             const factor = this.resolveValueSource(mut.factor, variables);
             this.addFieldWrite(defVar, mut.field, `${this.getFieldRead(defVar, mut.field)} * (${factor})`);
         } else if (mut.op === 'remove') {
             this.addFieldWrite(defVar, mut.field, 'nil');
         } else if (mut.op === 'assign_math_floor') {
             const readExpr = this.getFieldRead(defVar, mut.source);
             this.startIf(readExpr);
             const factor = this.resolveValueSource(mut.factor, variables);
             this.addFieldWrite(defVar, mut.target, `${this.getGlobalAlias('math.floor')}(${readExpr} * ${factor})`);
             this.endBlock();
         } else if (mut.op === 'list_append') {
             const val = this.resolveValueSource(mut.value, variables);
             const listVar = 'target_list';
             this.addLocal(listVar, this.getFieldRead(defVar, mut.field));
             this.startIf(`not ${listVar}`);
             const parts = mut.field.split('.');
             if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
                 const keyAccess = this.getInternedOrLiteral(parts[1]);
                 this.addStatement(`${defVar}.customparams = ${defVar}.customparams or {}`);
                 this.addStatement(`${defVar}.customparams[${keyAccess}] = {}`);
                 this.addStatement(`${listVar} = ${defVar}.customparams[${keyAccess}]`);
             } else {
                 this.addStatement(`${defVar}.${mut.field} = {}`);
                 this.addStatement(`${listVar} = ${defVar}.${mut.field}`);
             }
             this.endBlock();
             this.addStatement(`${this.getGlobalAlias('table.insert')}(${listVar}, ${val})`);
         }
         else if (mut.op === 'modify_weapon') {
             const weaponName = mut.weaponName || '*';
             this.startIf(`${defVar}.weapondefs`);
             this.startLoop(`for wName, wDef in ${this.getGlobalAlias('pairs')}(${defVar}.weapondefs)`);
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
         else if (mut.op === 'table_merge') {
             const parts = (mut.field as string).split('.');
             const isSimpleObject = this.isUnrollable(mut.value);

             if (isSimpleObject) {
                 // Optimized Unrolling
                 const obj = mut.value as Record<string, any>;
                 const keys = Object.keys(obj);

                 if (parts[0].toLowerCase() === 'customparams') {
                     // Special handling for customparams
                     let targetExpr = `${defVar}.customparams`;

                     if (parts.length > 1) {
                         const paramKey = parts[1];
                         const keyAccess = this.getInternedOrLiteral(paramKey);
                         // Ensure sub-table exists
                         this.startIf(`${defVar}.customparams`);
                             this.addStatement(`if not ${defVar}.customparams[${keyAccess}] then ${defVar}.customparams[${keyAccess}] = {} end`);
                         this.addElse();
                             this.addStatement(`if not ${defVar}.customParams then ${defVar}.customParams = {} end`);
                             this.addStatement(`if not ${defVar}.customParams[${keyAccess}] then ${defVar}.customParams[${keyAccess}] = {} end`);
                         this.endBlock();

                         // Determine where we are writing
                         const tableVar = 'target_table';
                         this.addLocal(tableVar, `(${defVar}.customparams and ${defVar}.customparams[${keyAccess}]) or ${defVar}.customParams[${keyAccess}]`);

                         for (const k of keys) {
                             const v = this.resolveValueSource(obj[k], variables);
                             const kAccess = this.getInternedOrLiteral(k);
                             this.addStatement(`${tableVar}[${kAccess}] = ${v}`);
                         }
                     } else {
                         // Root customparams
                         // Efficient aliasing
                         const cpVar = 'cp';
                         this.addLocal(cpVar, `${defVar}.customparams`);
                         this.startIf(`not ${cpVar}`);
                             this.startIf(`${defVar}.customParams`);
                                 this.addStatement(`${cpVar} = ${defVar}.customParams`);
                                 this.addStatement(`${defVar}.customparams = ${cpVar}`);
                             this.addElse();
                                 this.addStatement(`${cpVar} = {}`);
                                 this.addStatement(`${defVar}.customparams = ${cpVar}`);
                             this.endBlock();
                         this.endBlock();

                         for (const k of keys) {
                             const v = this.resolveValueSource(obj[k], variables);
                             const kAccess = this.getInternedOrLiteral(k);
                             this.addStatement(`${cpVar}[${kAccess}] = ${v}`);
                         }
                     }
                 } else {
                     // General field unrolling
                     const val = this.resolveValueSource(mut.value, variables); // Only used if we fallback, but here we loop
                     // Ensure root exists
                     const keyAccess = this.getInternedOrLiteral(mut.field as string);
                     // Note: getInternedOrLiteral handles the field name, but for full path 'a.b' it doesn't split.
                     // The DSL assumes 'field' is a path. But for table_merge logic in general usage, usually it is 1 level deep or we assume existence?
                     // Existing code: `if not def.field then def.field = {} end`

                     // If field is complex path 'a.b', checking existence is harder.
                     // But assuming simple field for optimization is safer.

                     if (parts.length === 1) {
                         // Simple field
                         this.addStatement(`if not ${defVar}[${keyAccess}] then ${defVar}[${keyAccess}] = {} end`);
                         const tVar = 't';
                         this.addLocal(tVar, `${defVar}[${keyAccess}]`);
                         for (const k of keys) {
                             const v = this.resolveValueSource(obj[k], variables);
                             const kAccess = this.getInternedOrLiteral(k);
                             this.addStatement(`${tVar}[${kAccess}] = ${v}`);
                         }
                     } else {
                         // Complex path - fallback to table.merge for safety or implement deep check?
                         // Fallback
                         const val = this.resolveValueSource(mut.value, variables);
                         this.addStatement(`if not ${defVar}.${mut.field} then ${defVar}.${mut.field} = {} end`);
                         this.addStatement(`${this.getGlobalAlias('table.merge')}(${defVar}.${mut.field}, ${val})`);
                     }
                 }
             } else {
                 // Fallback to table.merge
                 const val = this.resolveValueSource(mut.value, variables);

                 // Ensure target exists
                 if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
                      const paramKey = parts[1];
                      const keyAccess = this.getInternedOrLiteral(paramKey);
                      this.addStatement(`if not ${defVar}.customparams then ${defVar}.customparams = {} end`);
                      this.addStatement(`if not ${defVar}.customparams[${keyAccess}] then ${defVar}.customparams[${keyAccess}] = {} end`);
                      this.addStatement(`${this.getGlobalAlias('table.merge')}(${defVar}.customparams[${keyAccess}], ${val})`);
                 } else {
                     this.addStatement(`if not ${defVar}.${mut.field} then ${defVar}.${mut.field} = {} end`);
                     this.addStatement(`${this.getGlobalAlias('table.merge')}(${defVar}.${mut.field}, ${val})`);
                 }
             }
         }
         else if (mut.op === 'list_remove') {
             const val = this.resolveValueSource(mut.value, variables);
             const listVar = 'target_list';
             this.addLocal(listVar, this.getFieldRead(defVar, mut.field as string));
             this.startIf(listVar);
             this.startLoop(`for i = #(${listVar}), 1, -1`);
             this.startIf(`${listVar}[i] == ${val}`);
             this.addStatement(`${this.getGlobalAlias('table.remove')}(${listVar}, i)`);
             this.endBlock();
             this.endBlock();
             this.endBlock();
         }
         else if (mut.op === 'clone_unit') {
             const source = mut.source === 'SELF' ? defVar : `UnitDefs["${mut.source}"]`;
             const targetName = mut.target ? `"${mut.target}"` : (mut.targetSuffix ? `${defVar}.name .. "${mut.targetSuffix}"` : 'nil');
             this.startIf(source);
             this.addLocal('newDef', `${this.getGlobalAlias('table.merge')}({}, ${source})`);
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
                    conds.push(`${this.getGlobalAlias('string.match')}(${unitNameVar}, "${this.escapeLuaString(cond.regex)}")`);
                    break;
                case 'nameNotMatch':
                    conds.push(`not ${this.getGlobalAlias('string.match')}(${unitNameVar}, "${this.escapeLuaString(cond.regex)}")`);
                    break;
                case 'nameStartsWith': {
                    const prefix = typeof cond.prefix === 'string' ? cond.prefix : this.resolveValueSource(cond.prefix, variables).replace(/"/g, '');
                    if (typeof cond.prefix !== 'string') {
                         const pVal = this.resolveValueSource(cond.prefix, variables);
                         conds.push(`${this.getGlobalAlias('string.sub')}(${unitNameVar}, 1, ${this.getGlobalAlias('string.len')}(${pVal})) == ${pVal}`);
                    } else {
                        conds.push(`${this.getGlobalAlias('string.sub')}(${unitNameVar}, 1, ${cond.prefix.length}) == "${this.escapeLuaString(cond.prefix)}"`);
                    }
                    break;
                }
                case 'nameEndsWith': {
                     if (typeof cond.suffix !== 'string') {
                         const sVal = this.resolveValueSource(cond.suffix, variables);
                         conds.push(`${this.getGlobalAlias('string.sub')}(${unitNameVar}, -${this.getGlobalAlias('string.len')}(${sVal})) == ${sVal}`);
                    } else {
                        conds.push(`${this.getGlobalAlias('string.sub')}(${unitNameVar}, -${cond.suffix.length}) == "${this.escapeLuaString(cond.suffix)}"`);
                    }
                    break;
                }
                case 'customParam':
                    const val = typeof cond.value === 'object' ? this.resolveValueSource(cond.value, variables) : (typeof cond.value === 'string' ? `"${this.escapeLuaString(cond.value)}"` : cond.value);
                    const keyAccess = this.getInternedOrLiteral(cond.key);
                    conds.push(`((${defVar}.customParams and ${defVar}.customParams[${keyAccess}] == ${val}) or (${defVar}.customparams and ${defVar}.customparams[${keyAccess}] == ${val}))`);
                    break;
                case 'customParamMatch':
                    const keyAccessMatch = this.getInternedOrLiteral(cond.key);
                    const sm = this.getGlobalAlias('string.match');
                    conds.push(`((${defVar}.customParams and ${defVar}.customParams[${keyAccessMatch}] and ${sm}(${defVar}.customParams[${keyAccessMatch}], "${this.escapeLuaString(cond.regex)}")) or (${defVar}.customparams and ${defVar}.customparams[${keyAccessMatch}] and ${sm}(${defVar}.customparams[${keyAccessMatch}], "${this.escapeLuaString(cond.regex)}")))`);
                    break;
                case 'fieldValue':
                    const fVal = typeof cond.value === 'object' ? this.resolveValueSource(cond.value, variables) : (typeof cond.value === 'string' ? `"${cond.value}"` : cond.value);
                    conds.push(`${this.getFieldRead(defVar, cond.field)} == ${fVal}`);
                    break;
                case 'category':
                    const cVal = typeof cond.value === 'object' ? this.resolveValueSource(cond.value, variables) : `"${cond.value}"`;
                    conds.push(`${this.getGlobalAlias('string.match')}(${defVar}.category or "", ${cVal})`);
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
                    return this.jsonToLua(v, variables);
                }
                if (typedVal.type === 'mod_option') {
                    return `(${this.getGlobalAlias('Spring.GetModOptions')}().${typedVal.key} or ${this.jsonToLua(typedVal.default, variables)})`;
                }
                if (typedVal.type === 'math') {
                    let expr = typedVal.expression;
                    for (const [k, v] of Object.entries(typedVal.variables)) {
                         let resolved = this.resolveValueSource(v as ValueSource, variables);
                         if (resolved.startsWith('"') && resolved.endsWith('"')) {
                             const unquoted = resolved.slice(1, -1);
                             if (/^[a-zA-Z_][a-zA-Z0-9_.]*$/.test(unquoted)) {
                                 resolved = unquoted;
                             }
                         }
                         expr = expr.split(k).join(resolved);
                    }
                    const result = this.transformMathExpression(expr);
                    return `(${result.code})`;
                }
            }
            return this.jsonToLua(val, variables);
        }
        return this.jsonToLua(val, variables);
    }

    private transformMathExpression(expr: string): { code: string, globals: Set<string> } {
        const globals = new Set<string>();
        const parts = expr.split(/("(?:\\[\s\S]|[^"])*"|'(?:\\[\s\S]|[^'])*')/g);

        for (let i = 0; i < parts.length; i += 2) {
            parts[i] = parts[i].replace(/\b(max|min|ceil|floor|abs|random|sqrt)(\s*\()/g, (match, func, suffix) => {
                globals.add(`math.${func}`);
                return `${this.SHORT_GLOBALS[`math.${func}`] || 'math.' + func}${suffix}`;
            });
        }

        return { code: parts.join(''), globals };
    }

    private escapeLuaString(str: string): string {
        return str
            .replace(/\\/g, '\\\\')
            .replace(/"/g, '\\"')
            .replace(/\n/g, '\\n')
            .replace(/\r/g, '\\r');
    }

    private jsonToLua(obj: any, variables: Record<string, any>): string {
        if (obj === null || obj === undefined) return 'nil';
        if (typeof obj === 'object' && obj !== null && 'type' in obj && (obj.type === 'variable' || obj.type === 'math' || obj.type === 'mod_option')) {
             return this.resolveValueSource(obj, variables);
        }
        if (typeof obj === 'string') {
            const interned = this.internedStrings.get(obj);
            return interned ? interned : `"${this.escapeLuaString(obj)}"`;
        }
        if (typeof obj === 'number') return obj.toString();
        if (typeof obj === 'boolean') return obj ? 'true' : 'false';
        if (Array.isArray(obj)) {
            return `{ ${obj.map(v => this.jsonToLua(v, variables)).join(', ')} }`;
        }
        if (typeof obj === 'object') {
             const parts: string[] = [];
             for (const k in obj) {
                 if (Object.prototype.hasOwnProperty.call(obj, k)) {
                     const keyAccess = this.getInternedOrLiteral(k);
                     // If it's a bracket access (interned), use [key] = val
                     // If it's a string literal, jsonToLua(k) would be "k", but we might want just k if it's a valid ID
                     // But simpler to always use [k] = v syntax if we support arbitrary keys
                     // However standard Lua is { key = val } for identifiers.
                     // The getInternedOrLiteral returns valid lua expression for key access.
                     // If it is a string literal "key", we can check if it is valid identifier.

                     let keyStr = keyAccess;
                     if (keyStr.startsWith('"') && keyStr.endsWith('"')) {
                         const raw = k;
                         if (/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(raw)) {
                             keyStr = raw;
                         } else {
                             keyStr = `[${keyStr}]`;
                         }
                     } else {
                         // It's a variable or expression
                         keyStr = `[${keyStr}]`;
                     }

                     parts.push(`${keyStr} = ${this.jsonToLua(obj[k], variables)}`);
                 }
             }
             return `{ ${parts.join(', ')} }`;
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

    private scanStrings(inputs: CompilerInput[]) {
        // Helper to count strings
        const count = (str: string) => {
            if (str.length <= 3) return; // Ignore short strings
            this.stringFrequency.set(str, (this.stringFrequency.get(str) || 0) + 1);
        };

        const scanVal = (val: any) => {
            if (typeof val === 'string') count(val);
            else if (typeof val === 'object' && val !== null) {
                if (Array.isArray(val)) val.forEach(scanVal);
                else {
                    for (const k in val) {
                        count(k);
                        scanVal(val[k]);
                    }
                }
            }
        };

        for (const input of inputs) {
            // Scan mutations
            const scanMut = (m: any) => {
                if (m.field) {
                    m.field.split('.').forEach((p: string) => count(p));
                }
                if (m.value) scanVal(m.value);
                if (m.factor) scanVal(m.factor);
                if (m.weaponName) count(m.weaponName);
                if (m.mutations) m.mutations.forEach(scanMut);
                if (m.source && m.source !== 'SELF') count(m.source);
                if (m.target) count(m.target);
            };
            input.tweak.mutations.forEach(scanMut);

            // Scan conditions
            input.tweak.conditions.forEach(c => {
                 if (c.type === 'customParam' || c.type === 'customParamMatch') count(c.key);
                 if (c.type === 'fieldValue') count(c.field);
                 if ('value' in c) scanVal(c.value);
                 // Regexes are usually unique, but maybe check?
            });
        }
    }

    private scanValueSource(obj: any, vars: Record<string, any>) {
        if (!obj || typeof obj !== 'object') return;
        if (obj.type === 'mod_option') this.usedGlobals.add('Spring.GetModOptions');
        if (obj.type === 'math') {
             const result = this.transformMathExpression(obj.expression as string);
             result.globals.forEach(g => this.usedGlobals.add(g));
        }
        if (obj.type === 'table_merge' || obj.type === 'clone_unit' || obj.op === 'table_merge' || obj.op === 'clone_unit') {
             this.usedGlobals.add('table.merge');
        }
        if (obj.op === 'list_remove') {
             this.usedGlobals.add('table.remove');
        }
        for (const k in obj) {
            this.scanValueSource(obj[k], vars);
        }
    }

    private emitGlobalHeader() {
        const emit = (name: string, val: string) => this.addLocal(name, val);

        if (this.usedGlobals.has('Spring.GetModOptions')) {
            emit(this.SHORT_GLOBALS['Spring.GetModOptions'] || 'Spring_GetModOptions', 'Spring.GetModOptions');
        }
        if (this.usedGlobals.has('table.merge')) {
             emit(this.SHORT_GLOBALS['table.merge'] || 'table_merge', 'table.merge');
        }

        const sortedGlobals = Array.from(this.usedGlobals).sort();
        for (const g of sortedGlobals) {
            // We handled these above or they are mapped
            if (g === 'Spring.GetModOptions' || g === 'table.merge') continue;

            if (this.SHORT_GLOBALS[g]) {
                emit(this.SHORT_GLOBALS[g], g);
            }
        }

        // Emit interned strings
        // Filter: len > 3 and count > 10 (using 5 for test based on plan thought, but prompt said 10. I'll stick to 10 but might lower if my test case fails to trigger it).
        // My test case has 11 repeats of "customparams".
        const THRESHOLD = 10;
        const sortedStrings = Array.from(this.stringFrequency.entries())
            .filter(([str, count]) => count > THRESHOLD)
            .sort((a, b) => b[1] - a[1]); // Most frequent first

        for (const [str, count] of sortedStrings) {
            // Generate variable name. k_ + simplified string
            const safeName = 'k_' + str.replace(/[^a-zA-Z0-9_]/g, '_').substring(0, 20);
            this.addLocal(safeName, `"${this.escapeLuaString(str)}"`);
            this.internedStrings.set(str, safeName);
        }
    }

    private getGlobalAlias(global: string): string {
        return this.SHORT_GLOBALS[global] || global.replace('.', '_');
    }

    private getInternedOrLiteral(str: string): string {
        const interned = this.internedStrings.get(str);
        return interned ? interned : `"${this.escapeLuaString(str)}"`;
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
            const keyAccess = this.getInternedOrLiteral(paramKey);
            return `((${defVar}.customParams and ${defVar}.customParams[${keyAccess}]) or (${defVar}.customparams and ${defVar}.customparams[${keyAccess}]))`;
        }

        const keyAccess = this.getInternedOrLiteral(fieldPath);
        if (keyAccess.startsWith('"')) {
            const raw = keyAccess.slice(1, -1);
            if (/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(raw)) {
                return `${defVar}.${raw}`;
            }
        }
        return `${defVar}[${keyAccess}]`;
    }

    private addFieldWrite(defVar: string, fieldPath: string, valueExpr: string) {
        const parts = fieldPath.split('.');
        if (parts[0].toLowerCase() === 'customparams' && parts.length > 1) {
            const paramKey = parts[1];
            const keyAccess = this.getInternedOrLiteral(paramKey);
            this.startIf(`${defVar}.customparams`);
            this.addStatement(`${defVar}.customparams[${keyAccess}] = ${valueExpr}`);
            this.addElse();
            this.addStatement(`if not ${defVar}.customParams then ${defVar}.customParams = {} end`);
            this.addStatement(`${defVar}.customParams[${keyAccess}] = ${valueExpr}`);
            this.endBlock();
        } else {
            const keyAccess = this.getInternedOrLiteral(fieldPath);
            if (keyAccess.startsWith('"')) {
                const raw = keyAccess.slice(1, -1);
                if (/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(raw)) {
                    this.addStatement(`${defVar}.${raw} = ${valueExpr}`);
                } else {
                    this.addStatement(`${defVar}[${keyAccess}] = ${valueExpr}`);
                }
            } else {
                this.addStatement(`${defVar}[${keyAccess}] = ${valueExpr}`);
            }
        }
    }

    private isDirectLookup(input: CompilerInput): { isDirect: boolean, names: string[] } {
        if (input.tweak.scope !== 'UnitDefsLoop') return { isDirect: false, names: [] };

        const nameConds = input.tweak.conditions.filter(c =>
            c.type === 'nameMatch' || c.type === 'nameInList'
        );

        if (nameConds.length !== 1) return { isDirect: false, names: [] };

        const cond = nameConds[0];

        if (cond.type === 'nameInList') {
            return { isDirect: true, names: cond.names };
        }

        if (cond.type === 'nameMatch') {
            // Check if regex is exact match "^name$"
            const match = cond.regex.match(/^\^([a-zA-Z0-9_]+)\$$/);
            if (match) {
                return { isDirect: true, names: [match[1]] };
            }
        }

        return { isDirect: false, names: [] };
    }

    private isUnrollable(value: any): boolean {
        if (typeof value !== 'object' || value === null) return false;
        // If it has 'type' property, it might be a ValueSource, not a simple table
        if ('type' in value && (value.type === 'variable' || value.type === 'math' || value.type === 'mod_option')) {
            return false;
        }
        if (Array.isArray(value)) return false; // array merge logic is different (append vs replace?)

        // Check if all values are also simple or primitives
        // Actually, we can support recursion if we implemented recursive unrolling,
        // but for now we only support 1 level unrolling as per my implementation in generateMutation.
        // My implementation iterates keys and resolves values.
        // If value is a nested object, resolveValueSource converts it to Lua table string.
        // So `t[k] = { ... }`. This overwrites if t[k] existed as a table.
        // table.merge would merge.
        // So we can ONLY unroll if the values are PRIMITIVES (or simple arrays/objects that we treat as atomic replacements).
        // If a value is an object, and we assign it, we are replacing.
        // If the intention of the Tweak was merging nested tables, this breaks it.
        // So we must check that values are NOT objects (unless we want to overwrite).

        // But table.merge is often used to add fields.
        // If I have { tag = "commander" }, value is string. Safe.
        // If I have { weapons = { ... } }, value is object. Assigning it overwrites existing weapons table?
        // Yes.
        // So isUnrollable should return true ONLY if all values are primitives?

        for (const k in value) {
             const v = value[k];
             if (typeof v === 'object' && v !== null) {
                 if ('type' in v) {
                     // variable/math is fine, it resolves to a value.
                     // But does it resolve to a table?
                     // We assume not for safety, or we accept overwrite risk?
                     // Let's be safe: only unroll primitives.
                     // Wait, `ValueSource` can be { type: 'variable' }.
                     // If variable is a number, fine.
                 } else {
                     // Nested object/array.
                     // If we assign `target.k = { ... }`, we overwrite.
                     // table.merge would merge.
                     // So we cannot unroll if there are nested objects.
                     return false;
                 }
             }
        }
        return true;
    }
}
