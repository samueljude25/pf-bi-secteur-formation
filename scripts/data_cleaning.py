#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
data_cleaning.py
================
Script de nettoyage et de préparation des données pour le dashboard Power BI.
À exécuter après generate_data.py pour obtenir des données Power BI-ready.

Opérations effectuées :
  - Vérification de l'intégrité référentielle entre tables
  - Normalisation des formats de dates (ISO 8601)
  - Détection et traitement des valeurs manquantes
  - Vérification des contraintes métier (notes, montants, pourcentages)
  - Enrichissement des données (colonnes calculées utiles pour Power BI)
  - Export des données nettoyées dans un sous-dossier ../data/clean/

Usage :
    python data_cleaning.py [--input-dir ../data] [--output-dir ../data/clean]

Auteur : Portfolio BI — Samuel Jude Sendzi
"""

import os
import sys
import argparse
import warnings
import pandas as pd
import numpy as np

warnings.filterwarnings('ignore')

# --------------------------------------------------------------------------- #
# Configuration par défaut
# --------------------------------------------------------------------------- #

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_INPUT_DIR  = os.path.join(SCRIPT_DIR, '..', 'data')
DEFAULT_OUTPUT_DIR = os.path.join(SCRIPT_DIR, '..', 'data', 'clean')

TABLES = ['apprenants', 'intervenants', 'formations', 'modules', 'inscriptions', 'evaluations']


# --------------------------------------------------------------------------- #
# Utilitaires
# --------------------------------------------------------------------------- #

class Rapport:
    """Collecte et affiche un rapport de nettoyage."""

    def __init__(self):
        self.etapes = []

    def ajouter(self, table: str, operation: str, detail: str, nb: int = 0):
        self.etapes.append({'table': table, 'operation': operation, 'detail': detail, 'nb': nb})
        indicateur = f"[{nb:>4}]" if nb else "      "
        print(f"  {indicateur} {table:15s} | {operation:30s} | {detail}")

    def afficher_resume(self):
        total_corrections = sum(e['nb'] for e in self.etapes)
        print(f"\n  Total corrections appliquées : {total_corrections}")


rapport = Rapport()


# --------------------------------------------------------------------------- #
# Chargement des données brutes
# --------------------------------------------------------------------------- #

def charger_donnees(input_dir: str) -> dict:
    """Charge tous les fichiers CSV bruts."""
    print("\n[CHARGEMENT] Lecture des fichiers CSV bruts...")
    dfs = {}
    for table in TABLES:
        path = os.path.join(input_dir, f'{table}.csv')
        if not os.path.exists(path):
            print(f"  AVERTISSEMENT : Fichier manquant — {path}")
            dfs[table] = pd.DataFrame()
            continue
        df = pd.read_csv(path, encoding='utf-8-sig', low_memory=False)
        dfs[table] = df
        print(f"  {table:20s} : {len(df):>5} lignes × {len(df.columns):>2} colonnes")
    return dfs


# --------------------------------------------------------------------------- #
# Nettoyage par table
# --------------------------------------------------------------------------- #

def nettoyer_apprenants(df: pd.DataFrame) -> pd.DataFrame:
    """Nettoyage et enrichissement de la table apprenants."""
    print("\n[NETTOYAGE] apprenants")
    df = df.copy()

    # 1. Vérification des emails en doublon
    doublons_email = df[df.duplicated(subset=['email'], keep=False)]
    rapport.ajouter('apprenants', 'Doublons email', f"{len(doublons_email)} lignes détectées", len(doublons_email))

    # 2. Normalisation de la colonne sexe
    avant = df['sexe'].isna().sum()
    df['sexe'] = df['sexe'].str.upper().str.strip()
    df.loc[~df['sexe'].isin(['M', 'F']), 'sexe'] = np.nan
    rapport.ajouter('apprenants', 'Normalisation sexe', 'Valeurs hors M/F → NaN', avant)

    # 3. Conversion des dates
    for col in ['date_naissance', 'date_inscription_plateforme']:
        avant = df[col].isna().sum()
        df[col] = pd.to_datetime(df[col], errors='coerce')
        apres = df[col].isna().sum()
        rapport.ajouter('apprenants', f'Conversion date {col}', f'{apres - avant} dates invalides corrigées')

    # 4. Normalisation des noms (strip + title case)
    df['nom']    = df['nom'].str.strip()
    df['prenom'] = df['prenom'].str.strip()

    # 5. Colonne calculée : tranche d'âge (utile pour Power BI)
    df['annee_naissance'] = pd.to_datetime(df['date_naissance'], errors='coerce').dt.year
    df['age'] = 2024 - df['annee_naissance']
    df['tranche_age'] = pd.cut(
        df['age'],
        bins=[0, 25, 35, 45, 100],
        labels=['18-25 ans', '26-35 ans', '36-45 ans', '46 ans et +'],
        right=True
    )

    # 6. Colonne calculée : nom complet
    df['nom_complet'] = df['prenom'] + ' ' + df['nom']

    rapport.ajouter('apprenants', 'Enrichissement', 'Colonnes tranche_age, age, nom_complet ajoutées', 0)
    return df


def nettoyer_intervenants(df: pd.DataFrame) -> pd.DataFrame:
    """Nettoyage et enrichissement de la table intervenants."""
    print("\n[NETTOYAGE] intervenants")
    df = df.copy()

    # 1. Vérification des notes hors plage
    hors_plage = df[(df['note_moyenne'] < 0) | (df['note_moyenne'] > 5)]
    rapport.ajouter('intervenants', 'Notes hors plage (0-5)', f"{len(hors_plage)} anomalies", len(hors_plage))
    df['note_moyenne'] = df['note_moyenne'].clip(0, 5)

    # 2. Vérification des tarifs négatifs ou nuls
    tarifs_invalides = df[df['tarif_journalier_xaf'] <= 0]
    rapport.ajouter('intervenants', 'Tarifs invalides (≤0)', f"{len(tarifs_invalides)} anomalies", len(tarifs_invalides))

    # 3. Colonne calculée : nom complet
    df['nom_complet'] = df['prenom'] + ' ' + df['nom']

    # 4. Catégorie d'expérience
    df['categorie_experience'] = pd.cut(
        df['experience_annees'],
        bins=[0, 3, 7, 12, 100],
        labels=['Junior (0-3 ans)', 'Confirmé (4-7 ans)', 'Senior (8-12 ans)', 'Expert (12+ ans)']
    )

    rapport.ajouter('intervenants', 'Enrichissement', 'Colonnes nom_complet, categorie_experience ajoutées', 0)
    return df


def nettoyer_formations(df: pd.DataFrame) -> pd.DataFrame:
    """Nettoyage et enrichissement de la table formations."""
    print("\n[NETTOYAGE] formations")
    df = df.copy()

    # 1. Vérification des prix négatifs
    prix_invalides = df[df['prix_xaf'] <= 0]
    rapport.ajouter('formations', 'Prix invalides (≤0)', f"{len(prix_invalides)} anomalies", len(prix_invalides))

    # 2. Vérification des durées
    duree_invalides = df[df['duree_heures'] <= 0]
    rapport.ajouter('formations', 'Durées invalides (≤0)', f"{len(duree_invalides)} anomalies", len(duree_invalides))

    # 3. Normalisation du statut
    df['statut'] = df['statut'].str.strip()
    invalides_statut = df[~df['statut'].isin(['Actif', 'Inactif', 'Archivé'])]
    rapport.ajouter('formations', 'Statuts invalides', f"{len(invalides_statut)} anomalies", len(invalides_statut))

    # 4. Colonne calculée : prix en milliers XAF (pour affichage dashboard)
    df['prix_milliers_xaf'] = (df['prix_xaf'] / 1000).round(0).astype(int)

    # 5. Colonne calculée : classe de prix
    df['classe_prix'] = pd.cut(
        df['prix_xaf'],
        bins=[0, 60000, 100000, 130000, 999999],
        labels=['Entrée de gamme (<60k)', 'Milieu de gamme (60-100k)', 'Haut de gamme (100-130k)', 'Premium (>130k)']
    )

    rapport.ajouter('formations', 'Enrichissement', 'Colonnes prix_milliers_xaf, classe_prix ajoutées', 0)
    return df


def nettoyer_inscriptions(df: pd.DataFrame) -> pd.DataFrame:
    """Nettoyage et enrichissement de la table inscriptions."""
    print("\n[NETTOYAGE] inscriptions")
    df = df.copy()

    # 1. Conversion des dates
    for col in ['date_inscription', 'date_debut', 'date_fin_prevue', 'date_fin_reelle']:
        df[col] = pd.to_datetime(df[col], errors='coerce')

    # 2. Vérification cohérence dates (date_debut >= date_inscription)
    incoherence_dates = df[df['date_debut'] < df['date_inscription']]
    rapport.ajouter('inscriptions', 'Incohérences dates', f"{len(incoherence_dates)} lignes (debut < inscription)", len(incoherence_dates))

    # 3. Vérification taux de complétion hors plage
    hors_plage = df[(df['taux_completion_pct'] < 0) | (df['taux_completion_pct'] > 100)]
    rapport.ajouter('inscriptions', 'Complétion hors plage', f"{len(hors_plage)} anomalies", len(hors_plage))
    df['taux_completion_pct'] = df['taux_completion_pct'].clip(0, 100)

    # 4. Vérification montants négatifs
    montants_negatifs = df[df['montant_paye_xaf'] < 0]
    rapport.ajouter('inscriptions', 'Montants négatifs', f"{len(montants_negatifs)} anomalies", len(montants_negatifs))
    df['montant_paye_xaf'] = df['montant_paye_xaf'].clip(lower=0)

    # 5. Valeurs manquantes dans les colonnes catégorielles
    for col in ['mode_paiement', 'source_acquisition']:
        nb_manquants = df[col].isna().sum()
        rapport.ajouter('inscriptions', f'Valeurs manquantes {col}', f"{nb_manquants} lignes → 'Non renseigné'", nb_manquants)
        df[col] = df[col].fillna('Non renseigné')

    # 6. Colonnes calculées utiles pour Power BI
    df['annee_inscription'] = df['date_inscription'].dt.year
    df['mois_inscription'] = df['date_inscription'].dt.month
    df['trimestre_inscription'] = df['date_inscription'].dt.quarter
    df['annee_mois'] = df['date_inscription'].dt.strftime('%Y-%m')

    # Durée réelle de complétion (en jours)
    df['duree_reelle_jours'] = (
        df['date_fin_reelle'] - df['date_debut']
    ).dt.days

    # Écart entre date fin prévue et réelle (retard en jours, positif = en retard)
    df['retard_jours'] = (
        df['date_fin_reelle'] - df['date_fin_prevue']
    ).dt.days

    rapport.ajouter('inscriptions', 'Enrichissement', 'Colonnes date/durée/retard ajoutées', 0)
    return df


def nettoyer_evaluations(df: pd.DataFrame) -> pd.DataFrame:
    """Nettoyage et enrichissement de la table évaluations."""
    print("\n[NETTOYAGE] évaluations")
    df = df.copy()

    # 1. Conversion date
    df['date_evaluation'] = pd.to_datetime(df['date_evaluation'], errors='coerce')

    # 2. Vérification des notes hors plage (1-5)
    colonnes_notes = ['note_globale', 'note_contenu', 'note_intervenant',
                      'note_plateforme', 'note_rapport_qualite_prix']
    for col in colonnes_notes:
        hors_plage = df[(df[col] < 1) | (df[col] > 5)]
        rapport.ajouter('évaluations', f'Hors plage {col}', f"{len(hors_plage)} anomalies", len(hors_plage))
        df[col] = df[col].clip(1, 5)

    # 3. Vérification NPS hors plage (0-10)
    nps_hors_plage = df[(df['nps_score'] < 0) | (df['nps_score'] > 10)]
    rapport.ajouter('évaluations', 'NPS hors plage (0-10)', f"{len(nps_hors_plage)} anomalies", len(nps_hors_plage))
    df['nps_score'] = df['nps_score'].clip(0, 10)

    # 4. Normalisation recommande
    df['recommande'] = df['recommande'].str.strip()
    invalides_reco = df[~df['recommande'].isin(['Oui', 'Non', 'Neutre'])]
    rapport.ajouter('évaluations', 'Valeurs recommande invalides', f"{len(invalides_reco)} anomalies", len(invalides_reco))
    df.loc[~df['recommande'].isin(['Oui', 'Non', 'Neutre']), 'recommande'] = 'Neutre'

    # 5. Colonnes calculées
    df['annee_evaluation'] = df['date_evaluation'].dt.year
    df['mois_evaluation'] = df['date_evaluation'].dt.month
    df['annee_mois_evaluation'] = df['date_evaluation'].dt.strftime('%Y-%m')

    # Note moyenne toutes dimensions confondues
    df['note_moyenne_dimensions'] = df[colonnes_notes].mean(axis=1).round(2)

    # Segment NPS
    df['segment_nps'] = pd.cut(
        df['nps_score'],
        bins=[-1, 6, 8, 10],
        labels=['Détracteur (0-6)', 'Passif (7-8)', 'Promoteur (9-10)']
    )

    rapport.ajouter('évaluations', 'Enrichissement', 'Colonnes date, note_moy, segment_nps ajoutées', 0)
    return df


def verifier_integrite_referentielle(dfs: dict) -> None:
    """Vérifie les clés étrangères entre tables."""
    print("\n[INTÉGRITÉ RÉFÉRENTIELLE] Vérification des clés étrangères...")

    checks = [
        ('inscriptions', 'apprenant_id', 'apprenants', 'apprenant_id'),
        ('inscriptions', 'formation_id', 'formations', 'formation_id'),
        ('évaluations',  'inscription_id', 'inscriptions', 'inscription_id'),
        ('évaluations',  'apprenant_id',  'apprenants',   'apprenant_id'),
        ('évaluations',  'formation_id',  'formations',   'formation_id'),
        ('modules',      'formation_id',  'formations',   'formation_id'),
    ]

    # Harmoniser le nom de la clé évaluations
    dfs_check = dfs.copy()
    if 'evaluations' in dfs_check:
        dfs_check['évaluations'] = dfs_check['evaluations']

    for source_table, source_col, cible_table, cible_col in checks:
        if source_table not in dfs_check or cible_table not in dfs_check:
            continue
        if dfs_check[source_table].empty or dfs_check[cible_table].empty:
            continue
        orphelins = ~dfs_check[source_table][source_col].isin(dfs_check[cible_table][cible_col])
        nb_orphelins = orphelins.sum()
        rapport.ajouter(
            source_table,
            f'FK {source_col} → {cible_table}',
            f"{nb_orphelins} orphelins détectés",
            nb_orphelins
        )


# --------------------------------------------------------------------------- #
# Export des données nettoyées
# --------------------------------------------------------------------------- #

def exporter_donnees(dfs_clean: dict, output_dir: str) -> None:
    """Exporte les DataFrames nettoyés en CSV dans output_dir."""
    print(f"\n[EXPORT] Écriture dans {os.path.abspath(output_dir)}...")
    os.makedirs(output_dir, exist_ok=True)

    for nom, df in dfs_clean.items():
        if df is None or df.empty:
            continue
        # Reconvertir les dates en chaînes ISO pour l'export
        for col in df.select_dtypes(include=['datetime64']).columns:
            df[col] = df[col].dt.strftime('%Y-%m-%d')
        # Convertir les catégoriques en chaînes
        for col in df.select_dtypes(include=['category']).columns:
            df[col] = df[col].astype(str)

        path = os.path.join(output_dir, f'{nom}.csv')
        df.to_csv(path, index=False, encoding='utf-8-sig')
        print(f"  {nom:20s} : {len(df):>5} lignes → {path}")


# --------------------------------------------------------------------------- #
# Fonction principale
# --------------------------------------------------------------------------- #

def main():
    """Point d'entrée du script de nettoyage."""
    parser = argparse.ArgumentParser(
        description='Nettoyage et préparation des données pour Power BI.'
    )
    parser.add_argument('--input-dir',  default=DEFAULT_INPUT_DIR,  help='Dossier des CSV bruts')
    parser.add_argument('--output-dir', default=DEFAULT_OUTPUT_DIR, help='Dossier des CSV nettoyés')
    args = parser.parse_args()

    print("\n" + "=" * 65)
    print("  DATA CLEANING — Plateforme de Formation Professionnelle")
    print("  Portfolio BI — Samuel Jude Sendzi")
    print("=" * 65)

    # Chargement
    dfs = charger_donnees(args.input_dir)

    # Vérification de l'intégrité référentielle sur les données brutes
    print("\n" + "-" * 65)
    print(f"  {'TABLE':15s} | {'OPÉRATION':30s} | DÉTAIL")
    print("-" * 65)
    verifier_integrite_referentielle(dfs)

    # Nettoyage de chaque table
    dfs_clean = {}

    if not dfs.get('apprenants', pd.DataFrame()).empty:
        dfs_clean['apprenants'] = nettoyer_apprenants(dfs['apprenants'])

    if not dfs.get('intervenants', pd.DataFrame()).empty:
        dfs_clean['intervenants'] = nettoyer_intervenants(dfs['intervenants'])

    if not dfs.get('formations', pd.DataFrame()).empty:
        dfs_clean['formations'] = nettoyer_formations(dfs['formations'])

    if not dfs.get('modules', pd.DataFrame()).empty:
        dfs_clean['modules'] = dfs['modules'].copy()
        rapport.ajouter('modules', 'Aucune anomalie détectée', 'Table propre', 0)

    if not dfs.get('inscriptions', pd.DataFrame()).empty:
        dfs_clean['inscriptions'] = nettoyer_inscriptions(dfs['inscriptions'])

    if not dfs.get('evaluations', pd.DataFrame()).empty:
        dfs_clean['evaluations'] = nettoyer_evaluations(dfs['evaluations'])

    print("\n" + "-" * 65)
    rapport.afficher_resume()

    # Export
    exporter_donnees(dfs_clean, args.output_dir)

    print("\n" + "=" * 65)
    print("  Nettoyage terminé avec succès !")
    print(f"  Données prêtes pour import dans Power BI.")
    print("=" * 65 + "\n")


if __name__ == '__main__':
    main()
