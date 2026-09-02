CLASS_DISABLED = "Vous devez choisir une race différente pour être cette classe.";
CUSTOMIZE = "Apparence";
NEXT = "Apparence";
FINISH = "Terminer";
TATTOOS = "Tatouage";
HORN_STYLE = "Cornes";
BLINDFOLD = "Bandeau sur les yeux";
TATTOO_COLOR = "Couleurs de tatouage";


CHARACTER_FACING_INCREMENT = 2;
MAX_RACES = 31;
MAX_CLASSES_PER_RACE = 24;
NUM_CHAR_CUSTOMIZATIONS = 5;
MIN_CHAR_NAME_LENGTH = 2;
CHARACTER_CREATE_ROTATION_START_X = nil;
CHARACTER_CREATE_INITIAL_FACING = nil;
NUM_PREVIEW_FRAMES = 24; -- 14
WORGEN_RACE_ID = 6;
TUSKARR_RACE_ID = 6;
local featureIndex = 1
local FeatureType = 1

PAID_CHARACTER_CUSTOMIZATION = 1;
PAID_RACE_CHANGE = 3;
PAID_FACTION_CHANGE = 2;
PAID_SERVICE_CHARACTER_ID = nil;
PAID_SERVICE_TYPE = nil;

PREVIEW_FRAME_HEIGHT = 130;
PREVIEW_FRAME_X_OFFSET = 19;
PREVIEW_FRAME_Y_OFFSET = -7;

FACTION_BACKDROP_COLOR_TABLE = {
	["Alliance"] = {0.5, 0.5, 0.5, 0.09, 0.09, 0.19, 0, 0, 0.2, 0.29, 0.33, 0.91},
	["Horde"] = {0.5, 0.2, 0.2, 0.19, 0.05, 0.05, 0.2, 0, 0, 0.90, 0.05, 0.07},
	["Player"] = {0.2, 0.5, 0.2, 0.05, 0.2, 0.05, 0.05, 0.2, 0.05, 1, 1, 1},
};
FRAMES_TO_BACKDROP_COLOR = {
	"CharacterCreateCharacterRace",
	"CharacterCreateCharacterClass",
--	"CharacterCreateCharacterFaction",
	"CharacterCreateNameEdit",
};
RACE_ICON_TCOORDS = {
	["HUMAN_MALE"] = {0, 0.0625, 0, 0.25},
	["DWARF_MALE"] = {0.0625, 0.125, 0, 0.25},
	["GNOME_MALE"] = {0.125, 0.1875, 0, 0.25},
	["NIGHTELF_MALE"] = {0.1875, 0.25, 0, 0.25},

	["TAUREN_MALE"] = {0, 0.0625, 0.25, 0.5},
	["SCOURGE_MALE"] = {0.0625, 0.125, 0.25, 0.5},
	["TROLL_MALE"] = {0.125, 0.1875, 0.25, 0.5},
	["ORC_MALE"] = {0.1875, 0.25, 0.25, 0.5},

	["HUMAN_FEMALE"] = {0, 0.0625, 0.5, 0.75},
	["DWARF_FEMALE"] = {0.0625, 0.125, 0.5, 0.75},
	["GNOME_FEMALE"] = {0.125, 0.1875, 0.5, 0.75},
	["NIGHTELF_FEMALE"] = {0.1875, 0.25, 0.5, 0.75},

	["TAUREN_FEMALE"] = {0, 0.0625, 0.75, 1.0},
	["SCOURGE_FEMALE"] = {0.0625, 0.125, 0.75, 1.0},
	["TROLL_FEMALE"] = {0.125, 0.1875, 0.75, 1.0},
	["ORC_FEMALE"] = {0.1875, 0.25, 0.75, 1.0},

	["BLOODELF_MALE"] = {0.25, 0.3125, 0.25, 0.5},
	["BLOODELF_FEMALE"] = {0.25, 0.3125, 0.75, 1.0},

	["DRAENEI_MALE"] = {0.25, 0.3125, 0, 0.25},
	["DRAENEI_FEMALE"] = {0.25, 0.3125, 0.5, 0.75},

	["WORGEN_MALE"] = {0.3125, 0.375, 0, 0.25},
	["WORGEN_FEMALE"] = {0.3125, 0.375, 0.5, 0.75},

	["GOBLIN__MALE"] = {0.3125, 0.375, 0.25, 0.5},
	["GOBLIN__FEMALE"] = {0.3125, 0.375, 0.75, 1.0},
	
	["EREDAR_MALE"] = {0.375, 0.4375, 0, 0.25},
	["EREDAR_FEMALE"] = {0.375, 0.4375, 0.5, 0.75},

	["PANDAREN_A_MALE"] = {0.6250, 0.5625, 0.25, 0.5},
    ["PANDAREN_A_FEMALE"] = {0.6250, 0.5625, 0.75, 1.0},
	
	["PANDAREN_H_MALE"] = {0.5625, 0.6250, 0.25, 0.5},
	["PANDAREN_H_FEMALE"] = {0.5625, 0.6250, 0.75, 1.0},

	["VOIDELF_MALE"] = {0.4375, 0.5, 0, 0.25},
	["VOIDELF_FEMALE"] = {0.4375, 0.5, 0.5, 0.75},
	
	["DARKIRONDWARF_MALE"] = {0.5625, 0.6250, 0, 0.25},
	["DARKIRONDWARF_FEMALE"] = {0.5625, 0.6260, 0.5, 0.75},

	["NIGHTBORNE_MALE"] = {0.375, 0.4375, 0.25, 0.5},
	["NIGHTBORNE_FEMALE"] = {0.375, 0.4375, 0.75, 1.0},

	["VULPERA_MALE"] = {0.4375, 0.5, 0.25, 0.5},
	["VULPERA_FEMALE"] = {0.4375, 0.5, 0.75, 1.0},

	["BLOODELF_DH_MALE"] = {0.5, 0.5625, 0.25, 0.5},
	["BLOODELF_DH_FEMALE"] = {0.5, 0.5625, 0.75, 1.0},

	["NIGHTELF_DH_MALE"] = {0.5, 0.5625, 0, 0.25},
	["NIGHTELF_DH_FEMALE"] = {0.5, 0.5625, 0.5, 0.75},
	
	["LIGHTFORGED_MALE"] = {0.6900, 0.6258, 0.25, 0.5},
	["LIGHTFORGED_FEMALE"] = {0.6900, 0.6258, 0.75, 1.0},
	
	["ZANDALARITROLL_MALE"] = {0.7525, 0.6890, 0.25, 0.5},
	["ZANDALARITROLL_FEMALE"] = {0.7525, 0.6890, 0.75, 1.0},
	
	["DARKIRONDWARF_H_MALE"] = {0.8150, 0.7510, 0.25, 0.5},
	["DARKIRONDWARF_H_FEMALE"] = {0.8150, 0.7510, 0.75, 1.0},
	
	["HIGHELF_MALE"] = {0.6252, 0.6880, 0, 0.25},
	["HIGHELF_FEMALE"] = {0.6262, 0.6890, 0.5, 0.75},

	["HIGHMOUNTAINTAUREN_MALE"] = {0.8780, 0.8150, 0.25, 0.5},
	["HIGHMOUNTAINTAUREN_FEMALE"] = {0.8780, 0.8150, 0.75, 1.0},

	["VULPERA_A_MALE"] = {0.6885, 0.7500, 0, 0.25},
	["VULPERA_A_FEMALE"] = {0.6905, 0.7525, 0.5, 0.75},
	
	["DRACTHYR_H_MALE"] = {0.8750, 0.8115, 0, 0.25},
	["DRACTHYR_H_FEMALE"] = {0.8780, 0.8160, 0.5, 0.75},
	
	["DRACTHYR_A_MALE"] = {0.7500, 0.8125, 0.0000, 0.2500},
	["DRACTHYR_A_FEMALE"] = {0.7550, 0.8150, 0.5, 0.75},
	
	["MAGHAR_MALE"] = {0.9395, 0.8775, 0.25, 0.5},
	["MAGHAR_FEMALE"] = {0.9395, 0.8775, 0.75, 1.0},
	
	["KULTIRAN_MALE"] = {0.9380, 0.8760, 0, 0.25},
	["KULTIRAN_FEMALE"] = {0.9445, 0.8795, 0.5, 0.75},
};
CLASS_ICON_TCOORDS = {
	["WARRIOR"]	= {0, 0.125, 0, 0.125},
	["MAGE"] = {0.75, 0.875, 0, 0.125},
	["ROGUE"] = {0.25, 0.375, 0.125, 0.25},
	["DRUID"] = {0.875, 1, 0, 0.125},
	["EVOKER"] = {0, 0.125, 0.125, 0.25},
	["HUNTER"] = {0.75, 0.875, 0.125, 0.25},
	["SHAMAN"] = {0.5, 0.625, 0.375, 0.5},
	["PRIEST"] = {0.25, 0.372, 0, 0.125},
	["WARLOCK"] = {0.5, 0.625, 0.125, 0.25},
	["PALADIN"] = {0.25, 0.375, 0.25 , 0.375},
	["DEATHKNIGHT"]	= {0.5, 0.625, 0.25, 0.375},
	["MONK"] = {0.125, 0.25, 0, 0.125},
	["DEMONHUNTER"] = {0.375, 0.5, 0, 0.125},
	["KNIGHT"] = {0.625, 0.75, 0, 0.125},
	["BLOODMAGE"] = {0.625, 0.75, 0.25, 0.375},
	["TAMER"] = {0.5, 0.625, 0, 0.125},
	["HERO"] = {0.375, 0.5, 0.125, 0.25},
	["CHRONOMANCER"] = {0.125, 0.25, 0.25, 0.375},
    ["GEOMANCER"] = {0.125, 0.25, 0.25, 0.375},
	["NECROMANCER"] = {0.125, 0.25, 0.25, 0.375},
	["PYROMANCER"] = {0.125, 0.25, 0.25, 0.375},
	["VENOMANCER"] = {0.125, 0.25, 0.25, 0.375},
	["CHAOSRAVAGER"] = {0, 0.125, 0.5, 0.625},
	["UNKCLASS"] = {0, 0, 0, 0},
	
--	["SLOT"] = {0, 0.125, 0.5, 0.625}, -- USED CHAOSRAVAGER
--	["SLOT"] = {0.125, 0.25, 0.5, 0.625},
--	["SLOT"] = {0.625, 0.75, 0.375, 0.5},
--  ["SLOT"] = {0.125, 0.25, 0.375, 0.5},
--	["SLOT"] = {0.625, 0.75, 0.125, 0.25},
--	["SLOT"] = {0.375, 0.5, 0.25, 0.375},
};

BANNER_DEFAULT_TEXTURE_COORDS = {0.109375, 0.890625, 0.201171875, 0.80078125};
BANNER_DEFAULT_SIZE = {200, 308};

CHAR_CUSTOMIZE_HAIR_COLOR = 4;

function CharacterCreate_Body()	

	local _,_,currClass = GetSelectedClass();
    if (currClass < 31 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 30 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 29 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 28 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 27 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 26 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 25 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 24 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 23 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 22 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 21 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 20 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 19 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 18 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 17 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 16 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 15 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 14 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 13 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end
	
	local _,_,currClass = GetSelectedClass();
	if (currClass == 12 or forceSelect ) then
    CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Show(); -- Tattoo Colors
	CharCreateCustomizationButton8:Show(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end	
end

function CharacterCreate_Face()	

	local _,_,currClass = GetSelectedClass();
    if (currClass < 31 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 30 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 29 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 28 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 27 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 26 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 25 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 24 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 23 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 22 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 21 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 20 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 19 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 18 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 17 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 16 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 15 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 14 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 13 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end
	
	local _,_,currClass = GetSelectedClass();
	if (currClass == 12 or forceSelect ) then
    CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Show(); -- Face
	CharCreateCustomizationButton3:Show(); -- Hair Style
	CharCreateCustomizationButton4:Show(); -- Hair Color
	CharCreateCustomizationButton5:Show(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Show(); -- Horns
	CharCreateCustomizationButton10:Show(); -- Blindfolders
	end	
end

function CharacterCreate_BodyHIDE()	
	local _,_,currClass = GetSelectedClass();
    if (currClass < 31 or forceSelect ) then
	CharCreateCustomizationButton1:Hide(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end
end


function CharacterCreate_OPTHIDE()
end

function CharacterCreate_OnLoad(self)
	self:RegisterEvent("RANDOM_CHARACTER_NAME_RESULT");
	self:RegisterEvent("GLUE_UPDATE_EXPANSION_LEVEL");

	self:SetSequence(0);
	self:SetCamera(0);

	CharacterCreate.numRaces = 0;
	CharacterCreate.selectedRace = 0;
	CharacterCreate.numClasses = 0;
	CharacterCreate.selectedClass = 0;
	CharacterCreate.selectedGender = 0;
	CharacterCreate.selectedStartZone = "azeroth";
	CharacterCreate.selectedGearTier = "none";

	SetCharCustomizeFrame("CharacterCreate");

	for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
		_G["CharCreateCustomizationButton"..i].text:SetText(_G["CHAR_CUSTOMIZATION"..i.."_DESC"]);
	end

	-- Color edit box backdrop
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE["Alliance"];
	CharacterCreateNameEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	CharacterCreateNameEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	--[[CharacterCreateNameEdit:SetParent(CharacterCreateFrame)
	CharacterCreateNameEdit:SetPoint("TOPLEFT", CharacterCreateFrame, 635, -30)]]--
	CharCreateCustomizationFrame:SetPoint("RIGHT", CharacterCreateFrame, -50, -10)

	CharacterCreateFrame.state = "CLASSRACE";

	CharCreatePreviewFrame.previews = { };

	CustomizationBG = CharacterCreateFrame:CreateTexture("CustomizationBG", "BACKGROUND")
	CustomizationBG:SetSize(512, GlueParent:GetHeight())
    CustomizationBG:SetTexture("Interface\\Glues\\CharacterCreate\\Shadowv")
    CustomizationBG:SetPoint("RIGHT")
    CustomizationBG:Hide()

	CustomizationBG2 = CharacterCreateFrame:CreateTexture("CustomizationBG2", "BACKGROUND")
	CustomizationBG2:SetSize(GlueParent:GetWidth(), GlueParent:GetHeight())
    CustomizationBG2:SetTexture("Interface\\Glues\\CharacterCreate\\MainShadow")
    CustomizationBG2:SetPoint("CENTER")
    CustomizationBG2:SetAlpha(1)

	CustomizationLogoAlliance = CharacterCreateFrame:CreateTexture("CustomizationLogoAlliance", "ARTWORK")
	CustomizationLogoAlliance:SetSize(100, 100)
    CustomizationLogoAlliance:SetTexture("Interface\\Glues\\CharacterCreate\\AllianceLogo")
    CustomizationLogoAlliance:SetPoint("TOPLEFT", -16, 16)

	CustomizationTextAlliance = CharacterCreateFrame:CreateFontString("CustomizationTextAlliance", "OVERLAY")
    CustomizationTextAlliance:SetFontObject(GlueFontNormal)
    CustomizationTextAlliance:SetFont("Fonts\\FRIZQT__.TTF", 16)
    CustomizationTextAlliance:SetText(string.upper(ALLIANCE))
    CustomizationTextAlliance:SetPoint("LEFT", CustomizationLogoAlliance, "RIGHT", -24, 0)

	CustomizationLogoHorde = CharacterCreateFrame:CreateTexture("CustomizationLogoHorde", "ARTWORK")
	CustomizationLogoHorde:SetSize(100, 100)
    CustomizationLogoHorde:SetTexture("Interface\\Glues\\CharacterCreate\\HordeLogo")
    CustomizationLogoHorde:SetPoint("TOPRIGHT", 16, 16)
	  
	CustomizationTextHorde = CharacterCreateFrame:CreateFontString("CustomizationTextHorde", "OVERLAY")
    CustomizationTextHorde:SetFontObject(GlueFontNormal)
    CustomizationTextHorde:SetFont("Fonts\\FRIZQT__.TTF", 16)
    CustomizationTextHorde:SetText(string.upper(HORDE))
    CustomizationTextHorde:SetPoint("RIGHT", CustomizationLogoHorde, "LEFT", 24, 0)
end

function CharCustomizeButtonClick(id, button)
	if (button == 'LeftButton') then
		for i = 1, math.random(1, 5) do
			CharacterCustomization_Left(id)
		end
	elseif (button == 'RightButton') then
		for i = 1, math.random(1, 5) do
			CharacterCustomization_Right(id)
		end
	end
	-- CycleCharCustomization(id, 1);
	--[[FeatureType = id
	for i=1,5 do
		_G["CharCreateCustomizationButton"..i]:SetChecked(0);
	end
	_G["CharCreateCustomizationButton"..id]:SetChecked(1);]]

end

function CharacterCreate_OnShow()
	for i=1, MAX_CLASSES_PER_RACE, 1 do
		local button = _G["CharCreateClassButton"..i];
		button:Enable();
		--button:SetScale(0.8)
		SetButtonDesaturated(button, false)
	end

	for i=1, MAX_RACES, 1 do
		local button = _G["CharCreateRaceButton"..i];
		button:Enable();
		--button:SetScale(0.8)
		SetButtonDesaturated(button, false)
	end

	if ( PAID_SERVICE_TYPE ) then
		CustomizeExistingCharacter( PAID_SERVICE_CHARACTER_ID );
		CharacterCreateNameEdit:SetText( PaidChange_GetName() );
	else
		--randomly selects a combination
		ResetCharCustomize();
		CharacterCreateNameEdit:SetText("");
		CharCreateRandomizeButton:Show();
	end

	CharacterCreateEnumerateRaces(GetAvailableRaces());
	SetCharacterRace(GetSelectedRace());

	CharacterCreateEnumerateClasses(GetAvailableClasses());
	local_,_,index = GetSelectedClass();
	SetCharacterClass(index);

	--[[if ( GetSelectedRace() == TUSKARR_RACE_ID ) then
		SetCharacterGender(SEX_MALE);
		CharCreateMaleButton:SetChecked(1);
		CharCreateFemaleButton:SetChecked(0);
	else]]
	SetCharacterGender(GetSelectedSex());
	--end

	-- Hair customization stuff
	CharacterCreate_UpdateHairCustomization();

	SetCharacterCreateFacing(-15);
	CharacterCreate_ResetZoom();

	-- setup customization
	CharacterChangeFixup();

	--SetFaceCustomizeCamera(false);
		local _,_,currClass = GetSelectedClass();
	
	if ( currClass == 13 or forceSelect ) then
		local backgroundFilename = GetCreateBackgroundModel(faction);
			backgroundFilename = "DEMONHUNTER"
		SetBackgroundModel(CharacterCreate, backgroundFilename);
		CHARACTER_CREATE_SPECIAL_BACKGROUND = true;
	end
	
end

function CharacterCreate_OnHide()
	PAID_SERVICE_CHARACTER_ID = nil;
	PAID_SERVICE_TYPE = nil;
	if ( CharacterCreateFrame.state == "CUSTOMIZATION" ) then
		CharacterCreate_Back();
		CharacterCreate_BodyHIDE();
	end
	-- character previews will need to be redone if coming back to character create. One reason is all the memory used for
	-- tracking the frames (on the c side) will get released if the user returns to the login screen
	CharCreatePreviewFrame.rebuildPreviews = true;
end

function CharacterCreate_OnEvent(event, arg1, arg2, arg3)
	if ( event == "RANDOM_CHARACTER_NAME_RESULT" ) then
		if ( arg1 == 0 ) then
			-- Failed.  Generate a random name locally.
			CharacterCreateNameEdit:SetText(GenerateRandomName());
		else
			-- Succeeded.  Use what the server sent.
			CharacterCreateNameEdit:SetText(arg2);
		end
		CharacterCreateRandomName:Enable();
		CharCreateOkayButton:Enable();
		PlaySound("gsCharacterCreationLook");
	elseif ( event == "GLUE_UPDATE_EXPANSION_LEVEL" ) then
		-- Expansion level changed while online, so enable buttons as needed
		if ( CharacterCreateFrame:IsShown() ) then
			CharacterCreateEnumerateRaces(GetAvailableRaces());
			CharacterCreateEnumerateClasses(GetAvailableClasses());
		end
	end
end

function CharacterCreateFrame_OnMouseDown(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition();
		CHARACTER_CREATE_INITIAL_FACING = GetCharacterCreateFacing();
	end
end

function CharacterCreateFrame_OnMouseUp(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = nil
	end
end

function CharacterCreateFrame_OnUpdate(self, elapsed)
	if ( CHARACTER_CREATE_ROTATION_START_X ) then
		local x = GetCursorPosition();
		local diff = (x - CHARACTER_CREATE_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition();
		SetCharacterCreateFacing(GetCharacterCreateFacing() + diff);
		CharCreate_RotatePreviews();
	end
	CharacterCreateWhileMouseDown_Update(elapsed);
end

CHARACTER_CREATE_ZOOM_OFFSET = 0;
CHARACTER_CREATE_ZOOM_TARGET_OFFSET = 0;

CHARACTER_CREATE_ZOOM_API_PROBE_DONE = false;
CHARACTER_CREATE_ZOOM_HAS_MODEL_SCALE = false;
CHARACTER_CREATE_ZOOM_HAS_PORTRAIT_ZOOM = false;

CHARACTER_CREATE_ZOOM_MIN = 0;

CHARACTER_CREATE_ZOOM_MAX = 5.0;
CHARACTER_CREATE_ZOOM_STEP = 0.56;
CHARACTER_CREATE_ZOOM_SMOOTHING = 0.05;
CHARACTER_CREATE_ZOOM_FACE_SHIFT_MAX = 0.8;
CHARACTER_CREATE_ZOOM_FACE_BIAS_RATIO = 1.0;
CHARACTER_CREATE_ZOOM_SCALE_BOOST_MAX = 0.10;
CHARACTER_CREATE_ZOOM_DEFAULT_DIRECTION = {x = 1, y = 0, z = 0};
CHARACTER_CREATE_ZOOM_DIRECTION_BY_BACKDROP = {
	["Alliance"] = {x = -1.0, y = 0.75, z = 0.0},
	["Horde"] = {x = -1.0, y = 0.70, z = 0.0},
};

CHARACTER_CREATE_ZOOM_DIRECTION_OVERRIDE = nil;
CHARACTER_CREATE_ZOOM_CALIBRATION_INDEX = 0;
CHARACTER_CREATE_ZOOM_CALIBRATION_TEST_OFFSET = CHARACTER_CREATE_ZOOM_MAX;
CHARACTER_CREATE_ZOOM_CALIBRATION_CANDIDATES = {
	{x =  1, y =  0, z =  0},
	{x = -1, y =  0, z =  0},
	{x =  0, y =  1, z =  0},
	{x =  0, y = -1, z =  0},
	{x =  0, y =  0, z =  1},
	{x =  0, y =  0, z = -1},
};

CHARACTER_CREATE_ZOOM_SCALE_BY_SCENE = {
	["Dwarf"]   = 0.85,
	["Trol2"]   = 0.80,
	["Tauren"]  = 0.55,
	["Draenei"] = 0.75,
	["VoidElf"] = 0.75,
};

CHARACTER_CREATE_ZOOM_HEIGHT_BY_SCENE = {
	["Dwarf"]       = 0.40,
	["Gnome"]       = 0.20,
	["Draenei"]     = 1.90,
	["Worgen"]      = 1.20,
	["Pandaren"]    = 1.30,
	["DemonHunter"] = 1.05,
	["VoidElf"]     = 1.25,
	["BloodElf"]    = 1.00,
	["Horde"]       = 1.05,
	["Vulpera"]     = 0.25,
	["Dracthyr"]    = 1.00,
	["Kultiran"]    = 1.50,
	["Scourge"]     = 1.00,
	["Trol2"]       = 1.55,
	["Goblin"]      = 0.25,
	["DemonHunter"] = 1.40,
	["Pirate"]      = 1.40,
	["Troll"]       = 1.20,
	["Tauren"]      = 1.50,
	["ORCCLAN"]     = 1.15,
};

function CharacterCreate_GetActiveSceneName()
	local race = GetSelectedRace();

	if ( race == 1 ) then return "Human";
	elseif ( race == 2 ) then return "Dwarf";
	elseif ( race == 3 ) then return "Pirate";
	elseif ( race == 4 ) then return "Gnome";
	elseif ( race == 5 ) then return "Draenei";
	elseif ( race == 6 ) then return "Worgen";
	elseif ( race == 7 ) then return "Pandaren";
	elseif ( race == 8 ) then return "DemonHunter";
	elseif ( race == 9 ) then return "VoidElf";
	elseif ( race == 10 ) then return "Draenei";
	elseif ( race == 11 ) then return "Dwarf";
	elseif ( race == 12 ) then return "BloodElf";
	elseif ( race == 13 ) then return "Vulpera";
	elseif ( race == 14 ) then return "Dracthyr";
	elseif ( race == 15 ) then return "Kultiran";
	elseif ( race == 16 ) then return "Horde";
	elseif ( race == 17 ) then return "Scourge";
	elseif ( race == 18 ) then return "Pirate";
	elseif ( race == 19 ) then return "Trol2";
	elseif ( race == 20 ) then return "Goblin";
	elseif ( race == 21 ) then return "BloodElf";
	elseif ( race == 22 ) then return "Pandaren";
	elseif ( race == 23 ) then return "DemonHunter";
	elseif ( race == 24 ) then return "Draenei";
	elseif ( race == 25 ) then return "Vulpera";
	elseif ( race == 26 ) then return "NightElf";
	elseif ( race == 27 ) then return "Troll";
	elseif ( race == 28 ) then return "Dwarf";
	elseif ( race == 29 ) then return "Tauren";
	elseif ( race == 30 ) then return "Dracthyr";
	elseif ( race == 31 ) then return "ORCCLAN";
	end

	return "Earthen";
end

function CharacterCreate_GetActiveBackdropName()
	local _, _, currClass = GetSelectedClass();
	if ( currClass == "DEATHKNIGHT" ) then
		return "DeathKnight";
	end

	local race = GetSelectedRace();
	if ( race and race >= 1 and race <= 15 ) then
		return "Alliance";
	elseif ( race and race >= 16 and race <= 31 ) then
		return "Horde";
	end

	return "Earthen";
end

function CharacterCreate_GetZoomDirection()
	if ( CHARACTER_CREATE_ZOOM_DIRECTION_OVERRIDE ) then
		return CHARACTER_CREATE_ZOOM_DIRECTION_OVERRIDE;
	end
	local backdrop = CharacterCreate_GetActiveBackdropName();
	return CHARACTER_CREATE_ZOOM_DIRECTION_BY_BACKDROP[backdrop] or CHARACTER_CREATE_ZOOM_DEFAULT_DIRECTION;
end

function CharacterCreate_GetZoomScale()
	local scene = CharacterCreate_GetActiveSceneName();
	return CHARACTER_CREATE_ZOOM_SCALE_BY_SCENE[scene] or 1.0;
end

function CharacterCreate_GetZoomHeight()
	local scene = CharacterCreate_GetActiveSceneName();
	return CHARACTER_CREATE_ZOOM_HEIGHT_BY_SCENE[scene] or 1.0;
end

function CharacterCreate_UpdateZoomDebugText(offset, faceShift, sceneName, ownerFrame)
	if ( CharacterCreateZoomDebugText ) then
		CharacterCreateZoomDebugText:Hide();
	end
end

function CharacterCreate_Zoom(delta)
	if ( not delta or delta == 0 ) then
		return;
	end

	CHARACTER_CREATE_ZOOM_TARGET_OFFSET = CHARACTER_CREATE_ZOOM_TARGET_OFFSET + (delta * CHARACTER_CREATE_ZOOM_STEP);

	if ( CHARACTER_CREATE_ZOOM_TARGET_OFFSET < CHARACTER_CREATE_ZOOM_MIN ) then
		CHARACTER_CREATE_ZOOM_TARGET_OFFSET = CHARACTER_CREATE_ZOOM_MIN;
	elseif ( CHARACTER_CREATE_ZOOM_TARGET_OFFSET > CHARACTER_CREATE_ZOOM_MAX ) then
		CHARACTER_CREATE_ZOOM_TARGET_OFFSET = CHARACTER_CREATE_ZOOM_MAX;
	end
end

function CharacterCreate_ZoomToHead()
	if ( CHARACTER_CREATE_ZOOM_DIRECTION_OVERRIDE ) then
		CHARACTER_CREATE_ZOOM_DIRECTION_OVERRIDE = nil;
		CHARACTER_CREATE_ZOOM_CALIBRATION_INDEX = 0;
	end
	if ( CHARACTER_CREATE_ZOOM_TARGET_OFFSET >= CHARACTER_CREATE_ZOOM_MAX - 0.001 ) then
		CHARACTER_CREATE_ZOOM_TARGET_OFFSET = 0;
	else
		CHARACTER_CREATE_ZOOM_TARGET_OFFSET = CHARACTER_CREATE_ZOOM_MAX;
	end
end

function CharacterCreate_CycleZoomDirectionCandidate()
	CHARACTER_CREATE_ZOOM_CALIBRATION_INDEX = CHARACTER_CREATE_ZOOM_CALIBRATION_INDEX + 1;
	if ( CHARACTER_CREATE_ZOOM_CALIBRATION_INDEX > 6 ) then
		CHARACTER_CREATE_ZOOM_CALIBRATION_INDEX = 0;
	end

	if ( CHARACTER_CREATE_ZOOM_CALIBRATION_INDEX == 0 ) then
		CHARACTER_CREATE_ZOOM_DIRECTION_OVERRIDE = nil;
		CHARACTER_CREATE_ZOOM_TARGET_OFFSET = 0;
	else
		local candidate = CHARACTER_CREATE_ZOOM_CALIBRATION_CANDIDATES[CHARACTER_CREATE_ZOOM_CALIBRATION_INDEX];
		CHARACTER_CREATE_ZOOM_DIRECTION_OVERRIDE = {x = candidate.x, y = candidate.y, z = candidate.z};
		CHARACTER_CREATE_ZOOM_TARGET_OFFSET = CHARACTER_CREATE_ZOOM_CALIBRATION_TEST_OFFSET;
	end
end

function CharacterCreate_NudgeZoomDirectionLateral(delta)
	if ( not CHARACTER_CREATE_ZOOM_DIRECTION_OVERRIDE ) then
		local base = CharacterCreate_GetZoomDirection();
		CHARACTER_CREATE_ZOOM_DIRECTION_OVERRIDE = {x = base.x, y = base.y, z = base.z}; -- copie, jamais la table de base
		CHARACTER_CREATE_ZOOM_TARGET_OFFSET = CHARACTER_CREATE_ZOOM_CALIBRATION_TEST_OFFSET;
	end
	CHARACTER_CREATE_ZOOM_DIRECTION_OVERRIDE.y = CHARACTER_CREATE_ZOOM_DIRECTION_OVERRIDE.y + delta;
end

function CharacterCreate_ResetZoom()
	CHARACTER_CREATE_ZOOM_OFFSET = 0;
	if ( CHARACTER_CREATE_ZOOM_CALIBRATION_INDEX and CHARACTER_CREATE_ZOOM_CALIBRATION_INDEX > 0 ) then
		CHARACTER_CREATE_ZOOM_TARGET_OFFSET = CHARACTER_CREATE_ZOOM_CALIBRATION_TEST_OFFSET;
	else
		CHARACTER_CREATE_ZOOM_TARGET_OFFSET = 0;
	end
end

function CharacterCreate_ApplyZoom(self)
	if ( not CHARACTER_CREATE_ZOOM_API_PROBE_DONE ) then
		CHARACTER_CREATE_ZOOM_HAS_MODEL_SCALE = (type(self.SetModelScale) == "function");
		CHARACTER_CREATE_ZOOM_HAS_PORTRAIT_ZOOM = (type(self.SetPortraitZoom) == "function");
		CHARACTER_CREATE_ZOOM_API_PROBE_DONE = true;
	end

	if ( CHARACTER_CREATE_ZOOM_OFFSET ~= CHARACTER_CREATE_ZOOM_TARGET_OFFSET ) then
		local diff = CHARACTER_CREATE_ZOOM_TARGET_OFFSET - CHARACTER_CREATE_ZOOM_OFFSET;
		if ( abs(diff) < 0.001 ) then
			CHARACTER_CREATE_ZOOM_OFFSET = CHARACTER_CREATE_ZOOM_TARGET_OFFSET;
		else
			CHARACTER_CREATE_ZOOM_OFFSET = CHARACTER_CREATE_ZOOM_OFFSET + diff * CHARACTER_CREATE_ZOOM_SMOOTHING;
		end
	end

	if ( CHARACTER_CREATE_ZOOM_OFFSET == 0 ) then
		if ( CHARACTER_CREATE_ZOOM_HAS_MODEL_SCALE ) then
			self:SetModelScale(1);
		end
		CharacterCreate_UpdateZoomDebugText(0, 0, CharacterCreate_GetActiveSceneName(), self);
		return;
	end

	local x, y, z = self:GetPosition();
	if ( not x ) then
		x, y, z = 0, 0, 0;
	end

	local scale = CharacterCreate_GetZoomScale();
	local appliedOffset = CHARACTER_CREATE_ZOOM_OFFSET * scale;
	local dir = CharacterCreate_GetZoomDirection();

	local t = 0;
	if ( CHARACTER_CREATE_ZOOM_OFFSET > 0 and CHARACTER_CREATE_ZOOM_MAX > 0 ) then
		t = CHARACTER_CREATE_ZOOM_OFFSET / CHARACTER_CREATE_ZOOM_MAX;
		if ( t > 1 ) then
			t = 1;
		end
	end

	local faceBiasMax = CHARACTER_CREATE_ZOOM_FACE_SHIFT_MAX * CHARACTER_CREATE_ZOOM_FACE_BIAS_RATIO;
	local heightFactor = CharacterCreate_GetZoomHeight();
	local faceShift = faceBiasMax * scale * heightFactor * (t * t);

	self:SetPosition(
		x + appliedOffset * dir.x,
		y + appliedOffset * dir.y,
		z + appliedOffset * dir.z - faceShift
	);

	if ( CHARACTER_CREATE_ZOOM_HAS_MODEL_SCALE ) then
		local scaleBoost = 1 + (CHARACTER_CREATE_ZOOM_SCALE_BOOST_MAX * t * t);
		self:SetModelScale(scaleBoost);
	end

	CharacterCreate_UpdateZoomDebugText(CHARACTER_CREATE_ZOOM_OFFSET, faceShift, CharacterCreate_GetActiveSceneName(), self);
end

function CharacterCreateEnumerateRaces(...)
	CharacterCreate.numRaces = select("#", ...)/3;
	if ( CharacterCreate.numRaces > MAX_RACES ) then
		message("Too many races!  Update MAX_RACES");
		return;
	end
	local coords;
	local index = 1;
	local button;
	local gender;
	local selectedSex = GetSelectedSex();
	if ( selectedSex == SEX_MALE ) then
		gender = "MALE";
	else
		gender = "FEMALE";
	end
	for i=1, select("#", ...), 3 do
		local name = select(i, ...);
		local unlocalizedname = strupper(select(i+1, ...))

		coords = RACE_ICON_TCOORDS[strupper(select(i+1, ...).."_"..gender)];
		_G["CharCreateRaceButton"..index.."NormalTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		_G["CharCreateRaceButton"..index.."PushedTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		button = _G["CharCreateRaceButton"..index];
		if ( not button  ) then
			return;
		end

		button.nameFrame.text:SetText(name);
		if ( select(i+2, ...) == 1 ) then
			button:Enable();
			SetButtonDesaturated(button);
			button.name = name;
			button.tooltip = name;
		else
			button:Disable();
			SetButtonDesaturated(button, 1);
			button.name = name;
			local disabledReason = _G[strupper(select(i+1, ...).."_".."DISABLED")];
			if ( disabledReason ) then
				button.tooltip = name.."|n"..disabledReason;
			else
				button.tooltip = nil;
			end
		end

		local abilityIndex = 1;
		local tempText = _G["ABILITY_INFO_"..unlocalizedname..abilityIndex];
		abilityText = "";
		while ( tempText ) do
			abilityText = abilityText..tempText.."\n\n";
			abilityIndex = abilityIndex + 1;
			tempText = _G["ABILITY_INFO_"..unlocalizedname..abilityIndex];
		end

		text = GetFlavorText("RACE_INFO_"..unlocalizedname, gender)
		-- button.tooltip = "|r"..text
		button.tooltip = button.tooltip.."\n\n|cffFFFFFF"..abilityText


		index = index + 1;
	end
	for i=CharacterCreate.numRaces + 1, MAX_RACES, 1 do
		_G["CharCreateRaceButton"..i]:Hide();
	end
end

function CharacterCreateEnumerateClasses(...)
	CharacterCreate.numClasses = select("#", ...)/3;
	if ( CharacterCreate.numClasses > MAX_CLASSES_PER_RACE ) then
		message("Too many classes!  Update MAX_CLASSES_PER_RACE");
		return;
	end
	local coords;
	local index = 1;
	local button;
	for i=1, select("#", ...), 3 do
		local unlocalizedname = strupper(select(i+1, ...))

		coords = CLASS_ICON_TCOORDS[strupper(select(i+1, ...))];
		_G["CharCreateClassButton"..index.."NormalTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		_G["CharCreateClassButton"..index.."PushedTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		button = _G["CharCreateClassButton"..index];
		button:Show();
		button.nameFrame.text:SetText(select(i, ...));
		button.tooltip = ""
		button.tooltip = button.nameFrame.text:GetText()
		
		local abilityIndex = 0;
		local tempText = _G["CLASS_INFO_"..unlocalizedname..abilityIndex];
		abilityText = "";
		while ( tempText ) do
			abilityText = abilityText..tempText.."\n\n";
			abilityIndex = abilityIndex + 1;
			tempText = _G["CLASS_INFO_"..unlocalizedname..abilityIndex];
		end
				
		if ( select(i+2, ...) == 1 ) then
			if (IsRaceClassValid(CharacterCreate.selectedRace, index)) then
				button:Enable();
				SetButtonDesaturated(button);
				text = GetFlavorText("CLASS_"..strupper(unlocalizedname), "MALE").."|n|n"
				button.tooltip = "|r"..text
				button.tooltip = button.tooltip.."\n\n|cffFFFFFF"..abilityText
				--button.tooltip = nil;
				-- _G["CharCreateClassButton"..index.."DisableTexture"]:Hide();
			else
				button:Disable();
				SetButtonDesaturated(button, 1);
				button.tooltip = _G[strupper(select(i+1, ...).."_".."DISABLED")];
				text = GetFlavorText("CLASS_"..strupper(unlocalizedname), "MALE").."|n|n"
		        button.tooltip = "|cffFFFFFF"..button.tooltip.."|r\n\n"
				_G["CharCreateClassButton"..index.."DisableTexture"]:Show();
			end
		else
			button:Disable();
			SetButtonDesaturated(button, 1);
			_G["CharCreateClassButton"..index.."DisableTexture"]:Show();
		end
				
		index = index + 1;
	end
	for i=CharacterCreate.numClasses + 1, MAX_CLASSES_PER_RACE, 1 do
		_G["CharCreateClassButton"..i]:Hide();
	end
end

function SetCharacterRace(id)

	CharacterCreate.selectedRace = id;
	for i=1, CharacterCreate.numRaces, 1 do
		local button = _G["CharCreateRaceButton"..i];
		if ( i == id ) then
			button:SetChecked(1);
		else
			button:SetChecked(0);
		end
	end

	local name, faction = GetFactionForRace(CharacterCreate.selectedRace);

	if faction == nil then
		faction = "Alliance";
	end

	-- during a paid service we have to set alliance/horde for neutral races
	-- hard-coded for Pandaren because of alliance/horde pseudo buttons
	local canProceed = true;
	-- if ( id == TUSKARR_RACE_ID and PAID_SERVICE_TYPE ) then
	-- 	--[[
	-- 	--local currentFaction = PaidChange_GetCurrentFaction();
	-- 	if ( PaidChange_GetCurrentRaceIndex() == TUSKARR_RACE_ID and PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
	-- 		-- this is an original pandaren staying or becoming selected
	-- 		-- check the pseudo-buttons
	-- 		faction = PandarenFactionButtons_GetSelectedFaction();
	-- 		--if ( faction == currentFaction ) then
	-- 			canProceed = false;
	-- 		--end
	-- 	else
	-- 		-- for faction change use the opposite faction of current character
	-- 		if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
	-- 			--if ( currentFaction == "Horde" ) then
	-- 				faction = "Alliance";
	-- 			--elseif ( currentFaction == "Alliance" ) then
	-- 			--	faction = "Horde";
	-- 			--end
	-- 		-- for race change and customization use the same faction as current character
	-- 		else
	-- 			faction = "Alliance";
	-- 		end
	-- 	end
	-- 	]]
	-- else
	-- 	PandarenFactionButtons_ClearSelection();
	-- end
	CharCreate_EnableNextButton(canProceed);

	-- Set background
	local backgroundFilename = GetCreateBackgroundModel(faction);
	--[[if CharacterCreate.selectedClass == 11 then
		backgroundFilename = "DEMONHUNTER"
	end]]

	if (faction == "Alliance") then
		SetBackgroundModel(CharacterCreate, "HUMAN");
	else
		SetBackgroundModel(CharacterCreate, "ORC");
	end
	CHARACTER_CREATE_SPECIAL_BACKGROUND = false;
	CharacterCreate_ResetZoom();

	-- Set backdrop colors based on faction
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE[faction];
	--CharCreateRaceFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	--CharCreateClassFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	--CharCreateCustomizationFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	--harCreatePreviewFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateCustomizationFrameBanner:SetVertexColor(backdropColor[10], backdropColor[11], backdropColor[12]);
	CharacterCreateNameEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	--CharCreateRaceInfoFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	--CharCreateClassInfoFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);

	-- race info
	local frame = CharCreateRaceInfoFrame;
	local race, fileString = GetNameForRace();
	frame.title:SetText(race);
	fileString = strupper(fileString);
	local gender;
	if ( GetSelectedSex() == SEX_MALE ) then
		gender = "MALE";
	else
		gender = "FEMALE";
	end
	local raceText = _G["RACE_INFO_"..fileString];
	local abilityIndex = 1;
	local tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
	abilityText = "";
	while ( tempText ) do
		abilityText = abilityText..tempText.."\n\n";
		abilityIndex = abilityIndex + 1;
		tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
	end
	CharCreateRaceInfoFrameScrollFrameScrollBar:SetValue(0);
	local text
	text = GetFlavorText("RACE_INFO_"..strupper(fileString), GetSelectedSex())
	if not text then
		text = "Not in GlueXML."
	end
	CharCreateRaceInfoFrame.scrollFrame.scrollChild.infoText:SetText(text.."|n|n");
	if ( abilityText and abilityText ~= "" ) then
		CharCreateRaceInfoFrame.scrollFrame.scrollChild.bulletText:SetText(abilityText);
	else
		CharCreateRaceInfoFrame.scrollFrame.scrollChild.bulletText:SetText("");
	end

	-- Altered form
	--[[if (HasAlteredForm()) then
		SetPortraitTexture(CharacterCreateAlternateFormTopPortrait, 22, GetSelectedSex());
		SetPortraitTexture(CharacterCreateAlternateFormBottomPortrait, 23, GetSelectedSex());
		CharacterCreateAlternateFormTop:Show();
		CharacterCreateAlternateFormBottom:Show();
		if( IsViewingAlteredForm() ) then
			CharacterCreateAlternateFormTop:SetChecked(false);
			CharacterCreateAlternateFormBottom:SetChecked(true);
		else
			CharacterCreateAlternateFormTop:SetChecked(true);
			CharacterCreateAlternateFormBottom:SetChecked(false);
		end
	else
		CharacterCreateAlternateFormTop:Hide();
		CharacterCreateAlternateFormBottom:Hide();
	end]]
end

--ClickerClass--
function SetCharacterClass(id)
	if id == 11 then
		return
	end
	CharacterCreate.selectedClass = id;
	for i=1, CharacterCreate.numClasses, 1 do
		local button = _G["CharCreateClassButton"..i];
		if ( i == id ) then
			button:SetChecked(1);
		else
			button:SetChecked(0);
			button.selection:Hide();
		end
	end

	-- class info
	local frame = CharCreateClassInfoFrame;
	local className, classFileName, _, tank, healer, damage = GetSelectedClass();
	local abilityIndex = 0;
	if not classFileName then
		classFileName = "WARRIOR"
	end
	local tempText = _G["CLASS_INFO_"..classFileName..abilityIndex];
	abilityText = "";
	while ( tempText ) do
		abilityText = abilityText..tempText.."\n\n";
		abilityIndex = abilityIndex + 1;
		tempText = _G["CLASS_INFO_"..classFileName..abilityIndex];
	end
	CharCreateClassInfoFrame.title:SetText(className);
	CharCreateClassInfoFrame.scrollFrame.scrollChild.bulletText:SetText(abilityText);
	CharCreateClassInfoFrame.scrollFrame.scrollChild.infoText:SetText(GetFlavorText("CLASS_"..strupper(classFileName), GetSelectedSex()).."|n|n");
	CharCreateClassInfoFrameScrollFrameScrollBar:SetValue(0);
	
		local _,_,currClass = GetSelectedClass();
		
	if ( currClass == 13 or forceSelect ) then
		local backgroundFilename = GetCreateBackgroundModel(faction);
			backgroundFilename = "DEMONHUNTER"
		SetBackgroundModel(CharacterCreate, backgroundFilename);
		CHARACTER_CREATE_SPECIAL_BACKGROUND = true;
	else
		CHARACTER_CREATE_SPECIAL_BACKGROUND = false;
	end
end

function CharMultiCycle(id, count, button)    
    for i=1, count, 1 do
		CycleCharCustomization(id, button);
	end    
end

function CharCustomizeButtonClick_DH_SkinColor(id, right)    
    CharMultiCycle(id, 7, right);
end

function CharCustomizeButtonClick_DH_FacialHair(id, right)
	CycleCharCustomization(id, right);
end

function CharCustomizeButtonClick_DH_Tattoos(id, right)  
	CycleCharCustomization(id, right);
end

function CharCustomizeButtonClick_DH_HornStyle(id, right)
-- CharacterCreateNameEdit:SetText(id);
-- GetSelectedSex() == 2 | Male
-- GetSelectedSex() == 3 | Female
local selectedSex = GetSelectedSex();

	if ( GetSelectedRace() == 15 and selectedSex == SEX_MALE ) then
		gender = "MALE";
        CharMultiCycle(id, 10, right);
	elseif ( GetSelectedRace() == 15 and selectedSex == SEX_FEMALE ) then
		gender = "FEMALE";
        CharMultiCycle(id, 11, right);
	elseif ( GetSelectedRace() == 16 and selectedSex == SEX_FEMALE ) then
		gender = "FEMALE";
        CharMultiCycle(id, 11, right);
	elseif ( GetSelectedRace() == 16 and selectedSex == SEX_MALE ) then
		gender = "MALE";
        CharMultiCycle(id, 10, right);
	end
end

function CharCustomizeButtonClick_DH_Blindfolds(id, right)
	CycleCharCustomization(5, right);
end

function CharCustomizeButtonClick(id, button)
    CycleCharCustomization(id, 1);
	-- CycleCharCustomization(id, 1);
	--[[FeatureType = id
	for i=1,5 do
		_G["CharCreateCustomizationButton"..i]:SetChecked(0);
	end
	_G["CharCreateCustomizationButton"..id]:SetChecked(1);]]

end

function CharacterCustomizationCustom_Right(id)
	PlaySound("gsCharacterCreationLook");
    if (id == 1 ) then
	 CycleCharCustomization(1, 1);
	elseif (id == 2 )then
	CycleCharCustomization(2, 1);
	elseif (id == 3 )then
	CycleCharCustomization(3, 1);
    elseif (id == 4 )then
	CycleCharCustomization(4, 1);
	elseif (id == 5 )then
	CycleCharCustomization(5, 1);
    elseif ( id == 6 ) then
        CharCustomizeButtonClick_DH_SkinColor(1, 1);
    elseif (id == 8 ) then
        CharCustomizeButtonClick_DH_Tattoos(1, 1);
    elseif ( id == 9) then
        CharCustomizeButtonClick_DH_HornStyle(5, 1);
	elseif ( id == 10) then
       CharCustomizeButtonClick_DH_Blindfolds(5, 1);
    end
    --CycleCharCustomization(id, -1);
end

function CharacterCustomizationCustom_Left(id)
	PlaySound("gsCharacterCreationLook");
    if (id == 1 ) then
	 CycleCharCustomization(1, -1);
	elseif (id == 2 )then
	CycleCharCustomization(2, -1);
	elseif (id == 3 )then
	CycleCharCustomization(3, -1);
    elseif (id == 4 )then
	CycleCharCustomization(4, -1);
	elseif (id == 5 )then
	CycleCharCustomization(5, -1);
    elseif ( id == 6 ) then
        CharCustomizeButtonClick_DH_SkinColor(1, -1);
    elseif (id == 8 ) then
        CharCustomizeButtonClick_DH_Tattoos(1, -1);
    elseif ( id == 9) then
        CharCustomizeButtonClick_DH_HornStyle(5, -1);
	elseif ( id == 10) then
       CharCustomizeButtonClick_DH_Blindfolds(5, -1);
    end
end

function CharacterCreate_OnChar()
end

function CharacterCreate_OnNext()

	local _,_,currClass = GetSelectedClass();
    if (currClass < 31 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 30 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 29 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 28 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 27 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 26 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 25 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 24 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 23 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 22 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 21 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 20 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 19 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 18 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 17 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 16 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 15 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end

	local _,_,currClass = GetSelectedClass();
    if (currClass < 14 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end
	
	local _,_,currClass = GetSelectedClass();
    if (currClass < 13 or forceSelect ) then
	CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	CharCreateCustomizationButton8:Hide(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end
	
	local _,_,currClass = GetSelectedClass();
	if (currClass == 12 or forceSelect ) then
    CharCreateCustomizationButton1:Show(); --Skin Color
	CharCreateCustomizationButton2:Hide(); -- Face
	CharCreateCustomizationButton3:Hide(); -- Hair Style
	CharCreateCustomizationButton4:Hide(); -- Hair Color
	CharCreateCustomizationButton5:Hide(); -- Features
	CharCreateCustomizationButton6:Show(); -- Tattoo Colors
	CharCreateCustomizationButton8:Show(); -- Tattoo
	CharCreateCustomizationButton9:Hide(); -- Horns
	CharCreateCustomizationButton10:Hide(); -- Blindfolders
	end	
end

function CharacterCreate_OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		CharacterCreate_Back();
		CharacterCreate_BodyHIDE();
	elseif ( key == "ENTER" ) then
		CharacterCreate_Forward();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function CharacterCreate_UpdateModel(self)
	UpdateCustomizationScene();
	CharacterCreate_ApplyZoom(self);
	self:AdvanceTime();
end

AU_RACE_START_ZONE_NAME = {
	[1] = "Comté-du-Nord",
	[2] = "Vallée des Frigères",
	[3] = "Sombrevallon",
	[4] = "Dun Morogh",
	[5] = "Val d'Ammen",
	[6] = "Gilneas",
	[7] = "L'île Vagabonde",
	[8] = "Sombrevallon",
	[9] = "Faille de Telogrus",
	[10] = "Royaumes de l'Est",
	[11] = "Royaumes de l'Est",
	[12] = "Comté-du-Nord",
	[13] = "Royaumes de l'Est",
	[14] = "Comté-du-Nord",
	[15] = "Comté-du-Nord",
	[16] = "Vallée des Épreuves",
	[17] = "Le Glas",
	[18] = "Camp Narache",
	[19] = "L'îles de l'Écho",
	[20] = "Kezan",
	[21] = "L'Île de Haut-Soleil",
	[22] = "L'île Vagabonde",
	[23] = "L'Île de Haut-Soleil",
	[24] = "Kalimdor",
	[25] = "Kalimdor",
	[26] = "Kalimdor",
	[27] = "Kalimdor",
	[28] = "Kalimdor",
	[29] = "Camp Narache",
	[30] = "L'Île de Haut-Soleil",
	[31] = "Kalimdor",
};

AU_HIDDEN_START_ZONE_CLASSES = {
	[6] = true,
	[12] = true, [14] = true, [15] = true, [16] = true,
	[17] = true, [18] = true, [19] = true, [20] = true,
	[21] = true, [22] = true, [23] = true, [24] = true,
};

function AU_IsAzerionRealm()
	local realmName = GetCVar and GetCVar("realmName");
	return realmName == "Azerion Universe";
end

function CharacterCreate_SelectStartZone(zone)
	CharacterCreate.selectedStartZone = zone;
	PlaySound("igMainMenuOptionCheckBoxOn");
	CharacterCreate_UpdateStartZoneButtons();
end

function CharacterCreate_UpdateStartZoneButtons()
	local zoneName = AU_RACE_START_ZONE_NAME[CharacterCreate.selectedRace] or "Azeroth / Kalimdor";
	CharCreateStartZoneAzerothButtonText:SetText(zoneName);

	if ( CharacterCreate.selectedStartZone == "shadowlands" ) then
		CharCreateStartZoneAzerothButton:SetChecked(false);
		CharCreateStartZoneShadowlandsButton:SetChecked(true);
	else
		CharCreateStartZoneAzerothButton:SetChecked(true);
		CharCreateStartZoneShadowlandsButton:SetChecked(false);
	end
end

-- Gear Update
AU_GEARUPDATE_TIERS = {
	{ tier = "S0", name = "Équipement S0", role = "Niveau 80 - PvE Terre de Fyra", cost = 8000 },
	{ tier = "S4", name = "Équipement S4", role = "Niveau 80 - PvE Cœur de la peur", cost = 12000 },
	{ tier = "S7", name = "Équipement S7", role = "Niveau 90 - PvE Salles des Valeureux", cost = 20000 },
};

function CharacterCreate_SelectGearUpdateTier(tier)
	CharacterCreate.selectedGearTier = tier;
	CharacterCreate_GearUpdate_UpdateButtonLabel();
end

function CharacterCreate_GearUpdate_UpdateButtonLabel()
	if ( not (CharCreateGearUpdateButton and CharCreateGearUpdateButton.nameFrame) ) then
		return;
	end
	local tier = CharacterCreate.selectedGearTier or "none";
	if ( tier == "none" ) then
		CharCreateGearUpdateButton.nameFrame.text:SetText("Mise à niveau de l'équipement");
	else
		for _, data in ipairs(AU_GEARUPDATE_TIERS) do
			if ( data.tier == tier ) then
				CharCreateGearUpdateButton.nameFrame.text:SetText("Palier selectionné : "..data.name);
				break;
			end
		end
	end
end

function CharacterCreate_GearUpdate_OnButtonClick()
	PlaySound("gsCharacterSelectionCreateNew");
	CharCreateGUSpecDialog:Hide();
	CharCreateGUWelcomeDialog:Show();
end

function CharacterCreate_GearUpdate_WelcomeOnNext()
	CharCreateGUWelcomeDialog:Hide();
	CharacterCreate_GearUpdate_PopulateSpecDialog();
	CharCreateGUSpecDialog:Show();
end

function CharacterCreate_GearUpdate_PopulateSpecDialog()
	local raceButton = _G["CharCreateRaceButton"..(CharacterCreate.selectedRace or 0)];
	local raceName = (raceButton and raceButton.name) or "";
	local classButton = _G["CharCreateClassButton"..(CharacterCreate.selectedClass or 0)];
	local className = (classButton and classButton.nameFrame and classButton.nameFrame.text:GetText()) or "";
	CharCreateGUSpecCharacterInfo:SetText(className.." - "..raceName);

	CharacterCreate.gearUpdatePendingTier = CharacterCreate.selectedGearTier;

	for i, data in ipairs(AU_GEARUPDATE_TIERS) do
		local row = _G["CharCreateGUSpecRow"..i];
		if ( row ) then
			row.tier = data.tier;
			row:Show();
			_G[row:GetName().."Name"]:SetText(data.name);
			_G[row:GetName().."Role"]:SetText(data.role.."\n"..data.cost.." Breloques Supérieures.");
			if ( CharacterCreate.gearUpdatePendingTier == data.tier ) then
				_G[row:GetName().."Check"]:Show();
			else
				_G[row:GetName().."Check"]:Hide();
			end
		end
	end
end

function CharacterCreate_GearUpdate_RowOnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	CharacterCreate.gearUpdatePendingTier = self.tier;
	for i = 1, 3 do
		local row = _G["CharCreateGUSpecRow"..i];
		if ( row ) then
			if ( row.tier == self.tier ) then
				_G[row:GetName().."Check"]:Show();
			else
				_G[row:GetName().."Check"]:Hide();
			end
		end
	end
end

function CharacterCreate_GearUpdate_OnConfirm()
	PlaySound("gsCharacterCreationCreateChar");
	CharacterCreate_SelectGearUpdateTier(CharacterCreate.gearUpdatePendingTier or "none");
	CharCreateGUSpecDialog:Hide();
end

function CharacterCreate_Finish()
	PlaySound("gsCharacterCreationCreateChar");

	-- If something disabled this button, ignore this message.
	-- This can happen if you press enter while it's disabled, for example.
	if ( not CharCreateOkayButton:IsEnabled() ) then
		return;
	end

	if ( PAID_SERVICE_TYPE ) then
		GlueDialog_Show("CONFIRM_PAID_SERVICE");
	else
		-- if using templates, pandaren must pick a faction
		local _, faction = GetFactionForRace(CharacterCreate.selectedRace);
		--if ( IsUsingCharacterTemplate() and ( faction ~= "Alliance" and faction ~= "Horde" ) ) then
		--	CharacterTemplateConfirmDialog:Show();
		--else
			local charName = CharacterCreateNameEdit:GetText();
			if ( CharacterCreate.selectedStartZone == "shadowlands" ) then
				charName = charName.."u";
			end
			
			if ( CharacterCreate.selectedGearTier == "S0" ) then
				charName = charName.."qz";
			elseif ( CharacterCreate.selectedGearTier == "S4" ) then
				charName = charName.."xk";
			elseif ( CharacterCreate.selectedGearTier == "S7" ) then
				charName = charName.."vq";
			end
			CreateCharacter(charName);
		--end
	end
end

function CharacterCreate_Back()
	if ( CharacterCreateFrame.state == "CUSTOMIZATION" ) then
		PlaySound("gsCharacterCreationCancel");
		CharacterCreateFrame.state = "CLASSRACE"
		CharCreateClassFrame:Show();
		CharCreateRaceFrame:Show();
		CharCreateMaleButton:Show()
		CharCreateFemaleButton:Show()
		-- CharCreateMoreInfoButton:Show();
		CharCreateCustomizationFrame:Hide();
		CharCreatePreviewFrame:Hide();
		CharCreateOkayButton:SetText(NEXT);
		CharacterCreateNameEdit:Hide();
		CharCreateStartZoneFrame:Hide();
		CharCreateGearUpdateButton:Hide();
		CharacterCreateRandomName:Hide();
		CustomizationBG:Hide()
		CharCreateRandomizeButton:Hide()
		CustomizationLogoAlliance:Show()
		CustomizationTextAlliance:Show()
		CustomizationLogoHorde:Show()
		CustomizationTextHorde:Show()
	    CharCreateCustomizationButton1:Hide(); --Skin Color
	    CharCreateCustomizationButton2:Hide(); -- Face
	    CharCreateCustomizationButton3:Hide(); -- Hair Style
        CharCreateCustomizationButton4:Hide(); -- Hair Color
	    CharCreateCustomizationButton5:Hide(); -- Features
	    CharCreateCustomizationButton6:Hide(); -- Tattoo Colors
	    CharCreateCustomizationButton8:Hide(); -- Tattoo
	    CharCreateCustomizationButton9:Hide(); -- Horns
	    CharCreateCustomizationButton10:Hide(); -- Blindfolders


		--back to awesome gear
		--SetSelectedPreviewGearType(1);

		-- back to normal camera
		--SetFaceCustomizeCamera(false);

		return;
	end

	PlaySound("gsCharacterCreationCancel");
	CHARACTER_SELECT_BACK_FROM_CREATE = true;
	SetGlueScreen("charselect");
end

function CharacterCreate_UpdateFacialHairCustomization()
	if ( GetFacialHairCustomization() == "NONE" ) then
		CharacterCustomizationButtonFrame5:Hide();
		--CharCreateRandomizeButton:SetPoint("TOP", "CharacterCustomizationButtonFrame5", "BOTTOM", 0, -5);
	else
		CharacterCustomizationButtonFrame5Text:SetText(_G["FACIAL_HAIR_"..GetFacialHairCustomization()]);
		CharacterCustomizationButtonFrame5:Show();
		--CharCreateRandomizeButton:SetPoint("TOP", "CharacterCustomizationButtonFrame5", "BOTTOM", 0, -5);
	end
end

function CharacterCreate_UpdateHairCustomization()
	if not _G["HAIR_"..GetHairCustomization().."_STYLE"] or _G["HAIR_"..GetHairCustomization().."_STYLE"] == "" then
		CharCreateCustomizationButton3:Hide()
		CharCreateCustomizationButton4:SetPoint("TOP", CharCreateCustomizationButton2, "BOTTOM", 0, -20)
	else
		--CharCreateCustomizationButton3:Show()
		CharCreateCustomizationButton3.text:SetText(_G["HAIR_"..GetHairCustomization().."_STYLE"])
		--CharCreateCustomizationButton4:SetPoint("TOP", CharCreateCustomizationButton3, "BOTTOM", 0, -20)
	end

	if not _G["HAIR_"..GetHairCustomization().."_COLOR"] or _G["HAIR_"..GetHairCustomization().."_COLOR"] == "" then
		CharCreateCustomizationButton4:Hide()
		if CharCreateCustomizationButton3:IsShown() then
			CharCreateCustomizationButton5:SetPoint("TOP", CharCreateCustomizationButton4, "BOTTOM", 0, 0)
		else
			CharCreateCustomizationButton5:SetPoint("TOP", CharCreateCustomizationButton3, "BOTTOM", 0, 0)
		end
	else
		--CharCreateCustomizationButton4:Show()
		CharCreateCustomizationButton4.text:SetText(_G["HAIR_"..GetHairCustomization().."_COLOR"])
		CharCreateCustomizationButton5:SetPoint("TOP", CharCreateCustomizationButton4, "BOTTOM", 0, 0)
	end

	if not _G["FACIAL_HAIR_"..GetFacialHairCustomization()] or _G["FACIAL_HAIR_"..GetFacialHairCustomization()] == "" then
		CharCreateCustomizationButton5:Hide()
	else
		--CharCreateCustomizationButton5:Show()
		CharCreateCustomizationButton5.text:SetText(_G["FACIAL_HAIR_"..GetFacialHairCustomization()])
	end

end


function CharacterCreate_Forward()	
	if ( CharacterCreateFrame.state == "CLASSRACE" ) then
		CharacterCreateFrame.state = "CUSTOMIZATION"
		PlaySound("gsCharacterSelectionCreateNew");
		CharCreateClassFrame:Hide();
		CharCreateRaceFrame:Hide();
		-- CharCreateMoreInfoButton:Hide();
		CharCreateCustomizationFrame:Show();
		CharacterCreate_UpdateHairCustomization()
		--CharCreatePreviewFrame:Show();
		CharacterTemplateConfirmDialog:Hide();

		CharCreate_PrepPreviewModels();
		if ( CharacterCreateFrame.customizationType ) then
			CharCreate_ResetFeaturesDisplay();
		else
			CharCreateSelectCustomizationType(1);
		end

		CharCreateOkayButton:SetText(FINISH);
		CharacterCreateNameEdit:Show();
		if ( AU_IsAzerionRealm() or AU_HIDDEN_START_ZONE_CLASSES[CharacterCreate.selectedClass] ) then
			CharCreateStartZoneFrame:Hide();
			CharacterCreate.selectedStartZone = "azeroth";
		else
			CharCreateStartZoneFrame:Show();
			CharacterCreate_UpdateStartZoneButtons();
		end

		if ( AU_IsAzerionRealm() ) then
			CharCreateGearUpdateButton:Hide();
			CharacterCreate.selectedGearTier = "none";
		else
			CharCreateGearUpdateButton:Show();
			CharacterCreate_GearUpdate_UpdateButtonLabel();
		end
		if ( ALLOW_RANDOM_NAME_BUTTON ) then
			CharacterCreateRandomName:Show();
		end

		CharCreateMaleButton:Hide()
		CharCreateFemaleButton:Hide()
		CustomizationBG:Show()
		CharCreateRandomizeButton:Show()
		CustomizationLogoAlliance:Hide()
		CustomizationTextAlliance:Hide()
		CustomizationLogoHorde:Hide()
		CustomizationTextHorde:Hide()
		CharacterCreate_OnNext()

		-- Custom Part.

		-- set cam
		--[[if (CharacterCreateFrame.customizationType and CharacterCreateFrame.customizationType > 1) then
			SetFaceCustomizeCamera(true);
		else
			SetFaceCustomizeCamera(false);
		end]]
	else
		CharacterCreate_Finish();
	end
end

function CharCreateCustomizationFrame_OnShow ()
	-- reset size/tex coord to default to facilitate switching between genders for Pandaren
	CharCreateCustomizationFrameBanner:SetSize(BANNER_DEFAULT_SIZE[1], BANNER_DEFAULT_SIZE[2]);
	CharCreateCustomizationFrameBanner:SetTexCoord(BANNER_DEFAULT_TEXTURE_COORDS[1], BANNER_DEFAULT_TEXTURE_COORDS[2], BANNER_DEFAULT_TEXTURE_COORDS[3], BANNER_DEFAULT_TEXTURE_COORDS[4]);

	-- check each button and hide it if there are no values select
	local resize = 0;
	local lastGood = 0;
	local isSkinVariantHair = false --GetSkinVariationIsHairColor(CharacterCreate.selectedRace);
	local isDefaultSet = 0;
	local checkedButton = 1;

	-- check if this was set, if not, default to 1
	if ( CharacterCreateFrame.customizationType == 0 or CharacterCreateFrame.customizationType == nil ) then
		CharacterCreateFrame.customizationType = 1;
	end
	for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
		if ( ( --[[GetNumFeatureVariationsForType(i)]]5 <= 1 ) or ( isSkinVariantHair and i == CHAR_CUSTOMIZE_HAIR_COLOR ) ) then
			resize = resize + 1;
			_G["CharCreateCustomizationButton"..i]:Hide();
		else
			--_G["CharCreateCustomizationButton"..i]:Show();
			--_G["CharCreateCustomizationButton"..i]:SetChecked(0); -- we will handle default selection
			-- this must be done since a selected button can 'disappear' when swapping genders
			if ( isDefaultSet == 0 and CharacterCreateFrame.customizationType == i) then
				isDefaultSet = 1;
				checkedButton = i;
			end
			-- set your anchor to be the last good, this currently means button 1 HAS to be shown
			if (i > 1) then
				_G["CharCreateCustomizationButton"..i]:SetPoint( "TOP",_G["CharCreateCustomizationButton"..lastGood]:GetName() , "BOTTOM");
			end
			lastGood = i;
		end
	end

	if (isDefaultSet == 0) then
		CharacterCreateFrame.customizationType = lastGood;
		checkedButton = lastGood;
	end
	--_G["CharCreateCustomizationButton"..checkedButton]:SetChecked(1);

	if (resize > 0) then
	-- we need to resize and remap the banner texture
		local buttonx, buttony = CharCreateCustomizationButton1:GetSize()
		local screenamount = resize*buttony;
		print(screenamount);
		local frameX, frameY = CharCreateCustomizationFrameBanner:GetSize();
		local pctShrink = .2*resize;
		local uvXDefaultSize = BANNER_DEFAULT_TEXTURE_COORDS[2] - BANNER_DEFAULT_TEXTURE_COORDS[1];
		local uvYDefaultSize = BANNER_DEFAULT_TEXTURE_COORDS[4] - BANNER_DEFAULT_TEXTURE_COORDS[3];
		local newYUV = pctShrink*uvYDefaultSize + BANNER_DEFAULT_TEXTURE_COORDS[3];
		-- end coord stay the same
		CharCreateCustomizationFrameBanner:SetTexCoord(BANNER_DEFAULT_TEXTURE_COORDS[1], BANNER_DEFAULT_TEXTURE_COORDS[2], newYUV, BANNER_DEFAULT_TEXTURE_COORDS[4]);
		print(pctShrink);
		CharCreateCustomizationFrameBanner:SetSize(frameX, frameY - screenamount);
		print(CharCreateCustomizationFrameBanner:GetTexCoord());
	end

	--CharCreateRandomizeButton:SetPoint("TOP", _G["CharCreateCustomizationButton"..lastGood]:GetName(), "BOTTOM", 0, 0);
end

function CharacterClass_OnClick(self, id)
	if( self:IsEnabled() ) then
		PlaySound("gsCharacterCreationClass");
		local _,_,currClass = GetSelectedClass();
		if ( currClass ~= id ) then
			SetSelectedClass(id);
			SetCharacterClass(id);
			SetCharacterRace(GetSelectedRace());
			CharacterChangeFixup();
		else
			self:SetChecked(1);
		end
	else
		self:SetChecked(0);
	end
end

function CharacterRace_OnClick(self, id, forceSelect)
	if( self:IsEnabled() ) then
		PlaySound("gsCharacterCreationClass");
		if ( GetSelectedRace() ~= id or forceSelect ) then
			SetSelectedRace(id);
			SetCharacterRace(id);
			--[[if ( id == TUSKARR_RACE_ID ) then
				SetCharacterGender(SEX_MALE);
			else]]
				SetCharacterGender(GetSelectedSex());
			--end
			SetCharacterCreateFacing(-15);
			CharacterCreateEnumerateClasses(GetAvailableClasses());
			local _,_,classIndex = GetSelectedClass();
			if ( PAID_SERVICE_TYPE ) then
				classIndex = PaidChange_GetCurrentClassIndex();
				SetSelectedClass(classIndex);	-- selecting a race would have changed class to default
			end
			SetCharacterClass(classIndex);

			-- Hair customization stuff
			CharacterCreate_UpdateHairCustomization();

			CharacterChangeFixup();
		else
			self:SetChecked(1);
		end
	else
		self:SetChecked(0);
	end
end

function SetCharacterGender(sex)
	local gender;

	if ( sex == SEX_MALE ) then
		CharCreateMaleButton:SetChecked(1);
		CharCreateFemaleButton:SetChecked(0);
	else
		CharCreateMaleButton:SetChecked(0);
		CharCreateFemaleButton:SetChecked(1);
	end
	SetSelectedSex(sex);

	-- Update race images to reflect gender
	CharacterCreateEnumerateRaces(GetAvailableRaces());
	CharacterCreateEnumerateClasses(GetAvailableClasses());
 	SetCharacterRace(GetSelectedRace());

	local _,_,classIndex = GetSelectedClass();
	if ( PAID_SERVICE_TYPE ) then
		classIndex = PaidChange_GetCurrentClassIndex();
		-- PandarenFactionButtons_SetTextures();
	end
	SetCharacterClass(classIndex);

	CharacterCreate_UpdateHairCustomization();
	CharacterChangeFixup();

	-- Update preview models if on customization step
	if ( CharCreatePreviewFrame:IsShown() ) then
		CharCreateCustomizationFrame_OnShow(); -- buttons may need to reset for dirty Pandarens
		CharCreate_PrepPreviewModels();
		CharCreate_ResetFeaturesDisplay();
	end
end

function CharacterCustomization_Left(id)
	PlaySound("gsCharacterCreationLook");
	CycleCharCustomization(id, -1);
end

function CharacterCustomization_Right(id)
	PlaySound("gsCharacterCreationLook");
	CycleCharCustomization(id, 1);
end

function CharacterCreate_GenerateRandomName(button)
	CharacterCreateNameEdit:SetText(GetRandomName());
end

function CharacterCreate_Randomize()
	PlaySound("gsCharacterCreationLook");
	RandomizeCharCustomization();
	CharCreate_ResetFeaturesDisplay();
end

function CharacterCreateRotateRight_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() + CHARACTER_FACING_INCREMENT);
		CharCreate_RotatePreviews();
	end
end

function CharacterCreateRotateLeft_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() - CHARACTER_FACING_INCREMENT);
		CharCreate_RotatePreviews();
	end
end

function SetButtonDesaturated(button, desaturated)
	if ( not button ) then
		return;
	end
	local icon = button:GetNormalTexture();
	if ( not icon ) then
		return;
	end

	icon:SetDesaturated(desaturated);
end

function GetFlavorText(tagname, sex)
	local primary, secondary;
	if ( sex == SEX_MALE ) then
		primary = "";
		secondary = "_FEMALE";
	else
		primary = "_FEMALE";
		secondary = "";
	end
	local text = _G[tagname..primary];
	if ( (text == nil) or (text == "") ) then
		text = _G[tagname..secondary];
	end
	return text;
end

function CharacterChangeFixup()
	if ( PAID_SERVICE_TYPE ) then
		-- no class changing as a paid service
		CharCreateClassFrame:SetAlpha(0.5);
		for i=1, MAX_CLASSES_PER_RACE, 1 do
			if (CharacterCreate.selectedClass ~= i) then
				local button = _G["CharCreateClassButton"..i];
				button:Disable();
				SetButtonDesaturated(button, true);
			end
		end

		local numAllowedRaces = 0;
		for i=1, MAX_RACES, 1 do
			local allow = false;
			if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
				if ( IsRaceClassValid(i, CharacterCreate.selectedClass) ) then
					allow = true
				end
			elseif ( PAID_SERVICE_TYPE == PAID_RACE_CHANGE ) then
				local fact = CharacterCreate.selectedRace
				if ( ((fact < MAX_RACES and i < MAX_RACES) or (fact > (MAX_RACES-1) and i > (MAX_RACES-1))) and IsRaceClassValid(i, CharacterCreate.selectedClass) ) then
					allow = true
					local button = _G["CharCreateRaceButton"..i];
					button:Enable();
					SetButtonDesaturated(button, false);
				else
					allow = false
					local button = _G["CharCreateRaceButton"..i];
					button:Disable();
					SetButtonDesaturated(button, true);
				end
			elseif ( PAID_SERVICE_TYPE == PAID_CHARACTER_CUSTOMIZATION ) then
				if ( i == CharacterCreate.selectedRace ) then
					allow = true
				end
			end
			if (not allow) then
				local button = _G["CharCreateRaceButton"..i];
				if ( button ) then
					button:Disable();
					SetButtonDesaturated(button, true);
				end
			else
				numAllowedRaces = numAllowedRaces + 1;
			end
		end
		if ( numAllowedRaces > 1 ) then
			CharCreateRaceButtonsFrame:SetAlpha(1);
		else
			CharCreateRaceButtonsFrame:SetAlpha(0.5);
		end
	else
		CharCreateRaceButtonsFrame:SetAlpha(1);
		CharCreateClassFrame:SetAlpha(1);
	end
end

function CharCreateSelectCustomizationType(newType)
	-- deselect previous type selection
	if ( CharacterCreateFrame.customizationType and CharacterCreateFrame.customizationType ~= newType ) then
		--_G["CharCreateCustomizationButton"..CharacterCreateFrame.customizationType]:SetChecked(0);
	end
	--_G["CharCreateCustomizationButton"..newType]:SetChecked(1);
	CharacterCreateFrame.customizationType = newType;
	CharCreate_ResetFeaturesDisplay();

	--[[if (newType > 1) then
		SetFaceCustomizeCamera(true);
	else
		SetFaceCustomizeCamera(false);
	end]]
end

function CharCreate_ResetFeaturesDisplay()
	--SetPreviewFramesFeature(CharacterCreateFrame.customizationType);
	-- set the previews scrollframe container height
	-- since the first and the last previews need to be in the center position when scrolled all the way
	-- to the top or to the bottom, there will be gaps of height equal to 2 previews on each side
	local numTotalButtons = 4--GetNumFeatureVariations() + 4;
	CharCreatePreviewFrame.scrollFrame.container:SetHeight(numTotalButtons * PREVIEW_FRAME_HEIGHT - PREVIEW_FRAME_Y_OFFSET);

	for _, previewFrame in pairs(CharCreatePreviewFrame.previews) do
		previewFrame.featureType = 0;
	end

	CharCreate_DisplayPreviewModels();
end

function CharCreate_PrepPreviewModels(reloadModels)
	local displayFrame = CharCreatePreviewFrame;

	-- clear models if rebuildPreviews got flagged
	local rebuildPreviews = displayFrame.rebuildPreviews;
	displayFrame.rebuildPreviews = nil;

	-- need to reload models class was swapped to or from DK
	local classSwap = false;
	local _, class = GetSelectedClass();
	--[[if ( class == "DEATHKNIGHT" or displayFrame.lastClass == "DEATHKNIGHT" ) and ( class ~= displayFrame.lastClass ) then
		classSwap = true;
	end]]

	-- always clear the featureType
	for index, previewFrame in pairs(displayFrame.previews) do
		previewFrame.featureType = 0;
		-- force model reload if class changed
		if ( classSwap ) then
			previewFrame.race = nil;
			previewFrame.gender = nil;
		end
		if ( rebuildPreviews ) then
			--SetPreviewFrame(previewFrame.model:GetName(), index);
		end
	end
end

function CharCreate_DisplayPreviewModels(selectionIndex)
	if ( not selectionIndex ) then
		selectionIndex = featureIndex--GetSelectedFeatureVariation();
	end

	local displayFrame = CharCreatePreviewFrame;
	local previews = displayFrame.previews;
	local numVariations = 8--GetNumFeatureVariations();
	local currentFeatureType = CharacterCreateFrame.customizationType;

	local race = GetSelectedRace();
	local gender = GetSelectedSex();

	-- selection index is the center preview
	-- there are 2 previews above and 2 below, and will pad it out to 1 more on each side, for a total of 7 previews to set up
	for index = selectionIndex - 3, selectionIndex + 3 do
		-- there is empty space both at the beginning and at end of the list, each gap the height of 2 previews
		if ( index > 0 and index <= numVariations ) then
			local previewFrame = previews[index];
			-- create button if we don't have it yet
			if ( not previewFrame ) then
				previewFrame = CreateFrame("BUTTON", "PreviewFrame"..index, displayFrame.scrollFrame.container, "CharCreatePreviewFrameTemplate");
				-- index + 1 because of 2 gaps at the top and -1 for the current preview
				previewFrame:SetPoint("TOPLEFT", PREVIEW_FRAME_X_OFFSET, (index + 1) * -PREVIEW_FRAME_HEIGHT + PREVIEW_FRAME_Y_OFFSET);
				previewFrame.button.index = index;
				previews[index] = previewFrame;
				--SetPreviewFrame(previewFrame.model:GetName(), index);
				-- no texture as of yet
				--previewFrame:SetNormalTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			end
			-- load model if needed, may have been cleared by different race/gender selection
			if ( previewFrame.race ~= race or previewFrame.gender ~= gender ) then
				--SetPreviewFrameModel(index);
				previewFrame.race = race;
				previewFrame.gender = gender;
				-- apply settings
				local model = previewFrame.model;
				--model:SetCustomCamera(cameraID);
				local scale = 1--model:GetWorldScale();
				--model:SetCameraTarget(config.tx * scale, config.ty * scale, config.tz * scale);
				--model:SetCameraDistance(config.distance * scale);
				local cx, cy, cz = model:GetPosition();
				-- model:SetPosition(cx-15, cy, cz)
				--model:SetCameraPosition(cx, cy, config.cz * scale);
				previewFrame.model:SetLight(1, 0, 0, 0, 0, 1, 1.0, 1.0, 1.0);
			end
			-- need to reset the model if it was last used to preview a different feature
			if ( previewFrame.featureType ~= currentFeatureType ) then
				--ResetPreviewFrameModel(index);
				--ShowPreviewFrameVariation(index);
				previewFrame.featureType = currentFeatureType;
			end
			previewFrame:Show();
		else
			-- need to hide tail previews when going to features with fewer styles
			if ( previews[index] ) then
				previews[index]:Hide();
			end
		end
	end
	displayFrame.border.number:SetText("Option "..selectionIndex.."                     ");
	displayFrame.selectionIndex = selectionIndex;
	CharCreate_RotatePreviews();
	CharCreatePreviewFrame_UpdateStyleButtons();
	-- scroll to center the selection
	if ( not displayFrame.animating ) then
		displayFrame.scrollFrame:SetVerticalScroll((selectionIndex - 1) * PREVIEW_FRAME_HEIGHT);
	end
end


function CharCreate_RotatePreviews()
	if ( CharCreatePreviewFrame:IsShown() ) then
		local facing = ((GetCharacterCreateFacing())/ -180) * math.pi;
		local previews = CharCreatePreviewFrame.previews;
		--CharCreatePreviewFrame.selectionIndex = 0;
		for index = CharCreatePreviewFrame.selectionIndex - 3, CharCreatePreviewFrame.selectionIndex + 3 do
			local previewFrame = previews[index];
			if ( previewFrame ) then -- and previewFrame.model:HasCustomCamera()
				--previewFrame.model:SetCameraFacing(facing);
			end
		end
	end
end

function CharCreate_ChangeFeatureVariation(delta)
	local numVariations = 8--GetNumFeatureVariations();
	local startIndex = featureIndex--GetSelectedFeatureVariation();
	local endIndex = startIndex + delta;
	if ( endIndex < 1 or endIndex > numVariations ) then
		return;
	end
	PlaySound("gsCharacterCreationClass");
	featureIndex = endIndex
	CharCreatePreviewFrame_SelectFeatureVariation(endIndex);
end

function CharCreatePreviewFrameButton_OnClick(self)
	PlaySound("gsCharacterCreationClass");
	CharCreatePreviewFrame_SelectFeatureVariation(self.index);
end

function CharCreatePreviewFrame_SelectFeatureVariation(endIndex)
	local self = CharCreatePreviewFrame;
	if ( self.animating ) then
		if ( not self.queuedIndex ) then
			self.queuedIndex = endIndex;
		end
	else
		local startIndex = featureIndex--GetSelectedFeatureVariation();
		--SelectFeatureVariation(endIndex);
		for i=1,endIndex do
			CycleCharCustomization(FeatureType, 1);
		end
		CharCreatePreviewFrame_UpdateStyleButtons();
		featureIndex = endIndex
		CharCreatePreviewFrame_StartAnimating(startIndex, endIndex);
	end
end

function CharCreatePreviewFrame_StartAnimating(startIndex, endIndex)
	local self = CharCreatePreviewFrame;
	if ( self.animating ) then
		return;
	else
		self.startIndex = startIndex;
		self.currentIndex = startIndex;
		self.endIndex = endIndex;
		self.queuedIndex = nil;
		self.direction = 1;
		if ( self.startIndex > self.endIndex ) then
			self.direction = -1;
		end
		self.movedTotal = 0;
		self.moveUntilUpdate = PREVIEW_FRAME_HEIGHT;
		self.animating = true;
	end
end

function CharCreatePreviewFrame_StopAnimating()
	local self = CharCreatePreviewFrame;
	if ( self.animating ) then
		self.animating = false;
	end
end

local ANIMATION_SPEED = 5;
function CharCreatePreviewFrame_OnUpdate(self, elapsed)
	if ( self.animating ) then
		local moveIncrement = PREVIEW_FRAME_HEIGHT * elapsed * ANIMATION_SPEED;
		self.movedTotal = self.movedTotal + moveIncrement;
		self.scrollFrame:SetVerticalScroll((self.startIndex - 1) * PREVIEW_FRAME_HEIGHT + self.movedTotal * self.direction);
		self.moveUntilUpdate = self.moveUntilUpdate - moveIncrement;
		if ( self.moveUntilUpdate <= 0 ) then
			self.currentIndex = self.currentIndex + self.direction;
			self.moveUntilUpdate = PREVIEW_FRAME_HEIGHT;
			-- reset movedTotal to account for rounding errors
			self.movedTotal = abs(self.startIndex - self.currentIndex) * PREVIEW_FRAME_HEIGHT;
			CharCreate_DisplayPreviewModels(self.currentIndex);
		end
		if ( self.currentIndex == self.endIndex ) then
			self.animating = false;
			CharCreate_DisplayPreviewModels();
			if ( self.queuedIndex ) then
				local newIndex = self.queuedIndex;
				self.queuedIndex = nil;
				--SelectFeatureVariation(newIndex);
				featureIndex = newIndex
				CycleCharCustomization(FeatureType, featureIndex);
				CharCreatePreviewFrame_UpdateStyleButtons();
				CharCreatePreviewFrame_StartAnimating(self.endIndex, newIndex);
			end
		end
	end
end

function CharCreatePreviewFrame_UpdateStyleButtons()
	local selectionIndex = math.random(1,5)--GetSelectedFeatureVariation();
	local numVariations = 8--GetNumFeatureVariations();
	if ( selectionIndex == 1 ) then
		CharCreateStyleUpButton:Enable();
		CharCreateStyleUpButton.arrow:SetDesaturated(true);
	else
		CharCreateStyleUpButton:Enable();
		CharCreateStyleUpButton.arrow:SetDesaturated(false);
	end
	if ( selectionIndex == numVariations ) then
		CharCreateStyleDownButton:Disable();
		CharCreateStyleDownButton.arrow:SetDesaturated(true);
	else
		CharCreateStyleDownButton:Disable(true);
		CharCreateStyleDownButton.arrow:SetDesaturated(false);
	end
end

local TotalTime = 0;
local KeepScrolling = nil;
local TIME_TO_SCROLL = 0.5;
function CharacterCreateWhileMouseDown_OnMouseDown(direction)
	TIME_TO_SCROLL = 0.5;
	TotalTime = 0;
	KeepScrolling = direction;
end
function CharacterCreateWhileMouseDown_OnMouseUp()
	KeepScrolling = nil;
end
function CharacterCreateWhileMouseDown_Update(elapsed)
	if ( KeepScrolling ) then
		TotalTime = TotalTime + elapsed;
		if ( TotalTime >= TIME_TO_SCROLL ) then
			CharCreate_ChangeFeatureVariation(KeepScrolling);
			TIME_TO_SCROLL = 0.25;
			TotalTime = 0;
		end
	end
end

-- pandaren stuff related to faction change
function CharCreate_EnableNextButton(enabled)
	local button = CharCreateOkayButton;
	if enabled then
		button:Enable();
	else
		button:Disable();
	end
	button.Arrow:SetDesaturated(not enabled);
	if enabled then
		button.TopGlow:Hide();
		button.BottomGlow:Hide();
	else
		button.TopGlow:Show();
		button.BottomGlow:Show();
	end
end

-- -- function PandarenFactionButtons_OnLoad(self)
-- -- 	self.PandarenButton = CharCreateRaceButton6;
-- -- end
-- --
-- -- function PandarenFactionButtons_OnLoad(self)
-- -- 	self.PandarenButton = CharCreateRaceButton6;
-- -- end
--
-- function PandarenFactionButtons_Show()
-- 	local frame = CharCreatePandarenFactionFrame;
-- 	-- set the name
-- 	local raceName = GetNameForRace();
-- 	frame.AllianceButton.nameFrame.text:SetText(raceName);
-- 	frame.AllianceButton.tooltip = raceName;
-- 	frame.HordeButton.nameFrame.text:SetText(raceName);
-- 	frame.HordeButton.tooltip = raceName;
-- 	-- set the texture
-- 	PandarenFactionButtons_SetTextures();
-- 	-- set selected button
-- 	local faction = PaidChange_GetCurrentFaction();
-- 	-- deselect first in case of multiple pandaren faction changes
-- 	PandarenFactionButtons_ClearSelection();
-- 	frame[faction.."Button"]:SetChecked(1);
-- 	-- show the frame on top of the normal pandaren button
-- 	frame:Show();
-- 	frame:SetFrameLevel(frame.PandarenButton:GetFrameLevel() + 2);
-- 	CharCreate_EnableNextButton(false);
-- end
--
-- function PandarenFactionButtons_Hide()
-- 	CharCreatePandarenFactionFrame:Hide();
-- 	CharCreate_EnableNextButton(true);
-- end
--
-- function PandarenFactionButtons_SetTextures()
-- 	--[[local gender = "MALE";
-- 	local coords = RACE_ICON_TCOORDS["TUSKARR_"..gender];
-- 	CharCreatePandarenFactionFrameAllianceButtonNormalTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
-- 	CharCreatePandarenFactionFrameAllianceButtonPushedTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
-- 	CharCreatePandarenFactionFrameHordeButtonNormalTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
-- 	CharCreatePandarenFactionFrameHordeButtonPushedTexture:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);	]]
-- end
--
-- function PandarenFactionButtons_ClearSelection()
-- 	CharCreatePandarenFactionFrame.AllianceButton:SetChecked(0);
-- 	CharCreatePandarenFactionFrame.HordeButton:SetChecked(0);
-- end
--
-- function PandarenFactionButtons_GetSelectedFaction()
-- 	if ( CharCreatePandarenFactionFrame.AllianceButton:GetChecked() ) then
-- 		return "Alliance";
-- 	elseif ( CharCreatePandarenFactionFrame.HordeButton:GetChecked() ) then
-- 		return "Horde";
-- 	end
-- end
--
-- function PandarenFactionButton_OnClick(self)
-- 	PandarenFactionButtons_ClearSelection();
-- 	self:SetChecked(1);
-- 	CharacterRace_OnClick(CharCreatePandarenFactionFrame.PandarenButton, CharCreatePandarenFactionFrame.PandarenButton:GetID(), true);
-- end