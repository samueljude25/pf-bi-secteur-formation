-- =============================================================================
-- VUE : v_performance_intervenants
-- Description : Tableau de bord de performance des formateurs/intervenants
--               Agrège les notes, le volume d'activité et les revenus générés
-- Auteur : Portfolio BI - Samuel Jude Sendzi
-- =============================================================================

CREATE OR REPLACE VIEW v_performance_intervenants AS
SELECT
    -- Identité de l'intervenant
    iv.intervenant_id,
    CONCAT(iv.prenom, ' ', iv.nom)                              AS intervenant_nom_complet,
    iv.specialite,
    iv.experience_annees,
    iv.ville,
    iv.pays,
    iv.tarif_journalier_xaf,

    -- Volume d'activité
    COUNT(DISTINCT f.formation_id)                              AS nb_formations_animees,
    COUNT(DISTINCT i.inscription_id)                            AS nb_inscriptions_total,
    COUNT(DISTINCT e.evaluation_id)                             AS nb_evaluations_recues,

    -- Notes de performance (moyennes sur 5)
    ROUND(AVG(e.note_globale),              2)                  AS note_globale_moy,
    ROUND(AVG(e.note_intervenant),          2)                  AS note_intervenant_moy,
    ROUND(AVG(e.note_contenu),              2)                  AS note_contenu_moy,
    ROUND(AVG(e.note_rapport_qualite_prix), 2)                  AS note_qualite_prix_moy,

    -- NPS Intervenant
    ROUND(
        (
            100.0 * SUM(CASE WHEN e.nps_score >= 9 THEN 1 ELSE 0 END)
                  / NULLIF(COUNT(e.evaluation_id), 0)
        ) - (
            100.0 * SUM(CASE WHEN e.nps_score <= 6 AND e.nps_score IS NOT NULL THEN 1 ELSE 0 END)
                  / NULLIF(COUNT(e.evaluation_id), 0)
        ),
        1
    )                                                           AS nps_score_intervenant,

    -- Taux de recommandation des apprenants
    ROUND(
        100.0 * SUM(CASE WHEN e.recommande = 'Oui' THEN 1 ELSE 0 END)
              / NULLIF(COUNT(e.evaluation_id), 0),
        1
    )                                                           AS taux_recommandation_pct,

    -- Performance de complétion des formations animées
    ROUND(
        100.0 * SUM(CASE WHEN i.statut = 'Terminé' THEN 1 ELSE 0 END)
              / NULLIF(COUNT(i.inscription_id), 0),
        1
    )                                                           AS taux_completion_pct,

    -- Revenus générés par les formations de l'intervenant
    SUM(i.montant_paye_xaf)                                     AS revenus_generes_xaf,
    ROUND(AVG(i.montant_paye_xaf), 0)                           AS revenu_moyen_par_inscription_xaf,

    -- Rémunération estimée (nb jours * tarif journalier)
    -- Estimation : 1 heure de formation = 2h de préparation => jours = heures/8 * 3
    ROUND(
        SUM(f.duree_heures) / 8.0 * 3 * iv.tarif_journalier_xaf,
        0
    )                                                           AS remuneration_estimee_xaf,

    -- Ratio revenus générés / rémunération (rentabilité)
    ROUND(
        SUM(i.montant_paye_xaf)
      / NULLIF(ROUND(SUM(f.duree_heures) / 8.0 * 3 * iv.tarif_journalier_xaf, 0), 0),
        2
    )                                                           AS ratio_revenus_remuneration,

    -- Classement basé sur la note globale
    RANK() OVER (ORDER BY AVG(e.note_globale) DESC)             AS classement_satisfaction,
    RANK() OVER (ORDER BY COUNT(i.inscription_id) DESC)         AS classement_volume

FROM intervenants iv
    LEFT JOIN formations    f  ON iv.intervenant_id = f.intervenant_principal_id
    LEFT JOIN inscriptions  i  ON f.formation_id    = i.formation_id
    LEFT JOIN evaluations   e  ON i.inscription_id  = e.inscription_id
                               AND e.intervenant_id = iv.intervenant_id

WHERE iv.actif = TRUE

GROUP BY
    iv.intervenant_id,
    iv.nom,
    iv.prenom,
    iv.specialite,
    iv.experience_annees,
    iv.ville,
    iv.pays,
    iv.tarif_journalier_xaf

ORDER BY
    note_globale_moy DESC,
    nb_inscriptions_total DESC;
