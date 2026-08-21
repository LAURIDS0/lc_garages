local function getPlayer(source)
    return exports.qbx_core:GetPlayer(source)
end

local function getGarage(garageName)
    return Config.Garages[garageName]
end

local function hasGarageAccess(player, garage)
    if not player
        or not player.PlayerData
    then
        return false
    end

    if garage.type == 'public' then
        return true
    end

    if garage.type == 'job' then
        local job =
            player.PlayerData.job

        if not job
            or not job.name
        then
            return false
        end

        local minimumGrade =
            garage.jobs
            and garage.jobs[job.name]

        if minimumGrade == nil then
            return false
        end

        local grade =
            job.grade
            and job.grade.level
            or 0

        return grade >= minimumGrade
    end

    if garage.type == 'personal' then
        local citizenid =
            player.PlayerData.citizenid

        if garage.citizenid then
            return citizenid == garage.citizenid
        end

        if garage.citizenids then
            for _, allowedCitizenid in ipairs(
                garage.citizenids
            ) do
                if allowedCitizenid == citizenid then
                    return true
                end
            end
        end

        return false
    end

    return false
end

local function trimPlate(plate)
    return (plate or ''):gsub(
        '%s+',
        ''
    )
end

local function getOwnedVehicle(
    citizenid,
    plate
)
    return MySQL.single.await([[
        SELECT
            id,
            citizenid,
            vehicle,
            hash,
            mods,
            plate,
            garage,
            state,
            coords
        FROM player_vehicles
        WHERE citizenid = ?
          AND plate = ?
        LIMIT 1
    ]], {
        citizenid,
        plate
    })
end

local function getStoredVehicle(
    vehicleId,
    citizenid,
    garageName
)
    return MySQL.single.await([[
        SELECT
            id,
            citizenid,
            vehicle,
            hash,
            mods,
            plate,
            garage,
            state,
            coords
        FROM player_vehicles
        WHERE id = ?
          AND citizenid = ?
          AND garage = ?
          AND state = 1
        LIMIT 1
    ]], {
        vehicleId,
        citizenid,
        garageName
    })
end

-- =========================================================
-- PARK VEHICLE
-- =========================================================

RegisterNetEvent(
    'lc_garages:server:parkVehicle',
    function(
        garageName,
        netId,
        properties
    )
        local source = source

        local player =
            getPlayer(source)

        local garage =
            getGarage(garageName)

        if not player
            or not garage
        then
            return
        end

        if not hasGarageAccess(
            player,
            garage
        ) then

            TriggerClientEvent(
                'lc_garages:client:parkVehicleFailed',
                source,
                'You do not have access to this garage.'
            )

            return
        end

        if not netId then
            return
        end

        local entity =
            NetworkGetEntityFromNetworkId(
                netId
            )

        if not entity
            or entity == 0
            or not DoesEntityExist(entity)
        then

            TriggerClientEvent(
                'lc_garages:client:parkVehicleFailed',
                source,
                'The vehicle could not be resolved.'
            )

            return
        end

        local plate =
            trimPlate(
                GetVehicleNumberPlateText(
                    entity
                )
            )

        if plate == '' then
            TriggerClientEvent(
                'lc_garages:client:parkVehicleFailed',
                source,
                'The vehicle has no valid number plate.'
            )

            return
        end

        local ownedVehicle =
            getOwnedVehicle(
                player.PlayerData.citizenid,
                plate
            )

        if not ownedVehicle then

            TriggerClientEvent(
                'lc_garages:client:parkVehicleFailed',
                source,
                'This vehicle is not registered as one of your owned vehicles.'
            )

            return
        end

        properties =
            type(properties) == 'table'
            and properties
            or {}

        properties.plate = plate

        local propertiesJson =
            json.encode(properties)

        local affectedRows =
            MySQL.update.await([[
                UPDATE player_vehicles
                SET
                    garage = ?,
                    state = 1,
                    mods = ?
                WHERE id = ?
                  AND citizenid = ?
            ]], {
                garageName,
                propertiesJson,
                ownedVehicle.id,
                player.PlayerData.citizenid
            })

        if affectedRows ~= 1 then
            TriggerClientEvent(
                'lc_garages:client:parkVehicleFailed',
                source,
                'The vehicle could not be saved to the garage.'
            )

            return
        end

        TriggerClientEvent(
            'lc_garages:client:parkVehicleSuccess',
            source
        )
    end
)

-- =========================================================
-- REQUEST VEHICLES STORED IN GARAGE
-- =========================================================

RegisterNetEvent(
    'lc_garages:server:requestVehicles',
    function(garageName)
        local source = source

        local player =
            getPlayer(source)

        local garage =
            getGarage(garageName)

        if not player
            or not garage
        then
            return
        end

        if not hasGarageAccess(
            player,
            garage
        ) then

            TriggerClientEvent(
                'lc_garages:client:receiveVehicles',
                source,
                garageName,
                {}
            )

            return
        end

        local vehicles =
            MySQL.query.await([[
                SELECT
                    id,
                    vehicle,
                    hash,
                    mods,
                    plate,
                    garage,
                    state
                FROM player_vehicles
                WHERE citizenid = ?
                  AND garage = ?
                  AND state = 1
                ORDER BY vehicle ASC, plate ASC
            ]], {
                player.PlayerData.citizenid,
                garageName
            }) or {}

        TriggerClientEvent(
            'lc_garages:client:receiveVehicles',
            source,
            garageName,
            vehicles
        )
    end
)

-- =========================================================
-- REQUEST ONE VEHICLE
-- =========================================================

RegisterNetEvent(
    'lc_garages:server:requestVehicle',
    function(
        garageName,
        vehicleId
    )
        local source = source

        local player =
            getPlayer(source)

        local garage =
            getGarage(garageName)

        if not player
            or not garage
        then
            return
        end

        if not hasGarageAccess(
            player,
            garage
        ) then
            return
        end

        local vehicle =
            getStoredVehicle(
                vehicleId,
                player.PlayerData.citizenid,
                garageName
            )

        if not vehicle then
            TriggerClientEvent(
                'lc_garages:client:receiveVehicle',
                source,
                garageName,
                nil
            )

            return
        end

        TriggerClientEvent(
            'lc_garages:client:receiveVehicle',
            source,
            garageName,
            vehicle
        )
    end
)

-- =========================================================
-- VEHICLE HAS ACTUALLY SPAWNED
-- =========================================================

RegisterNetEvent(
    'lc_garages:server:vehicleSpawned',
    function(
        garageName,
        vehicleId,
        netId
    )
        local source = source

        local player =
            getPlayer(source)

        local garage =
            getGarage(garageName)

        if not player
            or not garage
        then
            return
        end

        if not hasGarageAccess(
            player,
            garage
        ) then
            return
        end

        if not netId then
            return
        end

        local vehicle =
            getStoredVehicle(
                vehicleId,
                player.PlayerData.citizenid,
                garageName
            )

        if not vehicle then

            return
        end

        -- ============================================
        -- WAIT FOR NETWORK ENTITY
        -- ============================================

        local entity = 0

        local timeout =
            GetGameTimer() + 5000

        while GetGameTimer() < timeout do
            entity =
                NetworkGetEntityFromNetworkId(
                    netId
                )

            if entity
                and entity ~= 0
                and DoesEntityExist(entity)
            then
                break
            end

            Wait(100)
        end

        if not entity
            or entity == 0
            or not DoesEntityExist(entity)
        then

            return
        end

        -- ============================================
        -- CHECK PLATE
        -- ============================================

        local spawnedPlate =
            trimPlate(
                GetVehicleNumberPlateText(
                    entity
                )
            )

        if spawnedPlate
            ~= trimPlate(vehicle.plate)
        then

            return
        end

        -- ============================================
        -- MARK VEHICLE OUT
        -- ============================================

        local updated =
            MySQL.update.await([[
                UPDATE player_vehicles
                SET state = 0
                WHERE id = ?
                  AND citizenid = ?
                  AND garage = ?
                  AND state = 1
            ]], {
                vehicle.id,
                player.PlayerData.citizenid,
                garageName
            })

        if updated ~= 1 then

            return
        end

        -- ============================================
        -- GIVE KEYS
        -- ============================================

        if Config.GiveKeys then
            exports.qbx_vehiclekeys:GiveKeys(
                source,
                entity
            )
        end
    end
)