# DroneAtlas Nova 3.0

DroneAtlas Academy devient **DroneAtlas Nova**, une expérience Flutter entièrement repensée autour d’un cockpit d’apprentissage, d’un laboratoire opérationnel et de Drobot Nova.

## Nouveau design

- Nouveau système visuel « Nova » : surfaces profondes, halos cyan/bleu/violet, cartes adaptatives, grille technique et typographie plus affirmée.
- Nouveau cockpit d’accueil responsive pour téléphone, tablette et ordinateur.
- Nouvelle barre latérale sur grand écran et navigation flottante sur mobile.
- Nouveau bouton orbital Drobot.
- Nouvel écran de démarrage et onboarding harmonisés.
- Mode clair et mode sombre conservés.

## Nova Labs

Un nouvel espace regroupe :

- simulateur intégral de plan de vol, caméra, fragments et pipeline ;
- calculateur de mission en direct ;
- estimation pédagogique du GSD ;
- nombre approximatif de photos ;
- durée, batteries et stockage ;
- checklist terrain GO / NO-GO ;
- décodeur de produits photogrammétriques ;
- accès direct au Rapport Studio, au quiz et à Drobot.

Les estimations sont pédagogiques. Le capteur réel, le relief, le vent, les virages et les contraintes opérationnelles peuvent modifier les résultats.

## Académie enrichie

Le parcours passe de 8 à **12 modules** et contient désormais 36 leçons intégrées :

1. Drone et systèmes
2. Photographie aérienne
3. Fondamentaux photogrammétriques
4. Planification
5. Acquisition terrain
6. Traitement simulé
7. Géomatique et qualité
8. Rédaction et restitution
9. Sécurité et réglementation
10. Capteurs avancés
11. IA et analyse géospatiale
12. Métier et entreprise

Nouveaux sujets :

- analyse de risque et retour d’expérience ;
- multispectral et calibration radiométrique ;
- thermographie ;
- LiDAR et fusion ;
- détection, segmentation et validation d’un modèle IA ;
- automatisation SIG ;
- besoin client, chiffrage, portfolio et assurance qualité.

## Missions supplémentaires

- diagnostiquer une parcelle agricole ;
- cartographier une zone inondée ;
- inspecter une centrale solaire.

L’application contient maintenant 6 missions scénarisées avec décisions et scores.

## Domaines supplémentaires

- inspection technique ;
- urgence et humanitaire ;
- énergie et solaire ;
- foncier et urbanisme.

## Drobot Nova

La base de connaissances hors ligne a été étendue avec :

- multispectral et NDVI ;
- thermographie ;
- LiDAR ;
- IA géospatiale ;
- validation de modèles ;
- cartographie d’urgence ;
- chiffrage d’une mission ;
- portfolio professionnel.

Drobot conserve ses calculateurs et sa possibilité de connexion à une IA via `DROBOT_API_URL`.

## Données utilisateur et EmailJS

La configuration fournie reste intégrée :

- Service ID : `service_726u54k`
- Template ID : `template_9y2rmzx`
- Public Key : configurée dans le workflow et le fichier de configuration

Les variables principales sont :

- `name`
- `profession`
- `email`

La variable `date` n’est pas obligatoire dans le template EmailJS.

## Compilation

Le workflow GitHub Actions produit :

- `app-release.apk`
- `app-release.aab`

Nom de l’artefact : `DroneAtlas-Nova-3.0-Android`.
