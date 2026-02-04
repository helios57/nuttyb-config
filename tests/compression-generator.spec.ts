import { generateCompressedUnits } from '../src/mod-logic/unit-generators';
import { MutationOperation } from '../src/mod-logic/tweak-dsl';

describe('Compression Generator', () => {
    test('Should generate compressed variants for Raptors', () => {
        const tweaks = generateCompressedUnits();

        // Find a specific raptor tweak
        const raptorTweak = tweaks.find(t => t.name === 'Generate raptor_land_swarmer_basic_t1_v1_compressed_x10');
        expect(raptorTweak).toBeDefined();

        if (raptorTweak) {
            const cloneOp = raptorTweak.mutations[0];

            if (cloneOp.op !== 'clone_unit') {
                throw new Error('Expected clone_unit op');
            }

            expect(cloneOp.source).toBe('raptor_land_swarmer_basic_t1_v1');
            expect(cloneOp.target).toBe('raptor_land_swarmer_basic_t1_v1_compressed_x10');

            // Check mutations inside clone
            const muts = cloneOp.mutations || [];

            // Health x10
            const hp = muts.find((m: any) => m.op === 'multiply' && m.field === 'health');
            expect(hp).toBeDefined();
            expect((hp as any).factor).toBe(10);

            // Custom Params
            const cp = muts.find((m: MutationOperation) => m.op === 'table_merge' && m.field === 'customParams');
            expect(cp).toBeDefined();
            if (cp && cp.op === 'table_merge') {
                expect(cp.value).toMatchObject({
                    is_compressed_unit: true,
                    compression_factor: 10,
                    color_tint: "1 0.5 0.5"
                });
            }

            // Weapon Damage x10
            const weaponMod = muts.find((m: MutationOperation) => m.op === 'modify_weapon');
            expect(weaponMod).toBeDefined();
            if (weaponMod && weaponMod.op === 'modify_weapon' && weaponMod.mutations) {
                const damage = weaponMod.mutations.find((m: any) => m.op === 'multiply' && m.field === 'damage.default');
                expect((damage as any)?.factor).toBe(10);
            }
        }
    });

    test('Should generate compressed variants for Eco Structures', () => {
        const tweaks = generateCompressedUnits();

        // Find solar collector x5
        const solarTweak = tweaks.find(t => t.name === 'Generate armsolar_compressed_x5');
        expect(solarTweak).toBeDefined();

        if (solarTweak) {
            const cloneOp = solarTweak.mutations[0];
             if (cloneOp.op !== 'clone_unit') {
                throw new Error('Expected clone_unit op');
            }

            const muts = cloneOp.mutations || [];

            // Energy Make x5
            const energy = muts.find((m: any) => m.op === 'multiply' && m.field === 'energyMake');
            expect(energy).toBeDefined();
            expect((energy as any)?.factor).toBe(5);

            // Model Scale
            const cp = muts.find((m: MutationOperation) => m.op === 'table_merge' && m.field === 'customParams');
            expect(cp).toBeDefined();
            if (cp && cp.op === 'table_merge') {
                 // cast value to any because it's object | ValueSource
                 expect((cp.value as any).model_scale).toBe(1.5); // x5 uses 1.5 scale
            }
        }
    });
});
