# DroneAtlas Academy 2.5 — Drobot Expert

## Nouveautés

- Retour d’un assistant pédagogique, renommé **Drobot**.
- Bouton flottant Drobot disponible depuis toutes les pages.
- Carte Drobot ajoutée sur l’accueil.
- Interface de conversation mobile et ordinateur.
- Conversations défilables, réponses copiables et suggestions intelligentes.
- Nouvelle conversation en un clic.

## Expertise embarquée

Drobot possède une base locale structurée sur :

- choix du drone, sécurité, météo et checklists ;
- photographie aérienne, netteté et exposition ;
- GSD, altitude, recouvrements, relief et lignes de vol ;
- GCP, checkpoints, RTK/PPK, GNSS et systèmes de coordonnées ;
- SfM, calibration, nuages de points, DSM/DTM, orthomosaïques et modèles 3D ;
- QGIS, formats SIG, métadonnées, précision et contrôle qualité ;
- LiDAR, thermique, multispectral et applications métier ;
- rapports, livrables et archivage.

La base fonctionne **sans connexion Internet**. Un moteur de recherche pondéré reconnaît les synonymes, les fautes simples, les accents et les questions multi-thèmes.

## Calculateurs intégrés

Drobot sait notamment :

- calculer un GSD et une largeur d’empreinte ;
- convertir hectares, mètres carrés et kilomètres carrés ;
- estimer un nombre minimal de batteries avec une marge de sécurité.

Exemple :

```text
Calcule le GSD avec altitude 100 m, capteur 13.2 mm,
focale 8.8 mm et image 5472 pixels.
```

## IA en ligne facultative

Drobot fonctionne immédiatement hors ligne. Pour ajouter une IA générative plus puissante, configure un proxy sécurisé dans le secret GitHub :

```text
DROBOT_API_URL
```

Le proxy reçoit :

```json
{
  "question": "...",
  "history": [],
  "offline_context": "...",
  "language": "fr",
  "assistant": "Drobot"
}
```

Il peut renvoyer :

```json
{"answer":"Réponse de l’IA"}
```

Ne place pas une clé secrète directement dans l’application Flutter : elle pourrait être extraite de l’APK. Le proxy doit conserver la clé côté serveur.
