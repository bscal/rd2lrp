vRPclient = Tunnel.getInterface("vRP","utils")
vRPUtilS = Tunnel.getInterface("utils","utils")

vRPUtil = {}
Tunnel.bindInterface("utilsC", vRPUtil)
Proxy.addInterface("utilsC", vRPUtil)

local weedLocation = {x=2224.19091796875,y=5576.9423828125,z=53.8465042114258}
local recipies = {{name="blunt", items={{item="weed", amount=3}}, result={{item="edible|blunt", amount=1}}},}

Citizen.CreateThread(function()
    Citizen.Wait(0)
    local blip = AddBlipForCoord(weedLocation.x, weedLocation.y, weedLocation.z)
    SetBlipSprite(blip, 140)
    SetBlipColour(blip, 25)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Weed")
    EndTextCommandSetBlipName(blip)
end)

RegisterCommand('craft', function(source, args, rawCommand)
    for k, v in pairs(recipies) do
        if (args[1] == v.name) then
            if (vRPUtilS.hasItem(v.items[1].item, v.items[1].amount)) then
                print(v.result[1].item)
                print(v.result[1].amount)
                vRPUtilS.giveItem(v.result[1].item, v.result[1].amount)
                break
            end
        end
    end
end)

RegisterCommand('search', function(source, args, rawCommand)
    vRPUtilS.openInv(tonumber(args[1]))
end)