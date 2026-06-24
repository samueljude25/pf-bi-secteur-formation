# Mesures DAX — Dashboard Plateforme de Formation Professionnelle

> **Projet :** Portfolio BI — Samuel Jude Sendzi  
> **Contexte :** Dashboard Power BI de pilotage d'une plateforme de formation professionnelle en Afrique centrale  
> **Modèle :** Schéma en étoile avec tables de faits `f_inscriptions` et `f_evaluations`

---

## Table des matières

1. [Mesures de volume et activité](#1-mesures-de-volume-et-activité)
2. [Mesures de complétion](#2-mesures-de-complétion)
3. [Mesures financières et revenus](#3-mesures-financières-et-revenus)
4. [Mesures de satisfaction et NPS](#4-mesures-de-satisfaction-et-nps)
5. [Mesures de performance des intervenants](#5-mesures-de-performance-des-intervenants)
6. [Mesures temporelles et tendances](#6-mesures-temporelles-et-tendances)
7. [Mesures de classement et KPIs avancés](#7-mesures-de-classement-et-kpis-avancés)

---

## 1. Mesures de volume et activité

### Total Inscriptions
```dax
Total Inscriptions =
COUNTROWS( f_inscriptions )
```
*Compte toutes les inscriptions dans le contexte de filtre courant.*

---

### Total Apprenants
```dax
Total Apprenants =
DISTINCTCOUNT( f_inscriptions[apprenant_id] )
```
*Nombre d'apprenants uniques ayant au moins une inscription.*

---

### Total Formations Actives
```dax
Total Formations Actives =
CALCULATE(
    COUNTROWS( d_formations ),
    d_formations[statut] = "Actif"
)
```
*Nombre de formations disponibles avec le statut "Actif".*

---

### Nouveaux Apprenants Ce Mois
```dax
Nouveaux Apprenants Ce Mois =
CALCULATE(
    DISTINCTCOUNT( d_apprenants[apprenant_id] ),
    DATESMTD( d_temps[date] )
)
```
*Apprenants ayant rejoint la plateforme durant le mois en cours.*

---

## 2. Mesures de complétion

### Apprenants Ayant Terminé
```dax
Apprenants Ayant Terminé =
CALCULATE(
    COUNTROWS( f_inscriptions ),
    f_inscriptions[statut] = "Terminé"
)
```
*Nombre d'inscriptions avec le statut "Terminé".*

---

### Taux de Complétion
```dax
Taux de Complétion =
DIVIDE(
    [Apprenants Ayant Terminé],
    [Total Inscriptions],
    0
)
```
*Proportion des apprenants ayant terminé leur formation. Formule centrale du dashboard.*  
*Format : Pourcentage (0,0%)*

---

### Taux d'Abandon
```dax
Taux d'Abandon =
DIVIDE(
    CALCULATE(
        COUNTROWS( f_inscriptions ),
        f_inscriptions[statut] = "Abandonné"
    ),
    [Total Inscriptions],
    0
)
```
*Proportion d'inscriptions abandonnées. À surveiller pour identifier les formations problématiques.*

---

### Taux de Complétion Moyen (Progression)
```dax
Complétion Moyenne % =
AVERAGE( f_inscriptions[taux_completion_pct] )
```
*Avancement moyen de tous les apprenants, y compris ceux en cours.*

---

### Formations En Cours
```dax
Formations En Cours =
CALCULATE(
    COUNTROWS( f_inscriptions ),
    f_inscriptions[statut] = "En cours"
)
```

---

## 3. Mesures financières et revenus

### Revenus Totaux
```dax
Revenus Totaux =
SUM( f_inscriptions[montant_paye_xaf] )
```
*Total des revenus encaissés en Francs CFA (XAF).*  
*Format : # ##0 "XAF"*

---

### Revenu Moyen par Inscription
```dax
Revenu Moyen par Inscription =
AVERAGEX(
    FILTER(
        f_inscriptions,
        f_inscriptions[montant_paye_xaf] > 0
    ),
    f_inscriptions[montant_paye_xaf]
)
```
*Revenu moyen encaissé par inscription (exclut les abandons sans paiement).*

---

### Revenus des Formations Terminées
```dax
Revenus Formations Terminées =
CALCULATE(
    SUM( f_inscriptions[montant_paye_xaf] ),
    f_inscriptions[statut] = "Terminé"
)
```
*Revenus consolidés générés par les formations dont l'apprenant a terminé.*

---

### Revenu Moyen par Formation
```dax
Revenu Moyen par Formation =
DIVIDE(
    [Revenus Totaux],
    DISTINCTCOUNT( f_inscriptions[formation_id] ),
    0
)
```
*Revenu moyen généré par formation active dans le contexte de filtre.*

---

### Évolution MoM (Revenus)
```dax
Évolution Revenus MoM =
VAR RevenusActuels = [Revenus Totaux]
VAR RevenusMoisPrecedent =
    CALCULATE(
        [Revenus Totaux],
        DATEADD( d_temps[date], -1, MONTH )
    )
RETURN
DIVIDE(
    RevenusActuels - RevenusMoisPrecedent,
    RevenusMoisPrecedent,
    BLANK()
)
```
*Croissance des revenus par rapport au mois précédent.*  
*Format : +0,0% ; -0,0% ; 0,0%*

---

### Revenus Cumulés Année (YTD)
```dax
Revenus YTD =
CALCULATE(
    [Revenus Totaux],
    DATESYTD( d_temps[date] )
)
```
*Revenus cumulés depuis le début de l'année en cours.*

---

### Objectif Revenus Mensuel
```dax
Objectif Revenus Mensuel = 2000000
```
*Objectif mensuel fixé à 2 000 000 XAF. À paramétrer selon les cibles.*

---

### Taux Atteinte Objectif
```dax
Taux Atteinte Objectif =
DIVIDE(
    [Revenus Totaux],
    [Objectif Revenus Mensuel],
    0
)
```
*Pourcentage d'atteinte de l'objectif mensuel de revenus.*

---

## 4. Mesures de satisfaction et NPS

### Score Satisfaction Moyen
```dax
Score Satisfaction Moyen =
AVERAGE( f_evaluations[note_globale] )
```
*Note de satisfaction globale moyenne sur 5.*  
*Format : 0,0 "/ 5"*

---

### Nb Promoteurs NPS
```dax
Nb Promoteurs NPS =
CALCULATE(
    COUNTROWS( f_evaluations ),
    f_evaluations[nps_score] >= 9
)
```
*Apprenants très satisfaits, susceptibles de recommander la plateforme (NPS 9-10).*

---

### Nb Passifs NPS
```dax
Nb Passifs NPS =
CALCULATE(
    COUNTROWS( f_evaluations ),
    f_evaluations[nps_score] >= 7,
    f_evaluations[nps_score] <= 8
)
```
*Apprenants satisfaits mais non enthousiastes (NPS 7-8).*

---

### Nb Détracteurs NPS
```dax
Nb Détracteurs NPS =
CALCULATE(
    COUNTROWS( f_evaluations ),
    f_evaluations[nps_score] <= 6,
    NOT ISBLANK( f_evaluations[nps_score] )
)
```
*Apprenants insatisfaits, risquant de nuire à la réputation (NPS 0-6).*

---

### NPS (Net Promoter Score)
```dax
NPS =
VAR TotalEvals = CALCULATE(
    COUNTROWS( f_evaluations ),
    NOT ISBLANK( f_evaluations[nps_score] )
)
VAR PctPromoteurs = DIVIDE( [Nb Promoteurs NPS], TotalEvals, 0 ) * 100
VAR PctDetracteurs = DIVIDE( [Nb Détracteurs NPS], TotalEvals, 0 ) * 100
RETURN
    ROUND( PctPromoteurs - PctDetracteurs, 1 )
```
*Net Promoter Score = % Promoteurs - % Détracteurs. Varie de -100 à +100.*  
*Interprétation : > 50 excellent, > 0 positif, < 0 problématique.*

---

### Taux de Recommandation
```dax
Taux de Recommandation =
DIVIDE(
    CALCULATE(
        COUNTROWS( f_evaluations ),
        f_evaluations[recommande] = "Oui"
    ),
    COUNTROWS( f_evaluations ),
    0
)
```
*Proportion d'apprenants ayant indiqué recommander la formation.*

---

### Note Intervenant Moyenne
```dax
Note Intervenant Moyenne =
AVERAGE( f_evaluations[note_intervenant] )
```
*Note moyenne attribuée aux intervenants par les apprenants.*

---

## 5. Mesures de performance des intervenants

### Meilleur Intervenant (Note)
```dax
Meilleur Intervenant =
CALCULATE(
    SELECTEDVALUE( d_intervenants[nom_complet] ),
    TOPN(
        1,
        SUMMARIZE(
            f_evaluations,
            d_intervenants[nom_complet],
            "MoyNote", AVERAGE( f_evaluations[note_intervenant] )
        ),
        [MoyNote],
        DESC
    )
)
```
*Nom de l'intervenant avec la meilleure note moyenne dans le contexte actuel.*

---

### Inscriptions par Intervenant
```dax
Inscriptions par Intervenant =
CALCULATE(
    [Total Inscriptions],
    USERELATIONSHIP( f_inscriptions[formation_id], d_formations[formation_id] )
)
```

---

## 6. Mesures temporelles et tendances

### Inscriptions Mois Précédent
```dax
Inscriptions Mois Précédent =
CALCULATE(
    [Total Inscriptions],
    DATEADD( d_temps[date], -1, MONTH )
)
```

---

### Évolution MoM Inscriptions
```dax
Évolution Inscriptions MoM =
DIVIDE(
    [Total Inscriptions] - [Inscriptions Mois Précédent],
    [Inscriptions Mois Précédent],
    BLANK()
)
```
*Croissance du nombre d'inscriptions par rapport au mois précédent.*

---

### Inscriptions YTD (Cumul Annuel)
```dax
Inscriptions YTD =
CALCULATE(
    [Total Inscriptions],
    DATESYTD( d_temps[date] )
)
```

---

### Revenus 3 Derniers Mois
```dax
Revenus 3 Derniers Mois =
CALCULATE(
    [Revenus Totaux],
    DATESINPERIOD(
        d_temps[date],
        LASTDATE( d_temps[date] ),
        -3,
        MONTH
    )
)
```
*Revenus sur les 3 derniers mois glissants.*

---

### Tendance Satisfaction (MoM)
```dax
Tendance Satisfaction MoM =
VAR SatisfactionActuelle = [Score Satisfaction Moyen]
VAR SatisfactionPrecedente =
    CALCULATE(
        [Score Satisfaction Moyen],
        DATEADD( d_temps[date], -1, MONTH )
    )
RETURN
    SatisfactionActuelle - SatisfactionPrecedente
```
*Variation de la note de satisfaction entre le mois actuel et le mois précédent.*

---

## 7. Mesures de classement et KPIs avancés

### Rang Formation (Revenus)
```dax
Rang Formation Revenus =
RANKX(
    ALLSELECTED( d_formations[titre] ),
    [Revenus Totaux],
    ,
    DESC,
    Dense
)
```
*Classement de la formation sélectionnée selon ses revenus (1 = meilleure).*

---

### Rang Intervenant (Satisfaction)
```dax
Rang Intervenant Satisfaction =
RANKX(
    ALLSELECTED( d_intervenants[nom_complet] ),
    [Score Satisfaction Moyen],
    ,
    DESC,
    Dense
)
```

---

### KPI Santé Plateforme
```dax
KPI Santé Plateforme =
VAR ScoreCompletion  = [Taux de Complétion] * 40
VAR ScoreSatisfaction = DIVIDE( [Score Satisfaction Moyen], 5 ) * 35
VAR ScoreCroissance  = MIN( DIVIDE( [Revenus Totaux], [Objectif Revenus Mensuel], 0 ), 1 ) * 25
RETURN
    ROUND( ScoreCompletion + ScoreSatisfaction + ScoreCroissance, 1 )
```
*Score de santé global de la plateforme (0 à 100).*  
*Pondération : 40% complétion + 35% satisfaction + 25% atteinte objectif revenus.*

---

### Icône Tendance Revenus
```dax
Icône Tendance Revenus =
VAR Evo = [Évolution Revenus MoM]
RETURN
    IF( ISBLANK(Evo), "—",
        IF( Evo > 0.05, "▲ En hausse",
            IF( Evo < -0.05, "▼ En baisse",
                "► Stable"
            )
        )
    )
```
*Indicateur visuel de tendance pour les revenus (utilisable dans une carte KPI).*

---

## Notes d'implémentation

### Convention de nommage
- Mesures simples : `[Nom Simple]`
- Mesures avec contexte temporel : `[Nom YTD]`, `[Nom MoM]`
- Mesures de classement : `[Rang Entité Critère]`

### Tables utilisées
| Abréviation | Table complète |
|-------------|----------------|
| `f_inscriptions` | Table de faits des inscriptions |
| `f_evaluations` | Table de faits des évaluations |
| `d_apprenants` | Dimension apprenants |
| `d_formations` | Dimension formations |
| `d_intervenants` | Dimension intervenants |
| `d_modules` | Dimension modules |
| `d_temps` | Dimension calendrier |

### Bonnes pratiques appliquées
- Utilisation systématique de `DIVIDE()` au lieu de `/` pour éviter les erreurs de division par zéro
- Variables DAX (`VAR`) pour améliorer la lisibilité et les performances
- `CALCULATE()` pour modifier le contexte de filtre
- `ALLSELECTED()` dans les classements pour respecter les filtres utilisateur
