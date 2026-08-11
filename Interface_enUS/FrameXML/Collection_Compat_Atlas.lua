-- Collection_Compat_Atlas.lua
-- Universe\SharedXML\AtlasStorage.lua (PRETTY_ATLAS_STORAGE) ne contient AUCUNE
-- entree "transmog-*" (0 vs 77 chez Sirus) : c'est pourquoi la grille du
-- Garde-robe (et les icones de la barre d'emplacements du Transmogrificateur)
-- n'affiche aucune bordure coloree, aucun cadre de selection, etc.
--
-- Ces 77 entrees sont copiees TELLES QUELLES depuis SharedXML\AtlasStorage.lua
-- de Sirus (donnees de coordonnees UV pures, aucun risque d'ecraser quoi que ce
-- soit d'existant puisqu'aucune de ces cles n'existe deja cote Universe).
--
-- IMPORTANT (round 51->52) : ecrire seulement dans PRETTY_ATLAS_STORAGE NE
-- SUFFISAIT PAS. SharedExtendedMethods.lua's Method_SetAtlas lit en realite
-- S_ATLAS_STORAGE (pas PRETTY_ATLAS_STORAGE), et Collection_Compat.lua fait
-- une fusion UNIQUE PRETTY_ATLAS_STORAGE -> S_ATLAS_STORAGE au moment de son
-- propre chargement (Collection_Compat.xml, ligne 58 du .toc) -- qui a lieu
-- AVANT le chargement de ce fichier-ci (ligne 59), donc nos 77 entrees
-- n'atteignaient jamais S_ATLAS_STORAGE et Method_SetAtlas ne trouvait rien
-- (no-op silencieux, aucune erreur, aucune bordure). On ecrit donc
-- desormais DIRECTEMENT dans les deux tables ici, ce qui rend ce fichier
-- independant de l'ordre de chargement.
--
-- Les images elles-memes (26 fichiers .tga : Transmogrify, TransmogSets,
-- TransmogSetsVendor, TransmogToast, TransmogBackground<Race>) sont des
-- fichiers BINAIRES fournis a part dans ce patch, sous le dossier
-- "Interface_Transmogrify" du zip -- a copier par le joueur (cote client)
-- dans Interface\Transmogrify\ (a cote de Interface\FrameXML et
-- Interface\SharedXML). Recuperes depuis ezCollectionsSyphrena.zip (dossier
-- ezCollections/Interface/Transmogrify/), qui les avait deja au format .tga
-- (charge nativement par le client, pas besoin de conversion .blp). Seule
-- l'entree "transmog-background-race-eredar" (race Eredar, non jouable) n'a
-- pas de texture correspondante disponible -- sans impact puisque cette race
-- n'existe ni cote Sirus ni cote Universe.

local TRANSMOG_ATLAS_ENTRIES = {
	["transmog-toast-bg"] = {253, 75, 0.003906, 0.992188, 0.007813, 0.593750, false, false, "Interface/Transmogrify/TransmogToast"},
	["transmog-set-iconrow-background"] = {418, 64, 0.001953, 0.818359, 0.707031, 0.957031, false, false, "Interface/Transmogrify/TransmogSets"},
	["transmog-set-model-cutoff-fade"] = {403, 178, 0.001953, 0.789062, 0.003906, 0.699219, false, false, "Interface/Transmogrify/TransmogSets"},
	["transmog-set-border-unusable"] = {144, 200, 0.302734, 0.583984, 0.001953, 0.392578, false, false, "Interface/Transmogrify/TransmogSetsVendor"},
	["transmog-set-border-collected"] = {152, 208, 0.001953, 0.298828, 0.001953, 0.408203, false, false, "Interface/Transmogrify/TransmogSetsVendor"},
	["transmog-set-border-highlighted"] = {132, 188, 0.564453, 0.822266, 0.396484, 0.763672, false, false, "Interface/Transmogrify/TransmogSetsVendor"},
	["transmog-set-border-current-transmogged"] = {132, 188, 0.587891, 0.845703, 0.001953, 0.369141, false, false, "Interface/Transmogrify/TransmogSetsVendor"},
	["transmog-set-border-current"] = {132, 188, 0.302734, 0.560547, 0.396484, 0.763672, false, false, "Interface/Transmogrify/TransmogSetsVendor"},
	["transmog-set-border-selected"] = {150, 206, 0.001953, 0.294922, 0.412109, 0.814453, false, false, "Interface/Transmogrify/TransmogSetsVendor"},
	["transmog-icon-hidden"] = {36, 30, 0.804688, 0.875000, 0.171875, 0.230469, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-frame-small"] = {40, 40, 0.736328, 0.814453, 0.001953, 0.080078, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-wardrobe-border-selected-smoke"] = {19, 65, 0.373047, 0.410156, 0.248047, 0.375000, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-icon-downarrow"] = {15, 9, 0.330078, 0.359375, 0.687500, 0.705078, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-selected"] = {45, 47, 0.205078, 0.292969, 0.898438, 0.990234, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-wardrobe-border-selected-wisp"] = {28, 19, 0.638672, 0.693359, 0.248047, 0.285156, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-icon-chat"] = {13, 13, 0.330078, 0.355469, 0.658203, 0.683594, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-icon-revert-small-disabled"] = {25, 24, 0.585938, 0.634766, 0.248047, 0.294922, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-feet"] = {35, 37, 0.523438, 0.591797, 0.093750, 0.166016, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-secondaryhand"] = {35, 37, 0.884766, 0.953125, 0.093750, 0.166016, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-frame-selected"] = {62, 62, 0.205078, 0.326172, 0.658203, 0.779297, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-frame-red"] = {44, 43, 0.556641, 0.642578, 0.001953, 0.085938, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-frame-small-selected"] = {40, 40, 0.818359, 0.896484, 0.001953, 0.080078, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-legs"] = {35, 37, 0.740234, 0.808594, 0.093750, 0.166016, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-frame-pink"] = {44, 43, 0.466797, 0.552734, 0.001953, 0.085938, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-wardrobe-border-current-transmogged"] = {84, 110, 0.205078, 0.369141, 0.220703, 0.435547, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-wardrobe-border-highlighted"] = {84, 110, 0.205078, 0.369141, 0.439453, 0.654297, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-chest"] = {35, 37, 0.451172, 0.519531, 0.093750, 0.166016, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-wardrobe-border-current"] = {84, 110, 0.205078, 0.369141, 0.001953, 0.216797, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-wardrobe-border-uncollected"] = {96, 122, 0.001953, 0.189453, 0.498047, 0.736328, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-frame-highlighted"] = {44, 41, 0.646484, 0.732422, 0.001953, 0.082031, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-icon-revert-small"] = {25, 24, 0.533203, 0.582031, 0.248047, 0.294922, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-wardrobe-border-selected"] = {102, 128, 0.001953, 0.201172, 0.001953, 0.251953, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-frame-blackcover"] = {46, 45, 0.373047, 0.462891, 0.001953, 0.089844, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-wardrobe-border-unusable"] = {96, 122, 0.001953, 0.189453, 0.740234, 0.978516, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-hands"] = {35, 37, 0.595703, 0.664062, 0.093750, 0.166016, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-selected-small"] = {34, 35, 0.734375, 0.800781, 0.171875, 0.240234, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-enchant"] = {29, 29, 0.414062, 0.470703, 0.248047, 0.304688, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-shirt"] = {35, 37, 0.373047, 0.441406, 0.171875, 0.244141, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-wrist"] = {35, 37, 0.662109, 0.730469, 0.171875, 0.244141, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-ranged"] = {35, 37, 0.740234, 0.808594, 0.240500, 0.310066, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-tabard"] = {35, 37, 0.517578, 0.585938, 0.171875, 0.244141, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-frame"] = {58, 57, 0.205078, 0.318359, 0.783203, 0.894531, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-waist"] = {35, 37, 0.589844, 0.658203, 0.171875, 0.244141, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-back"] = {35, 37, 0.296875, 0.365234, 0.898438, 0.970703, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-shoulder"] = {35, 37, 0.445312, 0.513672, 0.171875, 0.244141, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-mainhand"] = {35, 37, 0.812500, 0.880859, 0.093750, 0.166016, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-icon-checkmark"] = {28, 26, 0.474609, 0.529297, 0.248047, 0.298828, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-nav-slot-head"] = {35, 37, 0.667969, 0.736328, 0.093750, 0.166016, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-frame-small-red"] = {38, 38, 0.373047, 0.447266, 0.093750, 0.167969, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-wardrobe-border-collected"] = {96, 122, 0.001953, 0.189453, 0.255859, 0.494141, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-icon-revert"] = {32, 32, 0.878906, 0.941406, 0.171875, 0.234375, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-frame-small-pink"] = {38, 38, 0.900391, 0.974609, 0.001953, 0.076172, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-frame-highlighted-small"] = {24, 24, 0.322266, 0.369141, 0.783203, 0.830078, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-icon-remove"] = {26, 26, 0.945312, 0.996094, 0.171875, 0.222656, false, false, "Interface/Transmogrify/Transmogrify"},
	["transmog-background-race-bloodelf"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundBloodElf"},
	["transmog-background-race-darkirondwarf"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundDarkIronDwarf"},
	["transmog-background-race-dracthyr"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundDracthyr"},
	["transmog-background-race-draenei"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundDraenei"},
	["transmog-background-race-dwarf"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundDwarf"},
	["transmog-background-race-eredar"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundBloodEredar"},
	["transmog-background-race-gnome"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundGnome"},
	["transmog-background-race-goblin"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundGoblin"},
	["transmog-background-race-highmountaintauren"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundHighmountain"},
	["transmog-background-race-human"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundHuman"},
	["transmog-background-race-lightforged"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundLightforged"},
	["transmog-background-race-magharorc"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundMaghar"},
	["transmog-background-race-nightborne"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundNightborne"},
	["transmog-background-race-nightelf"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundNightElf"},
	["transmog-background-race-orc"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundOrc"},
	["transmog-background-race-pandaren"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundPandaren"},
	["transmog-background-race-tauren"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundTauren"},
	["transmog-background-race-troll"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundTroll"},
	["transmog-background-race-undead"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundUndead"},
	["transmog-background-race-voidelf"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundVoidElf"},
	["transmog-background-race-vulpera"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundVulpera"},
	["transmog-background-race-worgen"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundWorgen"},
	["transmog-background-race-zandalaritroll"] = {294, 494, 0.001953, 0.576172, 0.001953, 0.966797, false, false, "Interface/Transmogrify/TransmogBackgroundZandalari"},
}

PRETTY_ATLAS_STORAGE = PRETTY_ATLAS_STORAGE or {}
S_ATLAS_STORAGE = S_ATLAS_STORAGE or {}
for atlasName, atlasData in pairs(TRANSMOG_ATLAS_ENTRIES) do
	if not PRETTY_ATLAS_STORAGE[atlasName] then
		PRETTY_ATLAS_STORAGE[atlasName] = atlasData;
	end
	if not S_ATLAS_STORAGE[atlasName] then
		S_ATLAS_STORAGE[atlasName] = atlasData;
	end
end

-- ROUND 74 : meme probleme, meme fix, pour la feuille de sprites partagee
-- Interface\Collections\Collections.blp (deja presente cote Universe -- le
-- fichier existe bel et bien, seules ses coordonnees UV/atlas manquaient).
-- Sans ces entrees, SetAtlas(...) est un no-op silencieux : les icones
-- Jouets/Heritage/Montures/Familiers restent de simples carres sans le
-- cadre dore Blizzard (collections-itemborder-*), et les en-tetes de
-- categorie ("EPAULE", "TORSE", etc.) restent du texte nu sans le bandeau
-- (collections-slotheader) qui va derriere. Copiees telles quelles depuis
-- SharedXML\AtlasStorage.lua de Sirus.
local COLLECTIONS_UI_ATLAS_ENTRIES = {
	["_collections-background-line"] = {512, 4, 0.000000, 1.000000, 0.001953, 0.009766, true, true, "Interface/Collections/Collections"},
	["collections-background-corner"] = {90, 67, 0.001953, 0.177734, 0.013672, 0.144531, false, false, "Interface/Collections/Collections"},
	["collections-background-filagree"] = {151, 109, 0.001953, 0.296875, 0.199219, 0.412109, false, false, "Interface/Collections/Collections"},
	["collections-background-shadow-large"] = {145, 147, 0.181641, 0.464844, 0.416016, 0.703125, false, false, "Interface/Collections/Collections"},
	["collections-background-shadow-small"] = {13, 13, 0.181641, 0.207031, 0.082031, 0.107422, false, false, "Interface/Collections/Collections"},
	["collections-icon-favorites"] = {31, 33, 0.181641, 0.242188, 0.013672, 0.078125, false, false, "Interface/Collections/Collections"},
	["collections-itemborder-collected"] = {56, 56, 0.246094, 0.355469, 0.013672, 0.123047, false, false, "Interface/Collections/Collections"},
	["collections-itemborder-uncollected"] = {100, 100, 0.300781, 0.496094, 0.199219, 0.394531, false, false, "Interface/Collections/Collections"},
	["collections-itemborder-uncollected-innerglow"] = {42, 41, 0.359375, 0.441406, 0.013672, 0.093750, false, false, "Interface/Collections/Collections"},
	["collections-levelplate-black"] = {32, 21, 0.359375, 0.421875, 0.097656, 0.138672, false, false, "Interface/Collections/Collections"},
	["collections-levelplate-gold"] = {32, 21, 0.445313, 0.507813, 0.013672, 0.054688, false, false, "Interface/Collections/Collections"},
	["collections-newglow"] = {59, 37, 0.511719, 0.626953, 0.013672, 0.085938, false, false, "Interface/Collections/Collections"},
	["collections-slotheader"] = {490, 24, 0.001953, 0.958984, 0.148438, 0.195313, false, false, "Interface/Collections/Collections"},
	["collections-upgradeglow"] = {100, 100, 0.500000, 0.695313, 0.199219, 0.394531, false, false, "Interface/Collections/Collections"},
	["collections-upgradeglow-blue"] = {100, 100, 0.699219, 0.894531, 0.199219, 0.394531, false, false, "Interface/Collections/Collections"},
	["collections-watermark-heirloom"] = {90, 92, 0.001953, 0.177734, 0.416016, 0.595703, false, false, "Interface/Collections/Collections"},
	["collections-watermark-toy"] = {109, 110, 0.181641, 0.394531, 0.707031, 0.921875, false, false, "Interface/Collections/Collections"},
}

for atlasName, atlasData in pairs(COLLECTIONS_UI_ATLAS_ENTRIES) do
	if not PRETTY_ATLAS_STORAGE[atlasName] then
		PRETTY_ATLAS_STORAGE[atlasName] = atlasData;
	end
	if not S_ATLAS_STORAGE[atlasName] then
		S_ATLAS_STORAGE[atlasName] = atlasData;
	end
end
