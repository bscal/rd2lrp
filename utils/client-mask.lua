-- glasses
local glassesOn = false
local currentGlasses = nil
local myGlasses = nil
local sgTexture = nil
local glassesSet = false
local noGlasses = false
-- hats
local hatsTexture = nil
local hatsOn = false
local currentHats = nil
local myHats = nil
local hatsSet = false
local noHats = false
-- masks
local masksTexture = nil
local masksOn = false
local currentMasks = nil
local mymasks = nil
local masksSet = false
local nomasks = false

RegisterNetEvent("sung")
AddEventHandler(
    "sung",
    function()
        --[[
Sets variables for if sunglasses are on and which sunglasses they are
]] --
        local player = GetPlayerPed(-1)
        local currentGlasses = GetPedPropIndex(player, 1)
        if currentGlasses == -1 and glassesSet == false then
            noGlasses = true
            glassesSet = false
        elseif currentGlasses ~= -1 and glassesSet == false then
            myGlasses = GetPedPropIndex(player, 1)
            sgTexture = GetPedPropTextureIndex(player, 1)
            noGlasses = false
            glassesSet = true
            glassesOn = true
        elseif currentGlasses == -1 and glassesSet == true then
            glassesOn = false
        elseif glassesSet == true and currentGlasses ~= -1 and myGlasses ~= currentGlasses then
            myGlasses = GetPedPropIndex(player, 1)
            sgTexture = GetPedPropTextureIndex(player, 1)
            glassesSet = true
            noGlasses = false
            glassesOn = true
        end

        --Takes Glasses off / Puts them On
        if not noGlasses then
            glassesOn = not glassesOn
            if glassesOn then
                SetPedPropIndex(player, 1, myGlasses, sgTexture, 2)
                ShowNotification("Sunglasses are on")
            else
                ClearPedProp(player, 1)
                ShowNotification("Sunglasses are off")
            end
        else
            ShowNotification("You are not wearing sunglasses")
        end
    end,
    false
)

--Adding hats here

RegisterNetEvent("hats")
AddEventHandler(
    "hats",
    function()
        --[[
Sets variables for if hat is on and which hat it is
]] --
        local player = GetPlayerPed(-1)
        local currentHats = GetPedPropIndex(player, 0)
        if currentHats == -1 and hatsSet == false then
            noHats = true
            hatsSet = false
        elseif currentHats ~= -1 and hatsSet == false then
            myHats = GetPedPropIndex(player, 0)
            hatsTexture = GetPedPropTextureIndex(player, 0)
            noHats = false
            hatsSet = true
            hatsOn = true
        elseif currentHats == -1 and hatsSet == true then
            hatsOn = false
        elseif hatsSet == true and currentHats ~= -1 and myHats ~= currentHats then
            myHats = GetPedPropIndex(player, 0)
            hatsTexture = GetPedPropTextureIndex(player, 0)
            hatsSet = true
            noHats = false
            hatsOn = true
        end

        --Takes hat off / Puts it On
        if not noHats then
            hatsOn = not hatsOn
            if hatsOn then
                SetPedPropIndex(player, 0, myHats, hatsTexture, 2)
                ShowNotification("Hat is on")
            else
                ClearPedProp(player, 0)
                ShowNotification("Hat is off")
            end
        else
            ShowNotification("You are not wearing a hat")
        end
    end,
    false
)

---------------------

RegisterNetEvent("mask")
AddEventHandler(
    "mask",
    function()
        --[[
Sets variables for if sunglasses are on and which sunglasses they are
]] --
        local player = GetPlayerPed(-1)
        local currentmasks = GetPedDrawableVariation(player, 1)
        if currentmasks == -1 and masksSet == false then
            nomasks = true
            masksSet = false
        elseif currentmasks ~= -1 and masksSet == false then
            mymasks = GetPedDrawableVariation(player, 1)
            masksTexture = GetPedTextureVariation(player, 1)
            nomasks = false
            masksSet = true
            masksOn = true
        elseif currentmasks == -1 and masksSet == true then
            masksOn = false
        elseif masksSet == true and currentMasks ~= -1 and myMasks ~= currentMasks then
            mymasks = GetPedDrawableVariation(player, 1)
            masksTexture = GetPedTextureVariation(player, 1)
            masksSet = true
            nomasks = false
            masksOn = true
        end

        --Takes masks off / Puts them On
        if not nomasks then
            masksOn = not masksOn
            if masksOn then
                SetPedComponentVariation(player, 1, mymasks, masksTexture, 2)
                ShowNotification("Masks are on")
            else
                SetPedComponentVariation(player, 1)
                ShowNotification("Masks are off")
            end
        else
            ShowNotification("You are not wearing a mask")
        end
    end,
    false
)

RegisterCommand(
    "hat",
    function()
        TriggerEvent("hats")
    end
)

RegisterCommand(
    "sg",
    function()
        TriggerEvent("sung")
    end
)

RegisterCommand(
    "mask",
    function()
        TriggerEvent("mask")
    end
)
--Function to show the notification

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end
