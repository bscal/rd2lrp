vRPjobs = {}
Tunnel.bindInterface("jobs", vRPjobs)
Proxy.addInterface("jobs", vRPjobs)

vRPclient = Tunnel.getInterface("vRP","jobs")
vRPjobsC = Tunnel.getInterface("jobs","jobs")

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
    local amount = 50 + math.floor(distance / 25)
    user:giveWallet(amount)
    vRP.EXT.Base.remote._notify(user.source, "You recieved "..amount.." for the delivery")
end