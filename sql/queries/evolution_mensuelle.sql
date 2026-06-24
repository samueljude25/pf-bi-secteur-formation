-- =============================================================================
-- REQUÊTE : Évolution mensuelle des indicateurs clés
-- Description : Suivi de la progression mois par mois des KPIs principaux
--               Inclut les comparaisons MoM (Month-over-Month) et YoY
-- Auteur : Portfolio BI - Samuel Jude Sendzi
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Requête 1 : Évolution mensuelle complète avec calculs MoM
-- -----------------------------------------------------------------------------
WITH stats_mensuelles AS (
    SELECT
        YEAR(i.date_inscription)                        AS annee,
        MONTH(i.date_inscription)                       AS mois_num,
        DATE_FORMAT(i.date_inscription, '%Y-%m')        AS annee_mois,
        DATE_FORMAT(i.date_inscription, '%b %Y')        AS mois_label,

        -- Volume
        COUNT(i.inscription_id)                         AS nb_inscriptions,
        COUNT(DISTINCT i.apprenant_id)                  AS nb_apprenants_uniques,

        -- Revenus
        SUM(i.montant_paye_xaf)                         AS revenus_xaf,
        ROUND(AVG(i.montant_paye_xaf), 0)               AS revenu_moyen_xaf,

        -- Complétion
        SUM(CASE WHEN i.statut = 'Terminé'   THEN 1 ELSE 0 END) AS nb_termines,
        SUM(CASE WHEN i.statut = 'Abandonné' THEN 1 ELSE 0 END) AS nb_abandonnes,
        SUM(CASE WHEN i.statut = 'En cours'  THEN 1 ELSE 0 END) AS nb_en_cours,

        ROUND(
            100.0 * SUM(CASE WHEN i.statut = 'Terminé' THEN 1 ELSE 0 END)
                  / NULLIF(COUNT(i.inscription_id), 0), 1
        )                                               AS taux_completion_pct,

        -- Satisfaction (évaluations du mois)
        ROUND(AVG(e.note_globale), 2)                   AS satisfaction_moy,
        ROUND(AVG(e.nps_score), 1)                      AS nps_moyen,
        COUNT(e.evaluation_id)                          AS nb_evaluations

    FROM inscriptions i
        LEFT JOIN evaluations e
            ON i.inscription_id = e.inscription_id
            AND DATE_FORMAT(e.date_evaluation, '%Y-%m') = DATE_FORMAT(i.date_inscription, '%Y-%m')

    GROUP BY
        YEAR(i.date_inscription),
        MONTH(i.date_inscription),
        DATE_FORMAT(i.date_inscription, '%Y-%m'),
        DATE_FORMAT(i.date_inscription, '%b %Y')
),

-- Ajout des calculs de croissance MoM (Month-over-Month)
stats_avec_croissance AS (
    SELECT
        *,
        -- Revenus mois précédent (LAG)
        LAG(revenus_xaf, 1) OVER (ORDER BY annee_mois)         AS revenus_mois_precedent_xaf,
        LAG(nb_inscriptions, 1) OVER (ORDER BY annee_mois)     AS inscriptions_mois_precedent,

        -- Revenus cumulés
        SUM(revenus_xaf) OVER (
            PARTITION BY annee
            ORDER BY annee_mois
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                                                       AS revenus_cumules_annee_xaf,

        -- Inscriptions cumulées
        SUM(nb_inscriptions) OVER (
            PARTITION BY annee
            ORDER BY annee_mois
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                                                       AS inscriptions_cumulees_annee

    FROM stats_mensuelles
)

SELECT
    annee,
    mois_label,
    annee_mois,

    -- Indicateurs du mois
    nb_inscriptions,
    nb_apprenants_uniques,
    revenus_xaf,
    revenu_moyen_xaf,
    nb_termines,
    nb_abandonnes,
    CONCAT(taux_completion_pct, ' %')       AS taux_completion,
    satisfaction_moy,
    nps_moyen,
    nb_evaluations,

    -- Croissance MoM inscriptions
    inscriptions_mois_precedent,
    ROUND(
        100.0 * (nb_inscriptions - inscriptions_mois_precedent)
              / NULLIF(inscriptions_mois_precedent, 0),
        1
    )                                       AS croissance_inscriptions_mom_pct,

    -- Croissance MoM revenus
    revenus_mois_precedent_xaf,
    ROUND(
        100.0 * (revenus_xaf - revenus_mois_precedent_xaf)
              / NULLIF(revenus_mois_precedent_xaf, 0),
        1
    )                                       AS croissance_revenus_mom_pct,

    -- Cumulés annuels
    revenus_cumules_annee_xaf,
    inscriptions_cumulees_annee

FROM stats_avec_croissance

ORDER BY
    annee_mois ASC;


-- -----------------------------------------------------------------------------
-- Requête 2 : Comparaison annuelle 2024 vs 2025
-- -----------------------------------------------------------------------------
SELECT
    mois_num,
    MONTHNAME(STR_TO_DATE(CONCAT('2024-', mois_num, '-01'), '%Y-%m-%d')) AS mois,

    -- 2024
    SUM(CASE WHEN annee = 2024 THEN nb_inscriptions ELSE 0 END)  AS inscriptions_2024,
    SUM(CASE WHEN annee = 2024 THEN revenus_xaf ELSE 0 END)      AS revenus_2024_xaf,
    AVG(CASE WHEN annee = 2024 THEN taux_completion_pct END)     AS completion_2024_pct,

    -- 2025
    SUM(CASE WHEN annee = 2025 THEN nb_inscriptions ELSE 0 END)  AS inscriptions_2025,
    SUM(CASE WHEN annee = 2025 THEN revenus_xaf ELSE 0 END)      AS revenus_2025_xaf,
    AVG(CASE WHEN annee = 2025 THEN taux_completion_pct END)     AS completion_2025_pct,

    -- Croissance YoY
    ROUND(
        100.0 * (
            SUM(CASE WHEN annee = 2025 THEN nb_inscriptions ELSE 0 END) -
            SUM(CASE WHEN annee = 2024 THEN nb_inscriptions ELSE 0 END)
        ) / NULLIF(SUM(CASE WHEN annee = 2024 THEN nb_inscriptions ELSE 0 END), 0),
        1
    )                                                             AS croissance_inscriptions_yoy_pct,

    ROUND(
        100.0 * (
            SUM(CASE WHEN annee = 2025 THEN revenus_xaf ELSE 0 END) -
            SUM(CASE WHEN annee = 2024 THEN revenus_xaf ELSE 0 END)
        ) / NULLIF(SUM(CASE WHEN annee = 2024 THEN revenus_xaf ELSE 0 END), 0),
        1
    )                                                             AS croissance_revenus_yoy_pct

FROM (
    SELECT
        YEAR(date_inscription)                          AS annee,
        MONTH(date_inscription)                         AS mois_num,
        COUNT(inscription_id)                           AS nb_inscriptions,
        SUM(montant_paye_xaf)                           AS revenus_xaf,
        ROUND(
            100.0 * SUM(CASE WHEN statut = 'Terminé' THEN 1 ELSE 0 END)
                  / NULLIF(COUNT(inscription_id), 0), 1
        )                                               AS taux_completion_pct
    FROM inscriptions
    WHERE YEAR(date_inscription) IN (2024, 2025)
    GROUP BY
        YEAR(date_inscription),
        MONTH(date_inscription)
) sub

GROUP BY mois_num

ORDER BY mois_num ASC;


-- -----------------------------------------------------------------------------
-- Requête 3 : Analyse de la saisonnalité (inscriptions par trimestre)
-- -----------------------------------------------------------------------------
SELECT
    YEAR(date_inscription)                                          AS annee,
    QUARTER(date_inscription)                                       AS trimestre,
    CONCAT('T', QUARTER(date_inscription), ' ', YEAR(date_inscription)) AS periode,

    COUNT(inscription_id)                                           AS nb_inscriptions,
    SUM(montant_paye_xaf)                                           AS revenus_xaf,
    ROUND(
        100.0 * SUM(CASE WHEN statut = 'Terminé' THEN 1 ELSE 0 END)
              / NULLIF(COUNT(inscription_id), 0), 1
    )                                                               AS taux_completion_pct,

    -- Part du trimestre dans l'année
    ROUND(
        100.0 * COUNT(inscription_id) / SUM(COUNT(inscription_id)) OVER (PARTITION BY YEAR(date_inscription)),
        1
    )                                                               AS pct_inscriptions_annee

FROM inscriptions

GROUP BY
    YEAR(date_inscription),
    QUARTER(date_inscription)

ORDER BY
    annee ASC,
    trimestre ASC;
