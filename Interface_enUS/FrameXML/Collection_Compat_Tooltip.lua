-- Collection_Compat_Tooltip.lua
-- Methodes GameTooltip manquantes (Sirus\FrameXML\GameTooltip.lua,
-- GameTooltipMixin), copiees verbatim. Doit charger APRES GameTooltip.xml
-- (le widget GameTooltip global n'existe pas encore avant), donc ce fichier
-- est place juste avant Custom_Collections.xml et non dans Collection_Compat.lua.
-- ============================================================
-- ROUND Transmog-3 : garde-fou GameTooltip:SetText. Erreur observee au survol
-- d'elements du Transmogrificateur : "[string \"*:OnEnter\"]:2: Usage:
-- GameTooltip:SetText(\"text\" [, color])" -- cette erreur native (le C
-- valide les types d'arguments) se declenche des qu'un script OnEnter
-- lui passe autre chose qu'une chaine (nil le plus souvent, ex. une
-- constante globale non definie sur ce client). Plutot que de traquer
-- un par un chaque site d'appel fragile dans le tres volumineux
-- Custom_Wardrobe.lua (2700+ lignes, jamais reellement exerce avant ce
-- round), on blinde SetText lui-meme sur ce frame precis : si l'appelant
-- ne fournit pas une chaine, on ne fait rien plutot que de planter.
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

-- FIX : GameTooltip:SetItemByID n'existe pas nativement sur ce client
-- (methode absente sur ce build WotLK 3.3.5), ce qui plantait
-- TransmogrifierClient.lua (bouton d'objet, OnEnter) avec "attempt to call
-- method 'SetItemByID' (a nil value)". Meme schema que SetToyByItemID /
-- SetHeirloomByItemID ci-dessus : on redirige vers SetHyperlink.
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
-- PATCH round Transmog-26 : GameTooltip:SetTransmogrifyItem n'existe pas sur
-- ce client (methode retail absente sur ce build WotLK 3.3.5). Elle est
-- appelee par Custom_Wardrobe.lua:513 (TransmogSlotButtonMixin:OnEnter, APRES
-- GameTooltip:SetInventoryItem) pour completer la tooltip du slot survole
-- avec une ligne d'info sur l'apparence en attente / annulable, et plantait
-- avec "attempt to call method 'SetTransmogrifyItem' (a nil value)".
-- Contrairement a SetItemByID/SetHeirloomByItemID ci-dessus, on n'appelle PAS
-- SetHyperlink ici : la tooltip de l'objet equipe est deja affichee par
-- SetInventoryItem juste avant, donc on se contente d'AJOUTER les lignes
-- d'info (meme logique que la branche illusion un peu plus haut dans
-- Custom_Wardrobe.lua, qui utilise deja TRANSMOGRIFY_FONT_COLOR /
-- WILL_BE_TRANSMOGRIFIED_HEADER / TRANSMOGRIFY_TOOLTIP_REVERT - ces globales
-- existent donc deja bien sur ce client).
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
-- PKBT_ButtonMixin:OnLoad / :InitButton : Universe fait
-- PKBT_ButtonMixin = CreateFromMixins(ThreeSliceButtonMixin), mais
-- ThreeSliceButtonMixin (SharedXML\SharedUIPanelTemplates.lua cote Sirus)
-- n'existe pas cote Universe -> PKBT_ButtonMixin n'a jamais eu de :OnLoad,
-- ce qui plante tout bouton PKBT dont le script XML fait self:OnLoad()
-- (ex. WardrobeFrameHelpFrameKnowledgeBaseButton, le bouton d'aide du PNJ
-- transmogrificateur - PAS l'onglet Garde-robe du Codex). Stub minimal :
-- positionne juste l'atlas 3-slice si disponible.
-- IMPORTANT : ce fix doit charger APRES SharedXML\SharedUIPanelPKBTTemplates.xml
-- (qui definit PKBT_ButtonMixin) - une premiere tentative placee dans
-- Collection_Compat.lua (charge trop tot) ne faisait donc rien.
-- ============================================================
if PKBT_ButtonMixin then
	if not PKBT_ButtonMixin.InitButton then
		function PKBT_ButtonMixin:InitButton()
			-- no-op : voir OnLoad ci-dessous.
		end
	end
	if not PKBT_ButtonMixin.OnLoad then
		function PKBT_ButtonMixin:OnLoad()
			-- PATCH Collection : no-op pur. Un premier essai appelait
			-- self:SetThreeSliceAtlas(...), mais celle-ci appelle a son tour
			-- self:UpdateButton() qui n'existe pas non plus cote Universe
			-- (meme cause : ThreeSliceButtonMixin absent). Plutot que de
			-- rajouter un stub par methode manquante en cascade pour un
			-- bouton d'aide du PNJ transmogrificateur (hors Codex), on
			-- s'arrete ici : le bouton garde sa texture par defaut du
			-- template XML, mais ne crashe plus.
		end
	end
	if not PKBT_ButtonMixin.UpdateButton then
		-- ROUND Transmog : PKBT_ButtonMixin:OnShow/:OnEnable/:OnDisable
		-- (SharedXML\SharedUIPanelPKBTTemplates.lua) appellent tous les
		-- trois self:UpdateButton() sans jamais verifier son existence.
		-- Sans ce stub, le seul fait d'AFFICHER un bouton PKBT minimal (ex.
		-- WardrobeFrameHelpFrameKnowledgeBaseButton) plantait des l'OnShow,
		-- avant meme d'atteindre InitButton/OnLoad ci-dessus. Meme
		-- philosophie que les deux stubs precedents : no-op pur, le bouton
		-- garde sa texture par defaut mais ne crashe plus.
		function PKBT_ButtonMixin:UpdateButton()
		end
	end
end

-- ============================================================
-- ModelsPanningFrame:OnUpdate : bug preexistant d'Universe (SharedXML\
-- ModelFrames.xml, script inline non lie a Collection), qui suppose que
-- model.controlFrameModel existe toujours. Pour certains widgets modele
-- (ex. l'apercu de monture, model scene "MountDisplayModelScene"), ce
-- champ est nil, ce qui fait planter ce script en boucle tant que la
-- fenetre de panning reste affichee (spam d'erreurs, "Count: 249").
-- On remplace le script par une version avec garde-fou, sans toucher au
-- fichier XML d'origine.
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
		print("|cffff0000[Collection Debug]|r Collection_DebugSkills indisponible (ouvrez d'abord le Garde-robe au moins une fois).")
	end
end

-- ============================================================
-- PATCH round Transmog-26: /diagcp v7 - le round 25 a signale
-- "CRASH ENTRE LIGNE 1032 ET LIGNE 1047", mais c'etait un FAUX signal : le
-- checkpoint 1047 avait ete place par erreur A L'INTERIEUR du constructeur de
-- table COLLECTION_SHIMMED_CVARS = { ... } (le ';' est un separateur de champ
-- valide en Lua a cet endroit, donc "DIAGv25_CP1047 = true" ajoutait juste une
-- cle a la table au lieu d'assigner la variable globale -> elle restait donc
-- nil meme si le fichier continuait de s'executer normalement). Verifie
-- (script Python, comptage d'accolades) : c'est le SEUL checkpoint sur les 51
-- concerne par ce probleme. Corrige en deplacant ce checkpoint juste apres la
-- fermeture de la table. Devrait maintenant afficher FICHIER COMPLET.
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
			print("CRASH ENTRE LIGNE " .. last .. " ET LIGNE " .. v);
			return;
		end
	end
	if DIAGv26_END then
		print("FICHIER COMPLET - dernier checkpoint=" .. last);
	else
		print("CRASH APRES LIGNE " .. last .. " (avant la fin du fichier)");
	end
end

-- PATCH round 34: diagnostic dedie a la creature 413 (mannequin d'affichage
-- d'armes). Custom_Wardrobe.xml contient deja un widget DummyWardrobeWeaponModel
-- dont le seul but est de "faire chauffer" cette creature en boucle jusqu'a ce
-- que GetModel() ne renvoie plus le widget lui-meme (signe que le modele a
-- charge). Si cette creature n'existe pas / n'a pas de displayID valide sur
-- Universe, cette boucle tourne indefiniment et aucune arme ne peut jamais
-- s'afficher, quel que soit le code Lua autour. Ce test isole le probleme.
SLASH_MODELDEBUG1 = "/mdebug"
SlashCmdList["MODELDEBUG"] = function()
	if not DummyWardrobeWeaponModel then
		print("|cffff0000[Model Debug]|r DummyWardrobeWeaponModel introuvable (le XML n'a peut-etre pas charge).");
		return;
	end

	local before = DummyWardrobeWeaponModel:GetModel();
	print("|cffffcc00[Model Debug]|r AVANT SetCreature(413) : GetModel() == self ?", tostring(before == DummyWardrobeWeaponModel));

	local ok, err = pcall(DummyWardrobeWeaponModel.SetCreature, DummyWardrobeWeaponModel, 413);
	print("|cffffcc00[Model Debug]|r SetCreature(413) ok =", tostring(ok), err and ("erreur: " .. tostring(err)) or "");

	local after = DummyWardrobeWeaponModel:GetModel();
	print("|cffffcc00[Model Debug]|r APRES SetCreature(413) : GetModel() == self ?", tostring(after == DummyWardrobeWeaponModel), " GetModel() =", tostring(after));

	-- Test avec un modele fiable pour comparaison (le joueur lui-meme).
	local testModel = CreateFrame("DressUpModel");
	testModel:SetUnit("player");
	print("|cffffcc00[Model Debug]|r Reference SetUnit(player) : GetModel() =", tostring(testModel:GetModel()));

	-- Quelques ID alternatifs plausibles pour un mannequin d'affichage d'arme,
	-- au cas ou 413 ne serait pas le bon sur Universe.
	local candidateIDs = {413, 17, 942, 1};
	for _, cid in ipairs(candidateIDs) do
		local okC, errC = pcall(testModel.SetCreature, testModel, cid);
		local m = okC and testModel:GetModel();
		print(string.format("  candidat creature %d : ok=%s GetModel()==self? %s", cid, tostring(okC), tostring(m == testModel)));
	end
end


-- PATCH round 35: trace pas-a-pas de la SEQUENCE REELLE utilisee par
-- SetItemAppearance (SetCreature -> Undress -> TryOn) sur le widget deja
-- pre-charge DummyWardrobeWeaponModel, pour voir a quelle etape precise le
-- modele "se perd". sourceID=15230 = "Fendoir strie" (confirme resolu par
-- /wdebug precedent).
SLASH_MODELTRACE1 = "/mtrace"
SlashCmdList["MODELTRACE"] = function()
	if not DummyWardrobeWeaponModel then
		print("|cffff0000[Model Trace]|r DummyWardrobeWeaponModel introuvable.");
		return;
	end

	local m = DummyWardrobeWeaponModel;
	local function report(step)
		local model = m:GetModel();
		print(string.format("|cffffcc00[Model Trace]|r apres %s : GetModel()==self? %s type=%s", step, tostring(model == m), type(model)));
	end

	report("(etat initial, deja chauffe)");

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
		print("|cffff0000[Wardrobe Debug]|r WardrobeCollectionFrame.ItemsCollectionFrame introuvable (ouvrez d'abord le Garde-robe).");
		return;
	end

	print("|cffffcc00[Wardrobe Debug]|r activeCategory =", tostring(frame.activeCategory), " activeSubCategory =", tostring(frame.activeSubCategory));

	local loc = frame.transmogLocation;
	if loc then
		local isAppearance = loc.IsAppearance and loc:IsAppearance();
		local isIllusion = loc.IsIllusion and loc:IsIllusion();
		print("|cffffcc00[Wardrobe Debug]|r transmogLocation: type=", tostring(loc.type), " slotID=", tostring(loc.slotID), " IsAppearance=", tostring(isAppearance), " IsIllusion=", tostring(isIllusion));
	else
		print("|cffff0000[Wardrobe Debug]|r frame.transmogLocation est nil");
	end

	local visualsList = frame.visualsList;
	if not visualsList then
		print("|cffff0000[Wardrobe Debug]|r frame.visualsList est nil (RefreshVisualsList n'a peut-etre pas encore tourne).");
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
			print("      ItemsCache[sourceID] existe =", tostring(ItemsCache and ItemsCache[sourceID] ~= nil));
			if C_Item and C_Item.GetItemInfoRaw then
				local ok, result = pcall(C_Item.GetItemInfoRaw, sourceID);
				print("      C_Item.GetItemInfoRaw(sourceID) =", ok and tostring(result) or ("ERREUR: " .. tostring(result)));
			end
			local ok2, result2 = pcall(GetItemInfo, sourceID);
			print("      GetItemInfo(sourceID) [natif global] =", ok2 and tostring(result2) or ("ERREUR: " .. tostring(result2)));
		end

		-- PATCH round 32: diagnostic specifique cases noires Armes. On resout le
		-- sourceID exactement comme le fait UpdateItems (via GetAnAppearanceSourceFromVisual
		-- et GetSortedAppearanceSources) pour voir si le probleme vient d'une liste de
		-- sources vide (categorie/sous-categorie qui ne matchent jamais) ou d'autre chose.
		if v.visualID and frame.GetAnAppearanceSourceFromVisual then
			local okA, resolvedSourceID = pcall(frame.GetAnAppearanceSourceFromVisual, frame, v.visualID, nil);
			print("      GetAnAppearanceSourceFromVisual(visualID) =", okA and tostring(resolvedSourceID) or ("ERREUR: " .. tostring(resolvedSourceID)));

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
					print("      GetSortedAppearanceSources ERREUR:", tostring(sources));
				end
			end
		end
	end
end

SLASH_HEIRLOOMDEBUG1 = "/hdebug"
SlashCmdList["HEIRLOOMDEBUG"] = function()
	if not C_Heirloom or not C_Heirloom.DebugState then
		print("|cffff0000[Heirloom Debug]|r C_Heirloom.DebugState indisponible.");
		return;
	end

	local populated, dataCount, displayedCount, classFilter, specFilter = C_Heirloom.DebugState();
	print("|cffffcc00[Heirloom Debug]|r populated =", tostring(populated), " #COLLECTION_HEIRLOOMDATA =", dataCount, " #HEIRLOOMS (filtres) =", displayedCount);
	print("|cffffcc00[Heirloom Debug]|r classFilter =", tostring(classFilter), " specFilter =", tostring(specFilter));

	local numDisplayed = C_Heirloom.GetNumDisplayedHeirlooms and C_Heirloom.GetNumDisplayedHeirlooms() or "n/a";
	print("|cffffcc00[Heirloom Debug]|r C_Heirloom.GetNumDisplayedHeirlooms() =", tostring(numDisplayed));

	if type(numDisplayed) == "number" and numDisplayed > 0 then
		for i = 1, math.min(3, numDisplayed) do
			local itemID = C_Heirloom.GetHeirloomItemIDFromDisplayedIndex(i);
			local ok, name, itemEquipLoc = pcall(C_Heirloom.GetHeirloomInfo, itemID);
			print(string.format("  [%d] itemID=%s name=%s equipLoc=%s", i, tostring(itemID), ok and tostring(name) or ("ERREUR:" .. tostring(name)), tostring(itemEquipLoc)));
		end
	end

	local frame = HeirloomsJournal;
	if frame then
		print("|cffffcc00[Heirloom Debug]|r HeirloomsJournal:IsVisible() =", tostring(frame:IsVisible()), " numKnownHeirlooms =", tostring(frame.numKnownHeirlooms), " numPossibleHeirlooms =", tostring(frame.numPossibleHeirlooms));
		print("|cffffcc00[Heirloom Debug]|r needsDataRebuilt =", tostring(frame.needsDataRebuilt), " needsRefresh =", tostring(frame.needsRefresh), " filtersSet =", tostring(frame.filtersSet));
		print("|cffffcc00[Heirloom Debug]|r #heirloomLayoutData =", tostring(frame.heirloomLayoutData and #frame.heirloomLayoutData));

		-- ROUND 58 : forcer un rebuild propre, hors de tout contexte de
		-- script deja en cours (donc aucun risque de reentrance), et capter
		-- toute erreur silencieuse avec pcall pour savoir si
		-- RebuildLayoutData plante reellement ou si le probleme est ailleurs.
		local okBuckets, equipBucketsOrErr = pcall(frame.SortHeirloomsIntoEquipmentBuckets, frame);
		if okBuckets then
			local bucketCount = 0;
			for _ in pairs(equipBucketsOrErr) do bucketCount = bucketCount + 1; end
			print("|cffffcc00[Heirloom Debug]|r SortHeirloomsIntoEquipmentBuckets() OK, categories remplies =", bucketCount, " numPossibleHeirlooms apres appel =", tostring(frame.numPossibleHeirlooms));
		else
			print("|cffff0000[Heirloom Debug]|r SortHeirloomsIntoEquipmentBuckets() a plante :", tostring(equipBucketsOrErr));
		end

		frame.needsDataRebuilt = true;
		local okRebuild, rebuildErr = pcall(frame.RebuildLayoutData, frame);
		if okRebuild then
			print("|cffffcc00[Heirloom Debug]|r RebuildLayoutData() force OK -> numPossibleHeirlooms =", tostring(frame.numPossibleHeirlooms), " #heirloomLayoutData =", tostring(frame.heirloomLayoutData and #frame.heirloomLayoutData));
		else
			print("|cffff0000[Heirloom Debug]|r RebuildLayoutData() a plante :", tostring(rebuildErr));
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

-- PATCH round 110 : MAIN_HELP_BUTTON_TOOLTIP manquant (meme cause que les
-- HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_1.._9 : uniquement defini en russe
-- dans Sirus/GlobalStrings.lua, absent d'Universe). C'est le texte affiche
-- par la grosse fleche qui part de l'icone "i" principale (portrait, en
-- haut a gauche) quand on la survole - le bouton maitre qui active/desactive
-- tout le plan d'aide, distinct des 9 bulles numerotees deja traduites.
MAIN_HELP_BUTTON_TOOLTIP = "Show/hide this window's tooltips.";

-- PATCH round 111 : meme cause, 4 nouveaux globaux manquants (uniquement
-- en russe dans Sirus/GlobalStrings.lua) : les tooltips (GameTooltip classique,
-- pas HelpPlate) affiches au survol de l'icone "i" des onglets Jouets et
-- Heritage (Custom_ToyBox.xml / Custom_HeirloomCollection.xml).
HELPTIP_TOYS_HEAD = "'Toys' collection specifics";
HELPTIP_TOYS = "Toys are items intended for entertainment.\n\nSome provide a cosmetic effect, others let you summon a world object to interact with.\n\nHover over the toy you're interested in to learn how to use it or how to obtain it.";
HELPTIP_HEIRLOOM_HEAD = "'Heirloom' collection specifics";
HELPTIP_HEIRLOOM = "Heirloom items are items designed to make leveling up your character easier. This type of item generally increases the experience gained by the character from quests and killing monsters. Their stats also increase with the character's level, up to level 80.\n\nOn our server, Heirloom items are added to the collection using special tokens. You can obtain them in-game with internal currency, or from our store.\n\nOnce an item is added to the collection, it becomes accessible on any character on the account, in the game world.\n\nTo obtain a Heirloom item, left-click it: it will then join your bag. This action can be repeated an unlimited number of times.";

-- PATCH round 114 : titres/descriptions des specialisations Chasseur de
-- demons (S_CALSS_SPECIALIZATION_DATA[CLASS_ID_DEMONHUNTER], base client
-- Universe) referencent DEMONHUNTER_HAVOC/REVENGE/POSESSION_TITLE/_DESC,
-- jamais definis nulle part cote Universe (seulement en russe cote Sirus/
-- GlobalStrings.lua) -> case a cocher sans texte dans le sous-menu
-- specialisations de l'onglet Heritage. C'est la SEULE classe presente
-- dans cette table (Mage de sang/Cavalier/Moine/Dompteur/Heros n'y sont
-- pas du tout, donc 0 ligne de specialisation pour elles, pas de bug).
DEMONHUNTER_HAVOC_TITLE = "Havoc";
DEMONHUNTER_HAVOC_DESC = "Dark master of combat blades and devastating Fel magic.";
DEMONHUNTER_REVENGE_TITLE = "Vengeance";
DEMONHUNTER_REVENGE_DESC = "Uses the power of the inner demon to incinerate enemies and protect allies.";
DEMONHUNTER_POSESSION_TITLE = "Possession";
DEMONHUNTER_POSESSION_DESC = "Unleashes the inner demon to fight enemies.";

-- Ces globales seules NE SUFFISENT PAS : S_CALSS_SPECIALIZATION_DATA (dans
-- SharedXML\SharedConstants.lua, toc ligne 38) capture leur VALEUR au
-- moment de la construction de la table, laquelle a lieu tres tot, bien
-- avant que ce fichier-ci (toc ligne 242) ne les definisse. Sans le patch
-- direct ci-dessous, les 3 sous-tables Chasseur de demons resteraient donc
-- figees avec title/desc = nil pour toujours, meme avec les globales
-- ci-dessus definies (meme piege que PLAYER_CLASS_FLAG au round 101).
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


-- PATCH round 109: diagnostic dedie aux bulles d'aide (HelpPlate) vides du
-- Garde-robe. L'utilisateur confirme avoir survole une icone "i" et vu une
-- bulle sans texte, MEME APRES le round 108 (traduction frFR ajoutee en fin
-- de Collection_Compat.lua). Deux causes possibles a departager :
--   1) Les globales HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_1.._9 ne sont pas
--      definies du tout (le patch round 108 n'a pas ete applique, ou une
--      erreur runtime plus haut dans Collection_Compat.lua interrompt le
--      fichier avant d'atteindre le bloc ajoute en fin de fichier - deja vu
--      au round 26 avec SlashCmdList).
--   2) Les globales SONT definies, mais WardrobeFrame.helpPlate a capture
--      leur valeur AVANT qu'elles n'existent (OnLoad qui tourne trop tot).
-- Cette commande affiche l'etat reel des deux pour trancher sans deviner.
SLASH_HELPPLATEDEBUG1 = "/hpdebug"
SlashCmdList["HELPPLATEDEBUG"] = function()
	print("|cffffcc00[HelpPlate Debug]|r --- Globales HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_1..9 ---");
	for i = 1, 9 do
		local v = _G["HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_" .. i];
		if type(v) == "string" then
			print(string.format("  [%d] DEFINIE, longueur=%d, debut=%q", i, #v, v:sub(1, 40)));
		else
			print(string.format("  [%d] |cffff0000NIL|r (type=%s)", i, type(v)));
		end
	end

	print("|cffffcc00[HelpPlate Debug]|r --- WardrobeFrame.helpPlate (capture au OnLoad) ---");
	if not WardrobeFrame then
		print("  WardrobeFrame introuvable.");
		return;
	end
	if not WardrobeFrame.helpPlate then
		print("  WardrobeFrame.helpPlate est nil (OnLoad n'a peut-etre pas encore tourne).");
		return;
	end
	for i = 1, 9 do
		local entry = WardrobeFrame.helpPlate[i];
		if not entry then
			print(string.format("  [%d] entree absente", i));
		else
			local t = entry.ToolTipText;
			if type(t) == "string" then
				print(string.format("  [%d] ToolTipText DEFINI, longueur=%d, debut=%q", i, #t, t:sub(1, 40)));
			else
				print(string.format("  [%d] ToolTipText |cffff0000NIL|r (type=%s) -> capture au chargement a echoue", i, type(t)));
			end
		end
	end
end

-- PATCH round 112 : libelles des cases a cocher dans les sous-menus du
-- bouton Filtrer (Capacites/Sources/Faction pour Montures, Familles de
-- familiers/Sources pour Familiers, Sources pour Garde-robe/Jouets/
-- Heritage). FilterDropdown.lua (AddDynamicFilterSet) construit le texte
-- de chaque case via _G[globalPrepend .. i] ; ces globales n'existaient
-- qu'en russe cote Sirus/GlobalStrings.lua -> texte nil -> case a cocher
-- sans libelle a cote, dans les 5 onglets a la fois (meme prefixe partage).
-- COLLECTION_MOUNT_ABILITY_*
COLLECTION_MOUNT_ABILITY_1 = "Vitesse au sol 60";
COLLECTION_MOUNT_ABILITY_2 = "Vitesse au sol 100";
COLLECTION_MOUNT_ABILITY_3 = "Vitesse de vol 280";
COLLECTION_MOUNT_ABILITY_4 = "Vitesse de vol 310";
COLLECTION_MOUNT_ABILITY_5 = "Marche sur l'eau";
COLLECTION_MOUNT_ABILITY_6 = "Improved Swimming";
COLLECTION_MOUNT_ABILITY_7 = "Biplace";
COLLECTION_MOUNT_ABILITY_8 = "Triplace";
COLLECTION_MOUNT_ABILITY_9 = "Vendor or Repairman";
COLLECTION_MOUNT_ABILITY_10 = "Enables faster flight";
COLLECTION_MOUNT_ABILITY_11 = "Account-wide";
-- COLLECTION_PET_SOURCE_*
COLLECTION_PET_SOURCE_1 = "Butin";
COLLECTION_PET_SOURCE_2 = "Quests";
COLLECTION_PET_SOURCE_3 = "Marchand";
COLLECTION_PET_SOURCE_4 = "Profession";
COLLECTION_PET_SOURCE_5 = "Haut fait";
COLLECTION_PET_SOURCE_6 = "In-Game Event";
COLLECTION_PET_SOURCE_7 = "Boutique en jeu";
COLLECTION_PET_SOURCE_8 = "Points de vote";
COLLECTION_PET_SOURCE_9 = "Passe de combat";
COLLECTION_PET_SOURCE_10 = "Black Market";
-- COLLECTION_TRAVELING_MERCHANT_*
COLLECTION_TRAVELING_MERCHANT_1 = "Lurgen";
COLLECTION_TRAVELING_MERCHANT_2 = "Aishali";
COLLECTION_TRAVELING_MERCHANT_3 = "Saralet";
-- COLLECTION_MOUNT_FACTION_*
COLLECTION_MOUNT_FACTION_1 = "Alliance";
COLLECTION_MOUNT_FACTION_2 = "Horde";
COLLECTION_MOUNT_FACTION_3 = "Neutre";
COLLECTION_MOUNT_FACTION_4 = "Renegades";
-- COLLECTION_PET_NAME_*
COLLECTION_PET_NAME_1 = "Aquatique";
COLLECTION_PET_NAME_2 = "Humanoid";
COLLECTION_PET_NAME_3 = "Dragonnet";
COLLECTION_PET_NAME_4 = "Beast";
COLLECTION_PET_NAME_5 = "Bestiole";
COLLECTION_PET_NAME_6 = "Volant";
COLLECTION_PET_NAME_7 = "Magique";
COLLECTION_PET_NAME_8 = "Mechanical";
COLLECTION_PET_NAME_9 = "Mort-vivant";
COLLECTION_PET_NAME_10 = "Elemental";
-- TRANSMOG_SOURCE_*
TRANSMOG_SOURCE_1 = "Butin de boss";
TRANSMOG_SOURCE_2 = "Quests";
TRANSMOG_SOURCE_3 = "Marchand";
TRANSMOG_SOURCE_4 = "Random Loot";
TRANSMOG_SOURCE_5 = "Haut fait";
TRANSMOG_SOURCE_6 = "Profession";
TRANSMOG_SOURCE_7 = "Boutique en jeu";
TRANSMOG_SOURCE_8 = "Available when upgrading an item";
TRANSMOG_SOURCE_9 = "Special Events";
TRANSMOG_SOURCE_10 = "Black Market Contraband";
TRANSMOG_SOURCE_11 = "Guild Rewards";
TRANSMOG_SOURCE_12 = "Starting Equipment";
TRANSMOG_SOURCE_13 = "Transmogrification (boutique)";
TRANSMOG_SOURCE_14 = "Non disponible actuellement";

-- PATCH round 117 : erreur "GetBindingKey: Usage: GetBindingKey(...)" au survol
-- of the "Professions" tab of the Spellbook (SpellBookFrameTabButton2). In
-- SpellBookFrame.lua, la ligne "SpellBookFrameTabButton2.binding = TOGGLEPROFESSIONBOOK;"
-- reference une variable globale SANS guillemets (contrairement a "TOGGLESPELLBOOK",
-- "TOGGLEPETBOOK", etc. qui sont bien des chaines litterales juste au-dessus/en-dessous).
-- Cette globale TOGGLEPROFESSIONBOOK n'existe nulle part dans le client -> nil -> le
-- OnEnter de cet onglet (SpellBookFrame.xml) appelle ensuite MicroButtonTooltipText(text, nil)
-- -> GetBindingKey(nil) -> crash. En definissant cette globale comme une chaine (au pire
-- une action de binding qui n'existe simplement pas, comme c'etait deja implicitement le cas
-- pour cet onglet), SpellBookFrame_Update() (qui reassigne .binding a chaque affichage du
-- Grimoire) lui donnera desormais toujours une vraie chaine et GetBindingKey ne plantera plus.
TOGGLEPROFESSIONBOOK = "TOGGLEPROFESSIONBOOK";

-- PATCH round 117 : erreur "attempt to call global 'LootWonAlertFrame_ShowAlert' (a nil value)"
-- a chaque butin recu. ChatFrame.lua (evenement CHAT_MSG_LOOT) appelle cette fonction pour
-- afficher un toast visuel "Objet obtenu" (fonctionnalite retail), mais elle n'a jamais ete
-- portee dans ce client 3.3.5 -- AlertFrames.lua ne definit que AchievementAlertFrame_ShowAlert
-- et DungeonCompletionAlertFrame_ShowAlert, pas celle-ci. Le message de butin s'affiche deja
-- normalement dans le chat juste apres cet appel (self:AddMessage) ; ce stub vide supprime
-- seulement le crash, sans toast visuel. Si un vrai toast "Objet obtenu" est souhaite plus
-- tard, ce sera un ajout separe (nouvelle frame a construire).
if not LootWonAlertFrame_ShowAlert then
	function LootWonAlertFrame_ShowAlert(itemLink)
	end
end

-- ============================================================
-- ROUND Transmog-2 : SetUIPanelAttribute manquant. Cette fonction (introduite
-- dans une expansion posterieure a 3.3.5, cote retail elle passe par un frame
-- secure FramePositionDelegate:SetAttribute) n'existe pas du tout sur ce
-- client -- plantait WardrobeFrameMixin:SetShowHelpFrame (Custom_Wardrobe.lua)
-- des le premier clic sur le bouton d'aide "i" du Transmogrificateur :
-- "attempt to call global 'SetUIPanelAttribute' (a nil value)".
-- Stub minimal : ecrit directement l'attribut dans UIPanelWindows[nomDuFrame],
-- la meme table simple que ce client utilise deja pour toute la gestion des
-- panneaux (area/pushable/width/xOffset/yOffset, voir UIPanelWindows["WardrobeFrame"]
-- dans Custom_Wardrobe.lua). Suffisant pour eliminer le crash ; l'elargissement
-- visuel du panneau pour le volet d'aide reste cosmetique et secondaire face au
-- besoin principal (transmogrifier sans planter).
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
-- ROUND Transmog-2 : C_Item.DoesItemExist manquant. ItemLocationMixin:IsValid()
-- (Interface\FrameXML\ItemLocation.lua) appelle C_Item.DoesItemExist(self) sans
-- garde -- absent sur ce client, ce qui plantait TransmogSlotButtonMixin:GetEffectiveTransmogID
-- (Custom_Wardrobe.lua) des l'affichage du Transmogrificateur, empechant TOUTE
-- case d'equipement de se peupler (Update() s'arretait la pour chaque slot,
-- d'ou les cases vides malgre un equipement porte). Stub : verifie directement
-- via les API natives WotLK 3.3.5 (GetInventoryItemID / GetContainerItemID)
-- si un objet existe reellement a l'emplacement decrit par l'ItemLocation.
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
-- ROUND Transmog-31 : /tclickdebug -- tracage live du clic dans la grille
-- ============================================================
-- Le round 30 (fallback frame:OnEvent dans FireCustomClientEvent) n'a PAS
-- resolu "impossible de selectionner un item directement dans l'onglet
-- Transmogrification". Plutot que de continuer a deviner, cette commande
-- instrumente EN DIRECT (sans rien changer au comportement reel) toute la
-- chaine impliquee par un clic sur un item de la grille :
--   OnClick -> WardrobeItemsCollectionMixin:SelectVisual
--           -> TransmogFrameMixin:SetPendingTransmog (necessite
--              WardrobeTransmogFrame.selectedSlotButton != nil !)
--           -> C_Transmog.SetPending (ecrit _pending[slotID] + notifie)
--           -> FireCustomClientEvent("TRANSMOGRIFY_UPDATE")
--           -> WardrobeItemsCollectionMixin:OnEvent (doit maintenant etre
--              atteint grace au fix round 30) -> UpdateItems (recalcule la
--              bordure via C_Transmog.GetSlotVisualInfo)
--
-- Usage : taper /tclickdebug UNE FOIS pour activer (la commande le redit),
-- puis cliquer un item dans l'onglet Transmogrification, puis copier-coller
-- les lignes "[TDEBUG]" qui apparaissent dans le chat. Retaper /tclickdebug
-- pour desactiver.
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

	-- FIX ROUND TRANSMOG-32 : le premier jet de /tclickdebug (round 31)
	-- accrochait les methodes sur les TABLES MIXIN partagees
	-- (WardrobeItemsCollectionMixin.SelectVisual = ..., etc). Or Mixin(objet,
	-- MixinTable) -- utilise par ce code retail porte tel quel -- COPIE les
	-- fonctions UNE FOIS sur l'INSTANCE au moment du OnLoad (bien avant que le
	-- joueur ne tape /tclickdebug) : reassigner la table mixin APRES coup n'a
	-- alors plus aucun effet sur les frames deja charges (WardrobeTransmogFrame,
	-- WardrobeCollectionFrame.ItemsCollectionFrame). Resultat observe : seul le
	-- hook sur C_Transmog.SetPending (une fonction de table normale, jamais
	-- "copiee" nulle part, toujours relue en direct) se declenchait -- d'ou des
	-- lignes "[TDEBUG] C_Transmog.SetPending(...)" san aucune ligne
	-- SelectVisual/SelectSlotButton/SetPendingTransmog avant. On accroche
	-- desormais directement sur les INSTANCES reelles (WardrobeTransmogFrame et
	-- WardrobeCollectionFrame.ItemsCollectionFrame), qui existent forcement deja
	-- a ce stade (le joueur doit avoir ouvert Garde-robe ou Transmogrification
	-- au moins une fois avant de taper la commande).
	if not (C_Transmog and WardrobeTransmogFrame and WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame) then
		return false; -- pas encore charge, on reessaiera au prochain toggle
	end

	local itemsFrame = WardrobeCollectionFrame.ItemsCollectionFrame;
	local transmogFrame = WardrobeTransmogFrame;

	-- 1) SelectVisual : point d'entree du clic gauche sur un item (sur
	-- l'INSTANCE reelle de la grille, pas sur la table mixin).
	local orig_SelectVisual = itemsFrame.SelectVisual;
	itemsFrame.SelectVisual = function(self, visualID, ...)
		local atNPC = C_Transmog.IsAtTransmogNPC();
		local gridSlotID = self.transmogLocation and self.transmogLocation:GetSlotID();
		tdbg(string.format("SelectVisual(visualID=%s) | IsAtTransmogNPC=%s | grid.transmogLocation:GetSlotID()=%s | activeCategory=%s/%s",
			tostring(visualID), tostring(atNPC), tostring(gridSlotID), tostring(self.activeCategory), tostring(self.activeSubCategory)));
		if not atNPC then
			tdbg("  -> ABANDON ICI : IsAtTransmogNPC() = false, SelectVisual s'arrete (retour immediat, rien d'autre ne s'execute).");
		end
		return orig_SelectVisual(self, visualID, ...);
	end

	-- 2) SelectSlotButton : quel emplacement (Tete/Torse/...) est actuellement
	-- selectionne sur le mannequin, cote WardrobeTransmogFrame.
	local orig_SelectSlotButton = transmogFrame.SelectSlotButton;
	transmogFrame.SelectSlotButton = function(self, slotButton, fromOnClick, ...)
		local slotID = slotButton and slotButton.transmogLocation and slotButton.transmogLocation:GetSlotID();
		tdbg(string.format("SelectSlotButton(slotID=%s, fromOnClick=%s)", tostring(slotID), tostring(fromOnClick)));
		return orig_SelectSlotButton(self, slotButton, fromOnClick, ...);
	end

	-- 3) SetPendingTransmog : n'ecrit REELLEMENT quelque chose que si
	-- self.selectedSlotButton est deja renseigne -- suspect n°1 si ca reste
	-- nil pendant qu'on est sur l'onglet Transmogrification.
	local orig_SetPendingTransmog = transmogFrame.SetPendingTransmog;
	transmogFrame.SetPendingTransmog = function(self, transmogID, category, subCategory, ...)
		local hasSlotButton = self.selectedSlotButton ~= nil;
		local slotID = hasSlotButton and self.selectedSlotButton.transmogLocation and self.selectedSlotButton.transmogLocation:GetSlotID();
		tdbg(string.format("SetPendingTransmog(transmogID=%s) | selectedSlotButton=%s | slotID=%s",
			tostring(transmogID), tostring(hasSlotButton), tostring(slotID)));
		if not hasSlotButton then
			tdbg("  -> ABANDON ICI : WardrobeTransmogFrame.selectedSlotButton est nil, C_Transmog.SetPending n'est JAMAIS appele.");
		end
		return orig_SetPendingTransmog(self, transmogID, category, subCategory, ...);
	end

	-- 4) C_Transmog.SetPending : ecriture reelle de _pending[slotID].
	local orig_SetPending = C_Transmog.SetPending;
	C_Transmog.SetPending = function(transmogLocation, pendingInfo, ...)
		local slotID = transmogLocation and transmogLocation:GetSlotID();
		tdbg(string.format("C_Transmog.SetPending(slotID=%s, transmogID=%s)", tostring(slotID), tostring(pendingInfo and pendingInfo.transmogID)));
		return orig_SetPending(transmogLocation, pendingInfo, ...);
	end

	-- 5) OnEvent (instance) : confirme si TRANSMOGRIFY_UPDATE est bien recu
	-- par la grille (cense etre corrige par le round 30).
	local orig_OnEvent = itemsFrame.OnEvent;
	itemsFrame.OnEvent = function(self, event, ...)
		if event == "TRANSMOGRIFY_UPDATE" or event == "TRANSMOGRIFY_SUCCESS" then
			TCLICKDEBUG_LAST_ONEVENT_FIRED = event;
			tdbg(string.format("ItemsCollectionFrame:OnEvent RECU event=%s | grid.transmogLocation:GetSlotID()=%s",
				tostring(event), tostring(self.transmogLocation and self.transmogLocation:GetSlotID())));
		end
		return orig_OnEvent(self, event, ...);
	end

	-- 5bis) FireCustomClientEvent (ROUND 32/34) : verifie EMPIRIQUEMENT si le
	-- correctif du round 30 (repli vers frame:OnEvent quand frame:GetScript
	-- ("OnEvent") est nil) est reellement actif chez toi. Round 33 mesurait
	-- juste "atteint=true/false" via un flag -- toujours false chez toi meme
	-- apres avoir remplace Collection_Compat.lua. Round 34 : au lieu d'inferer,
	-- on INSPECTE DIRECTEMENT chaque listener enregistre pour TRANSMOGRIFY_UPDATE
	-- (frame:GetScript("OnEvent") existe ? frame.OnEvent existe ?) -- ceci ne
	-- depend d'AUCUNE hypothese sur le code reellement installe, juste de l'etat
	-- reel des frames en jeu au moment du clic.
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
						tdbg(string.format("  listener #%d : itemsFrame=%s transmogFrame=%s GetScript(OnEvent)=%s frame.OnEvent(methode)=%s",
							count, tostring(isItemsFrame), tostring(isTransmogFrame), tostring(hasScript), tostring(hasOnEventMethod)));
					end
				end
				tdbg(string.format("FireCustomClientEvent(%s) | listeners enregistres=%d", tostring(event), count));
				local a, b, c, d, e, f = orig_FireCustomClientEvent(event, ...);
				local reached = (TCLICKDEBUG_LAST_ONEVENT_FIRED == event);
				tdbg(string.format("FireCustomClientEvent(%s) termine | ItemsCollectionFrame:OnEvent atteint=%s%s",
					tostring(event), tostring(reached),
					(not reached) and "  <-- voir le detail 'GetScript(OnEvent)'/'frame.OnEvent' ci-dessus pour la vraie raison." or ""));
				return a, b, c, d, e, f;
			end
			return orig_FireCustomClientEvent(event, ...);
		end
	end

	-- 6) UpdateItems (instance) : etat final utilise pour dessiner la bordure.
	local orig_UpdateItems = itemsFrame.UpdateItems;
	itemsFrame.UpdateItems = function(self, ...)
		local atNPC = C_Transmog.IsAtTransmogNPC();
		local ok, baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID = pcall(C_Transmog.GetSlotVisualInfo, self.transmogLocation);
		if ok then
			tdbg(string.format("UpdateItems() | IsAtTransmogNPC=%s | baseVisualID=%s appliedVisualID=%s pendingVisualID=%s",
				tostring(atNPC), tostring(baseVisualID), tostring(appliedVisualID), tostring(pendingVisualID)));
		else
			tdbg("UpdateItems() | IsAtTransmogNPC=" .. tostring(atNPC) .. " | GetSlotVisualInfo ERREUR: " .. tostring(baseSourceID));
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
			print("|cff00ff88[TDEBUG]|r ACTIVE. Ouvre l'onglet Transmogrification et clique un item de la grille : les etapes vont s'afficher ici.");
		else
			TCLICKDEBUG_ENABLED = false;
			print("|cffff0000[TDEBUG]|r Impossible d'activer : ouvre d'abord une fois le Garde-robe ou la Transmogrification (le code necessaire n'est pas encore charge), puis retape /tclickdebug.");
		end
	else
		print("|cff00ff88[TDEBUG]|r DESACTIVE.");
	end
end

-- ============================================================
-- ROUND Transmog-38 : /tbagdebug -- pourquoi seulement 5/13 epaulettes
-- (et 0 arme) detectees en sac malgre le fix round 37.
-- ============================================================
-- Usage : ouvre l'onglet Transmogrification sur l'emplacement concerne
-- (ex. Epaules, filtre "Tous"), PUIS tape /tbagdebug. Affiche : combien
-- d'objets bruts sont vus dans les sacs, et pour chaque apparence NON
-- collectionnee de la liste actuelle, si son sourceID correspond a un objet
-- en sac (avec la methode round 37) ou pas -- au lieu de deviner plus loin.
SLASH_TBAGDEBUG1 = "/tbagdebug"
SlashCmdList["TBAGDEBUG"] = function()
	local frame = WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame;
	if not frame or not frame.visualsList then
		print("|cffff0000[TBAGDEBUG]|r Ouvre d'abord Garde-robe ou Transmogrification sur un emplacement.");
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
	print(string.format("|cff00ff88[TBAGDEBUG]|r NUM_BAG_SLOTS=%s | objets bruts distincts trouves dans les sacs (bag 0 a NUM_BAG_SLOTS)=%d", tostring(NUM_BAG_SLOTS), bagCount));
	print("  Liste des item IDs trouves en sac : " .. table.concat(bagList, ", "));

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
			print("  [champs bruts visualInfo] " .. table.concat(fields, ", "));
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
				print(string.format("  visualID=%s directHit=%s anyBagMatch=%s | sources reelles=[%s]",
					tostring(visualInfo.visualID), tostring(directHit),
					tostring(anyBagSourceMatch), table.concat(sourceIDList, ", ")));
			end
		end
	end
	print(string.format("|cff00ff88[TBAGDEBUG]|r Sur %d apparences NON collectionnees, %d seraient affichees comme 'en sac' avec la methode actuelle (limite a 20 lignes de detail ci-dessus).", checked, shown));
end

-- ============================================================
-- ROUND Transmog-41 : /titemdebug -- pipeline complet par itemID reel de sac.
-- ============================================================
-- Le round 40 a corrige la METHODE DE CORRESPONDANCE (matching), mais si le
-- vrai probleme se situe plus en amont -- dans la construction meme de la
-- liste de candidats (BASE_APPEARANCES, utilisee par
-- C_TransmogCollection.GetCategoryAppearances, donc par self.visualsList) --
-- aucune amelioration du matching ne peut faire apparaitre un objet qui
-- n'est jamais entre dans cette liste de candidats en premier lieu. Ce
-- diagnostic prend chaque objet REELLEMENT en sac et affiche a quelle etape
-- precise du pipeline il "disparait" : pas d'entree dans
-- ITEM_MODIFIED_APPEARANCE_STORAGE ? categorie/sous-categorie non resolue ?
-- sourceType exclu ? IsKnownItemModifiedAppearance renvoie faux ? ou bien
-- tout est correct mais il n'est simplement pas encore dans
-- BASE_APPEARANCES (inBaseAppearances=false) ?
-- Usage : ouvre Garde-robe ou Transmogrification sur l'emplacement concerne
-- (ex. Epaules), tape /titemdebug.
SLASH_TITEMDEBUG1 = "/titemdebug"
SlashCmdList["TITEMDEBUG"] = function()
	local frame = WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame;
	if not frame then
		print("|cffff0000[TITEMDEBUG]|r Ouvre d'abord Garde-robe ou Transmogrification.");
		return;
	end
	if not (C_TransmogCollection and C_TransmogCollection.DebugItemPipeline) then
		print("|cffff0000[TITEMDEBUG]|r C_TransmogCollection.DebugItemPipeline indisponible (patch pas a jour ?).");
		return;
	end

	local bagItemIDs = frame:BuildBagItemIDSet();
	local list = {};
	for itemID in pairs(bagItemIDs) do
		list[#list + 1] = itemID;
	end
	table.sort(list);

	print(string.format("|cff00ff88[TITEMDEBUG]|r activeCategory=%s activeSubCategory=%s | %d objets en sac a analyser (limite 25 lignes).",
		tostring(frame.activeCategory), tostring(frame.activeSubCategory), #list));

	local n = 0;
	for i = 1, #list do
		if n >= 25 then break; end
		local itemID = list[i];
		local ok, result = pcall(C_TransmogCollection.DebugItemPipeline, itemID);
		if ok and result then
			if not result.hasStorageEntry then
				print(string.format("  itemID=%d : PAS d'entree dans ITEM_MODIFIED_APPEARANCE_STORAGE (jamais reference comme apparence).", itemID));
			else
				print(string.format("  itemID=%d categoryID=%s subCategoryID=%s equipLocID=%s appearanceID=%s sourceType=%s classMask=%s isKnown=%s inBaseAppearances=%s",
					itemID, tostring(result.categoryID), tostring(result.subCategoryID), tostring(result.equipLocID),
					tostring(result.appearanceID), tostring(result.sourceType), tostring(result.classMask),
					tostring(result.isKnown), tostring(result.inBaseAppearances)));
				if result.categoryID == 0 then
					print(string.format("      -> categoryID=0 (rejete) | rawEquipLocStr=%s itemSubTypeStr=%s (utile si c'est une arme)",
						tostring(result.rawEquipLocStr), tostring(result.itemSubTypeStr)));
				end
			end
			n = n + 1;
		else
			print(string.format("  itemID=%d : erreur diagnostic (%s)", itemID, tostring(result)));
			n = n + 1;
		end
	end
end

-- ============================================================
-- ROUND Transmog-41 : /tmodeltrace -- bascule pour voir en direct ce que
-- GetEffectiveTransmogID()/RefreshItemModel calculent reellement au moment
-- ou le mannequin devrait changer (utile pour le point "mannequin ne se met
-- pas a jour apres Appliquer", meme quand ShowingHelm() est confirme actif).
-- Usage : tape /tmodeltrace pour activer, clique Appliquer, regarde les
-- lignes [TMODELTRACE], puis retape /tmodeltrace pour desactiver (sinon ca
-- imprime a chaque clic dans la grille).
-- ============================================================
TMODELTRACE_ENABLED = false;
SLASH_TMODELTRACE1 = "/tmodeltrace"
SlashCmdList["TMODELTRACE"] = function()
	TMODELTRACE_ENABLED = not TMODELTRACE_ENABLED;
	print("|cff00ccff[TMODELTRACE]|r " .. (TMODELTRACE_ENABLED and "ACTIVE" or "DESACTIVE"));
end

-- ============================================================
-- ROUND Transmog-38 : tracage de la confirmation serveur ASMSG_TRANSMOG_APPLIED
-- (le round 37 y a ajoute un rafraichissement direct du mannequin -- ceci
-- verifie s'il se declenche vraiment et sans erreur).
-- ============================================================
if EventHandler and EventHandler.ASMSG_TRANSMOG_APPLIED and not EventHandler.__transmog38Traced then
	local orig_ASMSG_TRANSMOG_APPLIED = EventHandler.ASMSG_TRANSMOG_APPLIED;
	EventHandler.ASMSG_TRANSMOG_APPLIED = function(self, msg, ...)
		print("|cff00ff88[TDEBUG]|r ASMSG_TRANSMOG_APPLIED recu, msg=" .. tostring(msg));
		local ok, err = pcall(orig_ASMSG_TRANSMOG_APPLIED, self, msg, ...);
		if not ok then
			print("|cffff0000[TDEBUG]|r ASMSG_TRANSMOG_APPLIED ERREUR : " .. tostring(err));
		else
			local hasItemsFrame = WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame ~= nil;
			local hasTransmogFrame = WardrobeTransmogFrame ~= nil;
			print(string.format("|cff00ff88[TDEBUG]|r ASMSG_TRANSMOG_APPLIED traite sans erreur | ItemsCollectionFrame present=%s | WardrobeTransmogFrame present=%s",
				tostring(hasItemsFrame), tostring(hasTransmogFrame)));
		end
	end
	EventHandler.__transmog38Traced = true;
end
