# Cahier des charges — Tableau de bord BI Secteur Formation

## 1. Objet du document

Ce cahier des charges définit les exigences fonctionnelles et techniques pour la conception et le déploiement d'un tableau de bord de pilotage BI pour une plateforme de formation professionnelle en Afrique centrale. Il constitue le document de référence entre le commanditaire et l'équipe projet.

---

## 2. Périmètre fonctionnel

### 2.1 Modules couverts

| Module | Priorité | Description |
|---|---|---|
| Pilotage pédagogique | Haute | Taux de complétion, abandon, progression |
| Satisfaction apprenants | Haute | Scores NPS, CSAT, verbatim |
| Performance formateurs | Haute | Notes, sessions, ponctualité |
| Pilotage financier | Moyenne | CA, marges, taux de remplissage |
| Prévisions | Basse | Projections d'inscriptions |

### 2.2 Indicateurs clés (KPIs)

**Pédagogiques**
- Taux de complétion global et par module (cible : > 80%)
- Taux d'abandon (cible : < 15%)
- Score moyen aux évaluations finales
- Nombre d'apprenants actifs par semaine

**Satisfaction**
- Net Promoter Score (NPS) : note de recommandation 0–10
- Customer Satisfaction Score (CSAT) : satisfaction globale 1–5
- Taux de réponse aux enquêtes de satisfaction

**Formateurs**
- Note moyenne attribuée par les apprenants (1–5)
- Nombre de sessions animées par trimestre
- Taux de présence et de ponctualité

**Financiers**
- Chiffre d'affaires par module et par trimestre
- Revenu moyen par apprenant inscrit
- Taux de remplissage des sessions (% places occupées)
- Taux de recouvrement des paiements

---

## 3. Exigences fonctionnelles

### 3.1 Filtres et navigation
- Filtres temporels : jour, semaine, mois, trimestre, année
- Filtres par module de formation
- Filtres par formateur
- Filtres par type de financement (entreprise, individuel, public)
- Navigation drill-down : vue globale → vue module → vue session

### 3.2 Alertes automatiques
- Alerte si taux d'abandon dépasse 20% sur un module
- Alerte si score de satisfaction descend en dessous de 3,5/5
- Alerte si taux de remplissage est inférieur à 60% à J-7 d'une session

### 3.3 Rapports automatiques
- Rapport mensuel envoyé par email à la direction (PDF Power BI)
- Export Excel des données brutes sur demande

---

## 4. Exigences techniques

### 4.1 Architecture
- Source : SQL Server (données inscriptions + résultats)
- ETL : Power Query + scripts Python pour les fichiers CSV
- Stockage : SQL Server (base analytique dédiée)
- Visualisation : Power BI Desktop (développement) + Power BI Service (publication)

### 4.2 Fréquence d'actualisation
- Données pédagogiques : actualisation quotidienne (nuit)
- Données financières : actualisation hebdomadaire
- Données satisfaction : actualisation à réception des formulaires

### 4.3 Sécurité et accès
- Authentification via Microsoft 365 (SSO)
- Row-Level Security : chaque formateur ne voit que ses propres indicateurs
- Direction : accès lecture complète
- Administrateur BI : accès édition complète

### 4.4 Performance
- Temps de chargement d'un rapport : < 5 secondes
- Disponibilité : 99% en heures ouvrables (7h–19h)

---

## 5. Contraintes

| Contrainte | Description |
|---|---|
| Budget | Enveloppe totale de 5,5 millions FCFA |
| Délai | Mise en production Phase 1 en 12 semaines |
| Formation | Intégrer 2 jours de formation utilisateurs |
| Langue | Interface et documentation en français |
| Support offline | Prévoir exports pour zones à faible connectivité |

---

## 6. Livrables

| Livrable | Semaine |
|---|---|
| Modèle de données (schéma) | S4 |
| Maquettes des tableaux de bord | S6 |
| Version Alpha (3 écrans) | S8 |
| Version Beta complète | S10 |
| Formation utilisateurs | S11 |
| Mise en production + recette | S12 |

---

## 7. Critères de recette

- Tous les KPIs calculés correspondent aux formules validées avec le métier
- Les filtres fonctionnent sans erreur sur toutes les combinaisons testées
- Les temps de chargement sont inférieurs à 5 secondes sur connexion standard
- Les utilisateurs clés ont validé l'ergonomie lors des tests UAT
- La documentation technique est livrée et complète
