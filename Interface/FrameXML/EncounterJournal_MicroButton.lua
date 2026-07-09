--============================================================
-- EncounterJournal_MicroButton.lua
-- Ajoute le bouton "Codex des donjons" (Encounter Journal)
-- Corrections par rapport à la version précédente :
--   1) Le bouton est parenté à UIParent (et non plus à MainMenuBarArtFrame),
--      pour ne pas dépendre de la visibilité de la barre Blizzard par défaut
--      (souvent masquée par les UI d'action bar custom).
--   2) USE_CUSTOM_EJ_ART = true : le client dispose bien des textures
--      officielles "UI-MicroButton-EJ-Up/Down/Disabled", donc on les
--      utilise directement (icône d'origine du Codex des donjons).
--============================================================

-- >>> RÉGLAGES POSITION : modifie ces 4 valeurs pour repositionner l'icône <<<
local EJ_ANCHOR          = "TOPLEFT"       -- point d'ancrage du bouton
local EJ_RELATIVE_FRAME  = "LFDParentFrame" -- frame de référence (panneau "Donjons")
local EJ_RELATIVE_POINT  = "TOPLEFT"       -- point de référence sur cette frame
local EJ_OFFSET_X        = 25              -- décalage horizontal (négatif = vers la gauche)
local EJ_OFFSET_Y         = -60              -- décalage vertical (positif = vers le haut)

-- >>> RÉGLAGE TEXTURE <<<
-- false = utilise une icône de secours garantie visible (recommandé par défaut)
-- true  = utilise les textures officielles UI-MicroButton-EJ-* (seulement si
--         tu les as toi-même ajoutées via un patch MPQ custom côté client)
local USE_CUSTOM_EJ_ART  = true
--============================================================

local function LoadMicroButtonTextures(self, name)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	if USE_CUSTOM_EJ_ART then
		local prefix = "Interface\\Buttons\\UI-MicroButton-"
		self:SetNormalTexture(prefix .. name .. "-Up")
		self:SetPushedTexture(prefix .. name .. "-Down")
		self:SetDisabledTexture(prefix .. name .. "-Disabled")
	else
		-- Icône de secours garantie présente dans le client 3.3.5
		local icon = "Interface\\ICONS\\INV_Misc_Book_09"
		self:SetNormalTexture(icon)
		self:SetPushedTexture(icon)
		self:SetDisabledTexture(icon)

		local nt = self:GetNormalTexture()
		if nt then nt:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
		local pt = self:GetPushedTexture()
		if pt then pt:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
	end

	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
end

function EncounterJournal_SetupMicroButton()
	if EncounterJournalMicroButton then
		return
	end

	-- Parenté directement à la frame du panneau Donjons (LFDParentFrame) :
	-- le bouton apparaît/disparaît avec le panneau.
	local relFrame = _G[EJ_RELATIVE_FRAME] or UIParent
	local btn = CreateFrame("Button", "EncounterJournalMicroButton", relFrame, "MainMenuBarMicroButton")
	LoadMicroButtonTextures(btn, "EJ")

	btn:SetFrameStrata("HIGH")
	if not USE_CUSTOM_EJ_ART then
		btn:SetSize(24, 24) -- taille adaptée à l'icône carrée de secours
	end

	btn:ClearAllPoints()
	btn:SetPoint(EJ_ANCHOR, relFrame, EJ_RELATIVE_POINT, EJ_OFFSET_X, EJ_OFFSET_Y)

	-- Suit l'affichage/masquage du panneau Donjons
	if relFrame ~= UIParent then
		relFrame:HookScript("OnShow", function() btn:Show() end)
		relFrame:HookScript("OnHide", function() btn:Hide() end)
		if relFrame:IsShown() then btn:Show() else btn:Hide() end
	else
		btn:Show()
	end

	local title = ADVENTURE or "Codex des donjons"
	btn.tooltipText = MicroButtonTooltipText(title, "TOGGLEENCOUNTERJOURNAL") or title
	btn.newbieText = MAINMENUBAR_EJ_NEWBIE_TOOLTIP or title
	btn:SetScript("OnClick", ToggleEncounterJournalFrame)

	if not EncounterJournalMicroButtonHooked and UpdateMicroButtons then
		EncounterJournalMicroButtonHooked = true
		local orig = UpdateMicroButtons
		UpdateMicroButtons = function()
			orig()
			if EncounterJournal and EncounterJournal:IsShown() then
				btn:SetButtonState("PUSHED", 1)
			else
				btn:SetButtonState("NORMAL")
			end
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", EncounterJournal_SetupMicroButton)
