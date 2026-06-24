-- =============================================================================
-- VUE : v_revenus_par_module
-- Description : Analyse des revenus ventilés par module, formation et catégorie
--               Calcul du revenu proportionnel par module (basé sur la durée)
-- Auteur : Portfolio BI - Samuel Jude Sendzi
-- =============================================================================

-- Vue principale : revenus par formation avec détail des modules
CREATE OR REPLACE VIEW v_revenus_par_module AS
WITH
-- CTE : calcul de la durée totale par formation (pour pondération)
duree_par_formation AS (
    SELECT
        formation_id,
        SUM(duree_heures) AS duree_totale_heures
    FROM modules
    GROUP BY formation_id
),

-- CTE : revenus réels par formation
revenus_formation AS (
    SELECT
        formation_id,
        COUNT(inscription_id)       AS nb_inscriptions,
        SUM(montant_paye_xaf)       AS revenus_totaux_xaf,
        AVG(montant_paye_xaf)       AS revenu_moyen_xaf,
        SUM(CASE WHEN statut = 'Terminé' THEN montant_paye_xaf ELSE 0 END) AS revenus_termines_xaf
    FROM inscriptions
    GROUP BY formation_id
)

SELECT
    -- Identifiants
    m.module_id,
    m.titre                                                         AS module,
    m.ordre                                                         AS ordre_module,
    m.duree_heures                                                  AS duree_module_heures,
    m.type_contenu,
    m.obligatoire,

    -- Formation parente
    f.formation_id,
    f.titre                                                         AS formation,
    f.categorie,
    f.niveau,
    f.prix_xaf                                                      AS prix_formation_xaf,

    -- Durée totale de la formation
    dpf.duree_totale_heures,

    -- Part du module dans la formation (en %)
    ROUND(
        100.0 * m.duree_heures / NULLIF(dpf.duree_totale_heures, 0),
        1
    )                                                               AS poids_module_pct,

    -- Revenus associés à cette formation
    COALESCE(rf.nb_inscriptions, 0)                                 AS nb_inscriptions,
    COALESCE(rf.revenus_totaux_xaf, 0)                              AS revenus_formation_xaf,

    -- Revenus attribués au module (prorata de sa durée)
    ROUND(
        COALESCE(rf.revenus_totaux_xaf, 0)
        * m.duree_heures / NULLIF(dpf.duree_totale_heures, 0),
        0
    )                                                               AS revenus_module_xaf,

    -- Revenu moyen par inscription pour ce module
    ROUND(
        COALESCE(rf.revenu_moyen_xaf, 0)
        * m.duree_heures / NULLIF(dpf.duree_totale_heures, 0),
        0
    )                                                               AS revenu_moyen_module_xaf,

    -- Revenus des formations terminées (revenus consolidés)
    ROUND(
        COALESCE(rf.revenus_termines_xaf, 0)
        * m.duree_heures / NULLIF(dpf.duree_totale_heures, 0),
        0
    )                                                               AS revenus_termines_module_xaf,

    -- Revenu par heure de module (productivité pédagogique)
    ROUND(
        COALESCE(rf.revenus_totaux_xaf, 0)
        * m.duree_heures / NULLIF(dpf.duree_totale_heures, 0)
        / NULLIF(m.duree_heures, 0),
        0
    )                                                               AS revenu_par_heure_xaf

FROM modules m
    INNER JOIN formations           f   ON m.formation_id  = f.formation_id
    INNER JOIN duree_par_formation  dpf ON f.formation_id  = dpf.formation_id
    LEFT  JOIN revenus_formation    rf  ON f.formation_id  = rf.formation_id

ORDER BY
    revenus_module_xaf DESC,
    f.formation_id ASC,
    m.ordre ASC;


-- -----------------------------------------------------------------------------
-- Vue agrégée : revenus par catégorie de formation
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_revenus_par_categorie AS
SELECT
    f.categorie,

    COUNT(DISTINCT f.formation_id)                              AS nb_formations,
    COUNT(DISTINCT i.inscription_id)                            AS nb_inscriptions,
    SUM(i.montant_paye_xaf)                                     AS revenus_totaux_xaf,
    ROUND(AVG(i.montant_paye_xaf), 0)                           AS revenu_moyen_inscription_xaf,

    -- Revenus par statut
    SUM(CASE WHEN i.statut = 'Terminé'   THEN i.montant_paye_xaf ELSE 0 END) AS revenus_termines_xaf,
    SUM(CASE WHEN i.statut = 'En cours'  THEN i.montant_paye_xaf ELSE 0 END) AS revenus_en_cours_xaf,
    SUM(CASE WHEN i.statut = 'Abandonné' THEN i.montant_paye_xaf ELSE 0 END) AS revenus_abandonnes_xaf,

    -- Part des revenus par mode de paiement
    SUM(CASE WHEN i.mode_paiement = 'Mobile Money' THEN i.montant_paye_xaf ELSE 0 END) AS revenus_mobile_money_xaf,
    SUM(CASE WHEN i.mode_paiement = 'Virement'     THEN i.montant_paye_xaf ELSE 0 END) AS revenus_virement_xaf,
    SUM(CASE WHEN i.mode_paiement = 'Espèces'      THEN i.montant_paye_xaf ELSE 0 END) AS revenus_especes_xaf,

    -- Taux de complétion
    ROUND(
        100.0 * SUM(CASE WHEN i.statut = 'Terminé' THEN 1 ELSE 0 END)
              / NULLIF(COUNT(i.inscription_id), 0),
        1
    )                                                           AS taux_completion_pct

FROM formations f
    INNER JOIN inscriptions i ON f.formation_id = i.formation_id

GROUP BY
    f.categorie

ORDER BY
    revenus_totaux_xaf DESC;
