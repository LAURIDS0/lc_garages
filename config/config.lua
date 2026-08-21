Config = {}

-- Draw the garage box zones while testing.
Config.Debug = true

-- How close another vehicle can be to a configured spawn point.
Config.SpawnClearRadius = 3.0

-- Put the player into the driver seat after retrieving a vehicle.
Config.WarpPlayerIntoVehicle = true

-- Give the player keys after the server confirms the vehicle was spawned.
Config.GiveKeys = true

-- Default blip values. A garage can override any of these.
Config.DefaultBlip = {
    sprite = 357,
    color = 3,
    scale = 0.8,
    shortRange = true
}
