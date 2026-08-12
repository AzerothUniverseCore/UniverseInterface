--[[
    Rebirth_Tutorial.lua
    Interactive tutorial system for the Rebirth interface.

    Ported from Paragon_Tutorial.lua practically verbatim (overlay/highlight/
    tooltip frame construction, pulsing highlight animation, step navigation,
    smart tooltip positioning) : only the 6 step definitions were rewritten to
    describe the Rebirth interface (help button, level, XP bar, the 4
    category rows, icon interaction, pagination) instead of Paragon's stat
    panel (which no longer exists in this project).

    Compatible with WoW 3.3.5 API (2008-2010 era).

    @module Rebirth_Tutorial
    @author iThorgrim (Paragon) / adapted for Rebirth
]]

-- ============================================================================
-- TUTORIAL STATE
-- ============================================================================

--- Tutorial state management.
-- @field active boolean Whether the tutorial is currently running
-- @field currentStep number Current step index (1-based)
-- @field steps table Array of tutorial step definitions
local TutorialState = {
    active = false,
    currentStep = 1,
    steps = {}
}

-- ============================================================================
-- TUTORIAL STEP DEFINITIONS
-- ============================================================================

--- Defines all tutorial steps with their targets and text keys.
--- Each step highlights a specific UIRebirth element and shows an
--- explanation. Steps 5/6 target the first category row ("Pierre",
--- RebirthCategory_1) which is only created after the first
--- UIRebirth_RebuildCategories() call -- Rebirth_TutorialShowStep already
--- skips gracefully to the next step if the target frame doesn't exist yet.
--- @return table Array of step definitions
local function GetTutorialSteps()
    return {
        -- Step 1: Help Button
        {
            frame = function() return UIRebirth.HelpButton end,
            textKey = "TUTORIAL_HELP_BUTTON",
            position = "CENTER",
            xOffset = 0,
            yOffset = -110
        },

        -- Step 2: Level Display
        {
            frame = function() return UIRebirth.TopBanner.Level end,
            textKey = "TUTORIAL_LEVEL",
            position = "RIGHT",
            xOffset = 250,
            yOffset = -150
        },

        -- Step 3: Experience Bar
        {
            frame = function() return UIRebirth.TopBanner.ExperienceBar end,
            textKey = "TUTORIAL_XP_BAR",
            position = "BOTTOM",
            xOffset = 0,
            yOffset = -210
        },

        -- Step 4: Categories Section (title area)
        {
            frame = function() return UIRebirth.Body.TopSpacer.Title end,
            textKey = "TUTORIAL_CATEGORIES",
            position = "RIGHT",
            xOffset = 150,
            yOffset = -110
        },

        -- Step 5: Icon interaction -- highlights ALL 4 category rows
        -- together (the whole CategoriesList container), not just "Pierre",
        -- since the explanation (click an unlocked icon) applies identically
        -- across every category.
        {
            frame = function() return UIRebirth.Body and UIRebirth.Body.CategoriesList end,
            textKey = "TUTORIAL_ICONS",
            position = "TOP",
            xOffset = 0,
            yOffset = -150
        },

        -- Step 6: Pagination -- highlights the WHOLE first category row's
        -- block (title + icons + arrow together), exactly like Paragon's own
        -- final step targeted its whole StatisticsList rather than a single
        -- isolated control ; previously this only glowed around the tiny
        -- arrow button, disconnected from the icons it pages through.
        {
            frame = function() return _G["RebirthCategory_1"] end,
            textKey = "TUTORIAL_PAGINATION",
            position = "RIGHT",
            xOffset = 30,
            yOffset = 0
        }
    }
end

-- ============================================================================
-- TUTORIAL UI FRAMES
-- ============================================================================

--- Creates the tutorial overlay frame.
--- Invisible frame that blocks interactions during the tutorial.
--- @return Frame The overlay frame
local function CreateTutorialOverlay()
    local overlay = CreateFrame("Frame", "RebirthTutorialOverlay", UIRebirth)
    overlay:SetFrameStrata("FULLSCREEN_DIALOG")
    overlay:SetFrameLevel(100)
    overlay:SetAllPoints(UIRebirth)
    overlay:EnableMouse(true)
    overlay:EnableMouseWheel(true)
    overlay:Hide()

    -- No background texture - we'll use alpha manipulation instead

    return overlay
end

--- Creates the highlight frame around a UI element.
--- Uses OnUpdate-based animation compatible with WoW 3.3.5.
--- @return Frame The highlight frame
local function CreateTutorialHighlight()
    local highlight = CreateFrame("Frame", "RebirthTutorialHighlight", UIParent)
    highlight:SetFrameStrata("FULLSCREEN_DIALOG")
    highlight:SetFrameLevel(101)
    highlight:Hide()

    -- Glowing border effect
    local border = highlight:CreateTexture(nil, "OVERLAY")
    border:SetAllPoints()
    border:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
    border:SetBlendMode("ADD")
    border:SetVertexColor(1, 0.82, 0, 0.8)
    highlight.border = border

    -- Animation state (using OnUpdate instead of AnimationGroup)
    highlight.pulseAlpha = 0.5
    highlight.pulseDirection = 1 -- 1 = increasing, -1 = decreasing
    highlight.pulseSpeed = 1.0   -- Duration for full cycle

    -- OnUpdate handler for pulsing animation
    highlight:SetScript("OnUpdate", function(self, elapsed)
        if not self:IsShown() then return end

        local alphaChange = elapsed / self.pulseSpeed
        self.pulseAlpha = self.pulseAlpha + (alphaChange * self.pulseDirection)

        if self.pulseAlpha >= 1.0 then
            self.pulseAlpha = 1.0
            self.pulseDirection = -1
        elseif self.pulseAlpha <= 0.5 then
            self.pulseAlpha = 0.5
            self.pulseDirection = 1
        end

        self.border:SetVertexColor(1, 0.82, 0, self.pulseAlpha)
    end)

    return highlight
end

--- Creates the tutorial tooltip frame.
--- Displays step-by-step instructions and navigation buttons.
--- @return Frame The tooltip frame
local function CreateTutorialTooltip()
    local tooltip = CreateFrame("Frame", "RebirthTutorialTooltip", UIParent)
    tooltip:SetFrameStrata("FULLSCREEN_DIALOG")
    tooltip:SetFrameLevel(102)
    tooltip:SetSize(420, 180)
    tooltip:Hide()

    tooltip:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    tooltip:SetBackdropColor(0.05, 0.05, 0.1, 1)
    tooltip:SetBackdropBorderColor(0.90, 0.80, 0.50, 1)

    local title = tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetTextColor(1, 0.82, 0)
    tooltip.Title = title

    -- Divider line
    local divider = tooltip:CreateTexture(nil, "ARTWORK")
    divider:SetPoint("TOPLEFT", 12, -38)
    divider:SetPoint("TOPRIGHT", -12, -38)
    divider:SetHeight(1)
    divider:SetTexture(1, 1, 1, 0.1)

    -- Description text
    local description = tooltip:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    description:SetPoint("TOPLEFT", 16, -48)
    description:SetPoint("TOPRIGHT", -16, -48)
    description:SetJustifyH("LEFT")
    description:SetJustifyV("TOP")
    description:SetSpacing(3)
    tooltip.Description = description

    -- Step counter with icon
    local stepIcon = tooltip:CreateTexture(nil, "OVERLAY")
    stepIcon:SetSize(16, 16)
    stepIcon:SetPoint("BOTTOMLEFT", 15, 42)
    stepIcon:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")

    local stepCounter = tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    stepCounter:SetPoint("LEFT", stepIcon, "RIGHT", 5, 0)
    stepCounter:SetTextColor(0.9, 0.85, 0.6)
    tooltip.StepCounter = stepCounter

    -- Button separator line
    local buttonDivider = tooltip:CreateTexture(nil, "ARTWORK")
    buttonDivider:SetPoint("BOTTOMLEFT", 12, 38)
    buttonDivider:SetPoint("BOTTOMRIGHT", -12, 38)
    buttonDivider:SetHeight(1)
    buttonDivider:SetTexture(1, 1, 1, 0.1)

    -- Previous button
    local prevButton = CreateFrame("Button", nil, tooltip, "UIPanelButtonTemplate")
    prevButton:SetSize(110, 24)
    prevButton:SetPoint("BOTTOMLEFT", 15, 8)
    prevButton:SetScript("OnClick", function() Rebirth_TutorialPrevious() end)
    tooltip.PrevButton = prevButton

    -- Next button (styled differently when it's "Finish")
    local nextButton = CreateFrame("Button", nil, tooltip, "UIPanelButtonTemplate")
    nextButton:SetSize(110, 24)
    nextButton:SetPoint("BOTTOM", 0, 8)
    nextButton:SetScript("OnClick", function() Rebirth_TutorialNext() end)
    tooltip.NextButton = nextButton

    -- Close button
    local closeButton = CreateFrame("Button", nil, tooltip, "UIPanelButtonTemplate")
    closeButton:SetSize(110, 24)
    closeButton:SetPoint("BOTTOMRIGHT", -15, 8)
    closeButton:SetScript("OnClick", function() Rebirth_TutorialEnd() end)
    tooltip.CloseButton = closeButton

    return tooltip
end

-- ============================================================================
-- ALPHA MANAGEMENT FUNCTIONS
-- ============================================================================

--- Restores original alpha values for all UIRebirth elements touched by the
--- tutorial.
local function RestoreUIRebirthAlpha()
    for _, data in pairs(GetTutorialSteps()) do
        local frame = data.frame()
        if frame then
            frame:SetAlpha(1)
        end
    end
end

-- ============================================================================
-- TUTORIAL CONTROL FUNCTIONS
-- ============================================================================

--- Starts the tutorial sequence.
--- Creates UI elements if needed and shows the first step.
function Rebirth_TutorialStart()
    if TutorialState.active then return end

    if not RebirthTutorialOverlay then
        CreateTutorialOverlay()
    end
    if not RebirthTutorialHighlight then
        CreateTutorialHighlight()
    end
    if not RebirthTutorialTooltip then
        CreateTutorialTooltip()
    end

    TutorialState.active = true
    TutorialState.currentStep = 1
    TutorialState.steps = GetTutorialSteps()

    RebirthTutorialOverlay:Show()

    for _, data in pairs(GetTutorialSteps()) do
        local frame = data.frame()
        if frame then
            frame:SetAlpha(0.5)
        end
    end

    Rebirth_TutorialShowStep(1)
end

--- Ends the tutorial and hides all UI elements.
function Rebirth_TutorialEnd()
    if not TutorialState.active then return end

    TutorialState.active = false
    TutorialState.currentStep = 1

    RestoreUIRebirthAlpha()

    if RebirthTutorialOverlay then RebirthTutorialOverlay:Hide() end
    if RebirthTutorialHighlight then RebirthTutorialHighlight:Hide() end
    if RebirthTutorialTooltip then RebirthTutorialTooltip:Hide() end
end

--- Advances to the next tutorial step.
function Rebirth_TutorialNext()
    if not TutorialState.active then return end

    local nextStep = TutorialState.currentStep + 1
    if nextStep > #TutorialState.steps then
        Rebirth_TutorialEnd()
        return
    end

    Rebirth_TutorialShowStep(nextStep)
end

--- Goes back to the previous tutorial step.
function Rebirth_TutorialPrevious()
    if not TutorialState.active then return end

    local prevStep = TutorialState.currentStep - 1
    if prevStep < 1 then return end

    Rebirth_TutorialShowStep(prevStep)
end

--- Shows a specific tutorial step.
--- @param stepIndex number The step index to show (1-based)
function Rebirth_TutorialShowStep(stepIndex)
    if not TutorialState.active then return end
    if stepIndex < 1 or stepIndex > #TutorialState.steps then return end

    local L = GetLocaleTable()
    local step = TutorialState.steps[stepIndex]
    TutorialState.currentStep = stepIndex

    local targetFrame = step.frame()
    if not targetFrame then
        -- Frame doesn't exist yet (e.g. categories not built yet) : skip.
        Rebirth_TutorialNext()
        return
    end

    for index, data in pairs(GetTutorialSteps()) do
        local frame = data.frame()
        if frame then
            if index == stepIndex then
                frame:SetAlpha(1)
            else
                frame:SetAlpha(0.5)
            end
        end
    end

    RebirthTutorialHighlight:ClearAllPoints()
    RebirthTutorialHighlight:SetPoint("TOPLEFT", targetFrame, "TOPLEFT", -5, 5)
    RebirthTutorialHighlight:SetPoint("BOTTOMRIGHT", targetFrame, "BOTTOMRIGHT", 5, -5)
    RebirthTutorialHighlight:Show()

    RebirthTutorialTooltip:SetSize(420, 180)

    RebirthTutorialTooltip.Title:SetText(L.TUTORIAL_TITLE or "Aide - Interface Rebirth")
    RebirthTutorialTooltip.Description:SetText(L[step.textKey] or "Description manquante")
    RebirthTutorialTooltip.StepCounter:SetText(string.format(
        L.TUTORIAL_STEP_COUNTER or "Étape %d/%d",
        stepIndex,
        #TutorialState.steps
    ))

    if stepIndex > 1 then
        RebirthTutorialTooltip.PrevButton:Enable()
    else
        RebirthTutorialTooltip.PrevButton:Disable()
    end
    RebirthTutorialTooltip.PrevButton:SetText(L.TUTORIAL_BUTTON_PREVIOUS or "Précédent")

    if stepIndex == #TutorialState.steps then
        RebirthTutorialTooltip.NextButton:SetText(L.TUTORIAL_BUTTON_FINISH or "Terminer")
    else
        RebirthTutorialTooltip.NextButton:SetText(L.TUTORIAL_BUTTON_NEXT or "Suivant")
    end

    RebirthTutorialTooltip.CloseButton:SetText(L.TUTORIAL_BUTTON_CLOSE or "Fermer")

    -- Smart positioning of tooltip relative to the highlighted frame
    RebirthTutorialTooltip:ClearAllPoints()

    local position = step.position or "BOTTOM"
    local xOffset = step.xOffset or 0
    local yOffset = step.yOffset or -15

    local anchorMap = {
        ["TOP"] = "BOTTOM",
        ["BOTTOM"] = "TOP",
        ["LEFT"] = "RIGHT",
        ["RIGHT"] = "LEFT",
        ["TOPLEFT"] = "BOTTOMRIGHT",
        ["TOPRIGHT"] = "BOTTOMLEFT",
        ["BOTTOMLEFT"] = "TOPRIGHT",
        ["BOTTOMRIGHT"] = "TOPLEFT"
    }

    local targetAnchor = anchorMap[position] or position

    RebirthTutorialTooltip:SetPoint(position, targetFrame, targetAnchor, xOffset, yOffset)
    RebirthTutorialTooltip:Show()

    -- Ensure the tooltip stays within UIRebirth's bounds (not screen bounds)
    local rebirthLeft = UIRebirth:GetLeft()
    local rebirthRight = UIRebirth:GetRight()
    local rebirthTop = UIRebirth:GetTop()
    local rebirthBottom = UIRebirth:GetBottom()

    local tooltipLeft = RebirthTutorialTooltip:GetLeft()
    local tooltipRight = RebirthTutorialTooltip:GetRight()
    local tooltipTop = RebirthTutorialTooltip:GetTop()
    local tooltipBottom = RebirthTutorialTooltip:GetBottom()

    if tooltipLeft and rebirthLeft and tooltipLeft < rebirthLeft then
        local adjustment = rebirthLeft - tooltipLeft + 10
        RebirthTutorialTooltip:ClearAllPoints()
        RebirthTutorialTooltip:SetPoint(position, targetFrame, targetAnchor, xOffset + adjustment, yOffset)
    elseif tooltipRight and rebirthRight and tooltipRight > rebirthRight then
        local adjustment = rebirthRight - tooltipRight - 10
        RebirthTutorialTooltip:ClearAllPoints()
        RebirthTutorialTooltip:SetPoint(position, targetFrame, targetAnchor, xOffset + adjustment, yOffset)
    end

    if tooltipTop and rebirthTop and tooltipTop > rebirthTop then
        local adjustment = rebirthTop - tooltipTop - 10
        RebirthTutorialTooltip:ClearAllPoints()
        RebirthTutorialTooltip:SetPoint(position, targetFrame, targetAnchor, xOffset, yOffset + adjustment)
    elseif tooltipBottom and rebirthBottom and tooltipBottom < rebirthBottom then
        local adjustment = rebirthBottom - tooltipBottom + 10
        RebirthTutorialTooltip:ClearAllPoints()
        RebirthTutorialTooltip:SetPoint(position, targetFrame, targetAnchor, xOffset, yOffset + adjustment)
    end
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

--- Checks if the tutorial is currently active.
--- @return boolean True if the tutorial is running
function Rebirth_IsTutorialActive()
    return TutorialState.active
end

--- Ends the tutorial if it's active. Called from UIRebirth_OnHide so closing
--- the frame while the tutorial is running doesn't leave orphaned overlay/
--- highlight/tooltip frames on screen.
function Rebirth_RemoveActiveTutorial()
    if Rebirth_IsTutorialActive() then
        Rebirth_TutorialEnd()
    end
end
