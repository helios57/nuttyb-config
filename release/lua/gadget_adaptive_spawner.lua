function gadget:GetInfo()
  return {
    name      = "Adaptive Raptor Spawner",
    desc      = "Compresses raptor waves dynamically to reduce entity count",
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

local GAIA_TEAM_ID = spGetGaiaTeamID()

-- Counters for each unit type
local spawnCounters = {}

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

function gadget:UnitCreated(unitID, unitDefID, teamID)
    if teamID ~= GAIA_TEAM_ID then return end

    local ud = UnitDefs[unitDefID]
    if not ud then return end

    -- Check if this is a compressible raptor
    -- (We don't want to compress already compressed units!)
    if ud.customParams and ud.customParams.is_compressed_unit then return end

    -- Filter: Only apply to known raptors to avoid deleting bosses or special units
    if not (string.find(ud.name, "raptor_land") or string.find(ud.name, "raptor_air")) then
        return
    end

    -- Determine compression factor based on unit count
    local unitCount = spGetUnitCount()
    local factor = 1
    if unitCount > 3000 then factor = 10
    elseif unitCount > 1500 then factor = 5
    elseif unitCount > 800 then factor = 2
    end

    if factor == 1 then return end

    -- Verify if a compressed variant exists
    local compressedID = GetCompressedDefID(unitDefID, factor)
    if not compressedID then
        -- Fallback: try lower factors if high factor doesn't exist
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

    -- Logic: We need to accumulate 'factor' units, then spawn 1 compressed.
    spawnCounters[unitDefID] = (spawnCounters[unitDefID] or 0) + 1

    if spawnCounters[unitDefID] >= factor then
        -- Spawn compressed unit
        local x, y, z = spGetUnitPosition(unitID)
        spCreateUnit(compressedID, x, y, z, 0, teamID)
        -- Reset counter
        spawnCounters[unitDefID] = 0
    end

    -- Always destroy the original unit (since we are replacing N units with 0 or 1)
    spDestroyUnit(unitID, false, true)
end
