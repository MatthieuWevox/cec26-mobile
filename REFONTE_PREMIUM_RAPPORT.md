# Rapport final de préparation - CEC 2026

Date de mise à jour : 5 septembre 2026.

## Périmètre livré

La refonte couvre l'application Flutter, l'API Laravel, la vitrine publique et l'administration Filament. Les fonctionnalités initiales sont conservées et complétées pour la publication : notifications Firebase, uploads mobiles, conformité du contenu généré par les utilisateurs, pages légales et ressources graphiques des stores.

## Application mobile

- Design system Material 3 premium aux couleurs du logo CEC.
- Navigation, en-têtes, listes, fiches, formulaires et états harmonisés.
- Accès public aux actualités, rencontres et annuaires.
- Espace membre pour le profil, les invités, les recommandations et les remerciements.
- Sélection de la photo, du logo et de la bannière depuis la galerie ou les fichiers du téléphone.
- Acceptation obligatoire des conditions à la connexion.
- Signalement et masquage d'un profil, d'une entreprise, d'une recommandation ou d'un remerciement.
- Blocage et déblocage d'un membre.
- Écran Informations avec présentation, confidentialité, conditions, suppression et assistance.
- Notifications FCM avec gestion du premier plan, de l'arrière-plan, du lancement et de la navigation au toucher.
- Session restaurée proprement ; une session expirée ne peut pas ouvrir un écran privé depuis une notification.

## Android

- Package `cloud.wevox.cec2026.cec2026`.
- Niveau d'API cible 36.
- Permission Android 13+ et channel de notification configurés.
- Core library desugaring activé.
- Sauvegarde Android désactivée pour éviter l'export involontaire des préférences de session.
- Signature Release dédiée configurée ; JKS et `key.properties` ignorés par Git.
- Gradle 8.14, Android Gradle Plugin 8.11.1 et Kotlin 2.2.20.
- AAB Release final construit et signé.
- APK Release installé et lancé sur émulateur.
- Réception FCM Android réelle validée.

## iOS

- Bundle ID `cloud.wevox.cec2026.cec2026`.
- Entitlement APNs paramétré pour développement et production.
- Background fetch et remote notifications déclarés.
- Texte d'autorisation photothèque présent.
- Chiffrement non exempt déclaré à `false`.
- Swift Package Manager activé pour anticiper la fin des publications Firebase CocoaPods en octobre 2026.
- Plugins iOS natifs contrôlés : les dépendances concernées embarquent leurs manifestes `PrivacyInfo.xcprivacy` et leurs paquets Swift.

La configuration liée aux comptes reste à faire sur un Mac : ajout du vrai `GoogleService-Info.plist`, clé APNs, équipe de signature, build Xcode 26.2+ et test sur iPhone/TestFlight.

## Laravel et API

- Stockage des appareils et tokens FCM.
- Envoi FCM HTTP v1 direct et synchrone, sans queue.
- Notifications automatiques pour les recommandations et remerciements.
- Nettoyage des tokens FCM invalides.
- Upload multipart des médias avec validation et URLs publiques.
- Suppression des anciens médias lors d'un remplacement ou de la suppression du propriétaire.
- Endpoints de signalement et de blocage.
- Protection des contenus privés : seul un participant peut signaler une recommandation ou un remerciement.
- Filtrage des relations bloquées dans les échanges privés.
- Révocation unique des anciennes sessions pour imposer les nouvelles conditions.
- Clé privée Firebase exclue du dépôt Git.

## Web public

- Présentation publique disponible à la racine et sous `/application/`.
- Politique de confidentialité détaillant identité, coordonnées, médias, contenu utilisateur et données Firebase.
- Procédure publique de suppression par email.
- Conditions d'utilisation et règles de comportement.
- Adresse légale, assistance et durée de conservation de deux ans documentées.

## Administration Filament

- Identité visuelle CEC appliquée à l'administration.
- Ressource de gestion des signalements.
- Compteur des signalements en attente sur le tableau de bord.
- Désactivation d'un membre disponible.
- Upload de photo, logo et bannière dans les formulaires d'administration.
- Actualités en brouillon exclues de l'API publique.

## Validations exécutées

```text
flutter analyze                         succès, aucune erreur
flutter test                            succès
flutter build appbundle --release       succès
flutter build apk --release             succès
installation APK Release sur Android    succès
php artisan test                        14 tests, 58 assertions, succès
vendor/bin/pint --dirty                 succès
```

L'environnement WAMP local affiche un avertissement non bloquant : l'extension Imagick a été compilée pour ImageMagick 1808 alors que la DLL chargée est en 1809. Les tests et les uploads actuels passent, mais les deux versions devront être réalignées dans WAMP avant d'ajouter un traitement d'image dépendant d'Imagick. Ce point ne concerne ni l'AAB Android ni le serveur de production s'il utilise son propre environnement PHP.

Bundle Android :

```text
C:\Users\Matthieu\StudioProjects\cec2026\build\app\outputs\bundle\release\app-release.aab
SHA-256 : 9C81AE09CCD9097E8A8C9BB1A0F78B3F335FB09C25D3DAC4C0CBEEB77B26C3A4
```

## Visuels livrés

- icône Google Play 512 x 512 ;
- image de présentation Google Play 1024 x 500 ;
- six captures téléphone Android 1080 x 1920 ;
- quatre captures tablette Android 1600 x 2560 ;
- six captures iPhone 1290 x 2796 ;
- quatre captures iPad 2048 x 2732 ;
- icône App Store de référence 1024 x 1024.

Ils sont inventoriés dans `release_assets/README.md`.

Les captures téléphone ont été recomposées en une série premium avec accroches courtes, alternance de fonds et châssis génériques. Les écrans applicatifs proviennent de captures réelles sur émulateur Android. Les captures tablette Google montrent l'interface en plein écran, conformément aux recommandations grands écrans.

Toutes les captures, l'image de présentation Google et les icônes Apple ont été contrôlées en RGB 24 bits sans canal alpha. L'icône Google Play est conforme à son exigence distincte : PNG 32 bits avec alpha. Les planches de contrôle se trouvent dans `release_assets/review`.

Les images App Store sont aux formats iPhone et iPad acceptés, mais leurs sources applicatives n'ont pas été prises sur un simulateur iOS, indisponible sous Windows. Une comparaison finale sur Mac avec Xcode reste obligatoire avant la soumission Apple.

## Blocages externes restants

1. Les deux dossiers contiennent encore des modifications et fichiers nouveaux non committés ; le paquet de déploiement doit les inclure explicitement.
2. Le serveur `cec.wevox.cloud` expose encore l'ancienne version : la route des conditions et les nouvelles routes API répondent en `404`.
3. Les comptes de démonstration et leurs identifiants doivent être créés.
4. Le contenu public doit être actualisé avec une actualité récente et une réunion future.
5. Le fichier iOS `GoogleService-Info.plist` doit être téléchargé depuis Firebase.
6. La clé APNs `.p8`, son Key ID et le Team ID doivent être configurés.
7. Le build iOS doit être produit avec Xcode 26.2+ et testé sur un véritable iPhone via TestFlight.
8. Les comptes Google et Apple doivent avoir terminé leurs vérifications, contrats et informations publiques.

## Documentation de livraison

Le guide à suivre sans sauter d'étape est :

```text
PRODUCTION_RELEASE_GUIDE.md
```

Le guide Firebase ciblé est :

```text
FIREBASE_NOTIFICATIONS_SETUP.md
```

Le journal de reprise est :

```text
REFONTE_PREMIUM_WORKLOG.md
```
