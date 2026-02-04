import { generateFusionUnits, generateMegaRaptors } from '../src/mod-logic/unit-generators';

describe('Unit Generators', () => {
    test('generateFusionUnits should generate correct number of tweaks and scaling', () => {
        const tweaks = generateFusionUnits();
        // 8 base units * 4 tiers = 32 tweaks
        expect(tweaks.length).toBe(32);

        const t2Solar = tweaks.find(t => t.mutations.some(m => m.op === 'clone_unit' && m.target === 'armsolar_t2'));
        expect(t2Solar).toBeDefined();

        const cloneOp = t2Solar!.mutations[0] as any;
        expect(cloneOp.op).toBe('clone_unit');
        expect(cloneOp.source).toBe('armsolar');

        // Check mutations inside clone
        const hpMult = cloneOp.mutations.find((m: any) => m.op === 'multiply' && m.field === 'health');
        expect(hpMult.factor).toBe(4.4);

        // Check footprint scaling
        const fpX = cloneOp.mutations.find((m: any) => m.op === 'multiply' && m.field === 'footprintX');
        expect(fpX.factor).toBe(1.5);

        // Check customParams model_scale
        const customParams = cloneOp.mutations.find((m: any) => m.op === 'table_merge' && m.field === 'customParams');
        expect(customParams.value.model_scale).toBe(1.5);
    });

    test('generateMegaRaptors should generate correct number of tweaks', () => {
        const tweaks = generateMegaRaptors();
        // (5 base raptors + 8 eco buildings) * 3 variants = 39 tweaks
        expect(tweaks.length).toBe(39);

        const x2Raptor = tweaks.find(t => t.mutations.some(m => m.op === 'clone_unit' && m.target === 'raptor_land_swarmer_basic_t1_v1_compressed_x2'));
        expect(x2Raptor).toBeDefined();

        const cloneOp = x2Raptor!.mutations[0] as any;
        expect(cloneOp.op).toBe('clone_unit');
        expect(cloneOp.mutations.some((m: any) => m.op === 'multiply' && m.field === 'health' && m.factor === 2)).toBe(true);
    });
});
