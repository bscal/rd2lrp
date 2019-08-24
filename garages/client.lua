--[[Register]]--


RegisterNetEvent("ply_garages2:setGarages")
RegisterNetEvent("ply_garages2:setGaragesPlayer")
RegisterNetEvent("ply_garages2:setVehicles")
RegisterNetEvent("ply_garages2:sellGaragesFalse")
RegisterNetEvent("ply_garages2:sellGaragesTrue")
RegisterNetEvent("ply_garages2:buyGaragesTrue")
RegisterNetEvent("ply_garages2:buyGaragesFalse")
RegisterNetEvent("ply_garages2:buyGaragesFalse2")
RegisterNetEvent("ply_garages2:buyGaragesFalse3")

--[[Local/Global]]--

VEHICLES = {}
GARAGES2 = {}
PLAYERGARAGES = {}
garageSelected = { {x=nil, y=nil, z=nil}, }
garagesloaded = false
playergarageloaded = false
temp = true
local vente_location = {-45.228, -1083.123, 25.816}

local options = {
	x = 0.1,
	y = 0.2,
	width = 0.2,
	height = 0.04,
	scale = 0.4,
	font = 0,
	menu_title = "GARAGES",
	menu_subtitle = "Options",
	color_r = 0,
	color_g = 20,
	color_b = 255,
}

--[[Functions]]--
--menu

function MenuGarages(garage_id,name,price,slot,owned)
	ClearMenu()
	options.menu_title = options.menu_title
	options.menu_subtitle = "Options"
	if garage_id == 22 then
		Menu.addButton("Store a vehicle","ReturnVeh",{garage_id,slot})
		Menu.addButton("Get a vehicle","GetVeh",{garage_id})
		Menu.addButton("Close","CloseMenu",nil)
	else
		if owned == "off" then
			Menu.addButton(price.."$ "..slot.." space(s) - Buy","BuyGarages",{garage_id,price})
			Menu.addButton("Close","CloseMenu",nil)
		else
			Menu.addButton("Sell this garage","SellGarages",{garage_id,price})
			Menu.addButton("Store a vehicle","ReturnVeh",{garage_id,slot})
			Menu.addButton("Get a vehicle","GetVeh",{garage_id})
			--Menu.addButton("Mettre à jour le véhicule","UpdateVehicule",nil)
			Menu.addButton("Close","CloseMenu",nil)
		end
	end
end

function SellGarages(arg)
	TriggerServerEvent("ply_garages2:sellGarages",arg)
	CloseMenu()
end

function BuyGarages(arg)
	TriggerServerEvent("ply_garages2:buyGarages",arg)
	CloseMenu()
end

function ReturnVeh(arg)
	local garage_id = arg[1]
	local slot = arg[2]

	Citizen.CreateThread(function()
		Citizen.Wait(0)
		if garagesloaded then
			local model = exports['vrp']:getClosestOwnedVehicle(2)
			print(model)
			exports.pNotify:SendNotification({text = "Vehicle stored", type = "success", queue = "left", timeout = 3000, layout = "centerRight"})
			TriggerServerEvent("vrp_despawnVehicle", model)
			TriggerServerEvent("ply_garages2:add", model, garage_id)
			Citizen.Wait(1000)
			CloseMenu()
		end
	end)
end

function GetVeh(args)
	options.menu_title = options.menu_title
	options.menu_subtitle = "VEHICLES"
	ClearMenu()
	print(args[1], VEHICLES[1].garage_id)
	for _, v in pairs(VEHICLES) do
		print(v.garage_id)
		if args[1] == v.garage_id then
			Menu.addButton(tostring(v.model), "OptionVehicle", {v.id, args[1], v.model})
		end
	end
	Menu.addButton("Close","CloseMenu",nil)
end

function OptionVehicle(args)
	options.menu_title = options.menu_title
	options.menu_subtitle = "Options"
	ClearMenu()
	Menu.addButton("Get", "Get", args)
	Menu.addButton("Close","CloseMenu",nil)
end

function Get(args)
	local garage_id = args[2]
	Citizen.CreateThread(function()
		Citizen.Wait(0)

		local model = args[3] --exports['garages']:getVeh(GetPlayerServerId(GetPlayerPed(-1)), args[1], garage_id)
		TriggerServerEvent("vrp_spawnVehicle", model)
		TriggerServerEvent('ply_garages2:remove', model)
		exports.pNotify:SendNotification({text = "Vehicle out", type = "success", queue = "left", timeout = 3000, layout = "centerRight"})
		Citizen.Wait(1000)
		CloseMenu()
	end)
end

function CloseMenu()
	ClearMenu()
	Menu.hidden = true
end

--base
function ShowInfo(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, state, 0, -1)
end

function getPlayerGarage(id)
	if PLAYERGARAGES then
		for _, v in pairs(PLAYERGARAGES) do
			if id == v.garage_id then
				return true
			end
		end
	end
	return false
end

--[[Citiren]]--

Citizen.CreateThread(function()
	while true do
	  Citizen.Wait(60000)
	  TriggerServerEvent("ply_garages2:getVehicles")
	end
end)



Citizen.CreateThread(function()
  while true do
    local near = false
    Citizen.Wait(0)
    for _, v in pairs(GARAGES2) do
      if (GetDistanceBetweenCoords(v.x, v.y, v.z, GetEntityCoords(GetPlayerPed(-1))) < 2 and near == false) then
        near = true
      end
    end
    if near == false then
      Menu.hidden = true;
    end
  end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if garagesloaded then
			if temp then
				for _, v in pairs(GARAGES2) do
					if v.available == "on" then
						v.blip = AddBlipForCoord(v.x, v.y, v.z)
						SetBlipSprite(v.blip, v.blip_id)
						SetBlipAsShortRange(v.blip, true)
						SetBlipColour(v.blip, v.blip_colour)
						SetBlipScale(v.blip, 0.9)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString(v.name)
						EndTextCommandSetBlipName(v.blip)
					end
				end
				temp = false
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if garagesloaded and playergarageloaded and vehicleloaded then
			for _, v in pairs(GARAGES2) do
				if v.available == "on" then
					DrawMarker(1, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 3.001, 3.0001, 0.5001, 0, 155, 255, 200, 0, 0, 0, 0)
					if GetDistanceBetweenCoords(v.x, v.y, v.z, GetEntityCoords(GetPlayerPed(-1))) < 2 and IsPedInAnyVehicle(GetPlayerPed(-1), true) == false then
						ShowInfo("~INPUT_VEH_HORN~ to open ~g~Menu~s~", 0)
						if IsControlJustPressed(1, 86) then
							local id = v.id
							local name = v.name
							local price = v.price
							local slot = v.slot
							local owned
							garageSelected.x = v.x
							garageSelected.y = v.y
							garageSelected.z = v.z
							if getPlayerGarage(id) then
								owned = "on"
							else
								owned = "off"
							end
							MenuGarages(id,name,price,slot,owned)
							Menu.hidden = not Menu.hidden
						end
						Menu.renderGUI(options)
					end
				end
			end
		end
	end
end)

--[[Events]]--

AddEventHandler("ply_garages2:setGarages", function(THEGARAGES2)
	GARAGES2 = {}
	GARAGES2 = THEGARAGES2
	garagesloaded = true
	vehicleloaded = true
end)

AddEventHandler("ply_garages2:setGaragesPlayer", function(THEPLAYERGARAGES)
	print(THEPLAYERGARAGES)
	PLAYERGARAGES = {}
	PLAYERGARAGES = THEPLAYERGARAGES
	playergarageloaded = true
end)

AddEventHandler("ply_garages2:setVehicles", function(THEVEHICLES)
	vehicleloaded = false
	VEHICLES = {}
	VEHICLES = THEVEHICLES
	if VEHICLES then
		vehicleloaded = true
	else
		vehicleloaded = false
	end
end)

AddEventHandler('ply_garages2:sellGaragesFalse', function()
	exports.pNotify:SendNotification({text = "The garage can not be sold as long as there are still vehicles", type = "error", queue = "left", timeout = 5000, layout = "centerRight"})
end)

AddEventHandler('ply_garages2:sellGaragesTrue', function()
	exports.pNotify:SendNotification({text = "The garage has been sold", type = "success", queue = "left", timeout = 3000, layout = "centerRight"})
	playergarageloaded = false
	TriggerServerEvent("ply_garages2:updatePlayer")
	Citizen.Wait(1000)
end)

AddEventHandler('ply_garages2:buyGaragesFalse', function()
	exports.pNotify:SendNotification({text = "You do not have enough money", type = "error", queue = "left", timeout = 5000, layout = "centerRight"})
end)

AddEventHandler('ply_garages2:buyGaragesTrue', function()
	exports.pNotify:SendNotification({text = "Garage purchased", type = "success", queue = "left", timeout = 3000, layout = "centerRight"})
	playergarageloaded = false
	TriggerServerEvent("ply_garages2:updatePlayer")
	Citizen.Wait(1000)
end)

AddEventHandler('ply_garages2:buyGaragesFalse2', function()
	exports.pNotify:SendNotification({text = "You have already bought a garage", type = "error", queue = "left", timeout = 3000, layout = "centerRight"})
end)

AddEventHandler('ply_garages2:buyGaragesFalse3', function()
	exports.pNotify:SendNotification({text = "You bought too much garage", type = "error", queue = "left", timeout = 3000, layout = "centerRight"})
end)

RegisterNetEvent('vrp:playerReady')
AddEventHandler('vrp:playerReady', function(user, data)
	TriggerServerEvent("ply_garages2:getVehicles")
end)

TriggerServerEvent("ply_garages2:update")
TriggerServerEvent("ply_garages2:updatePlayer")
