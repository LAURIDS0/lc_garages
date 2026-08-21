local blips = {}

local function hasGarageAccess(garage)
    local player = exports.qbx_core:GetPlayerData()

    if not player then
        return false
    end

    if garage.type == 'public' then
        return true
    end

    if garage.type == 'job' then
        local job = player.job

        if not job or not job.name then
            return false
        end

        local minimumGrade = garage.jobs and garage.jobs[job.name]

        if minimumGrade == nil then
            return false
        end

        local grade = job.grade and job.grade.level or 0

        return grade >= minimumGrade
    end

    if garage.type == 'personal' then
        local citizenid = player.citizenid

        if garage.citizenid then
            return citizenid == garage.citizenid
        end

        if garage.citizenids then
            for _, allowedCitizenid in ipairs(garage.citizenids) do
                if allowedCitizenid == citizenid then
                    return true
                end
            end
        end
    end

    return false
end

local function getVehicleLabel(vehicle)
    local hash

    if vehicle.hash then
        hash = tonumber(vehicle.hash)
    elseif vehicle.vehicle then
        hash = joaat(vehicle.vehicle)
    end

    if not hash then
        return vehicle.vehicle or 'Unknown vehicle'
    end

    local displayName = GetDisplayNameFromVehicleModel(hash)

    if displayName
        and displayName ~= 'CARNOTFOUND'
        and displayName ~= 'NULL'
    then
        local label = GetLabelText(displayName)

        if label and label ~= 'NULL' then
            return label
        end

        return displayName
    end

    return vehicle.vehicle or 'Unknown vehicle'
end

local function findSpawnPoint(garage)
    for _, point in ipairs(garage.spawnPoints or {}) do
        local closestVehicle = lib.getClosestVehicle(
            vec3(point.x, point.y, point.z),
            Config.SpawnClearRadius or 3.0
        )

        if closestVehicle == nil then
            return point
        end
    end

    return nil
end

local function deleteVehicle(vehicle)
    if not DoesEntityExist(vehicle) then
        return
    end

    SetEntityAsMissionEntity(vehicle, true, true)

    DeleteVehicle(vehicle)

    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
end

local function collectVehicleProperties(vehicle)
    local properties = lib.getVehicleProperties(vehicle)

    if not properties then
        return nil
    end

    local plate = GetVehicleNumberPlateText(vehicle)

    if plate and plate ~= '' then
        properties.plate = plate:gsub('%s+', '')
    end

    return properties
end

local function parkVehicle(garageName, garage, vehicle)
    local properties = collectVehicleProperties(vehicle)

    if not properties then
        lib.notify({
            title = garage.label,
            description = 'Could not read the vehicle properties.',
            type = 'error'
        })

        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    if not netId or netId == 0 then
        lib.notify({
            title = garage.label,
            description = 'Could not resolve the vehicle network ID.',
            type = 'error'
        })

        return
    end

    TriggerServerEvent(
        'lc_garages:server:parkVehicle',
        garageName,
        netId,
        properties
    )
end

local function requestStoredVehicles(garageName)
    TriggerServerEvent(
        'lc_garages:server:requestVehicles',
        garageName
    )
end

local function requestVehicle(garageName, vehicleId)
    TriggerServerEvent(
        'lc_garages:server:requestVehicle',
        garageName,
        vehicleId
    )
end

-- =========================================================
-- SERVER -> CLIENT: PARK SUCCESS
-- =========================================================

RegisterNetEvent('lc_garages:client:parkVehicleSuccess', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= 0 then
        TaskLeaveVehicle(
            playerPed,
            vehicle,
            0
        )

        Wait(500)

        deleteVehicle(vehicle)
    end

    lib.notify({
        title = 'Garage',
        description = 'Vehicle parked successfully.',
        type = 'success'
    })
end)

-- =========================================================
-- SERVER -> CLIENT: PARK FAILED
-- =========================================================

RegisterNetEvent('lc_garages:client:parkVehicleFailed', function(message)
    lib.notify({
        title = 'Garage',
        description = message or 'The vehicle could not be parked.',
        type = 'error'
    })
end)

-- =========================================================
-- SERVER -> CLIENT: VEHICLE LIST
-- =========================================================

RegisterNetEvent('lc_garages:client:receiveVehicles', function(
    garageName,
    vehicles
)
    local garage = Config.Garages[garageName]

    if not garage then
        return
    end

    vehicles = vehicles or {}

    if #vehicles == 0 then
        lib.notify({
            title = garage.label,
            description = 'You have no owned vehicles stored in this garage.',
            type = 'inform'
        })

        return
    end

    local options = {}

    for _, vehicle in ipairs(vehicles) do
        local vehicleLabel = getVehicleLabel(vehicle)

        options[#options + 1] = {
            title = vehicleLabel,

            description = ('%s • %s'):format(
                vehicle.vehicle or 'Unknown',
                vehicle.plate or 'NO PLATE'
            ),

            icon = 'car',

            onSelect = function()
                requestVehicle(
                    garageName,
                    vehicle.id
                )
            end
        }
    end

    lib.registerContext({
        id = 'lc_garage_' .. garageName,
        title = garage.label,
        options = options
    })

    lib.showContext(
        'lc_garage_' .. garageName
    )
end)

-- =========================================================
-- SERVER -> CLIENT: VEHICLE DATA FOR SPAWN
-- =========================================================

RegisterNetEvent('lc_garages:client:receiveVehicle', function(
    garageName,
    vehicle
)
    local garage = Config.Garages[garageName]

    if not garage then
        return
    end

    if not vehicle then
        lib.notify({
            title = garage.label,
            description = 'The vehicle could not be retrieved.',
            type = 'error'
        })

        return
    end

    if not vehicle.vehicle then
        lib.notify({
            title = garage.label,
            description = 'The vehicle has no model in the database.',
            type = 'error'
        })

        return
    end

    local spawnPoint = findSpawnPoint(garage)

    if not spawnPoint then
        lib.notify({
            title = garage.label,
            description = 'There are no free vehicle spawn points.',
            type = 'error'
        })

        return
    end

    local model = joaat(vehicle.vehicle)

    if not lib.requestModel(model) then
        lib.notify({
            title = garage.label,
            description = 'The vehicle model could not be loaded.',
            type = 'error'
        })

        return
    end

    local spawnedVehicle = CreateVehicle(
        model,
        spawnPoint.x,
        spawnPoint.y,
        spawnPoint.z,
        spawnPoint.w,
        true,
        true
    )

    if not DoesEntityExist(spawnedVehicle) then
        SetModelAsNoLongerNeeded(model)

        lib.notify({
            title = garage.label,
            description = 'The vehicle could not be spawned.',
            type = 'error'
        })

        return
    end

    SetEntityAsMissionEntity(
        spawnedVehicle,
        true,
        true
    )

    -- ========================================
    -- RESTORE VEHICLE PROPERTIES
    -- ========================================

    local properties = {}

    if vehicle.mods
        and vehicle.mods ~= ''
    then
        local decoded = json.decode(vehicle.mods)

        if type(decoded) == 'table' then
            properties = decoded
        end
    end

    properties.plate = vehicle.plate

    if not lib.setVehicleProperties(
        spawnedVehicle,
        properties
    ) then
        print((
            '[lc_garages] Failed to fully apply stored properties to %s'
        ):format(
            vehicle.plate
        ))
    end

    -- Make absolutely sure the plate is correct.
    SetVehicleNumberPlateText(
        spawnedVehicle,
        vehicle.plate
    )

    SetVehicleOnGroundProperly(
        spawnedVehicle
    )

    local netId =
        NetworkGetNetworkIdFromEntity(
            spawnedVehicle
        )

    if not netId or netId == 0 then
        deleteVehicle(spawnedVehicle)
        SetModelAsNoLongerNeeded(model)

        lib.notify({
            title = garage.label,
            description = 'Could not resolve the spawned vehicle.',
            type = 'error'
        })

        return
    end

    -- Tell server the vehicle actually exists.
    TriggerServerEvent(
        'lc_garages:server:vehicleSpawned',
        garageName,
        vehicle.id,
        netId
    )

    if Config.WarpPlayerIntoVehicle then
        TaskWarpPedIntoVehicle(
            PlayerPedId(),
            spawnedVehicle,
            -1
        )
    end

    SetModelAsNoLongerNeeded(model)
end)

-- =========================================================
-- BLIPS
-- =========================================================

local function createBlip(garage)
    if not garage.blip
        or garage.blip.enabled ~= true
    then
        return
    end

    if not garage.zone then
        return
    end

    local coords = garage.zone.coords
    local defaults = Config.DefaultBlip or {}

    local blip = AddBlipForCoord(
        coords.x,
        coords.y,
        coords.z
    )

    SetBlipSprite(
        blip,
        garage.blip.sprite
            or defaults.sprite
            or 357
    )

    SetBlipColour(
        blip,
        garage.blip.color
            or defaults.color
            or 3
    )

    SetBlipScale(
        blip,
        garage.blip.scale
            or defaults.scale
            or 0.8
    )

    SetBlipAsShortRange(
        blip,
        garage.blip.shortRange ~= false
    )

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(garage.label)
    EndTextCommandSetBlipName(blip)

    blips[#blips + 1] = blip
end

-- =========================================================
-- GARAGE ZONES
-- =========================================================

CreateThread(function()
    for garageName, garage in pairs(Config.Garages) do
        createBlip(garage)

        if not garage.zone then
            print((
                '[lc_garages] Garage %s has no zone configured.'
            ):format(
                garageName
            ))

            goto continue
        end

        lib.zones.box({
            coords = garage.zone.coords,
            size = garage.zone.size,
            rotation = garage.zone.rotation,
            debug = Config.Debug,

            onEnter = function()
                if hasGarageAccess(garage) then
                    lib.showTextUI(
                        '[E] - ' .. garage.label
                    )
                end
            end,

            onExit = function()
                lib.hideTextUI()
            end,

            inside = function()
                if not hasGarageAccess(garage) then
                    return
                end

                if not IsControlJustReleased(0, 38) then
                    return
                end

                local playerPed =
                    PlayerPedId()

                local currentVehicle =
                    GetVehiclePedIsIn(
                        playerPed,
                        false
                    )

                -- =================================================
                -- PLAYER IS IN A VEHICLE
                -- =================================================

                if currentVehicle ~= 0 then

                    if GetPedInVehicleSeat(
                        currentVehicle,
                        -1
                    ) ~= playerPed then

                        lib.notify({
                            title = garage.label,
                            description =
                                'You must be the driver to park this vehicle.',
                            type = 'error'
                        })

                        return
                    end

                    parkVehicle(
                        garageName,
                        garage,
                        currentVehicle
                    )

                    return
                end

                -- =================================================
                -- PLAYER IS ON FOOT
                -- =================================================

                requestStoredVehicles(
                    garageName
                )
            end
        })

        ::continue::
    end
end)