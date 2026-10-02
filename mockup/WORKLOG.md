# Suivi de la maquette mobile CEC

## Périmètre

Demande : nouvelle maquette premium de l'ensemble de l'application mobile, dans un dossier `mockup`, sans remplacer l'application actuelle.

Les changements Flutter précédents sur la superposition du logo entreprise et leur test sont laissés intacts. Aucun commit, push, déploiement, changement Laravel ou appel aux données de production n'est réalisé pour cette maquette.

## Plan et avancement

1. **Terminé : inventaire.** Lecture des écrans, formulaires, modèles, thème, navigation, signalements et gestion des médias. Vérification des logos et photographies existants.
2. **Terminé : direction graphique.** Fond clair, typographie Manrope, couleurs CEC, navigation vitrée, arrondis courts, sections ouvertes, hiérarchie des parcours.
3. **Terminé : prototype.** Écrans publics et privés, données locales, formulaires, filtres, notifications, assistance et garde des parcours privés.
4. **Terminé : ressources.** Logos du projet, photos illustratives, police et icônes locales avec licences.
5. **Terminé : première validation.** 29 routes sur trois tailles de téléphone ; navigation, recherche, filtres, recommandations, remerciements, invitations, profil, médias, blocage, notifications et connexion testés.
6. **Terminé : ajustement après captures.** Navigation réservée aux rubriques racines pour ne pas recouvrir les actions des sous-écrans ; logo entreprise au premier plan ; champs à 16 px pour limiter le zoom automatique iOS ; hiérarchie affinée.
7. **Terminé : validation finale et régénération des captures.** Après les derniers ajustements typographiques, le contrôle du masquage, l'édition d'entreprise et la vérification du chargement des neuf aperçus de la planche.
8. **Terminé : documentation.** README avec couverture, différences avec l'existant, limites, sources et étapes proposées d'intégration Flutter.

## Résultat final automatisé

- 29 routes × 3 tailles : 87 ouvertures contrôlées.
- Téléphones : 320, 390 et 430 px ; ordinateur : 1440 px.
- Aucune erreur JavaScript.
- Aucune requête HTTP externe à l'utilisation.
- Images chargées et aucune sortie horizontale du contenu contrôlé.
- 15 captures exportées : 13 écrans mobiles, un aperçu ordinateur et une planche d'ensemble.
- Parcours supplémentaires vérifiés : édition du nom et du logo de l'entreprise, signalement avec masquage du contenu, chargement des neuf aperçus de la planche.
- Contrôle visuel des captures : accueil, fiche entreprise, réunion, recommandations, formulaire de recommandation, aperçu ordinateur et planche d'ensemble.

## Limites connues

- Prototype HTML, pas une compilation Flutter ni un test natif Android/iOS.
- Envois, appels, autorisations système et suppression de compte simulés.
- Données éphémères ; un rechargement annule les modifications de démonstration.
- Pas d'authentification réelle ; aucun mot de passe enregistré.
- Pas de nouvelle API pour le centre de notifications ; cette fonction est une proposition détaillée dans le README.
- Le navigateur intégré ne permet pas l'ouverture d'une URL `file:`. Le point d'entrée livré est donc un fichier HTML autonome à ouvrir dans le navigateur habituel, sans serveur ajouté pour contourner cette restriction.

## Reprise du travail

Ouvrir `index.html`, lire le README, lancer `npm test`, puis consulter les captures. L'entrée du prototype et ses tests sont indépendants des outils et dépendances Flutter.

## Ajustement du parcours de connexion : 2 octobre 2026

- Suppression du bouton « Découvrir le Club sans compte » et du séparateur « ou » dans la connexion de la maquette.
- Démarrage conservé sur l'accueil public ; connexion uniquement après sélection de l'espace membre ou d'une fonction privée. Le retour depuis la connexion mène à l'accueil.
- Vérification du code Flutter : `CecApp` démarre déjà sur `MainScreen`, dont l'onglet initial est Actualités. Aucun changement du routage de production n'était nécessaire ; aucun bouton équivalent n'y existe.
- Test Flutter renforcé pour vérifier l'accueil sans compte, l'ouverture volontaire de la connexion et le retour aux actualités.
- Tests du prototype renforcés pour vérifier l'accueil public, les rubriques publiques, l'accès volontaire à la connexion, son retour et l'absence du bouton supprimé sur les 29 routes.
- Résultat : 18 tests Flutter validés ; analyse Flutter sans diagnostic ; contrôles du prototype validés sur trois tailles et 15 captures régénérées. Le runner Flutter signale toujours des chargements de polices Google indisponibles en test, sans échec des tests.
