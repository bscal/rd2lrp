local vRPjobs = {}
Tunnel.bindInterface("jobs", vRPjobs)
Proxy.addInterface("jobs", vRPjobs)
local vRPclient = Tunnel.getInterface("vRP","jobs")
local vRPjobsC = Tunnel.getInterface("jobs","jobs")