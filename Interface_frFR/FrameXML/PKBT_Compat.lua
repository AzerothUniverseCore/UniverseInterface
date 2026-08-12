-- PKBT_Compat.lua
-- Polyfill minimal requis par SharedUIPanelPKBTTemplates.lua (PKBT_ModelMixin)
-- pour le client Azeroth Universe.
--
-- Verifie par recherche exhaustive dans les deux clients complets (zips
-- InterfaceSirus / InterfaceAzerothUniverse) : tout le reste dont depend
-- PKBT_ModelMixin (tInvert, tContains, tIndexOf, GMError,
-- LoadingSpinnerTemplate, issecure, CreateFromMixins, Mixin,
-- IsCreatureDataCached, RequestLoadCreatureByID, l'evenement
-- CREATURE_DATA_LOAD_RESULT, Model:SetCreature/GetModel) existe deja
-- nativement cote client Universe (ou tolere un argument nil sans planter,
-- cas de CreateFromMixins/Mixin) : aucun besoin de le reimplementer ici.
--
-- Doit etre charge AVANT SharedUIPanelPKBTTemplates.xml/.lua dans FrameXML.toc.

Enum = Enum or {}

if not Enum.CreateMirror then
	local function readOnlyError()
		error("This is a read only table and cannot be modified.", 2)
	end

	function Enum.CreateMirror(t)
		local mirror = {}
		local inverted

		for k, v in pairs(t) do
			mirror[k] = v
			mirror[v] = k

			if type(v) == "number" then
				if not inverted then
					inverted = {}
				end
				inverted[v] = k
			end
		end

		if inverted then
			t = inverted
		end

		setmetatable(t, {
			__index = function(self, key)
				return mirror[key]
			end,
			__call = function(self, key, value)
				if value and issecure() then
					rawset(self, key, value)
				else
					return mirror[key]
				end
			end,
			__newindex = readOnlyError,
			__metatable = false,
		})

		return t
	end
end

if not Enum.ModelType then
	-- Valeurs identiques a celles de Sirus (SharedXML/SharedConstants.lua)
	Enum.ModelType = Enum.CreateMirror({
		M2 = 0,
		Unit = 1,
		Creature = 2,
		Item = 3,
		ItemSet = 4,
		Illusion = 5,
		ItemTransmog = 6,
		Customization = 7,
	})
end

if not SetParentFrameLevel then
	function SetParentFrameLevel(frame, offset)
		frame:SetFrameLevel(frame:GetParent():GetFrameLevel() + (offset or 0))
	end
end

if not IsOnGlueScreen then
	-- Sirus utilise IsOnGlueScreen(), Azeroth Universe utilise InGlue() (voir
	-- Interface\SharedXML\EJ_CompatEarly.lua) : meme role, nom different.
	-- SANS ce polyfill, SharedUIPanelPKBTTemplates.lua plante des la ligne
	-- "if not IsOnGlueScreen() then" (hors de toute fonction, executee
	-- immediatement au chargement du fichier) et TOUT ce qui suit --
	-- ModelLoadHandler et PKBT_ModelMixin en entier -- n'est jamais defini.
	function IsOnGlueScreen()
		return InGlue()
	end
end

if not C_Timer then
	-- Azeroth Universe n'a pas C_Timer (standard retail : C_Timer.NewTimer /
	-- C_Timer.After / C_Timer.NewTicker) mais un equivalent maison,
	-- C_TimerAug (voir Interface\SharedXML\C_TimerAugment.lua), avec
	-- C_TimerAug:After(duration, callback) et
	-- C_TimerAug:NewTicker(duration, callback, iterations), tous deux
	-- renvoyant un objet avec :Cancel(). SharedUIPanelPKBTTemplates.lua
	-- utilise C_Timer.NewTimer(...):Cancel() (PKBT_ModelMixin:OnShow /
	-- OnUpdateModel) : on relie simplement les deux API, sans reimplementer
	-- la logique de timer.
	C_Timer = {}

	function C_Timer.NewTimer(duration, callback)
		return C_TimerAug:After(duration, callback)
	end

	function C_Timer.After(duration, callback)
		C_TimerAug:After(duration, callback)
	end

	function C_Timer.NewTicker(duration, callback, iterations)
		return C_TimerAug:NewTicker(duration, callback, iterations)
	end
end
