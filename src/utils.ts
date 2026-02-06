// Utility Functions Module
// General helper and utility functions for BAR Configurator

export function withAssetVersion(url: string): string {
    const ASSET_CACHE_BUSTER = (window as any).ASSET_CACHE_BUSTER || Date.now().toString();
    const resolvedUrl = new URL(url, window.location.href);
    resolvedUrl.searchParams.set('v', ASSET_CACHE_BUSTER);
    return resolvedUrl.toString();
}

export async function loadPartial(url: string, targetId: string) {
    try {
        const response = await fetch(withAssetVersion(url));
        if (!response.ok) throw new Error(`Failed to load ${url}`);
        const html = await response.text();
        const target = document.getElementById(targetId);
        if (target) target.innerHTML = html;
    } catch (error) {
        console.error(`Error loading partial ${url}:`, error);
        const target = document.getElementById(targetId);
        if (target) target.innerHTML = `<p style="color: red;">Failed to load ${url}</p>`;
    }
}

export function populateStartSelector(gameConfigs: any, updateOutput: () => void) {
    const startSelect = document.getElementById('modes-select') as HTMLSelectElement;
    if (!startSelect) return;

    const originalValue = startSelect.value;
    startSelect.innerHTML = '';

    if (gameConfigs && gameConfigs.modes) {
        gameConfigs.modes.forEach((mode: any, index: number) => {
            const option = document.createElement('option');
            option.value = index.toString();
            option.textContent = mode.name;
            startSelect.appendChild(option);
        });

        if (Array.from(startSelect.options).some(opt => opt.value === originalValue)) {
            startSelect.value = originalValue;
        } else if (startSelect.options.length > 0) {
            startSelect.selectedIndex = 0;
        }
        startSelect.dataset.defaultValue = startSelect.value || '';
    }

    if (typeof updateOutput === 'function') {
        updateOutput();
    }
}

export async function loadConfigData(parseConfigData: () => void) {
    if (typeof parseConfigData === 'function') {
        parseConfigData();
    }
    console.log("All tweaks loaded from dynamic-tweaks.json");
}

export function decodeBase64Url(base64Url: string): string {
    if (!base64Url) return '';
    try {
        let base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const padding = base64.length % 4;
        if (padding) base64 += '===='.slice(padding);
        const decodedData = atob(base64);
        return new TextDecoder('utf-8').decode(Uint8Array.from(decodedData, c => c.charCodeAt(0)));
    } catch (e) {
        console.error(`Base64URL decoding failed for: ${base64Url}`, e);
        return 'Error decoding data';
    }
}

export function parseConfigData(rawOptionsData: any[], formOptionsConfig: any[]) {
    // Initialize config arrays
    // Note: These are passed by reference or managed globally in the original JS
    // In TS, we should probably return the new arrays or manage state better

    const controlModeGroup = {
        label: "Control Mode", type: "select", column: "left", id: "control-mode-select",
        defaultValue: "custom",
        choices: [
            { label: "Difficulty Mode", value: "difficulty", shortLabel: "Difficulty" },
            { label: "Custom Mode", value: "custom", shortLabel: "Custom" },
        ]
    };
    const difficultyGroup = {
        label: "Difficulty", type: "select", column: "left", id: "difficulty-select",
        defaultValue: "1",
        choices: [
            { label: "x1", value: "1", shortLabel: "Dx1" },
            { label: "x2", value: "2", shortLabel: "Dx2" },
            { label: "x3", value: "3", shortLabel: "Dx3" },
            { label: "x4", value: "4", shortLabel: "Dx4" },
            { label: "x5", value: "5", shortLabel: "Dx5" },
            { label: "x6", value: "6", shortLabel: "Dx6" },
            { label: "x7", value: "7", shortLabel: "Dx7" },
            { label: "x8", value: "8", shortLabel: "Dx8" },
            { label: "x9", value: "9", shortLabel: "Dx9" },
            { label: "x10", value: "10", shortLabel: "Dx10" },
        ]
    };
    const dynamicHPGroup = {
        label: "Raptor Health", type: "select", isHpGenerator: true, hpType: 'hp', column: 'left',
        defaultValue: "1.3",
        choices: [
            { label: "Default", value: "", shortLabel: "" }, { label: "1x RHP", value: "1", shortLabel: "1xRHP" },
            { label: "1.3x RHP", value: "1.3", shortLabel: "1_3xRHP" }, { label: "1.5x RHP", value: "1.5", shortLabel: "1_5xRHP" },
            { label: "1.7x RHP", value: "1.7", shortLabel: "1_7xRHP" }, { label: "2x RHP", value: "2", shortLabel: "2xRHP" },
            { label: "2.5x RHP", value: "2.5", shortLabel: "2_5xRHP" }, { label: "3x RHP", value: "3", shortLabel: "3xRHP" },
            { label: "4x RHP", value: "4", shortLabel: "4xRHP" }, { label: "5x RHP", value: "5", shortLabel: "5xRHP" },
        ]
    };
    const dynamicQHPGroup = {
        label: "Queen Health", type: "select", isHpGenerator: true, hpType: 'qhp', column: 'left',
        defaultValue: "1.3",
        choices: [
             { label: "Default", value: "", shortLabel: "" }, { label: "1x QHP", value: "1", shortLabel: "1xQHP" },
             { label: "1.3x QHP", value: "1.3", shortLabel: "1_3xQHP" }, { label: "1.5x QHP", value: "1.5", shortLabel: "1_5xQHP" },
             { label: "1.7x QHP", value: "1.7", shortLabel: "1_7xQHP" }, { label: "2x QHP", value: "2", shortLabel: "2xQHP" },
             { label: "2.5x QHP", value: "2.5", shortLabel: "2_5xQHP" }, { label: "3x QHP", value: "3", shortLabel: "3xQHP" },
             { label: "4x QHP", value: "4", shortLabel: "4xQHP" }, { label: "5x QHP", value: "5", shortLabel: "5xQHP" },
        ]
    };

    formOptionsConfig.push(controlModeGroup, difficultyGroup, dynamicHPGroup, dynamicQHPGroup);
    console.log(`Loaded ${formOptionsConfig.length} total options`);
}

export function encodeBase64Url(text: string, skipMinify: boolean = false): string {
    try {
        let textToEncode = text;
        // Assuming LuaMinifier is globally available or imported
        if (!skipMinify && (window as any).LuaMinifier && typeof (window as any).LuaMinifier.minify === 'function') {
            try {
                textToEncode = (window as any).LuaMinifier.minify(text);
                const stats = (window as any).LuaMinifier.getStats(text, textToEncode);
                console.log(`LuaMinifier: ${stats.originalSize} chars -> ${stats.minifiedSize} chars (${stats.reduction}% reduction, saved ${stats.saved} bytes)`);
            } catch (minifyError: any) {
                console.warn("Minification failed, using original text:", minifyError.message);
                textToEncode = text;
            }
        }

        const utf8Bytes = new TextEncoder().encode(textToEncode);
        const latin1String = Array.from(utf8Bytes, byte => String.fromCharCode(byte)).join('');
        return btoa(latin1String)
            .replace(/\+/g, '-')
            .replace(/\//g, '_')
            .replace(/=/g, '');
    } catch (e) {
        console.error("Encoding error:", e);
        return btoa(text)
            .replace(/\+/g, '-')
            .replace(/\//g, '_')
            .replace(/=/g, '');
    }
}

export function createCommandCell(cell: HTMLElement, commandText: string, buttonText: string = 'Copy') {
    const wrapper = document.createElement('div');
    wrapper.className = 'command-cell-wrapper';

    const textSpan = document.createElement('span');
    textSpan.className = 'command-text';
    textSpan.textContent = commandText;
    textSpan.title = commandText;

    const copyBtn = document.createElement('button');
    copyBtn.textContent = buttonText;
    copyBtn.className = 'copy-row-button';
    copyBtn.dataset.command = commandText;

    wrapper.appendChild(textSpan);
    wrapper.appendChild(copyBtn);
    cell.appendChild(wrapper);
}

export function findAvailableSlot(usedSlots: Set<number>, possibleSlots: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9]): number | null {
    for (const slot of possibleSlots) {
        if (!usedSlots.has(slot)) {
            return slot;
        }
    }
    return null;
}

export async function loadLinksContent() {
    // Placeholder for loadLinksContent
    console.log('loadLinksContent called');
}
