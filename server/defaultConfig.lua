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