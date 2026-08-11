-- Collection_Compat.lua
-- Minimal polyfill required by the Collection system ported from Sirus
-- (Mounts / Pets / Toys / Heirlooms / Wardrobe) for the Azeroth Universe
-- client. Must be loaded AFTER SharedXML\EventHandler.lua and
-- SharedXML\CallbackRegistry.lua, BEFORE Custom_Collections\Custom_Collections.xml.

-- ============================================================
-- 1) EventRegistry (equivalent of Sirus's SharedXML\GlobalCallbackRegistry.lua).
--    Universe already has CallbackRegistryMixin (SharedXML\CallbackRegistry.lua)
--    with OnLoad / SetUndefinedEventsAllowed / RegisterCallback / TriggerEvent /
--    UnregisterCallback / UnregisterEvents / GenerateCallbackEvents: sufficient
--    for everything the Collection system actually uses.
-- ============================================================
DIAGv26_CP13 = true;
if not EventRegistry then
	EventRegistry = CreateFromMixins(CallbackRegistryMixin)

	function EventRegistry:OnLoad()
		CallbackRegistryMixin.OnLoad(self)
		self:SetUndefinedEventsAllowed(true)

		self.frameEventFrame = CreateFrame("Frame")
		self.frameEventFrame:SetScript("OnEvent", function(frameEventFrame, event, ...)
			self:TriggerEvent(event, ...)
		end)
	end

	EventRegistry:OnLoad()
end

-- ============================================================
-- 2) RegisterCustomEvent / UnregisterCustomEvent
--    Present in Sirus's version of SharedXML\EventHandler.lua, absent from
--    the (older) version already used by Azeroth Universe.
--    IMPORTANT: the Collection system calls them using method syntax
--    (self:RegisterCustomEvent(...)), not as global functions. A simple
--    global function of the same name is NOT ENOUGH: Lua resolves
--    self:Method(...) through the object's metatable, not through a lookup
--    in globals. We therefore add them directly to the shared Frame
--    metatable (same technique as SharedXML\SharedExtendedMethods.lua,
--    which already does "function Frame.__index:SetShown(...) ... end").
-- ============================================================
DIAGv26_CP41 = true;
REGISTERED_CUSTOM_EVENTS = REGISTERED_CUSTOM_EVENTS or {}

local CollectionCompat_FrameMeta = getmetatable(CreateFrame("Frame"))

if not CollectionCompat_FrameMeta.__index.RegisterCustomEvent then
	function CollectionCompat_FrameMeta.__index:RegisterCustomEvent(event)
		if not REGISTERED_CUSTOM_EVENTS[event] then
			REGISTERED_CUSTOM_EVENTS[event] = {}
		end
		REGISTERED_CUSTOM_EVENTS[event][self] = true
	end
end

if not CollectionCompat_FrameMeta.__index.UnregisterCustomEvent then
	function CollectionCompat_FrameMeta.__index:UnregisterCustomEvent(event)
		if REGISTERED_CUSTOM_EVENTS[event] then
			REGISTERED_CUSTOM_EVENTS[event][self] = nil
		end
	end
end

-- Equivalent global functions (in case some code calls them using function
-- syntax rather than method syntax).
DIAGv26_CP64 = true;
if not RegisterCustomEvent then
	function RegisterCustomEvent(self, event)
		self:RegisterCustomEvent(event)
	end
end

if not UnregisterCustomEvent then
	function UnregisterCustomEvent(self, event)
		self:UnregisterCustomEvent(event)
	end
end

-- ============================================================
-- 2bis) FireCustomClientEvent
--    ROUND 53: the Collection system calls FireCustomClientEvent(...)
--    ~24 times (Mounts/Pets search refresh, Summon/Dismiss button update,
--    filling the Relics grid, etc.) but this function did not exist
--    anywhere in this patch -- only RegisterCustomEvent/UnregisterCustomEvent
--    (which populate REGISTERED_CUSTOM_EVENTS) had been ported above. Result:
--    listeners registered correctly, but were never notified -- hence a
--    silent Mounts/Pets search, the Summon/Dismiss button never updating,
--    and the Heirloom grid staying empty even though C_Heirloom actually had
--    data internally.
--
--    ROUND 55: the very first version used ExecuteFrameScript (like Sirus),
--    but ExecuteFrameScript fails SILENTLY (swallowed by securecall) when
--    called in a REENTRANT context -- that is, when FireCustomClientEvent
--    is itself called from INSIDE a Frame script that is already running
--    (e.g. PopulateHeirloomData calls FireCustomClientEvent("HEIRLOOMS_UPDATED")
--    from the OnEvent of PLAYER_ENTERING_WORLD; the Mounts/Pets searches call
--    FireCustomClientEvent from the OnTextChanged of the EditBox). These are
--    exactly the most common use cases for this system. We now call the
--    frame's OnEvent script directly (a plain Lua function call, without
--    going through ExecuteFrameScript), which has no reentrancy restriction.
-- ============================================================
DIAGv26_CP102 = true;
if not FireCustomClientEvent then
	function FireCustomClientEvent(event, ...)
		local listeners = REGISTERED_CUSTOM_EVENTS[event]
		if not listeners then
			return
		end
		local frame = securecall(next, listeners, nil)
		while frame do
			-- FIX ROUND TRANSMOG-30: this function only knew how to dispatch
			-- the event to a frame that had a real XML <OnEvent function="..."/>
			-- script (retrieved via frame:GetScript("OnEvent")). However
			-- WardrobeItemsCollectionMixin (the grid SHARED between the
			-- "Wardrobe" tab and the "Transmogrification" tab, cf.
			-- Custom_Wardrobe.lua) is retail code ported as-is: it defines a
			-- real Lua METHOD ":OnEvent(event, ...)" on the mixin, without
			-- ever calling self:SetScript("OnEvent", ...) or declaring an
			-- <OnEvent> in XML -- on retail, the game engine automatically
			-- calls self:OnEvent(...) for any frame that has a method with
			-- that name, even without an explicit script. Our WotLK engine
			-- does not have this behavior, so frame:GetScript("OnEvent")
			-- always returned nil for this particular frame: TRANSMOGRIFY_UPDATE
			-- was faithfully sent (SelectVisual -> C_Transmog.SetPending ->
			-- FireCustomClientEvent) but NEVER RECEIVED, so
			-- WardrobeItemsCollectionMixin:UpdateItems() (which redraws the
			-- pink selection border) never triggered right after a click --
			-- neither in Wardrobe nor in Transmogrification. The selection
			-- was indeed saved (hence the "hidden" effect reported), but only
			-- became visible after a full OnShow (switching tabs and coming
			-- back), which forces an independent refresh unrelated to this
			-- mechanism. We therefore add a fallback: if the frame has no
			-- native OnEvent script but does have a Lua ":OnEvent" method, we
			-- call it directly.
			local handler = frame.GetScript and frame:GetScript("OnEvent")
			if handler then
				securecall(handler, frame, event, ...)
			elseif type(frame.OnEvent) == "function" then
				securecall(frame.OnEvent, frame, event, ...)
			end
			frame = securecall(next, listeners, frame)
		end
	end
end

-- ============================================================
-- 2ter) AzuCollection_RequestItem
--    ROUND 54: on Azeroth Universe, clicking a collected Toy or Relic/
--    Heirloom must create the PHYSICAL item in the player's bag (no mail,
--    not just a retail-style spell effect). The client alone has NO
--    authority to create an item -- this simply sends a REQUEST to the
--    server via an addon message (the only client->server channel
--    available without touching the core's C++), caught server-side by a
--    separate provided Eluna script (AzuCollection_ItemGrant.lua) that
--    verifies actual entitlement (player:HasSpell(spellID), server
--    authority) before creating the item (player:AddItem). Without this
--    Eluna script installed and active, this function sends the message but
--    nothing will happen server-side.
-- ============================================================
DIAGv26_CP133 = true;
AZUCOL_ADDON_PREFIX = "AZUCOL"

function AzuCollection_RequestItem(kind, itemID)
	if type(itemID) ~= "number" then
		return;
	end
	SendAddonMessage(AZUCOL_ADDON_PREFIX, kind .. ":" .. itemID, "WHISPER", UnitName("player"));
end

-- ============================================================
-- 3) C_EventUtils.IsEventValid: only used by EventRegistry:OnAttributeChanged
--    (never triggered by the Collection system, which only uses
--    :TriggerEvent/:RegisterCallback), but we provide it anyway as a safety
--    net in case something ever relies on it.
-- ============================================================
DIAGv26_CP149 = true;
C_EventUtils = C_EventUtils or {}
if not C_EventUtils.IsEventValid then
	function C_EventUtils.IsEventValid(event)
		return false
	end
end

-- ============================================================
-- 4) GetCVarBitfield / SetCVarBitfield
--    Standalone version (no need to port all of Sirus's C_CVar.lua, which
--    registers ~150 CVars specific to Sirus). Relies only on the stock
--    GetCVar/SetCVar natives + the bit library, both already present.
-- ============================================================
if not GetCVarBitfield then
	function GetCVarBitfield(name, index)
		if type(name) ~= "string" or type(index) ~= "number" then
			error("Usage: local value = GetCVarBitfield(name, index)", 2)
		end
		local value = tonumber(GetCVar(name)) or 0
		return bit.band(value, bit.lshift(1, index - 1)) ~= 0
	end
end

DIAGv26_CP172 = true;
if not SetCVarBitfield then
	function SetCVarBitfield(name, index, value, scriptCvar)
		if type(name) ~= "string" or type(index) ~= "number" then
			error("Usage: local value = SetCVarBitfield(name, index)", 2)
		end
		local currentValue = tonumber(GetCVar(name)) or 0
		if value then
			value = bit.bor(currentValue, bit.lshift(1, index - 1))
		else
			value = bit.band(currentValue, bit.bnot(bit.lshift(1, index - 1)))
		end
		SetCVar(name, value)
	end
end

-- ============================================================
-- 5) GMError: present in Sirus\SharedXML\Utils\C_Service.lua, absent from
--    Universe. Universe already has IsGMAccount() (SharedXML\Utils\C_Service.lua),
--    we rely on it.
-- ============================================================
DIAGv26_CP192 = true;
if not GMError then
	function GMError(err)
		if IsGMAccount and IsGMAccount() then
			geterrorhandler()("[GMError] " .. tostring(err))
		end
	end
end

-- ============================================================
-- 6) Model_OnShow: small helper used by Custom_MountCollection.lua, present
--    in Sirus\FrameXML\UIParent.lua, absent from Universe's version of this
--    (very large) file. Copied verbatim.
-- ============================================================
if not Model_OnShow then
	function Model_OnShow(self, rotation)
		if self.isZooming then
			self.originZoom = 0
			self.newZoom = 0
		end
		if rotation then
			self.rotation = rotation
			self:SetRotation(self.rotation)
		end
	end
end

-- ============================================================
-- 7) ToggleCollectionsJournal: opening/closing the panel, present in
--    Sirus\FrameXML\UIParent.lua. Follows the same pattern as the client's
--    other ToggleXFrame() functions (ShowUIPanel/HideUIPanel).
-- ============================================================
DIAGv26_CP223 = true;
if not ToggleCollectionsJournal then
	function ToggleCollectionsJournal(tab)
		if CollectionsJournal and CollectionsJournal:IsShown() then
			HideUIPanel(CollectionsJournal)
		else
			if tab then
				PanelTemplates_SetTab(CollectionsJournal, tab)
			end
			ShowUIPanel(CollectionsJournal)
		end
	end
end

-- ============================================================
-- 8) Missing localization strings (absent from Universe's GlobalStrings.lua;
--    MOUNTS and PETS already exist and are left untouched).
-- ============================================================
DIAGv26_CP240 = true;
if not COLLECTIONS then COLLECTIONS = "Collections" end
if not WARDROBE then WARDROBE = "Wardrobe" end
if not TOY_BOX then TOY_BOX = "Toys" end
if not HEIRLOOMS then HEIRLOOMS = "Heirlooms" end

-- ============================================================
-- ROUND 59: HEIRLOOMS_CATEGORY_* -- GlobalStrings missing on the Universe
--    side (present on the Sirus side, e.g. GlobalStrings.lua). Used by
--    GetHeirloomCategoryFromInvType (Custom_HeirloomCollection.lua) to sort
--    each heirloom into a category ("Head", "Weapons", etc). Since these
--    globals were nil, GetHeirloomCategoryFromInvType ALWAYS returned nil
--    (regardless of invType), so the "if category then" condition failed
--    for all 24 heirlooms every time -- this is the REAL cause of the
--    Heirlooms grid being stuck at 0/0 despite a correct class filter and
--    otherwise correct data (confirmed by /hdebug round 58:
--    SortHeirloomsIntoEquipmentBuckets() ran without error but filled 0
--    categories out of 24 otherwise valid items).
-- ============================================================
DIAGv26_CP259 = true;
if not HEIRLOOMS_CATEGORY_HEAD then HEIRLOOMS_CATEGORY_HEAD = "Head" end
if not HEIRLOOMS_CATEGORY_SHOULDER then HEIRLOOMS_CATEGORY_SHOULDER = "Shoulder" end
if not HEIRLOOMS_CATEGORY_BACK then HEIRLOOMS_CATEGORY_BACK = "Back" end
if not HEIRLOOMS_CATEGORY_CHEST then HEIRLOOMS_CATEGORY_CHEST = "Chest" end
if not HEIRLOOMS_CATEGORY_HAND then HEIRLOOMS_CATEGORY_HAND = "Hands" end
if not HEIRLOOMS_CATEGORY_WRIST then HEIRLOOMS_CATEGORY_WRIST = "Wrists" end
if not HEIRLOOMS_CATEGORY_LEGS then HEIRLOOMS_CATEGORY_LEGS = "Legs" end
if not HEIRLOOMS_CATEGORY_WAIST then HEIRLOOMS_CATEGORY_WAIST = "Waist" end
if not HEIRLOOMS_CATEGORY_FEET then HEIRLOOMS_CATEGORY_FEET = "Feet" end
if not HEIRLOOMS_CATEGORY_WEAPON then HEIRLOOMS_CATEGORY_WEAPON = "Weapons" end
if not HEIRLOOMS_CATEGORY_TRINKETS_RINGS_NECKLACES_AND_RELIC then HEIRLOOMS_CATEGORY_TRINKETS_RINGS_NECKLACES_AND_RELIC = "Trinkets, rings, necklaces and relics" end
if not MAINMENUBAR_COLLECTIONS_BUTTON_DESC then
	MAINMENUBAR_COLLECTIONS_BUTTON_DESC = "Shows all your mounts and pets."
end
if not BINDING_NAME_TOGGLECOLLECTIONS then
	BINDING_NAME_TOGGLECOLLECTIONS = "Open Collections"
end

-- ============================================================
-- 9) UIResettableDropdownButtonMixin: used by the FILTER button of the 5
--    Collection systems (UIResettableDropdownButtonTemplate, cf
--    Collection_Compat.xml). Simplified version compared to Sirus: does not
--    depend on UIMenuButtonStretchMixin (which does not exist on the
--    Universe side, whose UIMenuButtonStretchTemplate already handles
--    OnMouseDown/OnMouseUp via inline XML scripts).
-- ============================================================
DIAGv26_CP285 = true;
if not UIResettableDropdownButtonMixin then
	UIResettableDropdownButtonMixin = {}

	function UIResettableDropdownButtonMixin:OnLoad()
		self.ResetButton:SetScript("OnClick", function(button, buttonName, down)
			if self.resetFunction then
				-- Fix Round Transmog-10: defensive pcall. self.resetFunction
				-- (SetDefaultFilters on the Mounts/Wardrobe/etc. side) can
				-- fail on an unregistered CVar (cf. the generic CVar shim
				-- above); even with this shim, we avoid an unexpected error
				-- preventing the button from hiding.
				local ok, err = pcall(self.resetFunction)
				if not ok then
					geterrorhandler()(err)
				end
			end
			self.ResetButton:Hide()
		end)
	end

	function UIResettableDropdownButtonMixin:SetResetFunction(resetFunction)
		self.resetFunction = resetFunction
	end
end

-- ============================================================
-- 10) SKILL_NAME_*: global strings for weapon/armor skill names used by
--     C_TransmogCollection.lua (SKILL_ID_BY_NAME), absent from Universe's
--     GlobalStrings.lua. Official Blizzard EN translations.
-- ============================================================
DIAGv26_CP315 = true;
if not SKILL_NAME_SWORDS then SKILL_NAME_SWORDS = "Swords" end
if not SKILL_NAME_AXES then SKILL_NAME_AXES = "Axes" end
if not SKILL_NAME_BOWS then SKILL_NAME_BOWS = "Bows" end
if not SKILL_NAME_GUNS then SKILL_NAME_GUNS = "Guns" end
if not SKILL_NAME_MACES then SKILL_NAME_MACES = "Mace" end -- PATCH round 27: /cdebug showed "Mace" (singular), not "Maces"
if not SKILL_NAME_TWO_HANDED_SWORDS then SKILL_NAME_TWO_HANDED_SWORDS = "Two-Handed Swords" end
if not SKILL_NAME_STAVES then SKILL_NAME_STAVES = "Staves" end
if not SKILL_NAME_TWO_HANDED_MACES then SKILL_NAME_TWO_HANDED_MACES = "Two-Handed Maces" end
if not SKILL_NAME_TWO_HANDED_AXES then SKILL_NAME_TWO_HANDED_AXES = "Two-Handed Axes" end
if not SKILL_NAME_DAGGERS then SKILL_NAME_DAGGERS = "Daggers" end
if not SKILL_NAME_THROWN then SKILL_NAME_THROWN = "Thrown" end
if not SKILL_NAME_CROSSBOWS then SKILL_NAME_CROSSBOWS = "Crossbows" end
if not SKILL_NAME_WANDS then SKILL_NAME_WANDS = "Wands" end
if not SKILL_NAME_POLEARMS then SKILL_NAME_POLEARMS = "Polearms" end
if not SKILL_NAME_CHIELD then SKILL_NAME_CHIELD = "Shield" end
DIAGv26_CP330 = true;
if not SKILL_NAME_FIST_WEAPONS then SKILL_NAME_FIST_WEAPONS = "Fist Weapons" end
if not SKILL_NAME_FISHING then SKILL_NAME_FISHING = "Fishing" end
if not SKILL_NAME_PLATE_MAIL then SKILL_NAME_PLATE_MAIL = "Plate Mail" end
if not SKILL_NAME_MAIL then SKILL_NAME_MAIL = "Mail" end
if not SKILL_NAME_LEATHER then SKILL_NAME_LEATHER = "Leather" end
if not SKILL_NAME_CLOTH then SKILL_NAME_CLOTH = "Cloth" end

-- PATCH Collection (round 99, fixed round 100): ITEM_SUB_CLASS_4_X
-- (armor sub-categories used by the Wardrobe filter dropdown, cf.
-- C_TransmogCollection.lua line ~117:
-- subCategories[subCategoryID].name = _G["ITEM_SUB_CLASS_4_"..subCategoryID]).
-- Round 99 only forced index 3 (Mail) based on the position of the "???" in
-- the first screenshot -- wrong assumption: the second screenshot
-- (decorative/event items: Santa hat, glasses, flame effect) shows that the
-- remaining "???" is actually index 5 ("Cosmetic" on the Russian Sirus
-- source), not index 3. Rather than guessing again, the entire 0-6 range
-- (official Blizzard EN values) is now forced explicitly to eliminate any
-- remaining Russian leftovers, regardless of which index is actually
-- displayed for a given slot.
DIAGv26_CP349 = true;
ITEM_SUB_CLASS_4_0 = "Miscellaneous";
ITEM_SUB_CLASS_4_1 = "Cloth";
ITEM_SUB_CLASS_4_2 = "Leather";
ITEM_SUB_CLASS_4_3 = "Mail";
ITEM_SUB_CLASS_4_4 = "Plate";
ITEM_SUB_CLASS_4_5 = "Cosmetic";
ITEM_SUB_CLASS_4_6 = "Shields";

-- ============================================================
-- 11) C_SpellBook.FilterOutSpellLearn: used by C_TransmogCollection.lua
--     (BuildIllusions) to avoid showing a "spell learned" popup for illusion
--     spells. Sirus's real C_SpellBook.lua depends on FLYOUT_STORAGE/
--     C_GlobalStorage which are not ported here; since this function is
--     only used for cosmetic popup filtering, a harmless stub is enough.
-- ============================================================
DIAGv26_CP364 = true;
C_SpellBook = C_SpellBook or {}
if not C_SpellBook.FilterOutSpellLearn then
	function C_SpellBook.FilterOutSpellLearn(spellID, spellName)
		-- no-op
	end
end

-- ============================================================
-- 12) S_ATLAS_STORAGE: :SetAtlas(...) (SharedXML\SharedExtendedMethods.lua)
--     reads the global table S_ATLAS_STORAGE, which is only initialized as
--     an EMPTY table by Interface\FrameXML\EncounterJournal_OfflineStubs.lua
--     ("S_ATLAS_STORAGE = S_ATLAS_STORAGE or {}") - never actually filled.
--     The real atlas data already exists in SharedXML\AtlasStorage.lua under
--     the name PRETTY_ATLAS_STORAGE. We merge the two, regardless of load
--     order (the "or {}" further down the .toc will not replace a table
--     that is already non-nil).
-- ============================================================
DIAGv26_CP381 = true;
S_ATLAS_STORAGE = S_ATLAS_STORAGE or {}
if PRETTY_ATLAS_STORAGE then
	for atlasName, atlasData in pairs(PRETTY_ATLAS_STORAGE) do
		if S_ATLAS_STORAGE[atlasName] == nil then
			S_ATLAS_STORAGE[atlasName] = atlasData
		end
	end
end

-- ============================================================
-- 13) EnumUtil.MakeEnum / EnumUtil.IsValid: used by FilterDropdown.lua.
--     We do NOT port Sirus's SharedXML\EnumUtil.lua as-is: that file would
--     also redefine Enum/enum, which already exist and work fine on the
--     Universe side (SharedXML\Extensions\enum.lua). We only add the 2
--     missing functions, based on tInvert/tContains (already present).
-- ============================================================
DIAGv26_CP397 = true;
EnumUtil = EnumUtil or {}
if not EnumUtil.MakeEnum then
	function EnumUtil.MakeEnum(...)
		return tInvert({...})
	end
end
if not EnumUtil.IsValid then
	function EnumUtil.IsValid(enumClass, enumValue)
		return tContains(enumClass, enumValue)
	end
end

-- ============================================================
-- 14) UIDropDownMenu_AddSpace / AddSeparator / RefreshAll: used by
--     FilterDropdown.lua, absent from Universe's version of
--     UIDropDownMenu.lua (only UIDropDownMenu_AddButton exists). Copied
--     verbatim from Sirus.
-- ============================================================
DIAGv26_CP415 = true;
if not UIDropDownMenu_AddSeparator then
	function UIDropDownMenu_AddSeparator(level)
		local separatorInfo = {
			hasArrow = false;
			dist = 0;
			isTitle = true;
			isUninteractable = true;
			notCheckable = true;
			iconOnly = true;
			icon = "Interface\\Common\\UI-TooltipDivider-Transparent";
			tCoordLeft = 0;
			tCoordRight = 1;
			tCoordTop = 0;
			tCoordBottom = 1;
			tSizeX = 0;
			tSizeY = 8;
			tFitDropDownSizeX = true;
			iconInfo = {
				tCoordLeft = 0,
				tCoordRight = 1,
				tCoordTop = 0,
				tCoordBottom = 1,
				tSizeX = 0,
				tSizeY = 8,
				tFitDropDownSizeX = true
			},
		};

		UIDropDownMenu_AddButton(separatorInfo, level);
	end
end

DIAGv26_CP447 = true;
if not UIDropDownMenu_AddSpace then
	function UIDropDownMenu_AddSpace(level)
		local spaceInfo = {
			hasArrow = false,
			dist = 0,
			isTitle = true,
			isUninteractable = true,
			notCheckable = true,
		};

		UIDropDownMenu_AddButton(spaceInfo, level);
	end
end

if not UIDropDownMenu_RefreshAll then
	function UIDropDownMenu_RefreshAll(frame, useValue)
		for dropdownLevel = UIDROPDOWNMENU_MENU_LEVEL, 2, -1 do
			local listFrame = _G["DropDownList"..dropdownLevel];
			if listFrame and listFrame:IsShown() then
				UIDropDownMenu_Refresh(frame, nil, dropdownLevel);
			end
		end
		UIDropDownMenu_Refresh(frame, useValue, 1);
	end
end

-- ============================================================
-- 15) Missing localization strings (continued): found by scanning all of
--     Custom_Collections for GlobalStrings constants missing from Universe
--     (confirmed by in-game errors: ERR_NO_RIDING_SKILL, RANDOM_FAVORITE_MOUNT,
--     YOU_IN_COLLECTED, WARDROBE_ITEMS, etc.)
-- ============================================================
DIAGv26_CP479 = true;
if not ADD_TO_FAVORITE then ADD_TO_FAVORITE = "Add to Favorites" end
if not ALL_CLASSES then ALL_CLASSES = "All Classes" end
if not ALL_MOUNTS then ALL_MOUNTS = "All Mounts" end
if not ALL_SPECS then ALL_SPECS = "All Specializations" end
if not BATTLE_PET_FAVORITE then BATTLE_PET_FAVORITE = "Add to Favorites" end
if not BATTLE_PET_UNFAVORITE then BATTLE_PET_UNFAVORITE = "Remove from Favorites" end
if not BUY then BUY = "Buy" end
if not CATEGORYES then CATEGORYES = "Categories" end
if not CHECK_ALL then CHECK_ALL = "Check All" end
if not COLLECTED then COLLECTED = "Collected" end
if not COLLECTION_MOUNT_ABILITIES then COLLECTION_MOUNT_ABILITIES = "Abilities" end
if not COLLECTION_PAGE_NUMBER then COLLECTION_PAGE_NUMBER = "Page %d / %d" end
if not COLLECTION_TRAVELING_MERCHANTS then COLLECTION_TRAVELING_MERCHANTS = "Traveling Merchants" end
if not COMMUNITIES_LIST_DROP_DOWN_FAVORITE then COMMUNITIES_LIST_DROP_DOWN_FAVORITE = "Add to Favorites" end
if not DELETE_FAVORITE then DELETE_FAVORITE = "Remove from Favorites" end
DIAGv26_CP494 = true;
if not ERR_NO_RIDING_SKILL then ERR_NO_RIDING_SKILL = "You can learn riding and obtain a mount from your riding trainer at level 20" end
if not FAVORITES then FAVORITES = "Favorites" end
if not GO_TO_BATTLE_BASS then GO_TO_BATTLE_BASS = "Go to Battle Pass" end
if not GO_TO_STORE then GO_TO_STORE = "Go to Store" end
if not HEIRLOOMS_PROGRESS_FORMAT then HEIRLOOMS_PROGRESS_FORMAT = "%d/%d" end
if not MOUNT_COLLECTION_ENCOUNTER then MOUNT_COLLECTION_ENCOUNTER = "Encounter" end
if not MOUNT_COLLECTION_ENCOUNTER_DESC then MOUNT_COLLECTION_ENCOUNTER_DESC = "You can obtain it as loot" end
if not MOUNT_COLLECTION_ENCOUNTER_SHOW then MOUNT_COLLECTION_ENCOUNTER_SHOW = "Show" end
if not MOUNT_JOURNAL_PLAYER then MOUNT_JOURNAL_PLAYER = "Show Character" end
if not MY_COLLECTIONS then MY_COLLECTIONS = "My Collection" end
if not NEW_CAPS then NEW_CAPS = "NEW" end
if not NOT_COLLECTED then NOT_COLLECTED = "Not Collected" end
if not PET_FAMILIES then PET_FAMILIES = "Pet Families" end
if not PET_JOURNAL_SUMMON_RANDOM_FAVORITE_PET then PET_JOURNAL_SUMMON_RANDOM_FAVORITE_PET = "Summon a Random\nFavorite Pet" end
if not PICK_UP then PICK_UP = "Pick Up" end
DIAGv26_CP509 = true;
if not RANDOM_FAVORITE_MOUNT then RANDOM_FAVORITE_MOUNT = "Summon a Random Favorite Mount" end
if not SOURCES then SOURCES = "Sources" end
if not TOY_PROGRESS_FORMAT then TOY_PROGRESS_FORMAT = "%d/%d" end
if not TRANSMOGRIFY then TRANSMOGRIFY = "Transmogrification" end
if not TRANSMOGRIFY_FILTER_SORT_TITLE then TRANSMOGRIFY_FILTER_SORT_TITLE = "Sort" end
if not TRANSMOG_HELP_BUTTON then TRANSMOG_HELP_BUTTON = "Full Rules" end
if not TRANSMOG_HELP_HEADER then TRANSMOG_HELP_HEADER = "Transmogrification rules for this item type" end
if not TRANSMOG_NO_VALID_ITEMS_EQUIPPED then TRANSMOG_NO_VALID_ITEMS_EQUIPPED = "No valid item equipped." end
if not UNCHECK_ALL then UNCHECK_ALL = "Uncheck All" end
if not WARDROBE_ITEMS then WARDROBE_ITEMS = "Items" end
if not WARDROBE_NO_SEARCH then WARDROBE_NO_SEARCH = "No search results." end
if not WARDROBE_TRANSMOGRIFY_AS then WARDROBE_TRANSMOGRIFY_AS = "Transmogrify into:" end
if not WEAPON_ENCHANTMENT then WEAPON_ENCHANTMENT = "Weapon Enchantment" end
if not YOU_IN_COLLECTED then YOU_IN_COLLECTED = "Your Collection:" end

-- ============================================================
-- 16) C_Service / IsGMAccount / GetServerID: Interface\SharedXML\Utils\C_Service.lua
--     does exist on the Universe side BUT is not referenced in ANY .toc
--     (neither FrameXML nor Glue) - it's a dead file, never loaded. Several
--     files of the Collection system do "local IsGMAccount = IsGMAccount" at
--     the top of the file and therefore capture nil. We do not port the real
--     file as-is (it depends on RegisterEventListener/RegisterHookListener
--     which don't exist anywhere on the Universe side and would crash on
--     OnLoad): we provide a minimal sufficient stub (always returns "not GM").
-- ============================================================
DIAGv26_CP534 = true;
if not IsGMAccount then
	function IsGMAccount()
		return false
	end
end

C_Service = C_Service or {}
if not C_Service.GetRealmID then
	function C_Service:GetRealmID()
		return 0
	end
end
if not C_Service.IsGM then
	function C_Service:IsGM()
		return false
	end
end

-- ============================================================
-- 17) LE_MOUNT_JOURNAL_FILTER_*: constants from Sirus's
--     Interface\FrameXML\Constants.lua, absent from Universe's version of
--     this file.
-- ============================================================
DIAGv26_CP556 = true;
if not LE_MOUNT_JOURNAL_FILTER_COLLECTED then LE_MOUNT_JOURNAL_FILTER_COLLECTED = 1 end
if not LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED then LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED = 2 end
if not LE_MOUNT_JOURNAL_FILTER_FAVORITES then LE_MOUNT_JOURNAL_FILTER_FAVORITES = 3 end

-- ============================================================
-- 18) C_FactionManager.RegisterCallback / GetFactionOverrideCVar: Universe
--     already has a C_FactionManager stub (Interface\FrameXML\EncounterJournal_OfflineStubs.lua)
--     but with different method names (RegisterFactionOverrideCallback, not
--     RegisterCallback). We complete this same stub with the names the
--     Collection system actually calls, without touching what already exists.
-- ============================================================
C_FactionManager = C_FactionManager or {}
if not C_FactionManager.RegisterCallback then
	function C_FactionManager.RegisterCallback(callback, shouldExecute, persistent)
		if shouldExecute and callback then
			callback()
		end
	end
end
DIAGv26_CP575 = true;
if not C_FactionManager.GetFactionOverrideCVar then
	function C_FactionManager.GetFactionOverrideCVar()
		return nil
	end
end

-- ============================================================
-- 19) MicroButtonPulse / MicroButtonPulseStop: used by
--     CollectionsJournal_OnShow on the CollectionsMicroButton button, absent
--     from Universe. Defensive version (guards against .Flash not existing).
-- ============================================================
if not MicroButtonPulse then
	function MicroButtonPulse(self, duration)
		if self and self.Flash and UIFrameFlash then
			UIFrameFlash(self.Flash, 1.0, 1.0, duration or -1, false, 0, 0, "microbutton")
		end
	end
end
DIAGv26_CP593 = true;
if not MicroButtonPulseStop then
	function MicroButtonPulseStop(self)
		if self and self.Flash and UIFrameFlashStop then
			UIFrameFlashStop(self.Flash)
		end
	end
end

-- ============================================================
-- 20) Enum.TransmogType: defined in Sirus's
--     Interface\FrameXML\Utils\C_Transmog.lua (file not ported: too many
--     dependencies for just the "at the Transmogrifier NPC" frame, separate
--     from the Wardrobe tab of the Collection Codex). We just provide the
--     enum, used by Custom_Wardrobe.xml.
-- ============================================================
Enum = Enum or {}
DIAGv26_CP608 = true;
if not Enum.TransmogType then
	Enum.TransmogType = {Appearance = 0, Illusion = 1}
end

-- ============================================================
-- 21) C_StorePublic / C_StoreSecure: shop/cash-shop, not ported (no shop
--     system on the Universe side). "Shop unavailable" stubs to avoid
--     crashes on the Buy buttons of premium mounts/pets; those items will
--     remain non-purchasable through the Codex, which is already the
--     functional behavior without a shop backend.
-- ============================================================
C_StorePublic = C_StorePublic or {}
if not C_StorePublic.IsEnabled then function C_StorePublic.IsEnabled() return false end end
if not C_StorePublic.IsValidCurrencyType then function C_StorePublic.IsValidCurrencyType(currencyType) return false end end
if not C_StorePublic.GetRolledItemInfoByHash then function C_StorePublic.GetRolledItemInfoByHash(hash) return nil end end

DIAGv26_CP624 = true;
C_StoreSecure = C_StoreSecure or {}
if not C_StoreSecure.GetVirtualCategoryByRemoteID then
	function C_StoreSecure.GetVirtualCategoryByRemoteID(...)
		return nil, nil
	end
end


-- ============================================================
-- 23) Missing Transmog constants from Constants.lua (Sirus)
-- ============================================================
if not NO_TRANSMOG_VISUAL_ID then NO_TRANSMOG_VISUAL_ID = 0 end
if not FIRST_TRANSMOG_COLLECTION_SUB_CATEGORY then FIRST_TRANSMOG_COLLECTION_SUB_CATEGORY = 0 end
if not LAST_TRANSMOG_COLLECTION_SUB_CATEGORY then LAST_TRANSMOG_COLLECTION_SUB_CATEGORY = 5 end

DIAGv26_CP639 = true;
Enum = Enum or {}
if not Enum.TransmogModification then
	Enum.TransmogModification = {Main = 0, Secondary = 1}
end
if not Enum.TransmogPendingType then
	Enum.TransmogPendingType = {Apply = 0, Revert = 1, ToggleOn = 2, ToggleOff = 3}
end

-- ============================================================
-- 24) C_Transmog: real implementation (ROUND Transmog-5).
--
--     The old minimal stub (kept in a comment below for reference) made the
--     Codex browsable but left the "Apply" button completely non-functional:
--     SetPending/GetPending/GetSlotInfo/ApplyAllPending never actually did
--     anything. We now implement the real mechanism, reusing EXACTLY the
--     same trick as Transmog/TransmogrifierServer.lua (an independent AIO
--     system, already working on Universe for a long time): writing the
--     player's PLAYER_VISIBLE_ITEM_x_ENTRYID fields directly on the SERVER
--     side (PLAYER_VISIBLE_ITEM_1_ENTRYID = 283 for the Head slot, +2 per
--     following slot) -- a pure protocol trick that changes the appearance
--     WITHOUT touching the actually equipped item. No client-side magic
--     required.
--
--     Protocol (addon-message, same ACMSG_*/ASMSG_* family as
--     Utils\C_TransmogCollection.lua):
--       ACMSG_TRANSMOG_APPLY   "slot:itemEntry"   client -> server
--                              (itemEntry=0 = revert/remove the transmog)
--       ASMSG_TRANSMOG_APPLIED "slot:itemEntry"   server -> client (confirmation)
--       ASMSG_TRANSMOG_SYNC    "slot:item,slot:item,..." server -> client (on login)
--       ASMSG_TRANSMOG_ERROR   text               server -> client (refusal)
--     Server side: see AzuCollections/AzuCollection_TransmogApply_v1.lua.
--     Requires AzuCollection_TransmogTracker_v2.lua (already installed): you
--     can only apply an appearance that has already been "collected"
--     (already worn at least once), same principle as the retail Wardrobe.
-- ============================================================
--- Error code -> tag lookup table used by TransmogSlotButtonMixin:Update
--- (Custom_Wardrobe.lua:565) to decide which icon to show when a slot cannot
--- be transmogrified. Our C_Transmog.GetSlotInfo (below) currently only
--- returns a single code (1 = nothing equipped in that slot), mapped to the
--- retail tag "NO_ITEM" (shows the empty slot outline instead of a black/nil
--- icon). Missing global = crash ("attempt to index global
--- 'TRANSMOG_INVALID_CODES' (a nil value)"), reported multiple times by the
--- user (Round Transmog-7).
DIAGv26_CP683 = true;
if not TRANSMOG_INVALID_CODES then
	TRANSMOG_INVALID_CODES = {
		[1] = "NO_ITEM",
	}
end

--- Fix Round Transmog-8: missing _AnimateTexCoords (crash in a loop on
--- OnUpdate, 727 occurrences reported) -- used by the 2 "Ants" (animated
--- purple halo around a slot pending application, Custom_Wardrobe.xml,
--- PurpleIconAlertAnts) via
--- _AnimateTexCoords(self.Ants, 256, 256, 48, 48, 22, elapsed, 0.01).
--- Standard retail polyfill (sprite sheet grid, advances one frame every
--- <throttle> seconds).
if not _AnimateTexCoords then
	function _AnimateTexCoords(texture, width, height, frameWidth, frameHeight, numFrames, elapsed, throttle, numColumns)
		throttle = throttle or 0.1;
		numColumns = numColumns or numFrames;

		texture.transmogAnimElapsed = (texture.transmogAnimElapsed or 0) + elapsed;
		if texture.transmogAnimElapsed >= throttle then
			local framesElapsed = floor(texture.transmogAnimElapsed / throttle);
			texture.transmogAnimElapsed = texture.transmogAnimElapsed - (throttle * framesElapsed);
			local currentFrame = texture.transmogAnimCurrentFrame or 1;
			currentFrame = ((currentFrame + framesElapsed - 1) % numFrames) + 1;
			texture.transmogAnimCurrentFrame = currentFrame;

			local column = (currentFrame - 1) % numColumns;
			local row = floor((currentFrame - 1) / numColumns);

			local left = column * frameWidth / width;
			local right = (column + 1) * frameWidth / width;
			local top = row * frameHeight / height;
			local bottom = (row + 1) * frameHeight / height;

			texture:SetTexCoord(left, right, top, bottom);
		end
	end
end

DIAGv26_CP722 = true;
do
	C_Transmog = C_Transmog or {}
	-- FIX ROUND TRANSMOG-24 (root cause found via /diagcp bisection):
	-- C_Item is never created by this file itself, only used (see the line
	-- "if not C_Item.GetBaseItemTransmogInfo then" a bit further below). On
	-- this client, C_Item does not exist yet at this exact point in loading
	-- (the real C_Item, with GetItemInfo etc., is created by a file that
	-- loads AFTER Collection_Compat.lua) -- hence
	-- "attempt to index a nil value (global 'C_Item')", which interrupted
	-- the rest of the file (EventHandler:ASMSG_TRANSMOG_*, C_Talent,
	-- PET_TYPE_SUFFIX, COLLECTION_ITEM_HYPERLINK_FORMAT, StringSplitEx,
	-- GetSlotInfo, /ccheck, etc.). Same idiom as C_Transmog above: if
	-- C_Item already exists, we don't touch it; otherwise we create an
	-- empty table that the real C_Item file (loaded later) will fill in
	-- itself normally via the same "C_Item = C_Item or {}" idiom.
	C_Item = C_Item or {}

	local _pending = {};	-- [slotID] = {type = Enum.TransmogPendingType.*, transmogID = itemID}
	local _applied = {};	-- [slotID] = itemID currently applied (nil = none, base item shown)

	--- IMPORTANT (fix Round Transmog-7): in the original retail system, this
	--- function indicates whether the player is physically near the
	--- Transmogrifier NPC; otherwise most UI actions -- including SELECTING
	--- an item in the grid (WardrobeItemsCollectionMixin:SelectVisual) -- are
	--- no-ops. Our system is a self-service journal (AzuCollections), with no
	--- NPC required: we therefore consider the player "at the transmogrifier"
	--- as soon as the WardrobeTransmogFrame window is shown. Before this fix,
	--- IsAtTransmogNPC always returned false, which prevented clicking on any
	--- grid item from doing anything at all (reported symptom: "I click the
	--- item, nothing happens, it doesn't even get selected").
	if not C_Transmog.IsAtTransmogNPC then
		function C_Transmog.IsAtTransmogNPC()
			return WardrobeTransmogFrame ~= nil and WardrobeTransmogFrame:IsShown();
		end
	end
	if not C_Transmog.Close then
		function C_Transmog.Close() end
	end
	if not C_Transmog.GetSlotEffectiveCategory then
		function C_Transmog.GetSlotEffectiveCategory(transmogLocation) return nil, nil end
	end
	if not C_Transmog.LoadOutfit then
		function C_Transmog.LoadOutfit(outfitID) end
	end
	--- Fix Round Transmog-8: this function used to be a stub always
	--- returning zeros. TransmogUtil.GetInfoForEquippedSlot (TransmogUtil.lua)
	--- relies ON IT to compute the "selectedSourceID" passed to
	--- WardrobeItemsCollectionMixin:GoToSourceID when clicking a slot
	--- (TransmogFrameMixin:SelectSlotButton, Custom_Wardrobe.lua): with zeros
	--- everywhere, GoToSourceID never got a valid visualID and therefore
	--- never called SetActiveSlot -- the grid never changed category/content
	--- when clicking a slot (reported symptom: "I click chest, nothing shows,
	--- only the Cloth/Leather/... menu works"). In our system, "sourceID" ==
	--- the itemID itself (verified in Utils/C_TransmogCollection.lua:
	--- GetAppearanceSourceInfo treats its parameter as a direct itemID, no
	--- separate source ID). We therefore actually compute: the base = the
	--- equipped item, and the applied/pending values from our _applied/_pending
	--- tables.
	if not C_Transmog.GetSlotVisualInfo then
		function C_Transmog.GetSlotVisualInfo(transmogLocation)
			local slotID = transmogLocation:GetSlotID();

			local baseSourceID = GetInventoryItemID("player", slotID) or 0;
			local baseVisualID = 0;
			if baseSourceID ~= 0 and C_TransmogCollection and C_TransmogCollection.GetAppearanceSourceInfo then
				local _, _, visID = C_TransmogCollection.GetAppearanceSourceInfo(baseSourceID);
				baseVisualID = visID or 0;
			end

			local appliedItemID = _applied[slotID];
			local appliedSourceID = NO_TRANSMOG_SOURCE_ID or 0;
			local appliedVisualID = 0;
			if appliedItemID and appliedItemID ~= 0 then
				appliedSourceID = appliedItemID;
				if C_TransmogCollection and C_TransmogCollection.GetAppearanceSourceInfo then
					local _, _, visID = C_TransmogCollection.GetAppearanceSourceInfo(appliedItemID);
					appliedVisualID = visID or 0;
				end
			end

			local pending = _pending[slotID];
			local pendingSourceID = REMOVE_TRANSMOG_ID or 0;
			local pendingVisualID = 0;
			local hasPendingUndo = false;
			if pending then
				if pending.type == Enum.TransmogPendingType.Apply then
					pendingSourceID = pending.transmogID or 0;
					if C_TransmogCollection and C_TransmogCollection.GetAppearanceSourceInfo then
						local _, _, visID = C_TransmogCollection.GetAppearanceSourceInfo(pendingSourceID);
						pendingVisualID = visID or 0;
					end
				elseif pending.type == Enum.TransmogPendingType.Revert then
					hasPendingUndo = true;
				end
			end

			return baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo, nil, nil;
		end
	end
	if not C_Transmog.GetSlotUseError then
		function C_Transmog.GetSlotUseError(transmogLocation) return nil, nil end
	end
	if not C_Transmog.GetInventoryTransmogInfo then
		function C_Transmog.GetInventoryTransmogInfo(unit, slotID) return nil end
	end

	--- Fix Round Transmog-8: GetBaseItemTransmogInfo/GetAppliedItemTransmogInfo
	--- used to be stubs (defined in Collection_Compat_Late.lua, under a
	--- "if not X then" guard -- our definition HERE loads earlier, cf.
	--- FrameXML.toc: Collection_Compat.xml before Collection_Compat_Late.lua
	--- -- so our version takes precedence). Used by
	--- TransmogSlotButtonMixin:GetEffectiveTransmogID (Custom_Wardrobe.lua)
	--- to decide which appearance to put on the 3D mannequin.
	-- FIX ROUND TRANSMOG-47 (real root cause of point 2, proven by the
	-- /tmodeltrace trace from round 46): these 2 functions were defined here
	-- UNDER an "if not C_Item.XXX then" guard, on the assumption that this
	-- file necessarily loads before Collection_Compat_Late.lua (which
	-- defines the same names, under an identical guard, as simple stubs --
	-- for GetAppliedItemTransmogInfo its stub ALWAYS returns
	-- {appearanceID=0}, completely ignoring _applied). The round 46 trace
	-- proved that _applied[slotID] did contain the correct itemID right
	-- after applying, but that GetEffectiveTransmogID() still computed the
	-- base item -- the only explanation is that it was Collection_Compat_Late's
	-- STUB that actually won in practice, not our version here, regardless
	-- of the assumed order of FrameXML.toc. We therefore remove the guard:
	-- these 2 functions are now ALWAYS (re)defined here, which guarantees
	-- that our version -- the only one that actually reads _applied -- wins
	-- consistently, independent of the real load order.
	function C_Item.GetBaseItemTransmogInfo(itemLocation)
		local itemID = 0;
		if itemLocation and itemLocation.IsEquipmentSlot and itemLocation:IsEquipmentSlot() then
			itemID = GetInventoryItemID("player", itemLocation:GetEquipmentSlot()) or 0;
		end
		return { appearanceID = itemID, illusionID = 0 };
	end
	function C_Item.GetAppliedItemTransmogInfo(itemLocation)
		local appliedItemID = 0;
		if itemLocation and itemLocation.IsEquipmentSlot and itemLocation:IsEquipmentSlot() then
			appliedItemID = _applied[itemLocation:GetEquipmentSlot()] or 0;
		end
		return { appearanceID = appliedItemID, illusionID = 0 };
	end

	-- FIX ROUND TRANSMOG-35: diagnostics (/tclickdebug, rounds 31-34) confirm
	-- that neither WardrobeCollectionFrame.ItemsCollectionFrame nor
	-- WardrobeTransmogFrame refresh live after TRANSMOGRIFY_UPDATE, EVEN
	-- after the round 30 fix -- both do have a native OnEvent script
	-- inherited from a template (GetScript("OnEvent")=true for both), but
	-- this inherited script apparently does not call our custom ":OnEvent"
	-- method (likely a generic shared template, outside this patch, that we
	-- cannot reliably inspect or modify). Rather than keep guessing at a
	-- mechanism we don't fully control, we now DIRECTLY and explicitly
	-- refresh the 2 known frames right after changing _pending, without
	-- relying at all on FireCustomClientEvent/OnEvent for this specific case
	-- (which is still called in addition, in case other listeners benefit
	-- from it).
	local function RefreshTransmogDisplaysNow(transmogLocation)
		if WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame.UpdateItems then
			pcall(WardrobeCollectionFrame.ItemsCollectionFrame.UpdateItems, WardrobeCollectionFrame.ItemsCollectionFrame);
		end
		-- FIX ROUND TRANSMOG-36 (history): round 35 also called
		-- WardrobeTransmogFrame:MarkDirty(), which scheduled a FULL
		-- TransmogFrameMixin:Update() (every slot) on the next OnUpdate, on
		-- EVERY click on the grid -- the mannequin ended up disappearing
		-- entirely. Hence the rule ever since: never redraw ALL slots on
		-- every click.
		--
		-- FIX ROUND TRANSMOG-58: the user now wants a real live preview
		-- (before clicking Apply), which is reasonable and is NOT the same
		-- thing that round 36 was avoiding. Here we only redraw the SINGLE
		-- slot affected by this specific click (transmogLocation, passed via
		-- SetPending/ClearPending), never the whole loop -- so there's no
		-- risk of reproducing the round 36 bug. RefreshItemModel() is already
		-- reliable for a pending item (pendingInfo.transmogID is returned
		-- directly by GetEffectiveTransmogID, without going through the
		-- "applied/base" calculation (which is itself buggy -- see rounds
		-- 55-57). Existing widget reused (no RecreateModelFrame here: too
		-- heavy for a simple click preview, and unnecessary since we're only
		-- doing TryOn on a single item).
		if transmogLocation and WardrobeTransmogFrame and WardrobeTransmogFrame.GetSlotButton then
			local slotButton = WardrobeTransmogFrame:GetSlotButton(transmogLocation);
			if slotButton and slotButton.RefreshItemModel then
				pcall(slotButton.RefreshItemModel, slotButton);
			end
		end
		if WardrobeTransmogFrame and WardrobeTransmogFrame.UpdateApplyButton then
			pcall(WardrobeTransmogFrame.UpdateApplyButton, WardrobeTransmogFrame);
		end
	end

	function C_Transmog.SetPending(transmogLocation, pendingInfo)
		_pending[transmogLocation:GetSlotID()] = pendingInfo;
		FireCustomClientEvent("TRANSMOGRIFY_UPDATE");
		RefreshTransmogDisplaysNow(transmogLocation);
	end

	function C_Transmog.GetPending(transmogLocation)
		return _pending[transmogLocation:GetSlotID()];
	end

	-- FIX ROUND TRANSMOG-58: direct accessor for _applied, completely
	-- bypassing the ItemLocation/GetRelevantTransmogID/
	-- C_Item.GetAppliedItemTransmogInfo chain used until now by
	-- TransmogSlotButtonMixin:GetEffectiveTransmogID(). This chain turned
	-- out to be unreliable (confirmed by the /tmodeltrace trace from round
	-- 55: even when _applied[slot] contains the correct value, resolving
	-- through this chain kept falling back to the base item). Rather than
	-- keep guessing exactly where this breaks in this indirection (native
	-- ItemLocation cannot be modified by this patch), GetEffectiveTransmogID
	-- now reads _applied[slotID] directly through this accessor -- the same
	-- table that C_Transmog.DebugGetRawState already reads, whose
	-- reliability is confirmed by all previous traces.
	function C_Transmog.GetAppliedTransmogID(slotID)
		return (slotID and _applied[slotID]) or 0;
	end

	-- FIX ROUND TRANSMOG-46 (diagnostics only, no behavior change): _pending
	-- and _applied are local upvalues to this "do...end" block, invisible
	-- from Custom_Wardrobe.lua. We expose here a read-only accessor so that
	-- /tmodeltrace can display their ACTUAL content at the exact moment
	-- RefreshItemModel() runs, in order to determine whether the problem
	-- comes from the write side (ASMSG_TRANSMOG_APPLIED not updating
	-- _applied as expected) or the read side (GetEffectiveTransmogID not
	-- reading the right value).
	function C_Transmog.DebugGetRawState(slotID)
		local pending = _pending[slotID];
		local pendingDesc = "nil";
		if pending then
			pendingDesc = string.format("type=%s transmogID=%s", tostring(pending.type), tostring(pending.transmogID));
		end
		return tostring(_applied[slotID]), pendingDesc;
	end

	function C_Transmog.ClearPending(transmogLocation)
		_pending[transmogLocation:GetSlotID()] = nil;
		FireCustomClientEvent("TRANSMOGRIFY_UPDATE");
		RefreshTransmogDisplaysNow(transmogLocation);
	end

	--- Transmogrification cost (fix Round Transmog-7): 500000 copper
	--- (50 gold) per APPLIED slot, exactly the same value as TRANSMOG_COST in
	--- Transmog/TransmogrifierServer.lua (the already-working AIO system), to
	--- stay consistent between the two systems. Cancelling a transmogrification
	--- (Revert) remains free, just like in TransmogrifierServer.lua
	--- (ResetSlot/ResetAll). The real cost is checked and charged server-side
	--- in AzuCollection_TransmogApply_v1.lua; this client-side calculation is
	--- only used to display/enable the Apply button.
	local TRANSMOG_COST_PER_SLOT = 500000;

	function C_Transmog.GetApplyCost()
		local hasPending, cost = false, 0;
		for _, pending in pairs(_pending) do
			hasPending = true;
			if pending.type == Enum.TransmogPendingType.Apply then
				cost = cost + TRANSMOG_COST_PER_SLOT;
			end
		end
		if not hasPending then
			return nil;
		end
		return cost;
	end

	function C_Transmog.GetApplyWarnings()
		return {};
	end

	function C_Transmog.GetSlotInfo(transmogLocation)
		local slotID = transmogLocation:GetSlotID();
		local pending = _pending[slotID];
		local appliedID = _applied[slotID];
		local equippedID = GetInventoryItemID("player", slotID);

		local isTransmogrified = appliedID ~= nil and appliedID ~= 0;
		local hasPending = pending ~= nil;
		local hasUndo = hasPending and pending.type == Enum.TransmogPendingType.Revert;
		-- FIX ROUND TRANSMOG-28 (free mode requested by the user): we used to
		-- require an actually equipped item in the slot in order to
		-- transmogrify it (canTransmogrify = equippedID ~= nil). Free mode =
		-- no restriction, even an empty slot should be able to receive an
		-- appearance. Honest note: the application mechanism
		-- (PLAYER_VISIBLE_ITEM_x_ENTRYID, server-side) only RE-DRESSES an
		-- already equipped item visually -- on a TRULY empty slot (no item
		-- at all), the game engine simply has no geometry to apply the
		-- appearance to. This fix therefore removes the software block (the
		-- click/selection will now work), but if the slot is truly empty the
		-- visual rendering might still show nothing -- an engine limitation,
		-- not a script one.
		local canTransmogrify = true;
		local cannotTransmogrifyReason = nil;
		local isPendingCollected = true;
		local isHideVisual = false;

		local textureItemID;
		if hasPending and pending.type == Enum.TransmogPendingType.Apply then
			textureItemID = pending.transmogID;
		elseif isTransmogrified then
			textureItemID = appliedID;
		else
			textureItemID = equippedID;
		end
		local texture = textureItemID and textureItemID ~= 0 and GetItemIcon(textureItemID) or nil;

		return isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture;
	end

	function C_Transmog.ApplyAllPending()
		local sentAny = false;
		for slotID, pending in pairs(_pending) do
			local itemID = 0;
			if pending.type == Enum.TransmogPendingType.Apply then
				itemID = pending.transmogID or 0;
			end
			SendServerMessage("ACMSG_TRANSMOG_APPLY", string.format("%d:%d", slotID, itemID));
			sentAny = true;
		end
		wipe(_pending);
		FireCustomClientEvent("TRANSMOGRIFY_UPDATE");
		return sentAny;
	end

	-- ------------------------------------------------------------
	-- Receiving server messages (same EventHandler dispatcher as
	-- Utils\C_TransmogCollection.lua: a method named exactly like the
	-- addon-message prefix is called automatically).
	-- ------------------------------------------------------------
	-- FIX ROUND TRANSMOG-37: these 2 server confirmations (sync on login,
	-- apply confirmation) are REAL equipment changes -- unlike simple
	-- hover/click navigation in the grid (round 36, where we deliberately
	-- stopped refreshing the mannequin on every click to avoid making it
	-- disappear), here a full mannequin refresh is legitimate and expected:
	-- "the character's visual doesn't update" after clicking Apply. We
	-- therefore explicitly call MarkDirty (redraws the mannequin via
	-- Undress/RefreshItemModel) IN ADDITION to the light grid refresh, only
	-- here (rare events, not on every click).
	-- FIX ROUND TRANSMOG-40: round 37 only did MarkDirty() (setting a flag
	-- self.dirty=true, consumed on the next native OnUpdate of
	-- WardrobeTransmogFrame). The OnUpdate script is correctly wired in XML
	-- so this should work on its own -- but we remove this dependency on an
	-- extra round trip (flag + waiting for the next tick) and now call
	-- Update() directly and immediately, synchronously, at the exact moment
	-- the server confirms. We also keep MarkDirty() as a safety net
	-- (harmless, costs nothing extra).
	local function DoRefreshTransmogModel()
		if WardrobeTransmogFrame then
			-- FIX ROUND TRANSMOG-55: rounds 51-54 all called
			-- RefreshPlayerModel(), which recreates the widget AND THEN still
			-- manually replays Undress()+TryOn() for every slot (via
			-- Update()). See the long comment in Custom_Wardrobe.lua above
			-- RefreshPlayerModelAfterApply(): the working reference
			-- (TransmogUniverse.zip) NEVER replays TryOn() for an item
			-- already confirmed by the server, only SetUnit("player") on the
			-- freshly recreated widget. We therefore now use this new
			-- dedicated function here, which ONLY does the recreation +
			-- SetUnit (+ 2D icon refresh), without a manual TryOn loop.
			if WardrobeTransmogFrame.RefreshPlayerModelAfterApply then
				local ok, err = pcall(WardrobeTransmogFrame.RefreshPlayerModelAfterApply, WardrobeTransmogFrame);
				if not ok then
					--print("|cffff0000[TDEBUG]|r WardrobeTransmogFrame:RefreshPlayerModelAfterApply() failed: " .. tostring(err));
				end
			elseif WardrobeTransmogFrame.RefreshPlayerModel then
				local ok, err = pcall(WardrobeTransmogFrame.RefreshPlayerModel, WardrobeTransmogFrame, true);
				if not ok then
					--print("|cffff0000[TDEBUG]|r WardrobeTransmogFrame:RefreshPlayerModel() failed: " .. tostring(err));
				end
			elseif WardrobeTransmogFrame.Update then
				pcall(WardrobeTransmogFrame.Update, WardrobeTransmogFrame, true);
			end
			-- FIX ROUND TRANSMOG-56 (BUG FOUND VIA USER TRACE): this "safety
			-- net" line (inherited from round 40) set self.dirty=true, which
			-- schedules a FULL TransmogFrameMixin:Update() on the very next
			-- native OnUpdate (next frame). But Update() does exactly what
			-- we've been trying to avoid since round 55: Undress() +
			-- manually looping TryOn(...) for EVERY slot. The /tmodeltrace
			-- trace provided by the user (round 55 test) proves it in black
			-- and white: right after EACH of the 4 calls to
			-- RefreshPlayerModelAfterApply(), a full Update()/TryOn() loop
			-- would re-trigger on the next frame and overwrite everything --
			-- completely undoing the "SetUnit only" fix from round 55, which
			-- therefore never had any chance of "sticking". We therefore
			-- remove this call: RefreshPlayerModelAfterApply already handles
			-- the 2D slot icons (slotButton:Update()) and the Apply button,
			-- this safety net is no longer necessary and is even actively
			-- harmful here.
		end
	end

	local function RefreshTransmogModelAfterServerConfirm()
		if WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame.UpdateItems then
			pcall(WardrobeCollectionFrame.ItemsCollectionFrame.UpdateItems, WardrobeCollectionFrame.ItemsCollectionFrame);
		end
		-- FIX ROUND TRANSMOG-53 (insufficient): a single call deferred by
		-- zero seconds (C_Timer.After(0, ...)) was not enough. The problem
		-- persisted even after leaving the message handler's context.
		--
		-- FIX ROUND TRANSMOG-54: TransmogFrameMixin already listens to the
		-- native UNIT_MODEL_CHANGED event and calls RefreshPlayerModel() on
		-- it -- which suggests the client engine needs some time AFTER the
		-- server writes the PLAYER_VISIBLE_ITEM_x_ENTRYID fields before its
		-- internal model state is truly up to date. Our confirmation
		-- (ASMSG_TRANSMOG_APPLIED) may arrive before this native processing
		-- is finished: a single attempt, even deferred by one frame, can
		-- therefore still read stale data.
		--
		-- By analogy with the mechanism already used server-side for a
		-- similar race condition at login (REAPPLY_ON_LOGIN_ATTEMPTS /
		-- REAPPLY_ON_LOGIN_DELAY_MS), we now retry the mannequin refresh
		-- SEVERAL times at increasing delays here, instead of a single fixed-
		-- delay attempt. Even if the first attempts arrive too early, one of
		-- the following attempts (up to 1.5s) should necessarily arrive
		-- after the engine has finished its native processing -- exactly
		-- like when switching tabs and coming back.
		if C_Timer and C_Timer.After then
			C_Timer.After(0, DoRefreshTransmogModel);
			C_Timer.After(0.15, DoRefreshTransmogModel);
			C_Timer.After(0.4, DoRefreshTransmogModel);
			C_Timer.After(0.8, DoRefreshTransmogModel);
			C_Timer.After(1.5, DoRefreshTransmogModel);
		else
			DoRefreshTransmogModel();
		end
	end

	function EventHandler:ASMSG_TRANSMOG_SYNC(msg)
		-- FIX ROUND TRANSMOG-55 (diagnostics): this handler FULLY REPLACES
		-- _applied (wipe + repopulate from msg). If the server sends a SYNC
		-- right after an APPLIED (for example at the same time as a native
		-- equipment event), and that SYNC does not yet contain the new item
		-- (server-side snapshot slightly behind), this handler would
		-- silently ERASE our fix. We therefore systematically log (not just
		-- under /tmodeltrace) the time and raw content received here, to
		-- verify whether this is indeed what's happening.
		--print(string.format("|cffffcc00[TDEBUG55]|r ASMSG_TRANSMOG_SYNC received @ %.3f, msg=%s", GetTime(), tostring(msg)));
		wipe(_applied);
		if msg and msg ~= "" then
			for slotStr, itemStr in msg:gmatch("(%d+):(%d+)") do
				local slotID = tonumber(slotStr);
				local itemID = tonumber(itemStr);
				if slotID and itemID and itemID > 0 then
					_applied[slotID] = itemID;
				end
			end
		end
		FireCustomClientEvent("TRANSMOGRIFY_UPDATE");
		RefreshTransmogModelAfterServerConfirm();
	end

	function EventHandler:ASMSG_TRANSMOG_APPLIED(msg)
		-- FIX ROUND TRANSMOG-40: inline logging (independent of any load
		-- order between files, unlike round 38's external wrapper in
		-- Collection_Compat_Tooltip.lua which only installs if this file is
		-- already loaded) + pcall protection to never let a silent error
		-- interrupt the mannequin refresh.
		--print(string.format("|cff00ff88[TDEBUG40]|r ASMSG_TRANSMOG_APPLIED received @ %.3f, msg=%s", GetTime(), tostring(msg)));
		local slotStr, itemStr = msg:match("(%d+):(%d+)");
		local slotID = tonumber(slotStr);
		local itemID = tonumber(itemStr);
		if slotID then
			if itemID and itemID > 0 then
				_applied[slotID] = itemID;
			else
				_applied[slotID] = nil;
			end
		else
			--print("|cffff0000[TDEBUG40]|r ASMSG_TRANSMOG_APPLIED: malformed message, slotID not found in '" .. tostring(msg) .. "'");
		end
		FireCustomClientEvent("TRANSMOGRIFY_UPDATE");
		local ok, err = pcall(RefreshTransmogModelAfterServerConfirm);
		if ok then
			--print("|cff00ff88[TDEBUG40]|r mannequin refresh triggered without error.");
		else
			--print("|cffff0000[TDEBUG40]|r mannequin refresh ERROR: " .. tostring(err));
		end
	end

	function EventHandler:ASMSG_TRANSMOG_ERROR(msg)
		if UIErrorsFrame then
			UIErrorsFrame:AddMessage(msg or "Unable to transmogrify.", 1.0, 0.1, 0.1);
		end
	end
end

-- ============================================================
-- 25) C_Talent.GetCurrentSpecID: used by Custom_HeirloomCollection.lua to
--     filter by active spec. Universe has its own C_Talent (based on
--     GetActiveTalentGroup, 1 or 2), with no notion of a retail "specID".
--     We provide a harmless alias (nil = no spec filter applied).
-- ============================================================
DIAGv26_CP986 = true;
C_Talent = C_Talent or {}
if not C_Talent.GetCurrentSpecID then
	function C_Talent.GetCurrentSpecID()
		-- Universe has no real notion of a retail specID; 0 matches the
		-- NO_SPEC_FILTER convention used by Custom_HeirloomCollection.lua
		-- (avoids the error "Usage: C_Heirloom.SetClassAndSpecFilters(classID, specID)").
		return 0
	end
end

-- ============================================================
-- 26) LE_PET_JOURNAL_FILTER_*: missing constants (only the
--     LE_MOUNT_JOURNAL_FILTER_* had been added in the previous round).
-- ============================================================
if not LE_PET_JOURNAL_FILTER_COLLECTED then LE_PET_JOURNAL_FILTER_COLLECTED = 1 end
DIAGv26_CP1001 = true;
if not LE_PET_JOURNAL_FILTER_NOT_COLLECTED then LE_PET_JOURNAL_FILTER_NOT_COLLECTED = 2 end

-- ============================================================
-- 27) PET_TYPE_SUFFIX: missing table from Constants.lua (Sirus), used by
--     Custom_PetCollection.lua for the pet type icon.
-- ============================================================
if not PET_TYPE_SUFFIX then
	PET_TYPE_SUFFIX = {
		[1] = "Water",
		[2] = "Humanoid",
		[3] = "Dragon",
		[4] = "Beast",
		[5] = "Critter",
		[6] = "Flying",
		[7] = "Magical",
		[8] = "Mechanical",
		[9] = "Undead",
		[10] = "Elemental",
	}
end

-- ============================================================
-- 28) Filter CVars not registered on the client side (heirloomCollectedFilters,
--     heirloomSourceFilters, toyBoxCollectedFilters, toyBoxSourceFilters):
--     Azeroth Universe's client engine rejects GetCVar/SetCVar with
--     "Couldn't find CVar named ..." for any CVar name not hard-registered
--     client-side (same principle as petJournalTab in the previous round).
--     We intercept GetCVar/SetCVar ONLY for these specific names and
--     redirect them to a Lua table; all other CVar names go through the
--     native functions normally.
-- ============================================================
DIAGv26_CP1032 = true;
local COLLECTION_SHIMMED_CVARS = {
	heirloomCollectedFilters = true,
	heirloomSourceFilters = true,
	toyBoxCollectedFilters = true,
	toyBoxSourceFilters = true,
	petJournalFilters = true,
	petJournalSort = true,
	petJournalSourceFilters = true,
	petJournalTypeFilters = true,
	petJournalExpansionFilters = true,
	mountJournalFactionFilter = true,
	mountJournalGeneralFilters = true,
	mountJournalAbilityFilters = true,
	mountJournalSourcesFilter = true,
	mountJournalTravelingMerchantFilter = true,
	mountJournalShowPlayer = true,
	illusionShowCollected = true,
	illusionShowUncollected = true,
	illusionSourceFilters = true,
	lastTransmogOutfit = true,
	wardrobeShowCollected = true,
	wardrobeShowUncollected = true,
	wardrobeSourceFilters = true,
}
DIAGv26_CP1047 = true;
COLLECTION_CVAR_SHIM_VALUES = COLLECTION_CVAR_SHIM_VALUES or {}

-- PATCH round 80: default values for the Wardrobe's "show
-- collected / uncollected" CVars (and Illusions, same system). Without this
-- seed, GetCVar falls back to "0" (false) as long as the player has never
-- clicked "reset filters", and SetSearchAndFilterAppearances
-- (C_TransmogCollection.lua) UNCONDITIONALLY hides all uncollected items
-- when wardrobeShowUncollected is false -- hence the empty Wardrobe grid
-- (0/N) the first time the tab is shown, until clicking the small cross.
DIAGv26_CP1066 = true;
if COLLECTION_CVAR_SHIM_VALUES.wardrobeShowCollected == nil then
	COLLECTION_CVAR_SHIM_VALUES.wardrobeShowCollected = "1"
end
if COLLECTION_CVAR_SHIM_VALUES.wardrobeShowUncollected == nil then
	COLLECTION_CVAR_SHIM_VALUES.wardrobeShowUncollected = "1"
end
if COLLECTION_CVAR_SHIM_VALUES.illusionShowCollected == nil then
	COLLECTION_CVAR_SHIM_VALUES.illusionShowCollected = "1"
end
if COLLECTION_CVAR_SHIM_VALUES.illusionShowUncollected == nil then
	COLLECTION_CVAR_SHIM_VALUES.illusionShowUncollected = "1"
end

if not COLLECTION_CVAR_SHIM_INSTALLED then
	COLLECTION_CVAR_SHIM_INSTALLED = true

	local RealGetCVar = GetCVar
	local RealSetCVar = SetCVar

	--- Fix Round Transmog-10: non-exhaustive whitelist. Several CVar names
	--- invented by the various ported Collection systems (e.g.
	--- "mountJournalGeneralFilters" called by C_MountJournal.SetDefaultFilters,
	--- "wardrobeShowCollected" by C_TransmogCollection.SetDefaultFilters) WERE
	--- already in COLLECTION_SHIMMED_CVARS but the call still failed with
	--- "Couldn't find CVar named ..." -- symptom observed on the Reset
	--- Filters button (both Mounts AND Wardrobe/Transmog). Rather than
	--- chasing down each invented, not-yet-catalogued CVar name one by one,
	--- we make the safety net generic: if the native call fails (a name
	--- truly unknown to the client engine), that name is automatically
	--- switched over to the fallback table instead of letting the whole
	--- call stack crash (and it's remembered in COLLECTION_SHIMMED_CVARS so
	--- the native call is never retried for that name again).
	function GetCVar(name, ...)
		if COLLECTION_SHIMMED_CVARS[name] then
			return COLLECTION_CVAR_SHIM_VALUES[name] or "0"
		end
		local ok, result = pcall(RealGetCVar, name, ...)
		if ok then
			return result
		end
		COLLECTION_SHIMMED_CVARS[name] = true
		return COLLECTION_CVAR_SHIM_VALUES[name] or "0"
	end

	function SetCVar(name, value, ...)
		if COLLECTION_SHIMMED_CVARS[name] then
			COLLECTION_CVAR_SHIM_VALUES[name] = tostring(value)
			return
		end
		local ok = pcall(RealSetCVar, name, value, ...)
		if not ok then
			COLLECTION_SHIMMED_CVARS[name] = true
			COLLECTION_CVAR_SHIM_VALUES[name] = tostring(value)
		end
	end

	if GetCVarBool then
		local RealGetCVarBool = GetCVarBool
		function GetCVarBool(name, ...)
			if COLLECTION_SHIMMED_CVARS[name] then
				local value = COLLECTION_CVAR_SHIM_VALUES[name]
				return value == "1" or value == "true"
			end
			local ok, result = pcall(RealGetCVarBool, name, ...)
			if ok then
				return result
			end
			COLLECTION_SHIMMED_CVARS[name] = true
			local value = COLLECTION_CVAR_SHIM_VALUES[name]
			return value == "1" or value == "true"
		end
	end
end

--- Fix Round Transmog-10: diagnostic command. Several recent bug reports
--- (rounds 8-9) showed "(a nil value)" errors on functions/tables that ARE
--- indeed present in this file as delivered (checked line by line before
--- every delivery) -- the typical symptom of a client still loading an
--- outdated/truncated version of Collection_Compat.lua. This command lets
--- you verify IN-GAME, unambiguously, whether the last few rounds' fixes are
--- actually active.
DIAGv26_CP1149 = true;
SLASH_COLLECTIONCOMPATCHECK1 = "/ccheck"
SlashCmdList = SlashCmdList or {}
SlashCmdList["COLLECTIONCOMPATCHECK"] = function()
	local function report(label, isPresent)
		if isPresent then
			print("|cff00ff00[ccheck] OK|r - " .. label)
		else
			print("|cffff0000[ccheck] MISSING|r - " .. label .. " (Collection_Compat.lua file is outdated or truncated, copy the patch again and fully restart the client)")
		end
	end
	print("|cffffcc00=== Collection_Compat.lua: diagnostic ===|r");
	report("TRANSMOG_INVALID_CODES (round 7)", TRANSMOG_INVALID_CODES ~= nil)
	report("C_Transmog.GetSlotInfo (round 6)", C_Transmog ~= nil and C_Transmog.GetSlotInfo ~= nil)
	report("C_Transmog.GetSlotVisualInfo real (round 8)", C_Transmog ~= nil and C_Transmog.GetSlotVisualInfo ~= nil)
	report("C_Item.GetBaseItemTransmogInfo real (round 8)", C_Item ~= nil and C_Item.GetBaseItemTransmogInfo ~= nil)
	report("_AnimateTexCoords (round 8)", _AnimateTexCoords ~= nil)
	report("PET_TYPE_SUFFIX (earlier round)", PET_TYPE_SUFFIX ~= nil)
	report("C_Talent.GetCurrentSpecID (earlier round)", C_Talent ~= nil and C_Talent.GetCurrentSpecID ~= nil)
	report("COLLECTION_ITEM_HYPERLINK_FORMAT (earlier round)", COLLECTION_ITEM_HYPERLINK_FORMAT ~= nil)
	report("Generic/pcall CVar shim (round 10)", COLLECTION_CVAR_SHIM_INSTALLED == true)
	print("|cffffcc00=== end of diagnostic ===|r");
end

-- ============================================================
-- 29) CHAR_COLLECTION_*: constants from Constants.lua (Sirus), entirely
--     absent from Universe. Used by C_MountJournal/C_PetJournal/
--     C_ToyBox/C_TransmogCollection.lua for the ACMSG_C_A_F / ACMSG_C_R_F
--     protocol (add/remove favorites). Without them, string.format received
--     nil instead of a number -> crash on every click on the "Favorite"
--     star (mounts/pets/toys/appearances/relics).
-- ============================================================
DIAGv26_CP1180 = true;
if not CHAR_COLLECTION_MOUNT then CHAR_COLLECTION_MOUNT = 0 end
if not CHAR_COLLECTION_PET then CHAR_COLLECTION_PET = 1 end
if not CHAR_COLLECTION_APPEARANCE then CHAR_COLLECTION_APPEARANCE = 2 end
if not CHAR_COLLECTION_TOY then CHAR_COLLECTION_TOY = 3 end
if not CHAR_COLLECTION_HEIRLOOM then CHAR_COLLECTION_HEIRLOOM = 4 end
if not CHAR_COLLECTION_ILLUSION then CHAR_COLLECTION_ILLUSION = 5 end

-- ============================================================
-- 30) Missing localization strings (Wardrobe tooltips)
-- ============================================================
if not WEAPON_ENCHANTMENT then WEAPON_ENCHANTMENT = "Weapon Enchantment" end
if not WARDROBE_NO_SEARCH then WARDROBE_NO_SEARCH = "No results for this search" end

-- ============================================================
-- 31) FIRST_/LAST_TRANSMOG_COLLECTION_WEAPON_TYPE: constants from
--     Constants.lua (Sirus), missing (same family as the
--     FIRST_/LAST_TRANSMOG_COLLECTION_SUB_CATEGORY added above). Without
--     them, WardrobeItemsCollectionMixin:SetActiveSlot crashed with
--     "'for' initial value must be a number" as soon as you clicked a
--     weapon slot in the Wardrobe tab.
-- ============================================================
DIAGv26_CP1201 = true;
if not FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE then FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE = 12 end
if not LAST_TRANSMOG_COLLECTION_WEAPON_TYPE then LAST_TRANSMOG_COLLECTION_WEAPON_TYPE = 30 end

-- ============================================================
-- 32) SpellBook_GetSpellIndex: present in Sirus\FrameXML\SpellBookFrame.lua,
--     absent from Universe's (older) version. Used by Custom_ToyBox.lua
--     (ToySpellButton_OnDrag) to drag a toy from the Codex onto an action
--     bar. We write a standalone version that does NOT use
--     C_SpellBook.GetSpellIDFromLink (absent from Universe) but extracts the
--     ID directly from the link via a pattern, the same way the rest of the
--     client already does elsewhere (e.g. C_Item.GetItemIDFromString).
-- ============================================================
if not SpellBook_GetSpellIndex then
	function SpellBook_GetSpellIndex(spellID, bookType)
		if not spellID or not bookType then
			return;
		end

		for tabIndex = 1, GetNumSpellTabs() do
			local _, _, offset, numSpells = GetSpellTabInfo(tabIndex);

			for s = offset + 1, numSpells + offset do
				local spellIndex = (bookType == BOOKTYPE_PET) and s or (GetKnownSlotFromHighestRankSlot and GetKnownSlotFromHighestRankSlot(s) or s);
				local spellLink = GetSpellLink(spellIndex, bookType);

				if spellLink then
					local linkedSpellID = tonumber(spellLink:match("spell:(%d+)"));
					if linkedSpellID == spellID then
						return spellIndex;
					end
				end
			end
		end
	end
end


-- ============================================================
-- 34) Missing localization strings (GlobalStrings.lua) used by
--     C_TransmogCollection.lua / CollectionsUtil.lua for appearance/illusion
--     tooltips and collection messages. Confirmed missing by a real crash
--     (COLLECTION_ILLUSION_HYPERLINK_FORMAT, bad argument #1 to 'format');
--     the others are added proactively since they are used in the same
--     file / the same tooltip function (CollectionsUtil.lua:SetAppearanceTooltip).
-- ============================================================
DIAGv26_CP1247 = true;
if not COLLECTION_ADD_FORMAT then COLLECTION_ADD_FORMAT = "Appearance %s added to your collection." end
if not COLLECTION_REMOVE_FORMAT then COLLECTION_REMOVE_FORMAT = "Appearance %s removed from your collection." end
if not COLLECTION_ITEM_HYPERLINK_FORMAT then COLLECTION_ITEM_HYPERLINK_FORMAT = "|cffff80ff|Hcollection:2:%d|h[Appearances: %s]|h|r" end
if not COLLECTION_ILLUSION_ADD_FORMAT then COLLECTION_ILLUSION_ADD_FORMAT = "Illusion %s added to your collection." end
if not COLLECTION_ILLUSION_HYPERLINK_FORMAT then COLLECTION_ILLUSION_HYPERLINK_FORMAT = "|cffff80ff|Hcollection:5:%d|h[Illusion: %s]|h|r" end
if not WARDROBE_TOOLTIP_BOSS_DROP_FORMAT then WARDROBE_TOOLTIP_BOSS_DROP_FORMAT = "Boss drop: %1$s" end
if not WARDROBE_TOOLTIP_BOSS_DROP_FORMAT_WITH_DIFFICULTIES then WARDROBE_TOOLTIP_BOSS_DROP_FORMAT_WITH_DIFFICULTIES = "Boss drop: %1$s (%2$s)" end
if not WARDROBE_TOOLTIP_CYCLE then WARDROBE_TOOLTIP_CYCLE = "You can cycle through items with the Tab key." end
if not WARDROBE_TOOLTIP_ENCOUNTER_SOURCE then WARDROBE_TOOLTIP_ENCOUNTER_SOURCE = "%s (%s)" end
if not WARDROBE_TOOLTIP_TRANSMOGRIFIER then WARDROBE_TOOLTIP_TRANSMOGRIFIER = "Visit a transmogrifier to change the appearance of your equipment." end
if not WARDROBE_TOOLTIP_TRANSMOGRIFIER_CLICKABLE then WARDROBE_TOOLTIP_TRANSMOGRIFIER_CLICKABLE = "Right-click to choose this item." end
if not WARDROBE_TOOLTIP_TRANSMOGRIFIER_UNUSABLE then WARDROBE_TOOLTIP_TRANSMOGRIFIER_UNUSABLE = "Enchant effects and illusions are not displayed on the selected weapon appearance." end
if not WARDROBE_ALTERNATE_ITEMS then WARDROBE_ALTERNATE_ITEMS = "Other items that unlock this slot:" end
if not RETRIEVING_ITEM_INFO then RETRIEVING_ITEM_INFO = "Retrieving item information" end
if not PLAYER_LIST_DELIMITER then PLAYER_LIST_DELIMITER = ", " end

-- ============================================================
-- PATCH Collection (fix round 20): missing constants/icons, discovered
-- following the crash CollectionsUtil.lua:479 "attempt to concatenate global
-- 'WARDROBE_TOOLTIP_CYCLE_ARROW_ICON' (a nil value)" when hovering over an
-- item with several sources/illusions (SetIllusionTooltip). Values taken
-- verbatim from Sirus\FrameXML\Constants.lua.
-- ============================================================
DIAGv26_CP1270 = true;
if not WARDROBE_TOOLTIP_CYCLE_ARROW_ICON then WARDROBE_TOOLTIP_CYCLE_ARROW_ICON = "|TInterface\\Transmogrify\\transmog-tooltip-arrow:12:11:-1:-1|t" end
if not WARDROBE_TOOLTIP_CYCLE_SPACER_ICON then WARDROBE_TOOLTIP_CYCLE_SPACER_ICON = "|TInterface\\Common\\spacer:12:11:-1:-1|t" end
if not ENCHANT_EMPTY_SLOT_FILEDATAID then ENCHANT_EMPTY_SLOT_FILEDATAID = "Interface\\Icons\\INV_Scroll_05" end
if not QUESTION_MARK_ICON then QUESTION_MARK_ICON = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK.BLP" end
-- NB: WARDROBE_OTHER_ITEMS is used by CollectionsUtil.lua but is NOT DEFINED
-- ANYWHERE, even on the Sirus side (checked) - this is a latent bug already
-- present in the original code, but harmless (tooltip:AddLine(nil,...)
-- does not crash, it just shows a blank line). We take the opportunity to
-- give it a real translation rather than reproducing the bug identically.
if not WARDROBE_OTHER_ITEMS then WARDROBE_OTHER_ITEMS = "Other items using this appearance:" end

-- ============================================================
-- PATCH Collection (fix round 22): Heirloom crashes.
-- Error 1: Custom_HeirloomCollection.lua:694 "bad argument #1 to 'format'"
--   -> HEIRLOOMS_CLASS_FILTER_FORMAT / HEIRLOOMS_CLASS_SPEC_FILTER_FORMAT
--      missing. Values taken verbatim from Sirus\FrameXML\GlobalStrings.lua.
-- ============================================================
DIAGv26_CP1287 = true;
if not HEIRLOOMS_CLASS_FILTER_FORMAT then HEIRLOOMS_CLASS_FILTER_FORMAT = "|c%s%s|r" end
if not HEIRLOOMS_CLASS_SPEC_FILTER_FORMAT then HEIRLOOMS_CLASS_SPEC_FILTER_FORMAT = "|c%s%s|r (%s)" end

-- ============================================================
-- PATCH Collection (fix round 22): Heirloom crash - Error 2
-- "Usage: C_Heirloom.SetClassAndSpecFilters(classID, specID)".
--
-- Diagnostics: Custom_HeirloomCollection.lua (the Heirlooms filter's "Class"
-- dropdown) does "local _, classDisplayName, classID = UnitClass("player")"
-- to get the player's NUMERIC classID when no class filter is active. Sirus
-- provides a CUSTOM UnitClass() (Utils\C_Unit.lua) that adds this numeric
-- classID as a 3rd return value (absent from the standard native WotLK
-- 3.3.5 UnitClass, which only returns 2 values: localized name + English
-- token). Universe never had this fix -> classID was always nil -> clicking
-- a specialization sent SetClassAndSpecFilters(nil, specID), rejected by
-- native validation (which requires two NUMBERS).
--
-- We port the same fix as Sirus, applied GLOBALLY (as Sirus itself does):
-- the 2 original return values stay unchanged at the front of the list, we
-- just add classID/classFlag as the 3rd/4th value, so no existing caller
-- (which only reads the first 2 values) is affected. Relies on
-- S_CLASS_SORT_ORDER, already present on the Universe side
-- (SharedXML\SharedConstants.lua).
-- ============================================================
DIAGv26_CP1312 = true;
do
	local NativeUnitClass = UnitClass

	_G.UnitClass = function(unit)
		local className, classToken = NativeUnitClass(unit)

		local classID, classFlag
		if S_CLASS_SORT_ORDER and classToken then
			for id, classInfo in pairs(S_CLASS_SORT_ORDER) do
				if classInfo[2] == classToken then
					classID = id
					classFlag = classInfo[1]
					break
				end
			end
		end

		return className, classToken, classID, classFlag
	end
end

-- ============================================================
-- PATCH Collection (fix round 23): Heirloom crash - Error 3
-- "bad argument #2 to 'format' (string expected, got nil)" in
-- UpdateClassFilterDropDownText -> RAID_CLASS_COLORS[classFile].colorStr.
--
-- Diagnostics: Universe's GLOBAL RAID_CLASS_COLORS table
-- (FrameXML\Constants.lua) only contains r/g/b per class, NEVER a
-- precomputed "colorStr" field (unlike Sirus). Universe does have a version
-- WITH colorStr, but it is LOCAL to SharedXML\Util.lua (so invisible
-- elsewhere) and serves a different internal purpose. We therefore complete
-- the GLOBAL table by adding colorStr to every entry, computed from r/g/b.
-- ============================================================
DIAGv26_CP1345 = true;
if RAID_CLASS_COLORS then
	for classFile, colorInfo in pairs(RAID_CLASS_COLORS) do
		if type(colorInfo) == "table" and not colorInfo.colorStr then
			colorInfo.colorStr = string.format("ff%02x%02x%02x", (colorInfo.r or 1) * 255, (colorInfo.g or 1) * 255, (colorInfo.b or 1) * 255)
		end
	end
end

-- ============================================================
-- PATCH Collection (fix round 30): Wardrobe tooltip crash -
-- "attempt to index local 'nameColor' (a nil value)" / "attempt to index
-- field '?' (a nil value)" in CollectionsUtil.lua:149/267
-- (GetAppearanceNameTextAndColor / SetAppearanceTooltip).
--
-- Diagnostics: this code (ported from Sirus) expects
-- ITEM_QUALITY_COLORS[quality].color, a Color object with :GetRGB(). The
-- native Universe table (FrameXML\UIParent.lua) only builds r/g/b/hex (no
-- .color field), and only covers qualities -1 to 6: quality 7
-- (Heirlooms/Relics, used by some Wardrobe appearances) does not exist in
-- the table at all. Result: the tooltip crashes as soon as you hover over a
-- quality-7 item, and for qualities 0-6 the missing .color field silently
-- returns nil -> crash a bit further on nameColor:GetRGB(). This crash,
-- happening DURING UpdateItems (automatic grid hover), interrupts the
-- rendering of the rest of the page -> cascading black boxes and missing
-- models. We therefore complete the existing table with a Color object, and
-- add the missing entry 7 (classic Heirloom/Relic color: light blue).
-- ============================================================
DIAGv26_CP1371 = true;
if ITEM_QUALITY_COLORS and CreateColor then
	for quality, info in pairs(ITEM_QUALITY_COLORS) do
		if type(info) == "table" and not info.color then
			info.color = CreateColor(info.r or 1, info.g or 1, info.b or 1)
		end
	end
	if not ITEM_QUALITY_COLORS[7] then
		ITEM_QUALITY_COLORS[7] = { r = 0, g = 0.8, b = 1, hex = "|cff00ccff" }
	end
	if not ITEM_QUALITY_COLORS[7].color then
		ITEM_QUALITY_COLORS[7].color = CreateColor(ITEM_QUALITY_COLORS[7].r or 0, ITEM_QUALITY_COLORS[7].g or 0.8, ITEM_QUALITY_COLORS[7].b or 1)
	end
end

-- ============================================================
-- PATCH Collection (fix round 24): Heirloom crash - Error 4
-- "attempt to call global 'GetSpecializationNameForSpecID' (a nil value)".
-- Sirus function missing on the Universe side (Utils\C_Talent.lua). Universe
-- already has the data table it needs (S_CALSS_SPECIALIZATION_DATA,
-- SharedXML\SharedConstants.lua) - only the accessor function was missing.
-- Ported verbatim from Sirus.
-- ============================================================
DIAGv26_CP1393 = true;
if not GetSpecializationNameForSpecID then
	function GetSpecializationNameForSpecID(specID)
		if type(specID) ~= "number" then
			return ""
		end

		if S_CALSS_SPECIALIZATION_DATA then
			for classID, specList in pairs(S_CALSS_SPECIALIZATION_DATA) do
				for specIndex, specInfo in ipairs(specList) do
					if specInfo[1] == specID then
						return specInfo[2]
					end
				end
			end
		end

		return ""
	end
end

-- ============================================================
-- PATCH Collection (fix round 89): Wardrobe crash -
-- "attempt to call global 'StringSplitEx' (a nil value)" in
-- Utils\C_TransmogCollection.lua:2131 (ASMSG_C_I_GET_MODELS handler,
-- response from the new Eluna script tracking collected Transmog
-- appearances). StringSplitEx is a Sirus utility function
-- (SharedXML\StringUtil.lua) never ported to the Universe side - only that
-- one source file was never copied over, even though several Sirus Utils
-- call it as if it were an always-available global.
-- Ported verbatim from Sirus (SharedXML/StringUtil.lua): a simple wrapper
-- around string.split (already used successfully elsewhere in this client,
-- including in C_TransmogCollection.lua itself via strsplit) that first
-- strips a trailing delimiter to avoid a spurious empty last piece.
-- ============================================================
DIAGv26_CP1428 = true;
if not StringSplitEx then
	function StringSplitEx(delimiter, str, pieces)
		str = string.gsub(str, strconcat(delimiter, "$"), "")
		if str ~= "" then
			return string.split(delimiter, str, pieces)
		end
	end
end

-- ============================================================
-- PATCH Collection (fix round 90): Wardrobe crash -
-- "attempt to call global 'AddChatTyppedMessage' (a nil value)" in
-- Utils\C_TransmogCollection.lua:2199 (the "Appearance added to your
-- collection" chat message triggered by ASMSG_C_I_ADD_MODEL, itself now
-- sent by the Eluna script tracking Transmog appearances as soon as a
-- player equips a new item - see round 88/89). Same class of bug as
-- StringSplitEx (round 89): AddChatTyppedMessage is a Sirus utility function
-- (FrameXML\ChatFrame.lua) never ported to the Universe side, called as an
-- always-available global by several Sirus Utils (C_Heirloom.lua,
-- C_ToyBox.lua, C_TransmogCollection.lua x3).
-- Ported verbatim from Sirus (FrameXML/ChatFrame.lua). Its dependencies
-- (ChatTypeInfo, CHAT_FRAMES, SendSystemMessage, tIndexOf) already all exist
-- in the base Universe client - only this function itself was missing.
-- ============================================================
DIAGv26_CP1454 = true;
if not AddChatTyppedMessage then
	function AddChatTyppedMessage(messageType, message)
		if messageType == "SYSTEM" then
			SendSystemMessage(message)
			return
		end

		local info = ChatTypeInfo[messageType];
		if not info then
			error(string.format("AddChatTyppedMessage: unknown messageType (%s)", messageType), 2)
			return;
		end

		for _, chatFrameName in ipairs(CHAT_FRAMES) do
			local frame = _G[chatFrameName];
			if tIndexOf(frame.messageTypeList, messageType) then
				frame:AddMessage(message, info.r or 1, info.g or 1, info.b or 0, info.id or 1)
			end
		end
	end
end

-- ============================================================
-- PATCH Collection (round 101): missing custom classes in the "Class"
-- filter of the Heirlooms tab.
--
-- Diagnostics: Custom_HeirloomCollection.lua builds this menu via
-- "for i = 1, GetNumClasses() do ... GetClassInfo(i) ... end", and for the
-- current selection via C_CreatureInfo.GetClassInfo(classID)
-- (Utils\C_CreatureInfo.lua). All 3 of these functions rely on
-- S_CLASS_SORT_ORDER (SharedXML\SharedConstants.lua), which only lists 11
-- classes (WARRIOR..WARLOCK, DRUID=11, DEMONHUNTER=13) -- missing: BloodMage
-- (10), Knight (12), Monk (14), Tamer (15), Hero (16), Evoker (17),
-- Necromancer (18), Venomancer (19), Pyromancer (20), Chronomancer (21),
-- Geomancer (22), ChaosRavager (23), i.e. the server's 12 custom classes
-- (cf. the Classes enum, SharedDefines.h provided by the user). Worse:
-- S_CLASS_SORT_ORDER is explicitly LOCKED read-only (table.lockTable,
-- SharedConstants.lua) -- any attempt to write new entries into it is
-- silently ignored (Extensions\table.lua: __newindex just prints a
-- warning).
--
-- On the other hand, Universe already has, on the FrameXML\Constants.lua
-- side, a complete and UNLOCKED dataset for all 23 classes + UNKCLASS:
-- RAID_CLASS_COLORS (colors), CLASS_ICON_TCOORDS (icons) and
-- CLASS_SORT_ORDER (list of tokens) are already filled in for BLOODMAGE,
-- KNIGHT, MONK, TAMER, HERO, EVOKER, NECROMANCER, VENOMANCER, PYROMANCER,
-- CHRONOMANCER, GEOMANCER and CHAOSRAVAGER -- only the classID -> token
-- mapping (used by the Heirlooms menu) was missing. We therefore build our
-- own complete (unlocked) table and replace GetNumClasses/GetClassInfo/
-- C_CreatureInfo.GetClassInfo to rely on it, without ever touching
-- S_CLASS_SORT_ORDER.
--
-- The EN names come from LOCALIZED_CLASS_NAMES_MALE/FEMALE (natively filled
-- by FillLocalizedClassList, Constants.lua, from the same compiled data as
-- RAID_CLASS_COLORS/CLASS_ICON_TCOORDS -- so already available for all 23
-- classes); a fallback name (standard EN translation) is provided in case an
-- entry is still missing regardless.
--
-- Specializations (per-class submenu) remain unchanged: they rely on
-- S_CALSS_SPECIALIZATION_DATA (unlocked, not touched here), which only
-- covers the 11 original classes. For the 12 custom classes,
-- GetNumSpecializationsForClassID natively returns 0 (fallback code already
-- present in EJ_CompatLate.lua): the menu then simply shows the class with
-- no specialization sub-list, without error.
-- ============================================================
DIAGv26_CP1519 = true;
do
	local CLASS_ID_TO_TOKEN = {
		[1]  = "WARRIOR",
		[2]  = "PALADIN",
		[3]  = "HUNTER",
		[4]  = "ROGUE",
		[5]  = "PRIEST",
		[6]  = "DEATHKNIGHT",
		[7]  = "SHAMAN",
		[8]  = "MAGE",
		[9]  = "WARLOCK",
		[10] = "BLOODMAGE",
		[11] = "DRUID",
		[12] = "KNIGHT",
		[13] = "DEMONHUNTER",
		[14] = "MONK",
		[15] = "TAMER",
		[16] = "HERO",
		[17] = "EVOKER",
		[18] = "NECROMANCER",
		[19] = "VENOMANCER",
		[20] = "PYROMANCER",
		[21] = "CHRONOMANCER",
		[22] = "GEOMANCER",
		[23] = "CHAOSRAVAGER",
	};

	-- EN fallback name, used only if LOCALIZED_CLASS_NAMES_MALE/FEMALE does
	-- not yet know the token (safety net).
	local FALLBACK_CLASS_NAME_EN = {
		WARRIOR      = "Warrior",
		PALADIN      = "Paladin",
		HUNTER       = "Hunter",
		ROGUE        = "Rogue",
		PRIEST       = "Priest",
		DEATHKNIGHT  = "Death Knight",
		SHAMAN       = "Shaman",
		MAGE         = "Mage",
		WARLOCK      = "Warlock",
		BLOODMAGE    = "Blood Mage",
		DRUID        = "Druid",
		KNIGHT       = "Knight",
		DEMONHUNTER  = "Demon Hunter",
		MONK         = "Monk",
		TAMER        = "Tamer",
		HERO         = "Hero",
		EVOKER       = "Evoker",
		NECROMANCER  = "Necromancer",
		VENOMANCER   = "Venomancer",
		PYROMANCER   = "Pyromancer",
		CHRONOMANCER = "Chronomancer",
		GEOMANCER    = "Geomancer",
		CHAOSRAVAGER = "Chaos Ravager",
	};

	local NUM_CUSTOM_CLASSES = 23;

	local function ResolveClassName(token, useFemale)
		local pool = useFemale and LOCALIZED_CLASS_NAMES_FEMALE or LOCALIZED_CLASS_NAMES_MALE;
		local name = pool and pool[token];
		if not name or name == "" then
			name = FALLBACK_CLASS_NAME_EN[token];
		end
		return name;
	end

	function GetNumClasses()
		return NUM_CUSTOM_CLASSES;
	end

	function GetClassInfo(index, declension)
		local token = CLASS_ID_TO_TOKEN[index];
		if not token then
			return;
		end

		local className;
		if declension then
			local gender = UnitSex("player");
			className = ResolveClassName(token, gender == 3);
		else
			className = ResolveClassName(token, false);
		end

		local classFlag = bit.lshift(1, index - 1);
		return className, token, index, classFlag;
	end

	C_CreatureInfo = C_CreatureInfo or {};
	function C_CreatureInfo.GetClassInfo(class)
		local token = CLASS_ID_TO_TOKEN[class];
		if not token then
			return;
		end

		local nameMale = ResolveClassName(token, false);
		local nameFemale = ResolveClassName(token, true);
		local classFlag = bit.lshift(1, class - 1);

		local ClassInfo = {};
		ClassInfo.classFile = token;
		ClassInfo.className = nameMale;
		ClassInfo.classID = class;
		ClassInfo.classFlag = classFlag;
		ClassInfo.localizeName = {
			male = nameMale,
			female = nameFemale,
		};

		return ClassInfo;
	end

	-- Same fix for the UnitClass shim (round 92, earlier in this file): its
	-- classID resolution went through S_CLASS_SORT_ORDER, so a player whose
	-- class is one of the 12 custom classes ended up with a nil classID
	-- (UnitClass("player") -> classID not found), preventing their own class
	-- from being selected by default in the Heirlooms filter. We extend it
	-- to cover all 23 classes.
	local CLASS_TOKEN_TO_ID = {};
	for id, token in pairs(CLASS_ID_TO_TOKEN) do
		CLASS_TOKEN_TO_ID[token] = id;
	end

	local PreviousUnitClass = _G.UnitClass;
	_G.UnitClass = function(unit)
		local className, classToken, classID, classFlag = PreviousUnitClass(unit);
		if not classID and classToken and CLASS_TOKEN_TO_ID[classToken] then
			classID = CLASS_TOKEN_TO_ID[classToken];
			classFlag = bit.lshift(1, classID - 1);
		end
		return className, classToken, classID, classFlag;
	end
end

-- ============================================================
-- PATCH Collection (round 108): Wardrobe tutorial help texts (HelpPlate,
-- "i" icon). HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_1 through _9 are
-- referenced by Custom_Wardrobe.lua but were not defined anywhere on the
-- Universe side (only in Russian, in Sirus/GlobalStrings.lua) -> ToolTipText
-- = nil -> empty help bubbles. EN translation from the original Russian text.
-- ============================================================
DIAGv26_CP1661 = true;
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_1 = "Transmogrification lets you change the appearance of your equipment. But there are a few important points to know.\n\n1. Once Transmogrification is done, you will no longer be able to sell the items back to a vendor. This applies to both the item whose appearance you changed and the one whose appearance you used.\n\n2. If you destroy or sell an item with a return or exchange timer, you will lose the appearance associated with the Transmogrification.\n\n3. After Transmogrification, both items become Soulbound. This also applies to Heirloom items (armor and weapons).\n\n4. Applying a visual enchant to a weapon also makes it Soulbound.\n\n5. The Transmogrification effect is removed from Heirloom items sent by mail.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_2 = "This counter shows the number of item appearances you have collected. The number displayed varies depending on the selected slot and item type.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_3 = "To find the appearance of an item you're interested in, start typing its name in the \"Search\" field.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_4 = "Here you can choose the acquisition source of the item appearances you have already obtained.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_5 = "Here you can enable/disable the help window display for the Transmogrification of the selected item type. If the help window is enabled, the \"Full Rules\" button will let you access detailed information about all Transmogrification rules in the encyclopedia.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_6 = "Here you can save all your outfits.\n\nChoose the desired appearances for your items, then click \"New Outfit\". Give it a unique name and click \"Apply\". Your outfit is now saved, and you'll be able to use it later to quickly switch your Transmogrification.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_7 = "Here you can select the item you want to give a new appearance.\n\nTo cancel the changes for a particular item, right-click on it or click the arrow that appears next to it.\n\nIf you want to cancel the changes for all items at once, click the arrow at the top right.\n\nNote that bulk cancellation is only possible as long as the Transmogrification service has not been paid for.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_8 = "Here you can choose the desired item appearance type.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_9 = "All your item appearances matching the filters and search are shown here.\n\nTo place an appearance at the top of the list, add it to your Favorites. To do this, right-click the item and select \"Add to Favorites\".";

DIAGv26_END = true;
