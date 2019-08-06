vRPjobs = {}
Tunnel.bindInterface("jobs", vRPjobs)
Proxy.addInterface("jobs", vRPjobs)
vRPclient = Tunnel.getInterface("vRP", "jobs")
vRPjobsC = Tunnel.getInterface("jobs", "jobs")

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

--[[
    ! Cocaine
]]
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
