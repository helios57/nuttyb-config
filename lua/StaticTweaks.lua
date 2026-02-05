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

local function GetCustomParams(def)
    local cp = def.customparams
    if not cp then
        if def.customParams then
            cp = def.customParams
            def.customparams = cp
        else
            cp = {}
            def.customparams = cp
        end
    end
    return cp
end

local function CloneTable(t)
    local newT = {}
    for k,v in pairs(t) do newT[k] = v end
    return newT
end

local function CreateTieredUnit(baseName, tier, humanName)
    local sourceName = (tier == 2) and baseName or (baseName .. "_t" .. (tier - 1))
    local destName = baseName .. "_t" .. tier

    if UnitDefs[sourceName] then
        local newDef = tm({}, UnitDefs[sourceName])
        newDef[k_health] = newDef[k_health] * 16
        newDef[k_metalCost] = newDef[k_metalCost] * 4
        newDef[k_energyCost] = newDef[k_energyCost] * 4
        newDef[k_buildTime] = newDef[k_buildTime] * 4
        newDef[k_energyMake] = newDef[k_energyMake] * 4.2
        newDef[k_metalMake] = newDef[k_metalMake] * 4.2
        newDef[k_windGenerator] = newDef[k_windGenerator] * 4.2

        if newDef.weapondefs then
            local newWeaponDefs = {}
            for wk, wv in pairs(newDef.weapondefs) do
                local newWv = CloneTable(wv)
                if newWv.damage then
                    newWv.damage = CloneTable(newWv.damage)
                    if newWv.damage.default then
                        newWv.damage.default = newWv.damage.default * 4.2
                    end
                end
                newWeaponDefs[wk] = newWv
            end
            newDef.weapondefs = newWeaponDefs
        end

        newDef[k_footprintX] = newDef[k_footprintX] * 1.5
        newDef[k_footprintZ] = newDef[k_footprintZ] * 1.5
        newDef[k_name] = humanName .. " T" .. tier

        local cp = GetCustomParams(newDef)
        -- Clone CP to break reference
        local newCp = CloneTable(cp)
        newDef.customparams = newCp
        if newDef.customParams then newDef.customParams = newCp end

        newCp[k_is_fusion_unit] = true
        newCp[k_fusion_tier] = tier
        newCp[k_model_scale] = 1.5

        UnitDefs[destName] = newDef
    end
end

local function CreateCompressedUnit(baseName, factor, humanName)
    if UnitDefs[baseName] then
        local newDef = tm({}, UnitDefs[baseName])

        -- Scaling
        newDef[k_health] = newDef[k_health] * factor
        newDef[k_metalCost] = newDef[k_metalCost] * factor
        newDef[k_energyCost] = newDef[k_energyCost] * factor
        newDef[k_buildTime] = newDef[k_buildTime] * factor
        newDef[k_mass] = newDef[k_mass] * factor
        newDef[k_energyMake] = newDef[k_energyMake] * factor
        newDef[k_metalMake] = newDef[k_metalMake] * factor
        newDef[k_windGenerator] = newDef[k_windGenerator] * factor

        local aoeFactor = math.sqrt(factor)
        if newDef.weapondefs then
             -- Clone weapondefs
            local newWeaponDefs = {}
            for wk, wv in pairs(newDef.weapondefs) do
                local newWv = CloneTable(wv)
                if newWv.damage then
                     newWv.damage = CloneTable(newWv.damage)
                     if newWv.damage.default then
                         newWv.damage.default = newWv.damage.default * factor
                     end
                end
                if newWv[k_areaOfEffect] then
                    newWv[k_areaOfEffect] = newWv[k_areaOfEffect] * aoeFactor
                end
                newWeaponDefs[wk] = newWv
            end
            newDef.weapondefs = newWeaponDefs
        end

        newDef[k_name] = humanName .. " x" .. factor

        local cp = GetCustomParams(newDef)
        -- Clone CP
        local newCp = CloneTable(cp)
        newDef.customparams = newCp
        if newDef.customParams then newDef.customParams = newCp end

        newCp[k_is_compressed_unit] = true
        newCp[k_compression_factor] = factor
        newCp[k_color_tint] = k_1_0_5_0_5

        -- Factor specific settings
        if factor == 2 then
            newCp[k_model_scale] = 1.2
        elseif factor == 5 then
            newCp[k_model_scale] = 1.5
            newDef[k_footprintX] = newDef[k_footprintX] * 1.5
            newDef[k_footprintZ] = newDef[k_footprintZ] * 1.5
        elseif factor == 10 then
            newCp[k_model_scale] = 1.5
            newDef[k_footprintX] = newDef[k_footprintX] * 1.5
            newDef[k_footprintZ] = newDef[k_footprintZ] * 1.5
        end

        UnitDefs[baseName .. "_compressed_x" .. factor] = newDef
    end
end

local tiered_units = {
    { base = "armsolar", human = "Solar Collector" },
    { base = "corsolar", human = "Solar Collector" },
    { base = "armwin",   human = "Wind Generator" },
    { base = "corwin",   human = "Wind Generator" },
    { base = "armmakr",  human = "Metal Maker" },
    { base = "cormakr",  human = "Metal Maker" },
    { base = "armllt",   human = "Light Laser Tower" },
    { base = "corllt",   human = "Light Laser Tower" },
}

local raptor_units = {
    "raptor_land_swarmer_basic_t1_v1",
    "raptor_land_assault_basic_t2_v1",
    "raptor_air_fighter_basic",
    "raptor_hive_swarmer_basic",
    "raptor_hive_assault_basic"
}

-- Generate Tiered Units (T2-T5)
for _, unit in ipairs(tiered_units) do
    for tier = 2, 5 do
        CreateTieredUnit(unit.base, tier, unit.human)
    end
end

-- Generate Compressed Raptors (x2, x5, x10)
local compression_factors = {2, 5, 10}
for _, raptorName in ipairs(raptor_units) do
    for _, factor in ipairs(compression_factors) do
        CreateCompressedUnit(raptorName, factor, raptorName)
    end
end

-- Generate Compressed Regular Units (x2, x5, x10)
for _, unit in ipairs(tiered_units) do
    for _, factor in ipairs(compression_factors) do
        CreateCompressedUnit(unit.base, factor, unit.human)
    end
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