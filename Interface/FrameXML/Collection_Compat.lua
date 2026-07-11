-- Collection_Compat.lua
-- Polyfill minimal requis par le systeme de Collection porte depuis Sirus
-- (Montures / Familiers / Jouets / Reliques / Garde-robe) pour le client
-- Azeroth Universe. A charger APRES SharedXML\EventHandler.lua et
-- SharedXML\CallbackRegistry.lua, AVANT Custom_Collections\Custom_Collections.xml.

-- ============================================================
-- 1) EventRegistry (equivalent de SharedXML\GlobalCallbackRegistry.lua
--    de Sirus). Universe a deja CallbackRegistryMixin (SharedXML\CallbackRegistry.lua)
--    avec OnLoad / SetUndefinedEventsAllowed / RegisterCallback / TriggerEvent /
--    UnregisterCallback / UnregisterEvents / GenerateCallbackEvents : suffisant
--    pour tout ce que le systeme de Collection utilise reellement.
-- ============================================================
if not EventRegistry then
	EventRegistry = CreateFromMixins(CallbackRegistryMixin)

	function EventRegistry:OnLoad()
		CallbackRegistryMixin.OnLoad(self)
		self:SetUndefinedEventsAllowed(true)

		self.frameEventFrame = CreateFrame("Frame")
		self.frameEventFrame:SetScript("OnEvent", function(frameEventFrame, event, ...)
			self:TriggerEvent(event, ...)
		end)
	end

	EventRegistry:OnLoad()
end

-- ============================================================
-- 2) RegisterCustomEvent / UnregisterCustomEvent
--    Presents dans la version Sirus de SharedXML\EventHandler.lua, absents
--    de la version (plus ancienne) deja utilisee par Azeroth Universe.
--    IMPORTANT : le systeme de Collection les appelle en syntaxe methode
--    (self:RegisterCustomEvent(...)), pas comme des fonctions globales. Une
--    simple fonction globale du meme nom NE SUFFIT PAS : Lua resout
--    self:Methode(...) via la metatable de l'objet, pas via une recherche
--    dans les globales. On les ajoute donc directement a la metatable
--    partagee des Frame (meme technique que SharedXML\SharedExtendedMethods.lua,
--    qui fait deja "function Frame.__index:SetShown(...) ... end").
-- ============================================================
REGISTERED_CUSTOM_EVENTS = REGISTERED_CUSTOM_EVENTS or {}

local CollectionCompat_FrameMeta = getmetatable(CreateFrame("Frame"))

if not CollectionCompat_FrameMeta.__index.RegisterCustomEvent then
	function CollectionCompat_FrameMeta.__index:RegisterCustomEvent(event)
		if not REGISTERED_CUSTOM_EVENTS[event] then
			REGISTERED_CUSTOM_EVENTS[event] = {}
		end
		REGISTERED_CUSTOM_EVENTS[event][self] = true
	end
end

if not CollectionCompat_FrameMeta.__index.UnregisterCustomEvent then
	function CollectionCompat_FrameMeta.__index:UnregisterCustomEvent(event)
		if REGISTERED_CUSTOM_EVENTS[event] then
			REGISTERED_CUSTOM_EVENTS[event][self] = nil
		end
	end
end

-- Fonctions globales equivalentes (au cas ou du code les appelle en syntaxe
-- fonction plutot qu'en syntaxe methode).
if not RegisterCustomEvent then
	function RegisterCustomEvent(self, event)
		self:RegisterCustomEvent(event)
	end
end

if not UnregisterCustomEvent then
	function UnregisterCustomEvent(self, event)
		self:UnregisterCustomEvent(event)
	end
end

-- ============================================================
-- 2bis) FireCustomClientEvent
--    ROUND 53 : le systeme de Collection appelle FireCustomClientEvent(...)
--    ~24 fois (rafraichissement de la recherche Montures/Familiers, mise a
--    jour du bouton Invoquer/Renvoyer, remplissage de la grille Reliques,
--    etc.) mais cette fonction n'existait nulle part dans ce patch -- seuls
--    RegisterCustomEvent/UnregisterCustomEvent (qui remplissent
--    REGISTERED_CUSTOM_EVENTS) avaient ete portes plus haut. Resultat : les
--    listeners s'enregistraient correctement, mais n'etaient jamais
--    notifies -- d'ou recherche Montures/Familiers muette, bouton
--    Invoquer/Renvoyer jamais mis a jour, et grille Heritage qui reste
--    vide meme quand C_Heirloom a bien des donnees en interne.
--
--    ROUND 55 : la toute premiere version utilisait ExecuteFrameScript
--    (comme Sirus), mais ExecuteFrameScript echoue SILENCIEUSEMENT (avale
--    par securecall) quand on l'appelle en contexte REENTRANT -- c'est a
--    dire quand FireCustomClientEvent est lui-meme appele depuis
--    l'INTERIEUR d'un script Frame deja en cours d'execution (ex:
--    PopulateHeirloomData appelle FireCustomClientEvent("HEIRLOOMS_UPDATED")
--    depuis le OnEvent de PLAYER_ENTERING_WORLD ; les recherches Montures/
--    Familiers appellent FireCustomClientEvent depuis le OnTextChanged de
--    la EditBox). Ce sont exactement les cas les plus courants
--    d'utilisation de ce systeme. On appelle desormais directement le
--    script OnEvent du frame (un simple appel de fonction Lua, sans passer
--    par ExecuteFrameScript), ce qui n'a aucune restriction de reentrance.
-- ============================================================
if not FireCustomClientEvent then
	function FireCustomClientEvent(event, ...)
		local listeners = REGISTERED_CUSTOM_EVENTS[event]
		if not listeners then
			return
		end
		local frame = securecall(next, listeners, nil)
		while frame do
			local handler = frame.GetScript and frame:GetScript("OnEvent")
			if handler then
				securecall(handler, frame, event, ...)
			end
			frame = securecall(next, listeners, frame)
		end
	end
end

-- ============================================================
-- 2ter) AzuCollection_RequestItem
--    ROUND 54 : sur Azeroth Universe, cliquer un Jouet ou une Relique/
--    Heritage collecte(e) doit creer l'objet PHYSIQUE dans le sac du
--    joueur (pas de courrier, pas juste un effet de sort a la retail). Le
--    client seul n'a AUCUNE autorite pour creer un item -- ceci envoie
--    juste une DEMANDE au serveur via un message d'addon (le seul canal
--    client->serveur disponible sans toucher au C++ du core), capte cote
--    serveur par un script Eluna fourni a part
--    (AzuCollection_ItemGrant.lua) qui verifie l'entitlement reel
--    (player:HasSpell(spellID), autorite serveur) avant de creer l'item
--    (player:AddItem). Sans ce script Eluna installe et actif, cette
--    fonction envoie le message mais rien ne se passera cote serveur.
-- ============================================================
AZUCOL_ADDON_PREFIX = "AZUCOL"

function AzuCollection_RequestItem(kind, itemID)
	if type(itemID) ~= "number" then
		return;
	end
	SendAddonMessage(AZUCOL_ADDON_PREFIX, kind .. ":" .. itemID, "WHISPER", UnitName("player"));
end

-- ============================================================
-- 3) C_EventUtils.IsEventValid : uniquement utilise par
--    EventRegistry:OnAttributeChanged (jamais declenche par le systeme de
--    Collection, qui n'utilise que :TriggerEvent/:RegisterCallback), mais on
--    le fournit quand meme par securite pour eviter un crash si un jour
--    quelque chose s'appuie dessus.
-- ============================================================
C_EventUtils = C_EventUtils or {}
if not C_EventUtils.IsEventValid then
	function C_EventUtils.IsEventValid(event)
		return false
	end
end

-- ============================================================
-- 4) GetCVarBitfield / SetCVarBitfield
--    Version standalone (pas besoin de porter tout C_CVar.lua de Sirus, qui
--    enregistre ~150 CVars propres a Sirus). S'appuie uniquement sur les
--    natives stock GetCVar/SetCVar + la lib bit, deja presentes.
-- ============================================================
if not GetCVarBitfield then
	function GetCVarBitfield(name, index)
		if type(name) ~= "string" or type(index) ~= "number" then
			error("Usage: local value = GetCVarBitfield(name, index)", 2)
		end
		local value = tonumber(GetCVar(name)) or 0
		return bit.band(value, bit.lshift(1, index - 1)) ~= 0
	end
end

if not SetCVarBitfield then
	function SetCVarBitfield(name, index, value, scriptCvar)
		if type(name) ~= "string" or type(index) ~= "number" then
			error("Usage: local value = SetCVarBitfield(name, index)", 2)
		end
		local currentValue = tonumber(GetCVar(name)) or 0
		if value then
			value = bit.bor(currentValue, bit.lshift(1, index - 1))
		else
			value = bit.band(currentValue, bit.bnot(bit.lshift(1, index - 1)))
		end
		SetCVar(name, value)
	end
end

-- ============================================================
-- 5) GMError : present dans Sirus\SharedXML\Utils\C_Service.lua, absent
--    d'Universe. Universe a deja IsGMAccount() (SharedXML\Utils\C_Service.lua),
--    on s'appuie dessus.
-- ============================================================
if not GMError then
	function GMError(err)
		if IsGMAccount and IsGMAccount() then
			geterrorhandler()("[GMError] " .. tostring(err))
		end
	end
end

-- ============================================================
-- 6) Model_OnShow : petit helper utilise par Custom_MountCollection.lua,
--    present dans Sirus\FrameXML\UIParent.lua, absent de la version
--    Universe de ce (tres gros) fichier. Copie verbatim.
-- ============================================================
if not Model_OnShow then
	function Model_OnShow(self, rotation)
		if self.isZooming then
			self.originZoom = 0
			self.newZoom = 0
		end
		if rotation then
			self.rotation = rotation
			self:SetRotation(self.rotation)
		end
	end
end

-- ============================================================
-- 7) ToggleCollectionsJournal : ouverture/fermeture du panneau, presente
--    dans Sirus\FrameXML\UIParent.lua. Suit le meme schema que les autres
--    ToggleXFrame() du client (ShowUIPanel/HideUIPanel).
-- ============================================================
if not ToggleCollectionsJournal then
	function ToggleCollectionsJournal(tab)
		if CollectionsJournal and CollectionsJournal:IsShown() then
			HideUIPanel(CollectionsJournal)
		else
			if tab then
				PanelTemplates_SetTab(CollectionsJournal, tab)
			end
			ShowUIPanel(CollectionsJournal)
		end
	end
end

-- ============================================================
-- 8) Chaines de localisation manquantes (absentes de GlobalStrings.lua
--    d'Universe ; MOUNTS et PETS existent deja et ne sont pas touches).
-- ============================================================
if not COLLECTIONS then COLLECTIONS = "Collections" end
if not WARDROBE then WARDROBE = "Garde-robe" end
if not TOY_BOX then TOY_BOX = "Jouets" end
if not HEIRLOOMS then HEIRLOOMS = "Héritage" end

-- ============================================================
-- ROUND 59 : HEIRLOOMS_CATEGORY_* -- chaines GlobalStrings manquantes
--    cote Universe (presentes cote Sirus, ex: GlobalStrings.lua). Utilisees
--    par GetHeirloomCategoryFromInvType (Custom_HeirloomCollection.lua)
--    pour classer chaque relique dans une categorie ("Tete", "Armes",
--    etc). Comme ces globales valaient nil, GetHeirloomCategoryFromInvType
--    renvoyait TOUJOURS nil (peu importe l'invType), donc la condition
--    "if category then" echouait pour les 24 reliques a chaque fois --
--    c'est la VRAIE cause de la grille Heritage bloquee a 0/0 malgre un
--    filtre classe et des donnees par ailleurs correctes (confirme par
--    /hdebug round 58 : SortHeirloomsIntoEquipmentBuckets() s'executait
--    sans erreur mais remplissait 0 categorie sur 24 objets pourtant
--    valides).
-- ============================================================
if not HEIRLOOMS_CATEGORY_HEAD then HEIRLOOMS_CATEGORY_HEAD = "Tête" end
if not HEIRLOOMS_CATEGORY_SHOULDER then HEIRLOOMS_CATEGORY_SHOULDER = "Épaule" end
if not HEIRLOOMS_CATEGORY_BACK then HEIRLOOMS_CATEGORY_BACK = "Dos" end
if not HEIRLOOMS_CATEGORY_CHEST then HEIRLOOMS_CATEGORY_CHEST = "Torse" end
if not HEIRLOOMS_CATEGORY_HAND then HEIRLOOMS_CATEGORY_HAND = "Mains" end
if not HEIRLOOMS_CATEGORY_WRIST then HEIRLOOMS_CATEGORY_WRIST = "Poignets" end
if not HEIRLOOMS_CATEGORY_LEGS then HEIRLOOMS_CATEGORY_LEGS = "Jambes" end
if not HEIRLOOMS_CATEGORY_WAIST then HEIRLOOMS_CATEGORY_WAIST = "Taille" end
if not HEIRLOOMS_CATEGORY_FEET then HEIRLOOMS_CATEGORY_FEET = "Pieds" end
if not HEIRLOOMS_CATEGORY_WEAPON then HEIRLOOMS_CATEGORY_WEAPON = "Armes" end
if not HEIRLOOMS_CATEGORY_TRINKETS_RINGS_NECKLACES_AND_RELIC then HEIRLOOMS_CATEGORY_TRINKETS_RINGS_NECKLACES_AND_RELIC = "Bijoux, anneaux, colliers et reliques" end
if not MAINMENUBAR_COLLECTIONS_BUTTON_DESC then
	MAINMENUBAR_COLLECTIONS_BUTTON_DESC = "Affiche toutes vos montures et familiers."
end
if not BINDING_NAME_TOGGLECOLLECTIONS then
	BINDING_NAME_TOGGLECOLLECTIONS = "Ouvrir les collections"
end

-- ============================================================
-- 9) UIResettableDropdownButtonMixin : utilise par le bouton FILTER des 5
--    systemes de Collection (UIResettableDropdownButtonTemplate, cf
--    Collection_Compat.xml). Version simplifiee par rapport a Sirus : ne
--    depend pas de UIMenuButtonStretchMixin (qui n'existe pas cote Universe,
--    dont le UIMenuButtonStretchTemplate gere deja OnMouseDown/OnMouseUp en
--    scripts XML inline).
-- ============================================================
if not UIResettableDropdownButtonMixin then
	UIResettableDropdownButtonMixin = {}

	function UIResettableDropdownButtonMixin:OnLoad()
		self.ResetButton:SetScript("OnClick", function(button, buttonName, down)
			if self.resetFunction then
				self.resetFunction()
			end
			self.ResetButton:Hide()
		end)
	end

	function UIResettableDropdownButtonMixin:SetResetFunction(resetFunction)
		self.resetFunction = resetFunction
	end
end

-- ============================================================
-- 10) SKILL_NAME_* : chaines globales de noms de competences d'armes/armures
--     utilisees par C_TransmogCollection.lua (SKILL_ID_BY_NAME), absentes du
--     GlobalStrings.lua d'Universe. Traductions FR officielles Blizzard.
-- ============================================================
if not SKILL_NAME_SWORDS then SKILL_NAME_SWORDS = "Epees" end
if not SKILL_NAME_AXES then SKILL_NAME_AXES = "Haches" end
if not SKILL_NAME_BOWS then SKILL_NAME_BOWS = "Arcs" end
if not SKILL_NAME_GUNS then SKILL_NAME_GUNS = "Armes a feu" end
if not SKILL_NAME_MACES then SKILL_NAME_MACES = "Masse" end -- PATCH round 27: /cdebug a montre "Masse" (singulier), pas "Masses"
if not SKILL_NAME_TWO_HANDED_SWORDS then SKILL_NAME_TWO_HANDED_SWORDS = "Epees a deux mains" end
if not SKILL_NAME_STAVES then SKILL_NAME_STAVES = "Batons" end
if not SKILL_NAME_TWO_HANDED_MACES then SKILL_NAME_TWO_HANDED_MACES = "Masses a deux mains" end
if not SKILL_NAME_TWO_HANDED_AXES then SKILL_NAME_TWO_HANDED_AXES = "Haches a deux mains" end
if not SKILL_NAME_DAGGERS then SKILL_NAME_DAGGERS = "Dagues" end
if not SKILL_NAME_THROWN then SKILL_NAME_THROWN = "Armes de jet" end
if not SKILL_NAME_CROSSBOWS then SKILL_NAME_CROSSBOWS = "Arbaletes" end
if not SKILL_NAME_WANDS then SKILL_NAME_WANDS = "Baguettes" end
if not SKILL_NAME_POLEARMS then SKILL_NAME_POLEARMS = "Armes d'hast" end
if not SKILL_NAME_CHIELD then SKILL_NAME_CHIELD = "Bouclier" end
if not SKILL_NAME_FIST_WEAPONS then SKILL_NAME_FIST_WEAPONS = "Armes de pugilat" end
if not SKILL_NAME_FISHING then SKILL_NAME_FISHING = "Peche" end
if not SKILL_NAME_PLATE_MAIL then SKILL_NAME_PLATE_MAIL = "Plaques" end
if not SKILL_NAME_MAIL then SKILL_NAME_MAIL = "Mailles" end
if not SKILL_NAME_LEATHER then SKILL_NAME_LEATHER = "Cuir" end
if not SKILL_NAME_CLOTH then SKILL_NAME_CLOTH = "Tissu" end

-- ============================================================
-- 11) C_SpellBook.FilterOutSpellLearn : utilise par C_TransmogCollection.lua
--     (BuildIllusions) pour ne pas afficher de popup "sort appris" pour les
--     sorts d'illusions. Le vrai C_SpellBook.lua de Sirus depend de
--     FLYOUT_STORAGE/C_GlobalStorage non portes ici ; comme cette fonction ne
--     sert qu'a du filtrage cosmetique de popups, un stub inoffensif suffit.
-- ============================================================
C_SpellBook = C_SpellBook or {}
if not C_SpellBook.FilterOutSpellLearn then
	function C_SpellBook.FilterOutSpellLearn(spellID, spellName)
		-- no-op
	end
end

-- ============================================================
-- 12) S_ATLAS_STORAGE : :SetAtlas(...) (SharedXML\SharedExtendedMethods.lua)
--     lit la table globale S_ATLAS_STORAGE, qui n'est initialisee comme table
--     VIDE que par Interface\FrameXML\EncounterJournal_OfflineStubs.lua
--     ("S_ATLAS_STORAGE = S_ATLAS_STORAGE or {}") - jamais remplie. Les
--     vraies donnees d'atlas existent deja dans SharedXML\AtlasStorage.lua
--     sous le nom PRETTY_ATLAS_STORAGE. On fusionne les deux, quel que soit
--     l'ordre de chargement (le "or {}" plus loin dans le .toc ne remplacera
--     pas une table deja non-nil).
-- ============================================================
S_ATLAS_STORAGE = S_ATLAS_STORAGE or {}
if PRETTY_ATLAS_STORAGE then
	for atlasName, atlasData in pairs(PRETTY_ATLAS_STORAGE) do
		if S_ATLAS_STORAGE[atlasName] == nil then
			S_ATLAS_STORAGE[atlasName] = atlasData
		end
	end
end

-- ============================================================
-- 13) EnumUtil.MakeEnum / EnumUtil.IsValid : utilises par FilterDropdown.lua.
--     On NE porte PAS SharedXML\EnumUtil.lua de Sirus tel quel : ce fichier
--     redefinirait aussi Enum/enum, qui existent deja et fonctionnent cote
--     Universe (SharedXML\Extensions\enum.lua). On ajoute seulement les 2
--     fonctions manquantes, basees sur tInvert/tContains (deja presents).
-- ============================================================
EnumUtil = EnumUtil or {}
if not EnumUtil.MakeEnum then
	function EnumUtil.MakeEnum(...)
		return tInvert({...})
	end
end
if not EnumUtil.IsValid then
	function EnumUtil.IsValid(enumClass, enumValue)
		return tContains(enumClass, enumValue)
	end
end

-- ============================================================
-- 14) UIDropDownMenu_AddSpace / AddSeparator / RefreshAll : utilises par
--     FilterDropdown.lua, absents de la version d'UIDropDownMenu.lua
--     d'Universe (seul UIDropDownMenu_AddButton existe). Copies verbatim
--     depuis Sirus.
-- ============================================================
if not UIDropDownMenu_AddSeparator then
	function UIDropDownMenu_AddSeparator(level)
		local separatorInfo = {
			hasArrow = false;
			dist = 0;
			isTitle = true;
			isUninteractable = true;
			notCheckable = true;
			iconOnly = true;
			icon = "Interface\\Common\\UI-TooltipDivider-Transparent";
			tCoordLeft = 0;
			tCoordRight = 1;
			tCoordTop = 0;
			tCoordBottom = 1;
			tSizeX = 0;
			tSizeY = 8;
			tFitDropDownSizeX = true;
			iconInfo = {
				tCoordLeft = 0,
				tCoordRight = 1,
				tCoordTop = 0,
				tCoordBottom = 1,
				tSizeX = 0,
				tSizeY = 8,
				tFitDropDownSizeX = true
			},
		};

		UIDropDownMenu_AddButton(separatorInfo, level);
	end
end

if not UIDropDownMenu_AddSpace then
	function UIDropDownMenu_AddSpace(level)
		local spaceInfo = {
			hasArrow = false,
			dist = 0,
			isTitle = true,
			isUninteractable = true,
			notCheckable = true,
		};

		UIDropDownMenu_AddButton(spaceInfo, level);
	end
end

if not UIDropDownMenu_RefreshAll then
	function UIDropDownMenu_RefreshAll(frame, useValue)
		for dropdownLevel = UIDROPDOWNMENU_MENU_LEVEL, 2, -1 do
			local listFrame = _G["DropDownList"..dropdownLevel];
			if listFrame and listFrame:IsShown() then
				UIDropDownMenu_Refresh(frame, nil, dropdownLevel);
			end
		end
		UIDropDownMenu_Refresh(frame, useValue, 1);
	end
end

-- ============================================================
-- 15) Chaines de localisation manquantes (suite) : reperees en balayant tout
--     Custom_Collections a la recherche de constantes GlobalStrings absentes
--     d'Universe (confirme par les erreurs en jeu : ERR_NO_RIDING_SKILL,
--     RANDOM_FAVORITE_MOUNT, YOU_IN_COLLECTED, WARDROBE_ITEMS, etc.)
-- ============================================================
if not ADD_TO_FAVORITE then ADD_TO_FAVORITE = "Ajouter aux favoris" end
if not ALL_CLASSES then ALL_CLASSES = "Toutes les classes" end
if not ALL_MOUNTS then ALL_MOUNTS = "Toutes les montures" end
if not ALL_SPECS then ALL_SPECS = "Toutes les specialisations" end
if not BATTLE_PET_FAVORITE then BATTLE_PET_FAVORITE = "Ajouter aux favoris" end
if not BATTLE_PET_UNFAVORITE then BATTLE_PET_UNFAVORITE = "Retirer des favoris" end
if not BUY then BUY = "Acheter" end
if not CATEGORYES then CATEGORYES = "Categories" end
if not CHECK_ALL then CHECK_ALL = "Tout cocher" end
if not COLLECTED then COLLECTED = "Collectionne" end
if not COLLECTION_MOUNT_ABILITIES then COLLECTION_MOUNT_ABILITIES = "Capacites" end
if not COLLECTION_PAGE_NUMBER then COLLECTION_PAGE_NUMBER = "Page %d / %d" end
if not COLLECTION_TRAVELING_MERCHANTS then COLLECTION_TRAVELING_MERCHANTS = "Marchands itinerants" end
if not COMMUNITIES_LIST_DROP_DOWN_FAVORITE then COMMUNITIES_LIST_DROP_DOWN_FAVORITE = "Ajouter aux favoris" end
if not DELETE_FAVORITE then DELETE_FAVORITE = "Retirer des favoris" end
if not ERR_NO_RIDING_SKILL then ERR_NO_RIDING_SKILL = "Vous pouvez apprendre l'equitation et obtenir une monture aupres de votre dresseur d'equitation au niveau 20" end
if not FAVORITES then FAVORITES = "Favoris" end
if not GO_TO_BATTLE_BASS then GO_TO_BATTLE_BASS = "Aller au Passe de combat" end
if not GO_TO_STORE then GO_TO_STORE = "Aller a la boutique" end
if not HEIRLOOMS_PROGRESS_FORMAT then HEIRLOOMS_PROGRESS_FORMAT = "%d/%d" end
if not MOUNT_COLLECTION_ENCOUNTER then MOUNT_COLLECTION_ENCOUNTER = "Codex" end
if not MOUNT_COLLECTION_ENCOUNTER_DESC then MOUNT_COLLECTION_ENCOUNTER_DESC = "Vous pouvez l'obtenir en butin" end
if not MOUNT_COLLECTION_ENCOUNTER_SHOW then MOUNT_COLLECTION_ENCOUNTER_SHOW = "Afficher" end
if not MOUNT_JOURNAL_PLAYER then MOUNT_JOURNAL_PLAYER = "Afficher le personnage" end
if not MY_COLLECTIONS then MY_COLLECTIONS = "Ma collection" end
if not NEW_CAPS then NEW_CAPS = "NOUVEAU" end
if not NOT_COLLECTED then NOT_COLLECTED = "Non collectionne" end
if not PET_FAMILIES then PET_FAMILIES = "Familles de familiers" end
if not PET_JOURNAL_SUMMON_RANDOM_FAVORITE_PET then PET_JOURNAL_SUMMON_RANDOM_FAVORITE_PET = "Invoquer un familier\nfavori aleatoire" end
if not PICK_UP then PICK_UP = "Prendre" end
if not RANDOM_FAVORITE_MOUNT then RANDOM_FAVORITE_MOUNT = "Invoquer une monture favorite aleatoire" end
if not SOURCES then SOURCES = "Sources" end
if not TOY_PROGRESS_FORMAT then TOY_PROGRESS_FORMAT = "%d/%d" end
if not TRANSMOGRIFY then TRANSMOGRIFY = "Transmogrification" end
if not TRANSMOGRIFY_FILTER_SORT_TITLE then TRANSMOGRIFY_FILTER_SORT_TITLE = "Trier" end
if not TRANSMOG_HELP_BUTTON then TRANSMOG_HELP_BUTTON = "Regles completes" end
if not TRANSMOG_HELP_HEADER then TRANSMOG_HELP_HEADER = "Regles de transmogrification pour ce type d'objet" end
if not TRANSMOG_NO_VALID_ITEMS_EQUIPPED then TRANSMOG_NO_VALID_ITEMS_EQUIPPED = "Aucun objet valide equipe." end
if not UNCHECK_ALL then UNCHECK_ALL = "Tout decocher" end
if not WARDROBE_ITEMS then WARDROBE_ITEMS = "Objets" end
if not WARDROBE_NO_SEARCH then WARDROBE_NO_SEARCH = "Aucun resultat de recherche." end
if not WARDROBE_TRANSMOGRIFY_AS then WARDROBE_TRANSMOGRIFY_AS = "Transmogrifier en :" end
if not WEAPON_ENCHANTMENT then WEAPON_ENCHANTMENT = "Enchantement d'arme" end
if not YOU_IN_COLLECTED then YOU_IN_COLLECTED = "Votre collection :" end

-- ============================================================
-- 16) C_Service / IsGMAccount / GetServerID : Interface\SharedXML\Utils\C_Service.lua
--     existe bien cote Universe MAIS n'est reference dans AUCUN .toc (ni
--     FrameXML ni Glue) - c'est un fichier mort, jamais charge. Plusieurs
--     fichiers du systeme de Collection font "local IsGMAccount = IsGMAccount"
--     en tete de fichier et capturent donc nil. On ne porte pas le vrai
--     fichier tel quel (il depend de RegisterEventListener/RegisterHookListener
--     qui n'existent nulle part cote Universe et planterait a l'OnLoad) : on
--     fournit un stub minimal suffisant (retourne toujours "pas GM").
-- ============================================================
if not IsGMAccount then
	function IsGMAccount()
		return false
	end
end

C_Service = C_Service or {}
if not C_Service.GetRealmID then
	function C_Service:GetRealmID()
		return 0
	end
end
if not C_Service.IsGM then
	function C_Service:IsGM()
		return false
	end
end

-- ============================================================
-- 17) LE_MOUNT_JOURNAL_FILTER_* : constantes de Interface\FrameXML\Constants.lua
--     de Sirus, absentes de la version d'Universe de ce fichier.
-- ============================================================
if not LE_MOUNT_JOURNAL_FILTER_COLLECTED then LE_MOUNT_JOURNAL_FILTER_COLLECTED = 1 end
if not LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED then LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED = 2 end
if not LE_MOUNT_JOURNAL_FILTER_FAVORITES then LE_MOUNT_JOURNAL_FILTER_FAVORITES = 3 end

-- ============================================================
-- 18) C_FactionManager.RegisterCallback / GetFactionOverrideCVar : Universe a
--     deja un stub C_FactionManager (Interface\FrameXML\EncounterJournal_OfflineStubs.lua)
--     mais avec d'autres noms de methodes (RegisterFactionOverrideCallback,
--     pas RegisterCallback). On complete ce meme stub avec les noms que le
--     systeme de Collection appelle reellement, sans toucher a l'existant.
-- ============================================================
C_FactionManager = C_FactionManager or {}
if not C_FactionManager.RegisterCallback then
	function C_FactionManager.RegisterCallback(callback, shouldExecute, persistent)
		if shouldExecute and callback then
			callback()
		end
	end
end
if not C_FactionManager.GetFactionOverrideCVar then
	function C_FactionManager.GetFactionOverrideCVar()
		return nil
	end
end

-- ============================================================
-- 19) MicroButtonPulse / MicroButtonPulseStop : utilises par
--     CollectionsJournal_OnShow sur le bouton CollectionsMicroButton, absents
--     d'Universe. Version defensive (garde si .Flash n'existe pas).
-- ============================================================
if not MicroButtonPulse then
	function MicroButtonPulse(self, duration)
		if self and self.Flash and UIFrameFlash then
			UIFrameFlash(self.Flash, 1.0, 1.0, duration or -1, false, 0, 0, "microbutton")
		end
	end
end
if not MicroButtonPulseStop then
	function MicroButtonPulseStop(self)
		if self and self.Flash and UIFrameFlashStop then
			UIFrameFlashStop(self.Flash)
		end
	end
end

-- ============================================================
-- 20) Enum.TransmogType : defini dans Interface\FrameXML\Utils\C_Transmog.lua
--     de Sirus (fichier non porte : trop de dependances pour la seule frame
--     "au PNJ transmogrificateur", separee de l'onglet Garde-robe du Codex
--     de Collection). On fournit juste l'enum, utilise par Custom_Wardrobe.xml.
-- ============================================================
Enum = Enum or {}
if not Enum.TransmogType then
	Enum.TransmogType = {Appearance = 0, Illusion = 1}
end

-- ============================================================
-- 21) C_StorePublic / C_StoreSecure : boutique/cash-shop, non portee (aucun
--     systeme de boutique cote Universe). Stubs "boutique indisponible" pour
--     eviter les crashs sur les boutons Acheter des montures/familiers
--     premium ; ces objets resteront non-achetables via le Codex, ce qui est
--     deja le cas fonctionnellement sans backend boutique.
-- ============================================================
C_StorePublic = C_StorePublic or {}
if not C_StorePublic.IsEnabled then function C_StorePublic.IsEnabled() return false end end
if not C_StorePublic.IsValidCurrencyType then function C_StorePublic.IsValidCurrencyType(currencyType) return false end end
if not C_StorePublic.GetRolledItemInfoByHash then function C_StorePublic.GetRolledItemInfoByHash(hash) return nil end end

C_StoreSecure = C_StoreSecure or {}
if not C_StoreSecure.GetVirtualCategoryByRemoteID then
	function C_StoreSecure.GetVirtualCategoryByRemoteID(...)
		return nil, nil
	end
end


-- ============================================================
-- 23) Constantes Transmog manquantes de Constants.lua (Sirus)
-- ============================================================
if not NO_TRANSMOG_VISUAL_ID then NO_TRANSMOG_VISUAL_ID = 0 end
if not FIRST_TRANSMOG_COLLECTION_SUB_CATEGORY then FIRST_TRANSMOG_COLLECTION_SUB_CATEGORY = 0 end
if not LAST_TRANSMOG_COLLECTION_SUB_CATEGORY then LAST_TRANSMOG_COLLECTION_SUB_CATEGORY = 5 end

Enum = Enum or {}
if not Enum.TransmogModification then
	Enum.TransmogModification = {Main = 0, Secondary = 1}
end
if not Enum.TransmogPendingType then
	Enum.TransmogPendingType = {Apply = 0, Revert = 1, ToggleOn = 2, ToggleOff = 3}
end

-- ============================================================
-- 24) C_Transmog : stub minimal. Le systeme complet (Sirus\Utils\C_Transmog.lua,
--     950 lignes) s'appuie sur un protocole d'addon-message serveur (ASMSG_*)
--     que le serveur Universe n'implemente pas, donc on ne le porte PAS
--     integralement (crasherait sur SendServerMessage/evenements jamais recus).
--     Ce stub couvre uniquement les appels faits par WardrobeCollectionFrame
--     (onglet Garde-robe du Codex) pour eviter les crashs OnLoad/OnShow.
--     Consequence : le Codex peut etre parcouru normalement, mais le bouton
--     "Appliquer" d'un transmogrificateur ne sera pas fonctionnel tant que le
--     serveur ne parle pas ce protocole.
-- ============================================================
if not C_Transmog then
	C_Transmog = {}
	function C_Transmog.IsAtTransmogNPC() return false end
	function C_Transmog.Close() end
	function C_Transmog.GetSlotEffectiveCategory(transmogLocation) return nil, nil end
	function C_Transmog.SetPending(transmogLocation, pendingInfo) end
	function C_Transmog.GetApplyCost() return 0 end
	function C_Transmog.GetApplyWarnings() return {} end
	function C_Transmog.ApplyAllPending() return false end
	function C_Transmog.LoadOutfit(outfitID) end
	function C_Transmog.GetSlotInfo(transmogLocation)
		-- isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture
		return false, false, false, true, nil, false, false, nil
	end
	function C_Transmog.ClearPending(transmogLocation) end
	function C_Transmog.GetSlotVisualInfo(transmogLocation)
		-- baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo, _, itemSubclass
		return 0, 0, 0, 0, 0, 0, false, nil, nil
	end
	function C_Transmog.GetSlotUseError(transmogLocation) return nil, nil end
	function C_Transmog.GetPending(transmogLocation) return nil end
	function C_Transmog.GetInventoryTransmogInfo(unit, slotID) return nil end
end

-- ============================================================
-- 25) C_Talent.GetCurrentSpecID : utilise par Custom_HeirloomCollection.lua
--     pour filtrer par spe active. Universe a son propre C_Talent (base sur
--     GetActiveTalentGroup, 1 ou 2), sans notion de "specID" a la retail.
--     On fournit un alias sans danger (nil = pas de filtre par spe applique).
-- ============================================================
C_Talent = C_Talent or {}
if not C_Talent.GetCurrentSpecID then
	function C_Talent.GetCurrentSpecID()
		-- Universe n'a pas de vraie notion de specID retail ; 0 correspond a la
		-- convention NO_SPEC_FILTER utilisee par Custom_HeirloomCollection.lua
		-- (evite l'erreur "Usage: C_Heirloom.SetClassAndSpecFilters(classID, specID)").
		return 0
	end
end

-- ============================================================
-- 26) LE_PET_JOURNAL_FILTER_* : constantes manquantes (seules les
--     LE_MOUNT_JOURNAL_FILTER_* avaient ete ajoutees au round precedent).
-- ============================================================
if not LE_PET_JOURNAL_FILTER_COLLECTED then LE_PET_JOURNAL_FILTER_COLLECTED = 1 end
if not LE_PET_JOURNAL_FILTER_NOT_COLLECTED then LE_PET_JOURNAL_FILTER_NOT_COLLECTED = 2 end

-- ============================================================
-- 27) PET_TYPE_SUFFIX : table manquante de Constants.lua (Sirus), utilisee
--     par Custom_PetCollection.lua pour l'icone de type de familier.
-- ============================================================
if not PET_TYPE_SUFFIX then
	PET_TYPE_SUFFIX = {
		[1] = "Water",
		[2] = "Humanoid",
		[3] = "Dragon",
		[4] = "Beast",
		[5] = "Critter",
		[6] = "Flying",
		[7] = "Magical",
		[8] = "Mechanical",
		[9] = "Undead",
		[10] = "Elemental",
	}
end

-- ============================================================
-- 28) CVars de filtres non enregistres cote client (heirloomCollectedFilters,
--     heirloomSourceFilters, toyBoxCollectedFilters, toyBoxSourceFilters) :
--     le moteur client d'Azeroth Universe rejette GetCVar/SetCVar avec
--     "Couldn't find CVar named ..." pour tout nom de CVar non enregistre en
--     dur cote client (meme principe que petJournalTab au round precedent).
--     On intercepte GetCVar/SetCVar UNIQUEMENT pour ces 4 noms precis et on
--     les redirige vers une table Lua ; tous les autres noms de CVar passent
--     par les fonctions natives normalement.
-- ============================================================
local COLLECTION_SHIMMED_CVARS = {
	heirloomCollectedFilters = true,
	heirloomSourceFilters = true,
	toyBoxCollectedFilters = true,
	toyBoxSourceFilters = true,
	petJournalFilters = true,
	petJournalSort = true,
	petJournalSourceFilters = true,
	petJournalTypeFilters = true,
	petJournalExpansionFilters = true,
	mountJournalFactionFilter = true,
	mountJournalGeneralFilters = true,
	mountJournalAbilityFilters = true,
	mountJournalSourcesFilter = true,
	mountJournalTravelingMerchantFilter = true,
	mountJournalShowPlayer = true,
	illusionShowCollected = true,
	illusionShowUncollected = true,
	illusionSourceFilters = true,
	lastTransmogOutfit = true,
	wardrobeShowCollected = true,
	wardrobeShowUncollected = true,
	wardrobeSourceFilters = true,
}
COLLECTION_CVAR_SHIM_VALUES = COLLECTION_CVAR_SHIM_VALUES or {}

-- PATCH round 80 : valeurs par defaut pour les CVars "afficher
-- collectionne / non collectionne" de la Garde-robe (et des Illusions, meme
-- systeme). Sans ce seed, GetCVar retombe sur "0" (false) tant que le
-- joueur n'a jamais clique sur "reinitialiser les filtres", et
-- SetSearchAndFilterAppearances (C_TransmogCollection.lua) masque de facon
-- INCONDITIONNELLE tous les objets non collectionnes quand
-- wardrobeShowUncollected est faux -- d'ou la grille Garde-robe vide (0/N)
-- au premier affichage de l'onglet, jusqu'a cliquer sur la petite croix.
if COLLECTION_CVAR_SHIM_VALUES.wardrobeShowCollected == nil then
	COLLECTION_CVAR_SHIM_VALUES.wardrobeShowCollected = "1"
end
if COLLECTION_CVAR_SHIM_VALUES.wardrobeShowUncollected == nil then
	COLLECTION_CVAR_SHIM_VALUES.wardrobeShowUncollected = "1"
end
if COLLECTION_CVAR_SHIM_VALUES.illusionShowCollected == nil then
	COLLECTION_CVAR_SHIM_VALUES.illusionShowCollected = "1"
end
if COLLECTION_CVAR_SHIM_VALUES.illusionShowUncollected == nil then
	COLLECTION_CVAR_SHIM_VALUES.illusionShowUncollected = "1"
end

if not COLLECTION_CVAR_SHIM_INSTALLED then
	COLLECTION_CVAR_SHIM_INSTALLED = true

	local RealGetCVar = GetCVar
	local RealSetCVar = SetCVar

	function GetCVar(name, ...)
		if COLLECTION_SHIMMED_CVARS[name] then
			return COLLECTION_CVAR_SHIM_VALUES[name] or "0"
		end
		return RealGetCVar(name, ...)
	end

	function SetCVar(name, value, ...)
		if COLLECTION_SHIMMED_CVARS[name] then
			COLLECTION_CVAR_SHIM_VALUES[name] = tostring(value)
			return
		end
		return RealSetCVar(name, value, ...)
	end

	if GetCVarBool then
		local RealGetCVarBool = GetCVarBool
		function GetCVarBool(name, ...)
			if COLLECTION_SHIMMED_CVARS[name] then
				local value = COLLECTION_CVAR_SHIM_VALUES[name]
				return value == "1" or value == "true"
			end
			return RealGetCVarBool(name, ...)
		end
	end
end

-- ============================================================
-- 29) CHAR_COLLECTION_* : constantes de Constants.lua (Sirus), entierement
--     absentes d'Universe. Utilisees par C_MountJournal/C_PetJournal/
--     C_ToyBox/C_TransmogCollection.lua pour le protocole ACMSG_C_A_F /
--     ACMSG_C_R_F (ajout/retrait des favoris). Sans elles, string.format
--     recevait nil a la place d'un nombre -> crash a chaque clic sur
--     l'etoile "Favori" (montures/familiers/jouets/apparences/reliques).
-- ============================================================
if not CHAR_COLLECTION_MOUNT then CHAR_COLLECTION_MOUNT = 0 end
if not CHAR_COLLECTION_PET then CHAR_COLLECTION_PET = 1 end
if not CHAR_COLLECTION_APPEARANCE then CHAR_COLLECTION_APPEARANCE = 2 end
if not CHAR_COLLECTION_TOY then CHAR_COLLECTION_TOY = 3 end
if not CHAR_COLLECTION_HEIRLOOM then CHAR_COLLECTION_HEIRLOOM = 4 end
if not CHAR_COLLECTION_ILLUSION then CHAR_COLLECTION_ILLUSION = 5 end

-- ============================================================
-- 30) Chaines de localisation manquantes (tooltips Garde-robe)
-- ============================================================
if not WEAPON_ENCHANTMENT then WEAPON_ENCHANTMENT = "Enchantement d'arme" end
if not WARDROBE_NO_SEARCH then WARDROBE_NO_SEARCH = "Aucun resultat pour cette recherche" end

-- ============================================================
-- 31) FIRST_/LAST_TRANSMOG_COLLECTION_WEAPON_TYPE : constantes de
--     Constants.lua (Sirus), manquantes (meme famille que les
--     FIRST_/LAST_TRANSMOG_COLLECTION_SUB_CATEGORY ajoutees plus haut).
--     Sans elles, WardrobeItemsCollectionMixin:SetActiveSlot plantait avec
--     "'for' initial value must be a number" des qu'on cliquait sur un
--     emplacement d'arme dans l'onglet Garde-robe.
-- ============================================================
if not FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE then FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE = 12 end
if not LAST_TRANSMOG_COLLECTION_WEAPON_TYPE then LAST_TRANSMOG_COLLECTION_WEAPON_TYPE = 30 end

-- ============================================================
-- 32) SpellBook_GetSpellIndex : present dans Sirus\FrameXML\SpellBookFrame.lua,
--     absent de la version (plus ancienne) d'Universe. Utilise par
--     Custom_ToyBox.lua (ToySpellButton_OnDrag) pour glisser un jouet du
--     Codex vers une barre d'action. On ecrit une version autonome qui
--     n'utilise PAS C_SpellBook.GetSpellIDFromLink (absent d'Universe) mais
--     extrait l'ID directement du lien via un pattern, comme le reste du
--     client le fait deja ailleurs (ex. C_Item.GetItemIDFromString).
-- ============================================================
if not SpellBook_GetSpellIndex then
	function SpellBook_GetSpellIndex(spellID, bookType)
		if not spellID or not bookType then
			return;
		end

		for tabIndex = 1, GetNumSpellTabs() do
			local _, _, offset, numSpells = GetSpellTabInfo(tabIndex);

			for s = offset + 1, numSpells + offset do
				local spellIndex = (bookType == BOOKTYPE_PET) and s or (GetKnownSlotFromHighestRankSlot and GetKnownSlotFromHighestRankSlot(s) or s);
				local spellLink = GetSpellLink(spellIndex, bookType);

				if spellLink then
					local linkedSpellID = tonumber(spellLink:match("spell:(%d+)"));
					if linkedSpellID == spellID then
						return spellIndex;
					end
				end
			end
		end
	end
end


-- ============================================================
-- 34) Chaines de localisation manquantes (GlobalStrings.lua) utilisees par
--     C_TransmogCollection.lua / CollectionsUtil.lua pour les tooltips
--     d'apparences/illusions et les messages de collection. Confirmees
--     manquantes par un crash reel (COLLECTION_ILLUSION_HYPERLINK_FORMAT,
--     bad argument #1 to 'format') ; les autres sont ajoutees de maniere
--     proactive car utilisees dans le meme fichier / la meme fonction de
--     tooltip (CollectionsUtil.lua:SetAppearanceTooltip).
-- ============================================================
if not COLLECTION_ADD_FORMAT then COLLECTION_ADD_FORMAT = "Modele %s ajoute a votre collection." end
if not COLLECTION_REMOVE_FORMAT then COLLECTION_REMOVE_FORMAT = "Modele %s retire de votre collection." end
if not COLLECTION_ITEM_HYPERLINK_FORMAT then COLLECTION_ITEM_HYPERLINK_FORMAT = "|cffff80ff|Hcollection:2:%d|h[Modeles : %s]|h|r" end
if not COLLECTION_ILLUSION_ADD_FORMAT then COLLECTION_ILLUSION_ADD_FORMAT = "Illusion %s ajoutee a votre collection." end
if not COLLECTION_ILLUSION_HYPERLINK_FORMAT then COLLECTION_ILLUSION_HYPERLINK_FORMAT = "|cffff80ff|Hcollection:5:%d|h[Illusion : %s]|h|r" end
if not WARDROBE_TOOLTIP_BOSS_DROP_FORMAT then WARDROBE_TOOLTIP_BOSS_DROP_FORMAT = "Butin de boss : %1$s" end
if not WARDROBE_TOOLTIP_BOSS_DROP_FORMAT_WITH_DIFFICULTIES then WARDROBE_TOOLTIP_BOSS_DROP_FORMAT_WITH_DIFFICULTIES = "Butin de boss : %1$s (%2$s)" end
if not WARDROBE_TOOLTIP_CYCLE then WARDROBE_TOOLTIP_CYCLE = "Vous pouvez parcourir les objets avec la touche Tab." end
if not WARDROBE_TOOLTIP_ENCOUNTER_SOURCE then WARDROBE_TOOLTIP_ENCOUNTER_SOURCE = "%s (%s)" end
if not WARDROBE_TOOLTIP_TRANSMOGRIFIER then WARDROBE_TOOLTIP_TRANSMOGRIFIER = "Rendez-vous chez un transmogrificateur pour modifier l'apparence de votre equipement." end
if not WARDROBE_TOOLTIP_TRANSMOGRIFIER_CLICKABLE then WARDROBE_TOOLTIP_TRANSMOGRIFIER_CLICKABLE = "Clic droit pour choisir cet objet." end
if not WARDROBE_TOOLTIP_TRANSMOGRIFIER_UNUSABLE then WARDROBE_TOOLTIP_TRANSMOGRIFIER_UNUSABLE = "Les effets d'enchantement et les illusions ne s'affichent pas sur l'apparence d'arme selectionnee." end
if not WARDROBE_ALTERNATE_ITEMS then WARDROBE_ALTERNATE_ITEMS = "Autres objets debloquant cet emplacement :" end
if not RETRIEVING_ITEM_INFO then RETRIEVING_ITEM_INFO = "Recuperation des informations sur l'objet" end
if not PLAYER_LIST_DELIMITER then PLAYER_LIST_DELIMITER = ", " end

-- ============================================================
-- PATCH Collection (correction round 20) : constantes/icones manquantes,
-- decouvertes suite au crash CollectionsUtil.lua:479 "attempt to
-- concatenate global 'WARDROBE_TOOLTIP_CYCLE_ARROW_ICON' (a nil value)"
-- lors du survol d'un objet ayant plusieurs sources/illusions (SetIllusionTooltip).
-- Valeurs recuperees verbatim depuis Sirus\FrameXML\Constants.lua.
-- ============================================================
if not WARDROBE_TOOLTIP_CYCLE_ARROW_ICON then WARDROBE_TOOLTIP_CYCLE_ARROW_ICON = "|TInterface\\Transmogrify\\transmog-tooltip-arrow:12:11:-1:-1|t" end
if not WARDROBE_TOOLTIP_CYCLE_SPACER_ICON then WARDROBE_TOOLTIP_CYCLE_SPACER_ICON = "|TInterface\\Common\\spacer:12:11:-1:-1|t" end
if not ENCHANT_EMPTY_SLOT_FILEDATAID then ENCHANT_EMPTY_SLOT_FILEDATAID = "Interface\\Icons\\INV_Scroll_05" end
if not QUESTION_MARK_ICON then QUESTION_MARK_ICON = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK.BLP" end
-- NB : WARDROBE_OTHER_ITEMS est utilise par CollectionsUtil.lua mais n'est
-- DEFINI NULLE PART, meme cote Sirus (verifie) - c'est un bug latent, deja
-- present dans le code d'origine, mais inoffensif (tooltip:AddLine(nil,...)
-- ne plante pas, affiche juste une ligne vide). On en profite pour lui
-- donner une vraie traduction plutot que de reproduire le bug a l'identique.
if not WARDROBE_OTHER_ITEMS then WARDROBE_OTHER_ITEMS = "Autres objets utilisant cette apparence :" end

-- ============================================================
-- PATCH Collection (correction round 22) : crashes Reliques (Heirlooms).
-- Erreur 1 : Custom_HeirloomCollection.lua:694 "bad argument #1 to 'format'"
--   -> HEIRLOOMS_CLASS_FILTER_FORMAT / HEIRLOOMS_CLASS_SPEC_FILTER_FORMAT
--      manquantes. Valeurs verbatim depuis Sirus\FrameXML\GlobalStrings.lua.
-- ============================================================
if not HEIRLOOMS_CLASS_FILTER_FORMAT then HEIRLOOMS_CLASS_FILTER_FORMAT = "|c%s%s|r" end
if not HEIRLOOMS_CLASS_SPEC_FILTER_FORMAT then HEIRLOOMS_CLASS_SPEC_FILTER_FORMAT = "|c%s%s|r (%s)" end

-- ============================================================
-- PATCH Collection (correction round 22) : crash Reliques - Erreur 2
-- "Usage: C_Heirloom.SetClassAndSpecFilters(classID, specID)".
--
-- Diagnostic : Custom_HeirloomCollection.lua (menu deroulant "Classe" du
-- filtre Reliques) fait "local _, classDisplayName, classID = UnitClass(
-- "player")" pour recuperer le classID NUMERIQUE du joueur quand aucun
-- filtre de classe n'est actif. Sirus fournit un UnitClass() PERSONNALISE
-- (Utils\C_Unit.lua) qui ajoute ce classID numerique en 3e valeur de
-- retour (absent de l'UnitClass natif standard WotLK 3.3.5, qui ne renvoie
-- que 2 valeurs : nom localise + jeton anglais). Universe n'a jamais eu ce
-- correctif -> classID valait toujours nil -> le clic sur une specialisation
-- envoyait SetClassAndSpecFilters(nil, specID), rejete par la validation
-- native (qui exige deux NOMBRES).
--
-- On porte le meme correctif que Sirus, applique GLOBALEMENT (comme Sirus
-- le fait lui-meme) : les 2 valeurs d'origine restent inchangees en tete de
-- liste, on ajoute juste classID/classFlag en 3e/4e position, donc aucun
-- appelant existant (qui ne lit que les 2 premieres valeurs) n'est impacte.
-- Repose sur S_CLASS_SORT_ORDER, deja present cote Universe
-- (SharedXML\SharedConstants.lua).
-- ============================================================
do
	local NativeUnitClass = UnitClass

	_G.UnitClass = function(unit)
		local className, classToken = NativeUnitClass(unit)

		local classID, classFlag
		if S_CLASS_SORT_ORDER and classToken then
			for id, classInfo in pairs(S_CLASS_SORT_ORDER) do
				if classInfo[2] == classToken then
					classID = id
					classFlag = classInfo[1]
					break
				end
			end
		end

		return className, classToken, classID, classFlag
	end
end

-- ============================================================
-- PATCH Collection (correction round 23) : crash Reliques - Erreur 3
-- "bad argument #2 to 'format' (string expected, got nil)" dans
-- UpdateClassFilterDropDownText -> RAID_CLASS_COLORS[classFile].colorStr.
--
-- Diagnostic : la table GLOBALE RAID_CLASS_COLORS d'Universe
-- (FrameXML\Constants.lua) ne contient que r/g/b par classe, JAMAIS de champ
-- "colorStr" precalcule (contrairement a Sirus). Universe a bien une version
-- AVEC colorStr, mais elle est LOCALE a SharedXML\Util.lua (donc invisible
-- ailleurs) et sert a un usage interne different. On complete donc la table
-- GLOBALE en ajoutant colorStr a chaque entree, calcule depuis r/g/b.
-- ============================================================
if RAID_CLASS_COLORS then
	for classFile, colorInfo in pairs(RAID_CLASS_COLORS) do
		if type(colorInfo) == "table" and not colorInfo.colorStr then
			colorInfo.colorStr = string.format("ff%02x%02x%02x", (colorInfo.r or 1) * 255, (colorInfo.g or 1) * 255, (colorInfo.b or 1) * 255)
		end
	end
end

-- ============================================================
-- PATCH Collection (correction round 30) : crash tooltip Garde-robe -
-- "attempt to index local 'nameColor' (a nil value)" / "attempt to index
-- field '?' (a nil value)" dans CollectionsUtil.lua:149/267
-- (GetAppearanceNameTextAndColor / SetAppearanceTooltip).
--
-- Diagnostic : ce code (porte de Sirus) attend ITEM_QUALITY_COLORS[quality].color,
-- un objet Color avec :GetRGB(). La table native d'Universe (FrameXML\UIParent.lua)
-- ne construit que r/g/b/hex (pas de champ .color), et ne couvre QUE les qualites
-- -1 a 6 : la qualite 7 (Reliques/Heirloom, utilisee par certaines apparences de
-- Garde-robe) n'existe pas du tout dans la table. Resultat : le tooltip plante des
-- qu'on survole un objet de qualite 7, et pour les qualites 0-6 le champ .color
-- manquant renvoie nil silencieusement -> crash un peu plus loin sur nameColor:GetRGB().
-- Ce crash, survenant PENDANT UpdateItems (survol automatique de la grille), interrompt
-- le rendu du reste de la page -> cases noires et modeles manquants en cascade.
-- On complete donc la table existante avec un objet Color, et on ajoute l'entree 7
-- manquante (couleur Reliques/Heirloom classique : bleu clair).
-- ============================================================
if ITEM_QUALITY_COLORS and CreateColor then
	for quality, info in pairs(ITEM_QUALITY_COLORS) do
		if type(info) == "table" and not info.color then
			info.color = CreateColor(info.r or 1, info.g or 1, info.b or 1)
		end
	end
	if not ITEM_QUALITY_COLORS[7] then
		ITEM_QUALITY_COLORS[7] = { r = 0, g = 0.8, b = 1, hex = "|cff00ccff" }
	end
	if not ITEM_QUALITY_COLORS[7].color then
		ITEM_QUALITY_COLORS[7].color = CreateColor(ITEM_QUALITY_COLORS[7].r or 0, ITEM_QUALITY_COLORS[7].g or 0.8, ITEM_QUALITY_COLORS[7].b or 1)
	end
end

-- ============================================================
-- PATCH Collection (correction round 24) : crash Reliques - Erreur 4
-- "attempt to call global 'GetSpecializationNameForSpecID' (a nil value)".
-- Fonction Sirus manquante cote Universe (Utils\C_Talent.lua). Universe a
-- deja la table de donnees dont elle a besoin (S_CALSS_SPECIALIZATION_DATA,
-- SharedXML\SharedConstants.lua) - seule la fonction d'acces manquait.
-- Portee verbatim depuis Sirus.
-- ============================================================
if not GetSpecializationNameForSpecID then
	function GetSpecializationNameForSpecID(specID)
		if type(specID) ~= "number" then
			return ""
		end

		if S_CALSS_SPECIALIZATION_DATA then
			for classID, specList in pairs(S_CALSS_SPECIALIZATION_DATA) do
				for specIndex, specInfo in ipairs(specList) do
					if specInfo[1] == specID then
						return specInfo[2]
					end
				end
			end
		end

		return ""
	end
end

-- ============================================================
-- PATCH Collection (correction round 89) : crash Garde-robe -
-- "attempt to call global 'StringSplitEx' (a nil value)" dans
-- Utils\C_TransmogCollection.lua:2131 (handler ASMSG_C_I_GET_MODELS,
-- reponse du nouveau script Eluna de suivi des apparences Transmog
-- collectees). StringSplitEx est une fonction utilitaire Sirus
-- (SharedXML\StringUtil.lua) jamais portee cote Universe - seul son
-- fichier source entier n'a pas ete copie, alors que plusieurs Utils
-- Sirus l'appellent comme si elle etait un global toujours disponible.
-- Portee verbatim depuis Sirus (SharedXML/StringUtil.lua) : simple
-- enveloppe autour de string.split (deja utilise avec succes ailleurs
-- dans ce client, y compris dans C_TransmogCollection.lua lui-meme via
-- strsplit) qui retire d'abord un delimiteur final eventuel pour eviter
-- un dernier morceau vide parasite.
-- ============================================================
if not StringSplitEx then
	function StringSplitEx(delimiter, str, pieces)
		str = string.gsub(str, strconcat(delimiter, "$"), "")
		if str ~= "" then
			return string.split(delimiter, str, pieces)
		end
	end
end

-- ============================================================
-- PATCH Collection (correction round 90) : crash Garde-robe -
-- "attempt to call global 'AddChatTyppedMessage' (a nil value)" dans
-- Utils\C_TransmogCollection.lua:2199 (message de chat "Modele ajoute a
-- votre collection" declenche par ASMSG_C_I_ADD_MODEL, lui-meme
-- desormais envoye par le script Eluna de suivi des apparences Transmog
-- des qu'un joueur equipe un nouvel objet - voir round 88/89). Meme
-- classe de bug que StringSplitEx (round 89) : AddChatTyppedMessage est
-- une fonction utilitaire Sirus (FrameXML\ChatFrame.lua) jamais portee
-- cote Universe, appelee comme un global toujours disponible par
-- plusieurs Utils Sirus (C_Heirloom.lua, C_ToyBox.lua,
-- C_TransmogCollection.lua x3).
-- Portee verbatim depuis Sirus (FrameXML/ChatFrame.lua). Ses dependances
-- (ChatTypeInfo, CHAT_FRAMES, SendSystemMessage, tIndexOf) existent
-- deja toutes dans le client de base Universe - seule cette fonction
-- elle-meme manquait.
-- ============================================================
if not AddChatTyppedMessage then
	function AddChatTyppedMessage(messageType, message)
		if messageType == "SYSTEM" then
			SendSystemMessage(message)
			return
		end

		local info = ChatTypeInfo[messageType];
		if not info then
			error(string.format("AddChatTyppedMessage: unknown messageType (%s)", messageType), 2)
			return;
		end

		for _, chatFrameName in ipairs(CHAT_FRAMES) do
			local frame = _G[chatFrameName];
			if tIndexOf(frame.messageTypeList, messageType) then
				frame:AddMessage(message, info.r or 1, info.g or 1, info.b or 0, info.id or 1)
			end
		end
	end
end
