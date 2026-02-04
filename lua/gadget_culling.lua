function gadget:GetInfo()
  return {
    name      = "Eco Culler",
    desc      = "Destroys low-utility T1 eco structures to improve performance",
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
local spGetUnitNearestEnemy = Spring.GetUnitNearestEnemy
local spAddTeamResource = Spring.AddTeamResource
local spGetTeamList = Spring.GetTeamList
local spValidUnitID = Spring.ValidUnitID
local spGetUnitPosition = Spring.GetUnitPosition
local spSpawnCEG = Spring.SpawnCEG
local math_floor = math.floor

local modOptions = Spring.GetModOptions()
local MIN_SIM_SPEED = tonumber(modOptions.cull_simspeed) or 0.9
local MAX_UNITS = tonumber(modOptions.cull_maxunits) or 5000

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

function gadget:GameFrame(n)
    -- Periodic Check & Candidate Collection (Every 3 seconds)
    if n % 90 == 0 then
        local _, simSpeed = spGetGameSpeed()
        local currentUnits = Spring.GetUnitCount()

        -- Reset if previous batch not finished (prioritize fresh state)
        candidates = {}
        candidatesIndex = 1
        processingActive = false

        local needsCulling = false
        -- If simspeed is consistently low
        if simSpeed < MIN_SIM_SPEED then needsCulling = true end
        if currentUnits > MAX_UNITS then needsCulling = true end

        if needsCulling then
            -- Collect candidates (Fast Scan)
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
            end
        end
    end

    -- Process Batch (Every Frame if active)
    if processingActive then
        local batchSize = 20 -- Check 20 units per frame
        local processedCount = 0

        while processedCount < batchSize and candidatesIndex <= #candidates do
            local candidate = candidates[candidatesIndex]
            candidatesIndex = candidatesIndex + 1
            processedCount = processedCount + 1

            local uID = candidate.id
            if spValidUnitID(uID) then
                 -- Expensive Safety Check
                 local enemyID = spGetUnitNearestEnemy(uID, 2000, false)
                 if not enemyID then
                    -- Refund
                    local ud = UnitDefs[candidate.defId]
                    if ud then
                        local metalCost = ud.metalCost or 0
                        spAddTeamResource(candidate.team, "metal", metalCost)

                        -- Visuals
                        local x, y, z = spGetUnitPosition(uID)
                        if x then
                            spSpawnCEG("mediumexplosion", x, y, z, 0, 0, 0)
                        end

                        -- Destroy
                        spDestroyUnit(uID, false, true)
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
