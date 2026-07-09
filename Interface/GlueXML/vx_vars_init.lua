-- Data Storage
local vx_screen_listing = {
    ["cl"] = { "Interface\\Glues\\Models\\UI_MainMenu\\UI_MainMenu.m2", "Sound\\Music\\GlueScreenMusic\\wow_main_theme.mp3", "", "encl" },
    ["bc"] = { "Interface\\Glues\\Models\\UI_MainMenu_BurningCrusade\\UI_MainMenu_BurningCrusade.m2", "Sound\\music\\gluescreenmusic\\bc_main_theme.mp3", "", "enbc" },
    ["lk"] = { "Interface\\Glues\\Models\\UI_MainMenu_Northrend\\UI_MainMenu_Northrend.m2", "Sound\\Music\\lichking\\WotLK_main_title.mp3", "", "enlk" },
    ["ns"] = { "Interface\\Glues\\Models\\UI_MainMenu_Northrend\\UI_MainMenu_Northrend_noSindra.m2", "Sound\\Music\\lichking\\WotLK_main_title.mp3", "", "enlk" },
    ["ca"] = { "Interface\\Glues\\Models\\ui_mainmenu_cataclysm\\ui_mainmenu_cataclysm.m2", "Sound\\music\\cataclysm\\mus_shattering_uu01.mp3", "", "encc" },
    ["mp"] = { "Interface\\Glues\\Models\\ui_mainmenu_pandaria\\ui_mainmenu_pandaria.m2", "Sound\\music\\pandaria\\mus_50_heartofpandaria_01.mp3", "", "enmp" },
    ["wd"] = { "Interface\\Glues\\Models\\ui_mainmenu_warlords\\ui_mainmenu_warlords.m2", "Sound\\music\\draenor\\mus_60_asiegeofworlds_maintitle.mp3", "", "enwd" },
    ["le"] = { "Interface\\Glues\\Models\\ui_mainmenu_legion\\ui_mainmenu_legion.m2", "Sound\\music\\legion\\mus_70_kingdomswillburn_maintitle.mp3", "", "enle" },
    ["ln"] = { "Interface\\Glues\\Models\\ui_mainmenu_legio2\\ui_mainmenu_legio2.m2", "Sound\\music\\legion\\mus_70_kingdomswillburn_maintitle.mp3", "", "enle" },
    ["ba"] = { "Interface\\Glues\\Models\\ui_mainmenu_battleforazeroth\\ui_mainmenu_battleforazeroth.m2", "Sound\\music\\battleforazeroth\\mus_80_beforethestorm_maintitle.mp3", "", "enba" },
    ["sl"] = { "Interface\\Glues\\Models\\ui_mainmenu_shadowlands\\ui_mainmenu_shadowlands.m2", "Sound\\music\\shadowlands\\mus_90_throughtheroofoftheworld_maintitle.mp3", "", "ensl" },
    ["df"] = { "Interface\\Glues\\Models\\ui_mainmenu_dragonflight\\ui_mainmenu_dragonisles.m2", "Sound\\music\\dragonflight\\Dragonflight_Login_Screen_Music.mp3", "", "ensl" },
    ["nd"] = { "Interface\\Glues\\Models\\ui_mainmenu_dragonflight\\ui_mainmenu_dragonisles_nd.m2", "Sound\\music\\dragonflight\\Dragonflight_Login_Screen_Music.mp3", "", "ensl" },
	["ww"] = { "Interface\\Glues\\Models\\ui_mainmenu_warwithin\\ui_mainmenu_warwithin.m2", "Sound\\music\\warwithin\\mus_110_thewarwithin_maintitle.mp3", "", "ensl" },
	["wn"] = { "Interface\\Glues\\Models\\ui_mainmenu_warwithin\\ui_mainmenu_warwithin_02.m2", "Sound\\music\\warwithin\\mus_110_thewarwithin_maintitle.mp3", "", "ensl" },
    ["dy"] = { "Interface\\Glues\\Models\\ui_dracthyr\\ui_dracthyr.m2", "Sound\\music\\dragonflight\\mus_100_scene_ruby_oathstone_empowered.mp3", "", "ensl" },
    ["al"] = { "Interface\\Glues\\Models\\ui_alliance\\ui_alliance.m2", "Sound\\music\\shadowlands\\mus_90_rtc_acc_alliance.mp3", "", "enba" },
    ["ho"] = { "Interface\\Glues\\Models\\ui_horde\\ui_horde.m2", "Sound\\music\\shadowlands\\mus_90_rtc_acc_horde.mp3", "", "enba" },
    ["be"] = { "Interface\\Glues\\Models\\UI_BloodElf\\UI_BloodElf.m2", "Sound\\music\\zonemusic\\eversong\\es_silvermoonintro01.mp3", "", "enbc" },
    ["dk"] = { "Interface\\Glues\\Models\\UI_DeathKnight\\UI_DeathKnight.m2", "Sound\\music\\zonemusic\\ebon hold\\eh_assaultuni01.mp3", "", "enlk" },
	["dt"] = { "Interface\\Glues\\Models\\UI_DeathKnigh2\\UI_DeathKnigh2.m2", "Sound\\music\\zonemusic\\ebon hold\\eh_assaultuni01.mp3", "", "enlk" },
    ["dh"] = { "Interface\\Glues\\Models\\ui_demonhunter\\ui_demonhunter.m2", "Sound\\music\\legion\\mus_70_demonhunterpt1_b.mp3", "", "enle" },
    ["dr"] = { "Interface\\Glues\\Models\\UI_Draenei\\UI_DRAENEI.M2", "Sound\\music\\zonemusic\\azuremyst\\ai_exodarintro01.mp3", "", "enbc" },
    ["ld"] = { "Interface\\Glues\\Models\\ui_lightforgeddraenei\\ui_lightforgeddraenei.m2", "Sound\\music\\legion\\mus_735_alliedrace_lightforgeddraenei_vindicaar_01_02.mp3", "", "enle" },
    ["dg"] = { "Interface\\Glues\\Models\\UI_Dwarf\\UI_Dwarf.m2", "Sound\\music\\citymusic\\ironforge\\ironforge intro.mp3", "", "encl" },
    ["dw"] = { "Interface\\Glues\\Models\\UI_Dwar2\\UI_Dwar2.m2", "Sound\\music\\citymusic\\ironforge\\ironforge walking 02.mp3", "", "encl" },
    ["id"] = { "Interface\\Glues\\Models\\ui_darkirondwarf\\ui_darkirondwarf.m2", "Sound\\music\\cataclysm\\mus_darkironforge_gu01.mp3", "", "enba" },
    ["gn"] = { "Interface\\Glues\\Models\\ui_gnome\\ui_gnome.m2", "Sound\\music\\citymusic\\gnomeragon\\gnomeragon01-zone.mp3", "", "encc" },
    ["mg"] = { "Interface\\Glues\\Models\\ui_mechagnome\\ui_mechagnome.m2", "Sound\\music\\battleforazeroth\\mus_83_mechagnome_alliedrace_a.mp3", "", "enba" },
    ["hm"] = { "Interface\\Glues\\Models\\UI_Human\\UI_Human.m2", "Sound\\music\\citymusic\\stormwind\\stormwind01-moment.mp3", "", "encl" },
    ["hu"] = { "Interface\\Glues\\Models\\UI_Huma2\\UI_Huma2.m2", "Sound\\music\\citymusic\\stormwind\\stormwind03-moment.mp3", "", "encl" },
    ["wr"] = { "Interface\\Glues\\Models\\ui_worgen\\ui_worgen.m2", "Sound\\music\\cataclysm\\mus_gilneasevent_e04.mp3", "", "encc" },
    ["ne"] = { "Interface\\Glues\\Models\\UI_NightElf\\UI_NightElf.m2", "Sound\\music\\battleforazeroth\\mus_80_event_teldrassil_darnassusintro_h.mp3", "", "encl" },
    ["nl"] = { "Interface\\Glues\\Models\\UI_NightEl2\\UI_NightEl2.m2", "Sound\\music\\citymusic\\darnassus\\druid grove.mp3", "", "encl" },
    ["nf"] = { "Interface\\Glues\\Models\\ui_nightborneelf\\ui_nightborneelf.m2", "Sound\\music\\legion\\mus_70_suramar_pt1_h.mp3", "", "enle" },
    ["ot"] = { "Interface\\Glues\\Models\\UI_Orc\\UI_Orc.m2", "Sound\\music\\citymusic\\orgrimmar\\orgrimmar01-moment.mp3", "", "encl" },
    ["or"] = { "Interface\\Glues\\Models\\UI_Or2\\UI_Or2.m2", "Sound\\music\\cataclysm\\mus_orgrimmarlegacy_gu01.mp3", "", "encl" },
    ["oc"] = { "Interface\\Glues\\Models\\ui_orcclan\\ui_orcclan.m2", "Sound\\music\\battleforazeroth\\mus_80_maghar_a.mp3", "", "enba" },
    ["gb"] = { "Interface\\Glues\\Models\\ui_goblin\\ui_goblin.m2", "Sound\\music\\citymusic\\kezan\\muz_goblin_castaways.mp3", "", "encc" },
    ["tl"] = { "Interface\\Glues\\Models\\ui_troll\\ui_troll.m2", "Sound\\music\\zonemusic\\orgrimmar\\mus_dark_spear_troll.mp3", "", "encc" },
    ["ud"] = { "Interface\\Glues\\Models\\UI_Scourge\\UI_Scourge.m2", "Sound\\music\\citymusic\\undercity\\undercity02-zone.mp3", "", "encl" },
    ["sc"] = { "Interface\\Glues\\Models\\UI_SCOURG2\\UI_Scourg2.m2", "Sound\\music\\citymusic\\undercity\\undercity03-zone.mp3", "", "encl" },
    ["tr"] = { "Interface\\Glues\\Models\\UI_Tauren\\UI_Tauren.m2", "Sound\\music\\zonemusic\\taverntauren\\ra_taurenrestarea2b.mp3", "", "encl" },
    ["ta"] = { "Interface\\Glues\\Models\\UI_Taure2\\UI_Taure2.m2", "Sound\\music\\cataclysm\\mus_thunderbluff_gu03.mp3", "", "encl" },
    ["hr"] = { "Interface\\Glues\\Models\\ui_highmountaintauren\\ui_highmountaintauren.m2", "Sound\\music\\shadowlands\\mus_91_huln_highmountain_h.mp3", "", "enle" },
    ["pd"] = { "Interface\\Glues\\Models\\ui_pandaren\\ui_pandaren.m2", "Sound\\music\\pandaria\\mus_54_forthepandarenalliance_a_02.mp3", "" ,"enmp" },
    ["pn"] = { "Interface\\Glues\\Models\\ui_pandarencharacterselect\\ui_pandarencharacterselect.m2", "Sound\\music\\pandaria\\mus_50_bamboo_hero_01.mp3", "", "enmp" },
    ["kt"] = { "Interface\\Glues\\Models\\ui_kultiran\\ui_kultiran.m2", "Sound\\music\\battleforazeroth\\mus_83_boralus_extended.mp3", "", "enba" },
    ["vp"] = { "Interface\\Glues\\Models\\ui_vulpera\\ui_vulpera.m2", "Sound\\music\\battleforazeroth\\mus_83_vulpera_alliedrace_a.mp3", "", "enba" },
    ["ve"] = { "Interface\\Glues\\Models\\ui_voidelf\\ui_voidelf.m2", "Sound\\music\\legion\\mus_735_alliedrace_voidelf_01_01.mp3", "", "enle" },
    ["zl"] = { "Interface\\Glues\\Models\\ui_zandalari\\ui_zandalari.m2", "Sound\\music\\mus_80_zuldazar_dazaralor_intro.mp3", "", "enba" },
    ["ea"] = { "Interface\\Glues\\Models\\ui_earthen\\ui_earthen.m2", "Sound\\music\\dragonflight\\mus_101_ebyssian_earthwarder_h.mp3", "", "enww" },
    ["tp"] = { "Interface\\Glues\\Models\\ui_pirate\\ui_pirate.m2", "Sound\\music\\dragonflight\\mus_101_ebyssian_earthwarder_h.mp3", "", "enww" },
	["cs"] = { "Interface\\Glues\\Models\\UI_CharacterSelect\\UI_CharacterSelect.M2", "Sound\\music\\wow_a_call_to_arms.mp3", "", "encs" },
    ["bl"] = { "Environments\\Stars\\Stars.m2", "GlueScreenIntro", "", "encl" },
}

local vx_logo_listing = { -- put into "Interface\\Glues\\Common\\"
    ["encl"] = { "Glues-WoW-Logo" },
    ["chcl"] = { "Glues-WoW-ChineseLogo" },
    ["twcl"] = { "Glues-WoW-TaiwanLogo" },
	["enst"] = { "glues-wow-starterlogo" },
	["eccl"] = { "wow_classic-logohr" },
	["cccl"] = { "wow_classic-logohr_cn" },	
	["tccl"] = { "wow_classic-logohr_tw" },
	["enc2"] = { "wow_Winter_Veil" },
	["enc3"] = { "WoWTAG-Logo" },
	["enc4"] = { "gamelogo-worldofwarcraft" },
	["enbc"] = { "GLUES-WOW-BCLOGO" },
    ["chbc"] = { "Glues-WoW-ChineseBCLogo" },
    ["twbc"] = { "GLUES-WOW-TAIWANBCLOGO" },
	["ecbc"] = { "glues-wow-burningcrusadeclassiclogo" },
	["enb2"] = { "WoW_BC_Classic_logo3" },
	["enb3"] = { "WoW_BC_Classic_logo-a" },
    ["enlk"] = { "Glues-WoW-WotLKLogo" },
    ["enLK"] = { "Glues-WOW-WoltkLogo" },
    ["chlk"] = { "Glues-WoW-ChineseWotLKLogo" },
    ["twlk"] = { "Glues-WoW-TaiwanWotLKLogo" },
	["eclk"] = { "glues-wow-wrathofthelichkingclassiclogo" },
	["enl2"] = { "WrathLogo2" },
	["enl3"] = { "WoW_Wrath_Classic_logo-a" },
    ["encc"] = { "Glues-WoW-CCLogo" },
    ["chcc"] = { "Glues-WoW-ChineseCCLogo" },
    ["twcc"] = { "Glues-WoW-TaiwanCCLogo" },
    ["enmp"] = { "Glues-WoW-MPlogo" },
    ["chmp"] = { "Glues-WoW-ChineseMPLogo" },
    ["twmp"] = { "Glues-WoW-TaiwanMPLogo" },
    ["enwd"] = { "Glues-WoW-WoDlogo" },
    ["chwd"] = { "Glues-WoW-ChineseWoDLogo" },
    ["twwd"] = { "Glues-WoW-TaiwanWoDLogo" },
    ["enle"] = { "Glues-WoW-Legionlogo" },
    ["chle"] = { "Glues-WoW-ChineseLegionLogo" },
    ["twle"] = { "Glues-WoW-TaiwanLegionLogo" },
    ["enba"] = { "Glues-WoW-BattleForAzerothLogo" },
    ["chba"] = { "Glues-WoW-BattleForAzerothLogo_CN" },
    ["twba"] = { "Glues-WoW-BattleForAzerothLogo_TW" },
    ["ensl"] = { "Glues-WoW-ShadowlandsLogo" },
    ["chsl"] = { "Glues-WoW-ShadowlandsLogo_CN" },
	["endf"] = { "glues-wow-dragonflightlogo" },
	["twdf"] = { "glues-wow-dragonflightlogo_tw" },
    ["encs"] = { "Glues-Logo" },
    ["twcs"] = { "Glues-Logo-Taiwan" },
    ["enbl"] = { "Glues-WoW-BlLogo" },
	["enm1"] = { "wow_Mobile_armorylogo" },
	["ena1"] = { "wow_arena_worldchampionship" },
	["enww"] = { "World_of_Warcraft_The_War_Within_Logo" },
	["lkhd"] = { "WrathLogohdclient" },
	["eca1"] = { "gamelogo-cataclysmclassic" },
}

-- Fixed Random Function
lastIdxScene = 0; lastIdxMusic = 0;
rndScene = 1; rndMusic = 1;

function IsItRandom(bottom, top)
    local t = time() % math.random(23 * 11);
    while t > 0 do 
        t = t - 1
        math.random()
    end
    return math.random(bottom, top)
end
-- End Random Function

function ShowScene(self)
    local selectedScreen; local selectedScreenID;

    if #vx.SceneList > 0 then 
        if #vx.SceneList > 1 then
            repeat
                rndScene = IsItRandom(1,#vx.SceneList)
            until (rndScene ~= lastIdxScene and rndScene <= #vx.SceneList)
            lastIdxScene = rndScene
        end

        selectedScreenID = vx.SceneList[rndScene];

        if vx_screen_listing[selectedScreenID] == nil then
            VXBGTextureAL:SetTexture(selectedScreenID);
			VXBGTextureAL:Show();
        else
            VXBGTextureAL:Hide();
            selectedScreen = vx_screen_listing[selectedScreenID][1]; -- "Interface\\Glues\\Models\\UI_MainMenu_Northrend\\UI_MainMenu_Northrend.m2"
            self:SetModel(selectedScreen);
        end
    else
        self:SetModel(vx_screen_listing["lk"][1]);
    end
    
    self:SetCamera(0);
    self:SetSequence(0);
end

function PlaySceneMusic()
    StopMusic(); StopGlueMusic(); -- Stop Previous Music

    local selectedTrack; local selectedMusic; local selectedScreenID;

    if #vx.LoginMusic > 0 or #vx.SceneList > 0 then
        if #vx.LoginMusic > 0 then
            if #vx.LoginMusic > 1 then
                repeat
                    rndMusic = IsItRandom(1,#vx.LoginMusic)
                until (rndMusic ~= lastIdxMusic)
                lastIdxMusic = rndMusic
            end

            selectedTrack = vx.LoginMusic[rndMusic];
            local mp3Check = string.find(selectedTrack, "%.");

            if mp3Check then 
                PlayMusic(selectedTrack);
            else 
                selectedMusic = vx_screen_listing[selectedTrack][2];
                PlayMusic(selectedMusic);
            end
        else 
            selectedScreenID = vx.SceneList[rndScene];

            if vx_screen_listing[selectedScreenID] == nil then
                PlayMusic(vx_screen_listing["lk"][2]);
            else
                selectedMusic = vx_screen_listing[selectedScreenID][2]; -- "Sound\\Music\\GlueScreenMusic\\WotLK_main_title.mp3"
                PlayMusic(selectedMusic);
            end
        end
    else
        PlayMusic(vx_screen_listing["lk"][2]);
    end
end

function ShowSceneLogo()
    local selectedLogoID; local selectedScreenID;

    if not VX_LOGO_TEXTURE and not VX_LOGO then
        if #vx.SceneList > 0 then
            selectedScreenID = vx.SceneList[rndScene];

            if vx_screen_listing[selectedScreenID] == nil then
                selectedLogoID = vx_screen_listing["lk"][4];
            else
                selectedLogoID = vx_screen_listing[selectedScreenID][4];
            end
        else
            selectedLogoID = vx_screen_listing["lk"][4];
        end

        VX_LOGO_TEXTURE_SHOW = "Interface\\Glues\\Common\\" ..vx_logo_listing[selectedLogoID][1];

    elseif not VX_LOGO_TEXTURE then
        selectedLogoID = VX_LOGO;
        VX_LOGO_TEXTURE_SHOW = "Interface\\Glues\\Common\\" ..vx_logo_listing[selectedLogoID][1];
    else
        VX_LOGO_TEXTURE_SHOW = VX_LOGO_TEXTURE;
    end

    AccountLoginLogo:SetTexture(VX_LOGO_TEXTURE_SHOW);
end

function ConvertAccountString(account)
	if account.Login then
		account.Login = "VX_Login_string"..strrev(account.Login);
	else
		account.Login = "";
	end
	if account.Password then
		account.Password = "VX_Password_string"..strrev(account.Password);
	else
		account.Password = "";
	end
	return account
end

if vx.ServerList then
	for i = 1, #vx.ServerList, 1 do
		if vx.ServerList[i].AccountList then
			for j = 1, #vx.ServerList[i].AccountList, 1 do
				vx.ServerList[i].AccountList[j] = ConvertAccountString(vx.ServerList[i].AccountList[j]);
			end
		end
	end
end

if vx.AccountList then
	for i = 1, #vx.AccountList, 1 do
		vx.AccountList[i] = ConvertAccountString(vx.AccountList[i]);
	end
end