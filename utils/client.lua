-- * This resource is loaded twice once by vrp and once by fxserver.
if not vRP then
    -- * This is loaded regularly through fxserver to that exports can register
    exports('incrementStress', function(value)
        playerStress = playerStress + value
    end)
    
    exports('getStress', function()
        return playerStress
    end)
    
    exports('setStress', function(value)
        playerStress = value
    end)
    return
end

vRPclient = Tunnel.getInterface("vRP", "utils")
vRPUtilS = Tunnel.getInterface("utils", "utils")

vRPUtil = {}
Tunnel.bindInterface("utils", vRPUtil)
Proxy.addInterface("utils", vRPUtil)

local status = {}
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
    Citizen.Wait(1000)
    local stamina = (1 - GetPlayerSprintStaminaRemaining(PlayerId()) / 100)
    vRP.EXT.GUI:setProgressBar("bscal:stamina", "minimap", "", 255, 90, 155, stamina)

    vRP.EXT.GUI:setProgressBar("bscal:stress", "minimap", "", 150, 80, 150, 1 - playerStress / 100)
end

vRP:registerExtension(Utils)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)

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
            Citizen.Wait(0)
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
        while true do
            Citizen.Wait(32)
            local stamina = (1 - GetPlayerSprintStaminaRemaining(PlayerId()) / 100)
            vRP.EXT.GUI:setProgressBarValue("bscal:stamina", stamina)
            vRP.EXT.GUI:setProgressBarValue("bscal:stress", playerStress / 100)
        end
    end
)

-- * Stress update loop
Citizen.CreateThread(
    function()
        -- * Stress Level effects
        local STRESSED = 50
        local VERY_STRESSED = 75
        local PANIC = 96

        math.randomseed(GetGameTimer())
        while true do
            Citizen.Wait(1000 * 60)
            playerStress = playerStress + 0.5

            local rand = math.random(0, 1000)
            if playerStress > PANIC then
                ShakeGameplayCam("JOLT_SHAKE", 3.0)

                local ped = GetPlayerPed(-1)
                print(rand)
                if rand > 900 then
                    SetEntityHealth(ped, 100)
                    playerStress = 50
                    exports.pNotify:SendNotification(
                        {text = "<b style='color:red'>[Status]</b> You have passed out from being stressed", timeout = 7500}
                    )
                end
                exports.pNotify:SendNotification(
                    {text = "<b style='color:red'>[Status]</b> You are extremely distressed", timeout = 7500}
                )
            elseif playerStress > VERY_STRESSED then
                ShakeGameplayCam("JOLT_SHAKE", 2.0)

                local ped = GetPlayerPed(-1)
                if GetEntityHealth(ped) > 130 and rand < 300 then
                    ApplyDamageToPed(ped, 5, false)
                end
                exports.pNotify:SendNotification(
                    {text = "<b style='color:red'>[Status]</b> You are extremely distressed", timeout = 7500}
                )
            elseif playerStress > STRESSED then
                ShakeGameplayCam("JOLT_SHAKE", 1.0)
                exports.pNotify:SendNotification(
                    {text = "<b style='color:red'>[Status]</b> You feel very anxious", timeout = 7500}
                )
            else
                ShakeGameplayCam("JOLT_SHAKE", 0.0)
            end
        end
    end
)

-- vRP Edible Client Side Events
RegisterNetEvent("applyArmour")
AddEventHandler(
    "applyArmour",
    function(value)
        AddArmourToPed(GetPlayerPed(-1), value)
    end
)

RegisterNetEvent("applyHigh")
AddEventHandler(
    "applyHigh",
    function(value)
        ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 2.0)
        Citizen.SetTimeout(
            20000,
            function()
                ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0.0)
            end
        )
    end
)

RegisterNetEvent("runSpeed")
AddEventHandler(
    "runSpeed",
    function(value)
        local multiplier = value.m
        print(value.m, value.t)
        if multiplier > 1.49 then
            multiplier = 1.49
        end
        SetRunSprintMultiplierForPlayer(PlayerId(), multiplier)
        Citizen.SetTimeout(
            value.t * 1000,
            function()
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
            end
        )
    end
)

local drunkness = 0
local maxDrunk = 200
local lightDrunk = 25
local medDrunk = 50
local heavyDrunk = 100

RegisterNetEvent("applyDrunk")
AddEventHandler(
    "applyDrunk",
    function(value)
        if (drunkness + value > maxDrunk) then
            return
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

-- drunkness degrade
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(2500)
            local ped = GetPlayerPed(-1)
            if drunkness > 0 then
                drunkness = drunkness - 1

                if (drunkness > lightDrunk) then
                    RequestAnimSet("MOVE_M@DRUNK@SLIGHTLYDRUNK")
                    while (not HasAnimSetLoaded("MOVE_M@DRUNK@SLIGHTLYDRUNK")) do
                        Citizen.Wait(100)
                    end
                    SetPedMovementClipset(ped, "MOVE_M@DRUNK@SLIGHTLYDRUNK", 1.0)
                elseif (drunkness > medDrunk) then
                    RequestAnimSet("MOVE_M@DRUNK@MODERATEDRUNK")
                    while (not HasAnimSetLoaded("MOVE_M@DRUNK@MODERATEDRUNK")) do
                        Citizen.Wait(100)
                    end
                    SetPedMovementClipset(ped, "MOVE_M@DRUNK@MODERATEDRUNK", 1.0)
                elseif (drunkness > heavyDrunk) then
                    RequestAnimSet("MOVE_M@DRUNK@VERYDRUNK")
                    while (not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK")) do
                        Citizen.Wait(100)
                    end
                    SetPedMovementClipset(ped, "MOVE_M@DRUNK@VERYDRUNK", 1.0)
                end
            elseif drunkness == 0 then
                drunkness = -1
                RequestAnimSet("move_m@casual@d")
                while (not HasAnimSetLoaded("move_m@casual@d")) do
                    Citizen.Wait(100)
                end
                SetPedMovementClipset(ped, "move_m@casual@d", 1.0)
            end
        end
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

-- * PedMovementClipset Command

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

RegisterCommand(
    "walk",
    function(source, args, rawCommand)
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

        local ped = GetPlayerPed(-1)
        local style = walkStyles[args[1]]

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
)

--[[
    COORDS
    job1 - -258.60546875,-705.55871582032,34.27241897583
]]
