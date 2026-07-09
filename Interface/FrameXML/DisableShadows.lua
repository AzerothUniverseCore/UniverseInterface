------------------------------------------------------------------------------------
--[[ --------------------- VENDETTA WOW - Shadow Disabler --------------------- ]]--
------------------------------------------------------------------------------------

local DisableShadows = CreateFrame("Frame", "MUI_DisableShadows", UIParent);
DisableShadows:RegisterEvent("ADDON_LOADED")
DisableShadows:RegisterEvent("PLAYER_LOGOUT")
DisableShadows:RegisterEvent("PLAYER_ENTERING_WORLD")

function ShadowEventHandler(self, event, ...)
	if ( event == "ADDON_LOADED") then
		BackupValue = GetCVar("extShadowQuality")
	end

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		mapname = GetInstanceInfo()
		if mapname == "Caída de Crinceniza" or mapname == "Arena Filospada HD" then
			SetCVar("extShadowQuality", 0)
		else
			SetCVar("extShadowQuality", BackupValue)
		end
	end

	if (event == "PLAYER_LOGOUT") then
		SetCVar("extShadowQuality", BackupValue)
	end
end

DisableShadows:SetScript("OnEvent", ShadowEventHandler)