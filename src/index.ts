// Main entry point for the application
// This file will import and initialize all necessary modules

import { loadConfigData, parseConfigData, loadLinksContent } from './utils';
import { parseModesFile, loadSlotDistribution, loadTweakDependencies } from './config-loader';
import { loadTweakMetadata } from './metadata';
import { renderOptions } from './ui-renderer';
import { scanAllTweakFiles } from './slot-scanner';
import { generateDynamicCheckboxUI, generateRaptorWaveDropdown } from './ui-generator';
import { updateOutput } from './output-manager';
import { attachEventHandlers } from './event-handlers';
import { init as initDifficultyManager } from './difficulty-manager';

console.log('NuttyB Configurator initialized');

// Global state (to be refactored)
let formOptionsConfig: any[] = [];
let gameConfigs: any = { maps: [], modes: [], base: [], scavengers: [] };
let tweakFileCache: any = null;

// Placeholder functions for now
const renderMultipliers = () => { console.log('renderMultipliers called'); };
const renderAllCustomComponents = () => { console.log('renderAllCustomComponents called'); };

// Default implementation to prevent crashes if modules are missing
(window as any).getMultiplierValues = () => ({});
(window as any).multipliersConfig = [];

async function initializeApp() {
    try {
        // Load configurations
        await loadSlotDistribution();
        await loadTweakDependencies();

        const [parsedConfigs] = await Promise.all([
            parseModesFile('modes.txt'),
            loadConfigData(() => parseConfigData([], formOptionsConfig)),
            loadLinksContent(),
            loadTweakMetadata()
        ]);

        gameConfigs = parsedConfigs;
        (window as any).gameConfigs = gameConfigs; // Expose globally for now
        (window as any).formOptionsConfig = formOptionsConfig; // Expose globally for now

        // Render UI
        renderOptions(formOptionsConfig, gameConfigs, updateOutput, renderMultipliers, renderAllCustomComponents);
        initDifficultyManager({ renderMultipliers, updateOutput });
        generateRaptorWaveDropdown(updateOutput);
        attachEventHandlers(formOptionsConfig);

        // Scan tweaks and generate dynamic UI
        tweakFileCache = await scanAllTweakFiles();
        (window as any).tweakFileCache = tweakFileCache; // Expose globally for now
        if (tweakFileCache && Object.keys(tweakFileCache).length > 0) {
            await generateDynamicCheckboxUI(tweakFileCache, updateOutput);
        }

    } catch (error) {
        console.error("Failed to initialize the configurator:", error);
    }
}

// Start the app
document.addEventListener('DOMContentLoaded', () => {
    if (document.getElementById('left-column')) {
        initializeApp();
    } else {
        document.addEventListener('PartialsLoaded', initializeApp);
    }
});
