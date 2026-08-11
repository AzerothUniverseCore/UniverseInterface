--============================================================
-- EncounterJournal_MicroButton.lua
-- Adds the "Dungeon Journal" (Encounter Journal) button.
-- Fixes relative to the previous version:
--   1) The button is now parented to UIParent (instead of MainMenuBarArtFrame),
--      so it no longer depends on the visibility of the default Blizzard bar
--      (often hidden by custom action bar UIs).
--   2) USE_CUSTOM_EJ_ART = true: the client does have the official
--      "UI-MicroButton-EJ-Up/Down/Disabled" textures, so we use them
--      directly (the original Dungeon Journal icon).
--============================================================

-- >>> POSITION SETTINGS: change these 4 values to reposition the icon <<<
local EJ_ANCHOR          = "TOPLEFT"       -- button anchor point
local EJ_RELATIVE_FRAME  = "LFDParentFrame" -- reference frame (the "Dungeons" panel)
local EJ_RELATIVE_POINT  = "TOPLEFT"       -- reference point on that frame
local EJ_OFFSET_X        = 25              -- horizontal offset (negative = to the left)
local EJ_OFFSET_Y         = -60              -- vertical offset (positive = upward)

-- >>> TEXTURE SETTING <<<
-- false = use a guaranteed-visible fallback icon (recommended default)
-- true  = use the official UI-MicroButton-EJ-* textures (only if you have
--         added them yourself via a custom client-side MPQ patch)
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
		-- Fallback icon guaranteed to be present in the 3.3.5 client
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

	-- Parented directly to the Dungeons panel frame (LFDParentFrame):
	-- the button appears/disappears along with the panel.
	local relFrame = _G[EJ_RELATIVE_FRAME] or UIParent
	local btn = CreateFrame("Button", "EncounterJournalMicroButton", relFrame, "MainMenuBarMicroButton")
	LoadMicroButtonTextures(btn, "EJ")

	btn:SetFrameStrata("HIGH")
	if not USE_CUSTOM_EJ_ART then
		btn:SetSize(24, 24) -- size suited to the square fallback icon
	end

	btn:ClearAllPoints()
	btn:SetPoint(EJ_ANCHOR, relFrame, EJ_RELATIVE_POINT, EJ_OFFSET_X, EJ_OFFSET_Y)

	-- Follows the show/hide state of the Dungeons panel
	if relFrame ~= UIParent then
		relFrame:HookScript("OnShow", function() btn:Show() end)
		relFrame:HookScript("OnHide", function() btn:Hide() end)
		if relFrame:IsShown() then btn:Show() else btn:Hide() end
	else
		btn:Show()
	end

	local title = ADVENTURE or "Dungeon Journal"
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
