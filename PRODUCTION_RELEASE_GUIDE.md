# CEC 2026 - tutoriel complet de mise en production

Dernière vérification technique : 5 septembre 2026.

**Actualisation notifications du 28 septembre 2026 :** consulter [le rapport et la recette notifications](NOTIFICATIONS_AUDIT_2026-09-28.md) avant de suivre les anciennes étapes Firebase/iOS ci-dessous. Le backoffice est déployé, la clé APNs de production est maintenant importée, et l'app iOS existante est `net.wevox.cec.cec`, équipe `6YFVLX2X38`. La version mobile préparée est **2.0.1 (21)**. Ne pas recréer d'application ni de clé ; la validation sur iPhone et la compilation sur Mac restent à effectuer.

Ce document part du code présent dans :

- application mobile Flutter : `C:\Users\Matthieu\StudioProjects\cec2026`
- API, site public et administration Laravel/Filament : `C:\wamp642\www\cec`

Il décrit l'ordre exact à suivre. Ne soumets pas l'application aux stores avant d'avoir terminé la section 1.

## 1. Les cinq blocages à lever avant la soumission

- [ ] Déployer la nouvelle version Laravel, ses migrations, ses fichiers publics et sa configuration Firebase.
- [ ] Vérifier que les quatre URL de contrôle indiquées ci-dessous répondent avec les statuts attendus.
- [ ] Créer deux comptes de démonstration permanents et préparer du contenu visible pour les contrôleurs des stores.
- [ ] Finaliser Firebase/APNs sur iOS, puis tester les notifications sur un véritable iPhone.
- [ ] Construire et tester l'archive iOS sur un Mac avec Xcode 26.2 ou plus récent.

État constaté le 5 septembre 2026 sur `https://cec.wevox.cloud` :

- la présentation, la confidentialité et la suppression de compte répondent en `200` ;
- `https://cec.wevox.cloud/application/conditions-utilisation.html` répond encore en `404` ;
- `POST /api/me/push-tokens` et `POST /api/reports` répondent encore en `404` ;
- le serveur public utilise donc toujours l'ancienne version du backend.

Le bundle Android ne doit pas être envoyé en production tant que ce déploiement n'est pas fait. L'application publiée appellerait sinon des routes absentes pour les notifications, les signalements, le blocage et les nouveaux médias.

## 2. Fiche d'identité de l'application

| Champ | Valeur à utiliser |
|---|---|
| Nom | `CEC 2026` |
| Version | `1.0.0` |
| Numéro de build initial | `1` |
| Package Android | `cloud.wevox.cec2026.cec2026` |
| Bundle ID iOS | `net.wevox.cec.cec` (app publiee, equipe `6YFVLX2X38`) |
| Projet Firebase | `cec-2026` |
| Site / URL marketing / URL d'assistance | `https://cec.wevox.cloud/application/` |
| Politique de confidentialité | `https://cec.wevox.cloud/application/confidentialite.html` |
| Suppression de compte et de données | `https://cec.wevox.cloud/application/suppression-compte.html` |
| Conditions d'utilisation | `https://cec.wevox.cloud/application/conditions-utilisation.html` |
| Email d'assistance | `contact@wevox.eu` |
| Email de suppression | `contact@wevox.eu` |
| Responsable | `Club des Entrepreneurs du Cotentin` |
| Adresse | `40 boulevard Schuman, BP 612, 50100 Cherbourg-en-Cotentin` |
| Conservation annoncée | deux ans maximum après le départ du membre, sauf obligation légale contraire |
| Prix | gratuit |
| Public visé | professionnels et personnes souhaitant découvrir le réseau économique du Cotentin ; l'application n'est pas réservée aux membres |

Fiche publique utilisée pour vérifier l'adresse dans cette documentation :

`https://www.net1901.org/association/CLUB-DES-ENTREPRENEURS-DU-COTENTIN,1000131148.html`

Cette page n'est pas garantie comme justificatif accepté par Apple ou Google. Si un store demande une preuve, fournis le document officiel qu'il liste dans son écran de vérification et vérifie que le nom et l'adresse concordent exactement.

## 3. Ce qui est déjà terminé dans le code

### Mobile

- Firebase Messaging Android et iOS est intégré.
- Le token FCM est demandé puis enregistré auprès de Laravel après connexion.
- Les notifications ouvertes dirigent vers Recommandations ou Remerciements.
- Android 13+ demande l'autorisation `POST_NOTIFICATIONS`.
- Les notifications au premier plan sont affichées correctement.
- La signature Android de production est configurée.
- Le core library desugaring requis par `flutter_local_notifications` est actif.
- Le niveau d'API cible Android est 36.
- Les photos de profil, logos et bannières sont choisis depuis la galerie ou les fichiers du téléphone et envoyés en multipart.
- Les conditions sont acceptées lors de la connexion.
- Les écrans permettent le signalement, le masquage et le blocage.
- Les pages légales sont accessibles depuis l'application.
- Firebase iOS est configuré pour Swift Package Manager, sans `Podfile` Firebase à maintenir.

### Laravel / Filament

- Les tokens FCM sont stockés dans `member_push_tokens`.
- Les envois FCM HTTP v1 sont synchrones, sans file d'attente.
- Une recommandation et un remerciement déclenchent leur notification.
- Les anciens tokens FCM invalides sont supprimés automatiquement.
- Les uploads mobiles sont validés, stockés et leurs anciens fichiers sont nettoyés lors d'un remplacement.
- Les signalements et blocages sont gérés par l'API.
- Filament contient une ressource `Signalements` et affiche le nombre de signalements en attente.
- Un membre peut être désactivé depuis Filament.
- Les anciennes sessions mobiles seront révoquées une fois lors de la migration afin de faire accepter les conditions à tous les comptes.
- La clé privée Firebase est maintenant explicitement ignorée par Git dans le projet Laravel.

### Vérifications déjà réussies

- `flutter analyze` : aucun problème.
- `flutter test` : succès.
- `php artisan test` : 14 tests, 58 assertions, succès.
- `vendor/bin/pint --dirty` : succès.
- bundle Android Release signé : succès.
- APK Android Release installé et lancé sur émulateur : succès.
- réception d'une notification Firebase Android réelle : validée par le propriétaire du projet.

## 4. Déployer Laravel avant toute publication

### 4.0 Ne pas oublier les nouveaux fichiers

Les deux dossiers de travail contiennent encore des modifications non commitées et de nombreux fichiers nouveaux. Si ton hébergement se déploie depuis Git, un simple `git pull` ou `git add -u` n'inclura pas ces nouveaux fichiers.

1. Dans chaque projet, exécute `git status --short`.
2. Relis la liste avant de préparer le commit de release afin de ne pas embarquer un fichier personnel sans rapport.
3. Côté Laravel, inclus bien les nouveaux contrôleurs, modèles, observateurs, services, migrations, tests, fichiers de langue, `public/application` et `public/css/cec-admin.css`.
4. Côté mobile, inclus bien les nouveaux services, l'écran légal, `Runner.entitlements`, les guides, l'outil de génération et les visuels souhaités dans l'archive du projet.
5. `android/app/google-services.json` est actuellement non suivi : ajoute-le au dépôt privé ou transfère-le séparément sur les machines de build Android.
6. Ne force jamais l'ajout de `android/key.properties`, du JKS, du `.env` Laravel, du service account Firebase ou de la clé APNs ; ces secrets sont volontairement hors Git.
7. Crée ensuite ton commit ou ton paquet de livraison complet avant le déploiement.

Le serveur Laravel n'a pas besoin du projet Flutter, du JKS Android ni de `google-services.json`. Il a besoin de tout le code de `C:\wamp642\www\cec` et du service account Firebase installé séparément.

### 4.1 Préparer le serveur

1. Fais une sauvegarde de la base de données de production.
2. Fais une copie du `.env` de production.
3. Sauvegarde le dossier `storage/app/public` si les médias ne sont pas déjà sauvegardés ailleurs.
4. Vérifie que la racine web du domaine pointe vers le dossier Laravel `public`, jamais vers la racine du dépôt.
5. Vérifie que HTTPS est actif sur `https://cec.wevox.cloud`.
6. Vérifie que l'extension PHP OpenSSL est active :

```bash
php -m | grep -i openssl
```

La commande doit afficher `openssl`.

Note locale : WAMP affiche actuellement un avertissement de version Imagick, compilé pour ImageMagick 1808 alors que la DLL chargée est en 1809. Cela n'a pas empêché les tests ni les uploads actuels, qui ne transforment pas les images avec Imagick. Mets l'extension PHP et les DLL ImageMagick de WAMP sur une version concordante avant d'ajouter plus tard du redimensionnement serveur ; vérifie séparément l'environnement PHP du serveur de production.

### 4.2 Créer la clé serveur Firebase

Cette clé est différente de `google-services.json`. Elle sert uniquement au serveur Laravel pour envoyer les notifications.

1. Ouvre la [console Firebase](https://console.firebase.google.com/project/cec-2026/settings/serviceaccounts/adminsdk).
2. Sélectionne le projet `cec-2026` si Firebase te le demande.
3. Clique sur `Paramètres du projet` puis `Comptes de service`.
4. Reste dans la section `SDK Admin Firebase`.
5. Clique sur `Générer une nouvelle clé privée`.
6. Confirme avec `Générer la clé`.
7. Conserve le JSON téléchargé dans un gestionnaire de secrets.
8. Sur le serveur, crée `storage/app/firebase`.
9. Dépose la clé sous le nom exact `storage/app/firebase/service-account.json`.
10. Ne place jamais ce fichier dans `public`, un email, un ticket ou le dépôt Git.
11. Sur Linux, limite ses droits :

```bash
chmod 600 storage/app/firebase/service-account.json
```

### 4.3 Mettre à jour le `.env` de production

Conserve les vraies valeurs de base de données, de cache et d'email déjà présentes. Modifie ou ajoute uniquement les lignes utiles :

```dotenv
APP_NAME="CEC 2026"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://cec.wevox.cloud
LOG_LEVEL=warning

FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync

FIREBASE_PROJECT_ID=cec-2026
FIREBASE_CREDENTIALS=storage/app/firebase/service-account.json
```

Il ne faut ni worker de queue ni Supervisor pour les notifications : `QUEUE_CONNECTION=sync` correspond à la demande d'envoi immédiat.

### 4.4 Déployer le code et les migrations

Depuis la racine Laravel sur le serveur :

```bash
php artisan down
composer install --no-dev --optimize-autoloader
npm ci
npm run build
php artisan optimize:clear
php artisan migrate --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan up
```

Si l'hébergement ne fournit pas Node.js, exécute `npm ci` puis `npm run build` dans `C:\wamp642\www\cec` sur ce PC et téléverse aussi le dossier généré `public/build`. Ne saute pas simplement la compilation Vite.

Si `php artisan storage:link` indique que le lien existe déjà, continue simplement. Si une commande échoue, ne lance pas `php artisan up` avant d'avoir corrigé l'erreur.

La migration `2026_09_05_010000_expire_mobile_sessions_for_terms_acceptance.php` supprime une fois les anciens jetons de connexion. C'est volontaire : tous les membres devront se reconnecter et accepter les conditions.

Les dossiers suivants doivent être accessibles en écriture par PHP :

```text
storage
bootstrap/cache
```

### 4.5 Contrôler le déploiement

Dans PowerShell sur ce PC, exécute chaque commande :

```powershell
curl.exe -s -o NUL -w "%{http_code}`n" https://cec.wevox.cloud/application/index.html
curl.exe -s -o NUL -w "%{http_code}`n" https://cec.wevox.cloud/application/confidentialite.html
curl.exe -s -o NUL -w "%{http_code}`n" https://cec.wevox.cloud/application/suppression-compte.html
curl.exe -s -o NUL -w "%{http_code}`n" https://cec.wevox.cloud/application/conditions-utilisation.html
curl.exe -s -o NUL -w "%{http_code}`n" https://cec.wevox.cloud/api/me
curl.exe -s -o NUL -w "%{http_code}`n" -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d "{}" https://cec.wevox.cloud/api/me/push-tokens
curl.exe -s -o NUL -w "%{http_code}`n" -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d "{}" https://cec.wevox.cloud/api/reports
```

Résultats attendus, dans le même ordre :

```text
200
200
200
200
401
401
422
```

Un `401` est normal pour une route privée appelée sans connexion. Le `422` de `/api/reports` confirme que la route publique existe et refuse correctement un formulaire vide.

### 4.6 Préparer les données vues par les contrôleurs

Dans Filament, ouvre `https://cec.wevox.cloud/admin` puis :

1. Dans `Actualités`, publie au moins une actualité récente avec un vrai titre, une image autorisée et un contenu complet.
2. Dans `Réunions`, crée au moins une rencontre future avec date, lieu et description.
3. Dans `Entreprises`, vérifie qu'au moins trois fiches complètes possèdent un logo ou une bannière.
4. Dans `Membres`, vérifie que plusieurs profils non sensibles sont actifs et correctement présentés.
5. Crée deux comptes de démonstration dédiés aux stores, sans données personnelles réelles.
6. Avec le compte B, envoie au compte A une recommandation et un remerciement afin que ces deux écrans ne soient pas vides lors de la revue.
7. Laisse ces comptes actifs pendant toute la durée de la revue et au moins quelques semaines après la publication.

Valeurs à créer et à conserver dans un gestionnaire de mots de passe :

```text
Compte de démonstration A
Email : [À CRÉER]
Mot de passe : [À CRÉER]

Compte de démonstration B
Email : [À CRÉER]
Mot de passe : [À CRÉER]
```

## 5. Test fonctionnel complet avant les stores

Réalise ce test avec deux téléphones ou un téléphone et l'émulateur :

1. Installe le build Release.
2. Ouvre Actualités, Réunions, le détail d'une réunion, l'annuaire, une entreprise et un membre sans te connecter.
3. Connecte le compte A et accepte les conditions.
4. Accepte les notifications.
5. Modifie la photo du profil depuis `Galerie`.
6. Modifie la photo une seconde fois depuis `Fichiers` afin de tester les deux sources et le remplacement du média.
7. Modifie le logo puis la bannière de l'entreprise.
8. Avec le compte B, envoie une recommandation au compte A.
9. Vérifie la réception lorsque l'application A est ouverte, en arrière-plan, puis fermée.
10. Touche la notification et vérifie l'ouverture de Recommandations.
11. Recommence avec un remerciement et vérifie l'ouverture de Remerciements.
12. Signale un profil, puis vérifie le signalement dans `Filament > Signalements`.
13. Bloque un membre et vérifie qu'il ne peut plus échanger de recommandations ou remerciements avec ce compte.
14. Déconnecte-toi puis reconnecte-toi.
15. Depuis Informations, ouvre les quatre liens : présentation, confidentialité, conditions et suppression.

Ne poursuis pas si une étape échoue.

## 6. Firebase Android

### 6.1 Ce qui est déjà prêt

Le fichier Android existe déjà ici :

```text
C:\Users\Matthieu\StudioProjects\cec2026\android\app\google-services.json
```

Le package déclaré dans ce fichier et dans Gradle doit être exactement :

```text
cloud.wevox.cec2026.cec2026
```

Il n'y a pas d'autre fichier Firebase client à ajouter pour Android. La clé `service-account.json` de la section 4 reste toutefois indispensable sur Laravel.

### 6.2 Vérifier depuis Firebase

1. Ouvre [Firebase Console > projet cec-2026](https://console.firebase.google.com/project/cec-2026/overview).
2. Clique sur la roue dentée puis `Paramètres du projet`.
3. Dans `Général`, vérifie l'application Android et son package.
4. Dans `Cloud Messaging`, vérifie que l'API Firebase Cloud Messaging HTTP v1 est active.
5. Pour un test manuel, ouvre `Messaging`, clique sur `Créer votre première campagne` ou `Nouvelle campagne`, puis `Messages Firebase Notification`.
6. Saisis un titre et un texte de test.
7. Clique sur `Envoyer un message test`.
8. Colle le token imprimé par une version Debug dans la console Flutter.
9. Envoie et vérifie la réception.

Les empreintes SHA du certificat ne sont pas nécessaires à FCM seul. Elles seront utiles si Google Sign-In, App Check ou d'autres services Google sont ajoutés plus tard.

Empreintes du certificat Release actuellement utilisé :

```text
SHA-1   FF:D9:00:2E:7F:45:48:B9:F1:00:40:08:31:EC:D5:92:3D:96:86:3F
SHA-256 87:EA:54:81:EF:EB:0B:A1:D7:A0:34:07:42:FD:29:2B:B8:E7:E0:9A:8A:AA:13:96:C0:D9:50:E9:BB:CA:30:6E
```

## 7. Firebase et Apple Push Notifications sur iOS

Android est opérationnel, mais iOS n'est pas prêt tant que les étapes suivantes ne sont pas terminées.

### 7.1 Enregistrer l'identifiant Apple

1. Connecte-toi à [Apple Developer - Identifiers](https://developer.apple.com/account/resources/identifiers/list).
2. Clique sur le bouton `+`.
3. Choisis `App IDs`, puis `Continue`.
4. Choisis `App`, puis `Continue`.
5. Description : `CEC 2026`.
6. Bundle ID : utilise l'identifiant explicite existant `net.wevox.cec.cec` ; l'application est deja publiee.
7. Dans Capabilities, coche `Push Notifications`.
8. Clique sur `Continue`, vérifie puis `Register`.

Si cet App ID existe déjà, ouvre-le, active `Push Notifications`, puis clique sur `Save`.

### 7.2 Créer la clé APNs

1. Dans Apple Developer, ouvre [Certificates, Identifiers & Profiles > Keys](https://developer.apple.com/account/resources/authkeys/list).
2. Clique sur `+`.
3. Nom : `CEC 2026 APNs`.
4. Coche `Apple Push Notifications service (APNs)`.
5. Clique sur `Continue`, puis `Register`.
6. Télécharge le fichier `.p8`. Apple ne permet généralement qu'un seul téléchargement.
7. Note le `Key ID` affiché.
8. Note le `Team ID` visible dans [Membership details](https://developer.apple.com/account#MembershipDetailsCard).
9. Conserve le `.p8`, le Key ID et le Team ID dans un gestionnaire de secrets.

Champs encore inconnus et à renseigner :

```text
Apple Team ID : [À RENSEIGNER]
APNs Key ID : [À RENSEIGNER]
Fichier APNs .p8 : [À CRÉER ET SAUVEGARDER]
```

### 7.3 Ajouter l'application iOS dans Firebase

1. Ouvre [Firebase > Paramètres généraux du projet cec-2026](https://console.firebase.google.com/project/cec-2026/settings/general).
2. Dans `Vos applications`, clique sur l'icône iOS `+` si l'application iOS n'existe pas.
3. Apple bundle ID : `net.wevox.cec.cec`.
4. Surnom : `CEC 2026 iOS`.
5. App Store ID : laisse vide jusqu'à la création de la fiche App Store Connect.
6. Clique sur `Enregistrer l'application`.
7. Télécharge `GoogleService-Info.plist`.
8. Sur le Mac, place-le dans `ios/Runner/GoogleService-Info.plist`.
9. Ouvre `ios/Runner.xcworkspace` dans Xcode.
10. Glisse le fichier dans le groupe jaune `Runner`.
11. Coche `Copy items if needed` si Xcode le propose.
12. Coche la target `Runner`.
13. Dans l'inspecteur de fichier, vérifie `Target Membership > Runner`.

Le fichier `GoogleService-Info.plist` manque actuellement au dépôt mobile. Ne crée pas un faux fichier : télécharge celui du projet Firebase.

### 7.4 Relier APNs à Firebase

1. Ouvre [Firebase > Cloud Messaging](https://console.firebase.google.com/project/cec-2026/settings/cloudmessaging).
2. Descends à `Configuration de l'application Apple`.
3. Sélectionne l'application iOS CEC 2026.
4. Dans `Clé d'authentification APNs`, clique sur `Importer`.
5. Sélectionne le fichier `.p8`.
6. Saisis le `Key ID` et le `Team ID` notés plus haut.
7. Clique sur `Importer`.

Une clé APNs d'authentification fonctionne pour les environnements développement et production. Ne crée pas de certificat APNs séparé si cette clé est correctement importée.

### 7.5 Préparer le projet sur le Mac

Firebase cessant de publier de nouvelles versions CocoaPods en octobre 2026, le projet est déjà configuré pour Swift Package Manager dans `pubspec.yaml`. Il n'existe pas de `Podfile` à exécuter.

1. Installe Flutter 3.44.2 ou une version stable plus récente compatible avec le projet.
2. Installe Xcode 26.2 ou une version plus récente.
3. Dans Terminal, va dans le projet puis lance :

```bash
flutter doctor -v
flutter config --enable-swift-package-manager
flutter clean
flutter pub get
flutter build ios --config-only
open ios/Runner.xcworkspace
```

4. Dans Xcode, sélectionne `Runner` puis la target `Runner`.
5. Ouvre `Signing & Capabilities`.
6. Coche `Automatically manage signing`.
7. Dans `Team`, sélectionne le vrai compte Apple Developer.
8. Vérifie `Bundle Identifier = net.wevox.cec.cec`.
9. Clique sur `+ Capability` et ajoute `Push Notifications` si absent.
10. Ajoute `Background Modes` si absent.
11. Dans `Background Modes`, coche `Background fetch` et `Remote notifications`.
12. Attends la résolution complète des packages Swift avant de compiler.

Le projet contient déjà `Runner.entitlements` avec :

- `development` pour Debug ;
- `production` pour Profile et Release.

N'exécute pas `pod install` et n'ajoute pas Firebase avec CocoaPods.

### 7.6 Tester sur un véritable iPhone

1. Branche un iPhone au Mac.
2. Sélectionne cet iPhone dans Xcode.
3. Lance la target Runner en Debug.
4. Connecte le compte de démonstration A.
5. Accepte les notifications.
6. Vérifie dans Laravel qu'une ligne iOS apparaît dans `member_push_tokens`.
7. Depuis le compte B, envoie une recommandation.
8. Teste l'application ouverte, en arrière-plan et complètement fermée.
9. Touche la notification et vérifie la navigation.
10. Recommence avec un remerciement.
11. Répète le même test via TestFlight avant la soumission finale.

## 8. Préparer le compte Google Play

### 8.1 Vérification du compte

1. Ouvre la [Google Play Console](https://play.google.com/console/).
2. Ouvre `Compte développeur > À propos de vous`.
3. Termine toutes les cartes marquées `Action requise` ou `Vérification requise`.
4. Vérifie l'email et le numéro de téléphone développeur.
5. Si le compte appartient juridiquement à l'association, son type doit être `Organisation`.
6. Un compte Organisation demande notamment un numéro D-U-N-S, un site vérifié et des justificatifs concordants.
7. N'invente pas le D-U-N-S. Demande-le ou retrouve-le auprès de Dun & Bradstreet si l'écran l'exige.

Pour vérifier le site d'un compte Organisation :

1. Utilise `https://cec.wevox.cloud/` comme site principal de l'organisation.
2. Ajoute d'abord cette URL dans [Google Search Console](https://search.google.com/search-console/) avec le même compte Google que la Play Console, si possible.
3. Choisis une propriété `Préfixe de l'URL` et suis l'une des méthodes proposées par Google.
4. Si Google fournit un fichier HTML, téléverse ce fichier exact à la racine publique Laravel et vérifie son URL avant de cliquer sur `Valider`. N'invente ni le nom ni le contenu du fichier.
5. Reviens dans Play Console ou Android Developer Console, ouvre la page `Identité` / `À propos de vous`, puis clique sur `Envoyer une demande de vérification du site`.
6. Si Search Console appartient à un autre compte Google, son propriétaire doit accepter la demande d'association reçue par email ou dans Search Console.

Valeurs manquantes :

```text
Type du compte Play : [PERSONNEL OU ORGANISATION À VÉRIFIER]
Numéro D-U-N-S si Organisation : [À RENSEIGNER]
Téléphone public du développeur : [À RENSEIGNER]
État de vérification du compte : [À VÉRIFIER]
Date de création du compte personnel, le cas échéant : [À VÉRIFIER]
```

Documentation officielle :

- [Choisir un type de compte développeur](https://support.google.com/android-developer-console/answer/16641046?hl=fr)
- [Vérification de l'identité développeur](https://support.google.com/android-developer-console/answer/16641416?hl=fr)

## 9. Créer et remplir la fiche Google Play

### 9.1 Créer l'application

1. Dans [Google Play Console](https://play.google.com/console/), clique sur `Créer une application`.
2. Langue par défaut : `Français (France) – fr-FR`.
3. Nom : `CEC 2026`.
4. Type : `Application`.
5. Prix : `Gratuite`.
6. Email de contact : `contact@wevox.eu`.
7. Coche les déclarations exactes présentées par Google après les avoir lues.
8. Clique sur `Créer l'application`.

Attention : une application publiée comme gratuite ne peut généralement pas devenir payante ensuite. Cette application n'ayant ni achat intégré ni abonnement, `Gratuite` est le bon choix pour le fonctionnement actuel.

### 9.2 Fiche Play Store principale

Depuis le tableau de bord de l'application, ouvre `Développer le nombre d'utilisateurs > Présence sur le Play Store > Fiche Play Store principale`. Selon la langue de la console, le chemin peut être `Grow users > Store presence > Main store listing`.

Colle les valeurs suivantes.

**Nom de l'application**

```text
CEC 2026
```

**Description courte**

```text
Actualités, rencontres et réseau des entrepreneurs du Cotentin.
```

Cette description contient moins de 80 caractères.

**Description complète**

```text
CEC 2026 est l’application du Club des Entrepreneurs du Cotentin, ouverte à toutes les personnes qui souhaitent découvrir la vie économique et les acteurs du territoire.

Consultez librement :
- les actualités et initiatives du réseau
- le calendrier et le détail des rencontres
- l’annuaire des entreprises et des professionnels du Cotentin

Les membres disposant d’un compte peuvent également :
- mettre à jour leur profil, leur photo, le logo et la bannière de leur entreprise
- inviter un contact à une rencontre
- envoyer et recevoir des recommandations
- remercier un membre après une affaire réalisée
- recevoir des notifications utiles pour leurs échanges

Des outils de signalement, de masquage et de blocage sont intégrés afin de préserver des échanges professionnels respectueux.

L’application ne contient ni publicité, ni achat intégré. Les comptes membres sont créés et administrés par le Club.
```

**Catégorie**

```text
Application > Professionnel
```

La traduction anglaise affichée par certaines consoles est `Business`.

**Coordonnées de la fiche**

```text
Email : contact@wevox.eu
Téléphone : [À RENSEIGNER]
Site Web : https://cec.wevox.cloud/application/
```

### 9.3 Importer les visuels Google Play

Tous les fichiers prêts se trouvent dans `release_assets/google-play`.

L'image de présentation est obligatoire pour publier la fiche. Elle est déjà fournie au format Google exact `1024 x 500`. Les captures téléphone sont des compositions premium réalisées à partir de captures réelles de l'application sur émulateur Android. Les captures tablette restent en plein écran, conformément à la recommandation Google pour les grands écrans.

1. Icône de l'application : importe `icon-512.png`.
2. Image de présentation : importe `feature-graphic-1024x500.png`.
3. Captures de téléphone : importe dans l'ordre `01` à `06` les fichiers `*-1080x1920.png`.
4. Captures tablette 7 pouces : importe dans l'ordre `01` à `04` les fichiers du dossier `tablet`.
5. Captures tablette 10 pouces : tu peux importer le même jeu `1600x2560` dans l'ordre `01` à `04`.
6. Ne téléverse pas le dossier `release_assets/screenshots/android` : il contient les prises de travail, pas les visuels finaux.
7. Une vidéo YouTube n'est pas nécessaire pour cette première version.
8. Pour chaque capture, renseigne le texte alternatif proposé dans `release_assets/README.md`.
9. Clique sur `Enregistrer`.

Tu peux contrôler toute la série avant import dans `release_assets/review/android-premium-contact-sheet.jpg` et `release_assets/review/tablets-premium-contact-sheet.jpg`. Ces deux planches de contrôle ne doivent pas être téléversées.

### 9.4 Politique de confidentialité

1. Ouvre `Règles et programmes > Contenu de l'application`.
2. Dans `Règles de confidentialité`, clique sur `Commencer` ou `Gérer`.
3. Colle :

```text
https://cec.wevox.cloud/application/confidentialite.html
```

4. Enregistre.

### 9.5 Accès à l'application

1. Dans `Contenu de l'application`, ouvre `Accès à l'application`.
2. Choisis `Tout ou partie des fonctionnalités est restreint`.
3. Clique sur `Ajouter de nouvelles instructions`.
4. Nom des instructions : `Compte membre de démonstration`.
5. Email : `[EMAIL DU COMPTE A]`.
6. Mot de passe : `[MOT DE PASSE DU COMPTE A]`.
7. Dans les instructions supplémentaires, colle :

```text
Les actualités, les rencontres et l’annuaire sont accessibles sans connexion.

Le compte fourni donne accès à l’espace membre, au profil, aux recommandations et aux remerciements. Il ne nécessite ni validation supplémentaire, ni code à usage unique, ni abonnement.

Les comptes sont créés par l’administration du Club ; l’application ne propose pas d’inscription autonome.
```

8. Coche que les identifiants resteront valides pendant la revue.
9. Enregistre.

### 9.6 Publicités et autres déclarations

Dans `Contenu de l'application`, réponds comme suit pour le code actuel :

| Écran | Réponse |
|---|---|
| Publicités | `Non, mon application ne contient pas de publicité` |
| Identifiant publicitaire | `Non` |
| Application d'actualités | `Non` ; elle publie les informations d'une association, ce n'est pas un organisme de presse |
| Application gouvernementale | `Non` |
| Fonctionnalités financières | `Aucune` ; le montant d'un remerciement est une information déclarative, pas un paiement ni un service financier |
| Santé | `Aucune fonctionnalité de santé` |
| COVID-19 | `Non` |
| Achats intégrés | `Non` |

### 9.7 Public cible et classification du contenu

1. Ouvre `Public cible et contenu`.
2. Sélectionne uniquement `18 ans et plus` pour cette application de réseau professionnel.
3. Confirme que l'application n'est pas conçue pour les enfants.
4. Ouvre ensuite `Classification du contenu` et démarre le questionnaire IARC.
5. Email de classification : `contact@wevox.eu`.
6. Catégorie : choisis `Application de réseau social, communication ou autre application non ludique`, selon le libellé proposé.
7. Déclare que l'application contient du contenu généré ou transmis par les utilisateurs.
8. Déclare qu'elle permet des interactions entre utilisateurs au moyen de recommandations et de remerciements.
9. Pour violence, sexualité, drogues, jeux d'argent et langage grossier, réponds `Non` si le contenu réel administré reste conforme.
10. Ne force pas une classification : laisse IARC la calculer à partir des réponses.

### 9.8 Contenu généré par les utilisateurs

Les exigences sont couvertes dans le code, mais elles doivent également être exploitées au quotidien :

- acceptation des conditions à la connexion ;
- signalement depuis les fiches et contenus ;
- masquage local immédiat ;
- blocage d'un membre connecté ;
- modération dans `Filament > Signalements` ;
- possibilité de désactiver un membre.

Dans tout questionnaire UGC, indique que le service dispose de conditions d'utilisation, d'un mécanisme de signalement, d'un blocage et d'une modération humaine. Consulte la [règle Google Play sur le contenu généré par les utilisateurs](https://support.google.com/googleplay/android-developer/answer/9876937?hl=fr).

### 9.9 Sécurité des données Google Play

Ouvre `Règles et programmes > Contenu de l'application > Sécurité des données`, puis clique sur `Commencer`.

Réponses générales recommandées pour le code audité :

```text
L'application collecte-t-elle ou partage-t-elle des données utilisateur requises ? Oui
Les données sont-elles chiffrées en transit ? Oui
Les utilisateurs peuvent-ils demander la suppression de leurs données ? Oui
URL de suppression : https://cec.wevox.cloud/application/suppression-compte.html
Les données sont-elles partagées avec des tiers au sens du formulaire ? Non
```

La réponse `Non` au partage suppose que Firebase et l'hébergeur agissent uniquement comme prestataires techniques pour ton compte. Si un autre prestataire utilise les données pour ses propres finalités, il faut le déclarer.

Déclare les catégories suivantes :

| Catégorie Google | Collectée | Liée à l'utilisateur | Obligatoire | Finalité principale |
|---|---:|---:|---:|---|
| Informations personnelles > Nom | Oui | Oui | Oui pour un compte membre | Fonctionnalités, gestion du compte |
| Informations personnelles > Adresse email | Oui | Oui | Oui pour un compte membre | Authentification, gestion du compte, assistance |
| Informations personnelles > Numéro de téléphone | Oui | Oui | Non | Fonctionnalités de l'annuaire |
| Informations personnelles > Identifiants utilisateur | Oui | Oui | Oui pour un compte membre | Authentification, gestion du compte |
| Informations personnelles > Autres informations | Oui | Oui | Non | Profil et entreprise |
| Informations financières > Autres informations financières | Oui | Oui | Non | Montant HT déclaré dans un remerciement ; aucune transaction |
| Messages > Autres messages dans l'application | Oui | Oui | Non | Recommandations et remerciements |
| Photos et vidéos > Photos | Oui | Oui | Non | Photo de profil, logo et bannière |
| Activité dans l'application > Autre contenu généré par l'utilisateur | Oui | Oui | Non | Profils, entreprises, invités, descriptions et signalements |
| Identifiants de l'appareil ou autres identifiants | Oui | Oui | Non | Notifications FCM et sécurité de l'installation |
| Informations sur l'application et performances > Diagnostics | Oui | Non | Oui avec le SDK | Fonctionnement et fiabilité de Firebase Messaging |

Pour chaque type :

- coche `Collectées` ;
- ne coche pas `Partagées`, sous la réserve prestataire indiquée plus haut ;
- coche `Traitement temporaire` uniquement si Google définit réellement la donnée comme éphémère ; les données métier de CEC ne le sont pas ;
- coche `Fonctionnalités de l'application` ;
- ajoute `Gestion du compte` pour l'identité ;
- ajoute `Prévention de la fraude, sécurité et conformité` pour les signalements, blocages et identifiants techniques ;
- ne coche jamais Publicité, Marketing ou Personnalisation pour le code actuel.

Firebase Messaging collecte aussi des métadonnées techniques nécessaires à son service. Vérifie cette déclaration lors de chaque montée de version avec la [documentation Firebase pour Google Play](https://firebase.google.com/docs/android/play-data-disclosure).

### 9.10 Suppression de compte

L'application ne permet pas de créer soi-même un compte ; les comptes membres sont créés par l'administration du Club. Une demande de suppression reste disponible dans l'application et sur le Web.

Si Google affiche une carte `Suppression de compte` :

1. Indique que l'application n'offre pas la création de compte autonome.
2. Fournis malgré tout cette URL publique :

```text
https://cec.wevox.cloud/application/suppression-compte.html
```

3. Vérifie que l'adresse `contact@wevox.eu` répond réellement aux demandes.

Référence : [Exigence Google Play relative à la suppression de compte](https://support.google.com/googleplay/android-developer/answer/13327111?hl=fr).

## 10. Tester puis publier sur Google Play

### 10.1 Bundle à importer

Le bundle signé prêt à envoyer est :

```text
C:\Users\Matthieu\StudioProjects\cec2026\build\app\outputs\bundle\release\app-release.aab
```

Contrôle SHA-256 du fichier :

```text
9C81AE09CCD9097E8A8C9BB1A0F78B3F335FB09C25D3DAC4C0CBEEB77B26C3A4
```

Ce fichier utilise `versionCode = 1`. Si le package a déjà reçu un APK ou AAB portant le code `1`, même sur une piste de test, remplace `version: 1.0.0+1` par `version: 1.0.0+2` dans `pubspec.yaml`, relance `flutter build appbundle --release`, puis utilise le nouveau bundle. Google n'accepte jamais deux artefacts ayant le même versionCode.

Conserve hors du dépôt et à deux endroits sécurisés :

```text
android/app/cec2026-release.jks
android/key.properties
```

Ne partage jamais les mots de passe de signature. Active `Play App Signing` quand Google le propose ; la clé locale reste alors la clé d'importation à conserver.

### 10.2 Piste de test interne

1. Ouvre `Tests et publication > Tests > Tests internes`.
2. Clique sur `Créer une version`.
3. Active ou confirme `Play App Signing`.
4. Importe `app-release.aab`.
5. Nom de la version : `1.0.0 (1)`.
6. Colle les notes de version fournies plus bas.
7. Clique sur `Suivant`.
8. Corrige toute erreur rouge ; lis également les avertissements.
9. Clique sur `Enregistrer`, puis `Examiner la version` et `Lancer le déploiement en test interne`.
10. Dans l'onglet `Testeurs`, ajoute les adresses de test ou un groupe Google.
11. Ouvre le lien d'inscription sur un vrai téléphone, installe depuis Google Play et refais le test de la section 5.

### 10.3 Test fermé éventuellement obligatoire

Si le compte Play personnel a été créé après le 13 novembre 2023, Google exige généralement un test fermé avec au moins 12 testeurs inscrits sans interruption pendant 14 jours avant de demander l'accès à la production.

1. Ouvre `Tests fermés`.
2. Crée une piste `Production candidate`.
3. Ajoute au moins 12 vrais testeurs.
4. Vérifie que les 12 restent inscrits pendant 14 jours continus.
5. Réponds ensuite au questionnaire `Demander l'accès à la production`.

Cette contrainte dépend du type et de la date du compte, pas du code. Référence : [Exigences de test pour les nouveaux comptes personnels](https://support.google.com/googleplay/android-developer/answer/14151465?hl=fr).

### 10.4 Version de production

1. Quand tous les éléments du tableau de bord sont verts, ouvre `Tests et publication > Production`.
2. Clique sur `Créer une version`.
3. Sélectionne ou importe le bundle déjà validé en test.
4. Nom de version : `1.0.0 (1)`.
5. Colle les notes de version.
6. Clique sur `Suivant`, puis `Examiner la version`.
7. Ouvre chaque erreur ou avertissement et traite-le avant de continuer.
8. Pour une première publication prudente, choisis un déploiement progressif à `20 %` si la console le permet ; sinon publie après validation interne complète.
9. Clique sur `Démarrer le déploiement en production`.

## 11. Préparer le compte Apple

### 11.1 Contrats et identité

1. Ouvre [App Store Connect](https://appstoreconnect.apple.com/).
2. Ouvre `Business` puis `Agreements`.
3. Accepte tout contrat en attente affiché en haut de page.
4. Vérifie que l'adhésion Apple Developer est active.
5. Vérifie que le nom légal affiché est bien celui qui doit publier l'application.

Apple affiche comme vendeur le nom personnel pour un abonnement Individuel, et le nom de l'entité légale pour un abonnement Organisation. Si l'application doit être publiée officiellement au nom du Club :

1. Ouvre [Apple Developer > Membership details](https://developer.apple.com/account#MembershipDetailsCard).
2. Vérifie `Entity Type` et le nom du titulaire.
3. Si le compte est déjà une Organisation au bon nom, continue.
4. Si le compte est Individuel mais doit devenir celui de l'association, n'essaie pas de remplacer simplement le prénom et le nom par celui du Club.
5. Le titulaire doit demander à Apple la conversion vers une Organisation. Apple exige notamment une entité légale, l'autorité de l'engager et son numéro D-U-N-S.
6. Utilise la procédure officielle [Updating an individual membership to an organization membership](https://developer.apple.com/help/account/membership/updating-your-account-information).
7. La page officielle [D-U-N-S Number](https://developer.apple.com/help/account/membership/D-U-N-S/) permet de vérifier ou demander le numéro si nécessaire.

### 11.2 Digital Services Act pour l'Union européenne

Apple demande de déclarer un statut de professionnel pour distribuer dans l'Union européenne. Apple ne peut pas choisir ce statut à ta place.

1. Dans App Store Connect, ouvre `Business`.
2. Ouvre l'onglet `Agreements`.
3. Descends jusqu'à `Compliance`.
4. À droite de `Digital Services Act`, clique sur `Complete Compliance Requirements`.
5. Choisis `This is a trader account` si le titulaire agit dans le cadre de son activité professionnelle ou associative organisée ; en cas d'incertitude juridique, fais valider ce choix par le responsable de l'association.
6. Renseigne et vérifie l'email public.
7. Renseigne et vérifie le téléphone public.
8. Fournis le justificatif légal demandé pour le nom et l'adresse.
9. Confirme les informations.

Pour un compte Organisation, l'adresse publiée vient normalement du numéro D-U-N-S. Pour un compte Individuel, Apple demande directement adresse, téléphone et email. Référence : [exigences Apple DSA](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements).

Valeur encore manquante :

```text
Téléphone public Apple/DSA : [À RENSEIGNER]
Statut trader validé par le titulaire : [À CONFIRMER]
```

## 12. Créer la fiche App Store Connect

### 12.1 Nouvelle application

1. Dans [App Store Connect > Apps](https://appstoreconnect.apple.com/apps), clique sur `+`.
2. Choisis `New App` / `Nouvelle app`.
3. Plateformes : coche `iOS`.
4. Nom : `CEC 2026`.
5. Langue principale : `French`.
6. Bundle ID : sélectionne `net.wevox.cec.cec`.
7. SKU : saisis `CEC2026-IOS-001`.
8. Accès utilisateur : `Full Access` sauf politique interne contraire.
9. Clique sur `Create`.

Le SKU est une référence interne non visible. La valeur proposée peut être utilisée telle quelle.

Après création, App Store Connect affiche un identifiant Apple numérique pour l'app. Copie-le, puis ouvre [Firebase > Paramètres généraux](https://console.firebase.google.com/project/cec-2026/settings/general), édite l'app iOS et renseigne son `App Store ID`. Ce champ n'est pas requis pour recevoir FCM, mais il complète correctement la fiche Firebase.

### 12.2 Informations générales

Dans `App Information` :

```text
Name : CEC 2026
Subtitle : Le réseau du Cotentin
Primary Category : Business
Secondary Category : Social Networking
```

Pour `Content Rights`, l'application affiche des contenus d'association et des médias fournis par des membres. Si Apple demande si elle contient ou affiche du contenu tiers, choisis `Yes`, puis confirme que le Club dispose des droits nécessaires uniquement après avoir vérifié les autorisations sur les textes, photos, logos et bannières. Remplace tout média sans autorisation avant la soumission.

Pour `Age Rating` :

1. Ouvre le questionnaire.
2. Déclare `User-Generated Content = Yes`.
3. Déclare les capacités de communication ou d'échange entre utilisateurs lorsque la question apparaît.
4. Réponds `None` aux catégories violence, sexualité, drogues, jeu d'argent et contenu médical uniquement si les contenus réellement publiés restent dans ce cadre.
5. Laisse Apple calculer la classification, sans inventer un âge.

Dans `Pricing and Availability` :

1. Prix : `Free`.
2. Disponibilité initiale recommandée : `France`.
3. Ajoute d'autres pays uniquement si le Club souhaite effectivement y distribuer l'application.

### 12.3 Texte de la version iOS

Ouvre la version `1.0` sous la plateforme iOS et colle :

**Promotional Text**

```text
Suivez l’actualité entrepreneuriale du Cotentin, retrouvez les rencontres du Club et découvrez les entreprises et professionnels du territoire.
```

**Description**

```text
CEC 2026 est l’application du Club des Entrepreneurs du Cotentin, ouverte à toutes les personnes qui souhaitent découvrir la vie économique et les acteurs du territoire.

Consultez librement :
- les actualités et initiatives du réseau
- le calendrier et le détail des rencontres
- l’annuaire des entreprises et des professionnels du Cotentin

Les membres disposant d’un compte peuvent également :
- mettre à jour leur profil, leur photo, le logo et la bannière de leur entreprise
- inviter un contact à une rencontre
- envoyer et recevoir des recommandations
- remercier un membre après une affaire réalisée
- recevoir des notifications utiles pour leurs échanges

Des outils de signalement, de masquage et de blocage sont intégrés afin de préserver des échanges professionnels respectueux.

L’application ne contient ni publicité, ni achat intégré. Les comptes membres sont créés et administrés par le Club.
```

**Keywords**

```text
entrepreneurs,cotentin,réseau,entreprises,rencontres,actualités,club,cherbourg
```

**URLs**

```text
Support URL : https://cec.wevox.cloud/application/
Marketing URL : https://cec.wevox.cloud/application/
Privacy Policy URL : https://cec.wevox.cloud/application/confidentialite.html
```

**Copyright**

```text
2026 Club des Entrepreneurs du Cotentin
```

Il n'y a ni abonnement ni achat intégré à créer.

### 12.4 Captures App Store

Les fichiers finaux sont dans `release_assets/app-store`.

1. Dans `iPhone 6.9" Display`, importe dans l'ordre `01` à `06` les fichiers `*-1290x2796.png`.
2. Dans `iPad Pro (13-inch) Display`, importe dans l'ordre `ipad-01` à `ipad-04` les fichiers `*-2048x2732.png`.
3. Ne téléverse pas `app-icon-1024.png` dans les captures ; cette image sert d'icône de référence et de secours graphique.
4. L'icône App Store livrée dans le build est générée depuis `assets/logo_app.png`.
5. Aucune vidéo d'aperçu n'est nécessaire.

Les images ont les dimensions acceptées et n'ont pas de canal alpha. La série complète peut être contrôlée dans `release_assets/review/ios-premium-contact-sheet.jpg`.

Important : les compositions ont été produites sous Windows à partir du rendu réel de l'application Flutter capturé sur Android, puis placées dans des châssis iPhone et iPad génériques. Elles ne constituent donc pas encore une preuve d'exécution native iOS. Windows ne peut pas lancer le simulateur iOS. Avant de soumettre à Apple, ouvre l'application sur le simulateur iPhone 6,9 pouces et l'iPad 13 pouces avec le Mac de build, puis vérifie que chaque écran correspond. Remplace les sources des compositions si la typographie, les marges ou un composant natif diffèrent visiblement.

### 12.5 Confidentialité de l'app Apple

Dans la fiche de l'app :

1. Ouvre `App Privacy`.
2. Clique sur `Get Started` ou `Edit`.
3. `Privacy Policy URL` : `https://cec.wevox.cloud/application/confidentialite.html`.
4. `Privacy Choices URL`, si le champ apparaît : `https://cec.wevox.cloud/application/suppression-compte.html`.
5. Indique que l'application collecte des données.
6. Indique qu'aucune donnée n'est utilisée pour le suivi publicitaire (`tracking`).

Déclare :

| Catégorie Apple | Données | Liées à l'identité | Finalité |
|---|---|---:|---|
| Contact Info | Name, Email Address, Phone Number | Oui | App Functionality, Account Management |
| Identifiers | User ID | Oui | App Functionality, Account Management |
| Identifiers | Device ID | Oui | App Functionality ; le token FCM est relié au membre connecté |
| Financial Info | Other Financial Info | Oui | App Functionality ; montant HT informatif, sans paiement |
| User Content | Photos or Videos | Oui | App Functionality |
| User Content | Other User Content | Oui | App Functionality ; profils, entreprises, recommandations, remerciements, invités, signalements |
| User Content | Customer Support | Oui | App Functionality ; demandes et détails de signalement |
| Diagnostics | Other Diagnostic Data | Non | App Functionality ; métadonnées de transport Firebase |
| Other Data | Other Data Types | Non | App Functionality ; modèle, langue, fuseau horaire, OS et version d'app utilisés par FCM |

Pour toutes ces catégories :

- `Used for Tracking` : `No` ;
- Advertising : `No` ;
- Developer's Advertising or Marketing : `No` ;
- Third-Party Advertising : `No` ;
- Product Personalization : `No`.

Le SDK installé contient Firebase Core et Firebase Messaging, pas Analytics ni Crashlytics. La [documentation Firebase sur les déclarations App Store](https://firebase.google.com/docs/ios/app-store-data-collection) doit être revue à chaque mise à jour du SDK.

### 12.6 Informations pour l'équipe de revue

Dans `App Review Information` :

```text
First name : [PRÉNOM DU CONTACT À RENSEIGNER]
Last name : [NOM DU CONTACT À RENSEIGNER]
Phone number : [TÉLÉPHONE JOIGNABLE À RENSEIGNER]
Email : contact@wevox.eu
Sign-in required : Yes
Username : [EMAIL DU COMPTE A]
Password : [MOT DE PASSE DU COMPTE A]
```

Dans `Notes`, colle ce texte après avoir remplacé les deux champs entre crochets :

```text
Les actualités, les rencontres et l’annuaire sont accessibles sans connexion.

Le compte de démonstration [EMAIL DU COMPTE A] donne accès au profil, aux recommandations et aux remerciements. Les comptes membres sont créés par l’administration du Club ; il n’existe donc pas d’inscription autonome dans l’app. Le compte ne nécessite ni validation supplémentaire, ni code à usage unique, ni abonnement.

Le compte contient déjà une recommandation et un remerciement reçus. Les notifications sont déclenchées lorsqu’un autre membre envoie une recommandation ou un remerciement.

Les photos, logos et bannières peuvent être sélectionnés depuis la photothèque ou l’app Fichiers. Les options de signalement et de blocage sont accessibles depuis les fiches concernées.

L’application ne contient ni publicité, ni achat intégré. Backend de revue : https://cec.wevox.cloud
Assistance : contact@wevox.eu
```

Ajoute une pièce jointe de revue uniquement si Apple demande une vidéo d'un parcours impossible à reproduire. Le compte de démonstration doit suffire dans le fonctionnement actuel.

### 12.7 Chiffrement et conformité d'exportation

Le projet contient déjà :

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

L'application utilise HTTPS et le chiffrement standard fourni par les systèmes et Firebase ; elle n'implémente pas d'algorithme cryptographique propriétaire. Si App Store Connect demande `Uses non-exempt encryption`, réponds `No`. Si la question est formulée plus largement, choisis l'option correspondant au chiffrement standard/exempt fourni par le système, et non une fausse déclaration d'absence totale de HTTPS.

## 13. Construire, tester et soumettre iOS

### 13.1 TestFlight

Sur le Mac, après la section 7 :

```bash
flutter clean
flutter pub get
flutter build ipa --release --build-name=1.0.0 --build-number=1
```

Si App Store Connect contient déjà un build `1` pour la version `1.0.0`, utilise `--build-number=2`. Un numéro de build déjà téléversé ne peut pas être réutilisé.

Ou dans Xcode :

1. Ouvre `ios/Runner.xcworkspace`.
2. Sélectionne `Any iOS Device (arm64)` comme destination.
3. Ouvre `Product > Archive`.
4. À la fin, Xcode ouvre `Organizer`.
5. Sélectionne l'archive CEC 2026.
6. Clique sur `Distribute App`.
7. Choisis `App Store Connect` puis `Upload`.
8. Laisse `Automatically manage signing` actif.
9. Termine les contrôles puis clique sur `Upload`.

Ensuite :

1. Ouvre App Store Connect > CEC 2026 > `TestFlight`.
2. Attends la fin du traitement du build.
3. Réponds aux questions de conformité d'exportation si elles apparaissent.
4. Ajoute au moins un testeur interne.
5. Installe le build TestFlight sur un vrai iPhone.
6. Refais entièrement la section 5, en particulier notifications et uploads.

### 13.2 Associer le build à la version

1. Dans App Store Connect, ouvre `Apps > CEC 2026 > App Store > iOS App 1.0`.
2. Descends à `Build`.
3. Clique sur `+` ou `Select a build before you submit your app`.
4. Sélectionne le build `1.0.0 (1)`.
5. Clique sur `Done`.
6. Vérifie les captures, textes, URLs, confidentialité et informations de revue.
7. Clique sur `Add for Review`.
8. Ouvre la soumission créée puis clique sur `Submit for Review`.

Apple exige depuis le 28 avril 2026 des builds produits avec Xcode 26 ou plus récent et le SDK iOS 26. Utiliser Xcode 26.2 ou plus récent couvre également les exigences actuelles des paquets Firebase Swift.

## 14. Textes prêts à coller

### Notes de version Google Play

```text
Découvrez CEC 2026 : actualités du Club, calendrier des rencontres, annuaire des entreprises et espace membre. Recevez également une notification lors d’une recommandation ou d’un remerciement.
```

### What's New Apple

```text
Première version de CEC 2026.

- Actualités du Club et du réseau
- Calendrier et détail des rencontres
- Annuaire des entreprises et des professionnels
- Espace membre, recommandations et remerciements
- Notifications et gestion des médias du profil
```

### Réponse type à une question sur l'accès public

```text
CEC 2026 n’est pas réservée aux membres. Les actualités, les rencontres et l’annuaire sont accessibles sans connexion. Seules les fonctions d’échange entre membres nécessitent un compte fourni par le Club.
```

### Réponse type à une question sur la création de compte

```text
L’application ne permet pas la création autonome d’un compte. Les comptes membres sont créés et administrés par le Club des Entrepreneurs du Cotentin. Une procédure publique permet néanmoins de demander la suppression du compte et des données à l’adresse https://cec.wevox.cloud/application/suppression-compte.html.
```

### Réponse type à une question sur les paiements

```text
L’application ne traite aucun paiement et ne propose aucun achat intégré. Le montant HT facultatif associé à un remerciement est une information déclarative entre membres et ne déclenche aucune transaction.
```

## 15. Contrôles après publication

### Chaque jour pendant la première semaine

1. Vérifie `storage/logs/laravel.log`.
2. Vérifie `Filament > Signalements` et traite les éléments en attente.
3. Vérifie la boîte `contact@wevox.eu`.
4. Contrôle les erreurs Android dans `Play Console > Qualité > Android vitals`.
5. Contrôle les retours iOS dans App Store Connect et TestFlight.
6. Teste une recommandation et un remerciement sur chaque plateforme publiée.

### Ensuite

- traite les demandes de suppression par email et garde une trace de leur exécution ;
- supprime ou anonymise les données au plus tard selon la durée annoncée de deux ans ;
- sauvegarde régulièrement base de données et médias ;
- garde les clés JKS, APNs `.p8` et Firebase dans un coffre de secrets ;
- révoque immédiatement une clé exposée ;
- vérifie la politique de confidentialité après tout nouveau SDK ou nouveau traitement de données ;
- augmente toujours le build number avant un nouvel envoi : `1.0.0+2`, puis `1.0.0+3`, etc.

## 16. Valeurs que toi seul peux encore fournir

La préparation technique est terminée, mais ces éléments de compte ne peuvent pas être déduits du code :

- [ ] email et mot de passe des deux comptes de démonstration ;
- [ ] prénom, nom et téléphone du contact joignable pour Apple Review ;
- [ ] téléphone public du développeur ;
- [ ] type et état de vérification du compte Google Play ;
- [ ] D-U-N-S si le compte Google appartient à l'association ;
- [ ] Apple Team ID, APNs Key ID et clé `.p8` ;
- [ ] état des contrats Apple Developer ;
- [ ] statut DSA trader décidé par le titulaire du compte ;
- [ ] pays de diffusion au-delà de la France ;
- [ ] résultat du test TestFlight sur un vrai iPhone.

## 17. Liens officiels utiles

### Google

- [Play Console](https://play.google.com/console/)
- [Créer et configurer une application](https://support.google.com/googleplay/android-developer/answer/9859152?hl=fr)
- [Éléments graphiques de la fiche](https://support.google.com/googleplay/android-developer/answer/9866151?hl=fr)
- [Section Sécurité des données](https://support.google.com/googleplay/android-developer/answer/10787469?hl=fr)
- [Suppression de compte](https://support.google.com/googleplay/android-developer/answer/13327111?hl=fr)
- [Contenu généré par les utilisateurs](https://support.google.com/googleplay/android-developer/answer/9876937?hl=fr)
- [Tests des nouveaux comptes personnels](https://support.google.com/googleplay/android-developer/answer/14151465?hl=fr)
- [Exigences de niveau d'API cible](https://support.google.com/googleplay/android-developer/answer/11926878?hl=fr)

### Apple

- [Apple Developer](https://developer.apple.com/account/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Créer la fiche d'une app](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/)
- [Téléverser un build](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/)
- [Choisir un build](https://developer.apple.com/help/app-store-connect/manage-builds/choose-a-build-to-submit/)
- [Soumettre pour revue](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app/)
- [Dimensions des captures](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
- [Confidentialité de l'app](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/)
- [Exigences SDK à venir](https://developer.apple.com/news/upcoming-requirements/)

### Firebase

- [Projet Firebase cec-2026](https://console.firebase.google.com/project/cec-2026/overview)
- [Configurer Firebase avec Flutter](https://firebase.google.com/docs/flutter/setup)
- [Firebase Cloud Messaging pour Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/get-started)
- [Migration Firebase de CocoaPods vers Swift Package Manager](https://firebase.google.com/docs/ios/cocoapods-deprecation?hl=fr)
