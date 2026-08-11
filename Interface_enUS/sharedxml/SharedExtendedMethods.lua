local Texture, FontString, DressUpModel
local Frame = getmetatable(CreateFrame("Frame"))
local Button = getmetatable(CreateFrame("Button"))
local Slider = getmetatable(CreateFrame("Slider"))
local StatusBar = getmetatable(CreateFrame("StatusBar"))
local SimpleHTML = getmetatable(CreateFrame("SimpleHTML"))
local ScrollFrame = getmetatable(CreateFrame("ScrollFrame"))
local CheckButton = getmetatable(CreateFrame("CheckButton"))
local Model = getmetatable(CreateFrame("Model"))

if WorldFrame then
	DressUpModel = getmetatable(CreateFrame("DressUpModel"))
end

local FrameData = {
	CreateFrame("Frame"),
	CreateFrame("Button"),
	CreateFrame("SimpleHTML"),
	CreateFrame("Slider"),
	CreateFrame("StatusBar"),
	CreateFrame("ScrollFrame"),
	CreateFrame("CheckButton"),
}

function InitSubFrame()
	for _, v in pairs(FrameData) do
		Texture = getmetatable(v:CreateTexture())
		FontString = getmetatable(v:CreateFontString())
	end
end

InitSubFrame()

local function Method_SetShown( self, ... )
	if ... then
		self:Show()
	else
		self:Hide()
	end
end

local function Method_SetEnabled( self, ... )
	if ... then
		self:Enable()
	else
		self:Disable()
	end
end

local function Method_SetRemainingTime( self, _time, daysformat )
	local time = _time
	local dayInSeconds = 86400
	local days = ""

	self:SetText("")

	if type(time) ~= "number" then
		-- printc("EROR: Method_SetRemainingTime time is not number. Frame "..self:GetName())
		return
	end

	if daysformat then
		if time > 86400 then
			self:SetText(math.floor(time / dayInSeconds)..string.format(" |4день:дня:дней;", time % 10))
		else
			self:SetText(date("!%X", time))
		end
	else
		if time > dayInSeconds then
			days = math.floor(time / dayInSeconds) .. "д "
			time = time % dayInSeconds
		end

		if time and time >= 0 then
			self:SetText(days .. date("!%X", time))
		end
	end
end

local function Method_SetSubTexCoord( self, left, right, top, bottom )
    local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = self:GetTexCoord()

    local leftedge = ULx
    local rightedge = URx
    local topedge = ULy
    local bottomedge = LLy

    local width  = rightedge - leftedge
    local height = bottomedge - topedge

    leftedge = ULx + width * left
    topedge  = ULy  + height * top
    rightedge = math.max(rightedge * right, ULx)
    bottomedge = math.max(bottomedge * bottom, ULy)

    ULx = leftedge
    ULy = topedge
    LLx = leftedge
    LLy = bottomedge
    URx = rightedge
    URy = topedge
    LRx = rightedge
    LRy = bottomedge

    self:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
end

local function Method_SetTransmogrifyItem( self, Entry )
	if not self.TransmogText1:IsShown() and not self.TransmogText2:IsShown() then
		local name = GetItemInfo(Entry)

		if not name then
			return
		end

		self.TransmogText1:Show()
		self.TransmogText2:Show()

		self.TransmogText1:SetText("Предмет трансмогрифицирован в:")
		self.TransmogText2:SetText(name)

		self.TextLeft2:ClearAllPoints()
		self.TextLeft2:SetPoint("TOPLEFT", self.TransmogText2, "BOTTOMLEFT", 0, -2)
		self:SetHeight(self:GetHeight() + (self.TransmogText1:GetHeight() + self.TransmogText2:GetHeight()) + 6)

		Hook:FireEvent("TRANSMOGRIFY_ITEM_UPDATE", self, Entry)
	end
end

local function Method_SetPortrait( self, displayID )
	local portrait = "Interface\\PORTRAITS\\Portrait_model_"..tonumber(displayID)
	self:SetTexture(portrait)
end

local Panels = {"CollectionsJournal", "EncounterJournal"}
local function Method_FixOpenPanel( self )
	-- Хак, в связи с странностями работы системы позиционирования.
	-- Необходим для корректной работы системы Профессий.
	for i = 1, #Panels do
		local panel = _G[Panels[i]]

		if panel then
			if panel:IsShown() then
				HideUIPanel(panel)
				ShowUIPanel(self)
				return true
			end
		end
	end
end

local CONST_ATLAS_WIDTH			= 1
local CONST_ATLAS_HEIGHT		= 2
local CONST_ATLAS_LEFT			= 3
local CONST_ATLAS_RIGHT			= 4
local CONST_ATLAS_TOP			= 5
local CONST_ATLAS_BOTTOM		= 6
local CONST_ATLAS_TILESHORIZ	= 7
local CONST_ATLAS_TILESVERT		= 8
local CONST_ATLAS_TEXTUREPATH	= 9

local function Method_SetAtlas( self, atlasName, useAtlasSize, filterMode )
	assert(self, "SetAtlas: not found object")
	assert(atlasName, "SetAtlas: AtlasName must be specified")

	local atlas = S_ATLAS_STORAGE[atlasName]
	if not atlas then
		-- PATCH Collection : de nombreux atlas references par le systeme de
		-- Collection porte depuis Sirus n'existent pas dans les donnees
		-- d'atlas d'Azeroth Universe (texture/metadata non portee). Avant, un
		-- assert() ici stoppait immediatement TOUT le script appelant (ex.
		-- WardrobeItemsModelMixin:OnLoad), ce qui empechait du code CRITIQUE
		-- plus loin dans la meme fonction de s'executer (comme
		-- l'enregistrement des modeles dans self.Models). On degrade donc
		-- maintenant en no-op silencieux : la texture manquante ne s'affiche
		-- pas (deja un cas connu/accepte), mais le reste du script continue.
		return
	end

	self:SetTexture(atlas[CONST_ATLAS_TEXTUREPATH] or "", atlas[CONST_ATLAS_TILESHORIZ], atlas[CONST_ATLAS_TILESVERT])

	if useAtlasSize then
		self:SetWidth(atlas[CONST_ATLAS_WIDTH])
		self:SetHeight(atlas[CONST_ATLAS_HEIGHT])
	end

	self:SetTexCoord(atlas[CONST_ATLAS_LEFT], atlas[CONST_ATLAS_RIGHT], atlas[CONST_ATLAS_TOP], atlas[CONST_ATLAS_BOTTOM])

	self:SetHorizTile(atlas[CONST_ATLAS_TILESHORIZ])
	self:SetVertTile(atlas[CONST_ATLAS_TILESVERT])
end

local function Method_SmoothSetValue( self, value )
	-- local smoothFrame = self._SmoothUpdateFrame or CreateFrame("Frame")
	-- self._SmoothUpdateFrame =  smoothFrame
end

local function Method_SetUnit( self, unit, isCustomPosition )
	if isCustomPosition then
		self:SetPosition(1, 1, 1)
	end

	self:__SetUnit(unit)

	if isCustomPosition then
		local unitSex = UnitSex("player") or 2
		local _, unitRace = UnitRace("player")
		local data = DRESSUPMODEL_CAMERA_POSITION[string.format("%s%d", unitRace or "Human", unitSex)]

		if data then
			self:SetPosition(data.offsetX, data.offsetY, data.offsetZ)
		end
	end
end

function Method_SetDesaturated( self, toggle, color )
	if toggle then
		self:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	else
		if color then
			self:SetTextColor(color.r, color.g, color.b)
		else
			self:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		end
	end
end

function Method_SetParentArray( self, arrayName, element)
    if not self:GetParent()[arrayName] then
        self:GetParent()[arrayName] = {}
    end

    table.insert(self:GetParent()[arrayName], element or self)
end

function Method_ClearAndSetPoint( self, ... )
	self:ClearAllPoints()
	self:SetPoint(...)
end

-- Frame Method
function Frame.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function Frame.__index:FixOpenPanel( ... ) Method_FixOpenPanel( self, ... ) end
function Frame.__index:SetParentArray( arrayName, element ) Method_SetParentArray( self, arrayName, element ) end
function Frame.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end

-- Button Method
function Button.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function Button.__index:SetEnabled( ... ) Method_SetEnabled( self, ... ) end
function Button.__index:SetParentArray( arrayName, element ) Method_SetParentArray( self, arrayName, element ) end
function Button.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end

-- Slider Method
function Slider.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function Slider.__index:SetParentArray( arrayName, element ) Method_SetParentArray( self, arrayName, element ) end
function Slider.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end

-- Texture Method
function Texture.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function Texture.__index:SetSubTexCoord( left, right, top, bottom ) Method_SetSubTexCoord( self, left, right, top, bottom ) end
function Texture.__index:SetPortrait( displayID ) Method_SetPortrait( self, displayID ) end
function Texture.__index:SetAtlas( atlasName, useAtlasSize, filterMode ) Method_SetAtlas( self, atlasName, useAtlasSize, filterMode ) end
function Texture.__index:SetParentArray( arrayName, element ) Method_SetParentArray( self, arrayName, element ) end
function Texture.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end

-- StatusBar Method
function StatusBar.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function StatusBar.__index:SmoothSetValue( value ) Method_SmoothSetValue( self, value ) end
function StatusBar.__index:SetParentArray( arrayName, element ) Method_SetParentArray( self, arrayName, element ) end
function StatusBar.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end

-- SimpleHTML Method
function SimpleHTML.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function SimpleHTML.__index:SetParentArray( arrayName, element ) Method_SetParentArray( self, arrayName, element ) end
function SimpleHTML.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end

-- FontString Method
function FontString.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function FontString.__index:SetRemainingTime( time, daysformat ) Method_SetRemainingTime( self, time, daysformat ) end
function FontString.__index:SetDesaturated( toggle, color ) Method_SetDesaturated( self, toggle, color ) end
function FontString.__index:SetParentArray( arrayName, element ) Method_SetParentArray( self, arrayName, element ) end
function FontString.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end

-- ScrollFrame Method
function ScrollFrame.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function ScrollFrame.__index:SetParentArray( arrayName, element ) Method_SetParentArray( self, arrayName, element ) end
function ScrollFrame.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end

-- CheckButton Method
function CheckButton.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function CheckButton.__index:SetEnabled( ... ) Method_SetEnabled( self, ... ) end
function CheckButton.__index:SetParentArray( arrayName, element ) Method_SetParentArray( self, arrayName, element ) end
function CheckButton.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end

-- DressUpModel
if DressUpModel then
	DressUpModel.__index.__SetUnit = DressUpModel.__index.__SetUnit or DressUpModel.__index.SetUnit
	function DressUpModel.__index:SetUnit( ... ) Method_SetUnit( self, ... ) end
	function DressUpModel.__index:SetParentArray( arrayName, element ) Method_SetParentArray( self, arrayName, element ) end
	function DressUpModel.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
end

-- Model
function Model.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function Model.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end

-----------------------------

local EditBox = CreateFrame("EditBox")
EditBox:Hide()
EditBox = getmetatable(EditBox)

if WorldFrame then
	DressUpModel = getmetatable(CreateFrame("DressUpModel"))
end

function InitSubFrame()
	for _, v in pairs(FrameData) do
		Texture = getmetatable(v:CreateTexture())
		FontString = getmetatable(v:CreateFontString())
	end
end
InitSubFrame()

local function Method_SetFrameShown( self, ... )
	if ... then
		self:Show()
	else
		self:Hide()
	end
end

local function Method_SetEnabled( self, ... )
	if ... then
		self:Enable()
	else
		self:Disable()
	end
end

local function Method_SetSubTexCoords( self, left, right, top, bottom )
    local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = self:GetTexCoord()

    local leftedge = ULx
    local rightedge = URx
    local topedge = ULy
    local bottomedge = LLy

    local width  = rightedge - leftedge
    local height = bottomedge - topedge

    leftedge = ULx + width * left
    topedge  = ULy  + height * top
    rightedge = math.max(rightedge * right, ULx)
    bottomedge = math.max(bottomedge * bottom, ULy)

    ULx = leftedge
    ULy = topedge
    LLx = leftedge
    LLy = bottomedge
    URx = rightedge
    URy = topedge
    LRx = rightedge
    LRy = bottomedge

    self:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
end

local function Method_SetPortrait( self, displayID )
	local portrait = "Interface\\PORTRAITS\\Portrait_model_"..tonumber(displayID)
	self:SetTexture(portrait)
end

local function Method_SetTransmogItem( self, Entry )
	if not self.TransmogText1:IsShown() and not self.TransmogText2:IsShown() then
		local name = GetItemInfo(Entry)

		if not name then
			return
		end

		self.TransmogText1:Show()
		self.TransmogText2:Show()

		self.TransmogText1:SetText(TRANSMOGRIFIED2)
		self.TransmogText2:SetText(name)

		self.TextLeft2:ClearAllPoints()
		self.TextLeft2:SetPoint("TOPLEFT", self.TransmogText2, "BOTTOMLEFT", 0, -2)
		self:SetHeight(self:GetHeight() + (self.TransmogText1:GetHeight() + self.TransmogText2:GetHeight()) + 6)
	end
end

local CONST_ATLAS_WIDTH			= 1
local CONST_ATLAS_HEIGHT		= 2
local CONST_ATLAS_LEFT			= 3
local CONST_ATLAS_RIGHT			= 4
local CONST_ATLAS_TOP			= 5
local CONST_ATLAS_BOTTOM		= 6
local CONST_ATLAS_TILESHORIZ	= 7
local CONST_ATLAS_TILESVERT		= 8
local CONST_ATLAS_TEXTUREPATH	= 9

local function Method_SetAtlasTex( self, atlasName, useAtlasSize, filterMode )
	assert(self, "SetAtlasTex: not found object")
	assert(atlasName, "SetAtlasTex: AtlasName must be specified")

	-- PATCH Collection : meme degradation gracieuse que Method_SetAtlas (voir plus haut).
	local atlas = PRETTY_ATLAS_STORAGE[atlasName]
	if not atlas then
		return
	end

	self:SetTexture(atlas[CONST_ATLAS_TEXTUREPATH] or "", atlas[CONST_ATLAS_TILESHORIZ], atlas[CONST_ATLAS_TILESVERT])

	if useAtlasSize then
		self:SetWidth(atlas[CONST_ATLAS_WIDTH])
		self:SetHeight(atlas[CONST_ATLAS_HEIGHT])
	end

	self:SetTexCoord(atlas[CONST_ATLAS_LEFT], atlas[CONST_ATLAS_RIGHT], atlas[CONST_ATLAS_TOP], atlas[CONST_ATLAS_BOTTOM])

	self:SetHorizTile(atlas[CONST_ATLAS_TILESHORIZ])
	self:SetVertTile(atlas[CONST_ATLAS_TILESVERT])
end

local function Method_SetUnit( self, unit, isCustomPosition, positionData )
	local objectType = self:GetObjectType()

	if isCustomPosition then
		if objectType == "TabardModel" then
			self:SetPosition(0, 0, 0)
		else
			self:SetPosition(1, 1, 1)
		end
	end

	self:__SetUnit(unit)

	if isCustomPosition then
		local unitSex = UnitSex(unit) or 2
		local _, unitRace = UnitRace(unit)
		local positionStorage = positionData or (objectType == "TabardModel" and TABARDMODEL_CAMERA_POSITION or DRESSUPMODEL_CAMERA_POSITION)
		local data = positionStorage[string.format("%s%d", unitRace or "Human", unitSex)]

		if data then
			local positionX, positionY, positionZ = unpack(data)

			self.positionX = positionX
			self.positionY = positionY
			self.positionZ = positionZ
			self:SetPosition(positionX, positionY, positionZ)

			if data[4] then
				self:SetFacing(math.rad(data[4]))
			end
		end
	end
end

function Method_SetDesaturated( self, toggle, color )
	if toggle then
		self:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	else
		if color then
			self:SetTextColor(color.r, color.g, color.b)
		else
			self:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		end
	end
end

function Method_SetParentArrayFrame( self, arrayName, element, setInSelf)
	local parent = not setInSelf and self:GetParent() or self

    if not parent[arrayName] then
		parent[arrayName] = {}
    end

    table.insert(parent[arrayName], element or self)
end

function Method_ClearAndSetNewPoint( self, ... )
	self:ClearAllPoints()
	self:SetPoint(...)
end

function Method_GetScaledRectVal(self)
	local left, bottom, width, height = self:GetRect()
	if left and bottom and width and height then
		local scale = self:GetEffectiveScale()
		return left * scale, bottom * scale, width * scale, height * scale
	end
end

function Method_IsTruncated(fontString)
	local stringWidth = fontString:GetStringWidth();
	local width = fontString:GetWidth();
	fontString:SetWidth(width + 10000);
	local isTruncated = fontString:GetStringWidth() ~= stringWidth;
	fontString:SetWidth(width);
	return isTruncated;
 end

-- Frame Method
function Frame.__index:SetFrameShown( ... ) Method_SetFrameShown( self, ... ) end
function Frame.__index:SetParentArrayFrame( arrayName, element, setInSelf ) Method_SetParentArrayFrame( self, arrayName, element, setInSelf ) end
function Frame.__index:ClearAndSetNewPoint( ... ) Method_ClearAndSetNewPoint( self, ... ) end
function Frame.__index:GetScaledRectVal() return Method_GetScaledRectVal(self) end

-- Button Method
function Button.__index:SetFrameShown( ... ) Method_SetFrameShown( self, ... ) end
function Button.__index:SetEnabled( ... ) Method_SetEnabled( self, ... ) end
function Button.__index:SetParentArrayFrame( arrayName, element, setInSelf ) Method_SetParentArrayFrame( self, arrayName, element, setInSelf ) end
function Button.__index:ClearAndSetNewPoint( ... ) Method_ClearAndSetNewPoint( self, ... ) end
function Button.__index:SetNormalAtlas( atlasName, useAtlasSize, filterMode ) Method_SetAtlasTex( self:GetNormalTexture(), atlasName, useAtlasSize, filterMode )  end
function Button.__index:SetPushedAtlas( atlasName, useAtlasSize, filterMode ) Method_SetAtlasTex( self:GetPushedTexture(), atlasName, useAtlasSize, filterMode )  end
function Button.__index:SetDisabledAtlas( atlasName, useAtlasSize, filterMode ) Method_SetAtlasTex( self:GetDisabledTexture(), atlasName, useAtlasSize, filterMode )  end
function Button.__index:SetHighlightAtlas( atlasName, useAtlasSize, filterMode ) Method_SetAtlasTex( self:GetHighlightTexture(), atlasName, useAtlasSize, filterMode )  end
function Button.__index:GetScaledRectVal() return Method_GetScaledRectVal(self) end

-- Slider Method
function Slider.__index:SetFrameShown( ... ) Method_SetFrameShown( self, ... ) end
function Slider.__index:SetParentArrayFrame( arrayName, element, setInSelf ) Method_SetParentArrayFrame( self, arrayName, element, setInSelf ) end
function Slider.__index:ClearAndSetNewPoint( ... ) Method_ClearAndSetNewPoint( self, ... ) end
function Slider.__index:GetScaledRectVal() return Method_GetScaledRectVal(self) end

-- Texture Method
function Texture.__index:SetFrameShown( ... ) Method_SetFrameShown( self, ... ) end
function Texture.__index:SetSubTexCoords( left, right, top, bottom ) Method_SetSubTexCoords( self, left, right, top, bottom ) end
function Texture.__index:SetPortrait( displayID ) Method_SetPortrait( self, displayID ) end
function Texture.__index:SetAtlasTex( atlasName, useAtlasSize, filterMode ) Method_SetAtlasTex( self, atlasName, useAtlasSize, filterMode ) end
function Texture.__index:SetParentArrayFrame( arrayName, element, setInSelf ) Method_SetParentArrayFrame( self, arrayName, element, setInSelf ) end
function Texture.__index:ClearAndSetNewPoint( ... ) Method_ClearAndSetNewPoint( self, ... ) end
function Texture.__index:GetEffectiveScale() return self:GetParent():GetEffectiveScale() end
function Texture.__index:GetScaledRectVal() return Method_GetScaledRectVal(self) end

-- StatusBar Method
function StatusBar.__index:SetFrameShown( ... ) Method_SetFrameShown( self, ... ) end
function StatusBar.__index:SetParentArrayFrame( arrayName, element, setInSelf ) Method_SetParentArrayFrame( self, arrayName, element, setInSelf ) end
function StatusBar.__index:ClearAndSetNewPoint( ... ) Method_ClearAndSetNewPoint( self, ... ) end
function StatusBar.__index:GetScaledRectVal() return Method_GetScaledRectVal(self) end

-- SimpleHTML Method
function SimpleHTML.__index:SetFrameShown( ... ) Method_SetFrameShown( self, ... ) end
function SimpleHTML.__index:SetParentArrayFrame( arrayName, element, setInSelf ) Method_SetParentArrayFrame( self, arrayName, element, setInSelf ) end
function SimpleHTML.__index:ClearAndSetNewPoint( ... ) Method_ClearAndSetNewPoint( self, ... ) end
function SimpleHTML.__index:GetScaledRectVal() return Method_GetScaledRectVal(self) end

-- FontString Method
function FontString.__index:SetFrameShown( ... ) Method_SetFrameShown( self, ... ) end
function FontString.__index:SetDesaturated( toggle, color ) Method_SetDesaturated( self, toggle, color ) end
function FontString.__index:SetParentArrayFrame( arrayName, element, setInSelf ) Method_SetParentArrayFrame( self, arrayName, element, setInSelf ) end
function FontString.__index:ClearAndSetNewPoint( ... ) Method_ClearAndSetNewPoint( self, ... ) end
function FontString.__index:GetEffectiveScale() return self:GetParent():GetEffectiveScale() end
function FontString.__index:GetScaledRectVal() return Method_GetScaledRectVal(self) end
function FontString.__index:IsTruncated() return Method_IsTruncated(self) end

-- ScrollFrame Method
function ScrollFrame.__index:SetFrameShown( ... ) Method_SetFrameShown( self, ... ) end
function ScrollFrame.__index:SetParentArrayFrame( arrayName, element, setInSelf ) Method_SetParentArrayFrame( self, arrayName, element, setInSelf ) end
function ScrollFrame.__index:ClearAndSetNewPoint( ... ) Method_ClearAndSetNewPoint( self, ... ) end
function ScrollFrame.__index:GetScaledRectVal() return Method_GetScaledRectVal(self) end

-- CheckButton Method
function CheckButton.__index:SetFrameShown( ... ) Method_SetFrameShown( self, ... ) end
function CheckButton.__index:SetEnabled( ... ) Method_SetEnabled( self, ... ) end
function CheckButton.__index:SetParentArrayFrame( arrayName, element, setInSelf ) Method_SetParentArrayFrame( self, arrayName, element, setInSelf ) end
function CheckButton.__index:ClearAndSetNewPoint( ... ) Method_ClearAndSetNewPoint( self, ... ) end
function CheckButton.__index:GetScaledRectVal() return Method_GetScaledRectVal(self) end

-- DressUpModel
if DressUpModel then
	DressUpModel.__index.__SetUnit = DressUpModel.__index.__SetUnit or DressUpModel.__index.SetUnit
	function DressUpModel.__index:SetUnit( ... ) Method_SetUnit( self, ... ) end
	function DressUpModel.__index:SetParentArrayFrame( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
	function DressUpModel.__index:ClearAndSetNewPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
	function DressUpModel.__index:GetScaledRectVal() return Method_GetScaledRect(self) end
end

-- Model
function Model.__index:SetFrameShown( ... ) Method_SetFrameShown( self, ... ) end
function Model.__index:ClearAndSetNewPoint( ... ) Method_ClearAndSetNewPoint( self, ... ) end
function Model.__index:GetScaledRectVal() return Method_GetScaledRectVal(self) end

-- EditBox
function EditBox.__index:SetFrameShown(...) Method_SetFrameShown(self, ...) end
function EditBox.__index:ClearAndSetNewPoint(...) Method_ClearAndSetNewPoint(self, ...) end
function EditBox.__index:GetScaledRectVal() return Method_GetScaledRectVal(self) end
