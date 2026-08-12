-- KibsItemLevel Simplifié - Seulement niveau d'objet global
local namespace = select(2,...);
LoadAddOn("LibItemUpgradeInfo-1.0");

local ilvlFrame = CreateFrame("Frame");
local itemUpgradeInfo = LibStub("LibItemUpgradeInfo-1.0");
local variables_loaded = namespace.variables_loaded;

local function findItemInfo(who)
	if not (who) then
		return
	end
	
	local tilvl = 0;
	local numItems = 16;
	
	for i = 1, 18 do
		if (i ~= 4) then -- ignore shirt
			local itemlink = GetInventoryItemLink(who, i);
			if (itemlink) then
				if (i == 17) then numItems = numItems + 1; end
				
				local ilvl = itemUpgradeInfo:GetUpgradedItemLevel(itemlink);
				
				if not(ilvl) then ilvl = 0; end
				
				if (ilvl == 1) then
					ilvl = namespace.findHeirloomilvl();
				end
				
				if (ilvl) then
					tilvl = tilvl + ilvl;
				end
			end
		end
	end
	
	local itemLevel = math.floor((tilvl/numItems) * 100 * 0.01);
	
	if (_data.enableConfig) then
		if (who == "player") then
			if (_data.enableChar) then
				if not (CharacterItemLevelFrame) then
					CharacterItemLevelFrame = CreateFrame("Frame", "CharacterItemLevelFrame", PaperDollFrame);
					CharacterItemLevelFrame:SetPoint("TOP", PaperDollFrame, "TOP", 0, -5);
					
					CharacterItemLevelFrame.ilvltext = CharacterItemLevelFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge");
					CharacterItemLevelFrame.ilvltext:SetPoint("CENTER", CharacterItemLevelFrame);
				end
				CharacterItemLevelFrame.ilvltext:SetFormattedText("%d", itemLevel);
				CharacterItemLevelFrame.ilvltext:SetTextColor(1, 1, 1, 1); -- Blanc
			end
		else
			if (_data.enableInspect) then
				if not (InspectItemLevelFrame) then
					InspectItemLevelFrame = CreateFrame("Frame", "InspectItemLevelFrame", InspectPaperDollFrame);
					InspectItemLevelFrame:SetPoint("TOP", InspectPaperDollFrame, "TOP", 0, -5);
					
					InspectItemLevelFrame.ilvltext = InspectItemLevelFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge");
					InspectItemLevelFrame.ilvltext:SetPoint("CENTER", InspectItemLevelFrame);
				end
				InspectItemLevelFrame.ilvltext:SetFormattedText("%d", itemLevel);
				InspectItemLevelFrame.ilvltext:SetTextColor(1, 1, 1, 1); -- Blanc
			end
		end
	end
end

local function updatePlayer()
	if (_data.enableChar) then
		findItemInfo("player");
	end
end

local function updateInspect()
	findItemInfo(InspectFrame.unit);
end

local function eventHandler(self, event, ...)
	if (_data.enableConfig) then
		if (event == "PLAYER_TARGET_CHANGED" and ilvlFrame.inspectVisible and _data.enableInspect) then
			if (InspectFrame.unit and InspectFrame.unit == "target") then
				updateInspect();
			end
		elseif (event ~= "PLAYER_TARGET_CHANGED") then
			updatePlayer();
		elseif (event == "PLAYER_EQUIPMENT_CHANGED") then
			updatePlayer();
		end
	end
end

local function setupEventHandler(self, event)
	if (event == "VARIABLES_LOADED" or event == "PLAYER_LOGIN") then
		namespace.config_loaded();
		
		ilvlFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
		ilvlFrame:RegisterEvent("UNIT_INVENTORY_CHANGED");
		ilvlFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
		ilvlFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
		
		InspectFrame:SetScript("OnShow", function(self)
			ilvlFrame.inspectVisible = true;
			updateInspect();
		end);
		InspectFrame:SetScript("OnHide", function(self)
			ilvlFrame.inspectVisible = false;
		end);
		
		ilvlFrame:SetScript("OnEvent", eventHandler);
		
		if (_data.enableChar) then updatePlayer(); end
		
		CharacterResistanceFrame:Show();
	end
end

ilvlFrame:RegisterEvent("VARIABLES_LOADED");
ilvlFrame:RegisterEvent("PLAYER_LOGIN");
ilvlFrame:SetScript("OnEvent", setupEventHandler);

function cleanUpiLvl()
	eventHandler(self, "PLAYER_EQUIPMENT_CHANGED");
end