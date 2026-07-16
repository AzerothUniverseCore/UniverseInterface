--[[
    Rebirth_Locales.lua
    Localization strings for the Rebirth interface.

    Adapted from Paragon_Locales.lua : this project's whole custom UI is
    hardcoded French only (no other locale files exist anywhere else in this
    addon), so — unlike Paragon_Locales.lua's 9-language table — only frFR is
    provided here. GetLocaleTable() always returns it regardless of the
    client's actual game locale, matching every other custom UI in this
    project.

    All stat/category/points/popup/notification/tutorial strings were removed
    (those features don't exist in Rebirth). The interface now shows 4
    Paragon-style category rows instead of stat categories :
      1. Pierre           -> OPTIONS_INFO (the 8 Pierre de Rebirth buffs)
      2. Pierre Preuve     -> PROOF_INFO (the 25 teleport milestones)
      3. Héritage          -> item names/icons fetched live via GetItemInfo
      4. Récompenses       -> item names/icons fetched live via GetItemInfo
    CATEGORY_NAMES gives the display title shown on each category's line
    (in place of "Défense" / "Attaque" / "Magie" / "Autres" in Paragon).

    @module Rebirth_Locales
    @author iThorgrim (Paragon) / adapted for Rebirth
]]

-- ============================================================================
-- PIERRE PREUVE : 25 teleport milestone entries, built programmatically since
-- their ids are not sequential (1-23, 25, 30 — matches
-- Constant.PROOF_TELEPORTS on the server / Preuve_du_Rebirth.lua's gossip).
-- ============================================================================
local PROOF_IDS = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 30 }

local PROOF_INFO = {}
for _, proofId in ipairs(PROOF_IDS) do
    PROOF_INFO[proofId] = {
        name = "Preuve du Rebirth " .. proofId,
        description = "Téléporte vers la zone de la Preuve du Rebirth n°" .. proofId .. ". Tuez-la pour être récompensé !",
        icon = "Interface\\Icons\\INV_Misc_Rune_01",
    }
end

local Locales = {
    ["frFR"] = {
        -- ====================================================================
        -- EXPERIENCE BAR
        -- ====================================================================
        EXPERIENCE_TEXT = "Expérience %d / %d",
        REBIRTH_EXPERIENCE_TEXT = "Rebirth %d / %d (%d%%)",
        SHOW_MAINMENU_XP_LABEL = "Afficher la barre XP sur l'interface principale",
        SHOW_MAINMENU_XP_TOOLTIP = "Si coché, affiche la barre d'expérience Rebirth au-dessus de la barre XP de votre personnage en bas de l'écran.",

        -- ====================================================================
        -- MAIN FRAME / CATEGORY ROWS (Paragon-style : title + icon row + arrow)
        -- ====================================================================
        MAIN_TITLE_TEXT = "Rebirth",

        -- Display name shown on each category's title line, replacing
        -- Paragon's "Défense" / "Attaque" / "Magie" / "Autres".
        CATEGORY_NAMES = {
            [1] = "Pierre",
            [2] = "Pierre Preuve",
            [3] = "Héritage",
            [4] = "Récompenses",
        },

        -- Generic tooltip/hint strings reused across all 4 categories.
        ENTRY_LOCKED_TOOLTIP = "Débloqué au niveau de Rebirth %d",
        ENTRY_UNLOCKED_HINT = "Cliquez pour activer",
        ENTRY_COOLDOWN_HINT = "Temps de recharge : 60 secondes",
        ENTRY_CLAIMED_HINT = "Déjà réclamé",
        ENTRY_CLAIM_HINT = "Cliquez pour recevoir l'objet dans votre sac",
        -- Récompenses uniquement : compteur de réclamation + explication,
        -- affichés dans le tooltip pour que le nombre de réclamations
        -- restantes soit visible (l'objet est limité, contrairement à
        -- Héritage qui reste librement re-réclamable).
        ENTRY_REWARD_CLAIM_COUNT = "Réclamations : %d/%d",
        ENTRY_REWARD_CLAIM_COUNT_MAXED = "Réclamations : %d/%d (limite atteinte)",
        ENTRY_REWARD_CLAIM_EXPLANATION = "Cette récompense peut être réclamée plusieurs fois, jusqu'à la limite indiquée ci-dessus.",
        ENTRY_NEXT_PAGE_HINT = "Page suivante",

        -- ====================================================================
        -- HELP TOOLTIP ("i" button below the close button)
        -- ====================================================================
        HELP_TOOLTIP_TITLE = "Aide",
        HELP_TOOLTIP_TEXT = "Voir le tutoriel interactif.",

        -- ====================================================================
        -- INTERACTIVE TUTORIAL (ported from Paragon_Tutorial.lua, content
        -- rewritten for the 4-category Rebirth interface)
        -- ====================================================================
        TUTORIAL_TITLE = "Aide - Interface Rebirth",
        TUTORIAL_BUTTON_NEXT = "Suivant",
        TUTORIAL_BUTTON_PREVIOUS = "Précédent",
        TUTORIAL_BUTTON_CLOSE = "Fermer",
        TUTORIAL_BUTTON_FINISH = "Terminer",
        TUTORIAL_STEP_COUNTER = "Étape %d/%d",
        TUTORIAL_HELP_BUTTON = "Bouton d'aide|n- Instruction du système de Rebirth",
        TUTORIAL_LEVEL = "Niveau de Rebirth|n- Affiche votre niveau actuel de votre niveau de Rebirth\n(Nv.30 Max)",
        TUTORIAL_XP_BAR = "Barre d'expérience Rebirth|n- Montre votre progression vers le niveau suivant.|n- Survolez pour voir le détail (XP actuelle / requise).",
        TUTORIAL_CATEGORIES = "- Pierre (Amélioration d'état du personnage)|n- Pierre Preuve (Titre/Hauts faits)|n- Héritage (Arme/Armure Héritage)|n- Récompenses (Infusion de vie/Explosion de vie/Monture).",
        TUTORIAL_ICONS = "- Pierre : Se débloque en fonction du niveau de Rebirth|n- Pierre Preuve : Vous téléportes dans les zones|n- Récompenses : Se débloque en fonction du niveau|nde Rebirth.",
        TUTORIAL_PAGINATION = "- Utilisation : La petite flèche permet de parcourir\nles pages suivantes.",

        -- ====================================================================
        -- CHARACTERFRAME TAB
        -- ====================================================================
        REBIRTH_TAB_TOOLTIP = "Rebirth",

        -- Golden notification badge on the CharacterFrame Rebirth tab :
        -- shown after a level-up that just unlocked a new Pierre / Pierre
        -- Preuve / Recompenses entry (see RebirthCharacterTab_Create /
        -- RebirthCharacterTab_UpdateBadge in Rebirth_Interface.lua).
        REBIRTH_NOTIFICATION_TITLE = "Nouvelle récompense !",
        REBIRTH_NOTIFICATION_MESSAGE = "Une nouvelle Amélioration, Preuve du Rebirth ou Héritage/Récompense est disponible !",
        REBIRTH_NOTIFICATION_DISMISS = "Cliquer pour masquer cette notification.",
        REBIRTH_TAB_DESC = "Consultation :  Niveau de Rebirth et voir les options débloquées de la Pierre de Rebirth.",

        -- ====================================================================
        -- CATEGORY 1 : PIERRE (id -> name / description / icon)
        -- Same ids as Constant.OPTIONS in rebirth_constant.lua (server), same
        -- wording as the legacy Pierre_Rebirth.lua gossip menu entries.
        -- ====================================================================
        OPTIONS_INFO = {
            [1] = {
                name = "Amélioration d'état",
                description = "Bénéficiez de toutes les améliorations d'état correspondant à votre niveau de Rebirth (Renaissance Croissante, Féroce, Persistante et Robuste).",
                icon = "Interface\\Icons\\Spell_Holy_DivineIllumination",
            },
            [2] = {
                name = "Soin",
                description = "Restaure entièrement votre santé et votre ressource (mana, énergie, rage...).",
                icon = "Interface\\Icons\\Spell_Holy_Heal",
            },
            [3] = {
                name = "Retirer le mal de résurrection",
                description = "Retire l'effet de Mal de résurrection.",
                icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
            },
            [7] = {
                name = "Réparer l'équipement",
                description = "Répare intégralement tout votre équipement.",
                icon = "Interface\\Icons\\Trade_BlackSmithing",
            },
            [9] = {
                name = "Réinitialiser les talents",
                description = "Réinitialise vos points de talents.",
                icon = "Interface\\Icons\\INV_Misc_Book_11",
            },
            [13] = {
                name = "Réinitialiser le temps des sorts",
                description = "Réinitialise tous les temps de recharge de vos sorts.",
                icon = "Interface\\Icons\\Spell_Nature_TimeStop",
            },
            [14] = {
                name = "Retirer le déserteur",
                description = "Retire l'effet Déserteur.",
                icon = "Interface\\Icons\\Ability_Vanish",
            },
            [20] = {
                name = "Réinitialiser les instances",
                description = "Réinitialise vos verrouillages d'instances.",
                icon = "Interface\\Icons\\INV_Misc_Map_01",
            },
        },

        -- ====================================================================
        -- CATEGORY 2 : PIERRE PREUVE (id -> name / description / icon)
        -- Built programmatically above (PROOF_INFO), 25 entries.
        -- ====================================================================
        PROOF_INFO = PROOF_INFO,
    }
}

--- Retrieves the localization table. Always frFR, matching the rest of this
--- project's custom UI (hardcoded French, no other language support).
--- @return table The frFR strings table
--- @usage local L = GetLocaleTable(); print(L.EXPERIENCE_TEXT)
function GetLocaleTable()
    return Locales["frFR"]
end
