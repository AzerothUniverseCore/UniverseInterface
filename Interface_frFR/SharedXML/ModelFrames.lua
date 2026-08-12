--	Filename:	ModelFrames.lua

MODELFRAME_DRAG_ROTATION_CONSTANT = 0.010
MODELFRAME_MAX_ZOOM = 0.7
MODELFRAME_MIN_ZOOM = 0.0
MODELFRAME_ZOOM_STEP = 0.15
MODELFRAME_DEFAULT_ROTATION = 0.61
ROTATIONS_PER_SECOND = .5
MODELFRAME_MAX_PLAYER_ZOOM = 0.3
CAMERA_ZOOMSMOOTH_SPEED = 0.5
MODELDRESSUP_MULTIPLIER_ZOOM = 2.6
MODELFRAME_MAX_INSPECT_ZOOM = 0.35

local ModelSettings = {
	["HumanMale"]              = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.70, panMaxBottom = -0.75, panValue = 38, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["HumanFemale"]            = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.70, panMaxBottom = -0.65, panValue = 45, zoomMultiplier = 2.6, panMaxZoom = 0.3, minZoom = -0.02 },
	["OrcMale"]                = { panMaxLeft = -0.7, panMaxRight = 0.8, panMaxTop = 0.75, panMaxBottom = -0.60, panValue = 30, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["OrcFemale"]              = { panMaxLeft = -0.4, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.60, panValue = 37, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["DwarfMale"]              = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.45, panMaxBottom = -0.60, panValue = 44, zoomMultiplier = 3.6, panMaxZoom = 0.3, minZoom = -0.03 },
	["DwarfFemale"]            = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.70, panMaxBottom = -0.35, panValue = 47, zoomMultiplier = 2.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["NightElfMale"]           = { panMaxLeft = -0.5, panMaxRight = 0.5, panMaxTop = 0.85, panMaxBottom = -0.85, panValue = 30, zoomMultiplier = 4.2, panMaxZoom = 0.3, minZoom = -0.03 },
	["NightElfFemale"]         = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.90, panMaxBottom = -0.75, panValue = 33, zoomMultiplier = 4.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["ScourgeMale"]            = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.60, panMaxBottom = -0.65, panValue = 35, zoomMultiplier = 2.7, panMaxZoom = 0.3, minZoom = -0.03 },
	["ScourgeFemale"]          = { panMaxLeft = -0.3, panMaxRight = 0.4, panMaxTop = 0.75, panMaxBottom = -0.55, panValue = 36, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["TaurenMale"]             = { panMaxLeft = -0.7, panMaxRight = 0.9, panMaxTop = 0.75, panMaxBottom = -0.50, panValue = 31, zoomMultiplier = 4.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["TaurenFemale"]           = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.00, panMaxBottom = -0.30, panValue = 32, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["GnomeMale"]              = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.4,  panMaxBottom = -0.2,  panValue = 52, zoomMultiplier = 1.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["GnomeFemale"]            = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.40, panMaxBottom = -0.15, panValue = 60, zoomMultiplier = 1.5, panMaxZoom = 0.3, minZoom = -0.03 },
	["TrollMale"]              = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.05, panMaxBottom = -0.45, panValue = 27, zoomMultiplier = 3.7, panMaxZoom = 0.3, minZoom = -0.03 },
	["TrollFemale"]            = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.10, panMaxBottom = -0.60, panValue = 31, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["BloodElfMale"]           = { panMaxLeft = -0.5, panMaxRight = 0.4, panMaxTop = 0.65, panMaxBottom = -0.80, panValue = 36, zoomMultiplier = 3.7, panMaxZoom = 0.3, minZoom = -0.03 },
	["BloodElfFemale"]         = { panMaxLeft = -0.3, panMaxRight = 0.2, panMaxTop = 0.65, panMaxBottom = -0.63, panValue = 38, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["DraeneiMale"]            = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 0.95, panMaxBottom = -0.80, panValue = 28, zoomMultiplier = 4.5, panMaxZoom = 0.3, minZoom = -0.03 },
	["DraeneiFemale"]          = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.85, panValue = 31, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["WorgenMale"] 		       = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.60, panMaxBottom = -0.65, panValue = 35, zoomMultiplier = 2.7, panMaxZoom = 0.3, minZoom = -0.03 },
	["WorgenFemale"] 		   = { panMaxLeft = -0.3, panMaxRight = 0.4, panMaxTop = 0.75, panMaxBottom = -0.55, panValue = 36, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["Pandaren_aMale"]         = { panMaxLeft = -0.7, panMaxRight = 0.9, panMaxTop = 1.10, panMaxBottom = -0.80, panValue = 31, zoomMultiplier = 4.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["Pandaren_aFemale"]       = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.20, panMaxBottom = -0.60, panValue = 32, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["Pandaren_hMale"]         = { panMaxLeft = -0.7, panMaxRight = 0.9, panMaxTop = 1.10, panMaxBottom = -0.80, panValue = 31, zoomMultiplier = 4.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["Pandaren_hFemale"]       = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.20, panMaxBottom = -0.60, panValue = 32, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["BloodElf_DhMale"] 	   = { panMaxLeft = -0.5, panMaxRight = 0.4, panMaxTop = 0.65, panMaxBottom = -0.80, panValue = 36, zoomMultiplier = 3.7, panMaxZoom = 0.3, minZoom = -0.03 },
	["BloodElf_DhFemale"]      = { panMaxLeft = -0.3, panMaxRight = 0.2, panMaxTop = 0.65, panMaxBottom = -0.63, panValue = 38, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["NightElf_DhMale"]        = { panMaxLeft = -0.5, panMaxRight = 0.5, panMaxTop = 0.85, panMaxBottom = -0.85, panValue = 30, zoomMultiplier = 4.2, panMaxZoom = 0.3, minZoom = -0.03 },
	["NightElf_DhFemale"]      = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.90, panMaxBottom = -0.75, panValue = 33, zoomMultiplier = 4.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["EredarMale"]             = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 0.95, panMaxBottom = -0.80, panValue = 28, zoomMultiplier = 4.5, panMaxZoom = 0.3, minZoom = -0.03 },
	["EredarFemale"]           = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.85, panValue = 31, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["VoidElfMale"]            = { panMaxLeft = -0.5, panMaxRight = 0.4, panMaxTop = 0.65, panMaxBottom = -0.80, panValue = 36, zoomMultiplier = 3.7, panMaxZoom = 0.3, minZoom = -0.03 },
	["VoidElfFemale"]          = { panMaxLeft = -0.3, panMaxRight = 0.2, panMaxTop = 0.65, panMaxBottom = -0.63, panValue = 38, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["VulperaMale"]            = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.4, panMaxBottom = -0.2, panValue = 52, zoomMultiplier = 1.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["VulperaFemale"]          = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.40, panMaxBottom = -0.15, panValue = 60, zoomMultiplier = 1.5, panMaxZoom = 0.3, minZoom = -0.03 },
	["NightborneMale"]         = { panMaxLeft = -0.5, panMaxRight = 0.5, panMaxTop = 0.85, panMaxBottom = -0.85, panValue = 30, zoomMultiplier = 4.2, panMaxZoom = 0.3, minZoom = -0.03 },
	["NightborneFemale"]       = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.90, panMaxBottom = -0.75, panValue = 33, zoomMultiplier = 4.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["LightforgedMale"]        = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 0.95, panMaxBottom = -0.80, panValue = 28, zoomMultiplier = 4.5, panMaxZoom = 0.3, minZoom = -0.03 },
	["LightforgedFemale"]      = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.85, panValue = 31, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["ZandalariTrollMale"]     = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.05, panMaxBottom = -0.45, panValue = 27, zoomMultiplier = 3.7, panMaxZoom = 0.3, minZoom = -0.03 },
	["ZandalariTrollFemale"]   = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.10, panMaxBottom = -0.60, panValue = 31, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["DarkIronDwarfMale"]      = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.80, panMaxBottom = -0.25, panValue = 47, zoomMultiplier = 2.2, panMaxZoom = 0.3, minZoom = -0.03 },
	["DarkIronDwarfFemale"]    = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.80, panMaxBottom = -0.25, panValue = 47, zoomMultiplier = 2.2, panMaxZoom = 0.3, minZoom = -0.03 },
	["DarkIronDwarf_hMale"]    = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.80, panMaxBottom = -0.25, panValue = 47, zoomMultiplier = 2.2, panMaxZoom = 0.3, minZoom = -0.03 },
	["DarkIronDwarf_hFemale"]  = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.80, panMaxBottom = -0.25, panValue = 47, zoomMultiplier = 2.2, panMaxZoom = 0.3, minZoom = -0.03 },
	["HighElfMale"]            = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 0.95, panMaxBottom = -0.80, panValue = 28, zoomMultiplier = 4.5, panMaxZoom = 0.3, minZoom = -0.03 },
	["HighElfMaleC"]           = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 1.40, panMaxBottom = -0.45, panValue = 28, zoomMultiplier = 4.2, panMaxZoom = 0.3, minZoom = -0.03 },
	["HighElfFemale"]          = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.85, panValue = 31, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["HighmountainTaurenMale"] = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 0.95, panMaxBottom = -0.80, panValue = 28, zoomMultiplier = 4.5, panMaxZoom = 0.3, minZoom = -0.03 },
	["HighmountainTaurenMaleC"] = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 1.40, panMaxBottom = -0.45, panValue = 28, zoomMultiplier = 4.2, panMaxZoom = 0.3, minZoom = -0.03 },
	["HighmountainTaurenFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.85, panValue = 31, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["Vulpera_aMale"]          = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.4, panMaxBottom = -0.2, panValue = 52, zoomMultiplier = 1.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["Vulpera_aFemale"]        = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.40, panMaxBottom = -0.15, panValue = 60, zoomMultiplier = 1.5, panMaxZoom = 0.3, minZoom = -0.03 },
	["Dracthyr_hMale"]         = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.70, panMaxBottom = -0.75, panValue = 38, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["Dracthyr_hFemale"]       = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.70, panMaxBottom = -0.65, panValue = 45, zoomMultiplier = 2.4, panMaxZoom = 0.3, minZoom = -0.03 },
	["Dracthyr_hMale"]         = { panMaxLeft = -0.5, panMaxRight = 0.4, panMaxTop = 0.65, panMaxBottom = -0.80, panValue = 36, zoomMultiplier = 3.7, panMaxZoom = 0.3, minZoom = -0.03 },
	["Dracthyr_aFemale"]       = { panMaxLeft = -0.3, panMaxRight = 0.2, panMaxTop = 0.65, panMaxBottom = -0.63, panValue = 38, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["MagharMale"]             = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 0.60, panMaxBottom = -0.65, panValue = 35, zoomMultiplier = 2.7, panMaxZoom = 0.3, minZoom = -0.03 },
	["MagharFemale"]           = { panMaxLeft = -0.3, panMaxRight = 0.4, panMaxTop = 0.75, panMaxBottom = -0.55, panValue = 36, zoomMultiplier = 3.8, panMaxZoom = 0.3, minZoom = -0.03 },
	["KulTiranMale"]           = { panMaxLeft = -0.7, panMaxRight = 0.8, panMaxTop = 0.75, panMaxBottom = -0.60, panValue = 30, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
	["KulTiranFemale"]         = { panMaxLeft = -0.4, panMaxRight = 0.3, panMaxTop = 0.80, panMaxBottom = -0.60, panValue = 37, zoomMultiplier = 3.0, panMaxZoom = 0.3, minZoom = -0.03 },
}

-- Retourne les settings de la race/sexe du joueur connecté (évalué dynamiquement à chaque appel)
local function SelectSettings()
	local _, playerRaceSex = UnitRace("player")
	if UnitSex("player") == 2 then
		playerRaceSex = playerRaceSex .. "Male"
	else
		playerRaceSex = playerRaceSex .. "Female"
	end
	return ModelSettings[playerRaceSex]
end

-- Retourne l'offset de zoom selon le modèle (DressUp / Inspect)
local function GetZoomOffsetByModel(model)
	if model == DressUpModel then
		return MODELFRAME_MAX_ZOOM
	elseif model == InspectModelFrame then
		return MODELFRAME_MAX_INSPECT_ZOOM
	end
end

-- ─── OnLoad ────────────────────────────────────────────────────────────────────

function SharedXML_Model_OnLoad(self, maxZoom, minZoom, defaultRotation, onMouseUp)
	self.settings = SelectSettings()

	self.maxZoom         = GetZoomOffsetByModel(self) or (self.settings and self.settings.panMaxZoom) or MODELFRAME_MAX_ZOOM
	self.minZoom         = (self.settings and self.settings.minZoom) or minZoom or MODELFRAME_MIN_ZOOM
	self.defaultRotation = defaultRotation or MODELFRAME_DEFAULT_ROTATION
	self.onMouseUpFunc   = onMouseUp or SharedXML_Model_OnMouseUp

	self.rotation = self.defaultRotation
	-- SetFacing est l'API 3.3.5 pour orienter le modèle
	self.SetRotation = self.SetFacing
	self:SetRotation(self.rotation)
	self:RegisterEvent("UI_SCALE_CHANGED")
	self:RegisterEvent("DISPLAY_SIZE_CHANGED")

	-- Multiplicateur de zoom portrait
	self.portraitZoomMultiplier = (DressUpModel and MODELDRESSUP_MULTIPLIER_ZOOM)
	                           or (self.settings and self.settings.zoomMultiplier)
	                           or 3.0

	function self:SetPortraitZoom(zoomLevel)
		local x, y, z = self:GetPosition()
		self:SetPosition(zoomLevel * self.portraitZoomMultiplier * self:GetModelScale(), y, z)
	end
	self:SetPortraitZoom(self.minZoom)
end

-- ─── OnEvent ───────────────────────────────────────────────────────────────────

function SharedXML_Model_OnEvent(self, ...)
	if self.RefreshCamera then
		self:RefreshCamera()
	end
end

-- ─── Rotation boutons ──────────────────────────────────────────────────────────

function SharedXML_Model_RotateLeft(model, rotationIncrement)
	if not rotationIncrement then rotationIncrement = 0.03 end
	model.rotation = model.rotation - rotationIncrement
	model:SetRotation(model.rotation)
	PlaySound("igInventoryRotateCharacter")
end

function SharedXML_Model_RotateRight(model, rotationIncrement)
	if not rotationIncrement then rotationIncrement = 0.03 end
	model.rotation = model.rotation + rotationIncrement
	model:SetRotation(model.rotation)
	PlaySound("igInventoryRotateCharacter")
end

-- ─── Mouse Down / Up ───────────────────────────────────────────────────────────

function SharedXML_Model_OnMouseDown(model, button)
	if button == "LeftButton" or not button then
		-- Clic gauche : rotation par drag
		model.mouseDown = true
		model.rotationCursorStart = GetCursorPosition()
	elseif button == "RightButton" then
		-- Clic droit : déplacement (panning) du personnage + affichage du curseur visuel
		SharedXML_Model_StartPanning(model, true)
	end
end

function SharedXML_Model_OnMouseUp(model, button)
	if button == "LeftButton" or not button then
		model.mouseDown = false
	elseif button == "RightButton" then
		SharedXML_Model_StopPanning(model)
	end
end

-- ─── Mouse Wheel (zoom) ────────────────────────────────────────────────────────

function SharedXML_Model_OnMouseWheel(self, delta, maxZoom, minZoom)
	if self.disabledZooming then return end

	maxZoom = maxZoom or self.maxZoom
	minZoom = minZoom or self.minZoom

	local zoomLevel = self.zoomLevel or minZoom
	zoomLevel = zoomLevel + delta * MODELFRAME_ZOOM_STEP
	zoomLevel = min(zoomLevel, maxZoom)
	zoomLevel = max(zoomLevel, minZoom)
	self.zoomLevel = zoomLevel
end

-- ─── OnUpdate ──────────────────────────────────────────────────────────────────

function SharedXML_Model_OnUpdate(self, elapsedTime, rotationsPerSecond)
	if not rotationsPerSecond then
		rotationsPerSecond = ROTATIONS_PER_SECOND
	end

	-- Zoom fluide (smooth camera)
	if self.zoomLevel then
		local x, y, z = self:GetPosition()
		local tx = self.zoomLevel * self.portraitZoomMultiplier * self:GetModelScale()
		local delta = tx - x
		if math.abs(delta) > 0.001 then
			self.cameraX = x + delta * elapsedTime * 20 * CAMERA_ZOOMSMOOTH_SPEED
			if (delta > 0 and self.cameraX > tx) or (delta < 0 and self.cameraX < tx) then
				self.cameraX = tx
			end
			self:SetPosition(self.cameraX, y, z)
		elseif math.abs(delta) > 0.0001 then
			self.cameraX = tx
			self:SetPosition(self.cameraX, y, z)
		end
	end

	-- Rotation par drag clic gauche
	if self.mouseDown then
		if self.rotationCursorStart then
			local x = GetCursorPosition()
			local diff = (x - self.rotationCursorStart) * MODELFRAME_DRAG_ROTATION_CONSTANT
			self.rotationCursorStart = GetCursorPosition()
			self.rotation = self.rotation + diff
			if self.rotation < 0 then
				self.rotation = self.rotation + (2 * PI)
			end
			if self.rotation > (2 * PI) then
				self.rotation = self.rotation - (2 * PI)
			end
			self:SetRotation(self.rotation, false)
		end

	-- Panning (déplacement) clic droit
	elseif self.panning then
		local modelScale = self:GetModelScale()
		local cursorX, cursorY = GetCursorPosition()
		local scale = UIParent:GetEffectiveScale()
		ModelsPanningFrame:SetPoint("BOTTOMLEFT", cursorX / scale - 16, cursorY / scale - 16)	-- centre le curseur visuel sur la souris

		local settings = self.settings or SelectSettings()

		if settings then
			local zoom = self.zoomLevel or self.minZoom
			zoom = 1 + zoom - self.minZoom	-- 1 au zoom minimum

			-- Ratio de transformation : même vitesse de curseur quel que soit le zoom
			local transformationRatio = settings.panValue * 2 ^ (zoom * 2) * scale / modelScale

			local positionY = self.positionY or 0
			local positionZ = self.positionX or 0
			local dx = (cursorX - self.cursorX) / transformationRatio
			local dy = (cursorY - self.cursorY) / transformationRatio
			local cameraY = self.cameraY + dx - positionY
			local cameraZ = self.cameraZ + dy - positionZ

			-- Bornes de déplacement
			local scaledModel = scale * modelScale
			cameraY = min(cameraY, settings.panMaxRight  * scaledModel)
			cameraY = max(cameraY, settings.panMaxLeft   * scaledModel)
			cameraZ = min(cameraZ, settings.panMaxTop    * scaledModel)
			cameraZ = max(cameraZ, settings.panMaxBottom * scaledModel)

			-- Mise à jour du curseur de référence pour le prochain frame
			self.cursorX = cursorX
			self.cursorY = cursorY
			self.cameraY = cameraY + positionY
			self.cameraZ = cameraZ + positionZ

			self:SetPosition(self.cameraX, self.cameraY, self.cameraZ)
		end
	end

	-- Boutons de rotation gauche/droite
	local leftButton, rightButton
	if self.controlFrameModel then
		leftButton  = self.controlFrameModel.rotateLeftButton
		rightButton = self.controlFrameModel.rotateRightButton
	else
		leftButton  = self.RotateLeftButton  or (self:GetName() and _G[self:GetName() .. "RotateLeftButton"])
		rightButton = self.RotateRightButton or (self:GetName() and _G[self:GetName() .. "RotateRightButton"])
	end

	if leftButton and leftButton:GetButtonState() == "PUSHED" then
		self.rotation = self.rotation + (elapsedTime * 2 * PI * rotationsPerSecond)
		if self.rotation < 0 then
			self.rotation = self.rotation + (2 * PI)
		end
		self:SetRotation(self.rotation)
	elseif rightButton and rightButton:GetButtonState() == "PUSHED" then
		self.rotation = self.rotation - (elapsedTime * 2 * PI * rotationsPerSecond)
		if self.rotation > (2 * PI) then
			self.rotation = self.rotation - (2 * PI)
		end
		self:SetRotation(self.rotation)
	end
end

-- ─── Utilitaires ───────────────────────────────────────────────────────────────

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
	if usePanningFrame and ModelsPanningFrame then
		ModelsPanningFrame.model = self
		ModelsPanningFrame:Show()
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
	if ModelsPanningFrame then
		ModelsPanningFrame:Hide()
	end
end

-- ─── Boutons de contrôle du modèle ─────────────────────────────────────────────

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
