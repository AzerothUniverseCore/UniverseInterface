---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----------------------- AZEROTH UNIVERSE WOW - LK AccountLogin Customization ------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
NewsState = GetCVar("realmListbn")

NumeroParche = "Azeroth Universe 3.3.9"
BuildLK = "|cff8080ffBuild 49448 - 08 June 2024|r"

SyphrenaLKVersion = AccountLoginUI:CreateFontString("$parentText", "OVERLAY", "GlueFontNormal");
SyphrenaLKVersion:SetPoint("CENTER", AccountLoginUI, "BOTTOM", -15, 40);
SyphrenaLKVersion:SetText("|cff8080ff"..NumeroParche.."|r")

SyphrenaLKVersion2 = AccountLoginUI:CreateFontString("$parentText", "OVERLAY", "GlueFontNormalSmall");
SyphrenaLKVersion2:SetPoint("BOTTOM", SyphrenaLKVersion, "BOTTOM", 0, -17);
SyphrenaLKVersion2:SetText(BuildLK)

--Define Social URLs:
FACEBOOK_URL = "http://www.facebook.com/"
TWITTER_URL = "http://twitter.com/"
YOUTUBE_URL = "https://www.youtube.com/channel/UCkcnscSH0qJfiWMOpQBBBYQ"
DISCORD_URL = "https://discordapp.com/invite/9kfczSTdWk"

--Launch URL Functions
function LaunchFacebook()
	PlaySound("gsLoginNewAccount");
	LaunchURL(FACEBOOK_URL);
end

function LaunchTwitter()
	PlaySound("gsLoginNewAccount");
	LaunchURL(TWITTER_URL);
end

function LaunchYoutube()
	PlaySound("gsLoginNewAccount");
	LaunchURL(YOUTUBE_URL);
end

function LaunchDiscord()
	PlaySound("gsLoginNewAccount");
	LaunchURL(DISCORD_URL);
end

function HideNews()
	ServerAlertFrame:Hide()
	SetCVar("realmListbn", "HideNews");
end

function ShowNews()
	ServerAlertFrame:Show()
	SetCVar("realmListbn", "ShowNews");
end

backdropTF = {		-- TOOLS FRAME BACKDROP
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 32,
	insets = {
		left = 11,
		right = 12,
		top = 12,
		bottom = 11
	}
}

RedesFrame = CreateFrame("Frame",nil,LoginScene)
RedesFrame:SetBackdrop(backdropTF)
RedesFrame:SetSize(130, 130)
RedesFrame:SetFrameStrata("HIGH")
RedesFrame:SetPoint("CENTER", Redes, "CENTER", 0, 90)
RedesFrame:EnableMouseWheel(true)
RedesFrame:Hide()

Facebook = CreateFrame("Button", nil, RedesFrame)
Facebook:SetPoint("CENTER", RedesFrame, "CENTER", -25, 25)
Facebook:SetSize(40,40);
Facebook:SetNormalTexture("Vendetta\\Login\\TitanFacebookNormal")
Facebook:SetPushedTexture("Vendetta\\Login\\TitanFacebookPushed")
Facebook:SetHighlightTexture("Vendetta\\Login\\TitanFacebookHighlight")
Facebook:SetScript("OnClick", function(self, button, down)
		LaunchFacebook()
end)

Twitter = CreateFrame("Button", nil, RedesFrame)
Twitter:SetPoint("CENTER", RedesFrame, "CENTER", 25, 25)
Twitter:SetSize(40,40);
Twitter:SetNormalTexture("Vendetta\\Login\\TitanTwitterNormal")
Twitter:SetPushedTexture("Vendetta\\Login\\TitanTwitterPushed")
Twitter:SetHighlightTexture("Vendetta\\Login\\TitanTwitterHighlight")
Twitter:SetScript("OnClick", function(self, button, down)
		LaunchTwitter()
end)

Youtube = CreateFrame("Button", nil, RedesFrame)
Youtube:SetPoint("CENTER", RedesFrame, "CENTER", 25, -25)
Youtube:SetSize(40,40);
Youtube:SetNormalTexture("Vendetta\\Login\\TitanYoutubeNormal")
Youtube:SetPushedTexture("Vendetta\\Login\\TitanYoutubePushed")
Youtube:SetHighlightTexture("Vendetta\\Login\\TitanYoutubeHighlight")
Youtube:SetScript("OnClick", function(self, button, down)
		LaunchYoutube()
end)

Discord = CreateFrame("Button", nil, RedesFrame)
Discord:SetPoint("CENTER", RedesFrame, "CENTER", -25, -25)
Discord:SetSize(40,40);
Discord:SetNormalTexture("Vendetta\\Login\\TitanDiscordNormal")
Discord:SetPushedTexture("Vendetta\\Login\\TitanDiscordPushed")
Discord:SetHighlightTexture("Vendetta\\Login\\TitanDiscordHighlight")
Discord:SetScript("OnClick", function(self, button, down)
		LaunchDiscord()
end)

OptionsButton:SetPoint("BOTTOM", AccountLoginExitButton, "TOP", 0, 0)

