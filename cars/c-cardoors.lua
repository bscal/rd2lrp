local hotwiring = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local ped = GetPlayerPed(-1)

        if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then
			-- gets vehicle player is trying to enter and its lock status
            local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
            local lock = GetVehicleDoorLockStatus(veh)

            if lock == 7 then
                SetVehicleDoorsLocked(veh, 2)
            end
                 
            local pedd = GetPedInVehicleSeat(veh, -1)

            if pedd then                   
                SetPedCanBeDraggedOut(pedd, false)
            end
        end
    end
end)

local hotwire = 30

function hotwireCar(veh)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            vRP.EXT.GUI:setProgressBar("bscal:hotwire","center","Hotwiring...",255,90,155,hotwire/30)
        
            hotwire = hotwire - 1

            if (hotwire < 1) then
                vRP.EXT.GUI:removeProgressBar("bscal:hotwire")
                break;
            end
        end
    end)
end
