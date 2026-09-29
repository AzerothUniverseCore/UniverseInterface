--[[
    EditorMode

    Copyright (c) Dmitriy. All rights reserved.
    Licensed under the MIT license. See LICENSE file in the project root for details.
]]

local RUI = LibStub('AceAddon-3.0'):GetAddon('PortraitFrameUI')
local moduleName = 'EditorMode'
local Module = RUI:NewModule(moduleName, 'AceConsole-3.0')

local EDITABLE_MODULES = { 'UnitFrame', 'CastingBar' }

local GRID_SPACING = 64
local GRID_LINE_ALPHA = 0.12
local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"

local panel
local capture

local function ForEachEditableModule(callback)
    for _, name in ipairs(EDITABLE_MODULES) do
        local mod = RUI:GetModule(name, true)
        if mod then
            callback(mod)
        end
    end
end

local function CreateCapture()
    capture = CreateFrame("Frame", "RUIEditModeCapture", UIParent)
    capture:SetAllPoints(UIParent)
    capture:SetFrameStrata("FULLSCREEN")
    capture:SetFrameLevel(1)
    capture:EnableMouse(true)
    capture:Hide()

    local tint = capture:CreateTexture(nil, "BACKGROUND")
    tint:SetAllPoints(capture)
    tint:SetTexture(0, 0, 0, 0.25)

    local width, height = UIParent:GetWidth(), UIParent:GetHeight()

    local x = 0
    while x <= width do
        local line = capture:CreateTexture(nil, "BORDER")
        line:SetTexture(WHITE_TEXTURE)
        line:SetVertexColor(1, 1, 1, GRID_LINE_ALPHA)
        line:SetPoint("TOPLEFT", capture, "TOPLEFT", x, 0)
        line:SetSize(1, height)
        x = x + GRID_SPACING
    end

    local y = 0
    while y <= height do
        local line = capture:CreateTexture(nil, "BORDER")
        line:SetTexture(WHITE_TEXTURE)
        line:SetVertexColor(1, 1, 1, GRID_LINE_ALPHA)
        line:SetPoint("TOPLEFT", capture, "TOPLEFT", 0, -y)
        line:SetSize(width, 1)
        y = y + GRID_SPACING
    end
end

local function CreatePanel()
    panel = CreateFrame("Frame", "RUIEditorModePanel", UIParent)
    panel:SetSize(280, 150)
    panel:SetPoint("TOP", UIParent, "TOP", 0, -140)
    panel:SetFrameStrata("FULLSCREEN")
    panel:SetFrameLevel(200)
    panel:SetToplevel(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)

    panel:Hide()

    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", panel, "TOP", 0, -16)
    title:SetText("Edit Mode")

    local hint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    hint:SetPoint("TOP", title, "BOTTOM", 0, -10)
    hint:SetWidth(248)
    hint:SetNonSpaceWrap(true)
    hint:SetJustifyH("CENTER")
    hint:SetJustifyV("TOP")
    hint:SetText("Drag the highlighted frames to move them. Positions are saved automatically.")

    local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetButton:SetSize(120, 24)
    resetButton:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
    resetButton:SetText("Reset Positions")
    resetButton:SetScript("OnClick", function()
        ForEachEditableModule(function(mod)
            if mod.LoadDefaultSettings then mod:LoadDefaultSettings() end
            if mod.UpdateWidgets then mod:UpdateWidgets() end
        end)
    end)

    local doneButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    doneButton:SetSize(120, 24)
    doneButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)
    doneButton:SetText("Done")
    doneButton:SetScript("OnClick", function()
        Module:Hide()
    end)

    panel:SetScript("OnShow", function()
        ForEachEditableModule(function(mod)
            if mod.ShowEditorTest then mod:ShowEditorTest() end
        end)
    end)

    panel:SetScript("OnHide", function()
        ForEachEditableModule(function(mod)
            if mod.HideEditorTest then mod:HideEditorTest(true) end
        end)
        if capture then
            capture:Hide()
        end
        Module.active = false
    end)

    tinsert(UISpecialFrames, "RUIEditorModePanel")
end

function Module:OnInitialize()
    self.active = false
end

function Module:IsShown()
    return self.active == true
end

function Module:Show()
    if self.active then
        return
    end
    self.active = true

    if not capture then
        CreateCapture()
    end
    if not panel then
        CreatePanel()
    end

    capture:Show()
    panel:Show()
end

function Module:Hide()
    if not self.active then
        return
    end

    if panel then
        panel:Hide()
    end
end

if GameMenuFrame and GameMenuButtonUIOptions and GameMenuButtonKeybindings then
    local menuButton = CreateFrame("Button", "RUIGameMenuEditModeButton", GameMenuFrame, "GameMenuButtonTemplate")
    menuButton:SetText("Edit Mode")
    menuButton:SetPoint("TOP", GameMenuButtonUIOptions, "BOTTOM", 0, -1)
    menuButton:SetScript("OnClick", function()
        PlaySound("igMainMenuOption")

        if Module:IsShown() then
            Module:Hide()
        else
            Module:Show()
        end

        HideUIPanel(GameMenuFrame)
    end)

    GameMenuButtonKeybindings:ClearAllPoints()
    GameMenuButtonKeybindings:SetPoint("TOP", menuButton, "BOTTOM", 0, -1)

    local GAME_MENU_BOTTOM_MARGIN = 16

    local function FitGameMenuFrameToContinueButton()
        if not GameMenuButtonContinue then
            return
        end

        local frameBottom = GameMenuFrame:GetBottom()
        local continueBottom = GameMenuButtonContinue:GetBottom()
        if not frameBottom or not continueBottom then
            return
        end

        local margin = continueBottom - frameBottom
        if margin < GAME_MENU_BOTTOM_MARGIN then
            GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + (GAME_MENU_BOTTOM_MARGIN - margin) * 2)
        end
    end

    GameMenuFrame:HookScript("OnShow", FitGameMenuFrameToContinueButton)
end
