Citizen.CreateThread(function()
    MySQL.ready(function ()
        -- Configs Table
        MySQL.Async.execute("CREATE TABLE IF NOT EXISTS `ov_configs` (`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY, `name` VARCHAR(255) NOT NULL UNIQUE, `version` INT NOT NULL DEFAULT '0', `data` JSON NOT NULL, `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) ENGINE = InnoDB;", {},
                function(affectedRows) end);
    end)
end)

local configs = {}

function getConfig(name, defaultConfig, validationFunction)
    if name == nil or defaultConfig == nil then
        print("Could not get config for nil values!")
        return nil
    end

    local config = configs[name]

    if config == nil then
        config = loadConfig(name, defaultConfig, validationFunction)
        if config == nil then
            print("Could not load config with name: " .. dump(name))
            return nil
        end
        configs[name] = config

        if config.getVersion() < 0 then
            config.setVersion(0)
            saveConfig(name, config.getData(), 0, true)
        end
    end

    config.setValidation(validationFunction)

    return config
end

exports('getConfig', getConfig)

function loadConfig(name, defaultConfig, validationFunction)
    local row = MySQL.single.await('SELECT `name`, `version`, `data` FROM `ov_configs` WHERE `name` = ? LIMIT 1', {
        name
    })

    local config = createConfig(name)

    config.setDefaultConfig(validationFunction)
    config.setValidation(validationFunction)

    if not row then
        if not config.load(json.encode(defaultConfig)) then
            print("Could not load default config!")
            return nil
        end

        config.setVersion(-1)
    else
        if not config.load(row.data) then
            return nil
        end

        config.setVersion(row.version)
    end

    return config
end

function saveConfig(name, configObject, version, forceSave)
    local successEncode, rawData = pcall(json.encode, configObject)
    if not successEncode then
        print(string.format("Failed to encode config ('%s'): %s", name, configObject))
        return false, "Failed to encode config."
    end

    local config = configs[name]

    if config == nil and not forceSave then
        print("Could not save unloaded config!")
        return false, "Could not save unloaded config"
    end

    if not config.load(rawData) then
        print("Could not load rawData to save config (" .. dump(name) .. ")!")
        return false, "Could not load config"
    end

    if version then
        config.setVersion(version)
    end

    local existingRow = MySQL.single.await('SELECT `id` FROM `ov_configs` WHERE `name` = ? LIMIT 1', {
        name
    })

    if existingRow then
        if version then
            MySQL.update.await('UPDATE `ov_configs` SET `data` = ?, `version` = ?, `updatedAt` = CURRENT_TIMESTAMP WHERE `name` = ?', {
                rawData,
                version,
                name
            })
        else
            MySQL.update.await('UPDATE `ov_configs` SET `data` = ?, `updatedAt` = CURRENT_TIMESTAMP WHERE `name` = ?', {
                rawData,
                name
            })
        end

        debug(string.format("Config '%s' updated successfully in database.", name))
    else
        MySQL.insert.await('INSERT INTO `ov_configs` (`name`, `data`, `createdAt`, `updatedAt`) VALUES (?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)', {
            name,
            rawData
        })
        debug(string.format("Config '%s' created successfully in database.", name))
    end

    print(string.format("Config '%s' saved successfully.", name))

    sendReloadConfig(config)

    return true
end

exports('saveConfig', saveConfig)

Events.RegisterServerCallback("getUiConfig", function(src, cb, name)
    if name ~= nil then
        if canEditConfig(src, name) then
            local config = configs[name]
            if config ~= nil then
                cb(config.getSortedData())
                return
            else
                notifyPlayer(src, "error", "Configuration", "This config is not loaded yet.")
            end
        else
            notifyPlayer(src, "error", "Configuration", "No permissions to edit config.")
        end
    end
    cb(nil)
end)

Events.RegisterServerCallback("saveUiConfig", function(src, cb, name, configData)
    if name ~= nil then
        if canEditConfig(src, name) then
            local config = configs[name]
            if config ~= nil then
                local restoredConfigData = restoreSortedConfig(configData)
                cb(saveConfig(name, restoredConfigData, config.getVersion()))
                return
            else
                notifyPlayer(src, "error", "Configuration", "Failed to save config that is not loaded yet.")
            end
        else
            notifyPlayer(src, "error", "Configuration", "No permissions to save config.")
        end
    end
    cb(false)
end)

Events.RegisterServerCallback("getConfig", function(src, cb, name)
    if name ~= nil then
        local config = configs[name]
        if config ~= nil then
            local clientData = config.getClientData()
            if clientData then
                cb(clientData)
                return
            end
        end
    end
    cb(nil)
end)

function sendReloadConfig(config)
    if config == nil then
        print("Error: Tried to send reload of nil config!")
        return
    end

    local configName = config.getName()

    TriggerEvent("ov_configs:reloadConfig", configName)
    TriggerClientEvent("ov_configs:deleteConfigCache", -1, configName)
    Citizen.CreateThread(function()
        Citizen.Wait(50)
        TriggerClientEvent("ov_configs:reloadConfig", -1, configName)
    end)
end