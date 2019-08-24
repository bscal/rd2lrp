local voice = {default = 5.0, shout = 12.0, whisper = 1.0, current = 0, level = nil}
local changed = false

local function voiceToPercent()
	if voice.current == 0 then
		return 0.5
	elseif voice.current == 2 then
		return 0.0
	elseif voice.current == 1 then
		return 1.0
	end
end

AddEventHandler('onClientMapStart', function()
	if voice.current == 0 then
		NetworkSetTalkerProximity(voice.default)
	elseif voice.current == 1 then
		NetworkSetTalkerProximity(voice.shout)
	elseif voice.current == 2 then
		NetworkSetTalkerProximity(voice.whisper)
	end
end)

RegisterNetEvent("vrp:playerReady")
AddEventHandler("vrp:playerReady", function(user, data)
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1)
	
			if IsControlJustPressed(1, 74) and IsControlPressed(1, 21) then -- H and leftshift
				voice.current = (voice.current + 1) % 3
				if voice.current == 0 then
					NetworkSetTalkerProximity(voice.default)
				elseif voice.current == 1 then
					NetworkSetTalkerProximity(voice.shout)
				elseif voice.current == 2 then
					NetworkSetTalkerProximity(voice.whisper)
				end
				TriggerEvent("vrp:updateStatusBar", "voice", voiceToPercent())
			end
	
			if NetworkIsPlayerTalking(PlayerId()) then
				TriggerEvent("vrp:setStatusBar", "voice", "", 25, 210, 25, voiceToPercent())
				changed = true
			elseif not NetworkIsPlayerTalking(PlayerId()) and changed then
				TriggerEvent("vrp:setStatusBar", "voice", "", 153, 153, 153, voiceToPercent())
				changed = false
			end
		end
	end)	
end)
