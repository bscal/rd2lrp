vRPclient = Tunnel.getInterface("vRP", "utils")
vRPUtilsC = Tunnel.getInterface("utils", "utils")

vRPUtils = {}
Tunnel.bindInterface("utils", vRPUtils)
Proxy.addInterface("utils", vRPUtils)

local Utils = class("Utils", vRP.Extension)
Utils.event = {}

function Utils.event:playerSpawn(user, first_spawn)
    if first_spawn then
        self.remote._initPlayer(user.source)
    end
    self.remote._reloadPlayer(user.source)
end

vRP:registerExtension(Utils)

local recentAds = {}
local adPrice = 100

function vRPUtils.hasAdMoney()
    local user = vRP.users_by_source[source]
    if (user:tryPayment(adPrice, false)) then
        return true
    end
    return false
end

function vRPUtils.sendTweet(msg)
    local user = vRP.users_by_source[source]
    local name = "@" .. user.identity.firstname .. user.identity.name .. " "
    vRPUtilsC.printTweet(-1, name, msg)
end

function vRPUtils.sendAd(msg)
    local user = vRP.users_by_source[source]
    local name = user.identity.firstname .. " " .. user.identity.name .. ": "
    local formattedMsg = table.insert(recentAds, 1, name .. msg)
    if (#recentAds > 5) then
        table.remove(ads, 5)
    end
    vRPUtilsC.printAd(-1, name .. msg)
end

function vRPUtils.sendRecentAds(msg)
    local user = vRP.users_by_source[source]
    for k, v in pairs(recentAds) do
        vRPUtilsC.printAd(user.source, v)
    end
end

function vRPUtils.hasItem(item, amount, ritem, ramount)
    local user = vRP.users_by_source[source]
    if user:tryTakeItem(item, amount, false, false) then
        user:tryGiveItem(ritem, ramount, false, false)
        return true
    end
    return false
end

function vRPUtils.craftItem(item, ritem)
    local user = vRP.users_by_source[source]

    for k, v in pairs(item) do
        if not user:tryTakeItem(v.item, v.amount, true, false) then
            vRP.EXT.Base.remote._notify(user.source, "You are missing " .. v.amount .. " " .. v.item)
            return false
        end
    end

    for k, v in pairs(item) do
        user:tryTakeItem(v.item, v.amount, false, false)
    end

    for k, v in pairs(ritem) do
        user:tryGiveItem(v.item, v.amount, false, false)
    end
    return true
end

function vRPUtils.test()
    local user = vRP.users_by_source[source]

    for k, v in pairs(user.phone_sms) do
        print(v)
    end

    for phone, name in pairs(user.cdata.phone_directory) do
        print(phone)
        print(name)
    end
    print(user.phone_call)
end

function vRPUtils.getContacts()
    local user = vRP.users_by_source[source]
    vRPUtilsC.setContacts(user.source, user.cdata.phone_directory)
end
