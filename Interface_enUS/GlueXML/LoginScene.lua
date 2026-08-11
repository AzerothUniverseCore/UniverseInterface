
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                1     2  3  4  5    6      7                                                  8                                                       9          10           11         12        13				14
--modelData: { sceneID, x, y, z, o, scale, alpha, [{ enabled[,omni,dirX,dirY,dirZ,ambIntensity[,ambR,ambG,ambB[,dirIntensity[,dirR,dirG,dirB]]]] }], sequence, widthSquish, heightSquish, path [,referenceID] [,cameraModel] }
--[[ DOCUMENTATION:
	sceneID:			number	- on which scene it's supposed to show up
	x:					number	- moves the model left and right  \
	y:					number	- moves the model up and down	   |	if the model doesn't show up at all try moving it around sometimes it will show up | blue white box: wrong path | no texture: texture is set through dbc, needs to be hardcoded | green texture: no texture
	z:					number	- moves the model back and forth  /
	o:					number	- the orientation in which direction the model will face | number in radians | math.pi = 180° | math.pi * 2 = 360° | math.pi / 2 = 90°
	scale:				number	- used to scale the model | 1 = normal size | does not scale particles of flames for example on no camera models, use width/heightSquish for that
	alpha:				number  - opacity of the model | 1 = 100% , 0 = 0%
	light:				table	- table containing light data (look in light documentation for further explanation) | is optional
	sequence:			number	- the animation that should be played after the model is loaded
	widthSquish:		number	- squishes the model on the X axis | 1 = normal
	heightSquish:		number	- squishes the model on the Y axis | 1 = normal
	path:				String  - the path to the model ends with .m2
	referenceID:		number  - mainly used for making changes while the scene is playing | example:
	
	local m = GetModel(1)	<- GetModel(referenceID) the [1] to use the first model with this referenceID without it it would be a table with all models inside
	if m then
		m = m[1]
		local x,y,z = m:GetPosition()
		m:SetPosition(x-0.1,y,z)				<- move the model -0.1 from it's current position on the x-axis
	end
	
	cameraModel:		String	- if a path to a model is set here, it will be used as the camera
]]
--[[ LIGHT:
	enabled:			number	- appears to be 1 for lit and 0 for unlit
    omni:				number	- ?? (default of 0)
    dirX, dirY, dirZ:	numbers	- vector from the origin to where the light source should face
    ambIntensity:		number	- intensity of the ambient component of the light source
    ambR, ambG, ambB:	numbers	- color of the ambient component of the light source
    dirIntensity:		number	- intensity of the direct component of the light source
    dirR, dirG, dirB:	numbers	- color of the direct component of the light source 
]]
--[[ METHODS:
	GetModelData(referenceID / sceneID, (bool) get-all-scene-models)	table									- gets the model data table out of ModelList (returns a table with all model datas that have the same referenceID) or if bool is true from the scene
	GetModel(referenceID / sceneID, (bool) get-all-scene-models)		table									- gets all models with the same referenceID or the same sceneID (if bool is true)
	SetScene(sceneID)													nil										- sets the current scene to the sceneID given to the function
	GetScene([sceneID])													sceneID, sceneData, models, modeldatas	- gets all information of the current scene [of the sceneID]

	some helpful globals:
	ModelList.sceneCount	number	- the count of how many scenes exist
	ModelList.modelCount	number	- the count of how many models exist
]]
--[[ CREDITS:
	Made by Mordred P.H.
	
	Thanks to:
	Soldan - helping me with all the model work
	Chase - finding a method to copy cameras on the fly
	Stoneharry - bringing me to the conclusion that blizzard frames are never fullscreen, so it works with every resolution
	Blizzard - for making it almost impossible to make it work properly
]]
-------------------------------------------------------------------------
--                   1                2
--sceneData: {time_in_seconds, background_path}   --> (index is scene id)

-- 720x576  = 1.25
-- 800x600  = 1.33
-- 1024x768  = 1.33
-- 1152x864 = 1.33
-- 1280x720 = 1.77
-- 1280x768 = 1.66
-- 1280x800 = 1.6
-- 1280x960 = 1.33
-- 1280x1024 = 1.25
-- 1360x768 = 1.77
-- 1366x768 = 1.77
-- 1440x900 = 1.6
-- 1600x900 = 1.77
-- 1600x1024 = 1.56
-- 1600x1200 = 1.33
-- 1680x1050 = 1.6
-- 1920x1080 = 1.77

-- 1.25  = 5/4    ------>  nº1
-- 1.33  = 4/3    ------>  nº2
-- 1.56  = 39/25  ------>  nº3
-- 1.6   = 8/5    ------>  nº4
-- 1.66  = 5/3    ------>  nº5
-- 1.77  = 16/9   ------>  nº6

local resolution = 0
local width, height = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)");
if ( (tonumber(width) / tonumber(height ) >= 5/4) and  (tonumber(width) / tonumber(height ) < 4/3)) then
	resolution = 1
elseif ( (tonumber(width) / tonumber(height ) >= 4/3) and  (tonumber(width) / tonumber(height ) < 7/5)) then
	resolution = 2
elseif ( (tonumber(width) / tonumber(height ) >= 39/25) and  (tonumber(width) / tonumber(height ) < 8/5)) then
	resolution = 3
elseif ( (tonumber(width) / tonumber(height ) >= 8/5) and  (tonumber(width) / tonumber(height ) < 5/3)) then
	resolution = 4
elseif ( (tonumber(width) / tonumber(height ) >= 5/3) and  (tonumber(width) / tonumber(height ) < 16/9)) then
	resolution = 5
elseif ( (tonumber(width) / tonumber(height ) >= 16/9)) then
	resolution = 6
end

if resolution == 0 then
	ModelList = {
		loaded = false,											-- safety so anything else happens after loading (leave at 0)
		blend_start_duration = 1,								-- beginning fade animation duration in seconds
		max_scenes = 1,											-- number of scenes you use to shuffle through
		fade_duration = 1,										-- fade animation duration in seconds (to next scene if more than 1 exists)
		current_scene = 1,										-- current scene that gets displayed
		use_random_starting_scene = false,						-- boolean: false = always starts with sceneID 1   ||   true = starts with a random sceneID
		shuffle_scenes_randomly = false,						-- boolean: false = after one scene ends, starts the scene with sceneID + 1   ||   true = randomly shuffles the next sceneID
		login_music_path = "Interface/LoginScreen/Intro.mp3",	-- path to the music
		login_ambience_name = false,							-- name in SoundEntries.dbc / false if no ambience
		sceneData = {
			{-1,"Interface/LoginScreen/Fondo.blp"}
		},
		{1, -2.518, 6.214, -0.208, 2.711, 0.085, 1.000, _, 1, 1, 1, "Environments/Stars/vindicaar_nethersky01.mdx", _, _},
		{1, -1.128, 0.104, 0.000, 0.055, 0.047, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, 1.236, -0.630, 0.000, 0.055, 0.054, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, -0.975, 0.645, 0.000, 0.195, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.752, 0.622, 0.000, 6.162, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.028, 1.100, -0.885, 0.002, 2.472, 1.000, _, 1, 1, 1, "AzerothU/Login/Pantheon.mdx", _, _},
		{1, -0.335, 0.660, -0.027, 0.477, 0.056, 1.000, _, 213, 1, 1, "Creature/eonar/eonar.mdx", _, _},
		{1, -0.652, 0.548, 0.000, 0.909, 0.063, 1.000, _, 115, 1, 1, "Creature/khazgoroth/khazgoroth.mdx", _, _},
		{1, -0.896, 0.462, 0.000, 1.626, 0.081, 1.000, _, 115, 1, 1, "Creature/golganneth/golganneth.mdx", _, _},
		{1, 0.430, 0.625, 0.000, 5.686, 0.055, 1.000, _, 115, 1, 1, "Creature/aggramar_original/aggramar_original.mdx", _, _},
		{1, 0.893, 0.481, 0.009, 4.888, 0.080, 1.000, _, 115, 1, 1, "Creature/norgannon/norgannon.mdx", _, _},
		{1, 0.035, 0.527, 0.000, 0.048, 0.085, 1.000, _, 27, 1, 1, "Creature/amanthul/amanthul.mdx", _, _},
		{1, -0.002, 6.954, -38.804, 4.719, 0.665, 1.000, _, 149, 1, 1, "creature/titanorb/titanorb_02.mdx", _, _}
	}
end
if resolution == 1 then
	ModelList = {
		loaded = false,											-- safety so anything else happens after loading (leave at 0)
		blend_start_duration = 1,								-- beginning fade animation duration in seconds
		max_scenes = 1,											-- number of scenes you use to shuffle through
		fade_duration = 1,										-- fade animation duration in seconds (to next scene if more than 1 exists)
		current_scene = 1,										-- current scene that gets displayed
		use_random_starting_scene = false,						-- boolean: false = always starts with sceneID 1   ||   true = starts with a random sceneID
		shuffle_scenes_randomly = false,						-- boolean: false = after one scene ends, starts the scene with sceneID + 1   ||   true = randomly shuffles the next sceneID
		login_music_path = "Interface/LoginScreen/Intro.mp3",	-- path to the music
		login_ambience_name = false,							-- name in SoundEntries.dbc / false if no ambience
		sceneData = {
			{-1,"Interface/LoginScreen/Fondo.blp"}
		},
		{1, -2.662, 7.802, -0.208, 2.711, 0.085, 1.000, _, 1, 1, 1, "Environments/Stars/vindicaar_nethersky01.mdx", _, _},
		{1, -1.032, -0.040, 0.000, 0.055, 0.047, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, 1.264, -1.034, 0.000, 0.055, 0.054, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, -0.951, 0.493, 0.000, 0.195, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.852, 0.434, 0.000, 6.162, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.036, 1.136, -0.885, 0.002, 2.496, 1.000, _, 1, 1, 1, "AzerothU/Login/Pantheon.mdx", _, _},
		{1, -0.451, 0.548, -0.027, 0.477, 0.056, 1.000, _, 213, 1, 1, "Creature/eonar/eonar.mdx", _, _},
		{1, -0.760, 0.432, 0.000, 0.909, 0.063, 1.000, _, 115, 1, 1, "Creature/khazgoroth/khazgoroth.mdx", _, _},
		{1, -1.032, 0.314, 0.000, 1.626, 0.081, 1.000, _, 115, 1, 1, "Creature/golganneth/golganneth.mdx", _, _},
		{1, 0.462, 0.501, 0.000, 5.686, 0.055, 1.000, _, 115, 1, 1, "Creature/aggramar_original/aggramar_original.mdx", _, _},
		{1, 0.929, 0.349, 0.009, 4.888, 0.080, 1.000, _, 115, 1, 1, "Creature/norgannon/norgannon.mdx", _, _},
		{1, 0.039, 0.411, 0.000, 0.048, 0.085, 1.000, _, 27, 1, 1, "Creature/amanthul/amanthul.mdx", _, _},
		{1, 0.102, 8.534, -38.804, 4.719, 0.665, 1.000, _, 149, 1, 1, "creature/titanorb/titanorb_02.mdx", _, _}
	}
end
if resolution == 2 then
	ModelList = {
		loaded = false,											-- safety so anything else happens after loading (leave at 0)
		blend_start_duration = 1,								-- beginning fade animation duration in seconds
		max_scenes = 1,											-- number of scenes you use to shuffle through
		fade_duration = 1,										-- fade animation duration in seconds (to next scene if more than 1 exists)
		current_scene = 1,										-- current scene that gets displayed
		use_random_starting_scene = false,						-- boolean: false = always starts with sceneID 1   ||   true = starts with a random sceneID
		shuffle_scenes_randomly = false,						-- boolean: false = after one scene ends, starts the scene with sceneID + 1   ||   true = randomly shuffles the next sceneID
		login_music_path = "Interface/LoginScreen/Intro.mp3",	-- path to the music
		login_ambience_name = false,							-- name in SoundEntries.dbc / false if no ambience
		sceneData = {
			{-1,"Interface/LoginScreen/Fondo.blp"}
		},
		{1, -2.611, 7.849, -0.208, 2.711, 0.085, 1.000, _, 1, 1, 1, "Environments/Stars/vindicaar_nethersky01.mdx", _, _},
		{1, -1.171, 0.085, 0.000, 0.055, 0.047, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, 1.201, -0.630, 0.000, 0.055, 0.054, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, -0.948, 0.490, 0.000, 0.195, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.896, 0.393, 0.000, 6.162, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.025, 1.135, -0.885, 0.002, 2.472, 1.000, _, 1, 1, 1, "AzerothU/Login/Pantheon.mdx", _, _},
		{1, -0.388, 0.612, -0.027, 0.477, 0.056, 1.000, _, 213, 1, 1, "Creature/eonar/eonar.mdx", _, _},
		{1, -0.721, 0.489, 0.000, 0.909, 0.063, 1.000, _, 115, 1, 1, "Creature/khazgoroth/khazgoroth.mdx", _, _},
		{1, -0.979, 0.363, 0.000, 1.626, 0.081, 1.000, _, 115, 1, 1, "Creature/golganneth/golganneth.mdx", _, _},
		{1, 0.465, 0.569, 0.000, 5.686, 0.055, 1.000, _, 115, 1, 1, "Creature/aggramar_original/aggramar_original.mdx", _, _},
		{1, 0.933, 0.385, 0.009, 4.888, 0.080, 1.000, _, 115, 1, 1, "Creature/norgannon/norgannon.mdx", _, _},
		{1, 0.038, 0.428, 0.000, 0.048, 0.085, 1.000, _, 27, 1, 1, "Creature/amanthul/amanthul.mdx", _, _},
		{1, -0.023, 8.258, -38.804, 4.719, 0.665, 1.000, _, 149, 1, 1, "creature/titanorb/titanorb_02.mdx", _, _}
	}
end
if resolution == 3 then
	ModelList = {
		loaded = false,											-- safety so anything else happens after loading (leave at 0)
		blend_start_duration = 1,								-- beginning fade animation duration in seconds
		max_scenes = 1,											-- number of scenes you use to shuffle through
		fade_duration = 1,										-- fade animation duration in seconds (to next scene if more than 1 exists)
		current_scene = 1,										-- current scene that gets displayed
		use_random_starting_scene = false,						-- boolean: false = always starts with sceneID 1   ||   true = starts with a random sceneID
		shuffle_scenes_randomly = false,						-- boolean: false = after one scene ends, starts the scene with sceneID + 1   ||   true = randomly shuffles the next sceneID
		login_music_path = "Interface/LoginScreen/Intro.mp3",	-- path to the music
		login_ambience_name = false,							-- name in SoundEntries.dbc / false if no ambience
		sceneData = {
			{-1,"Interface/LoginScreen/Fondo.blp"}
		},
		{1, -2.551, 6.755, -0.208, 2.711, 0.085, 1.000, _, 1, 1, 1, "Environments/Stars/vindicaar_nethersky01.mdx", _, _},
		{1, -1.054, 0.097, 0.000, 0.055, 0.047, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, 1.138, -0.630, 0.000, 0.055, 0.054, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, -0.984, 0.568, 0.000, 0.195, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.812, 0.543, 0.000, 6.162, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.028, 1.109, -0.885, 0.002, 2.472, 1.000, _, 1, 1, 1, "AzerothU/Login/Pantheon.mdx", _, _},
		{1, -0.354, 0.641, -0.027, 0.477, 0.056, 1.000, _, 213, 1, 1, "Creature/eonar/eonar.mdx", _, _},
		{1, -0.650, 0.539, 0.000, 0.909, 0.063, 1.000, _, 115, 1, 1, "Creature/khazgoroth/khazgoroth.mdx", _, _},
		{1, -0.887, 0.429, 0.000, 1.626, 0.081, 1.000, _, 115, 1, 1, "Creature/golganneth/golganneth.mdx", _, _},
		{1, 0.451, 0.604, 0.000, 5.686, 0.055, 1.000, _, 115, 1, 1, "Creature/aggramar_original/aggramar_original.mdx", _, _},
		{1, 0.909, 0.451, 0.009, 4.888, 0.080, 1.000, _, 115, 1, 1, "Creature/norgannon/norgannon.mdx", _, _},
		{1, 0.035, 0.485, 0.000, 0.048, 0.085, 1.000, _, 27, 1, 1, "Creature/amanthul/amanthul.mdx", _, _},
		{1, 0.017, 7.358, -38.804, 4.719, 0.665, 1.000, _, 149, 1, 1, "creature/titanorb/titanorb_02.mdx", _, _}
	}
end
if resolution == 4 then
	ModelList = {
		loaded = false,											-- safety so anything else happens after loading (leave at 0)
		blend_start_duration = 1,								-- beginning fade animation duration in seconds
		max_scenes = 1,											-- number of scenes you use to shuffle through
		fade_duration = 1,										-- fade animation duration in seconds (to next scene if more than 1 exists)
		current_scene = 1,										-- current scene that gets displayed
		use_random_starting_scene = false,						-- boolean: false = always starts with sceneID 1   ||   true = starts with a random sceneID
		shuffle_scenes_randomly = false,						-- boolean: false = after one scene ends, starts the scene with sceneID + 1   ||   true = randomly shuffles the next sceneID
		login_music_path = "Interface/LoginScreen/Intro.mp3",	-- path to the music
		login_ambience_name = false,							-- name in SoundEntries.dbc / false if no ambience
		sceneData = {
			{-1,"Interface/LoginScreen/Fondo.blp"}
		},
		{1, -2.551, 6.755, -0.208, 2.711, 0.085, 1.000, _, 1, 1, 1, "Environments/Stars/vindicaar_nethersky01.mdx", _, _},
		{1, -1.054, 0.097, 0.000, 0.055, 0.047, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, 1.138, -0.630, 0.000, 0.055, 0.054, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, -0.984, 0.568, 0.000, 0.195, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.812, 0.543, 0.000, 6.162, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.028, 1.109, -0.885, 0.002, 2.472, 1.000, _, 1, 1, 1, "AzerothU/Login/Pantheon.mdx", _, _},
		{1, -0.354, 0.641, -0.027, 0.477, 0.056, 1.000, _, 213, 1, 1, "Creature/eonar/eonar.mdx", _, _},
		{1, -0.650, 0.539, 0.000, 0.909, 0.063, 1.000, _, 115, 1, 1, "Creature/khazgoroth/khazgoroth.mdx", _, _},
		{1, -0.887, 0.429, 0.000, 1.626, 0.081, 1.000, _, 115, 1, 1, "Creature/golganneth/golganneth.mdx", _, _},
		{1, 0.451, 0.604, 0.000, 5.686, 0.055, 1.000, _, 115, 1, 1, "Creature/aggramar_original/aggramar_original.mdx", _, _},
		{1, 0.909, 0.451, 0.009, 4.888, 0.080, 1.000, _, 115, 1, 1, "Creature/norgannon/norgannon.mdx", _, _},
		{1, 0.035, 0.485, 0.000, 0.048, 0.085, 1.000, _, 27, 1, 1, "Creature/amanthul/amanthul.mdx", _, _},
		{1, 0.017, 7.358, -38.804, 4.719, 0.665, 1.000, _, 149, 1, 1, "creature/titanorb/titanorb_02.mdx", _, _}
	}
end
if resolution == 5 then
	ModelList = {
		loaded = false,											-- safety so anything else happens after loading (leave at 0)
		blend_start_duration = 1,								-- beginning fade animation duration in seconds
		max_scenes = 1,											-- number of scenes you use to shuffle through
		fade_duration = 1,										-- fade animation duration in seconds (to next scene if more than 1 exists)
		current_scene = 1,										-- current scene that gets displayed
		use_random_starting_scene = false,						-- boolean: false = always starts with sceneID 1   ||   true = starts with a random sceneID
		shuffle_scenes_randomly = false,						-- boolean: false = after one scene ends, starts the scene with sceneID + 1   ||   true = randomly shuffles the next sceneID
		login_music_path = "Interface/LoginScreen/Intro.mp3",	-- path to the music
		login_ambience_name = false,							-- name in SoundEntries.dbc / false if no ambience
		sceneData = {
			{-1,"Interface/LoginScreen/Fondo.blp"}
		},
		{1, -2.551, 6.755, -0.208, 2.711, 0.085, 1.000, _, 1, 1, 1, "Environments/Stars/vindicaar_nethersky01.mdx", _, _},
		{1, -1.054, 0.097, 0.000, 0.055, 0.047, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, 1.138, -0.630, 0.000, 0.055, 0.054, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, -0.984, 0.568, 0.000, 0.195, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.812, 0.543, 0.000, 6.162, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.028, 1.109, -0.885, 0.002, 2.472, 1.000, _, 1, 1, 1, "AzerothU/Login/Pantheon.mdx", _, _},
		{1, -0.354, 0.641, -0.027, 0.477, 0.056, 1.000, _, 213, 1, 1, "Creature/eonar/eonar.mdx", _, _},
		{1, -0.650, 0.539, 0.000, 0.909, 0.063, 1.000, _, 115, 1, 1, "Creature/khazgoroth/khazgoroth.mdx", _, _},
		{1, -0.887, 0.429, 0.000, 1.626, 0.081, 1.000, _, 115, 1, 1, "Creature/golganneth/golganneth.mdx", _, _},
		{1, 0.451, 0.604, 0.000, 5.686, 0.055, 1.000, _, 115, 1, 1, "Creature/aggramar_original/aggramar_original.mdx", _, _},
		{1, 0.909, 0.451, 0.009, 4.888, 0.080, 1.000, _, 115, 1, 1, "Creature/norgannon/norgannon.mdx", _, _},
		{1, 0.038, 0.509, 0.000, 0.048, 0.085, 1.000, _, 27, 1, 1, "Creature/amanthul/amanthul.mdx", _, _},
		{1, 0.029, 7.253, -38.804, 4.719, 0.665, 1.000, _, 149, 1, 1, "creature/titanorb/titanorb_02.mdx", _, _}
	}
end
if resolution == 6 then
	ModelList = {
		loaded = false,											-- safety so anything else happens after loading (leave at 0)
		blend_start_duration = 1,								-- beginning fade animation duration in seconds
		max_scenes = 1,											-- number of scenes you use to shuffle through
		fade_duration = 1,										-- fade animation duration in seconds (to next scene if more than 1 exists)
		current_scene = 1,										-- current scene that gets displayed
		use_random_starting_scene = false,						-- boolean: false = always starts with sceneID 1   ||   true = starts with a random sceneID
		shuffle_scenes_randomly = false,						-- boolean: false = after one scene ends, starts the scene with sceneID + 1   ||   true = randomly shuffles the next sceneID
		login_music_path = "Interface/LoginScreen/Intro.mp3",	-- path to the music
		login_ambience_name = false,							-- name in SoundEntries.dbc / false if no ambience
		sceneData = {
			{-1,"Interface/LoginScreen/Fondo.blp"}
		},
		{1, -2.518, 6.214, -0.208, 2.711, 0.085, 1.000, _, 1, 1, 1, "Environments/Stars/vindicaar_nethersky01.mdx", _, _},
		{1, -1.128, 0.104, 0.000, 0.055, 0.047, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, 1.236, -0.630, 0.000, 0.055, 0.054, 1.000, _, 0, 1, 1, "world/expansion03/doodads/uldum/beams/uldum_titan_micro_stars_beam.mdx", _, _},
		{1, -0.975, 0.645, 0.000, 0.195, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.752, 0.622, 0.000, 6.162, 0.117, 1.000, _, 0, 1, 1, "spells/dragonbreath_celestialbreath.mdx", _, _},
		{1, 0.028, 1.100, -0.885, 0.002, 2.472, 1.000, _, 1, 1, 1, "AzerothU/Login/Pantheon.mdx", _, _},
		{1, -0.335, 0.660, -0.027, 0.477, 0.056, 1.000, _, 213, 1, 1, "Creature/eonar/eonar.mdx", _, _},
		{1, -0.652, 0.548, 0.000, 0.909, 0.063, 1.000, _, 115, 1, 1, "Creature/khazgoroth/khazgoroth.mdx", _, _},
		{1, -0.896, 0.462, 0.000, 1.626, 0.081, 1.000, _, 115, 1, 1, "Creature/golganneth/golganneth.mdx", _, _},
		{1, 0.430, 0.625, 0.000, 5.686, 0.055, 1.000, _, 115, 1, 1, "Creature/aggramar_original/aggramar_original.mdx", _, _},
		{1, 0.893, 0.481, 0.009, 4.888, 0.080, 1.000, _, 115, 1, 1, "Creature/norgannon/norgannon.mdx", _, _},
		{1, 0.035, 0.527, 0.000, 0.048, 0.085, 1.000, _, 27, 1, 1, "Creature/amanthul/amanthul.mdx", _, _},
		{1, -0.002, 6.954, -38.804, 4.719, 0.665, 1.000, _, 149, 1, 1, "creature/titanorb/titanorb_02.mdx", _, _}
	}
end
-------------------------------------------------------------------------!!!- end of configuration part -!!!------------------------------------------------------------------------------------------
------------------------------------------------------------------!!!!!!!!!!- end of configuration part -!!!!!!!!!!-----------------------------------------------------------------------------------
-----------------------------------------------!!!!!!!!!!!!!!!!!!!- DO NOT CHANGE BELOW HERE, EXCEPT SCENESCRIPTS -!!!!!!!!!!!!!!!!!!!----------------------------------------------------------------
------------------------------------------------------------------!!!!!!!!!!- end of configuration part -!!!!!!!!!!-----------------------------------------------------------------------------------
-------------------------------------------------------------------------!!!- end of configuration part -!!!------------------------------------------------------------------------------------------

function newScene()	-- creates a scene object that gets used internaly
	local s = {parent = CreateFrame("Frame",nil,LoginScene),
				background = ModelList.sceneData[#M+1 or 1][2],
				duration = ModelList.sceneData[#M+1 or 1][1]}
	s.parent:SetSize(LoginScene:GetWidth(), LoginScene:GetHeight())
	s.parent:SetPoint("CENTER")
	s.parent:SetFrameStrata("MEDIUM")
	table.insert(M, s)
	return s
end

function newModel(parent,alpha,light,wSquish,hSquish,camera)	-- creates a new model object that gets used internally but also can be altered after loading
	local mod = CreateFrame("Model",nil,parent)
	
	light = light or {1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8}
	mod:SetModel("Character/Human/Male/HumanMale.m2")
	mod:SetSize(LoginScene:GetWidth() / wSquish, LoginScene:GetHeight() / hSquish)
	mod:SetPoint("CENTER")
	mod:SetCamera(1)
	mod:SetLight(unpack(light))
	mod:SetAlpha(alpha)
	
	return mod
end

function Generate_M()	-- starts the routine for loading all models and scenes
	M = {}
	ModelList.sceneCount = #ModelList.sceneData
	
	local counter = 0
	for i=1, ModelList.sceneCount do
		local s = newScene()
		
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == i then
					table.insert(s, num, newModel(s.parent, m[7], m[8], m[10], m[11], m[14]))
					counter = counter + 1
					ModelList.lastModelNum = num
				end
			end
		end
		
		s.parent:Hide()
		if i == ModelList.current_scene then
			if type(s.background)=="table" then
				LoginScreenBackground:SetTexture(s.background[1],s.background[2],s.background[3],s.background[4])
			else
				LoginScreenBackground:SetTexture(s.background)
			end
		end
	end
	ModelList.modelCount = counter
	ModelList.loaded = true
end

------- updating and methods

function LoginScreen_OnLoad(self)
	local width, height = GlueParent:GetSize()
	timed_update, blend_timer = 0, 0
	
	if ModelList.login_ambience_name then
		PlayGlueAmbience(ModelList.login_ambience_name,5.0)
	end
	
	function randomScene()
		return (time() % ModelList.max_scenes) + 1
	end
	
	if ModelList.use_random_starting_scene then
		ModelList.current_scene = randomScene()
	end
	
	-- main frame for displaying and positioning of the whole loginscreen
	LoginScene = CreateFrame("Frame",nil,self)
		LoginScene:SetSize(width, height)
		LoginScene:SetPoint("CENTER", self, "CENTER", 0,0)
		LoginScene:SetFrameStrata("LOW")
	
-- main background that changes according to the scene
LoginScreenBackground = LoginScene:CreateTexture(nil,"LOW")
	LoginScreenBackground:SetPoint("TOPRIGHT", LoginScene, "TOPRIGHT", 0, 125)
	LoginScreenBackground:SetPoint("BOTTOMLEFT", LoginScene, "BOTTOMLEFT", -1, -125)
	
	LoginScreenBlend = LoginScene:CreateTexture(nil,"OVERLAY")
	LoginScreenBlend:SetTexture(0,0,0,1)
	LoginScreenBlend:SetAlpha(1)
	LoginScreenBlend:SetAllPoints(GlueParent)

	Generate_M()
end

	local timerpuede = 0
	function LoginScreen_OnUpdateTimer(self,dt)
	  if timerpuede > 2 then
		 LoginScreen_OnUpdate(self,dt)
		 --timerpuede = 0
	   else
		 timerpuede = timerpuede+1
	   end
	end


function LoginScreen_OnUpdate(self,dt)
	if M then
		if ModelList.loaded then
			if timed_update > 0.5 then
				for num, m in pairs(ModelList) do
					if type(m)=="table" and num ~= "sceneData" and m[1] <= ModelList.max_scenes then
						local mod = M[m[1]][num]
						mod:SetModel(m[12])
						mod:SetPosition(m[4], m[2], m[3])
						mod:SetFacing(m[5])
						mod:SetModelScale(m[6])
						mod:SetSequence(m[9])
					end
				end
				
				M[ModelList.current_scene].parent:Show()
				Loginscreen_OnLoad()
				Scene_OnStart(ModelList.current_scene)
				blend_start = 0
				timed_update = 0
				ModelList.loaded = false
			else
				timed_update = timed_update + 1
			end
		end
		
		if blend_start then				-- Start blend after the loginscreen loaded to hide the setting up frame
			if blend_start > ModelList.blend_start_duration/2 and blend_start < ModelList.blend_start_duration then
				LoginScreenBlend:SetAlpha( 1 - (blend_start - ModelList.blend_start_duration/2)/(ModelList.blend_start_duration/2) )
				blend_start = blend_start + dt
			elseif blend_start <= ModelList.blend_start_duration/2 then
				blend_start = blend_start + dt
			else
				LoginScreenBlend:SetAlpha(0)
				blend_start = false
			end
		end
		
		local cur = M[ModelList.current_scene]
		if cur.duration ~= -1 then
			if cur.duration < blend_timer then		-- Scene and blend timer for next scene and blends between the scenes
				if ModelList.max_scenes > 1 then
					local blend = blend_timer - cur.duration
					if blend < ModelList.fade_duration then
						LoginScreenBlend:SetAlpha( 1 - math.abs( 1 - (blend*2 / ModelList.fade_duration) ) )
						
						if blend*2 > ModelList.fade_duration and not nextCset then
							nextC = randomScene()
							if ModelList.shuffle_scenes_randomly then
								if ModelList.current_scene == nextC then
									nextC = ((ModelList.current_scene+1 > ModelList.max_scenes) and 1) or ModelList.current_scene + 1
								end
							else
								nextC = ((ModelList.current_scene+1 > ModelList.max_scenes) and 1) or ModelList.current_scene + 1
							end
							nextCset = true
							
							local new = M[nextC]
							cur.parent:Hide()
							new.parent:Show()
							if type(new.background)=="table" then
								LoginScreenBackground:SetTexture(new.background[1],new.background[2],new.background[3],new.background[4])
							else
								LoginScreenBackground:SetTexture(new.background)
							end
							Scene_OnEnd(ModelList.current_scene)
							Scene_OnStart(nextC)
						end
						
						blend_timer = blend_timer + dt
					else
						ModelList.current_scene = nextC
						nextCset = false
						blend_timer = 0
						LoginScreenBlend:SetAlpha(0)
					end
				else
					blend_timer = 0
					Scene_OnEnd(ModelList.current_scene)
					Scene_OnStart(ModelList.current_scene)
				end
			else
				blend_timer = blend_timer + dt
			end
		end
		
		SceneUpdate(dt, ModelList.current_scene, blend_timer, ModelList.sceneData[ModelList.current_scene][1])
	end
end

function SetScene(sceneID)
	M[ModelList.current_scene].parent:Hide()
	M[sceneID].parent:Show()
	if type(M[sceneID].background)=="table" then
		LoginScreenBackground:SetTexture(M[sceneID].background[1],M[sceneID].background[2],M[sceneID].background[3],M[sceneID].background[4])
	else
		LoginScreenBackground:SetTexture(M[sceneID].background)
	end
	Scene_OnEnd(ModelList.current_scene)
	Scene_OnStart(sceneID)
	ModelList.current_scene = sceneID
end

function GetScene(sceneID)
	local curScene = ModelList.current_scene
	if sceneID then
		if sceneID <= ModelList.max_scenes and sceneID > 0 then
			curScene = sceneID
		end
	end
	return curScene, ModelList.sceneData[curScene], GetModel(curScene, true), GetModelData(curScene, true)
end

function GetModelData(refID, allSceneModels)
	local data, count = {}, 0
	if allSceneModels then
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == refID then
					table.insert(data, num, m)
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	else
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[13] == refID then
					table.insert(data, num, m)
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	end
end

function GetModel(refID, allSceneModels)
	local data, count = {} ,0
	if allSceneModels then
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == refID then
					table.insert(data, num, M[m[1]][num])
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	else
		local mData = GetModelData(refID)
		if mData then
			for num, m in pairs(mData) do
				table.insert(data, num, M[m[1]][num])
				count = count + 1
			end
			return (count > 0 and data) or false
		else
			return false
		end
	end
end

-- overwrite GlueParent function

function SetGlueScreen(name)
	local newFrame;
	for index, value in pairs(GlueScreenInfo) do
		local frame = _G[value];
		if ( frame ) then
			frame:Hide();
			if ( index == name ) then
				newFrame = frame;
			end
		end
	end
	
	if ( newFrame ) then
		newFrame:Show();
		SetCurrentScreen(name);
		SetCurrentGlueScreenName(name);
		if ( name == "login" ) then
			if ModelList.login_music_path then
				PlayMusic(ModelList.login_music_path)
			end
			if ModelList.login_ambience_name then
				PlayGlueAmbience(ModelList.login_ambience_name,5.0)
			end
		end
	end
end

------------------------------------------------------------------------------------------------------
------									SCENE SCRIPTING PART									------
------------------------------------------------------------------------------------------------------

-- function run right after everything is set up (run before first Scene_OnStart())
function Loginscreen_OnLoad()
	-- Scene scripts that need to be initialized  (setting values and shit)
end

-- update function that gets called each frame
function SceneUpdate(dt, sceneID, timer, sceneTime)
	-- Scene scripts that need updates each frame (moving a model for example) go in here.
end

-- on end function that gets called when the scene ends
function Scene_OnEnd(sceneID)
	-- Scene scripts that need an update at the end of a scene (resetting the position of a moving model for example) go in here.
end

-- on start function that gets called when the scene starts
function Scene_OnStart(sceneID)
	-- Scene scripts that need an update at the start of a scene (one time spell visual for example) go in here.
end
