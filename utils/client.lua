vRPclient = Tunnel.getInterface("vRP","utils")
vRPUtilS = Tunnel.getInterface("utils","utils")

vRPUtil = {}
Tunnel.bindInterface("utilsC", vRPUtil)
Proxy.addInterface("utilsC", vRPUtil)

local Utils = class("Utils", vRP.Extension)
Utils.User = class("User")

Utils.event = {}
function Utils.event:playerSpawn(user, first_spawn)
    local stamina = (1-GetPlayerSprintStaminaRemaining(PlayerId()) / 100)
    vRP.EXT.GUI:setProgressBar("bscal:stamina","minimap","",255,90,155,stamina)
end


local showPlayerList = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Reduce Vehicle Density
        SetVehicleDensityMultiplierThisFrame(0.7)
        SetParkedVehicleDensityMultiplierThisFrame(0.6)

        -- Online Players
        if (IsControlJustPressed(0,214)) then
            showPlayerList = not showPlayerList
        end

        if (showPlayerList) then
            showOnlinePlayerBoard()
        end

        -- Remove Gun Reticle
        HideHudComponentThisFrame(14)
    end
end)

colourH = {r = 255, b = 55, g = 55}
colourR = {r = 255, b = 255, g = 255}
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

markers = {}
RegisterNetEvent("DrawHiddenMarker")
AddEventHandler("DrawHiddenMarker", function(x, y, z)
    for k, v in pairs(markers) do
        if v.x == x then
            return
        end
    end
    table.insert( markers, {x = x, y = y, z = z} )
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k, v in pairs(markers) do
            -- draw hidden markers
            DrawMarker(1, v.x, v.y, v.z - 1,0,0,0,0,0,0,0.8,0.8,0.8, 255, 55, 55, 155,0)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(20)
        local stamina = (1-GetPlayerSprintStaminaRemaining(PlayerId()) / 100)
        vRP.EXT.GUI:setProgressBarValue("bscal:stamina", stamina)
    end
end)

-- vRP Edible Client Side Events 
RegisterNetEvent('applyArmour')
AddEventHandler('applyArmour', function(value)
    AddArmourToPed(GetPlayerPed(-1), value)
end)

local highness
RegisterNetEvent('applyHigh')
AddEventHandler('applyHigh', function(value)
    ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 2.0)
    Citizen.SetTimeout(20000, function() 
        ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0.0)
    end)
end)

RegisterNetEvent('runSpeed')
AddEventHandler('runSpeed', function(value)
    local multiplier = value.m
    print(multiplier)
    if multiplier > 1.49 then
        multiplier = 1.49
    end
    SetRunSprintMultiplierForPlayer(PlayerId(), multiplier)
    Citizen.SetTimeout(value.t * 1000, function() 
        print("fading")
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end)
end)

local drunkness = 0
local MAX_DRUNK = 200
local lightDrunk = 25
local medDrunk = 50
local heavyDrunk = 100

RegisterNetEvent('applyDrunk')
AddEventHandler('applyDrunk', function(value)
    if (drunkness + value > MAX_DRUNK) then
        return
    end
    drunkness = drunkness + value
end)

-- drunkness degrade
Citizen.CreateThread(function()

    while true do
        Citizen.Wait(2500)
        if drunkness > 0 then
            drunkness = drunkness - 1
            
            if (drunkness > lightDrunk) then
                RequestAnimSet( "MOVE_M@DRUNK@SLIGHTLYDRUNK" )
                while ( not HasAnimSetLoaded( "MOVE_M@DRUNK@SLIGHTLYDRUNK" ) ) do 
                    Citizen.Wait( 100 )
                end 
                SetPedMovementClipset( ped, "MOVE_M@DRUNK@SLIGHTLYDRUNK", 0.25 )
            elseif (drunkness > medDrunk) then
                RequestAnimSet( "MOVE_M@DRUNK@MODERATEDRUNK" )
                while ( not HasAnimSetLoaded( "MOVE_M@DRUNK@MODERATEDRUNK" ) ) do 
                    Citizen.Wait( 100 )
                end 
                SetPedMovementClipset( ped, "MOVE_M@DRUNK@MODERATEDRUNK", 0.25 )
            elseif (drunkness > heavyDrunk) then
                RequestAnimSet( "MOVE_M@DRUNK@VERYDRUNK" )
                while ( not HasAnimSetLoaded( "MOVE_M@DRUNK@VERYDRUNK" ) ) do 
                    Citizen.Wait( 100 )
                end 
                SetPedMovementClipset( ped, "MOVE_M@DRUNK@VERYDRUNK", 0.25 )
            end

        elseif drunkness == 0 then
            drunkness = -1
            RequestAnimSet( "move_m@casual@d" )
            while ( not HasAnimSetLoaded( "move_m@casual@d" ) ) do 
                Citizen.Wait( 100 )
            end 
            SetPedMovementClipset( ped, "move_m@casual@d", 0.25 )
        end
    end
end)

vRP:registerExtension(Utils)