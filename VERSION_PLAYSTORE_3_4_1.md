# DroneAtlas 3.4.1 — Version Play Store

Cette compilation est destinée à la première publication publique de l’application.

## Comportement du parcours certifiant

- Le bouton **Parcours certifiants** reste visible dans le profil.
- Il porte le badge **BIENTÔT**.
- Son ouverture affiche une page d’information et de préparation.
- Aucun compte Firebase n’est demandé.
- Aucun examen certifiant ne peut être lancé.
- Aucun certificat ne peut être généré.
- Aucun appel au serveur de certification n’est effectué.

## Message affiché

> Les parcours certifiants arrivent bientôt. Restez connectés pour découvrir les prochaines mises à jour de DroneAtlas Academy. Explorez d’abord les cours, les quiz et les autres fonctionnalités de l’application : les connaissances et compétences acquises vous seront utiles pour réussir les différentes certifications.

## Version

- Nom : `3.4.1`
- Code Android : `18`
- Identifiant Android : `com.novateur221.droneatlas`

## Publication Google Play

Le workflow produit un APK et un AAB. Pour envoyer l’AAB sur Google Play, il doit être signé avec la clé d’importation privée du propriétaire de l’application. Le workflow utilise automatiquement une vraie signature lorsque les secrets GitHub suivants sont renseignés :

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Sans ces secrets, une signature de test est utilisée et l’AAB ne doit pas être envoyé sur Google Play.

### Préparer le secret `ANDROID_KEYSTORE_BASE64` sous Windows PowerShell

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\chemin\vers\upload-keystore.jks")) | Set-Clipboard
```

Collez ensuite la valeur copiée dans le secret GitHub `ANDROID_KEYSTORE_BASE64`. La clé privée et les mots de passe ne doivent jamais être ajoutés directement au dépôt.
