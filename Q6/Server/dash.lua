-- Define default configuration for the spell.
local data = {
    speed = 5,
    range = 5
}

-- Define a movement array that will indicate which direction the creature should  move based on their direction.
local directionMovement = {
    [DIRECTION_NORTH] = Position(0, -1),
    [DIRECTION_SOUTH] = Position(0, 1),
    [DIRECTION_WEST] = Position(-1, 0),
    [DIRECTION_EAST] = Position(1, 0),
    [DIRECTION_NORTHWEST] = Position(0, 0),
    [DIRECTION_NORTHEAST] = Position(0, 0),
    [DIRECTION_SOUTHWEST] = Position(0, 0),
    [DIRECTION_SOUTHEAST] = Position(0, 0)
}

-- Define the spell and set its properties.
local  spell = Spell(SPELL_INSTANT)
spell:id(1001)
spell:name("Dash")
spell:words("flash")
spell:group("attack")
spell:isSelfTarget(true)
spell:needLearn(false)
spell:level(1)
spell:mana(0)
spell:cooldown(0)
spell:groupCooldown(0)

function endDash(creatureId)
    -- Adds a little bit of delay before sending the packet.
    addEvent(function()
        local packet = NetworkMessage()
        packet:addByte(50) -- Packs "50" into the packet, which represents the Extend OPcode in the OTClient.
        packet:addByte(100) -- Packs "100" into the packet, which informs the OTClient that this creature is starting/ending a dash.
        packet:addString(tostring(creatureId) .. "," .. "ed") -- Packs the creature ID and "ed". I used a string because there is a bug with reading other data types in the OTClient.
        packet:sendToPlayer(Creature(creatureId))
        packet:delete()
    end, 5)
end

-- Define the function that performs the dash. It's recursive.
function dash(creatureId, range)
    local creatureData = Creature(creatureId)

    -- Check if the creature that cast this spell still exists.
    if not creatureData then
        return
    end

    -- Gather data that will be used later on.
    local creatureDirection = creatureData:getDirection()
    local targetPosition = creatureData:getPosition() + directionMovement[creatureDirection]
    local targetTile = Tile(targetPosition)

    -- Checks if the "targetTile" is a valid position or if there isn't any creature in it.
    if targetTile:hasFlag(bit.bor(TILESTATE_BLOCKPATH, TILESTATE_BLOCKSOLID, TILESTATE_PROTECTIONZONE, TILESTATE_TELEPORT, TILESTATE_MAGICFIELD, TILESTATE_FLOORCHANGE)) or targetTile:getCreatureCount() > 0 then
        endDash(creatureId)

        return
    end

    -- Checks if this is the first teleport.
    if range == data.range then
        local packet = NetworkMessage()
        packet:addByte(50) -- Packs "50" into the packet, which represents the Extend OPcode in the OTClient.
        packet:addByte(100) -- Packs "100" into the packet, which informs the OTClient that this creature is starting/ending a dash.
        packet:addString(tostring(creatureId) .. "," .. "sd") -- Packs the creature ID and "sd". I used a string because there is a bug with reading other data types in the OTClient.
        packet:sendToPlayer(creatureData)
        packet:delete()
    end

    -- Teleport the creature to the "targetPosition" and set its direction. I didn't find a better way of moving the creature in the source.
    creatureData:teleportTo(targetPosition, false)
    creatureData:setDirection(creatureDirection)

    -- Decrements the range, which works like a counter.
    range = range - 1

    -- Checks if the creature still have any movement left, if so, creates an event that will call dash again (with the remaining range as an argument). 
    if range > 0 then
        addEvent(dash, data.speed, creatureId, range)
    else
        endDash(creatureId)
    end
end

function spell.onCastSpell(creatureData, variant)
    if data.range > 0 then
        dash(creatureData:getId(), data.range)
    end

    return false -- Prevents the player from broadcasting the words in chat.
end

spell:register()