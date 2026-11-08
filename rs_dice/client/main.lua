local ESX = exports['es_extended']:getSharedObject()
local isRollingDice = false
local activeDisplays = {}

-- Vérifie si le point n'est pas caché par un mur/objet (vue caméra -> tête du joueur)
local function HasLineOfSight(camCoords, targetCoords, ignoreEntity)
    local rayHandle = StartShapeTestLosProbe(
        camCoords.x, camCoords.y, camCoords.z,
        targetCoords.x, targetCoords.y, targetCoords.z,
        1, ignoreEntity, 7
    )
    local _, hit = GetShapeTestResult(rayHandle)
    return hit == 0
end

-- Affiche les 2 faces de dés en 2D, suivant la tête du joueur ciblé
local function StartDiceDisplay(dice1, dice2, playerId)
    if activeDisplays[playerId] then
        activeDisplays[playerId].active = false
    end

    local state = { active = true }
    activeDisplays[playerId] = state

    Citizen.CreateThread(function()
        local duration = Config.DisplayDuration or 6000
        local endTime = GetGameTimer() + duration

        while state.active and GetGameTimer() < endTime do
            local visible = false
            local screenX, screenY = 0.5, 0.5

            local targetPlayer = GetPlayerFromServerId(playerId)
            if targetPlayer ~= -1 then
                local targetPed = GetPlayerPed(targetPlayer)
                if targetPed ~= 0 and DoesEntityExist(targetPed) then
                    local targetCoords = GetEntityCoords(targetPed)
                    local localCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(localCoords - targetCoords)

                    if distance <= (Config.DisplayDistance or 5.0) then
                        local headCoords = targetCoords + vector3(0.0, 0.0, 1.1)
                        local onScreen, x, y = GetScreenCoordFromWorldCoord(headCoords.x, headCoords.y, headCoords.z)

                        if onScreen then
                            local camCoords = GetGameplayCamCoord()
                            visible = HasLineOfSight(camCoords, headCoords, targetPed)
                            screenX, screenY = x, y
                        end
                    end
                end
            end

            SendNUIMessage({
                action = 'updateDice',
                playerId = playerId,
                dice1 = dice1,
                dice2 = dice2,
                x = screenX,
                y = screenY,
                visible = visible
            })

            Citizen.Wait(0)
        end

        if activeDisplays[playerId] == state then
            activeDisplays[playerId] = nil
        end
        SendNUIMessage({ action = 'hideDice', playerId = playerId })
    end)
end

-- Animation de lancer
local function PlayDiceAnimation()
    local playerPed = PlayerPedId()

    local animDict = "mp_player_int_upperwank"
    local animName = "mp_player_int_wank_01"

    RequestAnimDict(animDict)
    local timeout = 0
    while not HasAnimDictLoaded(animDict) and timeout < 50 do
        Citizen.Wait(10)
        timeout = timeout + 1
    end

    if HasAnimDictLoaded(animDict) then
        TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, 3000, 48, 0, false, false, false)
        return true
    end

    TaskPlayAnim(playerPed, "anim@mp_player_intcelebrationfemale@wank", "wank", 8.0, -8.0, 3000, 48, 0, false, false, false)
    return true
end

-- Fonction principale
local function UseDice()
    if isRollingDice then
        ESX.ShowNotification('~r~Vous lancez déjà les dés !')
        return
    end

    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed, false) then
        ESX.ShowNotification('~r~Vous ne pouvez pas lancer les dés dans un véhicule')
        return
    end

    isRollingDice = true

    PlayDiceAnimation()
    ESX.ShowNotification('~y~🎲 Lancement des dés...')

    Citizen.Wait(2500)

    local dice1 = math.random(1, 6)
    local dice2 = math.random(1, 6)
    local total = dice1 + dice2
    local myPlayerId = GetPlayerServerId(PlayerId())

    -- Affichage local immédiat
    StartDiceDisplay(dice1, dice2, myPlayerId)

    -- Diffusion aux joueurs proches
    TriggerServerEvent('lancer_de_des:showDiceForAll', dice1, dice2)

    ESX.ShowNotification(string.format('~g~🎲 %d + %d = %d 🎲', dice1, dice2, total))

    Citizen.Wait(2500)
    ClearPedTasks(playerPed)
    isRollingDice = false
end

-- Réception de l'UI des autres joueurs
RegisterNetEvent('lancer_de_des:showUIClient', function(dice1, dice2, playerId)
    StartDiceDisplay(dice1, dice2, playerId)
end)

-- Événements
RegisterNetEvent('lancer_de_des:useDice', function()
    UseDice()
end)

RegisterNetEvent('esx:useItem', function(item)
    if item == Config.DiceItem then
        UseDice()
    end
end)

RegisterCommand('testdice', function()
    UseDice()
end, false)

-- Nettoyage
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for playerId, state in pairs(activeDisplays) do
        state.active = false
        SendNUIMessage({ action = 'hideDice', playerId = playerId })
    end
end)
