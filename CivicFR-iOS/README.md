# CIVIC FR — Réussir l'examen civique 🇫🇷

Application iPhone native (SwiftUI) pour préparer l'examen civique français,
avec aide en vietnamien à la demande. Inspirée de Duolingo pour la
gamification et du design Apple pour l'interface.

## Ouvrir le projet

1. Sur un **Mac avec Xcode 16 ou plus récent**, ouvrir `CivicFR.xcodeproj`.
2. Choisir un simulateur iPhone (iOS 17+) puis **Run (⌘R)**.
3. Les tests unitaires : **⌘U** (cible `CivicFRTests`).

> Le projet utilise les *groupes synchronisés sur le système de fichiers*
> (Xcode 16) : tout fichier ajouté dans le dossier `CivicFR/` est inclus
> automatiquement, sans manipulation du projet.

## Fonctionnalités (v1)

- **Accueil** : objectif, progression (XP/niveau), série de jours, scores.
- **Apprendre** : entraînement rapide (5/10/20 questions), par catégorie,
  révision des erreurs — feedback immédiat, animations, sons, XP.
- **Examen** : simulation de 40 questions / 45 min, chronomètre fiable basé
  sur une date (résiste au passage en arrière-plan et à la fermeture de
  l'app), reprise d'une session interrompue, résultats visuels, correction
  détaillée, graphiques par catégorie et historique.
- **Traduction FR/VI** à la demande (désactivable en mode examen strict).
- **Gamification** : XP, 6 niveaux, séries quotidiennes, badges, sons.
- **Statistiques** : taux par catégorie, détection des faiblesses, évolution.
- **Programme 30 jours** adaptatif.
- **Rappels** quotidiens (notifications locales) configurables.
- **Paramètres** : langue, sons, vibrations, mode strict, réinitialisation.
- 100 % **hors ligne**, aucune donnée ne quitte l'iPhone, pas de compte requis.

## Architecture

```
CivicFR/
  App/          Point d'entrée, Tab Bar, onboarding
  Config/       AppConfig (règles examen), Theme, Localization
  Models/       Question, UserData, ExamResult, Badge, Level, enums
  Services/     Store (persistance+XP), QuestionBank, ExamEngine,
                TrainingEngine, Scoring, Notifications, Sons
  Views/        Écrans + composants réutilisables
  Resources/    questions.json  (banque de questions)
CivicFRTests/   Tests unitaires de la notation
```

Les paramètres de l'examen sont centralisés dans `Config/AppConfig.swift`
(40 questions, 45 min, seuil 80 %) — à ajuster si les règles officielles
évoluent.

## Banque de questions

- **69 questions** pédagogiques bilingues (FR + VI) couvrant les 10 catégories
  du programme, dans `CivicFR/Resources/questions.json`.
- Format `Codable` (clés *snake_case*). **Ajouter des questions = éditer le
  JSON**, sans toucher au code. Objectif à terme : 300–500 questions.
- Les questions sont marquées `educational` : ce sont des questions
  **pédagogiques originales fondées sur des connaissances officielles**, pas
  des questions officielles d'examen. Vérifier les informations susceptibles
  d'évoluer avant tout usage sérieux.

> ⚠️ Aucune question n'est présentée comme « officielle ». Les sources
> recommandées (Livret du citoyen, Service-Public.fr, ministère de
> l'Intérieur) doivent être consultées pour valider/enrichir la base dans le
> respect des droits d'auteur.

## Pistes v2

Synchronisation iCloud facultative, import de nouvelles questions depuis une
URL, sons personnalisés, davantage de questions vérifiées.
