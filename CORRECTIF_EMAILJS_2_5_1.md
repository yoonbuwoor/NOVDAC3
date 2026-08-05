# Correctif EmailJS 2.5.1

## Paramètres utilisés

- Service ID : `service_726u54k`
- Template ID : `template_9y2rmzx`
- Public Key : `fxWkKI41fWVZAmts5`
- Destinataire : `novateur221@gmail.com`

## Vérification obligatoire dans EmailJS

Dans **Email Templates > Contact Us > Content** :

- **To Email** : `novateur221@gmail.com`
- **From Name** : `{{name}}`
- **Reply To** : `{{email}}`
- **Subject** : `Nouvelle inscription DroneAtlas — {{name}}`

Le contenu peut utiliser :

```text
Nom : {{name}}
Profession : {{profession}}
E-mail : {{email}}
Date : {{time}}

{{message}}
```

Clique ensuite sur **Save**, puis sur **Test It**.

## Dans l’application

Le bouton d’inscription attend désormais une confirmation réelle d’EmailJS. En cas d’échec, le code et le message EmailJS sont affichés. Depuis le profil, le bouton **Renvoyer les informations** permet de refaire un essai, même pour un profil déjà créé.

## Test sans installer l’APK

Le workflow **Tester EmailJS** est inclus. Dans GitHub :

1. ouvre **Actions** ;
2. choisis **Tester EmailJS** ;
3. clique sur **Run workflow** ;
4. ouvre le résultat.

Si le workflow est vert mais que rien n’arrive, vérifie **EmailJS > Email History**, les spams et la connexion du service Gmail. Si le workflow est rouge, le détail exact du refus EmailJS apparaît dans les logs.
