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

local MAX_COMPRESSION = tonumber(modOptions.adaptive_compression_max) or 10
local VAMPIRE_ENABLED = (modOptions.adaptive_vampire == "1")
local BOSS_TINT_ENABLED = (modOptions.adaptive_boss_tint == "1")

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

        -- Clamp to User Configured Max
        if factor > MAX_COMPRESSION then
            factor = MAX_COMPRESSION
        end

        currentCompressionFactor = factor
    end
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
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

function gadget:UnitCollision(unitID, unitDefID, teamID, colliderID, colliderDefID, colliderTeamID)
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
