
import { generateLuaTweak, decodeBase64Url } from '../src/mod-logic/utils';
import { getTweakDefs2 } from '../src/mod-logic/tweak-definitions';
import { compileTweak } from '../src/mod-logic/lua-compiler';

// Mock luamin
(global as any).luamin = {
    minify: (code: string) => code.replace(/\s+/g, ' ').trim() // Simple mock minifier
};

describe('Migration Verification', () => {
    test('getTweakDefs2 returns valid definition', () => {
        const def = getTweakDefs2();
        expect(def).toBeDefined();
        expect(def.name).toContain('Main tweakdefs');
        expect(def.scope).toBe('Global');
        expect(def.mutations).toHaveLength(1);
        expect(def.mutations[0].op).toBe('raw_lua');
    });

    test('compileTweak handles raw_lua', () => {
        const def = getTweakDefs2();
        const lua = compileTweak(def);
        expect(lua).toContain('NuttyB v1.52bb Def Main');
        expect(lua).toContain('UnitDefs');
    });

    test('generateLuaTweak handles qhp', () => {
        const result = generateLuaTweak('qhp', '2');
        expect(result).not.toContain('Error');
        const decoded = decodeBase64Url(result);
        expect(decoded).toContain('raptor_queen_');
        expect(decoded).toContain('health * 2');
    });

    test('generateLuaTweak handles boss', () => {
        const result = generateLuaTweak('boss', '1.5');
        expect(result).not.toContain('Error');
        const decoded = decodeBase64Url(result);
        expect(decoded).toContain('scavengerbossv4');
        expect(decoded).toContain('health * 1.5');
    });

    test('generateLuaTweak handles hp (complex)', () => {
        const result = generateLuaTweak('hp', '1.3');
        expect(result).not.toContain('Error');
        const decoded = decodeBase64Url(result);
        expect(decoded).toContain('raptor_land_swarmer_heal');
        // Check derived values for 1.3 -> workertime 0.5, metalCostFactor 0.576923077
        expect(decoded).toContain('buildSpeed * 0.5'); 
        expect(decoded).toContain('0.576923077');
    });

    test('generateLuaTweak handles scav', () => {
        const result = generateLuaTweak('scav', '3');
        expect(result).not.toContain('Error');
        const decoded = decodeBase64Url(result);
        expect(decoded).toContain('_scav');
        expect(decoded).toContain('health * 3');
    });
    
    test('Generated code should be minified (mocked)', () => {
         const result = generateLuaTweak('boss', '1.5');
         const decoded = decodeBase64Url(result);
         // The mock minifier replaces newlines with spaces. 
         // Check that we don't have multiple newlines or indentation that LuaBlockBuilder produces by default.
         expect(decoded).not.toContain('\n    ');
    });
});
