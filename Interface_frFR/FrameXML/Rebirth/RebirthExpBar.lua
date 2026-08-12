--[[
    RebirthExpBar.lua
    MainMenuBar size : 1024 x 53

    Verbatim rename of ParagonExpBar.lua : the mini experience bar shown
    above (or below, at max character level) the native XP bar on the
    MainMenuBar. CVar renamed rebirthShowMainMenuXP.
]]

RebirthExpData = {
    currentXP = 0,
    maxXP = 50
}

local BAR_OFFSET_LEFT  = 275
local BAR_OFFSET_RIGHT = -275
local BAR_HEIGHT       = 7
local BAR_OFFSET_Y     = -40

function RebirthExpBar_OnLoad(self)
    self:RegisterEvent("UNIT_LEVEL")
    self.textLocked = false
    if RebirthExpBarOverlayFrameText then
        RebirthExpBarOverlayFrameText:Hide()
    end
    RebirthExpBar_Update()
end

function RebirthExpBar_OnEvent(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        RebirthExpBar_Update()
    elseif (event == "PLAYER_LEVEL_UP") then
        RebirthExpBar_Update()
    elseif (event == "UNIT_LEVEL") then
        -- Fired when a unit's level changes (arg1 = unitId)
        local unitId = ...
        if (unitId == "player") then
            RebirthExpBar_Update()
        end
    elseif (event == "UPDATE_FACTION") then
        RebirthExpBar_UpdatePosition()
    end
end

function RebirthExpBar_UpdatePosition()
    if (not RebirthExpBar) then return end

    RebirthExpBar:ClearAllPoints()

    -- Character level 80 : the native purple XP bar is hidden, reposition
    -- exactly where it would have been (same logic as ParagonExpBar).
    local isMaxLevel = (UnitLevel("player") >= 80)

    if (ReputationWatchBar and ReputationWatchBar:IsShown()) then
        RebirthExpBar:SetPoint("BOTTOMLEFT",  "ReputationWatchBar", "TOPLEFT",  0, 2)
        RebirthExpBar:SetPoint("BOTTOMRIGHT", "ReputationWatchBar", "TOPRIGHT", 0, 2)
    elseif isMaxLevel then
        if (MainMenuExpBar) then
            RebirthExpBar:SetPoint("BOTTOMLEFT",  "MainMenuExpBar", "BOTTOMLEFT",  0, 0)
            RebirthExpBar:SetPoint("BOTTOMRIGHT", "MainMenuExpBar", "BOTTOMRIGHT", 0, 0)
        else
            RebirthExpBar:SetPoint("BOTTOMLEFT",  "MainMenuBar", "TOPLEFT",  BAR_OFFSET_LEFT,  -33)
            RebirthExpBar:SetPoint("BOTTOMRIGHT", "MainMenuBar", "TOPRIGHT", BAR_OFFSET_RIGHT, -33)
        end
    else
        RebirthExpBar:SetPoint("BOTTOMLEFT",  "MainMenuBar", "TOPLEFT",  BAR_OFFSET_LEFT,  BAR_OFFSET_Y)
        RebirthExpBar:SetPoint("BOTTOMRIGHT", "MainMenuBar", "TOPRIGHT", BAR_OFFSET_RIGHT, BAR_OFFSET_Y)
    end

    RebirthExpBar:SetHeight(BAR_HEIGHT)

    if RebirthExpBar.overlayFrame then
        RebirthExpBar.overlayFrame:SetFrameLevel(RebirthExpBar:GetFrameLevel() + 500)
    end
end

function RebirthExpBar_Update()
    if (not RebirthExpBar or not RebirthExpBar.StatusBar) then return end

    local currentXP = RebirthExpData.currentXP
    local maxXP = RebirthExpData.maxXP

    RebirthExpBar.StatusBar:SetMinMaxValues(0, maxXP)
    RebirthExpBar.StatusBar:SetValue(currentXP)

    RebirthExpBar_UpdateText()
    RebirthExpBar_UpdatePosition()

    local cvarValue = GetCVar("rebirthShowMainMenuXP")
    if (cvarValue == nil) then
        SetCVar("rebirthShowMainMenuXP", "1")
        cvarValue = "1"
    end

    if (cvarValue == "1") then
        RebirthExpBar:Show()
    else
        if (RebirthExpBar:IsShown()) then
            RebirthExpBar:Hide()
        end
    end
end

function RebirthExpBar_UpdateText()
    if (not RebirthExpBarOverlayFrameText) then return end

    local currentXP = RebirthExpData.currentXP
    local maxXP = RebirthExpData.maxXP

    local Locales = GetLocaleTable()
    local experienceText = Locales and Locales.REBIRTH_EXPERIENCE_TEXT or "Rebirth %d / %d (%d%%)"

    local percentage = 0
    if (maxXP > 0) then
        percentage = math.floor((currentXP / maxXP) * 100)
    end

    RebirthExpBarOverlayFrameText:SetText(string.format(experienceText, currentXP, maxXP, percentage))
end

function RebirthExpBar_SetExperience(current, max)
    RebirthExpData.currentXP = current or 0
    RebirthExpData.maxXP = max or 50
    RebirthExpBar_Update()
end

function ShowRebirthExpBarText(lock)
    if (not RebirthExpBar) then return end
    if (lock) then RebirthExpBar.textLocked = true end
    if (RebirthExpBarOverlayFrameText) then
        RebirthExpBarOverlayFrameText:Show()
    end
end

function HideRebirthExpBarText(unlock)
    if (not RebirthExpBar) then return end
    if (unlock) then RebirthExpBar.textLocked = false end
    if (RebirthExpBarOverlayFrameText and not RebirthExpBar.textLocked) then
        RebirthExpBarOverlayFrameText:Hide()
    end
end
