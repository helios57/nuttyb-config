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

-- Tweak: Defs_Cross_Faction_T2.lua
-- Cross Faction T2
-- Decoded from tweakdata.txt line 4

--Cross Faction Tax 70%
-- Authors: TetrisCo
-- docs.google.com/spreadsheets/d/1QSVsuAAMhBrhiZdTihVfSCwPzbbZWDLCtXWP23CU0ko
-- CROSS_FACTION_START
do
local unitDefs,taxMultiplier,tierTwoFactories,taxedDefs,language,suffix,labelSuffix=UnitDefs or{},1.7,{}, {},Json.decode(VFS.LoadFile('language/en/units.json')),'_taxed',' (Taxed)'

local function ensureBuildOption(builderName, optionName, optionSource)
	local builder = unitDefs[builderName]
	local optionDef = optionSource and optionSource[optionName] or unitDefs[optionName]
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

for unitName,def in pairs(unitDefs)do
	if def.customparams and def.customparams.subfolder and(def.customparams.subfolder:match'Fact'or def.customparams.subfolder:match'Lab')and def.customparams.techlevel==2 then
		local humanName=language and language.units.names[unitName]or unitName
		tierTwoFactories[unitName]=true
		taxedDefs[unitName..suffix]=table.merge(def,{
			energycost=def.energycost*taxMultiplier,
			icontype=unitName,
			metalcost=def.metalcost*taxMultiplier,
			name=humanName..labelSuffix,
			customparams={
				i18n_en_humanname=humanName..labelSuffix,
				i18n_en_tooltip=language and language.units.descriptions[unitName]or unitName
			}
		})
	end
end

for builderName,builder in pairs(unitDefs)do
	if builder.buildoptions then
		for _,optionName in pairs(builder.buildoptions)do
			if tierTwoFactories[optionName] then
				for _,factionPrefix in pairs{'arm','cor','leg'}do
					local taxedName=factionPrefix..optionName:sub(4)..suffix
					if optionName:sub(1,3)~=factionPrefix and taxedDefs[taxedName] then
						ensureBuildOption(builderName,taxedName,taxedDefs)
					end
				end
			end
		end
	end
end

table.mergeInPlace(unitDefs,taxedDefs)
end
-- CROSS_FACTION_END


-- Tweak: Defs_Main.lua
-- Main tweakdefs
-- Decoded from tweakdata.txt line 1

--NuttyB v1.52b Def Main
-- Authors: ChrispyNut, BackBash
-- docs.google.com/spreadsheets/d/1QSVsuAAMhBrhiZdTihVfSCwPzbbZWDLCtXWP23CU0ko
-- MAIN_DEFS_START
local a, pairs, c = UnitDefs or {}, pairs, table.merge;

for i,j in pairs(a)do
    if string.sub(i,1,24)=='raptor_air_fighter_basic'then
        if j.weapondefs then
            for g,k in pairs(j.weapondefs)do
                k.name='Spike'
                k.accuracy=200;
                k.collidefriendly=0;
                k.collidefeature=0;
                k.avoidfeature=0;
                k.avoidfriendly=0;
                k.areaofeffect=64;
                k.edgeeffectiveness=0.3;
                k.explosiongenerator='custom:raptorspike-large-sparks-burn'
                k.cameraShake= {}
                k.dance= {}
                k.interceptedbyshieldtype=0;
                k.model='Raptors/spike.s3o'
                k.reloadtime=1.1;
                k.soundstart='talonattack'
                k.startvelocity=200;
                k.submissile=1;
                k.smoketrail=0;
                k.smokePeriod= {}
                k.smoketime= {}
                k.smokesize= {}
                k.smokecolor= {}
                k.soundhit= {}
                k.texture1= {}
                k.texture2= {}
                k.tolerance= {}
                k.tracks=0;
                k.turnrate=60000;
                k.weaponacceleration=100;
                k.weapontimer=1;
                k.weaponvelocity=1000;
                k.weapontype= {}
                k.wobble= {}
            end
        end
    else
    if i:match'^[acl][ore][rgm]com'and not i:match'_scav$'then
        table.mergeInPlace(j, {
            customparams= {
                combatradius=0,
                fall_damage_multiplier=0,
                paratrooper=true,
                wtboostunittype= {}
            },
            featuredefs= {
                dead= {
                    damage=9999999,
                    reclaimable=false,
                    mass=9999999
                }
            }
        })
    end
    end
end
local l= {
    raptor_air_kamikaze_basic_t2_v1= {
        selfdestructas='raptor_empdeath_big'
    },
    raptor_land_swarmer_emp_t2_v1= {
        weapondefs= {
            raptorparalyzersmall= {
                damage= {
                    shields=70
                },
                paralyzetime=6
            }
        }
    },
    raptor_land_assault_emp_t2_v1= {
        weapondefs= {
            raptorparalyzerbig= {
                damage= {
                    shields=150
                },
                paralyzetime=10
            }
        }
    },
    raptor_allterrain_arty_emp_t2_v1= {
        weapondefs= {
            goolauncher= {
                paralyzetime=6
            }
        }
    },
    raptor_allterrain_arty_emp_t4_v1= {
        weapondefs= {
            goolauncher= {
                paralyzetime=10
            }
        }
    },
    raptor_air_bomber_emp_t2_v1= {
        weapondefs= {
            weapon= {
                damage= {
                    shields=1100,
                    default=2000
                },
                paralyzetime=10
            }
        }
    },
    raptor_allterrain_swarmer_emp_t2_v1= {
        weapondefs= {
            raptorparalyzersmall= {
                damage= {
                    shields=70
                },
                paralyzetime=6
            }
        }
    },
    raptor_allterrain_assault_emp_t2_v1= {
        weapondefs= {
            raptorparalyzerbig= {
                damage= {
                    shields=150
                },
                paralyzetime=6
            }
        }
    },
    raptor_matriarch_electric= {
        weapondefs= {
            goo= {
                paralyzetime=13
            },
            melee= {
                paralyzetime=13
            },
            spike_emp_blob= {
                paralyzetime=13
            }
        }
    }
}
for m,n in pairs(l)do
    if a[m]then
        a[m]=c(
        a[m],n)
    end
end
for g,o in pairs({'raptor_antinuke','raptor_turret_acid_t2_v1','raptor_turret_acid_t3_v1','raptor_turret_acid_t4_v1','raptor_turret_antiair_t2_v1','raptor_turret_antiair_t3_v1','raptor_turret_antiair_t4_v1','raptor_turret_antinuke_t2_v1','raptor_turret_antinuke_t3_v1','raptor_turret_basic_t2_v1','raptor_turret_basic_t3_v1','raptor_turret_basic_t4_v1','raptor_turret_burrow_t2_v1','raptor_turret_emp_t2_v1','raptor_turret_emp_t3_v1','raptor_turret_emp_t4_v1','raptor_worm_green'
})do
    local p=a[o]
    if p then
        p.maxthisunit=10;
        p.health=p.health*2;
        if p.weapondefs then
            for g,q in pairs(p.weapondefs)do
                q.reloadtime=q.reloadtime/1.5;
                q.range=q.range/2
            end
        end
    end
end
for g,r in pairs(a)do
    if r.builder==true then
        if r.canfly==true then
            r.explodeas=''
            r.selfdestructas=''
        end
    end
end
local s= {'raptor_air_bomber_basic_t2_v1','raptor_air_bomber_basic_t2_v2','raptor_air_bomber_basic_t4_v1','raptor_air_bomber_basic_t4_v2','raptor_air_bomber_basic_t1_v1'
}
for g,t in pairs(s)do
    local j=a[t]
    if j then
        if j.weapondefs then
            for g,u in pairs(j.weapondefs)do
                u.damage.default=u.damage.default/1.30
            end
        end
    end
end
local v= {'armrespawn','correspawn','legnanotcbase'
}
for g,i in ipairs(v)do
    local w=UnitDefs[i]
    if w then
        w.cantbetransported,w.footprintx,w.footprintz=false,4,4;
        w.customparams=w.customparams or {}
        w.customparams.paratrooper=true;
        w.customparams.fall_damage_multiplier=0
    end
end
local UnitDefs=UnitDefs or {}
local
function x(y)
    local z= {}
    for A,B in pairs(y)do
        z[A]=type(B)=="table"and x(B)or B
    end
    return z
end
local
function C(D,k)
    for A,B in pairs(k)do
        if type(B)=="table"then
            D[A]=D[A]or {}
            C(
            D[A],B)
        else
        if D[A]==nil then
            D[A]=B
        end
    end
end
local
function E(F,G,H)
    if UnitDefs[F]and not UnitDefs[G]then
        local z=x(UnitDefs[F])
        C(z,H)
        UnitDefs[G]=z
    end
end
local I= {
    {"raptor_land_swarmer_basic_t1_v1","raptor_hive_swarmer_basic", {
            name="Hive Spawn",
            customparams= {
                i18n_en_humanname="Hive Spawn",i18n_en_tooltip="Raptor spawned to defend hives from attackers."
            }
        }
        }, {"raptor_land_assault_basic_t2_v1","raptor_hive_assault_basic", {
            name="Armored Assault Raptor",
            customparams= {
                i18n_en_humanname="Armored Assault Raptor",i18n_en_tooltip="Heavy, slow, and unyielding—these beasts are made to take the hits others cant."
            }
        }
        }, {"raptor_land_assault_basic_t4_v1","raptor_hive_assault_heavy", {
            name="Heavy Armored Assault Raptor",
            customparams= {
                i18n_en_humanname="Heavy Armored Assault Raptor",i18n_en_tooltip="Lacking speed, these armored monsters make up for it with raw, unbreakable toughness."
                }
            }
            }, {"raptor_land_assault_basic_t4_v2","raptor_hive_assault_superheavy", {
                name="Super Heavy Armored Assault Raptor",
                customparams= {
                    i18n_en_humanname="Super Heavy Armored Assault Raptor",i18n_en_tooltip="These super-heavy armored beasts may be slow, but they're built to take a pounding and keep rolling."
                }
            }
            }, {"raptorartillery","raptor_evolved_motort4", {
                name="Evolved Lobber",
                customparams= {
                    i18n_en_humanname="Evolved Lobber",i18n_en_tooltip="These lobbers did not just evolve—they became deadlier than anything before them."
                }
            }
            }, {"raptor_land_swarmer_acids_t2_v1","raptor_land_swarmer_acids_t2_v1", {
                name="Acid Spawnling",
                customparams= {
                    i18n_en_humanname="Acid Spawnling",i18n_en_tooltip="This critters are so cute but can be so deadly at the same time."
                }
            }
        }
    }
    for g,J in ipairs(I)do
        E(J[1],J[2],J[3])
    end
    local K=UnitDef_Post;
    function UnitDef_Post(L,M)
        if K and K~=UnitDef_Post then
            K(L,M)
        end
        local N=UnitDefs["raptor_land_swarmer_basic_t1_v1"]and UnitDefs["raptor_land_swarmer_basic_t1_v1"].health;
        local O= {
            texture1= {},texture2= {},
            tracks=false,
            weaponvelocity=4000,
            smokePeriod= {},
            smoketime= {},
            smokesize= {},
            smokecolor= {},
            smoketrail=0
        }
        local P= {
            accuracy=2048,
            areaofeffect=256,
            burst=4,
            burstrate=0.4,
            flighttime=12,
            dance=25,
            craterareaofeffect=256,
            edgeeffectiveness=0.7,
            cegtag="blob_trail_blue",
            explosiongenerator="custom:genericshellexplosion-huge-bomb",
            impulsefactor=0.4,
            intensity=0.3,
            interceptedbyshieldtype=1,
            range=2300,
            reloadtime=10,
            rgbcolor="0.2 0.5 0.9",
            size=8,
            sizedecay=0.09,
            soundhit="bombsmed2",
            soundstart="bugarty",
            sprayangle=2048,
            tolerance=60000,
            turnrate=6000,
            trajectoryheight=2,
            turret=true,
            weapontype="Cannon",
            weaponvelocity=520,
            startvelocity=140,
            weaponacceleration=125,
            weapontimer=0.2,
            wobble=14500,
            highTrajectory=1,
            damage= {
                default=900,
                shields=600
            }
        }
        local Q= {
            accuracy=1024,
            areaofeffect=24,
            burst=1,
            burstrate=0.3,
            cegtag="blob_trail_green",
            edgeeffectiveness=0.63,
            explosiongenerator="custom:raptorspike-small-sparks-burn",
            impulsefactor=1,
            intensity=0.4,
            interceptedbyshieldtype=1,
            name="Acid",
            range=250,
            reloadtime=1,
            rgbcolor="0.8 0.99 0.11",
            size=1,
            stages=6,
            soundhit="bloodsplash3",
            soundstart="alien_bombrel",
            sprayangle=128,
            tolerance=5000,
            turret=true,
            weapontimer=0.1,
            weapontype="Cannon",
            weaponvelocity=320,
            damage= {
                default=80
            }
        }
        local R= {
            raptor_hive_swarmer_basic= {
                metalcost=350,
                nochasecategory="OBJECT",
                icontype="raptor_land_swarmer_basic_t1_v1"
            },
            raptor_hive_assault_basic= {
                metalcost=3000,
                health=25000,
                speed=20.0,
                nochasecategory="OBJECT",
                icontype="raptor_land_assault_basic_t2_v1",
                weapondefs= {
                    aaweapon=O
                }
            },
            raptor_hive_assault_heavy= {
                metalcost=6000,
                health=30000,
                speed=17.0,
                nochasecategory="OBJECT",
                icontype="raptor_land_assault_basic_t4_v1",
                weapondefs= {
                    aaweapon=O
                }
            },
            raptor_hive_assault_superheavy= {
                metalcost=9000,
                health=35000,
                speed=16.0,
                nochasecategory="OBJECT",
                icontype="raptor_land_assault_basic_t4_v2",
                weapondefs= {
                    aaweapon=O
                }
            },
            raptor_evolved_motort4= {
                icontype="raptor_allterrain_arty_basic_t4_v1",
                weapondefs= {
                    poopoo=P
                },
                weapons= {[1]= {
                        badtargetcategory="MOBILE",
                        def="poopoo",
                        maindir="0 0 1",
                        maxangledif=50,
                        onlytargetcategory="NOTAIR"
                    }
                }
            },
            raptor_land_swarmer_acids_t2_v1= {
                metalcost=375,
                energycost=600,
                health=N*2,
                icontype="raptor_land_swarmer_basic_t1_v1",
                buildpic="raptors/raptorh1b.DDS",
                objectname="Raptors/raptor_droneb.s3o",
                weapondefs= {
                    throwup=Q
                },
                weapons= {[1]= {
                        def="throwup",
                        onlytargetcategory="NOTAIR",
                        maindir="0 0 1",
                        maxangledif=180
                    }
                }
            }
        }
		for i,S in pairs(R)do
			local j=UnitDefs[i]
			if j then
				for A,B in pairs(S)do
					if A=="weapondefs"then
                        j.weapondefs=j.weapondefs or {}
                        for T,U in pairs(B)do
                            j.weapondefs[T]=j.weapondefs[T]or {}
                            for V,W in pairs(U)do
                                j.weapondefs[T][V]=W
                            end
                        end
                    elseif A=="weapons"then
						j.weapons=B
					else
						j[A]=B
					end
				end
			end
		end
	end
end
-- MAIN_DEFS_END


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

-- Tweak: Defs_T3_Builders.lua
-- T3 Builders
-- Decoded from tweakdata.txt line 6

--T3 Cons & Taxed Factories
-- Authors: Nervensaege, TetrisCo
-- docs.google.com/spreadsheets/d/1QSVsuAAMhBrhiZdTihVfSCwPzbbZWDLCtXWP23CU0ko
-- T3_BUILDERS_START
do
local a,b,c,d,e,f,
g=UnitDefs or {}, {'arm','cor','leg'
    },table.merge, {
    arm='Armada ',
    cor='Cortex ',
    leg='Legion '
},'_taxed',1.5,table.contains;
local
function h(i,j,k)
    if a[i]and not a[j]then
        a[j]=c(
        a[i],k)
    end
end
for l,m in pairs(b)do
    local n,o,
    p=m=='arm',
    m=='cor',
    m=='leg'
    h(m..'nanotct2',m..'nanotct3', {
        metalcost=3700,
        energycost=62000,
        builddistance=550,
        buildtime=108000,
        collisionvolumescales='61 128 61',
        footprintx=6,
        footprintz=6,
        health=8800,
        mass=37200,
        sightdistance=575,
        workertime=1900,
        icontype="armnanotct2",
        canrepeat=true,
        objectname=p and'Units/legnanotcbase.s3o'or o and'Units/CORRESPAWN.s3o'or'Units/ARMRESPAWN.s3o',
        customparams= {
            i18n_en_humanname='T3 Construction Turret',i18n_en_tooltip='More BUILDPOWER! For the connoisseur'
        }
    })
    h(p and'legamstor'or m..'uwadvms',p and'legamstort3'or m..'uwadvmst3', {
        metalstorage=30000,
        metalcost=4200,
        energycost=231150,
        buildtime=142800,
        health=53560,
        maxthisunit=10,
        icontype="armuwadves",
        name=d[m]..'T3 Metal Storage',
        customparams= {
            i18n_en_humanname='T3 Hardened Metal Storage',i18n_en_tooltip=[[The big metal storage tank for your most precious resources. Chopped chicken!]]
            }
        })
        h(p and'legadvestore'or m..'uwadves',p and'legadvestoret3'or m..'advestoret3', {
            energystorage=272000,
            metalcost=2100,
            energycost=59000,
            buildtime=93380,
            health=49140,
            icontype="armuwadves",
            maxthisunit=10,
            name=d[m]..'T3 Energy Storage',
            customparams= {
                i18n_en_humanname='T3 Hardened Energy Storage',i18n_en_tooltip='Power! Power! We need power!1!'
            }
        })
        for l,q in pairs({
            m..'nanotc',m..'nanotct2'
        })do
            if a[q]then
                a[q].canrepeat=true
            end
        end
        local r=n and'armshltx'or o and'corgant'or'leggant'
        local s=a[r]
        if s then
            h(r,r..e, {
                energycost=s.energycost*f,
                icontype=r,
                metalcost=s.metalcost*f,
                name=d[m]..'Experimental Gantry Taxed',
                customparams= {
                    i18n_en_humanname=d[m]..'Experimental Gantry Taxed',i18n_en_tooltip='Produces Experimental Units'
                }
            })
        end
        local t,
        u= {}, {
            m..'nanotct2',m..'nanotct3',m..'alab',m..'avp',m..'aap',m..'gatet3',m..'flak',p and'legdeflector'or m..'gate',p and'legforti'or m..'fort',n and'armshltx'or m..'gant'
        }

        for l,v in ipairs(u)do
            t[#t+1]=v
        end
        local w= {
            arm= {'corgant','leggant'
            },
            cor= {'armshltx','leggant'
            },
            leg= {'armshltx','corgant'
            }
        }
        for l,x in ipairs(w[m]or {})do t[#t+1]=x..e
        end
        local y= {
            arm= {'armamd','armmercury','armbrtha','armminivulc','armvulc','armannit3','armlwall','armannit4'
            },
            cor= {'corfmd','corscreamer','cordoomt3','corbuzz','corminibuzz','corint','corhllllt','cormwall','cordoomt4','epic_calamity'
            },
            leg= {'legabm','legstarfall','legministarfall','leglraa','legbastion','legrwall','leglrpc','legbastiont4','legdtf'
            }
        }
        for l,v in ipairs(y[m]or {})do t[#t+1]=v
        end
        local j=m..'t3aide'
        h(m..'decom',j, {
            blocking=true,
            builddistance=350,
            buildtime=140000,
            energycost=200000,
            energyupkeep=2000,
            health=10000,
            idleautoheal=5,
            idletime=1800,
            maxthisunit=10,
            metalcost=12600,
            speed=85,
            terraformspeed=3000,
            turninplaceanglelimit=1.890,
            turnrate=1240,
            workertime=6000,
            reclaimable=true,
            candgun=false,
            name=d[m]..'Epic Aide',
            customparams= {
                subfolder='ArmBots/T3',
                techlevel=3,
                unitgroup='buildert3',i18n_en_humanname='Epic Ground Construction Aide',i18n_en_tooltip='Your Aide that helps you construct buildings'
            },
            buildoptions=t
        })
        if a[j] then
            a[j].weapondefs= {}
            a[j].weapons= {}
        end
        j=m..'t3airaide'
        h('armfify',j, {
            blocking=false,
            canassist=true,
            cruisealtitude=3000,
            builddistance=1750,
            buildtime=140000,
            energycost=200000,
            energyupkeep=2000,
            health=1100,
            idleautoheal=5,
            idletime=1800,
            icontype="armnanotct2",
            maxthisunit=10,
            metalcost=13400,
            speed=25,
            category="OBJECT",
            terraformspeed=3000,
            turninplaceanglelimit=1.890,
            turnrate=1240,
            workertime=1600,
            buildpic='ARMFIFY.DDS',
            name=d[m]..'Epic Aide',
            customparams= {
                is_builder=true,
                subfolder='ArmBots/T3',
                techlevel=3,
                unitgroup='buildert3',i18n_en_humanname='Epic Air Construction Aide',i18n_en_tooltip='Your Aide that helps you construct buildings'
            },
            buildoptions=t
        })
        if a[j] then
            a[j].weapondefs= {}
            a[j].weapons= {}
        end
        local z=n and'armshltx'or o and'corgant'or'leggant'
        if a[z]and a[z].buildoptions then
            local A=m..'t3aide'
            if not g(a[z].buildoptions,A)then
                table.insert(a[z].buildoptions,A)
            end
        end
        z=m..'apt3'
        if a[z]and a[z].buildoptions then
            local B=m..'t3airaide'
            if not g(a[z].buildoptions,B)then
                table.insert(a[z].buildoptions,B)
            end
        end
    end
end
-- T3_BUILDERS_END


-- Tweak: Defs_T3_Eco.lua
-- T3 Eco

-- T3_ECO_START
do
local a,
b=UnitDefs or {}, {'armack','armaca','armacv','corack','coraca','coracv','legack','legaca','legacv'}

local function ensureBuildOption(builderName, optionName)
	local builder = a[builderName]
	local optionDef = optionName and a[optionName]
	if not builder or not optionDef then
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

for _,defName in pairs({'armmmkrt3','cormmkrt3','legadveconvt3'})do
	table.mergeInPlace(a[defName], {
		footprintx=6,
		footprintz=6
	})
end

for _,builderName in pairs(b)do
	local prefix=builderName:sub(1,3)
	ensureBuildOption(builderName,prefix..'afust3')
	ensureBuildOption(builderName,prefix=='leg'and'legadveconvt3'or prefix..'mmkrt3')
end

for _,prefix in pairs({'arm','cor','leg'})do
	local groundBuilder = prefix..'t3aide'
	local airBuilder = prefix..'t3airaide'
	local ecoOptions = {
		prefix..'afust3',
		prefix=='leg' and 'legadveconvt3' or prefix..'mmkrt3',
		prefix=='leg' and 'legamstort3' or prefix..'uwadvmst3',
		prefix=='leg' and 'legadvestoret3' or prefix..'advestoret3'
	}
	for _,optionName in ipairs(ecoOptions)do
		ensureBuildOption(groundBuilder, optionName)
		ensureBuildOption(airBuilder, optionName)
	end
end

ensureBuildOption('legck','legdtf')

for _,defName in pairs({'coruwadves','legadvestore'})do
	table.mergeInPlace(a[defName], {
		footprintx=4,
		footprintz=4
	})
end
end
-- T3_ECO_END


-- Tweak: Defs_T4_Air.lua
-- T4 Air Rework
-- Authors: BackBash
-- T4_AIR_START
do
	local defs = UnitDefs or {}
	local merge = table.mergeInPlace or table.merge

	local payload = {
		customparams = {
			i18n_en_humanname = 'Experimental Tyrannus',
			i18n_en_tooltip = 'In dedication to our commander Tyrannus'
		},
		weapondefs = {
			machinegun = {
				accuracy = 400,
				areaofeffect = 64,
				avoidfriendly = false,
				avoidfeature = false,
				collidefriendly = false,
				collidefeature = true,
				maxthisunit = 80,
				beamtime = 0.09,
				corethickness = 0.55,
				duration = 0.09,
				burst = 1,
				burstrate = 0.1,
				explosiongenerator = "custom:genericshellexplosion-tiny-aa",
				energypershot = 0,
				falloffrate = 0,
				firestarter = 50,
				interceptedbyshieldtype = 4,
				intensity = 2,
				name = "scav rapid fire plasma gun",
				range = 1000,
				reloadtime = 0.1,
				weapontype = "LaserCannon",
				rgbcolor = "1 0 0",
				rgbcolor2 = "1 1 1",
				soundtrigger = true,
				soundstart = "tgunshipfire",
				texture1 = "shot",
				texture2 = "explo2",
				thickness = 8.5,
				tolerance = 1000,
				turret = true,
				weaponvelocity = 1000,
				damage = {
					default = 60
				}
			},
			heatray1 = {
				allowNonBlockingAim = true,
				avoidfriendly = true,
				areaofeffect = 64,
				avoidfeature = false,
				beamtime = 0.033,
				camerashake = 0.1,
				collidefriendly = false,
				corethickness = 0.45,
				craterareaofeffect = 12,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 1,
				energypershot = 0,
				explosiongenerator = "custom:heatray-large",
				firestarter = 90,
				firetolerance = 300,
				impulsefactor = 0,
				intensity = 9,
				laserflaresize = 8,
				name = 'Experimental Thermal Ordnance Generators',
				noselfdamage = true,
				proximitypriority = -1,
				range = 850,
				reloadtime = 0.033,
				rgbcolor = "1 0.55 0",
				rgbcolor2 = "0.9 1.0 0.5",
				scrollspeed = 5,
				soundhitdry = 'heatray3start',
				soundhitwet = 'sizzle',
				soundstart = 'heatray3lp',
				soundstartvolume = 6,
				soundtrigger = 1,
				thickness = 6,
				turret = true,
				weapontype = 'BeamLaser',
				weaponvelocity = 1500,
				damage = {
					default = 150
				}
			},
			ata = {
				areaofeffect = 34,
				avoidfeature = false,
				beamtime = 2,
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
				name = 'Heavy long-range g2g tachyon accelerator beam',
				noselfdamage = true,
				range = 1300,
				reloadtime = 15,
				rgbcolor = '0 1 1',
				scrollspeed = 5,
				soundhitdry = '',
				soundhitwet = 'sizzle',
				soundstart = 'raptorlaser',
				soundtrigger = 1,
				soundstartvolume = 4,
				texture3 = 'largebeam',
				thickness = 10,
				tilelength = 150,
				tolerance = 10000,
				turret = true,
				weapontype = 'BeamLaser',
				weaponvelocity = 3100,
				damage = {
					commanders = 480,
					default = 48000
				}
			}
		},
		weapons = {
			[1] = {
				badtargetcategory = "NOTLAND",
				def = "heatray1",
				maindir = "-1 0 0",
				maxangledif = 210,
				onlytargetcategory = "SURFACE"
			},
			[2] = {
				badtargetcategory = "NOTLAND",
				def = "heatray1",
				maindir = "1 0 0",
				maxangledif = 210,
				onlytargetcategory = "SURFACE"
			},
			[3] = {
				def = "ata",
				maindir = "1 0 0",
				maxangledif = 190,
				onlytargetcategory = "SURFACE"
			},
			[4] = {
				def = "machinegun",
				onlytargetcategory = "SURFACE"
			},
			[5] = {
				def = "machinegun",
				onlytargetcategory = "SURFACE"
			}
		}
	}

	if defs.legfortt4 then
		merge(defs.legfortt4, payload)
	else
		defs.legfortt4 = payload
	end
end
-- T4_AIR_END


-- Tweak: Defs_T4_Defenses.lua
-- T4 Defences NuttyB Balance
-- Authors: Hedgehogzs
-- docs.google.com/spreadsheets/d/1QSVsuAAMhBrhiZdTihVfSCwPzbbZWDLCtXWP23CU0ko

-- LEGENDARY_PULSAR_START
do
local a,b,c = UnitDefs or {}, table.merge, 'armannit4'
if a['armannit3'] then
    a[c] = b(a['armannit3'], {
        name='Legendary Pulsar',
        description='Rapid tachyon burst supergun.',
        buildtime=240000,
        health=30000,
        metalcost=43840,
        energycost=1096000,
        icontype="armannit3",
        customparams={
            i18n_en_humanname='Legendary Pulsar',
            i18n_en_tooltip='Fires devastating, rapid-fire tachyon bolts',
            techlevel=4
        },
        weapondefs={
            tachyon_burst_cannon={
                collidefriendly=0,
                collidefeature=0,
                avoidfeature=0,
                avoidfriendly=0,
                name='Tachyon Burst Cannon',
                weapontype='LaserCannon',
                rgbcolor='1 0 1',
                burst=3,
                burstrate=0.40,
                reloadtime=5,
                accuracy=400,
                areaofeffect=12,
                range=1800,
                energypershot=12000,
                turret=true,
                soundstart='annigun1',
                soundhit='xplolrg3',
                size=6,
                impulsefactor=0,
                weaponvelocity=3100,
                thickness=10,
                laserflaresize=8,
                texture3="largebeam",
                tilelength=150,
                tolerance=10000,
                beamtime=3,
                explosiongenerator='custom:tachyonshot',
                damage={ default=8000 },
                allowNonBlockingAim=true
            }
        },
        weapons={
            [1]={ badtargetcategory="VTOL GROUNDSCOUT", def='tachyon_burst_cannon', onlytargetcategory='SURFACE' }
        }
    })
end
local builders_arm={
	'armaca','armack','armacsub','armacv',
	'armt3airaide','armt3aide'
}
local function ensureBuildOption(builderName, optionName)
	local builder = a[builderName]
	local optionDef = optionName and a[optionName]
	if not builder or not optionDef then
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
for i=3,10 do
	builders_arm[#builders_arm+1]='armcomlvl'..i
end
for _,builder_name in pairs(builders_arm)do
	ensureBuildOption(builder_name,c)
end
end
-- LEGENDARY_PULSAR_END

-- LEGENDARY_BASTION_START
do
local a,b,c = UnitDefs or {}, table.merge, 'legbastiont4'
if a['legbastion'] then
    a[c] = b(
    a['legbastion'], {
        name='Legendary Bastion',
        description='Purple heatray defensive tower.',
        health=28000,
        metalcost=65760,
        energycost=1986500,
        buildtime=180000,
        footprintx=6,
        footprintz=6,
        icontype="legbastion",
        objectname='scavs/scavbeacon_t4.s3o',
        script='scavs/scavbeacon.cob',
        buildpic='scavengers/SCAVBEACON.DDS',
        damagemodifier=0.20,
        customparams={
            i18n_en_humanname='Legendary Bastion',
            i18n_en_tooltip='Projects a devastating purple heatray',
            maxrange=1450,
            techlevel=4
        },
        weapondefs={
            legendary_bastion_ray={
                areaofeffect=24,
                collidefriendly=0,
                collidefeature=0,
                avoidfeature=0,
                avoidfriendly=0,
                beamtime=0.3,
                camerashake=0,
                corethickness=0.3,
                craterareaofeffect=120,
                craterboost=0,
                cratermult=0,
                edgeeffectiveness=0.45,
                energypershot=3000,
                explosiongenerator="custom:laserhit-medium-purple",
                firestarter=90,
                firetolerance=300,
                impulsefactor=0,
                laserflaresize=2,
                name="Legendary Heat Ray",
                noselfdamage=true,
                predictboost=0.3,
                proximitypriority=1,
                range=1450,
                reloadtime=0.3,
                rgbcolor="1.0 0.2 1.0",
                rgbcolor2="0.9 1.0 0.5",
                soundhitdry="",
                soundhitwet="sizzle",
                soundstart="banthie2",
                soundstartvolume=25,
                soundtrigger=1,
                thickness=5.5,
                turret=true,
                weapontype="BeamLaser",
                weaponvelocity=1500,
                allowNonBlockingAim=true,
                damage={ default=2500, vtol=15 }
            }
        },
        weapons={
            [1]={ badtargetcategory='VTOL GROUNDSCOUT', def='legendary_bastion_ray', onlytargetcategory='SURFACE' }
        }
    })
end
local builders_leg={
	'legaca','legack','legacsub','legacv',
	'legt3airaide','legt3aide'
}
local function ensureBuildOption(builderName, optionName)
	local builder = a[builderName]
	local optionDef = optionName and a[optionName]
	if not builder or not optionDef then
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
for i=3,10 do
	builders_leg[#builders_leg+1]='legcomlvl'..i
end
for _,builder_name in pairs(builders_leg)do
	ensureBuildOption(builder_name,c)
end
end
-- LEGENDARY_BASTION_END

-- LEGENDARY_BULWARK_START
do
local a,b,c = UnitDefs or {}, table.merge, 'cordoomt4'
if a['cordoomt3'] then
    a[c] = b(
    a['cordoomt3'], {
        name='Legendary Bulwark',
        description='Defensive bulwark annihilates approachers',
        buildtime=250000,
        health=42000,
        metalcost=61650,
        energycost=1712500,
        damagemodifier=0.15,
        energystorage=5000,
        radardistance=1400,
        sightdistance=1100,
        icontype="cordoomt3",
        customparams={
            i18n_en_humanname='Legendary Bulwark',
            i18n_en_tooltip='The ultimate defensive structure',
            paralyzemultiplier=0.2,
            techlevel=4
        },
        weapondefs={
            legendary_overload_scatter={
                collidefriendly=0,
                collidefeature=0,
                avoidfeature=0,
                avoidfriendly=0,
                name='Overload Scatter Beamer',
                weapontype='BeamLaser',
                range=1000,
                reloadtime=0.1,
                sprayangle=2000,
                projectiles=12,
                rgbcolor='0.8 0.1 1.0',
                accuracy=50,
                areaofeffect=8,
                beamdecay=0.05,
                beamtime=0.1,
                beamttl=1,
                corethickness=0.05,
                burnblow=true,
                cylindertargeting=1,
                edgeeffectiveness=0.15,
                explosiongenerator='custom:laserhit-medium-purple',
                firestarter=100,
                impulsefactor=0.123,
                intensity=0.3,
                laserflaresize=11.35,
                noselfdamage=true,
                soundhitwet='sizzle',
                soundstart='beamershot2',
                tolerance=5000,
                thickness=2,
                turret=true,
                weaponvelocity=1000,
                damage={ default=600 }
            },
            legendary_heat_ray={
                collidefriendly=0,
                collidefeature=0,
                avoidfeature=0,
                avoidfriendly=0,
                name='Armageddon Heat Ray',
                weapontype='BeamLaser',
                range=1300,
                reloadtime=4.0,
                areaofeffect=72,
                beamtime=0.6,
                cameraShake=350,
                corethickness=0.40,
                craterareaofeffect=72,
                energypershot=1200,
                explosiongenerator='custom:genericshellexplosion-medium-beam',
                impulsefactor=0,
                largebeamlaser=true,
                laserflaresize=8.8,
                noselfdamage=true,
                rgbcolor='0.9 1.0 0.5',
                rgbcolor2='0.8 0 0',
                scrollspeed=5,
                soundhitdry='',
                soundhitwet='sizzle',
                soundstart='heatray2xl',
                soundtrigger=1,
                thickness=7,
                tolerance=10000,
                turret=true,
                weaponvelocity=1800,
                damage={ default=9000, commanders=1350 }
            },
            legendary_point_defense={
                collidefriendly=0,
                collidefeature=0,
                avoidfeature=0,
                avoidfriendly=0,
                name='Point Defense Laser',
                weapontype='BeamLaser',
                range=750,
                reloadtime=0.5,
                areaofeffect=12,
                beamtime=0.3,
                corethickness=0.32,
                energypershot=500,
                explosiongenerator='custom:laserhit-large-blue',
                firestarter=90,
                impactonly=1,
                impulsefactor=0,
                largebeamlaser=true,
                laserflaresize=8.8,
                noselfdamage=true,
                proximitypriority=0,
                rgbcolor='0 0 1',
                soundhitdry='',
                soundhitwet='sizzle',
                soundstart='annigun1',
                soundtrigger=1,
                texture3='largebeam',
                thickness=5.5,
                tilelength=150,
                tolerance=10000,
                turret=true,
                weaponvelocity=1500,
                damage={ default=450, commanders=999 }
            }
        },
        weapons={
            [1]={ def='legendary_overload_scatter', onlytargetcategory='SURFACE' },
            [2]={ def='legendary_heat_ray', onlytargetcategory='SURFACE' },
            [3]={ def='legendary_point_defense', onlytargetcategory='SURFACE' }
        }
    })
end
local builders_cor={
	'coraca','corack','coracsub','coracv',
	'cort3airaide','cort3aide'
}
local function ensureBuildOption(builderName, optionName)
	local builder = a[builderName]
	local optionDef = optionName and a[optionName]
	if not builder or not optionDef then
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
for i=3,10 do
	builders_cor[#builders_cor+1]='corcomlvl'..i
end
for _,builder_name in pairs(builders_cor)do
	ensureBuildOption(builder_name,c)
end
end
-- LEGENDARY_BULWARK_END


-- Tweak: Defs_T4_Eco.lua
-- T4_ECO_START
do

local unitDefs = UnitDefs or {}
local merge = table.merge
local factions = {'arm', 'cor', 'leg'}
local legendaryScale = 2.0
local fusionEnergyScale = 1.3

local function cloneIfMissing(baseName, newName, overrides)
  if unitDefs[baseName] and not unitDefs[newName] then
    unitDefs[newName] = merge(unitDefs[baseName], overrides)
  end
end

local function mergeIfPresent(name, overrides)
  if unitDefs[name] then
    unitDefs[name] = merge(unitDefs[name], overrides)
  end
end

local function scaled(value, multiplier)
  if value then
    return math.ceil(value * multiplier)
  end
  return nil
end

local function ensureBuildOption(builderName, optionName)
  local builder = unitDefs[builderName]
  local option = unitDefs[optionName]
  if not builder or not option then
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

for _, faction in ipairs(factions) do
  local isLegion = faction == 'leg'

  -- energy converters (Legendary variant)
  local converterBaseName = isLegion and 'legadveconvt3' or (faction .. 'mmkrt3')
  local converterBase = unitDefs[converterBaseName]

  if converterBase then
    local baseCustom = converterBase.customparams or {}
    local legendaryConverterName = converterBaseName .. '_200'

    cloneIfMissing(converterBaseName, legendaryConverterName, {
      description = 'Legendary Energy Converter by Jackie',
      metalcost = scaled(converterBase.metalcost, legendaryScale),
      energycost = scaled(converterBase.energycost, legendaryScale),
      buildtime = scaled(converterBase.buildtime, legendaryScale),
      health = scaled(converterBase.health, legendaryScale * 6),
      customparams = {
        energyconv_capacity = scaled(baseCustom.energyconv_capacity, 2),
        energyconv_efficiency = 0.022,
        buildinggrounddecaldecayspeed = baseCustom.buildinggrounddecaldecayspeed,
        buildinggrounddecalsizex = baseCustom.buildinggrounddecalsizex,
        buildinggrounddecalsizey = baseCustom.buildinggrounddecalsizey,
        buildinggrounddecaltype = baseCustom.buildinggrounddecaltype,
        model_author = baseCustom.model_author,
        normaltex = baseCustom.normaltex,
        removestop = baseCustom.removestop,
        removewait = baseCustom.removewait,
        subfolder = baseCustom.subfolder,
        techlevel = baseCustom.techlevel,
        unitgroup = baseCustom.unitgroup,
        usebuildinggrounddecal = baseCustom.usebuildinggrounddecal,
        i18n_en_humanname = 'Legendary Energy Converter',
        i18n_en_tooltip = 'Convert 12k energy to 264m/s by Jackie (Extremely Explosive)'
      },
      name = 'Legendary Energy Converter',
      buildpic = converterBase.buildpic,
      objectname = converterBase.objectname,
      footprintx = 6,
      footprintz = 6,
      yardmap = converterBase.yardmap,
      script = converterBase.script,
      activatewhenbuilt = converterBase.activatewhenbuilt,
      sightdistance = converterBase.sightdistance,
      seismicsignature = converterBase.seismicsignature,
      idleautoheal = converterBase.idleautoheal,
      idletime = converterBase.idletime,
      maxslope = converterBase.maxslope,
      maxwaterdepth = converterBase.maxwaterdepth,
      maxacc = converterBase.maxacc,
      maxdec = converterBase.maxdec,
      explodeas = "fusionExplosion",
      selfdestructas = "fusionExplosion",
      corpse = converterBase.corpse,
      canrepeat = converterBase.canrepeat

    })
  end

  -- fusion reactors (Legendary variant)
  local fusionBaseName = faction .. 'afust3'
  local fusionBase = unitDefs[fusionBaseName]

  if fusionBase then
    local baseCustom = fusionBase.customparams or {}
    local legendaryFusionName = fusionBaseName .. '_200'

    cloneIfMissing(fusionBaseName, legendaryFusionName, {
      buildtime = scaled(fusionBase.buildtime, 1.8),
      name = 'Legendary Fusion Reactor',
      description = 'Legendary Fusion Reactor by Jackie (Extremely Explosive)',
      metalcost = scaled(fusionBase.metalcost, legendaryScale),
      energycost = scaled(fusionBase.energycost, legendaryScale),
      energymake = scaled(fusionBase.energymake, 2.4),
      energystorage = scaled(fusionBase.energystorage, 6.0),
      health = scaled(fusionBase.health, legendaryScale * 3),
      buildpic = fusionBase.buildpic,
      collisionvolumeoffsets = fusionBase.collisionvolumeoffsets,
      collisionvolumescales = fusionBase.collisionvolumescales,
      collisionvolumetype = fusionBase.collisionvolumetype,
      damagemodifier = 0.95,
      buildangle = fusionBase.buildangle,
      objectname = fusionBase.objectname,
      footprintx = 12,
      footprintz = 12,
      yardmap = fusionBase.yardmap,
      script = fusionBase.script,
      activatewhenbuilt = fusionBase.activatewhenbuilt,
      sightdistance = fusionBase.sightdistance,
      seismicsignature = fusionBase.seismicsignature,
      idleautoheal = scaled(fusionBase.idleautoheal, 6),
      idletime = fusionBase.idletime,
      maxslope = fusionBase.maxslope,
      maxwaterdepth = fusionBase.maxwaterdepth,
      maxacc = fusionBase.maxacc,
      maxdec = fusionBase.maxdec,
      explodeas = "ScavComBossExplo",
      selfdestructas = "ScavComBossExplo",
      corpse = fusionBase.corpse,
      canrepeat = fusionBase.canrepeat,
      customparams = {

        buildinggrounddecaldecayspeed = 30,
        buildinggrounddecalsizex = 18,
        buildinggrounddecalsizey = 18,
        buildinggrounddecaltype = baseCustom.buildinggrounddecaltype,
        model_author = baseCustom.model_author,
        normaltex = baseCustom.normaltex,
        subfolder = baseCustom.subfolder,
        removestop = true,
        removewait = true,
        techlevel = 3,
        unitgroup = "energy",
        usebuildinggrounddecal = true,
        i18n_en_humanname = 'Legendary Fusion Reactor',
        i18n_en_tooltip = 'Convert 12k energy to 264m/s by Jackie (Extremely Explosive)'
      },
      sfxtypes = {
        pieceexplosiongenerators = {
          [1] = "deathceg2",
          [2] = "deathceg3",
          [3] = "deathceg4"
        }
      },
      sounds = {
        canceldestruct = "cancel2",
        underattack = "warning1",
        count = {"count6", "count5", "count4", "count3", "count2", "count1"},
        select = {"fusion2"}
      }
    })
  end

  -- T3 Aides pick up the new options if both builder and options exist
  local groundBuilderName = faction .. 't3aide'
  local airBuilderName = faction .. 't3airaide'

  local optionNames = {
    converterBaseName and (converterBaseName .. '_200') or nil,
    fusionBaseName and (fusionBaseName .. '_200') or nil
  }

  for _, optionName in ipairs(optionNames) do
    if optionName then
      ensureBuildOption(groundBuilderName, optionName)
      ensureBuildOption(airBuilderName, optionName)
    end
  end
end

local sharedBuilders = {'armack', 'armaca', 'armacv', 'corack', 'coraca', 'coracv', 'legack', 'legaca', 'legacv'}

for _, builderName in ipairs(sharedBuilders) do
  local builder = unitDefs[builderName]
  if builder then
    local factionPrefix = builderName:sub(1, 3)
    local converterBaseName = (factionPrefix == 'leg') and 'legadveconvt3' or (factionPrefix .. 'mmkrt3')

    ensureBuildOption(builderName, converterBaseName .. '_200')

    local fusionBaseName = factionPrefix .. 'afust3'
    ensureBuildOption(builderName, fusionBaseName .. '_200')
  end
end
end

-- T4_ECO_END


-- Tweak: Defs_T4_Epics.lua
--Epic Ragnarok, Calamity, Starfall, & Bastion
--Authors: Altwaal

-- RAGNAROK_START
do
local a,b=UnitDefs or{},table.merge
if a['armvulc'] then
    a.epic_ragnarok=b(a['armvulc'],{
      name='Epic Ragnarok',
      description='Beam supergun deletes distant heavies by Altwaal',
      buildtime=920000,
      maxthisunit=80,
      health=140000,
      footprintx=6,
      footprintz=6,
      metalcost=180000,
      energycost=2600000,
      energystorage = 18000,
      icontype="armvulc",
      customparams={
        i18n_en_humanname='Epic Ragnarok',
        i18n_en_tooltip='Ultimate Rapid-Fire Laser Beams Blaster by Altwaal',
        techlevel=4
      },
      weapondefs={
        apocalypse_plasma_cannon={
          collidefriendly=0,
          collidefeature=0,
          avoidfeature=0,
          avoidfriendly=0,
          name='Apocalypse Plasma Cannon',
          weapontype='BeamLaser',
          rgbcolor='1.0 0.2 0.1',
          camerashake=0,
          reloadtime=1,
          accuracy=10,
          areaofeffect=160,
          range=3080,
          energypershot=42000,
          turret=true,
          soundstart='lrpcshot3',
          soundhit='rflrpcexplo',
          soundhitvolume=40,
          size=8,
          impulsefactor=1.3,
          weaponvelocity=3100,
          thickness=12,
          laserflaresize=8,
          texture3="largebeam",
          tilelength=150,
          tolerance=10000,
          beamtime=0.12,
          corethickness=0.4,
          explosiongenerator='custom:tachyonshot',
          craterboost=0.15,
          cratermult=0.15,
          edgeeffectiveness=0.25,
          impactonly=1,
          noselfdamage=true,
          soundtrigger=1,
          lightintensity=0.05,
          lightradius=60,
          damage={
            default=22000,
            shields=6000,
            subs=2657
          },
          allowNonBlockingAim=true
        }
      },
      weapons={
        [1]={
          def='apocalypse_plasma_cannon'
        }
      }
    })
    local builders_arm = { 'armaca', 'armack', 'armacsub', 'armacv', 'armt3airaide', 'armt3aide' }

    local function ensureBuildOptions(builderNames, optionName)
        if not a[optionName] then
            return
        end

        for i = 1, #builderNames do
            local builder = a[builderNames[i]]
            if builder then
                local buildoptions = builder.buildoptions or {}
                builder.buildoptions = buildoptions

                local hasOption = false
                for j = 1, #buildoptions do
                    if buildoptions[j] == optionName then
                        hasOption = true
                        break
                    end
                end

                if not hasOption then
                    buildoptions[#buildoptions + 1] = optionName
                end
            end
        end
    end

    local function removeBuildOption(builderNames, optionName)
        for i = 1, #builderNames do
            local builder = a[builderNames[i]]
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

    removeBuildOption(builders_arm, 'armvulc')
    ensureBuildOptions(builders_arm, 'epic_ragnarok')
end
end
-- RAGNAROK_END

-- CALAMITY_START
do
local a,b=UnitDefs or{},table.merge
if a['corbuzz'] then
    a.epic_calamity=b(a['corbuzz'],{
      name='Epic Calamity',
      description='Huge plasma sieges slow groups by Altwaal',
      maxthisunit=80,
      footprintx=6,
      footprintz=6,
      buildtime=920000,
      health=145000,
      metalcost=165000,
      energycost=2700000,
      energystorage = 18000,
      icontype="corbuzz",
      customparams={
        i18n_en_humanname='Epic Calamity',
        i18n_en_tooltip='Ultimate Rapid-Fire Laser Machine Gun by Altwaal',
        techlevel=4
      },
      weapondefs={
        cataclysm_plasma_howitzer={
          collidefriendly=0,
          collidefeature=0,
          avoidfeature=0,
          avoidfriendly=0,
          impactonly=1,
          name='Cataclysm Plasma Howitzer',
          weapontype='Cannon',
          rgbcolor='0.15 0.6 0.5',
          camerashake=0,
          reloadtime=0.5,
          accuracy=10,
          areaofeffect=220,
          range=3150,
          energypershot=22000,
          turret=true,
          soundstart='lrpcshot3',
          soundhit='rflrpcexplo',
          soundhitvolume=50,
          size=12,
          impulsefactor=2.0,
          weaponvelocity=2500,
          turnrate=20000,
          thickness=18,
          laserflaresize=8,
          texture3="largebeam",
          tilelength=200,
          tolerance=10000,
          explosiongenerator='custom:tachyonshot',
          craterboost=0.15,
          cratermult=0.15,
          edgeeffectiveness=0.35,
          lightintensity=0.05,
          lightradius=60,
          damage={
            default=9000,
            shields=5490,
            subs=2350
          },
          allowNonBlockingAim=true
        }
      },
      weapons={
        [1]={
          def='cataclysm_plasma_howitzer'
        }
      }
    })
    local builders_cor={'coraca','corack','coracsub','coracv','cort3airaide','cort3aide'}

    local function ensureBuildOptions(builderNames, optionName)
        if not a[optionName] then
            return
        end

        for i = 1, #builderNames do
            local builder = a[builderNames[i]]
            if builder then
                local buildoptions = builder.buildoptions or {}
                builder.buildoptions = buildoptions

                local hasOption = false
                for j = 1, #buildoptions do
                    if buildoptions[j] == optionName then
                        hasOption = true
                        break
                    end
                end

                if not hasOption then
                    buildoptions[#buildoptions + 1] = optionName
                end
            end
        end
    end

    local function removeBuildOption(builderNames, optionName)
        for i = 1, #builderNames do
            local builder = a[builderNames[i]]
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

    removeBuildOption(builders_cor, 'corbuzz')
    ensureBuildOptions(builders_cor, 'epic_calamity')
end
end
-- CALAMITY_END

-- STARFALL_START
do
local a,b=UnitDefs or{},table.merge
if a['legstarfall'] then
    a.epic_starfall=b(a['legstarfall'],{
      name='Epic Starfall',
      description='Rapid-fire Ion Plasma by Altwaal',
      buildtime=920000,
      health=145000,
      metalcost=180000,
      energycost=3400000,
      maxthisunit = 80,
      collisionvolumescales='61 128 61',
      footprintx=6,
      footprintz=6,
      customparams={
        i18n_en_humanname='Epic Starfall',
        i18n_en_tooltip='Rapid-fire Ion Plasma by Altwaal',
        techlevel=4,
        modelradius=150
      },
      weapondefs={
        starfire={
          accuracy=10,
          areaofeffect=256,
          collidefriendly=0,
          collidefeature=0,
          avoidfeature=0,
          avoidfriendly=0,
          avoidground=false,
          burst=61,
          burstrate=0.10,
          sprayangle=20,
          highTrajectory=1,
          cegtaj="starfire",
          craterboost=0.1,
          cratermult=0.1,
          edgeeffectiveness=0.95,
          energypershot=36000,
          fireTolerance=364,
          tolerance=364,
          explosiongenerator="custom:starfire-explosion",
          gravityaffected="true",
          impulsefactor=0.5,
          name="Very Long-Range High-Trajectory 63-Salvo Plasma Launcher",
          noselfdamage=true,
          range=3150,
          reloadtime=8,
          rgbcolor="0.7 0.7 1.0",
          soundhit="rflrpcexplo",
          soundhitwet="splshbig",
          soundstart="lrpcshot",
          soundhitvolume=36,
          turret=true,
          weapontimer=14,
          weapontype="Cannon",
          weaponvelocity=650,
          windup = 5,
          damage={
            default=2200,
            shields=740,
            subs=220
          },
        }
      },
      weapons={
        [1]={
          def='starfire',
          onlytargetcategory='SURFACE',
          badtargetcategory='VTOL'
        }
      }
    })
    local builders_leg_starfall={'legaca','legack','legacsub','legacv','legt3airaide','legt3aide'}

    local function ensureBuildOptions(builderNames, optionName)
        if not a[optionName] then
            return
        end

        for i = 1, #builderNames do
            local builder = a[builderNames[i]]
            if builder then
                local buildoptions = builder.buildoptions or {}
                builder.buildoptions = buildoptions

                local hasOption = false
                for j = 1, #buildoptions do
                    if buildoptions[j] == optionName then
                        hasOption = true
                        break
                    end
                end

                if not hasOption then
                    buildoptions[#buildoptions + 1] = optionName
                end
            end
        end
    end

    local function removeBuildOption(builderNames, optionName)
        for i = 1, #builderNames do
            local builder = a[builderNames[i]]
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

    removeBuildOption(builders_leg_starfall, 'legstarfall')
    ensureBuildOptions(builders_leg_starfall, 'epic_starfall')
end
end
-- STARFALL_END

-- BASTION_START
do
local a,b=UnitDefs or{},table.merge
if a['legbastion'] then
    a.epic_bastion=b(a['legbastion'],{
      name='Epic Bastion',
      description='Heat ray tower melts swarms by Altwaal',
      buildtime=150000,
      footprintx=6,
      footprintz=6,
      health=70000,
      metalcost=26000,
      energycost=860000,
      energystorage = 6000,
      sightdistance=1200,
      radardistance=1740,
      paralyzemultiplier=0.4,
      customparams={
        i18n_en_humanname='Epic Bastion',
        i18n_en_tooltip='Sweeping heat ray; place on approach lanes to clear waves by Altwaal',
        techlevel=3
      },
      weapondefs={
        dmaw={
          weapontype="BeamLaser",
          damage={
            default=750,
            vtol=75
          },
          range=1450,
          rgbcolor="0.65 0.2 0.05",
          rgbcolor2="0.6 0.4 0.2",
          lightcolor='0.55 0.25 0.08',
          lightintensity=0.01,
          lightradius=16,
          explosiongenerator="custom:heatray-huge",
          energypershot=12000,
          reloadtime=4,
          beamtime=0.1,
          turret=true,
          weaponvelocity=1500,
          thickness=5.5,
          areaofeffect=120,
          edgeeffectiveness=0.45,
          name="Epic Bastion Ray",
          collidefriendly=0,
          collidefeature=0,
          avoidfeature=0,
          avoidfriendly=0,
          impactonly=1,
          laserflaresize=9,
          corethickness=0.4,
          soundstart="heatray3",
          soundstartvolume=38,
          soundhitdry="",
          soundhitwet="sizzle",
          soundtrigger=1,
          firetolerance=300,
          noselfdamage=true,
          predictboost=0.3,
          proximitypriority=1,
          impulsefactor=0,
          camerashake=0,
          craterareaofeffect=0,
          craterboost=0.1,
          cratermult=0.1,
          customparams={
            sweepfire=4,--multiplier for displayed dps during the 'bonus' sweepfire stage
          },
          tracks=false,
        }
      },
      weapons={
        [1]={
          def='dmaw',
          fastautoretargeting=true
        }
      }
    })
    local builders_leg_bastion={'legaca','legack','legacsub','legacv','legt3airaide','legt3aide'}

    local function ensureBuildOptions(builderNames, optionName)
        if not a[optionName] then
            return
        end

        for i = 1, #builderNames do
            local builder = a[builderNames[i]]
            if builder then
                local buildoptions = builder.buildoptions or {}
                builder.buildoptions = buildoptions

                local hasOption = false
                for j = 1, #buildoptions do
                    if buildoptions[j] == optionName then
                        hasOption = true
                        break
                    end
                end

                if not hasOption then
                    buildoptions[#buildoptions + 1] = optionName
                end
            end
        end
    end
    for i=3,10 do
        builders_leg_bastion[#builders_leg_bastion+1]='legcomlvl'..i
    end
    ensureBuildOptions(builders_leg_bastion, 'epic_bastion')
end
end
-- BASTION_END

-- EPIC_ELYSIUM_START
do
local d,m=UnitDefs or{},table.merge
local e=d.leggatet3
if e then
	local function c(t)
		local n={}
		for k,v in pairs(t) do
			n[k]=type(v)=='table' and c(v) or v
		end
		return n
	end
	local function x(v,n)
		if v then
			return math.ceil(v*n)
		end
	end
	local u=c(e)
	u.name='Epic Elysium'
	u.description='Ultimate shield hub. Projects an impenetrable energy barrier.'
	u.buildtime=x(e.buildtime,1.7)
	u.health=x(e.health,2.5)
	u.metalcost=x(e.metalcost,1.7)
	u.energycost=x(e.energycost,1.7)
	u.energystorage=x(e.energystorage,1.25)
	u.footprintx=6
	u.footprintz=6
	u.icontype='leggatet3'

	local r=(e.weapondefs or{}).repulsor or{}
	local rep=c(r)
	rep.name='Epic Shield'
	rep.weapontype='Shield'

	local sh=c(r.shield or{})
	sh.power=x(sh.power,2.5)
	sh.powerregen=x(sh.powerregen,4.5)
	sh.powerregenenergy=x(sh.powerregenenergy,1.9)
	sh.radius=x(sh.radius,1.3)
	sh.startingpower=x(sh.startingpower,1.7)
	rep.shield=sh
	rep.range=x(rep.range,1.3)

	u.weapondefs={epic_shield=rep}
	u.weapons={{def='epic_shield'}}

	u.customparams=m(c(e.customparams or{}),{
		i18n_en_humanname='Epic Elysium',
		i18n_en_tooltip='Massive shield generator',
		techlevel=4,
		shield_power=sh.power,
		shield_radius=sh.radius
	})

	d.epic_elysium=u

    local builders_leg_elysium={'legaca','legack','legacsub','legacv','legt3aide','legt3airaide'}

    local function ensureBuildOptions(builderNames, optionName)
        if not d[optionName] then
            return
        end

        for i = 1, #builderNames do
            local builder = d[builderNames[i]]
            if builder then
                local buildoptions = builder.buildoptions or {}
                builder.buildoptions = buildoptions

                local hasOption = false
                for j = 1, #buildoptions do
                    if buildoptions[j] == optionName then
                        hasOption = true
                        break
                    end
                end

                if not hasOption then
                    buildoptions[#buildoptions + 1] = optionName
                end
            end
        end
    end
    for i=3,10 do
        table.insert(builders_leg_elysium,'legcomlvl'..i)
    end
    ensureBuildOptions(builders_leg_elysium, 'epic_elysium')
end
end
-- EPIC_ELYSIUM_END

-- FORTRESS_START

do
local a,b=UnitDefs or{},table.merge
if a['legapopupdef'] then
    a.epic_fortress=b(a['legapopupdef'],{
      name='Epic Fortress',
      description='EMP proof Swarm Destroyer by Pyrem',
      buildtime=300000,
      health=60000,
      metalcost=25200,
      energycost=315000,
      sightdistance=1500,
      customparams={
        i18n_en_humanname='Epic Fortress',
        i18n_en_tooltip='EMP proof Swarm Destroyer by Pyrem',
        techlevel=3,
        paralyzemultiplier=0.0
      },
      weapondefs={
        epic_riot_devastator={
          name='Epic Riot Devastator',
          weapontype='Cannon',
          collidefriendly=0,
          collidefeature=0,
          avoidfeature=0,
          avoidfriendly=0,
          damage={
            default=4900
          },
          accuracy=10,
          areaofeffect=164,
          areaofeffect=220,
          edgeeffectiveness=0.50,
          range=1300,
          reloadtime=1.6,
          energypershot=2400,
          turret=true,
          weaponvelocity=900,
          camerashake=0,
          explosiongenerator='custom:genericshellexplosion-medium',
          rgbcolor='1.0 0.3 0.5',
          size=10,
          soundhitvolume=22,
          soundstartvolume=18.0,
          impulsefactor=3.2,
          craterboost=0.25,
          cratermult=0.25,
          noselfdamage=true,
          impactonly=true,
          burnblow=true,
          proximitypriority=5
        },
        epic_minigun={
          accuracy=2,
          areaofeffect=32,
          collidefriendly=0,
          collidefeature=0,
          avoidfeature=0,
          avoidfriendly=0,
          burst = 6,
                burstrate = 0.066,
          burnblow=false,
          craterareaofeffect=0,
          craterboost=0,
          cratermult=0,
          duration=0.05,
          edgeeffectiveness=0.85,
          explosiongenerator="custom:plasmahit-sparkonly",
          falloffrate=0.15,
          firestarter=5,
          impulsefactor=2.0,
          intensity=1.2,
          name="Epic Rotary Cannons",
          noselfdamage=true,
          impactonly=true,
          ownerExpAccWeight=4.0,
          proximitypriority=6,
          range=1000,
          reloadtime=0.4,
          rgbcolor="1 0.4 0.6",
          soundhit="bimpact3",
          soundhitwet="splshbig",
          soundstart="mgun6heavy",
          soundstartvolume=6.5,
          soundtrigger=true,
          sprayangle=450,
          texture1="shot",
          texture2="empty",
          thickness=4.5,
          tolerance=3000,
          turret=true,
          weapontype="LaserCannon",
          weaponvelocity=1300,
          damage={
            default=60,
            vtol=60,
          }
        }
      },
      weapons={
        [1]={
          def='epic_riot_devastator',
          onlytargetcategory='SURFACE'
        },
        [2]={
          def='epic_minigun',
          onlytargetcategory='SURFACE'
        },
        [3]={
          def='epic_minigun',
          onlytargetcategory='SURFACE'
        }
      }
    })
    local builders_leg={'legaca','legack','legacsub','legacv','legt3airaide','legt3aide'}

    local function ensureBuildOptions(builderNames, optionName)
        if not a[optionName] then
            return
        end

        for i = 1, #builderNames do
            local builder = a[builderNames[i]]
            if builder then
                local buildoptions = builder.buildoptions or {}
                builder.buildoptions = buildoptions

                local hasOption = false
                for j = 1, #buildoptions do
                    if buildoptions[j] == optionName then
                        hasOption = true
                        break
                    end
                end

                if not hasOption then
                    buildoptions[#buildoptions + 1] = optionName
                end
            end
        end
    end
    for i=3,10 do
        builders_leg[#builders_leg+1]='legcomlvl'..i
    end
    ensureBuildOptions(builders_leg, 'epic_fortress')
end
end
-- FORTRESS_END


-- Tweak: Defs_Unit_Launchers.lua
-- Unit Launchers

--Meatballlunch Reloaded
-- UNIT_LAUNCHERS_START
do
local UnitDefs,
a=UnitDefs or {},'armbotrail'
local b= {
    armt3= {
        maxthisunit=20,
        footprintx=6,
        footprintz=6,
        customparams= {

            i18n_en_humanname='Armada T3 Launcher',
            i18n_en_tooltip='Launches Titan, Thor & Ratte by Pyrem'
        },
        weapondefs= {
            arm_botrail= {
                stockpiletime=8,
                range=7550,
                metalpershot=13000,
                energypershot=180000,
                reloadtime=2,
                customparams= {
                    stockpilelimit=50,
                    spawns_name='armbanth armthor armrattet4',
                    spawns_mode='random'
                }
            }
        }
    },
    cort3= {
        maxthisunit=20,
        footprintx=6,
        footprintz=6,
        customparams= {

            i18n_en_humanname='Cortex T3 Launcher',
            i18n_en_tooltip='Launches Tzar, Behemoth & Juggernaut by Pyrem'
        },
        weapondefs= {
            arm_botrail= {
                stockpiletime=8,
                range=7550,
                metalpershot=20000,
                energypershot=180000,
                reloadtime=2,
                customparams= {
                    stockpilelimit=50,
                    spawns_name='corjugg corkorg corgolt4',
                    spawns_mode='random'
                }
            }
        }
    },
    legt3= {
        maxthisunit=20,
        footprintx=6,
        footprintz=6,
        customparams= {

            i18n_en_humanname='Legion T3 Launcher',
            i18n_en_tooltip='Launches Sols (2 Types) by Pyrem'
        },
        weapondefs= {
            arm_botrail= {
                stockpiletime=8,
                range=7550,
                metalpershot=16000,
                energypershot=180000,
                reloadtime=2,
                customparams= {
                    stockpilelimit=50,
                    spawns_name='leegmech legeheatraymech legeheatraymech_old',
                    spawns_mode='random'
                }
            }
        }
    }
}

local function ensureBuildOption(builderName, optionName)
	local builder = UnitDefs[builderName]
	local optionDef = optionName and UnitDefs[optionName]
	if not builder or not optionDef then
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

if UnitDefs.cormandot4 then
    for c,d in pairs(b)do
        local e=a..'_'..c;
        if UnitDefs[a]and not UnitDefs[e]then
            UnitDefs[e]=table.merge(
            UnitDefs[a],d)
            ensureBuildOption('cormandot4',e)
        end
    end
end
end
-- UNIT_LAUNCHERS_END


-- Tweak: Defs_Waves_Experimental_Wave_Challenge.lua

                local newUnits = -- Experimental Wave Challenge
-- Authors: BackBash

-- EXP_WAVE_START
{
    raptor_air_scout_basic_t2_v1= {
        customparams= {
            raptorcustomsquad=true,
            raptorsquadunitsamount=25,
            raptorsquadminanger=20,
            raptorsquadmaxanger=26,
            raptorsquadweight=10,
            raptorsquadrarity="basic",
            raptorsquadbehavior="raider",
            raptorsquadbehaviordistance=500,
            raptorsquadbehaviorchance=0.75
        }
    },
    raptor_hive_assault_basic= {
        customparams= {
            raptorcustomsquad=true,
            raptorsquadunitsamount=25,
            raptorsquadminanger=0,
            raptorsquadmaxanger=40,
            raptorsquadweight=1,
            raptorsquadrarity="basic",
            raptorsquadbehavior="raider",
            raptorsquadbehaviordistance=500,
            raptorsquadbehaviorchance=0.75
        }
    },
    raptor_land_swarmer_basic_t3_v1= {
        customparams= {
            raptorcustomsquad=true,
            raptorsquadunitsamount=25,
            raptorsquadminanger=0,
            raptorsquadmaxanger=40,
            raptorsquadweight=2,
            raptorsquadrarity="basic",
            raptorsquadbehavior="raider",
            raptorsquadbehaviordistance=500,
            raptorsquadbehaviorchance=0.75
        }
    },
    raptor_evolved_motort4= {
        customparams= {
            raptorcustomsquad=true,
            raptorsquadunitsamount=12,
            raptorsquadminanger=50,
            raptorsquadmaxanger=300,
            raptorsquadweight=3,
            raptorsquadrarity="special",
            raptorsquadbehavior="artillery",
            raptorsquadbehaviordistance=2500,
            raptorsquadbehaviorchance=0.75
        }
    },
    raptor_hive_assault_heavy= {
        customparams= {
            raptorcustomsquad=true,
            raptorsquadunitsamount=25,
            raptorsquadminanger=55,
            raptorsquadmaxanger=70,
            raptorsquadweight=1,
            raptorsquadrarity="basic",
            raptorsquadbehavior="berserk",
            raptorsquadbehaviordistance=500,
            raptorsquadbehaviorchance=0.75
        }
    },
    raptor_hive_assault_superheavy= {
        customparams= {
            raptorcustomsquad=true,
            raptorsquadunitsamount=25,
            raptorsquadminanger=80,
            raptorsquadmaxanger=85,
            raptorsquadweight=1,
            raptorsquadrarity="basic",
            raptorsquadbehavior="berserk",
            raptorsquadbehaviordistance=500,
            raptorsquadbehaviorchance=0.75
        }
    },
    raptor_air_kamikaze_basic_t2_v1= {
        customparams= {
            raptorcustomsquad=true,
            raptorsquadunitsamount=55,
            raptorsquadminanger=100,
            raptorsquadmaxanger=105,
            raptorsquadweight=2,
            raptorsquadrarity="basic",
            raptorsquadbehavior="berserk",
            raptorsquadbehaviordistance=500,
            raptorsquadbehaviorchance=0.75
        }
    },
    raptor_matriarch_fire= {
        customparams= {
            raptorcustomsquad=true,
            raptorsquadunitsamount=30,
            raptorsquadminanger=105,
            raptorsquadmaxanger=135,
            raptorsquadweight=3,
            raptorsquadrarity="special",
            raptorsquadbehavior="berserk",
            raptorsquadbehaviordistance=500,
            raptorsquadbehaviorchance=0.75
        }
    },
    raptor_matriarch_basic= {
        customparams= {
            raptorcustomsquad=true,
            raptorsquadunitsamount=30,
            raptorsquadminanger=105,
            raptorsquadmaxanger=135,
            raptorsquadweight=3,
            raptorsquadrarity="special",
            raptorsquadbehavior="berserk",
            raptorsquadbehaviordistance=500,
            raptorsquadbehaviorchance=0.75
        }
    },
    raptor_matriarch_acid= {
        customparams= {
            raptorcustomsquad=true,
            raptorsquadunitsamount=30,
            raptorsquadminanger=105,
            raptorsquadmaxanger=135,
            raptorsquadweight=3,
            raptorsquadrarity="special",
            raptorsquadbehavior="berserk",
            raptorsquadbehaviordistance=500,
            raptorsquadbehaviorchance=0.75
        }
    },
    raptor_matriarch_electric= {
        customparams= {
            raptorcustomsquad=true,
            raptorsquadunitsamount=30,
            raptorsquadminanger=105,
            raptorsquadmaxanger=135,
            raptorsquadweight=3,
            raptorsquadrarity="special",
            raptorsquadbehavior="berserk",
            raptorsquadbehaviordistance=500,
            raptorsquadbehaviorchance=0.75
        },
        weapons= {[5]= {
                def=""
            }
        }
    },
    raptor_queen_veryeasy= {
        selfdestructas="customfusionexplo",
        explodeas="customfusionexplo",
        maxthisunit=3,
        customparams= {
            raptorcustomsquad=true,i18n_en_humanname="Queen Degenerative",i18n_en_tooltip="SHES A BIG ONE",
            raptorsquadunitsamount=2,
            raptorsquadminanger=70,
            raptorsquadmaxanger=150,
            raptorsquadweight=2,
            raptorsquadrarity="special",
            raptorsquadbehavior="berserk",
            raptorsquadbehaviordistance=500,
            raptorsquadbehaviorchance=0.75
        },
        weapondefs= {
            melee= {
                damage= {
                    default=5000
                }
            },
            yellow_missile= {
                damage= {
                    default=1,
                    vtol=500
                }
            },
            goo= {
                range=500,
                damage= {
                    default=1200
                }
            }
        }
    },
    corcomlvl4= {
        weapondefs= {
            disintegratorxl= {
                damage= {
                    commanders=0,
                    default=99999,
                    scavboss=1000,
                    raptorqueen=5000
                }
            }
        }
    }
}

-- EXP_WAVE_END

                if UnitDefs and newUnits then
                    for name, def in pairs(newUnits) do
                        if UnitDefs[name] then
                            table.mergeInPlace(UnitDefs[name], def)
                        else
                            UnitDefs[name] = def
                        end
                    end
                end


-- Tweak: Defs_Waves_Mini_Bosses.lua
-- Mini Bosses
-- Decoded from tweakdata.txt line 3

--Mini Bosses v2f
-- Authors: RCore
-- docs.google.com/spreadsheets/d/1QSVsuAAMhBrhiZdTihVfSCwPzbbZWDLCtXWP23CU0ko
-- MINI_BOSSES_START
do
local a,b,c,d,e,
f=UnitDefs or {},table.merge,table.copy,'raptor_matriarch_basic','customfusionexplo',Spring;
local g,
h=1.3,1.3;
if a[d] and a['raptor_queen_epic'] then
    if a[d].health then h=a[d].health/60000 end
    if a['raptor_queen_epic'].health then g=a['raptor_queen_epic'].health/1250000 end
end
local i=1;
if f.Utilities.Gametype.IsRaptors()then
    i=(#f.GetTeamList()-2)/12
end
local j=f.GetModOptions().raptor_spawncountmult or 3;
local i=i*(j/3)
local
function j(a)return math.max(1,math.ceil(a*i))
end
local i= {70,85,90,105,110,125
}
local k=math.max(1,f.GetModOptions().raptor_queentimemult or 1.3)
local l,
m=i[1],i[#i]
local n=k*i[#i]/1.3;
local m=(n-l)/(m-l)
for a=2,#i do
    i[a]=math.floor(l+(
    i[a]-l)*m)
end
local f=f.GetModOptions().raptor_queen_count or 1;
local l=1;
l=math.min(10,g/1.3*0.9)
local g=20;
local m=10*(1.06^math.max(0,math.min(f,g)-8))
local g=math.max(0,f-g)
local g=m+g;
local g=math.ceil(l*g)
local g=k*100+g;
local f=math.max(3,j(math.floor((21*f+36)/19)))
local
function k(c,d,e)
    if a[c]and not a[d]then
        a[d]=b(
        a[c],e or {})
    end
end
local d_health=0;
if a[d] and a[d].health then d_health=a[d].health end
k('raptor_queen_veryeasy','raptor_miniq_a', {
    name='Queenling Prima',
    icontype='raptor_queen_veryeasy',
    health=d_health*5,
    customparams= {
        i18n_en_humanname='Queenling Prima',i18n_en_tooltip='Majestic and bold, ruler of the hunt.'
    }
})
k('raptor_queen_easy','raptor_miniq_b', {
    name='Queenling Secunda',
    icontype='raptor_queen_easy',
    health=d_health*6,
    customparams= {
        i18n_en_humanname='Queenling Secunda',i18n_en_tooltip='Swift and sharp, a noble among raptors.'
    }
})
k('raptor_queen_normal','raptor_miniq_c', {
    name='Queenling Tertia',
    icontype='raptor_queen_normal',
    health=d_health*7,
    customparams= {
        i18n_en_humanname='Queenling Tertia',i18n_en_tooltip='Refined tastes. Likes her prey rare.'
    }
})
if a.raptor_miniq_b and a['raptor_matriarch_acid'] then
a.raptor_miniq_b.weapondefs.acidgoo=c(a['raptor_matriarch_acid'].weapondefs.acidgoo)
end
if a.raptor_miniq_c and a['raptor_matriarch_electric'] then
a.raptor_miniq_c.weapondefs.empgoo=c(a['raptor_matriarch_electric'].weapondefs.goo)
end
for a,a in ipairs{
    {'raptor_matriarch_basic','raptor_mama_ba','Matrona','Claws charged with vengeance.'
        }, {'raptor_matriarch_fire','raptor_mama_fi','Pyro Matrona','A firestorm of maternal wrath.'
        }, {'raptor_matriarch_electric','raptor_mama_el','Paralyzing Matrona','Crackling with rage, ready to strike.'
        }, {'raptor_matriarch_acid','raptor_mama_ac','Acid Matrona','Acid-fueled, melting everything in sight.'
    }
} do
    k(a[1],a[2], {
        name=a[3],
        icontype=a[1],
        health=d_health*1.5,
        customparams= {
        i18n_en_humanname=a[3],i18n_en_tooltip=a[4]}
    })
end;
k('critter_penguinking','raptor_consort', {
    name='Raptor Consort',
    icontype='corkorg',
    health=d_health*4,
    mass=100000,
    nochasecategory="MOBILE VTOL OBJECT",
    sonarstealth=false,
    stealth=false,
    speed=67.5,
    customparams= {
        i18n_en_humanname='Raptor Consort',i18n_en_tooltip='Sneaky powerful little terror.'
    }
})
if a.raptor_consort and a['raptor_queen_epic'] then
a.raptor_consort.weapondefs.goo=c(a['raptor_queen_epic'].weapondefs.goo)
end
k('raptor_consort','raptor_doombringer', {
    name='Doombringer',
    icontype='armafust3',
    health=d_health*12,
    speed=50,
    customparams= {
        i18n_en_humanname='Doombringer',i18n_en_tooltip=[[Your time is up. The Queens called for backup.]]
        }
    })
    local
    function c(a,b,c,d,e,f)return{
        raptorcustomsquad=true,
        raptorsquadunitsamount=e or 1,
        raptorsquadminanger=a,
        raptorsquadmaxanger=b,
        raptorsquadweight=f or 5,
        raptorsquadrarity=d or'basic',
        raptorsquadbehavior=c,
        raptorsquadbehaviordistance=500,
        raptorsquadbehaviorchance=0.75
    }
end
local d= {
    selfdestructas=e,
    explodeas=e,
    weapondefs= {
        yellow_missile= {
            damage= {
                default=1,
                vtol=1000
            }
        }
    }
}
for b,c in pairs{
    raptor_miniq_a=b(d, {
        maxthisunit=j(2),
        customparams=c(i[1],i[2],'berserk'),
        weapondefs= {
            goo= {
                damage= {
                    default=750
                }
            },
            melee= {
                damage= {
                    default=4000
                }
            }
        }
    }),
    raptor_miniq_b=b(d, {
        maxthisunit=j(3),
        customparams=c(i[3],i[4],'berserk'),
        weapondefs= {
            acidgoo= {
                burst=8,
                reloadtime=10,
                sprayangle=4096,
                damage= {
                    default=1500,
                    shields=1500
                }
            },
            melee= {
                damage= {
                    default=5000
                }
            }
        },
        weapons= {[1]= {
                def="MELEE",
                maindir="0 0 1",
                maxangledif=155
                },[2]= {
                onlytargetcategory="VTOL",
                def="yellow_missile"
                },[3]= {
                onlytargetcategory="VTOL",
                def="yellow_missile"
                },[4]= {
                onlytargetcategory="VTOL",
                def="yellow_missile"
                },[5]= {
                def="acidgoo",
                maindir="0 0 1",
                maxangledif=180
            }
        }
    }),
    raptor_miniq_c=b(d, {
        maxthisunit=j(4),
        customparams=c(
        i[5],i[6],'berserk'),
        weapondefs= {
            empgoo= {
                burst=10,
                reloadtime=10,
                sprayangle=4096,
                damage= {
                    default=2000,
                    shields=2000
                }
            },
            melee= {
                damage= {
                    default=6000
                }
            }
        },
        weapons= {[1]= {
                def="MELEE",
                maindir="0 0 1",
                maxangledif=155
                },[2]= {
                onlytargetcategory="VTOL",
                def="yellow_missile"
                },[3]= {
                onlytargetcategory="VTOL",
                def="yellow_missile"
                },[4]= {
                onlytargetcategory="VTOL",
                def="yellow_missile"
                },[5]= {
                def="empgoo",
                maindir="0 0 1",
                maxangledif=180
            }
        }
    }),
    raptor_consort= {
        explodeas='raptor_empdeath_big',
        maxthisunit=j(6),
        customparams=c(
        i[2],1000,'berserk'),
        weapondefs= {
            eyelaser= {
                name='Angry Eyes',
                reloadtime=3,
                rgbcolor='1 0 0.3',
                range=500,
                damage= {
                    default=6000,
                    commanders=6000
                }
            },
            goo= {
                name='Snowball Barrage',
                soundstart='penbray2',
                soundStartVolume=2,
                cegtag="blob_trail_blue",
                burst=8,
                sprayangle=2048,
                weaponvelocity=600,
                reloadtime=4,
                range=1000,
                hightrajectory=1,
                rgbcolor="0.7 0.85 1.0",
                damage= {
                    default=1000
                }
            }
        },
        weapons= {[1]= {
                def="eyelaser",
                badtargetcategory="VTOL OBJECT"
                },[2]= {
                def='goo',
                maindir='0 0 1',
                maxangledif=180,
                badtargetcategory="VTOL OBJECT"
            }
        }
    },
    raptor_doombringer= {
        explodeas="ScavComBossExplo",
        maxthisunit=f,
        customparams=c(g,1000,'berserk',nil,1,99),
        weapondefs= {
            eyelaser= {
                name='Eyes of Doom',
                reloadtime=3,
                rgbcolor='0.3 1 0',
                range=500,
                damage= {
                    default=48000,
                    commanders=24000
                }
            },
            goo= {
                name='Amber Hailstorm',
                soundstart='penbray1',
                soundStartVolume=2,
                cegtag="blob_trail_red",
                burst=15,
                sprayangle=3072,
                weaponvelocity=600,
                reloadtime=5,
                rgbcolor="0.7 0.85 1.0",
                hightrajectory=1,
                damage= {
                    default=5000
                }
            }
        },
        weapons= {[1]= {
                def="eyelaser",
                badtargetcategory="VTOL OBJECT"
                },[2]= {
                def='goo',
                maindir='0 0 1',
                maxangledif=180,
                badtargetcategory="VTOL OBJECT"
            }
        }
    },
    raptor_mama_ba= {
        maxthisunit=j(4),
        customparams=c(55,
        i[3]-1,'berserk'),
        weapondefs= {
            goo= {
                damage= {
                    default=750
                }
            },
            melee= {
                damage= {
                    default=750
                }
            }
        }
    },
    raptor_mama_fi= {
        explodeas='raptor_empdeath_big',
        maxthisunit=j(4),
        customparams=c(55,i[3]-1,'berserk'),
        weapondefs= {
            flamethrowerspike= {
                damage= {
                    default=80
                }
            },
            flamethrowermain= {
                damage= {
                    default=160
                }
            }
        }
    },
    raptor_mama_el= {
        maxthisunit=j(4),
    customparams=c(65,1000,'berserk')},
    raptor_mama_ac= {
        maxthisunit=j(4),
        customparams=c(60,1000,'berserk'),
        weapondefs= {
            melee= {
                damage= {
                    default=750
                }
            }
        }
    },
    raptor_land_assault_basic_t4_v2= {
        maxthisunit=j(8),
        customparams=c(33,50,'raider')
    },
    raptor_land_assault_basic_t4_v1= {
        maxthisunit=j(12),
    customparams=c(51,64,'raider','basic',2)
    }
} do
    a[b]=a[b]or {}
    table.mergeInPlace(
    a[b],c,true)
end
local a= {
    raptor_mama_ba=36000,
    raptor_mama_fi=36000,
    raptor_mama_el=36000,
    raptor_mama_ac=36000,
    raptor_consort=45000,
    raptor_doombringer=90000
}
local b=UnitDef_Post;
function UnitDef_Post(c,d)
    if b then
        b(c,d)
    end
    local b=1;
	if h>1.3 then
		b=h/1.3
	end
	for a,c in pairs(a)do
		if UnitDefs[a]then
			local b=math.floor(c*b)
			UnitDefs[a].metalcost=b
		end
	end
end
end
-- MINI_BOSSES_END


-- Tweak: Units_EVO_XP.lua
-- EVO_XP_START
for name, ud in pairs(UnitDefs) do
	if string.match(name, 'comlvl%d') or string.match(name, 'armcom') or string.match(name, 'corcom') or string.match(name, 'legcom') then
		ud.customparams = ud.customparams or {}
		ud.customparams.inheritxpratemultiplier = 0.5
		ud.customparams.childreninheritxp = 'TURRET MOBILEBUILT'
		ud.customparams.parentsinheritxp = 'TURRET MOBILEBUILT'
	end
end
-- EVO_XP_END


-- Tweak: Units_LRPC_v2.lua
-- LRPC Rebalance v2
-- LRPC_START
do
local UnitDefs = UnitDefs or {}

-- Armada LRPC (Big Bertha)
if UnitDefs.armbrtha then
    table.mergeInPlace(UnitDefs.armbrtha, {
        health = 13000,
        weapondefs = {
            ARMBRTHA_MAIN = {
                damage = {
                    commanders = 480,
                    default = 33000
                },
                areaofeffect = 60,
                energypershot = 8000,
                range = 2400,
                reloadtime = 9,
                turnrate = 20000
            }
        }
    })
end

-- Cortex LRPC (Intimidator)
if UnitDefs.corint then
    table.mergeInPlace(UnitDefs.corint, {
        health = 13000,
        weapondefs = {
            CORINT_MAIN = {
                damage = {
                    commanders = 480,
                    default = 85000
                },
                areaofeffect = 230,
                edgeeffectiveness = 0.6,
                energypershot = 15000,
                range = 2700,
                reloadtime = 18
            }
        }
    })
end

-- Legion LRPC
if UnitDefs.leglrpc then
    table.mergeInPlace(UnitDefs.leglrpc, {
        health = 13000,
        weapondefs = {
            LEGLRPC_MAIN = {
                damage = {
                    commanders = 480,
                    default = 4500
                },
                energypershot = 2000,
                range = 2000,
                reloadtime = 2,
                turnrate = 30000
            }
        }
    })
end
end
-- LRPC_END


-- Tweak: Units_Main.lua

                local newUnits = --NuttyB v1.52 Units Main
-- Authors: ChrispyNut, BackBash
-- MAIN_UNITS_START
{
    cortron= {
        energycost=42000,
        metalcost=3600,
        buildtime=110000,
        health=12000,
        weapondefs= {
            cortron_weapon= {
                energypershot=51000,
                metalpershot=600,
                range=4050,
                damage= {
                    default=9000
                }
            }
        }
    },
    corfort= {
        repairable=true
    },
    armfort= {
        repairable=true
    },
    legforti= {
        repairable=true
    },
    armgate= {
        explodeas='empblast',
        selfdestructas='empblast'
    },
    corgate= {
        explodeas='empblast',
        selfdestructas='empblast'
    },
    legdeflector= {
        explodeas='empblast',
        selfdestructas='empblast'
    },
    corsat= {
        sightdistance=3100,
        radardistance=4080,
        cruisealtitude=3300,
        energyupkeep=1250,
        category="OBJECT"
    },
    armsat= {
        sightdistance=3100,
        radardistance=4080,
        cruisealtitude=3300,
        energyupkeep=1250,
        category="OBJECT"
    },
    legstarfall= {
        weapondefs= {
            starfire= {
                energypershot=270000
            }
        }
    },
    armflak= {
        airsightdistance=1350,
        energycost=30000,
        metalcost=1500,
        health=4000,
        weapondefs= {
            armflak_gun= {
                collidefriendly=0,
                collidefeature=0,
                avoidfeature=0,
                avoidfriendly=0,
                areaofeffect=150,
                range=1150,
                reloadtime=0.475,
                weaponvelocity=2400,
                intensity=0.18
            }
        }
    },
    corflak= {
        airsightdistance=1350,
        energycost=30000,
        metalcost=1500,
        health=4000,
        weapondefs= {
            armflak_gun= {
                collidefriendly=0,
                collidefeature=0,
                avoidfeature=0,
                avoidfriendly=0,
                areaofeffect=200,
                range=1350,
                reloadtime=0.56,
                weaponvelocity=2100,
                intensity=0.18
            }
        }
    },
    legflak= {
        footprintx=4,
        footprintz=4,
        airsightdistance=1350,
        energycost=35000,
        metalcost=2100,
        health=6000,
        weapondefs= {
            legflak_gun= {
                collidefriendly=0,
                collidefeature=0,
                avoidfeature=0,
                avoidfriendly=0,
                areaofeffect=100,
                burst=3,
                range=1050,
                intensity=0.18
            }
        }
    },
    armmercury= {
        airsightdistance=2200,
        weapondefs= {
            arm_advsam= {
                areaofeffect=500,
                energypershot=2000,
                explosiongenerator='custom:flak',
                flighttime=1.5,
                metalpershot=6,
                name='Mid-range, rapid-fire g2a guided missile launcher',
                range=2500,
                reloadtime=1.2,
                smoketrail=false,
                startvelocity=1500,
                weaponacceleration=1000,
                weaponvelocity=4000
            }
        }
    },
    corscreamer= {
        airsightdistance=2800,
        weapondefs= {
            cor_advsam= {
                areaofeffect=800,
                energypershot=2000,
                explosiongenerator='custom:flak',
                flighttime=1,
                metalpershot=10,
                name='Long-range g2a guided heavy flak missile launcher',
                range=2800,
                reloadtime=1.8,
                smoketrail=false,
                startvelocity=4000,
                weaponacceleration=1000,
                weaponvelocity=8000
            }
        }
    },
    armassistdrone= {
        buildoptions= {[31]='armclaw'
        }
    },
    corassistdrone= {
        buildoptions= {[32]='cormaw'
        }
    },
    legassistdrone= {
        buildoptions= {[31]='legdtf',[32]='legdtl',[33]='legdtr'
        }
    },
    legfortt4= {
        explodeas="fusionExplosionSelfd",
        selfdestructas="fusionExplosionSelfd"
    },
    legfort= {
        explodeas="empblast",
        selfdestructas="empblast"
    },
    raptor_hive= {
        weapondefs= {
            antiground= {
                burst=5,
                burstrate=0.01,
                cegtag='arty-heavy-purple',
                explosiongenerator='custom:dirt',
                model='Raptors/s_raptor_white.s3o',
                range=1600,
                reloadtime=5,
                rgbcolor='0.5 0 1',
                soundhit='smallraptorattack',
                soundstart='bugarty',
                sprayangle=256,
                turret=true,
                stockpiletime=12,
                proximitypriority=nil,
                damage= {
                    default=1,
                    shields=100
                },
                customparams= {
                    spawns_count=15,
                    spawns_expire=11,
                    spawns_mode='random',
                    spawns_name='raptor_land_swarmer_basic_t1_v1 raptor_land_swarmer_basic_t1_v1 raptor_land_swarmer_basic_t1_v1 ',
                    spawns_surface='LAND SEA',
                    stockpilelimit=10
                }
            }
        }
    },
    armapt3= {
        buildoptions= {[58]='armsat'
        }
    },
    corapt3= {
        buildoptions= {[58]='corsat'
        }
    },
    legapt3= {
        buildoptions= {[58]='corsat'
        }
    },
    armlwall= {
        energycost=25000,
        metalcost=1300,
        weapondefs= {
            lightning= {
                energypershot=200,
                range=430
            }
        }
    },
    armclaw= {
        collisionvolumeoffsets='0 -2 0',
        collisionvolumescales='30 51 30',
        collisionvolumetype='Ell',
        usepiececollisionvolumes=0,
        weapondefs= {
            dclaw= {
                energypershot=60
            }
        }
    },
    legdtl= {
        weapondefs= {
            dclaw= {
                energypershot=60
            }
        }
    },
    armamd= {
        metalcost=1800,
        energycost=41000,
        weapondefs= {
            amd_rocket= {
                coverage=2125,
                stockpiletime=70
            }
        }
    },
    corfmd= {
        metalcost=1800,
        energycost=41000,
        weapondefs= {
            fmd_rocket= {
                coverage=2125,
                stockpiletime=70
            }
        }
    },
    legabm= {
        metalcost=1800,
        energycost=41000,
        weapondefs= {
            fmd_rocket= {
                coverage=2125,
                stockpiletime=70
            }
        }
    },
    corwint2= {
        metalcost=400
    },
    legwint2= {
        metalcost=400
    },
    legdtr= {
        buildtime=5250,
        energycost=5500,
        metalcost=400,
        collisionvolumeoffsets='0 -10 0',
        collisionvolumescales='39 88 39',
        collisionvolumetype='Ell',
        usepiececollisionvolumes=0,
        weapondefs= {
            corlevlr_weapon= {
                areaofeffect=30,
                avoidfriendly=true,
                collidefriendly=false,
                cegtag='railgun',
                range=650,
                energypershot=75,
                explosiongenerator='custom:plasmahit-sparkonly',
                rgbcolor='0.34 0.64 0.94',
                soundhit='mavgun3',
                soundhitwet='splshbig',
                soundstart='lancefire',
                weaponvelocity=1300,
                damage= {
                    default=550
                }
            }
        }
    },
    armrespawn= {
        blocking=false,
        canresurrect=true
    },
    legnanotcbase= {
        blocking=false,
        canresurrect=true
    },
    correspawn= {
        blocking=false,
        canresurrect=true
    },
    legrwall= {
        collisionvolumeoffsets="0 -3 0",
        collisionvolumescales="32 50 32",
        collisionvolumetype="CylY",
        energycost=21000,
        metalcost=1400,
        weapondefs= {
            railgunt2= {
                collidefriendly=0,
                collidefeature=0,
                avoidfeature=0,
                avoidfriendly=0,
                range=725,
                reloadtime=3,
                energypershot=200,
                damage= {
                    default=1500
                }
            }
        },
        weapons= {[1]= {
                def="railgunt2",
                onlytargetcategory="SURFACE"
            }
        }
    },
    cormwall= {
        energycost=18000,
        metalcost=1350,
        weapondefs= {
            exp_heavyrocket= {
                areaofeffect=70,
                collidefriendly=0,
                collidefeature=0,
                cameraShake=0,
                energypershot=125,
                avoidfeature=0,
                avoidfriendly=0,
                burst=1,
                burstrate=0,
                colormap='0.75 0.73 0.67 0.024   0.37 0.4 0.30 0.021   0.22 0.21 0.14 0.018  0.024 0.014 0.009 0.03   0.0 0.0 0.0 0.008',
                craterareaofeffect=0,
                explosiongenerator='custom:burnblack',
                flamegfxtime=1,
                flighttime=1.05,
                name='Raptor Boomer',
                reloadtime=1.5,
                rgbcolor='1 0.25 0.1',
                range=700,
                size=2,
                proximitypriority=nil,
                impactonly=1,
                trajectoryheight=1,
                targetmoveerror=0.2,
                tracks=true,
                weaponacceleration=660,
                weaponvelocity=950,
                damage= {
                    default=1050
                }
            }
        }
    },
    cormaw= {
        collisionvolumeoffsets='0 -2 0',
        collisionvolumescales='30 51 30',
        collisionvolumetype='Ell',
        usepiececollisionvolumes=false,
        metalcost=350,
        energycost=2500,
        weapondefs= {
            dmaw= {
                collidefriendly=0,
                collidefeature=0,
                areaofeffect=80,
                edgeeffectiveness=0.45,
                energypershot=50,
                burst=24,
                rgbcolor='0.051 0.129 0.871',
                rgbcolor2='0.57 0.624 1',
                sizegrowth=0.80,
                range=450,
                intensity=0.68,
                damage= {
                    default=28
                }
            }
        }
    },
    legdtf= {
        collisionvolumeoffsets='0 -24 0',
        collisionvolumescales='30 51 30',
        collisionvolumetype='Ell',
        metalcost=350,
        energycost=2750,
        weapondefs= {
            dmaw= {
                collidefriendly=0,
                collidefeature=0,
                areaofeffect=80,
                edgeeffectiveness=0.45,
                energypershot=50,
                burst=24,
                sizegrowth=2,
                range=450,
                intensity=0.38,
                sprayangle=500,
                damage= {
                    default=30
                }
            }
        }
    },
    corhllllt= {
        collisionvolumeoffsets='0 -24 0',
        collisionvolumescales='30 51 30',
        metalcost=415,
        energycost=9500,
        buildtime=10000,
        health=2115
    },
    corhlt= {
        energycost=5500,
        metalcost=520,
        weapondefs= {
            cor_laserh1= {
                range=750,
                reloadtime=0.95,
                damage= {
                    default=395,
                    vtol=35
                }
            }
        }
    },
    armhlt= {
        energycost=5700,
        metalcost=510,
        weapondefs= {
            arm_laserh1= {
                range=750,
                reloadtime=1,
                damage= {
                    default=405,
                    vtol=35
                }
            }
        }
    },
    armbrtha= {
        explodeas='fusionExplosion',
        energycost=500000,
        metalcost=18500,
        buildtime=175000,
        turnrate=16000,
        health=10450,
        weapondefs= {
            ARMBRTHA_MAIN= {
                areaofeffect=50,
                collidefriendly=0,
                collidefeature=0,
                avoidfeature=0,
                avoidfriendly=0,
                beamtime=2.5,
                corethickness=0.1,
                craterareaofeffect=90,
                craterboost=0,
                cratermult=0,
                cameraShake=0,
                edgeeffectiveness=0.30,
                energypershot=14000,
                explosiongenerator='custom:laserhit-large-blue',
                firestarter=90,
                impulseboost=0,
                impulsefactor=0,
                largebeamlaser=true,
                laserflaresize=1,
                impactonly=1,
                name='Experimental Duction Beam',
                noselfdamage=true,
                range=2400,
                reloadtime=13,
                rgbcolor='0.4 0.2 0.6',
                scrollspeed=13,
                soundhitdry="",
                soundhitwet="sizzle",
                soundstart="hackshotxl3",
                soundtrigger=1,
                targetmoveerror=0.3,
                texture3='largebeam',
                thickness=14,
                tilelength=150,
                tolerance=10000,
                turret=true,
                turnrate=16000,
                weapontype='LaserCannon',
                weaponvelocity=3100,
                damage= {
                    commanders=480,
                    default=34000
                }
            }
        },
        weapons= {[1]= {
                badtargetcategory='VTOL GROUNDSCOUT',
                def='ARMBRTHA_MAIN',
                onlytargetcategory='SURFACE'
            }
        }
    },
    corint= {
        explodeas='fusionExplosion',
        energycost=505000,
        metalcost=19500,
        buildtime=170000,
        health=12450,
        footprintx=6,
        footprintz=6,
        weapondefs= {
            CORINT_MAIN= {
                areaofeffect=70,
                collidefriendly=0,
                collidefeature=0,
                avoidfeature=0,
                avoidfriendly=0,
                beamtime=2.5,
                corethickness=0.1,
                craterareaofeffect=90,
                craterboost=0,
                cratermult=0,
                cameraShake=0,
                edgeeffectiveness=0.30,
                energypershot=17000,
                explosiongenerator='custom:laserhit-large-blue',
                firestarter=90,
                impulseboost=0,
                impulsefactor=0,
                largebeamlaser=true,
                laserflaresize=1,
                impactonly=1,
                name='Mini DeathStar',
                noselfdamage=true,
                range=2800,
                reloadtime=15,
                rgbcolor='0 1 0',
                scrollspeed=13,
                soundhitdry='',
                soundhitwet='sizzle',
                soundstart='annigun1',
                soundtrigger=1,
                targetmoveerror=0.3,
                texture3='largebeam',
                thickness=14,
                tilelength=150,
                tolerance=10000,
                turret=true,
                turnrate=1600,
                weapontype='LaserCannon',
                weaponvelocity=3100,
                damage= {
                    commanders=480,
                    default=50000
                }
            }
        },
        weapons= {[1]= {
                badtargetcategory='VTOL GROUNDSCOUT',
                def='CORINT_MAIN',
                onlytargetcategory='SURFACE'
            }
        }
    },
    leglrpc= {
        explodeas='fusionExplosion',
        energycost=555000,
        metalcost=21000,
        buildtime=150000,
        health=11000,
        footprintx=6,
        footprintz=6,
        weapondefs= {
            LEGLRPC_MAIN= {
                areaofeffect=70,
                collidefriendly=0,
                collidefeature=0,
                avoidfeature=0,
                avoidfriendly=0,
                beamtime=0.5,
                burst=3,
                burstrate=0.4,
                corethickness=0.1,
                craterareaofeffect=90,
                craterboost=0,
                cratermult=0,
                cameraShake=0,
                edgeeffectiveness=0.30,
                energypershot=10000,
                explosiongenerator='custom:laserhit-large-red',
                firestarter=90,
                impactonly=1,
                impulseboost=0,
                impulsefactor=0,
                largebeamlaser=true,
                laserflaresize=1,
                name='The Eagle Standard',
                noselfdamage=true,
                range=2150,
                reloadtime=3,
                rgbcolor='0/1/0.4',
                scrollspeed=13,
                soundhitdry='',
                soundhitwet='sizzle',
                soundstart='lasrcrw1',
                soundtrigger=1,
                targetmoveerror=0.3,
                texture3='largebeam',
                thickness=12,
                tilelength=150,
                tolerance=10000,
                turret=true,
                turnrate=16000,
                weapontype='LaserCannon',
                weaponvelocity=3100,
                damage= {
                    commanders=480,
                    default=6000
                }
            }
        },
        weapons= {[1]= {
                badtargetcategory='VTOL GROUNDSCOUT',
                def='LEGLRPC_MAIN',
                onlytargetcategory='SURFACE'
            }
        }
	}
}
-- MAIN_UNITS_END

                if UnitDefs and newUnits then
                    for name, def in pairs(newUnits) do
                        if UnitDefs[name] then
                            table.mergeInPlace(UnitDefs[name], def)
                        else
                            UnitDefs[name] = def
                        end
                    end
                end


-- Tweak: Units_NuttyB_Evolving_Commanders_Armada.lua

                local newUnits = -- ARMADA_COMMANDER_START
--NuttyB v1.52c Armada Com
{
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
-- ARMADA_COMMANDER_END

                if UnitDefs and newUnits then
                    for name, def in pairs(newUnits) do
                        if UnitDefs[name] then
                            table.mergeInPlace(UnitDefs[name], def)
                        else
                            UnitDefs[name] = def
                        end
                    end
                end


-- Tweak: Units_NuttyB_Evolving_Commanders_Cortex.lua

                local newUnits = -- CORTEX_COMMANDER_START
--NuttyB v1.52c Cortex Com
{
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
        weapontimer = 4.2,
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
-- CORTEX_COMMANDER_END

                if UnitDefs and newUnits then
                    for name, def in pairs(newUnits) do
                        if UnitDefs[name] then
                            table.mergeInPlace(UnitDefs[name], def)
                        else
                            UnitDefs[name] = def
                        end
                    end
                end


-- Tweak: Units_NuttyB_Evolving_Commanders_Legion.lua

                local newUnits = -- LEGION_COMMANDER_START
--NuttyB v1.52c Legion Com
{
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



-- LEGION_COMMANDER_END

                if UnitDefs and newUnits then
                    for name, def in pairs(newUnits) do
                        if UnitDefs[name] then
                            table.mergeInPlace(UnitDefs[name], def)
                        else
                            UnitDefs[name] = def
                        end
                    end
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
