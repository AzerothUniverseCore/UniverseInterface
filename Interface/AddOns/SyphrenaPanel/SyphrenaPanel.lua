----------------------------------------------------------------
--  Bouton "Grimoire d'identité" dans le CharacterFrame
--  (remplace l'ancien bouton accroché à la Minimap)
----------------------------------------------------------------
do
	-- >>> RÉGLAGES POSITION : ajuste ces 3 valeurs pour repositionner l'icône <<<
	local CF_ANCHOR         = "TOPRIGHT" -- point d'ancrage du bouton
	local CF_RELATIVE_POINT = "TOPRIGHT" -- point de référence sur CharacterFrame
	local CF_OFFSET_X       = -10       -- décalage horizontal (négatif = vers la gauche)
	local CF_OFFSET_Y       = -30        -- décalage vertical (négatif = vers le bas)
	--------------------------------------------------------------

	local button = CreateFrame("Button", "PanelCharacterFrameButton", CharacterFrame)
	button:SetHeight(28)
	button:SetWidth(28)
	button:SetFrameStrata("HIGH")
	button:SetPoint(CF_ANCHOR, CharacterFrame, CF_RELATIVE_POINT, CF_OFFSET_X, CF_OFFSET_Y)
	button:SetMovable(true)
	button:SetNormalTexture("Interface\\AddOns\\SyphrenaPanel\\textures\\Panel-Button-Up.blp")
	button:SetPushedTexture("Interface\\AddOns\\SyphrenaPanel\\textures\\Panel-Button-Down.blp")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	-- Suit l'affichage/masquage de l'onglet "Personnage" uniquement
	-- (PaperDollFrame = le sous-panneau affiché par cet onglet précis,
	-- contrairement à CharacterFrame qui reste affiché sur tous les onglets)
	button:Hide()
	PaperDollFrame:HookScript("OnShow", function() button:Show() end)
	PaperDollFrame:HookScript("OnHide", function() button:Hide() end)
	if PaperDollFrame:IsShown() then button:Show() end

	-- Tooltip au survol
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Grimoire d'identité", 1, 1, 1)
		GameTooltip:AddLine("Informations sur votre personnage.", 1, 0.82, 0, true)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	-- Déplacement libre en maintenant Shift (facultatif, pour affiner la position en jeu)
	button:SetScript("OnMouseDown", function(self, mouseButton)
		if IsShiftKeyDown() then
			self:StartMoving()
		end
	end)
	button:SetScript("OnMouseUp", function(self)
		self:StopMovingOrSizing()
	end)

	-- Envoie un message dans le chat au clic
	button:SetScript("OnClick", function(self, mouseButton)
		SendChatMessage(".modmepanel")
	end)
end
