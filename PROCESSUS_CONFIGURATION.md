# Processus de configuration — Firebase Spark + Backblaze B2 + Netlify

## 1. Préparer Firebase sans activer Blaze

1. Créer ou ouvrir le projet Firebase DroneAtlas.
2. Conserver le plan **Spark**.
3. Ouvrir **Authentication > Sign-in method**.
4. Activer uniquement **E-mail/Mot de passe**.
5. Ne pas activer Cloud Storage, Firestore ou Cloud Functions.
6. Ajouter une application Android avec le package :

   `com.novateur221.droneatlas`

7. Télécharger `google-services.json` uniquement pour lire les valeurs de configuration. Le fichier n’est pas à publier.
8. Relever :
   - `project_info.project_id` → `FIREBASE_PROJECT_ID`
   - `project_info.project_number` → `FIREBASE_MESSAGING_SENDER_ID`
   - `client[0].client_info.mobilesdk_app_id` → `FIREBASE_APP_ID`
   - `client[0].api_key[0].current_key` → `FIREBASE_API_KEY`
   - `PROJECT_ID.firebaseapp.com` → `FIREBASE_AUTH_DOMAIN`
9. Dans **Paramètres du projet > Comptes de service**, générer une nouvelle clé privée JSON.
10. Conserver ce JSON uniquement dans Netlify sous `FIREBASE_SERVICE_ACCOUNT_JSON`. Ne jamais le placer dans GitHub ou dans l’APK.

Le fichier `certification_config.dart` utilise des `dart-define`. Les valeurs Firebase visibles dans l’application ne sont pas des secrets administratifs. La clé du compte de service, elle, est secrète et reste sur Netlify.

## 2. Préparer Backblaze B2

1. Créer un bucket privé, par exemple :

   `droneatlas-certificates`

2. Dans les paramètres du bucket, laisser l’accès sur **Private**.
3. Créer une Application Key limitée à ce bucket avec les droits :
   - lire les fichiers ;
   - écrire les fichiers ;
   - lister les fichiers ;
   - lire les métadonnées.
4. Noter :
   - Key ID → `B2_KEY_ID`
   - Application Key → `B2_APPLICATION_KEY`
   - nom du bucket → `B2_BUCKET`
   - région, exemple `us-west-004` → `B2_REGION`
   - endpoint S3, exemple `https://s3.us-west-004.backblazeb2.com` → `B2_S3_ENDPOINT`
5. Ne jamais mettre ces clés dans Flutter ou GitHub.
6. Il est conseillé d’ajouter une règle de cycle de vie Backblaze supprimant les anciennes versions cachées des petits fichiers JSON après 30 jours, tout en conservant les PDF officiels.

Structure créée automatiquement :

```text
certification/
  results/{uid}/{filiere}/{examen}.json
  cooldowns/{uid}/{filiere}/{examen}.json
  sessions/{uid}/{tentative}.json
  certificates/{uid}/{filiere}/{certificat}/
    preview.pdf
    official.pdf
    metadata.json
    notification.json
  verification/{certificat}.json
```

## 3. Déployer le serveur sur Netlify

1. Mettre les dossiers `netlify/`, `package.json` et `netlify.toml` dans le dépôt.
2. Connecter le dépôt à un nouveau site Netlify ou au site DroneAtlas existant.
3. Dans **Site configuration > Environment variables**, créer :

```text
FIREBASE_SERVICE_ACCOUNT_JSON
B2_S3_ENDPOINT
B2_REGION
B2_BUCKET
B2_KEY_ID
B2_APPLICATION_KEY
EXAM_SIGNING_SECRET
CERTIFICATE_VERIFY_BASE_URL
EMAILJS_SERVICE_ID
EMAILJS_TEMPLATE_ID_CERTIFICATE
EMAILJS_PUBLIC_KEY
NOVATEUR_EMAIL
```

4. Pour `EXAM_SIGNING_SECRET`, utiliser une chaîne aléatoire d’au moins 32 caractères.
5. Définir :

```text
CERTIFICATE_VERIFY_BASE_URL=https://VOTRE-SITE.netlify.app/certificat.html
NOVATEUR_EMAIL=novateur221@gmail.com
```

6. Déployer le site.
7. L’API aura cette forme :

```text
https://VOTRE-SITE.netlify.app/.netlify/functions/certification-api
```

## 4. Créer le modèle EmailJS des certificats

Créer un nouveau template EmailJS destiné à Novateur221.

### Destinataire

```text
novateur221@gmail.com
```

### Objet

```text
Nouveau certificat officiel DroneAtlas — {{certificate_id}}
```

### Corps suggéré

```text
Un certificat officiel sans filigrane vient d’être généré automatiquement.

Titulaire : {{full_name}}
E-mail du candidat : {{user_email}}
Filière : {{path_title}}
Résultat : {{score}}
Identifiant : {{certificate_id}}

Lien privé temporaire :
{{official_download_url}}

{{message}}
```

Copier l’identifiant du template dans `EMAILJS_TEMPLATE_ID_CERTIFICATE` sur Netlify.

## 5. Configurer GitHub Actions

Dans **GitHub > Settings > Secrets and variables > Actions**, ajouter :

```text
FIREBASE_API_KEY
FIREBASE_APP_ID
FIREBASE_MESSAGING_SENDER_ID
FIREBASE_PROJECT_ID
FIREBASE_AUTH_DOMAIN
CERTIFICATION_API_URL
```

`CERTIFICATION_API_URL` doit contenir l’URL complète de la fonction Netlify.

Le workflow fourni transmet automatiquement ces valeurs à l’APK et à l’AAB au moment de la compilation.

## 6. Tester le parcours complet

1. Relancer GitHub Actions et installer le nouvel APK.
2. Vérifier que l’application reste utilisable sans compte.
3. Ouvrir **Profil > Parcours certifiants**.
4. Créer un compte Firebase avec un e-mail de test.
5. Vérifier que le deuxième examen est verrouillé avant la réussite du premier.
6. Réussir les trois examens intermédiaires puis l’examen final.
7. Saisir un prénom et un nom réels.
8. Vérifier dans Backblaze que `preview.pdf` et `official.pdf` existent.
9. Vérifier que le mail EmailJS arrive à Novateur221 avec un lien privé.
10. Vérifier que l’application affiche l’aperçu avec de nombreux filigranes.
11. Vérifier que la capture d’écran Android est bloquée sur l’examen et l’aperçu.
12. Scanner le QR du certificat officiel pour tester la page publique de vérification automatique.

## 7. Règles fonctionnelles retenues

- Aucun temps de formation n’apparaît sur le certificat.
- Seuls les candidats aux certifications créent un compte.
- Les examens intermédiaires exigent 70 à 75 %.
- Les examens finaux exigent 80 %.
- Les résultats et certificats sont stockés dans Backblaze, pas dans Firebase.
- La version officielle est générée automatiquement ; Novateur221 n’a pas à modifier un statut « verified ».
- L’utilisateur ne reçoit pas automatiquement le PDF officiel dans l’application.
- Le bouton WhatsApp sert à demander la remise de la version officielle sans filigrane.
- Le certificat est pédagogique et ne remplace aucune licence ou autorisation ANACIM.
