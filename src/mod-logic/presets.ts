export interface RaptorTweakConfig {
    multiplierText: string;
    healthMultiplier: number;
    workertimeMultiplier: number;
    metalCostFactor: number;
}

export const PRESET_RAPTOR_DEFAULT: RaptorTweakConfig = {
    multiplierText: "1.0",
    healthMultiplier: 1.0,
    workertimeMultiplier: 1.0,
    metalCostFactor: 1.0
};

export const PRESET_RAPTOR_HARD: RaptorTweakConfig = {
    multiplierText: "2.0",
    healthMultiplier: 2.0,
    workertimeMultiplier: 1.5,
    metalCostFactor: 0.8
};
