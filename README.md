# LC Garages

Public, job-restricted and personal vehicle garages for FiveM/Qbox.

## Documentation

Read it on [lc-development.com/docs](https://lc-development.com/docs/#/lc_garages).

## Core behaviour

Each garage uses **one box zone**.

When the player presses `E` inside the garage zone:

- If the player is inside a vehicle, the script treats the interaction as **parking**.
- If the player is not inside a vehicle, the script treats the interaction as **vehicle retrieval**.

For parking, the server checks that the vehicle belongs to the player in Qbox `player_vehicles` before saving it.

For retrieval, the server only returns vehicles owned by the player, stored in the current garage, and marked as garaged (`state = 1`).

## Garage types

### Public

```lua
type = 'public'
```

Everyone can access the garage.

### Job

```lua
type = 'job'

jobs = {
    police = 0,
    bcso = 2
}
```

The number is the minimum job grade allowed to use the garage.

### Personal

One citizen ID:

```lua
type = 'personal'
citizenid = 'ABC123'
```

Or multiple citizen IDs:

```lua
type = 'personal'
citizenids = {
    'ABC123',
    'XYZ789'
}
```

## Garage configuration

Each garage contains:

```lua
['legion'] = {
    label = 'Legion Square Garage',
    type = 'public',

    blip = {
        enabled = true,
        sprite = 357,
        color = 3,
        scale = 0.8,
        shortRange = true
    },

    zone = {
        coords = vec3(215.0, -810.0, 30.0),
        size = vec3(5.0, 5.0, 3.0),
        rotation = 0.0
    },

    spawnPoints = {
        vec4(221.09, -789.46, 29.42, 157.0),
        vec4(217.45, -790.78, 29.42, 157.0),
        vec4(213.79, -792.05, 29.42, 157.0)
    }
}
```

## Parking checks

When pressing `E` while inside a vehicle, the following checks are made:

1. The player must have access to the garage.
2. The player must be the driver.
3. The vehicle must have a valid number plate.
4. The plate must belong to the current player's `player_vehicles` record.
5. The current vehicle properties are saved to the `mods` column.
6. The vehicle is assigned to the current garage.
7. The vehicle state becomes `1` (garaged).
8. Only after the database update succeeds is the vehicle removed from the world.

## Retrieval checks

When pressing `E` while on foot, the script queries:

- current player's `citizenid`;
- current garage name;
- `state = 1`.

Only matching owned vehicles are shown in the `ox_lib` context menu.

The player chooses a vehicle and the script:

1. Checks that the vehicle still belongs to the player and is still stored in this garage.
2. Finds the first free configured `vec4` spawn point.
3. Spawns the vehicle.
4. Restores the saved `mods` JSON through `ox_lib` vehicle properties.
5. Sets the vehicle state to `0` (out) only after the spawned entity has been validated.
6. Gives keys through `qbx_vehiclekeys`.

If spawning fails before the server confirms the entity, the vehicle remains garaged.

## Blips

Blips are configured per garage.

```lua
blip = {
    enabled = true,
    sprite = 357,
    color = 3,
    scale = 0.8,
    shortRange = true
}
```

Set `enabled = false` to hide the blip.

## Debug

In `config/config.lua`:

```lua
Config.Debug = true
```

This enables the `ox_lib` box debug visualization.

## Dependencies

- `qbx_core`
- `ox_lib`
- `oxmysql`
- `qbx_vehiclekeys`

## Database

This resource uses Qbox's existing `player_vehicles` table.

It does not create or replace vehicle ownership.

Qbox state values:

- `0` = OUT
- `1` = GARAGED
- `2` = IMPOUNDED

The `garage` column stores the configured garage name.
# lc_garages
