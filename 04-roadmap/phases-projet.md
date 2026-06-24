# Roadmap — Phases du projet BI Formation

## Vue d'ensemble

| Phase | Durée | Objectif principal |
|---|---|---|
| Phase 0 — Cadrage | 2 semaines | Alignement besoins, audit données |
| Phase 1 — Pilotage pédagogique | 4 semaines | Dashboard pédagogie + satisfaction |
| Phase 2 — Pilotage financier | 3 semaines | Dashboard finance + formateurs |
| Phase 3 — Déploiement | 2 semaines | Formation, tests UAT, mise en production |
| Phase 4 — Amélioration continue | Récurrent | Évolutions, maintenance |

---

## Phase 0 — Cadrage (S1–S2)

**Objectifs :**
- Réunion de lancement avec toutes les parties prenantes
- Audit de la qualité des données sources
- Validation finale des KPIs et formules de calcul avec le métier
- Signature du cahier des charges
- Mise en place de l'environnement technique (accès SQL Server, licences Power BI)

**Livrables :**
- Rapport d'audit données
- Dictionnaire des indicateurs validé
- Environnement technique opérationnel

---

## Phase 1 — Pilotage pédagogique (S3–S6)

**Objectifs :**
- Modélisation de la base analytique (tables de faits et dimensions)
- Développement du pipeline ETL (SQL Server + CSV satisfaction)
- Création du rapport Power BI — volet pédagogie :
  - Taux de complétion par module et formateur
  - Taux d'abandon avec drill-down par phase
  - Progression hebdomadaire des apprenants
- Création du rapport — volet satisfaction :
  - NPS global et par module
  - CSAT et nuage de mots des verbatims

**Livrables :**
- Modèle de données documenté
- Rapport Power BI volets Pédagogie + Satisfaction
- Scripts ETL Python et Power Query

**Revue de sprint S4 et S6**

---

## Phase 2 — Pilotage financier & formateurs (S7–S9)

**Objectifs :**
- Connexion au logiciel comptable (export ODBC ou CSV)
- Intégration des données de paiement dans le modèle
- Création du rapport — volet financier :
  - CA mensuel par module et type de financement
  - Taux de remplissage et recettes prévisionnelles
  - Taux de recouvrement des paiements
- Création du rapport — volet formateurs :
  - Classement par note apprenants
  - Volume d'activité (sessions, heures)
  - Évolution de la performance dans le temps

**Livrables :**
- Rapports Power BI volets Finance + Formateurs
- Alertes configurées (abandons, satisfaction, remplissage)
- Abonnements email mensuels configurés

**Revue de sprint S9**

---

## Phase 3 — Déploiement (S10–S11)

**Objectifs :**
- Tests de recette utilisateurs (UAT) avec les référents métier
- Correction des anomalies détectées
- Formation des utilisateurs clés (2 jours)
- Publication sur Power BI Service
- Configuration des droits d'accès et RLS
- Remise de la documentation technique et du guide utilisateur

**Livrables :**
- PV de recette signé
- Supports de formation
- Documentation technique
- Guide utilisateur en français

---

## Phase 4 — Amélioration continue (récurrent)

**Revues trimestrielles :**
- Vérification de la pertinence des KPIs avec la direction
- Ajout de nouvelles métriques selon les besoins exprimés
- Mise à jour de la documentation

**Maintenance :**
- Surveillance mensuelle des pipelines ETL
- Mise à jour des connexions sources si nécessaire
- Support utilisateurs (tickets, questions)

**Évolutions planifiées (N+1) :**
- Intégration des données de formation en ligne (LMS)
- Analyse prédictive des inscriptions (Power BI AI insights)
- Extension du dashboard aux antennes régionales (Pointe-Noire)
