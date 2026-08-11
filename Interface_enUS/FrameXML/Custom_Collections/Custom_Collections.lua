UIPanelWindows["CollectionsJournal"] = { area = "left",	pushable = 0, whileDead = 1, xOffset = "15", yOffset = "-10", width = 703, height = 606 }

local tutorialPointer;

function CollectionsJournal_SetTab(self, tab)
	PanelTemplates_SetTab(self, tab);
	-- PATCH Collection : "petJournalTab" n'est pas un CVar enregistre cote
	-- Universe (SetCVar echouerait). On retient l'onglet dans une simple
	-- variable Lua plutot que de le persister via CVar.
	COLLECTION_LAST_TAB = tab;
	CollectionsJournal_UpdateSelectedTab(self);
end

function CollectionsJournal_GetTab(self)
	return PanelTemplates_GetSelectedTab(self);
end

local titles = {
	[1] = MOUNTS,
	[2] = PETS,
	[3] = WARDROBE,
	[4] = TOY_BOX,
	[5] = HEIRLOOMS,
	[6] = TRANSMOGRIFY,
};

local function GetTitleText(titleIndex)
	return titles[titleIndex] or "";
end

function CollectionsJournal_UpdateSelectedTab(self)
	local selected = CollectionsJournal_GetTab(self);

	MountJournal:SetShown(selected == 1);
	PetJournal:SetShown(selected == 2);
	WardrobeCollectionFrame:SetShown(selected == 3);
	ToyBox:SetShown(selected == 4);
	HeirloomsJournal:SetShown(selected == 5);
	-- don't touch the wardrobe frame if it's used by the transmogrifier
	if WardrobeCollectionFrame:GetParent() == self or not WardrobeCollectionFrame:GetParent():IsShown() then
		if selected == 3 then
			HideUIPanel(WardrobeFrame);
			WardrobeCollectionFrame:SetContainer(self);
		else
			WardrobeCollectionFrame:Hide();
		end
	end

	CollectionsJournalTitleText:SetText(GetTitleText(selected));

	EventRegistry:TriggerEvent("CollectionsJournal.SetTab", selected)
end

--- Ouvre le Transmogrificateur et ferme le journal Collections.
---
--- IMPORTANT : n'utilise PAS FireCustomClientEvent("TRANSMOGRIFY_OPEN"). Ce
--- systeme d'evenement personnalise n'est ecoute que par le WardrobeFrame
--- historique defini dans NOTRE PROPRE Custom_Wardrobe.lua (porte depuis
--- Sirus, jamais reellement exerce jusqu'ici, cf. rounds precedents). Or le
--- Transmogrificateur reellement fonctionnel et utilise en jeu aujourd'hui
--- (celui qu'eZCollection ouvre depuis son propre onglet Transmog) est un
--- WardrobeFrame DIFFERENT, fourni par l'addon eZCollection
--- (Blizzard_Wardrobe.xml, charge apres tout le FrameXML de base -> son
--- <Frame name="WardrobeFrame"> ecrase la variable globale WardrobeFrame et
--- devient LA version reellement utilisee en jeu). Ce nouveau WardrobeFrame
--- n'a jamais entendu parler de notre evenement TRANSMOGRIFY_OPEN (il n'a
--- pas ete ecrit pour notre systeme), donc FireCustomClientEvent ne
--- l'atteint jamais -- d'ou le symptome observe (le journal se ferme mais
--- rien ne s'ouvre).
---
--- Fix : appeler ShowUIPanel(WardrobeFrame) directement, comme le fait
--- eZCollection lui-meme depuis son propre bouton d'onglet. WardrobeFrame
--- est lu ici comme variable GLOBALE au moment du clic (pas une reference
--- capturee a l'avance), donc on obtient toujours la version reellement
--- active en jeu, quelle qu'elle soit.
function CollectionsJournal_OpenTransmogrify(self)
	HideUIPanel(self);
	if WardrobeFrame then
		ShowUIPanel(WardrobeFrame);
	end
end

function CollectionsJournal_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");

	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\MountJournalPortrait");

	PanelTemplates_SetNumTabs(self, 6);
end

function CollectionsJournal_OnEvent(self, event)
	if event == "VARIABLES_LOADED" then
		PanelTemplates_SetTab(self, tonumber(COLLECTION_LAST_TAB) or 1);
	end
end

function CollectionsJournal_OnShow(self)
	PlaySound("igCharacterInfoOpen");
	UpdateMicroButtons();
	MicroButtonPulseStop(CollectionsMicroButton);
	CollectionsJournal_UpdateSelectedTab(self);
	EventRegistry:TriggerEvent("CollectionsJournal.OnShow")
end

function CollectionsJournal_OnHide(self)
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
	EventRegistry:TriggerEvent("CollectionsJournal.OnHide")
end