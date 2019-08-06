--====================================================================================
--  Function APP BANK
--====================================================================================

--[[
      Appeller SendNUIMessage({event = 'updateBankbalance', banking = xxxx})
      à la connection & à chaque changement du compte
--]]

-- ES / ESX Implementation

local bank = 0
function setBankBalance (value)
      bank = value
      SendNUIMessage({event = 'updateBankbalance', banking = bank})
end

RegisterNetEvent('vrp:playerReady')
AddEventHandler('vrp:playerReady', function(user, data)
      if data.bank ~= nil then
            setBankBalance(data.bank)
      end
end)

RegisterNetEvent('vrp:core:moneyUpdated')
AddEventHandler('vrp:core:moneyUpdated', function(user, wallet, bank)
      setBankBalance(bank)
end)

-- RegisterNetEvent('esx:setAccountMoney')
-- AddEventHandler('esx:setAccountMoney', function(account)
--       if account.name == 'bank' then
--             setBankBalance(account.money)
--       end
-- end)

-- RegisterNetEvent("es:addedBank")
-- AddEventHandler("es:addedBank", function(m)
--       setBankBalance(bank + m)
-- end)

-- RegisterNetEvent("es:removedBank")
-- AddEventHandler("es:removedBank", function(m)
--       setBankBalance(bank - m)
-- end)

-- RegisterNetEvent('es:displayBank')
-- AddEventHandler('es:displayBank', function(bank)
--       setBankBalance(bank)
-- end)