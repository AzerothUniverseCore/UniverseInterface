--[[
    Rebirth_Locales.lua
    Localization strings for the Rebirth interface.

    Bilingual frFR/enUS : GetLocaleTable() picks the table matching the
    client's GetLocale() -- "enUS" selects the English table, and every
    other locale (frFR, deDE, ruRU, esES, ...) falls back to French,
    matching the frFR-universal-fallback convention used across the rest of
    this addon (never crash, never show a blank string).

    All stat/category/points/popup/notification/tutorial strings were removed
    (those features don't exist in Rebirth). The interface now shows 4
    Paragon-style category rows instead of stat categories :
      1. Pierre / Stone        -> OPTIONS_INFO (the 8 Pierre de Rebirth buffs)
      2. Pierre Preuve / Proof -> PROOF_INFO (the 25 teleport milestones)
      3. Héritage / Heirloom   -> item names/icons fetched live via GetItemInfo
      4. Récompenses / Rewards -> item names/icons fetched live via GetItemInfo
    CATEGORY_NAMES gives the display title shown on each category's line
    (in place of "Défense" / "Attaque" / "Magie" / "Autres" in Paragon).

    @module Rebirth_Locales
    @author iThorgrim (Paragon) / adapted for Rebirth
]]

-- ============================================================================
-- PIERRE PREUVE / PROOF : 25 teleport milestone entries, built
-- programmatically since their ids are not sequential (1-23, 25, 30 --
-- matches Constant.PROOF_TELEPORTS on the server / Preuve_du_Rebirth.lua's
-- gossip). One locale-aware builder instead of a single hardcoded frFR loop
-- so both languages get the same generated set of 25 entries.
-- ============================================================================
local PROOF_IDS = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 30 }

local function BuildProofInfo(locale)
    local info = {}
    for _, proofId in ipairs(PROOF_IDS) do
        if locale == "enUS" then
            info[proofId] = {
                name = "Proof of Rebirth " .. proofId,
                description = "Teleports you to the Proof of Rebirth #" .. proofId .. " area. Kill it to be rewarded!",
                icon = "Interface\\Icons\\INV_Misc_Rune_01",
            }
        else
            info[proofId] = {
                name = "Preuve du Rebirth " .. proofId,
                description = "Téléporte vers la zone de la Preuve du Rebirth n°" .. proofId .. ". Tuez-la pour être récompensé !",
                icon = "Interface\\Icons\\INV_Misc_Rune_01",
            }
        end
    end
    return info
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

        -- Last-resort name fallbacks (entry/category has neither a DB name
        -- nor a static locale entry -- should rarely trigger in practice).
        FALLBACK_OPTION_NAME = "Option %d",
        FALLBACK_PROOF_NAME = "Preuve %d",
        FALLBACK_ITEM_NAME = "Objet %d",
        FALLBACK_CATEGORY_NAME = "Catégorie %d",

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
        PROOF_INFO = BuildProofInfo("frFR"),
    },

    ["enUS"] = {
        -- ====================================================================
        -- EXPERIENCE BAR
        -- ====================================================================
        EXPERIENCE_TEXT = "Experience %d / %d",
        REBIRTH_EXPERIENCE_TEXT = "Rebirth %d / %d (%d%%)",
        SHOW_MAINMENU_XP_LABEL = "Show XP bar on main interface",
        SHOW_MAINMENU_XP_TOOLTIP = "If checked, displays the Rebirth experience bar above your character's XP bar at the bottom of the screen.",

        -- ====================================================================
        -- MAIN FRAME / CATEGORY ROWS (Paragon-style : title + icon row + arrow)
        -- ====================================================================
        MAIN_TITLE_TEXT = "Rebirth",

        -- Display name shown on each category's title line.
        CATEGORY_NAMES = {
            [1] = "Stone",
            [2] = "Proof",
            [3] = "Heirloom",
            [4] = "Rewards",
        },

        -- Generic tooltip/hint strings reused across all 4 categories.
        ENTRY_LOCKED_TOOLTIP = "Unlocked at Rebirth level %d",
        ENTRY_UNLOCKED_HINT = "Click to activate",
        ENTRY_COOLDOWN_HINT = "Cooldown: 60 seconds",
        ENTRY_CLAIMED_HINT = "Already claimed",
        ENTRY_CLAIM_HINT = "Click to receive the item in your bag",
        -- Rewards only : claim counter + explanation, shown in the tooltip
        -- so the number of remaining claims is visible (the item is
        -- limited, unlike Heirloom which stays freely re-claimable).
        ENTRY_REWARD_CLAIM_COUNT = "Claims: %d/%d",
        ENTRY_REWARD_CLAIM_COUNT_MAXED = "Claims: %d/%d (limit reached)",
        ENTRY_REWARD_CLAIM_EXPLANATION = "This reward can be claimed multiple times, up to the limit shown above.",
        ENTRY_NEXT_PAGE_HINT = "Next page",

        -- Last-resort name fallbacks (entry/category has neither a DB name
        -- nor a static locale entry -- should rarely trigger in practice).
        FALLBACK_OPTION_NAME = "Option %d",
        FALLBACK_PROOF_NAME = "Proof %d",
        FALLBACK_ITEM_NAME = "Item %d",
        FALLBACK_CATEGORY_NAME = "Category %d",

        -- ====================================================================
        -- HELP TOOLTIP ("i" button below the close button)
        -- ====================================================================
        HELP_TOOLTIP_TITLE = "Help",
        HELP_TOOLTIP_TEXT = "View the interactive tutorial.",

        -- ====================================================================
        -- INTERACTIVE TUTORIAL (ported from Paragon_Tutorial.lua, content
        -- rewritten for the 4-category Rebirth interface)
        -- ====================================================================
        TUTORIAL_TITLE = "Help - Rebirth Interface",
        TUTORIAL_BUTTON_NEXT = "Next",
        TUTORIAL_BUTTON_PREVIOUS = "Previous",
        TUTORIAL_BUTTON_CLOSE = "Close",
        TUTORIAL_BUTTON_FINISH = "Finish",
        TUTORIAL_STEP_COUNTER = "Step %d/%d",
        TUTORIAL_HELP_BUTTON = "Help button|n- Instructions for the Rebirth system",
        TUTORIAL_LEVEL = "Rebirth Level|n- Shows your current Rebirth level\n(Max Lv.30)",
        TUTORIAL_XP_BAR = "Rebirth Experience Bar|n- Shows your progress toward the next level.|n- Hover to see the details (current / required XP).",
        TUTORIAL_CATEGORIES = "- Stone (Character state improvements)|n- Proof (Titles/Achievements)|n- Heirloom (Heirloom weapon/armor)|n- Rewards (Life Infusion/Life Explosion/Mount).",
        TUTORIAL_ICONS = "- Stone: Unlocks based on your Rebirth level|n- Proof: Teleports you to the zones|n- Rewards: Unlocks based on your Rebirth|nlevel.",
        TUTORIAL_PAGINATION = "- Usage: The small arrow lets you browse\nthrough the following pages.",

        -- ====================================================================
        -- CHARACTERFRAME TAB
        -- ====================================================================
        REBIRTH_TAB_TOOLTIP = "Rebirth",

        -- Golden notification badge on the CharacterFrame Rebirth tab :
        -- shown after a level-up that just unlocked a new Stone / Proof /
        -- Rewards entry (see RebirthCharacterTab_Create /
        -- RebirthCharacterTab_UpdateBadge in Rebirth_Interface.lua).
        REBIRTH_NOTIFICATION_TITLE = "New reward!",
        REBIRTH_NOTIFICATION_MESSAGE = "A new Improvement, Proof of Rebirth, or Heirloom/Reward is available!",
        REBIRTH_NOTIFICATION_DISMISS = "Click to dismiss this notification.",
        REBIRTH_TAB_DESC = "View your Rebirth level and see the unlocked options for the Rebirth Stone.",

        -- ====================================================================
        -- CATEGORY 1 : STONE (id -> name / description / icon)
        -- Same ids as Constant.OPTIONS in rebirth_constant.lua (server) ;
        -- names match the server's name_en column set for these entries.
        -- ====================================================================
        OPTIONS_INFO = {
            [1] = {
                name = "State Improvement",
                description = "Grants all the state improvements matching your Rebirth level (Growing Rebirth, Fierce, Persistent, and Sturdy).",
                icon = "Interface\\Icons\\Spell_Holy_DivineIllumination",
            },
            [2] = {
                name = "Heal",
                description = "Fully restores your health and resource (mana, energy, rage...).",
                icon = "Interface\\Icons\\Spell_Holy_Heal",
            },
            [3] = {
                name = "Remove Resurrection Sickness",
                description = "Removes the Resurrection Sickness effect.",
                icon = "Interface\\Icons\\Spell_Nature_Reincarnation",
            },
            [7] = {
                name = "Repair Equipment",
                description = "Fully repairs all your equipment.",
                icon = "Interface\\Icons\\Trade_BlackSmithing",
            },
            [9] = {
                name = "Reset Talents",
                description = "Resets your talent points.",
                icon = "Interface\\Icons\\INV_Misc_Book_11",
            },
            [13] = {
                name = "Reset Spell Cooldowns",
                description = "Resets all your spell cooldowns.",
                icon = "Interface\\Icons\\Spell_Nature_TimeStop",
            },
            [14] = {
                name = "Remove Deserter",
                description = "Removes the Deserter effect.",
                icon = "Interface\\Icons\\Ability_Vanish",
            },
            [20] = {
                name = "Reset Instances",
                description = "Resets your instance lockouts.",
                icon = "Interface\\Icons\\INV_Misc_Map_01",
            },
        },

        -- ====================================================================
        -- CATEGORY 2 : PROOF (id -> name / description / icon)
        -- Built programmatically above (PROOF_INFO), 25 entries.
        -- ====================================================================
        PROOF_INFO = BuildProofInfo("enUS"),
    },
}

-- ============================================================================
-- LOCALE DETECTION
-- ============================================================================
-- Client round-trip pattern used across every other custom UI in this
-- project : GetLocale() == "enUS" selects English, anything else
-- (frFR/deDE/ruRU/esES/...) falls back to French, so the panel never shows
-- a blank string for an unhandled locale.
local UI_LOCALE = (GetLocale and GetLocale() == "enUS") and "enUS" or "frFR"

--- Retrieves the localization table matching the client's game locale
--- (enUS, else frFR fallback).
--- @return table The active locale's strings table
--- @usage local L = GetLocaleTable(); print(L.EXPERIENCE_TEXT)
function GetLocaleTable()
    return Locales[UI_LOCALE] or Locales["frFR"]
end
