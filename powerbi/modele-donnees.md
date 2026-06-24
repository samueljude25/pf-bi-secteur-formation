# Modèle de Données — Dashboard Plateforme de Formation Professionnelle

> **Projet :** Portfolio BI — Samuel Jude Sendzi  
> **Type de modèle :** Schéma en étoile (Star Schema)  
> **Outil :** Microsoft Power BI Desktop  
> **Base source :** MySQL 8.0

---

## Vue d'ensemble du modèle

Le modèle de données suit un **schéma en étoile** avec deux tables de faits centrales et cinq tables de dimensions. Cette architecture optimise les performances des requêtes DAX et facilite la navigation dans le dashboard.

```
                    ┌──────────────┐
                    │  d_temps     │
                    │  (Calendrier)│
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
┌───────▼──────┐   ┌───────▼───────┐  ┌──────▼───────┐
│ d_apprenants │   │ f_inscriptions│  │ d_formations │
│  (Dimension) │◄──│  (Faits)      │──►  (Dimension) │
└──────────────┘   └───────┬───────┘  └──────┬───────┘
                           │                  │
                   ┌───────▼───────┐  ┌───────▼──────┐
                   │ f_evaluations │  │  d_modules   │
                   │  (Faits)      │  │  (Dimension) │
                   └───────┬───────┘  └──────────────┘
                           │
                   ┌───────▼──────┐
                   │d_intervenants│
                   │  (Dimension) │
                   └──────────────┘
```

---

## Tables de faits

### f_inscriptions — Table de faits principale

La table centrale du modèle. Chaque ligne représente une inscription d'un apprenant à une formation.

| Colonne | Type | Description | Rôle |
|---------|------|-------------|------|
| `inscription_id` | INT | Identifiant unique | Clé primaire |
| `apprenant_id` | INT | FK vers d_apprenants | Clé étrangère |
| `formation_id` | INT | FK vers d_formations | Clé étrangère |
| `date_inscription` | DATE | Date d'inscription | Clé temporelle (→ d_temps) |
| `date_debut` | DATE | Début effectif | Clé temporelle secondaire |
| `date_fin_reelle` | DATE | Fin réelle | Clé temporelle secondaire |
| `statut` | VARCHAR | En cours / Terminé / Abandonné | Dimension dégénérée |
| `taux_completion_pct` | INT | Avancement (0-100%) | Mesure |
| `montant_paye_xaf` | INT | Montant encaissé en XAF | Mesure financière |
| `mode_paiement` | VARCHAR | Mobile Money / Virement / Espèces | Dimension dégénérée |
| `source_acquisition` | VARCHAR | Canal d'acquisition | Dimension dégénérée |

**Granularité :** 1 ligne = 1 inscription (apprenant × formation)  
**Volume estimé :** 150 lignes (données démo), évolutif vers 10 000+

---

### f_evaluations — Table de faits secondaire

Chaque ligne représente une évaluation soumise par un apprenant après avoir terminé une formation.

| Colonne | Type | Description | Rôle |
|---------|------|-------------|------|
| `evaluation_id` | INT | Identifiant unique | Clé primaire |
| `inscription_id` | INT | FK vers f_inscriptions | Clé de liaison (1:1) |
| `apprenant_id` | INT | FK vers d_apprenants | Clé étrangère (raccourci) |
| `formation_id` | INT | FK vers d_formations | Clé étrangère |
| `intervenant_id` | INT | FK vers d_intervenants | Clé étrangère |
| `date_evaluation` | DATE | Date de l'évaluation | Clé temporelle |
| `note_globale` | INT | Note globale (1-5) | Mesure |
| `note_contenu` | INT | Qualité du contenu (1-5) | Mesure |
| `note_intervenant` | INT | Performance formateur (1-5) | Mesure |
| `note_plateforme` | INT | UX plateforme (1-5) | Mesure |
| `note_rapport_qualite_prix` | INT | Valeur perçue (1-5) | Mesure |
| `recommande` | VARCHAR | Oui / Non / Neutre | Dimension dégénérée |
| `nps_score` | INT | Score NPS (0-10) | Mesure NPS |
| `commentaire` | TEXT | Avis textuel | Attribut textuel |

**Granularité :** 1 ligne = 1 évaluation (1 par inscription maximum)  
**Volume estimé :** 120 lignes (données démo)

---

## Tables de dimensions

### d_apprenants — Dimension apprenants

| Colonne | Type | Description |
|---------|------|-------------|
| `apprenant_id` | INT | Clé primaire |
| `nom` | VARCHAR | Nom de famille |
| `prenom` | VARCHAR | Prénom |
| `email` | VARCHAR | Email de contact |
| `telephone` | VARCHAR | Téléphone |
| `ville` | VARCHAR | Ville de résidence |
| `pays` | VARCHAR | Pays de résidence |
| `date_naissance` | DATE | Date de naissance |
| `sexe` | CHAR | M / F |
| `niveau_etude` | VARCHAR | Bac / BTS / Licence / Master |
| `date_inscription_plateforme` | DATE | Date d'entrée sur la plateforme |
| `tranche_age` | Calculé | Colonne calculée DAX : 18-25 / 26-35 / 36-45 / 46+ |

**Attributs de hiérarchie :**
- Géographique : Pays → Ville
- Démographique : Sexe → Tranche d'âge → Niveau d'étude

---

### d_formations — Dimension formations

| Colonne | Type | Description |
|---------|------|-------------|
| `formation_id` | INT | Clé primaire |
| `titre` | VARCHAR | Intitulé complet |
| `categorie` | VARCHAR | Informatique / Data / Management / Finance / Marketing / Business / Bureautique / Langues |
| `description` | TEXT | Description pédagogique |
| `duree_heures` | INT | Durée totale en heures |
| `prix_xaf` | INT | Prix catalogue en XAF |
| `niveau` | VARCHAR | Débutant / Intermédiaire / Avancé |
| `intervenant_principal_id` | INT | FK vers d_intervenants |
| `date_creation` | DATE | Date de mise en ligne |
| `statut` | VARCHAR | Actif / Inactif / Archivé |
| `nb_places_max` | INT | Capacité maximale |
| `certification` | CHAR | Oui / Non |

**Attributs de hiérarchie :**
- Pédagogique : Catégorie → Niveau → Formation → Module

---

### d_modules — Dimension modules

| Colonne | Type | Description |
|---------|------|-------------|
| `module_id` | INT | Clé primaire |
| `formation_id` | INT | FK vers d_formations |
| `titre` | VARCHAR | Titre du module |
| `ordre` | INT | Ordre dans la formation |
| `duree_heures` | INT | Durée du module |
| `type_contenu` | VARCHAR | Vidéo + TP / Vidéo + Projet / Vidéo + Quiz |
| `obligatoire` | CHAR | Oui / Non |

---

### d_intervenants — Dimension intervenants

| Colonne | Type | Description |
|---------|------|-------------|
| `intervenant_id` | INT | Clé primaire |
| `nom_complet` | Calculé | CONCAT(prenom, ' ', nom) |
| `specialite` | VARCHAR | Domaine d'expertise |
| `experience_annees` | INT | Années d'expérience |
| `tarif_journalier_xaf` | INT | Coût journalier en XAF |
| `ville` | VARCHAR | Ville de base |
| `pays` | VARCHAR | Pays |
| `note_moyenne` | DECIMAL | Note moyenne (mise à jour via SQL) |

---

### d_temps — Dimension calendrier

Table de dates générée dans Power BI avec DAX (à créer via une table calculée).

```dax
d_temps =
ADDCOLUMNS(
    CALENDAR( DATE(2024, 1, 1), DATE(2025, 12, 31) ),
    "Annee",         YEAR( [Date] ),
    "Trimestre",     "T" & QUARTER( [Date] ),
    "Mois_Num",      MONTH( [Date] ),
    "Mois_Nom",      FORMAT( [Date], "MMMM", "fr-FR" ),
    "Mois_Court",    FORMAT( [Date], "MMM", "fr-FR" ),
    "Annee_Mois",    FORMAT( [Date], "YYYY-MM" ),
    "Semaine",       WEEKNUM( [Date], 2 ),
    "Jour_Semaine",  FORMAT( [Date], "dddd", "fr-FR" ),
    "Jour_Num",      WEEKDAY( [Date], 2 ),
    "Est_Weekend",   IF( WEEKDAY( [Date], 2 ) >= 6, TRUE, FALSE ),
    "Periode_Label", FORMAT( [Date], "MMM YYYY", "fr-FR" )
)
```

**Attributs de hiérarchie temporelle :**
Année → Trimestre → Mois → Semaine → Jour

---

## Relations entre tables

| Table source | Colonne source | Table cible | Colonne cible | Cardinalité | Direction |
|-------------|----------------|-------------|---------------|-------------|-----------|
| f_inscriptions | apprenant_id | d_apprenants | apprenant_id | N:1 | → |
| f_inscriptions | formation_id | d_formations | formation_id | N:1 | → |
| f_inscriptions | date_inscription | d_temps | date | N:1 | → |
| f_evaluations | inscription_id | f_inscriptions | inscription_id | 1:1 | → |
| f_evaluations | apprenant_id | d_apprenants | apprenant_id | N:1 | → (inactive) |
| f_evaluations | formation_id | d_formations | formation_id | N:1 | → (inactive) |
| f_evaluations | intervenant_id | d_intervenants | intervenant_id | N:1 | → |
| f_evaluations | date_evaluation | d_temps | date | N:1 | → (inactive) |
| d_formations | formation_id | d_modules | formation_id | 1:N | → |
| d_formations | intervenant_principal_id | d_intervenants | intervenant_id | N:1 | → |

> **Note :** Les relations inactives sont activées dans les mesures DAX via `USERELATIONSHIP()` lorsque nécessaire.

---

## Pages du Dashboard recommandées

### Page 1 — Vue Exécutive
- KPIs globaux : total inscriptions, revenus, taux complétion, NPS
- Graphique : évolution mensuelle des revenus et inscriptions
- Carte : répartition géographique des apprenants
- Filtre : Année, Trimestre

### Page 2 — Analyse Formations
- Tableau : top formations par revenus, satisfaction, complétion
- Graphique barres : revenus par catégorie
- Graphique radar : performance multidimensionnelle par formation
- Filtre : Catégorie, Niveau, Certification

### Page 3 — Satisfaction & NPS
- Jauge : score NPS global
- Graphique en anneau : répartition Promoteurs / Passifs / Détracteurs
- Tableau : notes moyennes par formation et par dimension
- Nuage de mots ou tableau : commentaires apprenants (Top positifs / négatifs)
- Filtre : Formation, Intervenant, Période

### Page 4 — Performance Intervenants
- Tableau classement : intervenants par note moyenne
- Graphique : volume d'activité vs satisfaction (scatter plot)
- KPI : meilleur intervenant du mois
- Filtre : Spécialité, Intervenant

### Page 5 — Revenus & Finance
- KPI : revenus vs objectif (jauge)
- Graphique : évolution MoM et YoY des revenus
- Graphique : répartition par mode de paiement et source d'acquisition
- Tableau : revenus par formation avec variance vs prix catalogue
- Filtre : Période, Formation, Canal

---

## Paramètres de performance recommandés

- **Import vs DirectQuery :** Import (les données de démo sont statiques)
- **Actualisation :** Planifier une actualisation quotidienne en production
- **Optimisation :** Désactiver Auto Date/Time, utiliser `d_temps` personnalisé
- **Compression :** Éviter les colonnes texte non nécessaires dans les faits
