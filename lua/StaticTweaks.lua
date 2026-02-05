local tm = table.merge
local ip = ipairs
local mf = math.floor
local p = pairs
local sl = string.len
local sm = string.match
local ss = string.sub
local ti = table.insert
local k_health = "health"
local k_metalCost = "metalCost"
local k_buildTime = "buildTime"
local k_energyCost = "energyCost"
local k_energyMake = "energyMake"
local k_metalMake = "metalMake"
local k_windGenerator = "windGenerator"
local k_damage = "damage"
local k_default = "default"
local k_name = "name"
local k_customParams = "customParams"
local k_model_scale = "model_scale"
local k_footprintX = "footprintX"
local k_footprintZ = "footprintZ"
local k_mass = "mass"
local k_areaOfEffect = "areaOfEffect"
local k_is_compressed_unit = "is_compressed_unit"
local k_compression_factor = "compression_factor"
local k_color_tint = "color_tint"
local k_1_0_5_0_5 = "1 0.5 0.5"
local k_is_fusion_unit = "is_fusion_unit"
local k_fusion_tier = "fusion_tier"
local k_type = "type"
local k_variable = "variable"
if UnitDefs["armsolar"] then
local newDef = tm({}, UnitDefs["armsolar"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Solar Collector T2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 2
cp[k_model_scale] = 1.5
UnitDefs["armsolar_t2"] = newDef
end
if UnitDefs["armsolar_t2"] then
local newDef = tm({}, UnitDefs["armsolar_t2"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Solar Collector T3"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 3
cp[k_model_scale] = 1.5
UnitDefs["armsolar_t3"] = newDef
end
if UnitDefs["armsolar_t3"] then
local newDef = tm({}, UnitDefs["armsolar_t3"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Solar Collector T4"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 4
cp[k_model_scale] = 1.5
UnitDefs["armsolar_t4"] = newDef
end
if UnitDefs["armsolar_t4"] then
local newDef = tm({}, UnitDefs["armsolar_t4"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Solar Collector T5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 5
cp[k_model_scale] = 1.5
UnitDefs["armsolar_t5"] = newDef
end
if UnitDefs["corsolar"] then
local newDef = tm({}, UnitDefs["corsolar"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Solar Collector T2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 2
cp[k_model_scale] = 1.5
UnitDefs["corsolar_t2"] = newDef
end
if UnitDefs["corsolar_t2"] then
local newDef = tm({}, UnitDefs["corsolar_t2"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Solar Collector T3"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 3
cp[k_model_scale] = 1.5
UnitDefs["corsolar_t3"] = newDef
end
if UnitDefs["corsolar_t3"] then
local newDef = tm({}, UnitDefs["corsolar_t3"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Solar Collector T4"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 4
cp[k_model_scale] = 1.5
UnitDefs["corsolar_t4"] = newDef
end
if UnitDefs["corsolar_t4"] then
local newDef = tm({}, UnitDefs["corsolar_t4"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Solar Collector T5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 5
cp[k_model_scale] = 1.5
UnitDefs["corsolar_t5"] = newDef
end
if UnitDefs["armwin"] then
local newDef = tm({}, UnitDefs["armwin"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Wind Generator T2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 2
cp[k_model_scale] = 1.5
UnitDefs["armwin_t2"] = newDef
end
if UnitDefs["armwin_t2"] then
local newDef = tm({}, UnitDefs["armwin_t2"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Wind Generator T3"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 3
cp[k_model_scale] = 1.5
UnitDefs["armwin_t3"] = newDef
end
if UnitDefs["armwin_t3"] then
local newDef = tm({}, UnitDefs["armwin_t3"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Wind Generator T4"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 4
cp[k_model_scale] = 1.5
UnitDefs["armwin_t4"] = newDef
end
if UnitDefs["armwin_t4"] then
local newDef = tm({}, UnitDefs["armwin_t4"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Wind Generator T5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 5
cp[k_model_scale] = 1.5
UnitDefs["armwin_t5"] = newDef
end
if UnitDefs["corwin"] then
local newDef = tm({}, UnitDefs["corwin"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Wind Generator T2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 2
cp[k_model_scale] = 1.5
UnitDefs["corwin_t2"] = newDef
end
if UnitDefs["corwin_t2"] then
local newDef = tm({}, UnitDefs["corwin_t2"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Wind Generator T3"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 3
cp[k_model_scale] = 1.5
UnitDefs["corwin_t3"] = newDef
end
if UnitDefs["corwin_t3"] then
local newDef = tm({}, UnitDefs["corwin_t3"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Wind Generator T4"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 4
cp[k_model_scale] = 1.5
UnitDefs["corwin_t4"] = newDef
end
if UnitDefs["corwin_t4"] then
local newDef = tm({}, UnitDefs["corwin_t4"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Wind Generator T5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 5
cp[k_model_scale] = 1.5
UnitDefs["corwin_t5"] = newDef
end
if UnitDefs["armmakr"] then
local newDef = tm({}, UnitDefs["armmakr"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Metal Maker T2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 2
cp[k_model_scale] = 1.5
UnitDefs["armmakr_t2"] = newDef
end
if UnitDefs["armmakr_t2"] then
local newDef = tm({}, UnitDefs["armmakr_t2"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Metal Maker T3"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 3
cp[k_model_scale] = 1.5
UnitDefs["armmakr_t3"] = newDef
end
if UnitDefs["armmakr_t3"] then
local newDef = tm({}, UnitDefs["armmakr_t3"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Metal Maker T4"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 4
cp[k_model_scale] = 1.5
UnitDefs["armmakr_t4"] = newDef
end
if UnitDefs["armmakr_t4"] then
local newDef = tm({}, UnitDefs["armmakr_t4"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Metal Maker T5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 5
cp[k_model_scale] = 1.5
UnitDefs["armmakr_t5"] = newDef
end
if UnitDefs["cormakr"] then
local newDef = tm({}, UnitDefs["cormakr"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Metal Maker T2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 2
cp[k_model_scale] = 1.5
UnitDefs["cormakr_t2"] = newDef
end
if UnitDefs["cormakr_t2"] then
local newDef = tm({}, UnitDefs["cormakr_t2"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Metal Maker T3"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 3
cp[k_model_scale] = 1.5
UnitDefs["cormakr_t3"] = newDef
end
if UnitDefs["cormakr_t3"] then
local newDef = tm({}, UnitDefs["cormakr_t3"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Metal Maker T4"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 4
cp[k_model_scale] = 1.5
UnitDefs["cormakr_t4"] = newDef
end
if UnitDefs["cormakr_t4"] then
local newDef = tm({}, UnitDefs["cormakr_t4"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Metal Maker T5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 5
cp[k_model_scale] = 1.5
UnitDefs["cormakr_t5"] = newDef
end
if UnitDefs["armllt"] then
local newDef = tm({}, UnitDefs["armllt"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Light Laser Tower T2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 2
cp[k_model_scale] = 1.5
UnitDefs["armllt_t2"] = newDef
end
if UnitDefs["armllt_t2"] then
local newDef = tm({}, UnitDefs["armllt_t2"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Light Laser Tower T3"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 3
cp[k_model_scale] = 1.5
UnitDefs["armllt_t3"] = newDef
end
if UnitDefs["armllt_t3"] then
local newDef = tm({}, UnitDefs["armllt_t3"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Light Laser Tower T4"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 4
cp[k_model_scale] = 1.5
UnitDefs["armllt_t4"] = newDef
end
if UnitDefs["armllt_t4"] then
local newDef = tm({}, UnitDefs["armllt_t4"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Light Laser Tower T5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 5
cp[k_model_scale] = 1.5
UnitDefs["armllt_t5"] = newDef
end
if UnitDefs["corllt"] then
local newDef = tm({}, UnitDefs["corllt"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Light Laser Tower T2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 2
cp[k_model_scale] = 1.5
UnitDefs["corllt_t2"] = newDef
end
if UnitDefs["corllt_t2"] then
local newDef = tm({}, UnitDefs["corllt_t2"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Light Laser Tower T3"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 3
cp[k_model_scale] = 1.5
UnitDefs["corllt_t3"] = newDef
end
if UnitDefs["corllt_t3"] then
local newDef = tm({}, UnitDefs["corllt_t3"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Light Laser Tower T4"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 4
cp[k_model_scale] = 1.5
UnitDefs["corllt_t4"] = newDef
end
if UnitDefs["corllt_t4"] then
local newDef = tm({}, UnitDefs["corllt_t4"])
newDef[k_health] = newDef[k_health] * (16)
newDef[k_metalCost] = newDef[k_metalCost] * (4)
newDef[k_energyCost] = newDef[k_energyCost] * (4)
newDef[k_buildTime] = newDef[k_buildTime] * (4)
newDef[k_energyMake] = newDef[k_energyMake] * (4.2)
newDef[k_metalMake] = newDef[k_metalMake] * (4.2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (4.2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (4.2)
end
end
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
newDef[k_name] = "Light Laser Tower T5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_fusion_unit] = true
cp[k_fusion_tier] = 5
cp[k_model_scale] = 1.5
UnitDefs["corllt_t5"] = newDef
end
if UnitDefs["raptor_land_swarmer_basic_t1_v1"] then
local newDef = tm({}, UnitDefs["raptor_land_swarmer_basic_t1_v1"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "raptor_land_swarmer_basic_t1_v1 x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["raptor_land_swarmer_basic_t1_v1_compressed_x2"] = newDef
end
if UnitDefs["raptor_land_swarmer_basic_t1_v1"] then
local newDef = tm({}, UnitDefs["raptor_land_swarmer_basic_t1_v1"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "raptor_land_swarmer_basic_t1_v1 x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["raptor_land_swarmer_basic_t1_v1_compressed_x5"] = newDef
end
if UnitDefs["raptor_land_swarmer_basic_t1_v1"] then
local newDef = tm({}, UnitDefs["raptor_land_swarmer_basic_t1_v1"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "raptor_land_swarmer_basic_t1_v1 x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["raptor_land_swarmer_basic_t1_v1_compressed_x10"] = newDef
end
if UnitDefs["raptor_land_assault_basic_t2_v1"] then
local newDef = tm({}, UnitDefs["raptor_land_assault_basic_t2_v1"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "raptor_land_assault_basic_t2_v1 x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["raptor_land_assault_basic_t2_v1_compressed_x2"] = newDef
end
if UnitDefs["raptor_land_assault_basic_t2_v1"] then
local newDef = tm({}, UnitDefs["raptor_land_assault_basic_t2_v1"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "raptor_land_assault_basic_t2_v1 x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["raptor_land_assault_basic_t2_v1_compressed_x5"] = newDef
end
if UnitDefs["raptor_land_assault_basic_t2_v1"] then
local newDef = tm({}, UnitDefs["raptor_land_assault_basic_t2_v1"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "raptor_land_assault_basic_t2_v1 x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["raptor_land_assault_basic_t2_v1_compressed_x10"] = newDef
end
if UnitDefs["raptor_air_fighter_basic"] then
local newDef = tm({}, UnitDefs["raptor_air_fighter_basic"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "raptor_air_fighter_basic x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["raptor_air_fighter_basic_compressed_x2"] = newDef
end
if UnitDefs["raptor_air_fighter_basic"] then
local newDef = tm({}, UnitDefs["raptor_air_fighter_basic"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "raptor_air_fighter_basic x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["raptor_air_fighter_basic_compressed_x5"] = newDef
end
if UnitDefs["raptor_air_fighter_basic"] then
local newDef = tm({}, UnitDefs["raptor_air_fighter_basic"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "raptor_air_fighter_basic x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["raptor_air_fighter_basic_compressed_x10"] = newDef
end
if UnitDefs["raptor_hive_swarmer_basic"] then
local newDef = tm({}, UnitDefs["raptor_hive_swarmer_basic"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "raptor_hive_swarmer_basic x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["raptor_hive_swarmer_basic_compressed_x2"] = newDef
end
if UnitDefs["raptor_hive_swarmer_basic"] then
local newDef = tm({}, UnitDefs["raptor_hive_swarmer_basic"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "raptor_hive_swarmer_basic x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["raptor_hive_swarmer_basic_compressed_x5"] = newDef
end
if UnitDefs["raptor_hive_swarmer_basic"] then
local newDef = tm({}, UnitDefs["raptor_hive_swarmer_basic"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "raptor_hive_swarmer_basic x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["raptor_hive_swarmer_basic_compressed_x10"] = newDef
end
if UnitDefs["raptor_hive_assault_basic"] then
local newDef = tm({}, UnitDefs["raptor_hive_assault_basic"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "raptor_hive_assault_basic x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["raptor_hive_assault_basic_compressed_x2"] = newDef
end
if UnitDefs["raptor_hive_assault_basic"] then
local newDef = tm({}, UnitDefs["raptor_hive_assault_basic"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "raptor_hive_assault_basic x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["raptor_hive_assault_basic_compressed_x5"] = newDef
end
if UnitDefs["raptor_hive_assault_basic"] then
local newDef = tm({}, UnitDefs["raptor_hive_assault_basic"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "raptor_hive_assault_basic x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["raptor_hive_assault_basic_compressed_x10"] = newDef
end
if UnitDefs["armsolar"] then
local newDef = tm({}, UnitDefs["armsolar"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "Solar Collector x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["armsolar_compressed_x2"] = newDef
end
if UnitDefs["armsolar"] then
local newDef = tm({}, UnitDefs["armsolar"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "Solar Collector x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["armsolar_compressed_x5"] = newDef
end
if UnitDefs["armsolar"] then
local newDef = tm({}, UnitDefs["armsolar"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "Solar Collector x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["armsolar_compressed_x10"] = newDef
end
if UnitDefs["corsolar"] then
local newDef = tm({}, UnitDefs["corsolar"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "Solar Collector x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["corsolar_compressed_x2"] = newDef
end
if UnitDefs["corsolar"] then
local newDef = tm({}, UnitDefs["corsolar"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "Solar Collector x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["corsolar_compressed_x5"] = newDef
end
if UnitDefs["corsolar"] then
local newDef = tm({}, UnitDefs["corsolar"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "Solar Collector x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["corsolar_compressed_x10"] = newDef
end
if UnitDefs["armwin"] then
local newDef = tm({}, UnitDefs["armwin"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "Wind Generator x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["armwin_compressed_x2"] = newDef
end
if UnitDefs["armwin"] then
local newDef = tm({}, UnitDefs["armwin"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "Wind Generator x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["armwin_compressed_x5"] = newDef
end
if UnitDefs["armwin"] then
local newDef = tm({}, UnitDefs["armwin"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "Wind Generator x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["armwin_compressed_x10"] = newDef
end
if UnitDefs["corwin"] then
local newDef = tm({}, UnitDefs["corwin"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "Wind Generator x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["corwin_compressed_x2"] = newDef
end
if UnitDefs["corwin"] then
local newDef = tm({}, UnitDefs["corwin"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "Wind Generator x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["corwin_compressed_x5"] = newDef
end
if UnitDefs["corwin"] then
local newDef = tm({}, UnitDefs["corwin"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "Wind Generator x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["corwin_compressed_x10"] = newDef
end
if UnitDefs["armmakr"] then
local newDef = tm({}, UnitDefs["armmakr"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "Metal Maker x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["armmakr_compressed_x2"] = newDef
end
if UnitDefs["armmakr"] then
local newDef = tm({}, UnitDefs["armmakr"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "Metal Maker x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["armmakr_compressed_x5"] = newDef
end
if UnitDefs["armmakr"] then
local newDef = tm({}, UnitDefs["armmakr"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "Metal Maker x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["armmakr_compressed_x10"] = newDef
end
if UnitDefs["cormakr"] then
local newDef = tm({}, UnitDefs["cormakr"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "Metal Maker x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["cormakr_compressed_x2"] = newDef
end
if UnitDefs["cormakr"] then
local newDef = tm({}, UnitDefs["cormakr"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "Metal Maker x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["cormakr_compressed_x5"] = newDef
end
if UnitDefs["cormakr"] then
local newDef = tm({}, UnitDefs["cormakr"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "Metal Maker x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["cormakr_compressed_x10"] = newDef
end
if UnitDefs["armllt"] then
local newDef = tm({}, UnitDefs["armllt"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "Light Laser Tower x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["armllt_compressed_x2"] = newDef
end
if UnitDefs["armllt"] then
local newDef = tm({}, UnitDefs["armllt"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "Light Laser Tower x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["armllt_compressed_x5"] = newDef
end
if UnitDefs["armllt"] then
local newDef = tm({}, UnitDefs["armllt"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "Light Laser Tower x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["armllt_compressed_x10"] = newDef
end
if UnitDefs["corllt"] then
local newDef = tm({}, UnitDefs["corllt"])
newDef[k_health] = newDef[k_health] * (2)
newDef[k_metalCost] = newDef[k_metalCost] * (2)
newDef[k_energyCost] = newDef[k_energyCost] * (2)
newDef[k_buildTime] = newDef[k_buildTime] * (2)
newDef[k_mass] = newDef[k_mass] * (2)
newDef[k_energyMake] = newDef[k_energyMake] * (2)
newDef[k_metalMake] = newDef[k_metalMake] * (2)
newDef[k_windGenerator] = newDef[k_windGenerator] * (2)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (2)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (1.4142135623730951)
end
end
newDef[k_name] = "Light Laser Tower x2"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 2
cp[k_model_scale] = 1.2
cp[k_color_tint] = k_1_0_5_0_5
UnitDefs["corllt_compressed_x2"] = newDef
end
if UnitDefs["corllt"] then
local newDef = tm({}, UnitDefs["corllt"])
newDef[k_health] = newDef[k_health] * (5)
newDef[k_metalCost] = newDef[k_metalCost] * (5)
newDef[k_energyCost] = newDef[k_energyCost] * (5)
newDef[k_buildTime] = newDef[k_buildTime] * (5)
newDef[k_mass] = newDef[k_mass] * (5)
newDef[k_energyMake] = newDef[k_energyMake] * (5)
newDef[k_metalMake] = newDef[k_metalMake] * (5)
newDef[k_windGenerator] = newDef[k_windGenerator] * (5)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (5)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (2.23606797749979)
end
end
newDef[k_name] = "Light Laser Tower x5"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 5
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["corllt_compressed_x5"] = newDef
end
if UnitDefs["corllt"] then
local newDef = tm({}, UnitDefs["corllt"])
newDef[k_health] = newDef[k_health] * (10)
newDef[k_metalCost] = newDef[k_metalCost] * (10)
newDef[k_energyCost] = newDef[k_energyCost] * (10)
newDef[k_buildTime] = newDef[k_buildTime] * (10)
newDef[k_mass] = newDef[k_mass] * (10)
newDef[k_energyMake] = newDef[k_energyMake] * (10)
newDef[k_metalMake] = newDef[k_metalMake] * (10)
newDef[k_windGenerator] = newDef[k_windGenerator] * (10)
if newDef.weapondefs then
for wName, wDef in p(newDef.weapondefs) do
wDef.damage.default = wDef.damage.default * (10)
wDef[k_areaOfEffect] = wDef[k_areaOfEffect] * (3.1622776601683795)
end
end
newDef[k_name] = "Light Laser Tower x10"
local cp = newDef.customparams
if not cp then
if newDef.customParams then
cp = newDef.customParams
newDef.customparams = cp
else
cp = {}
newDef.customparams = cp
end
end
cp[k_is_compressed_unit] = true
cp[k_compression_factor] = 10
cp[k_model_scale] = 1.5
cp[k_color_tint] = k_1_0_5_0_5
newDef[k_footprintX] = newDef[k_footprintX] * (1.5)
newDef[k_footprintZ] = newDef[k_footprintZ] * (1.5)
UnitDefs["corllt_compressed_x10"] = newDef
end
if UnitDefs["armconst3"] then
local def = UnitDefs["armconst3"]
local name = "armconst3"
def.maxThisUnit = 10
end
if UnitDefs["corconst3"] then
local def = UnitDefs["corconst3"]
local name = "corconst3"
def.maxThisUnit = 10
end
if UnitDefs["legconst3"] then
local def = UnitDefs["legconst3"]
local name = "legconst3"
def.maxThisUnit = 10
end
if UnitDefs["armmeatball"] then
local def = UnitDefs["armmeatball"]
local name = "armmeatball"
def.maxThisUnit = 20
end
if UnitDefs["corclogger"] then
local def = UnitDefs["corclogger"]
local name = "corclogger"
def.maxThisUnit = 20
end
if UnitDefs["armavp"] then
local def = UnitDefs["armavp"]
local name = "armavp"
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
ti(target_list, "armmeatball")
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
ti(target_list, "corclogger")
end
if UnitDefs["coravp"] then
local def = UnitDefs["coravp"]
local name = "coravp"
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
ti(target_list, "armmeatball")
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
ti(target_list, "corclogger")
end
if UnitDefs["legavp"] then
local def = UnitDefs["legavp"]
local name = "legavp"
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
ti(target_list, "armmeatball")
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
ti(target_list, "corclogger")
end
for id, def in p(UnitDefs) do
local name = def.name or id
if ((def.customParams and def.customParams["subfolder"] == "other/raptors") or (def.customparams and def.customparams["subfolder"] == "other/raptors")) and not sm(name, "^raptor_queen_.*") then
def.health = def.health * (1.3)
end
if sm(name, "^raptor_land_swarmer_heal") then
def.reclaimSpeed = 100
def.stealth = false
def.builder = false
def.buildSpeed = def.buildSpeed * (0.5)
def.canAssist = false
def.maxThisUnit = 0
end
if ((def.customParams and def.customParams["subfolder"] == "other/raptors") or (def.customparams and def.customparams["subfolder"] == "other/raptors")) then
def.noChaseCategory = "OBJECT"
if def[k_health] then
def[k_metalCost] = mf(def[k_health] * 0.576923077)
end
end
if ss(name, 1, 13) == "raptor_queen_" then
def.repairable = false
def.canbehealed = false
def[k_buildTime] = 9999999
def.autoHeal = 2
def.canSelfRepair = false
def.health = def.health * (1.3)
end
if sm(name, "ragnarok") then
def.maxThisUnit = 80
end
if sm(name, "calamity") then
def.maxThisUnit = 80
end
if sm(name, "tyrannus") then
def.maxThisUnit = 80
end
if sm(name, "starfall") then
def.maxThisUnit = 80
end
end
local function ApplyTweaks_Post(name, def)
if ss(name, 1, 15) == "scavengerbossv4" then
def.health = def.health * (1.3)
end
if ss(name, -5) == "_scav" and not sm(name, "^scavengerbossv4") then
if def[k_health] then
def[k_health] = mf(def[k_health] * 1.3)
end
end
if ss(name, -5) == "_scav" then
if def[k_metalCost] then
def[k_metalCost] = mf(def[k_metalCost] * 1.3)
end
def.noChaseCategory = "OBJECT"
end
end
if UnitDef_Post then
local prev_UnitDef_Post = UnitDef_Post
UnitDef_Post = function(name, def)
prev_UnitDef_Post(name, def)
ApplyTweaks_Post(name, def)
end
else
UnitDef_Post = ApplyTweaks_Post
end