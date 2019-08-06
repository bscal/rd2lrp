AddEventHandler('playerConnecting', function(playerName, setKickReason)
    identifiers = GetPlayerIdentifiers(source)
    for i in ipairs(identifiers) do
        print('Player: ' .. playerName .. ', Identifier #' .. i .. ': ' .. identifiers[i])
    end
end)