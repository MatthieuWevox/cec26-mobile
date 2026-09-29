# Rapport de refonte UX/UI premium

> Historique de la première passe. La direction graphique et le bundle les plus récents sont documentés dans `UX_UI_MOBILE_V2.md`.

Date : 12 septembre 2026  
Application : CEC 2026  
Version contrôlée : `1.0.0+1`

## Résultat

L'application Flutter a été entièrement recomposée visuellement sans modifier ses contrats API ni supprimer de fonctionnalité. La nouvelle direction reprend le violet profond et le turquoise du logo CEC, avec des neutres froids, une profondeur mesurée et des surfaces translucides inspirées du verre dépoli.

La navigation, les écrans publics, les parcours membres, les détails, les formulaires, la modération et les états techniques partagent désormais le même langage visuel. Le rendu a été contrôlé sur téléphone Android et tablette Android, en portrait et en paysage.

## Audit initial

Les fonctions existantes étaient présentes et cohérentes, mais l'expérience paraissait encore sommaire :

- navigation Material standard et collée au bord de l'écran ;
- en-têtes opaques et hiérarchie visuelle peu marquée ;
- cartes principalement bordées, avec peu de profondeur ou de mouvement ;
- écrans larges insuffisamment exploités ;
- états vides, erreurs, chargements et formulaires visuellement disparates ;
- détails et espace membre moins aboutis que les parcours publics.

## Modifications réalisées

### Design system

- palette CEC consolidée autour de `#272262`, `#151234` et `#5CC7CF` ;
- typographie Poppins, contrastes et échelles de texte harmonisés ;
- thèmes centralisés pour champs, boutons, cartes, onglets, dialogues, feuilles modales et messages ;
- arrière-plan continu, surfaces tactiles et ombres douces ;
- primitives réutilisables de verre dépoli avec `BackdropFilter` ;
- animations courtes et désactivables lorsque le système demande une réduction des mouvements.

### Navigation

- barre inférieure flottante, translucide et réellement floutée ;
- indicateur de sélection animé et retour haptique ;
- conservation de l'état des quatre onglets avec `IndexedStack` ;
- masquage pendant la saisie pour libérer l'espace du clavier ;
- largeur plafonnée sur tablette pour préserver des proportions naturelles.

### Parcours publics

- refonte d'Actualités, Réunions, Entreprises et Membres ;
- en-têtes de marque, recherches plus lisibles et cartes plus éditoriales ;
- listes adaptatives et grilles à deux colonnes lorsque l'espace le permet ;
- détails des actualités, réunions, entreprises et membres harmonisés ;
- actions de contact, ajout d'invité, blocage et signalement conservées.

### Espace membre

- connexion recomposée avec formulaire compact et action principale immédiatement visible ;
- tableau de bord membre hiérarchisé autour des actions fréquentes ;
- recommandations, remerciements et profil alignés sur le nouveau design ;
- formulaires d'envoi, médias et comportements existants préservés ;
- informations légales et assistance réorganisées pour une lecture plus directe.

### Robustesse UX

- états de chargement, erreur et contenu vide unifiés ;
- zones sûres et espace de navigation pris en compte sur les petits écrans ;
- largeurs de lecture limitées sur tablette ;
- correction du débordement des cartes entreprise sur grand écran ;
- correction de la contrainte Material des cases à cocher du signalement ;
- suppression des poignées de feuilles modales dupliquées.

## Vérifications

- `dart format` : 20 fichiers contrôlés, aucun changement restant ;
- `flutter analyze` : aucune erreur ni aucun avertissement ;
- `flutter test` : 5 tests réussis ;
- tests couverts : action principale, flou réel, interaction tactile, réduction des animations et navigation tablette ;
- `flutter build apk --debug` : réussi ;
- contrôle manuel : téléphone Android `1080 x 1920`, tablette portrait `1600 x 2560` et tablette paysage ;
- `flutter build appbundle --release` : réussi ;
- signature du bundle : vérifiée avec `jarsigner`.

Bundle prêt pour Google Play :

`build/app/outputs/bundle/release/app-release.aab`  
Taille : 60 275 641 octets  
SHA-256 : `5D5CC76D9DC9B77966C696DEEDACF3F0D242D79B356E8B90C7FCBA54C9DAABC1`

## Visuels Store

Google Play :

- 6 visuels téléphone `1080 x 1920` ;
- 4 visuels tablette `1600 x 2560` ;
- bannière `1024 x 500` ;
- icône `512 x 512`.

App Store :

- 6 visuels iPhone `1290 x 2796` ;
- 4 visuels iPad `2048 x 2732` ;
- icône `1024 x 1024`.

Les visuels marketing comportent des accroches courtes, des compositions dynamiques et de vraies interfaces issues de l'application. Les planches de contrôle se trouvent dans `release_assets/review`.

## Point de vigilance futur

Le build actuel est publiable. Flutter affiche toutefois un avertissement annonçant qu'une prochaine version exigera la migration du projet et de certains plugins vers Built-in Kotlin. Cette migration n'est pas requise pour le bundle produit aujourd'hui, mais devra accompagner une future mise à niveau de Flutter et des plugins Android.

Le poste de travail étant sous Windows, aucun build ou simulateur iOS natif n'a pu être exécuté. Les visuels App Store ont été composés aux formats Apple à partir des captures de l'interface Flutter validée sous Android. Avant soumission iOS, il reste prudent d'ouvrir le projet sur un Mac, de lancer un appareil iPhone et un iPad, puis de vérifier les autorisations, Firebase/APNs et le rendu final sans modifier la direction graphique.

## Fichiers structurants

- `lib/theme/app_theme.dart` : palette, typographie et thèmes globaux ;
- `lib/widgets/common_widgets.dart` : composants premium réutilisables ;
- `lib/screens/main_screen.dart` : navigation flottante et transitions ;
- `tooling/generate_store_assets.ps1` : génération reproductible des visuels Store ;
- `UX_UI_PREMIUM_WORKLOG.md` : plan et journal de réalisation.
