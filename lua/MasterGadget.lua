function gadget:GetInfo()
  return {
    name      = "NuttyB Master Gadget",
    desc      = "Combined logic and tweaks for NuttyB Mod",
    author    = "NuttyB Team (Generated)",
    date      = "2026",
    license   = "GPL",
    layer     = 0,
    enabled   = true
  }
end

if (not gadgetHandler:IsSyncedCode()) then
  return
end

-- Localized Globals (Performance Optimization)
local spAddTeamResource = Spring.AddTeamResource
local spCreateUnit = Spring.CreateUnit
local spDestroyUnit = Spring.DestroyUnit
local spEcho = Spring.Echo
local spGetFPS = Spring.GetFPS
local spGetGaiaTeamID = Spring.GetGaiaTeamID
local spGetGameFrame = Spring.GetGameFrame
local spGetGameSpeed = Spring.GetGameSpeed
local spGetModOptions = Spring.GetModOptions
local spGetTeamList = Spring.GetTeamList
local spGetTeamStartPosition = Spring.GetTeamStartPosition
local spGetTeamUnits = Spring.GetTeamUnits
local spGetUnitCount = Spring.GetUnitCount
local spGetUnitDefID = Spring.GetUnitDefID
local spGetUnitExperience = Spring.GetUnitExperience
local spGetUnitHealth = Spring.GetUnitHealth
local spGetUnitNearestEnemy = Spring.GetUnitNearestEnemy
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitsInCylinder = Spring.GetUnitsInCylinder
local spGiveOrderToUnit = Spring.GiveOrderToUnit
local spSendMessage = Spring.SendMessage
local spSetUnitExperience = Spring.SetUnitExperience
local spSetUnitHealth = Spring.SetUnitHealth
local spSetUnitLabel = Spring.SetUnitLabel
local spSetUnitNeutral = Spring.SetUnitNeutral
local spSpawnCEG = Spring.SpawnCEG
local spValidUnitID = Spring.ValidUnitID
local math_abs = math.abs
local math_floor = math.floor
local math_max = math.max
local math_random = math.random
local math_sqrt = math.sqrt

-- Forward Declarations for Gadget Events
local adaptivespawner_GameFrame
local adaptivespawner_UnitCreated
local adaptivespawner_UnitCollision
local culling_Initialize
local culling_UnitDamaged
local culling_UnitWeaponFire
local culling_GameFrame
local fusioncore_Initialize
local fusioncore_UnitFinished
local fusioncore_UnitDestroyed
local raptoraioptimized_UnitCreated
local raptoraioptimized_UnitDestroyed
local raptoraioptimized_GameFrame

-- Common Utilities

-- Common Utilities
local function table_merge(dest, src)
    for k, v in pairs(src) do
        if (type(v) == "table") and (type(dest[k]) == "table") then
            table_merge(dest[k], v)
        else
            dest[k] = v
        end
    end
    return dest
end

local function table_mergeInPlace(dest, src)
    if not dest or not src then return end
    for k, v in pairs(src) do
        if (type(v) == "table") and (type(dest[k]) == "table") then
            table_mergeInPlace(dest[k], v)
        else
            dest[k] = v
        end
    end
end

local function table_copy(t)
    if type(t) ~= "table" then return t end
    local res = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            res[k] = table_copy(v)
        else
            res[k] = v
        end
    end
    return res
end

-- Polyfill table.merge and table.mergeInPlace if missing
if not table.merge then table.merge = table_merge end
if not table.mergeInPlace then table.mergeInPlace = table_mergeInPlace end
if not table.copy then table.copy = table_copy end

-- Imported Tweaks Logic (Configurable)

-- Tweak: Defs_Mega_Nuke.lua
if (tonumber(Spring.GetModOptions().meganuke) == 1) then
-- Mega Nuke
-- Decoded from tweakdata.txt line 15

--NuttyB v1.52 Mega Nuke
-- docs.google.com/spreadsheets/d/1QSVsuAAMhBrhiZdTihVfSCwPzbbZWDLCtXWP23CU0ko
-- MEGA_NUKE_START
do
	local defs = UnitDefs or {}
	local merge = table.mergeInPlace or table.merge

	merge(defs, {
		armsilo = {
			energycost = 1500000,
			metalcost = 98720,
			buildtime = 228500,
			footprintx = 12,
			footprintz = 12,
			maxthisunit = 1,
			explodeas = 'advancedFusionExplosion',
			weapondefs = {
				nuclear_missile = {
					areaofeffect = 5000,
					cameraShake = 15000,
					craterboost = 55,
					cratermult = 40,
					energypershot = 390000,
					metalpershot = 3000,
					smokesize = 28,
					smokecolor = 0.85,
					soundhitwetvolume = 80,
					soundstartvolume = 50,
					stockpiletime = 160,
					weaponvelocity = 500,
					damage = {
						commanders = 500,
						default = 19500,
						raptor = 100000
					}
				}
			}
		},
		corsilo = {
			energycost = 1500000,
			metalcost = 98720,
			buildtime = 228500,
			footprintx = 12,
			footprintz = 12,
			maxthisunit = 1,
			explodeas = 'advancedFusionExplosion',
			weapondefs = {
				nuclear_missile = {
					areaofeffect = 5000,
					cameraShake = 15000,
					craterboost = 55,
					cratermult = 40,
					energypershot = 390000,
					metalpershot = 3000,
					smokesize = 28,
					smokecolor = 0.85,
					soundhitwetvolume = 80,
					soundstartvolume = 50,
					stockpiletime = 160,
					weaponvelocity = 500,
					damage = {
						commanders = 500,
						default = 19500,
						raptor = 100000
					}
				}
			}
		},
		legsilo = {
			energycost = 1500000,
			metalcost = 98720,
			buildtime = 228500,
			footprintx = 12,
			footprintz = 12,
			maxthisunit = 1,
			explodeas = 'advancedFusionExplosion',
			weapondefs = {
				nuclear_missile = {
					areaofeffect = 5000,
					cameraShake = 15000,
					craterboost = 55,
					cratermult = 40,
					energypershot = 390000,
					metalpershot = 3000,
					smokesize = 28,
					smokecolor = 0.85,
					soundhitwetvolume = 80,
					soundstartvolume = 50,
					stockpiletime = 160,
					weaponvelocity = 500,
					damage = {
						commanders = 500,
						default = 19500,
						raptor = 100000
					}
				}
			}
		},
		raptor_turret_antinuke_t3_v1 = {
			maxthisunit = 0
		},
		raptor_antinuke = {
			maxthisunit = 0
		},
		raptor_turret_antinuke_t4_v1 = {
			maxthisunit = 0
		},
		raptor_turret_antinuke_t2_v1 = {
			maxthisunit = 0
		}
	})
end
-- MEGA_NUKE_END

end

-- Static Tweaks Logic (Base)
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
-- Gadget Logic

local function Initialize_adaptivespawner()




-- Always enabled
local modOptions = Spring.GetModOptions() or {}

local MAX_COMPRESSION = tonumber(modOptions.adaptive_compression_max) or 10
-- Vampire defaults to TRUE
local VAMPIRE_ENABLED = true
if modOptions.adaptive_vampire == "0" then VAMPIRE_ENABLED = false end

-- Boss Tint defaults to TRUE
local BOSS_TINT_ENABLED = true
if modOptions.adaptive_boss_tint == "0" then BOSS_TINT_ENABLED = false end

local spGetUnitCount = Spring.GetUnitCount
local spDestroyUnit = Spring.DestroyUnit
local spCreateUnit = Spring.CreateUnit
local spGetUnitPosition = Spring.GetUnitPosition
local spGetGaiaTeamID = Spring.GetGaiaTeamID
local spGetGameSpeed = Spring.GetGameSpeed
local spGetFPS = Spring.GetFPS
local spGetUnitHealth = Spring.GetUnitHealth
local spSetUnitHealth = Spring.SetUnitHealth
local spGetUnitExperience = Spring.GetUnitExperience
local spSetUnitExperience = Spring.SetUnitExperience

local GAIA_TEAM_ID = spGetGaiaTeamID()

-- Counters for each unit type
local spawnCounters = {}

-- Dynamic Compression State
local currentCompressionFactor = 1

-- Mapping logic
local function GetCompressedDefID(unitDefID, factor)
    if not unitDefID then return nil end
    local ud = UnitDefs[unitDefID]
    if not ud then return nil end
    local name = ud.name
    local suffix = "_compressed_x" .. factor
    local newName = name .. suffix
    local newDef = UnitDefNames[newName]
    return newDef and newDef.id or nil
end

adaptivespawner_GameFrame = function(n)
    -- Update compression factor every 30 frames (1 second)
    if n % 30 == 0 then
        local _, simSpeed = spGetGameSpeed()
        local fps = spGetFPS()
        local unitCount = spGetUnitCount()

        -- Default to 1 (No compression)
        local factor = 1

        -- SimSpeed/FPS Logic
        if simSpeed < 0.8 or fps < 20 then
            factor = 10
        elseif simSpeed < 0.9 or fps < 35 then
            factor = 5
        elseif simSpeed < 1.0 then
            factor = 2 -- Light compression if slightly lagging
        end

        -- Hard Unit Count Override (Force compression if engine is overloaded by entities)
        if unitCount > 3500 then
            factor = 10
        elseif unitCount > 2000 and factor < 5 then
            factor = 5
        elseif unitCount > 1000 and factor < 2 then
            factor = 2
        end

        -- Clamp to User Configured Max
        if factor > MAX_COMPRESSION then
            factor = MAX_COMPRESSION
        end

        currentCompressionFactor = factor
    end
end

adaptivespawner_UnitCreated = function(unitID, unitDefID, teamID)
    -- Interceptor Pattern:
    -- This gadget intercepts units spawned by the mission script (or other sources).
    -- If high compression is active, it destroys the original unit and replaces it
    -- with a higher-tier "compressed" variant (e.g., 1x10HP instead of 10x1HP).
    if teamID ~= GAIA_TEAM_ID then return end

    local ud = UnitDefs[unitDefID]
    if not ud then return end

    -- Check if this is a compressible raptor
    if ud.customParams and ud.customParams.is_compressed_unit then return end

    -- Filter: Only apply to known raptors
    if not (string.find(ud.name, "raptor_land") or string.find(ud.name, "raptor_air")) then
        return
    end

    local factor = currentCompressionFactor

    if factor == 1 then return end

    -- Verify if a compressed variant exists
    local compressedID = GetCompressedDefID(unitDefID, factor)
    if not compressedID then
        -- Fallback: try lower factors
        if factor == 10 then
            factor = 5
            compressedID = GetCompressedDefID(unitDefID, factor)
        end
        if not compressedID and factor >= 5 then
            factor = 2
            compressedID = GetCompressedDefID(unitDefID, factor)
        end
        if not compressedID then return end
    end

    -- Accumulate counters
    spawnCounters[unitDefID] = (spawnCounters[unitDefID] or 0) + 1

    if spawnCounters[unitDefID] >= factor then
        -- Spawn compressed unit
        local x, y, z = spGetUnitPosition(unitID)
        local newUnitID = spCreateUnit(compressedID, x, y, z, 0, teamID)

        -- Apply Boss Tint if enabled
        if BOSS_TINT_ENABLED and newUnitID and spSetUnitColor then
            spSetUnitColor(newUnitID, 1, 0, 0, 1) -- Red tint
        end

        -- Reset counter
        spawnCounters[unitDefID] = 0
    end

    -- Always destroy the original unit
    spDestroyUnit(unitID, false, true)
end

adaptivespawner_UnitCollision = function(unitID, unitDefID, teamID, colliderID, colliderDefID, colliderTeamID)
    if not VAMPIRE_ENABLED then return end

    -- Only Gaia vs Gaia (Raptors)
    if teamID ~= GAIA_TEAM_ID or colliderTeamID ~= GAIA_TEAM_ID then return end

    -- Only if lagging severely (SimSpeed < 0.8)
    -- We can use the cached compression factor as a proxy for lag state?
    -- currentCompressionFactor is updated every 30 frames.
    -- If factor >= 10, it means we are in deep lag (SimSpeed < 0.8).
    if not currentCompressionFactor or currentCompressionFactor < 10 then return end

    -- Check if both are Raptors
    local ud1 = UnitDefs[unitDefID]
    local ud2 = UnitDefs[colliderDefID]
    if not (ud1 and ud2) then return end

    local isRaptor1 = string.find(ud1.name, "raptor")
    local isRaptor2 = string.find(ud2.name, "raptor")

    if isRaptor1 and isRaptor2 then
        -- Merge Logic: Bias towards keeping the one with more health
        local h1 = spGetUnitHealth(unitID) or 0
        local h2 = spGetUnitHealth(colliderID) or 0

        local survivor, victim, sH, vH
        if h1 >= h2 then
            survivor = unitID
            victim = colliderID
            sH = h1
            vH = h2
        else
            survivor = colliderID
            victim = unitID
            sH = h2
            vH = h1
        end

        -- Destroy victim
        spDestroyUnit(victim, false, true)

        -- Absorb Health
        spSetUnitHealth(survivor, sH + vH)

        -- Absorb XP
        local xp1 = spGetUnitExperience(survivor) or 0
        local xp2 = spGetUnitExperience(victim) or 0
        spSetUnitExperience(survivor, xp1 + xp2)
    end
end

end
-- Always Initialize
Initialize_adaptivespawner()

local function Initialize_culling()




local spGetGameFrame = Spring.GetGameFrame
local spGetGameSpeed = Spring.GetGameSpeed
local spDestroyUnit = Spring.DestroyUnit
local spGetTeamUnits = Spring.GetTeamUnits
local spGetGaiaTeamID = Spring.GetGaiaTeamID
local spGetUnitDefID = Spring.GetUnitDefID
-- local spGetUnitNearestEnemy = Spring.GetUnitNearestEnemy -- Removed
local spAddTeamResource = Spring.AddTeamResource
local spGetTeamList = Spring.GetTeamList
local spValidUnitID = Spring.ValidUnitID
local spGetUnitPosition = Spring.GetUnitPosition
local spSpawnCEG = Spring.SpawnCEG
local spSendMessage = Spring.SendMessage
local spGetUnitCount = Spring.GetUnitCount
local spGetTeamStartPosition = Spring.GetTeamStartPosition
local math_floor = math.floor

local modOptions = Spring.GetModOptions() or {}
local MIN_SIM_SPEED = tonumber(modOptions.cull_simspeed) or 0.9
local MAX_UNITS = tonumber(modOptions.cull_maxunits) or 5000
-- Default to Enabled, unless explicitly disabled
local CULL_ENABLED = (modOptions.cull_enabled ~= "0")
local SAFE_RADIUS = tonumber(modOptions.cull_radius) or 2000

culling_Initialize = function()
    Spring.Echo("[Eco Culler] Initialized with MIN_SIM_SPEED=" .. tostring(MIN_SIM_SPEED) .. ", MAX_UNITS=" .. tostring(MAX_UNITS) .. ", ENABLED=" .. tostring(CULL_ENABLED) .. ", RADIUS=" .. tostring(SAFE_RADIUS))
end

local GAIA_TEAM_ID = spGetGaiaTeamID()

-- List of units to cull (T1 Generators/Converters)
local cullableUnits = {
    ["armsolar"] = true,
    ["corsolar"] = true,
    ["armwin"] = true,
    ["corwin"] = true,
    ["armmakr"] = true,
    ["cormakr"] = true
}

-- Batch Processing State
local candidates = {} -- List of {id, team, defId}
local candidatesIndex = 1
local processingActive = false
local cullState = "IDLE" -- IDLE, WARNING, ACTIVE
local warningStartTime = 0
local WARNING_DURATION = 300 -- 10 seconds

-- Combat Grid (Safe Zone Caching)
local combatGrid = {} -- Key: "gx:gz", Value: timestamp (frame)
local GRID_SIZE = 1024 -- 1024 elmos (approx 2000 range check replacement)
local ACTIVE_DURATION = 900 -- 30 seconds * 30 frames

local function GetGridKey(x, z)
    local gx = math_floor(x / GRID_SIZE)
    local gz = math_floor(z / GRID_SIZE)
    return gx, gz, gx .. ":" .. gz
end

local function MarkActive(unitID)
    local x, _, z = spGetUnitPosition(unitID)
    if x then
        local _, _, key = GetGridKey(x, z)
        combatGrid[key] = spGetGameFrame()
    end
end

-- Event Handlers to update Combat Grid
culling_UnitDamaged = function(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
    MarkActive(unitID)
    if attackerID then MarkActive(attackerID) end
end

culling_UnitWeaponFire = function(unitID, unitDefID, unitTeam, weaponNum, weaponDefID, projectileParams, aimPos)
    MarkActive(unitID)
end


culling_GameFrame = function(n)
    if not CULL_ENABLED then return end

    -- State Machine Update (Every 30 frames)
    if n % 30 == 0 then
        local _, simSpeed = spGetGameSpeed()
        local currentUnits = spGetUnitCount()
        local conditionsMet = (simSpeed < MIN_SIM_SPEED) or (currentUnits > MAX_UNITS)

        if cullState == "IDLE" then
            if conditionsMet then
                cullState = "WARNING"
                warningStartTime = n
                spSendMessage("⚠️ Performance Critical! Eco Culling in 10s...")
            end
        elseif cullState == "WARNING" then
            if not conditionsMet then
                cullState = "IDLE"
                spSendMessage("✅ Performance Stabilized. Culling Cancelled.")
            elseif (n - warningStartTime) >= WARNING_DURATION then
                cullState = "ACTIVE"
                spSendMessage("♻️ Eco Culling STARTED: Removing inactive T1 structures...")

                -- Collection Logic
                candidates = {}
                candidatesIndex = 1
                processingActive = false

                local teamList = spGetTeamList()
                for _, teamID in pairs(teamList) do
                    if teamID ~= GAIA_TEAM_ID then
                        local units = spGetTeamUnits(teamID)
                        for _, uID in pairs(units) do
                             local udID = spGetUnitDefID(uID)
                             if udID then
                                local ud = UnitDefs[udID]
                                if ud and cullableUnits[ud.name] then
                                    table.insert(candidates, {id = uID, team = teamID, defId = udID})
                                end
                             end
                        end
                    end
                end

                if #candidates > 0 then
                    processingActive = true
                else
                    cullState = "IDLE"
                end
            end
        elseif cullState == "ACTIVE" then
             if not processingActive then
                 cullState = "IDLE"
             end
        end
    end

    -- Process Batch (Every Frame if active)
    if processingActive then
        local batchSize = 20 -- Check 20 units per frame
        local processedCount = 0
        local currentFrame = spGetGameFrame()

        while processedCount < batchSize and candidatesIndex <= #candidates do
            local candidate = candidates[candidatesIndex]
            candidatesIndex = candidatesIndex + 1
            processedCount = processedCount + 1

            local uID = candidate.id
            if spValidUnitID(uID) then
                 -- Check Safe Zone Cache (Combat Grid)
                 local x, y, z = spGetUnitPosition(uID)
                 local safe = true

                 if x then
                     local gx, gz, _ = GetGridKey(x, z)

                     -- Check current and neighbor cells (3x3)
                     for dx = -1, 1 do
                         for dz = -1, 1 do
                             local key = (gx + dx) .. ":" .. (gz + dz)
                             local lastActive = combatGrid[key]
                             if lastActive and (currentFrame - lastActive < ACTIVE_DURATION) then
                                 safe = false
                                 break
                             end
                         end
                         if not safe then break end
                     end

                     if safe then
                        -- Check Safe Radius from Start (approximate using 0,0 for now or assume commander/start pos)
                        -- The plan asked for "Safe Zone Radius" from start point/commander.
                        -- We will assume any unit within SAFE_RADIUS of ANY friendly commander is safe.
                        -- Actually, the current "Combat Grid" logic seems to be about "Active Combat".
                        -- The "Safe Zone" in the plan might be distinct.
                        -- For now, let's keep the Combat Grid logic as the primary safety check (as implemented).
                        -- If SAFE_RADIUS is intended to be a static zone around start, we need start positions.

                        -- Let's stick to the implementation I see here which uses "Combat Grid" for safety.
                        -- However, I should check distance to commanders if I want to respect SAFE_RADIUS strictly.
                        -- Let's check nearest commander.
                        local commanders = spGetTeamUnits(candidate.team) -- Optimize: Filter for commanders
                        local inSafeZone = false
                        -- This is expensive. Let's assume the previous logic handles safety via activity.
                        -- But the prompt asked for "Safe Zone Radius".
                        -- Let's check distance to (0,0) or start pos if available.
                        -- spGetTeamStartPosition(teamID)
                        local sx, sy, sz = spGetTeamStartPosition(candidate.team)
                        if sx then
                             local distSq = (x - sx)^2 + (z - sz)^2
                             if distSq < SAFE_RADIUS^2 then
                                 safe = false -- It IS safe from culling (so safe=false means don't cull?)
                                 -- Variable 'safe' here means "Safe to CULL". This is confusing naming in my code.
                                 -- In the code above: 'safe = true' -> check grid -> if active combat -> safe = false.
                                 -- So 'safe' means "Eligible for Culling".
                                 -- If inside SAFE_RADIUS of start, it should be NOT eligible.
                                 safe = false
                             end
                        end

                        if safe then
                             -- Refund
                            local ud = UnitDefs[candidate.defId]
                            if ud then
                                local metalCost = ud.metalCost or 0
                                spAddTeamResource(candidate.team, "metal", metalCost)

                            -- Visuals
                            spSpawnCEG("mediumexplosion", x, y, z, 0, 0, 0)

                            -- Destroy
                            spDestroyUnit(uID, false, true)
                            end
                        end
                     end
                 end
            end
        end

        if candidatesIndex > #candidates then
            processingActive = false
            candidates = {}
        end
    end
end

end
-- Always Initialize
Initialize_culling()

local function Initialize_fusioncore()




-- Always enabled
local modOptions = Spring.GetModOptions() or {}

local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitDefID = Spring.GetUnitDefID
local spCreateUnit = Spring.CreateUnit
local spDestroyUnit = Spring.DestroyUnit
local spSetUnitNeutral = Spring.SetUnitNeutral
local spGetUnitHealth = Spring.GetUnitHealth
local spSetUnitHealth = Spring.SetUnitHealth
local spGetUnitsInCylinder = Spring.GetUnitsInCylinder
local spGetUnitExperience = Spring.GetUnitExperience
local spSetUnitExperience = Spring.SetUnitExperience

-- Map of Mergeable UnitDefID -> Next Tier UnitDefID
local mergeMap = {}
-- Map of UnitDefID -> Tier (1 to 5)
local unitTier = {}

fusioncore_Initialize = function()
    -- Hardcoded base names that we know are generated by unit-generators.ts
    local baseNames = {"armsolar", "corsolar", "armwin", "corwin", "armmakr", "cormakr", "armllt", "corllt"}

    for _, name in pairs(baseNames) do
        -- T1 -> T2
        local u1 = UnitDefNames[name]
        local u2 = UnitDefNames[name .. "_t2"]
        if u1 then unitTier[u1.id] = 1 end
        if u1 and u2 then
             mergeMap[u1.id] = u2.id
             unitTier[u2.id] = 2
        end

        -- T2 -> T3, T3 -> T4, T4 -> T5
        for i = 2, 4 do
            local cur = UnitDefNames[name .. "_t" .. i]
            local next = UnitDefNames[name .. "_t" .. (i+1)]
            if cur then unitTier[cur.id] = i end
            if cur and next then
                 mergeMap[cur.id] = next.id
                 unitTier[next.id] = i+1
            end
        end
    end
end

fusioncore_UnitFinished = function(unitID, unitDefID, teamID)
    local minTier = tonumber(modOptions.fusion_mintier) or 1
    local currentTier = unitTier[unitDefID] or 0
    if currentTier < minTier then return end

    local nextTierID = mergeMap[unitDefID]
    if not nextTierID then return end

    local x, _, z = spGetUnitPosition(unitID)
    local ud = UnitDefs[unitDefID]
    -- Spring footprint is in 16-elmo blocks. e.g. 2x2 footprint = 32x32 elmos.
    local fpX = ud.footprintX * 16
    local fpZ = ud.footprintZ * 16

    -- Search radius slightly larger than 2x footprint
    local searchRadius = math.max(fpX, fpZ) * 2
    local nearby = spGetUnitsInCylinder(x, z, searchRadius, teamID)

    local candidates = {}
    for _, uid in pairs(nearby) do
        if spGetUnitDefID(uid) == unitDefID and uid ~= unitID then
            local ux, _, uz = spGetUnitPosition(uid)
            table.insert(candidates, {id=uid, x=ux, z=uz})
        end
    end

    if #candidates < 3 then return end

    -- Helper to find unit at specific relative coordinates with tolerance
    local function FindAt(targetX, targetZ)
        for _, c in pairs(candidates) do
            if math.abs(c.x - targetX) < 8 and math.abs(c.z - targetZ) < 8 then
                return c.id
            end
        end
        return nil
    end

    -- Helper to execute merge
    local function ExecuteMerge(uTL, uTR, uBL, uBR)
        if uTL and uTR and uBL and uBR then
             -- Lock units
            spSetUnitNeutral(uTL, true)
            spSetUnitNeutral(uTR, true)
            spSetUnitNeutral(uBL, true)
            spSetUnitNeutral(uBR, true)

            local h1 = spGetUnitHealth(uTL) or 0
            local h2 = spGetUnitHealth(uTR) or 0
            local h3 = spGetUnitHealth(uBL) or 0
            local h4 = spGetUnitHealth(uBR) or 0

            -- Calculate average center
            local px1, _, pz1 = spGetUnitPosition(uTL)
            local px4, _, pz4 = spGetUnitPosition(uBR)
            local cx = (px1 + px4) / 2
            local cz = (pz1 + pz4) / 2

            -- Get XP from fused units
            local xp1 = spGetUnitExperience(uTL) or 0
            local xp2 = spGetUnitExperience(uTR) or 0
            local xp3 = spGetUnitExperience(uBL) or 0
            local xp4 = spGetUnitExperience(uBR) or 0
            local totalXP = xp1 + xp2 + xp3 + xp4

            -- Apply Efficiency Bonus
            local efficiency = tonumber(modOptions.fusion_efficiency) or 1.10
            totalXP = totalXP * efficiency

            -- Destroy source units
            spDestroyUnit(uTL, false, true)
            spDestroyUnit(uTR, false, true)
            spDestroyUnit(uBL, false, true)
            spDestroyUnit(uBR, false, true)

            -- Create new unit
            local newUnit = spCreateUnit(nextTierID, cx, 0, cz, 0, teamID)
            if newUnit then
                -- Sum HP from fused units and apply bonus
                local totalHealth = (h1 + h2 + h3 + h4) * efficiency
                -- Check max health of new unit to avoid overflow if needed,
                -- though usually SetUnitHealth clamps it or allows overflow.
                -- We set it to the sum.
                spSetUnitHealth(newUnit, totalHealth)

                -- Sum XP
                spSetUnitExperience(newUnit, totalXP)
            end
            return true
        end
        return false
    end

    -- Check 4 permutations where 'unitID' is one of the corners

    -- Case 1: This is TL. Check TR, BL, BR.
    if ExecuteMerge(unitID, FindAt(x+fpX, z), FindAt(x, z+fpZ), FindAt(x+fpX, z+fpZ)) then return end

    -- Case 2: This is TR. Check TL, BL, BR.
    if ExecuteMerge(FindAt(x-fpX, z), unitID, FindAt(x-fpX, z+fpZ), FindAt(x, z+fpZ)) then return end

    -- Case 3: This is BL. Check TL, TR, BR.
    if ExecuteMerge(FindAt(x, z-fpZ), FindAt(x+fpX, z-fpZ), unitID, FindAt(x+fpX, z)) then return end

    -- Case 4: This is BR. Check TL, TR, BL.
    if ExecuteMerge(FindAt(x-fpX, z-fpZ), FindAt(x, z-fpZ), FindAt(x-fpX, z), unitID) then return end
end

fusioncore_UnitDestroyed = function(unitID, unitDefID, teamID)
    -- Mega Nuke Logic
    -- Checked via modOption 'meganuke' == "1"
    if modOptions.meganuke ~= "1" then return end

    -- Check if it is a high-tier fusion unit
    local tier = unitTier[unitDefID]
    if tier and tier >= 3 then
        local x, y, z = spGetUnitPosition(unitID)
        -- Spawn a large explosion
        if Spring.SpawnCEG then
            Spring.SpawnCEG("atomic_blast", x, y, z, 0, 1, 0)
        end
        -- Could add Area Damage here if needed
    end
end

end
-- Always Initialize
Initialize_fusioncore()

local function Initialize_raptoraioptimized()




-- Localization of Global Functions
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitDefID = Spring.GetUnitDefID
local spGiveOrderToUnit = Spring.GiveOrderToUnit
local spGetGameFrame = Spring.GetGameFrame
local spGetUnitsInCylinder = Spring.GetUnitsInCylinder
local spGetTeamUnits = Spring.GetTeamUnits
local spGetTeamList = Spring.GetTeamList
local spValidUnitID = Spring.ValidUnitID
local math_sqrt = math.sqrt
local math_abs = math.abs
local math_floor = math.floor
local math_random = math.random
local spSetUnitLabel = Spring.SetUnitLabel
local spGetModOptions = Spring.GetModOptions

-- Constants
local RAPTOR_TEAM_ID = Spring.GetGaiaTeamID()
local BUCKET_COUNT = 30
local GRID_SIZE = 512
local SQUAD_SIZE = 20

-- State
local raptorUnits = {} -- Map: unitID -> { bucket, isLeader, leaderID, squadID }
local targetGrid = {} -- Map: gridKey -> list of unitIDs (targets)

-- Squad Management State
local currentSquadID = 1
local currentSquadCount = 0
local currentLeaderID = nil

-- Helper: Get Grid Key
local function GetGridKey(x, z)
    local gx = math_floor(x / GRID_SIZE)
    local gz = math_floor(z / GRID_SIZE)
    return gx .. ":" .. gz
end

-- Spatial Partitioning: Register Target
local function RegisterTarget(unitID)
    local x, _, z = spGetUnitPosition(unitID)
    if x then
        local key = GetGridKey(x, z)
        if not targetGrid[key] then targetGrid[key] = {} end
        table.insert(targetGrid[key], unitID)
    end
end

-- Rebuild Grid
local function RebuildTargetGrid()
    targetGrid = {}
    local teams = spGetTeamList()
    for _, teamID in pairs(teams) do
        if teamID ~= RAPTOR_TEAM_ID then
            local units = spGetTeamUnits(teamID)
            for _, uID in pairs(units) do
                RegisterTarget(uID)
            end
        end
    end
end

-- Logic: Squad Leader (Full Pathing/Targeting)
local function ProcessLeader(unitID)
    local x, _, z = spGetUnitPosition(unitID)
    if not x then return end

    -- Visual Debugging
    local modOptions = spGetModOptions()
    if modOptions and (modOptions.debug_mode == "1" or modOptions.debug_mode == 1) then
        spSetUnitLabel(unitID, "Squad Leader")
    end

    -- Query Spatial Grid for nearest target
    local gx = math_floor(x / GRID_SIZE)
    local gz = math_floor(z / GRID_SIZE)

    local bestTarget = nil
    local minDistSq = 99999999

    -- Search 3x3 grid cells
    for dx = -1, 1 do
        for dz = -1, 1 do
            local key = (gx + dx) .. ":" .. (gz + dz)
            local targets = targetGrid[key]
            if targets then
                for _, tID in pairs(targets) do
                    local tx, _, tz = spGetUnitPosition(tID)
                    if tx then
                        local distSq = (tx - x)^2 + (tz - z)^2
                        if distSq < minDistSq then
                            minDistSq = distSq
                            bestTarget = tID
                        end
                    end
                end
            end
        end
    end

    if bestTarget then
        -- Attack specific target
        spGiveOrderToUnit(unitID, CMD.ATTACK, {bestTarget}, {})
    else
        -- Attack move to center/base
        -- Optimization: Only issue if command queue is empty?
        -- For now, issue every few seconds (governed by Time Slicing) is fine.
        spGiveOrderToUnit(unitID, CMD.FIGHT, {Game.mapSizeX/2, 0, Game.mapSizeZ/2}, {})
    end
end

-- Logic: Squad Follower (Cheap Follow)
local function ProcessFollower(unitID, leaderID)
    -- Check if leader exists
    if leaderID and spValidUnitID(leaderID) then
        local lx, _, lz = spGetUnitPosition(leaderID)
        if lx then
            -- Move to random offset around leader
            local ox = math_random(-50, 50)
            local oz = math_random(-50, 50)
            -- CMD.MOVE is cheaper than CMD.FIGHT/ATTACK usually, but doesn't engage.
            -- CMD.FIGHT allows engaging enemies on the way.
            -- Plan said "CMD.FIGHT or CMD.MOVE". MOVE is strictly cheaper pathing-wise (no enemy scan).
            spGiveOrderToUnit(unitID, CMD.MOVE, {lx + ox, 0, lz + oz}, {})
            return
        end
    end

    -- Fallback: Behave like a leader if orphaned
    ProcessLeader(unitID)
end

local function ProcessUnit(unitID)
    local data = raptorUnits[unitID]
    if not data then return end

    if data.isLeader then
        ProcessLeader(unitID)
    else
        ProcessFollower(unitID, data.leaderID)
    end
end

-- Event: UnitCreated
raptoraioptimized_UnitCreated = function(unitID, unitDefID, teamID)
    if teamID == RAPTOR_TEAM_ID then
        -- Squad Assignment
        if currentSquadCount >= SQUAD_SIZE or currentLeaderID == nil or not spValidUnitID(currentLeaderID) then
            -- New Squad / New Leader
            currentSquadID = currentSquadID + 1
            currentSquadCount = 1
            currentLeaderID = unitID

            raptorUnits[unitID] = {
                id = unitID,
                bucket = unitID % BUCKET_COUNT,
                isLeader = true,
                squadID = currentSquadID
            }
        else
            -- Follower
            currentSquadCount = currentSquadCount + 1
            raptorUnits[unitID] = {
                id = unitID,
                bucket = unitID % BUCKET_COUNT,
                isLeader = false,
                leaderID = currentLeaderID,
                squadID = currentSquadID
            }
        end
    else
        RegisterTarget(unitID)
    end
end

-- Event: UnitDestroyed
raptoraioptimized_UnitDestroyed = function(unitID, unitDefID, teamID)
    if raptorUnits[unitID] then
        raptorUnits[unitID] = nil
        if unitID == currentLeaderID then
            currentLeaderID = nil -- Next spawn will start new squad
            currentSquadCount = SQUAD_SIZE -- Force new squad creation
        end
    end
end

-- GameFrame: Time-Slicing Scheduler
raptoraioptimized_GameFrame = function(n)
    -- Rebuild target grid periodically
    if n % 30 == 0 then
        RebuildTargetGrid()
    end

    local currentBucket = n % BUCKET_COUNT

    for id, data in pairs(raptorUnits) do
        if data.bucket == currentBucket then
            ProcessUnit(id)
        end
    end
end

end
-- Always Initialize
Initialize_raptoraioptimized()

-- Master Dispatcher
function gadget:GameFrame(...)
    if adaptivespawner_GameFrame then adaptivespawner_GameFrame(...) end
    if culling_GameFrame then culling_GameFrame(...) end
    if raptoraioptimized_GameFrame then raptoraioptimized_GameFrame(...) end
end
function gadget:UnitCreated(...)
    if adaptivespawner_UnitCreated then adaptivespawner_UnitCreated(...) end
    if raptoraioptimized_UnitCreated then raptoraioptimized_UnitCreated(...) end
end
function gadget:UnitCollision(...)
    if adaptivespawner_UnitCollision then adaptivespawner_UnitCollision(...) end
end
function gadget:Initialize(...)
    if culling_Initialize then culling_Initialize(...) end
    if fusioncore_Initialize then fusioncore_Initialize(...) end
end
function gadget:UnitDamaged(...)
    if culling_UnitDamaged then culling_UnitDamaged(...) end
end
function gadget:UnitWeaponFire(...)
    if culling_UnitWeaponFire then culling_UnitWeaponFire(...) end
end
function gadget:UnitFinished(...)
    if fusioncore_UnitFinished then fusioncore_UnitFinished(...) end
end
function gadget:UnitDestroyed(...)
    if fusioncore_UnitDestroyed then fusioncore_UnitDestroyed(...) end
    if raptoraioptimized_UnitDestroyed then raptoraioptimized_UnitDestroyed(...) end
end
