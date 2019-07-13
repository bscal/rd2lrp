local MDT = class("MDT", vRP.Extension)
MDT.event = {}

vRPCops = {}
Tunnel.bindInterface("cops", vRPCops)
Proxy.addInterface("cops", vRPCops)

-- Events

function MDT.event:playerJoin(user)
    Citizen.CreateThread(
        function()
            while true do
                print("joinStart")
                Citizen.Wait(1000 * 180)
                print("joinDelayed")

                if not (criminalExists(user.id)) then
                    print("criminal entry created")
                    exports["GHMattiMySQL"]:Query(
                        "INSERT INTO mdt_criminal (uid, cid, flags, liscense, number, points, gunliscense) VALUES (@uid, @cid, @flags, @liscense, @number, 0, @gl)",
                        {
                            uid = user.id,
                            cid = user.cid,
                            flags = "",
                            liscense = "ok",
                            number = user.identity.registration,
                            gl = "ok"
                        }
                    )
                else
                    print("criminal entry updated")
                    exports["GHMattiMySQL"]:Query(
                        "UPDATE mdt_criminal SET number=@number WHERE uid=@uid AND cid=@cid",
                        {uid = user.id, cid = user.cid, number = user.identity.registration}
                    )
                end
                break
            end
        end
    )
end

vRP:registerExtension(MDT)

--------------- Functions -------------

function vRPCops.insertSentence(userid, sentence)
    local cop = vRP.users_by_source[source]
    local user = vRP.users_by_source[userid]
    local cid = user.cid

    exports["GHMattiMySQL"]:Query(
        "INSERT INTO mdt_sentence (uid, cid, sentence) VALUES (@uid, @cid, @sentence)",
        {uid = user.id, cid = cid, sentence = sentence}
    )

    TriggerClientEvent(
        "pNotify:SendNotification",
        cop.source,
        {
            text = "<b style='color:#2142ff'>MDT Status</b><br /><p>Sentence entered for" ..
                user.identity.name .. "," .. user.identity.firstname .. ".</p>",
            type = "success",
            timeout = 5000,
            layout = "topRight"
        }
    )
end

function vRPCops.insertWarrant(userid, warrant)
    local cop = vRP.users_by_source[source]
    local user = vRP.users_by_source[userid]
    local cid = user.cid

    exports["GHMattiMySQL"]:Query(
        "INSERT INTO mdt_warrant (uid, cid, officer, warrants) VALUES (@uid, @cid, @officer, @warrants)",
        {uid = user.id, cid = cid, officer = cop.identity.name, warrants = warrant}
    )

    TriggerClientEvent(
        "pNotify:SendNotification",
        cop.source,
        {
            text = "<b style='color:#2142ff'>MDT Status</b><br /><p>Warrant entered for " ..
                user.identity.name .. "," .. user.identity.firstname .. ".</p>",
            type = "success",
            timeout = 5000,
            layout = "topRight"
        }
    )
end

function vRPCops.removeWarrant(id)
    local cop = vRP.users_by_source[source]

    exports["GHMattiMySQL"]:Query("DELETE FROM mdt_warrant WHERE id=@id", {id = id})

    TriggerClientEvent(
        "pNotify:SendNotification",
        cop.source,
        {
            text = "<b style='color:#2142ff'>MDT Status</b><br /><p>Warrant removed. ID: " .. id .. ".</p>",
            type = "success",
            timeout = 5000,
            layout = "topRight"
        }
    )
end

function vRPCops.removeAllWarrants(criminalSource)
    local cop = vRP.users_by_source[source]
    local criminal = vRP.users_by_source[criminalSource]

    exports["GHMattiMySQL"]:Query("DELETE FROM mdt_warrant WHERE cid=@cid", {cid = criminal.cid})

    TriggerClientEvent(
        "pNotify:SendNotification",
        cop.source,
        {
            text = "<b style='color:#2142ff'>MDT Status</b><br /><p>All warrants removed for " ..
                criminal.identity.name .. ", " .. criminal.identity.firstname .. ".</p>",
            type = "success",
            timeout = 7500,
            layout = "topRight"
        }
    )
end

function vRPCops.setPoints(userid, points)
    local cop = vRP.users_by_source[source]
    local user = vRP.users_by_source[id]
    local cid = user.cid

    exports["GHMattiMySQL"]:Query(
        "UPDATE mdt_criminal SET points=@points WHERE uid=@uid AND cid=@cid",
        {points = points, uid = user.id, cid = cid}
    )

    TriggerClientEvent(
        "pNotify:SendNotification",
        cop.source,
        {
            text = "<b style='color:#2142ff'>MDT Status</b><br /><p>Points set.</p>",
            type = "success",
            timeout = 5000,
            layout = "topRight"
        }
    )
end

function vRPCops.setLicense(userid, liscense)
    local cop = vRP.users_by_source[source]
    local user = vRP.users_by_source[userid]
    local cid = user.cid

    local status = "ok"
    if (liscense == 1) then
        status = "suspended"
    elseif (liscense == 2) then
        status = "revoked"
    end

    exports["GHMattiMySQL"]:Query(
        "UPDATE mdt_criminal SET liscense=@liscense WHERE uid=@uid AND cid=@cid",
        {liscense = status, uid = user.id, cid = cid}
    )

    notifyUser(
        cop.source,
        "<div style='color:#2142ff'><b>MDT Status</b></div> Updated " ..
            getSourceName(user) .. " guns license to -> " .. status
    )
end

function vRPCops.setGunLicense(userid, liscense)
    local cop = vRP.users_by_source[source]
    local user = vRP.users_by_source[userid]
    local cid = user.cid

    local status = "ok"
    if (liscense == 1) then
        status = "suspended"
    elseif (liscense == 2) then
        status = "revoked"
    end

    exports["GHMattiMySQL"]:Query(
        "UPDATE mdt_criminal SET gunliscense=@gunliscense WHERE uid=@uid AND cid=@cid",
        {gunliscense = status, uid = user.id, cid = cid}
    )

    notifyUser(
        cop.source,
        "<div style='color:#2142ff'><b>MDT Status</b></div> Updated " ..
            getSourceName(user) .. " guns license to -> " .. status
    )
end

function vRPCops.setPilotLicense(userid, liscense)
    local cop = vRP.users_by_source[source]
    local user = vRP.users_by_source[userid]
    local cid = user.cid

    local status = "ok"
    if (liscense == 1) then
        status = "suspended"
    elseif (liscense == 2) then
        status = "revoked"
    elseif (liscense == 3) then
        status = "none"
    end

    exports["GHMattiMySQL"]:Query(
        "UPDATE mdt_criminal SET gunliscense=@gunliscense WHERE uid=@uid AND cid=@cid",
        {gunliscense = status, uid = user.id, cid = cid}
    )

    notifyUser(
        cop.source,
        "<div style='color:#2142ff'><b>MDT Status</b></div> Updated " ..
            getSourceName(user) .. " guns license to -> " .. status
    )
end

function vRPCops.getCriminalInfo(registration)
    local cop = vRP.users_by_source[source]
    local criminal =
        exports["GHMattiMySQL"]:QueryResult("SELECT * FROM mdt_criminal WHERE number=@number", {number = registration})
    if (#criminal < 1) then
        noCriminalFound(cop.source, registration)
        return
    end

    -- Criminal Variables
    local user = vRP.users[criminal[1].uid]
    local identity = user.identity
    local cid = user.cid

    -- Warrants
    local warrants =
        exports["GHMattiMySQL"]:QueryResult(
        "SELECT id, officer, warrants, UNIX_TIMESTAMP(date) AS date FROM mdt_warrant WHERE uid=@uid AND cid=@cid",
        {uid = user.id, cid = cid}
    )
    local warrantsStr = "<br />"
    for k, v in pairs(warrants) do
        local fdate = os.date("%c", v.date)
        warrantsStr =
            warrantsStr ..
            "<br />- " ..
                v.id .. " | Date: " .. tostring(fdate) .. " | Issued: " .. v.officer .. " | Warrant: " .. v.warrants
    end

    local info =
        "<div style='color:#2142ff'><b>MDT Status</b></div><p>Record for: #" ..
        registration ..
            " | " ..
                identity.firstname ..
                    ", " ..
                        identity.name ..
                            "</p>" ..
                                "<p> License Status: " ..
                                    criminal[1].liscense ..
                                        " | pts:" ..
                                            criminal[1].points ..
                                                "</p><p>Gun License Status: " ..
                                                    criminal[1].gunliscense ..
                                                        "</p><br /> Active Warrants:" .. warrantsStr

    TriggerClientEvent(
        "pNotify:SendNotification",
        cop.source,
        {
            text = info,
            type = "success",
            timeout = 20000,
            layout = "topRight"
        }
    )
end

function vRPCops.getCriminalInfoById(userid)
    local cop = vRP.users_by_source[source]

    local user = vRP.users_by_source[userid]
    local cid = user.cid
    local identity = user.identity
    local criminal =
        exports["GHMattiMySQL"]:QueryResult(
        "SELECT * FROM mdt_criminal WHERE uid=@uid AND cid=@cid",
        {uid = user.id, cid = cid}
    )
    if (#criminal < 1) then
        noCriminalFound(cop.source, userid)
        return
    end

    -- Criminal Variables

    -- Warrants
    local warrants =
        exports["GHMattiMySQL"]:QueryResult(
        "SELECT id, officer, warrants, UNIX_TIMESTAMP(date) AS date FROM mdt_warrant WHERE uid=@uid AND cid=@cid",
        {uid = user.id, cid = cid}
    )
    local warrantsStr = "<br />"
    for k, v in pairs(warrants) do
        local fdate = os.date("%c", v.date)
        warrantsStr =
            warrantsStr ..
            "<br />- " ..
                v.id .. " | Date: " .. tostring(fdate) .. " | Issued: " .. v.officer .. " | Warrant: " .. v.warrants
    end

    local info =
        "<div style='color:#2142ff'><b>MDT Status</b></div><p>Record for: #" ..
        identity.registration ..
            " | " ..
                identity.firstname ..
                    ", " ..
                        identity.name ..
                            "</p>" ..
                                "<p> License Status: " ..
                                    criminal[1].liscense ..
                                        " | pts:" ..
                                            criminal[1].points ..
                                                "</p><p>Gun License Status: " ..
                                                    criminal[1].gunliscense ..
                                                        "</p><br /> Active Warrants:" .. warrantsStr

    TriggerClientEvent(
        "pNotify:SendNotification",
        cop.source,
        {
            text = info,
            type = "success",
            timeout = 20000,
            layout = "topRight"
        }
    )
end

function vRPCops.getTimeRemaining()
    local user = vRP.users_by_source[source]
    local cid = user.cid
    local time =
        exports["GHMattiMySQL"]:QueryResult(
        "SELECT time FROM rp_jail WHERE uid=@uid AND cid=@cid",
        {uid = user.id, cid = cid}
    )
    if (#time < 1) then
        return
    end
    TriggerClientEvent(
        "pNotify:SendNotification",
        user.source,
        {
            text = "You have " .. time[1].time .. " months remaining.",
            type = "info",
            timeout = 5000,
            layout = "topRight"
        }
    )
end

function vRPCops.setDriversLicsenseType(crimID, type)
    local user = vRP.users_by_source[source]
    local criminal = vRP.users_by_source[crimID]
    if criminalExistsByCid(criminal.cid) then
        exports["GHMattiMySQL"]:Query(
            "UPDATE mdt_criminal SET dl_type=@dl_type WHERE cid=@cid",
            {dl_type = type, cid = cid}
        )
        notifyUser(
            user.source,
            "<div style='color:#2142ff'><b>MDT Status</b></div> Updated " ..
                getSourceName(criminal) .. " drivers license to -> " .. type
        )
    end
end

function vRPCops.setPilotLicsenseType(crimID, type)
    local user = vRP.users_by_source[source]
    local criminal = vRP.users_by_source[crimID]
    if criminalExistsByCid(criminal.cid) then
        exports["GHMattiMySQL"]:Query(
            "UPDATE mdt_criminal SET pl_type=@pl_type WHERE cid=@cid",
            {pl_type = type, cid = cid}
        )
        notifyUser(
            user.source,
            "<div style='color:#2142ff'><b>MDT Status</b></div> Updated " ..
                getSourceName(criminal) .. " pilots license to -> " .. type
        )
    end
end

function vRPCops.applyCharges(crimID, inf, mis, fel)
    local user = vRP.users_by_source[source]
    local criminal = vRP.users_by_source[crimID]
    if criminalExistsByCid(criminal.cid) then
        exports["GHMattiMySQL"]:Query(
            "UPDATE mdt_criminal SET infractions=infractions + @infractions, misdemeanor=misdemeanor + @misdemeanor, felony=felony + @felony WHERE cid=@cid",
            {infractions = inf, misdemeanor = mis, felony = fel, cid = cid}
        )
        notifyUser(
            user.source,
            "<div style='color:#2142ff'><b>MDT Status</b></div> Updated " ..
                getSourceName(criminal) .. " pilots license to -> " .. type
        )
    end
end

------------- Private Functions -------------

function getSourceName(user)
    return user.identity.name .. ", " .. user.identity.firstname
end

function notifyUser(userid, msg)
    TriggerClientEvent(
        "pNotify:SendNotification",
        userid,
        {
            text = msg,
            type = "info",
            timeout = 7500,
            layout = "topRight"
        }
    )
end

function criminalExists(playerid)
    local user = vRP.users[playerid]
    local cid = user.cid
    local results =
        exports["GHMattiMySQL"]:QueryResult(
        "SELECT * FROM mdt_criminal WHERE uid=@uid AND cid=@cid",
        {uid = user.id, cid = cid}
    )
    if (#results < 1) then
        return false
    end
    return true
end

function criminalExistsByCid(cid)
    local results = exports["GHMattiMySQL"]:QueryResult("SELECT cid FROM mdt_criminal WHERE cid=@cid", {cid = cid})
    if (#results < 1) then
        return false
    end
    return true
end

function getCriminal(registration)
    local user = vRP.users_by_source[source]
    local cid = user.cid
    local results =
        exports["GHMattiMySQL"]:QueryResult("SELECT * FROM mdt_criminal WHERE number=@number", {number = registration})
    if (#results < 1) then
        return false
    end
    return true
end

function noCriminalFound(user, registration)
    TriggerClientEvent(
        "pNotify:SendNotification",
        user,
        {
            text = "<div style='color:#2142ff'><b>MDT Status</b></div><p><span style='color:#ff2121'>Error</span> No record found for #" ..
                registration,
            type = "error",
            timeout = 5000,
            layout = "topRight"
        }
    )
end

------------- Init Databases -------------

local function initTables()
    exports["GHMattiMySQL"]:Query(
        "CREATE TABLE IF NOT EXISTS cops (uid INT, cid INT, rank INT, callsign VARCHAR(2))",
        {}
    )
    exports["GHMattiMySQL"]:Query("CREATE TABLE IF NOT EXISTS copadmins (uid INT, perm INT)", {})
    exports["GHMattiMySQL"]:Query("CREATE TABLE IF NOT EXISTS judges (cid INT, perm INT)", {})
    exports["GHMattiMySQL"]:Query("CREATE TABLE IF NOT EXISTS rp_jail (uid INT, cid INT, time INT)", {})
    exports["GHMattiMySQL"]:Query(
        "CREATE TABLE IF NOT EXISTS mdt_sentence (id INT NOT NULL PRIMARY KEY auto_increment, uid INT, cid INT, sentence TEXT(512))",
        {}
    )
    exports["GHMattiMySQL"]:Query(
        "CREATE TABLE IF NOT EXISTS mdt_warrant " ..
            "(id INT NOT NULL PRIMARY KEY auto_increment, uid INT, cid INT, officer VARCHAR(32), warrants VARCHAR(255), date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)",
        {}
    )
    exports["GHMattiMySQL"]:Query(
        "CREATE TABLE IF NOT EXISTS mdt_criminal " ..
            "(uid INT, cid INT, flags VARCHAR(32), liscense VARCHAR(32), number VARCHAR(16), points INT, gunliscense VARCHAR(32), pilotliscense VARCHAR(32), " ..
                "dl_type CHAR(1) DEFAULT 'C', pl_type CHAR(3) DEFAULT '000', infractions INT DEFAULT 0, misdemeanor INT DEFAULT 0, felony INT DEFAULT 0)",
        {}
    )
end
