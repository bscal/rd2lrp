local vRPCops = {}
Tunnel.bindInterface("cops", vRPCops)
Proxy.addInterface("cops", vRPCops)

local vRPclient = Tunnel.getInterface("vRP", "cops")
local vRPcopsC = Tunnel.getInterface("cops", "cops")

local jail = {1689.2, 2562.7, 46.7}
local osJail = {1848.33618, 2585.29825, 46.67208}

--[[
 * Server online cop blib logic
--]]
local onlineCops = {}

function vRPCops.addOnlineCop(jobId, x, y, z)
    onlineCops[source] = {x, y, z, jobId}
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(32)
            SendOnlineCopsToClients()
            onlineCops = {}
        end
    end
)

function SendOnlineCopsToClients()
    for k, v in pairs(onlineCops) do
        vRPcopsC._sendOnlineCopsToClients(k, onlineCops)
    end
end

--[[
 * Functions
--]]
function vRPCops.hospitalStay(amount)
    local user = vRP.users_by_source[source]
    user:tryFullPayment(amount, false)
end

function vRPCops.updateJailTime(player)
    local user = vRP.users_by_source[source]
    if (user == nil) then
        return
    end
    local cid = user.cid

    local userid = user.id
    if not isJailed(userid, cid) then
        return
    end

    TriggerClientEvent("leash", user.source, jail[1], jail[2], jail[3])

    if (getTime(userid, cid) < 1) then
        exports["GHMattiMySQL"]:Query("DELETE FROM rp_jail WHERE uid=@uid AND cid=@cid", {uid = userid, cid = cid})
        TriggerClientEvent("tp", user.source, osJail[1], osJail[2], osJail[3])
        TriggerClientEvent(
            "pNotify:SendNotification",
            user.source,
            {
                text = "You are free from your sentence.",
                type = "success",
                timeout = 3000,
                layout = "topRight"
            }
        )
    end

    exports["GHMattiMySQL"]:Query(
        "UPDATE rp_jail SET time=time - 1 WHERE uid=@uid AND cid=@cid",
        {uid = userid, cid = cid}
    )
end

function vRPCops.Fine(player, userid, amount)
    local user = vRP.users_by_source[source]
    local criminal = vRP.users_by_source[userid]
    if not (isCopId(user)) then
        TriggerClientEvent(
            "pNotify:SendNotification",
            user.source,
            {
                text = "<strong>You are not a cop</strong>",
                type = "error",
                timeout = 5000,
                layout = "topRight"
            }
        )
        return
    end
    if (criminal:tryFullPayment(amount, false) == true) then
        return true
    end
    local bank = criminal:getBank()
    criminal:setBank(bank - amount)
    TriggerClientEvent(
        "pNotify:SendNotification",
        criminal.source,
        {
            text = "<strong>You have been fined" .. amount .. "$</strong>",
            type = "info",
            timeout = 5000,
            layout = "topRight"
        }
    )
    return false
end

function vRPCops.removeWeaponServer()
    local user = vRP.users_by_source[source]
    local weapons = vRP.EXT.PlayerState.remote.replaceWeapons(user.source, {})
    for k, v in pairs(weapons) do
        -- convert weapons to parametric weapon items
        user:tryGiveItem("wbody|" .. k, 1)
        if v.ammo > 0 then
            user:tryGiveItem("wammo|" .. k, v.ammo)
        end
    end
end

function vRPCops.seize(closestID)
    local user = vRP.users_by_source[source]
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source, 5)
    if nplayer then
        nuser = vRP.users_by_source[nplayer]
    end
    if nuser then
        local weapons = vRP.EXT.PlayerState.remote.replaceWeapons(nuser.source, {})
        for k, v in pairs(weapons) do
            -- convert weapons to parametric weapon items
            user:tryGiveItem("wbody|" .. k, 1)
            if v.ammo > 0 then
                user:tryGiveItem("wammo|" .. k, v.ammo)
            end
        end

        -- items
        local inventory = nuser:getInventory()

        for key in pairs(self.cfg.seizable_items) do -- transfer seizable items
            local sub_items = {key} -- single item

            if string.sub(key, 1, 1) == "*" then -- seize all parametric items of this id
                local id = string.sub(key, 2)
                sub_items = {}
                for fullid in pairs(inventory) do
                    if splitString(fullid, "|")[1] == id then -- same parametric item
                        table.insert(sub_items, fullid) -- add full idname
                    end
                end
            end

            for _, fullid in pairs(sub_items) do
                local amount = nuser:getItemAmount(fullid)
                if amount > 0 then
                    local citem = vRP.EXT.Inventory:computeItem(fullid)
                    if citem then -- do transfer
                        if nuser:tryTakeItem(fullid, amount) then
                            user:tryGiveItem(fullid, amount)
                        end
                    end
                end
            end
        end
        vRP.EXT.Base.remote._notify(nuser.source, "You had you items seized")
    end
end

function vRPCops.Jail(player, userid, time)
    local user = vRP.users_by_source[source]
    local criminal = vRP.users_by_source[userid]
    local cid = criminal.cid
    if not (isCopId(user)) then
        TriggerClientEvent(
            "pNotify:SendNotification",
            user.source,
            {
                text = "<strong>You are not a cop</strong>",
                type = "error",
                timeout = 5000,
                layout = "topRight"
            }
        )
        return
    end
    if not isJailed(criminal.id, cid) then
        exports["GHMattiMySQL"]:Query(
            "INSERT INTO rp_jail (uid, cid, time) VALUES (@uid, @cid, @time)",
            {uid = criminal.id, cid = cid, time = time}
        )
        TriggerClientEvent("tp", criminal.source, jail[1], jail[2], jail[3])
        TriggerClientEvent(
            "pNotify:SendNotification",
            criminal.source,
            {
                text = "You have been jailed for " .. tostring(time) .. " months! Enjoy your stay :)",
                type = "info",
                timeout = 5000,
                layout = "topRight"
            }
        )
    else
        exports["GHMattiMySQL"]:Query(
            "UPDATE rp_jail SET time=@time WHERE uid=@uid AND cid=@cid",
            {time = time, uid = criminal.id, cid = cid}
        )
    end
end

function vRPCops.getJail()
    return jail
end

function isJailed(userid, cid)
    local results =
        exports["GHMattiMySQL"]:QueryResult(
        "SELECT * FROM rp_jail WHERE uid=@uid AND cid=@cid",
        {uid = userid, cid = cid}
    )
    if (#results < 1) then
        return false
    end
    return true
end

function getTime(userid, cid)
    local results =
        exports["GHMattiMySQL"]:QueryResult(
        "SELECT * FROM rp_jail WHERE uid=@uid AND cid=@cid",
        {uid = userid, cid = cid}
    )
    print(json.encode(results))
    if (#results < 1) then
        return 0
    end
    return results[1].time
end

function vRPCops.isCop()
    local user = vRP.users_by_source[source]
    local cid = user.cid
    local results =
        exports["GHMattiMySQL"]:QueryResult(
        "SELECT * FROM cops WHERE uid=@uid AND cid=@cid",
        {uid = user.id, cid = cid}
    )
    if (#results < 1) then
        return false
    end
    return true
end

function vRPCops.isAdmin()
    local user = vRP.users_by_source[source]
    local results = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM copadmins WHERE uid=@uid", {uid = user.id})
    if (#results < 1) then
        return false
    end
    return true
end

function vRPCops.isAdminToClient()
    local user = vRP.users_by_source[source]
    local results = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM copadmins WHERE uid=@uid", {uid = user.id})
    if #results < 1 then
        TriggerClientEvent("cop:clientIsAdmin", user.source, false, 0)
        return
    end
    TriggerClientEvent("cop:clientIsAdmin", user.source, true, results[1].perm)
end

function getCopData(userid, cid)
    local results =
        exports["GHMattiMySQL"]:QueryResult("SELECT * FROM cops WHERE uid=@uid AND cid=@cid", {uid = userid, cid = cid})
    if (#results < 1) then
        print("cop data error")
        return nil
    end
    return results
end

function isCopId(user)
    local results =
        exports["GHMattiMySQL"]:QueryResult(
        "SELECT * FROM cops WHERE uid=@uid AND cid=@cid",
        {uid = user.id, cid = user.cid}
    )
    if (#results < 1) then
        return false
    end
    return true
end

function isAdminId(userid)
    local user = vRP.users[userid]
    local results = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM copadmins WHERE uid=@uid", {uid = userid})
    if (#results < 1) then
        return false
    end
    return true
end

function getAdminPermLevel(userid)
    if not isAdminId(userid) then
        return 0
    end
    local results = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM copadmins WHERE uid=@uid", {uid = userid})
    return results[1].perms
end

function vRPCops.getAdminPermLevel()
    local user = vRP.users_by_source[source]
    local permLevel = getAdminPermLevel(user.id)
    if permLevel > 0 then
        TriggerClientEvent("cops:SetAdminPermLevel", user.source, permLevel)
    end
    return permLevel
end

function vRPCops.setAdmin(userid)
    local user = vRP.users_by_source[source]
    if (isAdminId(userid)) then
        return
    end
    exports["GHMattiMySQL"]:Query("INSERT INTO copadmins (uid) VALUES (@uid)", {uid = user.id})
end

function vRPCops.setCop(userid)
    local user = vRP.users_by_source[source]
    if not (isAdminId(user.id)) then
        return
    end
    if (isCopId(user)) then
        return
    end
    local p = vRP.users_by_source[userid]
    exports["GHMattiMySQL"]:Query("INSERT INTO cops (uid, cid) VALUES (@uid, @cid)", {uid = p.id, cid = p.cid})
end

function vRPCops.delCop(userid)
    local user = vRP.users_by_source[source]
    if not (isAdminId(user.id)) then
        return
    end
    local p = vRP.users_by_source[userid]
    exports["GHMattiMySQL"]:Query("DELETE FROM cops WHERE uid=@uid AND cid=@cid", {uid = p.id, cid = p.cid})
end

function vRPCops.delAdmin(userid)
    local user = vRP.users_by_source[source]
    if not (isAdminId(user.id)) then
        return
    end
    exports["GHMattiMySQL"]:Query("DELETE FROM copadmins WHERE uid=@uid", {uid = user.id})
end

function vRPCops.isCopToClient()
    local user = vRP.users_by_source[source]
    local cid = user.cid
    local results =
        exports["GHMattiMySQL"]:QueryResult(
        "SELECT * FROM cops WHERE uid=@uid AND cid=@cid",
        {uid = user.id, cid = cid}
    )
    if (#results < 1) then
        return
    end
    TriggerClientEvent("isCop", user.source)
end

function vRPCops.isEMS()
    local user = vRP.users_by_source[source]
    local cid = user.cid
    local results =
        exports["GHMattiMySQL"]:QueryResult("SELECT * FROM ems WHERE uid=@uid AND cid=@cid", {uid = user.id, cid = cid})
    if (#results < 1) then
        return
    end
    TriggerClientEvent("isEMS", user.source)
end

function vRPCops.showID(closestID)
    local user = vRP.users_by_source[source]
    local identity = user.identity
    TriggerClientEvent(
        "pNotify:SendNotification",
        user.source,
        {
            text = "You have showed your id",
            type = "info",
            timeout = 5000,
            layout = "topRight"
        }
    )
    TriggerClientEvent(
        "pNotify:SendNotification",
        closestID,
        {
            text = "<b style='color:yellow'>California ID</b> <br /> <p style='color:white'>ID#: " ..
                identity.registration ..
                    "<br />LN: " ..
                        identity.name .. "<br />FN: " .. identity.firstname .. "<br />Age: " .. identity.age .. "</p>",
            type = "info",
            timeout = 15000,
            layout = "topRight"
        }
    )
end

function vRPCops.showPhone(closestID)
    local user = vRP.users_by_source[source]
    TriggerClientEvent(
        "pNotify:SendNotification",
        user.source,
        {
            text = "<b>" ..
                user.identity.firstname .. " " .. user.identity.name .. "'s phone#: " .. user.identity.phone .. ".</b>",
            type = "info",
            timeout = 10000,
            layout = "topRight"
        }
    )
    TriggerClientEvent(
        "pNotify:SendNotification",
        closestID,
        {
            text = "<b>" ..
                user.identity.firstname .. " " .. user.identity.name .. "'s phone#: " .. user.identity.phone .. ".</b>",
            type = "info",
            timeout = 10000,
            layout = "topRight"
        }
    )
end

-- Client Cop Abilities

RegisterServerEvent('police:confirmUnseat')
AddEventHandler('police:confirmUnseat', function(t)
	TriggerClientEvent('police:unseatme', t)
end)

RegisterServerEvent('police:dragRequest')
AddEventHandler('police:dragRequest', function(t)
	TriggerClientEvent('police:toggleDrag', t, source)
end)

RegisterServerEvent('police:cuffGranted')
AddEventHandler('police:cuffGranted', function(t, isCop)
    TriggerClientEvent('police:getArrested', t, isCop, source)
end)

RegisterServerEvent('police:forceEnterAsk')
AddEventHandler('police:forceEnterAsk', function(t, v)
	TriggerClientEvent('police:forcedEnteringVeh', t, v)
end)

local function tryTakeItem(user, item, amount, dry)
    return user:tryTakeItem(item, amount, dry, false)
end

function vRPCops.hasCuffs(cuffer)
    return tryTakeItem(vRP.users_by_source[cuffer], "handcuff", 1, true)
end

function vRPCops.takeCuffs(cuffer)
    tryTakeItem(vRP.users_by_source[cuffer], "handcuff", 1, false)
end

function vRPCops.hasPicklock(cuffer)
    return tryTakeItem(vRP.users_by_source[cuffer], "lockpick", 1, true)
end

function vRPCops.takePicklock(cuffer)
    tryTakeItem(vRP.users_by_source[cuffer], "lockpick", 1, false)
end

-- RegisterNetEvent("cuffServer")
-- AddEventHandler(
--     "cuffServer",
--     function(closestID)
--         TriggerClientEvent("cuffClient", closestID)
--     end
-- )

-- RegisterNetEvent("unCuffServer")
-- AddEventHandler(
--     "unCuffServer",
--     function(closestID)
--         TriggerClientEvent("unCuffClient", closestID)
--     end
-- )

-- RegisterNetEvent("dragServer")
-- AddEventHandler(
--     "dragServer",
--     function(closestID)
--         TriggerClientEvent("dragClient", closestID, source)
--     end
-- )

-- RegisterNetEvent("unDragServer")
-- AddEventHandler(
--     "unDragServer",
--     function(closestID)
--         TriggerClientEvent("unDragClient", closestID)
--     end
-- )

-- RegisterNetEvent("seatServer")
-- AddEventHandler(
--     "seatServer",
--     function(closestID, veh)
--         TriggerClientEvent("seatClient", closestID, veh)
--     end
-- )

-- RegisterNetEvent("unSeatServer")
-- AddEventHandler(
--     "unSeatServer",
--     function(closestID)
--         TriggerClientEvent("unSeatClient", closestID)
--     end
-- )

-- RegisterNetEvent("putInServer")
-- AddEventHandler(
--     "putInServer",
--     function(closestID)
--         TriggerClientEvent("putInClient", closestID)
--     end
-- )

RegisterNetEvent("reviveServer")
AddEventHandler(
    "reviveServer",
    function(closestID)
        TriggerClientEvent("reviveClient", closestID)
    end
)


-- RegisterNetEvent("panicServer")
-- AddEventHandler(
--     "panicServer",
--     function(street)
--         _source = source
--         TriggerClientEvent(
--             "chatMessage",
--             -1,
--             "Police System",
--             {255, 255, 255},
--             "Officer ^2" .. GetPlayerName(_source) .. " ^7Has pushed their panic button. Location: " .. street
--         )
--     end
-- )

RegisterNetEvent("showIDServer")
AddEventHandler(
    "showIDServer",
    function(closestID, sourceid)
        local id = vRP.users_by_source[source].identity
        TriggerClientEvent("showIDClient", closestID, sourceid, id.name, id.firstname, id, registration, id.age)
    end
)

RegisterNetEvent("showIDMessageServer")
AddEventHandler(
    "showIDMessageServer",
    function(id)
        TriggerClientEvent("chatMessage", -1, "ID", {255, 255, 255}, "Name: " .. id)
    end
)

exports('isAdmin', function(sourcePlayer)
    return vRPcopsC.isAdmin(sourcePlayer)
end)

exports('copsIsCop', function(sourcePlayer)
    return vRPcopsC.isCop(sourcePlayer)
end)

exports('copsIsEMS', function(sourcePlayer)
    return vRPcopsC.isEMS(sourcePlayer)
end)