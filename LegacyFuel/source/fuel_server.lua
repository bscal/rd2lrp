-- ESX = nil

-- if Config.UseESX then
-- 	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- 	RegisterServerEvent('fuel:pay')
-- 	AddEventHandler('fuel:pay', function(price)
-- 		local xPlayer = ESX.GetPlayerFromId(source)
-- 		local amount = ESX.Math.Round(price)

-- 		if price > 0 then
-- 			xPlayer.removeMoney(amount)
-- 		end
-- 	end)
-- end

vRPFuel = {}
Tunnel.bindInterface("LegacyFuel", vRPFuel)
Proxy.addInterface("LegacyFuel", vRPFuel)

function vRPFuel.getCash()
	return vRP.users_by_source[source]:getWallet()
end

local function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

RegisterServerEvent('fuel:pay')
AddEventHandler('fuel:pay', function(price)
	local user = vRP.users_by_source[source]
	local amount = round(price, 0)

	if price > 0 then
		user:tryPayment(amount, false)
		vRP.EXT.Base.remote._notify(user.source, "You were charged ~r~" .. tostring(amount) .. "$ ~w~for gas.")
	end
end)



