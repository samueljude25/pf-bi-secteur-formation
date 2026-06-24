-- =============================================================================
-- VUE : v_satisfaction_par_formation
-- Description : Analyse de la satisfaction apprenants par formation
--               Inclut les notes moyennes, le NPS et les recommandations
-- Auteur : Portfolio BI - Samuel Jude Sendzi
-- =============================================================================

CREATE OR REPLACE VIEW v_satisfaction_par_formation AS
SELECT
    -- Identifiants de la formation
    f.formation_id,
    f.titre                                                     AS formation,
    f.categorie,
    f.niveau,

    -- Volume d'évaluations
    COUNT(e.evaluation_id)                                      AS nb_evaluations,
    COUNT(i.inscription_id)                                     AS nb_inscriptions,

    -- Taux de réponse aux évaluations
    ROUND(
        100.0 * COUNT(e.evaluation_id)
              / NULLIF(COUNT(i.inscription_id), 0),
        1
    )                                                           AS taux_reponse_evaluation_pct,

    -- Notes moyennes par dimension (arrondies à 1 décimale)
    ROUND(AVG(e.note_globale),              1)                  AS note_globale_moy,
    ROUND(AVG(e.note_contenu),              1)                  AS note_contenu_moy,
    ROUND(AVG(e.note_intervenant),          1)                  AS note_intervenant_moy,
    ROUND(AVG(e.note_plateforme),           1)                  AS note_plateforme_moy,
    ROUND(AVG(e.note_rapport_qualite_prix), 1)                  AS note_qualite_prix_moy,

    -- Distribution des notes globales
    SUM(CASE WHEN e.note_globale = 5 THEN 1 ELSE 0 END)        AS nb_note_5,
    SUM(CASE WHEN e.note_globale = 4 THEN 1 ELSE 0 END)        AS nb_note_4,
    SUM(CASE WHEN e.note_globale = 3 THEN 1 ELSE 0 END)        AS nb_note_3,
    SUM(CASE WHEN e.note_globale <= 2 THEN 1 ELSE 0 END)       AS nb_note_1_2,

    -- NPS (Net Promoter Score)
    -- Promoteurs : NPS >= 9, Passifs : NPS 7-8, Détracteurs : NPS <= 6
    SUM(CASE WHEN e.nps_score >= 9 THEN 1 ELSE 0 END)          AS nb_promoteurs,
    SUM(CASE WHEN e.nps_score BETWEEN 7 AND 8 THEN 1 ELSE 0 END) AS nb_passifs,
    SUM(CASE WHEN e.nps_score <= 6 AND e.nps_score IS NOT NULL THEN 1 ELSE 0 END) AS nb_detracteurs,

    -- Calcul du NPS = % Promoteurs - % Détracteurs (sur 100)
    ROUND(
        (
            100.0 * SUM(CASE WHEN e.nps_score >= 9 THEN 1 ELSE 0 END)
                  / NULLIF(COUNT(e.evaluation_id), 0)
        ) - (
            100.0 * SUM(CASE WHEN e.nps_score <= 6 AND e.nps_score IS NOT NULL THEN 1 ELSE 0 END)
                  / NULLIF(COUNT(e.evaluation_id), 0)
        ),
        1
    )                                                           AS nps_score,

    -- Score NPS moyen brut
    ROUND(AVG(e.nps_score), 1)                                  AS nps_moyen,

    -- Taux de recommandation
    ROUND(
        100.0 * SUM(CASE WHEN e.recommande = 'Oui' THEN 1 ELSE 0 END)
              / NULLIF(COUNT(e.evaluation_id), 0),
        1
    )                                                           AS taux_recommandation_pct

FROM formations f
    LEFT JOIN inscriptions  i ON f.formation_id = i.formation_id
    LEFT JOIN evaluations   e ON i.inscription_id = e.inscription_id

GROUP BY
    f.formation_id,
    f.titre,
    f.categorie,
    f.niveau

HAVING
    COUNT(e.evaluation_id) > 0

ORDER BY
    note_globale_moy DESC,
    nb_evaluations DESC;


-- -----------------------------------------------------------------------------
-- Vue complémentaire : satisfaction par catégorie de formation
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_satisfaction_par_categorie AS
SELECT
    f.categorie,

    COUNT(DISTINCT f.formation_id)          AS nb_formations,
    COUNT(e.evaluation_id)                  AS nb_evaluations,

    ROUND(AVG(e.note_globale),   1)         AS note_globale_moy,
    ROUND(AVG(e.note_contenu),   1)         AS note_contenu_moy,
    ROUND(AVG(e.note_intervenant), 1)       AS note_intervenant_moy,
    ROUND(AVG(e.nps_score),      1)         AS nps_moyen,

    ROUND(
        100.0 * SUM(CASE WHEN e.recommande = 'Oui' THEN 1 ELSE 0 END)
              / NULLIF(COUNT(e.evaluation_id), 0),
        1
    )                                       AS taux_recommandation_pct

FROM formations f
    INNER JOIN inscriptions i ON f.formation_id = i.formation_id
    INNER JOIN evaluations  e ON i.inscription_id = e.inscription_id

GROUP BY
    f.categorie

ORDER BY
    note_globale_moy DESC;
