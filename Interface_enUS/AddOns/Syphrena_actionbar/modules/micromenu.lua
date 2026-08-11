local addon = select(2,...);
local config = addon.config;
local pairs = pairs;
local gsub = string.gsub;
local UIParent = UIParent;
local hooksecurefunc = hooksecurefunc;
local _G = _G;

-- const
local PERFORMANCEBAR_LOW_LATENCY = 300;
local PERFORMANCEBAR_MEDIUM_LATENCY = 600;

local MainMenuMicroButtonMixin = {};
local MainMenuBarBackpackButton = _G.MainMenuBarBackpackButton;
local HelpMicroButton = _G.HelpMicroButton;
local KeyRingButton = _G.KeyRingButton;

local bagslots = {
    _G.CharacterBag0Slot,
    _G.CharacterBag1Slot,
    _G.CharacterBag2Slot,
    _G.CharacterBag3Slot
};
local MICRO_BUTTONS = {
	_G.CharacterMicroButton,
	_G.SpellbookMicroButton,
	_G.TalentMicroButton,
	_G.AchievementMicroButton,
	_G.QuestLogMicroButton,
	_G.SocialsMicroButton,
	_G.LFDMicroButton,
	_G.CollectionsMicroButton,
	_G.PVPMicroButton,
	_G.MainMenuMicroButton,
	_G.HelpMicroButton,
};
local pUiBagsBar = CreateFrame(
	'Frame',
	'pUiBagsBar',
	UIParent
);
pUiBagsBar:SetScale(config.micromenu.scale_bags);
MainMenuBarBackpackButton:SetParent(pUiBagsBar);
KeyRingButton:SetParent(_G.CharacterBag3Slot);
function MainMenuMicroButtonMixin:bagbuttons_setup()
	MainMenuBarBackpackButton:SetSize(50, 50)
	MainMenuBarBackpackButton:SetNormalTexture(nil)
	MainMenuBarBackpackButton:SetPushedTexture(nil)
	MainMenuBarBackpackButton:SetHighlightTexture''
	MainMenuBarBackpackButton:SetCheckedTexture''
	MainMenuBarBackpackButton:GetHighlightTexture():set_atlas('bag-main-highlight-2x')
	MainMenuBarBackpackButton:GetCheckedTexture():set_atlas('bag-main-highlight-2x')
	MainMenuBarBackpackButtonIconTexture:set_atlas('bag-main-2x')
	MainMenuBarBackpackButton:SetClearPoint('BOTTOMRIGHT', HelpMicroButton, 'BOTTOMRIGHT', 0, 30)
	MainMenuBarBackpackButton.SetPoint = addon._noop
	
	MainMenuBarBackpackButtonCount:SetClearPoint('CENTER', MainMenuBarBackpackButton, 'BOTTOM', 0, 14)
	CharacterBag0Slot:SetClearPoint('RIGHT', MainMenuBarBackpackButton, 'LEFT', -14, -2)
	
	KeyRingButton:SetSize(34, 34)
	KeyRingButton:SetClearPoint('RIGHT', CharacterBag3Slot, 'LEFT', -2, 0)
	KeyRingButton:SetNormalTexture''
	KeyRingButton:SetPushedTexture(nil)
	KeyRingButton:SetHighlightTexture''
	KeyRingButton:SetCheckedTexture''
	
	local highlight = KeyRingButton:GetHighlightTexture();
	highlight:SetAllPoints();
	highlight:SetBlendMode('ADD');
	highlight:SetAlpha(.4);
	highlight:set_atlas('bag-border-highlight-2x', true)
	KeyRingButton:GetNormalTexture():set_atlas('bag-reagent-border-2x')
	KeyRingButton:GetCheckedTexture():set_atlas('bag-border-highlight-2x', true)
	KeyRingButton:Hide();
	
	for _,bags in pairs(bagslots) do
		bags:SetHighlightTexture''
		bags:SetCheckedTexture''
		bags:SetPushedTexture(nil)
		bags:SetNormalTexture''
		bags:SetSize(28, 28)

		bags:GetCheckedTexture():set_atlas('bag-border-highlight-2x', true)
		bags:GetCheckedTexture():SetDrawLayer('OVERLAY', 7)
		
		local highlight = bags:GetHighlightTexture();
		highlight:SetAllPoints();
		highlight:SetBlendMode('ADD');
		highlight:SetAlpha(.4);
		highlight:set_atlas('bag-border-highlight-2x', true)

		local icon = _G[bags:GetName()..'IconTexture']
		icon:ClearAllPoints()
		icon:SetPoint('TOPRIGHT', bags, 'TOPRIGHT', -5, -2.9);
		icon:SetPoint('BOTTOMLEFT', bags, 'BOTTOMLEFT', 2.9, 5);
		icon:SetTexCoord(.08,.92,.08,.92)
		
		local border = bags:CreateTexture(nil, 'OVERLAY')
		border:SetPoint('CENTER')
		border:set_atlas('bag-border-2x', true)
		bags:GetCheckedTexture():SetAllPoints(border)
		
		local w, h = border:GetSize()
		bags.background = bags:CreateTexture(nil, 'BACKGROUND')
		bags.background:SetSize(w, h)
		bags.background:SetPoint('CENTER')
		bags.background:SetTexture(addon._dir..'bagslots2x')
		bags.background:SetTexCoord(295/512, 356/512, 64/128, 125/128)
		
		local count = _G[bags:GetName()..'Count']
		count:SetClearPoint('CENTER', 0, -10);
		count:SetDrawLayer('OVERLAY')
	end
end

addon.package:RegisterEvents(function(self)
	self:UnregisterEvent('PLAYER_ENTERING_WORLD')
	if HasKey() then
		KeyRingButton:Show();
	else
		KeyRingButton:Hide();
	end
	if config.style.bags == 'new' then
		for _,bags in pairs(bagslots) do
			local icon = _G[bags:GetName()..'IconTexture']
			local empty = icon:GetTexture() == 'interface\\paperdoll\\UI-PaperDoll-Slot-Bag'
			if empty then
				icon:SetAlpha(0)
			else
				icon:SetAlpha(1)
			end
		end
	end
end,
	'BAG_UPDATE', 'PLAYER_ENTERING_WORLD'
);

do
	for _,bags in pairs(bagslots) do
		bags:SetParent(pUiBagsBar);
	end
	if config.style.bags == 'new' then
		MainMenuMicroButtonMixin:bagbuttons_setup();
	elseif config.style.bags == 'old' then
		MainMenuBarBackpackButton:SetClearPoint('BOTTOMRIGHT', HelpMicroButton, 'BOTTOMRIGHT', 0, 34)
		MainMenuBarBackpackButtonIconTexture:SetTexture(addon._dir..'INV_Misc_Bag_08')
		CharacterBag0Slot:SetClearPoint('RIGHT', MainMenuBarBackpackButton, 'LEFT', -20, 0)
	else
		MainMenuBarBackpackButton:Hide();
		for _,bags in pairs(bagslots) do
			bags:Hide();
		end
	end
end

do
	local old = config.style.bags == 'old'
	local arrow = CreateFrame('CheckButton', 'pUiArrowManager', MainMenuBarBackpackButton)
	arrow:SetSize(12, 18)
	arrow:SetPoint('RIGHT', MainMenuBarBackpackButton, 'LEFT', old and -4 or 0, -2)
	arrow:SetNormalTexture''
	arrow:SetPushedTexture''
	arrow:SetHighlightTexture''
	arrow:RegisterForClicks('LeftButtonUp')

	local normal = arrow:GetNormalTexture()
	normal:set_atlas('bag-arrow-invert-2x')

	local pushed = arrow:GetPushedTexture()
	pushed:set_atlas('bag-arrow-invert-2x')

	local highlight = arrow:GetHighlightTexture()
	highlight:set_atlas('bag-arrow-invert-2x')
	highlight:SetAlpha(.4)
	highlight:SetBlendMode('ADD')

	arrow:SetScript('OnClick',function(self)
		local checked = self:GetChecked();
		if checked then
			normal:set_atlas('bag-arrow-2x')
			pushed:set_atlas('bag-arrow-2x')
			highlight:set_atlas('bag-arrow-2x')
			for _,bags in pairs(bagslots) do bags:Hide(); end
		else
			normal:set_atlas('bag-arrow-invert-2x')
			pushed:set_atlas('bag-arrow-invert-2x')
			highlight:set_atlas('bag-arrow-invert-2x')
			for _,bags in pairs(bagslots) do bags:Show(); end
		end
		collapse_state = checked
	end)
	
	addon.package:RegisterEvents(function(self, event)
		self:UnregisterEvent(event)
		if not collapse_state then collapse_state = {} end
		if collapse_state == 1 then
			for _,bags in pairs(bagslots) do bags:Hide(); end
			normal:set_atlas('bag-arrow-2x')
			pushed:set_atlas('bag-arrow-2x')
			highlight:set_atlas('bag-arrow-2x')
			arrow:SetChecked(1)
		else
			for _,bags in pairs(bagslots) do bags:Show(); end
			arrow:SetChecked(nil)
		end
	end, 'ADDON_LOADED'
	);
end

hooksecurefunc('MiniMapLFG_UpdateIsShown',function()
	MiniMapLFGFrame:SetClearPoint('LEFT', _G.CharacterMicroButton, -32, 2)
	MiniMapLFGFrame:SetScale(1.6)
	MiniMapLFGFrameBorder:SetTexture(nil)
	MiniMapLFGFrame.eye.texture:SetTexture(addon._dir..'uigroupfinderflipbookeye.tga')
end)

MiniMapLFGFrame:SetScript('OnClick',function(self, button)
	local mode, submode = GetLFGMode();
	if ( button == "RightButton" or mode == "lfgparty" or mode == "abandonedInDungeon") then
		PlaySound("igMainMenuOpen");
		local yOffset;
		if ( mode == "queued" ) then
			MiniMapLFGFrameDropDown.point = "BOTTOMRIGHT";
			MiniMapLFGFrameDropDown.relativePoint = "TOPLEFT";
			yOffset = 105;
		else
			MiniMapLFGFrameDropDown.point = nil;
			MiniMapLFGFrameDropDown.relativePoint = nil;
			yOffset = 110;
		end
		ToggleDropDownMenu(1, nil, MiniMapLFGFrameDropDown, "MiniMapLFGFrame", -60, yOffset);
	elseif ( mode == "proposal" ) then
		if ( not LFDDungeonReadyPopup:IsShown() ) then
			PlaySound("igCharacterInfoTab");
			StaticPopupSpecial_Show(LFDDungeonReadyPopup);
		end
	elseif ( mode == "queued" or mode == "rolecheck" ) then
		ToggleLFDParentFrame();
	elseif ( mode == "listed" ) then
		ToggleLFRParentFrame();
	end
end)

LFDSearchStatus:SetParent(MinimapBackdrop)
LFDSearchStatus:SetClearPoint('TOPRIGHT', MinimapBackdrop, 'TOPLEFT')

-- PATCH ShowHead (v2) : la texture native MicroButtonPortrait est
-- positionnee/dimensionnee par le FrameXML de base pour la taille de bouton
-- Blizzard d'origine (~36x36) ; une fois le bouton redimensionne a 14x19 par
-- cette barre custom (voir setupMicroButtons plus bas), MicroButtonPortrait
-- se retrouve hors de la zone visible du bouton et reste invisible meme
-- avec Alpha(1) -- c'est pourquoi la premiere tentative laissait une case
-- vide. On la garde donc masquee, et on cree a la place notre propre
-- texture, ancree directement sur les bords REELS du bouton (comme sur le
-- Grimoire d'identite), pour garantir un rendu correct quelle que soit sa
-- taille finale.
hooksecurefunc('CharacterMicroButton_SetPushed',function()
	MicroButtonPortrait:SetTexCoord(0,0,0,0);
	MicroButtonPortrait:SetAlpha(0);
end)

hooksecurefunc('CharacterMicroButton_SetNormal',function()
	MicroButtonPortrait:SetTexCoord(0,0,0,0);
	MicroButtonPortrait:SetAlpha(0);
end)

local characterPortrait = CharacterMicroButton:CreateTexture(nil, "ARTWORK")
characterPortrait:SetPoint("TOPLEFT", CharacterMicroButton, "TOPLEFT", 0, -2)
characterPortrait:SetPoint("BOTTOMRIGHT", CharacterMicroButton, "BOTTOMRIGHT", 0, 2)

local function pUiUpdateCharacterPortrait()
	SetPortraitTexture(characterPortrait, "player")
end

hooksecurefunc('CharacterMicroButton_SetPushed', pUiUpdateCharacterPortrait)
hooksecurefunc('CharacterMicroButton_SetNormal', pUiUpdateCharacterPortrait)

-- Cause racine trouvee via InterfaceMainMenuBarMicroButtons/FrameXML/MainMenuBarMicroButtons.lua :
-- SetNormal/SetPushed ne font que changer l'aspect visuel (TexCoord/Alpha) du
-- bouton, ce n'est PAS ce qui met a jour le contenu du portrait nativement.
-- Le client d'origine rafraichit MicroButtonPortrait via deux evenements
-- dedies (CharacterMicroButton_OnLoad/OnEvent) : PLAYER_ENTERING_WORLD (a
-- chaque connexion/changement de zone) et UNIT_PORTRAIT_UPDATE (quand
-- l'apparence du joueur change). Comme cette barre custom ne relaie pas ces
-- evenements vers notre texture, le portrait ne s'affichait qu'apres un
-- clic (qui declenche SetPushed/SetNormal manuellement). On ecoute donc ces
-- deux memes evenements ici, exactement comme le fait le client de base.
local characterPortraitWatcher = CreateFrame("Frame")
characterPortraitWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
characterPortraitWatcher:RegisterEvent("UNIT_PORTRAIT_UPDATE")
characterPortraitWatcher:SetScript("OnEvent", function(self, event, unit)
	if event == "UNIT_PORTRAIT_UPDATE" and unit ~= "player" then
		return
	end
	pUiUpdateCharacterPortrait()
end)

pUiUpdateCharacterPortrait()

-- Garder l'anneau hover_button_or allume en continu tant que la fenetre
-- "Infos personnage" (CharacterFrame) est ouverte, et l'eteindre a sa
-- fermeture, comme le font deja les autres micro-boutons (Sortilege,
-- Talents, etc. via SetButtonState("PUSHED")). On se branche sur
-- UpdateMicroButtons, la fonction native deja appelee par le client a
-- chaque ouverture/fermeture de CharacterFrame (et sur de nombreux autres
-- evenements de rafraichissement des micro-boutons), pour rester
-- parfaitement synchronise sans dupliquer sa logique de detection.
local function pUiSyncCharacterHighlight()
	if CharacterFrame and CharacterFrame:IsShown() then
		CharacterMicroButton:LockHighlight()
	else
		CharacterMicroButton:UnlockHighlight()
	end
end

hooksecurefunc('UpdateMicroButtons', pUiSyncCharacterHighlight)

if CharacterFrame then
	CharacterFrame:HookScript("OnShow", pUiSyncCharacterHighlight)
	CharacterFrame:HookScript("OnHide", pUiSyncCharacterHighlight)
end

-- Ni le hook sur UpdateMicroButtons ni OnShow/OnHide de CharacterFrame ne se
-- declenchent de facon fiable sur ce client (le panneau reskinne semble
-- passer par un chemin different pour s'afficher). Plutot que de continuer a
-- deviner le bon evenement, on verifie l'etat toutes les 0.2s : ca fonctionne
-- quelle que soit la maniere dont le panneau est ouvert/ferme.
local characterHighlightTicker = CreateFrame("Frame")
characterHighlightTicker.elapsed = 0
characterHighlightTicker:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed < 0 then
		return
	end
	self.elapsed = 0
	pUiSyncCharacterHighlight()
end)

-- On force aussi l'anneau tout en haut de la pile d'affichage du bouton, au
-- cas ou notre texture de portrait (creee par-dessus, layer ARTWORK) passe
-- malgre tout devant le HIGHLIGHT sur ce client.
do
	local hl = CharacterMicroButton:GetHighlightTexture()
	if hl then
		hl:SetDrawLayer("HIGHLIGHT", 7)
	end
end

pUiSyncCharacterHighlight()

function MainMenuMicroButtonMixin:OnUpdate(elapsed)
	local _, _, latencyHome = GetNetStats();
	local latency = latencyHome;
	if ( latency > PERFORMANCEBAR_MEDIUM_LATENCY ) then
		self:SetStatusBarColor(1, 0, 0);
	elseif ( latency > PERFORMANCEBAR_LOW_LATENCY ) then
		self:SetStatusBarColor(1, 1, 0);
	else
		self:SetStatusBarColor(0, 1, 0);
	end
end

function MainMenuMicroButtonMixin:CreateBar()
	local latencybar = CreateFrame('Statusbar', nil, UIParent)
	latencybar:SetParent(HelpMicroButton)
	latencybar:SetSize(14, 39)
	latencybar:SetPoint('BOTTOM', HelpMicroButton, 'BOTTOM', 0, -4)
	latencybar:SetStatusBarTexture(addon._dir..'ui-mainmenubar-performancebar')
	latencybar:SetStatusBarColor(1, 1, 0)
	latencybar:GetStatusBarTexture():SetBlendMode('ADD')
	latencybar:GetStatusBarTexture():SetDrawLayer('OVERLAY')
	latencybar:SetScript('OnUpdate', MainMenuMicroButtonMixin.OnUpdate)
end
MainMenuMicroButtonMixin:CreateBar();

local function setupMicroButtons(xOffset)
	local buttonxOffset = 0
	local menu = CreateFrame('Frame', 'pUiMicroMenu', UIParent)
	menu:SetScale(config.micromenu.scale_menu)
	menu:SetSize(10, 10)
	menu:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMRIGHT', xOffset, config.micromenu.y_position)
	for _,button in pairs(MICRO_BUTTONS) do
		local buttonName = button:GetName():gsub('MicroButton', '')
		local name = strlower(buttonName);

		button:texture_strip()

		CharacterMicroButton:SetDisabledTexture'' -- doesn't exist by default
		PVPMicroButton:SetDisabledTexture'' -- doesn't exist by default
		PVPMicroButton:GetDisabledTexture():set_atlas('ui-hud-micromenu-pvp-disabled-2x')

		button:SetParent(pUiMicroMenu)
		-- button:SetScale(1.4)
		button:SetSize(14, 19)
		button:SetClearPoint('BOTTOMLEFT', pUiMicroMenu, 'BOTTOMRIGHT', buttonxOffset, 55)
		button.SetPoint = addon._noop
		button:SetHitRectInsets(0,0,0,0)

		button:GetNormalTexture():set_atlas('ui-hud-micromenu-'..name..'-up-2x')
		button:GetPushedTexture():set_atlas('ui-hud-micromenu-'..name..'-down-2x')
		button:GetDisabledTexture():set_atlas('ui-hud-micromenu-'..name..'-disabled-2x')

		if name == 'character' then
			-- PATCH ShowHead : la case "character" de l'atlas uimicromenu2x a ete
			-- videe (cadre dore retire pour laisser la place au portrait), ce qui
			-- vide aussi la sous-case "mouseover" au meme endroit et supprime donc
			-- le highlight au survol pour ce bouton precis. On utilise a la place
			-- la texture de highlight custom fournie par l'utilisateur.
			button:SetHighlightTexture('Interface\\Buttons\\hover_button_or', 'ADD')
		else
			button:GetHighlightTexture():set_atlas('ui-hud-micromenu-'..name..'-mouseover-2x')
			button:GetHighlightTexture():SetBlendMode('ADD')
		end

		buttonxOffset = buttonxOffset + 15
	end
end

addon.package:RegisterEvents(function()
	local xOffset
	-- PATCH Collection (round 97) : MICRO_BUTTONS (ligne 24) contient
	-- desormais 11 boutons (CollectionsMicroButton a ete ajoute a la
	-- liste), mais ces deux valeurs de xOffset (-180/-166) etaient encore
	-- calibrees pour 10 boutons. Chaque bouton en plus dans MICRO_BUTTONS
	-- decale tous les boutons SUIVANTS de 15px vers la droite (voir
	-- buttonxOffset, incremente de 15 par bouton dans la boucle
	-- setupMicroButtons plus bas) sans que xOffset ne soit recalcule en
	-- consequence -- Help (dernier bouton de la liste) se retrouvait donc
	-- pousse de 15px de trop vers le bord droit de l'ecran, jusqu'a en
	-- sortir partiellement. On decale donc le point de depart de toute la
	-- rangee de 15px supplementaires vers la gauche pour compenser
	-- exactement ce bouton en plus.
	if IsAddOnLoaded('ezCollections') then
		xOffset = -195
	else
		xOffset = -181
	end
	-- PATCH Collection (round 116) : LoadMicroButtonTextures (Interface/FrameXML/
	-- MainMenuBarMicroButtons.lua) reenregistre CollectionsMicroButton sur
	-- UPDATE_BINDINGS a CHAQUE appel, et le <OnEvent> du bouton (MainMenuBarMicroButtons.xml)
	-- rappelle LoadMicroButtonTextures(self, "Mounts") a chaque UPDATE_BINDINGS, ce qui
	-- reecrit les 4 textures (Normal/Pushed/Disabled/Highlight) avec les chemins Blizzard
	-- d'origine (Interface\Buttons\UI-MicroButton-Mounts-*), ecrasant le skin custom
	-- applique juste en dessous par setupMicroButtons()/set_atlas(). N'importe quel
	-- SetBinding/SetBindingSpell ailleurs sur le client (ex: script Eluna Glide_Client du
	-- Chasseur de demons, mais ca peut venir de n'importe quel autre addon/keybind) declenche
	-- UPDATE_BINDINGS et fait donc revenir l'icone Collections a l'apparence Blizzard stock.
	-- Ce desenregistrement n'avait lieu avant que si l'addon ezCollections etait charge ; le
	-- skin de cette barre n'a de toute facon jamais besoin d'etre rafraichi par UPDATE_BINDINGS,
	-- donc on le fait desormais TOUJOURS, quel que soit l'etat de ezCollections.
	_G.CollectionsMicroButton:UnregisterEvent('UPDATE_BINDINGS')
	setupMicroButtons(xOffset + config.micromenu.x_position);
	if config.micromenu.hide_on_vehicle then
		RegisterStateDriver(pUiMicroMenu, 'visibility', '[vehicleui] hide;show')
		RegisterStateDriver(pUiBagsBar, 'visibility', '[vehicleui] hide;show')
	else
		UnregisterStateDriver(pUiMicroMenu, 'visibility')
		UnregisterStateDriver(pUiBagsBar, 'visibility')
	end
end, 'PLAYER_LOGIN'
);