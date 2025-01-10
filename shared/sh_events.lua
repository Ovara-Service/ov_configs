Events = {}

local eventPrefix = "ov_configs"

if IsDuplicityVersion() then
    Events.RegisterServerEvent = function(name, fn)
        RegisterNetEvent((eventPrefix .. ':server_event:' .. name), function(...)
            local playerId = source

            TriggerClientEvent((eventPrefix .. ':server_event:' .. name), playerId, fn(playerId, ...))
        end)
    end

    Events.TriggerClientEvent = function(playerId, name, ...)
        local p = promise.new()

        local handler = RegisterNetEvent((eventPrefix .. ':client_event:' .. name), function(...)
            p:resolve({ ... })
        end)

        TriggerClientEvent((eventPrefix .. ':client_event:' .. name), playerId, ...)

        local data = Citizen.Await(p)

        RemoveEventHandler(handler)

        return table.unpack(data)
    end

    local serverCallbacks = {}

    Events.RegisterServerCallback = function(eventName, callback)
        serverCallbacks[eventName] = callback
    end

    RegisterNetEvent(eventPrefix .. ':triggerServerCallback', function(eventName, requestId, invoker, ...)
        if not serverCallbacks[eventName] then
            return print(('[^1ERROR^7] Server Callback not registered, name: ^5%s^7, invoker resource: ^5%s^7'):format(eventName, invoker))
        end

        local source = source

        serverCallbacks[eventName](source, function(...)
            TriggerClientEvent(eventPrefix .. ':serverCallback', source, requestId, invoker, ...)
        end, ...)
    end)

    local clientRequests = {}
    local RequestId = 0

    Events.TriggerClientCallback = function(player, eventName, callback, ...)
        clientRequests[RequestId] = callback

        debug("Triggering client callback (" .. eventName .. ") with " .. dump(...))
        TriggerClientEvent(eventPrefix .. ':triggerClientCallback', player, eventName, RequestId, GetInvokingResource() or "unknown", ...)

        RequestId = RequestId + 1
    end

    RegisterNetEvent(eventPrefix .. ':clientCallback')
    AddEventHandler(eventPrefix .. ':clientCallback', function(requestId, invoker, ...)
        debug("Received clientCallback (" .. tostring(requestId) .. " - " .. tostring(invoker) .. ") with " .. dump({...}))
        if not clientRequests[requestId] then
            return print(('[^1ERROR^7] Client Callback with requestId ^5%s^7 Was Called by ^5%s^7 but does not exist.'):format(requestId, invoker))
        end

        clientRequests[requestId](...)
        clientRequests[requestId] = nil
    end)
else
    Events.TriggerServerEvent = function(name, ...)
        local p = promise.new()

        local handler = RegisterNetEvent((eventPrefix .. ':server_event:' .. name), function (...)
            p:resolve({ ... })
        end)

        TriggerServerEvent((eventPrefix .. ':server_event:' .. name), ...)

        local data = Citizen.Await(p)

        RemoveEventHandler(handler)

        return table.unpack(data)
    end

    Events.RegisterClientEvent = function(name, fn)
        RegisterNetEvent((eventPrefix .. ':client_event:' .. name), function(...)
            TriggerServerEvent((eventPrefix .. ':client_event:' .. name), fn(...))
        end)
    end

    local RequestId = 0
    local serverRequests = {}

    Events.TriggerServerCallback = function(eventName, callback, ...)
        serverRequests[RequestId] = callback

        TriggerServerEvent(eventPrefix .. ':triggerServerCallback', eventName, RequestId, GetInvokingResource() or "unknown", ...)

        RequestId = RequestId + 1
    end

    RegisterNetEvent(eventPrefix .. ':serverCallback', function(requestId, invoker, ...)
        if not serverRequests[requestId] then
            return print(('[^1ERROR^7] Server Callback with requestId ^5%s^7 Was Called by ^5%s^7 but does not exist.'):format(requestId, invoker))
        end

        serverRequests[requestId](...)
        serverRequests[requestId] = nil
    end)

    local clientCallbacks = {}

    Events.RegisterClientCallback = function(eventName, callback)
        clientCallbacks[eventName] = callback
    end

    RegisterNetEvent(eventPrefix .. ':triggerClientCallback', function(eventName, requestId, invoker, ...)
        if not clientCallbacks[eventName] then
            return print(('[^1ERROR^7] Client Callback not registered, name: ^5%s^7, invoker resource: ^5%s^7'):format(eventName, invoker))
        end

        debug("Got trigger callback (" .. eventName .. ") with " .. dump({...}))

        clientCallbacks[eventName](function(...)
            debug("Callback called (" .. eventName .. " - " .. tostring(requestId) ..  " - " .. tostring(invoker) .. ") with " .. dump({...}))
            TriggerLatentServerEvent(eventPrefix .. ':clientCallback', 100000, requestId, invoker, ...)
        end, ...)
    end)
end