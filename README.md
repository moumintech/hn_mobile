# 📱 HealthNorth Mobile
![Capture de l'application](docs/captures/capture-accueil.png)




Application mobile développée en **Dart / Flutter** dans le cadre du BTS SIO – option SLAM.

Elle permet à un patient disposant d’un compte web d’accéder à ses informations de santé via une interface mobile.



##  Fonctionnalités

* 🔐 Authentification par token
* 👤 Consultation du profil patient
* 📅 Consultation des rendez-vous
* 💊 Consultation des prescriptions
* ⏰ Consultation des rappels
* ⚙️ Consultation des options

⚠️ Les modifications des données sont effectuées uniquement via l’application web.



##  Technologies

* Dart / Flutter
* API REST (PHP)
* MySQL
* Git / GitHub



##  Structure du projet

###  Code principal

Le code développé dans ce projet se trouve principalement dans :

```text
/lib/
```

Ce dossier contient :

* `config/` → configuration (API, constantes)
* `models/` → structures de données
* `screens/` → écrans de l’application
* `services/` → appels API
* `widgets/` → composants UI
* fichiers Dart principaux

 C’est dans ce dossier que se trouve l’essentiel du travail de développement.


###  Documentation et ressources

Les éléments de conception et de preuve sont regroupés dans :

```text
/docs/
```

Ce dossier contient :

* 📊 diagrammes (modélisation)
* 🎨 maquettes de l’application
* 📡 requêtes API
* 📸 captures d’écran de l’application
*     script sql ( fussion de la base de donné web et mobile) et des screenshots des requêtte api

 Accès direct :
 **https://github.com/moumintech/hn_mobile/tree/main/docs**



###  Documentation API

Une documentation spécifique de l’API est fournie :

 `documentation_api.md`

 Accès direct:
 https://github.com/moumintech/hn_mobile/blob/main/documentation_api.md

Elle décrit :

* le fonctionnement de l’API
* les routes
* les méthodes (GET, POST…)
* des exemples d’utilisation



## 🔗 API

L’application mobile consomme une API REST développée dans le projet web associé.

 Accès au projet API :
https://github.com/moumintech/healthnorth-app/tree/main/api



##  Tests API

Une collection Postman est fournie :

 `healthnorth_api_postman_collection.json`
 Acces direct :
 https://github.com/moumintech/hn_mobile/blob/main/docs/requettes%20api/healthnorth_mobile.postman_collection.json

Elle contient :

* les endpoints
* les requêtes testées
* les exemples JSON

 Les tokens ont été remplacés par `YOUR_TOKEN` pour des raisons de sécurité.



##  Installation

```bash
flutter pub get
flutter run
```



##  Remarque

Certains dossiers du projet sont générés automatiquement par Flutter et n’ont pas été modifiés.
Le développement principal est concentré dans le dossier `/lib`.


