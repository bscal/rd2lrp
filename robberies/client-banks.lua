vRPclient = Tunnel.getInterface("vRP","robberies")
vRProbS = Tunnel.getInterface("robberies","robberies")

vRPRob = {}
Tunnel.bindInterface("robberiesC", vRPRob)
Proxy.addInterface("robberiesC", vRPRob)

local banks = {
	["fleeca"] = {
		position = { ['x'] = 147.04908752441, ['y'] = -1044.9448242188, ['z'] = 29.36802482605 },
		nameofbank = "Fleeca Bank",
		robbed = false,
		from = 1,
		to = 12
	},
	["fleeca2"] = {
		position = { ['x'] = -2957.6674804688, ['y'] = 481.45776367188, ['z'] = 15.697026252747 },
		nameofbank = "Fleeca Bank (Highway)",
		robbed = false,
		from = 1,
		to = 12
	},
	["blainecounty"] = {
		position = { ['x'] = -107.06505584717, ['y'] = 6474.8012695313, ['z'] = 31.62670135498 },
		nameofbank = "Blaine County Savings",
		robbed = false,
		from = 13,
		to = 15
	},
	["fleeca3"] = {
		position = { ['x'] = -1211.6306152344, ['y'] = -335.71124267578, ['z'] = 37.7 },
		nameofbank = "Fleeca Bank (Vinewood Hills)",
		robbed = false,
		from = 1,
		to = 12
	},
	["fleeca4"] = {
		position = { ['x'] = -354.452575683594, ['y'] = -53.8204879760742, ['z'] = 48.5463104248047 },
		nameofbank = "Fleeca Bank (Burton)",
		robbed = false,
		from = 1,
		to = 12
	},
	["fleeca5"] = {
		position = { ['x'] = 309.967376708984, ['y'] = -283.033660888672, ['z'] = 53.6745223999023 },
		nameofbank = "Fleeca Bank (Alta)",
		robbed = false,
		from = 1,
		to = 12
	},
	["fleeca6"] = {
		position = { ['x'] = 1176.86865234375, ['y'] = 2711.91357421875, ['z'] = 38.097785949707 },
		nameofbank = "Fleeca Bank (Desert)",
		robbed = false,
		from = 13,
		to = 15
	},
	--[[["fleeca7"] = {
		position = { ['x'] = -2068.9252929688, ['y'] = -1023.221496582, ['z'] = 11.91005039215 },
		nameofbank = "Yacht Luxury(Beach)",
		robbed = false,
		from = 16,
		to = 18
	},]]
	--[[["pacific"] = {
		position = { ['x'] = 255.001098632813, ['y'] = 225.855895996094, ['z'] = 101.005694274902 },
		nameofbank = "Pacific Standard PDB (Downtown Vinewood)",
		robbed = false,
		from = 1,
		to = 12
	}]]
}
local robColors = {r = 255, g = 55, b = 0, a = 125}
local CONST_THERMITE_TIME = 10 -- seconds
local CONST_THERMITE_FIRE = 90 -- seconds
local CONST_ROB_BANK_TIME = 60 * 5 --seconds
local CONST_BANK_COOLDOWN = 60 * 30 --minutes

local rob_progress = 0
local isBankRobbing = false
local isNearRob = false   
local thermite = CONST_THERMITE_TIME
local robTime = 0
    


function vRPRob.setBankCooldown(name)
    for k, v in pairs(banks) do
        if (k == name) then
            v.robbed = true
            resetBankCD(v)
            return
        end
    end
end

function resetBankCD(bank)
    Citizen.SetTimeout(CONST_BANK_COOLDOWN * 1000, function()
        bank.robbed = false
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if (robTime > 0) then
            robTime = robTime - 1
        end
        if (thermite > 0) then
            thermite = thermite - 1
        end
    end
end)

Citizen.CreateThread(function()

    for k, v in pairs(banks) do
        local blip = AddBlipForCoord(v.position['x'], v.position['y'], v.position['z'])
        SetBlipSprite(blip, 272)
        SetBlipColour(blip, 25)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 1.5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Bank")
        EndTextCommandSetBlipName(blip)
    end

    local ped
    local pos
    local dist
    while true do
        Citizen.Wait(1)
        ped = GetPlayerPed(-1)
        pos = GetEntityCoords(ped, true)
        isNearRob = false
        for k, v in pairs(banks) do
            DrawMarker(1,v.position['x'], v.position['y'], v.position['z'] - 1,0,0,0,0,0,0,0.8,0.8,0.8, robColors.r, robColors.g, robColors.b,robColors.a,0)
            dist = Vdist(pos.x, pos.y, pos.z, v.position['x'], v.position['y'], v.position['z'])
            if(dist < 3.0) then
                isNearRob = true
                if (isNearRob) and not (isBankRobbing) and not (v.robbed) and thermite < 1 then
                    ShowInfoRevive("~y~Rob the bank press ~p~H~y~. You need ~p~1 thermite~y~.", .35, .8)
                    
                    if (IsControlJustReleased(0,101)) then
                        if vRProbS.takeThermite() then
                            thermite = CONST_THERMITE_TIME
                            bankUseThermite(k, v.position['x'], v.position['y'], v.position['z'] - 1)
                        end
                    end
                elseif (isBankRobbing) and (isNearRob) then
                    ShowInfoRevive("~y~Robbing the bank. You have ~p~"..robTime.."~y~ seconds left.", .35, .8)
                end
            end
        end
    end
end)

function bankUseThermite(name, x, y, z)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if (thermite < 1) then
                isBankRobbing = true
                robTime = CONST_ROB_BANK_TIME
                robBank(name)
                StartScriptFire(x, y, z, 6, false)
                Citizen.SetTimeout(CONST_THERMITE_FIRE * 1000, function()
                    StopFireInRange(x, y, z, 8.0)
                end)
                break
            end
            ShowInfoRevive("~y~Thermite has ~p~"..thermite.."~y~ seconds left.", .35, .8)
        end
    end)
end

function robBank(name)
    vRProbS._robBankCooldown(name)
    Citizen.SetTimeout(CONST_ROB_BANK_TIME * 1000, function()
        if isNearRob and isBankRobbing then
            vRProbS._robBank()
        end
        isBankRobbing = false
    end)
    alertPoliceBank()
end

function alertPoliceBank() 
    local ped = GetPlayerPed(-1)
    local x,y,z = table.unpack(GetEntityCoords(ped, true))
    local streethash = GetStreetNameAtCoord(x, y, z)
    local street = GetStreetNameFromHashKey(streethash)
    TriggerEvent("DispatchRobbery", ped, "Bank robbery in progress", "None", street)
    TriggerEvent("DispatchPing", x, y, z, 120)
end