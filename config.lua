isDebug = true

canEditConfig = function(source, configName)
    if IsPlayerAceAllowed(source, "config.admin") then
        return true
    end

    return IsPlayerAceAllowed(source, "config." .. configName)
end

canConfigTeleport = function(source)
    if IsPlayerAceAllowed(source, "config.admin") then
        return true
    end

    return IsPlayerAceAllowed(source, "config.teleport")
end

-- Custom Notify -- type is 'success' or 'error'
notifyPlayer = function(src, type, title, message)
    if src == 0 then
        print(title .. ': ' .. message)
    elseif src ~= nil then
        if GetResourceState("ov_notifier") == 'started' then
            TriggerClientEvent('ov_notify', src, type, title, message)
        else
            local xPlayer = ESX.GetPlayerFromId(src)
            xPlayer.showNotification(message)
        end
    else
        if GetResourceState("ov_notifier") == 'started' then
            TriggerEvent('ov_notify', type, title, message)
        else
            ESX.ShowNotification(message)
        end
    end
end