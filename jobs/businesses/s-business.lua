local cfg = module("jobs", "configs/business")

local loans = module("jobs", "configs/loans")

local LOWER = 600
local MIDDLE = 1000
local UPPER = 1500

-- * Business table
local businessList = {
    ["Emergency Worker"]        = {name = "Emergency Worker", btype = "job", salary = 800},
    ["Banker"]                  = {name = "Banker", btype = "job", salary = 1200},
    ["Realtor"]                 = {name = "Realtor", btype = "job", salary = 600},
    ["Insurance Salesman"]      = {name = "Insurance Salesman", btype = "job", salary = 400},
    ["Lawyer"]                  = {name = "Lawyer", btype = "job", salary = 600},
    ["Judge"]                   = {name = "Judge", btype = "job", salary = 2000},
    ["Judicial Assistant"]      = {name = "Judicial Assistant", btype = "job", salary = 800},
    ["Taxi"]                    = {name = "Taxi", btype = "job", salary = 600},
    ["Tow"]                     = {name = "Tow", btype = "job", salary = 600},
    ["Chef"]                    = {name = "Chef", btype = "job", salary = 600},
    ["Arms Dealer"]             = {name = "Arms Dealer", btype = "job", salary = 600},
    ["IT"]                      = {name = "IT", btype = "job", salary = 600},
    ["Pilot"]                   = {name = "Pilot", btype = "job", salary = 600},
    ["Driving Teacher"]         = {name = "Driving Teacher", btype = "job", salary = 600},
    ["Car Salesman"]            = {name = "Car Salesman", btype = "business", salary = 800, downpay = 30000, cost = 100000},
    ["Car Repair"]              = {name = "Car Repair", btype = "business", salary = 800, downpay = 30000, cost = 100000},
    ["Car Exotic"]              = {name = "Car Exotic", btype = "business", salary = 1000, downpay = 250000, cost = 500000},
    ["Company"]                 = {name = "Company", btype = "business", salary = 600, downpay = 20000, cost = 40000},
    ["Store"]                   = {name = "Store", btype = "business", salary = 600, downpay = 20000, cost = 40000}
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

local function m_jobs(menu, value)
    print(name, value)
    local user = menu.user
    local query = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM user_jobs WHERE cid=@cid", {cid = user.cid})
    if #query < 1 then
        vRPjobsC._setJob(user.source, job)
        vRPjobs.setCurrentJob(user, job)
        return
    end

    if query[1].name == value then
        return
    end

    if query[1].last < query[1].last + 3600 then -- Hour in seconds
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
                    menu:addOption(
                        "<p style='color: red'>" .. k .. "</p>",
                        m_jobs,
                        "<p>TESTING 1 2 3 TEST TEST TESTINNNNGGG!</p>",
                        v.name,
                        v.id
                    )
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
    if (#query < 1) then
        return "Unemployed"
    end

    return query[1].job
end

function sqlInfoCallback(msg)
    print(msg)
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

-- ! Client Jobs Functions

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(60000 * 15)
            -- * Gets all over due loan payments that are one week old
            local querystring = "SELECT *, (nextDue > end) as isExpired FROM loans WHERE CURRENT_TIMESTAMP > nextDue"
            local query = exports["GHMattiMySQL"]:QueryResult(querystring)
            for k, v in pairs(query) do
                print(k, v, v.nextDue)
                local client = vRP.users_by_cid[v.client]

                if client then
                    local msg = "Your loan("..v.id..") payment is overdue. Amount owed ~r~"..v.currentDebt.."$~w~. Please consult your banker or use /paydebt <id>"
                    vRP.EXT.Base.remote._notifyPicture(client.source, "CHAR_BANK_MAZE", 2, "Maze Bank", "~r~Loan payment overdue", msg)
                end

                if v.currentDebt > 0 and v.currentWeek + 1 <= v.weeks then -- They have missed a payment for that week
                    querystring = "UPDATE loans SET missedPayments=missedPayments+1, currentDebt=@currentDebt, totalDebt=@totalDebt, currentWeek=currentWeek+1, nextDue=timestampadd(WEEK, 1, CURRENT_TIMESTAMP WHERE id=@id"
                    exports["GHMattiMySQL"]:Query(querystring, {currentDebt = loans.getInterestOwed(v), totalDebt = v.currentDebt, id = v.id})

                    querystring = "UPDATE char_data SET IF(credit-50 <= 0,credit=credit ,credit=credit-50) WHERE cid=@cid"
                    exports["GHMattiMySQL"]:Query(querystring, {cid = v.client})

                elseif v.currentDebt < 1 and v.currentWeek + 1 >= v.weeks then -- They have payed their payment for that week
                    querystring = "UPDATE loans SET currentDebt=@currentDebt, currentWeek=currentWeek+1, nextDue=timestampadd(WEEK, 1, CURRENT_TIMESTAMP WHERE id=@id"
                    exports["GHMattiMySQL"]:Query(querystring, {currentDebt = loans.getInterestOwed(v), id = v.id})
                end

                if v.isExpired  then
                    if v.totalDebt < 1 then -- Expired and fully paid
                        exports["GHMattiMySQL"]:Query("DELETE FROM loans WHERE id=@id", {id = v.id})
                    else -- Expired and not fully paid
                        querystring = "UPDATE char_data SET IF(credit-100 <= 0,credit=credit ,credit=credit-100) WHERE cid=@cid"
                        exports["GHMattiMySQL"]:Query(querystring, {cid = v.client})

                        querystring = "UPDATE loans SET currentDebt=currentDebt+(currentDebt * interest) WHERE cid=@cid"
                        exports["GHMattiMySQL"]:Query(querystring, {cid = v.client})
                    end
                end
            end
        end
    end
)


-- * Bankers
function vRPjobs.bankConstruct()
    local user = vRP.users_by_source[source]
    exports["GHMattiMySQL"]:Query("INSERT INTO bankers (cid) VALUES (@cid)", {cid = user.cid})
end

function vRPjobs.bankDeconstruct()
    local user = vRP.users_by_source[source]
    exports["GHMattiMySQL"]:Query("DELETE FROM bankers WHERE cid=@cid", {cid = user.cid})
end

-- Create loan
function vRPjobs.createLoan(bankerid, type, amount, interest, weeks)
    local MIN_INTEREST_PERSONAL      = 0.075
    local MIN_INTEREST_SECURE           = 0.055
    local client = vRP.users_by_source[source]
    local cid
    if vRP.users_by_source[bankerid] then
        cid = vRP.users_by_source[bankerid].cid
    else
        cid = -1
    end

    if type == "Personal" and interest < MIN_INTEREST_PERSONAL then
        return
    elseif type == "Secure" and interest < MIN_INTEREST_SECURE then
        return
    end

    if bankerid ~= -1 then
        local querystring = "SELECT totalLoanedOut FROM bankers WHERE cid=@cid"
        local bankerQuery = exports["GHMattiMySQL"]:QueryResult(querystring, {cid = cid})

        querystring = "SELECT level FROM user_jobs WHERE cid=@cid"
        local jobsQuery = exports["GHMattiMySQL"]:QueryResult(querystring, {cid = cid})

        local maxLoanMoney = loans.maxPersonalLoanMoney(jobsQuery[0].level)
        if bankerQuery + amount > maxLoanMoney then
            return
        end
    end

    -- Success
    local currentDebt = amount/weeks + amount/weeks*interest
    local querystring = "INSERT INTO fivem.loans (banker, client, type, amount, amountOwed, interest, currentDebt, weeks, end, nextDue) VALUES (@banker, @client, @type, @amount, @amount, @interest, @currentDebt, @weeks, TIMESTAMPADD(WEEK, @weeks, CURRENT_TIMESTAMP), TIMESTAMPADD(WEEK, 1, CURRENT_TIMESTAMP))"
    exports["GHMattiMySQL"]:Query(querystring, {banker = cid, client = client.cid, type = type, amount = amount, interest = interest, currentDebt = currentDebt, weeks = weeks})
end

function vRPjobs.testGUI(enabled)
    local user = vRP.users_by_source[source]
    local querystring = "SELECT id, banker, client, type, amount, interest, currentDebt, missedPayments, totalDebt, currentWeek, weeks, "
    .. "DATE_FORMAT(start,'%e/%c/%Y %H:%i:%s') as start, DATE_FORMAT(end, '%e/%c/%Y %H:%i:%s') as end, DATE_FORMAT(nextDue,'%e/%c/%Y %H:%i:%s') as nextDue "
    .. "FROM loans WHERE client=@cid"
    local query = exports["GHMattiMySQL"]:QueryResult(querystring, {cid = user.cid})
    TriggerClientEvent("jobs:enableWindow", user.source, enabled, user.identity.name..", "..user.identity.firstname, query, user:getWallet(), user:getBank())
end

-- * Taxis
function vRPjobs.taxiConstruct()
    local user = vRP.users_by_source[source]
    if not user:hasGroup("taxi") then
        user:addGroup("taxi")
    end
end

function vRPjobs.taxiDeconstruct()
    local user = vRP.users_by_source[source]
    user:removeGroup("taxi")
end

RegisterNetEvent("jobs:paybackWeekly")
AddEventHandler("jobs:paybackWeekly", function(loanID, loan)
    local user = vRP.users_by_source[source]
    local msg

    if user:tryFullPayment(loan.currentPayment, true) then
        -- Has enough cash or bank
        user:tryFullPayment(loan.currentPayment, false)

        -- Updates user's creditscore
        exports["GHMattiMySQL"]:Query("UPDATE char_data SET (creditscore=creditscore+25) WHERE cid=@cid", {cid = user.cid})
        if loan.currentWeek == loan.weeks then
            -- Was loans last payment. Deletes loan and updates banker to have his loan money back
            exports["GHMattiMySQL"]:Query("DELETE loans WHERE id=@id", {id = loanID})
            exports["GHMattiMySQL"]:Query("UPDATE bankers SET (totalLoanedOut=totalLoanedOut-@amount) WHERE cid=@banker", {banker = loan.banker, amount = loan.amount})
        else
            -- Pays weeks payment and increments currentWeek
            exports["GHMattiMySQL"]:Query("UPDATE loans SET (currentPayment=0, currentWeek=currentWeek+1) WHERE id=@id", {id = loanID})
        end
        -- Gives the bankers his pay 10% of the current loan payment. This will be given next time bankers is on
        exports["GHMattiMySQL"]:Query("UPDATE bankers SET (pay=pay+@amount) WHERE cid=@banker", {banker = loan.banker, amount = loan.currentPayment*0.1})
        msg = "You were charged ~g~" .. loan.currentPayment .. "$~w~ for your weekly loan payment."
        vRP.EXT.Base.remote._notifyPicture(user.source, "CHAR_BANK_MAZE", 2, "Maze Bank", "~g~Loan Payment Accepted", msg)
        return
    end
    msg = "Could not afford weekly payment. Current amount due ~r~" .. loan.currentPayment .. "$~w~."
    vRP.EXT.Base.remote._notifyPicture(user.source, "CHAR_BANK_MAZE", 2, "Maze Bank", "~r~Loan Payment Denied", msg)
end)

RegisterNetEvent("jobs:paybackTotal")
AddEventHandler("jobs:paybackTotal", function(loanID, loan, value)
    local user = vRP.users_by_source[source]
    local msg

    if user:tryFullPayment(value, true) then
        -- Has enough cash or bank
        user:tryFullPayment(value, false)

        if loan.totalDebt > 0 then
            
            -- Payback currently owed debt
            if loan.totalDebt - value < 0 then
                -- Has money left after paying debt
                local splitValue = loan.currentDebt - value
                local overflow = loan.amountOwed-splitValue
                if overflow < 1 then
                    -- Fully Paid Back
                    user:giveBank(overflow * 1)
                    exports["GHMattiMySQL"]:Query("DELETE loans WHERE id=@id", {id = loanID})
                    exports["GHMattiMySQL"]:Query("UPDATE bankers SET (totalLoanedOut=totalLoanedOut-@amount) WHERE cid=@banker", {banker = loan.banker, amount = loan.amount})
                    
                    msg = "You have fully paided back your loan. You were paid back ~g~"..overflow.."$~w~."
                    vRP.EXT.Base.remote._notifyPicture(user.source, "CHAR_BANK_MAZE", 2, "Maze Bank", "~g~Loan Payment Accepted", msg)
                    return
                else
                    -- Loan is not fully paid back
                    msg = "You have no remaining debt payments. You paid "..
                    exports["GHMattiMySQL"]:Query("UPDATE loans SET (totalDebt=0, amountOwed=amountOwed-@amount) WHERE id=@id", {id = loanID, amount=splitValue})
                end
            else
                -- Does not have money left after paying debt
                msg = "You have paid off ~g~"..value.."~w~ of your current debt. Remaining debt ~g~"..loan.currentDebt-value.."$"
                exports["GHMattiMySQL"]:Query("UPDATE loans SET (totalDebt=totalDebt-@amount) WHERE id=@id", {id = loanID, amount=value})
            end
        else
            -- Has no debt to pay only owed amount
            exports["GHMattiMySQL"]:Query("UPDATE loans SET (amountOwed=amountOwed-@amount) WHERE id=@id", {id = loanID, amount=value})
        end
        msg = "You have paid off ~g~"..value.."~w~ of your current owed amount. Remaining debt ~g~"..loan.currentDebt-value.."$"
        vRP.EXT.Base.remote._notifyPicture(user.source, "CHAR_BANK_MAZE", 2, "Maze Bank", "~g~Loan Payment Accepted", msg)
    else
        msg = "You have fully paided back your loan. You were paid back ~g~"..overflow.."$~w~."
        vRP.EXT.Base.remote._notifyPicture(user.source, "CHAR_BANK_MAZE", 2, "Maze Bank", "~r~Loan Payment Denied", msg)
    end
end)