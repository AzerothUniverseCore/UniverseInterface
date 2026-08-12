ADVENTURE = ADVENTURE or "Codex des donjons"
ADVENTURE_JOURNAL = ADVENTURE_JOURNAL or "Codex des donjons"
NAVIGATIONBAR_HOME = NAVIGATIONBAR_HOME or "Accueil"
AJ_SUGGESTED_CONTENT_TAB = AJ_SUGGESTED_CONTENT_TAB or "Recommandations"
EJ_RAIDS_TAB = EJ_RAIDS_TAB or "Raids"
RAIDS = RAIDS or "Raids"
INSTANCE = INSTANCE or "Instance"
ENCOUNTER = ENCOUNTER or "Combat"
HEADHUNTING = HEADHUNTING or "La chasse aux têtes"
LOOTJOURNAL_ITEM_SETS = LOOTJOURNAL_ITEM_SETS or "Tenue"
ENCOUNTER_JOURNAL_SHOW_MAP = ENCOUNTER_JOURNAL_SHOW_MAP or "Afficher la carte"
ENCOUNTER_JOURNAL_SHOW_SEARCH_RESULTS = ENCOUNTER_JOURNAL_SHOW_SEARCH_RESULTS or "Afficher tous les résultats"
ENCOUNTER_JOURNAL_SEARCH_RESULTS = ENCOUNTER_JOURNAL_SEARCH_RESULTS or "Résultats de la recherche: %s (%d)"
ENCOUNTER_JOURNAL_ITEM = ENCOUNTER_JOURNAL_ITEM or "Sujet"
ENCOUNTER_JOURNAL_ENCOUNTER = ENCOUNTER_JOURNAL_ENCOUNTER or "Combat"
ENCOUNTER_JOURNAL_INSTANCE = ENCOUNTER_JOURNAL_INSTANCE or "Donjon"
EJ_FILTER_ALL_CLASS = EJ_FILTER_ALL_CLASS or "Toutes les classes"
EJ_CLASS_FILTER = EJ_CLASS_FILTER or "Classe"
CLASS = CLASS or "Classe"
FILTER = FILTER or "Filtre"
ALL_INVENTORY_SLOTS = ALL_INVENTORY_SLOTS or "Tous les emplacements d’inventaire"
MAINMENUBAR_EJ_NEWBIE_TOOLTIP = MAINMENUBAR_EJ_NEWBIE_TOOLTIP or "Informations sur les boss des donjons et des raids, y compris leurs capacités et les butins."
LOOTJOURNAL_ITEM_CLICK_TO_OPEN_LOOT = LOOTJOURNAL_ITEM_CLICK_TO_OPEN_LOOT or "Cliquez pour ouvrir le butin."
LOOTJOURNAL_SOURCE_TOOLTIP_HEAD = LOOTJOURNAL_SOURCE_TOOLTIP_HEAD or "Tooltip"
LOOTJOURNAL_PVPICON_TOOLTIP_HEAD = LOOTJOURNAL_PVPICON_TOOLTIP_HEAD or "Tenue PvP"
LOOTJOURNAL_PVPICON_TOOLTIP = LOOTJOURNAL_PVPICON_TOOLTIP or "Un équipement adapté aux combats contre d'autres joueurs."
RETURN_TO_DEFAULT = RETURN_TO_DEFAULT or "Paramètres par défaut"
OVERVIEW = OVERVIEW or "Aperçu"
ABILITIES = ABILITIES or "Compétences"
LOOT_NOUN = LOOT_NOUN or "Loot"
MODEL = MODEL or "Modèle"
BOSS_INFO_STRING = BOSS_INFO_STRING or "Boss: %s"
EJ_SET_ITEM_LEVEL = EJ_SET_ITEM_LEVEL or "|cffcc4040[%s]|r Niveau d'objet: %d"
SEARCH_LOADING_TEXT = SEARCH_LOADING_TEXT or "Recherche..."
SEARCH_PROGRESS_BAR_TEXT = SEARCH_PROGRESS_BAR_TEXT or "Recherche"
BINDING_NAME_TOGGLEENCOUNTERJOURNAL = BINDING_NAME_TOGGLEENCOUNTERJOURNAL or ADVENTURE

LOOTJOURNAL_FACTION_NEUTRAL = LOOTJOURNAL_FACTION_NEUTRAL or 0
LOOTJOURNAL_FACTION_ALLIANCE = LOOTJOURNAL_FACTION_ALLIANCE or 1
LOOTJOURNAL_FACTION_HORDE = LOOTJOURNAL_FACTION_HORDE or 2

for i = 0, 12 do
	local key = "ENCOUNTER_JOURNAL_SECTION_FLAG"..i
	_G[key] = _G[key] or ("Drapeau "..i)
	local descKey = "ENCOUNTER_JOURNAL_SECTION_FLAG_DESCRIPTION"..i
	_G[descKey] = _G[descKey] or ("Description du drapeau "..i)
end

-- Vanilla 3.3.5 has no ITEM_SUB_CLASS_* globals; EJ uses them as GetItemInfo subclass keys.
local function DefItemSubClass(name, frFR)
	if not _G[name] then
		_G[name] = frFR
	end
end

DefItemSubClass("ITEM_SUB_CLASS_2_0", "Haches à une main")
DefItemSubClass("ITEM_SUB_CLASS_2_1", "Haches à deux mains")
DefItemSubClass("ITEM_SUB_CLASS_2_2", "Arcs")
DefItemSubClass("ITEM_SUB_CLASS_2_3", "Arme à feu")
DefItemSubClass("ITEM_SUB_CLASS_2_4", "Masses à une main")
DefItemSubClass("ITEM_SUB_CLASS_2_5", "Masses à deux mains")
DefItemSubClass("ITEM_SUB_CLASS_2_6", "Armes d'hast")
DefItemSubClass("ITEM_SUB_CLASS_2_7", "Epées à une main")
DefItemSubClass("ITEM_SUB_CLASS_2_8", "Epées à deux mains")
DefItemSubClass("ITEM_SUB_CLASS_2_9", "Warglaives")
DefItemSubClass("ITEM_SUB_CLASS_2_10", "Bâtons")
DefItemSubClass("ITEM_SUB_CLASS_2_13", "Armes de pugilat")
DefItemSubClass("ITEM_SUB_CLASS_2_14", "Divers")
DefItemSubClass("ITEM_SUB_CLASS_2_15", "Dagues")
DefItemSubClass("ITEM_SUB_CLASS_2_18", "Arbalètes")
DefItemSubClass("ITEM_SUB_CLASS_2_19", "Baguette")

DefItemSubClass("ITEM_SUB_CLASS_4_1", "Tissu")
DefItemSubClass("ITEM_SUB_CLASS_4_2", "Cuir")
DefItemSubClass("ITEM_SUB_CLASS_4_3", "Mailles")
DefItemSubClass("ITEM_SUB_CLASS_4_4", "Plaques")
DefItemSubClass("ITEM_SUB_CLASS_4_5", "Декоративные предметы")
DefItemSubClass("ITEM_SUB_CLASS_4_6", "Bouclier")
DefItemSubClass("ITEM_SUB_CLASS_4_7", "Libram")
DefItemSubClass("ITEM_SUB_CLASS_4_8", "Idole")
DefItemSubClass("ITEM_SUB_CLASS_4_9", "Totem")
DefItemSubClass("ITEM_SUB_CLASS_4_10", "Cachet")

DefItemSubClass("ITEM_SUB_CLASS_5_0", "Réactif")
DefItemSubClass("ITEM_SUB_CLASS_7_0", "Artisanat")
DefItemSubClass("ITEM_SUB_CLASS_7_1", "Eléments")
DefItemSubClass("ITEM_SUB_CLASS_7_2", "Explosifs")
DefItemSubClass("ITEM_SUB_CLASS_7_3", "Appareils")
DefItemSubClass("ITEM_SUB_CLASS_7_4", "Joaillerie")
DefItemSubClass("ITEM_SUB_CLASS_7_5", "Tissu")
DefItemSubClass("ITEM_SUB_CLASS_7_6", "Cuir")
DefItemSubClass("ITEM_SUB_CLASS_7_7", "Métal & pierre")
DefItemSubClass("ITEM_SUB_CLASS_7_8", "Viande")
DefItemSubClass("ITEM_SUB_CLASS_7_9", "Herbes")
DefItemSubClass("ITEM_SUB_CLASS_7_10", "Élémentaire")
DefItemSubClass("ITEM_SUB_CLASS_7_11", "Autre")
DefItemSubClass("ITEM_SUB_CLASS_7_12", "Enchantement")
DefItemSubClass("ITEM_SUB_CLASS_7_13", "Matériaux")
DefItemSubClass("ITEM_SUB_CLASS_7_14", "Enchantement d'armure")
DefItemSubClass("ITEM_SUB_CLASS_7_15", "Enchantement d'arme")

DefItemSubClass("ITEM_SUB_CLASS_9_0", "Livre")
DefItemSubClass("ITEM_SUB_CLASS_9_1", "Travail du cuir")
DefItemSubClass("ITEM_SUB_CLASS_9_2", "Couture")
DefItemSubClass("ITEM_SUB_CLASS_9_3", "Ingénierie")
DefItemSubClass("ITEM_SUB_CLASS_9_4", "Forge")
DefItemSubClass("ITEM_SUB_CLASS_9_5", "Cuisine")
DefItemSubClass("ITEM_SUB_CLASS_9_6", "Alchimie")
DefItemSubClass("ITEM_SUB_CLASS_9_7", "Secourisme")
DefItemSubClass("ITEM_SUB_CLASS_9_8", "Enchantement")
DefItemSubClass("ITEM_SUB_CLASS_9_9", "Pêche")
DefItemSubClass("ITEM_SUB_CLASS_9_10", "Joaillerie")
DefItemSubClass("ITEM_SUB_CLASS_9_11", "Calligraphie")

DefItemSubClass("ITEM_SUB_CLASS_11_3", "Giberne")
DefItemSubClass("ITEM_SUB_CLASS_12_0", "Quête")
DefItemSubClass("ITEM_SUB_CLASS_13_0", "Clé")
DefItemSubClass("ITEM_SUB_CLASS_13_1", "Crochetage")
DefItemSubClass("ITEM_SUB_CLASS_14_0", "Permanent")
DefItemSubClass("ITEM_SUB_CLASS_15_0", "Camelote")
DefItemSubClass("ITEM_SUB_CLASS_15_1", "Réactif")
DefItemSubClass("ITEM_SUB_CLASS_15_2", "Familier")
DefItemSubClass("ITEM_SUB_CLASS_15_3", "Fête")
DefItemSubClass("ITEM_SUB_CLASS_15_4", "Autre")
DefItemSubClass("ITEM_SUB_CLASS_15_5", "Monture")

if not GetItemSubClassInfo then
	function GetItemSubClassInfo(classID, subClassID)
		if tonumber(classID) and tonumber(subClassID) then
			return _G[string.format("ITEM_SUB_CLASS_%d_%d", classID, subClassID)]
		end
	end
end

local function DefItemClass(name, frFR)
	if not _G[name] then
		_G[name] = frFR
	end
end

DefItemClass("ITEM_CLASS_0", "Consommable")
DefItemClass("ITEM_CLASS_1", "Conteneur")
DefItemClass("ITEM_CLASS_2", "Arme")
DefItemClass("ITEM_CLASS_3", "Gemme")
DefItemClass("ITEM_CLASS_4", "Armure")
DefItemClass("ITEM_CLASS_5", "Composant")
DefItemClass("ITEM_CLASS_6", "Projectile")
DefItemClass("ITEM_CLASS_7", "Artisanat")
DefItemClass("ITEM_CLASS_8", "Enchantement")
DefItemClass("ITEM_CLASS_9", "Recette")
DefItemClass("ITEM_CLASS_10", "Monnaie")
DefItemClass("ITEM_CLASS_11", "Carquois")
DefItemClass("ITEM_CLASS_12", "Quête")
DefItemClass("ITEM_CLASS_13", "Clé")
DefItemClass("ITEM_CLASS_14", "Permanent")
DefItemClass("ITEM_CLASS_15", "Divers")
DefItemClass("ITEM_CLASS_16", "Glyphes")

DefItemSubClass("ITEM_SUB_CLASS_4_0", "Divers")
