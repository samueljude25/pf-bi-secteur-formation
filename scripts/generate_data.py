#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_data.py
================
Script de génération de données fictives pour la plateforme de formation professionnelle.
Génère tous les fichiers CSV du projet BI avec des données réalistes (Afrique centrale).

Usage :
    pip install -r requirements.txt
    python generate_data.py

Sortie :
    Crée les fichiers CSV dans le dossier ../data/ relatif à ce script.

Auteur : Portfolio BI — Samuel Jude Sendzi
"""

import os
import random
import pandas as pd
import numpy as np
from datetime import date, timedelta
from faker import Faker

# --------------------------------------------------------------------------- #
# Configuration
# --------------------------------------------------------------------------- #

SEED = 42                       # Graine pour la reproductibilité
NB_APPRENANTS = 50
NB_FORMATIONS = 10
NB_MODULES = 30
NB_INTERVENANTS = 10
NB_INSCRIPTIONS = 150
NB_EVALUATIONS = 120            # Maximum (certaines inscriptions pas encore évaluées)

# Dossier de sortie (../data/ depuis le script)
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(SCRIPT_DIR, '..', 'data')
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Initialisation de Faker (locale française) et graine aléatoire
fake = Faker('fr_FR')
Faker.seed(SEED)
random.seed(SEED)
np.random.seed(SEED)

# --------------------------------------------------------------------------- #
# Données de référence — noms et prénoms congolais/africains
# --------------------------------------------------------------------------- #

NOMS_CONGOLAIS = [
    'Mabiala', 'Nkounkou', 'Moukassa', 'Bouanga', 'Loemba',
    'Makosso', 'Nzaba', 'Ibara', 'Taty', 'Mountsaka',
    'Ngoma', 'Mabika', 'Paka', 'Louzolo', 'Moukagni',
    'Nzouzi', 'Biyoudi', 'Gandzion', 'Mpassi', 'Loubelo',
    'Ngakosso', 'Mboungou', 'Tchilouta', 'Nkeoua', 'Massamba',
    'Koubemba', 'Odzoki', 'Bitemo', 'Moundzeo', 'Nguimbi',
    'Kokolo', 'Bakala', 'Nzolani', 'Mouele', 'Kivoukissa',
    'Loukabou', 'Ntsikie', 'Mouanga', 'Makaya', 'Bafounga',
    'Maboukou', 'Nkengue', 'Tchikaya', 'Goma', 'Nkouka',
    'Moutsinga', 'Mbemba', 'Bahamboula', 'Moulengui', 'Lekouaghet',
]

PRENOMS_MASCULINS = [
    'Jean-Paul', 'Emmanuel', 'Patrick', 'Roland', 'Bertrand',
    'Théophile', 'Albert', 'Hervé', 'Marc', 'Cédric',
    'Wilfried', 'Gaston', 'Junior', 'Franck', 'Éric',
    'Stéphane', 'Ghislain', 'Damien', 'Rémy', 'Noël',
    'Arsène', 'Henri', 'Fernand', 'Thierry', 'Simon',
    'Rodrigue', 'Prosper', 'Vianney', 'Serge', 'Didier',
]

PRENOMS_FEMININS = [
    'Marie-Claire', 'Grâce', 'Christelle', 'Solange', 'Elise',
    'Sandra', 'Fatima', 'Aurélie', 'Prisca', 'Vanessa',
    'Laetitia', 'Blanche', 'Nadège', 'Rachel', 'Anastasie',
    'Florence', 'Jocelyne', 'Sylvie', 'Yvette', 'Claire',
    'Delphine', 'Bernadette', 'Isabelle', 'Carole', 'Joëlle',
    'Angélique', 'Patricia', 'Félicité', 'Nadine', 'Brigitte',
]

VILLES_CONGO = [
    'Brazzaville', 'Pointe-Noire', 'Dolisie', 'Nkayi',
    'Impfondo', 'Ouesso', 'Madingou', 'Sibiti',
]

VILLES_ETRANGERES = ['Kinshasa', 'Libreville', 'Douala', 'Yaoundé']

PAYS = {
    'Brazzaville': 'Congo', 'Pointe-Noire': 'Congo', 'Dolisie': 'Congo',
    'Nkayi': 'Congo', 'Impfondo': 'Congo', 'Ouesso': 'Congo',
    'Madingou': 'Congo', 'Sibiti': 'Congo',
    'Kinshasa': 'RDC', 'Libreville': 'Gabon',
    'Douala': 'Cameroun', 'Yaoundé': 'Cameroun',
}

NIVEAUX_ETUDE = ['Bac', 'BTS', 'Licence', 'Master']
NIVEAUX_POIDS = [0.10, 0.25, 0.40, 0.25]  # Distribution réaliste

CATEGORIES_FORMATIONS = [
    'Informatique', 'Data & IA', 'Management', 'Finance',
    'Marketing', 'Business', 'Bureautique', 'Langues',
]

NIVEAUX_FORMATIONS = ['Débutant', 'Intermédiaire', 'Avancé']

MODES_PAIEMENT = ['Mobile Money', 'Virement', 'Espèces']
MODES_PAIEMENT_POIDS = [0.50, 0.30, 0.20]

SOURCES_ACQUISITION = ['Réseaux sociaux', 'Site web', 'Bouche à oreille', 'Partenaire']
SOURCES_POIDS = [0.35, 0.30, 0.25, 0.10]

STATUTS_INSCRIPTION = ['Terminé', 'En cours', 'Abandonné']
STATUTS_POIDS = [0.72, 0.20, 0.08]

DATE_MIN = date(2024, 1, 1)
DATE_MAX = date(2025, 12, 31)


# --------------------------------------------------------------------------- #
# Fonctions utilitaires
# --------------------------------------------------------------------------- #

def date_aleatoire(date_min: date, date_max: date) -> date:
    """Génère une date aléatoire entre date_min et date_max."""
    delta = (date_max - date_min).days
    return date_min + timedelta(days=random.randint(0, delta))


def telephone_congo() -> str:
    """Génère un numéro de téléphone congolais réaliste."""
    prefixes = ['064', '055', '066', '054', '067', '058', '069', '051', '062', '053']
    return f"+242{random.choice(prefixes)}{random.randint(100000, 999999)}"


def email_professionnel(prenom: str, nom: str, idx: int) -> str:
    """Génère un email à partir du prénom et nom."""
    prenom_clean = prenom.lower().split('-')[0].replace('é', 'e').replace('è', 'e') \
                   .replace('ê', 'e').replace('à', 'a').replace('ô', 'o')
    nom_clean = nom.lower()
    domaines = ['email.com', 'gmail.com', 'yahoo.fr', 'hotmail.fr']
    domaine = domaines[idx % len(domaines)]
    return f"{prenom_clean[0]}.{nom_clean}{idx if idx > 1 else ''}@{domaine}"


# --------------------------------------------------------------------------- #
# Génération des apprenants
# --------------------------------------------------------------------------- #

def generer_apprenants(n: int = NB_APPRENANTS) -> pd.DataFrame:
    """Génère n apprenants fictifs avec noms africains/congolais."""
    print(f"  Génération de {n} apprenants...")

    rows = []
    noms_utilises = set()

    for i in range(1, n + 1):
        sexe = random.choice(['M', 'F'])
        nom = NOMS_CONGOLAIS[(i - 1) % len(NOMS_CONGOLAIS)]

        if sexe == 'M':
            prenom = PRENOMS_MASCULINS[i % len(PRENOMS_MASCULINS)]
        else:
            prenom = PRENOMS_FEMININS[i % len(PRENOMS_FEMININS)]

        ville = random.choices(
            VILLES_CONGO + VILLES_ETRANGERES,
            weights=[8, 4, 2, 1, 1, 1, 1, 1, 2, 1, 1, 1],
            k=1
        )[0]

        date_naissance = date(
            random.randint(1988, 2002),
            random.randint(1, 12),
            random.randint(1, 28)
        )

        date_inscription = date_aleatoire(DATE_MIN, date(2025, 6, 30))

        rows.append({
            'apprenant_id': i,
            'nom': nom,
            'prenom': prenom,
            'email': email_professionnel(prenom, nom, i),
            'telephone': telephone_congo(),
            'ville': ville,
            'pays': PAYS.get(ville, 'Congo'),
            'date_naissance': date_naissance.isoformat(),
            'sexe': sexe,
            'niveau_etude': random.choices(NIVEAUX_ETUDE, weights=NIVEAUX_POIDS, k=1)[0],
            'date_inscription_plateforme': date_inscription.isoformat(),
        })

    return pd.DataFrame(rows)


# --------------------------------------------------------------------------- #
# Génération des intervenants
# --------------------------------------------------------------------------- #

def generer_intervenants(n: int = NB_INTERVENANTS) -> pd.DataFrame:
    """Génère n formateurs/intervenants fictifs."""
    print(f"  Génération de {n} intervenants...")

    specialites = [
        ('Développement Web & Mobile', 75000),
        ('Data Science & BI', 85000),
        ('Management de Projet', 80000),
        ('Finance & Comptabilité', 70000),
        ('Marketing Digital', 65000),
        ('Entrepreneuriat & Business', 72000),
        ('Langues & Communication', 55000),
        ('Ressources Humaines', 68000),
        ('Logistique & Supply Chain', 73000),
        ('Bureautique & Outils Digitaux', 50000),
    ]

    noms_intervenants = [
        ('Ndoumbe', 'Alex', 'M'),
        ('Mvioki', 'Sarah', 'F'),
        ('Bouesso', 'Théodore', 'M'),
        ('Elenga', 'Patricia', 'F'),
        ('Nkabi', 'Joël', 'M'),
        ('Moussoki', 'Angélique', 'F'),
        ('Tsoumou', 'Richard', 'M'),
        ('Mongo', 'Nadine', 'F'),
        ('Lekouaghet', 'Bruno', 'M'),
        ('Koumou', 'Félicité', 'F'),
    ]

    rows = []
    for i in range(1, min(n, len(specialites)) + 1):
        nom, prenom, sexe = noms_intervenants[i - 1]
        specialite, tarif_base = specialites[i - 1]
        experience = random.randint(5, 15)
        note = round(random.uniform(4.0, 4.9), 1)

        rows.append({
            'intervenant_id': i,
            'nom': nom,
            'prenom': prenom,
            'email': f"{prenom[0].lower()}.{nom.lower()}@formateur.com",
            'specialite': specialite,
            'experience_annees': experience,
            'tarif_journalier_xaf': tarif_base + random.randint(-5000, 5000),
            'ville': random.choice(['Brazzaville', 'Pointe-Noire', 'Brazzaville', 'Dolisie']),
            'pays': 'Congo',
            'note_moyenne': note,
            'nb_formations_animees': random.randint(7, 25),
            'biographie_courte': (
                f"Expert en {specialite} avec {experience} ans d'expérience. "
                f"Formateur certifié spécialisé dans le développement des compétences "
                f"professionnelles en Afrique centrale."
            ),
        })

    return pd.DataFrame(rows)


# --------------------------------------------------------------------------- #
# Génération des formations
# --------------------------------------------------------------------------- #

def generer_formations(intervenants_df: pd.DataFrame) -> pd.DataFrame:
    """Génère les formations fictives du catalogue."""
    print(f"  Génération de {NB_FORMATIONS} formations...")

    catalogue = [
        {
            'formation_id': 1,
            'titre': 'Développement Web Full Stack',
            'categorie': 'Informatique',
            'description': 'Maîtrisez HTML/CSS/JavaScript et les frameworks modernes pour créer des applications web complètes.',
            'duree_heures': 120,
            'prix_xaf': 150000,
            'niveau': 'Intermédiaire',
            'intervenant_principal_id': 1,
            'date_creation': '2024-01-01',
            'statut': 'Actif',
            'nb_places_max': 30,
            'certification': 'Oui',
        },
        {
            'formation_id': 2,
            'titre': 'Data Analyst avec Python',
            'categorie': 'Data & IA',
            'description': 'Analysez et visualisez des données avec Python (Pandas, NumPy, Matplotlib, Seaborn).',
            'duree_heures': 80,
            'prix_xaf': 120000,
            'niveau': 'Intermédiaire',
            'intervenant_principal_id': 2,
            'date_creation': '2024-01-01',
            'statut': 'Actif',
            'nb_places_max': 25,
            'certification': 'Oui',
        },
        {
            'formation_id': 3,
            'titre': 'Gestion de Projet Agile',
            'categorie': 'Management',
            'description': 'Maîtrisez les méthodologies Scrum et Kanban pour piloter vos projets digitaux.',
            'duree_heures': 40,
            'prix_xaf': 80000,
            'niveau': 'Débutant',
            'intervenant_principal_id': 3,
            'date_creation': '2024-01-01',
            'statut': 'Actif',
            'nb_places_max': 35,
            'certification': 'Oui',
        },
        {
            'formation_id': 4,
            'titre': "Comptabilité et Finance d'Entreprise",
            'categorie': 'Finance',
            'description': "Fondamentaux de la comptabilité générale et de la gestion financière adaptés au contexte africain.",
            'duree_heures': 60,
            'prix_xaf': 100000,
            'niveau': 'Débutant',
            'intervenant_principal_id': 4,
            'date_creation': '2024-01-15',
            'statut': 'Actif',
            'nb_places_max': 30,
            'certification': 'Non',
        },
        {
            'formation_id': 5,
            'titre': 'Marketing Digital et Réseaux Sociaux',
            'categorie': 'Marketing',
            'description': 'Stratégie digitale, community management, publicité en ligne et analytics.',
            'duree_heures': 50,
            'prix_xaf': 90000,
            'niveau': 'Débutant',
            'intervenant_principal_id': 5,
            'date_creation': '2024-01-15',
            'statut': 'Actif',
            'nb_places_max': 40,
            'certification': 'Oui',
        },
        {
            'formation_id': 6,
            'titre': 'Power BI et Business Intelligence',
            'categorie': 'Data & IA',
            'description': 'Créez des tableaux de bord interactifs et maîtrisez la visualisation de données professionnelle.',
            'duree_heures': 60,
            'prix_xaf': 130000,
            'niveau': 'Intermédiaire',
            'intervenant_principal_id': 2,
            'date_creation': '2024-02-01',
            'statut': 'Actif',
            'nb_places_max': 20,
            'certification': 'Oui',
        },
        {
            'formation_id': 7,
            'titre': 'Administration Réseau et Cybersécurité',
            'categorie': 'Informatique',
            'description': "Sécurisez vos infrastructures réseau et protégez vos systèmes d'information.",
            'duree_heures': 90,
            'prix_xaf': 140000,
            'niveau': 'Avancé',
            'intervenant_principal_id': 1,
            'date_creation': '2024-02-01',
            'statut': 'Actif',
            'nb_places_max': 20,
            'certification': 'Oui',
        },
        {
            'formation_id': 8,
            "titre": "Entrepreneuriat et Création d'Entreprise",
            'categorie': 'Business',
            "description": "De l'idée à l'entreprise : business plan, financement et stratégie de lancement.",
            'duree_heures': 45,
            'prix_xaf': 70000,
            'niveau': 'Débutant',
            'intervenant_principal_id': 6,
            'date_creation': '2024-03-01',
            'statut': 'Actif',
            'nb_places_max': 50,
            'certification': 'Non',
        },
        {
            'formation_id': 9,
            'titre': 'Excel Avancé pour les Professionnels',
            'categorie': 'Bureautique',
            'description': 'Fonctions avancées, tableaux croisés dynamiques, macros VBA et automatisation.',
            'duree_heures': 30,
            'prix_xaf': 50000,
            'niveau': 'Intermédiaire',
            'intervenant_principal_id': 10,
            'date_creation': '2024-03-01',
            'statut': 'Actif',
            'nb_places_max': 40,
            'certification': 'Non',
        },
        {
            'formation_id': 10,
            'titre': "Anglais Professionnel des Affaires",
            'categorie': 'Langues',
            "description": "Communication professionnelle en anglais pour le monde des affaires et des négociations.",
            'duree_heures': 40,
            'prix_xaf': 60000,
            'niveau': 'Débutant',
            'intervenant_principal_id': 7,
            'date_creation': '2024-04-01',
            'statut': 'Actif',
            'nb_places_max': 35,
            'certification': 'Oui',
        },
    ]

    return pd.DataFrame(catalogue)


# --------------------------------------------------------------------------- #
# Génération des modules
# --------------------------------------------------------------------------- #

def generer_modules() -> pd.DataFrame:
    """Génère 3 modules par formation (simplifié pour la démo)."""
    print(f"  Génération de {NB_MODULES} modules...")

    modules_catalogue = [
        # Formation 1 : Développement Web Full Stack
        (1, 1, 'Introduction au HTML et CSS', 1, 12, 'Balises HTML5 sémantiques et stylisation CSS3 responsive design', 'Vidéo + TP', 'Oui'),
        (2, 1, 'JavaScript Fondamentaux', 2, 16, 'Variables, fonctions, DOM et événements', 'Vidéo + TP', 'Oui'),
        (3, 1, 'Framework React.js', 3, 20, 'Composants, hooks, state management et API REST', 'Vidéo + Projet', 'Oui'),
        (4, 1, 'Base de données et SQL', 4, 14, 'Modélisation relationnelle, MySQL et requêtes avancées', 'Vidéo + TP', 'Oui'),
        (5, 1, 'Déploiement et DevOps', 5, 10, 'Git, CI/CD, déploiement cloud et bonnes pratiques', 'Vidéo + TP', 'Non'),
        # Formation 2 : Data Analyst
        (6, 2, "Python pour l'Analyse de Données", 1, 16, 'Environnement Python, Jupyter, Pandas et NumPy', 'Vidéo + TP', 'Oui'),
        (7, 2, 'Visualisation avec Matplotlib et Seaborn', 2, 14, 'Graphiques statistiques et storytelling', 'Vidéo + Projet', 'Oui'),
        (8, 2, 'Statistiques Descriptives et Inférentielles', 3, 18, 'Moyenne, médiane, écart-type, tests d\'hypothèse', 'Vidéo + TP', 'Oui'),
        (9, 2, "SQL pour l'Analyse de Données", 4, 16, 'Requêtes complexes, agrégations et fenêtres analytiques', 'Vidéo + TP', 'Oui'),
        (10, 2, 'Introduction au Machine Learning', 5, 16, 'Régression, classification et clustering avec Scikit-learn', 'Vidéo + Projet', 'Non'),
        # Formation 3 : Gestion de Projet Agile
        (11, 3, 'Fondamentaux du Management de Projet', 1, 8, 'Cycle de vie, parties prenantes et livrables', 'Vidéo + Quiz', 'Oui'),
        (12, 3, 'Méthodologie Scrum', 2, 12, 'Rôles, cérémonies, backlog et sprint', 'Vidéo + TP', 'Oui'),
        (13, 3, 'Kanban et Lean Management', 3, 10, 'Flux de travail, WIP, kaizen et métriques', 'Vidéo + TP', 'Oui'),
        (14, 3, 'Outils de Gestion (Jira, Trello)', 4, 10, 'Configuration, reporting automatisé et intégrations', 'Vidéo + TP', 'Non'),
        # Formation 4 : Comptabilité
        (15, 4, 'Comptabilité Générale OHADA', 1, 20, 'Plan comptable OHADA, journal, grand livre et balance', 'Vidéo + TP', 'Oui'),
        (16, 4, 'États Financiers et Analyse', 2, 18, 'Bilan, compte de résultat, flux de trésorerie et ratios', 'Vidéo + Cas', 'Oui'),
        (17, 4, 'Fiscalité et Obligations Légales Congo', 3, 12, 'TVA, impôt sur les sociétés, obligations déclaratives', 'Vidéo + Quiz', 'Oui'),
        (18, 4, 'Gestion Budgétaire et Prévisions', 4, 10, 'Construction du budget, contrôle et révisions', 'Vidéo + Projet', 'Non'),
        # Formation 5 : Marketing Digital
        (19, 5, 'Stratégie de Présence Digitale', 1, 10, 'Audit digital, positionnement et plan d\'action marketing', 'Vidéo + TP', 'Oui'),
        (20, 5, 'Gestion des Réseaux Sociaux', 2, 14, 'Facebook, Instagram, LinkedIn, TikTok et stratégie de contenu', 'Vidéo + TP', 'Oui'),
        (21, 5, 'Google Ads et Meta Ads', 3, 14, 'Création de campagnes, ciblage, budget et optimisation ROI', 'Vidéo + Projet', 'Oui'),
        (22, 5, 'Analytics et Mesure de Performance', 4, 12, 'Google Analytics 4, KPIs, tableaux de bord et A/B testing', 'Vidéo + TP', 'Non'),
        # Formation 6 : Power BI
        (23, 6, 'Introduction à la Business Intelligence', 1, 10, 'Concepts ETL, entrepôt de données et rapport décisionnel', 'Vidéo + Quiz', 'Oui'),
        (24, 6, 'Power Query et Transformation des Données', 2, 15, 'Import, nettoyage, fusion et transformation des données', 'Vidéo + TP', 'Oui'),
        (25, 6, 'Modélisation de Données Power BI', 3, 15, 'Schéma en étoile, relations et bonnes pratiques DAX', 'Vidéo + TP', 'Oui'),
        (26, 6, 'DAX et Mesures Avancées', 4, 20, 'Fonctions CALCULATE, FILTER et mesures contextuelles', 'Vidéo + Projet', 'Oui'),
        # Formation 7 : Cybersécurité
        (27, 7, 'Réseaux TCP/IP et Infrastructure', 1, 20, 'Modèle OSI, adressage IP, routage et commutation', 'Vidéo + TP', 'Oui'),
        (28, 7, "Sécurité des Systèmes d'Information", 2, 25, 'Menaces, vulnérabilités, pare-feu et chiffrement', 'Vidéo + TP', 'Oui'),
        (29, 7, 'Administration Linux et Windows Server', 3, 25, 'Installation, configuration, services réseau et supervision', 'Vidéo + Projet', 'Oui'),
        (30, 7, 'Certification et Conformité', 4, 20, 'ISO 27001, RGPD et audit de sécurité', 'Vidéo + Cas', 'Non'),
    ]

    colonnes = ['module_id', 'formation_id', 'titre', 'ordre', 'duree_heures',
                'description', 'type_contenu', 'obligatoire']
    return pd.DataFrame(modules_catalogue, columns=colonnes)


# --------------------------------------------------------------------------- #
# Génération des inscriptions
# --------------------------------------------------------------------------- #

def generer_inscriptions(
    apprenants_df: pd.DataFrame,
    formations_df: pd.DataFrame,
    n: int = NB_INSCRIPTIONS
) -> pd.DataFrame:
    """Génère n inscriptions fictives avec des données cohérentes."""
    print(f"  Génération de {n} inscriptions...")

    prix_map = dict(zip(formations_df['formation_id'], formations_df['prix_xaf']))
    rows = []
    paires_utilisees = set()

    for i in range(1, n + 1):
        # Éviter les doublons (apprenant × formation)
        tentatives = 0
        while tentatives < 100:
            apprenant_id = random.randint(1, len(apprenants_df))
            formation_id = random.randint(1, len(formations_df))
            paire = (apprenant_id, formation_id)
            if paire not in paires_utilisees:
                paires_utilisees.add(paire)
                break
            tentatives += 1

        statut = random.choices(STATUTS_INSCRIPTION, weights=STATUTS_POIDS, k=1)[0]

        # Dates cohérentes
        date_inscription = date_aleatoire(DATE_MIN, date(2025, 5, 31))
        date_debut = date_inscription + timedelta(days=random.randint(5, 20))

        formation_row = formations_df[formations_df['formation_id'] == formation_id].iloc[0]
        duree_prevue_jours = int(formation_row['duree_heures'] * 3.5)  # ~3.5j par heure de cours
        date_fin_prevue = date_debut + timedelta(days=duree_prevue_jours)

        if statut == 'Terminé':
            variation_jours = random.randint(-10, 15)
            date_fin_reelle = date_fin_prevue + timedelta(days=variation_jours)
            date_fin_reelle_str = date_fin_reelle.isoformat()
            taux_completion = 100
        elif statut == 'En cours':
            date_fin_reelle_str = ''
            taux_completion = random.randint(20, 85)
        else:  # Abandonné
            date_fin_reelle_str = ''
            taux_completion = random.randint(5, 40)

        prix = prix_map[formation_id]
        if statut == 'Abandonné':
            # Remboursement partiel ou pas de paiement pour abandon
            montant = random.choices([0, prix // 2], weights=[0.6, 0.4], k=1)[0]
        elif statut == 'En cours':
            # Acompte ou paiement complet
            montant = random.choices([prix // 2, prix], weights=[0.3, 0.7], k=1)[0]
        else:
            montant = prix

        rows.append({
            'inscription_id': i,
            'apprenant_id': apprenant_id,
            'formation_id': formation_id,
            'date_inscription': date_inscription.isoformat(),
            'date_debut': date_debut.isoformat(),
            'date_fin_prevue': date_fin_prevue.isoformat(),
            'date_fin_reelle': date_fin_reelle_str,
            'statut': statut,
            'taux_completion_pct': taux_completion,
            'montant_paye_xaf': montant,
            'mode_paiement': random.choices(MODES_PAIEMENT, weights=MODES_PAIEMENT_POIDS, k=1)[0],
            'source_acquisition': random.choices(SOURCES_ACQUISITION, weights=SOURCES_POIDS, k=1)[0],
        })

    return pd.DataFrame(rows)


# --------------------------------------------------------------------------- #
# Génération des évaluations
# --------------------------------------------------------------------------- #

def generer_evaluations(
    inscriptions_df: pd.DataFrame,
    formations_df: pd.DataFrame,
    n: int = NB_EVALUATIONS
) -> pd.DataFrame:
    """Génère les évaluations pour les inscriptions terminées."""
    print(f"  Génération de {n} évaluations...")

    # Seules les inscriptions terminées peuvent être évaluées
    terminees = inscriptions_df[inscriptions_df['statut'] == 'Terminé'].copy()

    # Sélectionner un sous-ensemble aléatoire pour l'évaluation
    nb_eval = min(n, len(terminees))
    terminees_sample = terminees.sample(n=nb_eval, random_state=SEED)

    # Mapping formation -> intervenant principal
    formation_intervenant = dict(
        zip(formations_df['formation_id'], formations_df['intervenant_principal_id'])
    )

    commentaires_positifs = [
        "Formation excellente ! Le contenu est très pratique et directement applicable.",
        "Formateur exceptionnel, pédagogue et disponible. Je recommande vivement.",
        "Formation complète qui m'a permis de faire évoluer ma carrière rapidement.",
        "Très bonne formation, les cas pratiques sur le contexte africain sont parfaits.",
        "Contenu de haute qualité et bien structuré. Bravo à toute l'équipe.",
        "Formation transformante. J'ai enfin les compétences pour réaliser mes projets.",
        "Le meilleur investissement formation que j'ai fait. Retour sur investissement rapide.",
        "Formation adaptée aux réalités du marché congolais. Très pertinente et utile.",
        "Contenu riche, formateur passionné. L'environnement d'apprentissage est excellent.",
        "Formation qui tient ses promesses. Objectifs pédagogiques 100% atteints.",
    ]

    commentaires_moyens = [
        "Bonne formation dans l'ensemble, quelques modules pourraient être plus approfondis.",
        "Formation correcte mais j'attendais plus d'exemples pratiques locaux.",
        "Bon contenu général, le rythme pourrait être mieux adapté aux débutants.",
        "Formation satisfaisante. Les exercices pratiques sont pertinents.",
        "Contenu solide mais la plateforme nécessite quelques améliorations UX.",
    ]

    commentaires_negatifs = [
        "Formation trop rapide sur certains modules importants. Déçu par le rythme.",
        "Contenu à mettre à jour. Certaines sections sont obsolètes.",
        "Rapport qualité/prix à revoir. Trop cher pour le contenu proposé.",
    ]

    rows = []
    for idx, (_, insc) in enumerate(terminees_sample.iterrows()):
        # Distribution réaliste des notes : tendance vers le haut (4-5 dominant)
        note_globale = random.choices([1, 2, 3, 4, 5], weights=[0.02, 0.03, 0.10, 0.35, 0.50], k=1)[0]

        # Notes corrélées à la note globale (±1)
        def note_correlee(base):
            variation = random.randint(-1, 1)
            return max(1, min(5, base + variation))

        note_contenu = note_correlee(note_globale)
        note_intervenant = note_correlee(note_globale)
        note_plateforme = note_correlee(note_globale)
        note_qp = note_correlee(note_globale)

        # NPS corrélé à la note globale
        if note_globale == 5:
            nps = random.choices([9, 10], weights=[0.4, 0.6], k=1)[0]
            recommande = 'Oui'
            commentaire = random.choice(commentaires_positifs)
        elif note_globale == 4:
            nps = random.choices([7, 8, 9], weights=[0.2, 0.5, 0.3], k=1)[0]
            recommande = 'Oui'
            commentaire = random.choice(commentaires_positifs[:5] + commentaires_moyens)
        elif note_globale == 3:
            nps = random.choices([5, 6, 7], weights=[0.3, 0.4, 0.3], k=1)[0]
            recommande = random.choice(['Oui', 'Neutre', 'Neutre'])
            commentaire = random.choice(commentaires_moyens)
        else:
            nps = random.choices([2, 3, 4, 5], weights=[0.2, 0.3, 0.3, 0.2], k=1)[0]
            recommande = 'Non'
            commentaire = random.choice(commentaires_negatifs)

        # Date d'évaluation = quelques jours après la fin de formation
        date_fin_str = insc['date_fin_reelle']
        if date_fin_str:
            date_fin_reelle = date.fromisoformat(date_fin_str)
            date_eval = date_fin_reelle + timedelta(days=random.randint(1, 10))
        else:
            date_eval = date_aleatoire(DATE_MIN, DATE_MAX)

        formation_id = int(insc['formation_id'])

        rows.append({
            'evaluation_id': idx + 1,
            'inscription_id': int(insc['inscription_id']),
            'apprenant_id': int(insc['apprenant_id']),
            'formation_id': formation_id,
            'intervenant_id': formation_intervenant.get(formation_id, 1),
            'date_evaluation': date_eval.isoformat(),
            'note_globale': note_globale,
            'note_contenu': note_contenu,
            'note_intervenant': note_intervenant,
            'note_plateforme': note_plateforme,
            'note_rapport_qualite_prix': note_qp,
            'commentaire': commentaire,
            'recommande': recommande,
            'nps_score': nps,
        })

    return pd.DataFrame(rows)


# --------------------------------------------------------------------------- #
# Fonction principale
# --------------------------------------------------------------------------- #

def main():
    """Fonction principale : génère et exporte tous les fichiers CSV."""
    print("\n" + "=" * 60)
    print("  GÉNÉRATEUR DE DONNÉES — Plateforme de Formation Pro")
    print("  Portfolio BI — Samuel Jude Sendzi")
    print("=" * 60)
    print(f"\nDossier de sortie : {os.path.abspath(OUTPUT_DIR)}\n")

    # 1. Apprenants
    print("[1/6] Apprenants")
    apprenants_df = generer_apprenants(NB_APPRENANTS)
    path = os.path.join(OUTPUT_DIR, 'apprenants.csv')
    apprenants_df.to_csv(path, index=False, encoding='utf-8-sig')
    print(f"  -> {len(apprenants_df)} lignes exportées vers {path}")

    # 2. Intervenants
    print("\n[2/6] Intervenants")
    intervenants_df = generer_intervenants(NB_INTERVENANTS)
    path = os.path.join(OUTPUT_DIR, 'intervenants.csv')
    intervenants_df.to_csv(path, index=False, encoding='utf-8-sig')
    print(f"  -> {len(intervenants_df)} lignes exportées vers {path}")

    # 3. Formations
    print("\n[3/6] Formations")
    formations_df = generer_formations(intervenants_df)
    path = os.path.join(OUTPUT_DIR, 'formations.csv')
    formations_df.to_csv(path, index=False, encoding='utf-8-sig')
    print(f"  -> {len(formations_df)} lignes exportées vers {path}")

    # 4. Modules
    print("\n[4/6] Modules")
    modules_df = generer_modules()
    path = os.path.join(OUTPUT_DIR, 'modules.csv')
    modules_df.to_csv(path, index=False, encoding='utf-8-sig')
    print(f"  -> {len(modules_df)} lignes exportées vers {path}")

    # 5. Inscriptions
    print("\n[5/6] Inscriptions")
    inscriptions_df = generer_inscriptions(apprenants_df, formations_df, NB_INSCRIPTIONS)
    path = os.path.join(OUTPUT_DIR, 'inscriptions.csv')
    inscriptions_df.to_csv(path, index=False, encoding='utf-8-sig')
    print(f"  -> {len(inscriptions_df)} lignes exportées vers {path}")

    # 6. Évaluations
    print("\n[6/6] Évaluations")
    evaluations_df = generer_evaluations(inscriptions_df, formations_df, NB_EVALUATIONS)
    path = os.path.join(OUTPUT_DIR, 'evaluations.csv')
    evaluations_df.to_csv(path, index=False, encoding='utf-8-sig')
    print(f"  -> {len(evaluations_df)} lignes exportées vers {path}")

    # Résumé statistique
    print("\n" + "=" * 60)
    print("  RÉSUMÉ DES DONNÉES GÉNÉRÉES")
    print("=" * 60)
    print(f"  Apprenants      : {len(apprenants_df):>6}")
    print(f"  Intervenants    : {len(intervenants_df):>6}")
    print(f"  Formations      : {len(formations_df):>6}")
    print(f"  Modules         : {len(modules_df):>6}")
    print(f"  Inscriptions    : {len(inscriptions_df):>6}")
    print(f"    - Terminées   : {len(inscriptions_df[inscriptions_df['statut']=='Terminé']):>6}")
    print(f"    - En cours    : {len(inscriptions_df[inscriptions_df['statut']=='En cours']):>6}")
    print(f"    - Abandonnées : {len(inscriptions_df[inscriptions_df['statut']=='Abandonné']):>6}")
    print(f"  Évaluations     : {len(evaluations_df):>6}")
    revenus_totaux = inscriptions_df['montant_paye_xaf'].sum()
    print(f"  Revenus totaux  : {revenus_totaux:>10,} XAF")
    note_moy = evaluations_df['note_globale'].mean()
    print(f"  Note moy. glob. : {note_moy:>8.2f} / 5")
    print("\nGénération terminée avec succès !")
    print("=" * 60 + "\n")


if __name__ == '__main__':
    main()
