-- Opens the NUI with the configuration data
RegisterCommand("openConfig", function(source, args, rawCommand)
    local configName = args[1]

    if configName == nil then
        print("Need to enter a config name! /openConfig <name>")
        return
    end

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
end, false)

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

    debug("Updated Config (" .. tostring(configName) .. "): " .. dump(configData))

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
