function printSmallGuildNames(memberCount)
    -- This method is supposed to print names of all guilds that have less than memberCount max members
    local selectGuildQuery = "SELECT `name` FROM `guilds` WHERE `max_members` < %d;" -- Added backticks for safety.
    local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))

    -- Added a check to prevent operations on an empty result.
    if resultId ~= false then
        repeat
            local guildName = result.getString(resultId, "name") -- Added resultId since it was missing.
    
            print(guildName)
        until not result.next(resultId) -- Iterate over all resulting guilds.
        
        result.free(resultId) -- Free data.
    end
end