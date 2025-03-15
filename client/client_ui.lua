-- Opens the NUI with the configuration data
RegisterCommand("openConfig", function(source, args, rawCommand)
    local configName = args[1]

    if configName == nil then
        print("Need to enter a config name! /openConfig <name>")
        return
    end

    openConfig(configName)
end, false)

-- Opens the NUI with all available configs
RegisterCommand("configs", function(source, args, rawCommand)
    Events.TriggerServerCallback("getConfigs", function(returnedConfigs)
        SendNUIMessage({
            type = "showConfigs",
            configs = returnedConfigs
        })

        SetNuiFocus(true, true)
    end)
end, false)

-- NUI Callback for opening the config
RegisterNUICallback("openConfig", function(data, cb)
    local configName = data.configName

    print("Got nui with data: " .. dump(data))

    if configName == nil then
        print("Failed to open config with nil name!")
        return cb("error")
    end

    openConfig(configName)
    cb("success")
end)

-- Function to open config list
function openConfig(configName)
    Events.TriggerServerCallback("getUiConfig", function(sortedConfigData)
        if sortedConfigData == nil then
            print("Could not get ui config: " .. tostring(configName))
            return
        end

        SendNUIMessage({
            type = "openConfig",
            configName = configName,
            sortedConfig = sortedConfigData
        })

        SetNuiFocus(true, true)
    end, configName)
end

-- NUI Callback for saving the config
RegisterNUICallback("saveConfig", function(data, cb)
    local configName = data.configName

    if configName == nil then
        print("Failed to save config with nil name!")
        return cb("error")
    end

    local configData = data.sortedConfig

    if configData == nil then
        print("Failed to save config (" .. tostring(configName) .. ") with nil data!")
        return cb("error")
    end

    debug("Saving Config (" .. tostring(configName) .. "): " .. dump(configData))

    Events.TriggerServerCallback("saveUiConfig", function(success)
        if success then
            closeConfig()
        end
    end, configName, configData)

    cb("success")
end)

function closeConfig()
    SetNuiFocus(false, false)
end

-- NUI Callback for closing the config
RegisterNUICallback("closeConfig", function(data, cb)
    closeConfig()

    cb("success")
end)

-- NUI Callback for getting player position
RegisterNUICallback('getPlayerPosition', function(data, cb)
    TriggerServerEvent('ov_configs:getPlayerPosition')
    cb('ok')
end)

-- Event to return player position
RegisterNetEvent('returnPlayerPosition')
AddEventHandler('returnPlayerPosition', function(position)
    SendNUIMessage({
        type = 'playerPosition',
        x = position.x,
        y = position.y,
        z = position.z,
        heading = position.heading
    })
end)

-- NUI Callback for teleporting player to coords
RegisterNUICallback('teleportToPosition', function(data, cb)
    TriggerServerEvent('ov_configs:teleportToPosition', data)
    cb('ok')
end)