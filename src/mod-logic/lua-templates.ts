export const luaQhpTemplate = `--NuttyB v1.52 __MULTIPLIER_TEXT__X QHP
-- docs.google.com/spreadsheets/d/1QSVsuAAMhBrhiZdTihVfSCwPzbbZWDLCtXWP23CU0ko
for b, c in pairs(UnitDefs) do
	if b:match('^raptor_queen_.*') then
		c.repairable = false
		c.canbehealed = false
		c.buildtime = 9999999
		c.autoheal = 2
		c.canSelfRepair = false
		c.health = c.health * __HEALTH_MULTIPLIER__
	end
end`;

export const luaHpTemplate = `--NuttyB v1.52 __MULTIPLIER_TEXT__X HP
-- docs.google.com/spreadsheets/d/1QSVsuAAMhBrhiZdTihVfSCwPzbbZWDLCtXWP23CU0ko
for unitName, unitDef in pairs(UnitDefs) do
    if string.sub(unitName, 1, 24) == "raptor_land_swarmer_heal" then
        unitDef.reclaimspeed = 100
        unitDef.stealth = false
        unitDef.builder = false
        unitDef.workertime = unitDef.workertime * __WORKERTIME_MULTIPLIER__
        unitDef.canassist = false
        unitDef.maxthisunit = 0
    end

    if unitDef.customparams and unitDef.customparams.subfolder == "other/raptors" and unitDef.health and not unitName:match('^raptor_queen_.*') then
        unitDef.health = unitDef.health * __HEALTH_MULTIPLIER__
        --unitDef.sfxtypes = {}
        --unitDef.explodas = unitDef.explodas
    end
end

local oldUnitDef_Post = UnitDef_Post
function UnitDef_Post(unitID, unitDef)
    if oldUnitDef_Post and oldUnitDef_Post ~= UnitDef_Post then
        oldUnitDef_Post(unitID, unitDef)
    end

    if unitDef.customparams and unitDef.customparams.subfolder == "other/raptors" then
        unitDef.nochasecategory = "OBJECT"
        if unitDef.metalcost and unitDef.health then
            unitDef.metalcost = math.floor(unitDef.health * __METAL_COST_FACTOR__)
        end
    end
end`;

export const luaBossHpTemplate = `--Scav Boss HP __MULTIPLIER_TEXT__X
local originalUnitDef_Post = UnitDef_Post

function UnitDef_Post(unitName, unitDef)
	originalUnitDef_Post(unitName, unitDef)
	if unitDef.health and unitName:match("^scavengerbossv4") then
		unitDef.health = math.floor(unitDef.health * __HEALTH_MULTIPLIER__)
	end
end`;

export const luaScavHpTemplate = `--Scavengers HP __MULTIPLIER_TEXT__X
local originalUnitDef_Post = UnitDef_Post

function UnitDef_Post(unitName, unitDef)
	originalUnitDef_Post(unitName, unitDef)
	if unitDef.health and unitName:match("_scav$") and not unitName:match("^scavengerbossv4") then
		unitDef.health = math.floor(unitDef.health * __HEALTH_MULTIPLIER__)
	end 
	if unitName:match("_scav$") then
		if unitDef.metalcost and type(unitDef.metalcost) == "number" then
 			unitDef.metalcost = math.floor(unitDef.metalcost * __HEALTH_MULTIPLIER__)
    		end
		unitDef.nochasecategory = "OBJECT"
	end
end`;
