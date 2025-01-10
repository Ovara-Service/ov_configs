local clientConfigs = {}

function getConfig(name)
    if name == nil then
        print("Could not get config for nil name!")
        return nil
    end

    local configData = clientConfigs[name]

    if configData == nil then
        local count = 1
        local receivedResponse = true

        while configData == nil do
            if receivedResponse then
                receivedResponse = false
                Events.TriggerServerCallback("getConfig", function(newConfigData)
                    receivedResponse = true
                    if newConfigData ~= nil then
                        clientConfigs[name] = newConfigData
                        configData = newConfigData
                    else
                        print("Failed to load client config '" .. dump(name) .. "'!")
                    end
                end, name)
            else
                if count > 3 then
                    count = 1
                    print("Waiting for client config '" .. dump(name) .. "' to load...")
                    Citizen.Wait(5 * 1000);
                    receivedResponse = true
                else
                    count = count + 1
                end
            end
            Citizen.Wait(100);
        end
    end

    return configData
end

exports('getConfig', getConfig)

RegisterNetEvent("ov_configs:deleteConfigCache")
AddEventHandler("ov_configs:deleteConfigCache", function(configName)
    debug("Got reload for config '" .. tostring(configName) .. "'.")
    if configName ~= nil then
        clientConfigs[configName] = nil
    end
end)