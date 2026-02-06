// Tweak Metadata Handler
let tweaksMetadata: any = null;

function getCacheBuster() {
    if (typeof window !== 'undefined' && (window as any).ASSET_CACHE_BUSTER) {
        return (window as any).ASSET_CACHE_BUSTER;
    }
    return Date.now();
}

export async function loadTweakMetadata() {
    try {
        const response = await fetch(`tweaks-metadata.json?v=${getCacheBuster()}`);

        if (!response.ok) {
            console.warn('Could not load tweaks-metadata.json, using default names');
            return null;
        }
        tweaksMetadata = await response.json();
        return tweaksMetadata;
    } catch (error) {
        console.warn('Error loading metadata:', error);
        return null;
    }
}

/**
 * Generic getter for tweak metadata fields
 * @param {string} internalName - Internal tweak name
 * @param {string} field - Field to get (display, description, category, author)
 * @param {*} fallback - Fallback value if field not found
 * @returns {*} Field value or fallback
 */
function getTweakMetadataField(internalName: string, field: string, fallback: any) {
    if (!tweaksMetadata || !tweaksMetadata.tweaks[internalName]) {
        return fallback;
    }
    return tweaksMetadata.tweaks[internalName][field] || fallback;
}

export function getTweakDisplayName(internalName: string) {
    return getTweakMetadataField(internalName, 'display', internalName.replace(/_/g, ' '));
}

export function getTweakDescription(internalName: string) {
    return getTweakMetadataField(internalName, 'description', '');
}

export function getTweakCategory(internalName: string) {
    return getTweakMetadataField(internalName, 'category', 'Other');
}

export function getTweakAuthor(internalName: string) {
    return getTweakMetadataField(internalName, 'author', '');
}
