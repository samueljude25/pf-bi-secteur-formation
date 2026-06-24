-- =============================================================================
-- REQUÊTE : Top formations et classements
-- Description : Analyse des meilleures formations selon différents critères :
--               popularité, revenus, satisfaction, taux de complétion
-- Auteur : Portfolio BI - Samuel Jude Sendzi
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Requête 1 : Top 10 formations toutes catégories (score composite)
-- Score composite = 40% satisfaction + 30% taux complétion + 30% volume inscriptions
-- -----------------------------------------------------------------------------
WITH stats_formations AS (
    SELECT
        f.formation_id,
        f.titre,
        f.categorie,
        f.niveau,
        f.prix_xaf,
        CONCAT(iv.prenom, ' ', iv.nom)                  AS intervenant,

        COUNT(i.inscription_id)                         AS nb_inscriptions,
        SUM(i.montant_paye_xaf)                         AS revenus_xaf,
        ROUND(AVG(e.note_globale), 2)                   AS note_satisfaction,

        ROUND(
            100.0 * SUM(CASE WHEN i.statut = 'Terminé' THEN 1 ELSE 0 END)
                  / NULLIF(COUNT(i.inscription_id), 0),
            1
        )                                               AS taux_completion_pct,

        COUNT(e.evaluation_id)                          AS nb_evaluations

    FROM formations f
        INNER JOIN intervenants iv ON f.intervenant_principal_id = iv.intervenant_id
        INNER JOIN inscriptions  i ON f.formation_id = i.formation_id
        LEFT  JOIN evaluations   e ON i.inscription_id = e.inscription_id

    GROUP BY
        f.formation_id, f.titre, f.categorie, f.niveau, f.prix_xaf,
        iv.prenom, iv.nom
),

-- Normalisation des scores pour le classement composite
stats_normalisees AS (
    SELECT
        *,
        -- Normalisation de chaque métrique entre 0 et 1
        (note_satisfaction - MIN(note_satisfaction) OVER()) /
        NULLIF(MAX(note_satisfaction) OVER() - MIN(note_satisfaction) OVER(), 0)    AS score_satisfaction_norm,

        (taux_completion_pct - MIN(taux_completion_pct) OVER()) /
        NULLIF(MAX(taux_completion_pct) OVER() - MIN(taux_completion_pct) OVER(), 0) AS score_completion_norm,

        (nb_inscriptions - MIN(nb_inscriptions) OVER()) /
        NULLIF(MAX(nb_inscriptions) OVER() - MIN(nb_inscriptions) OVER(), 0)        AS score_volume_norm

    FROM stats_formations
)

SELECT
    ROW_NUMBER() OVER (ORDER BY
        0.4 * score_satisfaction_norm +
        0.3 * score_completion_norm +
        0.3 * score_volume_norm DESC
    )                                                               AS classement,

    titre                                                           AS formation,
    categorie,
    niveau,
    intervenant,
    prix_xaf,
    nb_inscriptions,
    revenus_xaf,
    CONCAT(note_satisfaction, ' / 5')                               AS satisfaction,
    CONCAT(taux_completion_pct, ' %')                               AS taux_completion,

    ROUND(
        0.4 * score_satisfaction_norm +
        0.3 * score_completion_norm +
        0.3 * score_volume_norm,
        3
    )                                                               AS score_composite

FROM stats_normalisees

ORDER BY score_composite DESC

LIMIT 10;


-- -----------------------------------------------------------------------------
-- Requête 2 : Top formations par catégorie (meilleure formation par catégorie)
-- -----------------------------------------------------------------------------
WITH rang_par_categorie AS (
    SELECT
        f.formation_id,
        f.titre,
        f.categorie,
        f.prix_xaf,
        COUNT(i.inscription_id)                         AS nb_inscriptions,
        SUM(i.montant_paye_xaf)                         AS revenus_xaf,
        ROUND(AVG(e.note_globale), 2)                   AS note_satisfaction,
        ROUND(
            100.0 * SUM(CASE WHEN i.statut = 'Terminé' THEN 1 ELSE 0 END)
                  / NULLIF(COUNT(i.inscription_id), 0), 1
        )                                               AS taux_completion_pct,

        RANK() OVER (
            PARTITION BY f.categorie
            ORDER BY
                AVG(e.note_globale) DESC,
                COUNT(i.inscription_id) DESC
        )                                               AS rang_dans_categorie

    FROM formations f
        INNER JOIN inscriptions i ON f.formation_id = i.formation_id
        LEFT  JOIN evaluations  e ON i.inscription_id = e.inscription_id

    GROUP BY f.formation_id, f.titre, f.categorie, f.prix_xaf
)

SELECT
    rang_dans_categorie     AS rang,
    categorie,
    titre                   AS meilleure_formation,
    prix_xaf,
    nb_inscriptions,
    revenus_xaf,
    note_satisfaction,
    CONCAT(taux_completion_pct, ' %') AS taux_completion

FROM rang_par_categorie
WHERE rang_dans_categorie <= 3  -- Top 3 par catégorie

ORDER BY
    categorie ASC,
    rang_dans_categorie ASC;


-- -----------------------------------------------------------------------------
-- Requête 3 : Formations avec le meilleur rapport qualité/satisfaction
-- (Évaluation du rapport qualité/prix perçu vs prix réel)
-- -----------------------------------------------------------------------------
SELECT
    f.titre                                             AS formation,
    f.categorie,
    f.prix_xaf,
    ROUND(AVG(e.note_rapport_qualite_prix), 2)          AS note_qualite_prix_moy,
    ROUND(AVG(e.note_globale), 2)                       AS note_globale_moy,
    COUNT(e.evaluation_id)                              AS nb_evaluations,

    -- Indice de valeur perçue : satisfaction / prix (plus c'est haut, meilleur le rapport)
    ROUND(
        AVG(e.note_globale) * 100000 / f.prix_xaf,
        4
    )                                                   AS indice_valeur_percue,

    -- Qualification du positionnement
    CASE
        WHEN AVG(e.note_rapport_qualite_prix) >= 4.5 THEN 'Excellent rapport Q/P'
        WHEN AVG(e.note_rapport_qualite_prix) >= 4.0 THEN 'Bon rapport Q/P'
        WHEN AVG(e.note_rapport_qualite_prix) >= 3.5 THEN 'Rapport Q/P moyen'
        ELSE 'Rapport Q/P à améliorer'
    END                                                 AS positionnement

FROM formations f
    INNER JOIN inscriptions i ON f.formation_id = i.formation_id
    INNER JOIN evaluations  e ON i.inscription_id = e.inscription_id

GROUP BY
    f.formation_id, f.titre, f.categorie, f.prix_xaf

HAVING COUNT(e.evaluation_id) >= 5  -- Au moins 5 évaluations pour être significatif

ORDER BY
    note_qualite_prix_moy DESC,
    indice_valeur_percue DESC;
