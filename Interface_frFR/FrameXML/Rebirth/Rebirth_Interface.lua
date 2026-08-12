--[[
    Rebirth_Interface.lua
    UI building and event handlers for the Rebirth interface.

    Adapted from Paragon_Interface.lua. Structural changes versus Paragon:
    - No StaticPopupDialogs (those existed only for the stat add/remove
      amount dialogs, which have no equivalent here).
    - UIParagon_RebuildStatistics (dynamic categories/stats) is replaced by
      UIRebirth_RebuildCategories : 4 Paragon-style category rows (Pierre /
      Pierre Preuve / Héritage / Récompenses), each showing a title box and a
      horizontal row of icon buttons with a pagination arrow to page through
      entries that don't fit in the visible row (Héritage alone has 68
      items). Uses the same frame-recycling-by-unique-name pattern as
      Paragon (by categoryId instead of categoryId_statId for the line, and
      a fixed pool of ICONS_PER_PAGE icon slots per line reused across
      pages). Clicking an unlocked, not-yet-claimed icon calls
      UIRebirth_TriggerEntry immediately — no Apply button, no batching, no
      pending-changes queue.
    - The experience bar code (UIRebirthExperienceBar_*) is carried over
      unchanged, it has nothing to do with stats.
    - The MainMenuBar mini XP bar checkbox (UIRebirth_ShowMainMenuXP_*) is
      carried over unchanged, only the CVar name changed
      (paragonShowMainMenuXP -> rebirthShowMainMenuXP).
    - RebirthCharacterTab_Create ports the CharacterFrame tab, INCLUDING a
      golden notification badge (RebirthCharacterTab_UpdateBadge) -- but
      repurposed : Paragon's badge signalled unspent stat points (a
      persistent condition), whereas this one flags a one-shot event
      (RebirthData.hasNewUnlock, set when a level-up unlocks a new Pierre /
      Pierre Preuve / Recompenses entry), cleared on click or on opening the
      Rebirth panel.
    - Everything tutorial-related (Paragon_Tutorial.lua, StaticPopup help
      overlay, HelpButton) is dropped : the tutorial content was entirely
      about the stat panel and doesn't fit the new category-row paradigm.

    @module Rebirth_Interface
    @author iThorgrim (Paragon) / adapted for Rebirth
]]

-- ============================================================================
-- CVAR REGISTRATION
-- ============================================================================

-- Register custom CVar for the Rebirth MainMenuBar XP mini-bar visibility.
RegisterCVar("rebirthShowMainMenuXP", "0", true)

-- ============================================================================
-- CATEGORY IDS (client-side mirror of Constant.CATEGORIES in
-- rebirth_constant.lua on the server — FrameXML has no require(), so this
-- small table is duplicated here rather than shared).
-- ============================================================================
REBIRTH_CATEGORY = {
    PIERRE = 1,
    PIERRE_PREUVE = 2,
    HERITAGE = 3,
    RECOMPENSES = 4,
}

-- Number of icon slots shown per category row / per page. Must match the
-- number of Icon1..IconN children defined on RebirthCategoryLineTemplate in
-- UIRebirth.xml.
local ICONS_PER_PAGE = 6

-- ============================================================================
-- TOGGLE REBIRTH FRAME
-- ============================================================================

--- Ouvre ou ferme le frame UIRebirth.
function ToggleRebirthFrame()
    if UIRebirth:IsShown() then
        UIRebirth:Hide()
    else
        UIRebirth:Show()
    end
end

-- ============================================================================
-- MAIN FRAME
-- ============================================================================

--- Initializes the main UIRebirth frame on load.
--- @param self Frame The UIRebirth frame being initialized
--- @usage Called automatically by XML OnLoad script
function UIRebirth_OnLoad(self)
    self:SetMovable(true)
    self:EnableMouse(true)
    self:SetClampedToScreen(true)
    self:SetFrameStrata("DIALOG")
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    self:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    self.Locales = GetLocaleTable()

    self.experienceBar = self.TopBanner.ExperienceBar
    self.level = self.TopBanner.Level
    self.body = self.Body

    self.body.TopSpacer.Title:SetText(self.Locales.MAIN_TITLE_TEXT)

    SetPortraitToTexture(self.PortraitFrame.Portrait, "Interface\\Icons\\inv_112_raidtrinkets_netheroverlaymatrix")

    -- Hide the diagonal resize/minimize handle inherited from
    -- PortraitFrame2X/MetalFrame2X (next to the close button) : not wanted
    -- on this interface.
    if self.MaximizeMinimizeButton then
        self.MaximizeMinimizeButton:Hide()
    end

    tinsert(UISpecialFrames, "UIRebirth")

    -- Refresh Héritage/Récompenses names+icons once the client finishes
    -- caching item info it didn't have yet (GetItemInfo returns nil until
    -- then, and fires this event when the data arrives).
    self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    self:SetScript("OnEvent", function(_, event)
        if (event == "GET_ITEM_INFO_RECEIVED" or event == "BAG_UPDATE") and UIRebirth:IsShown() then
            UIRebirth_RebuildCategories()
        end
    end)

    self:RegisterEvent("BAG_UPDATE")

    -- Request initial data from server (Hook ID: 1)
    SendClientRequest("RebirthStone", 1)
end

--- Called when UIRebirth frame is shown.
--- Closes other micro button frames to avoid overlapping.
function UIRebirth_OnShow()
    if CharacterFrame and CharacterFrame:IsShown() then
        HideUIPanel(CharacterFrame)
    end

    if SpellBookFrame and SpellBookFrame:IsShown() then
        HideUIPanel(SpellBookFrame)
    end

    if PlayerTalentFrame and PlayerTalentFrame:IsShown() then
        HideUIPanel(PlayerTalentFrame)
    end

    if AchievementFrame and AchievementFrame:IsShown() then
        HideUIPanel(AchievementFrame)
    end

    if QuestLogFrame and QuestLogFrame:IsShown() then
        HideUIPanel(QuestLogFrame)
    end

    if FriendsFrame and FriendsFrame:IsShown() then
        HideUIPanel(FriendsFrame)
    end

    if PVPParentFrame and PVPParentFrame:IsShown() then
        HideUIPanel(PVPParentFrame)
    end

    if LFDParentFrame and LFDParentFrame:IsShown() then
        HideUIPanel(LFDParentFrame)
    end

    if UpdateMicroButtons then
        UpdateMicroButtons()
    end

    -- Opening the panel acknowledges any pending "new unlock" notification
    -- (golden badge on the CharacterFrame tab).
    RebirthData.hasNewUnlock = false
    if RebirthCharacterTab_UpdateBadge then
        RebirthCharacterTab_UpdateBadge()
    end

    -- Refresh the categories every time the frame is (re)shown, in case the
    -- level changed while it was closed.
    UIRebirth_RebuildCategories()

    -- FIX SYNC : GetItemInfo() for Héritage/Récompenses items can still be
    -- uncached the first time a page is viewed ; the item's icon then shows
    -- the "?" fallback until the client finishes fetching it. The
    -- GET_ITEM_INFO_RECEIVED handler (registered in UIRebirth_OnLoad) should
    -- normally catch this while the panel is open, but isn't guaranteed to
    -- fire for every custom item id on every server, so a few delayed
    -- rebuilds act as a safety net -- cheap (a handful of GetItemInfo calls
    -- for the entries currently on screen), self-contained (only run while
    -- the frame is still shown), and give up after a few seconds.
    if C_Timer and C_Timer.After then
        for _, delay in ipairs({ 1, 2, 4, 7, 12, 20 }) do
            C_Timer.After(delay, function()
                if UIRebirth:IsShown() then
                    UIRebirth_RebuildCategories()
                end
            end)
        end
    end
end

function UIRebirth_OnHide()
    if UpdateMicroButtons then
        UpdateMicroButtons()
    end

    -- Closing the frame while the tutorial is running would otherwise leave
    -- the overlay/highlight/tooltip frames orphaned on screen.
    if Rebirth_RemoveActiveTutorial then
        Rebirth_RemoveActiveTutorial()
    end

    if RebirthCharacterTab_UpdateBadge then
        RebirthCharacterTab_UpdateBadge()
    end
end

-- ============================================================================
-- CATEGORIES UI BUILDING (Paragon-style : title box + icon row + arrow)
-- ============================================================================

--- Resolves the display name / description / icon texture for one entry,
--- depending on which category it belongs to.
--- - Pierre / Pierre Preuve : DB-editable name/icon (entry.name/entry.icon,
---   sent by BuildPierreEntries/BuildProofEntries in rebirth_hook.lua) take
---   priority, falling back to the static locale tables (OPTIONS_INFO /
---   PROOF_INFO) when an admin hasn't overridden them in DB.
--- - Héritage / Récompenses : same DB-editable name/icon priority ; when
---   NOT set in DB (the default, since no such data exists for these custom
---   items), falls back to the live GetItemInfo() lookup exactly as before.
---   Setting an explicit name/icon in DB (rebirth_config_heritage_items /
---   rebirth_config_reward_items) is what permanently eliminates the "?"
---   sync issue for a given item, since the client then never needs
---   GetItemInfo() to resolve it at all.
--- @param categoryId number One of REBIRTH_CATEGORY
--- @param entry table The full entry ({ id, requiredLevel, unlocked, ..., name, icon })
--- @param Locales table The locale table (GetLocaleTable())
--- @return string, string, string name, description, iconPath
local function RebirthEntry_GetDisplay(categoryId, entry, Locales)
    local entryId = entry.id
    local dbName = entry.name
    local dbIcon = entry.icon
    if dbName == "" then dbName = nil end
    if dbIcon == "" then dbIcon = nil end

    if categoryId == REBIRTH_CATEGORY.PIERRE then
        local info = Locales.OPTIONS_INFO[entryId] or {}
        return dbName or info.name or ("Option " .. entryId), info.description or "",
            dbIcon or info.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    elseif categoryId == REBIRTH_CATEGORY.PIERRE_PREUVE then
        local info = Locales.PROOF_INFO[entryId] or {}
        return dbName or info.name or ("Preuve " .. entryId), info.description or "",
            dbIcon or info.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    else
        -- If DB provides BOTH name and icon explicitly, skip GetItemInfo()
        -- entirely -- this is the real, permanent fix for the "?" sync bug
        -- for any item an admin has configured this way.
        if dbName and dbIcon then
            return dbName, "", dbIcon
        end

        local itemName, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(entryId)

        -- FIX : GetItemInfo can return an empty string ("") rather than nil
        -- for name/icon (e.g. item data still uncached, or a malformed
        -- entry). "" is truthy in Lua, so `itemIcon or fallback` alone does
        -- NOT catch it -- SetPortraitToTexture(icon, "") then shows the
        -- WotLK missing-texture (green/black) placeholder instead of the
        -- intended fallback icon. Explicitly treat "" the same as nil.
        if not itemName or itemName == "" then
            itemName = dbName or ("Objet " .. entryId)
        end
        if not itemIcon or itemIcon == "" then
            itemIcon = dbIcon or "Interface\\Icons\\INV_Misc_QuestionMark"
        end

        return itemName, "", itemIcon
    end
end

--- Initializes a category icon slot on load : default icon, hidden name
--- label, animation state. Ported from Paragon's UIParagonStatItem_OnLoad.
--- @param self Button The category icon slot being initialized
--- @usage Called automatically by XML OnLoad script
function RebirthCategoryIcon_OnLoad(self)
    SetPortraitToTexture(self.Icon, "Interface\\Icons\\INV_Misc_QuestionMark")

    self.Description:SetAlpha(0)
    self.descStartY = -48
    self.isAnimating = false
    self.zoomEnabled = false
end

--- Applies one entry's data (locked/unlocked/claimed state, icon, tooltip
--- fields) onto an icon slot button.
--- @param icon Button One of a category line's Icon1..IconN slots
--- @param categoryId number One of REBIRTH_CATEGORY
--- @param entry table { id, requiredLevel, unlocked, claimed }
--- @param Locales table The locale table (GetLocaleTable())
local function RebirthCategoryIcon_SetEntry(icon, categoryId, entry, Locales)
    local name, description, iconPath = RebirthEntry_GetDisplay(categoryId, entry, Locales)

    icon.categoryId = categoryId
    icon.entryId = entry.id
    icon.unlocked = entry.unlocked
    icon.requiredLevel = entry.requiredLevel
    icon.claimed = entry.claimed or false
    icon.claimable = (categoryId == REBIRTH_CATEGORY.HERITAGE or categoryId == REBIRTH_CATEGORY.RECOMPENSES)

    -- Récompenses only : claim counter (claimCount/maxClaims), sent by the
    -- server in BuildRewardEntries (rebirth_hook.lua). Héritage entries never
    -- carry these fields (unlimited, no counter to show).
    icon.claimCount = entry.claimCount
    icon.maxClaims = entry.maxClaims
    icon.title = name
    icon.description = description

    -- Name label shown below the icon on hover (fade animation), separate
    -- from the GameTooltip which keeps showing the fuller description.
    if icon.Description then
        icon.Description:SetText(name)
    end

    SetPortraitToTexture(icon.Icon, iconPath)

    if icon.claimed then
        if icon.LockIcon then icon.LockIcon:Hide() end
        if icon.ClaimedIcon then icon.ClaimedIcon:Show() end
        if icon.Border then icon.Border:SetVertexColor(0.55, 0.55, 0.55, 1) end
    elseif entry.unlocked then
        if icon.LockIcon then icon.LockIcon:Hide() end
        if icon.ClaimedIcon then icon.ClaimedIcon:Hide() end
        if icon.Border then icon.Border:SetVertexColor(1, 1, 1, 1) end
    else
        -- Locked : shown via the red stop-sign LockIcon overlay only (no
        -- SetDesaturated -- see comment above this function).
        if icon.LockIcon then icon.LockIcon:Show() end
        if icon.ClaimedIcon then icon.ClaimedIcon:Hide() end
        if icon.Border then icon.Border:SetVertexColor(1, 1, 1, 1) end
    end

    -- FIX SYNC (tooltip) : this icon's data (claimCount notably) may have
    -- just changed because of a rebuild triggered by the server's refreshed
    -- categories payload after a successful claim (see
    -- OnRebirthClientTriggerEntry / UIRebirth_OnReceiveCategories). If the
    -- player never moved the mouse off this icon after clicking it, the
    -- GameTooltip is still showing whatever text was drawn on the last
    -- OnEnter -- it does not redraw itself just because the underlying data
    -- changed. Re-run OnEnter's tooltip logic here whenever this icon is the
    -- one currently under the tooltip, so the claim counter updates live
    -- instead of only refreshing on the next mouse leave/re-enter.
    if GameTooltip:IsOwned(icon) then
        RebirthCategoryIcon_OnEnter(icon)
    end
end

--- Handles a click on a category icon slot : applies the entry's effect
--- through the server (Pierre buff / Pierre Preuve teleport / Héritage &
--- Récompenses item claim), unless it's locked or already claimed.
--- @param self Button The clicked icon slot
function RebirthCategoryIcon_OnClick(self)
    if not self.entryId then
        return
    end

    if not self.unlocked then
        PlaySound("igPlayerInviteDecline")
        return
    end

    if self.claimed then
        PlaySound("igPlayerInviteDecline")
        return
    end

    UIRebirth_TriggerEntry(self.categoryId, self.entryId)
    PlaySound("igMainMenuOptionCheckBoxOn")
end

--- Shows a tooltip for a category icon slot : name, description, and the
--- locked/unlocked/claimed hint. Also starts the name-label fade-in and
--- icon zoom animations (Rebirth_Animations.lua), exactly like Paragon's
--- stat items did on hover.
--- @param self Button The hovered icon slot
function RebirthCategoryIcon_OnEnter(self)
    if not self.entryId then
        return
    end

    self.animStart = GetTime()
    self.animDuration = 0.3
    self.animType = "in"
    self.isAnimating = true
    self.zoomEnabled = true

    local L = GetLocaleTable()

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.title or "???", 1, 0.82, 0, 1)

    if self.description and self.description ~= "" then
        GameTooltip:AddLine(self.description, 1, 1, 1, 1, true)
    end

    -- Récompenses only : show the claim counter (X/maxClaims) so the player
    -- can see how many claims remain, plus a short explanation that this
    -- category allows repeated claims up to that limit (unlike Héritage,
    -- which stays freely re-claimable, or Pierre/Preuve without any claim
    -- concept at all).
    if self.categoryId == REBIRTH_CATEGORY.RECOMPENSES and self.maxClaims and self.maxClaims > 0 then
        GameTooltip:AddLine(" ")
        local countText = self.claimed and L.ENTRY_REWARD_CLAIM_COUNT_MAXED or L.ENTRY_REWARD_CLAIM_COUNT
        GameTooltip:AddLine(string.format(countText, self.claimCount or 0, self.maxClaims), 1, 0.82, 0)
        GameTooltip:AddLine(L.ENTRY_REWARD_CLAIM_EXPLANATION, 0.8, 0.8, 0.8, true)
    end

    GameTooltip:AddLine(" ")

    if self.claimed then
        GameTooltip:AddLine(L.ENTRY_CLAIMED_HINT, 0.6, 0.6, 0.6)
    elseif self.unlocked then
        GameTooltip:AddLine(self.claimable and L.ENTRY_CLAIM_HINT or L.ENTRY_UNLOCKED_HINT, 0.1, 1, 0.1)
    else
        GameTooltip:AddLine(string.format(L.ENTRY_LOCKED_TOOLTIP, self.requiredLevel or 1), 1, 0.2, 0.2)
    end

    GameTooltip:Show()
end

--- Handles mouse leave on a category icon slot : starts the name-label
--- fade-out / zoom-out animation and hides the tooltip.
--- @param self Button The icon slot being left
function RebirthCategoryIcon_OnLeave(self)
    self.animStart = GetTime()
    self.animDuration = 0.3
    self.animType = "out"
    self.isAnimating = true
    self.zoomEnabled = false

    GameTooltip:Hide()
end

--- Refreshes a category line's visible icon slots for its current page.
--- @param line Frame A category line (RebirthCategoryLineTemplate instance)
local function RebirthCategoryLine_RefreshPage(line)
    local Locales = GetLocaleTable()
    local entries = line.entries or {}
    local maxPage = math.max(1, math.ceil(#entries / ICONS_PER_PAGE))

    if line.page > maxPage then
        line.page = maxPage
    end

    local startIndex = (line.page - 1) * ICONS_PER_PAGE

    if line.PageText then
        -- FIX : force le positionnement en Lua plutot que de compter sur
        -- l'ancre XML (relativeTo="$parentArrow") -- signale par
        -- l'utilisateur comme ne prenant pas effet en jeu malgre un XML
        -- correct. SetPoint explicite ici elimine toute ambiguite de
        -- resolution d'ancre : le compteur est garanti juste a droite de la
        -- fleche, quel que soit l'ordre de resolution XML sur ce client.
        if line.Arrow then
            line.PageText:ClearAllPoints()
            line.PageText:SetPoint("LEFT", line.Arrow, "RIGHT", 8, 0)
        end

        if maxPage > 1 then
            line.PageText:Show()
            line.PageText:SetText(string.format("%d/%d", line.page, maxPage))
        else
            line.PageText:Hide()
        end
    end

    if line.Arrow then
        if maxPage > 1 then
            line.Arrow:Show()
        else
            line.Arrow:Hide()
        end
    end

    for i = 1, ICONS_PER_PAGE do
        local slot = line.Icons and line.Icons[i]
        if slot then
            local entry = entries[startIndex + i]
            if entry then
                RebirthCategoryIcon_SetEntry(slot, line.categoryId, entry, Locales)
                slot:Show()
            else
                slot:Hide()
            end
        end
    end
end

--- Handles a click on a category line's pagination arrow : advances to the
--- next page of entries, wrapping back to page 1 after the last one.
--- @param self Button The Arrow button (child of a category line)
function RebirthCategoryArrow_OnClick(self)
    local line = self:GetParent()
    if not line or not line.entries then
        return
    end

    local maxPage = math.max(1, math.ceil(#line.entries / ICONS_PER_PAGE))
    if maxPage <= 1 then
        return
    end

    line.page = (line.page % maxPage) + 1
    RebirthCategoryLine_RefreshPage(line)
    PlaySound("igMainMenuOptionCheckBoxOn")
end

--- Shows a small tooltip on the pagination arrow.
--- @param self Button The Arrow button (child of a category line)
function RebirthCategoryArrow_OnEnter(self)
    local L = GetLocaleTable()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L.ENTRY_NEXT_PAGE_HINT or "Page suivante", 1, 0.82, 0, 1)
    GameTooltip:Show()
end

--- Launches the full interactive tutorial (Rebirth_Tutorial.lua), exactly
--- like Paragon's HelpButton did (UIParagon_ShowTutorial). Content was
--- rewritten to describe the 4-category Rebirth interface instead of
--- Paragon's stat panel.
--- @param self Button The HelpButton (child of UIRebirth, below CloseButton)
function RebirthHelpButton_OnClick(self)
    Rebirth_TutorialStart()
end

--- Shows a short hint on hover ; the actual walkthrough opens on click.
--- @param self Button The HelpButton (child of UIRebirth, below CloseButton)
function RebirthHelpButton_OnEnter(self)
    local L = GetLocaleTable()
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText(L.HELP_TOOLTIP_TITLE or "Aide", 1, 0.82, 0, 1)
    GameTooltip:AddLine(L.HELP_TOOLTIP_TEXT or "", 1, 1, 1, 1, true)
    GameTooltip:Show()
end

--- Rebuilds the 4 Paragon-style category rows from RebirthData.categories.
--- Implements the same frame-recycling system as Paragon's
--- UIParagon_RebuildStatistics : line frames are created once (keyed by
--- categoryId) and reused on every subsequent rebuild, and each line's
--- ICONS_PER_PAGE icon slots are static XML children reused across pages
--- instead of being created/destroyed per click.
--- @usage Called by Rebirth_Network.lua whenever the categories data or the
---   level changes, and every time UIRebirth is shown.
function UIRebirth_RebuildCategories()
    if not UIRebirth or not UIRebirth.Body then
        return
    end

    local categoriesList = UIRebirth.Body.CategoriesList
    if not categoriesList then
        return
    end

    local Locales = GetLocaleTable()
    local yOffset = 0

    for _, category in ipairs(RebirthData.categories) do
        local categoryId = category.categoryId
        local lineName = "RebirthCategory_" .. categoryId
        local line = _G[lineName]

        if not line then
            line = CreateFrame("Frame", lineName, categoriesList, "RebirthCategoryLineTemplate")
            line:SetPoint("TOP", 0, yOffset)
            line.page = 1
            line.Icons = { line.Icon1, line.Icon2, line.Icon3, line.Icon4, line.Icon5, line.Icon6 }
        end

        line:Show()
        line.categoryId = categoryId

        line.entries = category.entries or {}
        table.sort(line.entries, function(a, b) return a.id < b.id end)

        local categoryName = (Locales.CATEGORY_NAMES and Locales.CATEGORY_NAMES[categoryId])
            or ("Catégorie " .. categoryId)
        if line.Title and line.Title.Text then
            line.Title.Text:SetText(categoryName)
        end

        RebirthCategoryLine_RefreshPage(line)

        yOffset = yOffset - 105
    end
end

-- ============================================================================
-- EXPERIENCE BAR
-- ============================================================================

--- Initializes the experience bar on load.
--- @param self Frame The experience bar frame
--- @usage Called automatically by XML OnLoad script
function UIRebirthExperienceBar_OnLoad(self)
    self.statusbar = self.StatusBar
    self.hover_text = self.OverlayFrame.HoverText
    self.text = self.OverlayFrame.Text

    self.hover_text:SetAlpha(0)
    self.hover_text:SetText("")
    self.text:SetAlpha(1)
    self.text:SetText("0%")

    self.hoverStartY = 5
    self.textY = 3
    self.isAnimating = false

    self.Locales = GetLocaleTable()

    self.currentXP = 0
    self.maxXP = 50

    self.hover_text:ClearAllPoints()
    self.hover_text:SetPoint("CENTER", 0, self.hoverStartY)
end

--- OnShow handler for experience bar (unused, required by XML OnShow script).
--- @param self Frame The experience bar frame
function UIRebirthExperienceBar_OnShow(self)
    -- Currently unused
end

--- Sets the experience bar values and updates the display.
--- @param self Frame The experience bar frame
--- @param current number Current XP amount
--- @param max number Maximum XP amount (default: 50)
--- @usage Called by UIRebirth_OnClientReceiveXP from the network layer
function UIRebirthExperienceBar_SetExperience(self, current, max)
    self.currentXP = current or 0
    self.maxXP = max or 50

    local percentage = self.maxXP > 0 and (self.currentXP / self.maxXP) or 0

    self.statusbar:SetMinMaxValues(0, self.maxXP)
    self.statusbar:SetValue(self.currentXP)

    self.text:SetText(string.format("%d%%", percentage * 100))
    self.hover_text:SetText(string.format(self.Locales.EXPERIENCE_TEXT, self.currentXP, self.maxXP))
end

--- Handles mouse enter event on experience bar : starts the cross-fade
--- animation from percentage to detailed XP display.
--- @param self Frame The experience bar frame
function UIRebirthExperienceBar_OnEnter(self)
    self.animStart = GetTime()
    self.animDuration = 0.3
    self.animType = "in"
    self.isAnimating = true
end

--- Handles mouse leave event on experience bar : starts the cross-fade
--- animation back to the percentage display.
--- @param self Frame The experience bar frame
function UIRebirthExperienceBar_OnLeave(self)
    self.animStart = GetTime()
    self.animDuration = 0.3
    self.animType = "out"
    self.isAnimating = true
end

-- ============================================================================
-- SHOW MAINMENU XP CHECKBOX
-- ============================================================================

--- Initializes the checkbox for showing the Rebirth XP mini-bar on the
--- MainMenuBar. Sets the initial state from the CVar and configures the
--- label.
--- @param self CheckButton The checkbox frame
function UIRebirth_ShowMainMenuXP_OnLoad(self)
    local cvarValue = GetCVar("rebirthShowMainMenuXP")
    if (cvarValue == nil) then
        SetCVar("rebirthShowMainMenuXP", "0")
        cvarValue = "0"
    end

    local isEnabled = (cvarValue == "1")
    self:SetChecked(isEnabled)

    local Locales = GetLocaleTable()
    self.Text:SetText(Locales.SHOW_MAINMENU_XP_LABEL or "Show XP bar on main interface")

    UIRebirth_UpdateMainMenuXPVisibility()
end

--- Handle checkbox click event : toggles RebirthExpBar's visibility.
--- @param self CheckButton The checkbox frame
function UIRebirth_ShowMainMenuXP_OnClick(self)
    local isChecked = self:GetChecked()

    SetCVar("rebirthShowMainMenuXP", isChecked and "1" or "0")

    UIRebirth_UpdateMainMenuXPVisibility()

    if isChecked then
        PlaySound("igMainMenuOptionCheckBoxOn")
    else
        PlaySound("igMainMenuOptionCheckBoxOff")
    end
end

--- Handle checkbox hover event : shows tooltip with description.
--- @param self CheckButton The checkbox frame
function UIRebirth_ShowMainMenuXP_OnEnter(self)
    local Locales = GetLocaleTable()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(Locales.SHOW_MAINMENU_XP_LABEL or "Show XP bar on main interface", 1, 1, 1)
    GameTooltip:AddLine(Locales.SHOW_MAINMENU_XP_TOOLTIP or "If checked, displays the Rebirth experience bar above your character's XP bar at the bottom of the screen.", nil, nil, nil, true)
    GameTooltip:Show()
end

--- Updates RebirthExpBar's visibility based on the checkbox/CVar state.
function UIRebirth_UpdateMainMenuXPVisibility()
    if not RebirthExpBar then return end

    local cvarValue = GetCVar("rebirthShowMainMenuXP")
    if (cvarValue == nil) then
        SetCVar("rebirthShowMainMenuXP", "0")
        cvarValue = "0"
    end

    local isEnabled = (cvarValue == "1")

    if isEnabled then
        RebirthExpBar_Update()
    else
        RebirthExpBar:Hide()
    end
end

-- ============================================================================
-- ONGLET REBIRTH DANS LE CHARACTERFRAME
-- ============================================================================
-- Cree un onglet "Rebirth" dans le CharacterFrame vanilla (comme Personnage/
-- Rep./Comp.). S'accroche automatiquement apres le dernier onglet existant.
-- Contrairement a la version precedente de ce fichier, un badge de
-- notification dore EST cree ici (ported from Paragon's
-- ParagonCharacterTab_Create) : Rebirth n'a pas de "points non distribues",
-- mais le badge est repurpose pour signaler qu'un level-up vient de
-- debloquer une nouvelle entree Pierre / Pierre Preuve / Recompenses (voir
-- RebirthData.hasNewUnlock, mis a jour par UIRebirth_OnClientReceiveLevel
-- dans Rebirth_Network.lua).
-- ============================================================================

local function RebirthCharacterTab_Create()
    if not CharacterFrame then return end
    if _G["CharacterFrameTab_Rebirth"] then return end

    -- Compter les onglets existants (CharacterFrameTab1, Tab2, Tab3...)
    local tabIndex = 1
    while _G["CharacterFrameTab"..tabIndex] do
        tabIndex = tabIndex + 1
    end

    -- ID hors plage (99) : ignore par PanelTemplates_SetNumTabs, qui ne
    -- traite que les IDs 1..numTabs du systeme vanilla.
    local tab = CreateFrame("Button", "CharacterFrameTab_Rebirth", CharacterFrame, "CharacterFrameTabButtonTemplate")
    tab:SetID(99)
    tab:SetText("Rebirth")

    PanelTemplates_DeselectTab(tab)

    local prevTab = _G["CharacterFrameTab"..(tabIndex - 1)]
    if prevTab then
        tab:SetPoint("LEFT", prevTab, "RIGHT", -3, 0)
    else
        tab:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMLEFT", 50, -31)
    end

    tab:SetScript("OnClick", function()
        PlaySound("igCharacterInfoTab")
        HideUIPanel(CharacterFrame)
        ToggleRebirthFrame()
    end)

    tab:SetScript("OnEnter", function(self)
        local L = GetLocaleTable and GetLocaleTable() or {}
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.REBIRTH_TAB_TOOLTIP or "Rebirth", 1, 0.82, 0, 1)
        GameTooltip:AddLine(L.REBIRTH_TAB_DESC or "Consultez vos options de Rebirth.", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    tab:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    tab:Show()

    -- -------------------------------------------------------------------
    -- Badge de notification doree sur l'onglet (nouveau deblocage Rebirth)
    -- Parente a UIParent, meme texture que le MicroButton Notification,
    -- ported from Paragon's ParagonCharacterTab_Create -- seule la
    -- CONDITION d'affichage change (RebirthData.hasNewUnlock au lieu de
    -- ParagonData.availablePoints > 0).
    -- -------------------------------------------------------------------

    local badge = CreateFrame("Button", "CharacterFrameTab_RebirthBadge", UIParent)
    badge:SetSize(18, 18)
    badge:SetFrameStrata("HIGH")
    badge:SetFrameLevel(100)
    badge:SetPoint("TOPLEFT", tab, "TOPRIGHT", -20, 8)
    badge.dismissed = false

    local bg = badge:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up")
    bg:SetAllPoints(badge)
    badge.Bg = bg

    local glow = badge:CreateTexture(nil, "OVERLAY")
    glow:SetTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up")
    glow:SetBlendMode("ADD")
    glow:SetAlpha(0.8)
    glow:SetSize(22, 22)
    glow:SetPoint("CENTER", badge, "CENTER", 0, 0)
    badge.Glow = glow

    badge:SetScript("OnUpdate", function(self, elapsed)
        self.pulseTimer = (self.pulseTimer or 0) + elapsed
        local alpha = 0.5 + math.sin(self.pulseTimer * 3) * 0.3
        self.Glow:SetAlpha(alpha)
    end)

    badge:SetScript("OnClick", function(self)
        self.dismissed = true
        RebirthData.hasNewUnlock = false
        self:Hide()
        PlaySound("igMainMenuOptionCheckBoxOn")
    end)

    badge:SetScript("OnEnter", function(self)
        local L = GetLocaleTable and GetLocaleTable() or {}
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.REBIRTH_NOTIFICATION_TITLE or "Nouveau déblocage Rebirth !", 1, 0.82, 0, 1)
        GameTooltip:AddLine(L.REBIRTH_NOTIFICATION_MESSAGE or "Une nouvelle Amélioration, Preuve du Rebirth ou Récompense est disponible !", 1, 1, 1, 1, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L.REBIRTH_NOTIFICATION_DISMISS or "Cliquer pour masquer cette notification.", 0.5, 0.5, 0.5, 1)
        GameTooltip:Show()
    end)
    badge:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    badge:Hide()
    tab.NotificationBadge = badge

    -- Frame de polling toujours active : verifie chaque seconde si les
    -- conditions sont reunies pour afficher le badge (nouveau deblocage +
    -- pas encore rejete + panneau Rebirth ferme + onglet visible).
    local poller = CreateFrame("Frame", "CharacterFrameTab_RebirthPoller", UIParent)
    poller.timer = 0
    poller:SetScript("OnUpdate", function(self, elapsed)
        self.timer = self.timer + elapsed
        if self.timer < 1.0 then return end
        self.timer = 0

        local hasNewUnlock = RebirthData and RebirthData.hasNewUnlock
        local uiClosed = not (UIRebirth and UIRebirth:IsShown())
        local tabVisible = tab:IsVisible()

        if hasNewUnlock and not badge.dismissed and uiClosed and tabVisible then
            badge:ClearAllPoints()
            badge:SetPoint("TOPLEFT", tab, "TOPRIGHT", -20, 8)
            badge:Show()
        else
            badge:Hide()
        end
    end)
end

-- ============================================================================
-- Badge de notification sur l'onglet Rebirth : mise a jour globale
-- ============================================================================

--- Met a jour la visibilite du badge de notification sur l'onglet Rebirth.
-- Calque sur ParagonCharacterTab_UpdateBadge(). Appele des qu'un evenement
-- pertinent survient (level-up, ouverture/fermeture du panneau) plutot que
-- d'attendre le prochain tick du poller, pour une reaction immediate.
function RebirthCharacterTab_UpdateBadge()
    local tab = _G["CharacterFrameTab_Rebirth"]
    if not tab or not tab.NotificationBadge then return end

    local badge = tab.NotificationBadge
    local hasNewUnlock = RebirthData and RebirthData.hasNewUnlock
    local uiClosed = not (UIRebirth and UIRebirth:IsShown())
    local tabVisible = tab:IsVisible()

    if hasNewUnlock and not badge.dismissed and uiClosed and tabVisible then
        badge:ClearAllPoints()
        badge:SetPoint("TOPLEFT", tab, "TOPRIGHT", -20, 8)
        badge:Show()
    else
        badge:Hide()
    end
end

-- ============================================================================
-- Visibilite de l'onglet Rebirth : uniquement sur Tab1 (Personnage)
-- ============================================================================

local function RebirthTab_UpdateVisibility()
    local tab = _G["CharacterFrameTab_Rebirth"]
    if not tab then return end

    local selected = PanelTemplates_GetSelectedTab(CharacterFrame)
    if selected == 1 then
        tab:Show()
    else
        tab:Hide()
    end

    if RebirthCharacterTab_UpdateBadge then
        RebirthCharacterTab_UpdateBadge()
    end
end

-- Creer l'onglet au login (CharacterFrame est garanti charge a ce stade)
local _rebirthTabLoader = CreateFrame("Frame")
_rebirthTabLoader:RegisterEvent("PLAYER_LOGIN")
_rebirthTabLoader:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        RebirthCharacterTab_Create()

        hooksecurefunc("CharacterFrameTab_OnClick", function()
            RebirthTab_UpdateVisibility()
        end)

        hooksecurefunc(CharacterFrame, "Show", function()
            RebirthTab_UpdateVisibility()
        end)

        -- Immediate badge refresh on close : tab:IsVisible() above already
        -- makes the underlying condition correct, but without this hook the
        -- badge would linger up to 1 second (the poller's tick rate) after
        -- closing the character sheet.
        hooksecurefunc(CharacterFrame, "Hide", function()
            if RebirthCharacterTab_UpdateBadge then
                RebirthCharacterTab_UpdateBadge()
            end
        end)

        self:UnregisterAllEvents()
    end
end)
