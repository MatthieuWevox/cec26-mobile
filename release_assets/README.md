# Visuels de publication CEC 2026

Les captures et bannières sont exportées en PNG 24 bits sans transparence. L'icône Google Play est volontairement en PNG 32 bits avec canal alpha, tandis que l'icône Apple est opaque. Les dimensions et formats correspondent aux exigences des stores contrôlées le 5 septembre 2026.

Les six visuels téléphone forment une présentation premium alternant fonds clairs et foncés, accroches courtes et appareils simples ou doubles. Les écrans intégrés proviennent de captures réelles de l'application Flutter exécutée sur un émulateur Android.

## Google Play

### Icône et bannière

| Destination Play Console | Fichier | Dimensions |
|---|---|---:|
| Icône de l'application | `google-play/icon-512.png` | 512 x 512 |
| Image de présentation obligatoire | `google-play/feature-graphic-1024x500.png` | 1024 x 500 |

L'« image de présentation » est la bannière demandée pour la fiche Android classique. Une bannière Android TV distincte n'est pas nécessaire : l'application ne déclare pas de compatibilité Android TV ou Leanback.

### Captures téléphone

À téléverser dans cet ordre :

1. `google-play/01-actualites-1080x1920.png`
2. `google-play/02-reunions-1080x1920.png`
3. `google-play/03-reunion-detail-1080x1920.png`
4. `google-play/04-annuaire-1080x1920.png`
5. `google-play/05-connexion-1080x1920.png`
6. `google-play/06-informations-1080x1920.png`

### Captures tablette

À téléverser dans les sections tablette 7 pouces et tablette 10 pouces :

1. `google-play/tablet/01-actualites-1600x2560.png`
2. `google-play/tablet/02-reunions-1600x2560.png`
3. `google-play/tablet/03-annuaire-1600x2560.png`
4. `google-play/tablet/04-connexion-1600x2560.png`

Ces quatre exports montrent volontairement l'interface en plein écran, sans texte marketing ajouté. Cette présentation suit la recommandation Google dédiée aux captures de grands écrans.

## App Store

### Captures iPhone 6,9 pouces

À téléverser dans cet ordre :

1. `app-store/01-actualites-1290x2796.png`
2. `app-store/02-reunions-1290x2796.png`
3. `app-store/03-reunion-detail-1290x2796.png`
4. `app-store/04-annuaire-1290x2796.png`
5. `app-store/05-connexion-1290x2796.png`
6. `app-store/06-informations-1290x2796.png`

### Captures iPad Pro 13 pouces

À téléverser dans cet ordre :

1. `app-store/ipad-01-actualites-2048x2732.png`
2. `app-store/ipad-02-reunions-2048x2732.png`
3. `app-store/ipad-03-annuaire-2048x2732.png`
4. `app-store/ipad-04-connexion-2048x2732.png`

### Icône de référence

`app-store/app-icon-1024.png` est une version 1024 x 1024 sans transparence. L'icône réellement envoyée à Apple est également incluse dans le build iOS via le catalogue `AppIcon` généré par Flutter.

### Origine des captures iOS

Les fichiers iPhone et iPad ont les dimensions App Store exactes et utilisent le rendu Flutter actuel dans des compositions avec châssis Apple génériques. Ils ne sont pas issus d'un simulateur iOS : un simulateur iOS et Xcode nécessitent un Mac, alors que cette préparation a été réalisée sous Windows.

Avant la soumission Apple, exécute le build sur le simulateur iPhone 6,9 pouces et l'iPad 13 pouces ou sur de vrais appareils. Si le rendu diffère, remplace les images applicatives intégrées dans les compositions. Cette vérification est aussi nécessaire pour confirmer les autorisations, Firebase/APNs et les interactions natives.

## Textes alternatifs Google Play

1. `Actualités du Club des Entrepreneurs du Cotentin présentées dans l'application mobile.`
2. `Liste des réunions et rendez-vous du réseau professionnel du Cotentin.`
3. `Détail d'une réunion avec date, heure, lieu, ordre du jour et invités.`
4. `Annuaire des entreprises et présentation détaillée d'une entreprise membre.`
5. `Connexion à l'espace membre pour accéder aux échanges professionnels.`
6. `Outils de confidentialité, de signalement, de blocage et d'assistance.`

## Fichiers à ne pas envoyer

Le dossier `screenshots/android` contient les prises de travail et les captures de contrôle prises sur émulateur. Ne téléverse aucun de ces fichiers sur les stores.

`screenshots/android/moderation-report-sheet.png` peut être conservé comme preuve interne du système de signalement, mais ce n'est pas un visuel de fiche store.

Le dossier `review` contient les planches de contrôle suivantes, uniquement destinées à la revue interne :

- `review/android-premium-contact-sheet.jpg`
- `review/ios-premium-contact-sheet.jpg`
- `review/tablets-premium-contact-sheet.jpg`

## Régénération

Le script de composition est :

```powershell
powershell -ExecutionPolicy Bypass -File tooling\generate_store_assets.ps1
```

Ne régénère les images qu'après avoir repris de nouvelles captures sources. Vérifie ensuite visuellement chaque export et garde l'ordre ci-dessus.

Le tutoriel complet se trouve dans `PRODUCTION_RELEASE_GUIDE.md`.
