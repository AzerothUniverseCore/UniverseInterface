-- Collection_Compat_Tooltip.lua
-- Missing GameTooltip methods (Sirus\FrameXML\GameTooltip.lua,
-- GameTooltipMixin), copied verbatim. Must load AFTER GameTooltip.xml
-- (the global GameTooltip widget doesn't exist yet before that), so this
-- file is placed just before Custom_Collections.xml and not inside
-- Collection_Compat.lua.
-- ============================================================
-- ROUND Transmog-3: GameTooltip:SetText safety guard. Error observed when
-- hovering over Transmogrifier elements: "[string \"*:OnEnter\"]:2: Usage:
-- GameTooltip:SetText(\"text\" [, color])" -- this native error (the C side
-- validates argument types) triggers as soon as an OnEnter script passes it
-- anything other than a string (nil most of the time, e.g. a global
-- constant not defined on this client). Rather than hunting down every
-- single fragile call site one by one in the very large Custom_Wardrobe.lua
-- (2700+ lines, never really exercised before this round), we harden
-- SetText itself on this specific frame: if the caller doesn't provide a
-- string, we do nothing instead of crashing.
-- ============================================================
if GameTooltip and not GameTooltip.__CollectionSetTextGuarded then
	local CollectionCompat_OrigSetText = GameTooltip.SetText;
	function GameTooltip:SetText(text, ...)
		if type(text) ~= "string" then
			return;
		end
		return CollectionCompat_OrigSetText(self, text, ...);
	end
	GameTooltip.__CollectionSetTextGuarded = true;
end

if GameTooltip and not GameTooltip.SetToyByItemID then
	function GameTooltip:SetToyByItemID(itemID)
		if type(itemID) == "string" then
			itemID = tonumber(itemID)
		end
		if type(itemID) ~= "number" then
			return false
		end
		self.isToyByItemID = true
		self:SetHyperlink(string.format("item:%d", itemID))
		self.isToyByItemID = nil
		return true
	end
end

if GameTooltip and not GameTooltip.SetHeirloomByItemID then
	function GameTooltip:SetHeirloomByItemID(itemID)
		if type(itemID) == "string" then
			itemID = tonumber(itemID)
		end
		if type(itemID) ~= "number" then
			return false
		end
		self.isHeirloomItemID = true
		self:SetHyperlink(string.format("item:%d", itemID))
		self.isHeirloomItemID = nil
		return true
	end
end

-- FIX: GameTooltip:SetItemByID does not exist natively on this client
-- (method absent on this WotLK 3.3.5 build), which crashed
-- TransmogrifierClient.lua (item button, OnEnter) with "attempt to call
-- method 'SetItemByID' (a nil value)". Same pattern as SetToyByItemID /
-- SetHeirloomByItemID above: we redirect to SetHyperlink.
if GameTooltip and not GameTooltip.SetItemByID then
	function GameTooltip:SetItemByID(itemID)
		if type(itemID) == "string" then
			itemID = tonumber(itemID)
		end
		if type(itemID) ~= "number" then
			return false
		end
		self:SetHyperlink(string.format("item:%d", itemID))
		return true
	end
end

-- ============================================================
-- PATCH round Transmog-26: GameTooltip:SetTransmogrifyItem does not exist on
-- this client (retail method absent on this WotLK 3.3.5 build). It is
-- called by Custom_Wardrobe.lua:513 (TransmogSlotButtonMixin:OnEnter, AFTER
-- GameTooltip:SetInventoryItem) to append a line of info about the pending/
-- revertible appearance to the hovered slot's tooltip, and crashed with
-- "attempt to call method 'SetTransmogrifyItem' (a nil value)".
-- Unlike SetItemByID/SetHeirloomByItemID above, we do NOT call SetHyperlink
-- here: the equipped item's tooltip is already shown by SetInventoryItem
-- just before, so we simply ADD the info lines (same logic as the illusion
-- branch a bit further up in Custom_Wardrobe.lua, which already uses
-- TRANSMOGRIFY_FONT_COLOR / WILL_BE_TRANSMOGRIFIED_HEADER /
-- TRANSMOGRIFY_TOOLTIP_REVERT - these globals therefore already exist fine
-- on this client).
-- ============================================================
if GameTooltip and not GameTooltip.SetTransmogrifyItem then
	function GameTooltip:SetTransmogrifyItem(itemID, hasPending, hasUndo)
		if type(itemID) == "string" then
			itemID = tonumber(itemID)
		end
		if hasUndo then
			GameTooltip:AddLine(TRANSMOGRIFY_TOOLTIP_REVERT, TRANSMOGRIFY_FONT_COLOR.r, TRANSMOGRIFY_FONT_COLOR.g, TRANSMOGRIFY_FONT_COLOR.b)
		elseif hasPending and type(itemID) == "number" and itemID > 0 then
			GameTooltip:AddLine(WILL_BE_TRANSMOGRIFIED_HEADER, TRANSMOGRIFY_FONT_COLOR.r, TRANSMOGRIFY_FONT_COLOR.g, TRANSMOGRIFY_FONT_COLOR.b)
			local name = GetItemInfo(itemID)
			if name then
				GameTooltip:AddLine(name, 1.0, 1.0, 1.0)
			end
		end
		GameTooltip:Show()
		return true
	end
end

-- ============================================================
-- PKBT_ButtonMixin:OnLoad / :InitButton: Universe does
-- PKBT_ButtonMixin = CreateFromMixins(ThreeSliceButtonMixin), but
-- ThreeSliceButtonMixin (SharedXML\SharedUIPanelTemplates.lua on the Sirus
-- side) does not exist on the Universe side -> PKBT_ButtonMixin never had an
-- :OnLoad, which crashes any PKBT button whose XML script calls
-- self:OnLoad() (e.g. WardrobeFrameHelpFrameKnowledgeBaseButton, the help
-- button of the transmogrifier NPC - NOT the Codex's Wardrobe tab). Minimal
-- stub: just positions the 3-slice atlas if available.
-- IMPORTANT: this fix must load AFTER SharedXML\SharedUIPanelPKBTTemplates.xml
-- (which defines PKBT_ButtonMixin) - a first attempt placed in
-- Collection_Compat.lua (loads too early) therefore did nothing.
-- ============================================================
if PKBT_ButtonMixin then
	if not PKBT_ButtonMixin.InitButton then
		function PKBT_ButtonMixin:InitButton()
			-- no-op: see OnLoad below.
		end
	end
	if not PKBT_ButtonMixin.OnLoad then
		function PKBT_ButtonMixin:OnLoad()
			-- PATCH Collection: pure no-op. A first attempt called
			-- self:SetThreeSliceAtlas(...), but that in turn calls
			-- self:UpdateButton() which also doesn't exist on the Universe
			-- side (same cause: ThreeSliceButtonMixin absent). Rather than
			-- adding one stub per cascading missing method for a help
			-- button of the transmogrifier NPC (outside the Codex), we stop
			-- here: the button keeps its default XML template texture, but
			-- no longer crashes.
		end
	end
	if not PKBT_ButtonMixin.UpdateButton then
		-- ROUND Transmog: PKBT_ButtonMixin:OnShow/:OnEnable/:OnDisable
		-- (SharedXML\SharedUIPanelPKBTTemplates.lua) all three call
		-- self:UpdateButton() without ever checking whether it exists.
		-- Without this stub, simply SHOWING a minimal PKBT button (e.g.
		-- WardrobeFrameHelpFrameKnowledgeBaseButton) crashed on OnShow,
		-- before even reaching InitButton/OnLoad above. Same philosophy as
		-- the two previous stubs: pure no-op, the button keeps its default
		-- texture but no longer crashes.
		function PKBT_ButtonMixin:UpdateButton()
		end
	end
end

-- ============================================================
-- ModelsPanningFrame:OnUpdate: pre-existing Universe bug (SharedXML\
-- ModelFrames.xml, inline script unrelated to Collection), which assumes
-- model.controlFrameModel always exists. For certain model widgets (e.g.
-- the mount preview, "MountDisplayModelScene" model scene), this field is
-- nil, which makes this script crash in a loop for as long as the panning
-- window stays open (error spam, "Count: 249"). We replace the script with
-- a guarded version, without touching the original XML file.
-- ============================================================
if ModelsPanningFrame then
	ModelsPanningFrame:SetScript("OnUpdate", function(self, elapsed)
		local model = self.model
		local controlFrameModel = model and model.controlFrameModel
		if not controlFrameModel then
			self:Hide()
			return
		end
		if not IsMouseButtonDown(controlFrameModel.panButton) then
			SharedXML_Model_StopPanning(model)
			if controlFrameModel.buttonDown then
				ModelControlButton_OnMouseUp(controlFrameModel.buttonDown)
			end
			if not controlFrameModel:IsMouseOver() then
				controlFrameModel:Hide()
			end
		end
	end)
end

-- ============================================================
-- PATCH Collection (round 26 fix): /cdebug and /wdebug commands -
-- ROOT CAUSE identified for "nothing ever changes despite the fixes".
--
-- These two commands were originally registered in Collection_Compat.lua
-- (rounds 22 and 25), which loads VERY EARLY in FrameXML.toc (just before
-- Utils\C_Item.lua). But SlashCmdList (the native table for the /slash
-- command system) is only defined by ChatFrame.lua, which loads
-- MUCH LATER (via ChatFrame.xml, toc line ~139). Concrete result:
-- "SlashCmdList["COLLECTIONDEBUG"] = ..." immediately crashed with
-- "attempt to index a nil value (global 'SlashCmdList')" AS SOON AS
-- Collection_Compat.lua loaded - a runtime error (not a syntax error,
-- so invisible to our automatic checks).
--
-- This error interrupted execution of the FILE at exactly this point:
-- EVERYTHING that followed in Collection_Compat.lua (round 23 RAID_CLASS_COLORS,
-- round 24 GetSpecializationNameForSpecID, and the /wdebug command itself)
-- WAS NEVER EXECUTED, hence the IDENTICAL persistence of the Heirloom errors
-- despite several rounds of fixes that were nonetheless correct and well placed.
--
-- Moved here (Collection_Compat_Tooltip.lua loads after ChatFrame.xml,
-- SlashCmdList already exists) so they finally register correctly.
-- ============================================================
SLASH_COLLECTIONDEBUG1 = "/cdebug"
SlashCmdList["COLLECTIONDEBUG"] = function()
	if Collection_DebugSkills then
		Collection_DebugSkills()
	else
		print("|cffff0000[Collection Debug]|r Collection_DebugSkills unavailable (open the Wardrobe at least once first).")
	end
end

-- ============================================================
-- PATCH round Transmog-26: /diagcp v7 - round 25 reported
-- "CRASH BETWEEN LINE 1032 AND LINE 1047", but this was a FALSE signal: the
-- checkpoint 1047 had mistakenly been placed INSIDE the table constructor
-- COLLECTION_SHIMMED_CVARS = { ... } (';' is a valid field separator in Lua
-- at that spot, so "DIAGv25_CP1047 = true" just added a key to the table
-- instead of assigning the global variable -> it therefore stayed nil even
-- though the file kept executing normally). Verified (Python script,
-- brace counting): this is the ONLY checkpoint out of 51 affected by this
-- issue. Fixed by moving this checkpoint right after the table's closing
-- brace. Should now display FILE COMPLETE.
-- ============================================================
SLASH_DIAGCP1 = "/diagcp"
SlashCmdList["DIAGCP"] = function()
	local checkpoints = {13,41,64,102,133,149,172,192,223,240,259,285,315,330,349,364,381,397,415,447,479,494,509,534,556,575,593,608,624,639,683,722,986,1001,1032,1047,1066,1149,1180,1201,1247,1270,1287,1312,1345,1371,1393,1428,1454,1519,1661};
	local last = 0;
	for i = 1, #checkpoints do
		local v = checkpoints[i];
		if _G["DIAGv26_CP" .. v] then
			last = v;
		else
			print("CRASH BETWEEN LINE " .. last .. " AND LINE " .. v);
			return;
		end
	end
	if DIAGv26_END then
		print("FILE COMPLETE - last checkpoint=" .. last);
	else
		print("CRASH AFTER LINE " .. last .. " (before the end of the file)");
	end
end

-- PATCH round 34: diagnostic dedicated to creature 413 (weapon display
-- mannequin). Custom_Wardrobe.xml already contains a DummyWardrobeWeaponModel
-- widget whose sole purpose is to "warm up" this creature in a loop until
-- GetModel() no longer returns the widget itself (a sign that the model has
-- loaded). If this creature doesn't exist / has no valid displayID on
-- Universe, this loop runs forever and no weapon can ever be displayed, no
-- matter what Lua code surrounds it. This test isolates the problem.
SLASH_MODELDEBUG1 = "/mdebug"
SlashCmdList["MODELDEBUG"] = function()
	if not DummyWardrobeWeaponModel then
		print("|cffff0000[Model Debug]|r DummyWardrobeWeaponModel not found (the XML may not have loaded).");
		return;
	end

	local before = DummyWardrobeWeaponModel:GetModel();
	print("|cffffcc00[Model Debug]|r BEFORE SetCreature(413): GetModel() == self ?", tostring(before == DummyWardrobeWeaponModel));

	local ok, err = pcall(DummyWardrobeWeaponModel.SetCreature, DummyWardrobeWeaponModel, 413);
	print("|cffffcc00[Model Debug]|r SetCreature(413) ok =", tostring(ok), err and ("error: " .. tostring(err)) or "");

	local after = DummyWardrobeWeaponModel:GetModel();
	print("|cffffcc00[Model Debug]|r AFTER SetCreature(413): GetModel() == self ?", tostring(after == DummyWardrobeWeaponModel), " GetModel() =", tostring(after));

	-- Test with a reliable model for comparison (the player itself).
	local testModel = CreateFrame("DressUpModel");
	testModel:SetUnit("player");
	print("|cffffcc00[Model Debug]|r Reference SetUnit(player): GetModel() =", tostring(testModel:GetModel()));

	-- A few plausible alternative IDs for a weapon display mannequin, in
	-- case 413 isn't the right one on Universe.
	local candidateIDs = {413, 17, 942, 1};
	for _, cid in ipairs(candidateIDs) do
		local okC, errC = pcall(testModel.SetCreature, testModel, cid);
		local m = okC and testModel:GetModel();
		print(string.format("  candidate creature %d: ok=%s GetModel()==self? %s", cid, tostring(okC), tostring(m == testModel)));
	end
end


-- PATCH round 35: step-by-step trace of the REAL SEQUENCE used by
-- SetItemAppearance (SetCreature -> Undress -> TryOn) on the already
-- pre-loaded DummyWardrobeWeaponModel widget, to see at exactly which step
-- the model "gets lost". sourceID=15230 = "Fluted Cleaver" (confirmed
-- resolved by the previous /wdebug).
SLASH_MODELTRACE1 = "/mtrace"
SlashCmdList["MODELTRACE"] = function()
	if not DummyWardrobeWeaponModel then
		print("|cffff0000[Model Trace]|r DummyWardrobeWeaponModel not found.");
		return;
	end

	local m = DummyWardrobeWeaponModel;
	local function report(step)
		local model = m:GetModel();
		print(string.format("|cffffcc00[Model Trace]|r after %s: GetModel()==self? %s type=%s", step, tostring(model == m), type(model)));
	end

	report("(initial state, already warmed up)");

	local ok1, err1 = pcall(m.SetCreature, m, 413);
	print("  SetCreature(413) ok=", tostring(ok1), err1 and tostring(err1) or "");
	report("SetCreature(413)");

	local ok2, err2 = pcall(m.Undress, m);
	print("  Undress() ok=", tostring(ok2), err2 and tostring(err2) or "");
	report("Undress()");

	local testSourceID = 15230;
	local itemLink = string.format("item:%s:%s", testSourceID, 0);
	local ok3, err3 = pcall(m.TryOn, m, itemLink);
	print("  TryOn('" .. itemLink .. "') ok=", tostring(ok3), err3 and tostring(err3) or "");
	report("TryOn(item)");
end

SLASH_WARDROBEDEBUG1 = "/wdebug"
SlashCmdList["WARDROBEDEBUG"] = function()
	local frame = WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame;
	if not frame then
		print("|cffff0000[Wardrobe Debug]|r WardrobeCollectionFrame.ItemsCollectionFrame not found (open the Wardrobe first).");
		return;
	end

	print("|cffffcc00[Wardrobe Debug]|r activeCategory =", tostring(frame.activeCategory), " activeSubCategory =", tostring(frame.activeSubCategory));

	local loc = frame.transmogLocation;
	if loc then
		local isAppearance = loc.IsAppearance and loc:IsAppearance();
		local isIllusion = loc.IsIllusion and loc:IsIllusion();
		print("|cffffcc00[Wardrobe Debug]|r transmogLocation: type=", tostring(loc.type), " slotID=", tostring(loc.slotID), " IsAppearance=", tostring(isAppearance), " IsIllusion=", tostring(isIllusion));
	else
		print("|cffff0000[Wardrobe Debug]|r frame.transmogLocation is nil");
	end

	local visualsList = frame.visualsList;
	if not visualsList then
		print("|cffff0000[Wardrobe Debug]|r frame.visualsList is nil (RefreshVisualsList may not have run yet).");
		return;
	end

	print("|cffffcc00[Wardrobe Debug]|r #visualsList =", #visualsList, " #filteredVisualsList =", frame.filteredVisualsList and #frame.filteredVisualsList or "nil");

	for i = 1, math.min(5, #visualsList) do
		local v = visualsList[i];
		local fields = {};
		for k, val in pairs(v) do
			fields[#fields + 1] = tostring(k) .. "=" .. tostring(val);
		end
		table.sort(fields);
		print(string.format("  [%d] %s", i, table.concat(fields, ", ")));

		local sourceID = v.sourceID;
		if type(sourceID) == "number" then
			print("      ItemsCache[sourceID] exists =", tostring(ItemsCache and ItemsCache[sourceID] ~= nil));
			if C_Item and C_Item.GetItemInfoRaw then
				local ok, result = pcall(C_Item.GetItemInfoRaw, sourceID);
				print("      C_Item.GetItemInfoRaw(sourceID) =", ok and tostring(result) or ("ERROR: " .. tostring(result)));
			end
			local ok2, result2 = pcall(GetItemInfo, sourceID);
			print("      GetItemInfo(sourceID) [native global] =", ok2 and tostring(result2) or ("ERROR: " .. tostring(result2)));
		end

		-- PATCH round 32: diagnostic specific to black boxes on Weapons. We
		-- resolve the sourceID exactly the way UpdateItems does (via
		-- GetAnAppearanceSourceFromVisual and GetSortedAppearanceSources) to
		-- see whether the problem comes from an empty source list
		-- (category/sub-category that never matches) or something else.
		if v.visualID and frame.GetAnAppearanceSourceFromVisual then
			local okA, resolvedSourceID = pcall(frame.GetAnAppearanceSourceFromVisual, frame, v.visualID, nil);
			print("      GetAnAppearanceSourceFromVisual(visualID) =", okA and tostring(resolvedSourceID) or ("ERROR: " .. tostring(resolvedSourceID)));

			if CollectionWardrobeUtil and CollectionWardrobeUtil.GetSortedAppearanceSources then
				local exclusion;
				if frame.GetExclusionForSlotName then
					local okE, res = pcall(frame.GetExclusionForSlotName, frame);
					exclusion = okE and res or nil;
				end
				local okS, sources = pcall(CollectionWardrobeUtil.GetSortedAppearanceSources, v.visualID, frame.activeCategory, frame.activeSubCategory, exclusion);
				if okS and type(sources) == "table" then
					print("      GetSortedAppearanceSources: #sources =", #sources, " exclusion =", tostring(exclusion));
					if sources[1] then
						print("      sources[1]: sourceID=", tostring(sources[1].sourceID), " categoryID=", tostring(sources[1].categoryID), " subCategoryID=", tostring(sources[1].subCategoryID), " name=", tostring(sources[1].name));
					end
				else
					print("      GetSortedAppearanceSources ERROR:", tostring(sources));
				end
			end
		end
	end
end

SLASH_HEIRLOOMDEBUG1 = "/hdebug"
SlashCmdList["HEIRLOOMDEBUG"] = function()
	if not C_Heirloom or not C_Heirloom.DebugState then
		print("|cffff0000[Heirloom Debug]|r C_Heirloom.DebugState unavailable.");
		return;
	end

	local populated, dataCount, displayedCount, classFilter, specFilter = C_Heirloom.DebugState();
	print("|cffffcc00[Heirloom Debug]|r populated =", tostring(populated), " #COLLECTION_HEIRLOOMDATA =", dataCount, " #HEIRLOOMS (filtered) =", displayedCount);
	print("|cffffcc00[Heirloom Debug]|r classFilter =", tostring(classFilter), " specFilter =", tostring(specFilter));

	local numDisplayed = C_Heirloom.GetNumDisplayedHeirlooms and C_Heirloom.GetNumDisplayedHeirlooms() or "n/a";
	print("|cffffcc00[Heirloom Debug]|r C_Heirloom.GetNumDisplayedHeirlooms() =", tostring(numDisplayed));

	if type(numDisplayed) == "number" and numDisplayed > 0 then
		for i = 1, math.min(3, numDisplayed) do
			local itemID = C_Heirloom.GetHeirloomItemIDFromDisplayedIndex(i);
			local ok, name, itemEquipLoc = pcall(C_Heirloom.GetHeirloomInfo, itemID);
			print(string.format("  [%d] itemID=%s name=%s equipLoc=%s", i, tostring(itemID), ok and tostring(name) or ("ERROR:" .. tostring(name)), tostring(itemEquipLoc)));
		end
	end

	local frame = HeirloomsJournal;
	if frame then
		print("|cffffcc00[Heirloom Debug]|r HeirloomsJournal:IsVisible() =", tostring(frame:IsVisible()), " numKnownHeirlooms =", tostring(frame.numKnownHeirlooms), " numPossibleHeirlooms =", tostring(frame.numPossibleHeirlooms));
		print("|cffffcc00[Heirloom Debug]|r needsDataRebuilt =", tostring(frame.needsDataRebuilt), " needsRefresh =", tostring(frame.needsRefresh), " filtersSet =", tostring(frame.filtersSet));
		print("|cffffcc00[Heirloom Debug]|r #heirloomLayoutData =", tostring(frame.heirloomLayoutData and #frame.heirloomLayoutData));

		-- ROUND 58: force a clean rebuild, outside any already-running
		-- script context (so no risk of reentrancy), and catch any silent
		-- error with pcall to know whether RebuildLayoutData actually
		-- crashes or the problem lies elsewhere.
		local okBuckets, equipBucketsOrErr = pcall(frame.SortHeirloomsIntoEquipmentBuckets, frame);
		if okBuckets then
			local bucketCount = 0;
			for _ in pairs(equipBucketsOrErr) do bucketCount = bucketCount + 1; end
			print("|cffffcc00[Heirloom Debug]|r SortHeirloomsIntoEquipmentBuckets() OK, categories filled =", bucketCount, " numPossibleHeirlooms after call =", tostring(frame.numPossibleHeirlooms));
		else
			print("|cffff0000[Heirloom Debug]|r SortHeirloomsIntoEquipmentBuckets() crashed:", tostring(equipBucketsOrErr));
		end

		frame.needsDataRebuilt = true;
		local okRebuild, rebuildErr = pcall(frame.RebuildLayoutData, frame);
		if okRebuild then
			print("|cffffcc00[Heirloom Debug]|r RebuildLayoutData() forced OK -> numPossibleHeirlooms =", tostring(frame.numPossibleHeirlooms), " #heirloomLayoutData =", tostring(frame.heirloomLayoutData and #frame.heirloomLayoutData));
		else
			print("|cffff0000[Heirloom Debug]|r RebuildLayoutData() crashed:", tostring(rebuildErr));
		end
	else
		print("|cffff0000[Heirloom Debug]|r HeirloomsJournal not found (open Heirlooms first).");
	end
end

-- PATCH round 109 (safety net): re-defining the same 9 help texts
-- here, in Collection_Compat_Tooltip.lua. This file loads just
-- before Custom_Collections.xml (toc line 242 vs 243) and has a proven
-- track record of executing fully (every /debug command living here
-- works). If Collection_Compat.lua (round 108) is
-- interrupted earlier by a runtime error before reaching its
-- own definitions (the exact cause of the round 26 SlashCmdList bug),
-- these definitions take over as a last resort.
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_1 = "Transmogrification lets you change the appearance of your equipment. But there are a few important points to know.\n\n1. Once Transmogrification is done, you will no longer be able to sell the items back to a vendor. This applies to both the item whose appearance you changed and the one whose appearance you used.\n\n2. If you destroy or sell an item with a return or exchange timer, you will lose the appearance associated with the Transmogrification.\n\n3. After Transmogrification, both items become Soulbound. This also applies to Heirloom items (armor and weapons).\n\n4. Applying a visual enchant to a weapon also makes it Soulbound.\n\n5. The Transmogrification effect is removed from Heirloom items sent by mail.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_2 = "This counter shows the number of item appearances you have collected. The number displayed varies depending on the selected slot and item type.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_3 = "To find the appearance of an item you're interested in, start typing its name in the \"Search\" field.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_4 = "Here you can choose the acquisition source of the item appearances you have already obtained.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_5 = "Here you can enable/disable the help window display for the Transmogrification of the selected item type. If the help window is enabled, the \"Full Rules\" button will let you access detailed information about all Transmogrification rules in the encyclopedia.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_6 = "Here you can save all your outfits.\n\nChoose the desired appearances for your items, then click \"New Outfit\". Give it a unique name and click \"Apply\". Your outfit is now saved, and you'll be able to use it later to quickly switch your Transmogrification.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_7 = "Here you can select the item you want to give a new appearance.\n\nTo cancel the changes for a particular item, right-click on it or click the arrow that appears next to it.\n\nIf you want to cancel the changes for all items at once, click the arrow at the top right.\n\nNote that bulk cancellation is only possible as long as the Transmogrification service has not been paid for.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_8 = "Here you can choose the desired item appearance type.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_9 = "All your item appearances matching the filters and search are shown here.\n\nTo place an appearance at the top of the list, add it to your Favorites. To do this, right-click the item and select \"Add to Favorites\".";

-- PATCH round 110: missing MAIN_HELP_BUTTON_TOOLTIP (same cause as
-- HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_1.._9: only defined in Russian in
-- Sirus/GlobalStrings.lua, absent from Universe). This is the text shown by
-- the big arrow coming from the main "i" icon (portrait, top left) when
-- hovering it - the master button that toggles the entire help plate on/off,
-- distinct from the 9 numbered bubbles already translated.
MAIN_HELP_BUTTON_TOOLTIP = "Show/hide this window's tooltips.";

-- PATCH round 111: same cause, 4 new missing globals (only in Russian in
-- Sirus/GlobalStrings.lua): the tooltips (classic GameTooltip, not
-- HelpPlate) shown when hovering the "i" icon of the Toys and Heirlooms
-- tabs (Custom_ToyBox.xml / Custom_HeirloomCollection.xml).
HELPTIP_TOYS_HEAD = "'Toys' collection specifics";
HELPTIP_TOYS = "Toys are items intended for entertainment.\n\nSome provide a cosmetic effect, others let you summon a world object to interact with.\n\nHover over the toy you're interested in to learn how to use it or how to obtain it.";
HELPTIP_HEIRLOOM_HEAD = "'Heirloom' collection specifics";
HELPTIP_HEIRLOOM = "Heirloom items are items designed to make leveling up your character easier. This type of item generally increases the experience gained by the character from quests and killing monsters. Their stats also increase with the character's level, up to level 80.\n\nOn our server, Heirloom items are added to the collection using special tokens. You can obtain them in-game with internal currency, or from our store.\n\nOnce an item is added to the collection, it becomes accessible on any character on the account, in the game world.\n\nTo obtain a Heirloom item, left-click it: it will then join your bag. This action can be repeated an unlimited number of times.";

-- PATCH round 114: Demon Hunter specialization titles/descriptions
-- (S_CALSS_SPECIALIZATION_DATA[CLASS_ID_DEMONHUNTER], Universe client base)
-- reference DEMONHUNTER_HAVOC/REVENGE/POSESSION_TITLE/_DESC, never defined
-- anywhere on the Universe side (only in Russian on the Sirus/
-- GlobalStrings.lua side) -> checkbox with no text in the specializations
-- sub-menu of the Heirlooms tab. This is the ONLY class present in this
-- table (Blood Mage/Knight/Monk/Tamer/Hero are not in it at all, so 0
-- specialization lines for them, no bug).
DEMONHUNTER_HAVOC_TITLE = "Havoc";
DEMONHUNTER_HAVOC_DESC = "Dark master of combat blades and devastating Fel magic.";
DEMONHUNTER_REVENGE_TITLE = "Vengeance";
DEMONHUNTER_REVENGE_DESC = "Uses the power of the inner demon to incinerate enemies and protect allies.";
DEMONHUNTER_POSESSION_TITLE = "Possession";
DEMONHUNTER_POSESSION_DESC = "Unleashes the inner demon to fight enemies.";

-- These globals alone are NOT ENOUGH: S_CALSS_SPECIALIZATION_DATA (in
-- SharedXML\SharedConstants.lua, toc line 38) captures their VALUE at the
-- moment the table is built, which happens very early, well before this
-- file (toc line 242) defines them. Without the direct patch below, the 3
-- Demon Hunter sub-tables would therefore stay frozen with title/desc = nil
-- forever, even with the globals above defined (same trap as
-- PLAYER_CLASS_FLAG in round 101).
if S_CALSS_SPECIALIZATION_DATA and S_CALSS_SPECIALIZATION_DATA[CLASS_ID_DEMONHUNTER] then
	local dhSpecs = S_CALSS_SPECIALIZATION_DATA[CLASS_ID_DEMONHUNTER];
	local FIXED_TITLES = { DEMONHUNTER_HAVOC_TITLE, DEMONHUNTER_REVENGE_TITLE, DEMONHUNTER_POSESSION_TITLE };
	local FIXED_DESCS  = { DEMONHUNTER_HAVOC_DESC, DEMONHUNTER_REVENGE_DESC, DEMONHUNTER_POSESSION_DESC };
	for i, specData in ipairs(dhSpecs) do
		if FIXED_TITLES[i] then
			specData[2] = FIXED_TITLES[i];
			specData[3] = FIXED_DESCS[i];
		end
	end
end


-- PATCH round 109: diagnostic dedicated to empty Wardrobe help bubbles
-- (HelpPlate). The user confirms hovering an "i" icon and seeing an empty
-- bubble, EVEN AFTER round 108 (frFR translation added at the end of
-- Collection_Compat.lua). Two possible causes to tell apart:
--   1) The globals HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_1.._9 are not
--      defined at all (the round 108 patch wasn't applied, or a runtime
--      error earlier in Collection_Compat.lua interrupts the file before
--      reaching the block added at the end of the file - already seen in
--      round 26 with SlashCmdList).
--   2) The globals ARE defined, but WardrobeFrame.helpPlate captured
--      their value BEFORE they existed (OnLoad running too early).
-- This command shows the actual state of both to decide without guessing.
SLASH_HELPPLATEDEBUG1 = "/hpdebug"
SlashCmdList["HELPPLATEDEBUG"] = function()
	print("|cffffcc00[HelpPlate Debug]|r --- Globals HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_1..9 ---");
	for i = 1, 9 do
		local v = _G["HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_" .. i];
		if type(v) == "string" then
			print(string.format("  [%d] DEFINED, length=%d, start=%q", i, #v, v:sub(1, 40)));
		else
			print(string.format("  [%d] |cffff0000NIL|r (type=%s)", i, type(v)));
		end
	end

	print("|cffffcc00[HelpPlate Debug]|r --- WardrobeFrame.helpPlate (captured at OnLoad) ---");
	if not WardrobeFrame then
		print("  WardrobeFrame not found.");
		return;
	end
	if not WardrobeFrame.helpPlate then
		print("  WardrobeFrame.helpPlate is nil (OnLoad may not have run yet).");
		return;
	end
	for i = 1, 9 do
		local entry = WardrobeFrame.helpPlate[i];
		if not entry then
			print(string.format("  [%d] entry missing", i));
		else
			local t = entry.ToolTipText;
			if type(t) == "string" then
				print(string.format("  [%d] ToolTipText DEFINED, length=%d, start=%q", i, #t, t:sub(1, 40)));
			else
				print(string.format("  [%d] ToolTipText |cffff0000NIL|r (type=%s) -> capture on load failed", i, type(t)));
			end
		end
	end
end

-- PATCH round 112: checkbox labels in the Filter button's sub-menus
-- (Abilities/Sources/Faction for Mounts, Pet Families/Sources for Pets,
-- Sources for Wardrobe/Toys/Heirlooms). FilterDropdown.lua
-- (AddDynamicFilterSet) builds each checkbox's text via
-- _G[globalPrepend .. i]; these globals only existed in Russian on the
-- Sirus/GlobalStrings.lua side -> nil text -> checkbox with no label next
-- to it, in all 5 tabs at once (shared prefix).
-- COLLECTION_MOUNT_ABILITY_*
COLLECTION_MOUNT_ABILITY_1 = "Ground Speed 60";
COLLECTION_MOUNT_ABILITY_2 = "Ground Speed 100";
COLLECTION_MOUNT_ABILITY_3 = "Flying Speed 280";
COLLECTION_MOUNT_ABILITY_4 = "Flying Speed 310";
COLLECTION_MOUNT_ABILITY_5 = "Water Walking";
COLLECTION_MOUNT_ABILITY_6 = "Improved Swimming";
COLLECTION_MOUNT_ABILITY_7 = "Two-Seater";
COLLECTION_MOUNT_ABILITY_8 = "Three-Seater";
COLLECTION_MOUNT_ABILITY_9 = "Vendor or Repairman";
COLLECTION_MOUNT_ABILITY_10 = "Enables faster flight";
COLLECTION_MOUNT_ABILITY_11 = "Account-wide";
-- COLLECTION_PET_SOURCE_*
COLLECTION_PET_SOURCE_1 = "Loot";
COLLECTION_PET_SOURCE_2 = "Quests";
COLLECTION_PET_SOURCE_3 = "Vendor";
COLLECTION_PET_SOURCE_4 = "Profession";
COLLECTION_PET_SOURCE_5 = "Achievement";
COLLECTION_PET_SOURCE_6 = "In-Game Event";
COLLECTION_PET_SOURCE_7 = "In-Game Store";
COLLECTION_PET_SOURCE_8 = "Vote Points";
COLLECTION_PET_SOURCE_9 = "Battle Pass";
COLLECTION_PET_SOURCE_10 = "Black Market";
-- COLLECTION_TRAVELING_MERCHANT_*
COLLECTION_TRAVELING_MERCHANT_1 = "Lurgen";
COLLECTION_TRAVELING_MERCHANT_2 = "Aishali";
COLLECTION_TRAVELING_MERCHANT_3 = "Saralet";
-- COLLECTION_MOUNT_FACTION_*
COLLECTION_MOUNT_FACTION_1 = "Alliance";
COLLECTION_MOUNT_FACTION_2 = "Horde";
COLLECTION_MOUNT_FACTION_3 = "Neutral";
COLLECTION_MOUNT_FACTION_4 = "Renegades";
-- COLLECTION_PET_NAME_*
COLLECTION_PET_NAME_1 = "Aquatic";
COLLECTION_PET_NAME_2 = "Humanoid";
COLLECTION_PET_NAME_3 = "Dragonkin";
COLLECTION_PET_NAME_4 = "Beast";
COLLECTION_PET_NAME_5 = "Critter";
COLLECTION_PET_NAME_6 = "Flying";
COLLECTION_PET_NAME_7 = "Magic";
COLLECTION_PET_NAME_8 = "Mechanical";
COLLECTION_PET_NAME_9 = "Undead";
COLLECTION_PET_NAME_10 = "Elemental";
-- TRANSMOG_SOURCE_*
TRANSMOG_SOURCE_1 = "Boss Drop";
TRANSMOG_SOURCE_2 = "Quests";
TRANSMOG_SOURCE_3 = "Vendor";
TRANSMOG_SOURCE_4 = "Random Loot";
TRANSMOG_SOURCE_5 = "Achievement";
TRANSMOG_SOURCE_6 = "Profession";
TRANSMOG_SOURCE_7 = "In-Game Store";
TRANSMOG_SOURCE_8 = "Available when upgrading an item";
TRANSMOG_SOURCE_9 = "Special Events";
TRANSMOG_SOURCE_10 = "Black Market Contraband";
TRANSMOG_SOURCE_11 = "Guild Rewards";
TRANSMOG_SOURCE_12 = "Starting Equipment";
TRANSMOG_SOURCE_13 = "Transmogrification (Store)";
TRANSMOG_SOURCE_14 = "Currently Unavailable";

-- PATCH round 117: "GetBindingKey: Usage: GetBindingKey(...)" error when
-- hovering the "Professions" tab of the Spellbook (SpellBookFrameTabButton2).
-- In SpellBookFrame.lua, the line
-- "SpellBookFrameTabButton2.binding = TOGGLEPROFESSIONBOOK;" references a
-- global variable WITHOUT quotes (unlike "TOGGLESPELLBOOK",
-- "TOGGLEPETBOOK", etc. which are indeed literal strings just above/below).
-- This TOGGLEPROFESSIONBOOK global does not exist anywhere in the client ->
-- nil -> this tab's OnEnter (SpellBookFrame.xml) then calls
-- MicroButtonTooltipText(text, nil) -> GetBindingKey(nil) -> crash. By
-- defining this global as a string (worst case, a binding action that
-- simply doesn't exist, as was already implicitly the case for this tab),
-- SpellBookFrame_Update() (which reassigns .binding every time the
-- Spellbook is shown) will now always give it a real string and
-- GetBindingKey will no longer crash.
TOGGLEPROFESSIONBOOK = "TOGGLEPROFESSIONBOOK";

-- PATCH round 117: "attempt to call global 'LootWonAlertFrame_ShowAlert'
-- (a nil value)" error on every loot received. ChatFrame.lua (CHAT_MSG_LOOT
-- event) calls this function to show a visual "Item obtained" toast (retail
-- feature), but it was never ported to this 3.3.5 client -- AlertFrames.lua
-- only defines AchievementAlertFrame_ShowAlert and
-- DungeonCompletionAlertFrame_ShowAlert, not this one. The loot message
-- already displays normally in chat right after this call (self:AddMessage);
-- this empty stub only removes the crash, without a visual toast. If a real
-- "Item obtained" toast is wanted later, that will be a separate addition
-- (a new frame to build).
if not LootWonAlertFrame_ShowAlert then
	function LootWonAlertFrame_ShowAlert(itemLink)
	end
end

-- ============================================================
-- ROUND Transmog-2: missing SetUIPanelAttribute. This function (introduced
-- in an expansion later than 3.3.5, on retail it goes through a secure
-- FramePositionDelegate:SetAttribute frame) does not exist at all on this
-- client -- crashed WardrobeFrameMixin:SetShowHelpFrame (Custom_Wardrobe.lua)
-- on the very first click of the Transmogrifier's "i" help button:
-- "attempt to call global 'SetUIPanelAttribute' (a nil value)".
-- Minimal stub: writes the attribute directly into UIPanelWindows[frameName],
-- the same simple table this client already uses for all panel management
-- (area/pushable/width/xOffset/yOffset, see UIPanelWindows["WardrobeFrame"]
-- in Custom_Wardrobe.lua). Enough to eliminate the crash; the panel's
-- visual widening for the help pane remains cosmetic and secondary compared
-- to the main need (transmogrifying without crashing).
-- ============================================================
if not SetUIPanelAttribute then
	function SetUIPanelAttribute(frame, attribute, value)
		local info = UIPanelWindows[frame:GetName()];
		if info then
			info[attribute] = value;
		end
	end
end

-- ============================================================
-- ROUND Transmog-2: missing C_Item.DoesItemExist. ItemLocationMixin:IsValid()
-- (Interface\FrameXML\ItemLocation.lua) calls C_Item.DoesItemExist(self)
-- without a guard -- absent on this client, which crashed
-- TransmogSlotButtonMixin:GetEffectiveTransmogID (Custom_Wardrobe.lua) as
-- soon as the Transmogrifier was shown, preventing ANY equipment slot from
-- populating (Update() stopped there for every slot, hence empty slots
-- despite wearing equipment). Stub: checks directly via native WotLK 3.3.5
-- APIs (GetInventoryItemID / GetContainerItemID) whether an item actually
-- exists at the location described by the ItemLocation.
-- ============================================================
if C_Item and not C_Item.DoesItemExist then
	function C_Item.DoesItemExist(itemLocation)
		if not itemLocation then
			return false;
		end
		if itemLocation.IsEquipmentSlot and itemLocation:IsEquipmentSlot() then
			return GetInventoryItemID("player", itemLocation:GetEquipmentSlot()) ~= nil;
		elseif itemLocation.IsBagAndSlot and itemLocation:IsBagAndSlot() then
			local bagID, slotIndex = itemLocation:GetBagAndSlot();
			return GetContainerItemID(bagID, slotIndex) ~= nil;
		end
		return false;
	end
end

-- ============================================================
-- ROUND Transmog-31: /tclickdebug -- live tracing of grid clicks
-- ============================================================
-- Round 30 (the frame:OnEvent fallback in FireCustomClientEvent) did NOT
-- resolve "unable to select an item directly in the Transmogrification tab".
-- Rather than keep guessing, this command instruments LIVE (without
-- changing any actual behavior) the entire chain involved in clicking a
-- grid item:
--   OnClick -> WardrobeItemsCollectionMixin:SelectVisual
--           -> TransmogFrameMixin:SetPendingTransmog (requires
--              WardrobeTransmogFrame.selectedSlotButton != nil !)
--           -> C_Transmog.SetPending (writes _pending[slotID] + notifies)
--           -> FireCustomClientEvent("TRANSMOGRIFY_UPDATE")
--           -> WardrobeItemsCollectionMixin:OnEvent (should now be reached
--              thanks to the round 30 fix) -> UpdateItems (recomputes the
--              border via C_Transmog.GetSlotVisualInfo)
--
-- Usage: type /tclickdebug ONCE to enable (the command confirms it),
-- then click an item in the Transmogrification tab, then copy-paste the
-- "[TDEBUG]" lines that appear in chat. Type /tclickdebug again to disable.
-- ============================================================
TCLICKDEBUG_ENABLED = false;
TCLICKDEBUG_HOOKED = false;
TCLICKDEBUG_LAST_ONEVENT_FIRED = nil;

local function tdbg(...)
	if TCLICKDEBUG_ENABLED then
		print("|cff00ff88[TDEBUG]|r", ...);
	end
end

local function TClickDebug_InstallHooks()
	if TCLICKDEBUG_HOOKED then
		return true;
	end

	-- FIX ROUND TRANSMOG-32: the first version of /tclickdebug (round 31)
	-- hooked the methods on the SHARED MIXIN TABLES
	-- (WardrobeItemsCollectionMixin.SelectVisual = ..., etc). But
	-- Mixin(object, MixinTable) -- used by this ported retail code as-is --
	-- COPIES the functions ONCE onto the INSTANCE at OnLoad time (well
	-- before the player types /tclickdebug): reassigning the mixin table
	-- AFTER the fact then has no effect at all on already-loaded frames
	-- (WardrobeTransmogFrame, WardrobeCollectionFrame.ItemsCollectionFrame).
	-- Observed result: only the hook on C_Transmog.SetPending (a normal
	-- table function, never "copied" anywhere, always read live) fired --
	-- hence "[TDEBUG] C_Transmog.SetPending(...)" lines with no
	-- SelectVisual/SelectSlotButton/SetPendingTransmog line before them. We
	-- now hook directly onto the real INSTANCES (WardrobeTransmogFrame and
	-- WardrobeCollectionFrame.ItemsCollectionFrame), which necessarily
	-- already exist at this point (the player must have opened the
	-- Wardrobe or Transmogrification at least once before typing the
	-- command).
	if not (C_Transmog and WardrobeTransmogFrame and WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame) then
		return false; -- not loaded yet, we'll retry on the next toggle
	end

	local itemsFrame = WardrobeCollectionFrame.ItemsCollectionFrame;
	local transmogFrame = WardrobeTransmogFrame;

	-- 1) SelectVisual: entry point for left-clicking an item (on the real
	-- INSTANCE of the grid, not on the mixin table).
	local orig_SelectVisual = itemsFrame.SelectVisual;
	itemsFrame.SelectVisual = function(self, visualID, ...)
		local atNPC = C_Transmog.IsAtTransmogNPC();
		local gridSlotID = self.transmogLocation and self.transmogLocation:GetSlotID();
		tdbg(string.format("SelectVisual(visualID=%s) | IsAtTransmogNPC=%s | grid.transmogLocation:GetSlotID()=%s | activeCategory=%s/%s",
			tostring(visualID), tostring(atNPC), tostring(gridSlotID), tostring(self.activeCategory), tostring(self.activeSubCategory)));
		if not atNPC then
			tdbg("  -> STOPS HERE: IsAtTransmogNPC() = false, SelectVisual stops (immediate return, nothing else runs).");
		end
		return orig_SelectVisual(self, visualID, ...);
	end

	-- 2) SelectSlotButton: which slot (Head/Chest/...) is currently
	-- selected on the mannequin, on the WardrobeTransmogFrame side.
	local orig_SelectSlotButton = transmogFrame.SelectSlotButton;
	transmogFrame.SelectSlotButton = function(self, slotButton, fromOnClick, ...)
		local slotID = slotButton and slotButton.transmogLocation and slotButton.transmogLocation:GetSlotID();
		tdbg(string.format("SelectSlotButton(slotID=%s, fromOnClick=%s)", tostring(slotID), tostring(fromOnClick)));
		return orig_SelectSlotButton(self, slotButton, fromOnClick, ...);
	end

	-- 3) SetPendingTransmog: only REALLY writes anything if
	-- self.selectedSlotButton is already set -- suspect #1 if it stays nil
	-- while on the Transmogrification tab.
	local orig_SetPendingTransmog = transmogFrame.SetPendingTransmog;
	transmogFrame.SetPendingTransmog = function(self, transmogID, category, subCategory, ...)
		local hasSlotButton = self.selectedSlotButton ~= nil;
		local slotID = hasSlotButton and self.selectedSlotButton.transmogLocation and self.selectedSlotButton.transmogLocation:GetSlotID();
		tdbg(string.format("SetPendingTransmog(transmogID=%s) | selectedSlotButton=%s | slotID=%s",
			tostring(transmogID), tostring(hasSlotButton), tostring(slotID)));
		if not hasSlotButton then
			tdbg("  -> STOPS HERE: WardrobeTransmogFrame.selectedSlotButton is nil, C_Transmog.SetPending is NEVER called.");
		end
		return orig_SetPendingTransmog(self, transmogID, category, subCategory, ...);
	end

	-- 4) C_Transmog.SetPending: the actual write of _pending[slotID].
	local orig_SetPending = C_Transmog.SetPending;
	C_Transmog.SetPending = function(transmogLocation, pendingInfo, ...)
		local slotID = transmogLocation and transmogLocation:GetSlotID();
		tdbg(string.format("C_Transmog.SetPending(slotID=%s, transmogID=%s)", tostring(slotID), tostring(pendingInfo and pendingInfo.transmogID)));
		return orig_SetPending(transmogLocation, pendingInfo, ...);
	end

	-- 5) OnEvent (instance): confirms whether TRANSMOGRIFY_UPDATE is
	-- actually received by the grid (supposedly fixed by round 30).
	local orig_OnEvent = itemsFrame.OnEvent;
	itemsFrame.OnEvent = function(self, event, ...)
		if event == "TRANSMOGRIFY_UPDATE" or event == "TRANSMOGRIFY_SUCCESS" then
			TCLICKDEBUG_LAST_ONEVENT_FIRED = event;
			tdbg(string.format("ItemsCollectionFrame:OnEvent RECEIVED event=%s | grid.transmogLocation:GetSlotID()=%s",
				tostring(event), tostring(self.transmogLocation and self.transmogLocation:GetSlotID())));
		end
		return orig_OnEvent(self, event, ...);
	end

	-- 5bis) FireCustomClientEvent (ROUND 32/34): EMPIRICALLY checks whether
	-- the round 30 fix (fallback to frame:OnEvent when
	-- frame:GetScript("OnEvent") is nil) is actually active for you. Round
	-- 33 only measured "reached=true/false" via a flag -- always false for
	-- you even after replacing Collection_Compat.lua. Round 34: instead of
	-- inferring, we DIRECTLY INSPECT every listener registered for
	-- TRANSMOGRIFY_UPDATE (does frame:GetScript("OnEvent") exist? does
	-- frame.OnEvent exist?) -- this does NOT depend on any assumption about
	-- the code actually installed, only on the real state of the frames in
	-- game at the moment of the click.
	if type(FireCustomClientEvent) == "function" then
		local orig_FireCustomClientEvent = FireCustomClientEvent;
		FireCustomClientEvent = function(event, ...)
			if event == "TRANSMOGRIFY_UPDATE" then
				TCLICKDEBUG_LAST_ONEVENT_FIRED = nil;
				local listeners = REGISTERED_CUSTOM_EVENTS and REGISTERED_CUSTOM_EVENTS[event];
				local count = 0;
				if listeners then
					for frame in pairs(listeners) do
						count = count + 1;
						local isItemsFrame = (frame == itemsFrame);
						local isTransmogFrame = (frame == transmogFrame);
						local hasScript = frame.GetScript and frame:GetScript("OnEvent") ~= nil;
						local hasOnEventMethod = type(frame.OnEvent) == "function";
						tdbg(string.format("  listener #%d: itemsFrame=%s transmogFrame=%s GetScript(OnEvent)=%s frame.OnEvent(method)=%s",
							count, tostring(isItemsFrame), tostring(isTransmogFrame), tostring(hasScript), tostring(hasOnEventMethod)));
					end
				end
				tdbg(string.format("FireCustomClientEvent(%s) | registered listeners=%d", tostring(event), count));
				local a, b, c, d, e, f = orig_FireCustomClientEvent(event, ...);
				local reached = (TCLICKDEBUG_LAST_ONEVENT_FIRED == event);
				tdbg(string.format("FireCustomClientEvent(%s) finished | ItemsCollectionFrame:OnEvent reached=%s%s",
					tostring(event), tostring(reached),
					(not reached) and "  <-- see the 'GetScript(OnEvent)'/'frame.OnEvent' detail above for the real reason." or ""));
				return a, b, c, d, e, f;
			end
			return orig_FireCustomClientEvent(event, ...);
		end
	end

	-- 6) UpdateItems (instance): final state used to draw the border.
	local orig_UpdateItems = itemsFrame.UpdateItems;
	itemsFrame.UpdateItems = function(self, ...)
		local atNPC = C_Transmog.IsAtTransmogNPC();
		local ok, baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID = pcall(C_Transmog.GetSlotVisualInfo, self.transmogLocation);
		if ok then
			tdbg(string.format("UpdateItems() | IsAtTransmogNPC=%s | baseVisualID=%s appliedVisualID=%s pendingVisualID=%s",
				tostring(atNPC), tostring(baseVisualID), tostring(appliedVisualID), tostring(pendingVisualID)));
		else
			tdbg("UpdateItems() | IsAtTransmogNPC=" .. tostring(atNPC) .. " | GetSlotVisualInfo ERROR: " .. tostring(baseSourceID));
		end
		return orig_UpdateItems(self, ...);
	end

	TCLICKDEBUG_HOOKED = true;
	return true;
end

SLASH_TCLICKDEBUG1 = "/tclickdebug"
SlashCmdList["TCLICKDEBUG"] = function()
	TCLICKDEBUG_ENABLED = not TCLICKDEBUG_ENABLED;
	if TCLICKDEBUG_ENABLED then
		local installed = TClickDebug_InstallHooks();
		if installed then
			print("|cff00ff88[TDEBUG]|r ENABLED. Open the Transmogrification tab and click a grid item: the steps will be shown here.");
		else
			TCLICKDEBUG_ENABLED = false;
			print("|cffff0000[TDEBUG]|r Unable to enable: open the Wardrobe or Transmogrification once first (the required code isn't loaded yet), then type /tclickdebug again.");
		end
	else
		print("|cff00ff88[TDEBUG]|r DISABLED.");
	end
end

-- ============================================================
-- ROUND Transmog-38: /tbagdebug -- why only 5/13 shoulders (and 0 weapons)
-- are detected in bags despite the round 37 fix.
-- ============================================================
-- Usage: open the Transmogrification tab on the relevant slot (e.g.
-- Shoulders, "All" filter), THEN type /tbagdebug. Shows: how many raw items
-- are seen in bags, and for each NOT-collected appearance in the current
-- list, whether its sourceID matches a bag item (using the round 37 method)
-- or not -- instead of guessing further.
SLASH_TBAGDEBUG1 = "/tbagdebug"
SlashCmdList["TBAGDEBUG"] = function()
	local frame = WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame;
	if not frame or not frame.visualsList then
		print("|cffff0000[TBAGDEBUG]|r Open the Wardrobe or Transmogrification on a slot first.");
		return;
	end

	local bagItemIDs = frame:BuildBagItemIDSet();
	local bagCount = 0;
	local bagList = {};
	for itemID in pairs(bagItemIDs) do
		bagCount = bagCount + 1;
		bagList[#bagList + 1] = itemID;
	end
	table.sort(bagList);
	print(string.format("|cff00ff88[TBAGDEBUG]|r NUM_BAG_SLOTS=%s | distinct raw items found in bags (bag 0 to NUM_BAG_SLOTS)=%d", tostring(NUM_BAG_SLOTS), bagCount));
	print("  List of item IDs found in bags: " .. table.concat(bagList, ", "));

	print(string.format("|cff00ff88[TBAGDEBUG]|r activeCategory=%s activeSubCategory=%s | #visualsList=%d | #filteredVisualsList=%d",
		tostring(frame.activeCategory), tostring(frame.activeSubCategory), #frame.visualsList, frame.filteredVisualsList and #frame.filteredVisualsList or 0));

	local shown, checked = 0, 0;
	for i, visualInfo in ipairs(frame.visualsList) do
		if checked < 3 and not visualInfo.isCollected then
			local fields = {};
			for k, v in pairs(visualInfo) do
				fields[#fields + 1] = tostring(k) .. "=" .. tostring(v);
			end
			table.sort(fields);
			print("  [raw visualInfo fields] " .. table.concat(fields, ", "));
		end
		if not visualInfo.isCollected then
			checked = checked + 1;
			local directHit = visualInfo.sourceID and bagItemIDs[visualInfo.sourceID];
			local ok, sources = pcall(CollectionWardrobeUtil.GetSortedAppearanceSources, visualInfo.visualID, nil, nil, nil);
			local numSources = (ok and type(sources) == "table") and #sources or -1;
			local anyBagSourceMatch = false;
			local matchedSourceID;
			if ok and type(sources) == "table" then
				for j = 1, #sources do
					if bagItemIDs[sources[j].sourceID] then
						anyBagSourceMatch = true;
						matchedSourceID = sources[j].sourceID;
						break;
					end
				end
			end
			if directHit or anyBagSourceMatch then
				shown = shown + 1;
			end
			if checked <= 20 then
				local sourceIDList = {};
				if ok and type(sources) == "table" then
					for j = 1, #sources do
						sourceIDList[#sourceIDList + 1] = tostring(sources[j].sourceID);
					end
				end
				print(string.format("  visualID=%s directHit=%s anyBagMatch=%s | real sources=[%s]",
					tostring(visualInfo.visualID), tostring(directHit),
					tostring(anyBagSourceMatch), table.concat(sourceIDList, ", ")));
			end
		end
	end
	print(string.format("|cff00ff88[TBAGDEBUG]|r Out of %d NOT-collected appearances, %d would be shown as 'in bag' with the current method (limited to 20 detail lines above).", checked, shown));
end

-- ============================================================
-- ROUND Transmog-41: /titemdebug -- full pipeline for each real bag itemID.
-- ============================================================
-- Round 40 fixed the MATCHING METHOD, but if the real problem lies further
-- upstream -- in the very construction of the candidate list
-- (BASE_APPEARANCES, used by C_TransmogCollection.GetCategoryAppearances,
-- and therefore by self.visualsList) -- no improvement to the matching can
-- make an item appear that never entered this candidate list in the first
-- place. This diagnostic takes every item ACTUALLY in the bags and shows at
-- exactly which pipeline step it "disappears": no entry in
-- ITEM_MODIFIED_APPEARANCE_STORAGE? category/sub-category not resolved?
-- sourceType excluded? IsKnownItemModifiedAppearance returns false? or is
-- everything correct but it's simply not yet in BASE_APPEARANCES
-- (inBaseAppearances=false)?
-- Usage: open the Wardrobe or Transmogrification on the relevant slot (e.g.
-- Shoulders), type /titemdebug.
SLASH_TITEMDEBUG1 = "/titemdebug"
SlashCmdList["TITEMDEBUG"] = function()
	local frame = WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame;
	if not frame then
		print("|cffff0000[TITEMDEBUG]|r Open the Wardrobe or Transmogrification first.");
		return;
	end
	if not (C_TransmogCollection and C_TransmogCollection.DebugItemPipeline) then
		print("|cffff0000[TITEMDEBUG]|r C_TransmogCollection.DebugItemPipeline unavailable (patch out of date?).");
		return;
	end

	local bagItemIDs = frame:BuildBagItemIDSet();
	local list = {};
	for itemID in pairs(bagItemIDs) do
		list[#list + 1] = itemID;
	end
	table.sort(list);

	print(string.format("|cff00ff88[TITEMDEBUG]|r activeCategory=%s activeSubCategory=%s | %d bag items to analyze (limited to 25 lines).",
		tostring(frame.activeCategory), tostring(frame.activeSubCategory), #list));

	local n = 0;
	for i = 1, #list do
		if n >= 25 then break; end
		local itemID = list[i];
		local ok, result = pcall(C_TransmogCollection.DebugItemPipeline, itemID);
		if ok and result then
			if not result.hasStorageEntry then
				print(string.format("  itemID=%d: NO entry in ITEM_MODIFIED_APPEARANCE_STORAGE (never referenced as an appearance).", itemID));
			else
				print(string.format("  itemID=%d categoryID=%s subCategoryID=%s equipLocID=%s appearanceID=%s sourceType=%s classMask=%s isKnown=%s inBaseAppearances=%s",
					itemID, tostring(result.categoryID), tostring(result.subCategoryID), tostring(result.equipLocID),
					tostring(result.appearanceID), tostring(result.sourceType), tostring(result.classMask),
					tostring(result.isKnown), tostring(result.inBaseAppearances)));
				if result.categoryID == 0 then
					print(string.format("      -> categoryID=0 (rejected) | rawEquipLocStr=%s itemSubTypeStr=%s (useful if this is a weapon)",
						tostring(result.rawEquipLocStr), tostring(result.itemSubTypeStr)));
				end
			end
			n = n + 1;
		else
			print(string.format("  itemID=%d: diagnostic error (%s)", itemID, tostring(result)));
			n = n + 1;
		end
	end
end

-- ============================================================
-- ROUND Transmog-41: /tmodeltrace -- toggle to see live what
-- GetEffectiveTransmogID()/RefreshItemModel actually compute at the moment
-- the mannequin should change (useful for the "mannequin doesn't update
-- after Apply" issue, even when ShowingHelm() is confirmed active).
-- Usage: type /tmodeltrace to enable, click Apply, watch the [TMODELTRACE]
-- lines, then type /tmodeltrace again to disable (otherwise it prints on
-- every grid click).
-- ============================================================
TMODELTRACE_ENABLED = false;
SLASH_TMODELTRACE1 = "/tmodeltrace"
SlashCmdList["TMODELTRACE"] = function()
	TMODELTRACE_ENABLED = not TMODELTRACE_ENABLED;
	print("|cff00ccff[TMODELTRACE]|r " .. (TMODELTRACE_ENABLED and "ENABLED" or "DISABLED"));
end

-- ============================================================
-- ROUND Transmog-38: tracing of the server confirmation ASMSG_TRANSMOG_APPLIED
-- (round 37 added a direct mannequin refresh there -- this checks whether
-- it actually fires and without error).
-- ============================================================
if EventHandler and EventHandler.ASMSG_TRANSMOG_APPLIED and not EventHandler.__transmog38Traced then
	local orig_ASMSG_TRANSMOG_APPLIED = EventHandler.ASMSG_TRANSMOG_APPLIED;
	EventHandler.ASMSG_TRANSMOG_APPLIED = function(self, msg, ...)
		print("|cff00ff88[TDEBUG]|r ASMSG_TRANSMOG_APPLIED received, msg=" .. tostring(msg));
		local ok, err = pcall(orig_ASMSG_TRANSMOG_APPLIED, self, msg, ...);
		if not ok then
			print("|cffff0000[TDEBUG]|r ASMSG_TRANSMOG_APPLIED ERROR: " .. tostring(err));
		else
			local hasItemsFrame = WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame ~= nil;
			local hasTransmogFrame = WardrobeTransmogFrame ~= nil;
			print(string.format("|cff00ff88[TDEBUG]|r ASMSG_TRANSMOG_APPLIED processed without error | ItemsCollectionFrame present=%s | WardrobeTransmogFrame present=%s",
				tostring(hasItemsFrame), tostring(hasTransmogFrame)));
		end
	end
	EventHandler.__transmog38Traced = true;
end
