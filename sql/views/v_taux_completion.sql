-- =============================================================================
-- VUE : v_taux_completion
-- Description : Calcul des taux de complétion par formation, par mois et global
-- Auteur : Portfolio BI - Samuel Jude Sendzi
-- =============================================================================

CREATE OR REPLACE VIEW v_taux_completion AS
SELECT
    -- Identifiants
    f.formation_id,
    f.titre                                                     AS formation,
    f.categorie,
    f.niveau,

    -- Compteurs d'inscriptions par statut
    COUNT(i.inscription_id)                                     AS total_inscriptions,
    SUM(CASE WHEN i.statut = 'Terminé'   THEN 1 ELSE 0 END)    AS nb_termines,
    SUM(CASE WHEN i.statut = 'En cours'  THEN 1 ELSE 0 END)    AS nb_en_cours,
    SUM(CASE WHEN i.statut = 'Abandonné' THEN 1 ELSE 0 END)    AS nb_abandonnes,

    -- Taux de complétion : pourcentage des inscrits ayant terminé
    ROUND(
        100.0 * SUM(CASE WHEN i.statut = 'Terminé' THEN 1 ELSE 0 END)
              / NULLIF(COUNT(i.inscription_id), 0),
        2
    )                                                           AS taux_completion_pct,

    -- Taux d'abandon
    ROUND(
        100.0 * SUM(CASE WHEN i.statut = 'Abandonné' THEN 1 ELSE 0 END)
              / NULLIF(COUNT(i.inscription_id), 0),
        2
    )                                                           AS taux_abandon_pct,

    -- Complétion moyenne effective (pour les inscrits actifs ou terminés)
    ROUND(AVG(i.taux_completion_pct), 2)                        AS completion_moyenne_pct,

    -- Durée moyenne réelle de complétion (en jours, pour les formations terminées)
    ROUND(
        AVG(
            CASE
                WHEN i.statut = 'Terminé' AND i.date_fin_reelle IS NOT NULL
                THEN DATEDIFF(i.date_fin_reelle, i.date_debut)
            END
        ),
        1
    )                                                           AS duree_reelle_moy_jours,

    -- Durée prévue théorique en jours
    ROUND(
        AVG(DATEDIFF(i.date_fin_prevue, i.date_debut)),
        1
    )                                                           AS duree_prevue_moy_jours,

    -- Informations complémentaires
    f.duree_heures                                              AS duree_formation_heures,
    f.prix_xaf                                                  AS prix_xaf,
    iv.nom                                                      AS intervenant_nom,
    iv.prenom                                                   AS intervenant_prenom

FROM formations f
    INNER JOIN inscriptions i       ON f.formation_id = i.formation_id
    INNER JOIN intervenants  iv     ON f.intervenant_principal_id = iv.intervenant_id
WHERE
    f.statut = 'Actif'

GROUP BY
    f.formation_id,
    f.titre,
    f.categorie,
    f.niveau,
    f.duree_heures,
    f.prix_xaf,
    iv.nom,
    iv.prenom

ORDER BY
    taux_completion_pct DESC,
    total_inscriptions DESC;


-- -----------------------------------------------------------------------------
-- Vue complémentaire : taux de complétion mensuel (évolution dans le temps)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_taux_completion_mensuel AS
SELECT
    YEAR(i.date_inscription)                                    AS annee,
    MONTH(i.date_inscription)                                   AS mois,
    DATE_FORMAT(i.date_inscription, '%Y-%m')                    AS annee_mois,
    f.categorie,

    COUNT(i.inscription_id)                                     AS total_inscriptions,
    SUM(CASE WHEN i.statut = 'Terminé' THEN 1 ELSE 0 END)      AS nb_termines,

    ROUND(
        100.0 * SUM(CASE WHEN i.statut = 'Terminé' THEN 1 ELSE 0 END)
              / NULLIF(COUNT(i.inscription_id), 0),
        2
    )                                                           AS taux_completion_pct,

    SUM(i.montant_paye_xaf)                                     AS revenus_mois_xaf

FROM inscriptions i
    INNER JOIN formations f ON i.formation_id = f.formation_id

GROUP BY
    YEAR(i.date_inscription),
    MONTH(i.date_inscription),
    DATE_FORMAT(i.date_inscription, '%Y-%m'),
    f.categorie

ORDER BY
    annee_mois ASC,
    f.categorie ASC;
