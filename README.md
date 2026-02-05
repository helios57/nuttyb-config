# NuttyB Configurator

NuttyB Raptor Configuration Generator for Beyond All Reason

- Code is deployed to https://rcorex.github.io/nuttyb-config/
- Developer Guidelines: See [AGENTS.md](AGENTS.md)

- tweakdata.txt is used for tweaks
- modes.txt is used for base tweaks, maps and modes
- links.md is shown in the Links section

## Configuration Defaults
- **Queen Quantity:** 25
- **Wave Multiplier:** 4x
- **First Waves Boost:** 4x
- **Grace Period Multiplier:** 3x

## Architecture & Performance

This project includes a custom **Lua Tweak DSL** and **Compiler** designed to generate high-performance Lua code for the Spring Engine.

### Lua Tweak DSL
We use a structured TypeScript DSL (`src/mod-logic/tweak-dsl.ts`) to define unit modifications instead of raw strings. This ensures type safety and allows for compile-time validation.

### Lua Compiler & Optimization
The compiler (`src/mod-logic/optimized-compiler.ts`) transforms the DSL into optimized Lua code. Key performance features include:

1.  **Upvalue Optimization**: Standard library functions (e.g., `string.match`, `math.floor`) are localized at the top of the script. This avoids global table lookups inside tight loops, which is critical when iterating over thousands of UnitDefs.
2.  **Efficient String Matching**: Prefix checks use `string.sub` instead of regex (`string.match`), which is significantly faster in Lua.
3.  **Memory Management**: Removal operations set fields to `nil` rather than empty tables to facilitate proper garbage collection.
4.  **Safety Checks**: Generated code includes existence checks (e.g., `if def.health then ...`) to prevent runtime errors during math operations.

### Validation
Generated Lua code is validated using `luaparse` before being presented to the user, ensuring syntax correctness and preventing game crashes.

## Releasing

To create a new release (which updates `CHANGELOG.md`, bumps version, and tags the commit):

1.  Run `npm run release`.
2.  Push changes and tags: `git push --follow-tags`.
3.  Go to GitHub Releases and create a new release using the pushed tag. This will trigger the deployment workflow.
