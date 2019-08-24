--[[ Config Here ]]
local Radio = false -- Radio On/ Off after the engine starts
local Time = 15 * 1000 -- Time for each stage (ms)

--[[ Hotwire Anim --]]
local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
local anim = "machinic_loop_mechandplayer"
local flags = 49

--[[ Load Anim Dict Function --]]
local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

local vehicle
local function disableEngine()
	Citizen.CreateThread(function()
		while hotwiring do
			SetVehicleEngineOn(vehicle, false, true, false)
			if not hotwiring then
				break
			end
			Citizen.Wait(0)
		end
	end)
end

local function enableUI(time, text)
	TriggerEvent("mythic_progbar:client:progress", {
        name = "hotwire_bar",
        duration = time,
        label = text,
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = animDict,
            anim = anim,
        },
        prop = {}
    }, function(status)
        if not status then
            -- Do Something If Event Wasn't Cancelled
        end
    end)
end

-- --[[ NUI progressBar
-- Thanks to https://github.com/chipsahoy6/progressBars --]]
-- function startUI(time, text, bgcolor) 
-- 	local dcolor = 'rgba(179, 57, 57,0.7)'
-- 	if bgcolor then
-- 		dcolor = bgcolor
-- 	end
-- 	SendNUIMessage({
-- 		type = "ui",
-- 		display = true,
-- 		time = time,
-- 		text = text,
-- 		color = dcolor
-- 	})
-- end

--[[ Main Thread --]]
Citizen.CreateThread(function()
	local player_entity = PlayerPedId()
	local isOwned = false
	local model, cid
	while true do
		Citizen.Wait(1)
		if GetSeatPedIsTryingToEnter(player_entity) == -1 then
	        Citizen.Wait(10)
			vehicle = GetVehiclePedIsTryingToEnter(player_entity)

			model, cid = exports['vrp']:getVehicleInfo(vehicle)
			isOwned = false
			if cid then isOwned = true end
			
			if IsVehicleNeedsToBeHotwired(vehicle) then
				disableEngine()
				hotwiring = true
				--loadAnimDict(animDict)
				Citizen.Wait(7000)
				ClearPedTasks(player_entity)
				--TaskPlayAnim(player_entity, animDict, anim, 3.0, 1.0, -1, flags, 1, 0, 0, 0)
				if hotwiring then
					enableUI(Time, "Hotwire Stage 1")
					--startUI(Time, "Hotwire Stage 1", "rgba(194, 54, 22,0.7)")
					Citizen.Wait(Time+500)
					enableUI(Time, "Hotwire Stage 2")
					--startUI(Time, "Hotwire Stage 2", "rgba(232, 65, 24,0.7)")
					Citizen.Wait(Time+500)
					if isOwned then
						enableUI(Time, "Hotwire Stage 3")
						Citizen.Wait(Time+500)
					end
				end
				if GetVehiclePedIsIn(player_entity, false) == vehicle then
					hotwiring = false
					--StopAnimTask(player_entity, animDict, anim, 1.0)
					Citizen.Wait(1000)
					SetVehicleEngineOn(vehicle, true, true, false)
					SetVehicleJetEngineOn(vehicle, true)
					--RemoveAnimDict(animDict)
					if not Radio then
						SetVehicleRadioEnabled(vehicle, false)
					end
				end
			end
		end
	end
end)

