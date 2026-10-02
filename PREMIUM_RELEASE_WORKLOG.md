# Integration mobile premium et publication Android

## Demande et perimetre

2 octobre 2026 : integrer la direction du dossier mockup dans Flutter, conserver les fonctionnalites et le demarrage public, verifier sur le Samsung connecte, committer, pousser et soumettre sur Google Play en production.

Le prototype sert de reference visuelle. Aucun contenu fictif ne doit entrer dans l'application. Les fonctions nouvelles simulees qui necessitent une API (historique des notifications, par exemple) ne seront pas presentees comme disponibles sans implementation reelle. La configuration Firebase et les corrections iOS sont conservees.

## Plan

1. Termine : audit, composants communs, police locale, couleurs et navigation.
2. Termine : accueil, annuaire, fiches, reunions et actualites.
3. Termine : connexion, espace membre, echanges, formulaires et reglages.
4. Termine : 25 tests, analyse sans anomalie, parcours publics controles sur Samsung ; espace prive couvert par API simulee.
5. Termine : bundle signe compile, controle du diff, commit et push.
6. Termine : version 24 importee, release validee et soumission en production confirmee ; examen Google en cours.

## Etat initial

- Branche master ; HEAD et origin/master alignes sur 68dec91 apres fetch.
- Modifications locales conservees : correctif logo entreprise, tests associes et de demarrage public, dossier mockup.
- Version locale : 2.0.1+21. Numero final a verifier avec la console avant preparation du bundle.
- Aucune publication ni modification de donnees reelles a ce stade.

## Integration

- Manrope embarquee localement (licence OFL), surfaces blanches, accents violet/turquoise, navigation flottante vitree.
- Annuaire entreprises/membres unifie, recherche et filtres ; logo opaque au-dessus de la banniere.
- Accueil public conserve ; pas de bouton de decouverte sans compte.
- Fiches, actualites, reunions, compte et formulaires adaptes ; profile/entreprise/securite separes.
- Formulaires pleine page ; prevention du double envoi d'invitation, gestion des retours reseau apres fermeture, destinataire preselectionne depuis un membre.
- API, uploads et service Firebase inchanges. Aucune migration serveur requise.
- Analyse Flutter sans anomalie. APK release 2.1.0+22 compile ; tests de flux simules en cours, sans ecriture en production.
- Google Play : 21 (2.0.1) deja en examen a l'ouverture de la console. Ne pas annuler cette revision sans raison verifiee.

## Verification et bundle 22

- 25 tests Flutter reussis : demarrage public, navigation, clavier/texte a 130 %, filtres, logo pixel par pixel avec/sans banniere, routes de notifications, destinataire preselectionne, formulaires de recommandation/remerciement, details et onglets, invitation sans double envoi, retour asynchrone apres fermeture.
- Samsung SM-A202F : application existante signee Android Debug. L'APK release ne peut pas la remplacer. Mise a jour debug du meme code installee avec adb install -r, sans desinstallation ni effacement des donnees.
- Controle physique : accueil, annuaire et contenus reels, fiche entreprise, fiche membre, connexion. Captures locales dans build/qa-premium (non versionnees).
- Le Samsung etait deconnecte. Connexion demandee a l'utilisateur pour une verification physique de l'espace prive ; aucune donnee metier de test creee en production.
- Accueil sans actualites : presentation du Club et acces direct a l'annuaire ; pas de faux articles ni de faux rendez-vous.
- Echanges : listes compactes, ecrans de details et coordonnees actionnables, signalement conserve.
- Premier bundle importe en brouillon : 2.1.0+22, SHA-256 77FB2183FDBC73294C96A8E021E2F11E438620B48AE9F40D1C6F54FE5A8A7469. Non soumis.
- Signature JAR verifiee ; certificat Android auto-signe attendu. Manifeste : cloud.wevox.cec2026.cec2026, minSdk 24, targetSdk 36, permission POST_NOTIFICATIONS conservee.
- Avertissements non bloquants : migration future Kotlin Gradle Plugin/Flutter et API Android de Firebase depreciee. Pas de mise a jour native risquee dans cette refonte.
- Aucun diff dans ios, android, services Firebase, API ou authentification. Compilation native iOS a realiser sur Mac.
- Google Play a ensuite affiche 21 (2.0.1) disponible ; creation d'une nouvelle release possible sans annuler d'examen.
- Dernier controle Samsung : correction du contraste des filtres actifs/inactifs, couverte par un test. Licence Manrope embarquee et accessible dans la page des licences.
- Commit de la refonte f3ea5ea pousse sur master.
- Test complementaire clavier Samsung : ajout d'une SafeArea lorsque l'en-tete de l'annuaire se replie, afin de ne pas recouvrir la barre d'etat. Test avec marge haute de 28 px ajoute. Le code 22 etant deja importe, le bundle de soumission est incremente a 23 (2.1.0).

## Preparation 23 (2.1.0), non publiee

- Commits de code pousses sur master : f3ea5ea (refonte), 683ea97 (clavier et version 23), 78558a2 (barres systeme lisibles sur fond blanc).
- Bundle intermediaire : 57.9 MB, versionCode 23, versionName 2.1.0.
- SHA-256 : 5AB3815A84FAADB33F272BC4C151EC8B8808EA9A3AF46C06B444F7ECBB17A977.
- 25 tests reexecutes avec succes ; flutter analyze sans anomalie ; signature JAR valide ; git diff --check valide.
- APK debug final 23 installe sur Samsung avec conservation des donnees. Controle clavier confirme apres correction.
- Le bundle 22 est retire du brouillon et reste recuperable dans la bibliotheque Google.
- Import de 23 dans la release de production 4 (canal 4697590931000869452), notes francaises renseignees.

## Version finale 24 (2.1.0)

- Derniere correction de contraste : icones systeme Android explicitement sombres sur la barre blanche. Verification visuelle Samsung et assertion de test ajoutee.
- Code final : commit 3c94edb, pousse sur origin/master.
- Bundle : build/app/outputs/bundle/release/app-release.aab, 57.9 MB, versionCode 24, versionName 2.1.0.
- SHA-256 : A76D7DF118FB740EC8BEFBC8FC58C3665CF3B80812208CED3D4437F256E802D5.
- 25 tests reussis, analyse sans anomalie, signature verifiee. APK debug 24 du meme code installe sur Samsung, donnees conservees.
- Les versions 22 et 23 sont des iterations de preparation non soumises. Seule 24 est destinee a la publication.

## Soumission Google Play confirmee

- Le 2 octobre 2026, vers 13 h 29 (Europe/Paris), envoi de la release de production 24 (2.1.0), seule modification soumise.
- La console affiche "Modifications en cours d'examen" pour "Production / 24 (2.1.0) / Lancer le deploiement complet". Les verifications rapides sont encore en cours et precederont automatiquement l'examen. Ce statut ne signifie pas que la nouvelle version est deja approuvee.
- Deploiement demande a 100 % dans le perimetre existant (France). Publication geree desactivee : disponibilite automatique apres approbation Google. Aucun pays ajoute, aucune declaration ni fiche store modifiee.
- Aucun appareil compatible perdu selon le controle Google. La version 21 (2.0.1) reste la version disponible en attendant l'approbation de 24.
- Les bundles 22 et 23 sont exclus de cette release et restent recuperables dans la bibliotheque Google.
- Preuve locale : build/qa-premium/google-play-24-review.jpg. Captures Samsung : build/qa-premium/01-home.png a 06-directory-keyboard.png. Ces fichiers de controle ne sont pas versionnes.
- Console : https://play.google.com/console/u/1/developers/7865638073603147992/app/4974894204859822011/publishing

## Limites et suite

- Parcours publics verifies sur Samsung SM-A202F avec le build debug du meme code ; donnees existantes conservees. Le bundle de production est signe avec la cle release et accepte par Google.
- Espace prive couvert par tests avec API simulee. Controle physique prive encore a faire apres connexion par le proprietaire ; aucune recommandation, aucun remerciement ni invite de test cree en production.
- Services Firebase et API preserves, routes de notifications testees ; aucune nouvelle notification reelle envoyee pendant cette refonte. Pas de deploiement Laravel necessaire.
- Code iOS disponible sur master. Compilation native, TestFlight et envoi App Store a realiser sur Mac ; non verifies depuis Windows. La version du pubspec est desormais 2.1.0+24, verifier la disponibilite du numero de build dans App Store Connect avant envoi.
- Aucun suivi automatique Google programme. Consulter le resultat de l'examen avant d'annoncer la mise a jour comme disponible.
