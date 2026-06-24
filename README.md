# Dashboard BI — Secteur Formation Professionnelle

**Portfolio de compétences — Samuel Jude Sendzi, Chef de Projet Digital & Consultant SI**

---

## Présentation du projet

Ce projet illustre la conception et le déploiement d'un tableau de bord de pilotage pour une **plateforme de formation professionnelle en Afrique centrale**. Il couvre l'analyse des taux de complétion des parcours, la satisfaction des apprenants, la performance des intervenants et les revenus par module de formation.

L'objectif est de fournir aux directions pédagogique et financière une vision claire et actualisée des performances de la plateforme, pour orienter les décisions de programmation, de recrutement des formateurs et d'investissement.

---

## Contexte métier

Une plateforme de formation professionnelle en Afrique centrale propose des modules en présentiel et en ligne dans les domaines suivants : gestion d'entreprise, comptabilité, informatique, langues et développement personnel. Elle accueille plusieurs centaines d'apprenants par an, issus du secteur privé et public.

La direction fait face à plusieurs défis analytiques :
- Identifier les modules à faible taux de complétion pour les reformuler
- Détecter les formateurs les plus performants et les valoriser
- Suivre l'évolution des revenus par module et anticiper les inscriptions
- Mesurer la satisfaction et agir rapidement sur les insatisfactions

---

## Stack technique

| Composant | Technologie |
|---|---|
| Visualisation | Power BI Desktop + Power BI Service |
| Stockage | SQL Server (base de données formation) |
| Transformation | Python (Pandas) + Power Query |
| Formules analytiques | DAX avancé |
| Source données satisfaction | Formulaires en ligne (Google Forms → CSV) |

---

## Indicateurs clés couverts

### Pilotage pédagogique
- Taux de complétion par module et par formateur
- Taux d'abandon par phase du parcours
- Score de satisfaction moyen (NPS, CSAT)
- Progression moyenne des apprenants par semaine

### Pilotage financier
- Chiffre d'affaires par module, par trimestre
- Revenu moyen par apprenant
- Taux de remplissage des sessions
- Coût de formation par apprenant certifié

### Pilotage RH formateurs
- Note moyenne par formateur
- Nombre de sessions animées
- Taux de présence / ponctualité

---

## Structure du dépôt

```
01-avant-projet/
   etude-opportunite.md       Analyse de la valeur business du projet BI
   etude-faisabilite.md       Faisabilité technique et organisationnelle
   analyse-swot.md            Forces, faiblesses, opportunités, menaces
   analyse-pestel.md          Analyse de l'environnement macro

02-cahier-des-charges/
   cahier-des-charges.md      Spécifications fonctionnelles et techniques

03-conception/
   architecture-technique.md  Architecture de la solution
   stack-technologique.md     Justification des choix technologiques

04-roadmap/
   phases-projet.md           Planning et jalons du projet
```

---

## Résultats attendus

- Réduction du taux d'abandon de 20% grâce à la détection précoce des signaux faibles
- Amélioration du score de satisfaction de 15% par un suivi mensuel systématique
- Gain de temps de 8h/semaine sur la production des rapports manuels (Excel)
- Meilleure allocation des formateurs selon leur performance mesurée
