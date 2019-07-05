vRPclient = Tunnel.getInterface("vRP", "cops")
vRPCopsS = Tunnel.getInterface("cops", "cops")

vRPCops = {}
Tunnel.bindInterface("cops", vRPCops)
Proxy.addInterface("cops", vRPCops)

-- Admin and admin permission level
isAdmin = false
permLevel = 0

-- Cop, Ems, etc permissions
isCop = false
isEMS = false

-- Player statuses
local handcuffed = false
local deletegun = false
local volume = 1.0
local nearEMS = false;
local nearMDT = false;
local mdtLoggedIn = false;

local policeCoords = {{name = "Police Station", x = 441.07467651368, y = -978.25646972656, z = 30.689603805542}, --main
                {name = "Police Station", x = 1852.9038085938, y = 3690.0769042968, z = 34.267082214356}, --ss
                {name = "Police Station", x = -449.4927368164, y = 6012.422855625, z = 31.71650314331}, --p
                {name = "Police Station", x = 1755.4387207032, y = 2614.3198242188, z = 45.56502532959},  --bb
                {name = "Police Station", x = 459.74032592774, y = -989.16204833984, z = 24.914859771728}} --main
local policeColors = {r = 35, g = 45, b = 235,a = 125}
local emsCoords = {{name = "Hospital", x = 306.724609375, y = -595.47827148438, z = 43.995809082032}}
local emsColors = {r = 41, g = 41, b = 255,a = 125}

Citizen.CreateThread(function()
    for k, v in ipairs(policeCoords) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blip, 60)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
    end

    for k, v in ipairs(emsCoords) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blip, 61)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
    end

    while true do
        Citizen.Wait(8)
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped, true)

        for k, v in ipairs(policeCoords) do
            DrawMarker(1,v.x, v.y, v.z - 1,0,0,0,0,0,0,0.8,0.8,0.8, policeColors.r, policeColors.g, policeColors.b,policeColors.a,0)

            local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
            if (dist < 2.0) then
                mdtLoggedIn = true
            else
                mdtLoggedIn = false
            end
        end

        for k, v in ipairs(emsCoords) do
            DrawMarker(1,v.x, v.y, v.z - 2,0,0,0,0,0,0,0.8,0.8,0.8, emsColors.r, emsColors.g, emsColors.b,emsColors.a, 0)
            
            local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
            if (dist < 16.0) then
                Draw3DText(v.x, v.y, v.z + 1.0, "Check into the hospital [space]. Cost 100$.")
            end
            if(dist < 2.0) then
                nearEMS = true
                if (IsControlJustReleased(0,22)) then
                    if (IsEntityDead(ped)) then
                        vRPCopsS.hospitalStay(100)
                        revivePed(ped)
                        hospitalAlert()
                    elseif (GetEntityHealth(ped) < 200) then
                        vRPCopsS.hospitalStay(100)
                        SetEntityHealth(ped, 200)
                        hospitalAlert()
                    end
                end
            elseif (dist > 4.0) and (nearEMS) then
                nearEMS = false
            end
        end
    end
end)

function hospitalAlert()
    TriggerEvent("pNotify:SendNotification", {
        text = "<b style='color:#32b338'>Pillbox Hospital</b><br /><p>You were charged 100$ for your stay.</p>",
        type = "success",
        timeout = 5000,
        layout = "topRight"
    })
end

RegisterNetEvent('isCop')
AddEventHandler('isCop', function()
    if (isCop) then
        return
    end
    isCop = true
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 255},
        multiline = true,
        args = {"Police", " You are a cop"}
    })
end)

RegisterNetEvent('isEMS')
AddEventHandler('isEMS', function()
    if (isEMS) then
        return
    end
    isEMS = true
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 255},
        multiline = true,
        args = {"EMS", " You are an EMS"}
    })
end)

AddEventHandler('onClientMapStart', function()
    Citizen.Wait(500)
	exports.spawnmanager:spawnPlayer() -- Ensure player spawns into server.
	Citizen.Wait(2500)
	exports.spawnmanager:setAutoSpawn(false)
end)

local fullyLoaded = false

AddEventHandler('playerSpawned', function()
    fullyLoaded = true
end)

AddEventHandler('cop:revivePlayer', function()
    reviveWait = 120
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)
        if (fullyLoaded) then
            vRPCopsS.isCopToClient()
            vRPCopsS.isAdmin()
            if (isCop) or (isEMS) then
                TriggerEvent("isService", isCop, isEMS)
            end
        end
    end
end)

RegisterNetEvent('cop:clientIsAdmin')
AddEventHandler('cop:clientIsAdmin', function(admin, perm)
    isAdmin = admin
    permLevel = perm
end)

-- Commands

RegisterCommand('emsonduty', function()
    vRPCopsS._isEMS()
end)

RegisterCommand('cuff', function()
	if isCop == true then
		closest, distance = GetClosestPlayer()
		if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
			if distance -1 and distance < 3 then
                TriggerEvent('chat:addMessage', {
                    color = {255, 255, 255},
                    multiline = true,
                    args = {"You have cuffed a player"}
                })
				local closestID = GetPlayerServerId(closest)
				TriggerServerEvent('cuffServer', closestID)
            else
                TriggerEvent('chat:addMessage', {
                    color = {255, 255, 255},
                    multiline = false,
                    args = {"Nearest player is too far away."}
                })
			end
		end
	else
		TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = false,
            args = {"You are not a cop."}
        })
	end
end)

RegisterCommand('uncuff', function()
	if isCop == true then
		closest, distance = GetClosestPlayer()
		if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
            if distance -1 and distance < 3 then
                TriggerEvent('chat:addMessage', {
                    color = {255, 255, 255},
                    multiline = true,
                    args = {"You have uncuffed a player"}
                })
				local closestID = GetPlayerServerId(closest)
				TriggerServerEvent('unCuffServer', closestID)
			end
		end
	else
		TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = false,
            args = {"You are not a cop."}
        })
	end
end)

RegisterCommand('showid', function()
    closest, distance = GetClosestPlayer()
    if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
        local closestID = GetPlayerServerId(closest)
        vRPCopsS.showID(closestID)
    end
end)

RegisterCommand('pnum', function()
    closest, distance = GetClosestPlayer()
    if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
        local closestID = GetPlayerServerId(closest)
        vRPCopsS.showPhone(closestID)
    end
end)

RegisterCommand('drag', function(source, args, rawCommand)
	closest, distance = GetClosestPlayer()
	if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
		if distance -1 and distance < 3 then
			local closestID = GetPlayerServerId(closest)
            local pP = GetPlayerPed(-1)
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                multiline = true,
                args = {"You are dragging a player."}
            })
			TriggerServerEvent('dragServer', closestID)
		else
			TriggerEvent('chat:addMessage', {
                color = { 255, 255, 255},
                multiline = false,
                args = {"Nearest player is too far away."}
            })
		end
	else
		TriggerEvent('chat:addMessage', {
            color = { 255, 255, 255},
            multiline = false,
            args = {"You are not a cop."}
        })
	end
end)

RegisterCommand('seat', function(source, args, rawCommand)
	closest, distance = GetClosestPlayer()
	if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
		if distance -1 and distance < 3 then
			local closestID = GetPlayerServerId(closest)
			local pP = GetPlayerPed(-1)
            local veh = GetVehiclePedIsIn(pP, true)
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                multiline = true,
                args = {'You forced the player into the nearest vehicle.'}
            })
			TriggerServerEvent('seatServer', closestID, veh)
		else
			TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                multiline = false,
                args = {"Nearest player is too far away."}
            })
		end
	end
end)

RegisterCommand('unseat', function(source, args, rawCommand)
	closest, distance = GetClosestPlayer()
	if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
		if distance -1 and distance < 3 then
            local closestID = GetPlayerServerId(closest)
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                multiline = false,
                args = {"You forced the player out of the nearest vehicle."}
            })
			TriggerServerEvent('unSeatServer', closestID)
		else
			TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                multiline = false,
                args = {"Nearest player is too far away."}
            })
		end
	end	
end)


RegisterCommand('undrag', function()
	closest, distance = GetClosestPlayer()
	if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
		if distance -1 and distance < 3 then
			TriggerEvent('chatMessage', 'Police System', {255, 255, 255}, 'You are no longer dragging the nearest player. (' .. GetPlayerName(closest) .. ')')
			local closestID = GetPlayerServerId(closest)
			TriggerServerEvent('unDragServer', closestID)
		else
			TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                multiline = false,
                args = {"Nearest player is too far away."}
            })
		end
	end
end)

RegisterCommand('revive', function()
    if isCop or isEMS then
        local ped = GetPlayerPed(-1)
        closest, distance = GetClosestPlayer()
	    if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
            if distance -1 and distance < 3 then
                local closestID = GetPlayerServerId(closest)
                TriggerServerEvent("reviveServer", closestID)
            end
        end
    end
end, false)

RegisterCommand('copgear', function()
    if isCop then
        local ped = GetPlayerPed(-1)
        GiveWeaponToPed(ped, GetHashKey("WEAPON_NIGHTSTICK"), 1, false, false)
        GiveWeaponToPed(ped, GetHashKey("WEAPON_STUNGUN"), 100, false, false)
        GiveWeaponToPed(ped, GetHashKey("WEAPON_FLASHLIGHT"), 1, false, false)
        GiveWeaponToPed(ped, GetHashKey("WEAPON_COMBATPISTOL"), 84, false, false)
        GiveWeaponToPed(ped, GetHashKey("WEAPON_CARBINERIFLE"), 90, false, false)
        GiveWeaponToPed(ped, GetHashKey("WEAPON_PUMPSHOTGUN"), 24, false, false)
        SetPedArmour(ped, 100)
    end
end, false)

RegisterCommand('hideweapons', function()
    if not handcuffed then
        vRPCopsS.removeWeaponServer()
    end
end, false)

RegisterCommand('seize', function()
    if isCop then
        closest, distance = GetClosestPlayer()
	    if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
		    if distance -1 and distance < 3 then
                local closestID = GetPlayerServerId(closest)
                vRPCopsS.seize(closestID)
            end
        end
    end
end, false)

--[[RegisterCommand('pb', function()
    x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), true))
    streethash = GetStreetNameAtCoord(x, y, z)
    street = GetStreetNameFromHashKey(streethash)
    TriggerServerEvent('panicServer', street)
end, false)]]

RegisterCommand('cone', function()
	if isCop == true then
		local pP = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(pP, true))
		local heading = GetEntityHeading(pP)
		local cone = CreateObject(GetHashKey('prop_mp_cone_01'), x, y, z-2, true, true, true)
		PlaceObjectOnGroundProperly(cone)
		SetEntityHeading(cone, heading)
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = false,
            args = {"You placed a cone."}
        })
	else
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = false,
            args = {"You are not a cop."}
        })
	end
end)

RegisterCommand('barrier', function()
	if isCop == true then
		local pP = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(pP, true))
		local heading = GetEntityHeading(pP)
		local barrier = CreateObject(GetHashKey('prop_barrier_work05'), x, y, z-2, true, true, true)
		PlaceObjectOnGroundProperly(barrier)
		SetEntityHeading(barrier, heading)
		TriggerEvent('chat:addMessage', {0, 0, 0}, false, 'You placed a barrier.')
	else
		TriggerEvent('chat:addMessage', {0, 0, 0}, false, 'You are not a cop.')
	end
end)
--[[
RegisterCommand('deletegun', function() -- Thanks to 'murfasa' https://forum.fivem.net/t/release-fx-cfx-gun-delete-object/39422
	if isCop == true or isAdmin == true then
		deletegun = not deletegun
		local pP = GetPlayerPed(-1)
        if deletegun == true then
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                multiline = false,
                args = {"You toggled the delete gun on."}
            })
		else
			TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                multiline = false,
                args = {"You toggled the delete gun off."}
            })
		end
		while deletegun == true do
			Citizen.Wait(0)
			if IsPlayerFreeAiming(PlayerId()) then
				local target = getEntityPlayerAimingAt(PlayerId())
				if IsPedShooting(pP) then
					SetEntityAsMissionEntity(target, true, true)
					DeleteEntity(target)
				end
			end
		end
	else
		TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = false,
            args = {"You are not a cop."}
        })
	end
end)
]]
RegisterNetEvent('reviveClient')
AddEventHandler('reviveClient', function()
    local ped = GetPlayerPed(-1)
    if IsEntityDead(ped) then
        revivePed(ped)
        if (handcuffed) then
            TriggerEvent("cuffClient")
        end
    end
end)

RegisterNetEvent('cuffClient')
AddEventHandler('cuffClient', function()
	local pP = GetPlayerPed(-1)
	RequestAnimDict('mp_arresting')
	while not HasAnimDictLoaded('mp_arresting') do
		Citizen.Wait(100)
	end
	TaskPlayAnim(pP, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
	SetEnableHandcuffs(pP, true)
	SetCurrentPedWeapon(pP, GetHashKey('WEAPON_UNARMED'), true)
	DisablePlayerFiring(pP, true)
	FreezeEntityPosition(pP, true)
	handcuffed = true
end)

RegisterNetEvent('unCuffClient')
AddEventHandler('unCuffClient', function()
	local pP = GetPlayerPed(-1)
	ClearPedSecondaryTask(pP)
	SetEnableHandcuffs(pP, false)
	SetCurrentPedWeapon(pP, GetHashKey('WEAPON_UNARMED'), true)
	FreezeEntityPosition(pP, false)
	handcuffed = false
end)

RegisterNetEvent('dragClient')
AddEventHandler('dragClient', function(closestID)
	local officer = closestID
	local officerPed = GetPlayerPed(GetPlayerFromServerId(officer))
	local pP = GetPlayerPed(-1)
	drag = true
	while drag == true do
		Citizen.Wait(0)
		if IsPedDeadOrDying then
			drag = false
        end
        SetEnableHandcuffs(pP, true)
        SetCurrentPedWeapon(pP, GetHashKey('WEAPON_UNARMED'), true)
        DisablePlayerFiring(pP, true)
        FreezeEntityPosition(pP, true)
        AttachEntityToEntity(pP, officerPed, 4103, 11816, 0.48, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
	end
end)

RegisterNetEvent('seatClient')
AddEventHandler('seatClient', function(veh)
	local pP = GetPlayerPed(-1)
	local pos = GetEntityCoords(pP)
	local entityWorld = GetOffsetFromEntityInWorldCoords(pP, 0.0, 20.0, 0.0)
	local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, pP, 0)
	local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
	local vehicle = GetVehiclePedIsIn(pP, false)
	
	DetachEntity(pP, true, false)
	Citizen.Wait(100)
	if vehicleHandle ~= nil then
		SetPedIntoVehicle(pP, vehicleHandle, 1)
	end
	SetVehicleDoorsLocked(vehicle, 4)
end)

RegisterNetEvent('unSeatClient')
AddEventHandler('unSeatClient', function(closestID)
	local pP = GetPlayerPed(-1)
	local pos = GetEntityCoords(pP)
	ClearPedTasksImmediately(pP)
	local xnew = pos.x + 2
	local ynew = pos.y + 2
	
	SetEntityCoords(pP, xnew, ynew, pos.z)
    if not (handcuffed) then
        SetEnableHandcuffs(pP, true)
        DisablePlayerFiring(pP, true)
        FreezeEntityPosition(pP, true)
    end
    SetCurrentPedWeapon(pP, GetHashKey('WEAPON_UNARMED'), true)

end)

RegisterNetEvent('unDragClient')
AddEventHandler('unDragClient', function(closestID)
	local pP = GetPlayerPed(-1)
	drag = false
    DetachEntity(pP, true, false)
    if not (handcuffed) then
        SetEnableHandcuffs(pP, false)
        FreezeEntityPosition(pP, false)
    end
    SetCurrentPedWeapon(pP, GetHashKey('WEAPON_UNARMED'), true)

end)

RegisterNetEvent('putInClient')
AddEventHandler('putInClient', function(closestID, veh)
	local pP = GetPlayerPed(-1)
	local pos = GetEntityCoords(pP)
	local entityWorld = GetOffsetFromEntityInWorldCoords(pP, 0.0, 20.0, 0.0)
	local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
	local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
	if vehicleHandle ~= nil then
		SetPedIntoVehicle(pP, vehicleHandle, 1)
	end
end)

RegisterNetEvent('panicButtonSound', function()
	SendNUIMessage({
		playpanicbutton = true,
		panicbuttonvolume = volume
		})
end)

RegisterNetEvent('showIDClient')
AddEventHandler('showIDClient', function(fname, lname, age, regis)
    TriggerEvent("pNotify:SendNotification", {
		text = "<b style='color:yellow'>California ID</b> <br /> <p style='color:white'>ID#: "..regis.."<br />LN :"..lname.."<br />FN: "..fname.."<br />Age: "..age.."</p>",
		type = "info",
		timeout = 15000,
		layout = "topRight",
	})
end)

RegisterNetEvent('showPhoneClient')
AddEventHandler('showPhoneClient', function(fn, ln, num)
    TriggerEvent("pNotify:SendNotification", {
		text = "<b>"..fn.." "..ln.."'s phone#: "..num..".</b>",
		type = "info",
		timeout = 10000,
		layout = "topRight",
	})
end)

RegisterCommand('time', function(source, args)
    vRPCopsS.getTimeRemaining()
end)

-- Functions
function GetPlayers()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer, closestDistance
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry .. ':')
    DisplayOnscreenKeyboard(1, 'FMMC_KEY_TIP1', '', ExampleText, '', '', '', MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return result
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end

function getEntityPlayerAimingAt(player)
	local result, target = GetEntityPlayerIsFreeAimingAt(player)
	return target
end

-- MDT


RegisterCommand('mdt', function(source, args)
    if isCop == true and canAccessMDT() then
        vRPCopsS.getCriminalInfo(args[1])
	end
end)

RegisterCommand('mdtlookup', function(source, args)
    if isCop == true and canAccessMDT() then
        vRPCopsS.getCriminalInfoById(tonumber(args[1]))
	end
end)

RegisterCommand('setpts', function(source, args)
    if isCop == true and canAccessMDT() then
        vRPCopsS.setPoints(tonumber(args[1]), args[2])
    end
end)

RegisterCommand('setlicense', function(source, args)
    if isCop == true and canAccessMDT() then
        vRPCopsS.setLicense(tonumber(args[1]), tonumber(args[2]))
    end
end)

RegisterCommand('setgunlicense', function(source, args)
    if isCop == true and canAccessMDT() then
        vRPCopsS.setGunLicense(tonumber(args[1]), tonumber(args[2]))
    end
end)

RegisterCommand('addwarrant', function(source, args)
    if isCop == true and canAccessMDT() then
        local warrant = ""
        local i = 0
        for k, v in pairs(args) do
            if not (i == 0) then
                warrant = warrant.." "..v
            end
            i = i + 1
        end

        vRPCopsS.insertWarrant(tonumber(args[1]), warrant)
	end
end)

RegisterCommand('addsentence', function(source, args)
    if isCop == true and canAccessMDT() then
        local warrant = ""
        local i = 0
        for k, v in pairs(args) do
            if not (i == 0) then
                warrant = warrant.." "..v
            end
            i = i + 1
        end
        vRPCopsS.insertWarrant(tonumber(args[1]), warrant)
	end
end)


RegisterCommand('rmwarrant', function(source, args)
    if isCop == true and canAccessMDT() then
        vRPCopsS.removeWarrant(tonumber(args[1]))
	end
end)

function canAccessMDT()
    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsIn(ped, false)
    if mdtLoggedIn or GetVehicleClass(veh) == 18 then
        return true
    end
    TriggerEvent('chat:addMessage', {
        args = { "MDT", "No MDT near. Police stations and emergency vehicles have them" }
    })
    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local ped = GetPlayerPed(-1)
        local veh = GetVehiclePedIsTryingToEnter(ped)
        if (veh ~= nil) and (GetVehicleClass(veh) == 18) then
            mdtLoggedIn = true
        else
            mdtLoggedIn = false
        end
    end
end)

-- EMS

local reviveWait = 120

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        ped = GetPlayerPed(-1)
        if IsEntityDead(ped) and (reviveWait > 0) then
            reviveWait = reviveWait - 1
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = GetPlayerPed(-1)
        if IsEntityDead(ped) then
            SetPlayerInvincible(ped, true)
            SetEntityHealth(ped, 1)
            ShowInfoRevive('~y~You are in a coma. Use /911 to alert authorities. '..tostring(reviveWait)..' seconds to ~p~R ~y~ respawn (2500$)')
            if (IsControlJustReleased(0,45) or IsDisabledControlJustReleased(0,45)) and GetLastInputMethod(0) then
                if (reviveWait < 1) then
                    vRPCopsS.hospitalStay(2500)
                    respawnPed(ped, emsCoords[1])
                    RemoveAllPedWeapons(ped, true)
                    reviveWait = 120
                end
            end
        end
    end
end)

-- Private Revive Functions

function revivePed(ped)
	local playerPos = GetEntityCoords(ped, true)
    --TriggerEvent('playerSpawned', playerPos.x, playerPos.y, playerPos.z, 90.0)
    NetworkResurrectLocalPlayer(playerPos, true, true, false)
	SetPlayerInvincible(ped, false)
    ClearPedBloodDamage(ped)
    TriggerEvent('cop:revivePlayer')
end

function ShowInfoRevive(text)
    SetTextFont(0)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.25, 0.7)
end

function respawnPed(ped, coords)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 90.0, true, false) 

	SetPlayerInvincible(ped, false) 
	--TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, 90.0)
    ClearPedBloodDamage(ped)
    TriggerEvent('cop:revivePlayer')
end

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.25*scale, 0.4*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

-- * export functions
function isEmergencyJob()
    return isCop or isEMS
end

function isAdmin()
    return isAdmin
end

function getPermLevel()
    return permLevel
end

function isHandcuffed()
    return handcuffed
end