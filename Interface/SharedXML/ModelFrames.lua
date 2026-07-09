--	Filename:	ModelFrames.lua

MODELFRAME_DRAG_ROTATION_CONSTANT = 0.010
MODELFRAME_MAX_ZOOM = 0.7
MODELFRAME_MIN_ZOOM = 0.0
MODELFRAME_ZOOM_STEP = 0.15
MODELFRAME_DEFAULT_ROTATION = 0.61
ROTATIONS_PER_SECOND = .5
MODELFRAME_MAX_PLAYER_ZOOM = 0.8

local ModelSettings = {
	["HumanMale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.70, panMaxBottom = -0.75, panValue = 38, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["HumanFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.70, panMaxBottom = -0.65, panValue = 45, zoomMultiplier = 2.6, panMaxZoom = 0.3, minZoom = -0.02 },
	["OrcMale"] = { panMaxLeft = -0.7, panMaxRight = 0.8, panMaxTop = 0.75, panMaxBottom = -0.60, panValue = 30, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["OrcFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.60, panValue = 37, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["DwarfMale"] = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.45, panMaxBottom = -0.60, panValue = 44, zoomMultiplier = 3.6, panMaxZoom = 0.3, minZoom = -0.03 },
	["DwarfFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.70, panMaxBottom = -0.35, panValue = 47, zoomMultiplier = 2.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["NightElfMale"] = { panMaxLeft = -0.5, panMaxRight = 0.5, panMaxTop = 0.85, panMaxBottom = -0.85, panValue = 30, zoomMultiplier = 4.2, panMaxZoom = 0.3, minZoom = -0.03 },
	["NightElfFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.90, panMaxBottom = -0.75, panValue = 33, zoomMultiplier = 4.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["ScourgeMale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.60, panMaxBottom = -0.65, panValue = 35, zoomMultiplier = 2.7, panMaxZoom = 0.3, minZoom = -0.03 },
	["ScourgeFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.4, panMaxTop = 0.75, panMaxBottom = -0.55, panValue = 36, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["TaurenMale"] = { panMaxLeft = -0.7, panMaxRight = 0.9, panMaxTop = 0.75, panMaxBottom = -0.50, panValue = 31, zoomMultiplier = 4.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["TaurenFemale"] = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.00, panMaxBottom = -0.30, panValue = 32, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["GnomeMale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.4, panMaxBottom = -0.2, panValue = 52, zoomMultiplier = 1.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["GnomeFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.40, panMaxBottom = -0.15, panValue = 60, zoomMultiplier = 1.5, panMaxZoom = 0.3, minZoom = -0.03 },
	["TrollMale"] = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.05, panMaxBottom = -0.45, panValue = 27, zoomMultiplier = 3.7, panMaxZoom = 0.3, minZoom = -0.03 },
	["TrollFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.10, panMaxBottom = -0.60, panValue = 31, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["BloodElfMale"] = { panMaxLeft = -0.5, panMaxRight = 0.4, panMaxTop = 0.65, panMaxBottom = -0.80, panValue = 36, zoomMultiplier = 3.7, panMaxZoom = 0.3, minZoom = -0.03 },
	["BloodElfFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.2, panMaxTop = 0.65, panMaxBottom = -0.63, panValue = 38, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["DraeneiMale"] = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 0.95, panMaxBottom = -0.80, panValue = 28, zoomMultiplier = 4.5, panMaxZoom = 0.3, minZoom = -0.03 },
	["DraeneiFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.85, panValue = 31, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["WorgenMale"    ] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.60, panMaxBottom = -0.65, panValue = 35, zoomMultiplier = 2.7 },
	["WorgenFemale"  ] = { panMaxLeft = -0.3, panMaxRight = 0.4, panMaxTop = 0.75, panMaxBottom = -0.55, panValue = 36, zoomMultiplier = 3.8 },
	["Pandaren_AMale"] = { panMaxLeft = -0.7, panMaxRight = 0.9, panMaxTop = 0.75, panMaxBottom = -0.50, panValue = 31, zoomMultiplier = 4.0 },
	["Pandaren_AFemale"] = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.00, panMaxBottom = -0.30, panValue = 32, zoomMultiplier = 3.0 },
	["Pandaren_HMale"] = { panMaxLeft = -0.7, panMaxRight = 0.9, panMaxTop = 0.75, panMaxBottom = -0.50, panValue = 31, zoomMultiplier = 4.0 },
	["Pandaren_HFemale"] = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.00, panMaxBottom = -0.30, panValue = 32, zoomMultiplier = 3.0 },
	["BloodElf_DHMale"] = { panMaxLeft = -0.5, panMaxRight = 0.4, panMaxTop = 0.65, panMaxBottom = -0.80, panValue = 36, zoomMultiplier = 3.7 },
	["BloodElf_DHFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.2, panMaxTop = 0.65, panMaxBottom = -0.63, panValue = 38, zoomMultiplier = 3.0 },
	["NightElf_DHMale"] = { panMaxLeft = -0.5, panMaxRight = 0.5, panMaxTop = 0.85, panMaxBottom = -0.85, panValue = 30, zoomMultiplier = 4.2 },
	["NightElf_DHFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.90, panMaxBottom = -0.75, panValue = 33, zoomMultiplier = 4.0 },
	["EredarMale"] = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 0.95, panMaxBottom = -0.80, panValue = 28, zoomMultiplier = 4.5 },
	["EredarFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.85, panValue = 31, zoomMultiplier = 3.8 },
	["VoidElfMale"] = { panMaxLeft = -0.5, panMaxRight = 0.4, panMaxTop = 0.65, panMaxBottom = -0.80, panValue = 36, zoomMultiplier = 3.7 },
	["VoidElfFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.2, panMaxTop = 0.65, panMaxBottom = -0.63, panValue = 38, zoomMultiplier = 3.0 },
	["VulperaMale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.4, panMaxBottom = -0.2, panValue = 52, zoomMultiplier = 1.8 },
	["VulperaFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.40, panMaxBottom = -0.15, panValue = 60, zoomMultiplier = 1.5 },
	["NightborneMale"] = { panMaxLeft = -0.5, panMaxRight = 0.5, panMaxTop = 0.85, panMaxBottom = -0.85, panValue = 30, zoomMultiplier = 4.2 },
	["NightborneFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.90, panMaxBottom = -0.75, panValue = 33, zoomMultiplier = 4.0 },
	["LightforgedMale"] = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 0.95, panMaxBottom = -0.80, panValue = 28, zoomMultiplier = 4.5 },
	["LightforgedFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.85, panValue = 31, zoomMultiplier = 3.8 },
	["ZandalariTrollMale"] = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.05, panMaxBottom = -0.45, panValue = 27, zoomMultiplier = 3.7 },
	["ZandalariTrollFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.10, panMaxBottom = -0.60, panValue = 31, zoomMultiplier = 3.8 },
	["DarkIronDwarfMale"] = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.80, panMaxBottom = -0.25, panValue = 47, zoomMultiplier = 2.2 },
	["DarkIronDwarfFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.80, panMaxBottom = -0.25, panValue = 47, zoomMultiplier = 2.2 },
	["DarkIronDwarf_HMale"] = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.80, panMaxBottom = -0.25, panValue = 47, zoomMultiplier = 2.2 },
	["DarkIronDwarf_HFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.80, panMaxBottom = -0.25, panValue = 47, zoomMultiplier = 2.2 },
	["HighElfMale"   ] = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 0.95, panMaxBottom = -0.80, panValue = 28, zoomMultiplier = 4.5 },
	["HighElfMaleC"  ] = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 1.40, panMaxBottom = -0.45, panValue = 28, zoomMultiplier = 4.2 },
	["HighElfFemale" ] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.85, panValue = 31, zoomMultiplier = 3.8 },
	["HighmountainTaurenMale"   ] = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 0.95, panMaxBottom = -0.80, panValue = 28, zoomMultiplier = 4.5 },
	["HighmountainTaurenMaleC"  ] = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 1.40, panMaxBottom = -0.45, panValue = 28, zoomMultiplier = 4.2 },
	["HighmountainTaurenFemale" ] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.85, panValue = 31, zoomMultiplier = 3.8 },
	["Vulpera_AMale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.4, panMaxBottom = -0.2, panValue = 52, zoomMultiplier = 1.8 },
	["Vulpera_AFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.40, panMaxBottom = -0.15, panValue = 60, zoomMultiplier = 1.5 },
	["Dracthyr_HMale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.70, panMaxBottom = -0.75, panValue = 38, zoomMultiplier = 3.0 },
	["Dracthyr_HFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.70, panMaxBottom = -0.65, panValue = 45, zoomMultiplier = 2.4, minZoom = -0.1 },
	["Dracthyr_AMale"] = { panMaxLeft = -0.5, panMaxRight = 0.4, panMaxTop = 0.65, panMaxBottom = -0.80, panValue = 36, zoomMultiplier = 3.7 },
	["Dracthyr_AFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.2, panMaxTop = 0.65, panMaxBottom = -0.63, panValue = 38, zoomMultiplier = 3.0 },
	["MagharMale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.60, panMaxBottom = -0.65, panValue = 35, zoomMultiplier = 2.7 },
	["MagharFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.4, panMaxTop = 0.75, panMaxBottom = -0.55, panValue = 36, zoomMultiplier = 3.8 },
	["KulTiranMale"] = { panMaxLeft = -0.7, panMaxRight = 0.8, panMaxTop = 0.75, panMaxBottom = -0.60, panValue = 30, zoomMultiplier = 3.0 },
	["KulTiranFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.60, panValue = 37, zoomMultiplier = 3.0 },
};

local playerRaceSex
if ( UIParent ) then
	local _
	_, playerRaceSex = UnitRace("player")
	if ( UnitSex("player") == 2 ) then
		playerRaceSex = playerRaceSex.."Male"
	else
		playerRaceSex = playerRaceSex.."Female"
	end
end

function SharedXML_Model_OnLoad( self, maxZoom, minZoom, defaultRotation, onMouseUp )
	self.maxZoom = maxZoom or MODELFRAME_MAX_ZOOM
	self.minZoom = minZoom or MODELFRAME_MIN_ZOOM
	self.defaultRotation = defaultRotation or MODELFRAME_DEFAULT_ROTATION
	self.onMouseUpFunc = onMouseUp or SharedXML_Model_OnMouseUp

	self.rotation = self.defaultRotation
	self:SetRotation(self.rotation)
	self:RegisterEvent("UI_SCALE_CHANGED")
	self:RegisterEvent("DISPLAY_SIZE_CHANGED")
end

function SharedXML_Model_OnEvent( self, ... )
	-- self:RefreshCamera()
end

function SharedXML_Model_RotateLeft(model, rotationIncrement)
	if ( not rotationIncrement ) then
		rotationIncrement = 0.03
	end
	model.rotation = model.rotation - rotationIncrement
	model:SetRotation(model.rotation)
	PlaySound("igInventoryRotateCharacter")
end

function SharedXML_Model_RotateRight(model, rotationIncrement)
	if ( not rotationIncrement ) then
		rotationIncrement = 0.03
	end
	model.rotation = model.rotation + rotationIncrement
	model:SetRotation(model.rotation)
	PlaySound("igInventoryRotateCharacter")
end

function SharedXML_Model_OnMouseDown(model, button)
	if ( not button or button == "LeftButton" ) then
		model.mouseDown = true
		model.rotationCursorStart = GetCursorPosition()
	end
end

function SharedXML_Model_OnMouseUp(model, button)
	if ( not button or button == "LeftButton" ) then
		model.mouseDown = false
	end
end

function SharedXML_Model_OnMouseWheel(self, delta, maxZoom, minZoom)
	maxZoom = maxZoom or self.maxZoom
	minZoom = minZoom or self.minZoom
	local zoomLevel = self.zoomLevel or minZoom
	zoomLevel = zoomLevel + delta * MODELFRAME_ZOOM_STEP
	zoomLevel = min(zoomLevel, maxZoom)
	zoomLevel = max(zoomLevel, minZoom)
	local _, cameraY, cameraZ = self:GetPosition()
	self:SetPosition((self.positionX or 0) + zoomLevel, cameraY, cameraZ)
	self.zoomLevel = zoomLevel
end

function SharedXML_Model_OnUpdate(self, elapsedTime, rotationsPerSecond)
	if ( not rotationsPerSecond ) then
		rotationsPerSecond = ROTATIONS_PER_SECOND
	end
	
	-- Mouse drag rotation
	if (self.mouseDown) then
		if ( self.rotationCursorStart ) then
			local x = GetCursorPosition()
			local diff = (x - self.rotationCursorStart) * MODELFRAME_DRAG_ROTATION_CONSTANT
			self.rotationCursorStart = GetCursorPosition()
			self.rotation = self.rotation + diff
			if ( self.rotation < 0 ) then
				self.rotation = self.rotation + (2 * PI)
			end
			if ( self.rotation > (2 * PI) ) then
				self.rotation = self.rotation - (2 * PI)
			end
			self:SetRotation(self.rotation, false)
		end
	elseif ( self.panning ) then
		local modelScale = self:GetModelScale()
		local cursorX, cursorY = GetCursorPosition()
		local scale = UIParent:GetEffectiveScale()
		ModelPanningFrame:SetPoint("BOTTOMLEFT", cursorX / scale - 16, cursorY / scale - 16)	-- half the texture size to center it on the cursor
		-- settings
		local settings = ModelSettings[playerRaceSex]

		local zoom = self.zoomLevel or self.minZoom
		zoom = 1 + zoom - self.minZoom	-- want 1 at minimum zoom

		-- Panning should require roughly the same mouse movement regardless of zoom level so the model moves at the same rate as the cursor
		-- This formula more or less works for all zoom levels, found via trial and error
        if settings ~= nil then
            local transformationRatio = settings.panValue * 2 ^ (zoom * 2) * scale / modelScale
    
            local positionY, positionZ = (self.positionY or 0), (self.positionX or 0)
            local dx = (cursorX - self.cursorX) / transformationRatio
            local dy = (cursorY - self.cursorY) / transformationRatio
            local cameraY = self.cameraY + dx - positionY
            local cameraZ = self.cameraZ + dy - positionZ
            -- bounds
            scale = scale * modelScale
            local maxCameraY = settings.panMaxRight * scale
            cameraY = min(cameraY, maxCameraY)
            local minCameraY = settings.panMaxLeft * scale
            cameraY = max(cameraY, minCameraY)
            local maxCameraZ = settings.panMaxTop * scale
            cameraZ = min(cameraZ, maxCameraZ)
            local minCameraZ = settings.panMaxBottom * scale
            cameraZ = max(cameraZ, minCameraZ)
            
            self:SetPosition(self.cameraX, cameraY + positionY, cameraZ + positionZ)
        end
        
	end
	
	-- Rotate buttons
	local leftButton, rightButton
	if ( self.controlFrame ) then
		leftButton = self.controlFrame.rotateLeftButton
		rightButton = self.controlFrame.rotateRightButton
	else
		leftButton = self.RotateLeftButton or (self:GetName() and _G[self:GetName().."RotateLeftButton"])
		rightButton = self.RotateRightButton or (self:GetName() and _G[self:GetName().."RotateRightButton"])
	end

	if ( leftButton and leftButton:GetButtonState() == "PUSHED" ) then
		self.rotation = self.rotation + (elapsedTime * 2 * PI * rotationsPerSecond)
		if ( self.rotation < 0 ) then
			self.rotation = self.rotation + (2 * PI)
		end
		self:SetRotation(self.rotation)
	elseif ( rightButton and rightButton:GetButtonState() == "PUSHED" ) then
		self.rotation = self.rotation - (elapsedTime * 2 * PI * rotationsPerSecond)
		if ( self.rotation > (2 * PI) ) then
			self.rotation = self.rotation - (2 * PI)
		end
		self:SetRotation(self.rotation)
	end
end

function SharedXML_Model_SetDefaultRotation(self, rotation)
	self.defaultRotation = rotation
	self.rotation = rotation
	self:SetRotation(rotation)
end

function SharedXML_Model_Reset(self)
	self.rotation = self.defaultRotation
	self:SetRotation(self.rotation)
	self:SetPosition(self.positionX or 0, self.positionY or 0, self.positionZ or 0)
	self.zoomLevel = self.minZoom
end

function SharedXML_Model_StartPanning(self, usePanningFrame)
	if ( usePanningFrame ) then
		ModelPanningFrame.model = self
		ModelPanningFrame:Show()
	end
	self.panning = true
	local cameraX, cameraY, cameraZ = self:GetPosition()
	self.cameraX = cameraX
	self.cameraY = cameraY
	self.cameraZ = cameraZ
	local cursorX, cursorY = GetCursorPosition()
	self.cursorX = cursorX
	self.cursorY = cursorY
end

function SharedXML_Model_StopPanning(self)
	self.panning = false
	ModelPanningFrame:Hide()
end

function ModelControlButton_OnMouseDown(self)
	self.bg:SetTexCoord(0.01562500, 0.26562500, 0.14843750, 0.27343750)
	self.icon:SetPoint("CENTER", 1, -1)
	self:GetParent().buttonDown = self
end

function ModelControlButton_OnMouseUp(self)
	self.bg:SetTexCoord(0.29687500, 0.54687500, 0.14843750, 0.27343750)
	self.icon:SetPoint("CENTER", 0, 0)
	self:GetParent().buttonDown = nil
end

function SharedXML_Model_ApplyUICamera(self, uiCameraID)
	local posX, posY, posZ, yaw, pitch, roll, animId, animVariation, animFrame, centerModel = GetUICameraInfo(uiCameraID)
	if posX and posY and posZ and yaw and pitch and roll then
		self:MakeCurrentCameraCustom()

		self:SetPosition(posX, posY, posZ)
		self:SetFacing(yaw)
		self:SetPitch(pitch)
		self:SetRoll(roll)
		self:UseModelCenterToTransform(centerModel)

		local cameraX, cameraY, cameraZ = self:TransformCameraSpaceToModelSpace(MODELFRAME_UI_CAMERA_POSITION.x, MODELFRAME_UI_CAMERA_POSITION.y, MODELFRAME_UI_CAMERA_POSITION.z)
		local targetX, targetY, targetZ = self:TransformCameraSpaceToModelSpace(MODELFRAME_UI_CAMERA_TARGET.x, MODELFRAME_UI_CAMERA_TARGET.y, MODELFRAME_UI_CAMERA_TARGET.z)

		self:SetCameraPosition(cameraX, cameraY, cameraZ)
		self:SetCameraTarget(targetX, targetY, targetZ)
	end
	if( animId and animFrame ~= -1 and animId ~= -1 ) then
		self:FreezeAnimation(animId, animVariation, animFrame)
	else
		self:SetAnimation(0, 0)
	end
end