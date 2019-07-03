local vRPjobs = {}
Tunnel.bindInterface("jobs", vRPjobs)
Proxy.addInterface("jobs", vRPjobs)
local vRPclient = Tunnel.getInterface("vRP", "jobs")
local vRPjobsC = Tunnel.getInterface("jobs", "jobs")

local gangLocations = {}

local function doesGangExist(name)
    local gang = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM gangs WHERE name=@name", {name = name})
    if (#gang < 1) then
        return
    end
    return true
end

local function isPlayerInGang(cid)
    local gangMemeber = exports["GHMattiMySQL"]:QueryResult("SELECT * FROM gangs_members WHERE cid=@cid", {cid = cid})
    if (#gangMemeber < 1) then
        return
    end
    return true
end

--! Mysql Queries
exports["GHMattiMySQL"]:Query("CREATE TABLE IF NOT EXISTS gang_memebers (gang_id INT, cid INT)")
exports["GHMattiMySQL"]:Query(
    "CREATE TABLE IF NOT EXISTS gangs (id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, name VARCHAR(32), leader_cid INT, money INT, rep INT)"
)
