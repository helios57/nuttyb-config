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

-- Configuration Flags
ENABLE_ADAPTIVESPAWNER = true
ENABLE_CULLING = true
ENABLE_FUSIONCORE = true
ENABLE_RAPTORAIOPTIMIZED = true
ENABLE_MEGANUKE = true

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

local function ApplyTweakUnits(data)
    if not data then return end
    for name, defData in pairs(data) do
        if UnitDefs[name] then
            table_merge(UnitDefs[name], defData)
        end
    end
end

-- Tweaks Logic

do
    -- Tweak file: 1-tweakdefs2.json
    local table_merge = table.merge
local pairs = pairs
local ipairs = ipairs
local string_sub = string.sub
local string_match = string.match
local string_len = string.len
local table_insert = table.insert
local math_floor = math.floor
if UnitDefs["raptor_land_swarmer_basic_t1_v1"] then
local newDef = table_merge({}, UnitDefs["raptor_land_swarmer_basic_t1_v1"])
newDef.name = "Hive Spawn"
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = "Hive Spawn", i18n_en_tooltip = "Raptor spawned to defend hives from attackers." })
UnitDefs["raptor_hive_swarmer_basic"] = newDef
end
if UnitDefs["raptor_land_assault_basic_t2_v1"] then
local newDef = table_merge({}, UnitDefs["raptor_land_assault_basic_t2_v1"])
newDef.name = "Armored Assault Raptor"
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = "Armored Assault Raptor", i18n_en_tooltip = "Heavy, slow, and unyielding—these beasts are made to take the hits others cant." })
UnitDefs["raptor_hive_assault_basic"] = newDef
end
for id, def in pairs(UnitDefs) do
local name = def.name or id
if string_sub(name, 1, 24) == "raptor_air_fighter_basic" then
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.name = "Spike"
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.accuracy = 200
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.collidefriendly = 0
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.collidefeature = 0
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.avoidfeature = 0
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.avoidfriendly = 0
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.areaofeffect = 64
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.edgeeffectiveness = 0.3
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.explosiongenerator = "custom:raptorspike-large-sparks-burn"
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.cameraShake = {  }
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.dance = {  }
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.interceptedbyshieldtype = 0
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.model = "Raptors/spike.s3o"
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.reloadtime = 1.1
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.soundstart = "talonattack"
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.startvelocity = 200
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.submissile = 1
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.smoketrail = 0
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.smokePeriod = {  }
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.smoketime = {  }
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.smokesize = {  }
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.smokecolor = {  }
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.soundhit = {  }
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.texture1 = {  }
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.texture2 = {  }
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.tolerance = {  }
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.tracks = 0
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.turnrate = 60000
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.weaponacceleration = 100
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.weapontimer = 1
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.weaponvelocity = 1000
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.weapontype = {  }
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.wobble = {  }
end
end
end
if string_match(name, "^[acl][ore][rgm]com") and not string_match(name, "_scav$") then
if not def.customparams then def.customparams = {} end
table_merge(def.customparams, { combatradius = 0, fall_damage_multiplier = 0, paratrooper = true, wtboostunittype = {  } })
if not def.featuredefs then def.featuredefs = {} end
table_merge(def.featuredefs, { dead = { damage = 9999999, reclaimable = false, mass = 9999999 } })
end
if (name == "raptor_antinuke" or name == "raptor_turret_acid_t2_v1" or name == "raptor_turret_acid_t3_v1" or name == "raptor_turret_acid_t4_v1" or name == "raptor_turret_antiair_t2_v1" or name == "raptor_turret_antiair_t3_v1" or name == "raptor_turret_antiair_t4_v1" or name == "raptor_turret_antinuke_t2_v1" or name == "raptor_turret_antinuke_t3_v1" or name == "raptor_turret_basic_t2_v1" or name == "raptor_turret_basic_t3_v1" or name == "raptor_turret_basic_t4_v1" or name == "raptor_turret_burrow_t2_v1" or name == "raptor_turret_emp_t2_v1" or name == "raptor_turret_emp_t3_v1" or name == "raptor_turret_emp_t4_v1" or name == "raptor_worm_green") then
def.maxThisUnit = 10
def.health = def.health * (nil)
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.reloadtime = wDef.reloadtime * (nil)
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.range = wDef.range * (nil)
end
end
end
if def.builder == true and def.canfly == true then
def.explodeAs = ""
def.selfDestructAs = ""
end
end
end

do
    -- Tweak file: 2-tweakdefs3.json
    local table_merge = table.merge
local pairs = pairs
local ipairs = ipairs
local string_sub = string.sub
local string_match = string.match
local string_len = string.len
local table_insert = table.insert
local math_floor = math.floor
if UnitDefs["armannit3"] then
local newDef = table_merge({}, UnitDefs["armannit3"])
newDef.name = "Legendary Pulsar"
newDef.description = "A pinnacle of Armada engineering that fires devastating, rapid-fire tachyon bolts."
newDef.buildTime = 300000
newDef.health = 30000
newDef.metalCost = 43840
newDef.energyCost = 1096000
newDef.icontype = "armannit3"
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = "Legendary Pulsar", i18n_en_tooltip = "Fires devastating, rapid-fire tachyon bolts.", techlevel = 4 })
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "tachyon_burst_cannon" then
wDef.name = "Tachyon Burst Cannon"
wDef.damage = { default = 8000 }
wDef.burst = 3
wDef.burstrate = 0.4
wDef.reloadtime = 5
wDef.range = 1800
wDef.energypershot = 12000
end
end
end
UnitDefs["legendary_pulsar"] = newDef
end
if UnitDefs["legbastion"] then
local newDef = table_merge({}, UnitDefs["legbastion"])
newDef.name = "Legendary Bastion"
newDef.description = "The ultimate defensive emplacement. Projects a devastating, pulsating heatray."
newDef.health = 22000
newDef.metalCost = 65760
newDef.energyCost = 1986500
newDef.buildTime = 180000
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = "Legendary Bastion", i18n_en_tooltip = "Projects a devastating, pulsating purple heatray.", maxrange = 1450, techlevel = 4 })
UnitDefs["legendary_bastion"] = newDef
end
if UnitDefs["cordoomt3"] then
local newDef = table_merge({}, UnitDefs["cordoomt3"])
newDef.name = "Legendary Bulwark"
newDef.description = "A pinnacle of defensive technology, the Legendary Bulwark annihilates all who approach."
newDef.health = 42000
newDef.metalCost = 61650
newDef.energyCost = 1712500
newDef.buildTime = 250000
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = "Legendary Bulwark", i18n_en_tooltip = "The ultimate defensive structure.", paralyzemultiplier = 0.2, techlevel = 4 })
UnitDefs["legendary_bulwark"] = newDef
end
for id, def in pairs(UnitDefs) do
local name = def.name or id
if string_sub(name, 1, 9) == "armcomlvl" and (name == "armt3airaide") then
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "legendary_pulsar")
end
if string_sub(name, 1, 9) == "corcomlvl" and (name == "cort3airaide") then
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "legendary_bulwark")
end
if string_sub(name, 1, 9) == "legcomlvl" and (name == "legt3airaide") then
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "legendary_bastion")
end
end
end

do
    -- Tweak file: 3-tweakdefs4.json
    local Spring_GetModOptions = Spring.GetModOptions
local table_merge = table.merge
local pairs = pairs
local ipairs = ipairs
local string_sub = string.sub
local string_match = string.match
local string_len = string.len
local table_insert = table.insert
local math_floor = math.floor
local math_max = math.max
local math_ceil = math.ceil
if UnitDefs["raptor_matriarch_basic"] then
local newDef = table_merge({}, UnitDefs["raptor_matriarch_basic"])
newDef.name = "Queenling Prima"
newDef.icontype = "raptor_queen_veryeasy"
newDef.health = newDef.health * (5)
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = "Queenling Prima", i18n_en_tooltip = "Majestic and bold, ruler of the hunt." })
newDef.maxThisUnit = (math_max(1, math_ceil(2 * ((Spring_GetModOptions().raptor_spawncountmult or 3) / 3))))
UnitDefs["raptor_miniq_a"] = newDef
end
if UnitDefs["raptor_matriarch_basic"] then
local newDef = table_merge({}, UnitDefs["raptor_matriarch_basic"])
newDef.name = "Queenling Secunda"
newDef.icontype = "raptor_queen_easy"
newDef.health = newDef.health * (6)
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = "Queenling Secunda", i18n_en_tooltip = "Swift and sharp, a noble among raptors." })
newDef.maxThisUnit = (math_max(1, math_ceil(3 * ((Spring_GetModOptions().raptor_spawncountmult or 3) / 3))))
UnitDefs["raptor_miniq_b"] = newDef
end
if UnitDefs["raptor_matriarch_basic"] then
local newDef = table_merge({}, UnitDefs["raptor_matriarch_basic"])
newDef.name = "Queenling Tertia"
newDef.icontype = "raptor_queen_normal"
newDef.health = newDef.health * (7)
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = "Queenling Tertia", i18n_en_tooltip = "Refined tastes. Likes her prey rare." })
newDef.maxThisUnit = (math_max(1, math_ceil(4 * ((Spring_GetModOptions().raptor_spawncountmult or 3) / 3))))
UnitDefs["raptor_miniq_c"] = newDef
end
end

do
    -- Tweak file: 4-tweakdefs6.json
    local table_merge = table.merge
local pairs = pairs
local ipairs = ipairs
local string_sub = string.sub
local string_match = string.match
local string_len = string.len
local table_insert = table.insert
local math_floor = math.floor
for id, def in pairs(UnitDefs) do
local name = def.name or id
if ((def.customParams and def.customParams["techlevel"] == 2) or (def.customparams and def.customparams["techlevel"] == 2)) and ((def.customParams and def.customParams["subfolder"] and string_match(def.customParams["subfolder"], "Fact")) or (def.customparams and def.customparams["subfolder"] and string_match(def.customparams["subfolder"], "Fact"))) and not string_match(name, ".* %(Taxed%)$") then
if def then
local newDef = table_merge({}, def)
newDef.energyCost = newDef.energyCost * (1.7)
newDef.metalCost = newDef.metalCost * (1.7)
newDef.name = (name .. ' (Taxed)')
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = (def.customparams.i18n_en_humanname .. ' (Taxed)') })
UnitDefs[def.name .. "_taxed"] = newDef
end
end
if ((def.customParams and def.customParams["techlevel"] == 2) or (def.customparams and def.customparams["techlevel"] == 2)) and ((def.customParams and def.customParams["subfolder"] and string_match(def.customParams["subfolder"], "Lab")) or (def.customparams and def.customparams["subfolder"] and string_match(def.customparams["subfolder"], "Lab"))) and not string_match(name, ".* %(Taxed%)$") then
if def then
local newDef = table_merge({}, def)
newDef.energyCost = newDef.energyCost * (1.7)
newDef.metalCost = newDef.metalCost * (1.7)
newDef.name = (name .. ' (Taxed)')
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = (def.customparams.i18n_en_humanname .. ' (Taxed)') })
UnitDefs[def.name .. "_taxed"] = newDef
end
end
end
end

do
    -- Tweak file: 5-tweakdefs7.json
    local pairs = pairs
local ipairs = ipairs
local string_sub = string.sub
local string_match = string.match
local string_len = string.len
local table_insert = table.insert
local math_floor = math.floor
for id, def in pairs(UnitDefs) do
local name = def.name or id
if (name == "armmmkrt3" or name == "cormmkrt3" or name == "legadveconvt3") then
def.footprintx = 6
def.footprintz = 6
end
if (name == "armack" or name == "armaca" or name == "armacv") then
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "armafust3")
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "armmmkrt3")
end
if (name == "corack" or name == "coraca" or name == "coracv") then
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "corafust3")
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "cormmkrt3")
end
if (name == "legack" or name == "legaca" or name == "legacv") then
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "legafust3")
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "legadveconvt3")
end
if (name == "legck") then
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "legdtf")
end
if (name == "coruwadves" or name == "legadvestore") then
def.footprintx = 4
def.footprintz = 4
end
end
end

do
    -- Tweak file: 6-tweakdefs8.json
    local table_merge = table.merge
local pairs = pairs
local ipairs = ipairs
local string_sub = string.sub
local string_match = string.match
local string_len = string.len
local table_insert = table.insert
local math_floor = math.floor
if UnitDefs["armnanotct2"] then
local newDef = table_merge({}, UnitDefs["armnanotct2"])
newDef.metalcost = 3700
newDef.energycost = 62000
newDef.builddistance = 550
newDef.buildtime = 108000
newDef.health = 8800
newDef.workertime = 1900
newDef.customparams = { i18n_en_humanname = "T3 Construction Turret" }
UnitDefs["armnanotct3"] = newDef
end
if UnitDefs["cornanotct2"] then
local newDef = table_merge({}, UnitDefs["cornanotct2"])
newDef.metalcost = 3700
newDef.energycost = 62000
newDef.builddistance = 550
newDef.buildtime = 108000
newDef.health = 8800
newDef.workertime = 1900
newDef.customparams = { i18n_en_humanname = "T3 Construction Turret" }
UnitDefs["cornanotct3"] = newDef
end
if UnitDefs["legnanotct2"] then
local newDef = table_merge({}, UnitDefs["legnanotct2"])
newDef.metalcost = 3700
newDef.energycost = 62000
newDef.builddistance = 550
newDef.buildtime = 108000
newDef.health = 8800
newDef.workertime = 1900
newDef.customparams = { i18n_en_humanname = "T3 Construction Turret" }
UnitDefs["legnanotct3"] = newDef
end
if UnitDefs["armdecom"] then
local newDef = table_merge({}, UnitDefs["armdecom"])
newDef.name = "Armada Epic Aide"
newDef.workertime = 6000
newDef.buildoptions = { "armafust3", "armnanotct2", "armnanotct3", "armalab", "armavp", "armaap", "armgatet3", "armflak", "armmmkrt3", "armuwadvmst3", "armadvestoret3", "armgate", "armfort", "armshltx", "corgant_taxed", "leggant_taxed", "armamd", "armmercury", "armbrtha", "armminivulc", "armvulc", "armanni", "armannit3", "armlwall", "legendary_pulsar" }
UnitDefs["armt3aide"] = newDef
end
if UnitDefs["cordecom"] then
local newDef = table_merge({}, UnitDefs["cordecom"])
newDef.name = "Cortex Epic Aide"
newDef.workertime = 6000
newDef.buildoptions = { "corafust3", "cornanotct2", "cornanotct3", "coralab", "coravp", "coraap", "corgatet3", "corflak", "cormmkrt3", "coruwadvmst3", "coradvestoret3", "corgate", "corfort", "corgant", "armshltx_taxed", "leggant_taxed", "corfmd", "corscreamer", "cordoomt3", "corbuzz", "corminibuzz", "corint", "cordoom", "corhllllt", "cormwall", "legendary_bulwark" }
UnitDefs["cort3aide"] = newDef
end
if UnitDefs["legdecom"] then
local newDef = table_merge({}, UnitDefs["legdecom"])
newDef.name = "Legion Epic Aide"
newDef.workertime = 6000
newDef.buildoptions = { "legafust3", "legnanotct2", "legnanotct3", "legalab", "legavp", "legaap", "leggatet3", "legflak", "legadveconvt3", "legamstort3", "legadvestoret3", "legdeflector", "legforti", "leggant", "armshltx_taxed", "corgant_taxed", "legabm", "legstarfall", "legministarfall", "leglraa", "legbastion", "legrwall", "leglrpc", "legendary_bastion", "legapopupdef", "legdtf" }
UnitDefs["legt3aide"] = newDef
end
for id, def in pairs(UnitDefs) do
local name = def.name or id
if (name == "armshltx") then
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "armt3aide")
end
if (name == "corgant") then
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "cort3aide")
end
if (name == "leggant") then
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "legt3aide")
end
end
end

do
    -- Tweak file: 7-tweakdefs9.json
    local table_merge = table.merge
local pairs = pairs
local ipairs = ipairs
local string_sub = string.sub
local string_match = string.match
local string_len = string.len
local table_insert = table.insert
local math_floor = math.floor
if UnitDefs["armbotrail"] then
local newDef = table_merge({}, UnitDefs["armbotrail"])
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = "Meatball Launcher" })
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.range = 7550
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.metalpershot = 5300
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.energypershot = 96000
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.reloadtime = 0.5
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
if not wDef.customparams then wDef.customparams = {} end
table_merge(wDef.customparams, { stockpilelimit = 50, spawns_name = "armmeatball" })
end
end
end
UnitDefs["armmeatball"] = newDef
end
if UnitDefs["armbotrail"] then
local newDef = table_merge({}, UnitDefs["armbotrail"])
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = "Assimilator Launcher" })
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.range = 7550
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.metalpershot = 4500
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.energypershot = 80000
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.reloadtime = 0.5
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
if not wDef.customparams then wDef.customparams = {} end
table_merge(wDef.customparams, { stockpilelimit = 50, spawns_name = "armassimilator" })
end
end
end
UnitDefs["armassimilator"] = newDef
end
if UnitDefs["armbotrail"] then
local newDef = table_merge({}, UnitDefs["armbotrail"])
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = "Epic Pawn Launcher" })
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.range = 7550
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.metalpershot = 14200
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.energypershot = 480000
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.reloadtime = 0.5
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
if not wDef.customparams then wDef.customparams = {} end
table_merge(wDef.customparams, { stockpilelimit = 50, spawns_name = "armpwt4" })
end
end
end
UnitDefs["armpwt4"] = newDef
end
if UnitDefs["armbotrail"] then
local newDef = table_merge({}, UnitDefs["armbotrail"])
if not newDef.customparams then newDef.customparams = {} end
table_merge(newDef.customparams, { i18n_en_humanname = "Armada T1 Launcher" })
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.stockpiletime = 0.5
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.range = 7550
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.metalpershot = 250
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.energypershot = 12500
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
wDef.reloadtime = 0.5
end
end
end
if newDef.weapondefs then
for wName, wDef in pairs(newDef.weapondefs) do
if wName == "arm_botrail" then
if not wDef.customparams then wDef.customparams = {} end
table_merge(wDef.customparams, { stockpilelimit = 50, spawns_name = "armham armjeth armpw armrock armwar armah armanac armmh armsh armart armfav armflash armjanus armpincer armsam armstump armzapper", spawns_mode = "random" })
end
end
end
UnitDefs["armt1"] = newDef
end
for id, def in pairs(UnitDefs) do
local name = def.name or id
if string_match(name, "cormandot4") then
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "armmeatball")
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "armassimilator")
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "armpwt4")
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "armt1")
end
end
end

do
    -- Tweak file: 8-tweakunits.json
    local data = -- Main tweakunits (Migrated)
{cortron={energycost=42000,metalcost=3600,buildtime=110000,health=12000,weapondefs={cortron_weapon={energypershot=51000,metalpershot=600,range=4050,damage={default=9000}}}},corfort={repairable=true},armfort={repairable=true},legforti={repairable=true},armgate={explodeas='empblast',selfdestructas='empblast'},corgate={explodeas='empblast',selfdestructas='empblast'},legdeflector={explodeas='empblast',selfdestructas='empblast'},corsat={sightdistance=3100,radardistance=4080,cruisealtitude=3300,energyupkeep=1250,category='OBJECT'},armsat={sightdistance=3100,radardistance=4080,cruisealtitude=3300,energyupkeep=1250,category='OBJECT'},legstarfall={weapondefs={starfire={energypershot=270000}}},armflak={airsightdistance=1350,energycost=30000,metalcost=1500,health=4000,weapondefs={armflak_gun={collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,areaofeffect=150,range=1150,reloadtime=0.475,weaponvelocity=2400,intensity=0.18}}},corflak={airsightdistance=1350,energycost=30000,metalcost=1500,health=4000,weapondefs={armflak_gun={collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,areaofeffect=200,range=1350,reloadtime=0.56,weaponvelocity=2100,intensity=0.18}}},legflak={footprintx=4,footprintz=4,airsightdistance=1350,energycost=35000,metalcost=2100,health=6000,weapondefs={legflak_gun={collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,areaofeffect=100,burst=3,range=1050,intensity=0.18}}},armmercury={airsightdistance=2200,weapondefs={arm_advsam={areaofeffect=500,energypershot=2000,explosiongenerator='custom:flak',flighttime=1.5,metalpershot=6,name='Mid-range, rapid-fire g2a guided missile launcher',range=2500,reloadtime=1.2,smoketrail=false,startvelocity=1500,weaponacceleration=1000,weaponvelocity=4000}}},corscreamer={airsightdistance=2800,weapondefs={cor_advsam={areaofeffect=800,energypershot=2000,explosiongenerator='custom:flak',flighttime=1,metalpershot=10,name='Long-range g2a guided heavy flak missile launcher',range=2800,reloadtime=1.8,smoketrail=false,startvelocity=4000,weaponacceleration=1000,weaponvelocity=8000}}},armassistdrone={buildoptions={['31']='armclaw'}},corassistdrone={buildoptions={['32']='cormaw'}},legassistdrone={buildoptions={['31']='legdtf',['32']='legdtl',['33']='legdtr'}},legfortt4={explodeas='fusionExplosionSelfd',selfdestructas='fusionExplosionSelfd'},legfort={explodeas='empblast',selfdestructas='empblast'},raptor_hive={weapondefs={antiground={burst=5,burstrate=0.01,cegtag='arty-heavy-purple',explosiongenerator='custom:dirt',model='Raptors/s_raptor_white.s3o',range=1600,reloadtime=5,rgbcolor='0.5 0 1',soundhit='smallraptorattack',soundstart='bugarty',sprayangle=256,turret=true,stockpiletime=12,proximitypriority=nil,damage={default=1,shields=100},customparams={spawns_count=15,spawns_expire=11,spawns_mode='random',spawns_name='raptor_acidspawnling raptor_hive_swarmer_basic raptor_land_swarmer_basic_t1_v1 ',spawns_surface='LAND SEA',stockpilelimit=10}}}},armapt3={buildoptions={['58']='armsat'}},corapt3={buildoptions={['58']='corsat'}},legapt3={buildoptions={['58']='corsat'}},armlwall={energycost=25000,metalcost=1300,weapondefs={lightning={energypershot=200,range=430}}},armclaw={collisionvolumeoffsets='0 -2 0',collisionvolumescales='30 51 30',collisionvolumetype='Ell',usepiececollisionvolumes=0,weapondefs={dclaw={energypershot=60}}},legdtl={weapondefs={dclaw={energypershot=60}}},armamd={metalcost=1800,energycost=41000,weapondefs={amd_rocket={coverage=2125,stockpiletime=70}}},corfmd={metalcost=1800,energycost=41000,weapondefs={fmd_rocket={coverage=2125,stockpiletime=70}}},legabm={metalcost=1800,energycost=41000,weapondefs={fmd_rocket={coverage=2125,stockpiletime=70}}},corwint2={metalcost=400},legwint2={metalcost=400},legdtr={buildtime=5250,energycost=5500,metalcost=400,collisionvolumeoffsets='0 -10 0',collisionvolumescales='39 88 39',collisionvolumetype='Ell',usepiececollisionvolumes=0,weapondefs={corlevlr_weapon={areaofeffect=30,avoidfriendly=true,collidefriendly=false,cegtag='railgun',range=650,energypershot=75,explosiongenerator='custom:plasmahit-sparkonly',rgbcolor='0.34 0.64 0.94',soundhit='mavgun3',soundhitwet='splshbig',soundstart='lancefire',weaponvelocity=1300,damage={default=550}}}},armrespawn={blocking=false,canresurrect=true},legnanotcbase={blocking=false,canresurrect=true},correspawn={blocking=false,canresurrect=true},legrwall={collisionvolumeoffsets='0 -3 0',collisionvolumescales='32 50 32',collisionvolumetype='CylY',energycost=21000,metalcost=1400,weapondefs={railgunt2={collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,range=725,reloadtime=3,energypershot=200,damage={default=1500}}},weapons={['1']={def='railgunt2',onlytargetcategory='SURFACE'}}},cormwall={energycost=18000,metalcost=1350,weapondefs={exp_heavyrocket={areaofeffect=70,collidefriendly=0,collidefeature=0,cameraShake=0,energypershot=125,avoidfeature=0,avoidfriendly=0,burst=1,burstrate=0,colormap='0.75 0.73 0.67 0.024   0.37 0.4 0.30 0.021   0.22 0.21 0.14 0.018  0.024 0.014 0.009 0.03   0.0 0.0 0.0 0.008',craterareaofeffect=0,explosiongenerator='custom:burnblack',flamegfxtime=1,flighttime=1.05,name='Raptor Boomer',reloadtime=1.5,rgbcolor='1 0.25 0.1',range=700,size=2,proximitypriority=nil,impactonly=1,trajectoryheight=1,targetmoveerror=0.2,tracks=true,weaponacceleration=660,weaponvelocity=950,damage={default=1050}}}},cormaw={collisionvolumeoffsets='0 -2 0',collisionvolumescales='30 51 30',collisionvolumetype='Ell',usepiececollisionvolumes=false,metalcost=350,energycost=2500,weapondefs={dmaw={collidefriendly=0,collidefeature=0,areaofeffect=80,edgeeffectiveness=0.45,energypershot=50,burst=24,rgbcolor='0.051 0.129 0.871',rgbcolor2='0.57 0.624 1',sizegrowth=0.8,range=450,intensity=0.68,damage={default=28}}}},legdtf={collisionvolumeoffsets='0 -24 0',collisionvolumescales='30 51 30',collisionvolumetype='Ell',metalcost=350,energycost=2750,weapondefs={dmaw={collidefriendly=0,collidefeature=0,areaofeffect=80,edgeeffectiveness=0.45,energypershot=50,burst=24,sizegrowth=2,range=450,intensity=0.38,sprayangle=500,damage={default=30}}}},corhllllt={collisionvolumeoffsets='0 -24 0',collisionvolumescales='30 51 30',metalcost=415,energycost=9500,buildtime=10000,health=2115},corhlt={energycost=5500,metalcost=520,weapondefs={cor_laserh1={range=750,reloadtime=0.95,damage={default=395,vtol=35}}}},armhlt={energycost=5700,metalcost=510,weapondefs={arm_laserh1={range=750,reloadtime=1,damage={default=405,vtol=35}}}},armbrtha={explodeas='fusionExplosion',energycost=500000,metalcost=18500,buildtime=175000,turnrate=16000,health=10450,weapondefs={ARMBRTHA_MAIN={areaofeffect=50,collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,beamtime=2.5,corethickness=0.1,craterareaofeffect=90,craterboost=0,cratermult=0,cameraShake=0,edgeeffectiveness=0.3,energypershot=14000,explosiongenerator='custom:laserhit-large-blue',firestarter=90,impulseboost=0,impulsefactor=0,largebeamlaser=true,laserflaresize=1,impactonly=1,name='Experimental Duction Beam',noselfdamage=true,range=2400,reloadtime=13,rgbcolor='0.4 0.2 0.6',scrollspeed=13,soundhitdry='',soundhitwet='sizzle',soundstart='hackshotxl3',soundtrigger=1,targetmoveerror=0.3,texture3='largebeam',thickness=14,tilelength=150,tolerance=10000,turret=true,turnrate=16000,weapontype='LaserCannon',weaponvelocity=3100,damage={commanders=480,default=34000}}},weapons={['1']={badtargetcategory='VTOL GROUNDSCOUT',def='ARMBRTHA_MAIN',onlytargetcategory='SURFACE'}}},corint={explodeas='fusionExplosion',energycost=505000,metalcost=19500,buildtime=170000,health=12450,footprintx=6,footprintz=6,weapondefs={CORINT_MAIN={areaofeffect=70,collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,beamtime=2.5,corethickness=0.1,craterareaofeffect=90,craterboost=0,cratermult=0,cameraShake=0,edgeeffectiveness=0.3,energypershot=17000,explosiongenerator='custom:laserhit-large-blue',firestarter=90,impulseboost=0,impulsefactor=0,largebeamlaser=true,laserflaresize=1,impactonly=1,name='Mini DeathStar',noselfdamage=true,range=2800,reloadtime=15,rgbcolor='0 1 0',scrollspeed=13,soundhitdry='',soundhitwet='sizzle',soundstart='annigun1',soundtrigger=1,targetmoveerror=0.3,texture3='largebeam',thickness=14,tilelength=150,tolerance=10000,turret=true,turnrate=1600,weapontype='LaserCannon',weaponvelocity=3100,damage={commanders=480,default=50000}}},weapons={['1']={badtargetcategory='VTOL GROUNDSCOUT',def='CORINT_MAIN',onlytargetcategory='SURFACE'}}},leglrpc={explodeas='fusionExplosion',energycost=555000,metalcost=21000,buildtime=150000,health=11000,footprintx=6,footprintz=6,weapondefs={LEGLRPC_MAIN={areaofeffect=70,collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,beamtime=0.5,burst=3,burstrate=0.4,corethickness=0.1,craterareaofeffect=90,craterboost=0,cratermult=0,cameraShake=0,edgeeffectiveness=0.3,energypershot=10000,explosiongenerator='custom:laserhit-large-red',firestarter=90,impactonly=1,impulseboost=0,impulsefactor=0,largebeamlaser=true,laserflaresize=1,name='The Eagle Standard',noselfdamage=true,range=2150,reloadtime=3,rgbcolor='0/1/0.4',scrollspeed=13,soundhitdry='',soundhitwet='sizzle',soundstart='lasrcrw1',soundtrigger=1,targetmoveerror=0.3,texture3='largebeam',thickness=12,tilelength=150,tolerance=10000,turret=true,turnrate=16000,weapontype='LaserCannon',weaponvelocity=3100,damage={commanders=480,default=6000}}},weapons={['1']={badtargetcategory='VTOL GROUNDSCOUT',def='LEGLRPC_MAIN',onlytargetcategory='SURFACE'}}}}
    if data then
        ApplyTweakUnits(data)
    end
end

do
    -- Tweak file: 9-tweakunits1.json
    local data = -- Legion NuttyB Evolving Commander (Migrated)
{legcom={footprintx=2,footprintz=2,energymake=50,metalmake=5,health=6000,autoheal=40,buildoptions={'legrezbot','legdtl','legdtf','legdtr','legjam','legwin'},customparams={evolution_target='legcomlvl2',evolution_condition='timer_global',evolution_timer=420},weapondefs={legcomlaser={corethickness=0.25,duration=0.09,name='Light close-quarters g2g/g2a laser',range=360,reloadtime=0.2,rgbcolor='0 2 1',soundhitdry='',soundhitwet='sizzle',soundstart='lasrcrw1',soundtrigger=true,sprayangle=700,thickness=6,texture1='shot',texture2='empty',weapontype='LaserCannon',weaponvelocity=2100,damage={default=250}},shotgun={areaofeffect=60,energypershot=0,avoidfeature=false,craterboost=0,cratermult=0,cameraShake=0,edgeeffectiveness=0.65,explosiongenerator='custom:genericshellexplosion-small',impulseboost=0.2,impulsefactor=0.2,intensity=3,name='6 Gauge Shotgun',noselfdamage=true,predictboost=1,projectiles=6,range=320,reloadtime=2,rgbcolor='1 0.75 0.25',size=2,soundhit='xplomed2xs',soundhitwet='splsmed',soundstart='kroggie2xs',soundstartvolume=12,sprayangle=2000,turret=true,commandfire=true,weapontimer=1,weapontype='Cannon',weaponvelocity=600,stockpile=true,stockpiletime=5,customparams={stockpilelimit=10},damage={default=1800,commanders=0}}},weapons={['3']={def='shotgun',onlytargetcategory='SURFACE'}}},legcomlvl2={footprintx=2,footprintz=2,energymake=150,metalmake=15,speed=57.5,autoheal=100,health=6700,customparams={evolution_condition='timer_global',evolution_timer=1020},buildoptions={'legrezbot','legadvsol','corhllt','leggeo','legnanotc','legjam','legdtf','legmg','legrad','legdtl','legdtr','legrhapsis','legwin'},weapondefs={legcomlaser={accuracy=50,areaofeffect=12,avoidfriendly=false,avoidfeature=false,collidefriendly=false,collidefeature=true,beamtime=0.09,corethickness=0.3,duration=0.09,explosiongenerator='custom:laserhit-small-red',firestarter=70,impactonly=1,impulseboost=0,impulsefactor=0,name='Light close-quarters g2g/g2a laser',noselfdamage=true,range=500,reloadtime=0.2,rgbcolor='0 0.95 0.05',soundhitdry='',soundhitwet='sizzle',soundstart='lasrcrw1',soundtrigger=true,sprayangle=500,targetmoveerror=0.05,thickness=7,tolerance=1000,texture1='shot',texture2='empty',turret=true,weapontype='LaserCannon',weaponvelocity=2200,damage={bombers=180,default=450,fighters=110,subs=5}},shotgun={areaofeffect=65,energypershot=0,avoidfeature=false,craterboost=0,cratermult=0,cameraShake=0,edgeeffectiveness=0.65,explosiongenerator='custom:genericshellexplosion-small',impulseboost=0.2,impulsefactor=0.2,intensity=3,name='12 Gauge Shotgun',noselfdamage=true,predictboost=1,projectiles=7,range=440,reloadtime=2,rgbcolor='1 0.75 0.25',size=2.5,soundhit='xplomed2xs',soundhitwet='splsmed',soundstart='kroggie2xs',soundstartvolume=12,sprayangle=2250,turret=true,commandfire=true,weapontimer=1,weapontype='Cannon',weaponvelocity=600,stockpile=true,stockpiletime=5,customparams={stockpilelimit=15},damage={default=2200,commanders=0}}},weapons={['1']={def='legcomlaser',onlytargetcategory='NOTSUB',fastautoretargeting=true},['3']={def='shotgun',onlytargetcategory='SURFACE'}}},legcomlvl3={footprintx=2,footprintz=2,energymake=1280,metalmake=40,speed=70.5,workertime=700,autoheal=150,health=7500,customparams={evolution_condition='timer_global',evolution_timer=1440},buildoptions={'legdeflector','legfus','legbombard','legadvestore','legmoho','legadveconv','legarad','legajam','legforti','legacluster','legamstor','legflak','legabm','legbastion','legdtr','legdtf','legrezbot','legdtl','leglab','legendary_bastion','legnanotct3','legapopupdef'},weapondefs={legcomlaser={accuracy=50,areaofeffect=12,avoidfriendly=true,avoidfeature=true,collidefriendly=false,collidefeature=true,beamtime=0.09,corethickness=0.55,duration=0.09,explosiongenerator='custom:laserhit-small-red',firestarter=70,impactonly=0,impulseboost=0,impulsefactor=0,name='Light close-quarters g2g/g2a laser',noselfdamage=true,range=640,reloadtime=0.2,rgbcolor='0 0.2 0.8',soundhitdry='',soundhitwet='sizzle',soundstart='lasrcrw1',soundtrigger=true,sprayangle=500,targetmoveerror=0.05,thickness=7,tolerance=1000,texture1='shot',texture2='empty',turret=true,weapontype='LaserCannon',weaponvelocity=2500,damage={bombers=180,default=650,fighters=110,subs=5}},shotgun={areaofeffect=90,energypershot=0,avoidfeature=false,craterboost=0,cratermult=0,cameraShake=0,edgeeffectiveness=0.65,explosiongenerator='custom:genericshellexplosion-small',impulseboost=0.2,impulsefactor=0.2,intensity=3,name='12 Gauge Shotgun',noselfdamage=true,predictboost=1,projectiles=7,range=540,reloadtime=2,rgbcolor='1 0.75 0.25',size=2.5,soundhit='xplomed2xs',soundhitwet='splsmed',soundstart='kroggie2xs',soundstartvolume=12,sprayangle=2500,turret=true,commandfire=true,weapontimer=1,weapontype='Cannon',weaponvelocity=600,stockpile=true,stockpiletime=5,customparams={stockpilelimit=20},damage={default=3200,commanders=0}}},weapons={['1']={def='legcomlaser',onlytargetcategory='NOTSUB',fastautoretargeting=true},['3']={def='shotgun',onlytargetcategory='SURFACE'},['5']={def=''}}},legcomlvl4={footprintx=2,footprintz=2,energymake=1980,metalmake=46,speed=88.5,workertime=1000,autoheal=180,health=24500,customparams={evolution_condition='timer_global',evolution_timer=1740},buildoptions={'legdeflector','legfus','legbombard','legadvestore','legmoho','legadveconv','legeshotgunmech','legarad','legajam','legkeres','legacluster','legamstor','legflak','legabm','legbastion','legendary_bastion','legnanotct2','legnanotct2plat','legrwall','leglab','legtarg','legsd','legpede','legerailtank','legeheatraymech','legrezbot','legafus','leglraa','legdtl','legdtf','legministarfall','legstarfall','leggatet3','legperdition','legsilo','legsrailt4','legelrpcmech','legdtr','legnanotct3','legapopupdef'},weapondefs={legcomlaser={accuracy=50,areaofeffect=12,avoidfriendly=true,avoidfeature=true,collidefriendly=false,collidefeature=true,beamtime=0.1,corethickness=0.5,duration=0.09,explosiongenerator='custom:laserhit-small-red',firestarter=70,impactonly=0,impulseboost=0,impulsefactor=0,name='Light close-quarters g2g/g2a laser',noselfdamage=true,range=900,reloadtime=0.1,rgbcolor='0.45 0 1',soundhitdry='',soundhitwet='sizzle',soundstart='lasrcrw1',soundtrigger=1,sprayangle=400,targetmoveerror=0.05,thickness=6,tolerance=1000,texture1='shot',texture2='empty',turret=true,weapontype='LaserCannon',weaponvelocity=3000,damage={bombers=180,default=1750,fighters=110,subs=5}},shotgun={areaofeffect=75,energypershot=0,avoidfeature=false,craterboost=0,cratermult=0,cameraShake=0,edgeeffectiveness=0.65,explosiongenerator='custom:genericshellexplosion-small',impulseboost=0.2,impulsefactor=0.2,intensity=3,name='60 Gauge Raptor Popper',noselfdamage=true,predictboost=1,projectiles=9,range=550,reloadtime=1,rgbcolor='1 0.75 0.25',size=5,soundhit='xplomed2xs',soundhitwet='splsmed',soundstart='kroggie2xs',soundstartvolume=12,sprayangle=3000,turret=true,commandfire=true,weapontimer=1,weapontype='Cannon',weaponvelocity=600,stockpile=true,stockpiletime=4,customparams={stockpilelimit=20},damage={default=4400,commanders=0}}},weapons={['1']={def='legcomlaser',onlytargetcategory='NOTSUB',fastautoretargeting=true},['3']={def='shotgun',onlytargetcategory='SURFACE'},['5']={def=''}}},legcomlvl5={footprintx=2,footprintz=2,energymake=2280,metalmake=64,speed=100,workertime=1700,autoheal=4500,health=53900,buildoptions={'legdeflector','legfus','legbombard','legadvestore','legmoho','legadveconv','legeshotgunmech','legarad','legajam','legkeres','legacluster','legamstor','legflak','legabm','legbastion','legendary_bastion','legnanotct2','legnanotct2plat','legrwall','leglab','legtarg','legsd','legpede','legerailtank','legeheatraymech','legrezbot','legafus','leglraa','legdtl','legdtf','legministarfall','legstarfall','leggatet3','legperdition','legsilo','legsrailt4','legelrpcmech','legdtr','legnanotct3','legapopupdef'},weapondefs={machinegun={accuracy=80,areaofeffect=10,avoidfeature=false,beamburst=true,beamdecay=1,beamtime=0.07,burst=6,burstrate=0.10667,camerashake=0,corethickness=0.35,craterareaofeffect=0,craterboost=0,cratermult=0,edgeeffectiveness=1,explosiongenerator='custom:laserhit-medium-red',firestarter=10,impulsefactor=0,largebeamlaser=true,laserflaresize=30,name='Rapid-fire close quarters g2g armor-piercing laser',noselfdamage=true,pulsespeed='q8',range=1100,reloadtime=0.5,rgbcolor='0.7 0.3 1.0',rgbcolor2='0.8 0.6 1.0',soundhitdry='',soundhitwet='sizzle',soundstart='lasfirerc',soundtrigger=1,sprayangle=500,targetborder=0.2,thickness=5.5,tolerance=4500,turret=true,weapontype='BeamLaser',weaponvelocity=920,damage={default=1300,vtol=180}},shotgunarm={areaofeffect=112,commandfire=true,avoidfeature=false,craterboost=0,cratermult=0,cameraShake=0,edgeeffectiveness=0.65,explosiongenerator='custom:genericshellexplosion-medium',impulsefactor=0.8,intensity=0.2,mygravity=1,name='GaussCannon',noselfdamage=true,predictboost=1,projectiles=20,range=650,reloadtime=1,rgbcolor='0.8 0.4 1.0',size=4,sizeDecay=0.044,stages=16,alphaDecay=0.66,soundhit='xplomed2xs',soundhitwet='splsmed',soundstart='kroggie2xs',sprayangle=3500,tolerance=6000,turret=true,waterweapon=true,weapontimer=2,weapontype='Cannon',weaponvelocity=900,stockpile=true,stockpiletime=2,customparams={stockpilelimit=50},damage={default=10000,commanders=0}},exp_heavyrocket={areaofeffect=70,collidefriendly=0,collidefeature=0,cameraShake=0,energypershot=125,avoidfeature=0,avoidfriendly=0,burst=4,burstrate=0.3,cegtag='missiletrailsmall-red',colormap='0.75 0.73 0.67 0.024   0.37 0.4 0.30 0.021   0.22 0.21 0.14 0.018  0.024 0.014 0.009 0.03   0.0 0.0 0.0 0.008',craterboost=0,craterareaofeffect=0,cratermult=0,dance=24,edgeeffectiveness=0.65,explosiongenerator='custom:burnblack',firestarter=70,flighttime=1.05,flamegfxtime=1,impulsefactor=0.123,impactonly=1,model='catapultmissile.s3o',movingaccuracy=600,name='Raptor Boomer',noselfdamage=true,proximitypriority=nil,range=700,reloadtime=1,smoketrail=true,smokePeriod=4,smoketime=16,smokesize=8.5,smokecolor=0.5,size=2,smokeTrailCastShadow=false,soundhit='rockhit',soundhitwet='splsmed',soundstart='rapidrocket3',startvelocity=165,rgbcolor='1 0.25 0.1',texture1='null',texture2='smoketrailbar',trajectoryheight=1,targetmoveerror=0.2,turnrate=5000,tracks=true,turret=true,allowNonBlockingAim=true,weaponacceleration=660,weapontimer=6,weapontype='MissileLauncher',weaponvelocity=950,wobble=2000,damage={default=1300},customparams={exclude_preaim=true,overrange_distance=777,projectile_destruction_method='descend'}}},weapons={['1']={def='machinegun',onlytargetcategory='NOTSUB',fastautoretargeting=true},['3']={def='shotgunarm',onlytargetcategory='WEAPON'},['5']={def='exp_heavyrocket',onlytargetcategory='SURFACE'}}}}
    if data then
        ApplyTweakUnits(data)
    end
end

do
    -- Tweak file: 10-tweakunits2.json
    local data = -- Armada NuttyB Evolving Commander (Migrated)
{armcom={customparams={evolution_target='armcomlvl2',evolution_condition='timer_global',evolution_timer=420},energymake=100,metalmake=10,autoheal=55,health=4500,speed=41,canresurrect=true,buildoptions={'armsolar','armwin','armmstor','armestor','armmex','armmakr','armlab','armvp','armap','armeyes','armrad','armdrag','armllt','armrl','armdl','armtide','armuwms','armuwes','armuwmex','armfmkr','armsy','armfdrag','armtl','armfrt','armfrad','armhp','armfhp','armgeo','armamex','armhp','armbeamer','armjamt','armsy','armrectr','armclaw'},weapondefs={armcomlaser={range=330,rgbcolor='0.7 1 1',soundstart='lasrfir1',damage={default=175}},old_armsnipe_weapon={areaofeffect=32,avoidfeature=true,avoidfriendly=true,collidefeature=true,collidefriendly=false,corethickness=0.75,craterareaofeffect=0,craterboost=0,commandfire=true,cratermult=0,cegtag='railgun',duration=0.12,edgeeffectiveness=0.85,energypershot=400,explosiongenerator='custom:laserhit-large-blue',firestarter=100,impulseboost=0.4,impulsefactor=1,intensity=0.8,name='Long-range g2g armor-piercing rifle',range=550,reloadtime=1,rgbcolor='0 1 1',rgbcolor2='0 1 1',soundhit='sniperhit',soundhitwet='sizzle',soundstart='sniper3',soundtrigger=true,stockpile=true,stockpiletime=7,customparams={stockpilelimit=5},texture1='shot',texture2='empty',thickness=4,tolerance=1000,turret=true,weapontype='LaserCannon',weaponvelocity=3000,damage={commanders=100,default=4900}}},weapons={['3']={def='old_armsnipe_weapon',onlytargetcategory='NOTSUB'}}},armcomlvl2={autoheal=90,builddistance=175,canresurrect=true,energymake=315,health=7000,speed=57.5,metalmake=20,workertime=900,buildoptions={'armsolar','armwin','armmstor','armestor','armmex','armmakr','armlab','armvp','armap','armeyes','armrad','armdrag','armllt','armrl','armdl','armtide','armuwms','armuwes','armuwmex','armfmkr','armsy','armfdrag','armtl','armfrt','armfrad','armhp','armfhp','armadvsol','armgeo','armamex','armnanotcplat','armhp','armnanotc','armclaw','armbeamer','armhlt','armguard','armferret','armcir','armjamt','armjuno','armsy','armrectr'},customparams={evolution_target='armcomlvl3',evolution_condition='timer_global',evolution_timer=1320},weapondefs={armcomlaser={areaofeffect=16,avoidfeature=false,beamtime=0.1,corethickness=0.1,craterareaofeffect=0,craterboost=0,cratermult=0,cylindertargeting=1,edgeeffectiveness=1,explosiongenerator='custom:laserhit-small-red',firestarter=70,impactonly=1,impulseboost=0,impulsefactor=0,laserflaresize=7.7,name='Light close-quarters g2g/g2a laser',noselfdamage=true,range=425,reloadtime=0.7,rgbcolor='0 1 1',soundhitdry='',soundhitwet='sizzle',soundstart='lasrfir1',soundtrigger=1,targetmoveerror=0.05,thickness=4,tolerance=10000,turret=true,weapontype='BeamLaser',weaponvelocity=900,damage={default=950,VTOL=150}},old_armsnipe_weapon={areaofeffect=42,avoidfeature=true,avoidfriendly=true,collidefeature=true,collidefriendly=false,corethickness=0.75,craterareaofeffect=0,craterboost=0,commandfire=true,cratermult=0,cegtag='railgun',duration=0.12,edgeeffectiveness=0.85,energypershot=700,explosiongenerator='custom:laserhit-large-blue',firestarter=100,impulseboost=0.4,impulsefactor=1,intensity=1,name='Long-range g2g armor-piercing rifle',range=700,reloadtime=1,rgbcolor='0.2 0.1 1',rgbcolor2='0.2 0.1 1',soundhit='sniperhit',soundhitwet='sizzle',soundstart='sniper3',soundtrigger=true,stockpile=true,stockpiletime=6,customparams={stockpilelimit=10},texture1='shot',texture2='empty',thickness=4,tolerance=1000,turret=true,weapontype='LaserCannon',weaponvelocity=3000,damage={commanders=10,default=11000}}},weapons={['1']={def='armcomlaser',onlytargetcategory='NOTSUB',fastautoretargeting=true},['3']={def='old_armsnipe_weapon',onlytargetcategory='NOTSUB'}}},armcomlvl3={autoheal=50,builddistance=250,canresurrect=true,energymake=2712,health=10000,speed=71.5,metalmake=62,workertime=1500,buildoptions={'armanni','armpb','armamb','armmoho','armuwmme','armflak','armmercury','armgate','armsd','armfort','armtarg','armarad','armamd','armveil','armuwadvms','armuwadves','armmmkr','armclaw','armjuno','armuwmex','armhp','armsy','armfdrag','armtl','armfrt','armfrad','armhp','armlab','armvp','armap','armsy','armuwmmm','armuwfus','armplat','armfdrag','armfhlt','armfflak','armatl','armkraken','armnanotcplat','armbrtha','armannit3','armlwall','armnanotct2','armafus','armfus','armckfus','armraz','armzeus','armsnipe','armvang','armrectr','armgatet3','legendary_pulsar','armnanotct3'},customparams={evolution_target='armcomlvl4',evolution_condition='timer_global',evolution_timer=1740},weapondefs={old_armsnipe_weapon={areaofeffect=64,avoidfeature=true,avoidfriendly=true,collidefeature=true,collidefriendly=false,corethickness=0.75,craterareaofeffect=0,craterboost=0,commandfire=true,cratermult=0,cegtag='railgun',duration=0.12,edgeeffectiveness=1,energypershot=2000,explosiongenerator='custom:laserhit-large-blue',firestarter=100,impulseboost=0.4,impulsefactor=1,intensity=1.4,name='Long-range g2g armor-piercing rifle',range=1250,reloadtime=0.5,rgbcolor='0.4 0.1 0.7',rgbcolor2='0.4 0.1 0.7',soundhit='sniperhit',soundhitwet='sizzle',soundstart='sniper3',soundtrigger=true,stockpile=true,stockpiletime=3,customparams={stockpilelimit=10},texture1='shot',texture2='empty',thickness=6,tolerance=1000,turret=true,weapontype='LaserCannon',weaponvelocity=3000,damage={commanders=10,default=35000}},armcomlaser={areaofeffect=12,avoidfeature=false,beamtime=0.1,corethickness=0.1,craterareaofeffect=0,craterboost=0,cratermult=0,cylindertargeting=1,edgeeffectiveness=1,explosiongenerator='custom:laserhit-small-red',firestarter=70,impactonly=1,impulseboost=0,impulsefactor=0,laserflaresize=7.7,name='Light close-quarters g2g/g2a laser',noselfdamage=true,range=500,reloadtime=0.6,rgbcolor='0.1 0 1',soundhitdry='',soundhitwet='sizzle',soundstart='lasrcrw2',soundtrigger=1,targetmoveerror=0.05,thickness=6,tolerance=10000,turret=true,weapontype='BeamLaser',weaponvelocity=900,damage={default=1450,VTOL=180}}},weapons={['1']={def=''},['3']={def='old_armsnipe_weapon',onlytargetcategory='NOTSUB'},['4']={def=''},['5']={badtargetcategory='MOBILE',def='armcomlaser',onlytargetcategory='NOTSUB',fastautoretargeting=true},['6']={def=''}}},armcomlvl4={autoheal=150,builddistance=300,canresurrect=true,energymake=3112,health=20000,speed=82,metalmake=86,workertime=2000,buildoptions={'armanni','armpb','armamb','armmoho','armuwmme','armflak','armmercury','armgate','armsd','armfort','armtarg','armarad','armamd','armveil','armuwadvms','armuwadves','armmmkr','armclaw','armjuno','armuwmex','armhp','armsy','armfdrag','armtl','armfrt','armfrad','armhp','armlab','armvp','armap','armsy','armuwmmm','armuwfus','armplat','armfdrag','armfhlt','armfflak','armatl','armkraken','armnanotcplat','armbrtha','armannit3','armlwall','armnanotct2','armafus','armfus','armckfus','armraz','armzeus','armsnipe','armvang','armrectr','armgatet3','legendary_pulsar','armnanotct3'},weapondefs={old_armsnipe_weapon={areaofeffect=72,avoidfeature=true,avoidfriendly=true,collidefeature=true,collidefriendly=false,corethickness=0.75,craterareaofeffect=0,craterboost=0,commandfire=true,cratermult=0,cegtag='railgun',duration=0.12,edgeeffectiveness=1,energypershot=2000,explosiongenerator='custom:laserhit-large-blue',firestarter=100,impulseboost=0.4,impulsefactor=1,intensity=1.4,name='Long-range g2g armor-piercing rifle',range=1250,reloadtime=0.5,rgbcolor='0.4 0.1 0.7',rgbcolor2='0.4 0.1 0.7',soundhit='sniperhit',soundhitwet='sizzle',soundstart='sniper3',soundtrigger=true,stockpile=true,stockpiletime=2,customparams={stockpilelimit=15},texture1='shot',texture2='empty',thickness=6,tolerance=1000,turret=true,weapontype='LaserCannon',weaponvelocity=3000,damage={commanders=10,default=45000}},ata={areaofeffect=16,avoidfeature=false,beamtime=1.25,collidefriendly=false,corethickness=0.5,craterareaofeffect=0,craterboost=0,cratermult=0,edgeeffectiveness=0.3,energypershot=7000,explosiongenerator='custom:laserhit-large-blue',firestarter=90,impulsefactor=0,largebeamlaser=true,laserflaresize=7,name='Heavy long-range g2g tachyon accelerator beam',noselfdamage=true,range=1100,reloadtime=15,rgbcolor='1 0 1',scrollspeed=5,soundhitdry='',soundhitwet='sizzle',soundstart='annigun1',soundtrigger=1,texture3='largebeam',thickness=10,tilelength=150,tolerance=10000,turret=true,weapontype='BeamLaser',weaponvelocity=3100,damage={commanders=480,default=48000}},armcomlaser={areaofeffect=12,avoidfeature=false,beamtime=0.1,corethickness=0.1,craterareaofeffect=0,craterboost=0,cratermult=0,cylindertargeting=1,edgeeffectiveness=1,explosiongenerator='custom:laserhit-small-red',firestarter=70,impactonly=1,impulseboost=0,impulsefactor=0,laserflaresize=7.7,name='Light close-quarters g2g/g2a laser',noselfdamage=true,range=550,reloadtime=0.5,rgbcolor='0.659 0 1',soundhitdry='',soundhitwet='sizzle',soundstart='lasrcrw2',soundtrigger=1,targetmoveerror=0.05,thickness=6,tolerance=10000,turret=true,weapontype='BeamLaser',weaponvelocity=900,damage={default=1750,VTOL=200}}},weapons={['1']={def='armcomlaser',onlytargetcategory='NOTSUB',fastautoretargeting=true},['3']={def='old_armsnipe_weapon',onlytargetcategory='NOTSUB'},['4']={badtargetcategory='VTOL GROUNDSCOUT',def='ATA',onlytargetcategory='SURFACE'},['5']={def=''},['6']={def=''}}}}
    if data then
        ApplyTweakUnits(data)
    end
end

do
    -- Tweak file: 11-tweakunits3.json
    local data = -- Cortex NuttyB Evolving Commander (Migrated)
{corcom={customparams={evolution_target='corcomlvl2',evolution_condition='timer_global',evolution_timer=420},autoheal=80,speed=45,energymake=75,metalmake=6,health=5500,buildoptions={['28']='corhllt',['29']='cornecro',['30']='corlevlr',['31']='corak',['32']='cormaw'},weapondefs={corcomlaser={range=370,damage={bombers=180,default=260,fighters=110,subs=5}},disintegrator={energypershot=1000,reloadtime=8}}},corcomlvl2={speed=62,health=8500,energymake=255,metalmake=16,autoheal=300,builddistance=200,workertime=600,buildoptions={['1']='corsolar',['2']='coradvsol',['3']='corwin',['4']='corgeo',['5']='cormstor',['6']='corestor',['7']='cormex',['8']='corexp',['9']='cormakr',['10']='corcan',['11']='correap',['12']='corlab',['13']='corvp',['14']='corap',['15']='corhp',['16']='cornanotc',['17']='coreyes',['18']='corrad',['19']='cordrag',['20']='cormaw',['21']='corllt',['22']='corhllt',['23']='corhlt',['24']='corpun',['25']='corrl',['26']='cormadsam',['27']='corerad',['28']='cordl',['29']='corjamt',['30']='corjuno',['31']='corsy',['32']='coruwgeo',['33']='corfasp',['34']='cornerco',['35']='coruwes',['36']='corplat',['37']='corfhp',['38']='coruwms',['39']='corfhlt',['40']='cornanotcplat',['41']='corfmkr',['42']='cortide',['43']='corfrad',['44']='corfrt',['45']='corfdrag',['46']='cortl',['47']='cornecro'},customparams={evolution_target='corcomlvl3',evolution_condition='timer_global',evolution_timer=1320,shield_power=500,shield_radius=100},weapondefs={armcomlaser={areaofeffect=16,avoidfeature=false,beamtime=0.1,corethickness=0.1,craterareaofeffect=0,craterboost=0,cratermult=0,cylindertargeting=1,edgeeffectiveness=1,explosiongenerator='custom:laserhit-small-red',firestarter=70,impactonly=1,impulseboost=0,impulsefactor=0,laserflaresize=7.7,name='Light close-quarters g2g/g2a laser',noselfdamage=true,range=500,reloadtime=0.4,rgbcolor='0.6 0.3 0.8',soundhitdry='',soundhitwet='sizzle',soundstart='lasrfir1',soundtrigger=1,targetmoveerror=0.05,thickness=4,tolerance=10000,turret=true,weapontype='BeamLaser',weaponvelocity=900,damage={bombers=180,default=1500,fighters=110,subs=5}},disintegrator={areaofeffect=36,avoidfeature=false,avoidfriendly=false,avoidground=false,bouncerebound=0,cegtag='dgunprojectile',commandfire=true,craterboost=0,cratermult=0.15,edgeeffectiveness=0.15,energypershot=500,explosiongenerator='custom:expldgun',firestarter=100,firesubmersed=false,groundbounce=true,impulseboost=0,impulsefactor=0,name='Disintegrator',noexplode=true,noselfdamage=true,range=250,reloadtime=6,paralyzer={},soundhit='xplomas2s',soundhitwet='sizzlexs',soundstart='disigun1',soundhitvolume=36,soundstartvolume=96,soundtrigger=true,tolerance=10000,turret=true,waterweapon=true,weapontimer=4.2,weapontype='DGun',weaponvelocity=300,damage={commanders=0,default=20000,raptors=10000}}},weapons={['1']={def='armcomlaser',onlytargetcategory='NOTSUB',fastautoretargeting=true},['3']={def='DISINTEGRATOR',onlytargetcategory='NOTSUB'}}},corcomlvl3={speed=80,health=30000,energymake=2180,metalmake=49,autoheal=1500,workertime=1200,builddistance=250,buildoptions={['1']='corfus',['2']='corafus',['3']='corageo',['4']='corbhmth',['5']='cormoho',['6']='cormexp',['7']='cormmkr',['8']='coruwadves',['9']='coruwadvms',['10']='corarad',['11']='corshroud',['12']='corfort',['13']='corlab',['14']='cortarg',['15']='corsd',['16']='corgate',['17']='cortoast',['18']='corvipe',['19']='cordoom',['20']='corflak',['21']='corscreamer',['22']='corvp',['23']='corfmd',['24']='corap',['25']='corint',['26']='corplat',['27']='corsy',['28']='coruwmme',['29']='coruwmmm',['30']='corenaa',['31']='corfdoom',['32']='coratl',['33']='coruwfus',['34']='corjugg',['35']='corshiva',['36']='corsumo',['37']='corgol',['38']='corkorg',['39']='cornanotc2plat',['40']='cornanotct2',['41']='cornecro',['42']='cordoomt3',['43']='corhllllt',['44']='cormaw',['45']='cormwall',['46']='corgatet3',['47']='legendary_bulwark',['48']='cornanotct3'},customparams={evolution_target='corcomlvl4',evolution_condition='timer_global',evolution_timer=1740},weapondefs={corcomlaser={areaofeffect=12,avoidfeature=false,beamtime=0.1,corethickness=0.1,craterareaofeffect=0,craterboost=0,cratermult=0,cylindertargeting=1,edgeeffectiveness=1,explosiongenerator='custom:laserhit-small-red',firestarter=70,impactonly=1,impulseboost=0,impulsefactor=0,laserflaresize=5.5,name='J7Laser',noselfdamage=true,range=900,reloadtime=0.4,rgbcolor='0.7 0 1',soundhitdry='',soundhitwet='sizzle',soundstart='lasrfir1',soundtrigger=1,targetmoveerror=0.05,thickness=3,tolerance=10000,turret=true,weapontype='BeamLaser',weaponvelocity=900,damage={default=2000,subs=5}},disintegrator={areaofeffect=36,avoidfeature=false,avoidfriendly=false,avoidground=false,bouncerebound=0,cegtag='dgunprojectile',commandfire=true,craterboost=0,cratermult=0.15,edgeeffectiveness=0.15,energypershot=500,explosiongenerator='custom:expldgun',firestarter=100,firesubmersed=false,groundbounce=true,impulseboost=0,impulsefactor=0,name='Disintegrator',noexplode=true,noselfdamage=true,range=250,reloadtime=3,paralyzer={},soundhit='xplomas2s',soundhitwet='sizzlexs',soundstart='disigun1',soundhitvolume=36,soundstartvolume=96,soundtrigger=true,size=4,tolerance=10000,turret=true,waterweapon=true,weapontimer=4.2,weapontype='DGun',weaponvelocity=300,damage={commanders=0,default=20000,scavboss=1000,raptors=10000}}},weapons={['1']={def='CORCOMLASER',onlytargetcategory='NOTSUB',fastautoretargeting=true},['5']={def=''}}},corcomlvl4={speed=80,health=50000,energymake=2380,metalmake=56,autoheal=3550,workertime=1800,builddistance=300,buildoptions={['1']='corfus',['2']='corafus',['3']='corageo',['4']='corbhmth',['5']='cormoho',['6']='cormexp',['7']='cormmkr',['8']='coruwadves',['9']='coruwadvms',['10']='corarad',['11']='corshroud',['12']='corfort',['13']='corlab',['14']='cortarg',['15']='corsd',['16']='corgate',['17']='cortoast',['18']='corvipe',['19']='cordoom',['20']='corflak',['21']='corscreamer',['22']='corvp',['23']='corfmd',['24']='corap',['25']='corint',['26']='corplat',['27']='corsy',['28']='coruwmme',['29']='coruwmmm',['30']='corenaa',['31']='corfdoom',['32']='coratl',['33']='coruwfus',['34']='corjugg',['35']='corshiva',['36']='corsumo',['37']='corgol',['38']='corkorg',['39']='cornanotc2plat',['40']='cornanotct2',['41']='cornecro',['42']='cordoomt3',['43']='corhllllt',['44']='cormaw',['45']='cormwall',['46']='corgatet3',['47']='legendary_bulwark',['48']='cornanotct3'},customparams={shield_power=500,shield_radius=100},weapondefs={CORCOMLASER={areaofeffect=12,avoidfeature=false,beamtime=0.1,corethickness=0.1,craterareaofeffect=0,craterboost=0,cratermult=0,cylindertargeting=1,edgeeffectiveness=1,explosiongenerator='custom:laserhit-small-red',firestarter=70,impactonly=1,impulseboost=0,impulsefactor=0,laserflaresize=5.5,name='J7Laser',noselfdamage=true,range=1000,reloadtime=0.4,rgbcolor='0.7 0 1',soundhitdry='',soundhitwet='sizzle',soundstart='lasrfir1',soundtrigger=1,targetmoveerror=0.05,thickness=3,tolerance=10000,turret=true,weapontype='BeamLaser',weaponvelocity=900,damage={default=2500,subs=5}},disintegratorxl={areaofeffect=105,avoidfeature=false,avoidfriendly=true,avoidground=false,burst=1,burstrate=0,bouncerebound=0,cegtag='gausscannonprojectilexl',craterareaofeffect=0,craterboost=0,cratermult=0,commandfire=true,cameraShake=0,edgeeffectiveness=1,energypershot=0,explosiongenerator='custom:burnblackbiggest',firestarter=100,firesubmersed=false,gravityaffected=true,impulsefactor=0,intensity=4,name='Darkmatter Photon-Disruptor',noexplode=true,noselfdamage=true,range=500,reloadtime=1,rgbcolor='0.7 0.3 1.0',size=5.5,soundhit='xplomas2',soundhitwet='sizzlexs',soundstart='disigun1',soundtrigger=true,tolerance=10000,turret=true,weapontimer=4.2,weapontype='DGun',weaponvelocity=505,damage={commanders=0,default=20000,scavboss=1000,raptors=10000}},corcomeyelaser={allowNonBlockingAim=true,avoidfriendly=true,areaofeffect=6,avoidfeature=false,beamtime=0.033,camerashake=0.1,collidefriendly=false,corethickness=0.35,craterareaofeffect=12,craterboost=0,cratermult=0,edgeeffectiveness=1,energypershot=0,explosiongenerator='custom:laserhit-small-red',firestarter=90,firetolerance=300,impulsefactor=0,laserflaresize=2,name='EyeLaser',noselfdamage=true,proximitypriority=1,range=870,reloadtime=0.033,rgbcolor='0 1 0',rgbcolor2='0.8 0 0',scrollspeed=5,soundhitdry='flamhit1',soundhitwet='sizzle',soundstart='heatray3burn',soundstartvolume=6,soundtrigger=1,thickness=2.5,turret=true,weapontype='BeamLaser',weaponvelocity=1500,damage={default=185}}},weapons={['1']={def='CORCOMLASER',onlytargetcategory='NOTSUB',fastautoretargeting=true},['3']={badtargetcategory='VTOL',def='disintegratorxl',onlytargetcategory='SURFACE'},['5']={badtargetcategory='VTOL GROUNDSCOUT',def='corcomeyelaser',onlytargetcategory='SURFACE'},['6']={def=''}}}}
    if data then
        ApplyTweakUnits(data)
    end
end

do
    -- Tweak file: 12-tweakunits5.json
    local data = -- T4 Air Rework (Migrated)
{raptor_air_scout_basic_t2_v1={customparams={raptorcustomsquad=true,raptorsquadunitsamount=25,raptorsquadminanger=20,raptorsquadmaxanger=26,raptorsquadweight=10,raptorsquadrarity='basic',raptorsquadbehavior='raider',raptorsquadbehaviordistance=500,raptorsquadbehaviorchance=0.75}},raptor_hive_assault_basic={customparams={raptorcustomsquad=true,raptorsquadunitsamount=25,raptorsquadminanger=0,raptorsquadmaxanger=40,raptorsquadweight=1,raptorsquadrarity='basic',raptorsquadbehavior='raider',raptorsquadbehaviordistance=500,raptorsquadbehaviorchance=0.75}},raptor_land_swarmer_basic_t3_v1={customparams={raptorcustomsquad=true,raptorsquadunitsamount=25,raptorsquadminanger=0,raptorsquadmaxanger=40,raptorsquadweight=2,raptorsquadrarity='basic',raptorsquadbehavior='raider',raptorsquadbehaviordistance=500,raptorsquadbehaviorchance=0.75}},raptor_evolved_motort4={customparams={raptorcustomsquad=true,raptorsquadunitsamount=12,raptorsquadminanger=50,raptorsquadmaxanger=300,raptorsquadweight=3,raptorsquadrarity='special',raptorsquadbehavior='artillery',raptorsquadbehaviordistance=2500,raptorsquadbehaviorchance=0.75}},raptor_hive_assault_heavy={customparams={raptorcustomsquad=true,raptorsquadunitsamount=25,raptorsquadminanger=55,raptorsquadmaxanger=70,raptorsquadweight=1,raptorsquadrarity='basic',raptorsquadbehavior='berserk',raptorsquadbehaviordistance=500,raptorsquadbehaviorchance=0.75}},raptor_hive_assault_superheavy={customparams={raptorcustomsquad=true,raptorsquadunitsamount=25,raptorsquadminanger=80,raptorsquadmaxanger=85,raptorsquadweight=1,raptorsquadrarity='basic',raptorsquadbehavior='berserk',raptorsquadbehaviordistance=500,raptorsquadbehaviorchance=0.75}},raptor_air_kamikaze_basic_t2_v1={customparams={raptorcustomsquad=true,raptorsquadunitsamount=55,raptorsquadminanger=100,raptorsquadmaxanger=105,raptorsquadweight=2,raptorsquadrarity='basic',raptorsquadbehavior='berserk',raptorsquadbehaviordistance=500,raptorsquadbehaviorchance=0.75}},raptor_matriarch_fire={customparams={raptorcustomsquad=true,raptorsquadunitsamount=30,raptorsquadminanger=105,raptorsquadmaxanger=135,raptorsquadweight=3,raptorsquadrarity='special',raptorsquadbehavior='berserk',raptorsquadbehaviordistance=500,raptorsquadbehaviorchance=0.75}},raptor_matriarch_basic={customparams={raptorcustomsquad=true,raptorsquadunitsamount=30,raptorsquadminanger=105,raptorsquadmaxanger=135,raptorsquadweight=3,raptorsquadrarity='special',raptorsquadbehavior='berserk',raptorsquadbehaviordistance=500,raptorsquadbehaviorchance=0.75}},raptor_matriarch_acid={customparams={raptorcustomsquad=true,raptorsquadunitsamount=30,raptorsquadminanger=105,raptorsquadmaxanger=135,raptorsquadweight=3,raptorsquadrarity='special',raptorsquadbehavior='berserk',raptorsquadbehaviordistance=500,raptorsquadbehaviorchance=0.75}},raptor_matriarch_electric={customparams={raptorcustomsquad=true,raptorsquadunitsamount=30,raptorsquadminanger=105,raptorsquadmaxanger=135,raptorsquadweight=3,raptorsquadrarity='special',raptorsquadbehavior='berserk',raptorsquadbehaviordistance=500,raptorsquadbehaviorchance=0.75},weapons={['5']={def=''}}},raptor_queen_veryeasy={selfdestructas='customfusionexplo',explodeas='customfusionexplo',maxthisunit=3,customparams={raptorcustomsquad=true,i18n_en_humanname='Queen Degenerative',i18n_en_tooltip='SHES A BIG ONE',raptorsquadunitsamount=2,raptorsquadminanger=70,raptorsquadmaxanger=150,raptorsquadweight=2,raptorsquadrarity='special',raptorsquadbehavior='berserk',raptorsquadbehaviordistance=500,raptorsquadbehaviorchance=0.75},weapondefs={melee={damage={default=5000}},yellow_missile={damage={default=1,vtol=500}},goo={range=500,damage={default=1200}}}},corcomlvl4={weapondefs={disintegratorxl={damage={commanders=0,default=99999,scavboss=1000,raptorqueen=5000}}}}}
    if data then
        ApplyTweakUnits(data)
    end
end

do
    -- Tweak file: 13-tweakunits6.json
    local data = --NuttyB lrpc rebalance v2
-- docs.google.com/spreadsheets/d/1QSVsuAAMhBrhiZdTihVfSCwPzbbZWDLCtXWP23CU0ko
{armbrtha={health=13000,weapondefs={ARMBRTHA_MAIN={damage={commanders=480,default=33000},areaofeffect=60,energypershot=8000,range=2400,reloadtime=9,turnrate=20000}}},corint={health=13000,weapondefs={CORINT_MAIN={damage={commanders=480,default=85000},areaofeffect=230,edgeeffectiveness=0.6,energypershot=15000,range=2700,reloadtime=18}}},leglrpc={health=13000,weapondefs={LEGLRPC_MAIN={damage={commanders=480,default=4500},energypershot=2000,range=2000,reloadtime=2,turnrate=30000}}}}
    if data then
        ApplyTweakUnits(data)
    end
end

do
    -- Tweak file: 14-tweakunits7.json
    local data = -- Unit Launchers (Migrated)
{legfortt4={customparams={i18n_en_humanname='Experimental Tyrannus',i18n_en_tooltip='In dedication to our commander Tyrannus'},weapondefs={machinegun={accuracy=400,areaofeffect=64,avoidfriendly=false,avoidfeature=false,collidefriendly=false,collidefeature=true,beamtime=0.09,corethickness=0.55,duration=0.09,burst=1,burstrate=0.1,explosiongenerator='custom:genericshellexplosion-tiny-aa',energypershot=0,falloffrate=0,firestarter=50,interceptedbyshieldtype=4,intensity=2,name='scav rapid fire plasma gun',range=1000,reloadtime=0.1,weapontype='LaserCannon',rgbcolor='1 0 0',rgbcolor2='1 1 1',soundtrigger=true,soundstart='tgunshipfire',texture1='shot',texture2='explo2',thickness=8.5,tolerance=1000,turret=true,weaponvelocity=1000,damage={default=60}},heatray1={allowNonBlockingAim=true,avoidfriendly=true,areaofeffect=64,avoidfeature=false,beamtime=0.033,camerashake=0.1,collidefriendly=false,corethickness=0.45,craterareaofeffect=12,craterboost=0,cratermult=0,edgeeffectiveness=1,energypershot=0,explosiongenerator='custom:heatray-large',firestarter=90,firetolerance=300,impulsefactor=0,intensity=9,laserflaresize=8,name='Experimental Thermal Ordnance Generators',noselfdamage=true,proximitypriority=-1,range=850,reloadtime=0.033,rgbcolor='1 0.55 0',rgbcolor2='0.9 1.0 0.5',scrollspeed=5,soundhitdry='heatray3start',soundhitwet='sizzle',soundstart='heatray3lp',soundstartvolume=6,soundtrigger=1,thickness=6,turret=true,weapontype='BeamLaser',weaponvelocity=1500,damage={default=150}},ata={areaofeffect=34,avoidfeature=false,beamtime=2,collidefriendly=false,corethickness=0.5,craterareaofeffect=0,craterboost=0,cratermult=0,edgeeffectiveness=0.3,energypershot=7000,explosiongenerator='custom:laserhit-large-blue',firestarter=90,impulsefactor=0,largebeamlaser=true,laserflaresize=7,name='Heavy long-range g2g tachyon accelerator beam',noselfdamage=true,range=1300,reloadtime=15,rgbcolor='0 1 1',scrollspeed=5,soundhitdry='',soundhitwet='sizzle',soundstart='raptorlaser',soundtrigger=1,soundstartvolume=4,texture3='largebeam',thickness=10,tilelength=150,tolerance=10000,turret=true,weapontype='BeamLaser',weaponvelocity=3100,damage={commanders=480,default=48000}}},weapons={['1']={badtargetcategory='NOTLAND',def='heatray1',maindir='-1 0 0',maxangledif=210,onlytargetcategory='SURFACE'},['2']={badtargetcategory='NOTLAND',def='heatray1',maindir='1 0 0',maxangledif=210,onlytargetcategory='SURFACE'},['3']={def='ata',maindir='1 0 0',maxangledif=190,onlytargetcategory='SURFACE'},['4']={def='machinegun',onlytargetcategory='SURFACE'},['5']={def='machinegun',onlytargetcategory='SURFACE'}}}}
    if data then
        ApplyTweakUnits(data)
    end
end

do
    -- Tweak file: 15-tweakunits4.json
    local data = --NuttyB v1.52 Mega Nuke
-- docs.google.com/spreadsheets/d/1QSVsuAAMhBrhiZdTihVfSCwPzbbZWDLCtXWP23CU0ko
{armsilo={energycost=1500000,metalcost=98720,buildtime=228500,footprintx=12,footprintz=12,maxthisunit=1,explodeas='advancedFusionExplosion',weapondefs={nuclear_missile={areaofeffect=5000,cameraShake=15000,craterboost=55,cratermult=40,energypershot=390000,metalpershot=3000,smokesize=28,smokecolor=0.85,soundhitwetvolume=80,soundstartvolume=50,stockpiletime=160,weaponvelocity=500,damage={commanders=500,default=19500,raptor=100000}}}},corsilo={energycost=1500000,metalcost=98720,buildtime=228500,footprintx=12,footprintz=12,maxthisunit=1,explodeas='advancedFusionExplosion',weapondefs={nuclear_missile={areaofeffect=5000,cameraShake=15000,craterboost=55,cratermult=40,energypershot=390000,metalpershot=3000,smokesize=28,smokecolor=0.85,soundhitwetvolume=80,soundstartvolume=50,stockpiletime=160,weaponvelocity=500,damage={commanders=500,default=19500,raptor=100000}}}},legsilo={energycost=1500000,metalcost=98720,buildtime=228500,footprintx=12,footprintz=12,maxthisunit=1,explodeas='advancedFusionExplosion',weapondefs={nuclear_missile={areaofeffect=5000,cameraShake=15000,craterboost=55,cratermult=40,energypershot=390000,metalpershot=3000,smokesize=28,smokecolor=0.85,soundhitwetvolume=80,soundstartvolume=50,stockpiletime=160,weaponvelocity=500,damage={commanders=500,default=19500,raptor=100000}}}},raptor_turret_antinuke_t3_v1={maxthisunit=0},raptor_antinuke={maxthisunit=0},raptor_turret_antinuke_t4_v1={maxthisunit=0},raptor_turret_antinuke_t2_v1={maxthisunit=0}}
    if data then
        ApplyTweakUnits(data)
    end
end

-- Gadget Logic

local function Initialize_adaptivespawner()




local modOptions = Spring.GetModOptions()
if not modOptions or (modOptions.adaptive_spawner ~= "1" and modOptions.adaptive_spawner ~= 1) then
    return
end

local MAX_COMPRESSION = tonumber(modOptions.adaptive_compression_max) or 10
local VAMPIRE_ENABLED = (modOptions.adaptive_vampire == "1")
local BOSS_TINT_ENABLED = (modOptions.adaptive_boss_tint == "1")

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
if ENABLE_ADAPTIVESPAWNER then
    Initialize_adaptivespawner()
end

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

local modOptions = Spring.GetModOptions()
local MIN_SIM_SPEED = tonumber(modOptions.cull_simspeed) or 0.9
local MAX_UNITS = tonumber(modOptions.cull_maxunits) or 5000
local CULL_ENABLED = (modOptions.cull_enabled == "1")
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
if ENABLE_CULLING then
    Initialize_culling()
end

local function Initialize_fusioncore()




-- Check Mod Option
local modOptions = Spring.GetModOptions()
-- In testing, modOptions might be nil or strings. Check carefully.
if not modOptions or (modOptions.fusion_mode ~= "1" and modOptions.fusion_mode ~= 1) then
    return
end

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
    -- Mega Nuke Logic (Triggered if ENABLE_MEGANUKE is true)
    if not (ENABLE_MEGANUKE or (modOptions and modOptions.meganuke == "1")) then return end

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
if ENABLE_FUSIONCORE then
    Initialize_fusioncore()
end

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
if ENABLE_RAPTORAIOPTIMIZED then
    Initialize_raptoraioptimized()
end

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
