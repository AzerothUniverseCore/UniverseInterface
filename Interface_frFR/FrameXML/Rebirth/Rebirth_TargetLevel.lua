--[[
    Rebirth_TargetLevel.lua
    Client-side module for displaying the target's Rebirth level.

    Verbatim rename of Paragon_TargetLevel.lua : displays the Rebirth level
    of the player's current target next to the target portrait. Only shows
    when targeting another player.

    @module Rebirth_TargetLevel
    @author iThorgrim (Paragon) / adapted for Rebirth
]]

-- ============================================================================
-- TARGET CHANGE DETECTION
-- ============================================================================

---
--- Requests target's Rebirth level from server when target changes.
--- Called automatically by the OnUpdate handler.
---
local function RequestTargetRebirthLevel()
    -- Check if player has a target
    if not UnitExists("target") then
        if RebirthTargetLevel then
            RebirthTargetLevel:SetAlpha(0)
        end
        return
    end

    -- Check if target is a player
    if not UnitIsPlayer("target") then
        if RebirthTargetLevel then
            RebirthTargetLevel:SetAlpha(0)
        end
        return
    end

    -- Request target's Rebirth level from server (Hook ID 6, see rebirth_target_level.lua)
    SendClientRequest("RebirthStone", 6)
end

---
--- OnUpdate handler for RebirthTargetLevel frame.
--- Detects target changes and requests a level update.
--- @param self Frame The RebirthTargetLevel frame
--- @param elapsed number Time since last update
---
function RebirthTargetLevel_OnUpdate(self, elapsed)
    local currentTargetGUID = UnitGUID("target")
    if currentTargetGUID ~= self.lastTargetGUID then
        self.lastTargetGUID = currentTargetGUID
        RequestTargetRebirthLevel()
    end
end

---
--- OnLoad handler for RebirthTargetLevel frame.
--- @param self Frame The RebirthTargetLevel frame
---
function RebirthTargetLevel_OnLoad(self)
    self.lastTargetGUID = nil
    self:SetAlpha(0)
end

function RebirthTargetLevel_OnHide(self)
    self.lastTargetGUID = nil
end
