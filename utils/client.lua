vRPclient = Tunnel.getInterface("vRP", "utils")
vRPUtilS = Tunnel.getInterface("utils", "utils")
vRPCoreS = Tunnel.getInterface("bscore", "bscore")

vRPUtil = {}
Tunnel.bindInterface("utils", vRPUtil)
Proxy.addInterface("utils", vRPUtil)

local playerStress = 0.0
local showPlayerList = false
local markers = {}

-- * Class
local Utils = class("Utils", vRP.Extension)
Utils.User = class("User")
Utils.tunnel = {}

function Utils.tunnel:initPlayer()
    print("initilizing player...")
    playerStress = vRPUtilS.getStress()
    Citizen.CreateThread(function()
        while true  do
            Citizen.Wait(1000)
            print(vRPCoreS.hasLoaded())
            if vRPCoreS.hasLoaded() then
                Citizen.Wait(1000)
                local stamina = (1 - GetPlayerSprintStaminaRemaining(PlayerId()) / 100)

                vRP.EXT.GUI:setProgressBar("bscal:stress", "minimap", "", 150, 80, 150, 1 - playerStress / 100)
                vRP.EXT.GUI:setProgressBar("bscal:stamina", "minimap", "", 255, 90, 155, stamina)
                vRP.EXT.GUI:setProgressBar("voice", "minimap", "", 153, 153, 153, 0.5)

                self.loaded = true
                print("player initilized.")
                break
            end
        end
    end)
end

function Utils.tunnel:saveStressClient()
    if not self.loaded then return end
    vRPUtilS._saveStressServer(playerStress)
end

vRP:registerExtension(Utils)

function vRPUtil.getStress()
    return playerStress;
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)

            -- Reduce Vehicle Density
            SetVehicleDensityMultiplierThisFrame(0.7)
            SetParkedVehicleDensityMultiplierThisFrame(0.5)

            -- Online Players
            if (IsControlJustPressed(0, 214)) then
                showPlayerList = not showPlayerList
            end

            if (showPlayerList) then
                showOnlinePlayerBoard()
            end

            -- Remove Gun Reticle
            HideHudComponentThisFrame(14)
        end
    end
)

local colourH = {r = 255, b = 55, g = 55}
local colourR = {r = 255, b = 255, g = 255}
function showOnlinePlayerBoard()
    local x = 0.4
    local y = 0.075

    ShowInfoText("Name", x, y - .025, colourH)
    ShowInfoText("ID", x + 0.175, y - .025, colourH)

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            local target = GetPlayerPed(i)
            local source = GetPlayerServerId(i)
            local name = GetPlayerName(i)

            ShowInfoText(tostring(name), x, y, colourR)
            ShowInfoText(tostring(source), x + 0.175, y, colourR)

            y = y + 0.025
        end
    end
end

function ShowInfoText(text, x, y, colour)
    SetTextFont(0)
    SetTextScale(0.3, 0.3)
    SetTextColour(colour.r, colour.g, colour.b, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

RegisterNetEvent("DrawHiddenMarker")
AddEventHandler(
    "DrawHiddenMarker",
    function(x, y, z)
        for k, v in pairs(markers) do
            if v.x == x then
                return
            end
        end
        table.insert(markers, {x = x, y = y, z = z})
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)
            -- draw hidden markers
            for k, v in pairs(markers) do
                DrawMarker(1, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 255, 55, 55, 155, 0)
            end
        end
    end
)

-- * Updates Progress Bars
Citizen.CreateThread(
    function()
        local stamina
        while true do
            Citizen.Wait(100)
            if vRPCoreS.hasLoaded() then
                stamina = (1 - GetPlayerSprintStaminaRemaining(PlayerId()) / 100)
                vRP.EXT.GUI:setProgressBarValue("bscal:stamina", stamina)
                vRP.EXT.GUI:setProgressBarValue("bscal:stress", playerStress / 100)
            end
        end
    end
)

-- * Stress update loop
Citizen.CreateThread(
    function()
        -- * Stress Level effects
        local STRESSED = 49
        local VERY_STRESSED = 74
        local PANIC = 95

        math.randomseed(GetGameTimer())

        local rand
        local ped
        exports['mythic_notify']:DoHudText('type', 'message')
        while true do
            Citizen.Wait(1000 * 30)

            playerStress = playerStress + 0.25
            ped = GetPlayerPed(-1)

            if playerStress > PANIC then
                ShakeGameplayCam("JOLT_SHAKE", 3.0)
                SetFlash(0, 0, 100, 5000, 100)

                rand = math.random(0, 1000)
                if rand > 950 then
                    SetEntityHealth(ped, 0)
                    exports['mythic_notify']:DoHudText('inform', 'You have passed out from being over stressed.')
                end
                exports['mythic_notify']:DoHudText('inform', 'You are noticeably anxious.')
            elseif playerStress > VERY_STRESSED then
                ShakeGameplayCam("JOLT_SHAKE", 2.0)
                SetFlash(0, 0, 100, 2000, 100)

                if GetEntityHealth(ped) > 100 then
                    ApplyDamageToPed(ped, 5, false)
                end

                exports['mythic_notify']:DoHudText('inform', 'You are stressed.')
            elseif playerStress > STRESSED then
                ShakeGameplayCam("JOLT_SHAKE", 1.0)
                SetFlash(0, 0, 100, 500, 100)

                exports['mythic_notify']:DoHudText('inform', 'You are noticeably anxious.')
            else
                ShakeGameplayCam("JOLT_SHAKE", 0.0)
            end
        end
    end
)

-- vRP Edible Client Side Events
RegisterNetEvent("applyArmour")
AddEventHandler("applyArmour", function(value)
    AddArmourToPed(GetPlayerPed(-1), value)
end)

RegisterNetEvent("applyHigh")
AddEventHandler("applyHigh",function(value)
    ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 2.0)
    Citizen.SetTimeout(
        10000 * value,
        function()
            ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0.0)
        end
    )
end)

RegisterNetEvent("runSpeed")
AddEventHandler("runSpeed", function(value)
    local multiplier = value.multiplier
    if multiplier > 1.49 then
        multiplier = 1.49
    end
    SetRunSprintMultiplierForPlayer(PlayerId(), multiplier)
    Citizen.SetTimeout(
        value.time * 1000,
        function()
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        end
    )
end)

function loanAnimSet(style)
    RequestAnimSet(style)
    while (not HasAnimSetLoaded(style)) do
        Citizen.Wait(100)
    end
end

local drunkness = 0.0
local maxDrunk = 200.0

-- drunkness degrade
Citizen.CreateThread(function()
    local lightDrunk = 25.0 
    local medDrunk = 50.0
    local heavyDrunk = 100.0
    local ped
    while true do
        Citizen.Wait(1000)
        if drunkness > 0.0 then
            ped = GetPlayerPed(-1)
            drunkness = drunkness - 0.25

            if (drunkness > lightDrunk) then
                loanAnimSet("MOVE_M@DRUNK@SLIGHTLYDRUNK")
                SetPedMovementClipset(ped, "MOVE_M@DRUNK@SLIGHTLYDRUNK", 1.0)
                RemoveAnimSet("MOVE_M@DRUNK@SLIGHTLYDRUNK")
            elseif (drunkness > medDrunk) then
                loanAnimSet("MOVE_M@DRUNK@MODERATEDRUNK")
                SetPedMovementClipset(ped, "MOVE_M@DRUNK@MODERATEDRUNK", 1.0)
                RemoveAnimSet("MOVE_M@DRUNK@MODERATEDRUNK")
            elseif (drunkness > heavyDrunk) then
                loanAnimSet("MOVE_M@DRUNK@VERYDRUNK")
                SetPedMovementClipset(ped, "MOVE_M@DRUNK@VERYDRUNK", 1.0)
                RemoveAnimSet("MOVE_M@DRUNK@VERYDRUNK")
            end

        elseif drunkness == 0. then
            drunkness = -1
            changeWalkStyle("default")
        end
    end
end)

RegisterNetEvent("applyDrunk")
AddEventHandler(
    "applyDrunk",
    function(value)
        if (drunkness + value > maxDrunk) then
            drunkness = maxDrunk
        end
        drunkness = drunkness + value
    end
)

-- * Positive values add stress. Negitive values reduce stress
RegisterNetEvent("applyStress")
AddEventHandler(
    "applyStress",
    function(value)
        local newLevel = playerStress + value
        if newLevel < 0 then
            newLevel = 0
        elseif newLevel > 100 then
            newLevel = 100
        end
        playerStress = newLevel
    end
)

function drawTxt(x, y, width, height, scale, text, r, g, b, a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

-- PedMovementClipset Command
local walkStyles = {
    ["brave"] = "move_m@brave",
    ["casual"] = "move_m@casual@d",
    ["jog"] = "move_m@JOG@",
    ["flee"] = "move_f@flee@a",
    ["scared"] = "move_f@scared",
    ["sexy"] = "move_f@sexy@a",
    ["female_gang"] = "MOVE_F@GANGSTER@NG",
    ["male_gang"] = "MOVE_M@GANGSTER@NG",
    ["femme1"] = "MOVE_M@FEMME@",
    ["femme2"] = "MOVE_F@FEMME@",
    ["male_posh"] = "MOVE_M@POSH@",
    ["female_posh"] = "MOVE_F@POSH@",
    ["male_toughguy"] = "MOVE_M@TOUGH_GUY@",
    ["female_toughguy"] ="MOVE_F@TOUGH_GUY@",
    ["default"] = "default"
}

-- Walk style command
RegisterCommand("walk", function(source, args, rawCommand)
    if #args < 2 then
        local str = "Usage: /walk <stylename>. Styles: "
        for k, _ in pairs(walkStyles) do
            str = str .. k .. ", "
        end

        TriggerEvent(
            "chat:addMessage",
            {
                color = {0, 175, 255},
                multiline = false,
                args = {str}
            }
        )
        return
    end

    changeWalkStyle(walkStyles[args[1]])
end)

function changeWalkStyle(style)
    local ped = GetPlayerPed(-1)

    if style == "default" then
        ResetPedMovementClipset(ped)
        ResetPedStrafeClipset(ped)
        ResetPedWeaponMovementClipset(ped)
    else
        RequestAnimSet(style)

        while not HasAnimSetLoaded(style) do
            Citizen.Wait(50)
        end

        SetPedMovementClipset(ped, style, 1.0)
        RemoveAnimSet(style)
    end
end

RegisterNetEvent("vrp:incrementStress")
AddEventHandler("vrp:incrementStress", function(value)
    playerStress = playerStress + value
end)

RegisterNetEvent("vrp:setStress")
AddEventHandler("vrp:setStress", function(value)
    playerStress = value
end)
