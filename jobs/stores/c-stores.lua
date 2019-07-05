local stores = {}

Citizen.CreateThread(
    function()
        for _, v in pairs(stores) do
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

        while true do
            Citizen.Wait(0)
            local ped = GetPlayerPed(-1)
            local pos = GetEntityCoords(ped, false)

            for k, v in pairs(stores) do
                local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
                DrawMarker(1, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 255, 55, 55, 155, 0)
            end
        end
    end
)
