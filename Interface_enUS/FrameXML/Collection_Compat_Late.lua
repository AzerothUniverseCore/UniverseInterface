-- Collection_Compat_Late.lua
-- Suite de Collection_Compat.lua, mais chargee APRES Utils\C_Item.lua.
-- Raison : Collection_Compat.xml (donc Collection_Compat.lua) se charge tres
-- tot dans FrameXML.toc, AVANT Utils\C_Item.lua. Or Utils\C_Item.lua fait
-- C_Item = CreateFromMixins(C_ItemMixin), ce qui REMPLACE entierement la
-- table C_Item et effacerait tout polyfill ajoute dessus plus tot. Ce fichier
-- doit donc etre charge apres Utils\C_Item.lua (et avant Custom_Collections.xml).

-- ============================================================
-- PATCH Collection (correction round 20) : fusion des caches d'objets Sirus
-- (Generated_ItemsCache1/2/3.lua, ~214000 lignes au total) dans la table
-- ItemsCache d'Universe.
--
-- Universe a deja SA PROPRE table ItemsCache (SharedXML\ItemsCache.lua,
-- ~117000 objets), mais elle ne couvre pas tous les objets "source" de
-- transmog references par Generated_ItemAppearances.lua (porte de Sirus).
-- Resultat cote jeu : certaines cases de la grille Garde-robe restaient
-- bloquees sur "Recuperation des informations de l'objet" (nom introuvable
-- ni via la native, ni via ItemsCache d'Universe).
--
-- Sirus fournit 3 fichiers de donnees supplementaires au meme format
-- positionnel (voir ClientDataGenerated_Loader_FrameXML.xml de Sirus), mais
-- sous des noms de table separes (ItemsCache1/ItemsCache2/ItemsCache3) : cote
-- Sirus, c'est Utils\C_Item.lua qui les fusionne au demarrage. Universe n'a
-- pas cette logique de fusion puisqu'elle n'a jamais eu ces fichiers. On la
-- reproduit ici.
--
-- IMPORTANT : on ne fusionne QUE les itemID qui n'existent PAS DEJA dans
-- ItemsCache d'Universe, pour ne jamais ecraser une entree existante. Raison :
-- Sirus est un serveur russe (position 2 du tableau = nom RUSSE), alors
-- qu'Universe est un serveur francophone (position 2 = nom FRANCAIS,
-- cf. E_ITEM_INFO.NAME_FRFR dans Utils\C_Item.lua). Pour les objets DEJA
-- presents cote Universe, on garde donc la version francaise existante ; les
-- objets AJOUTES depuis Sirus (introuvables cote Universe) s'afficheront en
-- russe faute de mieux - c'est nettement preferable a l'ancien "Recuperation
-- des informations de l'objet" qui ne se resolvait jamais.
-- ============================================================
do
	if type(ItemsCache) == "table" then
		local addedCount = 0
		for suffix = 1, 3 do
			local sourceTable = _G["ItemsCache" .. suffix]
			if type(sourceTable) == "table" then
				for itemID, itemData in pairs(sourceTable) do
					if ItemsCache[itemID] == nil then
						ItemsCache[itemID] = itemData
						addedCount = addedCount + 1
					end
				end
				_G["ItemsCache" .. suffix] = nil
			end
		end
	end
end


-- ============================================================
-- C_Item : Universe a deja son propre C_Item (Utils\C_Item.lua, colon-call
-- C_Item:GetItemInfo), different de celui de Sirus (dot-call, GetItemInfoRaw).
-- Custom_Wardrobe.lua attend l'API "Sirus" en dot-call : on ajoute
-- uniquement les champs manquants SANS remplacer la table C_Item existante
-- (utilisee ailleurs, notamment par EJ_GetItemInfo).
-- ============================================================
C_Item = C_Item or {}
if not C_Item.GetItemInfoRaw then
	-- PATCH Collection (correction round 18) : Custom_Wardrobe.lua fait
	-- "local GetItemInfo = C_Item.GetItemInfoRaw" en tete de fichier, un
	-- ALIAS LOCAL qui masque GetItemInfo pour tout le reste du fichier.
	-- Une premiere version (round 8) pointait GetItemInfoRaw vers la
	-- native brute GetItemInfo, qui ne consulte QUE le cache serveur (donc
	-- nil pour tout objet jamais vu/ramasse par le joueur - typiquement le
	-- cas des objets "source" de transmog). Or Universe a deja son PROPRE
	-- GetItemInfo enrichi, C_Item:GetItemInfo (Utils\C_Item.lua), qui
	-- retente en secours sur la table locale ItemsCache (SharedXML
	-- ItemsCache.lua, ~117000 objets deja present cote client, sans
	-- requete serveur necessaire). On route donc GetItemInfoRaw vers CE
	-- wrapper plutot que vers la native brute.
	function C_Item.GetItemInfoRaw(itemIdentifier)
		return C_Item:GetItemInfo(itemIdentifier)
	end
end
if not C_Item.RequestServerCache then
	function C_Item.RequestServerCache(itemID)
		-- PATCH Collection (correction round 16) : un premier essai (round 8)
		-- faisait de cette fonction un no-op pur, en partant du principe que
		-- GetItemInfo() stock suffirait. FAUX pour les objets "source" de
		-- transmog (jamais ramasses/vus par le joueur) : sans requete
		-- explicite au serveur, leur nom ne se met jamais en cache et
		-- WardrobeItemsModelMixin:OnUpdateModel() reste bloque a scruter
		-- indefiniment un GetItemInfo() qui ne repondra jamais -> la case de
		-- la grille Garde-robe reste en spinner de chargement pour toujours.
		-- RequestLoadItemDataByID est une native standard du client 3.3.5
		-- (pas une extension Sirus) : on l'utilise si le client Universe
		-- l'expose, en pcall par securite si jamais elle etait absente.
		if RequestLoadItemDataByID then
			pcall(RequestLoadItemDataByID, itemID)
		end
	end
end
-- GetBaseItemTransmogInfo / GetAppliedItemTransmogInfo (Sirus\Utils\C_Transmog.lua)
-- necessitent un suivi serveur du transmog applique (protocole ASMSG, absent
-- d'Universe). On retourne un etat "aucun transmog applique" : le Codex affichera
-- l'objet de base sans overlay de transmog (l'application reelle via le bouton
-- Appliquer necessitera un jour le support serveur correspondant).
if not C_Item.GetBaseItemTransmogInfo then
	function C_Item.GetBaseItemTransmogInfo(itemLocation)
		local itemID = 0
		if itemLocation and itemLocation.GetEquipmentSlot then
			itemID = GetInventoryItemID("player", itemLocation:GetEquipmentSlot()) or 0
		end
		return {appearanceID = itemID, illusionID = 0}
	end
end
if not C_Item.GetAppliedItemTransmogInfo then
	function C_Item.GetAppliedItemTransmogInfo(itemLocation)
		return {appearanceID = 0, illusionID = 0}
	end
end

-- ============================================================
-- PATCH Collection (correction round 19) : C_Item.GetItemInfo (DOT-CALL,
-- signature Sirus a 5 arguments) - CAUSE RACINE du probleme "Garde-robe et
-- Reliques a 0/0 sans aucune erreur Lua".
--
-- Diagnostic : Utils\C_TransmogCollection.lua et Utils\C_Heirloom.lua (portes
-- tels quels depuis Sirus) appellent partout :
--     C_Item.GetItemInfo(item, skipClientCache, callback, noAdditionalData, noRequest)
-- en DOT-CALL, et attendent jusqu'a 15 valeurs de retour, notamment
-- classID/subClassID/equipLocID en positions 13/14/15 (necessaires a
-- GetItemModifiedAppearanceCategory() pour classer CHAQUE objet dans une
-- categorie de transmog).
--
-- Or le C_Item.GetItemInfo natif d'Universe (Utils\C_Item.lua) est une
-- METHODE prevue pour un appel en DEUX-POINTS avec un seul argument
-- (C_Item:GetItemInfo(itemIdentifier)) et ne renvoie que 11 valeurs (jamais
-- classID/subClassID/equipLocID). Resultat : chaque appel de
-- C_TransmogCollection.lua recevait "self=itemID, itemIdentifier=nil" (a
-- cause du dot-call) et sortait immediatement avec RIEN (pas d'erreur Lua,
-- juste des nil silencieux). Consequence en cascade :
--   GetItemModifiedAppearanceCategory() ne resout jamais de categorie
--   -> BuildTransmogCollection() ne remplit jamais BASE_APPEARANCES/
--      USABLE_APPEARANCES (le test "if categoryID ~= 0" echoue TOUJOURS)
--   -> GetCategoryAppearances() ne retourne jamais aucun item
--   -> Garde-robe ET Reliques affichent 0/0, sans la moindre erreur.
--
-- Fix : on remplace C_Item.GetItemInfo par une nouvelle fonction qui gere
-- LES DEUX styles d'appel (colon ET dot, detectes via "self == C_Item") et
-- respecte fidelement la signature/les valeurs de retour de la version
-- Sirus, tout en s'appuyant sur les memes sources de donnees qu'Universe
-- (native + repli sur la table ItemsCache deja chargee cote client).
-- ============================================================
do
	-- Capture de la METHODE colon-call native AVANT ecrasement, pour pouvoir
	-- encore l'appeler explicitement depuis la nouvelle fonction (sinon,
	-- appeler "C_Item:GetItemInfo(item)" plus bas se relancerait lui-meme
	-- indefiniment une fois C_Item.GetItemInfo remplace).
	local NativeGetItemInfoMethod = C_ItemMixin and C_ItemMixin.GetItemInfo

	function C_Item.GetItemInfo(a, skipClientCache, callback, noAdditionalData, noRequest)
		local item = a
		if a == C_Item then
			-- Appel en deux-points : C_Item:GetItemInfo(item, ...) equivaut a
			-- C_Item.GetItemInfo(C_Item, item, ...) - on decale tout d'un cran.
			item, skipClientCache, callback, noAdditionalData, noRequest = skipClientCache, callback, noAdditionalData, noRequest, nil
		end
		if not item then
			return
		end

		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice
		if NativeGetItemInfoMethod then
			itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = NativeGetItemInfoMethod(C_Item, item)
		end

		-- classID/subClassID/equipLocID : lus directement depuis ItemsCache
		-- (table positionnelle deja chargee, memes indices que E_ITEM_INFO
		-- dans Utils\C_Item.lua : TYPE=6, SUBTYPE=7, EQUIPLOC=9). Ce sont deja
		-- des identifiants NUMERIQUES bruts, pas besoin de table de conversion
		-- nom->ID comme le fait Sirus.
		local itemID = tonumber(item)
		if not itemID and type(item) == "string" then
			itemID = tonumber(item:match("item:(%d+)"))
		end

		local classID, subClassID, equipLocID
		local cacheData = itemID and ItemsCache and ItemsCache[itemID]
		if cacheData then
			classID = cacheData[6]
			subClassID = cacheData[7]
			equipLocID = cacheData[9]

			-- PATCH Collection (correction round 21) : repli sur ItemsCache pour
			-- itemName/itemLink/... quand la native n'a rien retourne.
			--
			-- Constat : meme apres la fusion des caches Sirus (round 20), de
			-- nombreuses cases de la grille Garde-robe restaient bloquees sur
			-- "Recuperation des informations de l'objet" MALGRE une
			-- classification reussie (l'objet apparait bien dans la bonne
			-- categorie/page). Cause : le classement (plus haut) ne lit QUE des
			-- champs numeriques toujours presents (classID/subClassID/
			-- equipLocID), alors que le nom lu par la native
			-- (C_ItemMixin:GetItemInfoFromCache) vient d'UN SEUL champ,
			-- cacheData[GetLocaleIndex()] (position 2 = francais cote Universe).
			-- Si ce champ precis est vide pour un objet donne (traduction
			-- manquante, ou objet fusionne depuis Sirus dont la position 2 est
			-- en russe mais peut aussi etre vide selon l'entree), la native
			-- renvoie nil et abandonne - alors que la position 1 (nom anglais)
			-- est quasi toujours renseignee. On comble donc nous-memes les
			-- valeurs d'affichage manquantes depuis ItemsCache, avec repli
			-- explicite sur l'anglais (position 1) si la langue locale est vide.
			if not itemName then
				itemName = cacheData[2] or cacheData[1]
				if itemName and itemName ~= "" then
					itemRarity = itemRarity or cacheData[3]
					itemLevel = itemLevel or cacheData[4]
					itemMinLevel = itemMinLevel or cacheData[5]
					itemType = itemType or _G["ITEM_CLASS_" .. tostring(classID)]
					itemSubType = itemSubType or _G[string.format("ITEM_SUB_CLASS_%s_%s", tostring(classID), tostring(subClassID))]
					itemStackCount = itemStackCount or cacheData[8]
					itemEquipLoc = itemEquipLoc or (SHARED_INVTYPE_BY_ID and SHARED_INVTYPE_BY_ID[equipLocID]) or ""
					itemTexture = itemTexture or (cacheData[10] and ("Interface\\Icons\\" .. cacheData[10]))
					vendorPrice = vendorPrice or cacheData[11]
				else
					itemName = nil
				end
			end
		end

		if noAdditionalData then
			return itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice
		else
			return itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice,
				itemID, classID, subClassID, equipLocID
		end
	end
end
