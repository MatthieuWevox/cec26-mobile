# Integration mobile premium et publication Android

## Demande et perimetre

2 octobre 2026 : integrer la direction du dossier mockup dans Flutter, conserver les fonctionnalites et le demarrage public, verifier sur le Samsung connecte, committer, pousser et soumettre sur Google Play en production.

Le prototype sert de reference visuelle. Aucun contenu fictif ne doit entrer dans l'application. Les fonctions nouvelles simulees qui necessitent une API (historique des notifications, par exemple) ne seront pas presentees comme disponibles sans implementation reelle. La configuration Firebase et les corrections iOS sont conservees.

## Plan

1. Termine : audit, composants communs, police locale, couleurs et navigation.
2. Termine : accueil, annuaire, fiches, reunions et actualites.
3. Termine : connexion, espace membre, echanges, formulaires et reglages.
4. Termine : 25 tests, analyse sans anomalie, parcours publics controles sur Samsung ; espace prive couvert par API simulee.
5. En cours : bundle signe compile, controle du diff, commit et push.
6. A faire : import Google Play, validation de la release et soumission en production.

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
