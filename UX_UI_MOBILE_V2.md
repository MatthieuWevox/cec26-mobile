# Refonte mobile : seconde direction graphique

12 septembre 2026. Cette passe remplace la direction visuelle de la première refonte. Elle se concentre sur le téléphone.

## Direction retenue

L'identité CEC reste fondée sur le violet et le turquoise du logo. Les grands bandeaux violets des listes ont été remplacés par des en-têtes clairs : logo lisible, titre court, description secondaire et accès rapide aux actions.

Les cartes conservent des coins légèrement arrondis de 8 points. La navigation est moins arrondie (16 points), avec une surface translucide, une sélection violette et des icônes contrastées. Le relief provient de calques en retrait, de logos superposés aux couvertures et d'ombres courtes.

## Changements concrets

- Actualités : en-tête allégé, carte principale sur un calque turquoise, état vide plus discret et actualisation possible même sans publication.
- Annuaire : recherche directe, bouton d'effacement, couverture et logo superposés, identité de l'entreprise plus visible, action de découverte séparée des métadonnées.
- Détail entreprise : couverture plus compacte, logo à cheval sur la couverture et le contenu, description présentée en lecture continue.
- Réunions : sélection entre réunions à venir et passées, compteurs réels, choix initial des réunions à venir lorsqu'il y en a, état vide propre à chaque vue.
- Membres : en-tête clair et recherche simplifiée avec remise à zéro en un geste.
- Connexion : fond clair, logo violet, titre plus compact et formulaire sur deux niveaux.
- Espace membre : en-tête clair et actions de recommandations/remerciements sur calques.
- Composants partagés : nouvelles surfaces, états vides, recherche, navigation, ombres et contraste de la barre système.
- Démarrage debug : l'affichage du token FCM dans la console ne bloque plus le premier écran en attendant la réponse réseau.

Les fonctions et contrats API existants restent en place. Aucun changement Laravel n'était nécessaire à cette passe graphique.

## Vérification

- Analyse Flutter : aucune anomalie.
- Huit tests widget réussis.
- Recherche : saisie, effacement, mise à jour du filtre et conservation du focus.
- Petit téléphone : 320 x 640, texte à 130 %, clavier ouvert et bouton de connexion accessible.
- Espace membre : petit écran, texte agrandi, accès au formulaire de profil.
- Navigation : conservation des onglets et masquage pendant la saisie.
- Build APK debug et AAB release : réussis.

Bundle : `build/app/outputs/bundle/release/app-release.aab`.

SHA-256 : `F2A748C7D1EC4B4A8D9B97A2ECBA128B31B8121168CE3F244AFECA48AF038FB6`.

La version reste `1.0.0+1`. Si le numéro de build 1 a déjà été envoyé au store, il faudra utiliser un numéro supérieur lors du prochain envoi.

## Captures et reprise

Les captures Android de téléphone sont dans `release_assets/screenshots/android`. Le journal des tâches reste dans `UX_UI_PREMIUM_WORKLOG.md`.

L'aperçu comparatif des quatre écrans est `release_assets/review/mobile-v2-preview.jpg`. Les six compositions Google Play, six compositions iPhone et la bannière ont été régénérées puis contrôlées visuellement à partir des captures actualisées.

Le générateur `tooling/generate_store_assets.ps1` ne produit désormais que les visuels téléphone par défaut. Les anciens fichiers tablette sont conservés comme historique ; ils ne représentent pas cette passe. Le paramètre optionnel `-IncludeTablets` maintient la possibilité de régénérer les anciens formats à partir de leurs sources.

Les compositions au format iPhone restent des visuels marketing issus des captures Flutter Android. Elles ne constituent pas une validation native iOS. Cette passe a été exécutée et contrôlée sous Windows avec un émulateur Android.

Les tests du parcours membre utilisent des données de test locales ; aucun envoi de recommandation, de remerciement ou de média réel n'a été effectué pour cette validation graphique.
