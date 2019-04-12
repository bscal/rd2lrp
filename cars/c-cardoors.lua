local hotwiring = false
local keys = {}

local ped = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        ped = GetPlayerPed(-1)

        if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then
			-- gets vehicle player is trying to enter and its lock status
            local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
            local lock = GetVehicleDoorLockStatus(veh)

            if lock == 7 then
                --keys[tostring(veh)] = false
                SetVehicleDoorsLocked(veh, 2)
            end
                 
            local pedd = GetPedInVehicleSeat(veh, -1)

            if pedd then                   
                SetPedCanBeDraggedOut(pedd, false)
            end
        end
    end
end)

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)
--         if IsPedSittingInAnyVehicle(ped) then
--             local veh = GetVehiclePedIsIn(ped, false)
--             for k, v in pairs(keys) do
--                 if not DoesEntityExist(tonumber(k), false) then
--                     keys[k] = nil
--                     return
--                 end
--                 if not v then
--                     SetVehicleEngineOn(tonumber(k), false, true, false)
--                     if IsControlJustPressed(0, 104) and not hotwiring then
--                         hotwireCar(tonumber(k))
--                     end
--                 end
--             end
--         end
--     end
-- end)

local hotwire = 0
function hotwireCar(veh)
    hotwiring = true
    hotwire = 0
    vRP.EXT.GUI:setProgressBar("cars:hotwire","center","Hotwiring...",255,90,155,hotwire/30)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            print(#keys)
            if IsPedSittingInAnyVehicle(ped) then
                hotwire = hotwire + 1
                vRP.EXT.GUI:setProgressBarValue("cars:hotwire",hotwire/30)

                if (hotwire > 30) then
                    vRP.EXT.GUI:removeProgressBar("cars:hotwire")
                    keys[tostring(veh)] = true
                    break;
                end
            else
                break;
            end
        end
        hotwiring = false
    end)
end
