--[[
    Rebirth_Network.lua
    Server communication and data management for the Rebirth interface.

    Adapted from Paragon_Network.lua : PendingChanges (batched stat edits),
    availablePoints and every stat-modification function are entirely
    removed — Rebirth has nothing to batch, an entry's effect is applied
    immediately server-side the moment it is clicked. Response id 3 ("all
    data") now carries the 4 Paragon-style category rows (Pierre / Pierre
    Preuve / Héritage / Récompenses), each an array of
    { id, requiredLevel, unlocked, claimed } entries, instead of stat
    categories — and response ids 4/5 (points/statistic) simply don't exist
    anymore on this protocol. Hook ID 6 (target level) is kept as-is.

    @module Rebirth_Network
    @author iThorgrim (Paragon) / adapted for Rebirth
]]

--- Global data store for the Rebirth interface.
-- Updated by server responses, read by Rebirth_Interface.lua.
-- @table RebirthData
-- @field level number Current account Rebirth level
-- @field experience number Current experience within the level
-- @field experienceMax number Experience required for the next level
-- @field categories table Array of { categoryId, entries = { {id, requiredLevel, unlocked, claimed}, ... } } (Hook ID 3)
RebirthData = {
    level = 1,
    experience = 0,
    experienceMax = 50,
    categories = {},
    -- previousLevel / hasNewUnlock : power the golden notification badge on
    -- the CharacterFrame Rebirth tab (RebirthCharacterTab_Create in
    -- Rebirth_Interface.lua). Unlike Paragon's badge (unspent stat points,
    -- a persistent condition), Rebirth has no points to distribute -- so
    -- this badge is repurposed to flag that a level-up just unlocked a new
    -- Pierre / Pierre Preuve / Recompenses entry, and is cleared once the
    -- player opens the Rebirth panel or dismisses the badge directly.
    previousLevel = nil,
    hasNewUnlock = false,
}

-- ============================================================================
-- ADDON REGISTRATION
-- ============================================================================

--- Addon registration table for server communication.
-- @table Addon
-- @field Prefix string Protocol identifier used by the server ("RebirthStone")
-- @field Functions table Map of response id -> function name
local Addon = {
    Prefix = "RebirthStone",
    Functions = {
        [1] = "UIRebirth_OnClientReceiveLevel",     -- Receive account Rebirth level update
        [2] = "UIRebirth_OnClientReceiveXP",        -- Receive XP bar update
        [3] = "UIRebirth_OnReceiveCategories",       -- Receive the 4 category rows (locked/unlocked/claimed)
        [6] = "UIRebirth_OnReceiveTargetLevel",      -- Receive target's Rebirth level
    }
}

RegisterServerResponses(Addon)

-- ============================================================================
-- SERVER RECEIVE FUNCTIONS
-- ============================================================================

--- Handles account Rebirth level update from server (Hook ID: 1).
--- @param player table Unused (provided by the addon framework)
--- @param arg_table table Arguments from server: {level}
function UIRebirth_OnClientReceiveLevel(player, arg_table)
    local level = arg_table[1]

    -- A real level-up (level increased since the last value we knew about)
    -- means new Pierre/Pierre Preuve/Recompenses entries may just have
    -- unlocked -- flag it for the CharacterFrame tab's golden badge. Ignore
    -- the very first value received after login (previousLevel == nil) :
    -- that's just the initial sync, not a level-up.
    if RebirthData.previousLevel and level > RebirthData.previousLevel then
        RebirthData.hasNewUnlock = true
    end
    RebirthData.previousLevel = level

    RebirthData.level = level

    if RebirthCharacterLevel and RebirthCharacterLevel.Text then
        RebirthCharacterLevel.Text:SetText(level)
    end

    if UIRebirth and UIRebirth.TopBanner and UIRebirth.TopBanner.Level then
        UIRebirth.TopBanner.Level.Text:SetText(level)
    end

    -- Locked/unlocked state depends on the level, refresh the categories so
    -- a level-up immediately shows newly unlocked entries.
    if UIRebirth and UIRebirth:IsShown() then
        UIRebirth_RebuildCategories()
    end

    if RebirthCharacterTab_UpdateBadge then
        RebirthCharacterTab_UpdateBadge()
    end
end

--- Handles experience update from server (Hook ID: 2).
--- @param player table Unused
--- @param arg_table table Arguments from server: {currentXP, maxXP}
function UIRebirth_OnClientReceiveXP(player, arg_table)
    local currentXP = arg_table[1]
    local maxXP = arg_table[2]

    RebirthData.experience = currentXP
    RebirthData.experienceMax = maxXP

    if UIRebirth and UIRebirth.TopBanner and UIRebirth.TopBanner.ExperienceBar then
        UIRebirthExperienceBar_SetExperience(UIRebirth.TopBanner.ExperienceBar, currentXP, maxXP)
        RebirthExpBar_SetExperience(currentXP, maxXP)
    end
end

--- Handles the 4 category rows from server (Hook ID: 3) : replaces Paragon's
--- category/stat "all data" payload entirely.
--- @param player table Unused
--- @param arg_table table Arguments from server: { { {categoryId, entries={...}}, ... } }
function UIRebirth_OnReceiveCategories(player, arg_table)
    RebirthData.categories = arg_table[1] or {}
    UIRebirth_RebuildCategories()
end

---
--- Handles target Rebirth level update from server (Hook ID: 6).
--- @param player table Unused
--- @param arg_table table Arguments from server: {level}
---
function UIRebirth_OnReceiveTargetLevel(player, arg_table)
    local level = arg_table[1]

    if not RebirthTargetLevel then
        return
    end

    -- If level is 0 or nil, hide visually (target is not a player or has no
    -- Rebirth data yet).
    if not level or level <= 0 then
        RebirthTargetLevel:SetAlpha(0)
        return
    end

    RebirthTargetLevel.Text:SetText(level)
    RebirthTargetLevel:SetAlpha(1)
end

-- ============================================================================
-- CLIENT -> SERVER : ENTRY TRIGGER
-- ============================================================================

--- Requests the server to apply the clicked entry's effect, in any of the 4
--- categories (Pierre buff, Pierre Preuve teleport, Héritage/Récompenses item
--- claim). Replaces Paragon's batched UIParagon_SendPendingChanges entirely :
--- there is nothing to batch, the effect is applied immediately server-side.
--- @param categoryId number One of Constant.CATEGORIES from rebirth_constant.lua
--- @param entryId number The clicked entry's id (option id / proof id / item id)
--- @usage Called when the player clicks an unlocked icon in a category row
function UIRebirth_TriggerEntry(categoryId, entryId)
    if not categoryId or not entryId then
        return
    end

    -- IMPORTANT : SendClientRequest(prefix, id, ...) is VARIADIC (see
    -- CMH.lua's ProcessVariables/ParseMessage) -- each argument becomes its
    -- own slot in the server's arg_table. Passing a single wrapping table
    -- here ({ categoryId, entryId }) would serialize as ONE table argument,
    -- landing entirely in arg_table[1] and leaving arg_table[2] nil server
    -- side -- silently failing OnRebirthClientTriggerEntry's guard clause
    -- (this was the exact bug reported : clicking any icon did nothing).
    SendClientRequest(Addon.Prefix, 2, categoryId, entryId)
end
