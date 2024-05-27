-- Renamed "do_sth_with_PlayerParty" to "removeMemberFromPlayerParty" (I like verbose names) and switched it over to camelCase from snake_case.
-- Renamed "membername" to "memberName" to keep it consistent.
function removeMemberFromPlayerParty(playerId, memberName)
    local player = Player(playerId) -- Made the variable local.

    if player then -- Validates player.
        local party = player:getParty()

        if party then -- Validates party.
            -- Replaced  "removeMember" with "leaveParty" since the former does not exist.
            party:leaveParty(Player(memberName)) -- "leaveParty" internally checks if the "Player(memberName)" is from that party, making the loop unnecessary.
        end
    end
end