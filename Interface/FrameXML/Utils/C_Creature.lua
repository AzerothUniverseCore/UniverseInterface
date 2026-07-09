C_CreatureMixin = {}

enum:E_CREATURE_CACHE {
    "DISPLAY_ID",
    "NAME",
    "ICON",
}

function C_CreatureMixin:GetCreatureDisplayId(creatureEntry)
    if not creatureEntry or not CreaturesCache then
        return
    end

    local row = CreaturesCache[tonumber(creatureEntry) or creatureEntry]
    if not row then
        return
    end

    return row[E_CREATURE_CACHE.DISPLAY_ID]
end

-- Retourne le chemin du modele (.mdx/.m2) correspondant a un displayId,
-- via la table generee DisplayIdToModelPath (cf DisplayIdToModelPath.lua).
function C_CreatureMixin:GetModelPathFromDisplayId(displayId)
    if not displayId or displayId <= 0 or not DisplayIdToModelPath then
        return nil
    end

    return DisplayIdToModelPath[displayId]
end

function C_CreatureMixin:SetCreatureModel(model, creatureEntry)
    if not model or not creatureEntry then
        return
    end

    local displayId = self:GetCreatureDisplayId(creatureEntry)
    if not displayId or displayId <= 0 then
        -- Pas de correspondance trouvee dans CreaturesCache pour cet entry.
        -- On ne doit JAMAIS utiliser creatureEntry comme displayId de secours :
        -- ce sont deux valeurs totalement differentes (entry vs CreatureDisplayID).
        if model.ClearModel then
            pcall(model.ClearModel, model)
        end
        print(string.format("|cffff0000[EncounterJournal]|r Aucun displayId trouve dans CreaturesCache pour l'entry %s (modele non affiche).", tostring(creatureEntry)))
        return
    end

    if model.ClearModel then
        pcall(model.ClearModel, model)
    end

    -- IMPORTANT : sur ce client (retroport 4.3.4 -> 3.3.5), Model:SetCreature(displayId)
    -- est casse au niveau du widget UI (confirme par test : le modele disparait purement
    -- et simplement, meme pour des displayId Blizzard d'origine comme Saurfang). Ce n'est
    -- PAS un probleme de donnees (CreatureDisplayInfoExtra + le .blp bake existent bien et
    -- s'affichent correctement via /morph, qui passe par le pipeline de rendu in-world).
    -- Le bug est localise dans le pipeline de rendu du widget Model lui-meme (binaire client).
    -- => SetCreature ne doit plus jamais etre utilise ici, meme en repli : il degraderait
    -- l'affichage au lieu de l'ameliorer. SetModel(path) est la seule methode fiable.
    --
    -- Consequence acceptee : les PNJ de race Character\ (bases sur un squelette joueur,
    -- ExtendedDisplayInfoID != 0 dans CreatureDisplayInfo.dbc, cf DisplayIdToExtraId.lua)
    -- s'afficheront nus (sans peau/cheveux/equipement), faute d'API Lua pour appliquer la
    -- texture bakee sur ce widget. Les PNJ de race Creature\ (autonomes, texture incluse
    -- dans le modele) s'affichent normalement sans probleme.
    local modelPath = self:GetModelPathFromDisplayId(displayId)

    if modelPath and model.SetModel then
        model:SetModel(modelPath)
    else
        print(string.format("|cffff0000[EncounterJournal]|r Aucun chemin de modele trouve pour l'entry %s (displayId %s) dans DisplayIdToModelPath.", tostring(creatureEntry), tostring(displayId)))
        return
    end

    if model.SetRotation then
        model:SetRotation(model.rotation or model.defaultRotation or MODELFRAME_DEFAULT_ROTATION or 0.61)
    end

    if model.SetSequence then
        pcall(model.SetSequence, model, 3)
    end
end

C_Creature = CreateFromMixins(C_CreatureMixin)

function EJ_GetCreatureDisplayId(creatureEntry)
    if C_Creature then
        return C_Creature:GetCreatureDisplayId(creatureEntry)
    end
end

function EJ_SetCreatureModel(model, creatureEntry)
    if C_Creature then
        C_Creature:SetCreatureModel(model, creatureEntry)
    end
end
