local IsGMAccount = IsGMAccount

local COLLECTION_HEIRLOOMDATA = COLLECTION_HEIRLOOMDATA;

local HEIRLOOM_COLLECTED = 1;
local HEIRLOOM_UNCOLLECTED = 2;

local HEIRLOOM_DAMAGER_FLAG = 0x1;
local HEIRLOOM_RANGED_DAMAGER_FLAG = 0x2;
local HEIRLOOM_TANK_FLAG = 0x4;
local HEIRLOOM_HEAL_FLAG = 0x8;

local HEIRLOOM_SPEC_ROLE_FLAG = {
	-- Warrior
	[161] = HEIRLOOM_DAMAGER_FLAG, [164] = HEIRLOOM_DAMAGER_FLAG, [163] = HEIRLOOM_TANK_FLAG,
	-- Paladin
	[382] = HEIRLOOM_HEAL_FLAG, [383] = HEIRLOOM_TANK_FLAG, [381] = HEIRLOOM_DAMAGER_FLAG,
	-- Hunter
	[361] = HEIRLOOM_DAMAGER_FLAG, [363] = HEIRLOOM_DAMAGER_FLAG, [362] = HEIRLOOM_DAMAGER_FLAG,
	-- Rogue
	[182] = HEIRLOOM_DAMAGER_FLAG, [181] = HEIRLOOM_DAMAGER_FLAG, [183] = HEIRLOOM_DAMAGER_FLAG,
	-- Priest
	[201] = HEIRLOOM_HEAL_FLAG, [202] = HEIRLOOM_HEAL_FLAG, [203] = HEIRLOOM_RANGED_DAMAGER_FLAG,
	-- Deathknight
	[398] = bit.bor(HEIRLOOM_DAMAGER_FLAG, HEIRLOOM_TANK_FLAG), [399] = bit.bor(HEIRLOOM_DAMAGER_FLAG, HEIRLOOM_TANK_FLAG), [400] = bit.bor(HEIRLOOM_DAMAGER_FLAG, HEIRLOOM_TANK_FLAG),
	-- Shaman
	[261] = HEIRLOOM_RANGED_DAMAGER_FLAG, [263] = HEIRLOOM_DAMAGER_FLAG, [262] = HEIRLOOM_HEAL_FLAG,
	-- Mage
	[81] = HEIRLOOM_RANGED_DAMAGER_FLAG, [41] = HEIRLOOM_RANGED_DAMAGER_FLAG, [61] = HEIRLOOM_RANGED_DAMAGER_FLAG,
	-- Warlock
	[302] = HEIRLOOM_RANGED_DAMAGER_FLAG, [303] = HEIRLOOM_RANGED_DAMAGER_FLAG, [301] = HEIRLOOM_RANGED_DAMAGER_FLAG,
	-- DemonHunter
	[504] = HEIRLOOM_DAMAGER_FLAG, [505] = HEIRLOOM_DAMAGER_FLAG, [506] = HEIRLOOM_DAMAGER_FLAG,
	-- Druid
	[283] = HEIRLOOM_RANGED_DAMAGER_FLAG, [281] = bit.bor(HEIRLOOM_DAMAGER_FLAG, HEIRLOOM_TANK_FLAG), [282] = HEIRLOOM_HEAL_FLAG,
};

local SOURCE_TYPES = {
	[1] = 1, [2] = 1, [3] = 1,
	[8] = 2, [12] = 2,
	[6] = 3, [13] = 3,
	[9] = 4,
	[7] = 5,
	[10] = 7, [11] = 7, [14] = 7,
	[15] = 8,
	[16] = 9,
	[17] = 10,
};

local FILTER_STRING = "";
local CLASS_FILTER = 0;
local SPEC_FILTER = 0;
local COLLECTED_SHOWN = true;
local UNCOLLECTED_SHOWN = true;

local HEIRLOOM_BY_ITEM_ID = {};

local HEIRLOOMS = {};

local VALID_SOURCE_FILTERS = {
	[3] = true,
	[7] = true,
};

local function PlayerHasHeirloom(itemID)
	-- PATCH round 67 : "possede" se basait sur IsSpellKnown(heirloom.spellID),
	-- or ces spellID (ex: 320561) sont des sorts retail modernes absents du
	-- spell.dbc WotLK 3.3.5 -- IsSpellKnown() est donc TOUJOURS faux, quel que
	-- soit l'etat reel du joueur. C'etait la cause du compteur "0/38" fige et
	-- des icones qui restaient eteintes/desaturees meme apres avoir recu
	-- l'objet contre de la monnaie (round 62 : on n'accorde plus aucun sort).
	-- La seule preuve reelle de possession desormais est d'avoir l'objet
	-- physiquement dans les sacs.
	local heirloom = HEIRLOOM_BY_ITEM_ID[itemID];
	-- PATCH round 75 : GetItemCount(itemID) sans le 2e argument ne compte
	-- QUE les sacs -- deposer l'objet a la banque personnelle le faisait
	-- donc paraitre "non collecte" (icone eteinte, retire du compte X/38)
	-- alors que le joueur le possede toujours. true = inclut la banque
	-- personnelle. Limitation connue : la banque de GUILDE n'est jamais
	-- visible via cette API cote client/serveur (ni WotLK ni Eluna), donc
	-- un objet depose en banque de guilde restera invisible pour ce
	-- controle -- aucune solution fiable sans toucher au C++ du core.
	if heirloom and GetItemCount(itemID, true) > 0 then
		return true;
	end

	return false;
end

local function CheckFilter(data, classFlag, specFlag, sourceFiltersFlag, sourceFlag, isGM)
	if not COLLECTED_SHOWN and PlayerHasHeirloom(data.itemID) then
		return false;
	end

	if not UNCOLLECTED_SHOWN and not PlayerHasHeirloom(data.itemID) then
		return false;
	end

	if classFlag and data.classFlags ~= 0 and bit.band(data.classFlags, classFlag) == 0 then
		return false;
	end

	if specFlag and bit.band(data.roleFlag, specFlag) == 0 then
		return false;
	end

	if not (sourceFiltersFlag == 0 or bit.band(sourceFiltersFlag, sourceFlag) ~= sourceFlag) then
		return false;
	end

	if FILTER_STRING ~= "" then
		if isGM then
			local searchID = tonumber(FILTER_STRING)
			if searchID and (searchID == data.itemID or searchID == data.spellID) then
				return true
			end
		end

		-- PATCH round 72 : la recherche comparait GetSpellInfo(data.spellID),
		-- toujours nil pour les memes raisons que le nom affiche (round 65) et
		-- le compteur (round 67) -- ces spellID retail n'existent pas en 3.3.5.
		-- Consequence : "not name" etait TOUJOURS vrai, donc CheckFilter
		-- renvoyait toujours false des qu'une recherche etait tapee -> 0/0
		-- systematique quel que soit le texte recherche. On compare
		-- desormais sur le vrai nom de l'item.
		local itemName = C_Item.GetItemInfo(data.itemID, false, nil, true, true);
		local name = itemName or GetSpellInfo(data.spellID);
		if not name or not string.find(string.lower(name), FILTER_STRING, 1, true) then
			return false;
		end
	end

	return true
end

local function SetFilteredHeirlooms()
	table.wipe(HEIRLOOMS);

	local sourceFiltersFlag = tonumber(GetCVar("heirloomSourceFilters")) or 0;
	local classFlag = CLASS_FILTER ~= 0 and bit.lshift(1, CLASS_FILTER - 1);
	local specFlag = SPEC_FILTER ~= 0 and HEIRLOOM_SPEC_ROLE_FLAG[SPEC_FILTER];
	local isGM = IsGMAccount()

	for i = 1, #COLLECTION_HEIRLOOMDATA do
		local data = COLLECTION_HEIRLOOMDATA[i];

		local sourceFlag = data.lootType ~= 0 and bit.lshift(1, ((data.currency ~= 0 and data.lootType ~= 15 and 7 or SOURCE_TYPES[data.lootType]) or 1) - 1) or 0;
		if data.holidayText ~= "" then
			sourceFlag = bit.bor(sourceFlag, bit.lshift(1, 6 - 1));
		end

		if CheckFilter(data, classFlag, specFlag, sourceFiltersFlag, sourceFlag, isGM) then
			HEIRLOOMS[#HEIRLOOMS + 1] = data;
		end
	end
end

function ReloadCollectionHearloomData()
	COLLECTION_HEIRLOOMDATA = _G.COLLECTION_HEIRLOOMDATA
end

-- PATCH round 29: PLAYER_LOGIN ne se declenche qu'a la toute premiere connexion.
-- Si ce fichier est charge apres (ex: /reload apres avoir installe le patch, ou
-- rechargement tardif du panneau Collections), HEIRLOOM_BY_ITEM_ID et HEIRLOOMS
-- restent vides pour toujours et Reliques affiche 0/0 en permanence.
-- On factorise la population dans une fonction idempotente et on la declenche
-- aussi bien sur PLAYER_LOGIN que sur PLAYER_ENTERING_WORLD (qui se declenche a
-- chaque /reload et chaque entree dans le monde), avec un garde pour ne le faire
-- qu'une seule fois "pour de vrai" (sauf si les donnees changent vraiment).
local heirloomDataPopulated = false;

local function PopulateHeirloomData()
	if not COLLECTION_HEIRLOOMDATA or #COLLECTION_HEIRLOOMDATA == 0 then
		-- Les donnees generees ne sont pas encore chargees (ne devrait pas arriver
		-- vu l'ordre du toc, mais on se protege quand meme) : on retentera au
		-- prochain evenement plutot que de planter ou de laisser HEIRLOOMS vide.
		return;
	end

	for i = 1, #COLLECTION_HEIRLOOMDATA do
		local data = COLLECTION_HEIRLOOMDATA[i];

		HEIRLOOM_BY_ITEM_ID[data.itemID] = data;
		if C_SpellBook and C_SpellBook.FilterOutSpellLearn then
			C_SpellBook.FilterOutSpellLearn(data.spellID)
		end
	end

	SetFilteredHeirlooms();

	heirloomDataPopulated = true;

	if FireCustomClientEvent then
		FireCustomClientEvent("HEIRLOOMS_UPDATED");
	end
end

local frame = CreateFrame("Frame");
frame:Hide();
frame:RegisterEvent("VARIABLES_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:SetScript("OnEvent", function(_, event)
	if event == "VARIABLES_LOADED" then
		COLLECTED_SHOWN = not GetCVarBitfield("heirloomCollectedFilters", HEIRLOOM_COLLECTED);
		UNCOLLECTED_SHOWN = not GetCVarBitfield("heirloomCollectedFilters", HEIRLOOM_UNCOLLECTED);
	elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
		if not heirloomDataPopulated then
			PopulateHeirloomData();
		end
	end
end);

C_Heirloom = {};

function C_Heirloom.GetNumLearnedHeirlooms()
	local num = 0;
	for i = 1, #COLLECTION_HEIRLOOMDATA do
		if PlayerHasHeirloom(COLLECTION_HEIRLOOMDATA[i].itemID) then
			num = num + 1;
		end
	end
	return num;
end

function C_Heirloom.GetNumDisplayedHeirlooms()
	return #HEIRLOOMS;
end

function C_Heirloom.GetNumLearnedHeirloomsForClass(classID)
	if type(classID) ~= "number" then
		error("Usage: C_Heirloom.GetNumLearnedHeirloomsForClass(classID)", 2);
	end

	local num = 0
	if classID then
		local classFlag = bit.lshift(1, classID - 1)

		for i = 1, #COLLECTION_HEIRLOOMDATA do
			local data = COLLECTION_HEIRLOOMDATA[i]
			if data.classFlags == 0 or bit.band(data.classFlags, classFlag) ~= 0 then
				if data.spellID and IsSpellKnown(data.spellID) then
					num = num + 1
				end
			end
		end
	end
	return num
end

function C_Heirloom.GetHeirloomItemIDFromDisplayedIndex(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: C_Heirloom.GetHeirloomItemIDFromDisplayedIndex(index)", 2);
	end

	return HEIRLOOMS[index] and HEIRLOOMS[index].itemID;
end

function C_Heirloom.GetHeirloomSpellID(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end

	if type(itemID) ~= "number" then
		error("Usage: local spellID = C_Heirloom.GetHeirloomSpellID(itemID)", 2);
	end

	local data = HEIRLOOM_BY_ITEM_ID[itemID];
	if data then
		return data.spellID;
	end
end

function C_Heirloom.GetHeirloomInfo(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end

	if type(itemID) ~= "number" then
		error("Usage: local name, itemEquipLoc, icon, descriptionText, priceText = C_Heirloom.GetHeirloomInfo(itemID)", 2);
	end

	local data = HEIRLOOM_BY_ITEM_ID[itemID];
	if data then
		-- PATCH round 65 : le nom affiche venait de GetSpellInfo(data.spellID),
		-- or ces spellID (ex: 320561) sont des sorts retail modernes absents du
		-- spell.dbc WotLK 3.3.5 -- GetSpellInfo() renvoie donc toujours nil, et
		-- le nom sous l'icone restait vide en permanence (contrairement aux
		-- Jouets, dont le nom vient de l'ITEM et pas du sort). On recupere
		-- desormais le nom directement depuis l'item lui-meme, qui lui existe
		-- reellement dans ce client -- avec repli sur le nom du sort puis sur
		-- l'itemID si l'item n'est pas encore en cache (meme filet de securite
		-- que C_ToyBox.GetToyInfo pour les Jouets).
		local itemName, _, _, _, _, _, _, _, itemEquipLoc, itemIcon = C_Item.GetItemInfo(data.itemID, false, nil, true, true);
		local name = itemName or GetSpellInfo(data.spellID) or tostring(data.itemID);
		local priceText;
		if data.factionSide == 2 then
			priceText = data.priceText:gsub("-Team.", "-Horde.");
		elseif data.factionSide == 1 then
			priceText = data.priceText:gsub("-Team.", "-Alliance.");
		else
			priceText = data.priceText:gsub("-Team.", "-"..(UnitFactionGroup("player"))..".");
		end

		return name, itemEquipLoc, itemIcon, data.descriptionText, priceText;
	end
end

function C_Heirloom.SetSearch(filterString)
	if type(filterString) ~= "string" then
		error("Usage: C_ToyBox.SetFilterString(filterString)", 2);
	end

	FILTER_STRING = string.lower(filterString);

	SetFilteredHeirlooms();
end

function C_Heirloom.SetClassAndSpecFilters(classID, specID)
	if type(classID) == "string" then
		classID = tonumber(classID);
	end

	if type(specID) == "string" then
		specID = tonumber(specID);
	end

	if type(classID) ~= "number" or type(specID) ~= "number" then
		error("Usage: C_Heirloom.SetClassAndSpecFilters(classID, specID)", 2);
	end

	CLASS_FILTER, SPEC_FILTER = classID, specID;

	SetFilteredHeirlooms();

	-- PATCH Collection (round 57) : contrairement a PopulateHeirloomData et
	-- au reste du systeme (favoris, etc.), cette fonction NE notifiait PAS
	-- l'UI apres avoir recalcule la liste filtree -- alors que
	-- HeirloomsMixin:OnShow() (Custom_HeirloomCollection.lua) l'appelle
	-- DIRECTEMENT (pas via le wrapper HeirloomsMixin:SetClassAndSpecFilters,
	-- qui lui fait bien self:FullRefreshIfVisible()) au tout premier
	-- affichage de l'onglet, pour appliquer le filtre "classe du joueur"
	-- par defaut. Resultat : #HEIRLOOMS (la liste filtree) devient correct
	-- (confirme par /hdebug : 24 pour Voleur) mais la grille ne se
	-- reconstruit jamais avec ces nouvelles donnees -- numPossibleHeirlooms
	-- reste bloque a 0 (sa valeur initiale) puisque RebuildLayoutData()
	-- n'est plus jamais redeclenche apres coup. On notifie donc ici aussi,
	-- comme le fait deja PopulateHeirloomData plus haut dans ce fichier.
	if FireCustomClientEvent then
		FireCustomClientEvent("HEIRLOOMS_UPDATED");
	end
end

function C_Heirloom.GetClassAndSpecFilters()
	return CLASS_FILTER, SPEC_FILTER;
end

-- PATCH round 29: expose l'etat interne pour /hdebug
function C_Heirloom.DebugState()
	return heirloomDataPopulated, (COLLECTION_HEIRLOOMDATA and #COLLECTION_HEIRLOOMDATA or 0), #HEIRLOOMS, CLASS_FILTER, SPEC_FILTER;
end

function C_Heirloom.SetHeirloomSourceFilter(index, checked)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" or checked == nil then
		error("Usage: C_Heirloom.SetHeirloomSourceFilter(index, checked)", 2);
	end
	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	if VALID_SOURCE_FILTERS[index] then
		SetCVarBitfield("heirloomSourceFilters", index, not checked);

		SetFilteredHeirlooms();
	end
end

function C_Heirloom.GetHeirloomSourceFilter(index)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" then
		error("Usage: local isChecked = C_Heirloom.GetHeirloomSourceFilter(index)", 2);
	end

	if GetCVarBitfield("heirloomSourceFilters", index) then
		return false;
	end

	return true;
end

function C_Heirloom.SetCollectedHeirloomFilter(checked)
	if checked == nil then
		error("Usage: C_Heirloom.SetCollectedHeirloomFilter(checked)", 2);
	end

	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	if checked ~= COLLECTED_SHOWN then
		SetCVarBitfield("heirloomCollectedFilters", HEIRLOOM_COLLECTED, not checked);

		COLLECTED_SHOWN = checked;

		SetFilteredHeirlooms();
	end
end

function C_Heirloom.GetCollectedHeirloomFilter()
	return COLLECTED_SHOWN;
end

function C_Heirloom.SetUncollectedHeirloomFilter(checked)
	if checked == nil then
		error("Usage: C_Heirloom.SetUncollectedHeirloomFilter(checked)", 2);
	end

	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	if checked ~= UNCOLLECTED_SHOWN then
		SetCVarBitfield("heirloomCollectedFilters", HEIRLOOM_UNCOLLECTED, not checked);

		UNCOLLECTED_SHOWN = checked;

		SetFilteredHeirlooms();
	end
end

function C_Heirloom.GetUncollectedHeirloomFilter()
	return UNCOLLECTED_SHOWN;
end

function C_Heirloom.CreateHeirloom()

end

function C_Heirloom.GetHeirloomItemIDs()

end

function C_Heirloom.GetHeirloomLink(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: local itemLink = C_Heirloom.GetHeirloomLink(index)", 2);
	end

	local heirloom = HEIRLOOM_BY_ITEM_ID[itemID];
	if heirloom and heirloom.itemID then
		local spellName = GetSpellInfo(heirloom.spellID);
		return string.format(COLLECTION_HEIRLOOM_HYPERLINK_FORMAT, heirloom.itemID, spellName or "");
	end

	return "";
end

function C_Heirloom.IsItemHeirloom(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: local isHeirloom = C_Heirloom.IsItemHeirloom(itemID)", 2);
	end

	if HEIRLOOM_BY_ITEM_ID[itemID] then
		return true;
	end

	return false;
end

function C_Heirloom.PlayerHasHeirloom(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: C_Heirloom.PlayerHasHeirloom(itemID)", 2);
	end

	return PlayerHasHeirloom(itemID);
end

C_HeirloomInfo = {};

function C_HeirloomInfo.SetDefaultFilters()
	SetCVar("heirloomCollectedFilters", "0");
	SetCVar("heirloomSourceFilters", "0");

	COLLECTED_SHOWN = true;
	UNCOLLECTED_SHOWN = true;

	SetFilteredHeirlooms();
end

function C_HeirloomInfo.IsUsingDefaultFilters()
	if tonumber(GetCVar("heirloomCollectedFilters")) ~= 0 or tonumber(GetCVar("heirloomSourceFilters")) ~= 0 then
		return false;
	end

 	return true;
end

function C_HeirloomInfo.IsHeirloomSourceValid(source)
	if type(source) == "string" then
		source = tonumber(source);
	end

	if type(source) ~= "number" then
		error("Usage: local isHeirloomSourceValid = C_HeirloomInfo.IsHeirloomSourceValid(source)", 2);
	end

	if VALID_SOURCE_FILTERS[source] then
		return true;
	end

	return false;
end

function C_HeirloomInfo.SetAllCollectionFilters(checked)
	if checked == nil then
		error("Usage: C_HeirloomInfo.SetAllCollectionFilters(checked)", 2);
	end

	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	SetCVarBitfield("heirloomCollectedFilters", HEIRLOOM_COLLECTED, true);
	SetCVarBitfield("heirloomCollectedFilters", HEIRLOOM_UNCOLLECTED, true);

	SetFilteredHeirlooms();
end

function C_HeirloomInfo.SetAllSourceFilters(checked)
	if checked == nil then
		error("Usage: C_HeirloomInfo.SetAllSourceFilters(checked)", 2);
	end

	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	for index in pairs(VALID_SOURCE_FILTERS) do
		SetCVarBitfield("heirloomSourceFilters", index, not checked);
	end

	SetFilteredHeirlooms();
end

function EventHandler:ASMSG_C_H_ADD(msg)
	local itemID = tonumber(msg);

	if itemID then
		AddChatTyppedMessage("SYSTEM", string.format(COLLECTION_HEIRLOOM_ADD_FORMAT, string.format(COLLECTION_HEIRLOOM_HYPERLINK_FORMAT, itemID, GetItemInfo(itemID) or "")));

		SetFilteredHeirlooms();

		FireCustomClientEvent("HEIRLOOMS_UPDATED", itemID, true);
		EventRegistry:TriggerEvent("Heirloom.Updated", itemID, true)
	end
end