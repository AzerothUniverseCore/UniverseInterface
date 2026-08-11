--[[
    Rebirth_Animations.lua
    Animation system for the Rebirth UI.

    Adapted from Paragon_Animations.lua : the experience bar hover cross-fade
    animation is kept unchanged. The stat-item description/zoom animations
    are ALSO kept (re-added), now driving the category icon slots' name label
    (fades in below the icon on hover) and a slight zoom-on-hover effect,
    exactly like Paragon's ParagonStatItemTemplate did for its stat icons.

    @module Rebirth_Animations
    @author iThorgrim (Paragon) / adapted for Rebirth
]]

-- ============================================================================
-- EXPERIENCE BAR ANIMATIONS
-- ============================================================================

--- Animates text swap on the experience bar during hover.
--- Handles smooth cross-fade between the percentage text and the detailed
--- current/max text, with vertical movement, exactly like Paragon's.
--- @param self Frame The experience bar frame
--- @usage Called automatically from the OnUpdate hook in UIRebirth.xml
function UIRebirthExperienceBar_AnimateTextSwap(self)
    if not self.isAnimating then return end

    local elapsed = GetTime() - self.animStart
    local progress = math.min(elapsed / self.animDuration, 1)

    if self.animType == "in" then
        if progress < 0.4 then
            self.text:SetAlpha(1 - (progress * 2.5))
        else
            self.text:SetAlpha(0)
        end

        if progress > 0.4 then
            local adjustedProgress = (progress - 0.4) / 0.6
            self.hover_text:SetAlpha(adjustedProgress)
            self.hover_text:ClearAllPoints()

            local offsetY = self.hoverStartY + (15 * adjustedProgress)
            self.hover_text:SetPoint("CENTER", 0, offsetY)
        end
    else
        if progress > 0.6 then
            local adjustedProgress = (progress - 0.6) / 0.4
            self.text:SetAlpha(adjustedProgress)
        else
            self.text:SetAlpha(0)
        end

        if progress < 0.6 then
            local adjustedProgress = progress / 0.6
            self.hover_text:SetAlpha(1 - adjustedProgress)
            self.hover_text:ClearAllPoints()

            local offsetY = (self.hoverStartY + 15) - (15 * adjustedProgress)
            self.hover_text:SetPoint("CENTER", 0, offsetY)
        else
            self.hover_text:SetAlpha(0)
        end
    end

    if progress >= 1 then
        self.isAnimating = false
        if self.animType == "in" then
            self.hover_text:SetAlpha(1)
            self.text:SetAlpha(0)
        else
            self.hover_text:SetAlpha(0)
            self.text:SetAlpha(1)
        end
    end
end


-- ============================================================================
-- CATEGORY ICON ANIMATIONS
-- ============================================================================

--- Animates a category icon's name label (below the icon) with fade and
--- movement. Ported from Paragon's UIParagonStatItem_AnimateDescription,
--- same easing, just renamed.
--- @param self Button The category icon slot
--- @usage Called automatically from the OnUpdate hook in UIRebirth.xml
function RebirthCategoryIcon_AnimateDescription(self)
    if not self.isAnimating then return end

    local elapsed = GetTime() - self.animStart
    local progress = math.min(elapsed / self.animDuration, 1)

    if self.animType == "in" then
        self.Description:SetAlpha(progress)
        self.Description:ClearAllPoints()

        local offsetY = self.descStartY - (10 * progress)
        self.Description:SetPoint("TOP", 0, offsetY)
    else
        self.Description:SetAlpha(1 - progress)
        self.Description:ClearAllPoints()

        local offsetY = (self.descStartY - 10) + (10 * progress)
        self.Description:SetPoint("TOP", 0, offsetY)
    end

    if progress >= 1 then
        self.isAnimating = false
        if self.animType == "in" then
            self.Description:SetAlpha(1)
        else
            self.Description:SetAlpha(0)
        end
    end
end

--- Animates a category icon's zoom effect on hover. Ported from Paragon's
--- UIParagonStatItem_AnimateZoom, rescaled for this project's 46px icon
--- slots (Paragon used 55px stat items with a 42x41 inner icon texture).
--- @param self Button The category icon slot
--- @usage Called automatically from the OnUpdate hook in UIRebirth.xml
function RebirthCategoryIcon_AnimateZoom(self)
    self.currentZoom = self.currentZoom or 0

    local targetZoom = self.zoomEnabled and 1.0 or 0.0
    local zoomSpeed = 0.2

    if math.abs(self.currentZoom - targetZoom) > 0.01 then
        self.currentZoom = self.currentZoom + (targetZoom - self.currentZoom) * zoomSpeed
    else
        self.currentZoom = targetZoom
    end

    local zoomAmount = 1.15
    local scaleMultiplier = 1 + (self.currentZoom * (zoomAmount - 1))

    if not self.originalXOffset then
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1)
        self.originalXOffset = xOfs or 0
        self.originalYOffset = yOfs or 0
        self.originalPoint = point
        self.originalRelativeTo = relativeTo
        self.originalRelativePoint = relativePoint
    end

    local baseSize = 46
    local newSize = baseSize * scaleMultiplier
    local sizeDiff = newSize - baseSize
    local offsetX = self.originalXOffset - (sizeDiff / 2)
    local offsetY = self.originalYOffset + (sizeDiff / 2)

    self:ClearAllPoints()
    self:SetPoint(self.originalPoint, self.originalRelativeTo, self.originalRelativePoint, offsetX, offsetY)
    self:SetSize(newSize, newSize)

    if self.Icon then
        self.Icon:SetSize(36 * scaleMultiplier, 36 * scaleMultiplier)
    end
end
