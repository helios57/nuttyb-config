import { luaQhpTemplate, luaHpTemplate, luaBossHpTemplate, luaScavHpTemplate } from './lua-templates';

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

export function generateLuaTweak(type: string, multiplierValue: string): string {
    let originalCode: string = '';
    
    if (typeof luamin === 'undefined') {
        console.error("luamin library not loaded yet!");
        return "Error: Lib not loaded";
    }

    if (type === 'qhp') { // Raptor Queen HP
        originalCode = luaQhpTemplate
            .replace(/__MULTIPLIER_TEXT__/g, multiplierValue)
            .replace(/__HEALTH_MULTIPLIER__/g, multiplierValue);
    } else if (type === 'hp') { // Raptor HP
        const multiplierNum = parseFloat(multiplierValue);
        let metalCostFactor: string;
        let workerTimeMultiplier: string;

        switch (multiplierNum) {
            case 1.3: metalCostFactor = '0.576923077'; workerTimeMultiplier = '0.5'; break;
            case 1.5: metalCostFactor = '0.466666667'; workerTimeMultiplier = '0.5'; break;
            case 1.7: metalCostFactor = '0.411764706'; workerTimeMultiplier = '0.5'; break;
            case 2:   metalCostFactor = '0.35';        workerTimeMultiplier = '0.5'; break;
            case 2.5: metalCostFactor = '0.3';         workerTimeMultiplier = '0.6'; break;
            case 3:   metalCostFactor = '0.25';        workerTimeMultiplier = '0.55'; break;
            case 4:   metalCostFactor = '0.1875';      workerTimeMultiplier = '0.45'; break;
            case 5:   metalCostFactor = '0.15';        workerTimeMultiplier = '0.25'; break;
            default:  metalCostFactor = '1';           workerTimeMultiplier = '0.5'; break; 
        }
        originalCode = luaHpTemplate
            .replace(/__MULTIPLIER_TEXT__/g, multiplierValue)
            .replace(/__HEALTH_MULTIPLIER__/g, multiplierValue)
            .replace(/__METAL_COST_FACTOR__/g, metalCostFactor)
            .replace(/__WORKERTIME_MULTIPLIER__/g, workerTimeMultiplier);
    } else if (type === 'boss') { // Boss HP
            originalCode = luaBossHpTemplate
            .replace(/__MULTIPLIER_TEXT__/g, multiplierValue)
            .replace(/__HEALTH_MULTIPLIER__/g, multiplierValue);
    } else if (type === 'scav') { // Scavenger HP
        originalCode = luaScavHpTemplate
            .replace(/__MULTIPLIER_TEXT__/g, multiplierValue)
            .replace(/__HEALTH_MULTIPLIER__/g, multiplierValue);
    }

    try {
        const firstLineComment = originalCode.split('\n')[0];
        const minifiedCode = luamin.minify(originalCode);
        const finalCodeToEncode = firstLineComment + '\n' + minifiedCode;
        const utf8SafeString = unescape(encodeURIComponent(finalCodeToEncode));
        const base64String = btoa(utf8SafeString);
        return base64String.replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
    } catch (e: any) {
        console.error(`Lua Minify Error: ${e.message}`);
        return `Error: ${e.message}`;
    }
}
