# API d’images Gemini

Cette section utilise le format natif Gemini GenerateContent `contents/parts`. Génération et édition exigent un modèle capable de produire des images ; ajouter un paramètre ne donne pas cette capacité à un modèle textuel. Commencez par une tâche à une seule image avant d’augmenter la quantité ou d’utiliser un agent.

## Format et paramètres de requête

| API                        | Format de requête                                   | Paramètres principaux                                                                       | Documentation détaillée                                           |
| -------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| Texte vers image           | `POST /v1beta/models/{model}:generateContent`, JSON | `contents[].parts[].text`, `generationConfig`                                               | [Paramètres de génération et code en quatre langages](/simidoc/fr/apps/api/images/gemini/generate) |
| Édition / image vers image | Même point de terminaison `generateContent`         | `text` et Part d’image distincte \: `inlineData` ou `fileData` pris en charge par le modèle | [Paramètres d’édition et code en quatre langages](/simidoc/fr/apps/api/images/gemini/edits)        |
| Compréhension d’image      | Même point de terminaison `generateContent`         | Image et question ; objectif \: analyse textuelle, pas sortie d’image                       | [Compréhension des médias Gemini](/simidoc/fr/apps/api/chat/gemini-media)        |

Pour générer, fournissez seulement du texte ; pour modifier, ajoutez des références et distinguez les éléments à conserver ou changer. Changement de style, remplacement du fond et composition multi-image sont des objectifs d’édition, pas une route distincte `/images/edits`. Les champs `contents`, `candidates` de GenerateContent ne sont pas les champs `input`, `steps`, `response_format` d’Interactions ; ne les mélangez pas.

### Spécifications de l’image

Si le protocole et le modèle le permettent, réglez le rapport avec `generationConfig.imageConfig.aspectRatio`, par exemple `1:1`, et la résolution avec `generationConfig.imageConfig.imageSize`, selon les valeurs acceptées, comme `1K`, `2K`, `4K`. Tous les modèles d’image Gemini ne les prennent pas en charge et elles ne se remplacent pas par `size` d’OpenAI. Pixels réels et rapports disponibles dépendent de la version du modèle ; le MIME réel détermine le format.

| Trois paliers par image de ce site | Côté le plus long demandé | Exemple en pixels |
| ---------------------------------- | ------------------------- | ----------------- |
| 1K                                 | ≤ 1024 pixels             | 1024×1024         |
| 2K                                 | > 1024 et ≤ 2048 pixels   | 1536×1024         |
| 4K                                 | > 2048 pixels             | 2560×1440         |

Ce tableau décrit la facturation de certains modèles du site, pas une définition universelle de Google pour les noms de résolution. Il s’applique seulement si [Modèles et prix](https://api.dwchainless.com/fr/pricing/) indique ces règles, pas aux prix en tokens ou à d’autres tarifs. Une résolution supérieure ne garantit pas l’exactitude du texte ou des détails. Si les spécifications demandées ne sont pas prises en charge, signalez une erreur sans réduire silencieusement le niveau. Voir la [vue d’ensemble des spécifications et tarifs](/simidoc/fr/apps/api/images).

## Champs de réponse

| Champ                                          | Signification et traitement                                                                                                |
| ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `candidates[]`                                 | Liste des candidats ; aucun résultat d’image utilisable en cas de filtrage ou d’échec.                                     |
| `candidates[].content.parts[]`                 | Parcourez textes et images dans l’ordre, sans supposer que le premier élément est une image.                               |
| `parts[].inlineData.mimeType` / `.data`        | MIME réel et Base64 brut ; choisissez l’extension selon le MIME et décodez.                                                |
| `parts[].thought` / `.thoughtSignature`        | Une image intermédiaire de raisonnement n’est pas finale ; conservez les signatures opaques pour les éditions successives. |
| `candidates[].finishReason` / `promptFeedback` | Vérifiez la fin normale et le filtrage ; HTTP 200 ne suffit pas pour annoncer un succès.                                   |
| `usageMetadata`                                | Utilisation facultative ; les règles tarifaires applicables et journaux déterminent le coût.                               |

## Exemples d’appel

### Préparer la configuration

Créez une clé dans [Gestion des clés API](https://api.dwchainless.com/keys), copiez dans [Modèles et prix](https://api.dwchainless.com/fr/pricing/) l’ID complet d’un modèle disponible avec sortie d’image GenerateContent, puis vérifiez groupe, crédit et édition. Variables à renseigner \:

| Variable       | Utilité                                                                                                                                     |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `API_KEY`      | Obligatoire ; définissez-la directement dans l’exemple, jamais les consignes, le code, les captures ou Git.                                 |
| `MODEL`        | Obligatoire ; modèle Gemini d’image utilisé comme nom de modèle dans le chemin.                                                             |
| `API_URL`      | URL complète de la requête ; les exemples utilisent la passerelle `https://api.dwchainless.com`.                                            |
| `IMAGE_BASE64` | Remplacez par le Base64 brut d’une image autorisée (sans préfixe `data:`) ; le format et les dimensions doivent respecter le modèle choisi. |

Les [exemples de génération](/simidoc/fr/apps/api/images/gemini/generate) et d’[édition](/simidoc/fr/apps/api/images/gemini/edits) proposent Python, Node.js, curl et Go. Choisissez un langage et effectuez un appel sans streaming. Enregistrez Python dans `generate.py` ou `edit.py`, puis exécutez `python3 generate.py` ou `python3 edit.py`. Les exemples Node.js utilisent un await de premier niveau (ESM) \: enregistrez-les dans `generate.mjs` ou `edit.mjs`, puis exécutez `node generate.mjs` ou `node edit.mjs`.

### Démo de génération avec un agent

L’agent doit exécuter des scripts locaux et examiner les réponses. Ce processus n’installe aucun Skill distant et ne modifie pas la connexion existante ; un client uniquement textuel ne peut pas l’exécuter directement.

```text
Read this Gemini protocol page and the GenerateContent image generation reference first.
Use the configured SimiRouter request URL in API_URL (default gateway
https://api.dwchainless.com) and MODEL. Set API_KEY directly in the example; never
print, paste, commit, or store it in source files. For this one approved task, call POST
/v1beta/models/{model}:generateContent once, non-streaming, Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. with a text Part describing a calm blue library with a small robot reading,
watercolor, no lettering. Request one image; use imageConfig aspectRatio=1:1 and
imageSize=1K only if the model supports them. Do not invent an n parameter or mix
Interactions fields into GenerateContent. After the response, read only completed,
non-thought inlineData from parts; decode the Base64 in memory and report any unmet
requirement; do not write an image file. Do not switch providers/models/billing groups,
increase size/count, write files, install remote skills, or retry an ambiguous failure
without approval. Report a redacted error instead of false success.
```

### Démo d’édition avec un agent

Ne lisez que les références autorisées ; vérifiez données personnelles et secrets commerciaux. Les éditions successives nécessitent le contexte complet renvoyé par le modèle \: ne supprimez pas arbitrairement les signatures. La conservation demandée ne garantit pas une identité pixel par pixel.

```text
Read this Gemini protocol page and its image editing reference first. Use the existing
API_KEY, MODEL and configured SimiRouter request URL; never reveal credentials or change
the existing connection. Read only the authorized local image, encode it as pure Base64,
and put it in IMAGE_BASE64. Submit its inlineData Part alongside the text instruction
through POST /v1beta/models/{model}:generateContent. Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. Keep the subject and layout; change only the background to pale blue. Request one
image, non-streaming; use aspectRatio=1:1 and imageSize=1K only if supported. Do not use
OpenAI multipart or mask fields. After the response, read only completed, non-thought
inlineData from parts; decode the Base64 in memory and report any unmet requirement; do
not write an image file. Preserve opaque signatures for later turns. Do not upload
unrelated files, overwrite results, change model/size/count/provider, install remote
skills, or retry automatically. Ask before any additional paid request.
```

## Enregistrement et critères de fin

* Vérifiez le statut HTTP, `finishReason` et le contenu d’image. Texte seul, filtrage, image finale absente ou format incompatible signifient une tâche non terminée ; ne sauvegardez pas le JSON entier comme image.
* Décodez strictement Base64, vérifiez format réel et MIME, puis ouverture, dimensions et contenu. Préservez les fichiers existants ; nettoyez seulement les sorties invalides créées par cet appel.
* Utilisez `streamGenerateContent?alt=sse` seulement si le modèle le permet ; un fragment quelconque n’est pas une image finale. `generateContent` renvoie le résultat complet de façon synchrone, sans ID universel à interroger ; Google Batch est un service distinct.
* Enregistrez séparément les images des différents éléments et vérifiez le nombre terminé. Une consigne « une image » ne garantit pas exactement une sortie pour chaque modèle. Sans autorisation, ne rappelez pas l’API pour compléter la quantité.

## Erreurs, nouvelles tentatives et coût

Pour 400, vérifiez modèle, champs et référence ; 401/403, les droits de la clé ; 404, modèle et chemin ; 429, crédit et limites. Après expiration, 5xx ou absence de résultat final complet, consultez journaux et fichiers avant toute action, sans renvoi automatique. Rapportez seulement une erreur expurgée et l’ID de requête, jamais la clé, le Base64 complet ou des images privées.

Les générations et éditions réelles peuvent être facturées. Confirmez modèle, spécifications, quantité et sortie avant l’appel. Un palier supérieur, davantage d’images, un nouveau modèle ou une nouvelle tentative exigent une confirmation. Chaque requête parallèle a ses limites, son délai et son coût ; la présence de données d’utilisation n’implique pas une facturation en tokens. Les prix actuels et journaux font foi.

## Références officielles

* [API Google GenerateContent](https\://ai.google.dev/api/generate-content)
* [Génération et édition d’images Google](https\://ai.google.dev/gemini-api/docs/image-generation)