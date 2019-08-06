local mph = 0.0
local doDraw = false;

Citizen.CreateThread(function()
    while true do
        if doDraw then
            SetTextFont(0)
            SetTextScale(0.4, 0.4)
            SetTextColour(255, 0, 0, 255)
            SetTextEntry("NUMBER")
            AddTextComponentFloat(mph, 1)
            DrawText(0.001, 0.5)
            SetTextFont(0)
            SetTextScale(0.3, 0.3)
            SetTextColour(255, 0, 0, 255)
            SetTextEntry("STRING")
            AddTextComponentString("mph")
            DrawText(0.025, 0.505)
        end
        Citizen.Wait(12);
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, true)
            local speed = GetEntitySpeed(veh);  
            mph = (speed * 2.236936); 
            doDraw = true;
        else
            doDraw = false;
        end
        Citizen.Wait(500);
    end
end)