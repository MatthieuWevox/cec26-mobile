# CEC 2026 – Application Mobile

Application mobile Flutter pour l'association de chefs d'entreprises CEC 2026.

## Fonctionnalités

### Espace public
- **Actualités** – Consultation des actualités publiées
- **Réunions** – Calendrier des réunions (date, heure, lieu, ordre du jour, invités)
- **Entreprises** – Annuaire des entreprises membres avec recherche
- **Membres** – Annuaire des membres avec recherche

### Espace privé (membres connectés)
- **Connexion** – Authentification par email / mot de passe
- **Mon profil** – Modification des informations personnelles
- **Mon entreprise** – Modification des informations de l'entreprise
- **Mot de passe** – Modification du mot de passe
- **Recommandations** – Consultation et création de recommandations (reçues / envoyées)
- **Remerciements** – Consultation et création de remerciements (reçus / envoyés)
- **Inviter à une réunion** – Ajout d'un invité à une réunion

## Configuration de l'API

L'URL de base de l'API est configurable dans :

```
lib/config/api_config.dart
```

Modifiez la constante `baseUrl` :

```dart
static const String baseUrl = 'https://votre-domaine.com/api';
```

## Installation

### Prérequis
- Flutter SDK ≥ 3.18
- Dart SDK ≥ 3.9.2

### Étapes

```bash
# Installer les dépendances
flutter pub get

# Lancer sur un émulateur ou appareil connecté
flutter run

# Compiler pour Android
flutter build apk

# Compiler pour iOS
flutter build ios
```

## Structure du projet

```
lib/
├── config/
│   └── api_config.dart         # URL de l'API (configurable)
├── models/                     # Modèles de données
│   ├── member.dart             # Membre + Entreprise
│   ├── news.dart               # Actualité
│   ├── meeting.dart            # Réunion + Invité
│   ├── recommendation.dart     # Recommandation
│   └── thanks.dart             # Remerciement
├── providers/
│   └── auth_provider.dart      # Gestion de l'authentification
├── services/
│   └── api_service.dart        # Client HTTP
├── theme/
│   └── app_theme.dart          # Thème et couleurs (#272262 / #5CC7CF)
├── screens/
│   ├── main_screen.dart        # Navigation principale
│   ├── news/                   # Écrans actualités
│   ├── meetings/               # Écrans réunions
│   ├── companies/              # Écrans entreprises
│   ├── members/                # Écrans membres
│   └── private/                # Espace membres (login, profil, etc.)
└── widgets/
    └── common_widgets.dart     # Composants réutilisables
```

## Couleurs

| Couleur | Valeur |
|---|---|
| Violet primaire | `#272262` |
| Cyan accent | `#5CC7CF` |
