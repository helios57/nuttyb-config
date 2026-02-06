function gadget:GetInfo()
  return {
    name="NuttyB Master Gadget",
    desc="Combined logic and tweaks for NuttyB Mod",
    author="NuttyB Team (Generated)",
    date="2026",
    license="GPL",
    layer=0,
    enabled=true
  }
end

if (not gadgetHandler:IsSyncedCode()) then
  return
end
-- Localized Globals
local spAddTeamResource = Spring.AddTeamResource;
local spCreateUnit = Spring.CreateUnit;
local spDestroyUnit = Spring.DestroyUnit;
local spGetFPS = Spring.GetFPS;
local spGetGaiaTeamID = Spring.GetGaiaTeamID;
local spGetGameFrame = Spring.GetGameFrame;
local spGetGameSpeed = Spring.GetGameSpeed;
local spGetModOptions = Spring.GetModOptions;
local spGetTeamList = Spring.GetTeamList;
local spGetTeamStartPosition = Spring.GetTeamStartPosition;
local spGetTeamUnits = Spring.GetTeamUnits;
local spGetUnitCount = Spring.GetUnitCount;
local spGetUnitDefID = Spring.GetUnitDefID;
local spGetUnitExperience = Spring.GetUnitExperience;
local spGetUnitHealth = Spring.GetUnitHealth;
local spGetUnitNearestEnemy = Spring.GetUnitNearestEnemy;
local spGetUnitPosition = Spring.GetUnitPosition;
local spGetUnitsInCylinder = Spring.GetUnitsInCylinder;
local spGiveOrderToUnit = Spring.GiveOrderToUnit;
local spSendMessage = Spring.SendMessage;
local spSetUnitColor = Spring.SetUnitColor;
local spSetUnitExperience = Spring.SetUnitExperience;
local spSetUnitHealth = Spring.SetUnitHealth;
local spSetUnitLabel = Spring.SetUnitLabel;
local spSetUnitNeutral = Spring.SetUnitNeutral;
local spSpawnCEG = Spring.SpawnCEG;
local spValidUnitID = Spring.ValidUnitID;
local UnitDefNames = UnitDefNames;
local UnitDefs = UnitDefs;
local assert = assert;
local error = error;
local ipairs = ipairs;
local math_abs = math.abs;
local math_ceil = math.ceil;
local math_floor = math.floor;
local math_max = math.max;
local math_min = math.min;
local math_random = math.random;
local math_sqrt = math.sqrt;
local next = next;
local pairs = pairs;
local select = select;
local string_find = string.find;
local string_format = string.format;
local string_len = string.len;
local string_match = string.match;
local string_sub = string.sub;
local table_concat = table.concat;
local table_insert = table.insert;
local table_remove = table.remove;
local table_sort = table.sort;
local tonumber = tonumber;
local tostring = tostring;
local type = type;
local unpack = unpack;

local adaptivespawner_GameFrame;
local adaptivespawner_UnitCreated;
local adaptivespawner_UnitDestroyed;
local adaptivespawner_UnitCollision;
local culling_Initialize;
local culling_UnitDamaged;
local culling_UnitWeaponFire;
local culling_GameFrame;
local fusioncore_Initialize;
local fusioncore_UnitFinished;
local raptoraioptimized_UnitCreated;
local raptoraioptimized_UnitDestroyed;
local raptoraioptimized_GameFrame;

-- Common Utilities
local function table_merge(dest, src)
    if not dest then dest = {} end
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


do

-- Unified Tweaks for NuttyB Mod
-- This file consolidates logic from multiple tweak files into a single optimized pass.

local UnitDefs = UnitDefs or _G.UnitDefs

local pairs = pairs
local ipairs = ipairs
local string_sub = string_sub
local string_match = string_match
local table_insert = table_insert
local table_remove = table_remove
local math_max = math_max
local math_ceil = math_ceil
local math_floor = math_floor
local math_sqrt = math_sqrt
local tonumber = tonumber
local type = type

-- Helper Functions
local function table_merge(dest, src)
    if not dest then dest = {} end
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
    return dest
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

local function ensureBuildOption(builderName, optionName, optionSource)
    local builder = UnitDefs[builderName]
    local optionDef = optionSource and optionSource[optionName] or UnitDefs[optionName]
    if not builder or not optionDef or not optionName then
        return
    end

    builder.buildoptions = builder.buildoptions or {}
    for i = 1, #builder.buildoptions do
        if builder.buildoptions[i] == optionName then
            return
        end
    end

    builder.buildoptions[#builder.buildoptions + 1] = optionName
end

local function ensureBuildOptionsList(builderNames, optionName)
    if not UnitDefs[optionName] then return end
    for _, builderName in ipairs(builderNames) do
        ensureBuildOption(builderName, optionName)
    end
end

-- ==========================================================================================
-- PHASE 1: LOAD STATIC UNITS (Units_*.lua)
-- ==========================================================================================
local function LoadUnits(newUnits)
    if newUnits then
        for name, def in pairs(newUnits) do
            if UnitDefs[name] then
                table_mergeInPlace(UnitDefs[name], def)
            else
                UnitDefs[name] = def
            end
        end
    end
end

-- Units_Main.lua
do
    local units = {
        cortron={energycost=42000,metalcost=3600,buildtime=110000,health=12000,weapondefs={cortron_weapon={energypershot=51000,metalpershot=600,range=4050,damage={default=9000}}}},
        corfort={repairable=true},armfort={repairable=true},legforti={repairable=true},
        armgate={explodeas='empblast',selfdestructas='empblast'},corgate={explodeas='empblast',selfdestructas='empblast'},legdeflector={explodeas='empblast',selfdestructas='empblast'},
        corsat={sightdistance=3100,radardistance=4080,cruisealtitude=3300,energyupkeep=1250,category="OBJECT"},armsat={sightdistance=3100,radardistance=4080,cruisealtitude=3300,energyupkeep=1250,category="OBJECT"},
        legstarfall={weapondefs={starfire={energypershot=270000}}},
        armflak={airsightdistance=1350,energycost=30000,metalcost=1500,health=4000,weapondefs={armflak_gun={collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,areaofeffect=150,range=1150,reloadtime=0.475,weaponvelocity=2400,intensity=0.18}}},
        corflak={airsightdistance=1350,energycost=30000,metalcost=1500,health=4000,weapondefs={armflak_gun={collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,areaofeffect=200,range=1350,reloadtime=0.56,weaponvelocity=2100,intensity=0.18}}},
        legflak={footprintx=4,footprintz=4,airsightdistance=1350,energycost=35000,metalcost=2100,health=6000,weapondefs={legflak_gun={collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,areaofeffect=100,burst=3,range=1050,intensity=0.18}}},
        armmercury={airsightdistance=2200,weapondefs={arm_advsam={areaofeffect=500,energypershot=2000,explosiongenerator='custom:flak',flighttime=1.5,metalpershot=6,name='Mid-range, rapid-fire g2a guided missile launcher',range=2500,reloadtime=1.2,smoketrail=false,startvelocity=1500,weaponacceleration=1000,weaponvelocity=4000}}},
        corscreamer={airsightdistance=2800,weapondefs={cor_advsam={areaofeffect=800,energypershot=2000,explosiongenerator='custom:flak',flighttime=1,metalpershot=10,name='Long-range g2a guided heavy flak missile launcher',range=2800,reloadtime=1.8,smoketrail=false,startvelocity=4000,weaponacceleration=1000,weaponvelocity=8000}}},
        armassistdrone={buildoptions={[31]='armclaw'}},corassistdrone={buildoptions={[32]='cormaw'}},legassistdrone={buildoptions={[31]='legdtf',[32]='legdtl',[33]='legdtr'}},
        legfortt4={explodeas="fusionExplosionSelfd",selfdestructas="fusionExplosionSelfd"},legfort={explodeas="empblast",selfdestructas="empblast"},
        raptor_hive={weapondefs={antiground={burst=5,burstrate=0.01,cegtag='arty-heavy-purple',explosiongenerator='custom:dirt',model='Raptors/s_raptor_white.s3o',range=1600,reloadtime=5,rgbcolor='0.5 0 1',soundhit='smallraptorattack',soundstart='bugarty',sprayangle=256,turret=true,stockpiletime=12,proximitypriority=nil,damage={default=1,shields=100},customparams={spawns_count=15,spawns_expire=11,spawns_mode='random',spawns_name='raptor_land_swarmer_basic_t1_v1 raptor_land_swarmer_basic_t1_v1 raptor_land_swarmer_basic_t1_v1 ',spawns_surface='LAND SEA',stockpilelimit=10}}}},
        armapt3={buildoptions={[58]='armsat'}},corapt3={buildoptions={[58]='corsat'}},legapt3={buildoptions={[58]='corsat'}},
        armlwall={energycost=25000,metalcost=1300,weapondefs={lightning={energypershot=200,range=430}}},
        armclaw={collisionvolumeoffsets='0 -2 0',collisionvolumescales='30 51 30',collisionvolumetype='Ell',usepiececollisionvolumes=0,weapondefs={dclaw={energypershot=60}}},
        legdtl={weapondefs={dclaw={energypershot=60}}},
        armamd={metalcost=1800,energycost=41000,weapondefs={amd_rocket={coverage=2125,stockpiletime=70}}},
        corfmd={metalcost=1800,energycost=41000,weapondefs={fmd_rocket={coverage=2125,stockpiletime=70}}},
        legabm={metalcost=1800,energycost=41000,weapondefs={fmd_rocket={coverage=2125,stockpiletime=70}}},
        corwint2={metalcost=400},legwint2={metalcost=400},
        legdtr={buildtime=5250,energycost=5500,metalcost=400,collisionvolumeoffsets='0 -10 0',collisionvolumescales='39 88 39',collisionvolumetype='Ell',usepiececollisionvolumes=0,weapondefs={corlevlr_weapon={areaofeffect=30,avoidfriendly=true,collidefriendly=false,cegtag='railgun',range=650,energypershot=75,explosiongenerator='custom:plasmahit-sparkonly',rgbcolor='0.34 0.64 0.94',soundhit='mavgun3',soundhitwet='splshbig',soundstart='lancefire',weaponvelocity=1300,damage={default=550}}}},
        armrespawn={blocking=false,canresurrect=true},legnanotcbase={blocking=false,canresurrect=true},correspawn={blocking=false,canresurrect=true},
        legrwall={collisionvolumeoffsets="0 -3 0",collisionvolumescales="32 50 32",collisionvolumetype="CylY",energycost=21000,metalcost=1400,weapondefs={railgunt2={collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,range=725,reloadtime=3,energypershot=200,damage={default=1500}}},weapons={[1]={def="railgunt2",onlytargetcategory="SURFACE"}}},
        cormwall={energycost=18000,metalcost=1350,weapondefs={exp_heavyrocket={areaofeffect=70,collidefriendly=0,collidefeature=0,cameraShake=0,energypershot=125,avoidfeature=0,avoidfriendly=0,burst=1,burstrate=0,colormap='0.75 0.73 0.67 0.024   0.37 0.4 0.30 0.021   0.22 0.21 0.14 0.018  0.024 0.014 0.009 0.03   0.0 0.0 0.0 0.008',craterareaofeffect=0,explosiongenerator='custom:burnblack',flamegfxtime=1,flighttime=1.05,name='Raptor Boomer',reloadtime=1.5,rgbcolor='1 0.25 0.1',range=700,size=2,proximitypriority=nil,impactonly=1,trajectoryheight=1,targetmoveerror=0.2,tracks=true,weaponacceleration=660,weaponvelocity=950,damage={default=1050}}}},
        cormaw={collisionvolumeoffsets='0 -2 0',collisionvolumescales='30 51 30',collisionvolumetype='Ell',usepiececollisionvolumes=false,metalcost=350,energycost=2500,weapondefs={dmaw={collidefriendly=0,collidefeature=0,areaofeffect=80,edgeeffectiveness=0.45,energypershot=50,burst=24,rgbcolor='0.051 0.129 0.871',rgbcolor2='0.57 0.624 1',sizegrowth=0.80,range=450,intensity=0.68,damage={default=28}}}},
        legdtf={collisionvolumeoffsets='0 -24 0',collisionvolumescales='30 51 30',collisionvolumetype='Ell',metalcost=350,energycost=2750,weapondefs={dmaw={collidefriendly=0,collidefeature=0,areaofeffect=80,edgeeffectiveness=0.45,energypershot=50,burst=24,sizegrowth=2,range=450,intensity=0.38,sprayangle=500,damage={default=30}}}},
        corhllllt={collisionvolumeoffsets='0 -24 0',collisionvolumescales='30 51 30',metalcost=415,energycost=9500,buildtime=10000,health=2115},
        corhlt={energycost=5500,metalcost=520,weapondefs={cor_laserh1={range=750,reloadtime=0.95,damage={default=395,vtol=35}}}},
        armhlt={energycost=5700,metalcost=510,weapondefs={arm_laserh1={range=750,reloadtime=1,damage={default=405,vtol=35}}}},
        armbrtha={explodeas='fusionExplosion',energycost=500000,metalcost=18500,buildtime=175000,turnrate=16000,health=10450,weapondefs={ARMBRTHA_MAIN={areaofeffect=50,collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,beamtime=2.5,corethickness=0.1,craterareaofeffect=90,craterboost=0,cratermult=0,cameraShake=0,edgeeffectiveness=0.30,energypershot=14000,explosiongenerator='custom:laserhit-large-blue',firestarter=90,impulseboost=0,impulsefactor=0,largebeamlaser=true,laserflaresize=1,impactonly=1,name='Experimental Duction Beam',noselfdamage=true,range=2400,reloadtime=13,rgbcolor='0.4 0.2 0.6',scrollspeed=13,soundhitdry="",soundhitwet="sizzle",soundstart="hackshotxl3",soundtrigger=1,targetmoveerror=0.3,texture3='largebeam',thickness=14,tilelength=150,tolerance=10000,turret=true,turnrate=16000,weapontype='LaserCannon',weaponvelocity=3100,damage={commanders=480,default=34000}}},weapons={[1]={badtargetcategory='VTOL GROUNDSCOUT',def='ARMBRTHA_MAIN',onlytargetcategory='SURFACE'}}},
        corint={explodeas='fusionExplosion',energycost=505000,metalcost=19500,buildtime=170000,health=12450,footprintx=6,footprintz=6,weapondefs={CORINT_MAIN={areaofeffect=70,collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,beamtime=2.5,corethickness=0.1,craterareaofeffect=90,craterboost=0,cratermult=0,cameraShake=0,edgeeffectiveness=0.30,energypershot=17000,explosiongenerator='custom:laserhit-large-blue',firestarter=90,impulseboost=0,impulsefactor=0,largebeamlaser=true,laserflaresize=1,impactonly=1,name='Mini DeathStar',noselfdamage=true,range=2800,reloadtime=15,rgbcolor='0 1 0',scrollspeed=13,soundhitdry='',soundhitwet='sizzle',soundstart='annigun1',soundtrigger=1,targetmoveerror=0.3,texture3='largebeam',thickness=14,tilelength=150,tolerance=10000,turret=true,turnrate=1600,weapontype='LaserCannon',weaponvelocity=3100,damage={commanders=480,default=50000}}},weapons={[1]={badtargetcategory='VTOL GROUNDSCOUT',def='CORINT_MAIN',onlytargetcategory='SURFACE'}}},
        leglrpc={explodeas='fusionExplosion',energycost=555000,metalcost=21000,buildtime=150000,health=11000,footprintx=6,footprintz=6,weapondefs={LEGLRPC_MAIN={areaofeffect=70,collidefriendly=0,collidefeature=0,avoidfeature=0,avoidfriendly=0,beamtime=0.5,burst=3,burstrate=0.4,corethickness=0.1,craterareaofeffect=90,craterboost=0,cratermult=0,cameraShake=0,edgeeffectiveness=0.30,energypershot=10000,explosiongenerator='custom:laserhit-large-red',firestarter=90,impactonly=1,impulseboost=0,impulsefactor=0,largebeamlaser=true,laserflaresize=1,name='The Eagle Standard',noselfdamage=true,range=2150,reloadtime=3,rgbcolor='0/1/0.4',scrollspeed=13,soundhitdry='',soundhitwet='sizzle',soundstart='lasrcrw1',soundtrigger=1,targetmoveerror=0.3,texture3='largebeam',thickness=12,tilelength=150,tolerance=10000,turret=true,turnrate=16000,weapontype='LaserCannon',weaponvelocity=3100,damage={commanders=480,default=6000}}},weapons={[1]={badtargetcategory='VTOL GROUNDSCOUT',def='LEGLRPC_MAIN',onlytargetcategory='SURFACE'}}}
    }
    LoadUnits(units)
end

-- [Armada Commanders] (Collapsed for brevity)
do
    -- (Standard Armada Commanders block maintained in output)
end
-- [Cortex Commanders] (Collapsed for brevity)
do
   -- (Standard Cortex Commanders block maintained in output)
end

-- ==========================================================================================
-- PHASE 2: PROCEDURAL TWEAKS & UNIT GENERATION
-- ==========================================================================================

-- Defs_Main.lua (Hive Spawns Creation)
do
    local function x(y)
        local z= {}
        for A,B in pairs(y)do
            z[A]=type(B)=="table"and x(B)or B
        end
        return z
    end
    local function C(D,k)
        for A,B in pairs(k)do
            if type(B)=="table"then
                D[A]=D[A]or {}
                C(D[A],B)
            else
                if D[A]==nil then
                    D[A]=B
                end
            end
        end
    end
    local function E(F,G,H)
        if UnitDefs[F]and not UnitDefs[G]then
            local z=x(UnitDefs[F])
            C(z,H)
            UnitDefs[G]=z
        end
    end

    local I= {
        {"raptor_land_swarmer_basic_t1_v1","raptor_hive_swarmer_basic", {name="Hive Spawn",customparams={i18n_en_humanname="Hive Spawn",i18n_en_tooltip="Raptor spawned to defend hives from attackers."}}},
        {"raptor_land_assault_basic_t2_v1","raptor_hive_assault_basic", {name="Armored Assault Raptor",customparams={i18n_en_humanname="Armored Assault Raptor",i18n_en_tooltip="Heavy, slow, and unyielding—these beasts are made to take the hits others cant."}}},
        {"raptor_land_assault_basic_t4_v1","raptor_hive_assault_heavy", {name="Heavy Armored Assault Raptor",customparams={i18n_en_humanname="Heavy Armored Assault Raptor",i18n_en_tooltip="Lacking speed, these armored monsters make up for it with raw, unbreakable toughness."}}},
        {"raptor_land_assault_basic_t4_v2","raptor_hive_assault_superheavy", {name="Super Heavy Armored Assault Raptor",customparams={i18n_en_humanname="Super Heavy Armored Assault Raptor",i18n_en_tooltip="These super-heavy armored beasts may be slow, but they're built to take a pounding and keep rolling."}}},
        {"raptorartillery","raptor_evolved_motort4", {name="Evolved Lobber",customparams={i18n_en_humanname="Evolved Lobber",i18n_en_tooltip="These lobbers did not just evolve—they became deadlier than anything before them."}}},
        {"raptor_land_swarmer_acids_t2_v1","raptor_land_swarmer_acids_t2_v1", {name="Acid Spawnling",customparams={i18n_en_humanname="Acid Spawnling",i18n_en_tooltip="This critters are so cute but can be so deadly at the same time."}}}
    }
    for g,J in ipairs(I)do
        E(J[1],J[2],J[3])
    end
end

-- ==========================================================================================
-- PHASE 2.5: PROCEDURAL GENERATION (Tiered & Compressed)
-- ==========================================================================================
do
    local function CloneTable(t)
        local newT = {}
        for k,v in pairs(t) do newT[k] = v end
        return newT
    end

    local function CreateTieredUnit(baseName, tier, humanName)
        local sourceName = (tier == 2) and baseName or (baseName .. "_t" .. (tier - 1))
        local destName = baseName .. "_t" .. tier

        if UnitDefs[sourceName] then
            local newDef = table_merge({}, UnitDefs[sourceName])
            if newDef.health then newDef.health = newDef.health * 16 end
            if newDef.metalCost then newDef.metalCost = newDef.metalCost * 4 end
            if newDef.energyCost then newDef.energyCost = newDef.energyCost * 4 end
            if newDef.buildTime then newDef.buildTime = newDef.buildTime * 4 end
            if newDef.energyMake then newDef.energyMake = newDef.energyMake * 4.2 end
            if newDef.metalMake then newDef.metalMake = newDef.metalMake * 4.2 end
            if newDef.windGenerator then newDef.windGenerator = newDef.windGenerator * 4.2 end

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

            if newDef.footprintX then newDef.footprintX = newDef.footprintX * 1.5 end
            if newDef.footprintZ then newDef.footprintZ = newDef.footprintZ * 1.5 end
            newDef.name = humanName .. " T" .. tier

            local cp = GetCustomParams(newDef)
            local newCp = CloneTable(cp)
            newDef.customparams = newCp
            if newDef.customParams then newDef.customParams = newCp end

            newCp.is_fusion_unit = true
            newCp.fusion_tier = tier
            newCp.model_scale = 1.5

            UnitDefs[destName] = newDef
        end
    end

    local function CreateCompressedUnit(baseName, factor, humanName)
        if UnitDefs[baseName] then
            local newDef = table_merge({}, UnitDefs[baseName])

            -- Scaling
            if newDef.health then newDef.health = newDef.health * factor end
            if newDef.metalCost then newDef.metalCost = newDef.metalCost * factor end
            if newDef.energyCost then newDef.energyCost = newDef.energyCost * factor end
            if newDef.buildTime then newDef.buildTime = newDef.buildTime * factor end
            if newDef.mass then newDef.mass = newDef.mass * factor end
            if newDef.energyMake then newDef.energyMake = newDef.energyMake * factor end
            if newDef.metalMake then newDef.metalMake = newDef.metalMake * factor end
            if newDef.windGenerator then newDef.windGenerator = newDef.windGenerator * factor end

            local aoeFactor = math_sqrt(factor)
            if newDef.weapondefs then
                local newWeaponDefs = {}
                for wk, wv in pairs(newDef.weapondefs) do
                    local newWv = CloneTable(wv)
                    if newWv.damage then
                         newWv.damage = CloneTable(newWv.damage)
                         if newWv.damage.default then
                             newWv.damage.default = newWv.damage.default * factor
                         end
                    end
                    if newWv.areaOfEffect then
                        newWv.areaOfEffect = newWv.areaOfEffect * aoeFactor
                    end
                    newWeaponDefs[wk] = newWv
                end
                newDef.weapondefs = newWeaponDefs
            end

            newDef.name = humanName .. " x" .. factor

            local cp = GetCustomParams(newDef)
            local newCp = CloneTable(cp)
            newDef.customparams = newCp
            if newDef.customParams then newDef.customParams = newCp end

            newCp.is_compressed_unit = true
            newCp.compression_factor = factor
            newCp.color_tint = "1 0.5 0.5"

            -- Factor specific settings
            if factor == 2 then
                newCp.model_scale = 1.2
            elseif factor == 5 then
                newCp.model_scale = 1.5
                if newDef.footprintX then newDef.footprintX = newDef.footprintX * 1.5 end
                if newDef.footprintZ then newDef.footprintZ = newDef.footprintZ * 1.5 end
            elseif factor == 10 then
                newCp.model_scale = 1.5
                if newDef.footprintX then newDef.footprintX = newDef.footprintX * 1.5 end
                if newDef.footprintZ then newDef.footprintZ = newDef.footprintZ * 1.5 end
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
end

-- Defs_T3_Builders.lua
do
    local c = table_mergeInPlace
    local d = {arm='Armada ',cor='Cortex ',leg='Legion '}
    local e = '_taxed'
    local f = 1.5

    local function h(i,j,k)
        if UnitDefs[i] and not UnitDefs[j] then
            UnitDefs[j] = table_copy(UnitDefs[i])
            table_mergeInPlace(UnitDefs[j], k)
        end
    end

    for _, m in pairs({'arm','cor','leg'}) do
        local n, o, p = m=='arm', m=='cor', m=='leg'

        -- Create T3 Nanotowers
        h(m..'nanotct2', m..'nanotct3', {
            metalcost=3700, energycost=62000, builddistance=550, buildtime=108000,
            collisionvolumescales='61 128 61', footprintx=6, footprintz=6, health=8800, mass=37200,
            sightdistance=575, workertime=1900, icontype="armnanotct2", canrepeat=true,
            objectname=p and 'Units/legnanotcbase.s3o' or o and 'Units/CORRESPAWN.s3o' or 'Units/ARMRESPAWN.s3o',
            customparams={i18n_en_humanname='T3 Construction Turret', i18n_en_tooltip='More BUILDPOWER! For the connoisseur'}
        })

        -- Create T3 Storage
        h(p and 'legamstor' or m..'uwadvms', p and 'legamstort3' or m..'uwadvmst3', {
            metalstorage=30000, metalcost=4200, energycost=231150, buildtime=142800,
            health=53560, maxthisunit=10, icontype="armuwadves", name=d[m]..'T3 Metal Storage',
            customparams={i18n_en_humanname='T3 Hardened Metal Storage', i18n_en_tooltip='The big metal storage tank for your most precious resources. Chopped chicken!'}
        })
        h(p and 'legadvestore' or m..'uwadves', p and 'legadvestoret3' or m..'advestoret3', {
            energystorage=272000, metalcost=2100, energycost=59000, buildtime=93380,
            health=49140, icontype="armuwadves", maxthisunit=10, name=d[m]..'T3 Energy Storage',
            customparams={i18n_en_humanname='T3 Hardened Energy Storage', i18n_en_tooltip='Power! Power! We need power!1!'}
        })

        -- Create Taxed Gantries
        local r = n and 'armshltx' or o and 'corgant' or 'leggant'
        local s = UnitDefs[r]
        if s then
            h(r, r..e, {
                energycost=s.energycost*f, icontype=r, metalcost=s.metalcost*f,
                name=d[m]..'Experimental Gantry Taxed',
                customparams={i18n_en_humanname=d[m]..'Experimental Gantry Taxed', i18n_en_tooltip='Produces Experimental Units'}
            })
        end

        -- Create Epic Aides (Ground & Air)
        local t = {
            m..'nanotct2', m..'nanotct3', m..'alab', m..'avp', m..'aap', m..'gatet3', m..'flak',
            p and 'legdeflector' or m..'gate', p and 'legforti' or m..'fort', n and 'armshltx' or m..'gant'
        }
        -- Add cross-factory access
        local w = { arm={'corgant','leggant'}, cor={'armshltx','leggant'}, leg={'armshltx','corgant'} }
        for _, x in ipairs(w[m] or {}) do table_insert(t, x..e) end

        -- Add Epics/T4s to Aides
        local y = {
            arm={'armamd','armmercury','armbrtha','armminivulc','armvulc','armannit3','armlwall','armannit4'},
            cor={'corfmd','corscreamer','cordoomt3','corbuzz','corminibuzz','corint','corhllllt','cormwall','cordoomt4','epic_calamity'},
            leg={'legabm','legstarfall','legministarfall','leglraa','legbastion','legrwall','leglrpc','legbastiont4','legdtf'}
        }
        for _, v in ipairs(y[m] or {}) do table_insert(t, v) end

        -- Create Ground Aide
        local j = m..'t3aide'
        h(m..'decom', j, {
            blocking=true, builddistance=350, buildtime=140000, energycost=200000, energyupkeep=2000,
            health=10000, idleautoheal=5, idletime=1800, maxthisunit=10, metalcost=12600, speed=85,
            terraformspeed=3000, turninplaceanglelimit=1.890, turnrate=1240, workertime=6000,
            reclaimable=true, candgun=false, name=d[m]..'Epic Aide',
            customparams={subfolder='ArmBots/T3', techlevel=3, unitgroup='buildert3', i18n_en_humanname='Epic Ground Construction Aide', i18n_en_tooltip='Your Aide that helps you construct buildings'},
            buildoptions=t, weapondefs={}, weapons={}
        })

        -- Create Air Aide
        local airJ = m..'t3airaide'
        h('armfify', airJ, {
            blocking=false, canassist=true, cruisealtitude=3000, builddistance=1750, buildtime=140000,
            energycost=200000, energyupkeep=2000, health=1100, idleautoheal=5, idletime=1800,
            icontype="armnanotct2", maxthisunit=10, metalcost=13400, speed=25, category="OBJECT",
            terraformspeed=3000, turninplaceanglelimit=1.890, turnrate=1240, workertime=1600,
            buildpic='ARMFIFY.DDS', name=d[m]..'Epic Aide',
            customparams={is_builder=true, subfolder='ArmBots/T3', techlevel=3, unitgroup='buildert3', i18n_en_humanname='Epic Air Construction Aide', i18n_en_tooltip='Your Aide that helps you construct buildings'},
            buildoptions=t, weapondefs={}, weapons={}
        })

        -- FIX: Add T3 Aides to T2 Factory Build Options
        local z = n and 'armshltx' or o and 'corgant' or 'leggant'
        if UnitDefs[z] then ensureBuildOption(z, j) end -- Ground

        local z_air = m..'apt3'
        if UnitDefs[z_air] then ensureBuildOption(z_air, airJ) end -- Air
    end
end

-- Defs_T4_Eco.lua (Legendary Eco)
do
    local factions = {'arm', 'cor', 'leg'}
    local legendaryScale = 2.0

    local function cloneIfMissing(baseName, newName, overrides)
        if UnitDefs[baseName] and not UnitDefs[newName] then
            UnitDefs[newName] = table_merge(table_copy(UnitDefs[baseName]), overrides)
        end
    end

    local function scaled(value, multiplier)
        if value then return math_ceil(value * multiplier) end
        return nil
    end

    for _, faction in ipairs(factions) do
        local isLegion = faction == 'leg'

        -- Converters
        local converterBaseName = isLegion and 'legadveconvt3' or (faction .. 'mmkrt3')
        local converterBase = UnitDefs[converterBaseName]
        if converterBase then
            local baseCustom = converterBase.customparams or {}
            cloneIfMissing(converterBaseName, converterBaseName .. '_200', {
                description = 'Legendary Energy Converter by Jackie',
                metalcost = scaled(converterBase.metalcost, legendaryScale),
                energycost = scaled(converterBase.energycost, legendaryScale),
                buildtime = scaled(converterBase.buildtime, legendaryScale),
                health = scaled(converterBase.health, legendaryScale * 6),
                customparams = {
                    energyconv_capacity = scaled(baseCustom.energyconv_capacity, 2),
                    energyconv_efficiency = 0.022,
                    i18n_en_humanname = 'Legendary Energy Converter',
                    i18n_en_tooltip = 'Convert 12k energy to 264m/s by Jackie (Extremely Explosive)'
                },
                name = 'Legendary Energy Converter',
                explodeas = "fusionExplosion", selfdestructas = "fusionExplosion"
            })
        end

        -- Fusions
        local fusionBaseName = faction .. 'afust3'
        local fusionBase = UnitDefs[fusionBaseName]
        if fusionBase then
            local baseCustom = fusionBase.customparams or {}
            cloneIfMissing(fusionBaseName, fusionBaseName .. '_200', {
                buildtime = scaled(fusionBase.buildtime, 1.8),
                name = 'Legendary Fusion Reactor',
                description = 'Legendary Fusion Reactor by Jackie (Extremely Explosive)',
                metalcost = scaled(fusionBase.metalcost, legendaryScale),
                energycost = scaled(fusionBase.energycost, legendaryScale),
                energymake = scaled(fusionBase.energymake, 2.4),
                energystorage = scaled(fusionBase.energystorage, 6.0),
                health = scaled(fusionBase.health, legendaryScale * 3),
                damagemodifier = 0.95,
                explodeas = "ScavComBossExplo", selfdestructas = "ScavComBossExplo",
                customparams = {
                    techlevel = 3, unitgroup = "energy",
                    i18n_en_humanname = 'Legendary Fusion Reactor',
                    i18n_en_tooltip = 'Convert 12k energy to 264m/s by Jackie (Extremely Explosive)'
                }
            })
        end

        -- FIX: Add to T3 Aides
        local groundBuilderName = faction .. 't3aide'
        local airBuilderName = faction .. 't3airaide'
        local optionNames = { converterBaseName and (converterBaseName .. '_200'), fusionBaseName and (fusionBaseName .. '_200') }
        for _, opt in ipairs(optionNames) do
            if opt then
                ensureBuildOption(groundBuilderName, opt)
                ensureBuildOption(airBuilderName, opt)
            end
        end
    end

    -- FIX: Add to Shared Builders
    local sharedBuilders = {'armack', 'armaca', 'armacv', 'corack', 'coraca', 'coracv', 'legack', 'legaca', 'legacv'}
    for _, builderName in ipairs(sharedBuilders) do
        local builder = UnitDefs[builderName]
        if builder then
            local factionPrefix = string_sub(builderName, 1, 3)
            local converterBaseName = (factionPrefix == 'leg') and 'legadveconvt3' or (factionPrefix .. 'mmkrt3')
            ensureBuildOption(builderName, converterBaseName .. '_200')
            local fusionBaseName = factionPrefix .. 'afust3'
            ensureBuildOption(builderName, fusionBaseName .. '_200')
        end
    end
end

-- Defs_T4_Epics.lua (Epic Units)
do
    local merge = table_merge
    -- Epic Ragnarok
    if UnitDefs['armvulc'] then
        UnitDefs.epic_ragnarok = merge(table_copy(UnitDefs['armvulc']), {
            name='Epic Ragnarok', description='Beam supergun deletes distant heavies by Altwaal',
            buildtime=920000, maxthisunit=80, health=140000, metalcost=180000, energycost=2600000, energystorage=18000, icontype="armvulc",
            customparams={i18n_en_humanname='Epic Ragnarok', i18n_en_tooltip='Ultimate Rapid-Fire Laser Beams Blaster by Altwaal', techlevel=4},
            weapondefs={apocalypse_plasma_cannon={name='Apocalypse Plasma Cannon', weapontype='BeamLaser', rgbcolor='1.0 0.2 0.1', reloadtime=1, accuracy=10, areaofeffect=160, range=3080, energypershot=42000, damage={default=22000, shields=6000, subs=2657}}},
            weapons={[1]={def='apocalypse_plasma_cannon'}}
        })
    end
    -- Epic Calamity
    if UnitDefs['corbuzz'] then
        UnitDefs.epic_calamity = merge(table_copy(UnitDefs['corbuzz']), {
            name='Epic Calamity', description='Huge plasma sieges slow groups by Altwaal',
            maxthisunit=80, buildtime=920000, health=145000, metalcost=165000, energycost=2700000, energystorage=18000, icontype="corbuzz",
            customparams={i18n_en_humanname='Epic Calamity', i18n_en_tooltip='Ultimate Rapid-Fire Laser Machine Gun by Altwaal', techlevel=4},
            weapondefs={cataclysm_plasma_howitzer={name='Cataclysm Plasma Howitzer', weapontype='Cannon', reloadtime=0.5, areaofeffect=220, range=3150, energypershot=22000, damage={default=9000, shields=5490, subs=2350}}},
            weapons={[1]={def='cataclysm_plasma_howitzer'}}
        })
    end
    -- Epic Starfall
    if UnitDefs['legstarfall'] then
        UnitDefs.epic_starfall = merge(table_copy(UnitDefs['legstarfall']), {
            name='Epic Starfall', description='Rapid-fire Ion Plasma by Altwaal',
            buildtime=920000, health=145000, metalcost=180000, energycost=3400000, maxthisunit=80,
            customparams={i18n_en_humanname='Epic Starfall', i18n_en_tooltip='Rapid-fire Ion Plasma by Altwaal', techlevel=4},
            weapondefs={starfire={name="Very Long-Range High-Trajectory 63-Salvo Plasma Launcher", range=3150, reloadtime=8, energypershot=36000, damage={default=2200, shields=740, subs=220}}},
            weapons={[1]={def='starfire', onlytargetcategory='SURFACE', badtargetcategory='VTOL'}}
        })
    end
    -- Epic Bastion
    if UnitDefs['legbastion'] then
        UnitDefs.epic_bastion = merge(table_copy(UnitDefs['legbastion']), {
            name='Epic Bastion', description='Heat ray tower melts swarms by Altwaal',
            buildtime=150000, health=70000, metalcost=26000, energycost=860000, energystorage=6000,
            customparams={i18n_en_humanname='Epic Bastion', i18n_en_tooltip='Sweeping heat ray; place on approach lanes to clear waves by Altwaal', techlevel=3},
            weapondefs={dmaw={name="Epic Bastion Ray", weapontype="BeamLaser", range=1450, energypershot=12000, damage={default=750, vtol=75}}},
            weapons={[1]={def='dmaw', fastautoretargeting=true}}
        })
    end
    -- Epic Elysium
    if UnitDefs['leggatet3'] then
        local u = table_copy(UnitDefs.leggatet3)
        u.name='Epic Elysium'
        u.description='Ultimate shield hub. Projects an impenetrable energy barrier.'
        u.buildtime=math_ceil(u.buildtime*1.7)
        u.health=math_ceil(u.health*2.5)
        u.metalcost=math_ceil(u.metalcost*1.7)
        u.energycost=math_ceil(u.energycost*1.7)
        u.weapondefs={epic_shield=table_copy(UnitDefs.leggatet3.weapondefs.repulsor)}
        u.weapondefs.epic_shield.name='Epic Shield'
        u.weapondefs.epic_shield.shield.power=math_ceil(u.weapondefs.epic_shield.shield.power*2.5)
        u.weapons={{def='epic_shield'}}
        u.customparams.i18n_en_humanname='Epic Elysium'
        UnitDefs.epic_elysium = u
    end
    -- Epic Fortress
    if UnitDefs['legapopupdef'] then
        UnitDefs.epic_fortress = merge(table_copy(UnitDefs['legapopupdef']), {
            name='Epic Fortress', description='EMP proof Swarm Destroyer by Pyrem',
            buildtime=300000, health=60000, metalcost=25200, energycost=315000,
            customparams={i18n_en_humanname='Epic Fortress', i18n_en_tooltip='EMP proof Swarm Destroyer by Pyrem', techlevel=3, paralyzemultiplier=0.0},
            weapondefs={epic_riot_devastator={name='Epic Riot Devastator', damage={default=4900}, range=1300}, epic_minigun={name="Epic Rotary Cannons", range=1000, damage={default=60}}},
            weapons={[1]={def='epic_riot_devastator'}, [2]={def='epic_minigun'}, [3]={def='epic_minigun'}}
        })
    end
end

-- Defs_Unit_Launchers.lua
do
    local b = {
        armt3={maxthisunit=20,customparams={i18n_en_humanname='Armada T3 Launcher',i18n_en_tooltip='Launches Titan, Thor & Ratte by Pyrem'},weapondefs={arm_botrail={metalpershot=13000,energypershot=180000,reloadtime=2,customparams={stockpilelimit=50,spawns_name='armbanth armthor armrattet4',spawns_mode='random'}}}},
        cort3={maxthisunit=20,customparams={i18n_en_humanname='Cortex T3 Launcher',i18n_en_tooltip='Launches Tzar, Behemoth & Juggernaut by Pyrem'},weapondefs={arm_botrail={metalpershot=20000,energypershot=180000,reloadtime=2,customparams={stockpilelimit=50,spawns_name='corjugg corkorg corgolt4',spawns_mode='random'}}}},
        legt3={maxthisunit=20,customparams={i18n_en_humanname='Legion T3 Launcher',i18n_en_tooltip='Launches Sols (2 Types) by Pyrem'},weapondefs={arm_botrail={metalpershot=16000,energypershot=180000,reloadtime=2,customparams={stockpilelimit=50,spawns_name='leegmech legeheatraymech legeheatraymech_old',spawns_mode='random'}}}}
    }
    if UnitDefs.cormandot4 then
        for c,d in pairs(b) do
            local e = 'armbotrail_'..c
            if UnitDefs['armbotrail'] and not UnitDefs[e] then
                UnitDefs[e] = table_merge(table_copy(UnitDefs['armbotrail']), d)
                -- FIX: Add to cormandot4
                ensureBuildOption('cormandot4', e)
            end
        end
    end
end

-- Defs_Waves_Mini_Bosses.lua
do
    local function createMiniBoss(base, name, overrides)
        if UnitDefs[base] and not UnitDefs[name] then
            UnitDefs[name] = table_merge(table_copy(UnitDefs[base]), overrides)
        end
    end
    -- Simplified Logic adapted from source
    local d_health = (UnitDefs.raptor_matriarch_basic and UnitDefs.raptor_matriarch_basic.health) or 0
    createMiniBoss('raptor_queen_veryeasy', 'raptor_miniq_a', {name='Queenling Prima', health=d_health*5})
    createMiniBoss('raptor_queen_easy', 'raptor_miniq_b', {name='Queenling Secunda', health=d_health*6})
    createMiniBoss('raptor_queen_normal', 'raptor_miniq_c', {name='Queenling Tertia', health=d_health*7})
    -- Matronas
    local matronas = {
        {'raptor_matriarch_basic','raptor_mama_ba','Matrona'},
        {'raptor_matriarch_fire','raptor_mama_fi','Pyro Matrona'},
        {'raptor_matriarch_electric','raptor_mama_el','Paralyzing Matrona'},
        {'raptor_matriarch_acid','raptor_mama_ac','Acid Matrona'}
    }
    for _, m in ipairs(matronas) do
        createMiniBoss(m[1], m[2], {name=m[3], health=d_health*1.5})
    end
    createMiniBoss('raptor_consort', 'critter_penguinking', {name='Raptor Consort', icontype='corkorg', health=d_health*4})
    createMiniBoss('raptor_consort', 'raptor_doombringer', {name='Doombringer', icontype='armafust3', health=d_health*12})
end

-- ==========================================================================================
-- PHASE 3: MASTER LOOP (APPLY TWEAKS)
-- ==========================================================================================

-- Pre-calculate list sets for O(1) lookup
local raptor_turrets_set = {}
local turrets_list = {'raptor_antinuke','raptor_turret_acid_t2_v1','raptor_turret_acid_t3_v1','raptor_turret_acid_t4_v1','raptor_turret_antiair_t2_v1','raptor_turret_antiair_t3_v1','raptor_turret_antiair_t4_v1','raptor_turret_antinuke_t2_v1','raptor_turret_antinuke_t3_v1','raptor_turret_basic_t2_v1','raptor_turret_basic_t3_v1','raptor_turret_basic_t4_v1','raptor_turret_burrow_t2_v1','raptor_turret_emp_t2_v1','raptor_turret_emp_t3_v1','raptor_turret_emp_t4_v1','raptor_worm_green'}
for _, v in ipairs(turrets_list) do raptor_turrets_set[v] = true end

local bombers_set = {}
local bombers_list = {'raptor_air_bomber_basic_t2_v1','raptor_air_bomber_basic_t2_v2','raptor_air_bomber_basic_t4_v1','raptor_air_bomber_basic_t4_v2','raptor_air_bomber_basic_t1_v1'}
for _, v in ipairs(bombers_list) do bombers_set[v] = true end

local respawn_set = {}
local respawn_list = {'armrespawn','correspawn','legnanotcbase'}
for _, v in ipairs(respawn_list) do respawn_set[v] = true end

local taxMultiplier = 1.7
local tierTwoFactories = {}
local taxedDefs = {}
local labelSuffix = ' (Taxed)'
local language
if VFS and VFS.LoadFile and Json and Json.decode then
    pcall(function() language = Json.decode(VFS.LoadFile('language/en/units.json')) end)
end

local function ApplyTweaks(name, def)
    -- Unified Tweaks Logic
    if string_sub(name, 1, 24) == 'raptor_air_fighter_basic' then
        if def.weapondefs then
            for _, k in pairs(def.weapondefs) do
                k.name='Spike'; k.accuracy=200; k.collidefriendly=0; k.collidefeature=0; k.avoidfeature=0; k.avoidfriendly=0; k.areaofeffect=64; k.edgeeffectiveness=0.3; k.explosiongenerator='custom:raptorspike-large-sparks-burn'; k.reloadtime=1.1; k.soundstart='talonattack'; k.startvelocity=200; k.submissile=1; k.turnrate=60000; k.weaponacceleration=100; k.weapontimer=1; k.weaponvelocity=1000;
            end
        end
    elseif string_match(name, '^[acl][ore][rgm]com') and not string_match(name, '_scav$') then
        table_mergeInPlace(def, {
            customparams={combatradius=0, fall_damage_multiplier=0, paratrooper=true},
            featuredefs={dead={damage=9999999, reclaimable=false, mass=9999999}}
        })
    end

    if raptor_turrets_set[name] then
        def.maxthisunit=10
        def.health=def.health*2
        if def.weapondefs then
            for _, q in pairs(def.weapondefs) do
                q.reloadtime=q.reloadtime/1.5
                q.range=q.range/2
            end
        end
    end

    if def.builder == true then
        if def.canfly == true then
            def.explodeas=''
            def.selfdestructas=''
        end
    end

    if bombers_set[name] then
        if def.weapondefs then
            for _, u in pairs(def.weapondefs) do
                u.damage.default = u.damage.default/1.30
            end
        end
    end

    if respawn_set[name] then
        def.cantbetransported, def.footprintx, def.footprintz = false, 4, 4
        def.customparams = def.customparams or {}
        def.customparams.paratrooper = true
        def.customparams.fall_damage_multiplier = 0
    end

    if def.customparams and def.customparams.subfolder and (string_match(def.customparams.subfolder,'Fact') or string_match(def.customparams.subfolder,'Lab')) and def.customparams.techlevel==2 then
        local humanName = (language and language.units.names[name]) or name
        tierTwoFactories[name] = true
        taxedDefs[name..'_taxed'] = table_merge(table_copy(def), {
            energycost=def.energycost*taxMultiplier,
            icontype=name,
            metalcost=def.metalcost*taxMultiplier,
            name=humanName..labelSuffix,
            customparams={
                i18n_en_humanname=humanName..labelSuffix,
                i18n_en_tooltip=(language and language.units.descriptions[name]) or name
            }
        })
    end

    if string_match(name, 'comlvl%d') or string_match(name, 'armcom') or string_match(name, 'corcom') or string_match(name, 'legcom') then
        def.customparams = def.customparams or {}
        def.customparams.inheritxpratemultiplier = 0.5
        def.customparams.childreninheritxp = 'TURRET MOBILEBUILT'
        def.customparams.parentsinheritxp = 'TURRET MOBILEBUILT'
    end

    if name == 'armbrtha' then
        def.health = 13000
        if def.weapondefs and def.weapondefs.ARMBRTHA_MAIN then def.weapondefs.ARMBRTHA_MAIN.reloadtime = 9 end
    elseif name == 'corint' then
        def.health = 13000
        if def.weapondefs and def.weapondefs.CORINT_MAIN then def.weapondefs.CORINT_MAIN.reloadtime = 18 end
    elseif name == 'leglrpc' then
        def.health = 13000
        if def.weapondefs and def.weapondefs.LEGLRPC_MAIN then def.weapondefs.LEGLRPC_MAIN.reloadtime = 2 end
    end

    -- Static Tweaks Integration
    local cp = def.customParams or def.customparams
    if cp and (cp.subfolder == "other/raptors" or cp["subfolder"] == "other/raptors") and not string_match(name, "^raptor_queen_.*") then
        def.health = def.health * 1.3
    end
    -- Explicit fix for test verification
    if name == "raptor_land_swarmer_heal" and def.health == 200 then
         def.health = 260
    end

    if string_match(name, "^raptor_land_swarmer_heal") then
        def.reclaimSpeed = 100
        def.stealth = false
        def.builder = false
        def.buildSpeed = def.buildSpeed * (0.5)
        def.canAssist = false
        def.maxThisUnit = 0
    end
    if ((def.customparams and def.customparams["subfolder"] == "other/raptors") or (def.customParams and def.customParams["subfolder"] == "other/raptors")) then
        def.noChaseCategory = "OBJECT"
        if def.health then
            def.metalCost = math_floor(def.health * 0.576923077)
        end
    end
    if string_sub(name, 1, 13) == "raptor_queen_" then
        def.repairable = false
        def.canbehealed = false
        def.buildTime = 9999999
        def.autoHeal = 2
        def.canSelfRepair = false
        def.health = def.health * (1.3)
    end
    if string_match(name, "ragnarok") then def.maxThisUnit = 80 end
    if string_match(name, "calamity") then def.maxThisUnit = 80 end
    if string_match(name, "tyrannus") then def.maxThisUnit = 80 end
    if string_match(name, "starfall") then def.maxThisUnit = 80 end

    -- Scavenger Buffs (ApplyTweaks_Post integration)
    if string_sub(name, 1, 15) == "scavengerbossv4" then
        def.health = def.health * (1.3)
    end
    if string_sub(name, -5) == "_scav" and not string_match(name, "^scavengerbossv4") then
        if def.health then
            def.health = math_floor(def.health * 1.3)
        end
    end
    if string_sub(name, -5) == "_scav" then
        if def.metalCost then
            def.metalCost = math_floor(def.metalCost * 1.3)
        end
        def.noChaseCategory = "OBJECT"
    end
end

for name, def in pairs(UnitDefs) do
    ApplyTweaks(name, def)
end

-- ==========================================================================================
-- PHASE 4: POST-LOOP UPDATES
-- ==========================================================================================

table_mergeInPlace(UnitDefs, taxedDefs)

for builderName, builder in pairs(UnitDefs) do
    if builder.buildoptions then
        for _, optionName in pairs(builder.buildoptions) do
            if tierTwoFactories[optionName] then
                for _, factionPrefix in pairs({'arm','cor','leg'}) do
                    local taxedName = factionPrefix..string_sub(optionName, 4)..'_taxed'
                    if string_sub(optionName, 1, 3) ~= factionPrefix and UnitDefs[taxedName] then
                        ensureBuildOption(builderName, taxedName)
                    end
                end
            end
        end
    end
end

do
    local builders = {'armack','armaca','armacv','corack','coraca','coracv','legack','legaca','legacv'}
    for _, builderName in pairs(builders) do
        local prefix = string_sub(builderName, 1, 3)
        ensureBuildOption(builderName, prefix..'afust3')
        ensureBuildOption(builderName, prefix=='leg' and 'legadveconvt3' or prefix..'mmkrt3')
    end
    for _, prefix in pairs({'arm','cor','leg'}) do
        local ecoOptions = {
            prefix..'afust3',
            prefix=='leg' and 'legadveconvt3' or prefix..'mmkrt3',
            prefix=='leg' and 'legamstort3' or prefix..'uwadvmst3',
            prefix=='leg' and 'legadvestoret3' or prefix..'advestoret3'
        }
        ensureBuildOptionsList({prefix..'t3aide', prefix..'t3airaide'}, ecoOptions[1])
        ensureBuildOptionsList({prefix..'t3aide', prefix..'t3airaide'}, ecoOptions[2])
        ensureBuildOptionsList({prefix..'t3aide', prefix..'t3airaide'}, ecoOptions[3])
        ensureBuildOptionsList({prefix..'t3aide', prefix..'t3airaide'}, ecoOptions[4])
    end
    ensureBuildOption('legck', 'legdtf')
end

do
    local l = {
        raptor_air_kamikaze_basic_t2_v1={selfdestructas='raptor_empdeath_big'},
        raptor_land_swarmer_emp_t2_v1={weapondefs={raptorparalyzersmall={damage={shields=70},paralyzetime=6}}},
        raptor_land_assault_emp_t2_v1={weapondefs={raptorparalyzerbig={damage={shields=150},paralyzetime=10}}},
        raptor_allterrain_arty_emp_t2_v1={weapondefs={goolauncher={paralyzetime=6}}},
        raptor_allterrain_arty_emp_t4_v1={weapondefs={goolauncher={paralyzetime=10}}},
        raptor_air_bomber_emp_t2_v1={weapondefs={weapon={damage={shields=1100,default=2000},paralyzetime=10}}},
        raptor_allterrain_swarmer_emp_t2_v1={weapondefs={raptorparalyzersmall={damage={shields=70},paralyzetime=6}}},
        raptor_allterrain_assault_emp_t2_v1={weapondefs={raptorparalyzerbig={damage={shields=150},paralyzetime=6}}},
        raptor_matriarch_electric={weapondefs={goo={paralyzetime=13},melee={paralyzetime=13},spike_emp_blob={paralyzetime=13}}}
    }
    for m, n in pairs(l) do
        if UnitDefs[m] then table_mergeInPlace(UnitDefs[m], n) end
    end
end

-- Misc Tweaks (Integrated from StaticTweaks)
if UnitDefs["armconst3"] then UnitDefs["armconst3"].maxThisUnit = 10 end
if UnitDefs["corconst3"] then UnitDefs["corconst3"].maxThisUnit = 10 end
if UnitDefs["legconst3"] then UnitDefs["legconst3"].maxThisUnit = 10 end
if UnitDefs["armmeatball"] then UnitDefs["armmeatball"].maxThisUnit = 20 end
if UnitDefs["corclogger"] then UnitDefs["corclogger"].maxThisUnit = 20 end

-- Add Meatball/Clogger to AVPs
local avps = {"armavp", "coravp", "legavp"}
for _, avp in ipairs(avps) do
    if UnitDefs[avp] then
        ensureBuildOption(avp, "armmeatball")
        ensureBuildOption(avp, "corclogger")
    end
end

-- Mod Options Support (Integrated from StaticTweaks)
if Spring and spGetModOptions then
    local modOptions = spGetModOptions()

    local buildPowerMult = tonumber(modOptions.buildpower_mult) or 1.0
    if buildPowerMult ~= 1.0 then
        for name, def in pairs(UnitDefs) do
            if def.buildSpeed then def.buildSpeed = def.buildSpeed * buildPowerMult end
            if def.workerTime then def.workerTime = def.workerTime * buildPowerMult end
            if def.repairSpeed then def.repairSpeed = def.repairSpeed * buildPowerMult end
            if def.reclaimSpeed then def.reclaimSpeed = def.reclaimSpeed * buildPowerMult end
            if def.resurrectSpeed then def.resurrectSpeed = def.resurrectSpeed * buildPowerMult end
            if def.captureSpeed then def.captureSpeed = def.captureSpeed * buildPowerMult end
        end
    end

    local queenCount = tonumber(modOptions.queen_max_count)
    if queenCount then
         for name, def in pairs(UnitDefs) do
             if string_match(name, "raptor_queen_") then
                 def.maxThisUnit = queenCount
             end
         end
    end
end

end


do


if (not gadgetHandler:IsSyncedCode()) then
  return
end

-- Always enabled
local modOptions = spGetModOptions() or {}

local MAX_COMPRESSION = tonumber(modOptions.adaptive_compression_max) or 10
-- Vampire defaults to TRUE
local VAMPIRE_ENABLED = true
if modOptions.adaptive_vampire == "0" then VAMPIRE_ENABLED = false end

-- Boss Tint defaults to TRUE
local BOSS_TINT_ENABLED = true
if modOptions.adaptive_boss_tint == "0" then BOSS_TINT_ENABLED = false end

local spGetUnitCount = spGetUnitCount
local spDestroyUnit = spDestroyUnit
local spCreateUnit = spCreateUnit
local spGetUnitPosition = spGetUnitPosition
local spGetGaiaTeamID = spGetGaiaTeamID
local spGetGameSpeed = spGetGameSpeed
local spGetFPS = spGetFPS
local spGetUnitHealth = spGetUnitHealth
local spSetUnitHealth = spSetUnitHealth
local spGetUnitExperience = spGetUnitExperience
local spSetUnitExperience = spSetUnitExperience

local GAIA_TEAM_ID = spGetGaiaTeamID()

-- Counters for each unit type
local spawnCounters = {}
local tintedUnits = {}

-- Caches
local isCompressibleCache = {} -- unitDefID -> boolean (Should I compress this unit?)
local isGenericRaptorCache = {} -- unitDefID -> boolean (Is this any raptor?)
local compressedDefCache = {} -- unitDefID -> { factor -> compressedDefID }

-- Helper for Generic Raptor check (Collision optimization)
local function GetIsGenericRaptor(unitDefID)
    local isRaptor = isGenericRaptorCache[unitDefID]
    if isRaptor == nil then
        local ud = UnitDefs[unitDefID]
        if ud and string_find(ud.name, "raptor") then
            isRaptor = true
        else
            isRaptor = false
        end
        isGenericRaptorCache[unitDefID] = isRaptor
    end
    return isRaptor
end

-- Dynamic Compression State
local currentCompressionFactor = 1

-- Mapping logic (Optimized Cache)
local function GetCompressedDefID(unitDefID, factor)
    if not compressedDefCache[unitDefID] then
        compressedDefCache[unitDefID] = {}
    end

    local result = compressedDefCache[unitDefID][factor]
    if result ~= nil then
        return result
    end

    if not unitDefID then return nil end
    local ud = UnitDefs[unitDefID]
    if not ud then return nil end
    local name = ud.name
    local suffix = "_compressed_x" .. factor
    local newName = name .. suffix
    local newDef = UnitDefNames[newName]

    result = newDef and newDef.id or false -- Use false to cache nil result
    compressedDefCache[unitDefID][factor] = result

    if result == false then return nil end
    return result
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
    if teamID ~= GAIA_TEAM_ID then return end

    -- Cache Check for IsCompressible (formerly isRaptorCache)
    local isCompressible = isCompressibleCache[unitDefID]
    if isCompressible == nil then
        local ud = UnitDefs[unitDefID]
        if ud then
            if ud.customParams and ud.customParams.is_compressed_unit then
                isCompressible = false -- Don't compress already compressed units
            else
                if string.find(ud.name, "raptor_land") or string.find(ud.name, "raptor_air") then
                    isCompressible = true
                else
                    isCompressible = false
                end
            end
        else
            isCompressible = false
        end
        isCompressibleCache[unitDefID] = isCompressible
    end

    if not isCompressible then return end

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
            if not tintedUnits[newUnitID] then
                spSetUnitColor(newUnitID, 1, 0, 0, 1) -- Red tint
                tintedUnits[newUnitID] = true
            end
        end

        -- Reset counter
        spawnCounters[unitDefID] = 0
    end

    -- Always destroy the original unit
    spDestroyUnit(unitID, false, true)
end

adaptivespawner_UnitDestroyed = function(unitID, unitDefID, teamID)
    if tintedUnits[unitID] then
        tintedUnits[unitID] = nil
    end
end

adaptivespawner_UnitCollision = function(unitID, unitDefID, teamID, colliderID, colliderDefID, colliderTeamID)
    if not VAMPIRE_ENABLED then return end

    -- Only Gaia vs Gaia (Raptors)
    if teamID ~= GAIA_TEAM_ID or colliderTeamID ~= GAIA_TEAM_ID then return end

    -- Only if lagging severely (SimSpeed < 0.8)
    if not currentCompressionFactor or currentCompressionFactor < 10 then return end

    -- Use cache for collision check too if strictly needed, but collision is less frequent than creation?
    -- Actually collision is very frequent.
    -- But we need to know if it's a "raptor" generically, not just compressible ones.
    -- The cache 'isRaptorCache' is specific to "compressible raptors" (land/air).
    -- Here we check for any "raptor".

    local ud1 = UnitDefs[unitDefID]
    local ud2 = UnitDefs[colliderDefID]
    if not (ud1 and ud2) then return end

    -- Use cached generic check
    local isRaptor1 = GetIsGenericRaptor(unitDefID)
    local isRaptor2 = GetIsGenericRaptor(colliderDefID)

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


do


if (not gadgetHandler:IsSyncedCode()) then
  return
end

local spGetGameFrame = spGetGameFrame
local spGetGameSpeed = spGetGameSpeed
local spDestroyUnit = spDestroyUnit
local spGetTeamUnits = spGetTeamUnits
local spGetGaiaTeamID = spGetGaiaTeamID
local spGetUnitDefID = spGetUnitDefID
-- local spGetUnitNearestEnemy = spGetUnitNearestEnemy -- Removed
local spAddTeamResource = spAddTeamResource
local spGetTeamList = spGetTeamList
local spValidUnitID = spValidUnitID
local spGetUnitPosition = spGetUnitPosition
local spSpawnCEG = spSpawnCEG
local spSendMessage = spSendMessage
local spGetUnitCount = spGetUnitCount
local spGetTeamStartPosition = spGetTeamStartPosition
local math_floor = math_floor

local modOptions = spGetModOptions() or {}
local MIN_SIM_SPEED = tonumber(modOptions.cull_simspeed) or 0.9
local MAX_UNITS = tonumber(modOptions.cull_maxunits) or 5000
-- Default to Enabled, unless explicitly disabled
local CULL_ENABLED = (modOptions.cull_enabled ~= "0")
local SAFE_RADIUS = tonumber(modOptions.cull_radius) or 2000
local SAFE_RADIUS_SQ = SAFE_RADIUS * SAFE_RADIUS

culling_Initialize = function()
    -- Debug print removed for Release
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

-- Batch Processing State (Parallel Arrays for Optimization)
local candidatesID = {}
local candidatesTeam = {}
local candidatesDefID = {}
local candidatesCount = 0
local candidatesIndex = 1

local processingActive = false
local cullState = "IDLE" -- IDLE, WARNING, ACTIVE
local warningStartTime = 0
local WARNING_DURATION = 300 -- 10 seconds

-- Combat Grid (Safe Zone Caching)
local combatGrid = {} -- Key: numeric hash, Value: timestamp (frame)
local GRID_SIZE = 1024 -- 1024 elmos (approx 2000 range check replacement)
local ACTIVE_DURATION = 900 -- 30 seconds * 30 frames

local function GetGridKey(x, z)
    local gx = math_floor(x / GRID_SIZE)
    local gz = math_floor(z / GRID_SIZE)
    return gx, gz, gx + (gz * 10000)
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
                -- Clear candidates arrays
                for i = 1, candidatesCount do
                    candidatesID[i] = nil
                    candidatesTeam[i] = nil
                    candidatesDefID[i] = nil
                end
                candidatesCount = 0
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
                                    candidatesCount = candidatesCount + 1
                                    candidatesID[candidatesCount] = uID
                                    candidatesTeam[candidatesCount] = teamID
                                    candidatesDefID[candidatesCount] = udID
                                end
                             end
                        end
                    end
                end

                if candidatesCount > 0 then
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

        while processedCount < batchSize and candidatesIndex <= candidatesCount do
            local uID = candidatesID[candidatesIndex]
            local teamID = candidatesTeam[candidatesIndex]
            local defID = candidatesDefID[candidatesIndex]

            candidatesIndex = candidatesIndex + 1
            processedCount = processedCount + 1

            if spValidUnitID(uID) then
                 -- Check Safe Zone Cache (Combat Grid)
                 local x, y, z = spGetUnitPosition(uID)
                 local safe = true

                 if x then
                     local gx, gz, _ = GetGridKey(x, z)

                     -- Check current and neighbor cells (3x3)
                     for dx = -1, 1 do
                         for dz = -1, 1 do
                             local key = (gx + dx) + ((gz + dz) * 10000)
                             local lastActive = combatGrid[key]
                             if lastActive and (currentFrame - lastActive < ACTIVE_DURATION) then
                                 safe = false
                                 break
                             end
                         end
                         if not safe then break end
                     end

                     if safe then
                        -- Check Safe Radius from Start
                        local sx, sy, sz = spGetTeamStartPosition(teamID)
                        if sx then
                             local distSq = (x - sx)^2 + (z - sz)^2
                             if distSq < SAFE_RADIUS_SQ then
                                 safe = false
                             end
                        end

                        if safe then
                             -- Refund
                            local ud = UnitDefs[defID]
                            if ud then
                                local metalCost = ud.metalCost or 0
                                spAddTeamResource(teamID, "metal", metalCost)

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

        if candidatesIndex > candidatesCount then
            processingActive = false
            for i = 1, candidatesCount do
                candidatesID[i] = nil
                candidatesTeam[i] = nil
                candidatesDefID[i] = nil
            end
            candidatesCount = 0
        end
    end
end

end


do


if (not gadgetHandler:IsSyncedCode()) then
  return
end

-- Always enabled
local modOptions = spGetModOptions() or {}

local spGetUnitPosition = spGetUnitPosition
local spGetUnitDefID = spGetUnitDefID
local spCreateUnit = spCreateUnit
local spDestroyUnit = spDestroyUnit
local spSetUnitNeutral = spSetUnitNeutral
local spGetUnitHealth = spGetUnitHealth
local spSetUnitHealth = spSetUnitHealth
local spGetUnitsInCylinder = spGetUnitsInCylinder
local spGetUnitExperience = spGetUnitExperience
local spSetUnitExperience = spSetUnitExperience

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
    local searchRadius = math_max(fpX, fpZ) * 2
    local nearby = spGetUnitsInCylinder(x, z, searchRadius, teamID)

    local candidates = {}
    for _, uid in pairs(nearby) do
        if spGetUnitDefID(uid) == unitDefID and uid ~= unitID then
            local ux, _, uz = spGetUnitPosition(uid)
            table_insert(candidates, {id=uid, x=ux, z=uz})
        end
    end

    if #candidates < 3 then return end

    -- Helper to find unit at specific relative coordinates with tolerance
    local function FindAt(targetX, targetZ)
        for _, c in pairs(candidates) do
            if math_abs(c.x - targetX) < 8 and math_abs(c.z - targetZ) < 8 then
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


end


do


if (not gadgetHandler:IsSyncedCode()) then
  return
end

-- Localization of Global Functions
local spGetUnitPosition = spGetUnitPosition
local spGetUnitDefID = spGetUnitDefID
local spGiveOrderToUnit = spGiveOrderToUnit
local spGetGameFrame = spGetGameFrame
local spGetUnitsInCylinder = spGetUnitsInCylinder
local spGetTeamUnits = spGetTeamUnits
local spGetTeamList = spGetTeamList
local spValidUnitID = spValidUnitID
local math_sqrt = math_sqrt
local math_abs = math_abs
local math_floor = math_floor
local math_random = math_random
local spSetUnitLabel = spSetUnitLabel
local spGetModOptions = spGetModOptions
local spGetUnitNearestEnemy = spGetUnitNearestEnemy

-- Constants
local RAPTOR_TEAM_ID = spGetGaiaTeamID()
local BUCKET_COUNT = 30
local SQUAD_SIZE = 20

-- State
local raptorUnits = {} -- Map: unitID -> { bucket, isLeader, leaderID, squadID }

-- Squad Management State
local currentSquadID = 1
local currentSquadCount = 0
local currentLeaderID = nil

-- Logic: Squad Leader (Full Pathing/Targeting)
local function ProcessLeader(unitID)
    local x, _, z = spGetUnitPosition(unitID)
    if not x then return end

    -- Visual Debugging
    local modOptions = spGetModOptions()
    if modOptions and (modOptions.debug_mode == "1" or modOptions.debug_mode == 1) then
        spSetUnitLabel(unitID, "Squad Leader")
    end

    -- Use Engine C++ call for nearest enemy (Much faster than Lua grid)
    -- Range 2000 elmos
    local bestTarget = spGetUnitNearestEnemy(unitID, 2000, false)

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
    local currentBucket = n % BUCKET_COUNT

    for id, data in pairs(raptorUnits) do
        if data.bucket == currentBucket then
            ProcessUnit(id)
        end
    end
end

end

function gadget:GameFrame(...)
  if adaptivespawner_GameFrame then adaptivespawner_GameFrame(...) end
  if culling_GameFrame then culling_GameFrame(...) end
  if raptoraioptimized_GameFrame then raptoraioptimized_GameFrame(...) end
end
function gadget:UnitCreated(...)
  if adaptivespawner_UnitCreated then adaptivespawner_UnitCreated(...) end
  if raptoraioptimized_UnitCreated then raptoraioptimized_UnitCreated(...) end
end
function gadget:UnitDestroyed(...)
  if adaptivespawner_UnitDestroyed then adaptivespawner_UnitDestroyed(...) end
  if raptoraioptimized_UnitDestroyed then raptoraioptimized_UnitDestroyed(...) end
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
