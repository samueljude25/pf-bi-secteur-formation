-- =============================================================================
-- REQUÊTE : KPIs Globaux de la Plateforme de Formation
-- Description : Tableau de bord KPI global - métriques clés d'activité
-- Auteur : Portfolio BI - Samuel Jude Sendzi
-- Usage : Exécuter en début de rapport ou sur la page d'accueil du dashboard
-- =============================================================================

-- -----------------------------------------------------------------------------
-- KPI 1 : Vue d'ensemble globale (toutes périodes confondues)
-- -----------------------------------------------------------------------------
SELECT
    -- Volume d'activité
    (SELECT COUNT(*) FROM apprenants WHERE actif = TRUE)                        AS total_apprenants,
    (SELECT COUNT(*) FROM formations  WHERE statut = 'Actif')                   AS total_formations_actives,
    (SELECT COUNT(*) FROM intervenants WHERE actif = TRUE)                      AS total_intervenants,
    (SELECT COUNT(*) FROM inscriptions)                                          AS total_inscriptions,
    (SELECT COUNT(*) FROM evaluations)                                           AS total_evaluations,

    -- Revenus
    (SELECT SUM(montant_paye_xaf) FROM inscriptions)                            AS revenus_totaux_xaf,
    (SELECT ROUND(AVG(montant_paye_xaf), 0) FROM inscriptions
     WHERE montant_paye_xaf > 0)                                                AS revenu_moyen_par_inscription_xaf,

    -- Taux de complétion global
    ROUND(
        100.0 * (SELECT COUNT(*) FROM inscriptions WHERE statut = 'Terminé')
              / NULLIF((SELECT COUNT(*) FROM inscriptions), 0),
        1
    )                                                                           AS taux_completion_global_pct,

    -- Taux d'abandon global
    ROUND(
        100.0 * (SELECT COUNT(*) FROM inscriptions WHERE statut = 'Abandonné')
              / NULLIF((SELECT COUNT(*) FROM inscriptions), 0),
        1
    )                                                                           AS taux_abandon_global_pct,

    -- Satisfaction globale
    (SELECT ROUND(AVG(note_globale), 2) FROM evaluations)                       AS note_satisfaction_globale,

    -- NPS Global
    ROUND(
        (
            100.0 * (SELECT COUNT(*) FROM evaluations WHERE nps_score >= 9)
                  / NULLIF((SELECT COUNT(*) FROM evaluations WHERE nps_score IS NOT NULL), 0)
        ) - (
            100.0 * (SELECT COUNT(*) FROM evaluations WHERE nps_score <= 6)
                  / NULLIF((SELECT COUNT(*) FROM evaluations WHERE nps_score IS NOT NULL), 0)
        ),
        1
    )                                                                           AS nps_global,

    -- Taux de recommandation global
    ROUND(
        100.0 * (SELECT COUNT(*) FROM evaluations WHERE recommande = 'Oui')
              / NULLIF((SELECT COUNT(*) FROM evaluations), 0),
        1
    )                                                                           AS taux_recommandation_pct;


-- -----------------------------------------------------------------------------
-- KPI 2 : Revenus et performance financière par mois (année en cours)
-- -----------------------------------------------------------------------------
SELECT
    DATE_FORMAT(i.date_inscription, '%Y-%m')    AS mois,
    COUNT(i.inscription_id)                     AS nb_nouvelles_inscriptions,
    SUM(i.montant_paye_xaf)                     AS revenus_mois_xaf,
    ROUND(AVG(i.montant_paye_xaf), 0)           AS revenu_moyen_xaf,
    SUM(CASE WHEN i.statut = 'Terminé' THEN 1 ELSE 0 END) AS formations_terminees,
    ROUND(
        100.0 * SUM(CASE WHEN i.statut = 'Terminé' THEN 1 ELSE 0 END)
              / NULLIF(COUNT(i.inscription_id), 0),
        1
    )                                           AS taux_completion_pct

FROM inscriptions i
WHERE YEAR(i.date_inscription) = 2024

GROUP BY
    DATE_FORMAT(i.date_inscription, '%Y-%m')

ORDER BY
    mois ASC;


-- -----------------------------------------------------------------------------
-- KPI 3 : Top 5 formations par revenus générés
-- -----------------------------------------------------------------------------
SELECT
    f.titre                                                     AS formation,
    f.categorie,
    f.prix_xaf                                                  AS prix_catalogue_xaf,
    COUNT(i.inscription_id)                                     AS nb_inscriptions,
    SUM(i.montant_paye_xaf)                                     AS revenus_totaux_xaf,
    ROUND(AVG(e.note_globale), 2)                               AS satisfaction_moy,
    ROUND(
        100.0 * SUM(CASE WHEN i.statut = 'Terminé' THEN 1 ELSE 0 END)
              / NULLIF(COUNT(i.inscription_id), 0),
        1
    )                                                           AS taux_completion_pct

FROM formations f
    INNER JOIN inscriptions i ON f.formation_id = i.formation_id
    LEFT  JOIN evaluations  e ON i.inscription_id = e.inscription_id

GROUP BY
    f.formation_id,
    f.titre,
    f.categorie,
    f.prix_xaf

ORDER BY
    revenus_totaux_xaf DESC

LIMIT 5;


-- -----------------------------------------------------------------------------
-- KPI 4 : Analyse de la satisfaction NPS par tranche de note
-- -----------------------------------------------------------------------------
SELECT
    CASE
        WHEN nps_score >= 9 THEN '😊 Promoteurs (9-10)'
        WHEN nps_score >= 7 THEN '😐 Passifs (7-8)'
        ELSE '😞 Détracteurs (0-6)'
    END                             AS segment_nps,

    COUNT(*)                        AS nb_evaluations,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM evaluations WHERE nps_score IS NOT NULL), 1) AS pct_total,
    ROUND(AVG(note_globale), 2)     AS note_globale_moy,
    SUM(CASE WHEN recommande = 'Oui' THEN 1 ELSE 0 END) AS nb_recommandent

FROM evaluations
WHERE nps_score IS NOT NULL

GROUP BY
    CASE
        WHEN nps_score >= 9 THEN '😊 Promoteurs (9-10)'
        WHEN nps_score >= 7 THEN '😐 Passifs (7-8)'
        ELSE '😞 Détracteurs (0-6)'
    END

ORDER BY
    MIN(nps_score) DESC;


-- -----------------------------------------------------------------------------
-- KPI 5 : Répartition des revenus par mode de paiement
-- -----------------------------------------------------------------------------
SELECT
    mode_paiement,
    COUNT(*)                        AS nb_transactions,
    SUM(montant_paye_xaf)           AS revenus_xaf,
    ROUND(100.0 * SUM(montant_paye_xaf) / (SELECT SUM(montant_paye_xaf) FROM inscriptions WHERE montant_paye_xaf > 0), 1) AS pct_revenus

FROM inscriptions
WHERE montant_paye_xaf > 0
  AND mode_paiement IS NOT NULL

GROUP BY mode_paiement

ORDER BY revenus_xaf DESC;
