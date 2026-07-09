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
