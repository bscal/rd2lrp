--[[
    FiveM Scripts
    Copyright C 2018  Sighmir
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    at your option any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.
z
    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

core = Tunnel.getInterface("bscore","bscore")

local cfg = module("vrp_showroom","cfg/showroom")
local vehgarage = cfg

local function getPrice( category, model )
    for i,v in ipairs(vehshop.menu[category].buttons) do
      if v.model == model then
          return v.costs
      end
    end
    return nil 
end

-- SHOWROOM
RegisterServerEvent('veh_SR:CheckMoneyForVeh')
AddEventHandler('veh_SR:CheckMoneyForVeh', function(category, vehicle, price, veh_type, isXZ, isDM)
	local player = vRP.users_by_source[source]
	local user_id = player.id
	
    if core.getVehicles()[vehicle] then
        vRP.EXT.Base.remote._notify(source, "~r~Vehicle already owned.")
    else
        local actual_price = getPrice( category, vehicle)
        if actual_price == nil then
            print("[ error ] Vehicle "..vehicle.." from the category "..category.." doesn't have aprice set in cfg/showroom.lua")
            vRP.EXT.Base.remote._notify(source, "~r~This car is out of stock")
            return
        end
        if  actual_price ~= price then
            print( "Player with ID "..user_id.. " is suspected of Cheat Engine.")
        end
        if player:tryPayment(actual_price, false) then
            TriggerClientEvent('veh_SR:CloseMenu', player)
            vRP.EXT.Base.remote._notify(source, "You paid ~r~$"..actual_price)
        else
            vRP.EXT.Base.remote._notify(source, "~r~Not enough money.")
        end
    end
end)
