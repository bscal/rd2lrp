vRPclient = Tunnel.getInterface("vRP", "utils")
vRPUtilS = Tunnel.getInterface("utils", "utils")

vRPUtil = {}
Tunnel.bindInterface("utils", vRPUtil)
Proxy.addInterface("utils", vRPUtil)

local status = {}
local playerStress = 0.0
local showPlayerList = false
local markers = {}

-- * Class
local Utils = class("Utils", vRP.Extension)
Utils.User = class("User")
Utils.tunnel = {}

function Utils.tunnel:initPlayer()
    print("initilizing player...")
    Citizen.CreateThread(function()
        Citizen.Wait(1000)
        local stamina = (1 - GetPlayerSprintStaminaRemaining(PlayerId()) / 100)
        vRP.EXT.GUI:setProgressBar("bscal:stamina", "minimap", "", 255, 90, 155, stamina)

        vRP.EXT.GUI:setProgressBar("bscal:stress", "minimap", "", 150, 80, 150, 1 - playerStress / 100)
    end)
end

function Utils.tunnel:reloadPlayer()
    Citizen.CreateThread(function()
        Citizen.Wait(15000)
        ExecuteCommand('restart Stances')
        print("initilizing player complete!")
    end)
end

vRP:registerExtension(Utils)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)

            -- Reduce Vehicle Density
            SetVehicleDensityMultiplierThisFrame(0.7)
            SetParkedVehicleDensityMultiplierThisFrame(0.6)

            -- Online Players
            if (IsControlJustPressed(0, 214)) then
                showPlayerList = not showPlayerList
            end

            if (showPlayerList) then
                showOnlinePlayerBoard()
            end

            -- Remove Gun Reticle
            HideHudComponentThisFrame(14)
        end
    end
)

local colourH = {r = 255, b = 55, g = 55}
local colourR = {r = 255, b = 255, g = 255}
function showOnlinePlayerBoard()
    local x = 0.4
    local y = 0.075

    ShowInfoText("Name", x, y - .025, colourH)
    ShowInfoText("ID", x + 0.175, y - .025, colourH)

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            local target = GetPlayerPed(i)
            local source = GetPlayerServerId(i)
            local name = GetPlayerName(i)

            ShowInfoText(tostring(name), x, y, colourR)
            ShowInfoText(tostring(source), x + 0.175, y, colourR)

            y = y + 0.025
        end
    end
end

function ShowInfoText(text, x, y, colour)
    SetTextFont(0)
    SetTextScale(0.3, 0.3)
    SetTextColour(colour.r, colour.g, colour.b, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

RegisterNetEvent("DrawHiddenMarker")
AddEventHandler(
    "DrawHiddenMarker",
    function(x, y, z)
        for k, v in pairs(markers) do
            if v.x == x then
                return
            end
        end
        table.insert(markers, {x = x, y = y, z = z})
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)
            -- draw hidden markers
            for k, v in pairs(markers) do
                DrawMarker(1, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.8, 255, 55, 55, 155, 0)
            end
        end
    end
)

-- * Updates Progress Bars
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(32)
            local stamina = (1 - GetPlayerSprintStaminaRemaining(PlayerId()) / 100)
            vRP.EXT.GUI:setProgressBarValue("bscal:stamina", stamina)
            vRP.EXT.GUI:setProgressBarValue("bscal:stress", playerStress / 100)
        end
    end
)

-- * Stress update loop
Citizen.CreateThread(
    function()
        -- * Stress Level effects
        local STRESSED = 50
        local VERY_STRESSED = 75
        local PANIC = 96

        math.randomseed(GetGameTimer())
        while true do
            Citizen.Wait(1000 * 60)
            playerStress = playerStress + 10

            local rand = math.random(0, 100)
            if playerStress > PANIC then
                ShakeGameplayCam("JOLT_SHAKE", 3.0)

                local ped = GetPlayerPed(-1)
                print(rand)
                if rand > 98 then
                    SetEntityHealth(ped, 100)
                    playerStress = 50
                    exports.pNotify:SendNotification(
                        {text = "<b style='color:red'>[Status]</b> You have passed out from being stressed", timeout = 7500}
                    )
                end
                exports.pNotify:SendNotification(
                    {text = "<b style='color:red'>[Status]</b> You are extremely distressed", timeout = 7500}
                )
            elseif playerStress > VERY_STRESSED then
                ShakeGameplayCam("JOLT_SHAKE", 2.0)

                local ped = GetPlayerPed(-1)
                if GetEntityHealth(ped) > 130 and rand < 250 then
                    ApplyDamageToPed(ped, 5, false)
                end
                exports.pNotify:SendNotification(
                    {text = "<b style='color:red'>[Status]</b> You are extremely distressed", timeout = 7500}
                )
            elseif playerStress > STRESSED then
                ShakeGameplayCam("JOLT_SHAKE", 1.0)
                exports.pNotify:SendNotification(
                    {text = "<b style='color:red'>[Status]</b> You feel very anxious", timeout = 7500}
                )
            else
                ShakeGameplayCam("JOLT_SHAKE", 0.0)
            end
        end
    end
)

-- vRP Edible Client Side Events
RegisterNetEvent("applyArmour")
AddEventHandler(
    "applyArmour",
    function(value)
        AddArmourToPed(GetPlayerPed(-1), value)
    end
)

RegisterNetEvent("applyHigh")
AddEventHandler(
    "applyHigh",
    function(value)
        ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 2.0)
        Citizen.SetTimeout(
            20000,
            function()
                ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0.0)
            end
        )
    end
)

RegisterNetEvent("runSpeed")
AddEventHandler(
    "runSpeed",
    function(value)
        local multiplier = value.m
        print(value.m, value.t)
        if multiplier > 1.49 then
            multiplier = 1.49
        end
        SetRunSprintMultiplierForPlayer(PlayerId(), multiplier)
        Citizen.SetTimeout(
            value.t * 1000,
            function()
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
            end
        )
    end
)

local drunkness = 0
local maxDrunk = 200
local lightDrunk = 25
local medDrunk = 50
local heavyDrunk = 100

RegisterNetEvent("applyDrunk")
AddEventHandler(
    "applyDrunk",
    function(value)
        if (drunkness + value > maxDrunk) then
            return
        end
        drunkness = drunkness + value
    end
)

-- * Positive values add stress. Negitive values reduce stress
RegisterNetEvent("applyStress")
AddEventHandler(
    "applyStress",
    function(value)
        local newLevel = playerStress + value
        if newLevel < 0 then
            newLevel = 0
        elseif newLevel > 100 then
            newLevel = 100
        end
        playerStress = newLevel
    end
)

-- drunkness degrade
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(2500)
            local ped = GetPlayerPed(-1)
            if drunkness > 0 then
                drunkness = drunkness - 1

                if (drunkness > lightDrunk) then
                    RequestAnimSet("MOVE_M@DRUNK@SLIGHTLYDRUNK")
                    while (not HasAnimSetLoaded("MOVE_M@DRUNK@SLIGHTLYDRUNK")) do
                        Citizen.Wait(100)
                    end
                    SetPedMovementClipset(ped, "MOVE_M@DRUNK@SLIGHTLYDRUNK", 1.0)
                elseif (drunkness > medDrunk) then
                    RequestAnimSet("MOVE_M@DRUNK@MODERATEDRUNK")
                    while (not HasAnimSetLoaded("MOVE_M@DRUNK@MODERATEDRUNK")) do
                        Citizen.Wait(100)
                    end
                    SetPedMovementClipset(ped, "MOVE_M@DRUNK@MODERATEDRUNK", 1.0)
                elseif (drunkness > heavyDrunk) then
                    RequestAnimSet("MOVE_M@DRUNK@VERYDRUNK")
                    while (not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK")) do
                        Citizen.Wait(100)
                    end
                    SetPedMovementClipset(ped, "MOVE_M@DRUNK@VERYDRUNK", 1.0)
                end
            elseif drunkness == 0 then
                drunkness = -1
                RequestAnimSet("move_m@casual@d")
                while (not HasAnimSetLoaded("move_m@casual@d")) do
                    Citizen.Wait(100)
                end
                SetPedMovementClipset(ped, "move_m@casual@d", 1.0)
            end
        end
    end
)

function drawTxt(x, y, width, height, scale, text, r, g, b, a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

-- * PedMovementClipset Command

local walkStyles = {
    ["brave"] = "move_m@brave",
    ["casual"] = "move_m@casual@d",
    ["jog"] = "move_m@JOG@"
}

RegisterCommand(
    "walk",
    function(source, args, rawCommand)
        if #args < 2 then
            local str = "Usage: /walk <stylename>. Styles: "
            for k, _ in pairs(walkStyles) do
                str = str .. k .. ", "
            end

            TriggerEvent(
                "chat:addMessage",
                {
                    color = {0, 175, 255},
                    multiline = false,
                    args = {str}
                }
            )
            return
        end

        local ped = GetPlayerPed(-1)
        local style = walkStyles[args[2]]

        RequestAnimSet(style)

        while not HasAnimSetLoaded(style) do
            Citizen.Wait(50)
        end

        SetPedMovementClipset(ped, style, 1.0)
    end
)

--[[
    COORDS
    job1 - -258.60546875,-705.55871582032,34.27241897583
]]

-- * Drawing of speedomiter, location, direction

local zones = {
    ["AIRP"] = "Los Santos International Airport",
    ["ALAMO"] = "Alamo Sea",
    ["ALTA"] = "Alta",
    ["ARMYB"] = "Fort Zancudo",
    ["BANHAMC"] = "Banham Canyon Dr",
    ["BANNING"] = "Banning",
    ["BEACH"] = "Vespucci Beach",
    ["BHAMCA"] = "Banham Canyon",
    ["BRADP"] = "Braddock Pass",
    ["BRADT"] = "Braddock Tunnel",
    ["BURTON"] = "Burton",
    ["CALAFB"] = "Calafia Bridge",
    ["CANNY"] = "Raton Canyon",
    ["CCREAK"] = "Cassidy Creek",
    ["CHAMH"] = "Chamberlain Hills",
    ["CHIL"] = "Vinewood Hills",
    ["CHU"] = "Chumash",
    ["CMSW"] = "Chiliad Mountain State Wilderness",
    ["CYPRE"] = "Cypress Flats",
    ["DAVIS"] = "Davis",
    ["DELBE"] = "Del Perro Beach",
    ["DELPE"] = "Del Perro",
    ["DELSOL"] = "La Puerta",
    ["DESRT"] = "Grand Senora Desert",
    ["DOWNT"] = "Downtown",
    ["DTVINE"] = "Downtown Vinewood",
    ["EAST_V"] = "East Vinewood",
    ["EBURO"] = "El Burro Heights",
    ["ELGORL"] = "El Gordo Lighthouse",
    ["ELYSIAN"] = "Elysian Island",
    ["GALFISH"] = "Galilee",
    ["GOLF"] = "GWC and Golfing Society",
    ["GRAPES"] = "Grapeseed",
    ["GREATC"] = "Great Chaparral",
    ["HARMO"] = "Harmony",
    ["HAWICK"] = "Hawick",
    ["HORS"] = "Vinewood Racetrack",
    ["HUMLAB"] = "Humane Labs and Research",
    ["JAIL"] = "Bolingbroke Penitentiary",
    ["KOREAT"] = "Little Seoul",
    ["LACT"] = "Land Act Reservoir",
    ["LAGO"] = "Lago Zancudo",
    ["LDAM"] = "Land Act Dam",
    ["LEGSQU"] = "Legion Square",
    ["LMESA"] = "La Mesa",
    ["LOSPUER"] = "La Puerta",
    ["MIRR"] = "Mirror Park",
    ["MORN"] = "Morningwood",
    ["MOVIE"] = "Richards Majestic",
    ["MTCHIL"] = "Mount Chiliad",
    ["MTGORDO"] = "Mount Gordo",
    ["MTJOSE"] = "Mount Josiah",
    ["MURRI"] = "Murrieta Heights",
    ["NCHU"] = "North Chumash",
    ["NOOSE"] = "N.O.O.S.E",
    ["OCEANA"] = "Pacific Ocean",
    ["PALCOV"] = "Paleto Cove",
    ["PALETO"] = "Paleto Bay",
    ["PALFOR"] = "Paleto Forest",
    ["PALHIGH"] = "Palomino Highlands",
    ["PALMPOW"] = "Palmer-Taylor Power Station",
    ["PBLUFF"] = "Pacific Bluffs",
    ["PBOX"] = "Pillbox Hill",
    ["PROCOB"] = "Procopio Beach",
    ["RANCHO"] = "Rancho",
    ["RGLEN"] = "Richman Glen",
    ["RICHM"] = "Richman",
    ["ROCKF"] = "Rockford Hills",
    ["RTRAK"] = "Redwood Lights Track",
    ["SANAND"] = "San Andreas",
    ["SANCHIA"] = "San Chianski Mountain Range",
    ["SANDY"] = "Sandy Shores",
    ["SKID"] = "Mission Row",
    ["SLAB"] = "Stab City",
    ["STAD"] = "Maze Bank Arena",
    ["STRAW"] = "Strawberry",
    ["TATAMO"] = "Tataviam Mountains",
    ["TERMINA"] = "Terminal",
    ["TEXTI"] = "Textile City",
    ["TONGVAH"] = "Tongva Hills",
    ["TONGVAV"] = "Tongva Valley",
    ["VCANA"] = "Vespucci Canals",
    ["VESP"] = "Vespucci",
    ["VINE"] = "Vinewood",
    ["WINDF"] = "Ron Alternates Wind Farm",
    ["WVINE"] = "West Vinewood",
    ["ZANCUDO"] = "Zancudo River",
    ["ZP_ORT"] = "Port of South Los Santos",
    ["ZQ_UAR"] = "Davis Quartz"
}

local directions = {
    [0] = "N",
    [45] = "NW",
    [90] = "W",
    [135] = "SW",
    [180] = "S",
    [225] = "SE",
    [270] = "E",
    [315] = "NE",
    [360] = "N"
}

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)
            local pos = GetEntityCoords(GetPlayerPed(-1))
            local var1, var2 =
                GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())

            for k, v in pairs(directions) do
                direction = GetEntityHeading(GetPlayerPed())
                if (math.abs(direction - k) < 22.5) then
                    direction = v
                    break
                end
            end

            if (var2 ~= 0) then
                drawTxt(
                    0.515,
                    1.22,
                    1.0,
                    1.0,
                    0.4,
                    "~w~[~y~" .. tostring(GetStreetNameFromHashKey(var2)) .. "~w~]",
                    255,
                    255,
                    255,
                    255
                )
            end

            if (GetStreetNameFromHashKey(var1) and GetNameOfZone(pos.x, pos.y, pos.z)) then
                if (zones[GetNameOfZone(pos.x, pos.y, pos.z)] and tostring(GetStreetNameFromHashKey(var1))) then
                    drawTxt(
                        0.515,
                        1.25,
                        1.0,
                        1.0,
                        0.4,
                        direction ..
                            "~b~ | ~y~" ..
                                tostring(GetStreetNameFromHashKey(var1)) ..
                                    " ~w~/ ~y~" .. zones[GetNameOfZone(pos.x, pos.y, pos.z)],
                        255,
                        255,
                        255,
                        255
                    )
                end
            end

            if (IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
                local speed = GetEntitySpeed(GetVehiclePedIsIn(GetPlayerPed(-1), false)) * 2.236936

                drawTxt(0.665, 1.337, 1.0, 1.0, 0.7, "~y~" .. math.ceil(speed) .. "", 255, 255, 255, 255)
                drawTxt(0.692, 1.337, 1.0, 1.0, 0.7, "~b~ mph", 255, 255, 255, 255)
            end
        end
    end
)
