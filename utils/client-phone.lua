local vRPclient = Tunnel.getInterface("vRP", "utils")
local vRPUtilS = Tunnel.getInterface("utils", "utils")

local vRPUtil = {}
Tunnel.bindInterface("utils", vRPUtil)
Proxy.addInterface("utils", vRPUtil)

local guiEnabled = false

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)

            if guiEnabled then
                DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
                DisableControlAction(0, 2, guiEnabled) -- LookUpDown
                DisableControlAction(0, 15, guiEnabled) -- ScrollUp
                DisableControlAction(0, 14, guiEnabled) -- ScrollDown
                DisableControlAction(0, 16, guiEnabled) -- ScrollUp
                DisableControlAction(0, 17, guiEnabled) -- ScrollDown
                DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate
                DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride
            else
                EnableControlAction(0, 1, true) -- LookLeftRight
                EnableControlAction(0, 2, true) -- LookUpDown
                EnableControlAction(0, 15, true) -- ScrollUp
                EnableControlAction(0, 14, true) -- ScrollDown
                EnableControlAction(0, 16, true) -- ScrollUp
                EnableControlAction(0, 17, true) -- ScrollDown
                EnableControlAction(0, 142, true) -- MeleeAttackAlternate
                EnableControlAction(0, 106, true) -- VehicleMouseControlOverride
            end

            if IsControlJustPressed(0, 170) then
                enableGui(not guiEnabled)
            end

            if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
                SendNUIMessage(
                    {
                        type = "click"
                    }
                )
            end
        end
    end
)

function enableGui(enable)
    guiEnabled = enable
    SetNuiFocus(guiEnabled)
    SendNUIMessage(
        {
            type = "display",
            enable = guiEnabled
        }
    )
end

RegisterNUICallback(
    "escape",
    function(data)
        print("escaped")
        enableGui(false)
    end
)

RegisterNUICallback(
    "clicked",
    function(data)
        print("clicked")
        print(data.id)

        local id = data.id

        if id == "icon-text" then
            print(1)
        elseif id == "icon-phone" then
            print(2)
        elseif id == "icon-contacts" then
            vRPUtilS.getContacts()
        elseif id == "icon-twitter" then
            print(4)
        end
    end
)

function vRPUtil.setContacts(contacts)
    SendNUIMessage(
        {
            type = "contacts",
            contacts = contacts
        }
    )
end

RegisterCommand(
    "test",
    function(source, args, rawCommand)
        vRPUtilS.test()
    end
)
