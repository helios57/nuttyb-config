import { gameConfigs, formOptionsConfig } from './config-data';
import { GameConfigs, RawOptionsData, FormOptionsConfig } from './types';

declare const marked: any;

export async function loadConfigData(): Promise<{ rawOptionsData: RawOptionsData[], formOptionsConfig: FormOptionsConfig[] }> {
    // As per instructions to recreate config data and ignore missing/empty data files.
    // We rely entirely on config-data.ts.
    // rawOptionsData is mainly for the Data View tab. We can leave it empty or populate it
    // based on formOptionsConfig if needed later.
    const rawOptionsData: RawOptionsData[] = [];
    return { rawOptionsData, formOptionsConfig };
}

export async function loadLinksContent(): Promise<string> {
    try {
        const response = await fetch(`links.md?t=${Date.now()}`);
        if (!response.ok) return "";
        const text = await response.text();
        if (typeof marked !== 'undefined' && marked.parse) {
             return marked.parse(text);
        }
        return text;
    } catch (e) {
        console.error("Failed to load links content", e);
        return "";
    }
}

export async function parseModesFile(filePath: string): Promise<GameConfigs> {
    // Return the hardcoded gameConfigs from config-data.ts
    // ignoring the external file content as we have reconstructed the data.
    return gameConfigs;
}
