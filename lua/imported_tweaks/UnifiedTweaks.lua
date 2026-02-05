
-- Unified Tweaks for NuttyB Mod
-- This file consolidates logic from multiple tweak files into a single optimized pass.

local UnitDefs = UnitDefs or {}
local pairs = pairs
local ipairs = ipairs
local string_sub = string.sub
local string_match = string.match
local table_insert = table.insert
local table_remove = table.remove
local math_max = math.max
local math_ceil = math.ceil
local math_floor = math.floor
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

local function removeBuildOption(builderNames, optionName)
    for i = 1, #builderNames do
        local builder = UnitDefs[builderNames[i]]
        if builder and builder.buildoptions then
            local buildoptions = builder.buildoptions
            for j = #buildoptions, 1, -1 do
                if buildoptions[j] == optionName then
                    table.remove(buildoptions, j)
                end
            end
        end
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

-- [Armada Commanders]
do
    local armada_coms = {
  armcom = {
    footprintx = 2,
    footprintz = 2,
    customparams = {
      evolution_target = 'armcomlvl2',
      evolution_condition = 'timer_global',
      evolution_timer = 420,
    },
    energymake = 100,
    metalmake = 10,
    autoheal = 55,
    health = 4500,
    speed = 41,
    canresurrect = true,
    buildoptions = {
      'armsolar',
      'armwin',
      'armmstor',
      'armestor',
      'armmex',
      'armmakr',
      'armgate',
      'armlab',
      'armnanotc',
      'armvp',
      'armap',
      'armeyes',
      'armrad',
      'armdrag',
      'armllt',
      'armrl',
      'armdl',
      'armtide',
      'armuwms',
      'armuwes',
      'armuwmex',
      'armfmkr',
      'armsy',
      'armfdrag',
      'armtl',
      'armfrt',
      'armfrad',
      'armhp',
      'armfhp',
      'armgeo',
      'armamex',
      'armbeamer',
      'armjamt',
      'armsy',
      'armrectr',
      'armclaw',
    },
    weapondefs = {
      armcomlaser = {
        range = 330,
        rgbcolor = '0.7 1 1',
        soundstart = 'lasrfir1',
        damage = {
          default = 175,
        },
      },
      old_armsnipe_weapon = {
        areaofeffect = 32,
        avoidfeature = true,
        avoidfriendly = true,
        collidefeature = true,
        collidefriendly = false,
        corethickness = 0.75,
        craterareaofeffect = 0,
        craterboost = 0,
        commandfire = true,
        cratermult = 0,
        cegtag = 'railgun',
        duration = 0.12,
        edgeeffectiveness = 0.85,
        energypershot = 400,
        explosiongenerator = 'custom:laserhit-large-blue',
        firestarter = 100,
        impulseboost = 0.4,
        impulsefactor = 1,
        intensity = 0.8,
        name = 'Long-range rail rifle',
        range = 550,
        reloadtime = 1,
        rgbcolor = '0 1 1',
        rgbcolor2 = '0 1 1',
        soundhit = 'sniperhit',
        soundhitwet = 'sizzle',
        soundstart = 'sniper3',
        soundtrigger = true,
        stockpile = true,
        stockpiletime = 7,
        customparams = {
          stockpilelimit = 5,
        },
        texture1 = 'shot',
        texture2 = 'empty',
        thickness = 4,
        tolerance = 1000,
        turret = true,
        weapontype = 'LaserCannon',
        weaponvelocity = 3000,
        damage = {
          commanders = 100,
          default = 4900,
        },
      },
    },
    weapons = {
      [3] = {
        def = 'old_armsnipe_weapon',
        onlytargetcategory = 'NOTSUB',
      },
    },
  },
  armcomlvl2 = {
    footprintx = 2,
    footprintz = 2,
    autoheal = 125,
    builddistance = 200,
    canresurrect = true,
    energymake = 315,
    health = 8125,
    speed = 57.5,
    metalmake = 30,
    workertime = 1700,
    buildoptions = {
      'armsolar',
      'armwin',
      'armmstor',
      'armestor',
      'armmex',
      'armmakr',
      'armgate',
      'armlab',
      'armvp',
      'armap',
      'armeyes',
      'armrad',
      'armdrag',
      'armllt',
      'armrl',
      'armdl',
      'armtide',
      'armuwms',
      'armuwes',
      'armuwmex',
      'armfmkr',
      'armsy',
      'armfdrag',
      'armtl',
      'armfrt',
      'armfrad',
      'armhp',
      'armfhp',
      'armadvsol',
      'armgeo',
      'armamex',
      'armlwall',
      'armnanotct2',
      'armclaw',
      'armbeamer',
      'armhlt',
      'armguard',
      'armferret',
      'armcir',
      'armjamt',
      'armjuno',
      'armsy',
      'armrectr',
    },
    customparams = {
      evolution_target = 'armcomlvl3',
      evolution_condition = 'timer_global',
      evolution_timer = 1320,
    },
    weapondefs = {
      armcomlaser = {
        areaofeffect = 16,
        avoidfeature = false,
        beamtime = 0.1,
        corethickness = 0.1,
        craterareaofeffect = 0,
        craterboost = 0,
        cratermult = 0,
        cylindertargeting = 1,
        edgeeffectiveness = 1,
        explosiongenerator = 'custom:laserhit-small-red',
        firestarter = 70,
        impactonly = 1,
        impulseboost = 0,
        impulsefactor = 0,
        laserflaresize = 7.7,
        name = 'Light close-quarters g2g/g2a laser',
        noselfdamage = true,
        range = 425,
        reloadtime = 0.7,
        rgbcolor = '0 1 1',
        soundhitdry = '',
        soundhitwet = 'sizzle',
        soundstart = 'lasrfir1',
        soundtrigger = 1,
        targetmoveerror = 0.05,
        thickness = 4,
        tolerance = 10000,
        turret = true,
        weapontype = 'BeamLaser',
        weaponvelocity = 900,
        damage = {
          default = 950,
          VTOL = 150,
        },
      },
      old_armsnipe_weapon = {
        areaofeffect = 42,
        avoidfeature = true,
        avoidfriendly = true,
        collidefeature = true,
        collidefriendly = false,
        corethickness = 0.75,
        craterareaofeffect = 0,
        craterboost = 0,
        commandfire = true,
        cratermult = 0,
        cegtag = 'railgun',
        duration = 0.12,
        edgeeffectiveness = 0.85,
        energypershot = 700,
        explosiongenerator = 'custom:laserhit-large-blue',
        firestarter = 100,
        impulseboost = 0.4,
        impulsefactor = 1,
        intensity = 1,
        name = 'Long-range g2g armor-piercing rifle',
        range = 700,
        reloadtime = 1,
        rgbcolor = '0.2 0.1 1',
        rgbcolor2 = '0.2 0.1 1',
        soundhit = 'sniperhit',
        soundhitwet = 'sizzle',
        soundstart = 'sniper3',
        soundtrigger = true,
        stockpile = true,
        stockpiletime = 6,
        customparams = {
          stockpilelimit = 10,
        },
        texture1 = 'shot',
        texture2 = 'empty',
        thickness = 4,
        tolerance = 1000,
        turret = true,
        weapontype = 'LaserCannon',
        weaponvelocity = 3000,
        damage = {
          commanders = 10,
          default = 11000,
        },
      },
    },
    weapons = {
      [1] = {
        def = 'armcomlaser',
        onlytargetcategory = 'NOTSUB',
        fastautoretargeting = true,
      },
      [3] = {
        def = 'old_armsnipe_weapon',
        onlytargetcategory = 'NOTSUB',
      },
    },
  },
  armcomlvl3 = {
    footprintx = 2,
    footprintz = 2,
    autoheal = 600,
    builddistance = 350,
    canresurrect = true,
    energymake = 2712,
    health = 16000,
    speed = 71.5,
    metalmake = 62,
    workertime = 3400,
    buildoptions = {
      'armanni',
      'armpb',
      'armamb',
      'armmoho',
      'armuwmme',
      'armflak',
      'armmercury',
      'armgate',
      'armsd',
      'armfort',
      'armtarg',
      'armarad',
      'armamd',
      'armveil',
      'armuwadvms',
      'armuwadves',
      'armmmkr',
      'armuwmmm',
      'armavp',
      'armaap',
      'armalab',
      'armfflak',
      'armatl',
      'armkraken',
      'armbrtha',
      'armannit3',
      'armlwall',
      'armgatet3',
      'armannit4',
      'armnanotct2',
      'armnanotct3',
    },
    customparams = {
      evolution_target = 'armcomlvl4',
      evolution_condition = 'timer_global',
      evolution_timer = 1740,
    },
    weapondefs = {
      old_armsnipe_weapon = {
        areaofeffect = 64,
        avoidfeature = true,
        avoidfriendly = true,
        collidefeature = true,
        collidefriendly = false,
        corethickness = 0.75,
        craterareaofeffect = 0,
        craterboost = 0,
        commandfire = true,
        cratermult = 0,
        cegtag = 'railgun',
        duration = 0.12,
        edgeeffectiveness = 1,
        energypershot = 2000,
        explosiongenerator = 'custom:laserhit-large-blue',
        firestarter = 100,
        impulseboost = 0.4,
        impulsefactor = 1,
        intensity = 1.4,
        name = 'Long-range g2g armor-piercing rifle',
        range = 1250,
        reloadtime = 0.5,
        rgbcolor = '0.4 0.1 0.7',
        rgbcolor2 = '0.4 0.1 0.7',
        soundhit = 'sniperhit',
        soundhitwet = 'sizzle',
        soundstart = 'sniper3',
        soundtrigger = true,
        stockpile = true,
        stockpiletime = 3,
        customparams = {
          stockpilelimit = 10,
        },
        texture1 = 'shot',
        texture2 = 'empty',
        thickness = 6,
        tolerance = 1000,
        turret = true,
        weapontype = 'LaserCannon',
        weaponvelocity = 3000,
        damage = {
          commanders = 10,
          default = 35000,
        },
      },
      armcomlaser = {
        areaofeffect = 12,
        avoidfeature = false,
        beamtime = 0.1,
        corethickness = 0.1,
        craterareaofeffect = 0,
        craterboost = 0,
        cratermult = 0,
        cylindertargeting = 1,
        edgeeffectiveness = 1,
        explosiongenerator = 'custom:laserhit-small-red',
        firestarter = 70,
        impactonly = 1,
        impulseboost = 0,
        impulsefactor = 0,
        laserflaresize = 7.7,
        name = 'Light close-quarters g2g/g2a laser',
        noselfdamage = true,
        range = 500,
        reloadtime = 0.6,
        rgbcolor = '0.1 0 1',
        soundhitdry = '',
        soundhitwet = 'sizzle',
        soundstart = 'lasrcrw2',
        soundtrigger = 1,
        targetmoveerror = 0.05,
        thickness = 6,
        tolerance = 10000,
        turret = true,
        weapontype = 'BeamLaser',
        weaponvelocity = 900,
        damage = {
          default = 1450,
          VTOL = 180,
        },
      },
    },
    weapons = {
      [5] = {
        badtargetcategory = 'MOBILE',
        def = 'armcomlaser',
        onlytargetcategory = 'NOTSUB',
        fastautoretargeting = true,
      },
      [3] = {
        def = 'old_armsnipe_weapon',
        onlytargetcategory = 'NOTSUB',
      },
      [4] = {
        def = '',
      },
      [1] = {
        def = '',
      },
      [6] = {
        def = '',
      },
    },
  },
  armcomlvl4 = {
    footprintx = 2,
    footprintz = 2,
    autoheal = 2213,
    builddistance = 500,
    canresurrect = true,
    energymake = 3112,
    health = 28000,
    speed = 82,
    metalmake = 86,
    workertime = 6200,
    buildoptions = {
      'armanni',
      'armpb',
      'armamb',
      'armmoho',
      'armuwmme',
      'armflak',
      'armmercury',
      'armgate',
      'armsd',
      'armfort',
      'armtarg',
      'armarad',
      'armamd',
      'armveil',
      'armuwadvms',
      'armuwadves',
      'armmmkr',
      'armuwmmm',
      'armavp',
      'armaap',
      'armalab',
      'armfflak',
      'armatl',
      'armkraken',
      'armbrtha',
      'armannit3',
      'armlwall',
      'armgatet3',
	    'armannit4',
	    'armnanotct3',
    },
    weapondefs = {
      old_armsnipe_weapon = {
        areaofeffect = 72,
        avoidfeature = true,
        avoidfriendly = true,
        collidefeature = true,
        collidefriendly = false,
        corethickness = 0.75,
        craterareaofeffect = 0,
        craterboost = 0,
        commandfire = true,
        cratermult = 0,
        cegtag = 'railgun',
        duration = 0.12,
        edgeeffectiveness = 1,
        energypershot = 2000,
        explosiongenerator = 'custom:laserhit-large-blue',
        firestarter = 100,
        impulseboost = 0.4,
        impulsefactor = 1,
        intensity = 1.4,
        name = 'Long-range g2g armor-piercing rifle',
        range = 1250,
        reloadtime = 0.5,
        rgbcolor = '0.4 0.1 0.7',
        rgbcolor2 = '0.4 0.1 0.7',
        soundhit = 'sniperhit',
        soundhitwet = 'sizzle',
        soundstart = 'sniper3',
        soundtrigger = true,
        stockpile = true,
        stockpiletime = 2,
        customparams = {
          stockpilelimit = 15,
        },
        texture1 = 'shot',
        texture2 = 'empty',
        thickness = 6,
        tolerance = 1000,
        turret = true,
        weapontype = 'LaserCannon',
        weaponvelocity = 3000,
        damage = {
          commanders = 10,
          default = 45000,
        },
      },
      ata = {
        areaofeffect = 16,
        avoidfeature = false,
        beamtime = 1.25,
        collidefriendly = false,
        corethickness = 0.5,
        craterareaofeffect = 0,
        craterboost = 0,
        cratermult = 0,
        edgeeffectiveness = 0.30,
        energypershot = 7000,
        explosiongenerator = 'custom:laserhit-large-blue',
        firestarter = 90,
        impulsefactor = 0,
        largebeamlaser = true,
        laserflaresize = 7,
        name = 'Heavy tachyon beam',
        noselfdamage = true,
        range = 1100,
        reloadtime = 15,
        rgbcolor = '1 0 1',
        scrollspeed = 5,
        soundhitdry = '',
        soundhitwet = 'sizzle',
        soundstart = 'annigun1',
        soundtrigger = 1,
        texture3 = 'largebeam',
        thickness = 10,
        tilelength = 150,
        tolerance = 10000,
        turret = true,
        weapontype = 'BeamLaser',
        weaponvelocity = 3100,
        damage = {
          commanders = 480,
          default = 48000,
        },
      },
      armcomlaser = {
        areaofeffect = 12,
        avoidfeature = false,
        beamtime = 0.1,
        corethickness = 0.1,
        craterareaofeffect = 0,
        craterboost = 0,
        cratermult = 0,
        cylindertargeting = 1,
        edgeeffectiveness = 1,
        explosiongenerator = 'custom:laserhit-small-red',
        firestarter = 70,
        impactonly = 1,
        impulseboost = 0,
        impulsefactor = 0,
        laserflaresize = 7.7,
        name = 'Close-range laser',
        noselfdamage = true,
        range = 550,
        reloadtime = 0.5,
        rgbcolor = '0.659 0 1',
        soundhitdry = '',
        soundhitwet = 'sizzle',
        soundstart = 'lasrcrw2',
        soundtrigger = 1,
        targetmoveerror = 0.05,
        thickness = 6,
        tolerance = 10000,
        turret = true,
        weapontype = 'BeamLaser',
        weaponvelocity = 900,
        damage = {
          default = 1750,
          VTOL = 200,
        },
      },
    },
    weapons = {
      [1] = {
        def = 'armcomlaser',
        onlytargetcategory = 'NOTSUB',
        fastautoretargeting = true,
      },
      [3] = {
        def = 'old_armsnipe_weapon',
        onlytargetcategory = 'NOTSUB',
      },
      [4] = {
        badtargetcategory = 'VTOL GROUNDSCOUT',
        def = 'ATA',
        onlytargetcategory = 'SURFACE',
      },
      [5] = {
        def = '',
      },
      [6] = {
        def = '',
      },
    },
  },
}
    LoadUnits(armada_coms)
end
-- [Cortex Commanders]
do
    local cortex_coms = {
  corcom = {
    footprintx = 2,
    footprintz = 2,
    customparams = {
      evolution_target = 'corcomlvl2',
      evolution_condition = 'timer_global',
      evolution_timer = 420,
    },
    autoheal = 80,
    speed = 45,
    energymake = 75,
    metalmake = 6,
    health = 5500,
    buildoptions = {
      'corsolar',
      'coradvsol',
      'corwin',
      'cormstor',
      'corestor',
      'cormex',
      'corexp',
      'cormakr',
      'corlab',
      'corvp',
      'corap',
      'corhp',
      'coreyes',
      'corrad',
      'cordrag',
      'corllt',
      'corrl',
      'cordl',
      'corhllt',
      'corcan',
      'correap',
      'corlevlr',
      'corak',
      'cormaw',
      'corjamt',
      'cornecro',
      'cortide',
      'corsy',
      'corfhp',
      'coruwms',
      'coruwes',
      'coruwmex',
      'corfmkr',
      'corfdrag',
      'cortl',
      'corfrt',
      'corfrad',
      'corgeo',
      'coruwgeo',
    },
    weapondefs = {
      corcomlaser = {
        range = 370,
        damage = {
          bombers = 180,
          default = 260,
          fighters = 110,
          subs = 5,
        },
      },
      disintegrator = {
        energypershot = 1000,
        reloadtime = 8,
      },
    },
  },
  corcomlvl2 = {
    footprintx = 2,
    footprintz = 2,
    speed = 62,
    health = 8500,
    energymake = 315,
    metalmake = 30,
    autoheal = 300,
    builddistance = 200,
    workertime = 600,
    buildoptions = {
      'corsolar',
      'coradvsol',
      'corwin',
      'corgeo',
      'cormstor',
      'corestor',
      'cormex',
      'coruwmex',
      'corexp',
      'cormakr',
      'corcan',
      'correap',
      'corlab',
      'corvp',
      'corap',
      'corhp',
      'cornanotc',
      'coreyes',
      'corrad',
      'cordrag',
      'cormaw',
      'corllt',
      'corhllt',
      'corhlt',
      'corpun',
      'corrl',
      'cormadsam',
      'corerad',
      'cordl',
      'corjamt',
      'corjuno',
      'corsy',
      'coruwgeo',
      'corfasp',
      'cornerco',
      'coruwes',
      'corplat',
      'corfhp',
      'coruwms',
      'corfhlt',
      'cornanotct2',
      'corfmkr',
      'cortide',
      'corfrad',
      'corfrt',
      'corfdrag',
      'cortl',
      'cornecro',
    },
    customparams = {
      evolution_target = 'corcomlvl3',
      evolution_condition = 'timer_global',
      evolution_timer = 1320,
      shield_power = 500,
      shield_radius = 100,
    },
    weapondefs = {
      armcomlaser = {
        areaofeffect = 16,
        avoidfeature = false,
        beamtime = 0.1,
        corethickness = 0.1,
        craterareaofeffect = 0,
        craterboost = 0,
        cratermult = 0,
        cylindertargeting = 1,
        edgeeffectiveness = 1,
        explosiongenerator = 'custom:laserhit-small-red',
        firestarter = 70,
        impactonly = 1,
        impulseboost = 0,
        impulsefactor = 0,
        laserflaresize = 7.7,
        name = 'Light close-quarters g2g/g2a laser',
        noselfdamage = true,
        range = 500,
        reloadtime = 0.4,
        rgbcolor = '0.6 0.3 0.8',
        soundhitdry = '',
        soundhitwet = 'sizzle',
        soundstart = 'lasrfir1',
        soundtrigger = 1,
        targetmoveerror = 0.05,
        thickness = 4,
        tolerance = 10000,
        turret = true,
        weapontype = 'BeamLaser',
        weaponvelocity = 900,
        damage = {
          bombers = 180,
          default = 1500,
          fighters = 110,
          subs = 5,
        },
      },
      disintegrator = {
        areaofeffect = 36,
        avoidfeature = false,
        avoidfriendly = false,
        avoidground = false,
        bouncerebound = 0,
        cegtag = 'dgunprojectile',
        commandfire = true,
        craterboost = 0,
        cratermult = 0.15,
        edgeeffectiveness = 0.15,
        energypershot = 500,
        explosiongenerator = 'custom:expldgun',
        firestarter = 100,
        firesubmersed = false,
        groundbounce = true,
        impulseboost = 0,
        impulsefactor = 0,
        name = 'Disintegrator',
        noexplode = true,
        noselfdamage = true,
        range = 250,
        reloadtime = 6,
        paralyzer = {},
        soundhit = 'xplomas2s',
        soundhitwet = 'sizzlexs',
        soundstart = 'disigun1',
        soundhitvolume = 36,
        soundstartvolume = 96,
        soundtrigger = true,
        tolerance = 10000,
        turret = true,
        waterweapon = true,
        weapontimer = 4.2,
        weapontype = 'DGun',
        weaponvelocity = 300,
        damage = {
          commanders = 0,
          default = 20000,
          raptors = 10000,
        },
      },
    },
    weapons = {
      [1] = {
        def = 'armcomlaser',
        onlytargetcategory = 'NOTSUB',
        fastautoretargeting = true,
      },
      [3] = {
        def = 'DISINTEGRATOR',
        onlytargetcategory = 'NOTSUB',
      },
    },
  },
  corcomlvl3 = {
    footprintx = 2,
    footprintz = 2,
    speed = 88,
    health = 30000,
    energymake = 2180,
    metalmake = 49,
    autoheal = 1500,
    workertime = 1200,
    builddistance = 350,
    buildoptions = {
      'corfus',
      'corafus',
      'corageo',
      'corbhmth',
      'cormoho',
      'cormexp',
      'cormmkr',
      'coruwadves',
      'coruwadvms',
      'corarad',
      'corshroud',
      'corfort',
      'corlab',
      'cortarg',
      'corsd',
      'corgate',
      'cortoast',
      'corvipe',
      'cordoom',
      'corflak',
      'corscreamer',
      'corvp',
      'corfmd',
      'corap',
      'corint',
      'corplat',
      'corsy',
      'coruwmme',
      'coruwmmm',
      'corenaa',
      'corfdoom',
      'coratl',
      'coruwfus',
      'corjugg',
      'corshiva',
      'corsumo',
      'corgol',
      'corkorg',
      'cornanotc2plat',
      'cornanotct2',
      'cornecro',
      'cordoomt3',
      'corhllllt',
      'cormaw',
      'cormwall',
      'corgatet3',
      'legendary_bulwark',
      'cornanotct3',
    },
    customparams = {
      evolution_target = 'corcomlvl4',
      evolution_condition = 'timer_global',
      evolution_timer = 1740,
    },
    weapondefs = {
      corcomlaser = {
        areaofeffect = 12,
        avoidfeature = false,
        beamtime = 0.1,
        corethickness = 0.1,
        craterareaofeffect = 0,
        craterboost = 0,
        cratermult = 0,
        cylindertargeting = 1,
        edgeeffectiveness = 1,
        explosiongenerator = 'custom:laserhit-small-red',
        firestarter = 70,
        impactonly = 1,
        impulseboost = 0,
        impulsefactor = 0,
        laserflaresize = 5.5,
        name = 'J7Laser',
        noselfdamage = true,
        range = 900,
        reloadtime = 0.4,
        rgbcolor = '0.7 0 1',
        soundhitdry = '',
        soundhitwet = 'sizzle',
        soundstart = 'lasrfir1',
        soundtrigger = 1,
        targetmoveerror = 0.05,
        thickness = 3,
        tolerance = 10000,
        turret = true,
        weapontype = 'BeamLaser',
        weaponvelocity = 900,
        damage = {
          default = 2000,
          subs = 5,
        },
      },
      disintegrator = {
        areaofeffect = 36,
        avoidfeature = false,
        avoidfriendly = false,
        avoidground = false,
        bouncerebound = 0,
        cegtag = 'dgunprojectile',
        commandfire = true,
        craterboost = 0,
        cratermult = 0.15,
        edgeeffectiveness = 0.15,
        energypershot = 500,
        explosiongenerator = 'custom:expldgun',
        firestarter = 100,
        firesubmersed = false,
        groundbounce = true,
        impulseboost = 0,
        impulsefactor = 0,
        name = 'Disintegrator',
        noexplode = true,
        noselfdamage = true,
        range = 250,
        reloadtime = 3,
        paralyzer = {},
        soundhit = 'xplomas2s',
        soundhitwet = 'sizzlexs',
        soundstart = 'disigun1',
        soundhitvolume = 36,
        soundstartvolume = 96,
        soundtrigger = true,
        size = 4,
        tolerance = 10000,
        turret = true,
        waterweapon = true,
        weapontimer = 4.2,
        weapontype = 'DGun',
        weaponvelocity = 300,
        damage = {
          commanders = 0,
          default = 20000,
          scavboss = 1000,
          raptors = 10000,
        },
      },
    },
    weapons = {
      [1] = {
        def = 'CORCOMLASER',
        onlytargetcategory = 'NOTSUB',
        fastautoretargeting = true,
      },
      [5] = {
        def = '',
      },
    },
  },
  corcomlvl4 = {
    footprintx = 2,
    footprintz = 2,
    speed = 80,
    health = 50000,
    energymake = 2380,
    metalmake = 56,
    autoheal = 3550,
    workertime = 1800,
    builddistance = 500,
    buildoptions = {
      'corfus',
      'corafus',
      'corageo',
      'corbhmth',
      'cormoho',
      'cormexp',
      'cormmkr',
      'coruwadves',
      'coruwadvms',
      'corarad',
      'corshroud',
      'corfort',
      'corlab',
      'cortarg',
      'corsd',
      'corgate',
      'cortoast',
      'corvipe',
      'cordoom',
      'corflak',
      'corscreamer',
      'corvp',
      'corfmd',
      'corap',
      'corint',
      'corplat',
      'corsy',
      'coruwmme',
      'coruwmmm',
      'corenaa',
      'corfdoom',
      'coratl',
      'coruwfus',
      'corjugg',
      'corshiva',
      'corsumo',
      'corgol',
      'corkorg',
      'cornanotc2plat',
      'cornanotct2',
      'cornecro',
      'cordoomt3',
      'corhllllt',
      'cormaw',
      'cormwall',
      'corgatet3',
      'legendary_bulwark',
      'cornanotct3',
    },
    customparams = {
      shield_power = 500,
      shield_radius = 100,
    },
    weapondefs = {
      CORCOMLASER = {
        areaofeffect = 12,
        avoidfeature = false,
        beamtime = 0.1,
        corethickness = 0.1,
        craterareaofeffect = 0,
        craterboost = 0,
        cratermult = 0,
        cylindertargeting = 1,
        edgeeffectiveness = 1,
        explosiongenerator = 'custom:laserhit-small-red',
        firestarter = 70,
        impactonly = 1,
        impulseboost = 0,
        impulsefactor = 0,
        laserflaresize = 5.5,
        name = 'J7Laser',
        noselfdamage = true,
        range = 1000,
        reloadtime = 0.4,
        rgbcolor = '0.7 0 1',
        soundhitdry = '',
        soundhitwet = 'sizzle',
        soundstart = 'lasrfir1',
        soundtrigger = 1,
        targetmoveerror = 0.05,
        thickness = 3,
        tolerance = 10000,
        turret = true,
        weapontype = 'BeamLaser',
        weaponvelocity = 900,
        damage = {
          default = 2500,
          subs = 5,
        },
      },
      disintegratorxl = {
        areaofeffect = 105,
        avoidfeature = false,
        avoidfriendly = true,
        avoidground = false,
        burst = 1,
        burstrate = 0,
        bouncerebound = 0,
        cegtag = 'gausscannonprojectilexl',
        craterareaofeffect = 0,
        craterboost = 0,
        cratermult = 0,
        commandfire = true,
        cameraShake = 0,
        edgeeffectiveness = 1,
        energypershot = 0,
        explosiongenerator = 'custom:burnblackbiggest',
        firestarter = 100,
        firesubmersed = false,
        gravityaffected = true,
        impulsefactor = 0,
        intensity = 4,
        name = 'Darkmatter Photon-Disruptor',
        noexplode = true,
        noselfdamage = true,
        range = 500,
        reloadtime = 1,
        rgbcolor = '0.7 0.3 1.0',
        size = 5.5,
        soundhit = 'xplomas2',
        soundhitwet = 'sizzlexs',
        soundstart = 'disigun1',
        soundtrigger = true,
        tolerance = 10000,
        turret = true,
        weapontype = 'DGun',
        weaponvelocity = 505,
        damage = {
          commanders = 0,
          default = 20000,
          scavboss = 1000,
          raptors = 10000,
        },
      },
      corcomeyelaser = {
        allowNonBlockingAim = true,
        avoidfriendly = true,
        areaofeffect = 6,
        avoidfeature = false,
        beamtime = 0.033,
        camerashake = 0.1,
        collidefriendly = false,
        corethickness = 0.35,
        craterareaofeffect = 12,
        craterboost = 0,
        cratermult = 0,
        edgeeffectiveness = 1,
        energypershot = 0,
        explosiongenerator = 'custom:laserhit-small-red',
        firestarter = 90,
        firetolerance = 300,
        impulsefactor = 0,
        laserflaresize = 2,
        name = 'EyeLaser',
        noselfdamage = true,
        proximitypriority = 1,
        range = 870,
        reloadtime = 0.033,
        rgbcolor = '0 1 0',
        rgbcolor2 = '0.8 0 0',
        scrollspeed = 5,
        soundhitdry = 'flamhit1',
        soundhitwet = 'sizzle',
        soundstart = 'heatray3burn',
        soundstartvolume = 6,
        soundtrigger = 1,
        thickness = 2.5,
        turret = true,
        weapontype = 'BeamLaser',
        weaponvelocity = 1500,
        damage = {
          default = 185,
        },
      },
    },
    weapons = {
      [1] = {
        def = 'CORCOMLASER',
        onlytargetcategory = 'NOTSUB',
        fastautoretargeting = true,
      },
      [3] = {
        badtargetcategory = 'VTOL',
        def = 'disintegratorxl',
        onlytargetcategory = 'SURFACE',
      },
      [6] = {
        def = '',
      },
      [5] = {
        badtargetcategory = 'VTOL GROUNDSCOUT',
        def = 'corcomeyelaser',
        onlytargetcategory = 'SURFACE',
      },
    },
  },
}
    LoadUnits(cortex_coms)
end
-- [Legion Commanders]
do
    local legion_coms = {
  legcom = {
    footprintx = 2,
    footprintz = 2,
    canresurrect = true,
    energymake = 50,
    metalmake = 5,
    health = 6000,
    autoheal = 40,
    buildoptions = {
      'legsolar',
      'legwin',
      'legmstor',
      'legestor',
      'legmex',
      'legeconv',
      'legnanotc',
      'legrezbot',
      'leglab',
      'legvp',
      'legap',
      'legdtl',
      'legdtf',
      'legdtr',
      'legjam',

    },
    customparams = {
      evolution_target = 'legcomlvl2',
      evolution_condition = 'timer_global',
      evolution_timer = 420,
    },
    weapondefs = {
      legcomlaser = {
        corethickness = 0.25,
        duration = 0.09,
        name = 'Light close-quarters g2g/g2a laser',
        range = 360,
        reloadtime = 0.20,
        rgbcolor = '0 2 1',
        soundhitdry = '',
        soundhitwet = 'sizzle',
        soundstart = 'lasrcrw1',
        soundtrigger = true,
        sprayangle = 700,
        thickness = 6,
        texture1 = 'shot',
        texture2 = 'empty',
        weapontype = 'LaserCannon',
        weaponvelocity = 2100,
        damage = {
          default = 250,
        },
      },
      shotgun = {
        areaofeffect = 60,
        energypershot = 0,
        avoidfeature = false,
        craterboost = 0,
        cratermult = 0,
        cameraShake = 0,
        edgeeffectiveness = 0.65,
        explosiongenerator = 'custom:genericshellexplosion-small',
        impulseboost = 0.2,
        impulsefactor = 0.2,
        intensity = 3,
        name = '6 Gauge Shotgun',
        noselfdamage = true,
        predictboost = 1,
        projectiles = 6,
        range = 320,
        reloadtime = 2,
        rgbcolor = '1 0.75 0.25',
        size = 2,
        soundhit = 'xplomed2xs',
        soundhitwet = 'splsmed',
        soundstart = 'kroggie2xs',
        soundstartvolume = 12,
        sprayangle = 2000,
        turret = true,
        commandfire = true,
        weapontimer = 1,
        weapontype = 'Cannon',
        weaponvelocity = 600,
        stockpile = true,
        stockpiletime = 5,
        customparams = {
          stockpilelimit = 10,
        },
        damage = {
          default = 1800,
          commanders = 0,
        },
      },
    },
    weapons = {
      [3] = {
        def = 'shotgun',
        onlytargetcategory = 'SURFACE',
      },
    },
  },
  legcomlvl2 = {
    footprintx = 2,
    footprintz = 2,
    canresurrect = true,
    energymake = 400,
    metalmake = 20,
    speed = 62,
    autoheal = 200,
    builddistance = 200,
    workertime = 800,
    health = 12000,
    customparams = {
      evolution_target = 'legcomlvl3',
      evolution_condition = 'timer_global',
      evolution_timer = 1320,
    },
    buildoptions = {
      'legsolar',
      'legadvsol',
      'legwin',
      'legmstor',
      'legestor',
      'legmex',
      'legeconv',
      'legrezbot',
      'leglab',
      'legvp',
      'legap',
      'corhllt',
      'leggeo',
      'legnanotct2',
      'legjam',
      'legdtf',
      'legmg',
      'legrad',
      'legdtl',
      'legdtr',
      'legrhapsis',
    },
    weapondefs = {
      legcomlaser = {
        accuracy = 50,
        areaofeffect = 12,
        avoidfriendly = false,
        avoidfeature = false,
        collidefriendly = false,
        collidefeature = true,
        beamtime = 0.09,
        corethickness = 0.3,
        duration = 0.09,
        explosiongenerator = 'custom:laserhit-small-red',
        firestarter = 70,
        impactonly = 1,
        impulseboost = 0,
        impulsefactor = 0,
        name = 'Light close-quarters g2g/g2a laser',
        noselfdamage = true,
        range = 500,
        reloadtime = 0.2,
        rgbcolor = '0 0.95 0.05',
        soundhitdry = '',
        soundhitwet = 'sizzle',
        soundstart = 'lasrcrw1',
        soundtrigger = true,
        sprayangle = 500,
        targetmoveerror = 0.05,
        thickness = 7,
        tolerance = 1000,
        texture1 = 'shot',
        texture2 = 'empty',
        turret = true,
        weapontype = 'LaserCannon',
        weaponvelocity = 2200,
        damage = {
          bombers = 180,
          default = 450,
          fighters = 110,
          subs = 5,
        },
      },
      shotgun = {
        areaofeffect = 65,
        energypershot = 0,
        avoidfeature = false,
        craterboost = 0,
        cratermult = 0,
        cameraShake = 0,
        edgeeffectiveness = 0.65,
        explosiongenerator = 'custom:genericshellexplosion-small',
        impulseboost = 0.2,
        impulsefactor = 0.2,
        intensity = 3,
        name = '12 Gauge Shotgun',
        noselfdamage = true,
        predictboost = 1,
        projectiles = 7,
        range = 440,
        reloadtime = 2,
        rgbcolor = '1 0.75 0.25',
        size = 2.5,
        soundhit = 'xplomed2xs',
        soundhitwet = 'splsmed',
        soundstart = 'kroggie2xs',
        soundstartvolume = 12,
        sprayangle = 2250,
        turret = true,
        commandfire = true,
        weapontimer = 1,
        weapontype = 'Cannon',
        weaponvelocity = 600,
        stockpile = true,
        stockpiletime = 5,
        customparams = {
          stockpilelimit = 15,
        },
        damage = {
          default = 2200,
          commanders = 0,
        },
      },
    },
    weapons = {
      [1] = {
        def = 'legcomlaser',
        onlytargetcategory = 'NOTSUB',
        fastautoretargeting = true,
      },
      [3] = {
        def = 'shotgun',
        onlytargetcategory = 'SURFACE',
      },
    },
  },
  legcomlvl3 = {
    footprintx = 2,
    footprintz = 2,
    canresurrect = true,
    energymake = 1500,
    metalmake = 45,
    speed = 85,
    builddistance = 350,
    workertime = 1200,
    autoheal = 900,
    health = 26000,
    customparams = {
      evolution_target = 'legcomlvl4',
      evolution_condition = 'timer_global',
      evolution_timer = 1740,
    },
    buildoptions = {
      'legdeflector',
      'legfus',
      'legbombard',
      'legadvestore',
      'legmoho',
      'legadveconv',
      'legarad',
      'legajam',
      'legforti',
      'legacluster',
      'legamstor',
      'legflak',
      'legabm',
      'legbastion',
      'legdtr',
      'legdtf',
      'legrezbot',
      'legdtl',
      'leglab',
      'legvp',
      'legap',
      'legbastiont4',
      'legnanotct2',
      'legnanotct3',
      'legapopupdef',
    },
    weapondefs = {
      legcomlaser = {
        accuracy = 50,
        areaofeffect = 12,
        avoidfriendly = true,
        avoidfeature = true,
        collidefriendly = false,
        collidefeature = true,
        beamtime = 0.09,
        corethickness = 0.55,
        duration = 0.09,
        explosiongenerator = 'custom:laserhit-small-red',
        firestarter = 70,
        impactonly = 0,
        impulseboost = 0,
        impulsefactor = 0,
        name = 'Light close-quarters g2g/g2a laser',
        noselfdamage = true,
        range = 640,
        reloadtime = 0.2,
        rgbcolor = '0 0.2 0.8',
        soundhitdry = '',
        soundhitwet = 'sizzle',
        soundstart = 'lasrcrw1',
        soundtrigger = true,
        sprayangle = 500,
        targetmoveerror = 0.05,
        thickness = 7,
        tolerance = 1000,
        texture1 = 'shot',
        texture2 = 'empty',
        turret = true,
        weapontype = 'LaserCannon',
        weaponvelocity = 2500,
        damage = {
          bombers = 180,
          default = 650,
          fighters = 110,
          subs = 5,
        },
      },
      shotgun = {
        areaofeffect = 90,
        energypershot = 0,
        avoidfeature = false,
        craterboost = 0,
        cratermult = 0,
        cameraShake = 0,
        edgeeffectiveness = 0.65,
        explosiongenerator = 'custom:genericshellexplosion-small',
        impulseboost = 0.2,
        impulsefactor = 0.2,
        intensity = 3,
        name = '12 Gauge Shotgun',
        noselfdamage = true,
        predictboost = 1,
        projectiles = 7,
        range = 540,
        reloadtime = 2,
        rgbcolor = '1 0.75 0.25',
        size = 2.5,
        soundhit = 'xplomed2xs',
        soundhitwet = 'splsmed',
        soundstart = 'kroggie2xs',
        soundstartvolume = 12,
        sprayangle = 2500,
        turret = true,
        commandfire = true,
        weapontimer = 1,
        weapontype = 'Cannon',
        weaponvelocity = 600,
        stockpile = true,
        stockpiletime = 5,
        customparams = {
          stockpilelimit = 20,
        },
        damage = {
          default = 3200,
          commanders = 0,
        },
      },
    },
    weapons = {
      [1] = {
        def = 'legcomlaser',
        onlytargetcategory = 'NOTSUB',
        fastautoretargeting = true,
      },
      [3] = {
        def = 'shotgun',
        onlytargetcategory = 'SURFACE',
      },
      [5] = {
        def = '',
      },
    },
  },
  legcomlvl4 = {
    footprintx = 2,
    footprintz = 2,
    canresurrect = true,
    energymake = 2280,
    metalmake = 64,
    speed = 100,
    builddistance = 500,
    workertime = 1700,
    autoheal = 4500,
    health = 53900,
    buildoptions = {
      'legdeflector',
      'legbombard',
      'legadvestore',
      'legmoho',
      'legadveconv',
      'legarad',
      'legajam',
      'legkeres',
      'legacluster',
      'legamstor',
      'legflak',
      'legabm',
      'legbastion',
      'legbastiont4',
      'legnanotct2',
      'legrwall',
      'leglab',
      'legvp',
      'legap',
      'legtarg',
      'legsd',
      'leglraa',
      'legdtl',
      'legdtf',
      'legministarfall',
      'legstarfall',
      'leggatet3',
      'legperdition',
      'legsilo',
      'legnanotct3',

    },
    weapondefs = {
      machinegun = {
        accuracy = 80,
        areaofeffect = 10,
        avoidfeature = false,
        beamburst = true,
        beamdecay = 1,
        beamtime = 0.07,
        burst = 6,
        burstrate = 0.10667,
        camerashake = 0,
        corethickness = 0.35,
        craterareaofeffect = 0,
        craterboost = 0,
        cratermult = 0,
        edgeeffectiveness = 1,
        explosiongenerator = "custom:laserhit-medium-red",
        firestarter = 10,
        impulsefactor = 0,
        largebeamlaser = true,
        laserflaresize = 30,
        name = "Rapid-fire close quarters g2g armor-piercing laser",
        noselfdamage = true,
        pulsespeed = "q8",
        range = 1100,
        reloadtime = 0.50,
        rgbcolor = "0.7 0.3 1.0",
        rgbcolor2 = "0.8 0.6 1.0",
        soundhitdry = "",
        soundhitwet = "sizzle",
        soundstart = "lasfirerc",
        soundtrigger = 1,
        sprayangle = 500,
        targetborder = 0.2,
        thickness = 5.5,
        tolerance = 4500,
        turret = true,
        weapontype = "BeamLaser",
        weaponvelocity = 920,
        damage = {
          default = 1300,
          vtol = 180,
        },
      },
      shotgunarm = {
        areaofeffect = 112,
        commandfire = true,
        avoidfeature = false,
        craterboost = 0,
        cratermult = 0,
        cameraShake = 0,
        edgeeffectiveness = 0.65,
        explosiongenerator = "custom:genericshellexplosion-medium",
        impulsefactor = 0.8,
        intensity = 0.2,
        mygravity = 1,
        name = "GaussCannon",
        noselfdamage = true,
        predictboost = 1,
        projectiles = 20,
        range = 650,
        reloadtime = 1,
        rgbcolor = "0.8 0.4 1.0",
        size = 4,
        sizeDecay = 0.044,
        stages = 16,
        alphaDecay = 0.66,
        soundhit = "xplomed2xs",
        soundhitwet = "splsmed",
        soundstart = "kroggie2xs",
        sprayangle = 3500,
        tolerance = 6000,
        turret = true,
        waterweapon = true,
        weapontimer = 2,
        weapontype = "Cannon",
        weaponvelocity = 900,
        stockpile = true,
        stockpiletime = 2,
        customparams = {
          stockpilelimit = 50,
        },
        damage = {
          default = 10000,
          commanders = 0,
        },
      },
      exp_heavyrocket = {
        areaofeffect = 70,
        collidefriendly = 0,
        collidefeature = 0,
        cameraShake = 0,
        energypershot = 125,
        avoidfeature = 0,
        avoidfriendly = 0,
        burst = 4,
        burstrate = 0.3,
        cegtag = "missiletrailsmall-red",
        colormap = '0.75 0.73 0.67 0.024   0.37 0.4 0.30 0.021   0.22 0.21 0.14 0.018  0.024 0.014 0.009 0.03   0.0 0.0 0.0 0.008',
        craterboost = 0,
        craterareaofeffect = 0,
        cratermult = 0,
        dance = 24,
        edgeeffectiveness = 0.65,
        explosiongenerator = "custom:burnblack",
        firestarter = 70,
        flighttime = 1.05,
        flamegfxtime = 1,
        impulsefactor = 0.123,
        impactonly = 1,
        model = "catapultmissile.s3o",
        movingaccuracy = 600,
        name = "Raptor Boomer",
        noselfdamage = true,
        proximitypriority = nil,
        range = 700,
        reloadtime = 1,
        smoketrail = true,
        smokePeriod = 4,
        smoketime = 16,
        smokesize = 8.5,
        smokecolor = 0.5,
        size = 2,
        smokeTrailCastShadow = false,
        soundhit = "rockhit",
        soundhitwet = "splsmed",
        soundstart = "rapidrocket3",
        startvelocity = 165,
        rgbcolor = '1 0.25 0.1',
        texture1 = "null",
        texture2 = "smoketrailbar",
        trajectoryheight = 1,
        targetmoveerror = 0.2,
        turnrate = 5000,
        tracks = true,
        turret = true,
        allowNonBlockingAim = true,
        weaponacceleration = 660,
        weapontimer = 6,
        weapontype = "MissileLauncher",
        weaponvelocity = 950,
        wobble = 2000,
        damage = {
          default = 1300,
        },
        customparams = {
          exclude_preaim = true,
          overrange_distance = 777,
          projectile_destruction_method = "descend",
        },
      },
    },
    weapons = {
      [1] = {
        def = 'machinegun',
        onlytargetcategory = 'NOTSUB',
        fastautoretargeting = true,
      },
      [3] = {
        def = 'shotgunarm',
        onlytargetcategory = 'WEAPON',
      },
      [5] = {
        def = 'exp_heavyrocket',
        onlytargetcategory = 'SURFACE',
      },
    },
  },
}
    LoadUnits(legion_coms)
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

-- Cross Faction T2 Data
local taxMultiplier = 1.7
local tierTwoFactories = {}
local taxedDefs = {}
local labelSuffix = ' (Taxed)'
-- NOTE: We assume VFS.LoadFile works or we skip language.
-- For safety, we default to unitName if language fails.
local language
if VFS and VFS.LoadFile and Json and Json.decode then
    pcall(function() language = Json.decode(VFS.LoadFile('language/en/units.json')) end)
end

local function ApplyTweaks(name, def)
    -- 1. Defs_Main: Raptor Fighters
    if string_sub(name, 1, 24) == 'raptor_air_fighter_basic' then
        if def.weapondefs then
            for _, k in pairs(def.weapondefs) do
                k.name='Spike'; k.accuracy=200; k.collidefriendly=0; k.collidefeature=0; k.avoidfeature=0; k.avoidfriendly=0; k.areaofeffect=64; k.edgeeffectiveness=0.3; k.explosiongenerator='custom:raptorspike-large-sparks-burn'; k.reloadtime=1.1; k.soundstart='talonattack'; k.startvelocity=200; k.submissile=1; k.turnrate=60000; k.weaponacceleration=100; k.weapontimer=1; k.weaponvelocity=1000;
            end
        end
    -- 2. Defs_Main: Commander Logic
    elseif string_match(name, '^[acl][ore][rgm]com') and not string_match(name, '_scav$') then
        table_mergeInPlace(def, {
            customparams={combatradius=0, fall_damage_multiplier=0, paratrooper=true},
            featuredefs={dead={damage=9999999, reclaimable=false, mass=9999999}}
        })
    end

    -- 3. Defs_Main: Turrets
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

    -- 4. Defs_Main: Builders
    if def.builder == true then
        if def.canfly == true then
            def.explodeas=''
            def.selfdestructas=''
        end
    end

    -- 5. Defs_Main: Bombers
    if bombers_set[name] then
        if def.weapondefs then
            for _, u in pairs(def.weapondefs) do
                u.damage.default = u.damage.default/1.30
            end
        end
    end

    -- 6. Defs_Main: Respawners
    if respawn_set[name] then
        def.cantbetransported, def.footprintx, def.footprintz = false, 4, 4
        def.customparams = def.customparams or {}
        def.customparams.paratrooper = true
        def.customparams.fall_damage_multiplier = 0
    end

    -- 7. Defs_Cross_Faction_T2: Identify Factories
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

    -- 8. Units_EVO_XP.lua
    if string_match(name, 'comlvl%d') or string_match(name, 'armcom') or string_match(name, 'corcom') or string_match(name, 'legcom') then
        def.customparams = def.customparams or {}
        def.customparams.inheritxpratemultiplier = 0.5
        def.customparams.childreninheritxp = 'TURRET MOBILEBUILT'
        def.customparams.parentsinheritxp = 'TURRET MOBILEBUILT'
    end

    -- 9. Units_LRPC_v2.lua (Direct Modifications)
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

    -- 10. T4 Defenses & Air
    if name == 'legfortt4' then
         -- Logic from Defs_T4_Air.lua merged here if needed, but phase 2 covered creation.
         -- If overrides needed, do here.
    end
    if name == 'armannit4' or name == 'legbastiont4' or name == 'cordoomt4' then
         -- T4 Defense logic already applied in Phase 2 via create/merge.
    end
end

-- Execute Master Loop
for name, def in pairs(UnitDefs) do
    ApplyTweaks(name, def)
end

-- ==========================================================================================
-- PHASE 4: POST-LOOP UPDATES (Dependencies)
-- ==========================================================================================

-- Defs_Cross_Faction_T2: Merge Taxed Units
table_mergeInPlace(UnitDefs, taxedDefs)

-- Defs_Cross_Faction_T2: Update Builder Options (Now that taxed units exist)
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

-- Defs_T3_Eco.lua: Update Eco Options
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

-- Defs_Main: Hive Spawns Weapon Updates (The loop over 'l' list in original)
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

-- Defs_Main: Hive Stats Integration (The final block in Defs_Main)
do
    local N = UnitDefs["raptor_land_swarmer_basic_t1_v1"] and UnitDefs["raptor_land_swarmer_basic_t1_v1"].health or 1000
    local O = {texture1={},texture2={},tracks=false,weaponvelocity=4000,smokePeriod={},smoketime={},smokesize={},smokecolor={},smoketrail=0}
    local P = {accuracy=2048,areaofeffect=256,burst=4,burstrate=0.4,flighttime=12,dance=25,craterareaofeffect=256,edgeeffectiveness=0.7,cegtag="blob_trail_blue",explosiongenerator="custom:genericshellexplosion-huge-bomb",impulsefactor=0.4,intensity=0.3,interceptedbyshieldtype=1,range=2300,reloadtime=10,rgbcolor="0.2 0.5 0.9",size=8,sizedecay=0.09,soundhit="bombsmed2",soundstart="bugarty",sprayangle=2048,tolerance=60000,turnrate=6000,trajectoryheight=2,turret=true,weapontype="Cannon",weaponvelocity=520,startvelocity=140,weaponacceleration=125,weapontimer=0.2,wobble=14500,highTrajectory=1,damage={default=900,shields=600}}
    local Q = {accuracy=1024,areaofeffect=24,burst=1,burstrate=0.3,cegtag="blob_trail_green",edgeeffectiveness=0.63,explosiongenerator="custom:raptorspike-small-sparks-burn",impulsefactor=1,intensity=0.4,interceptedbyshieldtype=1,name="Acid",range=250,reloadtime=1,rgbcolor="0.8 0.99 0.11",size=1,stages=6,soundhit="bloodsplash3",soundstart="alien_bombrel",sprayangle=128,tolerance=5000,turret=true,weapontimer=0.1,weapontype="Cannon",weaponvelocity=320,damage={default=80}}
    local R = {
        raptor_hive_swarmer_basic={metalcost=350,nochasecategory="OBJECT",icontype="raptor_land_swarmer_basic_t1_v1"},
        raptor_hive_assault_basic={metalcost=3000,health=25000,speed=20.0,nochasecategory="OBJECT",icontype="raptor_land_assault_basic_t2_v1",weapondefs={aaweapon=O}},
        raptor_hive_assault_heavy={metalcost=6000,health=30000,speed=17.0,nochasecategory="OBJECT",icontype="raptor_land_assault_basic_t4_v1",weapondefs={aaweapon=O}},
        raptor_hive_assault_superheavy={metalcost=9000,health=35000,speed=16.0,nochasecategory="OBJECT",icontype="raptor_land_assault_basic_t4_v2",weapondefs={aaweapon=O}},
        raptor_evolved_motort4={icontype="raptor_allterrain_arty_basic_t4_v1",weapondefs={poopoo=P},weapons={[1]={badtargetcategory="MOBILE",def="poopoo",maindir="0 0 1",maxangledif=50,onlytargetcategory="NOTAIR"}}},
        raptor_land_swarmer_acids_t2_v1={metalcost=375,energycost=600,health=N*2,icontype="raptor_land_swarmer_basic_t1_v1",buildpic="raptors/raptorh1b.DDS",objectname="Raptors/raptor_droneb.s3o",weapondefs={throwup=Q},weapons={[1]={def="throwup",onlytargetcategory="NOTAIR",maindir="0 0 1",maxangledif=180}}}
    }
    for i, S in pairs(R) do
        if UnitDefs[i] then table_mergeInPlace(UnitDefs[i], S) end
    end
end

-- Post-Hook Logic (UnitDef_Post)
if UnitDef_Post then
    -- If a global hook exists, we might normally wrap it.
    -- But since we are generating a single Unified file that REPLACES the others,
    -- we can just define the logic here if needed, or rely on StaticTweaks.lua to handle its part.
    -- Defs_Main had a UnitDef_Post hook, but it seems to have been inline logic.
    -- We've integrated that logic above.
end
