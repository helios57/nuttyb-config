function gadget:GetInfo()
  return {
    name      = "Optimized Raptor AI",
    desc      = "Raptor AI with Time-Slicing, Spatial Partitioning, and Squad Logic",
    author    = "NuttyB Team (Optimized by Jules)",
    date      = "2024",
    license   = "GPL",
    layer     = 0,
    enabled   = true
  }
end

if (not gadgetHandler:IsSyncedCode()) then
  return
end

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
local spGetUnitNearestEnemy = Spring.GetUnitNearestEnemy

-- Constants
local RAPTOR_TEAM_ID = Spring.GetGaiaTeamID()
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
function gadget:UnitCreated(unitID, unitDefID, teamID)
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
function gadget:UnitDestroyed(unitID, unitDefID, teamID)
    if raptorUnits[unitID] then
        raptorUnits[unitID] = nil
        if unitID == currentLeaderID then
            currentLeaderID = nil -- Next spawn will start new squad
            currentSquadCount = SQUAD_SIZE -- Force new squad creation
        end
    end
end

-- GameFrame: Time-Slicing Scheduler
function gadget:GameFrame(n)
    local currentBucket = n % BUCKET_COUNT

    for id, data in pairs(raptorUnits) do
        if data.bucket == currentBucket then
            ProcessUnit(id)
        end
    end
end
