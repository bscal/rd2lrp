local LOWER = 400
local MIDDLE = 800
local UPPER = 1250
local POLICE = 850

--[[
    btype = the type of job/business
    types:
        - job
        - business
        - gangjob

    if 'needSet = true' is set then the job is a manually set job. This is for more important positions.
]]

-- * Business table
local businessList = {
    ["Police"]                              = {name = "Police", btype = "job", salary = POLICE, needSet=true},
    ["EMS"]                                 = {name = "EMS", btype = "job", salary = POLICE, needSet=true},
    --["Banker"]                             = {name = "Banker", btype = "job", salary = 1200},
    --["Realtor"]                             = {name = "Realtor", btype = "job", salary = 600},
    --["Insurance Salesman"]         = {name = "Insurance Salesman", btype = "job", salary = 400},
    ["Lawyer"]                             = {name = "Lawyer", btype = "job", salary = MIDDLE, needSet=true},
    ["Judge"]                              = {name = "Judge", btype = "job", salary = 2000, needSet=true},
    --["Judicial Assistant"]            = {name = "Judicial Assistant", btype = "job", salary = UPPER, needSet=true},
    ["Taxi"]                                  = {name = "Taxi", btype = "job", salary = 600},
    ["Tow"]                                  = {name = "Tow", btype = "job", salary = 600},
    ["Chef"]                                = {name = "Chef", btype = "job", salary = 600},
   -- ["Arms Dealer"]                    = {name = "Arms Dealer", btype = "job", salary = 600},
    --["IT"]                                    = {name = "IT", btype = "job", salary = 600},
    ["Pilot"]                                = {name = "Pilot", btype = "job", salary = 600},
    ["Driving Teacher"]              = {name = "Driving Teacher", btype = "job", salary = UPPER, needSet=true},
    ["Car Salesman"]                 = {name = "Car Salesman", btype = "business", salary = 800, downpay = 30000, cost = 100000},
    ["Car Repair"]                      = {name = "Car Repair", btype = "business", salary = 800, downpay = 30000, cost = 100000},
    ["Car Exotic"]                      = {name = "Car Exotic", btype = "business", salary = 1000, downpay = 250000, cost = 500000},
    ["Company"]                       = {name = "Company", btype = "business", salary = 600, downpay = 20000, cost = 40000},
    ["Store"]                              = {name = "Store", btype = "business", salary = 600, downpay = 20000, cost = 40000}
}

-- * Table of levels based on initLevels and levelup equation function
local xpForLevel = {}

-- * Variables used in levelUpEquation
local lvlx = 2
local lvly = 2
local lvlz = 1
local function levelUpEquation(level)
    return (lvlx * level ^ 2) + (lvly * level) + lvlz
end

local function canLevelUp(xp, level)
    if level + 1 > #xpForLevel then return false end
    return xp > xpForLevel[level + 1]
end

local function initLevels(max)
    for i = 1, max do
        xpForLevel[i] = levelUpEquation(i)
    end
end

-- ! Initilize

initLevels(10)

--! Job Menu GUI

local MENU_NAME = "jobs.select"

local function m_jobs(menu, job)
    print(name, job)
    local user = menu.user
    local query = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM user_jobs WHERE cid=@cid", {cid = user.cid})
    if #query < 1 then
        vRPjobsC._setJob(user.source, job, 1)
        vRPjobs.setCurrentJob(user, job)
        return
    end

    if query[1].name == job then
        return
    end

    if os.time() < query[1].last + 3600 then -- Hour in seconds
        vRP.EXT.Base.remote._notify(user.source, "~r~You can change jobs once per hour.")
        return
    end

    vRPjobsC._setJob(user.source, job)
    vRPjobs.setCurrentJob(user, job)
end

local function initMenu(self)
    vRP.EXT.GUI:registerMenuBuilder(
        MENU_NAME,
        function(menu)
            menu.title = "Job Hiring"
            menu.css.header_color = "rgba(0,125,255,0.75)"

            local i = 1
            for k, v in pairs(businessList) do
                if v.btype == "job" then
                    businessList[k].id = i
                    if v.needSet then
                        menu:addOption(
                            "<p style='color: red'>" .. k .. "</p>",
                            nil,
                            "<p>You need to be interviewed for this job. Check Discord Tower's for openings.</p>",
                            v.name,
                            v.id
                        )
                    else
                        menu:addOption(
                            "<p style='color: red'>" .. k .. "</p>",
                            m_jobs,
                            "<p>TESTING 1 2 3 TEST TEST TESTINNNNGGG!</p>",
                            v.name,
                            v.id
                        )
                    end
                    i = i + 1
                end
            end
        end
    )
end

initMenu(self)

function vRPjobs.openJobMenu(jobName)
    local user = vRP.users_by_source[source]
    local menu = user:openMenu(MENU_NAME)
    if businessList[jobName].id then
        menu:updateOption(businessList[jobName].id, "<p style='color: green'>" .. jobName .. "</p>")
    end
    
end

function vRPjobs.closeJobMenu()
    local user = vRP.users_by_source[source]
    local menu = user:getMenu()
    if menu and menu.name == MENU_NAME then
        user:closeMenu(menu)
    end
end

-- * Paychecks
function vRPjobs.paycheck(job)
    local user = vRP.users_by_source[source]
    local pay
    local msg
    if businessList[job] then
        pay = businessList[job].salary
        msg =
            "Your paycheck of ~g~+" ..
            pay .. "$ ~w~has been deposited into your bank account. Total: ~g~" .. user:getBank() .. "$~w~."
    else
        pay = 200
        msg =
            "~g~+200$ ~w~of unemployment has been deposited into your bank account. Total: ~g~" ..
            user:getBank() .. "$~w~."
    end
    user:giveBank(pay)
    vRP.EXT.Base.remote._notifyPicture(user.source, "CHAR_BANK_MAZE", 2, "Maze Bank", "Bank statement", msg)
end

function DoesCIDJobExist(cid)
    local query = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM user_jobs WHERE cid=@cid", {cid = cid})
    if (#query < 1) then
        return false
    end
    return true
end

function vRPjobs.setLevel(level, job)
    local user = vRP.users_by_source[source]
    local querystring = "UPDATE user_jobs SET level=@level WHERE cid=@cid"
    local newLevel = level
    if level > 10 then
        newLevel = 10
    elseif level < 1 then
        newLevel = 1
    end
    exports["GHMattiMySQL"]:QueryAsync(
        querystring,
        {cid = user.cid, level = newLevel, callback = sqlInfoCallback("[ok] set level")}
    )
    if job == nil then
        job = ""
    end
    vRP.EXT.Base.remote._notify(user.source, "You gained a level! Now level~r~ " .. newLevel .. " " .. job)
end

function vRPjobs.tryLevelUp()
    local user = vRP.users_by_source[source]
    if not DoesCIDJobExist(user.cid) then
        return
    end

    exports["GHMattiMySQL"]:Query("UPDATE user_jobs SET xp = xp + 1 WHERE cid=@cid", {cid = user.cid})
    local query = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM user_jobs WHERE cid=@cid", {cid = user.cid})

    if canLevelUp(query[1].xp, query[1].level) then
        vRPjobs:setLevel(query[1].level + 1, query[1].job)
    end
end

function vRPjobs.getCurrentJob()
    local user = vRP.users_by_source[source]
    local query = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM user_jobs WHERE cid=@cid", {cid = user.cid})
    if #query < 1 or not businessList[query[1].job] then
        return {job = "Unemployed", level = 1}
    end
    return {job = query[1].job, level = query[1].level}
end

function vRPjobs.getCurrentJobByUser(user)
    local query = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM user_jobs WHERE cid=@cid", {cid = user.cid})
    if (#query < 1) then
        return {job = "Unemployed", level = 1}
    end
    for k, v in pairs(query) do
        print(k)
        for kk, vv in pairs(v) do
            print(kk, vv)
        end
    end
    return {job = query[1].job, level = query[1].level}
end

function sqlInfoCallback(msg)
    print(msg)
end

function vRPjobs.setSourceCurrentJob(sourceid, job)
    vRPjobs.setCurrentJob(vRP.users_by_source[sourceid], job)
end

function vRPjobs.setCurrentJob(user, job)
    local querystring = ""
    if DoesCIDJobExist(user.cid) then
        querystring = "UPDATE user_jobs SET job=@job, level=1, xp=0, last=@last WHERE cid=@cid"
    else
        querystring = "INSERT INTO user_jobs (cid, job, level, xp, last) VALUES (@cid, @job, 1, 0, @last)"
    end
    exports["GHMattiMySQL"]:QueryAsync(querystring, {cid = user.cid, job = job, last = os.time(), callback = sqlInfoCallback("success")})
end

function vRPjobs.trySetJob(user, job)
    local querystring = ""
    if DoesCIDJobExist(user.cid) then
        if vRPjobs.getCurrentJobByUser(user).job == job then return end
        querystring = "UPDATE user_jobs SET job=@job, level=1, xp=0, last=@last WHERE cid=@cid"
    else
        querystring = "INSERT INTO user_jobs (cid, job, level, xp, last) VALUES (@cid, @job, 1, 0, @last)"
    end
    exports["GHMattiMySQL"]:QueryAsync(querystring, {cid = user.cid, job = job, last = os.time(), callback = sqlInfoCallback("success")})
    vRPjobsC._setJob(user.source, job)
end

RegisterNetEvent("jobs:setEmergencyJob")
AddEventHandler("jobs:setEmergencyJob", function(job)
    vRPjobs.trySetJob(vRP.users_by_source[source], job)
end)

--[[
    !
    ! Mysql functions for businesses
    !
]]
-- Checks if business name or type already exists
function DoesBusinessExist(bname, btype)
    local querystring = "SELECT * FROM user_business WHERE bname=@bname OR btype=@btype"
    local query = exports["GHMattiMySQL"]:QueryResult(querystring, {bname = bname, btype = btype})
    if (#query < 1) then
        return false
    end
    return true
end

function CreateNewBusiness(cid, bname, btype, worth)
    if DoesBusinessExist(bname, btype) then
        return false
    end
    local querystring = "INSERT INTO user_business (cid, bname, btype, worth) VALUES (@cid, @bname, @btype, @worth)"
    exports["GHMattiMySQL"]:Query(querystring, {cid = cid, bname = bname, btype = btype, worth = worth})
    return true
end

function vRPjobs.buyBusiness(bname)
    local BASE_WORTH_PERCENTAGE = 0.50

    local user = vRP.users_by_source[source]
    local business = businessList[bname]
    if user:tryPayment(business.downpay, true) then
        if not CreateNewBusiness(user.cid, bname, business.btype, worth * BASE_WORTH_PERCENTAGE) then
            vRP.EXT.Base.remote._notify(user.source, "~r~Business name or type taken.")
            return
        end
        user:tryPayment(business.downpay, false)
        vRP.EXT.Base.remote._notify(user.source, "~g~Purchase success. Congratulations you now own " .. business.name)
    else
        vRP.EXT.Base.remote._notify(
            user.source,
            "~r~Purchase denied. Minimum down payment of: " .. business.downpay .. "$."
        )
    end
end

-- * Bankers
function vRPjobs.bankConstruct()
    local user = vRP.users_by_source[source]
    exports["GHMattiMySQL"]:Query("INSERT INTO bankers (cid) VALUES (@cid)", {cid = user.cid})
end

function vRPjobs.bankDeconstruct()
    local user = vRP.users_by_source[source]
    exports["GHMattiMySQL"]:Query("DELETE FROM bankers WHERE cid=@cid", {cid = user.cid})
end

function vRPjobs.testGUI(enabled)
    local user = vRP.users_by_source[source]
    local querystring = "SELECT id, banker, client, type, amount, interest, currentDebt, missedPayments, totalDebt, currentWeek, weeks, "
    .. "DATE_FORMAT(start,'%e/%c/%Y %H:%i:%s') as start, DATE_FORMAT(end, '%e/%c/%Y %H:%i:%s') as end, DATE_FORMAT(nextDue,'%e/%c/%Y %H:%i:%s') as nextDue "
    .. "FROM loans WHERE client=@cid"
    local query = exports["GHMattiMySQL"]:QueryResult(querystring, {cid = user.cid})
    TriggerClientEvent("jobs:enableWindow", user.source, enabled, user.identity.name..", "..user.identity.firstname, query, user:getWallet(), user:getBank())
end


function vRPjobs.constructor(job)
    jobs.SERVER.functions[job].constructor(job, source)
end

function vRPjobs.deconstructor(job)
    jobs.SERVER.functions[job].deconstructor(job, source)
end

function vRPjobs.update(job)
    jobs.SERVER.functions[job].update(job, source)
end

-- * Taxis
businessList["Taxi"].constructor = function(job, source)
    local user = vRP.users_by_source[source]
    if not user:hasGroup("taxi") then
        user:addGroup("taxi")
    end
end

businessList["Taxi"].deconstructor = function(job, source)
    local user = vRP.users_by_source[source]
    user:removeGroup("taxi")
end

-- * tow
businessList["Tow"].constructor = function(job, source)
    local user = vRP.users_by_source[source]
    if not user:hasGroup("repair") then
        user:addGroup("repair")
    end
end

businessList["Tow"].deconstructor = function(job, source)
    local user = vRP.users_by_source[source]
    user:removeGroup("repair")
end

businessList["Judge"].constructor = function(job, source)
    local user = vRP.users_by_source[source]
    user:removeGroup("repair")
end

businessList["Judge"].deconstructor = function(job, source)
    local user = vRP.users_by_source[source]
    user:removeGroup("repair")
end

exports('getJobData', function(sourcePlayer)
    return vRPcopsC.getCurrentJob(sourcePlayer)
end)