local defaultConfig = {
    ["debug"] = {
        description = "Enable debug mode for ovara configs.",
        value = false,
        sort = 1,
    },
    ["logger"] = {
        description = "Logger settings",
        value = {
            enabled = true,
            resourceName = "yss_logger",
            storageName = "configs"
        },
        sort = 2
    },
    ["spawnLocation"] = {
        description = "Spawn location",
        value = vector3(-30.2385, 1942.8660, 189.1860),
        sort = 3
    },
    ["playerSpawnLocation"] = {
        description = "Player spawn location",
        value = vector4(-30.2385, 1942.8660, 189.1860, 121.4813),
        sort = 3
    },
    ["spawnLocations"] = {
        description = "Spawn locations",
        value = {
            vector3(-30.2385, 1942.8660, 189.1860),
            vector3(-30.2385, 1942.8660, 189.1860),
            vector3(-30.2385, 1942.8660, 189.1860),
        },
        sort = 3
    },
    ["objects"] = {
        description = "Spawn objects",
        value = {
            {
                objPos = vector3(-627.735, -234.439, 37.875),
                model = 'des_jewel_cab_end'
            },
            {
                objPos = vector3(-627.735, -234.439, 37.875),
                model = 'des_jewel_cab_end'
            },
        },
        sort = 3
    }
}

function createDefaultConfig()
    local config = getConfig("default", defaultConfig)
    if config == nil then
        return
    end

    if config.getVersion() < 1 then
        local success, errorMessage = saveConfig(config.getName(), defaultConfig, 1)
        if success then
            debug("Default config created successfully.")
        else
            print(string.format("Failed to create default config: %s", errorMessage))
        end
    end
end

Citizen.CreateThread(function()
    MySQL.ready(function ()
        debug("Creating default config...")
        createDefaultConfig()
    end)
end)