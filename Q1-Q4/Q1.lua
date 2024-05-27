function onLogout(player)
    if player:getStorageValue(1000) == 1 then -- Maybe there is a reason to only set the storage to -1 when its value is 1, so I kept it in.
        player:setStorageValue(1000, -1) -- Removed the "addEvent" with delay, since I'm assuming this is a just a test thing and the server actually doesn't require a 1000ms delay to release the storage.
    end

    return true
end