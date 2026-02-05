local sgmo=Spring.GetModOptions
local tm=table.merge
local ip=ipairs
local mc=math.ceil
local mf=math.floor
local mM=math.max
local p=pairs
local sl=string.len
local sm=string.match
local ss=string.sub
local ti=table.insert
local k_customparams="customparams"
local k_buildoptions="buildoptions"
local k_arm_botrail="arm_botrail"
local k_type="type"
local k_health="health"
local k_i18n_en_humanname="i18n_en_humanname"
local k_name="name"
if UnitDefs["raptor_land_swarmer_basic_t1_v1"]then
local newDef=tm({},UnitDefs["raptor_land_swarmer_basic_t1_v1"])
newDef[k_name]="Hive Spawn"
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]="Hive Spawn"
cp["i18n_en_tooltip"]="Raptor spawned to defend hives from attackers."
UnitDefs["raptor_hive_swarmer_basic"]=newDef
end
if UnitDefs["raptor_land_assault_basic_t2_v1"]then
local newDef=tm({},UnitDefs["raptor_land_assault_basic_t2_v1"])
newDef[k_name]="Armored Assault Raptor"
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]="Armored Assault Raptor"
cp["i18n_en_tooltip"]="Heavy, slow, and unyielding—these beasts are made to take the hits others cant."
UnitDefs["raptor_hive_assault_basic"]=newDef
end
if UnitDefs["armannit3"]then
local newDef=tm({},UnitDefs["armannit3"])
newDef[k_name]="Legendary Pulsar"
newDef.description="A pinnacle of Armada engineering that fires devastating, rapid-fire tachyon bolts."
newDef.buildTime=300000
newDef[k_health]=30000
newDef.metalCost=43840
newDef.energyCost=1096000
newDef.icontype="armannit3"
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]="Legendary Pulsar"
cp["i18n_en_tooltip"]="Fires devastating, rapid-fire tachyon bolts."
cp["techlevel"]=4
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="tachyon_burst_cannon" then
wDef[k_name]="Tachyon Burst Cannon"
wDef.damage={default=8000}
wDef.burst=3
wDef.burstrate=0.4
wDef.reloadtime=5
wDef.range=1800
wDef.energypershot=12000
end
end
end
UnitDefs["legendary_pulsar"]=newDef
end
if UnitDefs["legbastion"]then
local newDef=tm({},UnitDefs["legbastion"])
newDef[k_name]="Legendary Bastion"
newDef.description="The ultimate defensive emplacement. Projects a devastating, pulsating heatray."
newDef[k_health]=22000
newDef.metalCost=65760
newDef.energyCost=1986500
newDef.buildTime=180000
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]="Legendary Bastion"
cp["i18n_en_tooltip"]="Projects a devastating, pulsating purple heatray."
cp["maxrange"]=1450
cp["techlevel"]=4
UnitDefs["legendary_bastion"]=newDef
end
if UnitDefs["cordoomt3"]then
local newDef=tm({},UnitDefs["cordoomt3"])
newDef[k_name]="Legendary Bulwark"
newDef.description="A pinnacle of defensive technology, the Legendary Bulwark annihilates all who approach."
newDef[k_health]=42000
newDef.metalCost=61650
newDef.energyCost=1712500
newDef.buildTime=250000
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]="Legendary Bulwark"
cp["i18n_en_tooltip"]="The ultimate defensive structure."
cp["paralyzemultiplier"]=0.2
cp["techlevel"]=4
UnitDefs["legendary_bulwark"]=newDef
end
if UnitDefs["raptor_matriarch_basic"]then
local newDef=tm({},UnitDefs["raptor_matriarch_basic"])
newDef[k_name]="Queenling Prima"
newDef.icontype="raptor_queen_veryeasy"
newDef[k_health]=newDef[k_health]*(5)
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]="Queenling Prima"
cp["i18n_en_tooltip"]="Majestic and bold, ruler of the hunt."
newDef.maxThisUnit=(mM(1,mc(2*((sgmo().raptor_spawncountmult or 3)/3))))
UnitDefs["raptor_miniq_a"]=newDef
end
if UnitDefs["raptor_matriarch_basic"]then
local newDef=tm({},UnitDefs["raptor_matriarch_basic"])
newDef[k_name]="Queenling Secunda"
newDef.icontype="raptor_queen_easy"
newDef[k_health]=newDef[k_health]*(6)
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]="Queenling Secunda"
cp["i18n_en_tooltip"]="Swift and sharp, a noble among raptors."
newDef.maxThisUnit=(mM(1,mc(3*((sgmo().raptor_spawncountmult or 3)/3))))
UnitDefs["raptor_miniq_b"]=newDef
end
if UnitDefs["raptor_matriarch_basic"]then
local newDef=tm({},UnitDefs["raptor_matriarch_basic"])
newDef[k_name]="Queenling Tertia"
newDef.icontype="raptor_queen_normal"
newDef[k_health]=newDef[k_health]*(7)
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]="Queenling Tertia"
cp["i18n_en_tooltip"]="Refined tastes. Likes her prey rare."
newDef.maxThisUnit=(mM(1,mc(4*((sgmo().raptor_spawncountmult or 3)/3))))
UnitDefs["raptor_miniq_c"]=newDef
end
if UnitDefs["armnanotct2"]then
local newDef=tm({},UnitDefs["armnanotct2"])
newDef.metalcost=3700
newDef.energycost=62000
newDef.builddistance=550
newDef.buildtime=108000
newDef[k_health]=8800
newDef.workertime=1900
newDef[k_customparams]={[k_i18n_en_humanname]="T3 Construction Turret"}
UnitDefs["armnanotct3"]=newDef
end
if UnitDefs["cornanotct2"]then
local newDef=tm({},UnitDefs["cornanotct2"])
newDef.metalcost=3700
newDef.energycost=62000
newDef.builddistance=550
newDef.buildtime=108000
newDef[k_health]=8800
newDef.workertime=1900
newDef[k_customparams]={[k_i18n_en_humanname]="T3 Construction Turret"}
UnitDefs["cornanotct3"]=newDef
end
if UnitDefs["legnanotct2"]then
local newDef=tm({},UnitDefs["legnanotct2"])
newDef.metalcost=3700
newDef.energycost=62000
newDef.builddistance=550
newDef.buildtime=108000
newDef[k_health]=8800
newDef.workertime=1900
newDef[k_customparams]={[k_i18n_en_humanname]="T3 Construction Turret"}
UnitDefs["legnanotct3"]=newDef
end
if UnitDefs["armdecom"]then
local newDef=tm({},UnitDefs["armdecom"])
newDef[k_name]="Armada Epic Aide"
newDef.workertime=6000
newDef[k_buildoptions]={"armafust3","armnanotct2","armnanotct3","armalab","armavp","armaap","armgatet3","armflak","armmmkrt3","armuwadvmst3","armadvestoret3","armgate","armfort","armshltx","corgant_taxed","leggant_taxed","armamd","armmercury","armbrtha","armminivulc","armvulc","armanni","armannit3","armlwall","legendary_pulsar"}
UnitDefs["armt3aide"]=newDef
end
if UnitDefs["cordecom"]then
local newDef=tm({},UnitDefs["cordecom"])
newDef[k_name]="Cortex Epic Aide"
newDef.workertime=6000
newDef[k_buildoptions]={"corafust3","cornanotct2","cornanotct3","coralab","coravp","coraap","corgatet3","corflak","cormmkrt3","coruwadvmst3","coradvestoret3","corgate","corfort","corgant","armshltx_taxed","leggant_taxed","corfmd","corscreamer","cordoomt3","corbuzz","corminibuzz","corint","cordoom","corhllllt","cormwall","legendary_bulwark"}
UnitDefs["cort3aide"]=newDef
end
if UnitDefs["legdecom"]then
local newDef=tm({},UnitDefs["legdecom"])
newDef[k_name]="Legion Epic Aide"
newDef.workertime=6000
newDef[k_buildoptions]={"legafust3","legnanotct2","legnanotct3","legalab","legavp","legaap","leggatet3","legflak","legadveconvt3","legamstort3","legadvestoret3","legdeflector","legforti","leggant","armshltx_taxed","corgant_taxed","legabm","legstarfall","legministarfall","leglraa","legbastion","legrwall","leglrpc","legendary_bastion","legapopupdef","legdtf"}
UnitDefs["legt3aide"]=newDef
end
if UnitDefs["armbotrail"]then
local newDef=tm({},UnitDefs["armbotrail"])
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]="Meatball Launcher"
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.range=7550
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.metalpershot=5300
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.energypershot=96000
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.reloadtime=0.5
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
local cp=wDef.customparams
if not cp then
if wDef.customParams then
cp=wDef.customParams
wDef.customparams=cp
else
cp={}
wDef.customparams=cp
end
end
cp["stockpilelimit"]=50
cp["spawns_name"]="armmeatball"
end
end
end
UnitDefs["armmeatball"]=newDef
end
if UnitDefs["armbotrail"]then
local newDef=tm({},UnitDefs["armbotrail"])
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]="Assimilator Launcher"
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.range=7550
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.metalpershot=4500
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.energypershot=80000
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.reloadtime=0.5
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
local cp=wDef.customparams
if not cp then
if wDef.customParams then
cp=wDef.customParams
wDef.customparams=cp
else
cp={}
wDef.customparams=cp
end
end
cp["stockpilelimit"]=50
cp["spawns_name"]="armassimilator"
end
end
end
UnitDefs["armassimilator"]=newDef
end
if UnitDefs["armbotrail"]then
local newDef=tm({},UnitDefs["armbotrail"])
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]="Epic Pawn Launcher"
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.range=7550
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.metalpershot=14200
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.energypershot=480000
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.reloadtime=0.5
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
local cp=wDef.customparams
if not cp then
if wDef.customParams then
cp=wDef.customParams
wDef.customparams=cp
else
cp={}
wDef.customparams=cp
end
end
cp["stockpilelimit"]=50
cp["spawns_name"]="armpwt4"
end
end
end
UnitDefs["armpwt4"]=newDef
end
if UnitDefs["armbotrail"]then
local newDef=tm({},UnitDefs["armbotrail"])
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]="Armada T1 Launcher"
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.stockpiletime=0.5
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.range=7550
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.metalpershot=250
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.energypershot=12500
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
wDef.reloadtime=0.5
end
end
end
if newDef.weapondefs then
for wName,wDef in p(newDef.weapondefs)do
if wName=="arm_botrail" then
local cp=wDef.customparams
if not cp then
if wDef.customParams then
cp=wDef.customParams
wDef.customparams=cp
else
cp={}
wDef.customparams=cp
end
end
cp["stockpilelimit"]=50
cp["spawns_name"]="armham armjeth armpw armrock armwar armah armanac armmh armsh armart armfav armflash armjanus armpincer armsam armstump armzapper"
cp["spawns_mode"]="random"
end
end
end
UnitDefs["armt1"]=newDef
end
if UnitDefs["raptor_antinuke"]then
local def=UnitDefs["raptor_antinuke"]
local name="raptor_antinuke"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_acid_t2_v1"]then
local def=UnitDefs["raptor_turret_acid_t2_v1"]
local name="raptor_turret_acid_t2_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_acid_t3_v1"]then
local def=UnitDefs["raptor_turret_acid_t3_v1"]
local name="raptor_turret_acid_t3_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_acid_t4_v1"]then
local def=UnitDefs["raptor_turret_acid_t4_v1"]
local name="raptor_turret_acid_t4_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_antiair_t2_v1"]then
local def=UnitDefs["raptor_turret_antiair_t2_v1"]
local name="raptor_turret_antiair_t2_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_antiair_t3_v1"]then
local def=UnitDefs["raptor_turret_antiair_t3_v1"]
local name="raptor_turret_antiair_t3_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_antiair_t4_v1"]then
local def=UnitDefs["raptor_turret_antiair_t4_v1"]
local name="raptor_turret_antiair_t4_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_antinuke_t2_v1"]then
local def=UnitDefs["raptor_turret_antinuke_t2_v1"]
local name="raptor_turret_antinuke_t2_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_antinuke_t3_v1"]then
local def=UnitDefs["raptor_turret_antinuke_t3_v1"]
local name="raptor_turret_antinuke_t3_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_basic_t2_v1"]then
local def=UnitDefs["raptor_turret_basic_t2_v1"]
local name="raptor_turret_basic_t2_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_basic_t3_v1"]then
local def=UnitDefs["raptor_turret_basic_t3_v1"]
local name="raptor_turret_basic_t3_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_basic_t4_v1"]then
local def=UnitDefs["raptor_turret_basic_t4_v1"]
local name="raptor_turret_basic_t4_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_burrow_t2_v1"]then
local def=UnitDefs["raptor_turret_burrow_t2_v1"]
local name="raptor_turret_burrow_t2_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_emp_t2_v1"]then
local def=UnitDefs["raptor_turret_emp_t2_v1"]
local name="raptor_turret_emp_t2_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_emp_t3_v1"]then
local def=UnitDefs["raptor_turret_emp_t3_v1"]
local name="raptor_turret_emp_t3_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_turret_emp_t4_v1"]then
local def=UnitDefs["raptor_turret_emp_t4_v1"]
local name="raptor_turret_emp_t4_v1"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["raptor_worm_green"]then
local def=UnitDefs["raptor_worm_green"]
local name="raptor_worm_green"
def.maxThisUnit=10
def[k_health]=def[k_health]*(2)
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=wDef.reloadtime*(0.666666)
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.range=wDef.range*(0.5)
end
end
end
if UnitDefs["armt3airaide"]then
local def=UnitDefs["armt3airaide"]
local name="armt3airaide"
if ss(name,1,9)=="armcomlvl" then
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"legendary_pulsar")
end
end
if UnitDefs["cort3airaide"]then
local def=UnitDefs["cort3airaide"]
local name="cort3airaide"
if ss(name,1,9)=="corcomlvl" then
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"legendary_bulwark")
end
end
if UnitDefs["legt3airaide"]then
local def=UnitDefs["legt3airaide"]
local name="legt3airaide"
if ss(name,1,9)=="legcomlvl" then
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"legendary_bastion")
end
end
if UnitDefs["armmmkrt3"]then
local def=UnitDefs["armmmkrt3"]
local name="armmmkrt3"
def.footprintx=6
def.footprintz=6
end
if UnitDefs["cormmkrt3"]then
local def=UnitDefs["cormmkrt3"]
local name="cormmkrt3"
def.footprintx=6
def.footprintz=6
end
if UnitDefs["legadveconvt3"]then
local def=UnitDefs["legadveconvt3"]
local name="legadveconvt3"
def.footprintx=6
def.footprintz=6
end
if UnitDefs["armack"]then
local def=UnitDefs["armack"]
local name="armack"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"armafust3")
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"armmmkrt3")
end
if UnitDefs["armaca"]then
local def=UnitDefs["armaca"]
local name="armaca"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"armafust3")
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"armmmkrt3")
end
if UnitDefs["armacv"]then
local def=UnitDefs["armacv"]
local name="armacv"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"armafust3")
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"armmmkrt3")
end
if UnitDefs["corack"]then
local def=UnitDefs["corack"]
local name="corack"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"corafust3")
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"cormmkrt3")
end
if UnitDefs["coraca"]then
local def=UnitDefs["coraca"]
local name="coraca"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"corafust3")
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"cormmkrt3")
end
if UnitDefs["coracv"]then
local def=UnitDefs["coracv"]
local name="coracv"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"corafust3")
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"cormmkrt3")
end
if UnitDefs["legack"]then
local def=UnitDefs["legack"]
local name="legack"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"legafust3")
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"legadveconvt3")
end
if UnitDefs["legaca"]then
local def=UnitDefs["legaca"]
local name="legaca"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"legafust3")
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"legadveconvt3")
end
if UnitDefs["legacv"]then
local def=UnitDefs["legacv"]
local name="legacv"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"legafust3")
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"legadveconvt3")
end
if UnitDefs["legck"]then
local def=UnitDefs["legck"]
local name="legck"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"legdtf")
end
if UnitDefs["coruwadves"]then
local def=UnitDefs["coruwadves"]
local name="coruwadves"
def.footprintx=4
def.footprintz=4
end
if UnitDefs["legadvestore"]then
local def=UnitDefs["legadvestore"]
local name="legadvestore"
def.footprintx=4
def.footprintz=4
end
if UnitDefs["armshltx"]then
local def=UnitDefs["armshltx"]
local name="armshltx"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"armt3aide")
end
if UnitDefs["corgant"]then
local def=UnitDefs["corgant"]
local name="corgant"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"cort3aide")
end
if UnitDefs["leggant"]then
local def=UnitDefs["leggant"]
local name="leggant"
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"legt3aide")
end
for id,def in p(UnitDefs)do
local name=def.name or id
if sm(name,"raptor_queen")then
def.repairable=false
def.canbehealed=false
def.buildTime=9999999
def.autoHeal=2
def.canSelfRepair=false
def.health=def.health*(2)
end
if sm(name,"alpha_unit")then
def.repairable=false
def.canbehealed=false
def.buildTime=9999999
def.autoHeal=2
def.canSelfRepair=false
def.health=def.health*(2)
end
if sm(name,"swarmer_heal")then
def.reclaimSpeed=100
def.stealth=false
def.builder=false
def.buildSpeed=def.buildSpeed*(1.2)
def.canAssist=false
def.maxThisUnit=0
end
if((def.customParams and def.customParams["subfolder"]=="other/raptors")or(def.customparams and def.customparams["subfolder"]=="other/raptors"))and not sm(name,"^raptor_queen_.*")then
def.health=def.health*(1.5)
end
if((def.customParams and def.customParams["subfolder"]=="other/raptors")or(def.customparams and def.customparams["subfolder"]=="other/raptors"))then
def.noChaseCategory="OBJECT"
if def[k_health]then
def.metalCost=mf(def[k_health]*0.9)
end
end
if ss(name,1,sl("arm"))=="arm" then
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"armwar")
end
if ss(name,1,24)=="raptor_air_fighter_basic" then
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef[k_name]="Spike"
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.accuracy=200
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.collidefriendly=0
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.collidefeature=0
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.avoidfeature=0
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.avoidfriendly=0
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.areaofeffect=64
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.edgeeffectiveness=0.3
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.explosiongenerator="custom:raptorspike-large-sparks-burn"
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.cameraShake={}
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.dance={}
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.interceptedbyshieldtype=0
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.model="Raptors/spike.s3o"
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.reloadtime=1.1
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.soundstart="talonattack"
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.startvelocity=200
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.submissile=1
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.smoketrail=0
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.smokePeriod={}
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.smoketime={}
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.smokesize={}
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.smokecolor={}
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.soundhit={}
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.texture1={}
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.texture2={}
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.tolerance={}
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.tracks=0
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.turnrate=60000
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.weaponacceleration=100
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.weapontimer=1
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.weaponvelocity=1000
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.weapontype={}
end
end
if def.weapondefs then
for wName,wDef in p(def.weapondefs)do
wDef.wobble={}
end
end
end
if sm(name,"^[acl][ore][rgm]com")and not sm(name,"_scav$")then
if not def.customparams then def.customparams={}end
tm(def.customparams,{combatradius=0,fall_damage_multiplier=0,paratrooper=true,wtboostunittype={}})
if not def.featuredefs then def.featuredefs={}end
tm(def.featuredefs,{dead={damage=9999999,reclaimable=false,mass=9999999}})
end
if def.builder==true and def.canfly==true then
def.explodeAs=""
def.selfDestructAs=""
end
if((def.customParams and def.customParams["techlevel"]==2)or(def.customparams and def.customparams["techlevel"]==2))and((def.customParams and def.customParams["subfolder"]and sm(def.customParams["subfolder"],"Fact"))or(def.customparams and def.customparams["subfolder"]and sm(def.customparams["subfolder"],"Fact")))and not sm(name,".* %(Taxed%)$")then
if def then
local newDef=tm({},def)
newDef.energyCost=newDef.energyCost*(1.7)
newDef.metalCost=newDef.metalCost*(1.7)
newDef[k_name]=(name .. ' (Taxed)')
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]=(def.customparams.i18n_en_humanname .. ' (Taxed)')
UnitDefs[def.name .. "_taxed"]=newDef
end
end
if((def.customParams and def.customParams["techlevel"]==2)or(def.customparams and def.customparams["techlevel"]==2))and((def.customParams and def.customParams["subfolder"]and sm(def.customParams["subfolder"],"Lab"))or(def.customparams and def.customparams["subfolder"]and sm(def.customparams["subfolder"],"Lab")))and not sm(name,".* %(Taxed%)$")then
if def then
local newDef=tm({},def)
newDef.energyCost=newDef.energyCost*(1.7)
newDef.metalCost=newDef.metalCost*(1.7)
newDef[k_name]=(name .. ' (Taxed)')
local cp=newDef.customparams
if not cp then
if newDef.customParams then
cp=newDef.customParams
newDef.customparams=cp
else
cp={}
newDef.customparams=cp
end
end
cp[k_i18n_en_humanname]=(def.customparams.i18n_en_humanname .. ' (Taxed)')
UnitDefs[def.name .. "_taxed"]=newDef
end
end
if sm(name,"cormandot4")then
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"armmeatball")
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"armassimilator")
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"armpwt4")
local target_list=def[k_buildoptions]
if not target_list then
def.buildoptions={}
target_list=def.buildoptions
end
ti(target_list,"armt1")
end
end
local function ApplyTweaks_Post(name,def)
if ss(name,1,15)=="scavengerbossv4" then
def.health=def.health*(2)
end
if ss(name,-5)=="_scav" and not sm(name,"^scavengerbossv4")then
if def[k_health]then
def[k_health]=mf(def[k_health]*2)
end
end
if ss(name,-5)=="_scav" then
if def.metalCost then
def.metalCost=mf(def.metalCost*2)
end
def.noChaseCategory="OBJECT"
end
end
if UnitDef_Post then
local prev_UnitDef_Post=UnitDef_Post
UnitDef_Post=function(name,def)
prev_UnitDef_Post(name,def)
ApplyTweaks_Post(name,def)
end
else
UnitDef_Post=ApplyTweaks_Post
end