local MDT = class("MDT", vRP.Extension)
MDT.event = {}

vRPCops = {}
Tunnel.bindInterface("cops", vRPCops)
Proxy.addInterface("cops", vRPCops)

-- Events

function MDT.event:playerJoin(user)
    Citizen.CreateThread(function()
        while true do
            print("joinStart")
            Citizen.Wait(1000 * 180)
            print("joinDelayed")
        
            if not (criminalExists(user.id)) then
                print("criminal entry created")
                exports['GHMattiMySQL']:Query("INSERT INTO mdt_criminal (uid, cid, flags, liscense, number, points, gunliscense) VALUES (@uid, @cid, @flags, @liscense, @number, 0, @gl)", {uid = user.id, cid = user.cid, flags = "", liscense = "ok", number = user.identity.registration, gl = "ok"})
            else
                print("criminal entry updated")
                exports['GHMattiMySQL']:Query("UPDATE mdt_criminal SET number=@number WHERE uid=@uid AND cid=@cid", {uid = user.id, cid = user.cid, number = user.identity.registration})
            end
            break
        end
    end)
end

-- Functions

function vRPCops.insertSentence(userid, sentence)
    local cop = vRP.users_by_source[source]
    local user = vRP.users_by_source[userid]
    local cid = user.cid

    exports['GHMattiMySQL']:Query("INSERT INTO mdt_sentence (uid, cid, sentence) VALUES (@uid, @cid, @sentence)", {uid = user.id, cid = cid, sentence = sentence})
    
    TriggerClientEvent("pNotify:SendNotification", cop.source, {
        text = "<b style='color:#2142ff'>MDT Status</b><br /><p>Sentence entered for"..user.identity.name..","..user.identity.firstname..".</p>",
        type = "success",
        timeout = 5000,
        layout = "topRight"
    })
end

function vRPCops.insertWarrant(userid, warrant)
    local cop = vRP.users_by_source[source]
    local user = vRP.users_by_source[userid]
    local cid = user.cid
    
    exports['GHMattiMySQL']:Query("INSERT INTO mdt_warrant (uid, cid, officer, warrants) VALUES (@uid, @cid, @officer, @warrants)", {uid = user.id, cid = cid, officer = cop.identity.name, warrants = warrant})
    
    TriggerClientEvent("pNotify:SendNotification", cop.source, {
        text = "<b style='color:#2142ff'>MDT Status</b><br /><p>Warrant entered for "..user.identity.name..","..user.identity.firstname..".</p>",
        type = "success",
        timeout = 5000,
        layout = "topRight"
    })
end

function vRPCops.removeWarrant(id)
    local cop = vRP.users_by_source[source]
    
    exports['GHMattiMySQL']:Query("DELETE FROM mdt_warrant WHERE id=@id", {id = id})
    
    TriggerClientEvent("pNotify:SendNotification", cop.source, {
        text = "<b style='color:#2142ff'>MDT Status</b><br /><p>Warrant removed. ID: "..id..".</p>",
        type = "success",
        timeout = 5000,
        layout = "topRight"
    })
end

function vRPCops.setPoints(userid, points)
    local cop = vRP.users_by_source[source]
    local user = vRP.users_by_source[id]
    local cid = user.cid
    
    exports['GHMattiMySQL']:Query("UPDATE mdt_criminal SET points=@points WHERE uid=@uid AND cid=@cid", {points = points, uid = user.id, cid = cid})
    
    TriggerClientEvent("pNotify:SendNotification", cop.source, {
        text = "<b style='color:#2142ff'>MDT Status</b><br /><p>Points set.</p>",
        type = "success",
        timeout = 5000,
        layout = "topRight"
    })
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

    exports['GHMattiMySQL']:Query("UPDATE mdt_criminal SET liscense=@liscense WHERE uid=@uid AND cid=@cid", {liscense=status, uid = user.id, cid = cid})
    
    TriggerClientEvent("pNotify:SendNotification", cop.source, {
        text = "<b style='color:#2142ff'>MDT Status</b><br /><p>Lisense status changed.</p>",
        type = "success",
        timeout = 5000,
        layout = "topRight"
    })
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

    exports['GHMattiMySQL']:Query("UPDATE mdt_criminal SET gunliscense=@gunliscense WHERE uid=@uid AND cid=@cid", {gunliscense=status, uid = user.id, cid = cid})
    
    TriggerClientEvent("pNotify:SendNotification", cop.source, {
        text = "<b style='color:#2142ff'>MDT Status</b><br /><p>Lisense status changed.</p>",
        type = "success",
        timeout = 5000,
        layout = "topRight"
    })
end

function vRPCops.getCriminalInfo(registration)
    local cop = vRP.users_by_source[source]
    local criminal = exports['GHMattiMySQL']:QueryResult("SELECT * FROM mdt_criminal WHERE number=@number", {number = registration})
    if (#criminal < 1) then
        noCriminalFound(cop.source, registration)
        return
    end

    -- Criminal Variables
    local user = vRP.users[criminal[1].uid]
    local identity = user.identity
    local cid = user.cid

    -- Warrants
    local warrants = exports['GHMattiMySQL']:QueryResult("SELECT id, officer, warrants, UNIX_TIMESTAMP(date) AS date FROM mdt_warrant WHERE uid=@uid AND cid=@cid", {uid = user.id, cid = cid})
    local warrantsStr = "<br />"
    for k, v in pairs(warrants) do
        local fdate = os.date("%c", v.date)
        warrantsStr = warrantsStr.."<br />- "..v.id.." | Date: "..tostring(fdate).." | Issued: "..v.officer.." | Warrant: "..v.warrants
    end

    local info = "<div style='color:#2142ff'><b>MDT Status</b></div><p>Record for: #"..registration.." | "..identity.firstname..", "..identity.name.."</p>"
    .."<p> License Status: "..criminal[1].liscense.. " | pts:"..criminal[1].points.."</p><p>Gun License Status: "..criminal[1].gunliscense.."</p><br /> Active Warrants:"..warrantsStr

    TriggerClientEvent("pNotify:SendNotification", cop.source, {
        text = info,
        type = "success",
        timeout = 20000,
        layout = "topRight"
    })
end

function vRPCops.getCriminalInfoById(userid)
    local cop = vRP.users_by_source[source]

    local user = vRP.users_by_source[userid]
    local cid = user.cid
    local identity = user.identity
    local criminal = exports['GHMattiMySQL']:QueryResult("SELECT * FROM mdt_criminal WHERE uid=@uid AND cid=@cid", {uid = user.id, cid = cid})
    if (#criminal < 1) then
        noCriminalFound(cop.source, userid)
        return
    end

    -- Criminal Variables


    -- Warrants
    local warrants = exports['GHMattiMySQL']:QueryResult("SELECT id, officer, warrants, UNIX_TIMESTAMP(date) AS date FROM mdt_warrant WHERE uid=@uid AND cid=@cid", {uid = user.id, cid = cid})
    local warrantsStr = "<br />"
    for k, v in pairs(warrants) do
        local fdate = os.date("%c", v.date)
        warrantsStr = warrantsStr.."<br />- "..v.id.." | Date: "..tostring(fdate).." | Issued: "..v.officer.." | Warrant: "..v.warrants
    end

    local info = "<div style='color:#2142ff'><b>MDT Status</b></div><p>Record for: #"..identity.registration.." | "..identity.firstname..", "..identity.name.."</p>"
    .."<p> License Status: "..criminal[1].liscense.. " | pts:"..criminal[1].points.."</p><p>Gun License Status: "..criminal[1].gunliscense.."</p><br /> Active Warrants:"..warrantsStr

    TriggerClientEvent("pNotify:SendNotification", cop.source, {
        text = info,
        type = "success",
        timeout = 20000,
        layout = "topRight"
    })
end

function vRPCops.getTimeRemaining()
    local user = vRP.users_by_source[source]
    local cid = user.cid
    local time = exports['GHMattiMySQL']:QueryResult("SELECT time FROM rp_jail WHERE uid=@uid AND cid=@cid", {uid = user.id, cid = cid})
    if (#time < 1) then
        return
    end
    TriggerClientEvent("pNotify:SendNotification", user.source, {
        text = "You have "..time[1].time.." months remaining.",
        type = "info",
        timeout = 5000,
        layout = "topRight"
    })

end

-- Private Functions

function criminalExists(playerid)
    local user = vRP.users[playerid]
    local cid = user.cid
    local results = exports['GHMattiMySQL']:QueryResult("SELECT * FROM mdt_criminal WHERE uid=@uid AND cid=@cid", {uid = user.id, cid = cid})
    if (#results < 1) then
        return false
    end
    return true
end

function getCriminal(registration)
    local user = vRP.users_by_source[source]
    local cid = user.cid
    local results = exports['GHMattiMySQL']:QueryResult("SELECT * FROM mdt_criminal WHERE number=@number", {number = registration})
    if (#results < 1) then
        return false
    end
    return true
end

function noCriminalFound(user, registration)
    TriggerClientEvent("pNotify:SendNotification", user, {
        text = "<div style='color:#2142ff'><b>MDT Status</b></div><p><span style='color:#ff2121'>Error</span> No record found for #"..registration,
        type = "error",
        timeout = 5000,
        layout = "topRight"
    })
end

vRP:registerExtension(MDT)