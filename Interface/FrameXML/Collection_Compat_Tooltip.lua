-- Collection_Compat_Tooltip.lua
-- Methodes GameTooltip manquantes (Sirus\FrameXML\GameTooltip.lua,
-- GameTooltipMixin), copiees verbatim. Doit charger APRES GameTooltip.xml
-- (le widget GameTooltip global n'existe pas encore avant), donc ce fichier
-- est place juste avant Custom_Collections.xml et non dans Collection_Compat.lua.
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
-- PATCH Collection (correction round 26) : commandes /cdebug et /wdebug -
-- CAUSE RACINE identifiee du "rien ne change jamais malgre les correctifs".
--
-- Ces deux commandes etaient a l'origine enregistrees dans Collection_Compat.lua
-- (rounds 22 et 25), qui charge TRES TOT dans FrameXML.toc (juste avant
-- Utils\C_Item.lua). Or SlashCmdList (la table native du systeme de
-- commandes /slash) n'est definie que par ChatFrame.lua, qui charge
-- LONGTEMPS APRES (via ChatFrame.xml, toc ligne ~139). Résultat concret :
-- "SlashCmdList["COLLECTIONDEBUG"] = ..." plantait immediatement avec
-- "attempt to index a nil value (global 'SlashCmdList')" DES le chargement
-- de Collection_Compat.lua - une erreur runtime (pas une erreur de syntaxe,
-- donc invisible a nos verifications automatiques).
--
-- Cette erreur interrompait l'execution du FICHIER a cet endroit précis :
-- TOUT ce qui suivait dans Collection_Compat.lua (rounds 23 RAID_CLASS_COLORS,
-- 24 GetSpecializationNameForSpecID, et la commande /wdebug elle-meme)
-- N'A JAMAIS ETE EXECUTE, d'ou la persistance IDENTIQUE des erreurs Reliques
-- malgre plusieurs rounds de correctifs pourtant corrects et bien places.
--
-- Deplacees ici (Collection_Compat_Tooltip.lua charge apres ChatFrame.xml,
-- SlashCmdList existe deja) pour qu'elles s'enregistrent enfin correctement.
-- ============================================================
SLASH_COLLECTIONDEBUG1 = "/cdebug"
SlashCmdList["COLLECTIONDEBUG"] = function()
	if Collection_DebugSkills then
		Collection_DebugSkills()
	else
		print("|cffff0000[Collection Debug]|r Collection_DebugSkills indisponible (ouvrez d'abord le Garde-robe au moins une fois).")
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
		print("|cffff0000[Heirloom Debug]|r HeirloomsJournal introuvable (ouvrez d'abord Reliques).");
	end
end

-- PATCH round 109 (filet de securite) : re-definition des memes 9 textes
-- d'aide ici, dans Collection_Compat_Tooltip.lua. Ce fichier charge juste
-- avant Custom_Collections.xml (toc ligne 242 vs 243) et a un historique
-- prouve de s'executer entierement (toutes les commandes /debug qui y
-- vivent fonctionnent). Si Collection_Compat.lua (round 108) est
-- interrompu plus haut par une erreur runtime avant d'atteindre ses
-- propres definitions (cause exacte du bug SlashCmdList du round 26),
-- ces definitions-ci prennent le relais en dernier recours.
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_1 = "La Transmogrification vous permet de modifier l'apparence de votre équipement. Mais il y a quelques points importants à connaître.\n\n1. Une fois la Transmogrification effectuée, vous ne pourrez plus rendre les objets au marchand. Cela concerne aussi bien l'objet dont vous avez changé l'apparence que celui dont vous avez utilisé l'apparence.\n\n2. Si vous détruisez ou vendez un objet possédant un minuteur de retour ou d'échange, vous perdrez l'apparence associée à la Transmogrification.\n\n3. Après la Transmogrification, les deux objets deviennent personnels. Cela s'applique également aux objets d'Héritage (armure et armes).\n\n4. Appliquer un enchantement visuel sur une arme la rend également personnelle.\n\n5. L'effet de Transmogrification est retiré des objets d'Héritage envoyés par courrier.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_2 = "Ce compteur indique le nombre d'apparences d'objets que vous avez collectées. Le nombre affiché varie selon l'emplacement et le type d'objet sélectionnés.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_3 = "Pour trouver l'apparence d'un objet qui vous intéresse, commencez à saisir son nom dans le champ \"Recherche\".";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_4 = "Vous pouvez ici choisir la source d'obtention des apparences d'objets que vous avez déjà obtenues.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_5 = "Vous pouvez ici activer/désactiver l'affichage de la fenêtre d'aide pour la Transmogrification du type d'objet sélectionné. Si la fenêtre d'aide est activée, le bouton \"Règles complètes\" vous permettra d'accéder aux informations détaillées sur toutes les règles de Transmogrification dans l'encyclopédie.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_6 = "Vous pouvez ici enregistrer toutes vos tenues.\n\nChoisissez les apparences souhaitées pour vos objets, puis cliquez sur \"Nouvel équipement\". Donnez-lui un nom unique et cliquez sur \"Appliquer\". Votre tenue est maintenant enregistrée et vous pourrez l'utiliser plus tard pour changer rapidement de Transmogrification.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_7 = "Vous pouvez ici sélectionner l'objet auquel vous souhaitez donner une nouvelle apparence.\n\nPour annuler les modifications d'un objet en particulier, cliquez dessus avec le bouton droit de la souris ou sur la flèche qui apparaît à côté.\n\nSi vous souhaitez annuler les modifications pour tous les objets à la fois, cliquez sur la flèche en haut à droite.\n\nNotez que l'annulation groupée n'est possible que tant que le service de Transmogrification n'a pas été payé.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_8 = "Vous pouvez ici choisir le type d'apparence d'objet souhaité.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_9 = "Toutes vos apparences d'objets correspondant aux filtres et à la recherche s'affichent ici.\n\nPour placer une apparence en tête de liste, ajoutez-la à vos Favoris. Pour cela, faites un clic droit sur l'objet et sélectionnez \"Ajouter aux Favoris\".";

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
