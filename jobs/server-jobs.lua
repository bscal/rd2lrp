local vRPjobs = {}
Tunnel.bindInterface("jobs", vRPjobs)
Proxy.addInterface("jobs", vRPjobs)

local vRPclient = Tunnel.getInterface("vRP", "jobs")
local vRPjobsC = Tunnel.getInterface("jobs", "jobs")

function vRPjobs.random(size)
    math.randomseed(os.time())
    return math.random(1, size)
end

function vRPjobs.notify()
    vRP.EXT.Base.remote._notify(source, "You have a delivery to make")
end

function vRPjobs.truckCost()
    local user = vRP.users_by_source[source]
    user:tryFullPayment(150, false)
    vRP.EXT.Base.remote._notify(user.source, "You were charged 150$ for truck damages")
end

function vRPjobs.completeDelivery(distance)
    local user = vRP.users_by_source[source]
    local amount = 250 + math.floor(distance * .05)
    user:giveWallet(amount)
    vRP.EXT.Base.remote._notify(user.source, "You recieved " .. amount .. "$ for the delivery")
end

function vRPjobs.completeWeedDelivery()
    local user = vRP.users_by_source[source]
    local amount = 1500
    user:giveWallet(amount)
    vRP.EXT.Base.remote._notify(user.source, "You recieved " .. amount .. "$ for the delivery")
end

function vRPjobs.hasWeed()
    local user = vRP.users_by_source[source]
    if user:tryTakeItem("weed_brick", 6, true, true) then
        return true
    end
    vRP.EXT.Base.remote._notify(user.source, "You need 6 weed bricks.")
end

function vRPjobs.weedDelivery()
    local user = vRP.users_by_source[source]
    return user:tryTakeItem("weed_brick", 2, false, false)
end

function vRPjobs.hasCocaine()
    local user = vRP.users_by_source[source]
    if user:tryTakeItem("edible|cocaine", 1, true, true) then
        return true
    end
    vRP.EXT.Base.remote._notify(user.source, "You need 1 cocaine.")
    return false
end

function vRPjobs.completeCocaineSale()
    local user = vRP.users_by_source[source]
    local amount = 600 + vRPjobs.getRandom(0, 100)
    if user:tryTakeItem("edible|cocaine", 1, false, false) then
        user:giveWallet(amount)
        vRP.EXT.Base.remote._notify(user.source, "You sold cocaine for " .. amount .. "$.")
    end
end

function vRPjobs.getRandom(min, max)
    math.randomseed(os.time())
    return math.random(min, max)
end

local cocaineSells = {
    {x = -807.35809326172, y = -1016.6823120118, z = 12.920090675354},
    {x = -1569.6735839844, y = -487.87338256836, z = 35.391376495362},
    {x = -41.171924591064, y = -103.00801086426, z = 57.705585479736},
    {x = 80.370742797852, y = -184.60665893554, z = 55.035083770752},
    {x = -662.1694946289, y = 241.7868347168, z = 81.311325073242},
    {x = -197.16400146484, y = 272.64752197266, z = 92.156089782714},
    {x = 269.21063232422, y = 325.6923828125, z = 105.5442123413}
}

local changeTime = 60 * 1000 * 60
local rand1 = 0
local rand2 = 0

Citizen.CreateThread(
    function()
        while true do
            rand1 = vRPjobs.random(#cocaineSells)
            rand2 = vRPjobs.random(#cocaineSells)
            while rand2 == rand1 do
                rand2 = vRPjobs.random(#cocaineSells)
            end
            print(rand1)
            print(rand2)
            vRPjobsC._switchCocaineLocations(-1, cocaineSells[rand1], cocaineSells[rand2])
            Citizen.Wait(changeTime)
        end
    end
)

function vRPjobs.getCocaineLocations()
    return cocaineSells[rand1], cocaineSells[rand2]
end

--[[
    !
    ! MYSQL user_jobs queries and other jobs functionality
    !
]]
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

-- * Table of levels based on initLevels and levelup equation function
local xpForLevel = {}
-- * Variables used in levelUpEquation
local lvlx = 2
local lvly = 2
local lvlz = 1
local function levelUpEquation(level)
    return (lvlx * level ^ 2) + (lvly * level) + lvlz
end

local function canLevelUp(xp)
    for i = 1, #xpForLevel do
        if xp < xpForLevel[i] then
            return i
        end
    end
end

local function initLevels(max)
    for i = 1, max do
        xpForLevel[i] = levelUpEquation(i)
    end
end

initLevels(10)

function vRPjobs.tryLevelUp()
    local user = vRP.users_by_source[source]
    if not DoesCIDJobExist(user.cid) then
        return
    end

    local query = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM user_jobs WHERE cid=@cid", {cid = user.cid})

    if canLevelUp(levelUpEquation(query[1].level)) then
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

function vRPjobs.setCurrentJob(job)
    local user = vRP.users_by_source[source]
    local querystring = ""
    if DoesCIDJobExist(user.cid) then
        querystring = "UPDATE user_jobs SET job=@job, level=1, xp=0 WHERE cid=@cid"
    else
        querystring = "INSERT INTO user_jobs (cid, job, level, xp) VALUES (@cid, @job, 1, 0)"
    end
    exports["GHMattiMySQL"]:QueryAsync(querystring, {cid = user.cid, job = job, callback = sqlInfoCallback("success")})
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

-- * Business table
local businessTables = {
    ["Car Salesman"] = {name = "Car Salesman", btype = "cars_sales", salary = 1000, downpay = 20000, cost = 50000},
    ["Banker"] = {salary = 2000}
}

function vRPjobs.buyBusiness(bname)
    local BASE_WORTH_PERCENTAGE = 0.50

    local user = vRP.users_by_source[source]
    local business = businessTables[bname]
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

--! Mysql Queries
exports["GHMattiMySQL"]:Query(
    "CREATE TABLE IF NOT EXISTS user_jobs (cid INT, level INT DEFAULT 1, xp INT, job VARCHAR(64))"
)
exports["GHMattiMySQL"]:Query(
    "CREATE TABLE IF NOT EXISTS user_business (cid INT, bid INT PRIMARY KEY AUTO_INCREMENT, bname VARCHAR(32), worth INT DEFAULT 20000, btype VARCHAR(64), building VARCHAR(128))"
)
