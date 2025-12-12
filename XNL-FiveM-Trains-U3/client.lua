--=============================================================
-- Freight Train Traffic Controller
-- - Spawns trains separated (min distance)
-- - If trains touch (too close) -> despawn both
-- - Hard-requires locomotive model 'freight' at spawn
-- - Logs spawn coords to console
--=============================================================

local spawnedTrains = {}

local function loadModels(modelNames)
    for _, name in ipairs(modelNames) do
        local h = GetHashKey(name)
        RequestModel(h)
        while not HasModelLoaded(h) do
            Wait(0)
        end
    end
end

local function cleanupDeadTrains()
    local alive = {}
    for _, ent in ipairs(spawnedTrains) do
        if ent and ent ~= 0 and DoesEntityExist(ent) then
            alive[#alive+1] = ent
        end
    end
    spawnedTrains = alive
end

local function dist(a, b)
    return #(a - b)
end

local function isSpawnPointClear(spawnPos, minDist)
    for _, ent in ipairs(spawnedTrains) do
        if ent and ent ~= 0 and DoesEntityExist(ent) then
            local p = GetEntityCoords(ent)
            if dist(p, spawnPos) < minDist then
                return false
            end
        end
    end
    return true
end

local function deleteTrain(ent)
    if ent and ent ~= 0 and DoesEntityExist(ent) then
        SetEntityAsMissionEntity(ent, true, true)
        DeleteEntity(ent)
    end
end

local function logSpawn(train, p, variation)
    local msg = ("[moritz-trains] Spawned freight train id=%s var=%s at (%.2f, %.2f, %.2f) dir=%s\n")
        :format(tostring(train), tostring(variation), p.x, p.y, p.z, tostring(p.dir))
    Citizen.Trace(msg)  -- console
    print(msg)          -- server/client console (depending)
end

local function trySpawnOneTrain()
    if not Config or not Config.TrainSpawnPoints or #Config.TrainSpawnPoints == 0 then return false end

    local start = math.random(1, #Config.TrainSpawnPoints)
    local minSpawnDist = (Config.MinSpawnDistance or 650.0)

    for i = 0, #Config.TrainSpawnPoints - 1 do
        local idx = ((start + i - 1) % #Config.TrainSpawnPoints) + 1
        local p = Config.TrainSpawnPoints[idx]
        local spawnPos = vector3(p.x, p.y, p.z)

        -- keep spawns separated
        if isSpawnPointClear(spawnPos, minSpawnDist) then
            local variation = Config.FreightVariations[math.random(1, #Config.FreightVariations)]
            local train = CreateMissionTrain(variation, p.x + 0.0, p.y + 0.0, p.z + 0.0, p.dir and true or false, true, true)

            if train and train ~= 0 and DoesEntityExist(train) then
                SetEntityAsMissionEntity(train, true, true)

                -- HARD REQUIRE: locomotive must be 'freight' (engine first, wagons behind)
                local model = GetEntityModel(train)
                if model ~= GetHashKey('freight') then
                    -- wrong engine (like metro etc) -> delete and try another spawn
                    deleteTrain(train)
                    Wait(0)
                else
                    -- make it resilient
                    SetEntityInvincible(train, true)

                    spawnedTrains[#spawnedTrains+1] = train
                    logSpawn(train, p, variation)
                    return true
                end
            end
        end

        Wait(0)
    end

    return false
end

local function maintainTrainCount()
    cleanupDeadTrains()
    local target = (Config and Config.TrainCount) or 8

    while #spawnedTrains < target do
        local ok = trySpawnOneTrain()
        if not ok then break end
        Wait(350)
        cleanupDeadTrains()
    end
end

local function handleTrainTouches()
    -- if two engines get too close -> delete both
    local touchDist = (Config.TouchDespawnDistance or 18.0)

    cleanupDeadTrains()
    if #spawnedTrains < 2 then return end

    for i = #spawnedTrains, 2, -1 do
        local a = spawnedTrains[i]
        if a and a ~= 0 and DoesEntityExist(a) then
            local pa = GetEntityCoords(a)

            for j = i - 1, 1, -1 do
                local b = spawnedTrains[j]
                if b and b ~= 0 and DoesEntityExist(b) then
                    local pb = GetEntityCoords(b)

                    if dist(pa, pb) <= touchDist then
                        Citizen.Trace(("[moritz-trains] TOUCH -> despawn both (%s) & (%s) dist=%.2f\n"):format(tostring(a), tostring(b), dist(pa,pb)))
                        deleteTrain(a)
                        deleteTrain(b)

                        table.remove(spawnedTrains, i)
                        table.remove(spawnedTrains, j)
                        break
                    end
                end
            end
        else
            table.remove(spawnedTrains, i)
        end
    end
end

CreateThread(function()
    math.randomseed(GetGameTimer())

    -- Tracks: 0 freight, 3 metro
    if Config.EnableFreightTrack then
        SwitchTrainTrack(0, true)
        SetTrainTrackSpawnFrequency(0, 120000)
    end

    if Config.EnableMetroTrack then
        SwitchTrainTrack(3, true)
        SetTrainTrackSpawnFrequency(3, 120000)
    else
        SwitchTrainTrack(3, false)
        SetTrainTrackSpawnFrequency(3, 0)
    end

    SetRandomTrains(Config.EnableRandomTrains and true or false)

    loadModels(Config.RequiredTrainModels or { 'freight' })

    maintainTrainCount()

    -- Maintenance loop (spawn missing)
    while true do
        Wait((Config and Config.MaintenanceTick) or 15000)
        maintainTrainCount()
    end
end)

-- Touch-check loop (more frequent so "berühren" schnell reagiert)
CreateThread(function()
    while true do
        Wait(750)
        handleTrainTouches()
    end
end)

RegisterCommand('trains_reset', function()
    for _, ent in ipairs(spawnedTrains) do
        deleteTrain(ent)
    end
    spawnedTrains = {}
    Wait(500)
    maintainTrainCount()
end, false)
