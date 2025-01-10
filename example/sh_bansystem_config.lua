Configuration = {
    ["debug"] = {
        sort = 1,
        client = true,
        description = "Enable debug mode for ovara configs.",
        value = true
    },
    ["locale"] = {
        sort = 2,
        client = true,
        description = "Language settings",
        value = "de"
    },
    ["logger"] = {
        description = "Logger settings",
        value = {
            enabled = true,
            resourceName = "yss_logger",
            storageName = "bansystem",
            adminJail = "bansystem_jails",
            reportStorageName = "bansystem_reports",
        }
    }
}

function waitConfigLoaded()
    while OV_CONFIG_DATA == nil do
        Citizen.Wait(100);
    end
end

while GetResourceState("ov_configs") ~= "started" do
    Citizen.Wait(1000 * 3);
    if GetResourceState("ov_configs") ~= "started" then
        print("You need to start ov_configs so that bansystem can start!")
    end
end

CONFIG_NAME = "bansystem"
if not IsDuplicityVersion() then -- Only register this event for the client
    OV_CONFIG_DATA = exports["ov_configs"]:getConfig(CONFIG_NAME)

    RegisterNetEvent("ov_configs:reloadConfig")
    AddEventHandler("ov_configs:reloadConfig", function(configName)
        if CONFIG_NAME == configName then
            OV_CONFIG_DATA = exports["ov_configs"]:getConfig(CONFIG_NAME)

            print("Successfully reloaded client configuration.")
        end
    end)
else
    OV_CONFIG = exports["ov_configs"]:getConfig(CONFIG_NAME, Configuration)
    OV_CONFIG_DATA = OV_CONFIG.getData()

    if OV_CONFIG_DATA ~= nil then
        print("Successfully loaded configuration.")
    else
        print("Failed to load configuration!")
    end

    RegisterNetEvent("ov_configs:reloadConfig")
    AddEventHandler("ov_configs:reloadConfig", function(configName)
        if CONFIG_NAME == configName then
            OV_CONFIG = exports["ov_configs"]:getConfig(CONFIG_NAME, Configuration)
            OV_CONFIG_DATA = OV_CONFIG.getData()

            print("Successfully reloaded configuration.")

            checkConfig()
        end
    end)

    function checkConfig()
        --[[
        if OV_CONFIG.getVersion() < 1 then
            OV_CONFIG_DATA["logger"] = {
                description = "Logger settings",
                value = {
                    enabled = true,
                    resourceName = "yss_logger",
                    storageName = "configs"
                }
            }
            exports["ov_configs"]:saveConfig(CONFIG_NAME, OV_CONFIG_DATA, 1)
        end]]
    end

    checkConfig()
end