local hotwiring = false
local keys = {}

local ped = nil

local function hasKey(veh)
    for k, v in pairs(keys) do
        if k == veh then
            return v
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        ped = GetPlayerPed(-1)

        if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then
			-- gets vehicle player is trying to enter and its lock status
            local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
            
            if not vRP.EXT.Garage:getAllVehicles()[veh] then
                return
            end

            local lock = GetVehicleDoorLockStatus(veh)
            if lock == 7 or not hasKey(veh) then
                keys[veh] = false
                --SetVehicleDoorsLocked(veh, 2)
            end
                 
            local pedd = GetPedInVehicleSeat(veh, -1)

            if pedd then                   
                SetPedCanBeDraggedOut(pedd, false)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsPedSittingInAnyVehicle(ped) then
            local veh = GetVehiclePedIsIn(ped, false)
            for k, v in pairs(keys) do
                
                if not DoesEntityExist(k, false) then
                    keys[k] = nil
                    goto continue
                end
                if not v then
                    SetVehicleEngineOn(k, false, true, false)
                    if IsControlJustPressed(0, 104) and not hotwiring then
                        hotwireCar(k)
                    end
                end
                ::continue::
            end
        end
    end
end)

local HOTWIRE_MAX_TIME = 210
local hotwire = 0

function hotwireCar(veh)
    hotwiring = true
    hotwire = 0
    vRP.EXT.GUI:setProgressBar("cars:hotwire","center","Hotwiring...",255,90,155,hotwire/HOTWIRE_MAX_TIME)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if IsPedSittingInAnyVehicle(ped) then
                hotwire = hotwire + 1
                vRP.EXT.GUI:setProgressBarValue("cars:hotwire",hotwire/HOTWIRE_MAX_TIME)

                if (hotwire > HOTWIRE_MAX_TIME) then
                    keys[veh] = true
                    break;
                end
            else
                break;
            end
        end
        vRP.EXT.GUI:removeProgressBar("cars:hotwire")
        hotwiring = false
    end)
end

