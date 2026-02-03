import { compileTweak } from './lua-compiler';
import { getQhpTweak, getBossHpTweak } from './tweak-definitions';

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

export function encodeBase64Url(str: string): string {
    const utf8SafeString = unescape(encodeURIComponent(str));
    return btoa(utf8SafeString).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
}

export function generateLuaTweak(type: string, value: string): string {
    const multiplier = parseFloat(value);
    if (isNaN(multiplier)) return "Error: Invalid multiplier";

    try {
        let tweak;
        if (type === 'qhp') {
            tweak = getQhpTweak(multiplier, value);
        } else if (type === 'boss') {
             tweak = getBossHpTweak(multiplier, value);
        } else {
            // 'hp' and 'scav' return arrays of tweaks, which cannot be represented as a single base64 string for a single slot easily here.
            // We return a placeholder or error.
            return "Error: Complex tweak (multiple slots)";
        }

        if (tweak) {
             const lua = compileTweak(tweak);
             const utf8SafeString = unescape(encodeURIComponent(lua));
             return btoa(utf8SafeString).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
        }
    } catch (e) {
        return "Error: " + e;
    }
    return "Error: Unknown type";
}
