local jobLocations = {
    {name = "Weed Delivery", blip = 140, color = 69, x = 2488.0251464844, y = 4961.0825195312, z = 44.432537078858}
}

-- weed
local weedDeliveries = {
    {x = -296.08215332032, y = 6303.6611328125, z = 31.143125534058},
    {x = -1074.9006347656, y = -1666.2935791016, z = 4.0842680931092},
    {x = 44.42465209961, y = -1829.8405761718, z = 24.01655960083}
}

local weedStep = 0
local currentWeedLoc = nil
local deliveringWeed = 0.0

-- cocaine
local currentCocaineLocations = {}
local sellCocaineTimer = 60
local isSellingCocaine = false
local COCAINE_SELL_ALERT_CHANCE = 15

local isInArea = false

Citizen.CreateThread(
    function()
        initBlips(jobLocations)

        while true do
            Citizen.Wait(0)
            local ped = GetPlayerPed(-1)
            local pos = GetEntityCoords(ped, false)

            for k, v in pairs(jobLocations) do
                local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
                DrawMarker(1, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 255, 55, 55, 155, 0)
                if (dist < 2.0) then
                    ShowText("~y~Do job press ~p~H~y~.", .4, .8)
                    if IsControlJustReleased(0, 101) then
                        if v.name == "Weed Delivery" and weedStep < 1 and vRPjobsS.hasWeed() then
                            nextWeedStep()
                        end
                    end
                end
            end
            for k, v in pairs(currentCocaineLocations) do
                local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
                DrawMarker(1, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 255, 55, 55, 155, 0)
                if not IsPedInAnyVehicle(ped, false) then
                    if dist < 2.0 and not isSellingCocaine then
                        ShowText("~y~Sell cocaine ~p~H~y~.", .4, .8)
                        if IsControlJustReleased(0, 101) and vRPjobsS.hasCocaine() then
                            startCokeSale(ped, pos)
                        end
                    elseif dist < 5.0 then
                        --isInArea = true
                        if isSellingCocaine then
                            ShowText("~y~You are selling cocaine please stay in the area.", .35, .8)
                        end
                    end
                end
            end

            if weedStep > 0 and currentWeedLoc ~= nil then
                local dist = Vdist(pos.x, pos.y, pos.z, currentWeedLoc.x, currentWeedLoc.y, currentWeedLoc.z)
                DrawMarker(
                    1,
                    currentWeedLoc.x,
                    currentWeedLoc.y,
                    currentWeedLoc.z - 1,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0.8,
                    0.8,
                    0.8,
                    255,
                    55,
                    55,
                    155,
                    0
                )
                if dist < 2.0 then
                    if deliveringWeed > 0 then
                        vRP.EXT.GUI:setProgressBarValue("weed-delivery", deliveringWeed)
                    else
                        ShowText("~y~Deliver weed ~p~E~y~.", .4, .8)
                        if IsControlJustReleased(0, 38) then
                            deliveringWeed = 0.1
                            SetVehicleDoorOpen(GetVehiclePedIsIn(ped, false), 5, false, true)
                            vRP.EXT.GUI:setProgressBar("weed-delivery", "center", "", 60, 190, 60, deliveringWeed)
                        end
                    end
                end
            end
        end
    end
)

-- Count thread
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1000)
            if deliveringWeed > 0.0 then
                deliveringWeed = deliveringWeed + 0.1
                if deliveringWeed > 1.0 then -- end
                    if vRPjobsS.weedDelivery() then
                        nextWeedStep()
                    end
                    SetVehicleDoorShut(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, false, true)
                    vRP.EXT.GUI:removeProgressBar("weed-delivery")
                    deliveringWeed = 0.0
                end
            end
            if sellCocaineTimer > -1 then
                sellCocaineTimer = sellCocaineTimer - 1
                if isSellingCocaine and sellCocaineTimer < 1 then -- end
                    isSellingCocaine = false
                    --if isInArea then
                    vRPjobsS.completeCocaineSale()
                --end
                end
            end
        end
    end
)

function nextWeedStep()
    weedStep = weedStep + 1
    if weedStep > #weedDeliveries then
        weedStep = 0
        currentWeedLoc = nil
        vRPjobsS._completeWeedDelivery()
        return
    end
    currentWeedLoc = weedDeliveries[weedStep]
    SetNewWaypoint(currentWeedLoc.x, currentWeedLoc.y)
    vRP.EXT.Base.notify("Delivery the weed to the marked location")
end

function startCokeSale(ped, pos)
    isSellingCocaine = true
    sellCocaineTimer = 50 + vRPjobsS.getRandom(0, 20)
    if vRPjobsS.getRandom(0, 100) < COCAINE_SELL_ALERT_CHANCE then
        local x, y, z = table.unpack(pos)
        local streethash = GetStreetNameAtCoord(x, y, z)
        local street = GetStreetNameFromHashKey(streethash)

        TriggerEvent("DispatchRobbery", ped, "Reports of sale of narcotics", "None", street)
        TriggerEvent("DispatchPing", x, y, z, 120)
    end
end

function vRPjobs.switchCocaineLocations(spot1, spot2)
    currentCocaineLocations[1] = spot1
    currentCocaineLocations[2] = spot2
end

AddEventHandler(
    "playerSpawned",
    function()
        local loc1, loc2 = vRPjobsS.getCocaineLocations()
        currentCocaineLocations[1] = loc1
        currentCocaineLocations[2] = loc2
    end
)
