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
local SAFE_RADIUS_SQ = SAFE_RADIUS * SAFE_RADIUS

function gadget:Initialize()
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
local combatGrid = {} -- Key: numeric hash, Value: timestamp (frame)
local GRID_SIZE = 1024 -- 1024 elmos (approx 2000 range check replacement)
local ACTIVE_DURATION = 900 -- 30 seconds * 30 frames

local function GetGridKey(x, z)
    local gx = math_floor(x / GRID_SIZE)
    local gz = math_floor(z / GRID_SIZE)
    return gx, gz, gx + (gz * 10000)
end

local function MarkActive(unitID)
    local x, _, z = spGetUnitPosition(unitID)
    if x then
        local _, _, key = GetGridKey(x, z)
        combatGrid[key] = spGetGameFrame()
    end
end

-- Event Handlers to update Combat Grid
function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
    MarkActive(unitID)
    if attackerID then MarkActive(attackerID) end
end

function gadget:UnitWeaponFire(unitID, unitDefID, unitTeam, weaponNum, weaponDefID, projectileParams, aimPos)
    MarkActive(unitID)
end


function gadget:GameFrame(n)
    if not CULL_ENABLED then return end
    candidates = candidates or {}

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
                -- Clear candidates table instead of creating new one
                for i = 1, #candidates do candidates[i] = nil end
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
                             local key = (gx + dx) + ((gz + dz) * 10000)
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
                        local sx, sy, sz = spGetTeamStartPosition(candidate.team)
                        if sx then
                             local distSq = (x - sx)^2 + (z - sz)^2
                             if distSq < SAFE_RADIUS_SQ then
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
            for i = 1, #candidates do candidates[i] = nil end
        end
    end
end
