vRPclient = Tunnel.getInterface("vRP","robberies")
vRProbS = Tunnel.getInterface("robberies","robberies")

vRPRob = {}
Tunnel.bindInterface("robberiesC", vRPRob)
Proxy.addInterface("robberiesC", vRPRob)

local stores = {{id = 0, x = 27.76, y = -1339.425292968, z = 29.49702262878, robbed = false},
                {id = 1, x = -43.65297698974, y = -1749.421752929, z = 29.42101478576, robbed = false},
                {id = 2, x = 1126.567504882, y = -980.948669433, z = 45.415672302246, robbed = false},
                {id = 3, x = 1160.589477539, y = -314.78958129882, z = 69.205055236816, robbed = false},
                {id = 4, x = 2549.7866210938, y = 384.57153320312, z = 108.62294769288, robbed = false},
                {id = 5, x = 2673.4716796875, y = 3286.1538085938, z = 55.241138458252, robbed = false},
                {id = 6, x = 1168.6564941406, y = 2718.6403808594, z = 37.157554626464, robbed = false},
                {id = 7, x = 546.70965576172, y = 2663.5910644532, z = 42.156513214112, robbed = false},
                {id = 8, x = 1706.887084961, y = 4920.4985351562, z = 42.063674926758, robbed = false},
                --{id = 9, x = -3047.3142089844, y = 585.82287597656, z = 7.9089288711548, robbed = false},
                {id = 10, x = -3249.0600585938, y = 1003.8526611328, z = 12.830713272094, robbed = false},
                {id = 11, x = -2959.1184082032, y = 387.3699645996, z = 14.043173789978, robbed = false},
                {id = 12, x = -1478.8981933594, y = -375.27380371094, z = 39.163394927978, robbed = false},
                {id = 13, x = -1220.5802001954, y = -916.322265625, z = 11.326298713684, robbed = false},
                {id = 14, x = -709.40338134766, y = -904.8685913086, z = 19.215589523316, robbed = false},
                {id = 15, x = 378.28979492188, y = 333.32037353516, z = 103.56636810302, robbed = false}}

                

                
local robColors = {r = 255, g = 55, b = 0, a = 125}
CONST_ROB_TIME = 90
robTime = CONST_ROB_TIME
cooldownTime = 60 * 15
isNearRob = false
isRobbing = false           

function vRPRob.setStoreCooldown(id)
    for k, v in ipairs(stores) do
        if (v.id == id) then
            v.robbed = true
            resetCD(v)
            return
        end
    end
end

function resetCD(store)
    Citizen.SetTimeout(cooldownTime * 1000, function()
        store.robbed = false
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if  (robTime > 0) then
            robTime = robTime - 1
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped, true)
        isNearRob = false
        for k, v in ipairs(stores) do
            DrawMarker(1,v.x, v.y, v.z - 1,0,0,0,0,0,0,0.8,0.8,0.8, robColors.r, robColors.g, robColors.b,robColors.a,0)
            local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
            if(dist < 3.0) then
                isNearRob = true
                if (isNearRob) and not (isRobbing) and not (v.robbed) then
                    ShowInfoRevive("~y~Rob the bank press ~p~H~y~.", .35, .8)
                
                    if (IsControlJustReleased(0,101)) then
                        isRobbing = true
                        robTime = CONST_ROB_TIME
                        robStore(v.id)
                    end
                elseif (isRobbing) and (isNearRob) then
                    ShowInfoRevive("~y~Robbing the store. You have ~p~"..robTime.."~y~ seconds left.", .35, .8)
                end
            end
        end
    end
end)

function robStore(id)
    vRProbS.robStoreCooldown(id)
    Citizen.SetTimeout(CONST_ROB_TIME * 1000, function()
        if isNearRob and isRobbing and not IsEntityDead(GetPlayerPed(-1)) then
            vRProbS.robStore()
        end
        isRobbing = false
    end)
    alertPolice()
end

function alertPolice() 
    local ped = GetPlayerPed(-1)
    local x,y,z = table.unpack(GetEntityCoords(ped, true))
    local streethash = GetStreetNameAtCoord(x, y, z)
    local street = GetStreetNameFromHashKey(streethash)
    TriggerEvent("DispatchRobbery", ped, "Attempted Robbery", "None", street)
end

function ShowInfoRevive(text, x, y)
    SetTextFont(0)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end