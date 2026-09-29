# Audit des notifications - 28 septembre 2026

## Périmètre et précautions

Application Flutter Android/iOS, Laravel/Filament et production cec.wevox.cloud ; consoles Firebase, Apple Developer/App Store Connect et Google Play. Aucun message de test ne doit être envoyé aux membres sans accord explicite. Aucun envoi en queue : traitement synchrone, après validation des écritures.

Les deux dépôts contiennent des modifications antérieures, à conserver. Aucun secret, token de téléphone, clé Apple ou compte de service ne doit figurer dans ce journal.

## Plan de travail

- [x] Premier inventaire du code et ouverture des consoles.
- [x] Vérifier les configurations Android, iOS, Firebase, signatures et versions publiées.
- [x] Auditer la configuration réelle du serveur sans envoi de notifications.
- [x] Compléter les notifications de réunions et fiabiliser les envois/rejets.
- [x] Corriger l'enregistrement des tokens et la navigation mobile depuis les notifications.
- [x] Ajouter les tests, exécuter les vérifications disponibles et déployer le backoffice.
- [x] Vérifier les consoles avec les connexions utilisateur et documenter les points bloquants.
- [x] Rédiger le bilan et les étapes de validation sur appareils et de publication.
- [ ] Sur Mac : compiler et installer le nouveau build iOS via TestFlight.
- [ ] Sur appareils réels : constater l'enregistrement puis la réception des quatre événements.
- [ ] Publier les nouvelles versions mobiles après ces tests (non demandé/non réalisé pendant cet audit).

## Constats initiaux

- Recommandations et remerciements : observers présents, envoi HTTP v1 FCM synchrone.
- Réunions : aucun observer d'envoi ; navigation mobile limitée à recommendation/thanks.
- iOS : entitlements APNs et modes de fond présents, mais GoogleService-Info.plist absent des ressources déclarées dans le projet Xcode local.
- Incohérence iOS à résoudre après contrôle du store : bundle ID Xcode local `cloud.wevox.cec2026.cec2026`, contre `net.wevox.cec.cec` dans le fichier Firebase iOS. Ne pas changer l'identifiant publié sur simple supposition.
- Projet Firebase déclaré par les configurations natives : `cec-2026`.
- Swift Package Manager activé dans pubspec ; pas de Podfile. Vérifier l'intégration effective au build sur Mac.
- Android : permission POST_NOTIFICATIONS, canal et desugaring déjà présents.
- Client : attente APNs limitée à trois secondes, erreurs d'enregistrement ignorées, absence de réessai au retour au premier plan.
- Service serveur : erreur de configuration silencieuse si projet absent ; retrait des tokens sur SENDER_ID_MISMATCH à revoir pour éviter d'effacer des installations valides en cas de mauvais projet configuré.

## Consoles

- Firebase : erreur initiale de chargement des conditions sur le compte Google temporaire affiché ; utilisateur invité à sélectionner le bon compte.
- Apple Developer : connexion demandée à l'utilisateur.
- Play Console : compte Wevox Cloud accessible ; vérification de l'application en cours.

## Résultat vérifié

### Firebase et Apple

- Seul le projet **CEC 2026**, ID `cec-2026`, expéditeur `39396459769`, a été modifié. Ne pas utiliser « CEC Prod ».
- L'API Firebase Cloud Messaging HTTP v1 est activée. Le compte de service du serveur appartient au bon projet.
- L'app iOS existante utilise **`net.wevox.cec.cec`**, équipe **`6YFVLX2X38`**.
- App Store Connect : version 2.0 prête pour la distribution, build **2.0.0 (20)** importé le 24/09/2026. Ses entitlements contiennent bien **`aps-environment: production`**. La capacité Push Notifications est cochée dans Apple Developer.
- Anomalie Firebase trouvée : clé Apple « CEC » **`L7DNK7Z5A7`**, production uniquement, importée dans la ligne APNs **développement**, aucune clé/certificat en production.
- Après confirmation de l'utilisateur sur le fichier et autorisation d'import, la clé existante a été ajoutée dans la ligne **APNs de production**. L'état enregistré a été vérifié dans Firebase. Aucune clé n'a été créée ou révoquée ; aucune autre application n'a été modifiée.
- L'ancienne ligne développement est conservée. Elle ne constitue pas une configuration sandbox valide puisque cette clé est production uniquement. Tester via **TestFlight** ; pour tester les push d'un build signé développement, il faudra une clé APNs sandbox adaptée et son import, séparément. Ne pas utiliser/reconfigurer les clés des autres applications.
- Preuve : `release_assets/firebase-apns-production-2026-09-28.png`.

### Google Play

- Compte Wevox Cloud, app CEC 2026, package **`cloud.wevox.cec2026.cec2026`**.
- Bundle **2 (1.0.0)**, production **en cours d'examen** au moment du contrôle. Build 1 accessible en tests internes.
- Les détails du bundle 2 indiquent `POST_NOTIFICATIONS`, `INTERNET`, `com.google.android.c2dm.permission.RECEIVE`, `WAKE_LOCK` et `VIBRATE`. SDK cible 36 ; compatibilité 16 Ko indiquée par Google.
- Aucun envoi de nouvelle version ni changement de déploiement dans cette console.

### Production Laravel

- Projet Firebase et fichier de compte de service cohérents, lisibles et présents hors du dossier public.
- Validation réelle de l'authentification et de l'autorisation FCM depuis le serveur : **HTTP 200**, avec **`validate_only: true`**. Cette opération ne livre aucun message et ne prouve pas une réception APNs.
- **Zéro token d'appareil** en base au contrôle final. Le compte membre `mgeiss@wevox.eu` existe, est actif, mais ne possède aucun token.
- L'utilisateur a ouvert la version App Store sur son iPhone et ne trouve pas de rubrique Notifications pour CEC. Cela suggère une initialisation/demande d'autorisation absente dans ce binaire ; nous n'avons pas son IPA ni les logs du Mac pour attribuer précisément la cause.
- Aucun test de notification livré, aucune réunion/recommandation/remerciement de test créé en production.

## Modifications réalisées

### Serveur, déjà déployé

- Nouvel `MeetingObserver` : création et modification de date, heure, adresse, ordre du jour ou compte rendu vers tous les **membres actifs ayant un appareil enregistré**.
- Recommandation et remerciement : envoi au destinataire, sur ses appareils enregistrés, pas à l'expéditeur ni aux membres inactifs.
- Les trois observers envoient **après commit**, dans la requête en cours, **sans queue ni worker**. Une transaction annulée ne déclenche pas de notification.
- Sauvegardes sans changement et changements de `updated_at` seuls : pas de notification de réunion.
- Service FCM : authentification une fois par diffusion, son Android/iOS, entêtes APNs d'alerte, vérification du projet du compte de service, journaux sans token ni clé.
- Suppression des tokens uniquement sur `UNREGISTERED`. `SENDER_ID_MISMATCH` est journalisé sans effacer le téléphone.
- API : un renouvellement de token remplace celui de la même installation du membre ; enregistrement protégé par authentification.
- Les erreurs réseau FCM sont journalisées sans annuler les données métier. Pas de reprise durable après panne réseau serveur : conforme au choix sans queue. Une diffusion reste proportionnelle au nombre d'appareils et peut allonger la sauvegarde.

Fichiers déployés et relus par FTPS pour comparaison exacte :

```text
app/Services/FirebaseCloudMessagingService.php
app/Observers/MeetingObserver.php
app/Observers/RecommendationObserver.php
app/Observers/ThanksObserver.php
app/Http/Controllers/Api/PushTokenController.php
app/Providers/AppServiceProvider.php
```

Sauvegardes privées : `C:\wamp642\www\cec\.ops-private\notifications-2026-09-28\backup`.
Déploiement limité à ces fichiers, sans migration ni modification des membres. Contrôle de concurrence avec le snapshot précédent ; anciennes modifications administrateurs conservées. Invalidation ciblée OPcache. Scripts temporaires protégés par secret aléatoire, expiration et POST HTTPS, supprimés après usage et **HTTP 404 vérifié**. Le script d'opération local est dans `.ops-private/deploy_notifications.py` ; ne jamais publier ce dossier.

Contrôle après déploiement : accueil, connexion admin, API réunions **HTTP 200**. Connexion au backoffice avec l'utilisateur, liste et édition de la réunion 20 consultées sans sauvegarde. Les cinq champs déclencheurs sont bien présents.

### Flutter, à republier

- Identifiant et équipe Xcode alignés sur l'app réellement publiée, sans créer une nouvelle fiche App Store.
- `GoogleService-Info.plist` déclaré dans les ressources de Runner ; cohérence du projet, de l'app ID et du bundle vérifiée.
- Autorisation demandée à la connexion membre, attente du token APNs avant le token FCM, réessais après erreur et au retour au premier plan, renouvellement de token pris en compte.
- Enregistrement des notifications non bloquant pour la connexion à l'espace membre.
- Désenregistrement au logout, invalidation du token FCM et remise à zéro de l'état local.
- État visible dans l'espace membre (« Appareil enregistré », attente ou autorisation à vérifier) et bouton de nouvelle vérification. « Enregistré » signifie accepté par l'API, pas livré par Apple/Google.
- Appui sur une notification de réunion : recharge la réunion actuelle puis ouvre son détail, avec gestion du réseau indisponible et des réunions supprimées. Les échanges privés restent conditionnés à une session membre.
- iOS : présentation native au premier plan sans doublon de notification locale. Android : canal haute importance conservé.
- `.p8` exclus de Git. Aucun secret ajouté au rapport ou à l'application.
- Version préparée **2.0.1+21**. Swift Package Manager conservé ; aucune migration vers CocoaPods.

## Vérifications locales

- `flutter analyze --no-pub` : aucune erreur.
- `flutter test --no-pub` : **14 tests réussis**, dont navigation de réunion, erreur/réessai, suppression, destinations de notifications et tests UI existants.
- `php artisan test --compact` : **32 tests, 152 assertions**, réussis. Couverture : destinataires des échanges, création/modification des réunions, commit/rollback, membres inactifs, renouvellement/révocation des tokens, format Android/APNs et panne réseau FCM.
- `flutter build appbundle --release --no-pub` : réussi, **57,6 Mo**, version **2.0.1 (21)**. Manifeste release fusionné vérifié : permissions réseau/notifications et service Firebase présents.
- AAB : `build/app/outputs/bundle/release/app-release.aab`.
- SHA-256 AAB : `A4EBD11A01C8AF295F20607BBD57AB89D647542D1E493912C590341B7D27551E`.
- Avertissements préexistants/non bloquants : Imagick local ; migration future du Kotlin Gradle Plugin signalée par Flutter. Pas de mise à niveau générale des dépendances pendant cet audit.
- **Pas de compilation iOS sur ce PC Windows**. Aucun résultat de livraison sur téléphone réel n'est affirmé. Les essais de panne native APNs et de reprise FCM restent à faire sur appareil.

## Suite exacte : iPhone

1. Reporter les fichiers de cette version sur le Mac de compilation, dont `ios/Runner/GoogleService-Info.plist`, le projet Xcode et les modifications Dart. Ne pas recopier les fichiers `.p8` dans Runner. Le code du Mac qui a produit le build 20 peut différer de ce dossier Windows : fusionner ses adaptations au lieu de l'écraser aveuglément.
2. Avec Flutter 3.44.2 ou version compatible et Xcode compatible avec les dépendances :

```bash
flutter pub get
flutter config --enable-swift-package-manager
flutter build ios --config-only --release
open ios/Runner.xcworkspace
```

3. Xcode > Runner > Signing & Capabilities : équipe WEVOX `6YFVLX2X38`, bundle `net.wevox.cec.cec`, signature automatique, Push Notifications et Background Modes > Remote notifications. Vérifier `GoogleService-Info.plist` dans Build Phases > Copy Bundle Resources, une seule fois.
4. Flutter 3.44 ajoute l'intégration SPM automatiquement au build sur Mac. Vérifier `FlutterGeneratedPluginSwiftPackage` et la pré-action `Run Prepare Flutter Framework Script`. Ne pas ajouter manuellement Firebase une seconde fois. Si une dépendance non Firebase nécessite encore CocoaPods, examiner cette dépendance : le flag SPM ne prouve pas à lui seul que tout est migré.
5. Compiler :

```bash
flutter build ipa --release --build-name=2.0.1 --build-number=21
```

6. Si le numéro 21 a entre-temps déjà été envoyé à Apple, choisir le prochain numéro libre. Dans Xcode Organizer, vérifier les entitlements d'archive : `aps-environment = production`.
7. Envoyer avec Organizer > Distribute App > App Store Connect > Upload. Dans App Store Connect > Club Entrepreneurs Cotentin > TestFlight, attendre le traitement puis installer **ce nouveau build** sur l'iPhone.
8. Ouvrir CEC > Espace membre > se connecter > accepter la demande iOS. Vérifier « Appareil enregistré » dans l'espace membre et la présence d'un appareil iOS en base. La correction Firebase seule ne remplace pas le binaire déjà installé.
9. Faire un envoi ciblé au seul compte de test après accord du propriétaire. Tester app ouverte, en arrière-plan et fermée normalement, puis le clic. Une fermeture forcée peut limiter la réception/reprise selon le système ; rouvrir l'app pour les essais.
10. Après réception validée, créer la mise à jour 2.0.1 sur la fiche EXISTANTE, sélectionner le build et soumettre à Apple. Aucun nouvel App ID ou compte Firebase à créer.

## Suite exacte : Android

1. Play Console > CEC 2026 > Tester et publier > Tests > Tests internes : créer une release et importer l'AAB ci-dessus (code 21).
2. Installer via le lien de test, se connecter et autoriser les notifications. Vérifier « Appareil enregistré ».
3. Tester les quatre événements ci-dessous ; vérifier aussi le clic vers la réunion mise à jour.
4. Après validation, préparer la release de production. La release 2 était encore en examen : tenir compte de son état courant sans l'annuler automatiquement. Aucune configuration supplémentaire des notifications n'est à ajouter à Play Console pour FCM.

## Recette métier indispensable

Sur un environnement de test, avec deux membres et des appareils autorisés :

| Action | Résultat attendu |
| --- | --- |
| A recommande B | B reçoit une alerte ; A n'en reçoit pas pour cet envoi |
| A remercie B | B reçoit une alerte |
| Administrateur crée une réunion | Chaque membre actif enregistré reçoit une alerte |
| Administrateur change date, heure, adresse, ordre du jour ou compte rendu | Les membres actifs enregistrés reçoivent une alerte et ouvrent les informations actualisées |
| Administrateur sauvegarde sans changement | Aucune alerte |
| Membre se déconnecte | Cet appareil ne reçoit plus ses échanges privés |

Ne pas créer une réunion factice en production pour cette recette : elle alerterait tous les membres enregistrés. Utiliser un environnement séparé ou une véritable annonce prévue avec accord. Ne pas considérer un HTTP 200 FCM comme une preuve de réception sur iPhone.

## Références

- [Firebase Flutter : configuration, APNs et autorisations](https://firebase.google.com/docs/cloud-messaging/flutter/get-started)
- [Réception des messages Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages)
- [Validation FCM sans livraison](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages/send)
- [Swift Package Manager Flutter](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)
- [Fin de publication Firebase CocoaPods](https://firebase.google.com/docs/ios/cocoapods-deprecation?hl=fr)
