Config = Config or {}

Config.TrainCount = 8
Config.MaintenanceTick = 15000

Config.EnableRandomTrains = true
Config.EnableFreightTrack = true
Config.EnableMetroTrack = false

-- Spawns müssen "weit auseinander" sein
Config.MinSpawnDistance = 650.0        -- Meter Abstand zu anderen Zügen beim Spawn

-- Wenn Züge sich "berühren"/zu nah kommen -> despawn
Config.TouchDespawnDistance = 18.0     -- Meter Abstand (Engine zu Engine) = kill both

-- Nur Variations nutzen, die i.d.R. Freight sind (wir prüfen trotzdem hart auf 'freight' als Engine)
Config.FreightVariations = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }

Config.RequiredTrainModels = {
  'freight', 'freightcar', 'freightcar2', 'freightcont1', 'freightcont2', 'freightgrain', 'tankercar'
}

Config.TrainSpawnPoints = {
  { x = 1438.98,  y = 6405.92,   z = 34.19,  dir = true  },
  { x = 670.2056, y = -685.7708, z = 25.1531,dir = true  },
  { x = 107.29,   y = -1713.03,  z = 29.13,  dir = true  },
  { x = 247.9364, y = -1198.597, z = 37.4482,dir = true  },

  { x = 2617.0,   y = 2930.0,    z = 40.0,   dir = true  },
  { x = 1743.0,   y = 3501.0,    z = 36.0,   dir = true  },
  { x = -532.0,   y = 5320.0,    z = 73.0,   dir = true  },
  { x = -1210.0,  y = 4430.0,    z = 20.0,   dir = true  },
}
