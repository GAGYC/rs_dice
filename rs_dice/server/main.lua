local ESX = exports['es_extended']:getSharedObject()

-- Diffuser aux joueurs proches (le lanceur affiche déjà sa propre UI localement)
RegisterNetEvent('lancer_de_des:showDiceForAll', function(dice1, dice2)
    local src = source
    local sourcePed = GetPlayerPed(src)
    local sourceCoords = GetEntityCoords(sourcePed)

    local players = ESX.GetPlayers()
    for _, targetId in ipairs(players) do
        if targetId ~= src then
            local targetPed = GetPlayerPed(targetId)
            if targetPed ~= 0 then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(sourceCoords - targetCoords)

                if distance < (Config.BroadcastRadius or 50.0) then
                    TriggerClientEvent('lancer_de_des:showUIClient', targetId, dice1, dice2, src)
                end
            end
        end
    end
end)