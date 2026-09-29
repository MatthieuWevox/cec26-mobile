# Refonte UX/UI premium mobile

Date de démarrage : 12 septembre 2026

## Objectif

Moderniser intégralement l'application Flutter sans modifier ses fonctionnalités ni ses contrats API. La direction visuelle reste alignée sur le logo CEC : violet profond, turquoise, blanc et neutres froids. Le rendu recherché combine clarté, fluidité, verre dépoli et profondeur mesurée.

## Principes

- préserver tous les parcours publics, membres, notifications, médias et modération ;
- réserver le flou réel aux éléments flottants pour conserver de bonnes performances ;
- maintenir la lisibilité et les contrastes malgré les transparences ;
- respecter les zones sûres, les petits écrans et les tablettes ;
- réduire les animations lorsque le système le demande ;
- ne pas ajouter de dépendance visuelle inutile.

## Plan suivi

- [x] Auditer le thème, les composants, la navigation et les écrans existants.
- [x] Construire le nouveau design system et les primitives de verre.
- [x] Installer la navigation flottante translucide et ses animations.
- [x] Recomposer les écrans Actualités, Réunions, Entreprises et Membres.
- [x] Recomposer Connexion et le tableau de bord membre.
- [x] Harmoniser détails, recommandations, remerciements, profil et informations légales.
- [x] Ajouter les tests ciblés du nouveau système visuel.
- [x] Exécuter formatage, analyse statique et tests Flutter.
- [x] Tester et capturer l'application sur plusieurs émulateurs.
- [x] Régénérer et contrôler les visuels des stores.
- [x] Rédiger le rapport final de la refonte.

## Journal

## Deuxième passe : priorité téléphone

- [x] Recomposer les en-têtes, les surfaces et la navigation avec des arrondis discrets.
- [x] Retravailler les cartes et les superpositions de l'annuaire et des actualités.
- [x] Simplifier l'agenda avec un choix entre rendez-vous à venir et passés.
- [x] Affiner la connexion, l'espace membre et les composants de formulaire.
- [x] Contrôler les parcours sur téléphone, le clavier et les textes agrandis.
- [x] Livrer les captures et le rapport actualisés.

Direction : surfaces claires, violet et turquoise CEC, relief par calques et ombres courtes. Aucun nouveau livrable tablette prévu pour cette passe.

Contrôles intermédiaires : 8 tests réussis, dont la recherche effaçable, le petit téléphone avec texte à 130 %, le clavier et le parcours espace membre vers le profil. Le journal FCM debug n'attend plus le réseau avant d'afficher l'application. Le générateur de visuels cible désormais les téléphones par défaut.

Contrôles finaux : analyse sans anomalie, builds debug et release réussis, signature du bundle vérifiée. Captures Android téléphone renouvelées et inspectées. Visuels marketing téléphone et bannière régénérés, planches Android/iPhone contrôlées. Rapport : `UX_UI_MOBILE_V2.md`. Aperçu : `release_assets/review/mobile-v2-preview.jpg`.

- 2026-09-12 : audit initial terminé. L'interface existante est cohérente mais encore plate : en-têtes opaques, cartes bordées, navigation Material standard et peu de mouvement.
- 2026-09-12 : direction retenue : navigation flottante en verre, arrière-plans atmosphériques continus, surfaces à profondeur légère, transitions courtes et hiérarchie éditoriale renforcée.
- 2026-09-12 : design system Flutter remplacé : palette CEC affinée, transitions réduites si demandé par le système, champs, boutons, onglets, modales et retours d'état harmonisés.
- 2026-09-12 : primitives `CecGlassPanel`, `CecGlassAppBar`, `CecGlassIconButton`, `CecBackground`, `CecReveal` et surfaces tactiles ajoutées.
- 2026-09-12 : barre de navigation Material remplacée par une barre flottante floutée, animée, haptique et masquée pendant la saisie.
- 2026-09-12 : écrans publics recomposés avec en-têtes éditoriaux, contenus responsive, cartes visuelles et états de chargement cohérents.
- 2026-09-12 : connexion et espace membre repensés pour mieux hiérarchiser les actions fréquentes sans modifier les parcours existants.
- 2026-09-12 : écrans de détail, formulaires, recommandations, remerciements et informations légales harmonisés avec le nouveau langage visuel.
- 2026-09-12 : analyse statique intermédiaire validée sans avertissement.
- 2026-09-12 : tests widget ajoutés pour le flou, les interactions tactiles et la réduction des animations ; 5 tests validés, dont une régression tablette sur la navigation et l'accès à la connexion.
- 2026-09-12 : validation visuelle effectuée sur téléphone Android, tablette Android portrait et tablette Android paysage. Les contrôles ont permis de corriger la hauteur de navigation sur grand écran, le débordement des cartes entreprise, la surface Material du signalement et les poignées de modales dupliquées.
- 2026-09-12 : captures brutes renouvelées puis visuels marketing Google Play, App Store, tablette et iPad régénérés. Les trois planches de contrôle et la bannière Google Play ont été inspectées visuellement.
- 2026-09-12 : bundle Android Release signé généré et vérifié, contrôles finaux réussis, rapport de refonte rédigé dans `UX_UI_PREMIUM_REPORT.md`.
