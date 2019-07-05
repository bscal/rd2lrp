--Settings--
RegisterServerEvent('carwash:checkmoney')
AddEventHandler('carwash:checkmoney', function(dirt)
	local user = vRP.users_by_source[source]
	if parseFloat(dirt) > parseFloat(1.0) then
	  if user:tryPayment(25, false) then
		TriggerClientEvent('carwash:success', user.source)
		vRP.EXT.Base.remote._notify(user.source, "You paid ~g~25$ ~w~for clean car.")
	  else
		TriggerClientEvent('carwash:notenough', user.source)
		vRP.EXT.Base.remote._notify(user.source, "You need ~r~25$~w~ for a carwash.")
	  end	
	else
	  vRP.EXT.Base.remote._notify(user.source, "You car is not dirty.")
	  TriggerClientEvent('carwash:alreadyclean', user.source)
	end
end)
