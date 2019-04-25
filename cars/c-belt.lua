

local hasSeatBeltOn = false
local speedBuffer  = {}
local velBuffer    = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(8)
        local ped = GetPlayerPed(-1)
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped)

            if not hasSeatBeltOn then

                speedBuffer[2] = speedBuffer[1]
                speedBuffer[1] = GetEntitySpeed(veh)
                
                if speedBuffer[2] ~= nil
                    and GetEntitySpeedVector(veh, true).y > 1.0
                    and speedBuffer[1] > 19.0
                    and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.4) then
                        print()
                        local pos = GetEntityCoords(ped)
                        local fw = Fwv(ped)
                        SetEntityCoords(ped, pos.x + fw.x, pos.y + fw.y, pos.z - 0.47, true, true, true)
                        SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
                        Citizen.Wait(1)
                        SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
                end
            end

            velBuffer[2] = velBuffer[1]
            velBuffer[1] = GetEntityVelocity(veh)

            if IsControlJustPressed(1, 29) then
                hasSeatBeltOn = not hasSeatBeltOn
            end

            -- Draw
            SetTextFont(2)
            SetTextFont(0)
            SetTextScale(0.4, 0.4)
            if not hasSeatBeltOn then
                SetTextColour(105, 99, 99, 255)
            else
                SetTextColour(55, 255, 55, 255)
            end
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("B")
            DrawText(0.1962, 0.9)
        else
            hasSeatBeltOn = false
            speedBuffer[1], speedBuffer[2] = 0.0, 0.0
            SetPedRagdollOnCollision(ped, false)
        end
    end
end)

function Fwv(entity)
    local hr = GetEntityHeading(entity) + 90.0
    if hr < 0.0 then hr = 360.0 + hr end
    hr = hr * 0.0174533
    return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end