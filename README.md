# DroneAtlas Nova 3.0

Application Flutter pédagogique complète pour apprendre et pratiquer :

- drones et sécurité opérationnelle ;
- photographie aérienne ;
- photogrammétrie ;
- planification et acquisition terrain ;
- contrôle qualité et SIG ;
- multispectral, thermique et LiDAR ;
- IA géospatiale ;
- rapport, métier et activité professionnelle.

## Expérience Nova

- cockpit responsive ;
- 12 modules et 36 leçons intégrées ;
- 6 missions scénarisées ;
- 10 domaines d’application ;
- Nova Labs avec calculateur de mission et checklist terrain ;
- simulateur de planification, caméra, fragments et traitement ;
- Rapport Studio ;
- quiz et glossaire ;
- Drobot Nova, expert hors ligne extensible par IA en ligne ;
- progression, XP, badges et notifications ;
- mise à jour des cours par fichiers JSON.

Le détail complet est dans [NOUVEAUTES_3_0_NOVA.md](NOUVEAUTES_3_0_NOVA.md).

## Compiler sur GitHub

1. Envoyer tout le contenu du dossier dans le dépôt GitHub.
2. Ouvrir **Actions**.
3. Choisir **Build DroneAtlas Nova Android**.
4. Cliquer sur **Run workflow**.
5. Télécharger l’artefact **DroneAtlas-Nova-3.0-Android**.

L’artefact contient l’APK et l’AAB Release.

## EmailJS

La version contient la configuration communiquée :

- `service_726u54k`
- `template_9y2rmzx`
- Public Key EmailJS configurée

Le template doit au minimum utiliser :

```text
{{name}}
{{profession}}
{{email}}
```

`{{date}}` reste facultatif.

## Drobot en ligne

La base experte hors ligne fonctionne sans clé. Pour connecter un proxy IA, créer le secret GitHub :

```text
DROBOT_API_URL
```

Ne place jamais une clé privée d’API directement dans l’APK.
