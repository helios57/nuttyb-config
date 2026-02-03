export type TweakScope = 'UnitDefsLoop' | 'UnitDef_Post';

export type TweakCondition =
  | { type: 'nameMatch'; regex: string }
  | { type: 'nameNotMatch'; regex: string }
  | { type: 'nameStartsWith'; prefix: string }
  | { type: 'nameEndsWith'; suffix: string }
  | { type: 'customParam'; key: string; value: string | number | boolean }
  | { type: 'category'; value: string };

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

export type MutationOperation =
  | { op: 'multiply'; field: UnitDefField; factor: number }
  | { op: 'set'; field: UnitDefField; value: string | number | boolean }
  | { op: 'remove'; field: UnitDefField }
  | { op: 'assign_math_floor'; target: UnitDefField; source: UnitDefField; factor: number }
  | { op: 'list_append'; field: UnitDefField; value: string | number }
  | { op: 'list_remove'; field: UnitDefField; value: string | number }
  | { op: 'table_merge'; field: UnitDefField; value: Record<string, any> };

export interface TweakDefinition {
  name: string;
  description: string;
  scope: TweakScope;
  conditions: TweakCondition[];
  mutations: MutationOperation[];
}
