declare module 'marked' {
    export function parse(markdown: string): string;
}

declare global {
    interface Window {
        ASSET_CACHE_BUSTER?: string;
        LuaMinifier?: {
            minify: (code: string) => string;
            getStats: (original: string, minified: string) => any;
        };
        ConfigDefaults?: any;
        dynamicTweaksConfig?: any;
        allTweaksData?: any;
        gameConfigs?: any;
        slotDistributionData?: any;
        tweakDependencyTable?: any;
        skipInitialCommandGeneration?: boolean;
        suppressOutputDuringStateRestore?: boolean;
        saveStateToStorage?: () => void;
        DEBUG_SLOT_PACKER?: boolean;
        packIntoSlots?: any;
        getSlotSummary?: any;
        SlotLabelUtils?: any;
        PriorityUtils?: any;
    }
}
