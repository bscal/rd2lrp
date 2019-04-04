local player        = nil
local cruisedSpeed  = 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(8);
        if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
            SetTextFont(2)
            SetTextFont(0)
            SetTextScale(0.4, 0.4)
            if cruisedSpeed < 1 then
                SetTextColour(105, 99, 99, 255)
            else
                SetTextColour(204, 153, 0, 255)
            end
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("C")
            DrawText(0.1662, 0.9)
        end
    end
end)



Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(1, 303) and IsDriver() and IsEngineRunning() then --k
            player = GetPlayerPed(-1)
            TriggerCruiseControl()
        end
    end
end)
  
function TriggerCruiseControl ()
    if cruisedSpeed == 0 and IsDriving() then
        if GetVehiculeSpeed() > 0 then
            cruisedSpeed = GetVehiculeSpeed()
            Citizen.CreateThread(function ()
                while cruisedSpeed > 0 and IsInVehicle() == player do
                    Citizen.Wait(0);

                    if not IsTurningOrHandBraking() and GetVehiculeSpeed() < (cruisedSpeed - 1.5) then
                        cruisedSpeed = 0
                        Citizen.Wait(2000)
                        break
                    end
            
                    if not IsTurningOrHandBraking() and IsVehicleOnAllWheels(GetVehicle()) and GetVehiculeSpeed() < cruisedSpeed then
                        SetVehicleForwardSpeed(GetVehicle(), cruisedSpeed)
                    end

                    if IsControlJustPressed(1, 303) then
                        cruisedSpeed = GetVehiculeSpeed()
                    end
		
                    if IsControlJustPressed(2, 72) then
                        cruisedSpeed = 0
                        Citizen.Wait(2000)
                        break
                    end
					
					if IsEngineRunning() == false then
						cruisedSpeed = 0
                        Citizen.Wait(1000)
                        break
					end
                end
            end)
        end
    end
end
  
function IsEngineRunning()
	return (GetVehicleEngineHealth(GetVehicle()) > -1)
end  
  
function IsTurningOrHandBraking ()
    return IsControlPressed(2, 76) or IsControlPressed(2, 63) or IsControlPressed(2, 64)
end
  
function IsDriving ()
    return IsPedInAnyVehicle(player, false)
end
  
function GetVehicle ()
    return GetVehiclePedIsIn(player, false)
end
  
function IsInVehicle ()
    return GetPedInVehicleSeat(GetVehicle(), -1)
end
  
function IsDriver ()
    return GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1)
end
  
function GetVehiculeSpeed ()
    return GetEntitySpeed(GetVehicle())
end
  
  