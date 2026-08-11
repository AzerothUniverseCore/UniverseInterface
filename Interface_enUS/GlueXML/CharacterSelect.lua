CHARACTER_SELECT_ROTATION_START_X = nil;
CHARACTER_SELECT_INITIAL_FACING = nil;
CHARACTER_ROTATION_CONSTANT = 0.6;
MAX_CHARACTERS_DISPLAYED = 20;
MAX_CHARACTERS_PER_REALM = 20;
local ShadowTable = {}
local CharacterButtons = {}
local ClassToIcon = {
	["Warrior"] = {"CharSelectWarrior", "|cFFC79C6E"},
	["Warrior"] = {"CharSelectWarrior", "|cFFC79C6E"},
	["Paladin"] = {"CharSelectPaladin", "|cFFF58CBA"},
	["Paladin"] = {"CharSelectPaladin", "|cFFF58CBA"},
	["Hunter"] = {"CharSelectHunter", "|cFFA9D271"},
	["Hunter"] = {"CharSelectHunter", "|cFFA9D271"},
	["Rogue"] = {"CharSelectRogue", "|cFFFFF569"},
	["Rogue"] = {"CharSelectRogue", "|cFFFFF569"},
	["Priest"] = {"CharSelectPriest", "|cFFFFFFFF"},
	["Priest"] = {"CharSelectPriest", "|cFFFFFFFF"},
	["DK"] = {"CharSelectDeathknight", "|cFFC41F3B"},
	["DK"] = {"CharSelectDeathknight", "|cFFC41F3B"},
	["Shaman"] = {"CharSelectShaman", "|cFF0070DE"},
	["Shaman"] = {"CharSelectShaman", "|cFF0070DE"},
	["Mage"] = {"CharSelectMage", "|cFF40C7EB"},
	["Mage"] = {"CharSelectMage", "|cFF40C7EB"},
	["Warlock"] = {"CharSelectWarlock", "|cFF8787ED"},
	["Warlock"] = {"CharSelectWarlock", "|cFF8787ED"},
	["BBM"] = {"CharSelectBloodBattleMage", "|cffeb0000"},
	["BBM"] = {"CharSelectBloodBattleMage", "|cffeb0000"},
	["Druid"] = {"CharSelectDruid", "|cFFFF7D0A"},
	["Druid"] = {"CharSelectDruid", "|cFFFF7D0A"},
	["Knight"] = {"CharSelectKnight", "|cfffadd16"},
	["Knight"] = {"CharSelectKnight", "|cfffadd16"},
	["DH"] = {"CharSelectDemonHunter", "|cffa330c9"},
	["DH"] = {"CharSelectDemonHunter", "|cffa330c9"},
	["Monk"] = {"CharSelectMonk", "|cff00ff96"},
	["Monk"] = {"CharSelectMonk", "|cff00ff96"},
	["Tamer"] = {"CharSelectTamer", "|cffffffff"},
	["Tamer"] = {"CharSelectTamer", "|cffffffff"},
	["Hero"] = {"CharSelectHeros", "|cfffdc5b8"},
	["Hero"] = {"CharSelectHeros", "|cfffdc5b8"},
	["Evoker"] = {"CharSelectEvoker", "|cff33937f"},
	["Evoker"] = {"CharSelectEvoker", "|cff33937f"},
	["Necromancer"] = {"CharSelectMancer", "|cff07c204"},
	["Necromancer"] = {"CharSelectMancer", "|cff07c204"},
	["Venomancer"] = {"CharSelectMancer", "|cfff57d20"},
	["Venomancer"] = {"CharSelectMancer", "|cfff57d20"},
	["Chronomancer"] = {"CharSelectMancer", "|cffa3bcbf"},
	["Chronomancer"] = {"CharSelectMancer", "|cffa3bcbf"},
	["Geomancer"] = {"CharSelectMancer", "|cffc4e96c"},
	["Geomancer"] = {"CharSelectMancer", "|cffc4e96c"},
	["Pyromancer"] = {"CharSelectMancer", "|cffff5204"},
	["Pyromancer"] = {"CharSelectMancer", "|cffff5204"},
	["CR"] = {"CharSelectChaosRavager", "|cffb79d44"},
	["CR"] = {"CharSelectChaosRavager", "|cffb79d44"},
}

function CharacterSelect_OnLoad(self)
	self:SetSequence(0);
	self:SetCamera(0);

	self.createIndex = 0;
	self.selectedIndex = 0;
	self.selectLast = 0;
	self.currentModel = nil;
	self:RegisterEvent("ADDON_LIST_UPDATE");
	self:RegisterEvent("CHARACTER_LIST_UPDATE");
	self:RegisterEvent("UPDATE_SELECTED_CHARACTER");
	self:RegisterEvent("SELECT_LAST_CHARACTER");
	self:RegisterEvent("SELECT_FIRST_CHARACTER");
	self:RegisterEvent("SUGGEST_REALM");
	self:RegisterEvent("FORCE_RENAME_CHARACTER");

	-- CharacterSelect:SetModel("Interface\\Glues\\Models\\UI_Orc\\UI_Orc.m2");

	-- local fogInfo = CharModelFogInfo["ORC"];
	-- CharacterSelect:SetFogColor(fogInfo.r, fogInfo.g, fogInfo.b);
	-- CharacterSelect:SetFogNear(0);
	-- CharacterSelect:SetFogFar(fogInfo.far);

	SetCharSelectModelFrame("CharacterSelect");

	-- Color edit box backdrops
	local backdropColor = DEFAULT_TOOLTIP_COLOR;
	CharacterSelectCharacterFrame:SetBackdropBorderColor(0, 0, 1, 0);
	CharacterSelectCharacterFrame:SetBackdropColor(1, 1, 1, 0)
end

function CharacterSelect_OnShow()
	-- request account data times from the server (so we know if we should refresh keybindings, etc...)
	ReadyForAccountDataTimes()
	
	local CurrentModel = CharacterSelect.currentModel;

	if ( CurrentModel ) then
		PlayGlueAmbience(GlueAmbienceTracks[strupper(CurrentModel)], 4.0);
	end

	UpdateAddonButton();

	local serverName, isPVP, isRP = GetServerName();
	local connected = IsConnectedToServer();
	local serverType = "";
	if ( serverName ) then
		if( not connected ) then
			serverName = serverName.."\n("..SERVER_DOWN..")";
		end
		if ( isPVP ) then
			if ( isRP ) then
				serverType = RPPVP_PARENTHESES;
			else
				serverType = PVP_PARENTHESES;
			end
		elseif ( isRP ) then
			serverType = RP_PARENTHESES;
		end
		CharSelectRealmName:SetText(serverName.." "..serverType);
		CharSelectRealmName:Show();
	else
		CharSelectRealmName:Hide();
	end

	if ( connected ) then
		GetCharacterListUpdate();
	else
		UpdateCharacterList();
	end

	-- Gameroom billing stuff (For Korea and China only)
	if ( SHOW_GAMEROOM_BILLING_FRAME ) then
		local paymentPlan, hasFallBackBillingMethod, isGameRoom = GetBillingPlan();
		if ( paymentPlan == 0 ) then
			-- No payment plan
			GameRoomBillingFrame:Hide();
			CharacterSelectRealmSplitButton:ClearAllPoints();
			CharacterSelectRealmSplitButton:SetPoint("TOP", CharacterSelectLogo, "BOTTOM", 0, -5);
		else
			local billingTimeLeft = GetBillingTimeRemaining();
			-- Set default text for the payment plan
			local billingText = _G["BILLING_TEXT"..paymentPlan];
			if ( paymentPlan == 1 ) then
				-- Recurring account
				billingTimeLeft = ceil(billingTimeLeft/(60 * 24));
				if ( billingTimeLeft == 1 ) then
					billingText = BILLING_TIME_LEFT_LAST_DAY;
				end
			elseif ( paymentPlan == 2 ) then
				-- Free account
				if ( billingTimeLeft < (24 * 60) ) then
					billingText = format(BILLING_FREE_TIME_EXPIRE, billingTimeLeft.." "..MINUTES_ABBR);
				end				
			elseif ( paymentPlan == 3 ) then
				-- Fixed but not recurring
				if ( isGameRoom == 1 ) then
					if ( billingTimeLeft <= 30 ) then
						billingText = BILLING_GAMEROOM_EXPIRE;
					else
						billingText = format(BILLING_FIXED_IGR, MinutesToTime(billingTimeLeft, 1));
					end
				else
					-- personal fixed plan
					if ( billingTimeLeft < (24 * 60) ) then
						billingText = BILLING_FIXED_LASTDAY;
					else
						billingText = format(billingText, MinutesToTime(billingTimeLeft));
					end	
				end
			elseif ( paymentPlan == 4 ) then
				-- Usage plan
				if ( isGameRoom == 1 ) then
					-- game room usage plan
					if ( billingTimeLeft <= 600 ) then
						billingText = BILLING_GAMEROOM_EXPIRE;
					else
						billingText = BILLING_IGR_USAGE;
					end
				else
					-- personal usage plan
					if ( billingTimeLeft <= 30 ) then
						billingText = BILLING_TIME_LEFT_30_MINS;
					else
						billingText = format(billingText, billingTimeLeft);
					end
				end
			end
			-- If fallback payment method add a note that says so
			if ( hasFallBackBillingMethod == 1 ) then
				billingText = billingText.."\n\n"..BILLING_HAS_FALLBACK_PAYMENT;
			end
			GameRoomBillingFrameText:SetText(billingText);
			GameRoomBillingFrame:SetHeight(GameRoomBillingFrameText:GetHeight() + 26);
			GameRoomBillingFrame:Show();
			--CharacterSelectRealmSplitButton:ClearAllPoints();
			--CharacterSelectRealmSplitButton:SetPoint("TOP", GameRoomBillingFrame, "BOTTOM", 0, -10);
		end
	end
	
	if( IsTrialAccount() ) then
		CharacterSelectUpgradeAccountButton:Show();
	else
		CharacterSelectUpgradeAccountButton:Hide();
	end

	-- fadein the character select ui
	GlueFrameFadeIn(CharacterSelectUI, CHARACTER_SELECT_FADE_IN)

	RealmSplitCurrentChoice:Hide();
	RequestRealmSplitInfo();

	--Clear out the addons selected item
	GlueDropDownMenu_SetSelectedValue(AddonCharacterDropDown, ALL);
	CharSelectShadows()
end

function CharacterSelect_OnHide()
	CharacterDeleteDialog:Hide();
	CharacterRenameDialog:Hide();
	if ( DeclensionFrame ) then
		DeclensionFrame:Hide();
	end
	SERVER_SPLIT_STATE_PENDING = -1;
end

function CharacterSelect_OnUpdate(elapsed)
	if ( SERVER_SPLIT_STATE_PENDING > 0 ) then
		--CharacterSelectRealmSplitButton:Show();

		if ( SERVER_SPLIT_CLIENT_STATE > 0 ) then
			RealmSplit_SetChoiceText();
			RealmSplitPending:SetPoint("TOP", RealmSplitCurrentChoice, "BOTTOM", 0, -10);
		else
			RealmSplitPending:SetPoint("TOP", CharacterSelectRealmSplitButton, "BOTTOM", 0, 0);
			RealmSplitCurrentChoice:Hide();
		end

		if ( SERVER_SPLIT_STATE_PENDING > 1 ) then
			CharacterSelectRealmSplitButton:Disable();
			CharacterSelectRealmSplitButtonGlow:Hide();
			RealmSplitPending:SetText( SERVER_SPLIT_PENDING );
		else
			CharacterSelectRealmSplitButton:Enable();
			CharacterSelectRealmSplitButtonGlow:Show();
			local datetext = SERVER_SPLIT_CHOOSE_BY.."\n"..SERVER_SPLIT_DATE;
			RealmSplitPending:SetText( datetext );
		end

		if ( SERVER_SPLIT_SHOW_DIALOG and not GlueDialog:IsShown() ) then
			SERVER_SPLIT_SHOW_DIALOG = false;
			local dialogString = format(SERVER_SPLIT,SERVER_SPLIT_DATE);
			if ( SERVER_SPLIT_CLIENT_STATE > 0 ) then
				local serverChoice = RealmSplit_GetFormatedChoice(SERVER_SPLIT_REALM_CHOICE);
				local stringWithDate = format(SERVER_SPLIT,SERVER_SPLIT_DATE);
				dialogString = stringWithDate.."\n\n"..serverChoice;
				GlueDialog_Show("SERVER_SPLIT_WITH_CHOICE", dialogString);
			else
				GlueDialog_Show("SERVER_SPLIT", dialogString);
			end
		end
	else
		CharacterSelectRealmSplitButton:Hide();
	end

	-- Account Msg stuff
	if ( (ACCOUNT_MSG_NUM_AVAILABLE > 0) and not GlueDialog:IsShown() ) then
		if ( ACCOUNT_MSG_HEADERS_LOADED ) then
			if ( ACCOUNT_MSG_BODY_LOADED ) then
				local dialogString = AccountMsg_GetHeaderSubject( ACCOUNT_MSG_CURRENT_INDEX ).."\n\n"..AccountMsg_GetBody();
				GlueDialog_Show("ACCOUNT_MSG", dialogString);
			end
		end
	end
end

function CharacterSelect_OnKeyDown(self,key)
	if ( key == "ESCAPE" ) then
		CharacterSelect_Exit();
	elseif ( key == "ENTER" ) then
		CharacterSelect_EnterWorld();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	elseif ( key == "UP" or key == "LEFT" ) then
		local numChars = GetNumCharacters();
		if ( numChars > 1 ) then
			if ( self.selectedIndex > 1 ) then
				CharacterSelect_SelectCharacter(self.selectedIndex - 1);
			else
				CharacterSelect_SelectCharacter(numChars);
			end
		end
	elseif ( arg1 == "DOWN" or arg1 == "RIGHT" ) then
		local numChars = GetNumCharacters();
		if ( numChars > 1 ) then
			if ( self.selectedIndex < GetNumCharacters() ) then
				CharacterSelect_SelectCharacter(self.selectedIndex + 1);
			else
				CharacterSelect_SelectCharacter(1);
			end
		end
	end
end
-- Suppression de l'affichage du nom de personnage sur l'UI Personnage (CharSelectCharacterName)
function CharacterSelect_OnEvent(self, event, ...)
	if ( event == "ADDON_LIST_UPDATE" ) then
		UpdateAddonButton();
	elseif ( event == "CHARACTER_LIST_UPDATE" ) then
		UpdateCharacterList();
		--CharSelectCharacterName:SetText(GetCharacterInfo(self.selectedIndex));
	elseif ( event == "UPDATE_SELECTED_CHARACTER" ) then
		local index = ...;
		if ( index == 0 ) then
			--CharSelectCharacterName:SetText("");
		else
			--CharSelectCharacterName:SetText(GetCharacterInfo(index));
			self.selectedIndex = index;
		end
		UpdateCharacterSelection(self);
		RepositionCharButtons()
	elseif ( event == "SELECT_LAST_CHARACTER" ) then
		self.selectLast = 1;
	elseif ( event == "SELECT_FIRST_CHARACTER" ) then
		CharacterSelect_SelectCharacter(1, 1);
	elseif ( event == "SUGGEST_REALM" ) then
		local category, id = ...;
		local name = GetRealmInfo(category, id);
		if ( name ) then
			SetGlueScreen("charselect");
			ChangeRealm(category, id);
		else
			if ( RealmList:IsShown() ) then
				RealmListUpdate();
			else
				RealmList:Show();
			end
		end
	elseif ( event == "FORCE_RENAME_CHARACTER" ) then
		local message = ...;
		CharacterRenameDialog:Show();
		CharacterRenameText1:SetText(_G[message]);
	end
end

function CharacterSelect_UpdateModel(self)
	UpdateSelectionCustomizationScene();
	self:AdvanceTime();
end

function UpdateCharacterSelection(self)
	for i=1, MAX_CHARACTERS_DISPLAYED, 1 do
		_G["CharSelectCharacterButton"..i]:UnlockHighlight();
	end

	local index = self.selectedIndex;
	if ( (index > 0) and (index <= MAX_CHARACTERS_DISPLAYED) )then
		_G["CharSelectCharacterButton"..index]:LockHighlight();
	end
end

function RepositionCharButtons()
	SetButtonDesaturated(CharSelectNoCustomizationButton, true)
    for i=1, #CharacterButtons do
        local buttonWidth = 100
        local dynamicWidth = (buttonWidth * #CharacterButtons)
        local resetPoint = (#CharacterButtons / 2) + 1;
        local yOffset = 0
        local _, _, class = GetCharacterInfo(i);
        buttonName = _G["CharSelectCharacterButton"..i]
        if class == "Death Knight" then
			class = "DK"
		end
		if class == "Demon Hunter" then
			class = "DH"
		end
		if class == "Blood Battle Mage" then
			class = "BBM"
		end
		if class == "Chaos Ravager" then
			class = "CR"
		end
        if ClassToIcon[class] ~= nil then
			buttonName:SetNormalTexture("Interface\\UniverseCharSelect\\"..ClassToIcon[class][1])
		else
			buttonName:SetNormalTexture("Interface\\UniverseCharSelect\\CharSelectBase")
		end
        if(#CharacterButtons > 10)then
            dynamicWidth = (buttonWidth * 10)
            resetPoint = 6
            if (i > 10) then
                yOffset = -50
                i = i - 10
                resetPoint = ((#CharacterButtons - 10) / 2) + 1;
            end
        end
        CharacterSelectCharacterFrame:SetWidth(dynamicWidth)
        buttonName:SetPoint("TOP", CharacterSelectCharacterFrame, "TOP", ( buttonWidth * i ) - ( resetPoint * buttonWidth ) + (buttonWidth / 2), yOffset);  
    end
end

function SetupCharacterCustomizationButtons(id)
	local numChars = GetNumCharacters();
	for i=1, numChars do
		_G["CharSelectCharacterCustomize"..i]:Hide();
		_G["CharSelectRaceChange"..i]:Hide();
		_G["CharSelectFactionChange"..i]:Hide();
		local CustomizeButton = _G["CharSelectCharacterCustomize"..i]
		local RaceButton = _G["CharSelectRaceChange"..i]
		local FactionButton = _G["CharSelectFactionChange"..i]
		CustomizeButton:SetPoint("TOP", CharacterSelectDeleteButton, "BOTTOM", 0, 0)
		RaceButton:SetPoint("TOP", CharacterSelectDeleteButton, "BOTTOM", 0, 0)
		FactionButton:SetPoint("TOP", CharacterSelectDeleteButton, "BOTTOM", 0, 0)
	end

	local name, race, class, level, zone, sex, ghost, PCC, PRC, PFC = GetCharacterInfo(id);
	if ( PFC ) then
		_G["CharSelectFactionChange"..id]:Show();
		CharSelectNoCustomizationButton:Hide()
	elseif ( PRC ) then
		_G["CharSelectRaceChange"..id]:Show();
		CharSelectNoCustomizationButton:Hide()
	elseif ( PCC ) then
		_G["CharSelectCharacterCustomize"..id]:Show();
		CharSelectNoCustomizationButton:Hide()
	else
		CharSelectNoCustomizationButton:Show()
		SetButtonDesaturated(CharSelectNoCustomizationButton, true)
	end
end

function UpdateCharacterList()
	CharacterButtons = {}
	local numChars = GetNumCharacters();
	local index = 1;
	local coords;
	for i=1, numChars, 1 do
		local name, race, class, level, zone, sex, ghost, PCC, PRC, PFC = GetCharacterInfo(i);
		local button = _G["CharSelectCharacterButton"..index];
		if ( not name ) then
			button:SetText("ERROR - Tell Jeremy");
		else
			if ( not zone ) then
				zone = "";
			end
			if class == "Death Knight" then
				class = "DK"
			end
			if class == "Demon Hunter" then
				class = "DH"
			end
			if class == "Blood Battle Mage" then
				class = "BBM"
			end
			if class == "Chaos Ravager" then
				class = "CR"
			end
			if ClassToIcon[class][2] ~= nil then
				class = ClassToIcon[class][2]..class.."|r"
			end
			_G["CharSelectCharacterButton"..index.."ButtonTextName"]:SetFormattedText(CHARACTER_SELECT_NAME, name);
			if( ghost ) then
				_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetFormattedText(CHARACTER_SELECT_INFO_GHOST, class, level);
			else
				_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetFormattedText(CHARACTER_SELECT_INFO, class, level);
			end
		end
		button:Show();
		table.insert(CharacterButtons, button)
		index = index + 1;
		if ( index > MAX_CHARACTERS_DISPLAYED ) then
			break;
		end
	end

	if ( numChars == 0 ) then
		CharacterSelectDeleteButton:Disable();
		CharSelectEnterWorldButton:Disable();
		CharSelectEnterWorldButton:SetScript("OnClick", nil)
		CharSelectEnterWorldButton:SetScript("OnMouseDown", function(self)
			self.Left:SetTexCoord(0.255859, 0.478516, 0.508301, 0.570801)
			self.Right:SetTexCoord(0.00195312, 0.572266, 0.317871, 0.380371)
		end)
		CharSelectEnterWorldButton:SetScript("OnMouseUp", function(self)
			self.Left:SetTexCoord(0.255859, 0.478516, 0.508301, 0.570801)
			self.Right:SetTexCoord(0.00195312, 0.572266, 0.317871, 0.380371)
		end)
	else
		CharacterSelectDeleteButton:Enable();
		CharSelectEnterWorldButton:Enable();
		CharSelectEnterWorldButton:SetScript("OnClick", function(self)
			CharacterSelect_EnterWorld();
		end)
		CharSelectEnterWorldButton:SetScript("OnMouseDown", function(self)
			self.Left:SetTexCoord(0.482422, 0.705078, 0.508301, 0.570801)
			self.Right:SetTexCoord(0.00195312, 0.572266, 0.381348, 0.443848)
		end)
		CharSelectEnterWorldButton:SetScript("OnMouseUp", function(self)
			self.Left:SetTexCoord(0.763672, 0.986328, 0.444824, 0.507324)
			self.Right:SetTexCoord(0.00195312, 0.572266, 0.25439, 0.316895)
		end)
	end

	CharacterSelect.createIndex = 0;
	CharSelectCreateCharacterButton:Show();
	CharSelectCreateCharacterButton:Disable();	
	SetButtonDesaturated(CharSelectCreateCharacterButton, true)
	AddIcon:SetTexCoord(0.5234375, 0.611328125, 0.626953125, 0.8046875)
	local connected = IsConnectedToServer();
	for i=index, MAX_CHARACTERS_DISPLAYED, 1 do
		local button = _G["CharSelectCharacterButton"..index];
		if ( (CharacterSelect.createIndex == 0) and (numChars < MAX_CHARACTERS_PER_REALM) ) then
			CharacterSelect.createIndex = index;
			if ( connected ) then
				--If can create characters position and show the create button
				CharSelectCreateCharacterButton:SetID(index);
				--CharSelectCreateCharacterButton:SetPoint("TOP", button, "TOP", 0, -5);
				CharSelectCreateCharacterButton:Show();
				CharSelectCreateCharacterButton:Enable();
				SetButtonDesaturated(CharSelectCreateCharacterButton, false)	
				AddIcon:SetTexCoord(0.5234375, 0.611328125, 0.0859375, 0.263671875)
			end
		end
		_G["CharSelectCharacterCustomize"..index]:Hide();
		_G["CharSelectFactionChange"..index]:Hide();
		_G["CharSelectRaceChange"..index]:Hide();
		button:Hide();
		index = index + 1;
	end

	if ( numChars == 0 ) then
		CharacterSelect.selectedIndex = 0;
		CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
		return;
	end

	if ( CharacterSelect.selectLast == 1 ) then
		CharacterSelect.selectLast = 0;
		CharacterSelect_SelectCharacter(numChars, 1);
		return;
	end

	if ( (CharacterSelect.selectedIndex == 0) or (CharacterSelect.selectedIndex > numChars) ) then
		CharacterSelect.selectedIndex = 1;
	end
	CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
	RepositionCharButtons()
end

function CharacterSelectButton_OnClick(self)
	local id = self:GetID();
	if ( id ~= CharacterSelect.selectedIndex ) then
		CharacterSelect_SelectCharacter(id);
	end
	SetupCharacterCustomizationButtons(id)
	local name, race, class, level = GetCharacterInfo(id);
	if class == "Chevalier de la mort" then
		SetCharacterSelectFacing(-8)
	else
		SetCharacterSelectFacing(0)
	end
end

function CharacterSelectButton_OnDoubleClick(self)
	local id = self:GetID();
	if ( id ~= CharacterSelect.selectedIndex ) then
		CharacterSelect_SelectCharacter(id);
	end
	CharacterSelect_EnterWorld();
end

function CharacterSelect_TabResize(self)
	local buttonMiddle = _G[self:GetName().."Middle"];
	local buttonMiddleDisabled = _G[self:GetName().."MiddleDisabled"];
	local width = self:GetTextWidth() - 8;
	local leftWidth = _G[self:GetName().."Left"]:GetWidth();
	buttonMiddle:SetWidth(width);
	buttonMiddleDisabled:SetWidth(width);
	self:SetWidth(width + (2 * leftWidth));
end

function CharacterSelect_SelectCharacter(id, noCreate)
	if ( id == CharacterSelect.createIndex ) then
		if ( not noCreate ) then
			PlaySound("gsCharacterSelectionCreateNew");
			SetGlueScreen("charcreate");
		end
	else

		local name, race, raceid, class, level, zone, sex, ghost, PCC, PRC, PFC = GetCharacterInfo(id);
	
		SetBackgroundModel(CharacterSelect, race, class);
		SelectCharacter(id);
	end
end

function CharacterDeleteDialog_OnShow()
	local name, race, class, level = GetCharacterInfo(CharacterSelect.selectedIndex);
	CharacterDeleteText1:SetFormattedText(CONFIRM_CHAR_DELETE, name, level, class);
	CharacterDeleteBackground:SetHeight(16 + CharacterDeleteText1:GetHeight() + CharacterDeleteText2:GetHeight() + 23 + CharacterDeleteEditBox:GetHeight() + 8 + CharacterDeleteButton1:GetHeight() + 16);
	CharacterDeleteButton1:Disable();
end

function CharacterSelect_EnterWorld()
	PlaySound("gsCharacterSelectionEnterWorld");
	StopGlueAmbience();
	EnterWorld();
end

function CharacterSelect_Exit()
	PlaySound("gsCharacterSelectionExit");
	DisconnectFromServer();
	SetGlueScreen("login");
end

function CharacterSelect_AccountOptions()
	PlaySound("gsCharacterSelectionAcctOptions");
end

function CharacterSelect_TechSupport()
	PlaySound("gsCharacterSelectionAcctOptions");
	LaunchURL(TECH_SUPPORT_URL);
end

function CharacterSelect_Delete()
	PlaySound("gsCharacterSelectionDelCharacter");
	if ( CharacterSelect.selectedIndex > 0 ) then
		CharacterDeleteDialog:Show();
	end
end

function CharacterSelect_ChangeRealm()
	PlaySound("gsCharacterSelectionDelCharacter");
	RequestRealmList(1);
end

function CharacterSelectFrame_OnMouseDown(button)
	if ( button == "LeftButton" ) then
		CHARACTER_SELECT_ROTATION_START_X = GetCursorPosition();
		CHARACTER_SELECT_INITIAL_FACING = GetCharacterSelectFacing();
	end
end

function CharacterSelectFrame_OnMouseUp(button)
	if ( button == "LeftButton" ) then
		CHARACTER_SELECT_ROTATION_START_X = nil
	end
end

function CharacterSelectFrame_OnUpdate()
	if ( CHARACTER_SELECT_ROTATION_START_X ) then
		local x = GetCursorPosition();
		local diff = (x - CHARACTER_SELECT_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_SELECT_ROTATION_START_X = GetCursorPosition();
		SetCharacterSelectFacing(GetCharacterSelectFacing() + diff);
	end
end



function CharacterSelect_ManageAccount()
	PlaySound("gsCharacterSelectionAcctOptions");
	LaunchURL(AUTH_NO_TIME_URL);
end

function RealmSplit_GetFormatedChoice(formatText)
	if ( SERVER_SPLIT_CLIENT_STATE == 1 ) then
		realmChoice = SERVER_SPLIT_SERVER_ONE;
	else
		realmChoice = SERVER_SPLIT_SERVER_TWO;
	end
	return format(formatText, realmChoice);
end

function RealmSplit_SetChoiceText()
	RealmSplitCurrentChoice:SetText( RealmSplit_GetFormatedChoice(SERVER_SPLIT_CURRENT_CHOICE) );
	RealmSplitCurrentChoice:Show();
end

function CharacterSelect_PaidServiceOnClick(self, button, down, service)
	PAID_SERVICE_CHARACTER_ID = self:GetID();
	PAID_SERVICE_TYPE = service;
	PlaySound("gsCharacterSelectionCreateNew");
	SetGlueScreen("charcreate");
end

function CharacterSelect_DeathKnightSwap(self)
	if ( CharacterSelect.currentModel == "DEATHKNIGHT" ) then
		if (self.currentModel ~= "DEATHKNIGHT") then
			self.currentModel = "DEATHKNIGHT";
			--self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up-Blue");
			--self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down-Blue");
			--self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight-Blue");
		end
	else
		if (self.currentModel == "DEATHKNIGHT") then
			self.currentModel = nil;
			--self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up");
			--self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down");
			--self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight");
		end
	end
end

function CharSelectShadows()
	for i, v in pairs(ShadowTable) do
		v:Hide()
	end
	ShadowTable = {}

	local charSelectShadow = CharacterSelect:CreateTexture("charSelectShadow", "OVERLAY")
	charSelectShadow:SetSize(GlueParent:GetWidth() + 5, GlueParent:GetHeight() + 5)
	charSelectShadow:SetTexture("Interface\\Glues\\CharacterCreate\\ShadowTotal")
	charSelectShadow:SetPoint("CENTER")
	charSelectShadow:SetAlpha(0.95)

	local charSelectShadowRight = CharacterSelect:CreateTexture("charSelectShadowRight", "OVERLAY")
	charSelectShadowRight:SetSize(200, GlueParent:GetHeight())
	charSelectShadowRight:SetTexture("Interface\\Glues\\CharacterCreate\\VerticalShadow")
	charSelectShadowRight:SetPoint("RIGHT", 5, 0)
	charSelectShadowRight:SetAlpha(0.8)

	local charSelectShadowLeft = CharacterSelect:CreateTexture("charSelectShadowLeft", "OVERLAY")
	charSelectShadowLeft:SetSize(200, GlueParent:GetHeight())
	charSelectShadowLeft:SetTexture("Interface\\Glues\\CharacterCreate\\VerticalShadow")
	charSelectShadowLeft:SetPoint("LEFT", -5, 0)
	charSelectShadowLeft:SetAlpha(0.8)
	charSelectShadowLeft:SetTexCoord(1, 0, 1, 0)

	table.insert(ShadowTable, charSelectShadow)
	table.insert(ShadowTable, charSelectShadowRight)
	table.insert(ShadowTable, charSelectShadowLeft)
end
