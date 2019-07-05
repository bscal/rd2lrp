RegisterNetEvent('playEmote');
RegisterNetEvent('showEmotes');

-- Emotes, feel free to modify or edit or whatevah!
local emotes = {}
emotes['cop'] = {name = 'cop', anim = 'WORLD_HUMAN_COP_IDLES'}
emotes['binoculars'] = {name = 'binoculars', anim = 'WORLD_HUMAN_BINOCULARS'}
emotes['cheer'] = {name = 'cheer', anim = 'WORLD_HUMAN_CHEERING'}
emotes["crink"] = {name = 'crink', anim="WORLD_HUMAN_DRINKING"}
emotes['drink'] = {name = 'drink', anim = 'WORLD_HUMAN_DRINKING'}
emotes['smoke'] = {name = 'smoke', anim = 'WORLD_HUMAN_SMOKING'}
emotes['film'] = {name = 'film', anim = 'WORLD_HUMAN_MOBILE_FILM_SHOCKING'}
emotes['plant'] = {name = 'plant', anim = 'WORLD_HUMAN_GARDENER_PLANT'}
emotes['guard'] = {name = 'guard', anim = 'WORLD_HUMAN_GUARD_STAND'}
emotes['hammer'] = {name = 'hammer', anim = 'WORLD_HUMAN_HAMMERING'}
emotes['hangout'] = {name = 'hangout', anim = 'WORLD_HUMAN_HANG_OUT_STREET'}
emotes['hiker'] = {name = 'hiker', anim = 'WORLD_HUMAN_HIKER_STANDING'}
emotes['statue'] = {name = 'statue', anim = 'WORLD_HUMAN_HUMAN_STATUE'}
emotes['jog'] = {name = 'jog', anim = 'WORLD_HUMAN_JOG_STANDING'}
emotes['lean'] = {name = 'lean', anim = 'WORLD_HUMAN_LEANING'}
emotes['flex'] = {name = 'flex', anim = 'WORLD_HUMAN_MUSCLE_FLEX'}
emotes['camera'] = {name = 'camera', anim = 'WORLD_HUMAN_PAPARAZZI'}
emotes['sit'] = {name = 'sit', anim = 'WORLD_HUMAN_PICNIC'}
emotes['sitchair'] = {name = 'sitchair', anim = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER'}
emotes['hoe'] = {name = 'hoe', anim = 'WORLD_HUMAN_PROSTITUTE_HIGH_CLASS'}
emotes['hoe2'] = {name = 'hoe2', anim = 'WORLD_HUMAN_PROSTITUTE_LOW_CLASS'}
emotes['pushups'] = {name = 'pushups', anim = 'WORLD_HUMAN_PUSH_UPS'}
emotes['situps'] = {name = 'situps', anim = 'WORLD_HUMAN_SIT_UPS'}
emotes['fish'] = {name = 'fish', anim = 'WORLD_HUMAN_STAND_FISHING'}
emotes['impatient'] = {name = 'impatient', anim = 'WORLD_HUMAN_STAND_IMPATIENT'}
emotes['mobile'] = {name = 'mobile', anim = 'WORLD_HUMAN_STAND_MOBILE'}
emotes['diggit'] = {name = 'diggit', anim = 'WORLD_HUMAN_STRIP_WATCH_STAND'}
emotes['sunbath'] = {name = 'sunbath', anim = 'WORLD_HUMAN_SUNBATHE_BACK'}
emotes['sunbath2'] = {name = 'sunbath2', anim = 'WORLD_HUMAN_SUNBATHE'}
emotes['weld'] = {name = 'weld', anim = 'WORLD_HUMAN_WELDING'}
emotes['yoga'] = {name = 'yoga', anim = 'WORLD_HUMAN_YOGA'}
emotes['kneel'] = {name = 'kneel', anim = 'CODE_HUMAN_MEDIC_KNEEL'}
emotes['crowdcontrol'] = {name = 'crowdcontrol', anim = 'CODE_HUMAN_POLICE_CROWD_CONTROL'}
emotes['investigate'] = {name = 'investigate', anim = 'CODE_HUMAN_POLICE_INVESTIGATE'}

playing_emote = false;

local Keys = { ["W"] = 32, ["A"] = 34, ["S"] = 8, ["D"] = 9 }

RegisterCommand('emotes', function(source, args)
    TriggerEvent('showEmotes')
end)

RegisterCommand('e', function(source, args)
    TriggerEvent('playEmote', args[1])
end)

AddEventHandler('playEmote', function(name)
	if emotes[name] then
		ped = GetPlayerPed(-1);	
		if ped then
			if playing_emote == false then
				TaskStartScenarioInPlace(ped, emotes[name].anim, 0, true)
				playing_emote = true;
			end
		end
	end
end)

AddEventHandler('showEmotes', function()
	TriggerEvent('chat:addMessage', {
		color = { 255, 0, 0},
		multiline = false,
		args = { "Emotes | Ex: /em sit" }
	})
	local emoteslist = ""
	for k in pairs(emotes) do
		emoteslist = k .. " ".. emoteslist
	end
	TriggerEvent('chat:addMessage', {
		color = { 255, 0, 0},
		multiline = true,
		args = { emoteslist }
	})
end)


Citizen.CreateThread(function()
	while true do
            Citizen.Wait(0)
		if playing_emote == true then
			if IsControlPressed(1, Keys["W"]) or IsControlPressed(1, Keys["A"]) or IsControlPressed(1, Keys["S"]) or IsControlPressed(1, Keys["D"])  then
				ClearPedTasksImmediately(ped);
				playing_emote = false;
			end
		end
    end
end)
