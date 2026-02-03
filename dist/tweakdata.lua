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
if string_sub(name, 1, 13) == "raptor_queen_" then
def.repairable = false
def.canbehealed = false
def.buildTime = 9999999
def.autoHeal = 2
def.canSelfRepair = false
def.health = def.health * (2)
end
if string_sub(name, 1, 24) == "raptor_land_swarmer_heal" then
def.reclaimSpeed = 100
def.stealth = false
def.builder = false
def.buildSpeed = def.buildSpeed * (1.2)
def.canAssist = false
def.maxThisUnit = 0
end
if ((def.customParams and def.customParams["subfolder"] == "other/raptors") or (def.customparams and def.customparams["subfolder"] == "other/raptors")) and not string_match(name, "^raptor_queen_.*") then
def.health = def.health * (1.5)
end
if ((def.customParams and def.customParams["subfolder"] == "other/raptors") or (def.customparams and def.customparams["subfolder"] == "other/raptors")) then
def.noChaseCategory = "OBJECT"
if def.health then
def.metalCost = math_floor(def.health * 0.9)
end
end
if string_sub(name, 1, string_len("arm")) == "arm" then
local target_list = def.buildoptions
if not target_list then
def.buildoptions = {}
target_list = def.buildoptions
end
table_insert(target_list, "armwar")
end
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
def.health = def.health * (2)
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.reloadtime = wDef.reloadtime * (0.666666)
end
end
if def.weapondefs then
for wName, wDef in pairs(def.weapondefs) do
wDef.range = wDef.range * (0.5)
end
end
end
if def.builder == true and def.canfly == true then
def.explodeAs = ""
def.selfDestructAs = ""
end
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
local function ApplyTweaks_Post(name, def)
if string_sub(name, 1, 15) == "scavengerbossv4" then
def.health = def.health * (2)
end
if string_sub(name, -5) == "_scav" and not string_match(name, "^scavengerbossv4") then
if def.health then
def.health = math_floor(def.health * 2)
end
end
if string_sub(name, -5) == "_scav" then
if def.metalCost then
def.metalCost = math_floor(def.metalCost * 2)
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