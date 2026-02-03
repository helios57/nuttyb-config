# Detailed Prioritized Prompts for AI Developer (Jules)

The following prompts act as a master plan to refactor the NuttyB Configurator, ensuring strict separation of data and logic, optimized Lua generation, and robust verification.

## Phase 1: Data Extraction & Normalization

**Goal:** Create a single, normalized JSON "Source of Truth" from the disparate configuration files.

**Prompt for Jules:**
```markdown
**Task:** Normalize Configuration Data
**Input:** `src/mod-logic/tweak-library.json`, `src/tweaks/*.json`, `src/mod-logic/tweak-dsl.ts`
**Action:**
1.  **Analyze Structures:**
    *   Read `tweak-dsl.ts` to confirm the `TweakDefinition` interface.
    *   `tweak-library.json` is an object where keys are IDs.
    *   `src/tweaks/*.json` are objects containing a `definitions` array.
2.  **Create Normalization Script:**
    *   Write a script (e.g., `scripts/normalize-config.ts`) that reads all these files.
    *   Convert the `tweak-library.json` entries into `TweakDefinition` objects (preserving the ID if needed, or ensuring `name` is unique).
    *   Extract the `definitions` arrays from `src/tweaks/*.json`.
    *   Merge all definitions into a single array.
3.  **Validation:**
    *   Ensure every entry strictly adheres to the `TweakDefinition` type.
    *   Fail if any legacy fields (e.g., `weapon_target` used outside of `modify_weapon` or `set` context improperly) are detected.
4.  **Output:**
    *   Save the result to `master_config_normalized.json`. This file must contain *only* data, no logic.
```

## Phase 2: Optimized Compiler Implementation

**Goal:** Finalize the `OptimizedLuaCompiler` to support all operations and maximize runtime performance (Spring Engine).

**Context:** The current `src/mod-logic/optimized-compiler.ts` is missing handling for `table_merge` and `list_remove`, despite them being in the DSL.

**Prompt for Jules:**
```markdown
**Task:** Complete & Optimize Lua Compiler
**Reference:** `src/mod-logic/optimized-compiler.ts`, `src/mod-logic/tweak-dsl.ts`
**Input:** `master_config_normalized.json`
**Action:**
1.  **Update `OptimizedLuaCompiler`:**
    *   **Implement Missing Opcodes:** Add support for `table_merge` and `list_remove` in the `generateMutation` method.
        *   `table_merge`: Should generate code that recursively merges the value into the target table (use `table.merge` if available in Spring, or generate a helper). The compiler already detects `table.merge` usage, ensure it's emitted.
    *   **Verify Global Localization:** Ensure `emitGlobals` captures all used math functions and string helpers (e.g., `math.floor`, `string.sub`).
2.  **Performance Optimization (Loop Fusion):**
    *   Verify the existing "Loop Fusion" logic (grouping tweaks by condition). Ensure it correctly handles nested conditions or mixed scopes (`UnitDefsLoop` vs `UnitDef_Post`).
3.  **AST Optimization (Pending Multiplies):**
    *   Ensure the `pendingMultiplies` logic correctly merges multiple multiplication factors into a single operation: `def.health = def.health * (1.5 * 2.0)` instead of two separate assignments.
4.  **Minification:**
    *   Ensure the output Lua string has minimal whitespace and no comments to reduce transfer size.
5.  **Execution:**
    *   Create a script `scripts/generate-lua.ts` that loads `master_config_normalized.json`, instantiates the compiler, and writes the output to `dist/tweakdata.lua`.
```

## Phase 3: Verification & Testing Environment

**Goal:** Verify the generated Lua code actually works in a simulated Spring Engine environment using `wasmoon`.

**Prompt for Jules:**
```markdown
**Task:** Create Lua Verification Suite
**Dependencies:** `wasmoon`, `jest`
**Input:** `dist/tweakdata.lua` (generated in Phase 2)
**Action:**
1.  **Create Test File:** Create `tests/integration/lua-execution.test.ts`.
2.  **Mock Spring Environment:**
    *   Initialize `wasmoon`.
    *   Create a global `UnitDefs` table with mock units (e.g., "raptor_queen", "armcom", "raptor_swarmer").
    *   Mock `Spring.GetModOptions()` to return default values.
    *   Mock `table.merge` (standard Spring utility).
3.  **Execute & Assert:**
    *   Load and run the generated `dist/tweakdata.lua`.
    *   **Logic Checks:**
        *   Verify "raptor_queen" health is multiplied correctly.
        *   Verify "armcom" has `customparams` merged (not overwritten).
        *   Verify cloned units (e.g., "raptor_hive_swarmer_basic") exist and have correct properties.
    *   **Safety Checks:**
        *   Ensure the script handles missing fields gracefully (e.g., if a unit lacks `customparams`).
4.  **Performance Benchmark:**
    *   Populate `UnitDefs` with 5000 mock entries.
    *   Measure execution time. Fail if it exceeds 100ms (adjust based on CI).
```

## Phase 4: Compatibility & Safety Checks

**Goal:** Ensure feature parity and safety against Spring Engine quirks.

**Prompt for Jules:**
```markdown
**Task:** Logic Parity & Safety Audit
**Action:**
1.  **CustomParams Handling:**
    *   Verify the generated code checks for both `customParams` and `customparams` (case-insensitivity) when reading, but consistently writes to one (usually `customparams` or preserves existing).
    *   Ensure `table_merge` on `customparams` merges sub-tables correctly if they exist.
2.  **Weapon Modification Safety:**
    *   Verify `modify_weapon` checks if `weapondefs` exists before iterating.
3.  **Cloning Safety:**
    *   Verify `clone_unit` performs a deep copy of the source definition to avoid side effects on the original unit.
4.  **Final Validation:**
    *   Run the full build and test process: `npm test`.
```
