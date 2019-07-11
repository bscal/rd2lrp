vRPclient = Tunnel.getInterface("vRP", "utils")
vRPUtilS = Tunnel.getInterface("utils", "utils")

vRPUtil = {}
Tunnel.bindInterface("utils", vRPUtil)
Proxy.addInterface("utils", vRPUtil)

local mechanics = {
	{name = "Mechanic", id = 446, r = 25.0, x = -337.0, y = -135.0, z = 39.0}, -- LSC Burton
	{name = "Mechanic", id = 446, r = 25.0, x = -1155.0, y = -2007.0, z = 13.0}, -- LSC by airport
	{name = "Mechanic", id = 446, r = 25.0, x = 734.0, y = -1085.0, z = 22.0}, -- LSC La Mesa
	{name = "Mechanic", id = 446, r = 25.0, x = 1177.0, y = 2640.0, z = 37.0}, -- LSC Harmony
	{name = "Mechanic", id = 446, r = 25.0, x = 108.0, y = 6624.0, z = 31.0}, -- LSC Paleto Bay
	{name = "Mechanic", id = 446, r = 18.0, x = 538.0, y = -183.0, z = 54.0}, -- Mechanic Hawic
	{name = "Mechanic", id = 446, r = 15.0, x = 1774.0, y = 3333.0, z = 41.0}, -- Mechanic Sandy Shores Airfield
	{name = "Mechanic", id = 446, r = 15.0, x = 1143.0, y = -776.0, z = 57.0}, -- Mechanic Mirror Park
	{name = "Mechanic", id = 446, r = 30.0, x = 2508.0, y = 4103.0, z = 38.0}, -- Mechanic East Joshua Rd.
	{name = "Mechanic", id = 446, r = 16.0, x = 2006.0, y = 3792.0, z = 32.0}, -- Mechanic Sandy Shores gas station
	{name = "Mechanic", id = 446, r = 25.0, x = 484.0, y = -1316.0, z = 29.0}, -- Hayes Auto, Little Bighorn Ave.
	{name = "Mechanic", id = 446, r = 33.0, x = -1419.0, y = -450.0, z = 36.0}, -- Hayes Auto Body Shop, Del Perro
	{name = "Mechanic", id = 446, r = 33.0, x = 268.0, y = -1810.0, z = 27.0}, -- Hayes Auto Body Shop, Davis
	--	{name="Mechanic", id=446, r=24.0, x=288.0,   y=-1730.0, z=29.0},	-- Hayes Auto, Rancho (Disabled, looks like a warehouse for the Davis branch)
	{name = "Mechanic", id = 446, r = 27.0, x = 1915.0, y = 3729.0, z = 32.0}, -- Otto's Auto Parts, Sandy Shores
	{name = "Mechanic", id = 446, r = 45.0, x = -29.0, y = -1665.0, z = 29.0}, -- Mosley Auto Service, Strawberry
	{name = "Mechanic", id = 446, r = 44.0, x = -212.0, y = -1378.0, z = 31.0}, -- Glass Heroes, Strawberry
	{name = "Mechanic", id = 446, r = 33.0, x = 258.0, y = 2594.0, z = 44.0}, -- Mechanic Harmony
	{name = "Mechanic", id = 446, r = 18.0, x = -32.0, y = -1090.0, z = 26.0}, -- Simeons
	{name = "Mechanic", id = 446, r = 25.0, x = -211.0, y = -1325.0, z = 31.0}, -- Bennys
	{name = "Mechanic", id = 446, r = 25.0, x = 903.0, y = 3563.0, z = 34.0}, -- Auto Repair, Grand Senora Desert
	{name = "Mechanic", id = 446, r = 25.0, x = 437.0, y = 3568.0, z = 38.0} -- Auto Shop, Grand Senora Desert
}

-- Display blips on map
Citizen.CreateThread(
	function()
		for _, item in pairs(mechanics) do
			item.blip = AddBlipForCoord(item.x, item.y, item.z)
			SetBlipSprite(item.blip, item.id)
			SetBlipAsShortRange(item.blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(item.name)
			EndTextCommandSetBlipName(item.blip)
		end
	end
)

function IsNearMechanic()
	local ped = GetPlayerPed(-1)
	local pedLocation = GetEntityCoords(ped, 0)
	for _, item in pairs(mechanics) do
		local distance =
			GetDistanceBetweenCoords(item.x, item.y, item.z, pedLocation["x"], pedLocation["y"], pedLocation["z"], true)
		if distance < 4 then
			return true
		end
	end
end

RegisterCommand(
	"repair",
	function(source, args, rawCommand)
		if (IsNearMechanic()) then
			if (vRPUtilS.hasMoneyForRepair()) then
				TriggerEvent("iens:repair", source)
			end
		end
	end
)

-- RegisterCommand('clean', function(source, args, rawCommand)
-- 	local ped = GetPlayerPed(-1)
-- 	local veh = GetVehiclePedIsIn(ped, false)
--     SetVehicleDirtLevel(veh, 0.0)
-- end)
