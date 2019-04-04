vRPUtils = {}
Tunnel.bindInterface("utils", vRPUtils)
Proxy.addInterface("utils", vRPUtils)
vRPclient = Tunnel.getInterface("vRP","utilsC")
vRPUtilsC = Tunnel.getInterface("utilsC","utilsC")

local recentAds = {}
local adPrice = 100

function vRPUtils.hasAdMoney()
    local user = vRP.users_by_source[source]
    if (user:tryPayment(adPrice, false)) then
        return true;
    end
    return false
end

function vRPUtils.sendTweet(msg)
    local user = vRP.users_by_source[source]
    local name = "@"..user.identity.firstname..user.identity.name.." "
    vRPUtilsC.printTweet(-1, name, msg)
end

function vRPUtils.sendAd(msg)
    local user = vRP.users_by_source[source]
    local name = user.identity.firstname.." "..user.identity.name..": "
    local formattedMsg = 
    table.insert(recentAds, 1, name..msg)
    if (#recentAds > 5) then
        table.remove(ads, 5)
    end
    vRPUtilsC.printAd(-1, name..msg)
end

function vRPUtils.sendRecentAds(msg)
    local user = vRP.users_by_source[source]
    for k, v in pairs(recentAds) do
        vRPUtilsC.printAd(user.source, v)
    end
end

function vRPUtils.hasItem(item, amount)
    local user = vRP.users_by_source[source]
    return user:tryTakeItem(item, amount, false, false)
end

function vRPUtils.giveItem(item, amount)
    local user = vRP.users_by_source[source]
    print(item)
    print(amount)
    user:tryGiveItem(item, amount, false, false)
end

function vRPUtils.openInv(targetSource)
    local user = vRP.users_by_source[source]
    local target = vRP.users_by_source[targetSource]

    user:openChest(target.source, 30)
end