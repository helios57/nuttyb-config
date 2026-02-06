# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [1.1.0] - 2024-05-21

### Features
* **Optimization:** Implemented "Macro-Optimizations" to reduce simulation lag.
    * **Raptor AI:** Optimized with Time-Slicing (BucketScheduler) and Spatial Partitioning.
    * **Fusion Protocol:** Added "Singularity Fusion" to merge 2x2 static structures (Solar, Wind, Converters, Turrets) into T2-T5 variants.
    * **Eco Culler:** Added "Cash for Clunkers" system to cull low-utility T1 eco structures when SimSpeed is low.
    * **Adaptive Spawner:** Implemented Wave Compression to scale difficulty by Unit Strength instead of Unit Count (FPS/UnitCount based).
* **UI:** Added "Optimization & Scaling" section with toggles for Fusion, Adaptive Spawner, and Culling thresholds.
* **Compiler:** Updated `OptimizedLuaCompiler` to support `clone_unit` and conditional logic for new features.
