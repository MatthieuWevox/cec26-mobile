# Documentation API – CEC BO 2026

> Documentation complète de l'API REST à destination d'un agent IA chargé de développer l'application mobile.

---

## Sommaire

1. [Informations générales](#1-informations-générales)
2. [Authentification](#2-authentification)
3. [Routes publiques](#3-routes-publiques)
   - [Actualités](#31-actualités)
   - [Réunions](#32-réunions)
   - [Entreprises](#33-entreprises)
   - [Membres](#34-membres)
   - [Identification](#35-identification-login)
4. [Routes privées](#4-routes-privées)
   - [Déconnexion](#41-déconnexion-logout)
   - [Recommandations reçues](#42-recommandations-reçues)
   - [Recommandations envoyées](#43-recommandations-envoyées)
   - [Créer une recommandation](#44-créer-une-recommandation)
   - [Remerciements reçus](#45-remerciements-reçus)
   - [Remerciements envoyés](#46-remerciements-envoyés)
   - [Créer un remerciement](#47-créer-un-remerciement)
   - [Modifier son profil](#48-modifier-son-profil)
   - [Modifier son mot de passe](#49-modifier-son-mot-de-passe)
   - [Modifier son entreprise](#410-modifier-son-entreprise)
   - [Ajouter un invité à une réunion](#411-ajouter-un-invité-à-une-réunion)
5. [Codes d'erreur HTTP](#5-codes-derreur-http)
6. [Modèles de données](#6-modèles-de-données)

---

## 1. Informations générales

| Propriété | Valeur |
|---|---|
| **Base URL** | `https://<domaine>/api` |
| **Format des requêtes** | `application/json` |
| **Format des réponses** | `application/json` |
| **Encodage** | UTF-8 |

### En-têtes communs

Toutes les requêtes doivent inclure :

```
Accept: application/json
Content-Type: application/json
```

---

## 2. Authentification

L'API utilise **Laravel Sanctum** avec des tokens Bearer.

### Flux d'authentification

1. L'application mobile appelle `POST /api/login` avec l'email et le mot de passe du membre.
2. L'API retourne un `token` (chaîne de caractères).
3. Ce token est inclus dans toutes les requêtes privées dans l'en-tête `Authorization`.

### En-tête d'autorisation (routes privées)

```
Authorization: Bearer <token>
```

### Durée de vie du token

Les tokens n'ont **pas de date d'expiration** par défaut. Ils sont invalidés lors de la déconnexion (`POST /api/logout`).

---

## 3. Routes publiques

Ces routes ne nécessitent **aucun token**.

---

### 3.1 Actualités

#### `GET /api/news`

Retourne la liste de toutes les actualités, triées de la plus récente à la plus ancienne.

**Exemple de réponse `200 OK` :**

```json
[
  {
    "id": 1,
    "titre": "Assemblée générale 2026",
    "sous_titre": "Rendez-vous le 15 avril",
    "statut": "publié",
    "contenu": "L'assemblée générale annuelle aura lieu...",
    "created_at": "2026-03-20T10:00:00.000000Z",
    "updated_at": "2026-03-20T10:00:00.000000Z"
  }
]
```

---

### 3.2 Réunions

#### `GET /api/meetings`

Retourne la liste de toutes les réunions avec leurs invités, triées de la plus récente à la plus ancienne.

**Exemple de réponse `200 OK` :**

```json
[
  {
    "id": 1,
    "date": "2026-04-10",
    "heure": "09:00:00",
    "adresse": "12 Rue de la Paix, Paris",
    "ordre_du_jour": "Point sur les projets en cours",
    "compte_rendu": null,
    "created_at": "2026-03-15T08:00:00.000000Z",
    "updated_at": "2026-03-15T08:00:00.000000Z",
    "guests": [
      {
        "id": 3,
        "nom": "Dupont",
        "prenom": "Jean",
        "nom_entreprise": "Dupont SARL",
        "invited_by": {
          "id": 2,
          "nom": "Martin",
          "prenom": "Sophie",
          "email": "sophie.martin@example.com",
          "telephone": "0612345678",
          "presentation": null,
          "company_id": 1,
          "created_at": "2026-03-01T00:00:00.000000Z",
          "updated_at": "2026-03-01T00:00:00.000000Z"
        },
        "created_at": "2026-03-16T09:00:00.000000Z",
        "updated_at": "2026-03-16T09:00:00.000000Z"
      }
    ]
  }
]
```

---

### 3.3 Entreprises

#### `GET /api/companies`

Retourne la liste de toutes les entreprises avec leurs membres.

**Exemple de réponse `200 OK` :**

```json
[
  {
    "id": 1,
    "nom": "Tech Solutions",
    "sous_titre": "Votre partenaire numérique",
    "activites": "Développement logiciel, conseil IT",
    "description": "Entreprise spécialisée dans...",
    "logo_url": "https://example.com/logos/tech-solutions.png",
    "photo_url": null,
    "created_at": "2026-03-01T00:00:00.000000Z",
    "updated_at": "2026-03-01T00:00:00.000000Z",
    "members": [
      {
        "id": 2,
        "nom": "Martin",
        "prenom": "Sophie",
        "email": "sophie.martin@example.com",
        "telephone": "0612345678",
        "presentation": "Développeuse full-stack",
        "company_id": 1,
        "created_at": "2026-03-01T00:00:00.000000Z",
        "updated_at": "2026-03-01T00:00:00.000000Z"
      }
    ]
  }
]
```

---

### 3.4 Membres

#### `GET /api/members`

Retourne la liste de tous les membres avec leur entreprise.

**Exemple de réponse `200 OK` :**

```json
[
  {
    "id": 2,
    "nom": "Martin",
    "prenom": "Sophie",
    "email": "sophie.martin@example.com",
    "telephone": "0612345678",
    "presentation": "Développeuse full-stack passionnée",
    "company_id": 1,
    "created_at": "2026-03-01T00:00:00.000000Z",
    "updated_at": "2026-03-01T00:00:00.000000Z",
    "company": {
      "id": 1,
      "nom": "Tech Solutions",
      "sous_titre": "Votre partenaire numérique",
      "activites": "Développement logiciel, conseil IT",
      "description": "Entreprise spécialisée dans...",
      "logo_url": "https://example.com/logos/tech-solutions.png",
      "photo_url": null,
      "created_at": "2026-03-01T00:00:00.000000Z",
      "updated_at": "2026-03-01T00:00:00.000000Z"
    }
  }
]
```

> ⚠️ Le champ `password` est **toujours masqué** et n'apparaît jamais dans les réponses.

---

### 3.5 Identification (Login)

#### `POST /api/login`

Authentifie un membre et retourne un token Bearer ainsi que les informations du membre connecté.

**Corps de la requête :**

```json
{
  "email": "sophie.martin@example.com",
  "password": "monMotDePasse"
}
```

| Champ | Type | Obligatoire | Description |
|---|---|---|---|
| `email` | string (email) | ✅ | Adresse email du membre |
| `password` | string | ✅ | Mot de passe |

**Exemple de réponse `200 OK` :**

```json
{
  "token": "1|AbCdEfGhIjKlMnOpQrStUvWxYz1234567890",
  "member": {
    "id": 2,
    "nom": "Martin",
    "prenom": "Sophie",
    "email": "sophie.martin@example.com",
    "telephone": "0612345678",
    "presentation": "Développeuse full-stack passionnée",
    "company_id": 1,
    "created_at": "2026-03-01T00:00:00.000000Z",
    "updated_at": "2026-03-01T00:00:00.000000Z",
    "company": {
      "id": 1,
      "nom": "Tech Solutions",
      "sous_titre": "Votre partenaire numérique",
      "activites": "Développement logiciel, conseil IT",
      "description": "...",
      "logo_url": "https://example.com/logos/tech-solutions.png",
      "photo_url": null,
      "created_at": "2026-03-01T00:00:00.000000Z",
      "updated_at": "2026-03-01T00:00:00.000000Z"
    }
  }
}
```

**Exemple de réponse `422 Unprocessable Content` (identifiants incorrects) :**

```json
{
  "message": "The email field must be a valid email address. (and 1 more error)",
  "errors": {
    "email": ["Les identifiants fournis sont incorrects."]
  }
}
```

---

## 4. Routes privées

Ces routes nécessitent le token récupéré lors du login :

```
Authorization: Bearer <token>
```

---

### 4.1 Déconnexion (Logout)

#### `POST /api/logout`

Révoque le token courant du membre connecté.

**Corps de la requête :** aucun

**Exemple de réponse `200 OK` :**

```json
{
  "message": "Déconnexion réussie."
}
```

---

### 4.2 Recommandations reçues

#### `GET /api/recommendations/received`

Retourne les recommandations dont le membre connecté est le **destinataire** (recommandé), triées de la plus récente à la plus ancienne.

**Exemple de réponse `200 OK` :**

```json
[
  {
    "id": 5,
    "nom_contact": "Leblanc",
    "prenom_contact": "Alice",
    "telephone": "0698765432",
    "email": "alice.leblanc@example.com",
    "description": "Alice cherche un prestataire pour développer son site web.",
    "recommandateur_id": 3,
    "recommande_id": 2,
    "created_at": "2026-03-22T14:00:00.000000Z",
    "updated_at": "2026-03-22T14:00:00.000000Z",
    "recommandateur": {
      "id": 3,
      "nom": "Durand",
      "prenom": "Paul",
      "email": "paul.durand@example.com",
      "telephone": null,
      "presentation": null,
      "company_id": 2,
      "created_at": "2026-03-01T00:00:00.000000Z",
      "updated_at": "2026-03-01T00:00:00.000000Z",
      "company": { "id": 2, "nom": "Durand & Co", "..." : "..." }
    }
  }
]
```

---

### 4.3 Recommandations envoyées

#### `GET /api/recommendations/sent`

Retourne les recommandations dont le membre connecté est l'**expéditeur** (recommandateur), triées de la plus récente à la plus ancienne.

**Exemple de réponse `200 OK` :**

```json
[
  {
    "id": 7,
    "nom_contact": "Petit",
    "prenom_contact": "Marc",
    "telephone": null,
    "email": "marc.petit@example.com",
    "description": "Marc souhaite développer une application mobile.",
    "recommandateur_id": 2,
    "recommande_id": 4,
    "created_at": "2026-03-25T11:00:00.000000Z",
    "updated_at": "2026-03-25T11:00:00.000000Z",
    "recommande": {
      "id": 4,
      "nom": "Bernard",
      "prenom": "Lucie",
      "email": "lucie.bernard@example.com",
      "telephone": "0611223344",
      "presentation": null,
      "company_id": 3,
      "created_at": "2026-03-01T00:00:00.000000Z",
      "updated_at": "2026-03-01T00:00:00.000000Z",
      "company": { "id": 3, "nom": "Bernard Consulting", "..." : "..." }
    }
  }
]
```

---

### 4.4 Créer une recommandation

#### `POST /api/recommendations`

Crée une recommandation. Le membre connecté est automatiquement défini comme **expéditeur** (`recommandateur_id`).

**Corps de la requête :**

```json
{
  "recommande_id": 4,
  "nom_contact": "Petit",
  "prenom_contact": "Marc",
  "telephone": "0612345678",
  "email": "marc.petit@example.com",
  "description": "Marc souhaite développer une application mobile."
}
```

| Champ | Type | Obligatoire | Description |
|---|---|---|---|
| `recommande_id` | integer | ✅ | ID du membre destinataire |
| `nom_contact` | string | ✅ | Nom du contact recommandé |
| `prenom_contact` | string | ✅ | Prénom du contact recommandé |
| `telephone` | string | ❌ | Téléphone du contact |
| `email` | string (email) | ❌ | Email du contact |
| `description` | string | ❌ | Détails de la recommandation |

**Exemple de réponse `201 Created` :**

```json
{
  "id": 8,
  "nom_contact": "Petit",
  "prenom_contact": "Marc",
  "telephone": "0612345678",
  "email": "marc.petit@example.com",
  "description": "Marc souhaite développer une application mobile.",
  "recommandateur_id": 2,
  "recommande_id": 4,
  "created_at": "2026-03-28T14:00:00.000000Z",
  "updated_at": "2026-03-28T14:00:00.000000Z",
  "recommandateur": {
    "id": 2,
    "nom": "Martin",
    "prenom": "Sophie",
    "company_id": 1,
    "company": { "..." : "..." }
  },
  "recommande": {
    "id": 4,
    "nom": "Bernard",
    "prenom": "Lucie",
    "company_id": 3,
    "company": { "..." : "..." }
  }
}
```

---

### 4.5 Remerciements reçus

#### `GET /api/thanks/received`

Retourne les remerciements dont le membre connecté est le **destinataire** (remercié), triés du plus récent au plus ancien.

**Exemple de réponse `200 OK` :**

```json
[
  {
    "id": 3,
    "description": "Excellent travail sur le projet de refonte.",
    "montant_ht": "2500.00",
    "date_affaire": "2026-02-15",
    "remerciant_id": 3,
    "remercie_id": 2,
    "created_at": "2026-03-10T09:00:00.000000Z",
    "updated_at": "2026-03-10T09:00:00.000000Z",
    "remerciant": {
      "id": 3,
      "nom": "Durand",
      "prenom": "Paul",
      "company_id": 2,
      "company": { "id": 2, "nom": "Durand & Co", "..." : "..." }
    }
  }
]
```

---

### 4.6 Remerciements envoyés

#### `GET /api/thanks/sent`

Retourne les remerciements dont le membre connecté est l'**expéditeur** (remerciant), triés du plus récent au plus ancien.

**Exemple de réponse `200 OK` :**

```json
[
  {
    "id": 6,
    "description": "Merci pour la recommandation qui a abouti à un beau contrat.",
    "montant_ht": "8000.00",
    "date_affaire": "2026-03-01",
    "remerciant_id": 2,
    "remercie_id": 5,
    "created_at": "2026-03-20T10:00:00.000000Z",
    "updated_at": "2026-03-20T10:00:00.000000Z",
    "remercie": {
      "id": 5,
      "nom": "Leroy",
      "prenom": "Isabelle",
      "company_id": 4,
      "company": { "id": 4, "nom": "Leroy Design", "..." : "..." }
    }
  }
]
```

---

### 4.7 Créer un remerciement

#### `POST /api/thanks`

Crée un remerciement. Le membre connecté est automatiquement défini comme **expéditeur** (`remerciant_id`).

**Corps de la requête :**

```json
{
  "remercie_id": 5,
  "description": "Merci pour la recommandation qui a abouti à un beau contrat.",
  "montant_ht": 8000.00,
  "date_affaire": "2026-03-01"
}
```

| Champ | Type | Obligatoire | Description |
|---|---|---|---|
| `remercie_id` | integer | ✅ | ID du membre destinataire |
| `montant_ht` | number (≥ 0) | ✅ | Montant HT de l'affaire générée |
| `date_affaire` | string (YYYY-MM-DD) | ✅ | Date de l'affaire |
| `description` | string | ❌ | Message de remerciement |

**Exemple de réponse `201 Created` :**

```json
{
  "id": 10,
  "description": "Merci pour la recommandation qui a abouti à un beau contrat.",
  "montant_ht": "8000.00",
  "date_affaire": "2026-03-01",
  "remerciant_id": 2,
  "remercie_id": 5,
  "created_at": "2026-03-28T14:30:00.000000Z",
  "updated_at": "2026-03-28T14:30:00.000000Z",
  "remerciant": {
    "id": 2,
    "nom": "Martin",
    "prenom": "Sophie",
    "company_id": 1,
    "company": { "..." : "..." }
  },
  "remercie": {
    "id": 5,
    "nom": "Leroy",
    "prenom": "Isabelle",
    "company_id": 4,
    "company": { "..." : "..." }
  }
}
```

---

### 4.8 Modifier son profil

#### `PUT /api/me`

Met à jour les informations du membre connecté. Tous les champs sont optionnels (envoyez uniquement ceux à modifier).

> ⚠️ Il est **impossible** de modifier l'email ou le mot de passe via cette route.

**Corps de la requête (exemple partiel) :**

```json
{
  "nom": "Martin",
  "prenom": "Sophie",
  "telephone": "0699887766",
  "presentation": "Développeuse full-stack avec 10 ans d'expérience."
}
```

| Champ | Type | Obligatoire | Description |
|---|---|---|---|
| `nom` | string | ❌ | Nom de famille |
| `prenom` | string | ❌ | Prénom |
| `telephone` | string (≤ 20 car.) | ❌ | Numéro de téléphone (`null` pour effacer) |
| `presentation` | string | ❌ | Présentation libre (`null` pour effacer) |

**Exemple de réponse `200 OK` :**

```json
{
  "id": 2,
  "nom": "Martin",
  "prenom": "Sophie",
  "email": "sophie.martin@example.com",
  "telephone": "0699887766",
  "presentation": "Développeuse full-stack avec 10 ans d'expérience.",
  "company_id": 1,
  "created_at": "2026-03-01T00:00:00.000000Z",
  "updated_at": "2026-03-28T14:00:00.000000Z",
  "company": {
    "id": 1,
    "nom": "Tech Solutions",
    "sous_titre": "Votre partenaire numérique",
    "activites": "Développement logiciel, conseil IT",
    "description": "...",
    "logo_url": "https://example.com/logos/tech-solutions.png",
    "photo_url": null,
    "created_at": "2026-03-01T00:00:00.000000Z",
    "updated_at": "2026-03-01T00:00:00.000000Z"
  }
}
```

---

### 4.9 Modifier son mot de passe

#### `PUT /api/me/password`

Modifie le mot de passe du membre connecté.

**Corps de la requête :**

```json
{
  "current_password": "ancienMotDePasse",
  "password": "nouveauMotDePasse123!",
  "password_confirmation": "nouveauMotDePasse123!"
}
```

| Champ | Type | Obligatoire | Description |
|---|---|---|---|
| `current_password` | string | ✅ | Mot de passe actuel |
| `password` | string | ✅ | Nouveau mot de passe (doit respecter les règles de sécurité Laravel) |
| `password_confirmation` | string | ✅ | Confirmation du nouveau mot de passe (doit être identique à `password`) |

> **Règles du mot de passe :** par défaut Laravel exige 8 caractères minimum.

**Exemple de réponse `200 OK` :**

```json
{
  "message": "Mot de passe mis à jour avec succès."
}
```

**Exemple de réponse `422 Unprocessable Content` (mot de passe actuel incorrect) :**

```json
{
  "message": "Le mot de passe actuel est incorrect."
}
```

---

### 4.10 Modifier son entreprise

#### `PUT /api/me/company`

Met à jour les informations de l'entreprise du membre connecté. Tous les champs sont optionnels (envoyez uniquement ceux à modifier).

> ⚠️ Si le membre n'a pas d'entreprise associée, l'API retourne une erreur `404`.

**Corps de la requête (exemple partiel) :**

```json
{
  "nom": "Tech Solutions",
  "sous_titre": "Experts en transformation digitale",
  "activites": "Développement logiciel, conseil IT, formation",
  "description": "Entreprise fondée en 2015...",
  "logo_url": "https://example.com/logos/tech-solutions-v2.png",
  "photo_url": null
}
```

| Champ | Type | Obligatoire | Description |
|---|---|---|---|
| `nom` | string | ❌ | Nom de l'entreprise |
| `sous_titre` | string | ❌ | Sous-titre / accroche (`null` pour effacer) |
| `activites` | string | ❌ | Description des activités (`null` pour effacer) |
| `description` | string | ❌ | Description longue (`null` pour effacer) |
| `logo_url` | string (URL) | ❌ | URL du logo (`null` pour effacer) |
| `photo_url` | string (URL) | ❌ | URL de la photo (`null` pour effacer) |

**Exemple de réponse `200 OK` :**

```json
{
  "id": 1,
  "nom": "Tech Solutions",
  "sous_titre": "Experts en transformation digitale",
  "activites": "Développement logiciel, conseil IT, formation",
  "description": "Entreprise fondée en 2015...",
  "logo_url": "https://example.com/logos/tech-solutions-v2.png",
  "photo_url": null,
  "created_at": "2026-03-01T00:00:00.000000Z",
  "updated_at": "2026-03-28T14:00:00.000000Z"
}
```

**Exemple de réponse `404 Not Found` (aucune entreprise) :**

```json
{
  "message": "Aucune entreprise associée à ce membre."
}
```

---

### 4.11 Ajouter un invité à une réunion

#### `POST /api/meetings/{meeting}/guests`

Crée un invité et l'associe à la réunion spécifiée. Le membre connecté est automatiquement défini comme **invitant** (`invited_by`).

**Paramètre de chemin :**

| Paramètre | Type | Description |
|---|---|---|
| `meeting` | integer | ID de la réunion |

**Corps de la requête :**

```json
{
  "nom": "Dupont",
  "prenom": "Jean",
  "nom_entreprise": "Dupont SARL"
}
```

| Champ | Type | Obligatoire | Description |
|---|---|---|---|
| `nom` | string | ✅ | Nom de l'invité |
| `prenom` | string | ✅ | Prénom de l'invité |
| `nom_entreprise` | string | ❌ | Entreprise de l'invité (`null` si aucune) |

**Exemple de réponse `201 Created` :**

```json
{
  "id": 12,
  "nom": "Dupont",
  "prenom": "Jean",
  "nom_entreprise": "Dupont SARL",
  "invited_by": {
    "id": 2,
    "nom": "Martin",
    "prenom": "Sophie",
    "email": "sophie.martin@example.com",
    "telephone": "0699887766",
    "presentation": "...",
    "company_id": 1,
    "created_at": "2026-03-01T00:00:00.000000Z",
    "updated_at": "2026-03-28T14:00:00.000000Z"
  },
  "created_at": "2026-03-28T15:00:00.000000Z",
  "updated_at": "2026-03-28T15:00:00.000000Z",
  "meetings": [
    {
      "id": 1,
      "date": "2026-04-10",
      "heure": "09:00:00",
      "adresse": "12 Rue de la Paix, Paris",
      "ordre_du_jour": "Point sur les projets en cours",
      "compte_rendu": null,
      "created_at": "2026-03-15T08:00:00.000000Z",
      "updated_at": "2026-03-15T08:00:00.000000Z"
    }
  ]
}
```

**Exemple de réponse `404 Not Found` (réunion introuvable) :**

```json
{
  "message": "No query results for model [App\\Models\\Meeting] 99"
}
```

---

## 5. Codes d'erreur HTTP

| Code | Signification | Cas typique |
|---|---|---|
| `200 OK` | Succès | Lecture ou mise à jour réussie |
| `201 Created` | Ressource créée | Création d'une recommandation, remerciement, invité |
| `401 Unauthorized` | Non authentifié | Token absent ou invalide sur une route privée |
| `404 Not Found` | Ressource introuvable | ID de réunion ou d'entreprise inexistant |
| `422 Unprocessable Content` | Données invalides | Champ obligatoire manquant, format incorrect, identifiants incorrects, mot de passe actuel erroné |

### Format standard des erreurs de validation (`422`)

```json
{
  "message": "The <champ> field is required. (and X more errors)",
  "errors": {
    "champ1": ["Message d'erreur 1."],
    "champ2": ["Message d'erreur 2."]
  }
}
```

---

## 6. Modèles de données

### Member (Membre)

```
id            integer       Identifiant unique
nom           string        Nom de famille
prenom        string        Prénom
email         string        Adresse email (unique)
telephone     string|null   Numéro de téléphone
presentation  string|null   Texte de présentation libre
company_id    integer|null  ID de l'entreprise associée
created_at    datetime      Date de création
updated_at    datetime      Date de dernière modification
```

> Le champ `password` est toujours masqué dans les réponses.

---

### Company (Entreprise)

```
id          integer      Identifiant unique
nom         string       Nom de l'entreprise
sous_titre  string|null  Accroche / sous-titre
activites   string|null  Description des activités
description string|null  Description longue
logo_url    string|null  URL du logo
photo_url   string|null  URL d'une photo
created_at  datetime     Date de création
updated_at  datetime     Date de dernière modification
```

---

### News (Actualité)

```
id         integer   Identifiant unique
titre      string    Titre de l'actualité
sous_titre string    Sous-titre
statut     string    Statut (ex. "publié", "brouillon")
contenu    string    Contenu de l'actualité
created_at datetime  Date de création
updated_at datetime  Date de dernière modification
```

---

### Meeting (Réunion)

```
id            integer      Identifiant unique
date          date         Date (format YYYY-MM-DD)
heure         time         Heure (format HH:MM:SS)
adresse       string       Adresse du lieu
ordre_du_jour string|null  Ordre du jour
compte_rendu  string|null  Compte-rendu (rempli après la réunion)
created_at    datetime     Date de création
updated_at    datetime     Date de dernière modification
```

---

### Guest (Invité)

```
id             integer      Identifiant unique
nom            string       Nom de l'invité
prenom         string       Prénom de l'invité
nom_entreprise string|null  Entreprise de l'invité
invited_by     integer|null ID du membre invitant
created_at     datetime     Date de création
updated_at     datetime     Date de dernière modification
```

---

### Recommendation (Recommandation)

```
id               integer      Identifiant unique
nom_contact      string       Nom du contact recommandé
prenom_contact   string       Prénom du contact recommandé
telephone        string|null  Téléphone du contact
email            string|null  Email du contact
description      string|null  Détails de la recommandation
recommandateur_id integer     ID du membre expéditeur
recommande_id    integer      ID du membre destinataire
created_at       datetime     Date de création
updated_at       datetime     Date de dernière modification
```

---

### Thanks (Remerciement)

```
id           integer   Identifiant unique
description  string|null  Message de remerciement
montant_ht   decimal   Montant HT de l'affaire (2 décimales)
date_affaire date      Date de l'affaire (format YYYY-MM-DD)
remerciant_id integer  ID du membre expéditeur
remercie_id  integer   ID du membre destinataire
created_at   datetime  Date de création
updated_at   datetime  Date de dernière modification
```
