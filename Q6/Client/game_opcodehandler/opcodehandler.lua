-- Initialize the signal reader.
function init()
    print("INITIALZE")
    ProtocolGame.registerExtendedOpcode(100, onReceiveOpcode)
end

-- Cleanup everything.
function terminate()
    ProtocolGame.unregisterExtendedOpcode(100)
end

function onReceiveOpcode(protocol, opcode, packet)
    -- Dash opcode.
    if opcode == 100 then
        local values = {}

        -- Split the data from the packet.
        for word in packet:gmatch("([^,]+)") do
            table.insert(values, word)

        -- Get the creature that performed the dash.
        local creature = g_map.getCreatureById(tonumber(values[1]))

        -- Start or end the dash.
        if values[2] == "sd" then
            creature:startDash()
        elseif values[2] == "ed" then
            creature:endDash()
        end
    end
end