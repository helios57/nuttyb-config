export type TweakScope = 'UnitDefsLoop' | 'UnitDef_Post' | 'Global';

export type TweakCondition =
  | { type: 'nameMatch'; regex: string }
  | { type: 'nameNotMatch'; regex: string }
  | { type: 'nameStartsWith'; prefix: string }
  | { type: 'nameEndsWith'; suffix: string }
  | { type: 'nameInList'; names: string[] }
  | { type: 'customParam'; key: string; value: string | number | boolean }
  | { type: 'customParamMatch'; key: string; regex: string }
  | { type: 'fieldValue'; field: string; value: string | number | boolean }
  | { type: 'category'; value: string };

export type MutationOperation =
  | { op: 'set'; target: string; value: any; weapon_target?: string | number }
  | { op: 'multiply'; target: string; value: number; weapon_target?: string | number }
  | { op: 'add'; target: string; value: number; weapon_target?: string | number }
  | { op: 'subtract'; target: string; value: number; weapon_target?: string | number }
  | { op: 'divide'; target: string; value: number; weapon_target?: string | number }
  | { op: 'append'; target: string; suffix: string; weapon_target?: string | number }
  | { op: 'prepend'; target: string; prefix: string; weapon_target?: string | number }
  | { op: 'list_append'; target: string; value: any; weapon_target?: string | number }
  | { op: 'list_remove'; target: string; value: any; weapon_target?: string | number }
  | { op: 'table_merge'; target: string; value: Record<string, any>; weapon_target?: string | number }
  | { op: 'clone_unit'; source: string; target: string; mutations?: MutationOperation[] };

export interface TweakDefinition {
  name: string;
  description?: string;
  scope: TweakScope;
  conditions: TweakCondition[];
  mutations: MutationOperation[];
}

export interface BarTweakSchema {
  label: string;
  variable: string;
  generator: string;
  definitions: TweakDefinition[];
}
