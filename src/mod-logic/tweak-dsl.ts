export type TweakScope = 'UnitDefsLoop' | 'UnitDef_Post' | 'Global';

export type UnitDefKnownField = 
  | 'health' | 'maxDamage' | 'metalCost' | 'energyCost' | 'buildTime' 
  | 'category' | 'description' | 'name' | 'objectName' 
  | 'buildoptions' | 'customParams' | 'mass' | 'speed' 
  | 'autoHeal' | 'canSelfRepair' | 'repairable' | 'canbehealed' 
  | 'reclaimSpeed' | 'stealth' | 'builder' | 'buildSpeed' 
  | 'canAssist' | 'maxThisUnit' | 'noChaseCategory' 
  | 'sightDistance' | 'radarDistance'
  | 'weaponDefs' | 'weapons' | 'sfxtypes'
  | 'explodeAs' | 'selfDestructAs' | 'footprintX' | 'footprintZ';

export type UnitDefField = UnitDefKnownField | (string & {});

export type ValueSource = 
  | string | number | boolean
  | { type: 'mod_option'; key: string; default: number | string | boolean }
  | { type: 'variable'; key: string }
  | { type: 'math'; expression: string; variables: Record<string, any> };

export type TweakCondition =
  | { type: 'nameMatch'; regex: string }
  | { type: 'nameNotMatch'; regex: string }
  | { type: 'nameStartsWith'; prefix: string | ValueSource }
  | { type: 'nameEndsWith'; suffix: string | ValueSource }
  | { type: 'nameInList'; names: string[] }
  | { type: 'customParam'; key: string; value: ValueSource }
  | { type: 'customParamMatch'; key: string; regex: string }
  | { type: 'fieldValue'; field: string; value: ValueSource }
  | { type: 'category'; value: string | ValueSource };

export type MutationOperation =
  | { op: 'multiply'; field: UnitDefField; factor: ValueSource }
  | { op: 'set'; field: UnitDefField; value: ValueSource | object }
  | { op: 'remove'; field: UnitDefField }
  | { op: 'assign_math_floor'; target: UnitDefField; source: UnitDefField; factor: ValueSource }
  | { op: 'list_append'; field: UnitDefField; value: ValueSource }
  | { op: 'list_remove'; field: UnitDefField; value: ValueSource }
  | { op: 'table_merge'; field: UnitDefField; value: Record<string, any> }
  | { op: 'modify_weapon'; weaponName?: string; mutations: MutationOperation[] }
  | { op: 'clone_unit'; source?: string; target?: string; targetSuffix?: string; mutations?: MutationOperation[] };

export interface TweakDefinition {
  name: string;
  description: string;
  scope: TweakScope;
  conditions: TweakCondition[];
  mutations: MutationOperation[];
}
