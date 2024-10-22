vRPclient = Tunnel.getInterface("vRP", "cops")
vRPCopsS = Tunnel.getInterface("cops", "cops")

vRPCops = {}
Tunnel.bindInterface("cops", vRPCops)
Proxy.addInterface("cops", vRPCops)

-- Admin and admin permission level
isAnAdmin = false
permLevel = 0
-- Cop, Ems, etc permissions
isCop = false
isEMS = false

-- Player statuses
handcuffed = false
local cuffedByCop = false
local dragged = false
local playerStillDragged = false
local cuffing = false
local officerDrag = -1
local nearEMS = false;
local nearMDT = false;
local mdtLoggedIn = false;
local reviveWait = 180

local policeCoords = {{name = "Police Station", x = 441.07467651368, y = -978.25646972656, z = 30.689603805542}, --main
                {name = "Police Station", x = 1852.9038085938, y = 3690.0769042968, z = 34.267082214356}, --ss
                {name = "Police Station", x = -449.4927368164, y = 6012.422855625, z = 31.71650314331}, --p
                {name = "Police Station", x = 1755.4387207032, y = 2614.3198242188, z = 45.56502532959},  --bb
                {name = "Police Station", x = 459.74032592774, y = -989.16204833984, z = 24.914859771728}} --main
local policeColors = {r = 35, g = 45, b = 235,a = 125}
local emsCoords = {{name = "Hospital", x = 306.724609375, y = -595.47827148438, z = 43.995809082032}}
local emsColors = {r = 41, g = 41, b = 255,a = 125}

Citizen.CreateThread(function()
    for _, v in pairs(policeCoords) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blip, 60)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
    end

    for _, v in pairs(emsCoords) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blip, 61)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
    end

    local ped
    local pos
    local dist

    while true do
        Citizen.Wait(1)

        ped = GetPlayerPed(-1)
        pos = GetEntityCoords(ped, true)

        for _, v in pairs(policeCoords) do
            DrawMarker(1,v.x, v.y, v.z - 1,0,0,0,0,0,0,0.8,0.8,0.8, policeColors.r, policeColors.g, policeColors.b,policeColors.a,0)
            dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
            if (dist < 2.0) then
                mdtLoggedIn = true
            else
                mdtLoggedIn = false
            end
        end

        -- for k, v in ipairs(emsCoords) do
        --     DrawMarker(1,v.x, v.y, v.z - 2,0,0,0,0,0,0,0.8,0.8,0.8, emsColors.r, emsColors.g, emsColors.b,emsColors.a, 0)
        --     dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
        --     if (dist < 16.0) then
        --         Draw3DText(v.x, v.y, v.z + 1.0, "Check into the hospital [space]. Cost 100$.")
        --     end
        --     if(dist < 2.0) then
        --         nearEMS = true
        --         if (IsControlJustReleased(0,22)) then
        --             if (IsEntityDead(ped)) then
        --                 vRPCopsS._hospitalStay(100)
        --                 revivePed(ped)
        --                 hospitalAlert()
        --             elseif (GetEntityHealth(ped) < 200) then
        --                 vRPCopsS._hospitalStay(150)
        --                 SetEntityHealth(ped, 200)
        --                 hospitalAlert()
        --             end
        --         end
        --     elseif (dist > 4.0) and (nearEMS) then
        --         nearEMS = false
        --     end
        -- end
    end
end)

-- function hospitalAlert()
--     TriggerEvent("pNotify:SendNotification", {
--         text = "<b style='color:#32b338'>Pillbox Hospital</b><br /><p>You were charged 150$ for your stay.</p>",
--         type = "success",
--         timeout = 5000,
--         layout = "topRight"
--     })
-- end

RegisterNetEvent('isCop')
AddEventHandler('isCop', function()
    if (isCop) then
        return
    end
    isCop = true
    TriggerServerEvent("jobs:setEmergencyJob", "Police")
    TriggerEvent('chat:addMessage', {
        color = {0, 0, 255},
        multiline = true,
        args = {"[Police]", "You are a cop"}
    })
end)

RegisterNetEvent('isEMS')
AddEventHandler('isEMS', function()
    if (isEMS) then
        return
    end
    isEMS = true
    TriggerServerEvent("jobs:setEmergencyJob", "EMS")
    TriggerEvent('chat:addMessage', {
         color = {255, 0, 0},
        multiline = true,
        args = {"[EMS]", " You are an EMS"}
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
    reviveWait = 180
    handcuffed = false
    dragged = false
    playerStillDragged = false
    cuffing = false
end)

AddEventHandler('cop:revivePlayer', function()
    TriggerEvent("vrp:setStress", 40.0)
    reviveWait = 180
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)
        if (fullyLoaded) then
            if isCop then
                TriggerEvent("isService", isCop, isEMS)
            else
                vRPCopsS._isCopToClient()
            end
            if not isAnAdmin then
                vRPCopsS._isAdminToClient()
            end
        end
    end
end)

RegisterNetEvent('cop:clientIsAdmin')
AddEventHandler('cop:clientIsAdmin', function(admin, perm)
    if admin then
        isAnAdmin = admin
        permLevel = perm
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[Admin]", "You are Admin. Permission level " .. perm, }
        })
    end
end)

-- Commands

RegisterCommand('emsonduty', function()
    vRPCopsS._isEMS()
end)

--[[
    ! Cops Abilities (Cuff, Carry, Seat)
]]

RegisterNetEvent('police:getArrested')
AddEventHandler('police:getArrested', function(byCop, cuffer)
    if not byCop then
        if not handcuffed then
            if vRPCopsS.hasCuffs(cuffer) then
                vRPCopsS.takeCuffs(cuffer)
            else
                return
            end
        elseif handcuffed then
            if vRPCopsS.hasPicklock(cuffer) then
                vRPCopsS.takePicklock(cuffer)
            else
                return
            end
        end
    end

    handcuffed = not handcuffed
	if (handcuffed) then
		cuffedByCop = byCop
	else
        handcuffed = false
        cuffedByCop = false
		dragged = false
		ClearPedTasksImmediately(PlayerPedId())
	end
end)

--Piece of code given by Thefoxeur54
RegisterNetEvent('police:unseatme')
AddEventHandler('police:unseatme', function(t)
	local ped = GetPlayerPed(t)        
	ClearPedTasksImmediately(ped)
	plyPos = GetEntityCoords(PlayerPedId(),  true)
	local xnew = plyPos.x+2
	local ynew = plyPos.y+2
   
	SetEntityCoords(PlayerPedId(), xnew, ynew, plyPos.z)
end)

RegisterNetEvent('police:toggleDrag')
AddEventHandler('police:toggleDrag', function(t)
	if(handcuffed) then
		dragged = not drag
		officerDrag = t
	end
end)

RegisterNetEvent('police:forcedEnteringVeh')
AddEventHandler('police:forcedEnteringVeh', function(veh)
	if (handcuffed) then
		local pos = GetEntityCoords(PlayerPedId())
		local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)

		local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, PlayerPedId(), 0)
		local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)

		if vehicleHandle ~= nil then
			if(IsVehicleSeatFree(vehicleHandle, 1)) then
				SetPedIntoVehicle(PlayerPedId(), vehicleHandle, 1)
			else 
				if(IsVehicleSeatFree(vehicleHandle, 2)) then
					SetPedIntoVehicle(PlayerPedId(), vehicleHandle, 2)
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	RequestAnimDict('mp_arresting')
	while not HasAnimDictLoaded('mp_arresting') do
		Citizen.Wait(50)
	end

	if not IsIplActive("FIBlobby") then
		RequestIpl("FIBlobbyfake")
	end

	SetMaxWantedLevel(0)
    SetWantedLevelMultiplier(0.0)
    
    local myPed
    local animation = 'idle'
    local flags = 50
    local ped
    while true do
        Citizen.Wait(5)	
		DisablePlayerVehicleRewards(PlayerId())
		
        if (handCuffed == true) then
            myPed = PlayerPedId()
			
			while(IsPedBeingStunned(myPed, 0)) do
				ClearPedTasksImmediately(myPed)
			end

			if not cuffing then
				DisableControlAction(1, 12, true)
				DisableControlAction(1, 13, true)
				DisableControlAction(1, 14, true)

				DisableControlAction(1, 15, true)
				DisableControlAction(1, 16, true)
				DisableControlAction(1, 17, true)

				SetCurrentPedWeapon(myPed, GetHashKey("WEAPON_UNARMED"), true)
				TaskPlayAnim(myPed, "mp_arresting", animation, 8.0, -8.0, -1, flags, 0, 0, 0, 0 )

				Wait(4000)
				cuffing = true
			end
		else
			EnableControlAction(1, 12, false)
			EnableControlAction(1, 13, false)
			EnableControlAction(1, 14, false)

			EnableControlAction(1, 15, false)
			EnableControlAction(1, 16, false)
			EnableControlAction(1, 17, false)
			cuffing = false	
		end
		
		--Piece of code from Drag command (by Frazzle, Valk, Michael_Sanelli, NYKILLA1127 : https://forum.fivem.net/t/release-drag-command/22174)
		if dragged then
			ped = GetPlayerPed(GetPlayerFromServerId(officerDrag))
			AttachEntityToEntity(myped, ped, 4103, 11816, 0.48, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
			playerStillDragged = true
		else
			if(playerStillDragged) then
				DetachEntity(PlayerPedId(), true, false)
				playerStillDragged = false
			end
		end

		if IsPlayerWantedLevelGreater(PlayerId(), 0) then
            ClearPlayerWantedLevel(PlayerId())
        end
        -- ! polmav
    end
end)

Citizen.CreateThread(function()
    local ped
	while true do
		if dragged then
			ped = GetPlayerPed(GetPlayerFromServerId(playerPedDragged))
			plyPos = GetEntityCoords(ped, true)
			SetEntityCoords(ped, plyPos.x, plyPos.y, plyPos.z)
		end
		Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()
    local veh
    local x,y,z
	while true do
		Citizen.Wait(1)
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			veh = GetVehiclePedIsIn(PlayerPedId(), false)
			x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), true))

			if DoesObjectOfTypeExistAtCoords(x, y, z, 0.9, GetHashKey("P_ld_stinger_s"), true) then
				SetVehicleTyreBurst(veh, 0, true, 1000.0)
                SetVehicleTyreBurst(veh, 1, true, 1000.0)
                Citizen.Wait(200)
                SetVehicleTyreBurst(veh, 2, true, 1000.0)
                SetVehicleTyreBurst(veh, 3, true, 1000.0)
                Citizen.Wait(200)
                SetVehicleTyreBurst(veh, 4, true, 1000.0)
                SetVehicleTyreBurst(veh, 5, true, 1000.0)
                SetVehicleTyreBurst(veh, 6, true, 1000.0)
                SetVehicleTyreBurst(veh, 7, true, 1000.0)

				Citizen.Wait(100)
				DeleteSpike()
			end
		end
	end
end)

RegisterCommand('cuff', function()
    local t, distance = GetClosestPlayer()
    if distance ~= -1 and distance < 3 then
        TriggerServerEvent("police:cuffGranted", GetPlayerServerId(t), isCop)
    end
end)

RegisterCommand('drag', function(source, args, rawCommand)
    local t, distance = GetClosestPlayer()
    if distance ~= -1 and distance < 3 then
        TriggerServerEvent("police:dragRequest", GetPlayerServerId(t))
    end
end)

RegisterCommand('seat', function(source, args, rawCommand)
    local t, distance = GetClosestPlayer()
    if isCop or isEMS and distance ~= -1 and distance < 3 then
        local v = GetVehiclePedIsIn(PlayerPedId(), true)
        TriggerServerEvent("police:forcedEnteringVeh", GetPlayerServerId(t), v)
    end
end)

RegisterCommand('unseat', function(source, args, rawCommand)
    local t, distance = GetClosestPlayer()
    if distance ~= -1 and distance < 3 then
        TriggerServerEvent("police:confirmUnseat", GetPlayerServerId(t))
    end
end)

RegisterCommand('spike', function(source, args, rawCommand)
    if isCop then
        SpawnSpikesStripe()
    end
end)

RegisterCommand('removeveh', function(source, args, rawCommand)
    if isAnAdmin then
        DropVehicle()
    end
end)


function DropVehicle()
	Citizen.CreateThread(function()
		local pos = GetEntityCoords(PlayerPedId())
		local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)

		local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, PlayerPedId(), 0)
		local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
		if DoesEntityExist(vehicleHandle) and IsEntityAVehicle(vehicleHandle) then
			DeleteEntity(vehicleHandle)
		else
			drawNotification(i18n.translate("no_veh_near_ped"))
		end
	end)
end

function SpawnSpikesStripe()
	if IsPedInAnyPoliceVehicle(PlayerPedId()) then
		local modelHash = GetHashKey("P_ld_stinger_s")
		local currentVeh = GetVehiclePedIsIn(PlayerPedId(), false)	
		local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(currentVeh, 0.0, -5.2, -0.25))

		RequestScriptAudioBank("BIG_SCORE_HIJACK_01", true)
		Citizen.Wait(500)

		RequestModel(modelHash)
		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)
		end

		if HasModelLoaded(modelHash) then
			SpikeObject = CreateObject(modelHash, x, y, z, true, false, true)
			SetEntityNoCollisionEntity(SpikeObject, PlayerPedId(), 1)
			SetEntityDynamic(SpikeObject, false)
			ActivatePhysics(SpikeObject)

			if DoesEntityExist(SpikeObject) then			
				local height = GetEntityHeightAboveGround(SpikeObject)

				SetEntityCoords(SpikeObject, x, y, z - height + 0.05)
				SetEntityHeading(SpikeObject, GetEntityHeading(PlayerPedId())-80.0)
				SetEntityCollision(SpikeObject, false, false)
				PlaceObjectOnGroundProperly(SpikeObject)

				SetEntityAsMissionEntity(SpikeObject, false, false)				
				SetModelAsNoLongerNeeded(modelHash)
				PlaySoundFromEntity(-1, "DROP_STINGER", PlayerPedId(), "BIG_SCORE_3A_SOUNDS", 0, 0)
			end			
			drawNotification("Spike stripe~g~ deployed~w~.")
		end
	else
		drawNotification("You need to get ~y~inside~w~ a ~y~police vehicle~w~.")
		PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
	end
end

function DeleteSpike()
	local model = GetHashKey("P_ld_stinger_s")
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), true))

	if DoesObjectOfTypeExistAtCoords(x, y, z, 0.9, model, true) then
		local spike = GetClosestObjectOfType(x, y, z, 0.9, model, false, false, false)
		DeleteObject(spike)
	end	
end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

-- RegisterCommand('cuff', function()
-- 	if isCop == true then
-- 		closest, distance = GetClosestPlayer()
-- 		if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
-- 			if distance -1 and distance < 3 then
--                 TriggerEvent('chat:addMessage', {
--                     color = {255, 255, 255},
--                     multiline = true,
--                     args = {"You have cuffed a player"}
--                 })
-- 				local closestID = GetPlayerServerId(closest)
-- 				TriggerServerEvent('cuffServer', closestID)
--             else
--                 TriggerEvent('chat:addMessage', {
--                     color = {255, 255, 255},
--                     multiline = false,
--                     args = {"Nearest player is too far away."}
--                 })
-- 			end
-- 		end
-- 	else
-- 		TriggerEvent('chat:addMessage', {
--             color = {255, 255, 255},
--             multiline = false,
--             args = {"You are not a cop."}
--         })
-- 	end
-- end)

-- RegisterCommand('uncuff', function()
-- 	if isCop == true then
-- 		closest, distance = GetClosestPlayer()
-- 		if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
--             if distance -1 and distance < 3 then
--                 TriggerEvent('chat:addMessage', {
--                     color = {255, 255, 255},
--                     multiline = true,
--                     args = {"You have uncuffed a player"}
--                 })
-- 				local closestID = GetPlayerServerId(closest)
-- 				TriggerServerEvent('unCuffServer', closestID)
-- 			end
-- 		end
-- 	else
-- 		TriggerEvent('chat:addMessage', {
--             color = {255, 255, 255},
--             multiline = false,
--             args = {"You are not a cop."}
--         })
-- 	end
-- end)

-- RegisterCommand('drag', function(source, args, rawCommand)
-- 	closest, distance = GetClosestPlayer()
-- 	if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
-- 		if distance -1 and distance < 3 then
-- 			local closestID = GetPlayerServerId(closest)
--             local pP = GetPlayerPed(-1)
--             TriggerEvent('chat:addMessage', {
--                 color = {255, 255, 255},
--                 multiline = true,
--                 args = {"You are dragging a player."}
--             })
-- 			TriggerServerEvent('dragServer', closestID)
-- 		else
-- 			TriggerEvent('chat:addMessage', {
--                 color = { 255, 255, 255},
--                 multiline = false,
--                 args = {"Nearest player is too far away."}
--             })
-- 		end
-- 	else
-- 		TriggerEvent('chat:addMessage', {
--             color = { 255, 255, 255},
--             multiline = false,
--             args = {"You are not a cop."}
--         })
-- 	end
-- end)

-- RegisterCommand('seat', function(source, args, rawCommand)
-- 	closest, distance = GetClosestPlayer()
-- 	if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
-- 		if distance -1 and distance < 3 then
-- 			local closestID = GetPlayerServerId(closest)
-- 			local pP = GetPlayerPed(-1)
--             local veh = GetVehiclePedIsIn(pP, true)
--             TriggerEvent('chat:addMessage', {
--                 color = {255, 255, 255},
--                 multiline = true,
--                 args = {'You forced the player into the nearest vehicle.'}
--             })
-- 			TriggerServerEvent('seatServer', closestID, veh)
-- 		else
-- 			TriggerEvent('chat:addMessage', {
--                 color = {255, 255, 255},
--                 multiline = false,
--                 args = {"Nearest player is too far away."}
--             })
-- 		end
-- 	end
-- end)

-- RegisterCommand('unseat', function(source, args, rawCommand)
-- 	closest, distance = GetClosestPlayer()
-- 	if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
-- 		if distance -1 and distance < 3 then
--             local closestID = GetPlayerServerId(closest)
--             TriggerEvent('chat:addMessage', {
--                 color = {255, 255, 255},
--                 multiline = false,
--                 args = {"You forced the player out of the nearest vehicle."}
--             })
-- 			TriggerServerEvent('unSeatServer', closestID)
-- 		else
-- 			TriggerEvent('chat:addMessage', {
--                 color = {255, 255, 255},
--                 multiline = false,
--                 args = {"Nearest player is too far away."}
--             })
-- 		end
-- 	end	
-- end)


-- RegisterCommand('undrag', function()
-- 	closest, distance = GetClosestPlayer()
-- 	if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
-- 		if distance -1 and distance < 3 then
-- 			TriggerEvent('chatMessage', 'Police System', {255, 255, 255}, 'You are no longer dragging the nearest player. (' .. GetPlayerName(closest) .. ')')
-- 			local closestID = GetPlayerServerId(closest)
-- 			TriggerServerEvent('unDragServer', closestID)
-- 		else
-- 			TriggerEvent('chat:addMessage', {
--                 color = {255, 255, 255},
--                 multiline = false,
--                 args = {"Nearest player is too far away."}
--             })
-- 		end
-- 	end
-- end)

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

RegisterCommand('revive', function()
    if isCop or isEMS then
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

-- RegisterNetEvent('cuffClient')
-- AddEventHandler('cuffClient', function()
-- 	local pP = GetPlayerPed(-1)
-- 	RequestAnimDict('mp_arresting')
-- 	while not HasAnimDictLoaded('mp_arresting') do
-- 		Citizen.Wait(100)
-- 	end
-- 	TaskPlayAnim(pP, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
-- 	SetEnableHandcuffs(pP, true)
-- 	SetCurrentPedWeapon(pP, GetHashKey('WEAPON_UNARMED'), true)
-- 	DisablePlayerFiring(pP, true)
-- 	FreezeEntityPosition(pP, true)
-- 	handcuffed = true
-- end)

-- RegisterNetEvent('unCuffClient')
-- AddEventHandler('unCuffClient', function()
-- 	local pP = GetPlayerPed(-1)
-- 	ClearPedSecondaryTask(pP)
-- 	SetEnableHandcuffs(pP, false)
-- 	SetCurrentPedWeapon(pP, GetHashKey('WEAPON_UNARMED'), true)
-- 	FreezeEntityPosition(pP, false)
-- 	handcuffed = false
-- end)

-- RegisterNetEvent('dragClient')
-- AddEventHandler('dragClient', function(closestID)
-- 	local officer = closestID
-- 	local officerPed = GetPlayerPed(GetPlayerFromServerId(officer))
-- 	local pP = GetPlayerPed(-1)
-- 	drag = true
-- 	while drag == true do
-- 		Citizen.Wait(0)
-- 		if IsPedDeadOrDying then
-- 			drag = false
--         end
--         SetEnableHandcuffs(pP, true)
--         SetCurrentPedWeapon(pP, GetHashKey('WEAPON_UNARMED'), true)
--         DisablePlayerFiring(pP, true)
--         FreezeEntityPosition(pP, true)
--         AttachEntityToEntity(pP, officerPed, 4103, 11816, 0.48, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
-- 	end
-- end)

-- RegisterNetEvent('seatClient')
-- AddEventHandler('seatClient', function(veh)
-- 	local pP = GetPlayerPed(-1)
-- 	local pos = GetEntityCoords(pP)
-- 	local entityWorld = GetOffsetFromEntityInWorldCoords(pP, 0.0, 20.0, 0.0)
-- 	local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, pP, 0)
-- 	local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
-- 	local vehicle = GetVehiclePedIsIn(pP, false)
	
-- 	DetachEntity(pP, true, false)
-- 	Citizen.Wait(100)
-- 	if vehicleHandle ~= nil then
-- 		SetPedIntoVehicle(pP, vehicleHandle, 1)
-- 	end
-- 	SetVehicleDoorsLocked(vehicle, 4)
-- end)

-- RegisterNetEvent('unSeatClient')
-- AddEventHandler('unSeatClient', function(closestID)
-- 	local pP = GetPlayerPed(-1)
-- 	local pos = GetEntityCoords(pP)
-- 	ClearPedTasksImmediately(pP)
-- 	local xnew = pos.x + 2
-- 	local ynew = pos.y + 2
	
-- 	SetEntityCoords(pP, xnew, ynew, pos.z)
--     if not (handcuffed) then
--         SetEnableHandcuffs(pP, true)
--         DisablePlayerFiring(pP, true)
--         FreezeEntityPosition(pP, true)
--     end
--     SetCurrentPedWeapon(pP, GetHashKey('WEAPON_UNARMED'), true)

-- end)

-- RegisterNetEvent('unDragClient')
-- AddEventHandler('unDragClient', function(closestID)
-- 	local pP = GetPlayerPed(-1)
-- 	drag = false
--     DetachEntity(pP, true, false)
--     if not (handcuffed) then
--         SetEnableHandcuffs(pP, false)
--         FreezeEntityPosition(pP, false)
--     end
--     SetCurrentPedWeapon(pP, GetHashKey('WEAPON_UNARMED'), true)

-- end)

-- RegisterNetEvent('putInClient')
-- AddEventHandler('putInClient', function(closestID, veh)
-- 	local pP = GetPlayerPed(-1)
-- 	local pos = GetEntityCoords(pP)
-- 	local entityWorld = GetOffsetFromEntityInWorldCoords(pP, 0.0, 20.0, 0.0)
-- 	local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
-- 	local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
-- 	if vehicleHandle ~= nil then
-- 		SetPedIntoVehicle(pP, vehicleHandle, 1)
-- 	end
-- end)

-- RegisterNetEvent('panicButtonSound', function()
-- 	SendNUIMessage({
-- 		playpanicbutton = true,
-- 		panicbuttonvolume = volume
-- 		})
-- end)

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

RegisterCommand('rmallwarrants', function(source, args)
    if isCop == true and canAccessMDT() then
        vRPCopsS.removeAllWarrants(tonumber(args[1]))
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
    local ped
    local veh
    while true do
        Citizen.Wait(500)
        ped = GetPlayerPed(-1)
        veh = GetVehiclePedIsTryingToEnter(ped)
        if (veh ~= nil) and (GetVehicleClass(veh) == 18) then
            mdtLoggedIn = true
        else
            mdtLoggedIn = false
        end
    end
end)

-- EMS

Citizen.CreateThread(function()
    local ped
    while true do
        Citizen.Wait(1000)
        ped = GetPlayerPed(-1)
        if IsEntityDead(ped) and (reviveWait > 0) then
            reviveWait = reviveWait - 1
        end
    end
end)


Citizen.CreateThread(function()
    local ped
    while true do
        Citizen.Wait(0)
        ped = GetPlayerPed(-1)
        if IsEntityDead(ped) or GetEntityHealth(ped) < 2 then
            SetPlayerInvincible(ped, true)
            SetEntityHealth(ped, 1)
            ShowInfoRevive('~y~You are in a coma. Use /911 to alert authorities. '..tostring(reviveWait)..' seconds to ~p~R ~y~ respawn (2500$)')
            if (IsControlJustReleased(0,45) or IsDisabledControlJustReleased(0,45)) and GetLastInputMethod(0) then
                if (reviveWait < 1) then
                    vRPCopsS.hospitalStay(2500)
                    respawnPed(ped, emsCoords[1])
                    RemoveAllPedWeapons(ped, true)
                    reviveWait = 180
                end
            end
        end
    end
end)

-- Private Revive Functions

function revivePed(ped)
	local playerPos = GetEntityCoords(ped, true)
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

AddEventHandler('vrp:RequestHandcuffed', function()
    TriggerEvent("vrp:UpdateHandcuffed", handcuffed)
end)

function vRPCops.isAdmin()
    return isAnAdmin
end

function vRPCops.isCop()
    return isCop
end

function vRPCops.isEMS()
    return isEMS
end

exports('isEmergencyJob', function()
    return isCop or isEMS
end)
exports('isCop', function()
    return isCop
end)
exports('isEMS', function()
    return isEMS
end)
exports('isAdmin', function()
    return isAnAdmin
end)
exports('getPermLevel', function()
    return permLevel
end)
exports('isHandcuffed', function()
    return handcuffed
end)
