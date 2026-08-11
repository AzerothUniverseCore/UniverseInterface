-- PandariaHighlight.lua
-- Reproduit le comportement de UpdateMapHighlight() pour la Pandarie
-- GetCurrentMapContinent() == 6 => Pandarie
-- GetCurrentMapZone() == 0      => vue continent (pas de sous-zone)

local PANDARIA_CONTINENT_ID = 6

-- IMPORTANT : zones ordonnées de la PLUS PETITE à la PLUS GRANDE surface
-- pour que les petites zones soient détectées en priorité quand elles sont
-- englobées par la bbox rectangulaire d'une plus grande zone (ex: Kun-Lai)
local PANDARIA_BOUNDS = {
    -- ~1.1M unités² — la plus petite
    { name = "Île du Temps figé",              file = "TimelessIsle",          zoneID = 3,  locLeft = -4083.33,  locRight = -6483.33,  locTop =  -166.666, locBottom = -1766.67  },
    -- ~2.8M unités²
    { name = "Île des Géants",                 file = "IsleOfGiants",          zoneID = 2,  locLeft =  2004.17,  locRight =   216.666, locTop =  6497.92,  locBottom =  5306.25  },
    -- ~3.7M unités²
    { name = "Val de l'Éternel Printemps",     file = "ValeofEternalBlossoms", zoneID = 9,  locLeft =  2481.25,  locRight =   -52.084, locTop =  1747.92,  locBottom =    60.416 },
    -- ~6.5M unités²
    { name = "Terres de l'Angoisse",           file = "DreadWastes",           zoneID = 8,  locLeft =  6139.58,  locRight =   787.5,   locTop =  1416.67,  locBottom = -2152.08  },
    -- ~8.5M unités²
    { name = "Étendues sauvages de Krasarang", file = "Krasarang",             zoneID = 1,  locLeft =  2947.92,  locRight = -1739.58,  locTop =  -510.416, locBottom = -3635.42  },
    -- ~10M unités²
    { name = "Vallée des Quatre Vents",        file = "ValleyoftheFourWinds",  zoneID = 10, locLeft =  2679.17,  locRight = -1245.83,  locTop =   895.83,  locBottom = -1720.83  },
    -- ~11M unités²
    { name = "Steppes de Tanglong",            file = "TownlongWastes",        zoneID = 6,  locLeft =  7079.17,  locRight =  1335.42,  locTop =  4158.33,  locBottom =   329.167 },
    -- ~25M unités²
    { name = "La forêt de Jade",               file = "TheJadeForest",         zoneID = 4,  locLeft =  1452.08,  locRight = -5531.25,  locTop =  3652.08,  locBottom = -1002.08  },
    -- ~37M unités² — la plus grande, testée EN DERNIER
    { name = "Sommet de Kun-Lai",              file = "KunLaiSummit",          zoneID = 5,  locLeft =  4839.58,  locRight = -1418.75,  locTop =  5018.75,  locBottom =   845.83  },
}

-- Bounds du continent entier — ID 6200 dans WorldMapArea.dbc
local CONT_LEFT   =  8752.86
local CONT_RIGHT  = -6762.44
local CONT_TOP    =  6679.16
local CONT_BOTTOM = -3664.38
local CONT_WIDTH  = CONT_LEFT - CONT_RIGHT   -- 15515.30
local CONT_HEIGHT = CONT_TOP  - CONT_BOTTOM  -- 10343.54

local highlightTexture = nil
local clickFrame       = nil

-- ─── Helpers ────────────────────────────────────────────────────────────────

local function GetHighlightTexture()
    if not highlightTexture then
        highlightTexture = WorldMapDetailFrame:CreateTexture("PandariaZoneHighlight", "OVERLAY")
        highlightTexture:SetBlendMode("ADD")
        highlightTexture:Hide()
    end
    return highlightTexture
end

local function GetClickFrame()
    if not clickFrame then
        clickFrame = CreateFrame("Button", "PandariaZoneClickFrame", WorldMapDetailFrame)
        clickFrame:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 5)
        clickFrame:Hide()
        clickFrame:SetScript("OnClick", function(self, button)
            if self.zoneID and button == "LeftButton" then
                SetMapZoom(PANDARIA_CONTINENT_ID, self.zoneID)
            end
        end)
    end
    return clickFrame
end

local function NormalizedToWorld(nx, ny)
    local worldX = CONT_LEFT - nx * CONT_WIDTH
    local worldY = CONT_TOP  - ny * CONT_HEIGHT
    return worldX, worldY
end

local function IsInZone(worldX, worldY, zone)
    return (worldX <= zone.locLeft) and (worldX >= zone.locRight)
       and (worldY <= zone.locTop)  and (worldY >= zone.locBottom)
end

local function GetTexturePosition(zone)
    local mapW = WorldMapDetailFrame:GetWidth()
    local mapH = WorldMapDetailFrame:GetHeight()

    local zoneLeft   = (CONT_LEFT - zone.locLeft)   / CONT_WIDTH
    local zoneTop    = (CONT_TOP  - zone.locTop)    / CONT_HEIGHT
    local zoneRight  = (CONT_LEFT - zone.locRight)  / CONT_WIDTH
    local zoneBottom = (CONT_TOP  - zone.locBottom) / CONT_HEIGHT

    local x = zoneLeft                   * mapW
    local y = -zoneTop                   * mapH
    local w = (zoneRight  - zoneLeft)    * mapW
    local h = (zoneBottom - zoneTop)     * mapH

    return x, y, w, h
end

-- ─── OnUpdate ───────────────────────────────────────────────────────────────

local frame    = CreateFrame("Frame")
local lastZone = nil

frame:SetScript("OnUpdate", function(self, elapsed)
    -- FIX : WorldMapDetailFrame:GetLeft()/GetTop() renvoient nil quand la
    -- carte du monde n'est pas affichee (frame non positionnee), ce qui
    -- plantait "attempt to perform arithmetic on a nil value" en boucle des
    -- que le joueur se trouvait sur le continent de Pandarie, meme carte
    -- fermee (ce script tourne en permanence via OnUpdate).
    if not WorldMapFrame:IsShown() or GetCurrentMapContinent() ~= PANDARIA_CONTINENT_ID or GetCurrentMapZone() ~= 0 then
        if highlightTexture then highlightTexture:Hide() end
        if clickFrame       then clickFrame:Hide()       end
        lastZone = nil
        return
    end

    local cursorX, cursorY = GetCursorPosition()
    local scale = WorldMapDetailFrame:GetEffectiveScale()
    local left  = WorldMapDetailFrame:GetLeft()   * scale
    local top   = WorldMapDetailFrame:GetTop()    * scale
    local w     = WorldMapDetailFrame:GetWidth()  * scale
    local h     = WorldMapDetailFrame:GetHeight() * scale

    local nx = (cursorX - left) / w
    local ny = (top - cursorY)  / h

    if nx < 0 or nx > 1 or ny < 0 or ny > 1 then
        if highlightTexture then highlightTexture:Hide() end
        if clickFrame       then clickFrame:Hide()       end
        lastZone = nil
        return
    end

    local worldX, worldY = NormalizedToWorld(nx, ny)

    local foundZone = nil
    for _, zone in ipairs(PANDARIA_BOUNDS) do
        if IsInZone(worldX, worldY, zone) then
            foundZone = zone
            break
        end
    end

    local tex = GetHighlightTexture()
    local cf  = GetClickFrame()

    if foundZone then
        if lastZone ~= foundZone.name then
            lastZone = foundZone.name

            if WorldMapFrameAreaLabel then
                WorldMapFrameAreaLabel:SetText(foundZone.name)
            end

            local ox, oy, tw, th = GetTexturePosition(foundZone)

            tex:SetTexture("Interface\\WorldMap\\" .. foundZone.file .. "\\" .. foundZone.file .. "Highlight")
            tex:SetWidth(tw)
            tex:SetHeight(th)
            tex:ClearAllPoints()
            tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", ox, oy)
            tex:Show()

            cf.zoneID = foundZone.zoneID
            cf:SetWidth(tw)
            cf:SetHeight(th)
            cf:ClearAllPoints()
            cf:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", ox, oy)
            cf:Show()
        end
    else
        if lastZone then
            lastZone = nil
            tex:Hide()
            cf:Hide()
            if WorldMapFrameAreaLabel then
                WorldMapFrameAreaLabel:SetText("")
            end
        end
    end
end)

-- ─── Nettoyage à la fermeture de la carte ───────────────────────────────────

WorldMapFrame:HookScript("OnHide", function()
    if highlightTexture then highlightTexture:Hide() end
    if clickFrame       then clickFrame:Hide()       end
    lastZone = nil
end)
