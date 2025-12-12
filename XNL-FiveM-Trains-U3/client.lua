--=============================================================
-- Freight Train Traffic Controller (NO metro/subway)
-- - Removes metro/subway logic entirely
-- - Keeps 8 freight trains alive at all times (best-effort)
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

local function trySpawnOneTrain()
    if not Config or not Config.TrainSpawnPoints or #Config.TrainSpawnPoints == 0 then return false end

    -- randomize start index so we don't always hammer the same point
    local start = math.random(1, #Config.TrainSpawnPoints)

    for i = 0, #Config.TrainSpawnPoints - 1 do
        local idx = ((start + i - 1) % #Config.TrainSpawnPoints) + 1
        local p = Config.TrainSpawnPoints[idx]

        local variation = Config.FreightVariations[math.random(1, #Config.FreightVariations)]

        -- CreateMissionTrain(variation, x, y, z, direction, isNetwork, netMissionEntity)
        local train = CreateMissionTrain(variation, p.x + 0.0, p.y + 0.0, p.z + 0.0, p.dir and true or false, true, true)

        if train and train ~= 0 and DoesEntityExist(train) then
            SetEntityAsMissionEntity(train, true, true)
            -- make it harder to grief / explode the whole map's train traffic
            SetEntityInvincible(train, true)

            spawnedTrains[#spawnedTrains+1] = train
            return true
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
        if not ok then
            -- if spawns keep failing, don't hard-loop and nuke the client
            break
        end
        Wait(250)
        cleanupDeadTrains()
    end
end

CreateThread(function()
    math.randomseed(GetGameTimer())

    -- tracks: 0 = freight, 3 = metro
    if Config.EnableFreightTrack then
        SwitchTrainTrack(0, true)
        SetTrainTrackSpawnFrequency(0, 120000) -- lower = more random spawns; we manage our own too
    end

    if Config.EnableMetroTrack then
        SwitchTrainTrack(3, true)
        SetTrainTrackSpawnFrequency(3, 120000)
    else
        -- hard disable metro track spawns
        SwitchTrainTrack(3, false)
        SetTrainTrackSpawnFrequency(3, 0)
    end

    if Config.EnableRandomTrains then
        SetRandomTrains(true)
    else
        SetRandomTrains(false)
    end

    -- load required train models once
    loadModels(Config.RequiredTrainModels or {
        'freight', 'freightcar', 'freightcar2', 'freightcont1', 'freightcont2', 'freightgrain', 'tankercar'
    })

    -- initial fill
    maintainTrainCount()

    -- keep filling
    while true do
        Wait((Config and Config.MaintenanceTick) or 15000)
        maintainTrainCount()
    end
end)

-- Optional: command for admins/devs to nuke and respawn all trains client-side
RegisterCommand('trains_reset', function()
    for _, ent in ipairs(spawnedTrains) do
        if ent and ent ~= 0 and DoesEntityExist(ent) then
            DeleteEntity(ent)
        end
    end
    spawnedTrains = {}
    Wait(500)
    maintainTrainCount()
end, false)
