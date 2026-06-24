-- =============================================================================
-- Schéma de base de données : Plateforme de Formation Professionnelle
-- Projet : Portfolio BI - Samuel Jude Sendzi
-- Version : 1.0
-- Date : 2024-01-01
-- Description : Schéma complet pour le pilotage d'une plateforme de formation
--               professionnelle en Afrique centrale (modèle OLTP)
-- =============================================================================

-- Suppression des tables existantes (dans l'ordre inverse des dépendances)
DROP TABLE IF EXISTS evaluations;
DROP TABLE IF EXISTS inscriptions;
DROP TABLE IF EXISTS modules;
DROP TABLE IF EXISTS formations;
DROP TABLE IF EXISTS intervenants;
DROP TABLE IF EXISTS apprenants;

-- =============================================================================
-- TABLE : apprenants
-- Description : Données démographiques des apprenants inscrits sur la plateforme
-- =============================================================================
CREATE TABLE apprenants (
    apprenant_id    INT             NOT NULL AUTO_INCREMENT,
    nom             VARCHAR(100)    NOT NULL COMMENT 'Nom de famille',
    prenom          VARCHAR(100)    NOT NULL COMMENT 'Prénom',
    email           VARCHAR(150)    NOT NULL UNIQUE COMMENT 'Email unique pour connexion',
    telephone       VARCHAR(20)     COMMENT 'Numéro de téléphone international',
    ville           VARCHAR(100)    COMMENT 'Ville de résidence',
    pays            VARCHAR(100)    NOT NULL DEFAULT 'Congo' COMMENT 'Pays de résidence',
    date_naissance  DATE            COMMENT 'Date de naissance',
    sexe            CHAR(1)         NOT NULL COMMENT 'M = Masculin, F = Féminin',
    niveau_etude    VARCHAR(50)     COMMENT 'Niveau d''étude : Bac, BTS, Licence, Master',
    date_inscription_plateforme DATE NOT NULL DEFAULT (CURRENT_DATE) COMMENT 'Date d''inscription sur la plateforme',
    actif           BOOLEAN         NOT NULL DEFAULT TRUE COMMENT 'Compte actif ou désactivé',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (apprenant_id),
    INDEX idx_apprenants_email (email),
    INDEX idx_apprenants_ville (ville),
    INDEX idx_apprenants_pays (pays),
    CONSTRAINT chk_apprenants_sexe CHECK (sexe IN ('M', 'F')),
    CONSTRAINT chk_apprenants_niveau CHECK (niveau_etude IN ('Bac', 'BTS', 'Licence', 'Master', 'Doctorat', 'Autre'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Table des apprenants inscrits sur la plateforme de formation';


-- =============================================================================
-- TABLE : intervenants
-- Description : Formateurs et experts animant les formations
-- =============================================================================
CREATE TABLE intervenants (
    intervenant_id          INT             NOT NULL AUTO_INCREMENT,
    nom                     VARCHAR(100)    NOT NULL,
    prenom                  VARCHAR(100)    NOT NULL,
    email                   VARCHAR(150)    NOT NULL UNIQUE,
    specialite              VARCHAR(200)    NOT NULL COMMENT 'Domaine de spécialité principal',
    experience_annees       INT             NOT NULL DEFAULT 0 COMMENT 'Années d''expérience professionnelle',
    tarif_journalier_xaf    INT             NOT NULL COMMENT 'Tarif journalier en Francs CFA (XAF)',
    ville                   VARCHAR(100),
    pays                    VARCHAR(100)    NOT NULL DEFAULT 'Congo',
    note_moyenne            DECIMAL(3,1)    COMMENT 'Note moyenne sur 5 calculée à partir des évaluations',
    nb_formations_animees   INT             NOT NULL DEFAULT 0 COMMENT 'Nombre total de formations animées',
    biographie_courte       TEXT            COMMENT 'Biographie professionnelle courte',
    actif                   BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (intervenant_id),
    INDEX idx_intervenants_specialite (specialite(50)),
    CONSTRAINT chk_intervenant_note CHECK (note_moyenne BETWEEN 0 AND 5),
    CONSTRAINT chk_intervenant_tarif CHECK (tarif_journalier_xaf > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Table des formateurs et experts intervenant sur la plateforme';


-- =============================================================================
-- TABLE : formations
-- Description : Catalogue des formations proposées sur la plateforme
-- =============================================================================
CREATE TABLE formations (
    formation_id                INT             NOT NULL AUTO_INCREMENT,
    titre                       VARCHAR(200)    NOT NULL COMMENT 'Intitulé de la formation',
    categorie                   VARCHAR(100)    NOT NULL COMMENT 'Catégorie : Informatique, Data, Management...',
    description                 TEXT            COMMENT 'Description détaillée de la formation',
    duree_heures                INT             NOT NULL COMMENT 'Durée totale en heures',
    prix_xaf                    INT             NOT NULL COMMENT 'Prix de vente en Francs CFA',
    niveau                      VARCHAR(50)     NOT NULL COMMENT 'Débutant, Intermédiaire, Avancé',
    intervenant_principal_id    INT             NOT NULL COMMENT 'FK vers l''intervenant principal',
    date_creation               DATE            NOT NULL,
    statut                      VARCHAR(20)     NOT NULL DEFAULT 'Actif' COMMENT 'Actif, Inactif, Archivé',
    nb_places_max               INT             NOT NULL DEFAULT 30 COMMENT 'Nombre maximum de participants',
    certification               CHAR(3)         NOT NULL DEFAULT 'Non' COMMENT 'Oui ou Non',
    created_at                  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (formation_id),
    FOREIGN KEY (intervenant_principal_id) REFERENCES intervenants(intervenant_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_formations_categorie (categorie),
    INDEX idx_formations_statut (statut),
    INDEX idx_formations_niveau (niveau),
    CONSTRAINT chk_formations_prix CHECK (prix_xaf > 0),
    CONSTRAINT chk_formations_duree CHECK (duree_heures > 0),
    CONSTRAINT chk_formations_niveau CHECK (niveau IN ('Débutant', 'Intermédiaire', 'Avancé')),
    CONSTRAINT chk_formations_statut CHECK (statut IN ('Actif', 'Inactif', 'Archivé')),
    CONSTRAINT chk_formations_certification CHECK (certification IN ('Oui', 'Non'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Catalogue des formations disponibles sur la plateforme';


-- =============================================================================
-- TABLE : modules
-- Description : Modules composant chaque formation (découpage pédagogique)
-- =============================================================================
CREATE TABLE modules (
    module_id       INT             NOT NULL AUTO_INCREMENT,
    formation_id    INT             NOT NULL COMMENT 'FK vers la formation parente',
    titre           VARCHAR(200)    NOT NULL COMMENT 'Titre du module',
    ordre           INT             NOT NULL COMMENT 'Ordre d''affichage dans la formation',
    duree_heures    INT             NOT NULL COMMENT 'Durée du module en heures',
    description     TEXT            COMMENT 'Description du contenu du module',
    type_contenu    VARCHAR(100)    COMMENT 'Vidéo + TP, Vidéo + Projet, Vidéo + Quiz...',
    obligatoire     CHAR(3)         NOT NULL DEFAULT 'Oui' COMMENT 'Module obligatoire ou optionnel',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (module_id),
    FOREIGN KEY (formation_id) REFERENCES formations(formation_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_modules_formation (formation_id),
    UNIQUE KEY uk_modules_ordre (formation_id, ordre),
    CONSTRAINT chk_modules_duree CHECK (duree_heures > 0),
    CONSTRAINT chk_modules_obligatoire CHECK (obligatoire IN ('Oui', 'Non'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Modules pédagogiques composant chaque formation';


-- =============================================================================
-- TABLE : inscriptions
-- Description : Table de faits principale - inscriptions des apprenants aux formations
-- =============================================================================
CREATE TABLE inscriptions (
    inscription_id          INT             NOT NULL AUTO_INCREMENT,
    apprenant_id            INT             NOT NULL COMMENT 'FK vers l''apprenant',
    formation_id            INT             NOT NULL COMMENT 'FK vers la formation',
    date_inscription        DATE            NOT NULL COMMENT 'Date d''inscription administrative',
    date_debut              DATE            COMMENT 'Date de début effectif de la formation',
    date_fin_prevue         DATE            COMMENT 'Date de fin prévisionnelle',
    date_fin_reelle         DATE            COMMENT 'Date de fin réelle (si terminé)',
    statut                  VARCHAR(20)     NOT NULL DEFAULT 'En cours' COMMENT 'En cours, Terminé, Abandonné',
    taux_completion_pct     INT             NOT NULL DEFAULT 0 COMMENT 'Pourcentage de complétion (0-100)',
    montant_paye_xaf        INT             NOT NULL DEFAULT 0 COMMENT 'Montant effectivement payé en XAF',
    mode_paiement           VARCHAR(50)     COMMENT 'Mobile Money, Virement, Espèces...',
    source_acquisition      VARCHAR(100)    COMMENT 'Canal d''acquisition : Site web, Réseaux sociaux...',
    created_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (inscription_id),
    FOREIGN KEY (apprenant_id) REFERENCES apprenants(apprenant_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (formation_id) REFERENCES formations(formation_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    UNIQUE KEY uk_inscription (apprenant_id, formation_id) COMMENT 'Un apprenant ne peut pas s''inscrire deux fois à la même formation',
    INDEX idx_inscriptions_statut (statut),
    INDEX idx_inscriptions_date (date_inscription),
    INDEX idx_inscriptions_formation (formation_id),
    CONSTRAINT chk_inscriptions_statut CHECK (statut IN ('En cours', 'Terminé', 'Abandonné')),
    CONSTRAINT chk_inscriptions_completion CHECK (taux_completion_pct BETWEEN 0 AND 100),
    CONSTRAINT chk_inscriptions_montant CHECK (montant_paye_xaf >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Table de faits principale : inscriptions des apprenants aux formations';


-- =============================================================================
-- TABLE : evaluations
-- Description : Évaluations et avis des apprenants après chaque formation
-- =============================================================================
CREATE TABLE evaluations (
    evaluation_id               INT             NOT NULL AUTO_INCREMENT,
    inscription_id              INT             NOT NULL COMMENT 'FK vers l''inscription (unique par inscription)',
    apprenant_id                INT             NOT NULL COMMENT 'FK vers l''apprenant (redondance pour performances)',
    formation_id                INT             NOT NULL COMMENT 'FK vers la formation',
    intervenant_id              INT             NOT NULL COMMENT 'FK vers l''intervenant évalué',
    date_evaluation             DATE            NOT NULL,
    note_globale                INT             NOT NULL COMMENT 'Note globale de 1 à 5',
    note_contenu                INT             NOT NULL COMMENT 'Qualité du contenu pédagogique (1-5)',
    note_intervenant            INT             NOT NULL COMMENT 'Performance de l''intervenant (1-5)',
    note_plateforme             INT             NOT NULL COMMENT 'Expérience utilisateur plateforme (1-5)',
    note_rapport_qualite_prix   INT             NOT NULL COMMENT 'Rapport qualité/prix perçu (1-5)',
    commentaire                 TEXT            COMMENT 'Avis libre de l''apprenant',
    recommande                  VARCHAR(10)     COMMENT 'Oui, Non, Neutre',
    nps_score                   INT             COMMENT 'Score NPS de 0 à 10 (Promoteur >= 9, Passif 7-8, Détracteur <= 6)',
    created_at                  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (evaluation_id),
    FOREIGN KEY (inscription_id) REFERENCES inscriptions(inscription_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (apprenant_id) REFERENCES apprenants(apprenant_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (formation_id) REFERENCES formations(formation_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (intervenant_id) REFERENCES intervenants(intervenant_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    UNIQUE KEY uk_evaluation_inscription (inscription_id) COMMENT 'Une seule évaluation par inscription',
    INDEX idx_evaluations_formation (formation_id),
    INDEX idx_evaluations_intervenant (intervenant_id),
    INDEX idx_evaluations_date (date_evaluation),
    CONSTRAINT chk_evaluations_note_globale CHECK (note_globale BETWEEN 1 AND 5),
    CONSTRAINT chk_evaluations_note_contenu CHECK (note_contenu BETWEEN 1 AND 5),
    CONSTRAINT chk_evaluations_note_intervenant CHECK (note_intervenant BETWEEN 1 AND 5),
    CONSTRAINT chk_evaluations_note_plateforme CHECK (note_plateforme BETWEEN 1 AND 5),
    CONSTRAINT chk_evaluations_note_qp CHECK (note_rapport_qualite_prix BETWEEN 1 AND 5),
    CONSTRAINT chk_evaluations_nps CHECK (nps_score BETWEEN 0 AND 10),
    CONSTRAINT chk_evaluations_recommande CHECK (recommande IN ('Oui', 'Non', 'Neutre'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Évaluations post-formation des apprenants (satisfaction et NPS)';


-- =============================================================================
-- Vérification des contraintes de dates après création des tables
-- =============================================================================
-- Note : Les contraintes croisées entre colonnes (date_fin_prevue > date_debut)
-- peuvent être ajoutées via des triggers selon la version MySQL utilisée.

-- =============================================================================
-- Fin du schéma
-- =============================================================================
