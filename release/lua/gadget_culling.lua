function gadget:GetInfo()
  return {
    name      = "Unit Culling System",
    desc      = "Destroys units to maintain performance",
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

local spGetGameFrame = Spring.GetGameFrame
local spGetGameSpeed = Spring.GetGameSpeed
local spDestroyUnit = Spring.DestroyUnit
local spGetTeamUnits = Spring.GetTeamUnits
local spGetGaiaTeamID = Spring.GetGaiaTeamID
local spGetUnitDefID = Spring.GetUnitDefID
local math_floor = math.floor

local modOptions = Spring.GetModOptions()
local MIN_SIM_SPEED = tonumber(modOptions.cull_simspeed) or 0.9
local MAX_UNITS = tonumber(modOptions.cull_maxunits) or 5000

local GAIA_TEAM_ID = spGetGaiaTeamID()

-- List of units safe to cull (low tier raptors)
local cullableUnits = {
    ["raptor_land_swarmer_basic_t1_v1"] = true,
    ["raptor_land_assault_basic_t2_v1"] = true,
    ["raptor_air_fighter_basic"] = true,
    ["scav_unit_t1"] = true, -- Placeholder
    ["scav_unit_t2"] = true  -- Placeholder
}

function gadget:GameFrame(n)
    if n % 90 == 0 then -- Check every 3 seconds
        local _, simSpeed = spGetGameSpeed()
        local currentUnits = Spring.GetUnitCount()

        local needsCulling = false
        -- If simspeed is consistently low
        if simSpeed < MIN_SIM_SPEED then needsCulling = true end
        if currentUnits > MAX_UNITS then needsCulling = true end

        if needsCulling then
            local raptors = spGetTeamUnits(GAIA_TEAM_ID)
            local cullCount = 0
            local targetCull = 50 -- Batch size

            for _, uID in pairs(raptors) do
                if cullCount >= targetCull then break end

                local udID = spGetUnitDefID(uID)
                if udID then
                    local ud = UnitDefs[udID]
                    if ud and cullableUnits[ud.name] then
                        spDestroyUnit(uID, false, true)
                        cullCount = cullCount + 1
                    end
                end
            end

            if cullCount > 0 then
                Spring.Echo("Culling System: Removed " .. cullCount .. " units due to load (SimSpeed: " .. simSpeed .. ", Units: " .. currentUnits .. ")")
            end
        end
    end
end
