if not vRP then goto nonvRP end

vRPclient = Tunnel.getInterface("vRP", "jobs")
vRPjobsS = Tunnel.getInterface("jobs", "jobs")
vRPjobs = {}
Tunnel.bindInterface("jobs", vRPjobs)
Proxy.addInterface("jobs", vRPjobs)

-- ! Temp jobs/deliveries
local deliveryJob = {
    {x = -425.2098083496, y = 6128.8266601562, z = 31.475679397584, name = "Delivery Job", blip = 67, color = 21},
    {x = 61.271408081054, y = 114.32566070556, z = 79.089897155762, name = "Delivery Job", blip = 67, color = 21}
}

local deliveryLocations = {
    {x = -290.15536499024, y = -1026.2470703125, z = 30.379957199096},
    {x = 642.75909423828, y = 276.9309387207, z = 103.19207763672},
    {x = -1379.859741211, y = 50.570621490478, z = 53.677974700928},
    {x = 26.67389678955, y = -1755.010131836, z = 29.303009033204},
    {x = 1202.1682128906, y = 2696.4016113282, z = 37.921215057374},
    {x = -144.14375305176, y = 6354.2202148438, z = 31.490629196166},
    {x = 2692.6315917968, y = 3453.1118164062, z = 55.790252685546}
}

local isDeliveryJob = false
local deliveriesDone = 0
local vehicle = nil
local currentDelivery = nil
local deliveryDist = 0

-- * Delivery Job Marker Manage Loop
Citizen.CreateThread(
    function()
        initBlips(deliveryJob)

        while true do
            Citizen.Wait(0)
            local ped = GetPlayerPed(-1)
            for k, v in pairs(deliveryJob) do
                DrawMarker(1, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 55, 55, 255, 155, 0)
                local pos = GetEntityCoords(ped, true)
                local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
                if (dist < 2.0) and not isDeliveryJob then
                    ShowText("~y~Take delivery job press ~p~H~y~.", .4, .8)
                    if (IsControlJustReleased(0, 101)) then
                        if vehicle == nil or not IsPedSittingInVehicle(ped, vehicle) then
                            local vehName = "BOXVILLE2"
                            -- load the model
                            RequestModel(vehName)
                            -- wait for the model to load
                            while not HasModelLoaded(vehName) do
                                Wait(500) -- often you'll also see Citizen.Wait
                            end
                            -- create the vehicle
                            vehicle = CreateVehicle(vehName, pos.x, pos.y, pos.z, GetEntityHeading(ped), true, false)
                            -- set the player ped into the vehicle's driver seat
                            SetPedIntoVehicle(ped, vehicle, -1)
                            -- give the vehicle back to the game (this'll make the game decide when to despawn the vehicle)
                            SetEntityAsNoLongerNeeded(vehicle)
                            -- release the model
                            SetModelAsNoLongerNeeded(vehName)
                        end
                        vRPjobs.newDelivery(pos)
                        isDeliveryJob = true
                        vRPjobsS._notify()
                    end
                end
            end
            if isDeliveryJob then
                if not DoesEntityExist(vehicle) then
                    vRPjobsS._truckCost(150)
                    isDeliveryJob = false
                elseif IsPedSittingInVehicle(ped, vehicle) then
                    for k, v in pairs(deliveryLocations) do
                        if (v.x == currentDelivery.x) then
                            DrawMarker(1, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 55, 55, 255, 155, 0)

                            local ped = GetPlayerPed(-1)
                            local pos = GetEntityCoords(ped, true)
                            local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
                            if (dist < 3.0) then
                                ShowText("~y~Take delivery job press ~p~E~y~.", .4, .8)
                                if (IsControlJustReleased(0, 38)) then
                                    vRPjobsS._completeDelivery(deliveryDist)
                                    isDeliveryJob = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end
)

function vRPjobs.newDelivery(pos)
    local index = vRPjobsS.random(#deliveryLocations)
    currentDelivery = deliveryLocations[index]
    deliveryDist = Vdist(pos.x, pos.y, pos.z, currentDelivery.x, currentDelivery.y, currentDelivery.z)
    SetNewWaypoint(currentDelivery.x, currentDelivery.y)
end

-- ! Functions

function initBlips(jobtable)
    for k, v in pairs(jobtable) do
        if not v.hidden then
            local blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(blip, v.blip)
            SetBlipColour(blip, v.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.name)
            EndTextCommandSetBlipName(blip)
        end
    end
end

function ShowText(text, x, y)
    SetTextFont(0)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

--[[
    !
    ! NUI and UI
    !
]]

::nonvRP::

if not vRP then
    local guiEnabled = false

    Citizen.CreateThread(
        function()
            while true do
                Citizen.Wait(0)

                if guiEnabled then
                    DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
                    DisableControlAction(0, 2, guiEnabled) -- LookUpDown
                    DisableControlAction(0, 24, guiEnabled) -- Attack
                    DisableControlAction(0, 15, guiEnabled) -- ScrollUp
                    DisableControlAction(0, 14, guiEnabled) -- ScrollDown
                    DisableControlAction(0, 16, guiEnabled) -- ScrollUp
                    DisableControlAction(0, 17, guiEnabled) -- ScrollDown
                    DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate
                    DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride
                else
                    EnableControlAction(0, 1, true) -- LookLeftRight
                    EnableControlAction(0, 2, true) -- LookUpDown
                    EnableControlAction(0, 24, true) -- Attack
                    EnableControlAction(0, 15, true) -- ScrollUp
                    EnableControlAction(0, 14, true) -- ScrollDown
                    EnableControlAction(0, 16, true) -- ScrollUp
                    EnableControlAction(0, 17, true) -- ScrollDown
                    EnableControlAction(0, 142, true) -- MeleeAttackAlternate
                    EnableControlAction(0, 106, true) -- VehicleMouseControlOverride
                end

                if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
                    SendNUIMessage(
                        {
                            type = "click"
                        }
                    )
                end
            end
        end
    )

    local function enableGui(enable, window)
        guiEnabled = enable
        SetNuiFocus(guiEnabled)
        SendNUIMessage(
            {
                type = "display",
                enable = guiEnabled,
                window = window
            }
        )
    end

    RegisterNUICallback(
        "escape",
        function(data)
            enableGui(false, "*")
        end
    )

    RegisterNUICallback(
        "clicked",
        function(data)
            print(data)
        end
    )

    RegisterNetEvent("jobs:enableWindow")
    AddEventHandler("jobs:enableWindow", function(enabled, window)
        enableGui(enabled, window)
    end)
end