local guiEnabled = false

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)
            if guiEnabled then
                DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
                DisableControlAction(0, 2, guiEnabled) -- LookUpDown
                DisableControlAction(0, 24, guiEnabled) -- Attack
                DisableControlAction(0, 15, guiEnabled) -- ScrollUp
                DisableControlAction(0, 14, guiEnabled) -- ScrollDown
                DisableControlAction(0, 16, guiEnabled) -- ScrollUp
                DisableControlAction(0, 17, guiEnabled) -- ScrollDown
                DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate
                DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride
            else
                EnableControlAction(0, 1, true) -- LookLeftRight
                EnableControlAction(0, 2, true) -- LookUpDown
                EnableControlAction(0, 24, true) -- Attack
                EnableControlAction(0, 15, true) -- ScrollUp
                EnableControlAction(0, 14, true) -- ScrollDown
                EnableControlAction(0, 16, true) -- ScrollUp
                EnableControlAction(0, 17, true) -- ScrollDown
                EnableControlAction(0, 142, true) -- MeleeAttackAlternate
                EnableControlAction(0, 106, true) -- VehicleMouseControlOverride
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

function enableBankGui(enable, name, loans, cash, bank)
    guiEnabled = enable
    SetNuiFocus(guiEnabled)
    SendNUIMessage(
        {
            type = "display",
            enable = guiEnabled,
            name = name,
            loans = loans,
            cash = cash,
            bank = bank
        }
    )
end

RegisterNUICallback(
    "escape",
    function(data)
        enableBankGui(false)
    end
)

RegisterNUICallback(
    "clicked",
    function(data)
        return
    end
)

RegisterNUICallback(
    "onPressed",
    function(data)
        local payCurrentAmount      = "payCurrentAmount"
        local payTotalAmount        = "payTotalAmount"
        print("Event onPressed fired. Data:", data.loanID, data.loan, data.htmlID, data.value)

        if htmlID == payCurrentAmount then -- Pays the current weekly due
            TriggerServerEvent("jobs:paybackWeekly", data.loanID, data.loan)
        elseif htmlID == payTotalAmount then -- Pays the desired amount off the total debt (Pays off total debt before attempting to payoff amount)
            TriggerServerEvent("jobs:paybackTotal", data.loanID, data.loan, data.value)
        end
    end
)

RegisterNetEvent("jobs:enableWindow")
AddEventHandler(
    "jobs:enableWindow",
    function(enabled, name, loans, cash, bank)
        print("testing2")
        enableBankGui(enabled, name, loans, cash, bank)
    end
)
