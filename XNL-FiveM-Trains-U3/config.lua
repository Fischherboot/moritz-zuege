--=============================================================
-- Train Traffic Config (Freight only, no Metro/Subway)
--=============================================================
Config = Config or {}

-- How many freight trains should exist at the same time
Config.TrainCount = 8

-- How often we check and (re)spawn missing trains (ms)
Config.MaintenanceTick = 15000

-- If true, we ALSO enable GTA's random trains (extra traffic, optional)
Config.EnableRandomTrains = true

-- Track settings
Config.EnableFreightTrack = true  -- Track 0
Config.EnableMetroTrack   = false -- Track 3 (subway) -> keep false

-- Mission train variations to use (freight-ish). Keep it tame to avoid ultra-long glitchy consists.
-- You can add/remove ids. (These are the "variation" parameter of CreateMissionTrain.)
Config.FreightVariations = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }

-- Spawn points that are ON/NEAR tracks.
-- If a point is slightly off, the train may fail to spawn (handle will be 0) -> we try the next one.
Config.TrainSpawnPoints = {
    { x = 1438.98,  y = 6405.92,  z = 34.19,  dir = true  },  -- Paleto / North
    { x = 670.2056, y = -685.7708, z = 25.1531, dir = true }, -- City / East-ish
    { x = 107.29,   y = -1713.03, z = 29.13,  dir = true  }, -- City / South
    { x = 247.9364, y = -1198.597, z = 37.4482, dir = true }, -- Downtown-ish
    -- Extra spares (tweak if any fail on your map pack)
    { x = 2617.0,   y = 2930.0,   z = 40.0,   dir = true  },
    { x = 1743.0,   y = 3501.0,   z = 36.0,   dir = true  },
    { x = -532.0,   y = 5320.0,   z = 73.0,   dir = true  },
    { x = -1210.0,  y = 4430.0,   z = 20.0,   dir = true  },
}

-- Models that must be loaded before CreateMissionTrain (freight consist pieces)
Config.RequiredTrainModels = {
    'freight', 'freightcar', 'freightcar2', 'freightcont1', 'freightcont2', 'freightgrain', 'tankercar'
}
