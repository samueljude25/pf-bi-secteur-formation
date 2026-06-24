# Étude de faisabilité — Tableau de bord BI Secteur Formation

## 1. Faisabilité technique

### Infrastructure existante
- Un serveur local sous Windows Server avec SQL Server Express installé
- Connexion Internet stable au siège (fibre optique, 20 Mbps)
- Postes de travail sous Windows 10/11 avec Microsoft 365 (incluant Power BI Desktop)

### Sources de données disponibles
| Source | Type | Format | Accessibilité |
|---|---|---|---|
| Gestion des inscriptions | Base SQL Server | Tables relationnelles | Direct |
| Présences / émargements | Excel | .xlsx mensuel | Import |
| Évaluations formateurs | Google Forms | CSV export | API + CSV |
| Feedbacks apprenants | Google Forms | CSV export | API + CSV |
| Paiements et factures | Logiciel comptable | Export CSV | Semi-automatique |

### Compatibilité Power BI
Power BI Desktop dispose de connecteurs natifs pour SQL Server, Excel et CSV. La connexion au logiciel comptable nécessitera un export intermédiaire ou un connecteur ODBC.

### Verdict technique : **FAISABLE**

---

## 2. Faisabilité organisationnelle

### Compétences disponibles
- Direction pédagogique : maîtrise d'Excel, volonté d'adopter Power BI
- Responsable informatique : compétences SQL de base, disponible 20% sur le projet
- Formateurs : peu techniques, besoins de consultation uniquement (pas de création)

### Formation nécessaire
- 2 jours de formation Power BI pour les utilisateurs clés (direction + responsable qualité)
- 1 session de sensibilisation pour les formateurs (lecture des rapports)

### Organisation du projet
- Comité de pilotage mensuel : direction générale + chef de projet
- Référent métier désigné : directeur pédagogique
- Revues de sprint bimensuelles

### Verdict organisationnel : **FAISABLE avec accompagnement**

---

## 3. Faisabilité financière

### Estimation des coûts

| Poste | Coût estimé (FCFA) |
|---|---|
| Licence Power BI Pro (2 utilisateurs × 12 mois) | 720 000 |
| Prestation consultant BI (développement, 40 jours) | 4 000 000 |
| Formation utilisateurs (2 jours) | 300 000 |
| Infrastructure (serveur si upgrade nécessaire) | 500 000 |
| **Total** | **5 520 000** |

### Estimation des gains

| Poste | Gain annuel estimé (FCFA) |
|---|---|
| Économie temps reporting (8h/mois × 12 × coût heure) | 960 000 |
| Amélioration taux remplissage (+10% sur CA) | 3 000 000 |
| Réduction abandons (rétention +5% apprenants) | 1 500 000 |
| **Total gains** | **5 460 000** |

**Retour sur investissement estimé : moins de 13 mois**

### Verdict financier : **VIABLE**

---

## 4. Conclusion

Le projet est faisable sur les trois dimensions analysées. Les prérequis techniques sont satisfaits avec des adaptations mineures. L'organisation dispose des ressources humaines nécessaires avec un accompagnement limité. Le ROI est positif en moins d'un an.

**Recommandation : lancer le projet en Phase 1 (périmètre pilotage pédagogique) puis étendre au pilotage financier en Phase 2.**
