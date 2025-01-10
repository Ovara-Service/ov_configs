function createConfig(name, version)
    local self = {}

    self.id = nil
    self.name = name
    self.version = version
    self.rawData = nil
    self.data = nil

    self.defaultConfig = nil
    self.validation = nil

    function self.getName()
        return self.name
    end

    function self.setVersion(versionValue)
        self.version = versionValue
    end

    function self.getVersion()
        return self.version
    end

    function self.setData(dataTable)
        self.data = dataTable
    end

    function self.getSortedData()
        return sortConfig(self.getData())
    end

    function self.getData()
        return self.data
    end

    function self.setDefaultConfig(defaultConfigValue)
        self.defaultConfig = defaultConfigValue
    end

    function self.getDefaultConfig()
        return self.defaultConfig
    end

    function self.setValidation(validationFunction)
        if validationFunction ~= nil then
            self.validation = validationFunction
        else
            self.validation = function(configValues, defaultConfig)
                if defaultConfig == nil then
                    debug("Could not validate config (" .. self.getName() .. ") with missing default config.")
                    return true
                end
                for key, default in pairs(defaultConfig) do
                    if configValues[key] == nil then
                        print(string.format("Missing config key: %s", key))
                    else
                        local value = configValues[key].value
                        if type(value) ~= type(default.value) then
                            print(string.format("Invalid type for key '%s'. Expected '%s', got '%s'.", key, type(default.value), type(value)))
                            return false, string.format("Invalid type for key '%s'", key)
                        end
                    end
                end

                return true
            end
        end
    end

    function self.validateConfig(rawData)
        if self.validation == nil then
            print(string.format("Could not validate config ('%s'), cause validation function is missing.", self.name))
            return false, "Validation function is missing"
        end

        local configValues = {}

        local success, parsed = pcall(json.decode, rawData)
        if success and parsed then
            for key, configValue in pairs(parsed) do
                debug(string.format("Successfully loaded %s:%s with configValue: %s", self.name, key, dump(configValue)))

                local description = configValue.description
                local value = configValue.value

                if description ~= nil and value ~= nil then
                    configValues[key] = configValue
                else
                    print(string.format("Invalid config value for %s:%s with value: %s", self.name, key, dump(configValue)))
                    return false, string.format("Invalid config value for %s", key)
                end
            end
        else
            print(string.format("Failed to load config '%s': Invalid JSON or missing description.", row.name))
            return false, "Invalid JSON or missing description"
        end

        return self.validation(configValues, self.getDefaultConfig())
    end

    function self.load(rawData)
        local success, errorMessage = self.validateConfig(rawData)
        if not success then
            print(string.format("Failed to load config ('%s'): %s", self.name, errorMessage))
            return false, errorMessage
        end

        self.rawData = rawData

        local data = json.decode(rawData)
        self.setData(data)

        return true
    end

    function self.getClientData()
        local clientData = {}

        for key, configValue in pairs(self.getData()) do
            local client = configValue.client

            if client then
                clientData[key] = configValue
            end
        end

        return clientData
    end

    return self
end

function sortConfig(configTable)
    local sorted = {}
    for key, value in pairs(configTable) do
        table.insert(sorted, value)
        value._key = key
    end

    table.sort(sorted, function(a, b)
        return (a.sort or math.huge) < (b.sort or math.huge)
    end)

    local currentSort = 1
    for _, entry in ipairs(sorted) do
        if not entry.sort then
            entry.sort = currentSort
        end
        currentSort = currentSort + 1
    end

    return sorted
end

function restoreSortedConfig(sortedConfig)
    local restoredConfig = {}

    for _, entry in ipairs(sortedConfig) do
        if entry._key then
            restoredConfig[entry._key] = entry
            entry._key = nil
        else
            print("Sorted Config is missing _key, cannot restore original format.")
        end
    end

    return restoredConfig
end

