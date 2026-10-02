# CEC : nouvelle direction mobile

Maquette interactive autonome, créée le 2 octobre 2026 à partir de l'application Flutter actuelle. Elle propose une nouvelle interface sans modifier le code de production.

## Ouvrir la maquette

Ouvrir `index.html` dans Edge, Chrome ou Safari. Aucun serveur, compte, installation ou accès Internet n'est nécessaire. Tous les fichiers nécessaires sont dans ce dossier.

- `index.html` : prototype navigable, utilisable à la souris, au clavier ou au toucher.
- `board.html` : neuf écrans présentés côte à côte ; chaque aperçu ouvre le parcours correspondant dans la maquette.
- `captures/` : treize vues mobiles et deux vues de présentation exportées.
- `styles.css` : couleurs, typographie, composants, animations et dimensions.
- `app.js` : écrans et comportements de démonstration.
- `tests/verify.cjs` : vérification automatisée et génération des captures.
- `WORKLOG.md` : suivi de réalisation et résultats de validation.

Sur ordinateur, le panneau de gauche permet de choisir un écran, basculer entre membre et visiteur, ou visualiser les listes vides, en chargement et en erreur. Sur une fenêtre étroite, seul le téléphone est affiché : ce n'est pas une déclinaison tablette.

La démo démarre avec un membre connecté. Le mode visiteur conserve l'accès aux actualités, réunions, entreprises et membres. Un formulaire de connexion intercepte les fonctions privées. Une adresse au format email, un mot de passe quelconque et l'acceptation des règles ouvrent une **session fictive**, sans authentification réelle.

Les changements restent en mémoire dans l'onglet. Un rechargement réinitialise les données. Le bouton « Réinitialiser la démo » revient à l'accueil initial. Ne pas utiliser de véritables mots de passe ni de données sensibles dans cette maquette.

### Démarrage et connexion

L'ouverture normale se fait sur l'accueil public **Le Club**, jamais sur une page de connexion imposée. Les actualités, réunions et annuaires sont accessibles sans compte. La connexion apparaît uniquement après un choix de l'utilisateur : onglet Connexion / espace membre ou fonction privée. Le bouton « Découvrir le Club sans compte » n'existe pas ; le retour de la connexion ramène simplement à l'accueil public. Les liens directs vers les écrans restent disponibles pour la revue de la maquette.

## Direction graphique

L'objectif n'est pas d'ajouter du verre à tous les éléments. La hiérarchie, la lecture et la facilité d'action portent le niveau de finition.

| Élément | Choix |
| --- | --- |
| Identité | Logo CEC original, inchangé |
| Violet | `#272262`, navigation active, actions principales et identité |
| Turquoise | `#5CC7CF`, accent de marque ; `#126B74` pour les textes lisibles |
| Surfaces | Blanc, `#F5F7FA`, séparateurs `#E5E8ED` |
| Texte | `#171827`, secondaire `#69717C` |
| Typographie | Manrope locale, graisses 400, 600 et 700 |
| Rythme | Grille de 4 px ; marges principales 22 px |
| Arrondis | Cartes 8 px ; navigation 20 px ; avatars circulaires |
| Transparence | Navigation flottante, barre de retour et fenêtres modales |
| Mouvement | Transition courte de 260 ms ; réduction des animations respectée |
| Formulaires | Champs de 16 px, libellés visibles, validation native, action explicite |

Les titres restent proportionnés à un téléphone. Les zones principales ne sont pas des cartes imbriquées. Les fiches utilisent des sections libres, des séparateurs et des espaces réguliers. Les cartes sont réservées aux éléments répétés comme les recommandations.

La navigation principale contient **Le Club, Agenda, Annuaire, Mon espace**. Elle reste vitrée et flottante. Elle disparaît dans les sous-écrans pour libérer la place nécessaire au contenu et à l'action principale. Un retour explicite conserve une sortie simple de chaque parcours.

## Ce qui change dans l'expérience

- L'accueil met une actualité à la une, le prochain rendez-vous et la vie du réseau dans une même lecture.
- L'annuaire réunit entreprises et membres avec une recherche commune et des filtres d'activité.
- La fiche entreprise utilise une bannière panoramique et un logo opaque, au premier plan. Le logo n'est pas dans le calque de la bannière.
- La fiche membre privilégie la prise de contact et la mise en relation.
- Les recommandations mettent en avant la personne à contacter, le contexte et le membre à l'origine du lien.
- Les remerciements ont une identité distincte, centrée sur le message et le montant du projet.
- Les formulaires deviennent des écrans dédiés, avec une confirmation après validation, plutôt que de longues fenêtres superposées.
- Le compte regroupe les échanges, la présence publique et les réglages en trois ensembles.
- Les fonctionnalités de signalement, blocage et suppression ne sont pas retirées au profit du design.

## Couverture fonctionnelle

| Fonction actuelle | Parcours dans la maquette | Comportement |
| --- | --- | --- |
| Actualités publiques | Le Club, article | Lecture, partage simulé, signalement |
| Réunions | Agenda, À venir / Passées | Liste, date, horaire, lieu, ordre du jour |
| Compte rendu | Agenda > Passées > réunion | Lecture du compte rendu de démonstration |
| Invités | Réunion > Ajouter un invité | Validation et ajout dans la réunion de la session |
| Entreprises | Annuaire > Entreprises | Recherche, filtres, détail, équipe |
| Membres | Annuaire > Membres | Recherche, fiche, lien vers l'entreprise |
| Coordonnées | Fiche membre ou recommandation | Aperçu des actions email et téléphone, sans contact réel |
| Recommandations reçues / envoyées | Mon espace > Mes recommandations | Deux listes, détails, contact et contexte |
| Création de recommandation | Faire une recommandation | Destinataire, prénom, nom, téléphone, email et description |
| Remerciements reçus / envoyés | Mon espace > Mes remerciements | Deux listes, détail, montant et message |
| Création de remerciement | Remercier un membre | Destinataire, montant, date, description et confirmation |
| Connexion / déconnexion | Session Visiteur, Connexion, Mon espace | Garde des parcours privés, acceptation des règles, confirmation de sortie |
| Profil | Mon espace > Mon profil | Prénom, nom, téléphone, présentation, photo |
| Entreprise personnelle | Mon entreprise | Nom, accroche, activité, description, logo et bannière |
| Médias | Galerie / Fichiers dans les formulaires | Sélection locale, validation JPG/PNG/WebP, aperçu et retrait |
| Mot de passe | Mon espace > Mot de passe | Visibilité des champs, confirmation identique, aucun stockage |
| Présence publique | Visibilité de mon profil | Résumé des informations visibles et accès à leur édition |
| Notifications | Réglages des notifications | État accordé / désactivé, aperçu de l'accès aux réglages du téléphone |
| Signalement | Options ou bas de fiche | Motif, précisions, option de masquage et confirmation |
| Blocage | Options de fiche membre | Confirmation, liste des membres bloqués et déblocage |
| Assistance / règles / confidentialité | Mon espace ou liens publics | Pages dédiées, coordonnées de support et procédure de suppression |
| États transverses | Commande « État des listes » | Chargement, vide, erreur, réessai, résultats de recherche vides |

Les noms des personnes et entreprises, contenus, dates de réunion, montants et coordonnées de démonstration sont fictifs. Les emails de test utilisent `example.test`. L'adresse de support `contact@wevox.eu` et la durée de conservation de 2 ans reprennent les informations fournies pour le projet.

## Propositions nouvelles, à distinguer de l'existant

Ces éléments sont des propositions UX, pas une affirmation qu'ils sont déjà disponibles dans Flutter ou Laravel :

1. **Centre de notifications** : historique visuel des recommandations, remerciements et créations/modifications de réunion, avec lien vers le bon contenu et action « Tout marquer comme lu ». Une vraie intégration demandera de choisir une persistance et une API de lecture/état lu ; Firebase seul ne constitue pas cet historique métier.
2. **Ajout au calendrier** : commande de réunion simulée. L'intégration native devra prévoir les dates, le fuseau, les autorisations et la gestion des modifications de réunion.
3. **Partage d'article** : aperçu des actions natives. Le partage réel devra utiliser les URLs publiques du site, pas les liens locaux de la maquette.
4. **Accès direct à la recommandation depuis une fiche membre**, avec destinataire présélectionné.
5. **Liste de gestion des membres bloqués** : complément au blocage/déblocage depuis une fiche.
6. **Compteurs d'échanges dans le compte** et regroupement des annuaires : présentation proposée à partir des données existantes.

Les notifications push, emails, appels, modifications de mot de passe et demandes de suppression ne sont jamais réellement exécutés. Les dialogues concernés le précisent. Galerie et fichiers utilisent ici le sélecteur du navigateur ; l'intégration Flutter gardera les deux sources natives.

Les pages légales constituent une mise en page de contenu de démonstration, pas une nouvelle politique juridique prête à publier. Il faudra réutiliser les textes validés du site lors de l'intégration.

## Intégration Flutter envisagée

1. Valider cette direction et les parcours avant de toucher aux écrans de production.
2. Reporter les tokens de couleur, typographie, espace et arrondis dans `lib/theme/app_theme.dart`.
3. Faire évoluer les composants partagés : navigation vitrée, barre de retour, champs, lignes de liste et boutons.
4. Reprendre les quatre entrées principales dans `lib/screens/main_screen.dart` en conservant l'état et les positions de défilement.
5. Adapter actualités, réunions, annuaire et fiches, en conservant les modèles et appels API actuels.
6. Recomposer les échanges et formulaires sans modifier les contrats Laravel, puis reprendre le profil et les médias.
7. Traiter séparément les ajouts qui demandent des services ou de nouvelles API, notamment l'historique de notifications.
8. Vérifier sur de vrais Android et iPhone : clavier, tailles de texte système, lecteur d'écran, retour système, permissions, encoches, réseau lent, sélection de médias et notifications.

La maquette n'introduit pas de version tablette, de paiement, de messagerie instantanée ni de fonction RSVP non présente dans le projet.

## Contrôles et captures

Les captures sont des rendus de la **maquette HTML**, pas des captures d'une nouvelle version Flutter, d'un simulateur iOS ou d'une application publiée sur les stores.

Pour régénérer les contrôles et captures sur Windows avec Edge installé :

```powershell
cd C:\Users\Matthieu\StudioProjects\cec2026\mockup
npm ci
npm test
```

Node n'est nécessaire que pour ces contrôles. Le prototype fonctionne directement avec `index.html`.

Le test visite 29 routes sur 320, 390 et 430 px, contrôle les débordements et le chargement des images, puis vérifie les principaux parcours interactifs. Le rendu ordinateur est contrôlé à 1440 px. Les appels réseau externes et erreurs JavaScript sont surveillés. Les captures sont régénérées dans `captures`.

## Assets et licences

- `logo_purple_nobg.png`, `logo_white_nobg.png` : identité CEC provenant du dossier `assets` du projet, non modifiée.
- `actu.jpg` : photographie déjà utilisée dans l'application, reprise pour illustrer les rencontres ; ce n'est pas une preuve d'un événement réel décrit dans la démo.
- `workspace.jpg` : photo d'intérieur de bureaux issue de [Unsplash](https://images.unsplash.com/photo-1497366754035-f200968a6e72), utilisée pour l'entreprise fictive ; elle ne représente pas les locaux d'une entreprise réelle du CEC. Conditions : [licence Unsplash](https://unsplash.com/license).
- Manrope : fichiers distribués par Google Fonts, licence SIL Open Font License incluse dans `assets/OFL-Manrope.txt`.
- Lucide 0.468.0 : bibliothèque d'icônes distribuée localement ; licence dans `vendor/LICENSE-lucide`.
- Les logos d'entreprises sont des monogrammes de démonstration, pas des marques récupérées sur Internet.

Tous les assets sont locaux ; aucune ressource externe n'est téléchargée à l'ouverture du prototype.
