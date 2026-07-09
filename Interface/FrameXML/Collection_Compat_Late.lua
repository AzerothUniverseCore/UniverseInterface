-- Collection_Compat_Late.lua
-- Suite de Collection_Compat.lua, mais chargee APRES Utils\C_Item.lua.
-- Raison : Collection_Compat.xml (donc Collection_Compat.lua) se charge tres
-- tot dans FrameXML.toc, AVANT Utils\C_Item.lua. Or Utils\C_Item.lua fait
-- C_Item = CreateFromMixins(C_ItemMixin), ce qui REMPLACE entierement la
-- table C_Item et effacerait tout polyfill ajoute dessus plus tot. Ce fichier
-- doit donc etre charge apres Utils\C_Item.lua (et avant Custom_Collections.xml).

-- ============================================================
-- C_Item : Universe a deja son propre C_Item (Utils\C_Item.lua, colon-call
-- C_Item:GetItemInfo), different de celui de Sirus (dot-call, GetItemInfoRaw).
-- Custom_Wardrobe.lua attend l'API "Sirus" en dot-call : on ajoute
-- uniquement les champs manquants SANS remplacer la table C_Item existante
-- (utilisee ailleurs, notamment par EJ_GetItemInfo).
-- ============================================================
C_Item = C_Item or {}
if not C_Item.GetItemInfoRaw then
	C_Item.GetItemInfoRaw = GetItemInfo
end
if not C_Item.RequestServerCache then
	function C_Item.RequestServerCache(itemID)
		-- no-op : Universe n'a pas de cache serveur asynchrone pour les objets,
		-- GetItemInfo() (stock) suffit pour tout ce que le Codex utilise.
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
