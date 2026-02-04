function gadget:GetInfo()
  return {
    name      = "Adaptive Raptor Spawner",
    desc      = "Compresses raptor waves dynamically based on SimSpeed/FPS",
    author    = "NuttyB Team",
    date      = "2024",
    license   = "GPL",
    layer     = 0,
    enabled   = true
  }
end

if (not gadgetHandler:IsSyncedCode()) then
  return
end

local modOptions = Spring.GetModOptions()
if not modOptions or (modOptions.adaptive_spawner ~= "1" and modOptions.adaptive_spawner ~= 1) then
    return
end

local spGetUnitCount = Spring.GetUnitCount
local spDestroyUnit = Spring.DestroyUnit
local spCreateUnit = Spring.CreateUnit
local spGetUnitPosition = Spring.GetUnitPosition
local spGetGaiaTeamID = Spring.GetGaiaTeamID
local spGetGameSpeed = Spring.GetGameSpeed
local spGetFPS = Spring.GetFPS

local GAIA_TEAM_ID = spGetGaiaTeamID()

-- Counters for each unit type
local spawnCounters = {}

-- Dynamic Compression State
local currentCompressionFactor = 1

-- Mapping logic
local function GetCompressedDefID(unitDefID, factor)
    local ud = UnitDefs[unitDefID]
    if not ud then return nil end
    local name = ud.name
    local suffix = "_compressed_x" .. factor
    local newName = name .. suffix
    local newDef = UnitDefNames[newName]
    return newDef and newDef.id or nil
end

function gadget:GameFrame(n)
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

        currentCompressionFactor = factor
    end
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
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
        spCreateUnit(compressedID, x, y, z, 0, teamID)
        -- Reset counter
        spawnCounters[unitDefID] = 0
    end

    -- Always destroy the original unit
    spDestroyUnit(unitID, false, true)
end
