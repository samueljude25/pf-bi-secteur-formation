# Stack technologique — Justification des choix

## Power BI

**Choix retenu pour la visualisation.**

Power BI est retenu en raison de la présence de Microsoft 365 dans l'organisation, de la certification PL-300 de l'équipe projet, et de sa capacité à connecter nativement SQL Server sans développement complémentaire. Les fonctionnalités de partage via Power BI Service, de sécurité par rôle (RLS) et d'abonnements email automatiques répondent directement aux besoins exprimés.

Alternative évaluée : Metabase (open source, gratuit) — écarté car moins riche en fonctionnalités DAX et moins intégré à l'écosystème Microsoft de l'organisation.

## SQL Server

**Choix retenu pour le stockage analytique.**

SQL Server est déjà présent sur l'infrastructure. L'utilisation d'une base analytique dédiée (séparée de la base transactionnelle) permet d'isoler les charges de travail et de modéliser librement le schéma dimensionnel.

## Python (Pandas)

**Choix retenu pour le nettoyage des données CSV.**

Les fichiers de satisfaction exportés depuis Google Forms nécessitent un nettoyage (encodages, valeurs hors-plage, doublons) plus fin que ce que Power Query peut offrir confortablement. Un script Python planifié assure ce prétraitement avant import dans SQL Server.

## DAX

**Choix retenu pour les calculs analytiques.**

DAX (Data Analysis Expressions) est le langage de formules natif de Power BI. Il permet d'exprimer des calculs complexes (ratios, comparaisons temporelles, classements dynamiques) sans modifier les données sources.

## Tableau de synthèse

| Technologie | Rôle | Justification |
|---|---|---|
| Power BI | Visualisation & publication | Écosystème Microsoft, certification, RLS |
| SQL Server | Stockage analytique | Déjà présent, fiable, bien connu de l'équipe IT |
| Python + Pandas | Nettoyage données CSV | Flexibilité, reproductibilité |
| Power Query | ETL intégré Power BI | Transformation sans code pour les sources simples |
| DAX | Formules analytiques | Natif Power BI, expressif pour la BI |
