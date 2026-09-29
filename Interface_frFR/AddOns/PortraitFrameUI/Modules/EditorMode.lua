--[[
    EditorMode

    Copyright (c) Dmitriy. All rights reserved.
    Licensed under the MIT license. See LICENSE file in the project root for details.
]]

local RUI = LibStub('AceAddon-3.0'):GetAddon('PortraitFrameUI')
local moduleName = 'EditorMode'
local Module = RUI:NewModule(moduleName, 'AceConsole-3.0')

-- Modules exposant ShowEditorTest()/HideEditorTest(), dont les cadres
-- peuvent donc être déplacés tant que le Mode Édition est actif.
local EDITABLE_MODULES = { 'UnitFrame', 'CastingBar' }

local GRID_SPACING = 64
local GRID_LINE_ALPHA = 0.12
local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"

local panel
local capture

local function ForEachEditableModule(callback)
    for _, name in ipairs(EDITABLE_MODULES) do
        local mod = RUI:GetModule(name, true)
        if mod then
            callback(mod)
        end
    end
end

-- Cadre plein écran placé sous les repères de déplacement (même strate
-- FULLSCREEN, niveau plus bas) mais au-dessus de tout cadre normal du
-- jeu/de l'interface. Activer la souris dessus, sans aucun gestionnaire de
-- clic, suffit à absorber tout clic qui n'atterrit pas sur un repère de
-- déplacement, pour que rien en dessous ne soit cliquable tant que le Mode
-- Édition est ouvert.
local function CreateCapture()
    capture = CreateFrame("Frame", "RUIEditModeCapture", UIParent)
    capture:SetAllPoints(UIParent)
    capture:SetFrameStrata("FULLSCREEN")
    capture:SetFrameLevel(1)
    capture:EnableMouse(true)
    capture:Hide()

    local tint = capture:CreateTexture(nil, "BACKGROUND")
    tint:SetAllPoints(capture)
    tint:SetTexture(0, 0, 0, 0.25)

    -- Quadrillage de repère, comme le fond du Mode Édition de Retail.
    local width, height = UIParent:GetWidth(), UIParent:GetHeight()

    local x = 0
    while x <= width do
        local line = capture:CreateTexture(nil, "BORDER")
        line:SetTexture(WHITE_TEXTURE)
        line:SetVertexColor(1, 1, 1, GRID_LINE_ALPHA)
        line:SetPoint("TOPLEFT", capture, "TOPLEFT", x, 0)
        line:SetSize(1, height)
        x = x + GRID_SPACING
    end

    local y = 0
    while y <= height do
        local line = capture:CreateTexture(nil, "BORDER")
        line:SetTexture(WHITE_TEXTURE)
        line:SetVertexColor(1, 1, 1, GRID_LINE_ALPHA)
        line:SetPoint("TOPLEFT", capture, "TOPLEFT", 0, -y)
        line:SetSize(width, 1)
        y = y + GRID_SPACING
    end
end

local function CreatePanel()
    panel = CreateFrame("Frame", "RUIEditorModePanel", UIParent)
    panel:SetSize(280, 150)
    panel:SetPoint("TOP", UIParent, "TOP", 0, -140)
    -- Même strate FULLSCREEN que la couche de capture (niveau 1) et les
    -- repères de déplacement (niveau 100), mais avec un niveau bien plus
    -- élevé, pour que le panneau s'affiche au-dessus des deux et que ses
    -- boutons restent cliquables. FULLSCREEN_DIALOG avait été essayé en
    -- premier ici mais n'est utilisé nulle part ailleurs dans le FrameXML de
    -- ce client, et faisait échouer silencieusement CreatePanel() en cours
    -- de route dès le tout premier appel (le panneau était créé mais jamais
    -- terminé, donc Show() semblait bloqué jusqu'à un second basculement) ;
    -- FULLSCREEN est confirmé sûr puisque le CreateUIFrame de Core.lua s'appuie
    -- déjà dessus.
    panel:SetFrameStrata("FULLSCREEN")
    panel:SetFrameLevel(200)
    panel:SetToplevel(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)

    -- Les cadres créés par CreateFrame() sont affichés par défaut. Sans
    -- cette ligne, le tout premier Module:Show() trouve le panneau déjà
    -- affiché, donc le panel:Show() plus bas ne fait rien (pas de
    -- transition caché->affiché) et OnShow - qui appelle justement
    -- ShowEditorTest() pour rendre les vrais cadres déplaçables - ne se
    -- déclenche jamais. C'est exactement pourquoi la fenêtre et le
    -- quadrillage apparaissaient bien dès le premier clic mais le
    -- déplacement ne fonctionnait qu'après avoir fermé puis rouvert le Mode
    -- Édition : la fermeture armait la transition pour la fois suivante.
    -- Démarrer caché ici (comme le fait déjà capture) fait fonctionner
    -- correctement ce tout premier Show() aussi.
    panel:Hide()

    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", panel, "TOP", 0, -16)
    title:SetText("Mode Édition")

    local hint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    hint:SetPoint("TOP", title, "BOTTOM", 0, -10)
    hint:SetWidth(248)
    hint:SetNonSpaceWrap(true)
    hint:SetJustifyH("CENTER")
    hint:SetJustifyV("TOP")
    hint:SetText("Faire glisser les cadres en surbrillance pour les déplacer. Les positions sont enregistrées automatiquement.")

    local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetButton:SetSize(120, 24)
    resetButton:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
    resetButton:SetText("Réinitialiser")
    resetButton:SetScript("OnClick", function()
        ForEachEditableModule(function(mod)
            if mod.LoadDefaultSettings then mod:LoadDefaultSettings() end
            if mod.UpdateWidgets then mod:UpdateWidgets() end
        end)
    end)

    local doneButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    doneButton:SetSize(120, 24)
    doneButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)
    doneButton:SetText("Terminé")
    doneButton:SetScript("OnClick", function()
        Module:Hide()
    end)

    -- Le travail réel (basculer vers les cadres déplaçables / restaurer les
    -- vrais cadres et enregistrer les positions) se fait à l'affichage et à
    -- la fermeture, donc Echap (via UISpecialFrames) et le bouton Terminé
    -- quittent proprement tous les deux.
    panel:SetScript("OnShow", function()
        ForEachEditableModule(function(mod)
            if mod.ShowEditorTest then mod:ShowEditorTest() end
        end)
    end)

    panel:SetScript("OnHide", function()
        ForEachEditableModule(function(mod)
            if mod.HideEditorTest then mod:HideEditorTest(true) end
        end)
        if capture then
            capture:Hide()
        end
        Module.active = false
    end)

    tinsert(UISpecialFrames, "RUIEditorModePanel")
end

function Module:OnInitialize()
    self.active = false
end

function Module:IsShown()
    return self.active == true
end

function Module:Show()
    if self.active then
        return
    end
    self.active = true

    if not capture then
        CreateCapture()
    end
    if not panel then
        CreatePanel()
    end

    capture:Show()
    panel:Show()
end

function Module:Hide()
    if not self.active then
        return
    end

    -- Le OnHide du panneau (ci-dessus) fait le vrai travail de fermeture et
    -- cache aussi la couche de capture, donc Echap (UISpecialFrames) comme
    -- cet appel aboutissent toujours à un état cohérent.
    if panel then
        panel:Hide()
    end
end

-- Expose aussi le Mode Édition depuis le menu Echap, comme sur Retail, pour
-- que les joueurs n'aient pas besoin de connaître la commande « /rui edit ».
if GameMenuFrame and GameMenuButtonUIOptions and GameMenuButtonKeybindings then
    local menuButton = CreateFrame("Button", "RUIGameMenuEditModeButton", GameMenuFrame, "GameMenuButtonTemplate")
    menuButton:SetText("Mode Édition")
    menuButton:SetPoint("TOP", GameMenuButtonUIOptions, "BOTTOM", 0, -1)
    menuButton:SetScript("OnClick", function()
        PlaySound("igMainMenuOption")

        -- Bascule le Mode Édition AVANT de fermer le menu Echap. Le OnHide
        -- de GameMenuFrame appelle UpdateMicroButtons(), qui sur ce client
        -- plante ("UIPanelTemplates.lua:18: 'for' limit must be a number",
        -- un souci préexistant dans PVPFrame.lua sans rapport avec le Mode
        -- Édition) — et cette erreur interrompt tout ce qui suit dans ce
        -- même clic. En basculant d'abord, notre action se termine toujours
        -- même si la fermeture du menu déclenche ensuite cette erreur.
        if Module:IsShown() then
            Module:Hide()
        else
            Module:Show()
        end

        HideUIPanel(GameMenuFrame)
    end)

    -- Décale tout ce qui est sous « Interface » d'une ligne, comme le fait
    -- déjà GameMenuButtonMacOptions pour le bouton réservé au client Mac
    -- au-dessus.
    GameMenuButtonKeybindings:ClearAllPoints()
    GameMenuButtonKeybindings:SetPoint("TOP", menuButton, "BOTTOM", 0, -1)

    local GAME_MENU_BOTTOM_MARGIN = 16

    -- Agrandit GameMenuFrame pour que « Retour au jeu » (le dernier bouton,
    -- chaîné sous Quitter) reste à l'intérieur du cadre. Une augmentation de
    -- taille fixe et unique n'est pas fiable ici : le menu Échap de ce
    -- serveur a déjà un bouton personnalisé « Boutique » ajouté par un autre
    -- script, et il n'y a aucun moyen de savoir, depuis ce seul fichier, si
    -- ce script s'exécute avant ou après celui-ci, ni exactement quelle
    -- hauteur il a déjà ajoutée — une estimation fixe pourrait donc être
    -- insuffisante ou excessive selon cet ordre. On mesure à la place
    -- l'écart réel entre le bord bas du cadre et celui du bouton « Retour au
    -- jeu » à chaque ouverture du menu (à ce moment-là, tous les scripts ont
    -- déjà appliqué leurs changements) et on agrandit le cadre du montant
    -- réellement manquant, ce qui continue de fonctionner quoi qu'un autre
    -- script modifie par ailleurs dans le menu. GameMenuFrame étant ancré
    -- par son point CENTER, agrandir sa hauteur ne déplace le bord bas que
    -- de la moitié de ce qui est ajouté (le bord haut remonte de l'autre
    -- moitié) — le montant manquant est donc doublé pour compenser.
    local function FitGameMenuFrameToContinueButton()
        if not GameMenuButtonContinue then
            return
        end

        local frameBottom = GameMenuFrame:GetBottom()
        local continueBottom = GameMenuButtonContinue:GetBottom()
        if not frameBottom or not continueBottom then
            return
        end

        local margin = continueBottom - frameBottom
        if margin < GAME_MENU_BOTTOM_MARGIN then
            GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + (GAME_MENU_BOTTOM_MARGIN - margin) * 2)
        end
    end

    GameMenuFrame:HookScript("OnShow", FitGameMenuFrameToContinueButton)
end
