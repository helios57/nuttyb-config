// Configuration loading module for BAR Configurator
// Handles loading of modes.txt and links content

function getCacheBuster() {
    if (typeof window !== 'undefined' && (window as any).ASSET_CACHE_BUSTER) {
        return (window as any).ASSET_CACHE_BUSTER;
    }
    return Date.now();
}

export async function parseModesFile(filePath: string) {
    try {
        const response = await fetch(`${filePath}?v=${getCacheBuster()}`);
        if (!response.ok) {
            throw new Error(`Could not load ${filePath}: ${response.statusText}`);
        }
        const text = await response.text();

        const configs: any = { maps: [], modes: [], base: [], scavengers: [] };

        const categoryBlocks = text.split('## CATEGORY:').slice(1);

        for (const block of categoryBlocks) {
            const lines = block.trim().split(/\r?\n/);
            const categoryName = lines.shift()?.trim();
            const content = lines.join('\n').trim();

            if (categoryName === 'base') {
                configs.base = content.split(/\r?\n/).filter(line => line.trim() !== '');
            } else if (categoryName === 'scavengers') {
                configs.scavengers = content.split(/\r?\n/).filter(line => line.trim() !== '');
            } else {
                const items = content.split('---').filter(item => item.trim() !== '');
                for (const item of items) {
                    const itemLines = item.trim().split(/\r?\n/).filter(line => line.trim() !== '');
                    if (itemLines.length === 0) continue;

                    const name = itemLines.shift()?.trim();
                    const commands = itemLines;

                    if (categoryName === 'maps' && configs.maps) {
                        configs.maps.push({ name, commands });
                    } else if (categoryName === 'modes' && configs.modes) {
                        configs.modes.push({ name, commands });
                    }
                }
            }
        }
        return configs;
    } catch (error) {
        console.error("Failed to parse game configs:", error);
        return { maps: [], modes: [], base: [], scavengers: [] };
    }
}

export async function loadSlotDistribution() {
    try {
        const response = await fetch(`slot-distribution.json?v=${getCacheBuster()}`);
        if (!response.ok) {
            console.warn(`Could not load slot-distribution.json: ${response.statusText}`);
            (window as any).slotDistributionData = null;
            return null;
        }
        const data = await response.json();
        (window as any).slotDistributionData = data;
        console.log("Loaded slot distribution schema:", data);
        return data;
    } catch (error) {
        console.warn("Could not load slot-distribution.json:", error);
        (window as any).slotDistributionData = null;
        return null;
    }
}

export async function loadTweakDependencies() {
    try {
        const response = await fetch(`tweak-dependencies.json?v=${getCacheBuster()}`);
        if (!response.ok) {
            console.warn(`Could not load tweak-dependencies.json: ${response.statusText}`);
            (window as any).tweakDependencyTable = null;
            return null;
        }
        const data = await response.json();
        (window as any).tweakDependencyTable = data;
        console.log("Loaded tweak dependency table:", data);
        return data;
    } catch (error) {
        console.warn("Could not load tweak-dependencies.json:", error);
        (window as any).tweakDependencyTable = null;
        return null;
    }
}

export async function loadLinksContent() {
    const linksContentEl = document.getElementById('links-tab');
    if (!linksContentEl) return;
    try {
        const response = await fetch(`links.md?v=${getCacheBuster()}`);
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
        const markdownText = await response.text();
        // Assuming marked is globally available
        linksContentEl.innerHTML = (window as any).marked.parse(markdownText);
    } catch (error) {
        console.error("Could not load links content:", error);
        linksContentEl.innerHTML = '<p style="color: red;">Failed to load content.</p>';
    }
}
