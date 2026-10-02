# Publication Google Play

Début : 22 septembre 2026.

## Périmètre

Mise en ligne Google Play uniquement, à la demande du propriétaire. Connexion et validation à deux facteurs effectuées directement par le propriétaire dans le navigateur. Aucun mot de passe de console ne doit être stocké ici.

## État

- [x] Vérifier les fichiers de la dernière refonte mobile.
- [x] Vérifier la disponibilité des pages publiques.
- [x] Connexion du propriétaire à Google Play Console.
- [x] Examiner la fiche existante, les pistes et les numéros de version déjà utilisés.
- [x] Déposer un bundle avec un numéro de version disponible.
- [x] Compléter la fiche, ses visuels téléphone et les déclarations nécessaires.
- [x] Examiner les erreurs et les prérequis de publication affichés par Google (vérifications automatiques encore en cours).
- [x] Soumettre la version et enregistrer le résultat exact de la console.

## Fichiers vérifiés

Bundle : `build/app/outputs/bundle/release/app-release.aab`.

Version initiale du projet : `1.0.0+1`. Passage à `1.0.0+2` nécessaire : le code 1 est déjà utilisé dans la console.

SHA-256 : `F2A748C7D1EC4B4A8D9B97A2ECBA128B31B8121168CE3F244AFECA48AF038FB6`.

Visuels : `release_assets/google-play`, icône, bannière et six captures téléphone. Pas de nouvelle déclinaison tablette demandée.

## Contrôles du serveur

Contrôles GET non authentifiés effectués le 22 septembre :

| URL sous https://cec.wevox.cloud | Statut |
| --- | --- |
| /application/index.html | 200 |
| /application/confidentialite.html | 200 |
| /application/suppression-compte.html | 200 |
| /application/conditions-utilisation.html | 200 |
| /api/me | 401 |
| /api/me/push-tokens | 405 |
| /api/reports | 405 |

Le statut 405 confirme que GET n'est pas accepté pour ces routes d'écriture ; aucun signalement ni token n'a été créé par ce contrôle. Il ne valide pas à lui seul les envois Firebase.

## Journal

- Console ouverte dans le navigateur intégré. Le premier onglet était invisible pour le propriétaire ; panneau rouvert et connexion du propriétaire confirmée.
- Compte organisation Wevox Cloud ; application CEC, package `cloud.wevox.cec2026.cec2026`, identifiant Console `4974894204859822011`.
- Application en brouillon, production inactive. Configuration initiale : 10 tâches terminées sur 11 ; fiche Play Store encore à compléter.
- Version 1 / 1.0.0 déjà importée le 9 juin 2026. Nouveau bundle à reconstruire avec le code 2 avant dépôt.
- Bundle `1.0.0+2` reconstruit avec succès (Flutter release, 57,6 Mo).
- Fiche française enregistrée, état « Prête à être envoyée pour examen » : nom CEC 2026, descriptions, icône 512, bannière 1024x500, six visuels 1080x1920. Aucun visuel tablette ajouté. Pas encore soumise.
- Bundle 2 / 1.0.0 accepté par Google : API minimale 24, cible 36, trois ABI. SHA-256 : `48630472418A1FF2FE3592BC14D1D090327265CDEFDA2804F46391C490AE5F01`. Signature locale vérifiée.
- Ancien bundle 1 retiré du brouillon de production uniquement ; il reste dans la bibliothèque Google. Nouvelle release nommée `2 (1.0.0)`, notes françaises actualisées.
- Distribution existante conservée : France. Tranche d'âge existante : 18 ans et plus. URL de confidentialité déjà correcte.
- Release de production enregistrée ; Google affiche « La release est prête », sans erreur de bundle. Non soumise.
- Compte de contrôle déjà présent : « Compte membre ». Instructions de navigation en anglais ajoutées sans modifier les identifiants. Le propriétaire a indiqué devoir vérifier ou remplacer ce compte : ne pas soumettre avant sa confirmation.
- Correction importante : ancienne déclaration Sécurité des données = aucune collecte. Remplacée et enregistrée le 22 septembre : collecte des cinq types personnels (nom, email, ID utilisateur, téléphone, autres infos), autres informations financières, messages internes, photos, contenus utilisateur, diagnostics et identifiants d'installation. HTTPS et URL de suppression déclarés.
- Données métier facultatives car navigation publique sans connexion. FID et diagnostics Firebase déclarés requis (initialisation automatique). Finalités : fonctionnement ; comptes pour identité ; sécurité pour ID utilisateur et signalements ; analyse pour métadonnées techniques Firebase. Aucun marketing. Partage tiers exclu selon les exceptions prestataires techniques et actions explicites des utilisateurs, sans autre transfert détecté dans le code.
- Sources de la déclaration : https://firebase.google.com/docs/android/play-data-disclosure et https://support.google.com/googleplay/android-developer/answer/10787469?hl=fr. Déclaration désormais « Prête à être envoyée pour examen ».
- Classification actualisée après accord explicite du propriétaire sur les conditions IARC. Questionnaire enregistré le 22 septembre à 16:57 : catégorie « Tous les autres types d'applications », contenus en ligne, échanges utilisateur, signalement, blocage et modération humaine conformément aux conditions publiques et aux outils Laravel. Résultat : PEGI 3 avec « Interactivité des utilisateurs ». Le ciblage 18+ reste distinct et inchangé.
- Coordonnées publiques vérifiées : `contact@wevox.eu`, `https://cec.wevox.cloud/application/`. Pas de téléphone ajouté. Catégorie Communication et marketing externe désactivé conservés.
- Dernier état de publication : bouton « Envoyer 10 modifications pour examen » actif. Vérifications rapides automatiques en cours, maximum annoncé 14 minutes. Aucune soumission lancée ; attendre le compte de contrôle confirmé puis relire les résultats des vérifications.

## Soumission confirmée

- Le 22 septembre 2026, le propriétaire a confirmé avoir terminé la vérification ou le remplacement du compte de contrôle. Les modifications de ce formulaire ont été enregistrées avant envoi. Aucun identifiant secret n'a été recopié ici.
- À 17:29 heure de Paris (15:29 UTC), les dix modifications ont été envoyées avec confirmation dans Google Play Console.
- Statut observé après envoi : **Modifications en cours d'examen**. Les vérifications rapides automatiques sont encore en cours ; Google indique que l'envoi à l'examen suivra automatiquement leur achèvement (maximum affiché : 14 minutes).
- Périmètre : release de production `2 (1.0.0)`, déploiement complet en France, fiche française et déclarations associées. Publication gérée désactivée. L'application n'est pas encore approuvée ni disponible publiquement.
- Google annonce habituellement un examen sous sept jours, avec possibilité de délai plus long. Aucun délai garanti.
- Console : https://play.google.com/console/u/0/developers/7865638073603147992/app/4974894204859822011/publishing

## Suivi éventuel

Consulter le résultat Google et traiter tout retour de validation avant d'annoncer l'application disponible. Aucun suivi automatique n'a été programmé. La notification générale concernant la validation développeur Android avant le 30 septembre n'a pas bloqué cet envoi et reste à examiner par le propriétaire.

Ordre des six visuels téléphone : 04, 01, 03, 02, 05, 06. Aucun changement effectué sur l'application Coprism ni sur l'App Store.

## Mise à jour notifications - 2 octobre 2026

- Demande du propriétaire : envoyer la mise à jour Android et pousser le code iOS sur GitHub pour compilation sur son MacBook.
- Console vérifiée : version 2 (1.0.0) disponible sur Google Play, déploiement complet, France, publication affichée le 2 octobre à 09:34.
- Code notifications déjà commité dans `832e6aa`, confirmé présent sur `origin/master` après `git fetch`. Fichiers Firebase Android/iOS suivis ; clés privées `.p8` et signature Android non suivies.
- Version de mise à jour : **2.0.1 (21)**. Brouillon production créé, ID de release Console 3. Ne pas confondre cet ID interne avec le code Android 21.
- 14 tests Flutter réussis. Deux avertissements de style corrigés dans le service de notifications ; aucune modification du comportement.
- Analyse Flutter sans avertissement après correction ; 14 tests réussis à nouveau. Bundle release reconstruit avec succès, manifeste 2.0.1/code 21 et permissions Firebase vérifiés.
- SHA-256 du bundle importé : `50BE13E1B704E0322EFCF6EFA33673717C28D35C2D87EA8932698BCCC1686A55` (60 401 058 octets environ, affichage Flutter 57,6 Mo).
- Notes françaises : notifications de recommandations/remerciements, alertes de création/modification de réunion, ouverture directe des réunions et suivi de l'activation.
- Bundle accepté par Google : API minimale 24, cible 36, trois ABI ; aucune perte de compatibilité d'appareils. État de la release : « La release est prête », sans erreur bloquante.
- Mise à jour **21 (2.0.1)** enregistrée puis envoyée pour examen le **2 octobre 2026**. Une seule modification soumise : release de production, déploiement complet (100 %) sur le périmètre existant, France. Fiche du store et déclarations inchangées.
- Confirmation visible : **Modifications en cours d'examen**. Vérifications rapides encore en cours (maximum affiché 15 minutes) ; Google indique que l'examen suivra automatiquement. La nouvelle version n'est pas encore approuvée ni disponible ; la version 2 reste celle publiée.
- Publication gérée désactivée, conservée : publication attendue automatiquement après approbation Google. Aucun suivi automatique programmé et aucun délai garanti.
- Preuve locale hors Git : `build/google-play-notifications-submitted-2026-10-02.png`. AAB dans `build/app/outputs/bundle/release/app-release.aab`.
- Réception sur téléphone réel non revalidée pendant cette publication ; les contrôles ci-dessus ne remplacent pas une recette de réception Android/iOS. Aucun test livré aux membres.

### Récupération sur MacBook

Dans le dépôt mobile sur le Mac, vérifier d'abord `git status`. En présence de modifications locales, les préserver et les fusionner ; ne pas utiliser de reset forcé.

```bash
git switch master
git pull --ff-only origin master
flutter pub get
flutter config --enable-swift-package-manager
flutter build ipa --release --build-name=2.0.1 --build-number=21
```

Le numéro iOS 21 était libre lors de l'audit du 28 septembre. S'il a depuis été utilisé sur App Store Connect, prendre le prochain numéro libre avec `--build-number`. Utiliser la fiche existante `net.wevox.cec.cec`, équipe `6YFVLX2X38`, et vérifier dans Xcode que `GoogleService-Info.plist` est inclus une seule fois dans les ressources Runner. Le projet contient déjà ces réglages ; ne pas créer une nouvelle app Firebase/Apple ni ajouter Firebase une seconde fois avec CocoaPods.

Importer l'archive avec Xcode Organizer ou l'IPA avec Transporter, puis installer via TestFlight. Se connecter et accepter les notifications ; vérifier « Appareil enregistré » puis une réception ciblée avant la soumission App Store. Aucun build iOS n'est compilé depuis Windows. Voir `NOTIFICATIONS_AUDIT_2026-09-28.md` pour la recette détaillée et les limites encore non validées sur téléphone réel.
