local vRPclient = Tunnel.getInterface("vRP","jobs")
local vRPjobsS = Tunnel.getInterface("jobs","jobs")
local vRPjobs = {}
Tunnel.bindInterface("jobs", vRPjobs)
Proxy.addInterface("jobs", vRPjobs)