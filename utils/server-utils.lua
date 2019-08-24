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
end

function Utils.event:save()
    for k, _ in pairs(vRP.users) do
        self.remote._saveStressClient(k)
    end
end

vRP:registerExtension(Utils)

function vRPUtils.saveStressServer(stress)
    local user = vRP.users_by_source[source]
    if not stress then return end
    local querystring = "INSERT INTO char_data (cid, stress) VALUES (@cid, @stress) ON DUPLICATE KEY UPDATE stress=@stress"
    exports["GHMattiMySQL"]:Query(querystring, {cid = user.cid, stress = stress})
end

function vRPUtils.getStress()
    local user = vRP.users_by_source[source]
    local querystring = "SELECT stress FROM char_data WHERE cid=@cid"
    local query = exports["GHMattiMySQL"]:QueryResult(querystring, {cid = user.cid})
    if #query < 1 then
        return 0.0
    end
    return query[1].stress
end

function vRPUtils.sendTweet(msg)
    local user = vRP.users_by_source[source]
    local name = "@" .. user.identity.firstname .. user.identity.name .. " "
    vRPUtilsC.printTweet(-1, name, msg)
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
