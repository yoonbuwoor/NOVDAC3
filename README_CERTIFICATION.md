# DroneAtlas Academy — Certifications sans Firebase Blaze

Ce pack met en place le système de certifications proposé sans utiliser Cloud Storage, Firestore ni Cloud Functions de Firebase.

## Architecture retenue

- **Firebase Spark** : uniquement création de compte et connexion par e-mail/mot de passe.
- **Netlify Functions** : sécurisation des examens, vérification des prérequis, calcul des notes et génération des PDF.
- **Backblaze B2 privé** : résultats, états de progression, aperçus filigranés, certificats officiels et métadonnées.
- **EmailJS** : envoi automatique à Novateur221 d’un lien privé temporaire vers le certificat officiel.
- **WhatsApp** : demande par l’utilisateur de la version officielle sans filigrane après consultation de l’aperçu.

Aucun compte n’est demandé pour utiliser les cours, ressources, simulations ou quiz d’entraînement. Le compte Firebase apparaît uniquement lorsque l’utilisateur ouvre « Parcours certifiants ».

## Filières incluses

1. Télépilotage et sécurité opérationnelle
2. Photogrammétrie et cartographie par drone
3. SIG et valorisation des données drones

Chaque filière comprend trois évaluations à prérequis et un examen final. Le pack contient une banque initiale de 66 questions côté serveur. Les réponses correctes ne sont jamais placées dans l’APK.

## Émission d’un certificat

1. L’utilisateur valide les examens dans l’ordre.
2. Il réussit l’examen final avec le seuil demandé.
3. Il saisit son prénom et son nom réels.
4. Le serveur génère automatiquement deux PDF :
   - un aperçu avec plusieurs filigranes « APERÇU — NON VALABLE » ;
   - le certificat officiel sans filigrane.
5. Les deux fichiers sont enregistrés dans un bucket Backblaze B2 privé.
6. Le certificat officiel est envoyé automatiquement à Novateur221 sous la forme d’un lien B2 temporaire signé.
7. L’application affiche seulement l’aperçu protégé, sans bouton de téléchargement.
8. Le bouton « Recevoir la version officielle sans filigrane » ouvre WhatsApp avec l’identifiant du certificat.

Il n’existe pas de statut manuel « verified ». L’émission est automatique dès que le serveur confirme la réussite.

## Protection des examens et aperçus

- `FLAG_SECURE` sur Android pour bloquer les captures et l’enregistrement d’écran dans les pages d’examen et d’aperçu.
- `SelectionContainer.disabled` pour empêcher la sélection et la copie du texte.
- Questions et options mélangées côté serveur.
- Une question affichée à la fois.
- Jeton d’examen signé et limité dans le temps.
- Tentative rendue une seule fois.
- Trois sorties de l’application invalident la tentative.
- Deux échecs dans une fenêtre de 24 heures imposent une attente jusqu’à la fin de cette fenêtre.

Aucune application ne peut empêcher une personne de photographier l’écran avec un second appareil. La protection repose donc aussi sur l’aléa des questions, les variantes, le chronomètre et la validation serveur.

## Fichiers à intégrer

Copier les fichiers du pack à la racine du dépôt en conservant leurs chemins. Les fichiers principaux remplacés sont :

- `pubspec.yaml`
- `lib/main.dart`
- `lib/screens/profile_screen.dart`
- `tool/configure_android.py`
- `.github/workflows/main.yml`

Les nouveaux dossiers sont :

- `lib/config/certification_config.dart`
- `lib/models/certification_models.dart`
- `lib/services/certification_*`
- `lib/screens/certification_*`
- `lib/screens/certificate_*`
- `netlify/functions/`
- `netlify/public/`

## Important

Les identifiants Firebase, Backblaze, EmailJS et les clés serveur ne sont pas inclus dans le code. Ils doivent être ajoutés comme variables d’environnement et secrets selon `PROCESSUS_CONFIGURATION.md`.
