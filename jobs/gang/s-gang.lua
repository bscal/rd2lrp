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
