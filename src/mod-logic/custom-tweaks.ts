import { CUSTOM_TWEAKS_KEY } from './constants';
import { CustomTweak } from './types';

let customOptions: CustomTweak[] = [];

export function loadCustomOptions(): CustomTweak[] {
    const savedTweaks = localStorage.getItem(CUSTOM_TWEAKS_KEY);
    customOptions = savedTweaks ? JSON.parse(savedTweaks) : [];
    return customOptions;
}

export function saveCustomOptions(options: CustomTweak[]): void {
    customOptions = options;
    localStorage.setItem(CUSTOM_TWEAKS_KEY, JSON.stringify(customOptions));
}

export function addCustomTweak(desc: string, type: string, tweak: string): CustomTweak[] {
    if (!desc || !tweak) return customOptions;
    
    customOptions.push({ id: Date.now(), desc, type, tweak });
    saveCustomOptions(customOptions);
    return customOptions;
}

export function deleteCustomTweak(id: number): CustomTweak[] {
    customOptions = customOptions.filter(tweak => tweak.id !== id);
    saveCustomOptions(customOptions);
    return customOptions;
}

export function getCustomOptions(): CustomTweak[] {
    return customOptions;
}
