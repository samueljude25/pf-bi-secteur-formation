# Architecture technique — Dashboard BI Formation

## Vue d'ensemble

```
[Sources de données]          [Ingestion & ETL]      [Stockage]        [Visualisation]
SQL Server (inscriptions) ──► Power Query      ──►   SQL Server   ──►  Power BI Desktop
Excel (présences)         ──► Python (Pandas)  ──►   (base BI)    ──►  Power BI Service
Google Forms (feedbacks)  ──► Script CSV       ──►                ──►  Export PDF/Excel
Logiciel comptable        ──► Export ODBC      ──►
```

## Couches de l'architecture

### Couche Source
Les données brutes proviennent de quatre systèmes distincts :
- **SQL Server** : base de gestion des inscriptions, résultats, présences
- **Excel** : émargements saisis manuellement par les formateurs
- **Google Forms** : enquêtes de satisfaction (export CSV quotidien)
- **Logiciel comptable** : exports CSV des paiements et factures

### Couche ETL (Power Query + Python)
- Connexion directe SQL Server via connecteur natif Power BI
- Import et transformation des fichiers CSV via Power Query
- Script Python pour le nettoyage des données de satisfaction (dédoublonnage, normalisation des notes)
- Planification des actualisations via Power BI Service (Gateway sur serveur local)

### Couche Analytique (SQL Server BI)
Base de données dédiée à l'analyse, séparée de la base transactionnelle :
- Tables de dimensions (apprenants, formateurs, modules, dates, géographie)
- Tables de faits (inscriptions, résultats, paiements, feedbacks)
- Vues agrégées pour les métriques les plus consultées

### Couche Visualisation (Power BI)
- 4 espaces de rapport : Pédagogie, Satisfaction, Formateurs, Finance
- Navigation par onglets avec filtres synchronisés
- Mode mobile activé pour consultation sur smartphone
- Abonnements email automatiques pour les rapports mensuels

## Modèle de données (schéma simplifié)

```
DIM_Dates ──────────────────────────────────────────────────────────────┐
DIM_Modules ──────────────────────────────────────────────────────────  │
DIM_Formateurs ─────────────────────────────────────────────────────    │
DIM_Apprenants ──────── FAIT_Inscriptions ─────────────────────────────┘
DIM_Financement ────────────┘
                     FAIT_Résultats
                     FAIT_Feedbacks
                     FAIT_Paiements
```

## Sécurité
- RLS configuré par rôle (Formateur, Direction Péda, Direction Fin, Admin)
- Authentification Microsoft 365 / Azure AD
- Données de paiement accessibles uniquement à la direction financière
