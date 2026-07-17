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
DIAGv26_CP13 = true;
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
DIAGv26_CP41 = true;
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
DIAGv26_CP64 = true;
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
DIAGv26_CP102 = true;
if not FireCustomClientEvent then
	function FireCustomClientEvent(event, ...)
		local listeners = REGISTERED_CUSTOM_EVENTS[event]
		if not listeners then
			return
		end
		local frame = securecall(next, listeners, nil)
		while frame do
			-- FIX ROUND TRANSMOG-30 : cette fonction ne savait dispatcher
			-- l'evenement QUE vers un frame ayant un vrai script XML
			-- <OnEvent function="..."/> (recupere via frame:GetScript("OnEvent")).
			-- Or WardrobeItemsCollectionMixin (la grille PARTAGEE entre l'onglet
			-- "Garde-robe" et l'onglet "Transmogrification", cf.
			-- Custom_Wardrobe.lua) est du code retail porte tel quel : il
			-- definit une METHODE Lua ":OnEvent(event, ...)" sur le mixin, sans
			-- jamais appeler self:SetScript("OnEvent", ...) ni declarer de
			-- <OnEvent> XML -- a la retail, le moteur du jeu appelle
			-- automatiquement self:OnEvent(...) pour n'importe quel frame qui a
			-- une methode de ce nom, meme sans script explicite. Notre moteur
			-- WotLK n'a pas ce comportement, donc frame:GetScript("OnEvent")
			-- renvoyait toujours nil pour ce frame precis : TRANSMOGRIFY_UPDATE
			-- etait fidelement envoye (SelectVisual -> C_Transmog.SetPending ->
			-- FireCustomClientEvent) mais JAMAIS RECU, donc WardrobeItemsCollectionMixin:
			-- UpdateItems() (qui redessine la bordure rose de selection) ne se
			-- declenchait jamais tout de suite apres un clic -- ni dans
			-- Garde-robe ni dans Transmogrification. La selection etait bien
			-- enregistree (d'ou l'effet "cache" rapporte), mais ne se voyait
			-- qu'apres un OnShow complet (changer d'onglet et revenir), qui lui
			-- force un rafraichissement independant de ce mecanisme. On ajoute
			-- donc un repli : si le frame n'a pas de script OnEvent natif mais
			-- possede une methode Lua ":OnEvent", on l'appelle directement.
			local handler = frame.GetScript and frame:GetScript("OnEvent")
			if handler then
				securecall(handler, frame, event, ...)
			elseif type(frame.OnEvent) == "function" then
				securecall(frame.OnEvent, frame, event, ...)
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
DIAGv26_CP133 = true;
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
DIAGv26_CP149 = true;
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

DIAGv26_CP172 = true;
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
DIAGv26_CP192 = true;
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
DIAGv26_CP223 = true;
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
DIAGv26_CP240 = true;
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
DIAGv26_CP259 = true;
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
DIAGv26_CP285 = true;
if not UIResettableDropdownButtonMixin then
	UIResettableDropdownButtonMixin = {}

	function UIResettableDropdownButtonMixin:OnLoad()
		self.ResetButton:SetScript("OnClick", function(button, buttonName, down)
			if self.resetFunction then
				-- Fix Round Transmog-10 : pcall defensif. self.resetFunction
				-- (SetDefaultFilters cote Montures/Garde-robe/etc.) peut
				-- planter sur une CVar non enregistree (cf. le shim
				-- CVar generique plus haut) ; meme avec ce shim, on evite
				-- qu'une erreur imprevue empeche le bouton de se cacher.
				local ok, err = pcall(self.resetFunction)
				if not ok then
					geterrorhandler()(err)
				end
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
DIAGv26_CP315 = true;
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
DIAGv26_CP330 = true;
if not SKILL_NAME_FIST_WEAPONS then SKILL_NAME_FIST_WEAPONS = "Armes de pugilat" end
if not SKILL_NAME_FISHING then SKILL_NAME_FISHING = "Peche" end
if not SKILL_NAME_PLATE_MAIL then SKILL_NAME_PLATE_MAIL = "Plaques" end
if not SKILL_NAME_MAIL then SKILL_NAME_MAIL = "Mailles" end
if not SKILL_NAME_LEATHER then SKILL_NAME_LEATHER = "Cuir" end
if not SKILL_NAME_CLOTH then SKILL_NAME_CLOTH = "Tissu" end

-- PATCH Collection (round 99, corrige round 100) : ITEM_SUB_CLASS_4_X
-- (sous-categories d'armure utilisees par le menu deroulant de filtre
-- Garde-robe, cf. C_TransmogCollection.lua ligne ~117 :
-- subCategories[subCategoryID].name = _G["ITEM_SUB_CLASS_4_"..subCategoryID]).
-- Round 99 n'avait force que l'index 3 (Mailles) en se basant sur la
-- position du "???" dans la premiere capture d'ecran -- mauvaise hypothese :
-- la seconde capture (items decoratifs/evenementiels : bonnet de pere Noel,
-- lunettes, effet de flamme) montre que le "???" restant est en realite
-- l'index 5 ("Decoratif" cote source Sirus russe), pas l'index 3.
-- Plutot que re-deviner, on force desormais explicitement TOUTE la serie
-- 0-6 (valeurs FR officielles Blizzard) pour eliminer tout residu russe,
-- quel que soit l'index reellement affiche pour un emplacement donne.
DIAGv26_CP349 = true;
ITEM_SUB_CLASS_4_0 = "Divers";
ITEM_SUB_CLASS_4_1 = "Tissu";
ITEM_SUB_CLASS_4_2 = "Cuir";
ITEM_SUB_CLASS_4_3 = "Mailles";
ITEM_SUB_CLASS_4_4 = "Plaques";
ITEM_SUB_CLASS_4_5 = "Cosmétique";
ITEM_SUB_CLASS_4_6 = "Boucliers";

-- ============================================================
-- 11) C_SpellBook.FilterOutSpellLearn : utilise par C_TransmogCollection.lua
--     (BuildIllusions) pour ne pas afficher de popup "sort appris" pour les
--     sorts d'illusions. Le vrai C_SpellBook.lua de Sirus depend de
--     FLYOUT_STORAGE/C_GlobalStorage non portes ici ; comme cette fonction ne
--     sert qu'a du filtrage cosmetique de popups, un stub inoffensif suffit.
-- ============================================================
DIAGv26_CP364 = true;
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
DIAGv26_CP381 = true;
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
DIAGv26_CP397 = true;
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
DIAGv26_CP415 = true;
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

DIAGv26_CP447 = true;
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
DIAGv26_CP479 = true;
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
DIAGv26_CP494 = true;
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
DIAGv26_CP509 = true;
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
DIAGv26_CP534 = true;
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
DIAGv26_CP556 = true;
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
DIAGv26_CP575 = true;
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
DIAGv26_CP593 = true;
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
DIAGv26_CP608 = true;
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

DIAGv26_CP624 = true;
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

DIAGv26_CP639 = true;
Enum = Enum or {}
if not Enum.TransmogModification then
	Enum.TransmogModification = {Main = 0, Secondary = 1}
end
if not Enum.TransmogPendingType then
	Enum.TransmogPendingType = {Apply = 0, Revert = 1, ToggleOn = 2, ToggleOff = 3}
end

-- ============================================================
-- 24) C_Transmog : implementation reelle (ROUND Transmog-5).
--
--     L'ancien stub minimal (ci-dessous en commentaire pour memoire)
--     rendait le Codex parcourable mais le bouton "Appliquer" totalement
--     inoperant : SetPending/GetPending/GetSlotInfo/ApplyAllPending ne
--     faisaient jamais rien de reel. On implemente maintenant le vrai
--     mecanisme, en reutilisant EXACTEMENT la meme astuce que
--     Transmog/TransmogrifierServer.lua (systeme AIO independant, deja
--     fonctionnel sur Universe depuis longtemps) : ecrire directement les
--     champs PLAYER_VISIBLE_ITEM_x_ENTRYID du joueur cote SERVEUR
--     (PLAYER_VISIBLE_ITEM_1_ENTRYID = 283 pour le slot Tete, +2 par slot
--     suivant) -- un pur artifice protocole qui change l'apparence SANS
--     toucher a l'objet reellement equipe. Aucune magie cote client requise.
--
--     Protocole (addon-message, meme famille ACMSG_*/ASMSG_* que
--     Utils\C_TransmogCollection.lua) :
--       ACMSG_TRANSMOG_APPLY   "slot:itemEntry"   client -> serveur
--                              (itemEntry=0 = revert/retirer la transmog)
--       ASMSG_TRANSMOG_APPLIED "slot:itemEntry"   serveur -> client (confirmation)
--       ASMSG_TRANSMOG_SYNC    "slot:item,slot:item,..." serveur -> client (au login)
--       ASMSG_TRANSMOG_ERROR   texte              serveur -> client (refus)
--     Cote serveur : voir AzuCollections/AzuCollection_TransmogApply_v1.lua.
--     Necessite AzuCollection_TransmogTracker_v2.lua (deja installe) : on ne
--     peut appliquer qu'une apparence deja "collectee" (deja portee au moins
--     une fois), meme principe que le Garde-robe retail.
-- ============================================================
--- Table de correspondance code-erreur -> tag utilisee par
--- TransmogSlotButtonMixin:Update (Custom_Wardrobe.lua:565) pour decider
--- quelle icone afficher quand un emplacement ne peut pas etre
--- transmogrifie. Notre C_Transmog.GetSlotInfo (plus bas) ne renvoie
--- actuellement qu'un seul code (1 = rien d'equipe dans cet emplacement),
--- mappe sur le tag retail "NO_ITEM" (fait afficher le contour vide de
--- l'emplacement plutot qu'une icone noire/nil). Global absent = crash
--- ("attempt to index global 'TRANSMOG_INVALID_CODES' (a nil value)"),
--- rapporte plusieurs fois par l'utilisateur (Round Transmog-7).
DIAGv26_CP683 = true;
if not TRANSMOG_INVALID_CODES then
	TRANSMOG_INVALID_CODES = {
		[1] = "NO_ITEM",
	}
end

--- Fix Round Transmog-8 : _AnimateTexCoords manquant (crash en boucle sur
--- OnUpdate, 727 occurences rapportees) -- utilise par les 2 "Ants" (halo
--- anime violet autour d'un emplacement en attente d'application,
--- Custom_Wardrobe.xml, PurpleIconAlertAnts) via
--- _AnimateTexCoords(self.Ants, 256, 256, 48, 48, 22, elapsed, 0.01).
--- Polyfill standard retail (feuille de sprite en grille, avance d'une frame
--- toutes les <throttle> secondes).
if not _AnimateTexCoords then
	function _AnimateTexCoords(texture, width, height, frameWidth, frameHeight, numFrames, elapsed, throttle, numColumns)
		throttle = throttle or 0.1;
		numColumns = numColumns or numFrames;

		texture.transmogAnimElapsed = (texture.transmogAnimElapsed or 0) + elapsed;
		if texture.transmogAnimElapsed >= throttle then
			local framesElapsed = floor(texture.transmogAnimElapsed / throttle);
			texture.transmogAnimElapsed = texture.transmogAnimElapsed - (throttle * framesElapsed);
			local currentFrame = texture.transmogAnimCurrentFrame or 1;
			currentFrame = ((currentFrame + framesElapsed - 1) % numFrames) + 1;
			texture.transmogAnimCurrentFrame = currentFrame;

			local column = (currentFrame - 1) % numColumns;
			local row = floor((currentFrame - 1) / numColumns);

			local left = column * frameWidth / width;
			local right = (column + 1) * frameWidth / width;
			local top = row * frameHeight / height;
			local bottom = (row + 1) * frameHeight / height;

			texture:SetTexCoord(left, right, top, bottom);
		end
	end
end

DIAGv26_CP722 = true;
do
	C_Transmog = C_Transmog or {}
	-- FIX ROUND TRANSMOG-24 (cause racine trouvee via bissection /diagcp) :
	-- C_Item n'est jamais cree par ce fichier lui-meme, seulement utilise
	-- (ligne "if not C_Item.GetBaseItemTransmogInfo then" un peu plus bas).
	-- Sur ce client, C_Item n'existe pas encore a ce stade precis du
	-- chargement (le vrai C_Item, avec GetItemInfo etc., est cree par un
	-- fichier qui charge APRES Collection_Compat.lua) -- d'ou
	-- "attempt to index a nil value (global 'C_Item')", qui interrompait
	-- tout le reste du fichier (EventHandler:ASMSG_TRANSMOG_*, C_Talent,
	-- PET_TYPE_SUFFIX, COLLECTION_ITEM_HYPERLINK_FORMAT, StringSplitEx,
	-- GetSlotInfo, /ccheck, etc.). Meme idiome que C_Transmog ci-dessus :
	-- si C_Item existe deja, on ne touche a rien ; sinon on cree une table
	-- vide que le vrai fichier C_Item (charge plus tard) completera lui
	-- normalement via le meme idiome "C_Item = C_Item or {}".
	C_Item = C_Item or {}

	local _pending = {};	-- [slotID] = {type = Enum.TransmogPendingType.*, transmogID = itemID}
	local _applied = {};	-- [slotID] = itemID actuellement applique (nil = aucun, objet de base affiche)

	--- IMPORTANT (fix Round Transmog-7) : dans le systeme retail original,
	--- cette fonction indique si le joueur est physiquement pres du PNJ
	--- Transmogrificateur ; sinon la plupart des actions de l'UI -- dont la
	--- SELECTION d'un objet dans la grille (WardrobeItemsCollectionMixin:
	--- SelectVisual) -- sont des no-op. Notre systeme est un journal en
	--- libre-service (AzuCollections), sans PNJ requis : on considere donc
	--- le joueur "au transmogrificateur" des que la fenetre
	--- WardrobeTransmogFrame est affichee. Avant ce fix, IsAtTransmogNPC
	--- renvoyait toujours false, ce qui empechait tout clic sur un objet de
	--- la grille de faire quoi que ce soit (symptome rapporte : "je clique
	--- sur l'item, rien ne se passe, ca ne le selectionne meme pas").
	if not C_Transmog.IsAtTransmogNPC then
		function C_Transmog.IsAtTransmogNPC()
			return WardrobeTransmogFrame ~= nil and WardrobeTransmogFrame:IsShown();
		end
	end
	if not C_Transmog.Close then
		function C_Transmog.Close() end
	end
	if not C_Transmog.GetSlotEffectiveCategory then
		function C_Transmog.GetSlotEffectiveCategory(transmogLocation) return nil, nil end
	end
	if not C_Transmog.LoadOutfit then
		function C_Transmog.LoadOutfit(outfitID) end
	end
	--- Fix Round Transmog-8 : cette fonction etait un stub renvoyant toujours
	--- des zeros. Or TransmogUtil.GetInfoForEquippedSlot (TransmogUtil.lua)
	--- s'appuie DESSUS pour calculer le "selectedSourceID" transmis a
	--- WardrobeItemsCollectionMixin:GoToSourceID au clic sur un emplacement
	--- (TransmogFrameMixin:SelectSlotButton, Custom_Wardrobe.lua) : avec des
	--- zeros partout, GoToSourceID n'obtenait jamais de visualID valide et
	--- n'appelait donc jamais SetActiveSlot -- la grille ne changeait jamais
	--- de categorie/contenu au clic sur un emplacement (symptome rapporte :
	--- "je clique sur torse, rien ne s'affiche, seul le menu Tissu/Cuir/...
	--- fonctionne"). Dans notre systeme, "sourceID" == l'itemID lui-meme
	--- (verifie dans Utils/C_TransmogCollection.lua : GetAppearanceSourceInfo
	--- traite son parametre comme un itemID direct, pas d'ID de source
	--- separe). On calcule donc reellement : la base = l'objet equipe, et
	--- l'applique/en-attente a partir de nos tables _applied/_pending.
	if not C_Transmog.GetSlotVisualInfo then
		function C_Transmog.GetSlotVisualInfo(transmogLocation)
			local slotID = transmogLocation:GetSlotID();

			local baseSourceID = GetInventoryItemID("player", slotID) or 0;
			local baseVisualID = 0;
			if baseSourceID ~= 0 and C_TransmogCollection and C_TransmogCollection.GetAppearanceSourceInfo then
				local _, _, visID = C_TransmogCollection.GetAppearanceSourceInfo(baseSourceID);
				baseVisualID = visID or 0;
			end

			local appliedItemID = _applied[slotID];
			local appliedSourceID = NO_TRANSMOG_SOURCE_ID or 0;
			local appliedVisualID = 0;
			if appliedItemID and appliedItemID ~= 0 then
				appliedSourceID = appliedItemID;
				if C_TransmogCollection and C_TransmogCollection.GetAppearanceSourceInfo then
					local _, _, visID = C_TransmogCollection.GetAppearanceSourceInfo(appliedItemID);
					appliedVisualID = visID or 0;
				end
			end

			local pending = _pending[slotID];
			local pendingSourceID = REMOVE_TRANSMOG_ID or 0;
			local pendingVisualID = 0;
			local hasPendingUndo = false;
			if pending then
				if pending.type == Enum.TransmogPendingType.Apply then
					pendingSourceID = pending.transmogID or 0;
					if C_TransmogCollection and C_TransmogCollection.GetAppearanceSourceInfo then
						local _, _, visID = C_TransmogCollection.GetAppearanceSourceInfo(pendingSourceID);
						pendingVisualID = visID or 0;
					end
				elseif pending.type == Enum.TransmogPendingType.Revert then
					hasPendingUndo = true;
				end
			end

			return baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo, nil, nil;
		end
	end
	if not C_Transmog.GetSlotUseError then
		function C_Transmog.GetSlotUseError(transmogLocation) return nil, nil end
	end
	if not C_Transmog.GetInventoryTransmogInfo then
		function C_Transmog.GetInventoryTransmogInfo(unit, slotID) return nil end
	end

	--- Fix Round Transmog-8 : GetBaseItemTransmogInfo/GetAppliedItemTransmogInfo
	--- etaient des stubs (definis dans Collection_Compat_Late.lua, sous garde
	--- "if not X then" -- notre definition ICI charge plus tot, cf.
	--- FrameXML.toc : Collection_Compat.xml avant Collection_Compat_Late.lua
	--- -- donc notre version prend le dessus). Utilisees par
	--- TransmogSlotButtonMixin:GetEffectiveTransmogID (Custom_Wardrobe.lua)
	--- pour decider quelle apparence habiller sur le mannequin 3D.
	-- FIX ROUND TRANSMOG-47 (cause racine reelle du point 2, prouvee par la
	-- trace /tmodeltrace du round 46) : ces 2 fonctions etaient definies ici
	-- SOUS GARDE "if not C_Item.XXX then", en partant du principe que ce
	-- fichier charge forcement avant Collection_Compat_Late.lua (qui definit
	-- les memes noms, sous garde identique, comme simples stubs -- pour
	-- GetAppliedItemTransmogInfo son stub renvoie TOUJOURS {appearanceID=0},
	-- ignorant totalement _applied). La trace du round 46 a prouve que
	-- _applied[slotID] contenait bien le bon itemID juste apres application,
	-- mais que GetEffectiveTransmogID() calculait quand meme l'objet de base
	-- -- la seule explication est que c'est le STUB de Collection_Compat_Late
	-- qui gagnait dans les faits, pas notre version ici, quel que soit
	-- l'ordre suppose du FrameXML.toc. On retire donc la garde : ces 2
	-- fonctions sont maintenant TOUJOURS (re)definies ici, ce qui garantit
	-- que notre version -- la seule a vraiment lire _applied -- l'emporte
	-- systematiquement, independamment de l'ordre de chargement reel.
	function C_Item.GetBaseItemTransmogInfo(itemLocation)
		local itemID = 0;
		if itemLocation and itemLocation.IsEquipmentSlot and itemLocation:IsEquipmentSlot() then
			itemID = GetInventoryItemID("player", itemLocation:GetEquipmentSlot()) or 0;
		end
		return { appearanceID = itemID, illusionID = 0 };
	end
	function C_Item.GetAppliedItemTransmogInfo(itemLocation)
		local appliedItemID = 0;
		if itemLocation and itemLocation.IsEquipmentSlot and itemLocation:IsEquipmentSlot() then
			appliedItemID = _applied[itemLocation:GetEquipmentSlot()] or 0;
		end
		return { appearanceID = appliedItemID, illusionID = 0 };
	end

	-- FIX ROUND TRANSMOG-35 : diagnostic (/tclickdebug, rounds 31-34) confirme
	-- que ni WardrobeCollectionFrame.ItemsCollectionFrame ni WardrobeTransmogFrame
	-- ne se rafraichissent en direct suite a TRANSMOGRIFY_UPDATE, MEME apres le
	-- fix round 30 -- les deux ont bien un script OnEvent natif herite d'un
	-- template (GetScript("OnEvent")=true chez les deux), mais ce script herite
	-- n'appelle visiblement pas notre methode ":OnEvent" personnalisee (probable
	-- template partage generique, hors de ce patch, qu'on ne peut pas inspecter
	-- ni modifier surement). Plutot que de continuer a deviner sur un mecanisme
	-- qu'on ne maitrise pas entierement, on rafraichit desormais DIRECTEMENT et
	-- explicitement les 2 frames connues juste apres avoir change _pending,
	-- sans dependre du tout de FireCustomClientEvent/OnEvent pour ce cas precis
	-- (celui-ci reste appele en plus, au cas ou d'autres listeners en beneficient).
	local function RefreshTransmogDisplaysNow(transmogLocation)
		if WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame.UpdateItems then
			pcall(WardrobeCollectionFrame.ItemsCollectionFrame.UpdateItems, WardrobeCollectionFrame.ItemsCollectionFrame);
		end
		-- FIX ROUND TRANSMOG-36 (historique) : le round 35 appelait aussi
		-- WardrobeTransmogFrame:MarkDirty(), qui programmait un
		-- TransmogFrameMixin:Update() COMPLET (tous les emplacements) au
		-- prochain OnUpdate, a CHAQUE clic sur la grille -- le mannequin a
		-- fini par disparaitre completement. D'ou la regle depuis : ne
		-- jamais redresser TOUS les emplacements a chaque clic.
		--
		-- FIX ROUND TRANSMOG-58 : l'utilisateur demande maintenant un vrai
		-- apercu en direct (avant de cliquer Appliquer), ce qui est
		-- raisonnable et n'est PAS la meme chose que le round 36 evitait.
		-- On ne redresse ici QUE l'unique emplacement concerne par ce clic
		-- precis (transmogLocation, passe par SetPending/ClearPending),
		-- jamais toute la boucle -- donc pas de risque de reproduire le bug
		-- du round 36. RefreshItemModel() est deja fiable pour un objet en
		-- attente (pendingInfo.transmogID est renvoye directement par
		-- GetEffectiveTransmogID, sans passer par le calcul "applique/base"
		-- qui, lui, est bugue -- voir rounds 55-57). Widget existant reutilise
		-- (pas de RecreateModelFrame ici : trop lourd pour un simple aperçu
		-- au clic, et inutile puisqu'on ne fait que TryOn un seul objet).
		if transmogLocation and WardrobeTransmogFrame and WardrobeTransmogFrame.GetSlotButton then
			local slotButton = WardrobeTransmogFrame:GetSlotButton(transmogLocation);
			if slotButton and slotButton.RefreshItemModel then
				pcall(slotButton.RefreshItemModel, slotButton);
			end
		end
		if WardrobeTransmogFrame and WardrobeTransmogFrame.UpdateApplyButton then
			pcall(WardrobeTransmogFrame.UpdateApplyButton, WardrobeTransmogFrame);
		end
	end

	function C_Transmog.SetPending(transmogLocation, pendingInfo)
		_pending[transmogLocation:GetSlotID()] = pendingInfo;
		FireCustomClientEvent("TRANSMOGRIFY_UPDATE");
		RefreshTransmogDisplaysNow(transmogLocation);
	end

	function C_Transmog.GetPending(transmogLocation)
		return _pending[transmogLocation:GetSlotID()];
	end

	-- FIX ROUND TRANSMOG-58 : accesseur direct pour _applied, en
	-- contournant completement la chaine ItemLocation/GetRelevantTransmogID/
	-- C_Item.GetAppliedItemTransmogInfo utilisee jusqu'ici par
	-- TransmogSlotButtonMixin:GetEffectiveTransmogID(). Cette chaine s'est
	-- averee peu fiable (confirme par la trace /tmodeltrace du round 55 :
	-- meme quand _applied[slot] contient la bonne valeur, la resolution
	-- via cette chaine retombait systematiquement sur l'objet de base).
	-- Plutot que de continuer a deviner ou exactement ca casse dans cette
	-- indirection (ItemLocation natif non modifiable par ce patch),
	-- GetEffectiveTransmogID lit desormais _applied[slotID] directement via
	-- cet accesseur -- la meme table que C_Transmog.DebugGetRawState lit
	-- deja, dont la fiabilite est confirmee par toutes les traces
	-- precedentes.
	function C_Transmog.GetAppliedTransmogID(slotID)
		return (slotID and _applied[slotID]) or 0;
	end

	-- FIX ROUND TRANSMOG-46 (diagnostic uniquement, aucun changement de
	-- comportement) : _pending et _applied sont des upvalues locales a ce
	-- bloc "do...end", invisibles depuis Custom_Wardrobe.lua. On expose ici
	-- un acces en lecture seule pour que /tmodeltrace puisse afficher leur
	-- contenu REEL au moment precis ou RefreshItemModel() s'execute, afin de
	-- determiner si le probleme vient de l'ecriture (ASMSG_TRANSMOG_APPLIED
	-- ne met pas _applied a jour comme attendu) ou de la lecture
	-- (GetEffectiveTransmogID ne consulte pas la bonne valeur).
	function C_Transmog.DebugGetRawState(slotID)
		local pending = _pending[slotID];
		local pendingDesc = "nil";
		if pending then
			pendingDesc = string.format("type=%s transmogID=%s", tostring(pending.type), tostring(pending.transmogID));
		end
		return tostring(_applied[slotID]), pendingDesc;
	end

	function C_Transmog.ClearPending(transmogLocation)
		_pending[transmogLocation:GetSlotID()] = nil;
		FireCustomClientEvent("TRANSMOGRIFY_UPDATE");
		RefreshTransmogDisplaysNow(transmogLocation);
	end

	--- Cout de la transmogrification (fix Round Transmog-7) : 500000 cuivre
	--- (50 pieces d'or) par emplacement APPLIQUE, exactement la meme valeur
	--- que TRANSMOG_COST dans Transmog/TransmogrifierServer.lua (le systeme
	--- AIO deja fonctionnel), pour rester coherent entre les deux systemes.
	--- Annuler une transmogrification (Revert) reste gratuit, comme dans
	--- TransmogrifierServer.lua (ResetSlot/ResetAll). Le cout reel est
	--- verifie et preleve cote serveur dans
	--- AzuCollection_TransmogApply_v1.lua ; ce calcul cote client ne sert
	--- qu'a l'affichage/activation du bouton Appliquer.
	local TRANSMOG_COST_PER_SLOT = 500000;

	function C_Transmog.GetApplyCost()
		local hasPending, cost = false, 0;
		for _, pending in pairs(_pending) do
			hasPending = true;
			if pending.type == Enum.TransmogPendingType.Apply then
				cost = cost + TRANSMOG_COST_PER_SLOT;
			end
		end
		if not hasPending then
			return nil;
		end
		return cost;
	end

	function C_Transmog.GetApplyWarnings()
		return {};
	end

	function C_Transmog.GetSlotInfo(transmogLocation)
		local slotID = transmogLocation:GetSlotID();
		local pending = _pending[slotID];
		local appliedID = _applied[slotID];
		local equippedID = GetInventoryItemID("player", slotID);

		local isTransmogrified = appliedID ~= nil and appliedID ~= 0;
		local hasPending = pending ~= nil;
		local hasUndo = hasPending and pending.type == Enum.TransmogPendingType.Revert;
		-- FIX ROUND TRANSMOG-28 (mode libre demande par l'utilisateur) : on
		-- exigeait un objet reellement equipe dans l'emplacement pour pouvoir
		-- transmogrifier (canTransmogrify = equippedID ~= nil). Mode libre =
		-- sans restriction, meme un emplacement vide doit pouvoir recevoir une
		-- apparence. Note honnete : le mecanisme d'application
		-- (PLAYER_VISIBLE_ITEM_x_ENTRYID, cote serveur) ne fait que RHABILLER
		-- visuellement un objet deja equipe -- sur un emplacement VRAIMENT
		-- vide (aucun objet du tout), le moteur du jeu n'a simplement aucune
		-- geometrie sur laquelle appliquer l'apparence. Ce fix retire donc le
		-- blocage logiciel (le clic/la selection fonctionnera desormais), mais
		-- si l'emplacement est reellement vide le rendu visuel pourrait ne
		-- rien montrer quand meme -- limite du moteur, pas du script.
		local canTransmogrify = true;
		local cannotTransmogrifyReason = nil;
		local isPendingCollected = true;
		local isHideVisual = false;

		local textureItemID;
		if hasPending and pending.type == Enum.TransmogPendingType.Apply then
			textureItemID = pending.transmogID;
		elseif isTransmogrified then
			textureItemID = appliedID;
		else
			textureItemID = equippedID;
		end
		local texture = textureItemID and textureItemID ~= 0 and GetItemIcon(textureItemID) or nil;

		return isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture;
	end

	function C_Transmog.ApplyAllPending()
		local sentAny = false;
		for slotID, pending in pairs(_pending) do
			local itemID = 0;
			if pending.type == Enum.TransmogPendingType.Apply then
				itemID = pending.transmogID or 0;
			end
			SendServerMessage("ACMSG_TRANSMOG_APPLY", string.format("%d:%d", slotID, itemID));
			sentAny = true;
		end
		wipe(_pending);
		FireCustomClientEvent("TRANSMOGRIFY_UPDATE");
		return sentAny;
	end

	-- ------------------------------------------------------------
	-- Reception des messages serveur (meme dispatcher EventHandler que
	-- Utils\C_TransmogCollection.lua : une methode nommee exactement comme
	-- le prefixe de l'addon-message est appelee automatiquement).
	-- ------------------------------------------------------------
	-- FIX ROUND TRANSMOG-37 : ces 2 confirmations serveur (sync au login,
	-- confirmation d'application) sont des VRAIS changements d'equipement --
	-- contrairement au simple survol/clic de navigation dans la grille
	-- (round 36, ou on a volontairement arrete de rafraichir le mannequin a
	-- chaque clic pour ne pas le faire disparaitre), ici un rafraichissement
	-- complet du mannequin est legitime et attendu : "le visuel du
	-- personnage ne se met pas a jour" apres avoir clique Appliquer. On
	-- appelle donc explicitement MarkDirty (redessine le mannequin via
	-- Undress/RefreshItemModel) EN PLUS du rafraichissement leger de la
	-- grille, uniquement ici (evenements rares, pas a chaque clic).
	-- FIX ROUND TRANSMOG-40 : le round 37 ne faisait que MarkDirty() (poser un
	-- drapeau self.dirty=true, consomme au prochain OnUpdate natif de
	-- WardrobeTransmogFrame). Le script OnUpdate est bien cable en XML donc
	-- ca devrait marcher tout seul -- mais on supprime cette dependance a un
	-- aller-retour supplementaire (drapeau + attente du prochain tick) et on
	-- appelle desormais Update() directement et immediatement, en synchrone,
	-- au moment meme ou le serveur confirme. On garde aussi MarkDirty() en
	-- filet de securite (inoffensif, coute rien de plus).
	local function DoRefreshTransmogModel()
		if WardrobeTransmogFrame then
			-- FIX ROUND TRANSMOG-55 : les rounds 51-54 appelaient tous
			-- RefreshPlayerModel(), qui recree le widget PUIS rejoue quand
			-- meme Undress()+TryOn() manuellement pour chaque emplacement
			-- (via Update()). Voir le long commentaire dans Custom_Wardrobe.lua
			-- au-dessus de RefreshPlayerModelAfterApply() : la reference
			-- fonctionnelle (TransmogUniverse.zip) ne rejoue JAMAIS TryOn()
			-- pour un objet deja confirme par le serveur, seulement
			-- SetUnit("player") sur le widget fraichement recree. On utilise
			-- donc desormais cette nouvelle fonction dediee ici, qui ne fait
			-- QUE la recreation + SetUnit (+ rafraichissement des icones 2D),
			-- sans boucle TryOn manuelle.
			if WardrobeTransmogFrame.RefreshPlayerModelAfterApply then
				local ok, err = pcall(WardrobeTransmogFrame.RefreshPlayerModelAfterApply, WardrobeTransmogFrame);
				if not ok then
					print("|cffff0000[TDEBUG]|r WardrobeTransmogFrame:RefreshPlayerModelAfterApply() a echoue : " .. tostring(err));
				end
			elseif WardrobeTransmogFrame.RefreshPlayerModel then
				local ok, err = pcall(WardrobeTransmogFrame.RefreshPlayerModel, WardrobeTransmogFrame, true);
				if not ok then
					print("|cffff0000[TDEBUG]|r WardrobeTransmogFrame:RefreshPlayerModel() a echoue : " .. tostring(err));
				end
			elseif WardrobeTransmogFrame.Update then
				pcall(WardrobeTransmogFrame.Update, WardrobeTransmogFrame, true);
			end
			-- FIX ROUND TRANSMOG-56 (BUG TROUVE VIA TRACE UTILISATEUR) : cette
			-- ligne "filet de securite" (heritee du round 40) posait
			-- self.dirty=true, ce qui programme un TransmogFrameMixin:Update()
			-- COMPLET au tout prochain OnUpdate natif (frame suivante). Or
			-- Update() refait exactement ce qu'on essaie d'eviter depuis le
			-- round 55 : Undress() + reboucle TryOn(...) manuellement pour
			-- CHAQUE emplacement. La trace /tmodeltrace fournie par
			-- l'utilisateur (round 55 test) le prouve noir sur blanc : juste
			-- apres CHACUN des 4 appels a RefreshPlayerModelAfterApply(), une
			-- boucle Update()/TryOn() complete se redeclenchait sur la frame
			-- suivante et ecrasait tout -- annulant totalement le fix "SetUnit
			-- seul" du round 55, qui n'avait donc jamais eu la moindre chance
			-- de "tenir". On retire donc cet appel : RefreshPlayerModelAfterApply
			-- s'occupe deja des icones 2D des cases (slotButton:Update()) et du
			-- bouton Appliquer, ce filet de securite n'est plus necessaire et
			-- est meme activement nuisible ici.
		end
	end

	local function RefreshTransmogModelAfterServerConfirm()
		if WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame.UpdateItems then
			pcall(WardrobeCollectionFrame.ItemsCollectionFrame.UpdateItems, WardrobeCollectionFrame.ItemsCollectionFrame);
		end
		-- FIX ROUND TRANSMOG-53 (insuffisant) : un seul appel differe de zero
		-- seconde (C_Timer.After(0, ...)) ne suffisait pas. Le probleme
		-- persistait meme apres etre sorti du contexte du handler de message.
		--
		-- FIX ROUND TRANSMOG-54 : TransmogFrameMixin ecoute deja l'evenement
		-- natif UNIT_MODEL_CHANGED et rappelle RefreshPlayerModel() dessus --
		-- ce qui suggere que le moteur du client a besoin d'un certain temps
		-- APRES l'ecriture serveur des champs PLAYER_VISIBLE_ITEM_x_ENTRYID
		-- avant que son etat de modele interne soit vraiment a jour. Notre
		-- confirmation (ASMSG_TRANSMOG_APPLIED) arrive peut-etre avant que ce
		-- traitement natif soit termine : un seul essai, meme differe d'une
		-- frame, peut donc encore lire les anciennes donnees.
		--
		-- Par analogie avec le mecanisme deja utilise cote serveur pour un
		-- probleme de course similaire au login (REAPPLY_ON_LOGIN_ATTEMPTS /
		-- REAPPLY_ON_LOGIN_DELAY_MS), on reessaie ici le rafraichissement du
		-- mannequin PLUSIEURS fois a des delais croissants, au lieu d'une
		-- seule tentative a delai fixe. Meme si les premiers essais arrivent
		-- encore trop tot, un des essais suivants (jusqu'a 1.5s) devrait
		-- forcement arriver apres que le moteur ait fini son traitement
		-- natif -- exactement comme quand on change d'onglet et qu'on revient.
		if C_Timer and C_Timer.After then
			C_Timer.After(0, DoRefreshTransmogModel);
			C_Timer.After(0.15, DoRefreshTransmogModel);
			C_Timer.After(0.4, DoRefreshTransmogModel);
			C_Timer.After(0.8, DoRefreshTransmogModel);
			C_Timer.After(1.5, DoRefreshTransmogModel);
		else
			DoRefreshTransmogModel();
		end
	end

	function EventHandler:ASMSG_TRANSMOG_SYNC(msg)
		-- FIX ROUND TRANSMOG-55 (diagnostic) : ce handler REMPLACE
		-- integralement _applied (wipe + repeuplement depuis msg). Si le
		-- serveur envoie un SYNC juste apres un APPLIED (par exemple au
		-- meme moment qu'un evenement d'equipement natif), et que ce SYNC
		-- ne contient pas encore le nouvel objet (snapshot legerement en
		-- retard cote serveur), ce handler EFFACERAIT silencieusement notre
		-- correction. On trace donc systematiquement (pas seulement sous
		-- /tmodeltrace) l'heure et le contenu brut recu ici, pour verifier
		-- si c'est bien ce qui se passe.
		print(string.format("|cffffcc00[TDEBUG55]|r ASMSG_TRANSMOG_SYNC recu @ %.3f, msg=%s", GetTime(), tostring(msg)));
		wipe(_applied);
		if msg and msg ~= "" then
			for slotStr, itemStr in msg:gmatch("(%d+):(%d+)") do
				local slotID = tonumber(slotStr);
				local itemID = tonumber(itemStr);
				if slotID and itemID and itemID > 0 then
					_applied[slotID] = itemID;
				end
			end
		end
		FireCustomClientEvent("TRANSMOGRIFY_UPDATE");
		RefreshTransmogModelAfterServerConfirm();
	end

	function EventHandler:ASMSG_TRANSMOG_APPLIED(msg)
		-- FIX ROUND TRANSMOG-40 : trace inline (independante de tout ordre de
		-- chargement entre fichiers, contrairement au wrap externe du round 38
		-- dans Collection_Compat_Tooltip.lua qui ne s'installe que si ce
		-- fichier-ci est deja charge) + protection pcall pour ne jamais
		-- laisser une erreur silencieuse interrompre le rafraichissement du
		-- mannequin.
		print(string.format("|cff00ff88[TDEBUG40]|r ASMSG_TRANSMOG_APPLIED recu @ %.3f, msg=%s", GetTime(), tostring(msg)));
		local slotStr, itemStr = msg:match("(%d+):(%d+)");
		local slotID = tonumber(slotStr);
		local itemID = tonumber(itemStr);
		if slotID then
			if itemID and itemID > 0 then
				_applied[slotID] = itemID;
			else
				_applied[slotID] = nil;
			end
		else
			print("|cffff0000[TDEBUG40]|r ASMSG_TRANSMOG_APPLIED : message mal forme, slotID introuvable dans '" .. tostring(msg) .. "'");
		end
		FireCustomClientEvent("TRANSMOGRIFY_UPDATE");
		local ok, err = pcall(RefreshTransmogModelAfterServerConfirm);
		if ok then
			print("|cff00ff88[TDEBUG40]|r rafraichissement mannequin declenche sans erreur.");
		else
			print("|cffff0000[TDEBUG40]|r rafraichissement mannequin ERREUR : " .. tostring(err));
		end
	end

	function EventHandler:ASMSG_TRANSMOG_ERROR(msg)
		if UIErrorsFrame then
			UIErrorsFrame:AddMessage(msg or "Transmogrification impossible.", 1.0, 0.1, 0.1);
		end
	end
end

-- ============================================================
-- 25) C_Talent.GetCurrentSpecID : utilise par Custom_HeirloomCollection.lua
--     pour filtrer par spe active. Universe a son propre C_Talent (base sur
--     GetActiveTalentGroup, 1 ou 2), sans notion de "specID" a la retail.
--     On fournit un alias sans danger (nil = pas de filtre par spe applique).
-- ============================================================
DIAGv26_CP986 = true;
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
DIAGv26_CP1001 = true;
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
DIAGv26_CP1032 = true;
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
DIAGv26_CP1047 = true;
COLLECTION_CVAR_SHIM_VALUES = COLLECTION_CVAR_SHIM_VALUES or {}

-- PATCH round 80 : valeurs par defaut pour les CVars "afficher
-- collectionne / non collectionne" de la Garde-robe (et des Illusions, meme
-- systeme). Sans ce seed, GetCVar retombe sur "0" (false) tant que le
-- joueur n'a jamais clique sur "reinitialiser les filtres", et
-- SetSearchAndFilterAppearances (C_TransmogCollection.lua) masque de facon
-- INCONDITIONNELLE tous les objets non collectionnes quand
-- wardrobeShowUncollected est faux -- d'ou la grille Garde-robe vide (0/N)
-- au premier affichage de l'onglet, jusqu'a cliquer sur la petite croix.
DIAGv26_CP1066 = true;
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

	--- Fix Round Transmog-10 : liste blanche non exhaustive. Plusieurs noms
	--- de CVar invente par les differents systemes de Collection portes
	--- (ex : "mountJournalGeneralFilters" appele par
	--- C_MountJournal.SetDefaultFilters, "wardrobeShowCollected" par
	--- C_TransmogCollection.SetDefaultFilters) ETAIENT deja dans
	--- COLLECTION_SHIMMED_CVARS mais l'appel plantait quand meme avec
	--- "Couldn't find CVar named ..." -- symptome observe sur le bouton
	--- Reinitialiser les filtres (Montures ET Garde-robe/Transmog). Plutot
	--- que de chasser un a un chaque nom de CVar invente non encore
	--- recense, on rend le filet de securite generique : si l'appel natif
	--- echoue (nom vraiment inconnu du moteur client), on bascule
	--- automatiquement ce nom sur la table de secours au lieu de laisser
	--- planter tout le call-stack (et on le memorise dans
	--- COLLECTION_SHIMMED_CVARS pour ne plus jamais retenter l'appel natif
	--- pour ce nom).
	function GetCVar(name, ...)
		if COLLECTION_SHIMMED_CVARS[name] then
			return COLLECTION_CVAR_SHIM_VALUES[name] or "0"
		end
		local ok, result = pcall(RealGetCVar, name, ...)
		if ok then
			return result
		end
		COLLECTION_SHIMMED_CVARS[name] = true
		return COLLECTION_CVAR_SHIM_VALUES[name] or "0"
	end

	function SetCVar(name, value, ...)
		if COLLECTION_SHIMMED_CVARS[name] then
			COLLECTION_CVAR_SHIM_VALUES[name] = tostring(value)
			return
		end
		local ok = pcall(RealSetCVar, name, value, ...)
		if not ok then
			COLLECTION_SHIMMED_CVARS[name] = true
			COLLECTION_CVAR_SHIM_VALUES[name] = tostring(value)
		end
	end

	if GetCVarBool then
		local RealGetCVarBool = GetCVarBool
		function GetCVarBool(name, ...)
			if COLLECTION_SHIMMED_CVARS[name] then
				local value = COLLECTION_CVAR_SHIM_VALUES[name]
				return value == "1" or value == "true"
			end
			local ok, result = pcall(RealGetCVarBool, name, ...)
			if ok then
				return result
			end
			COLLECTION_SHIMMED_CVARS[name] = true
			local value = COLLECTION_CVAR_SHIM_VALUES[name]
			return value == "1" or value == "true"
		end
	end
end

--- Fix Round Transmog-10 : commande de diagnostic. Plusieurs rapports de
--- bugs recents (rounds 8-9) montraient des erreurs "(a nil value)" sur des
--- fonctions/tables qui SONT bien presentes dans ce fichier tel que livre
--- (verifie ligne par ligne avant chaque livraison) -- le symptome typique
--- d'un client qui charge encore une version perimee/tronquee de
--- Collection_Compat.lua. Cette commande permet de verifier EN JEU, sans
--- ambiguite, si les correctifs des derniers rounds sont reellement actifs.
DIAGv26_CP1149 = true;
SLASH_COLLECTIONCOMPATCHECK1 = "/ccheck"
SlashCmdList = SlashCmdList or {}
SlashCmdList["COLLECTIONCOMPATCHECK"] = function()
	local function report(label, isPresent)
		if isPresent then
			print("|cff00ff00[ccheck] OK|r - " .. label)
		else
			print("|cffff0000[ccheck] MANQUANT|r - " .. label .. " (fichier Collection_Compat.lua perime ou tronque, recopiez le patch a nouveau et redemarrez completement le client)")
		end
	end
	print("|cffffcc00=== Collection_Compat.lua : diagnostic ===|r");
	report("TRANSMOG_INVALID_CODES (round 7)", TRANSMOG_INVALID_CODES ~= nil)
	report("C_Transmog.GetSlotInfo (round 6)", C_Transmog ~= nil and C_Transmog.GetSlotInfo ~= nil)
	report("C_Transmog.GetSlotVisualInfo reel (round 8)", C_Transmog ~= nil and C_Transmog.GetSlotVisualInfo ~= nil)
	report("C_Item.GetBaseItemTransmogInfo reel (round 8)", C_Item ~= nil and C_Item.GetBaseItemTransmogInfo ~= nil)
	report("_AnimateTexCoords (round 8)", _AnimateTexCoords ~= nil)
	report("PET_TYPE_SUFFIX (ancien round)", PET_TYPE_SUFFIX ~= nil)
	report("C_Talent.GetCurrentSpecID (ancien round)", C_Talent ~= nil and C_Talent.GetCurrentSpecID ~= nil)
	report("COLLECTION_ITEM_HYPERLINK_FORMAT (ancien round)", COLLECTION_ITEM_HYPERLINK_FORMAT ~= nil)
	report("CVar shim generique/pcall (round 10)", COLLECTION_CVAR_SHIM_INSTALLED == true)
	print("|cffffcc00=== fin du diagnostic ===|r");
end

-- ============================================================
-- 29) CHAR_COLLECTION_* : constantes de Constants.lua (Sirus), entierement
--     absentes d'Universe. Utilisees par C_MountJournal/C_PetJournal/
--     C_ToyBox/C_TransmogCollection.lua pour le protocole ACMSG_C_A_F /
--     ACMSG_C_R_F (ajout/retrait des favoris). Sans elles, string.format
--     recevait nil a la place d'un nombre -> crash a chaque clic sur
--     l'etoile "Favori" (montures/familiers/jouets/apparences/reliques).
-- ============================================================
DIAGv26_CP1180 = true;
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
DIAGv26_CP1201 = true;
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
DIAGv26_CP1247 = true;
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
DIAGv26_CP1270 = true;
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
DIAGv26_CP1287 = true;
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
DIAGv26_CP1312 = true;
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
DIAGv26_CP1345 = true;
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
DIAGv26_CP1371 = true;
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
DIAGv26_CP1393 = true;
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
DIAGv26_CP1428 = true;
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
DIAGv26_CP1454 = true;
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

-- ============================================================
-- PATCH Collection (round 101) : classes personnalisees manquantes dans le
-- filtre "Classe" de l'onglet Heritage (Reliques).
--
-- Diagnostic : Custom_HeirloomCollection.lua construit ce menu via
-- "for i = 1, GetNumClasses() do ... GetClassInfo(i) ... end", et pour la
-- selection courante via C_CreatureInfo.GetClassInfo(classID)
-- (Utils\C_CreatureInfo.lua). Ces 3 fonctions s'appuient TOUTES sur
-- S_CLASS_SORT_ORDER (SharedXML\SharedConstants.lua), qui ne liste QUE 11
-- classes (WARRIOR..WARLOCK, DRUID=11, DEMONHUNTER=13) -- absent : BloodMage
-- (10), Knight (12), Monk (14), Tamer (15), Hero (16), Evoker (17),
-- Necromancer (18), Venomancer (19), Pyromancer (20), Chronomancer (21),
-- Geomancer (22), ChaosRavager (23), soit les 12 classes custom du serveur
-- (cf. enum Classes, SharedDefines.h fourni par l'utilisateur). Pire :
-- S_CLASS_SORT_ORDER est explicitement VERROUILLEE en lecture seule
-- (table.lockTable, SharedConstants.lua) -- toute tentative d'y ecrire de
-- nouvelles entrees est silencieusement ignoree (Extensions\table.lua :
-- __newindex se contente d'imprimer un avertissement).
--
-- A l'inverse, Universe possede DEJA cote FrameXML\Constants.lua un jeu de
-- donnees complet et NON verrouille pour les 23 classes + UNKCLASS :
-- RAID_CLASS_COLORS (couleurs), CLASS_ICON_TCOORDS (icones) et
-- CLASS_SORT_ORDER (liste des jetons) sont deja renseignes pour BLOODMAGE,
-- KNIGHT, MONK, TAMER, HERO, EVOKER, NECROMANCER, VENOMANCER, PYROMANCER,
-- CHRONOMANCER, GEOMANCER et CHAOSRAVAGER -- seule la correspondance
-- classID -> jeton (utilisee par le menu Heritage) manquait. On construit
-- donc notre propre table complete (non verrouillee) et on remplace
-- GetNumClasses/GetClassInfo/C_CreatureInfo.GetClassInfo pour s'appuyer
-- dessus, sans jamais toucher a S_CLASS_SORT_ORDER.
--
-- Les noms FR proviennent de LOCALIZED_CLASS_NAMES_MALE/FEMALE (rempli
-- nativement par FillLocalizedClassList, Constants.lua, a partir des
-- memes donnees compilees que RAID_CLASS_COLORS/CLASS_ICON_TCOORDS -- donc
-- deja disponibles pour les 23 classes) ; un nom de secours (traduction FR
-- standard) est fourni au cas ou une entree serait malgre tout absente.
--
-- Les specialisations (sous-menu par classe) restent inchangees : elles
-- s'appuient sur S_CALSS_SPECIALIZATION_DATA (non verrouillee, non touchee
-- ici), qui ne couvre que les 11 classes d'origine. Pour les 12 classes
-- custom, GetNumSpecializationsForClassID renvoie 0 nativement (code de
-- repli deja present dans EJ_CompatLate.lua) : le menu affiche alors
-- simplement la classe sans sous-liste de specialisations, sans erreur.
-- ============================================================
DIAGv26_CP1519 = true;
do
	local CLASS_ID_TO_TOKEN = {
		[1]  = "WARRIOR",
		[2]  = "PALADIN",
		[3]  = "HUNTER",
		[4]  = "ROGUE",
		[5]  = "PRIEST",
		[6]  = "DEATHKNIGHT",
		[7]  = "SHAMAN",
		[8]  = "MAGE",
		[9]  = "WARLOCK",
		[10] = "BLOODMAGE",
		[11] = "DRUID",
		[12] = "KNIGHT",
		[13] = "DEMONHUNTER",
		[14] = "MONK",
		[15] = "TAMER",
		[16] = "HERO",
		[17] = "EVOKER",
		[18] = "NECROMANCER",
		[19] = "VENOMANCER",
		[20] = "PYROMANCER",
		[21] = "CHRONOMANCER",
		[22] = "GEOMANCER",
		[23] = "CHAOSRAVAGER",
	};

	-- Nom de secours FR, utilise seulement si LOCALIZED_CLASS_NAMES_MALE/FEMALE
	-- ne connait pas encore le jeton (filet de securite).
	local FALLBACK_CLASS_NAME_FR = {
		WARRIOR      = "Guerrier",
		PALADIN      = "Paladin",
		HUNTER       = "Chasseur",
		ROGUE        = "Voleur",
		PRIEST       = "Prêtre",
		DEATHKNIGHT  = "Chevalier de la mort",
		SHAMAN       = "Chaman",
		MAGE         = "Mage",
		WARLOCK      = "Démoniste",
		BLOODMAGE    = "Mage de sang",
		DRUID        = "Druide",
		KNIGHT       = "Chevalier",
		DEMONHUNTER  = "Chasseur de démons",
		MONK         = "Moine",
		TAMER        = "Dompteur",
		HERO         = "Héros",
		EVOKER       = "Évocateur",
		NECROMANCER  = "Nécromancien",
		VENOMANCER   = "Venimancien",
		PYROMANCER   = "Pyromancien",
		CHRONOMANCER = "Chronomancien",
		GEOMANCER    = "Géomancien",
		CHAOSRAVAGER = "Ravageur du Chaos",
	};

	local NUM_CUSTOM_CLASSES = 23;

	local function ResolveClassName(token, useFemale)
		local pool = useFemale and LOCALIZED_CLASS_NAMES_FEMALE or LOCALIZED_CLASS_NAMES_MALE;
		local name = pool and pool[token];
		if not name or name == "" then
			name = FALLBACK_CLASS_NAME_FR[token];
		end
		return name;
	end

	function GetNumClasses()
		return NUM_CUSTOM_CLASSES;
	end

	function GetClassInfo(index, declension)
		local token = CLASS_ID_TO_TOKEN[index];
		if not token then
			return;
		end

		local className;
		if declension then
			local gender = UnitSex("player");
			className = ResolveClassName(token, gender == 3);
		else
			className = ResolveClassName(token, false);
		end

		local classFlag = bit.lshift(1, index - 1);
		return className, token, index, classFlag;
	end

	C_CreatureInfo = C_CreatureInfo or {};
	function C_CreatureInfo.GetClassInfo(class)
		local token = CLASS_ID_TO_TOKEN[class];
		if not token then
			return;
		end

		local nameMale = ResolveClassName(token, false);
		local nameFemale = ResolveClassName(token, true);
		local classFlag = bit.lshift(1, class - 1);

		local ClassInfo = {};
		ClassInfo.classFile = token;
		ClassInfo.className = nameMale;
		ClassInfo.classID = class;
		ClassInfo.classFlag = classFlag;
		ClassInfo.localizeName = {
			male = nameMale,
			female = nameFemale,
		};

		return ClassInfo;
	end

	-- Meme correctif pour le shim UnitClass (round 92, plus haut dans ce
	-- fichier) : sa resolution de classID passait par S_CLASS_SORT_ORDER,
	-- donc un joueur dont la classe est l'une des 12 classes custom se
	-- retrouvait avec un classID nil (UnitClass("player") -> classID
	-- introuvable), empechant la selection par defaut de sa propre classe
	-- dans le filtre Heritage. On l'etend pour couvrir les 23 classes.
	local CLASS_TOKEN_TO_ID = {};
	for id, token in pairs(CLASS_ID_TO_TOKEN) do
		CLASS_TOKEN_TO_ID[token] = id;
	end

	local PreviousUnitClass = _G.UnitClass;
	_G.UnitClass = function(unit)
		local className, classToken, classID, classFlag = PreviousUnitClass(unit);
		if not classID and classToken and CLASS_TOKEN_TO_ID[classToken] then
			classID = CLASS_TOKEN_TO_ID[classToken];
			classFlag = bit.lshift(1, classID - 1);
		end
		return className, classToken, classID, classFlag;
	end
end

-- ============================================================
-- PATCH Collection (round 108) : textes d'aide (HelpPlate) du
-- tutoriel Garde-robe (icone "i"). HEPLPLATE_WARDROBE_TRANSMOG_
-- TUTORIAL_1 a _9 sont references par Custom_Wardrobe.lua mais
-- n'etaient definis nulle part cote Universe (uniquement en russe
-- dans Sirus/GlobalStrings.lua) -> ToolTipText = nil -> bulles
-- d'aide vides. Traduction frFR depuis le texte russe original.
-- ============================================================
DIAGv26_CP1661 = true;
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_1 = "La Transmogrification vous permet de modifier l'apparence de votre équipement. Mais il y a quelques points importants à connaître.\n\n1. Une fois la Transmogrification effectuée, vous ne pourrez plus rendre les objets au marchand. Cela concerne aussi bien l'objet dont vous avez changé l'apparence que celui dont vous avez utilisé l'apparence.\n\n2. Si vous détruisez ou vendez un objet possédant un minuteur de retour ou d'échange, vous perdrez l'apparence associée à la Transmogrification.\n\n3. Après la Transmogrification, les deux objets deviennent personnels. Cela s'applique également aux objets d'Héritage (armure et armes).\n\n4. Appliquer un enchantement visuel sur une arme la rend également personnelle.\n\n5. L'effet de Transmogrification est retiré des objets d'Héritage envoyés par courrier.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_2 = "Ce compteur indique le nombre d'apparences d'objets que vous avez collectées. Le nombre affiché varie selon l'emplacement et le type d'objet sélectionnés.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_3 = "Pour trouver l'apparence d'un objet qui vous intéresse, commencez à saisir son nom dans le champ \"Recherche\".";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_4 = "Vous pouvez ici choisir la source d'obtention des apparences d'objets que vous avez déjà obtenues.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_5 = "Vous pouvez ici activer/désactiver l'affichage de la fenêtre d'aide pour la Transmogrification du type d'objet sélectionné. Si la fenêtre d'aide est activée, le bouton \"Règles complètes\" vous permettra d'accéder aux informations détaillées sur toutes les règles de Transmogrification dans l'encyclopédie.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_6 = "Vous pouvez ici enregistrer toutes vos tenues.\n\nChoisissez les apparences souhaitées pour vos objets, puis cliquez sur \"Nouvel équipement\". Donnez-lui un nom unique et cliquez sur \"Appliquer\". Votre tenue est maintenant enregistrée et vous pourrez l'utiliser plus tard pour changer rapidement de Transmogrification.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_7 = "Vous pouvez ici sélectionner l'objet auquel vous souhaitez donner une nouvelle apparence.\n\nPour annuler les modifications d'un objet en particulier, cliquez dessus avec le bouton droit de la souris ou sur la flèche qui apparaît à côté.\n\nSi vous souhaitez annuler les modifications pour tous les objets à la fois, cliquez sur la flèche en haut à droite.\n\nNotez que l'annulation groupée n'est possible que tant que le service de Transmogrification n'a pas été payé.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_8 = "Vous pouvez ici choisir le type d'apparence d'objet souhaité.";
HEPLPLATE_WARDROBE_TRANSMOG_TUTORIAL_9 = "Toutes vos apparences d'objets correspondant aux filtres et à la recherche s'affichent ici.\n\nPour placer une apparence en tête de liste, ajoutez-la à vos Favoris. Pour cela, faites un clic droit sur l'objet et sélectionnez \"Ajouter aux Favoris\".";

DIAGv26_END = true;