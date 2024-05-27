-- Define default configuration for the spell.
local data = {
    tornadoType  = COMBAT_ICEDAMAGE,
    tornadoEffect = CONST_ME_ICETORNADO,
    tornadoPercentChance = 60, -- Chance to spawn a tornado.
    waveCount = 6,
    waveRate = 300, -- Time between each wave. The first wave is cast instantly.
}

-- Create the tornado object that will be used to deal the damage.
local tornado = Combat()
tornado:setParameter(COMBAT_PARAM_TYPE, data.tornadoType)
tornado:setParameter(COMBAT_PARAM_EFFECT, data.tornadoEffect)
tornado:setParameter(COMBAT_PARAM_AGGRESSIVE, true)

-- Define the damage function that will get damage formula for the tornado.
function onGetFormulaValues(creatureData, level, magicLevel)
    return -150, -200
end

tornado:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

-- Create the wave object that will be used to delineate the area in which tornados can be spawned.
local wave  = Combat()
wave:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

-- Define the area of the wave. I used 2 as the center since it ignores that position for casting.
local area = {
    {0, 0, 0, 0, 1, 0, 0, 0, 0},
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {1, 1, 1, 1, 2, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 1, 1, 0, 0, 0},
    {0, 0, 0, 0, 1, 0, 0, 0, 0}
}

wave:setArea(createCombatArea(area))

-- Define the callback function that will be called on every valid position of the wave.
function onTargetTile(creatureData, position)
    if math.random(0, 100) < data.tornadoPercentChance then
        tornado:execute(creatureData, Variant(position)) -- Casts the tornado at the desired position. The execute function requires the second argument to be a "Variant".
    end
end

wave:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")

-- Define the function that actually casts the spell.
function cast(creatureId, variant)    
    local creatureData = Creature(creatureId)

     -- Checks if the creature that cast this spell still extists.
    if not creatureData then
        return
    end

    -- Creates the wave that will call "onTargetTile" for every valid position.
    wave:execute(creatureData, variant)
end

-- Define the spell and set its properties.
local spell = Spell(SPELL_INSTANT)
spell:id(1000)
spell:name("Cold Wave")
spell:words("frigo")
spell:group("attack")
spell:isSelfTarget(true)
spell:needLearn(false)
spell:level(1)
spell:mana(0)
spell:cooldown(0)
spell:groupCooldown(0)

-- Define that event that will be called when a player says "frigo" in the chat.
function spell.onCastSpell(creatureData, variant)
    -- Cast the first wave if "waveCount" is bigger than 0.
    if data.waveCount > 0 then
        cast(creatureData:getId(), variant)
    end

    -- Loop through desired number of waves and create delayed events that will cast them.
    for i = 1, data.waveCount - 1 do
        addEvent(cast, i*data.waveRate, creatureData:getId(), variant) -- Pass "creatureData:getId()" as an argument instead of "creatureData" to prevent invalid data in case the creature is destroyed in the meantime.
    end

    return true
end

spell:register()
