vRPclient = Tunnel.getInterface("vRP", "utils")
vRPUtilS = Tunnel.getInterface("utils", "utils")

vRPUtil = {}
Tunnel.bindInterface("utils", vRPUtil)
Proxy.addInterface("utils", vRPUtil)

local weedLocation = {x = 2224.19091796875, y = 5576.9423828125, z = 53.8465042114258}
local recipies = {
    {name = "blunt", items = {{item = "weed", amount = 5}}, result = {{item = "edible|blunt", amount = 1}}},
    {name = "brick", items = {{item = "weed", amount = 25}}, result = {{item = "weed_brick", amount = 1}}},
    {
        name = "cocaine",
        loc = {x = 1392.245727539, y = 3606.6770019532, z = 38.941890716552},
        items = {{item = "wammo|WEAPON_PETROLCAN", amount = 50}, {item = "coca_leaf", amount = 10}},
        result = {{item = "edible|cocaine", amount = 1}}
    }
}

Citizen.CreateThread(
    function()
        Citizen.Wait(0)
        local blip = AddBlipForCoord(weedLocation.x, weedLocation.y, weedLocation.z)
        SetBlipSprite(blip, 140)
        SetBlipColour(blip, 25)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Weed")
        EndTextCommandSetBlipName(blip)
    end
)

-- Craft script

RegisterCommand(
    "craft",
    function(source, args, rawCommand)
        for k, v in pairs(recipies) do
            if (args[1] == v.name) then
                if loc ~= nil then
                    local coords = GetEntityCoords(GetPlayerPed(-1), false)
                    local dist = Vdist(v.loc.x, v.loc.y, v.loc.z, coords.x, coords.y, coords.z)
                    if not dist < 2 then
                        return
                    end
                end
                vRPUtilS._craftItem(v.items, v.result)
            end
        end
    end
)
