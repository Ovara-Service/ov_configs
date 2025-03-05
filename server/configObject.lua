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
                        print(string.format("Config (" .. self.getName() .. ") is missing config key: %s", key))
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

    -- Helper function to convert values to the correct type based on default config
    local function convertValue(value, defaultValue)
        if defaultValue == nil then
            return value -- No conversion if no default is provided
        end

        local defaultType = type(defaultValue)
        if defaultType == "number" then
            if type(value) == "string" then
                -- Check if the string contains a decimal point
                if value:find("%.") then
                    -- Force float representation by adding .0 if needed
                    local num = tonumber(value)
                    if num then
                        -- If the string ends with .0, ensure it stays a float
                        if value:match("%.0$") and math.floor(num) == num then
                            return num + 0.0 -- Forces float representation
                        end
                        return num
                    end
                end
                return tonumber(value) or value -- Fallback to original if not a number
            end
            return value -- Return as-is if already a number
        elseif defaultType == "boolean" then
            return value == "true" or value == true
        elseif defaultType == "table" then
            if type(value) ~= "table" then
                print("Could not convert invalid value for '" .. dump(value) .. "' with default: " .. dump(defaultValue))
                return value -- Cannot convert non-table to table
            end
            local convertedTable = {}
            for k, v in pairs(value) do
                convertedTable[k] = convertValue(v, defaultValue[k])
            end
            return convertedTable
        end
        return value -- Return as-is for strings or other types
    end

    function self.validateConfig(rawData)
        if self.validation == nil then
            print(string.format("Could not validate config ('%s'), cause validation function is missing.", self.name))
            return false, "Validation function is missing", nil
        end

        local configValues = {}

        local success, parsed = pcall(json.decode, rawData)
        if success and parsed then
            for key, configValue in pairs(parsed) do
                debug(string.format("Successfully loaded %s:%s with configValue: %s", self.name, key, dump(configValue)))

                local description = configValue.description
                local value = configValue.value

                if description ~= nil and value ~= nil then
                    -- Convert the value based on default config
                    local defaultEntry = self.getDefaultConfig() and self.getDefaultConfig()[key]
                    local defaultValue = defaultEntry and defaultEntry.value
                    configValues[key] = {
                        description = description,
                        value = convertValue(value, defaultValue),
                        client = configValue.client,
                        sort = configValue.sort
                    }
                else
                    print(string.format("Invalid config value for %s:%s with value: %s", self.name, key, dump(configValue)))
                    return false, string.format("Invalid config value for %s", key), nil
                end
            end
        else
            print(string.format("Failed to load config '%s': Invalid JSON or missing description.", self.name))
            return false, "Invalid JSON or missing description", nil
        end

        local validationSuccess, validationError = self.validation(configValues, self.getDefaultConfig())
        if not validationSuccess then
            return false, validationError, nil
        end

        return true, nil, configValues
    end

    function self.load(rawData)
        local success, errorMessage, validatedConfig = self.validateConfig(rawData)
        if not success then
            print(string.format("Failed to load config ('%s'): %s", self.name, errorMessage))
            return false, errorMessage
        end

        self.rawData = rawData
        self.setData(validatedConfig) -- Use the validated and converted config values

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