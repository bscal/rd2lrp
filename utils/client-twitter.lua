vRPclient = Tunnel.getInterface("vRP", "utils")
vRPUtilS = Tunnel.getInterface("utils", "utils")

vRPUtil = {}
Tunnel.bindInterface("utils", vRPUtil)
Proxy.addInterface("utils", vRPUtil)

RegisterCommand(
    "twt",
    function(source, args, rawCommand)
        local str = ""
        for k, v in pairs(args) do
            str = str .. " " .. v
        end
        vRPUtilS.sendTweet(str)
    end
)

RegisterCommand(
    "ad",
    function(source, args, rawCommand)
        if (vRPUtilS.hasAdMoney()) then
            local str = ""
            for k, v in pairs(args) do
                str = str .. " " .. tostring(v)
            end
            vRPUtilS.sendAd(str)
        end
    end
)

RegisterCommand(
    "adlist",
    function(source, args, rawCommand)
        vRPUtilS.sendRecentAds()
    end
)

function vRPUtil.printTweet(name, msg)
    TriggerEvent(
        "chat:addMessage",
        {
            color = {0, 175, 255},
            multiline = false,
            args = {"Twitter", name .. msg}
        }
    )
end

function vRPUtil.printAd(msg)
    TriggerEvent(
        "chat:addMessage",
        {
            color = {255, 0, 30},
            multiline = true,
            args = {"AD", msg}
        }
    )
end
