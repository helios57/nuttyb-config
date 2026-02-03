// Declare luamin as a global variable since it's loaded via script tag
declare const luamin: any;

export function decodeBase64Url(base64Url: string): string {
    if (!base64Url) return '';
    try {
        let base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const padding = base64.length % 4;
        if (padding) base64 += '===='.slice(padding);
        const decodedData = atob(base64);
        const uint8Array = Uint8Array.from(decodedData, c => c.charCodeAt(0));
        return new TextDecoder('utf-8').decode(uint8Array);
    } catch (e) { 
        console.error(`Base64URL decoding failed for: ${base64Url}`, e); 
        return 'Error decoding data'; 
    }
}

// Deprecated: generateLuaTweak is no longer used. Logic moved to command-generator.ts using DSL.
// Keeping empty or removing if no other dependencies.
// Since command-generator.ts was the only consumer (checked previously), we can remove it.
