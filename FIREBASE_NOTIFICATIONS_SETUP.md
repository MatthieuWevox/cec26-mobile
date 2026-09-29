# Firebase Cloud Messaging - CEC 2026

Dernière mise à jour : 5 septembre 2026.

Ce document résume uniquement Firebase. La procédure complète de déploiement et de publication se trouve dans `PRODUCTION_RELEASE_GUIDE.md`.

## État actuel

### Android

- package : `cloud.wevox.cec2026.cec2026`
- projet Firebase : `cec-2026`
- fichier présent : `android/app/google-services.json`
- plugin Google Services configuré dans Gradle
- permission Android 13+ configurée
- channel `cec_notifications` configuré
- core library desugaring activé
- signature Release configurée et bundle signé validé
- récupération et affichage du token FCM en mode Debug validés
- réception réelle d'une notification validée

Android ne nécessite pas d'autre fichier Firebase côté application. Le service account Laravel reste obligatoire pour l'envoi depuis le serveur.

### iOS

- bundle ID : `net.wevox.cec.cec` (identifiant de l'app publiee, verifie le 28/09/2026)
- entitlement APNs présent dans `ios/Runner/Runner.entitlements`
- environnement APNs : `development` en Debug, `production` en Profile/Release
- modes `fetch` et `remote-notification` déclarés
- Swift Package Manager activé dans `pubspec.yaml`
- fichier encore manquant : `ios/Runner/GoogleService-Info.plist`
- clé APNs `.p8`, Key ID et Team ID encore à configurer dans Firebase
- build et test sur véritable iPhone encore à réaliser sur macOS

## Fonctionnement codé

Dans Flutter, `lib/services/notification_service.dart` :

- initialise Firebase Messaging ;
- demande l'autorisation ;
- récupère le token FCM ;
- envoie le token à Laravel après connexion ;
- met à jour le serveur lors d'un renouvellement du token ;
- supprime le token serveur à la déconnexion ;
- affiche la notification lorsque l'app Android est ouverte ;
- ouvre Recommandations ou Remerciements après un toucher ;
- évite d'ouvrir un écran privé sans session valide.

Dans Laravel :

- `POST /api/me/push-tokens` enregistre ou met à jour un appareil ;
- `DELETE /api/me/push-tokens` retire son token ;
- `RecommendationObserver` et `ThanksObserver` déclenchent les envois ;
- `FirebaseCloudMessagingService` utilise l'API HTTP v1 ;
- les envois sont directs et synchrones, sans queue ;
- les tokens invalides sont nettoyés automatiquement.

## Configuration Firebase serveur

1. Ouvre [Firebase Service Accounts](https://console.firebase.google.com/project/cec-2026/settings/serviceaccounts/adminsdk).
2. Clique sur `Générer une nouvelle clé privée`.
3. Sur le serveur Laravel, dépose le JSON ici :

```text
storage/app/firebase/service-account.json
```

4. Ne place jamais cette clé sous `public` et ne la commite pas. Le chemin est ignoré par le `.gitignore` Laravel.
5. Ajoute au `.env` de production :

```dotenv
FIREBASE_PROJECT_ID=cec-2026
FIREBASE_CREDENTIALS=storage/app/firebase/service-account.json
QUEUE_CONNECTION=sync
```

6. Déploie et recharge la configuration :

```bash
php artisan optimize:clear
php artisan migrate --force
php artisan config:cache
```

## Configuration iOS et APNs

**Mise à jour du 28/09/2026 :** la clé APNs de production `L7DNK7Z5A7` a été importée et vérifiée dans **CEC 2026**. L'app Apple existe déjà : `net.wevox.cec.cec`. Ne recrée pas l'app ni la clé. Voir `NOTIFICATIONS_AUDIT_2026-09-28.md` pour l'état réel et la procédure TestFlight du nouveau build **2.0.1 (21)**. La ligne développement contient une clé limitée à la production : elle ne permet pas de valider les push sandbox d'un build debug.

1. Dans [Apple Developer Identifiers](https://developer.apple.com/account/resources/identifiers/list), ouvre l'App ID explicite existant `net.wevox.cec.cec` de l'equipe `6YFVLX2X38`. Ne cree pas une autre application.
2. Active `Push Notifications`.
3. Dans [Apple Developer Keys](https://developer.apple.com/account/resources/authkeys/list), vérifie la clé existante « CEC » avec `Apple Push Notifications service (APNs)` et environnement Production.
4. Conserve son `.p8` hors de l'application et de Git. Team ID : `6YFVLX2X38`.
5. Dans [Firebase Cloud Messaging](https://console.firebase.google.com/project/cec-2026/settings/cloudmessaging/ios:net.wevox.cec.cec), vérifie la ligne **production**, Key ID `L7DNK7Z5A7`. Import réalisé le 28/09/2026.
6. Dans [Firebase General Settings](https://console.firebase.google.com/project/cec-2026/settings/general), ouvre l'app iOS existante avec le bundle ID exact.
7. Télécharge `GoogleService-Info.plist`.
8. Sur le Mac, place-le dans `ios/Runner/GoogleService-Info.plist` puis ajoute-le à la target Runner avec Xcode.
9. Dans Xcode > Runner > Signing & Capabilities, sélectionne l'équipe, active la signature automatique et vérifie `Push Notifications` et `Background Modes`.
10. Dans Background Modes, coche `Background fetch` et `Remote notifications`.

## Swift Package Manager

Firebase arrête les nouvelles publications CocoaPods en octobre 2026. Le projet utilise donc Swift Package Manager :

```yaml
flutter:
  config:
    enable-swift-package-manager: true
```

Sur le Mac :

```bash
flutter config --enable-swift-package-manager
flutter clean
flutter pub get
flutter build ios --config-only
open ios/Runner.xcworkspace
```

Utilise Xcode 26.2 ou plus récent. N'ajoute pas de `Podfile` Firebase et ne lance pas `pod install` pour ce projet.

Documentation officielle : [migration Firebase CocoaPods vers SPM](https://firebase.google.com/docs/ios/cocoapods-deprecation?hl=fr).

## Test final obligatoire

### Android

1. Installe le build Release depuis une piste de test Google Play.
2. Connecte un compte et accepte les notifications.
3. Vérifie une ligne Android dans `member_push_tokens`.
4. Envoie une recommandation depuis un autre compte.
5. Teste l'app ouverte, en arrière-plan et fermée.
6. Recommence avec un remerciement.

### iOS

1. Installe le build via Xcode puis TestFlight sur un véritable iPhone.
2. Connecte un compte et accepte les notifications.
3. Vérifie une ligne iOS dans `member_push_tokens`.
4. Teste recommandation et remerciement dans les trois états de l'app.
5. Vérifie que le toucher ouvre le bon écran.

Le simulateur seul ne suffit pas pour valider toute la chaîne APNs/FCM de production.

## Dépannage

### Aucun token en base

- confirme que l'utilisateur est connecté ;
- contrôle la réponse de `POST /api/me/push-tokens` ;
- vérifie que la nouvelle API Laravel est réellement déployée ;
- contrôle les logs Flutter et `storage/logs/laravel.log` ;
- sur iOS, vérifie d'abord que le token APNs n'est pas nul.

### Android ne reçoit rien

- vérifie l'autorisation Notifications dans Android ;
- vérifie Google Play Services ;
- contrôle `android/app/google-services.json` et le package ;
- contrôle le service account et `FIREBASE_PROJECT_ID` sur Laravel.

### iOS ne reçoit rien

- vérifie `GoogleService-Info.plist` dans la target Runner ;
- vérifie le bundle ID, l'App ID et l'équipe Apple ;
- vérifie la clé APNs dans Firebase ;
- vérifie les capabilities Xcode ;
- teste via TestFlight pour valider l'environnement APNs production.

### Erreur d'envoi Laravel

- vérifie que PHP OpenSSL est actif ;
- vérifie le chemin et les droits du JSON ;
- vérifie l'accès sortant HTTPS vers Google ;
- lance `php artisan optimize:clear` puis `php artisan config:cache` ;
- consulte `storage/logs/laravel.log` sans exposer la clé privée.
