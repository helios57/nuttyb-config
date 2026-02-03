export type TweakScope = 'UnitDefsLoop' | 'UnitDef_Post';

export type TweakCondition =
  | { type: 'nameMatch'; regex: string }
  | { type: 'nameNotMatch'; regex: string }
  | { type: 'nameStartsWith'; prefix: string }
  | { type: 'nameEndsWith'; suffix: string }
  | { type: 'customParam'; key: string; value: string | number | boolean }
  | { type: 'category'; value: string };

export type MutationOperation =
  | { op: 'multiply'; field: string; factor: number }
  | { op: 'set'; field: string; value: string | number | boolean }
  | { op: 'remove'; field: string }
  | { op: 'assign_math_floor'; target: string; source: string; factor: number };

export interface TweakDefinition {
  name: string;
  description: string;
  scope: TweakScope;
  conditions: TweakCondition[];
  mutations: MutationOperation[];
}
