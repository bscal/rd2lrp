--[[Info]]--

--[[Register]]--

RegisterServerEvent("ply_garages2:sellGarages")
RegisterServerEvent("ply_garages2:buyGarages")
RegisterServerEvent("ply_garages2:add")
RegisterServerEvent("ply_garages2:remove")
RegisterServerEvent("ply_garages2:update")
RegisterServerEvent("ply_garages2:updatePlayer")
RegisterServerEvent("ply_garages2:getVehicles")

--[[Function]]--

function getPlayerID(source)
  return exports['vrp']:getCharacterID(source)
end

function checkIfThereIsAnyVehicleInTheGarage(id)
	return MySQL.Sync.fetchScalar("SELECT available FROM user_vehicle WHERE identifier=@identifier AND id=@id",	{['@id'] = id, ['@identifier'] = getPlayerID(source)})
end

function addGarageToPlayer(id, identifier)
	MySQL.Async.execute("INSERT INTO user_garage (identifier,garage_id) VALUES (@identifier,@garage_id)", {['@identifier'] = identifier, ['@garage_id'] = id}, function(data)
	end)
end

function updateSateOfGarage(id,state)
	MySQL.Async.execute("UPDATE garages SET available=@state WHERE id=@id", {['@state'] = state, ['@id'] = id}, function(data)
	end)
end

function deleteGarageFromPlayer(id)
	MySQL.Async.execute("DELETE from user_garage WHERE garage_id=@garage_id", {['@garage_id'] = id}, function(data)
	end)
end

function checkIFPlayerHasAlreadyBoughtThisGarage(id, identifier)
	local rs = MySQL.Sync.fetchAll("SELECT garage_id FROM user_garage WHERE identifier=@identifier AND garage_id=@id", {['@id'] = id, ['@identifier'] = identifier})
	return rs[1]
end

--[[Local/Global]]--



--[[Events]]--

AddEventHandler("ply_garages2:add", function(model, garage_id)
	local identifier = getPlayerID(source)
	MySQL.Async.execute("INSERT INTO user_vehicle (identifier,garage_id, model) VALUES (@identifier,@garage_id, @model)", {['@identifier'] = identifier, ['@garage_id'] = garage_id, ['@model'] = model}, function(data)
	end)
end)

AddEventHandler("ply_garages2:remove", function(model)
	local identifier = getPlayerID(source)
	MySQL.Async.execute("DELETE FROM user_vehicle WHERE identifier=@identifier AND model=@model", {['@identifier'] = identifier, ['@model'] = model}, function(data)
	end)
end)

AddEventHandler("ply_garages2:sellGarages", function(arg)
	if checkIfThereIsAnyVehicleInTheGarage(arg[1]) then
		TriggerClientEvent("ply_garages2:sellGaragesFalse", source)
	else
		exports['vrp']:giveWallet(source, arg[2])
		deleteGarageFromPlayer(arg[1])
		TriggerClientEvent("ply_garages2:sellGaragesTrue", source)
	end
end)

AddEventHandler("ply_garages2:buyGarages", function(arg)
	local playerSource = source
	local identifier = getPlayerID(playerSource)
	if checkIFPlayerHasAlreadyBoughtThisGarage(arg[1], identifier) then
		TriggerClientEvent("ply_garages2:buyGaragesFalse2", source)
	else
		MySQL.Async.fetchAll("SELECT id FROM user_garage WHERE identifier=@identifier ",{['@identifier'] = identifier}, function(data)
			if exports['vrp']:tryPayment(playerSource, arg[2], true) then
				exports['vrp']:tryPayment(playerSource, arg[2], false)
				addGarageToPlayer(arg[1], identifier)
				TriggerClientEvent('ply_garages2:buyGaragesTrue', playerSource)
			else
				TriggerClientEvent("ply_garages2:buyGaragesFalse", playerSource)
			end
		end)
	end
end)

AddEventHandler("ply_garages2:update", function()
	local playerSource = source
	TriggerClientEvent("ply_garages2:setGarages", playerSource, MySQL.Sync.fetchAll("SELECT * FROM garages",{}))
end)

AddEventHandler("ply_garages2:updatePlayer", function()
	local playerSource = source
	TriggerClientEvent("ply_garages2:setGaragesPlayer", playerSource, MySQL.Sync.fetchAll("SELECT * FROM user_garage WHERE identifier=@identifier",{["@identifier"]=getPlayerID(playerSource)}))
end)

AddEventHandler("ply_garages2:getVehicles", function()
	local playerSource = source
	local identifier = getPlayerID(playerSource)
	local rs = MySQL.Sync.fetchAll("SELECT * FROM user_vehicle WHERE identifier=@identifier",{['@identifier'] = identifier})
	TriggerClientEvent("ply_garages2:setVehicles", playerSource, rs)
end)

