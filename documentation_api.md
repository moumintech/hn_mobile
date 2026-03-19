#  HealthNorth API – Documentation complète



##  1. Contexte du projet

L’API HealthNorth est une API REST développée en **PHP** avec une base de données **MySQL**.

Elle est intégrée au projet web et permet de gérer les données médicales d’un patient.
Elle est utilisée par deux interfaces :

* 🌐 **Application web** : gestion des des rendez-vous (patient/admin)
* 📱 **Application mobile** : consultation des informations patient

 L’API constitue le **noyau central** du système.



## 🔗 2. Accès au code source

Une collection Postman est fournie pour tester les endpoints de l’API :

 `docs/requettes api/healthnorth_mobile.postman_collection.json`

L’API est incluse dans le projet web.

 **Lien GitHub du projet :**
 `https://github.com/moumintech/healthnorth-app/tree/main/api`

Dans ce dépôt, l’API se trouve dans :

```text
/api/
```

Les routes sont organisées dans ce dossier.



##  3. Architecture de l’API

```text
api/
│
├── auth/                  → Authentification (admin / patient)
├── web/                   → Routes CRUD (administration)
├── mobile/
│   └── patient/           → Routes de consultation mobile
├── config/                → Connexion base de données
├── utils/                 → Fonctions utilitaires
```



##  4. Gestion des rôles

###  Admin (application web)

* crée et modifie les données
* gère :

  * patients
  * rendez-vous
  * ordonnances
  * rappels
  * options

###  Patient (application mobile)

* consulte uniquement ses données :

  * profil
  * rendez-vous
  * prescriptions
  * rappels
  * options



##  5. Authentification

L’API utilise un système de **token (JWT)**.

### Fonctionnement :

1. L’utilisateur se connecte
2. Un token est généré
3. Le token est utilisé dans les requêtes

### Header obligatoire :

```http
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json
Accept: application/json
```

 Les tokens ne sont pas inclus dans cette documentation pour des raisons de sécurité.



##  6. Fonctionnalités de l’API

### Authentification

* login admin
* login patient

### Gestion des patients

* création
* modification
* suppression
* consultation

### Rendez-vous

* création
* modification
* suppression
* consultation

### Ordonnances (prescriptions)

* création d’ordonnances
* ajout de médicaments
* consultation mobile

### Rappels

* gestion des rappels de prise de médicaments
* consultation mobile

### Options patient

* gestion des préférences
* activation / désactivation
* consultation mobile



##  7. Utilisation de l’API

###  Base URL

```text
http://localhost/healthnorth/api/
```



##  Exemple 1 : récupérer le profil patient

### Requête

```http
GET /api/mobile/patient/get_patient.php
```

### URL complète

```text
http://localhost/healthnorth/api/mobile/patient/get_patient.php
```



##  Exemple 2 : récupérer les prescriptions

```http
GET /api/mobile/patient/get_prescription.php
```



##  Exemple 3 : récupérer les rappels

```http
GET /api/mobile/patient/get_rappels.php
```



##  Exemple 4 : récupérer les options

```http
GET /api/mobile/patient/get_options.php
```



##  Exemple 5 : créer une option (admin)

```http
POST /api/web/options.php
```

### Body JSON

```json
{
  "libelle": "notifications_rappels",
  "valeur": "oui",
  "active": 1,
  "id_patient": 1
}
```



##  Exemple 6 : modifier une option

```http
POST /api/web/options.php?action=update
```



##  Exemple 7 : supprimer une option

```http
POST /api/web/options.php?action=delete&id=1
```



##  8. Méthodes HTTP utilisées

| Méthode | Utilisation      |
| - | - |
| GET     | Lire des données |
| POST    | Créer            |
| PUT     | Modifier         |
| DELETE  | Supprimer        |

 Certaines actions PUT/DELETE sont simulées via POST (`action=update`, `action=delete`).



##  9. Utilisation côté mobile

Le mobile consomme uniquement :

```text
api/mobile/patient/
```

### Fonctionnalités :

* consultation du profil
* consultation des rendez-vous
* consultation des prescriptions
* consultation des rappels
* consultation des options

 Les modifications se font uniquement via l’application web.



##  10. Format des réponses

### Succès

```json
{
  "success": true,
  "data": []
}
```

### Erreur

```json
{
  "success": false,
  "message": "Erreur serveur"
}
```



##  11. Tests avec Postman

Une collection Postman est fournie :

 `docs/requettes api/healthnorth_mobile.postman_collection.json`

Elle contient :

* toutes les routes
* les requêtes testées
* les exemples JSON

 Les tokens ont été remplacés par `YOUR_TOKEN` pour des raisons de sécurité.



##  12. Conclusion

L’API HealthNorth permet :

* une gestion complète des données médicales côté web
* une consultation sécurisée côté mobile
* une séparation claire des rôles
* une architecture structurée

Elle constitue le socle technique du projet.


