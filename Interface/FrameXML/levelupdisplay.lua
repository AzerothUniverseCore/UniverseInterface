function LevelUpDisplay_OnLoad(self, ...)
    self:RegisterEvent("PLAYER_LEVEL_UP")
end

function LevelUpDisplay_OnShow(self, ...)
    -- Réinitialisation des variables de niveau et de notification de sorts
    self.unlockList = {}
    self.currSpell = 0

    -- Configuration des lignes graphiques (le visuel d'affichage)
    self.gLine:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
    self.gLine2:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

    self.gLine:SetVertexColor(1, 1, 1)
    self.gLine2:SetVertexColor(1, 1, 1)

    -- Si des UPS sont reçus (points supplémentaires ou autres récompenses)
    if self.ups then
        self.levelFrame.reachedText:SetText(LEVEL_UP_YOU_RECEIVED)
        self.levelFrame.levelText:SetFormattedText(LEVEL_UP_UPS_RECEIVED, self.ups)
    end

    -- Affichage de la notification de niveau atteint
    if self.level then
        self.levelFrame.reachedText:SetText(LEVEL_UP_YOU_REACHED)
        self.levelFrame.levelText:SetFormattedText(LEVEL_GAINED, self.level)
    end

    -- Animation de montée de niveau
    self.levelFrame.levelText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    self.levelFrame.levelUp:Play()
end

function LevelUpDisplay_OnEvent(self, event, ...)
    local level = ...
    self.level = level
    self.ups = nil
    self:Show()
    LevelUpDisplaySide:Hide()
end

function LevelUpDisplay_AnimStep(self)
    -- Aucun sort à afficher ici, on désactive la partie des sorts
    self.currSpell = 0
    self.hideAnim:Play()
end
