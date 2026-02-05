import { OptimizedLuaCompiler } from './optimized-compiler';
import tweakLibrary from './tweak-library.json';
import { TweakDefinition } from './tweak-dsl';
import luamin from 'luamin';

const library = tweakLibrary as Record<string, TweakDefinition>;

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
        const inputs: { tweak: TweakDefinition, variables: Record<string, any> }[] = [];

        if (type === 'qhp') {
            if (library.qhp) inputs.push({ tweak: library.qhp, variables: { multiplier, multiplierText: value } });
        } else if (type === 'boss') {
             if (library.boss_hp) inputs.push({ tweak: library.boss_hp, variables: { multiplier, multiplierText: value } });
        } else if (type === 'hp') {
             let metalCostFactor = 1;
             let workertimeMultiplier = 0.5;

             switch (multiplier) {
                case 1.3: metalCostFactor = 0.576923077; workertimeMultiplier = 0.5; break;
                case 1.5: metalCostFactor = 0.466666667; workertimeMultiplier = 0.5; break;
                case 1.7: metalCostFactor = 0.411764706; workertimeMultiplier = 0.5; break;
                case 2:   metalCostFactor = 0.35;        workertimeMultiplier = 0.5; break;
                case 2.5: metalCostFactor = 0.3;         workertimeMultiplier = 0.6; break;
                case 3:   metalCostFactor = 0.25;        workertimeMultiplier = 0.55; break;
                case 4:   metalCostFactor = 0.1875;      workertimeMultiplier = 0.45; break;
                case 5:   metalCostFactor = 0.15;        workertimeMultiplier = 0.25; break;
                default:  metalCostFactor = 1;           workertimeMultiplier = 0.5; break;
             }

             if (library.raptor_swarmer_heal) inputs.push({ tweak: library.raptor_swarmer_heal, variables: { workertimeMultiplier, multiplierText: value } });
             if (library.raptor_health) inputs.push({ tweak: library.raptor_health, variables: { healthMultiplier: multiplier, multiplierText: value } });
             if (library.raptor_metal_chase) inputs.push({ tweak: library.raptor_metal_chase, variables: { metalCostFactor, multiplierText: value } });

        } else if (type === 'scav') {
             if (library.scav_hp_health) inputs.push({ tweak: library.scav_hp_health, variables: { multiplier, multiplierText: value } });
             if (library.scav_hp_metal) inputs.push({ tweak: library.scav_hp_metal, variables: { multiplier, multiplierText: value } });
        } else {
            return "Error: Unknown type";
        }

        if (inputs.length > 0) {
             const compiler = new OptimizedLuaCompiler();
             const lua = compiler.compile(inputs);

             let finalLua = lua;
             // Preserve the first line comment if it exists
             const firstLineMatch = lua.match(/^(--.*)\n/);
             const header = firstLineMatch ? firstLineMatch[1] : '';

             // Minify the code
             const minified = luamin.minify(lua);

             // Reattach header if it was there
             finalLua = header ? header + '\n' + minified : minified;

             return encodeBase64Url(finalLua);
        }
    } catch (e) {
        return "Error: " + e;
    }
    return "Error: Unknown type";
}
