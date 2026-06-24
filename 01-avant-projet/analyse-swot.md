# Analyse SWOT — Projet BI Secteur Formation (Afrique centrale)

## Matrice SWOT

|  | Favorable | Défavorable |
|---|---|---|
| **Interne** | Forces | Faiblesses |
| **Externe** | Opportunités | Menaces |

---

## Forces (Strengths)

### Données existantes
La plateforme dispose déjà de données structurées dans SQL Server (inscriptions, résultats). La base est suffisante pour démarrer sans phase de collecte longue.

### Engagement de la direction
La direction générale est convaincue de la valeur du projet et a désigné un sponsor interne. Cela garantit le budget et la mobilisation des équipes.

### Stack Microsoft existante
L'organisation utilise déjà Microsoft 365. Power BI Pro est accessible sans nouvel investissement en infrastructure. La courbe d'apprentissage est réduite pour les utilisateurs habitués à Excel.

### Cas d'usage concrets et immédiats
Les problèmes à résoudre (rapports manuels, abandons non détectés) sont bien documentés et quantifiés. Le projet a un périmètre clair dès le départ.

### Expertise consultant disponible
Le consultant en charge maîtrise Power BI, DAX, SQL Server et Python — toute la stack nécessaire est couverte sans sous-traitance.

---

## Faiblesses (Weaknesses)

### Qualité des données incomplète
Une partie des données de présence est encore sur papier. Un audit de qualité des données révèle des lacunes sur les années antérieures à 2023.

### Maturité numérique variable des équipes
Certains formateurs et responsables de formation ont une faible culture numérique. L'adoption de Power BI nécessitera un effort de formation soutenu.

### Absence de gouvernance de la donnée
Il n'existe pas de définitions partagées des indicateurs : le taux de complétion n'est pas calculé de la même façon par la direction pédagogique et par la direction financière.

### Dépendance à un seul référent IT
L'unique responsable informatique cumule plusieurs rôles. Sa disponibilité sur le projet est contrainte, ce qui peut allonger les délais.

### Données satisfaction non centralisées
Les feedbacks apprenants sont collectés par plusieurs canaux (formulaires papier, Google Forms, WhatsApp) sans processus unifié.

---

## Opportunités (Opportunities)

### Croissance du marché de la formation en Afrique centrale
Le secteur de la formation professionnelle est en forte croissance dans la zone CEMAC, porté par les politiques de développement des compétences et les financements publics. Un pilotage data-driven renforce la crédibilité auprès des bailleurs.

### Numérisation accélérée post-COVID
Les organisations africaines ont accéléré leur transformation numérique. La demande en formations certifiantes (notamment en IT et gestion) est en hausse, augmentant le volume de données à analyser.

### Accès aux financements pour l'innovation
Des fonds de développement (Banque mondiale, AFD, partenaires bilatéraux) financent des projets de modernisation de l'éducation et de la formation. Un système BI robuste facilite le reporting vers ces bailleurs.

### Benchmarking régional
Peu de plateformes de formation en Afrique centrale disposent d'un système BI mature. Se doter de cet avantage positionne favorablement face à la concurrence régionale.

### Évolution vers la formation hybride
La montée de l'enseignement à distance génère de nouvelles données (temps de connexion, progression en ligne, quiz interactifs) qui enrichiront les tableaux de bord futurs.

---

## Menaces (Threats)

### Instabilité de la connectivité Internet
La qualité de la connexion Internet peut varier à Brazzaville et dans les villes secondaires, ce qui peut affecter l'accès au Power BI Service en ligne. Une solution de consultation offline doit être prévue.

### Turnover du personnel clé
En cas de départ du directeur pédagogique (sponsor interne) ou du référent IT, le projet peut perdre son ancrage organisationnel. La documentation et la formation doivent être mutualisées.

### Résistance des formateurs
Certains formateurs peuvent percevoir le tableau de bord de performance comme un outil de surveillance plutôt que d'aide. Une communication adaptée est nécessaire.

### Coût des licences en devise
Les licences Power BI Pro sont facturées en USD. Les fluctuations de change peuvent augmenter le coût annuel de maintenance au-delà du budget prévu.

### Concurrence des solutions gratuites
Des outils gratuits (Metabase, Google Looker Studio) peuvent être proposés par d'autres prestataires. Ils offrent moins de fonctionnalités mais peuvent influencer le choix budgétaire.

---

## Matrice de priorités stratégiques

| Stratégie SO (Forces × Opportunités) | Exploiter les données existantes + croissance du marché pour lancer rapidement un MVP BI |
|---|---|
| **Stratégie ST (Forces × Menaces)** | Utiliser la stack Microsoft pour prévoir des exports offline et réduire la dépendance Internet |
| **Stratégie WO (Faiblesses × Opportunités)** | Profiter du contexte de numérisation pour obtenir un financement de la phase de nettoyage des données |
| **Stratégie WT (Faiblesses × Menaces)** | Documenter minutieusement et former plusieurs référents pour éviter la dépendance à une seule personne |
