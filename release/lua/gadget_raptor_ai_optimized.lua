function gadget:GetInfo()
  return {
    name      = "Optimized Raptor AI",
    desc      = "Raptor AI with Time-Slicing and Spatial Partitioning",
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
local math_sqrt = math.sqrt
local math_abs = math.abs
local math_floor = math.floor

-- Constants
-- Ideally this is determined dynamically or via modoptions
local RAPTOR_TEAM_ID = Spring.GetGaiaTeamID()
local BUCKET_COUNT = 30
local GRID_SIZE = 512

-- State
local raptorUnits = {} -- Map: unitID -> data
local targetGrid = {} -- Map: gridKey -> list of unitIDs (targets)

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

-- Rebuild Grid (Periodic, e.g., every 30 frames or so to handle movement/death)
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

-- AI Logic for a single Raptor
local function ProcessRaptor(unitID)
    local x, _, z = spGetUnitPosition(unitID)
    if not x then return end

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
        -- Simple attack order
        spGiveOrderToUnit(unitID, CMD.ATTACK, {bestTarget}, {})
    else
        -- Move towards center or random if no target nearby
        -- Assuming map center is approximate target
        spGiveOrderToUnit(unitID, CMD.FIGHT, {Game.mapSizeX/2, 0, Game.mapSizeZ/2}, {})
    end
end

-- Event: UnitCreated
function gadget:UnitCreated(unitID, unitDefID, teamID)
    if teamID == RAPTOR_TEAM_ID then
        raptorUnits[unitID] = {
            id = unitID,
            bucket = unitID % BUCKET_COUNT
        }
    else
        RegisterTarget(unitID)
    end
end

-- Event: UnitDestroyed
function gadget:UnitDestroyed(unitID, unitDefID, teamID)
    if raptorUnits[unitID] then
        raptorUnits[unitID] = nil
    end
end

-- GameFrame: Time-Slicing Scheduler
function gadget:GameFrame(n)
    -- Rebuild target grid periodically
    if n % 30 == 0 then
        RebuildTargetGrid()
    end

    local currentBucket = n % BUCKET_COUNT

    for id, data in pairs(raptorUnits) do
        if data.bucket == currentBucket then
            ProcessRaptor(id)
        end
    end
end
