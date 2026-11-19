# API d’images native Qwen

Cette section utilise le corps de requête natif Qwen, mais appelle toujours la passerelle de ce site \: `API_URL` vaut `https://api.dwchainless.com/v1/images/...` et l’authentification utilise la `API_KEY` de ce site. Les paramètres reprennent `model`, `input.messages`, `parameters`, et la réponse est toujours au format `data[]` ; commencez par un appel à une seule image avant d’augmenter la quantité ou d’utiliser un agent.

## Format et paramètres de requête

| API                        | Format de requête                   | Paramètres principaux                                         | Documentation détaillée                                              |
| -------------------------- | ----------------------------------- | ------------------------------------------------------------- | -------------------------------------------------------------------- |
| Texte vers image           | `POST /v1/images/generations`, JSON | `model`, `input.messages[].content[].text`, `parameters`      | [Paramètres de génération et code en quatre langages](/simidoc/fr/apps/api/images/qwen/generations) |
| Édition / image vers image | `POST /v1/images/edits`, JSON       | `content[]` contenant `image` et un `text`, avec `parameters` | [Paramètres d’édition et code en quatre langages](/simidoc/fr/apps/api/images/qwen/edits)           |

Les exemples de la série 2.0 de cette page placent dans `input.messages` un message `user` ; le texte décrit le sujet, la composition, le style et le texte à afficher. Pour l’édition, ajoutez une URL d’image autorisée ou une data URL prise en charge par le modèle. Remplacement de fond, changement de style, retouche du texte dans l’image et fusion multi-image sont des objectifs d’édition ; ils n’ajoutent pas de champ multipart OpenAI et ne garantissent pas la conservation pixel par pixel.

### Caractéristiques des images

Les dimensions se règlent dans `parameters.size`, au format `width*height`, par exemple `"2048*2048"`, et non `"2048x2048"` ni `"2K"`. La série 2.0 contraint les dimensions par une plage de pixels totaux ; vérifiez selon le modèle les images d’entrée, les dimensions et les limites de sortie ; une limite de pixels totaux n’équivaut pas à une limite du côté le plus long.

| Trois paliers de facturation par image de ce site | Côté le plus long demandé | Exemple en pixels |
| ------------------------------------------------- | ------------------------- | ----------------- |
| 1K                                                | ≤ 1024 pixels             | 1024×1024         |
| 2K                                                | > 1024 et ≤ 2048 pixels   | 1536×1024         |
| 4K                                                | > 2048 pixels             | 2560×1440         |

Ce tableau explique uniquement les paliers de facturation de certains modèles de ce site, et non l’acceptation des paramètres `1K` / `2K` / `4K` par le modèle. Les appels via ce site sont facturés selon [Modèles et prix](https://api.dwchainless.com/fr/pricing/) ; consultez aussi la [vue d’ensemble des caractéristiques et de la facturation](/simidoc/fr/apps/api/images). Un plus grand nombre de pixels ne garantit pas des textes et détails corrects ; une spécification non prise en charge doit produire une erreur plutôt qu’un remplacement silencieux.

## Champs de réponse

| Champ                   | Signification et traitement                                                                                    |
| ----------------------- | -------------------------------------------------------------------------------------------------------------- |
| `created`               | Horodatage de génération de la réponse.                                                                        |
| `data[].url`            | URL de l’image finale ; sa durée de validité dépend du canal, téléchargez-la rapidement.                       |
| `data[].b64_json`       | Certains canaux renvoient du Base64 pur ; le cas échéant, décodez-le directement pour l’enregistrer.           |
| `data[].revised_prompt` | Consigne réécrite par le canal ; peut être absente.                                                            |
| `error` / `message`     | Code et description d’erreur ; même en cas de succès HTTP, vérifiez l’erreur métier et l’existence de l’image. |

Le corps de requête est la structure native Qwen et la réponse utilise toujours `data[]`. Ne reprenez pas les protocoles `prompt`, multipart ou `task_id` asynchrone d’autres canaux ; l’identifiant de modèle doit correspondre exactement au nom réellement fourni par le canal de ce site.

## Exemples d’appel

### Préparer la configuration

Vérifiez les modèles disponibles et le solde dans [Modèles et prix](https://api.dwchainless.com/fr/pricing/), puis utilisez une clé créée sur ce site. `API_URL` pointe toujours vers la passerelle de ce site ; aucun ID d’espace de travail, domaine régional ni clé officielle Model Studio n’est nécessaire.

| Configuration | Utilité                                                                                                                                        |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `API_KEY`     | Clé de ce site ; renseignez-la directement dans l’exemple, sans la coller dans les consignes, le code, les captures ou Git.                    |
| `API_URL`     | Adresse complète de requête de la passerelle de ce site, par exemple `https://api.dwchainless.com/v1/images/generations`.                      |
| `model`       | Les exemples utilisent `qwen-image-2.0-pro` ; vérifiez d’abord que le canal de ce site prend en charge ce modèle et les capacités nécessaires. |
| `IMAGE_URL`   | Adresse HTTP(S) d’image autorisée et accessible depuis le cloud pour l’exemple d’édition, et non un chemin local ou localhost.                 |

Les [exemples de génération](/simidoc/fr/apps/api/images/qwen/generations) et d’[édition](/simidoc/fr/apps/api/images/qwen/edits) proposent Python, Node.js, curl et Go. Le code actuel envoie une requête et affiche le JSON, **sans télécharger l’image automatiquement**. Enregistrez le code Python sous `generate.py` / `edit.py` et lancez `python3 generate.py` / `python3 edit.py` ; pour Node.js, utilisez `generate.mjs` / `edit.mjs`, puis `node generate.mjs` / `node edit.mjs`. Configurez l’environnement d’exécution et les variables comme demandé sur chaque page, demandez d’abord une seule image, puis enregistrez le fichier réel pointé par l’URL comme indiqué dans la section suivante.

### Démo de génération avec un agent

L’agent doit pouvoir exécuter des scripts locaux, effectuer des requêtes réseau et examiner les résultats ; cette page n’est pas une instruction d’installation de Skill et n’ajoute pas ces capacités à un client purement textuel.

```text
Read this Qwen image protocol page and its generation reference first. Use the
existing API_KEY and API_URL from this site's gateway; never print, paste, commit,
or store the key in source files. Use the documented qwen-image-2.0-pro model only
after checking availability and pricing. For this one approved request, POST once
to /v1/images/generations with the native Qwen body: one user message, one text
content item, parameters.n=1 and size=1024*1024 if supported. Image brief: a calm
blue library with a small robot reading, watercolor illustration, no lettering.
Print the returned JSON and inspect data[].url or data[].b64_json; report the final
image URL without forwarding the API key. JSON or a URL alone is not a saved image.
Do not switch model/provider, increase size/count, write files, install remote
skills, or automatically retry an error or timeout. Ask before another paid request.
```

### Démo d’édition avec un agent

N’utilisez que des images dont le traitement et le téléversement sont autorisés ; vérifiez d’abord les données personnelles et secrets commerciaux. L’exemple actuel lit une URL et ne publie pas automatiquement de fichier local vers un autre service.

```text
Read this Qwen image protocol page and its editing reference first. Use the existing
API_KEY and API_URL from this site's gateway; never reveal the key or switch the
existing connection. Verify qwen-image-2.0-pro supports the edit. Use only the
authorized cloud-readable image in IMAGE_URL; do not upload unrelated local files or
publish a file. POST once to /v1/images/edits with the native Qwen body: one user
message containing that image item and one text instruction: keep the subject and
layout; change only the background to pale blue. Set parameters.n=1 and size=1024*1024
only if supported. Do not use OpenAI multipart or mask fields. Check the completed
business result, inspect data[].url or data[].b64_json without forwarding the API key,
and report it. Do not write files, change model/size/count/provider, install remote
skills, or retry automatically. If any step fails or the requested edit is not met,
report a redacted error instead of claiming success.
```

## Enregistrement et critères de fin

* La réponse synchrone n’est pas une tâche à interroger ; cette section n’utilise ni `task_id` ni `X-DashScope-Async`. Ne mélangez pas les protocoles asynchrones d’autres modèles et ne prenez pas les événements de flux pour critère de fin.
* Vérifiez les erreurs HTTP et métier, le motif de fin et les éléments d’image réels, puis parcourez les URL. Leur validité est limitée \: téléchargez rapidement. Un JSON, une adresse ou la conclusion orale d’un agent ne prouve pas que le fichier est enregistré.
* Au téléchargement, vérifiez le statut, le contenu et l’en-tête du fichier ; ne renommez pas une page d’erreur en PNG. N’envoyez pas la clé de ce site au domaine de stockage du résultat. Préservez les fichiers existants et, en cas d’échec, ne nettoyez que les sorties invalides créées par cette opération.
* Confirmez que le fichier existe, s’ouvre, et que ses dimensions et son contenu correspondent au besoin, puis vérifiez la requête et le coût dans la facturation ou les journaux d’utilisation de ce site. Contrôlez chaque image séparément, sans rappeler automatiquement l’API pour compléter la quantité.

## Erreurs, nouvelles tentatives et coût

En cas d’erreur de paramètres, vérifiez d’abord `model`, la structure des messages, `size` et l’image d’entrée ; en cas d’erreur d’authentification, la clé de ce site et les droits du modèle ; en cas d’erreur de crédit ou de limitation, l’état du compte. Après expiration, 5xx ou résultat ambigu, consultez d’abord les journaux d’appel et les fichiers existants, sans renvoyer automatiquement la requête, afin d’éviter doublons et doubles débits. Ne rapportez que des erreurs expurgées, jamais la clé, le Base64 complet ou des images privées.

Les générations et éditions réelles peuvent être facturées. Avant l’appel, confirmez le modèle, les dimensions, le nombre d’images et l’emplacement de sortie ; toute augmentation, montée en gamme ou nouvelle tentative exige une nouvelle confirmation. Chaque requête parallèle gère séparément sa limitation, son délai et son coût ; `n` est la quantité d’une requête. La facturation finale suit les règles et factures de ce site.

## Références officielles

* [Génération Qwen-Image](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api)
* [Édition Qwen-Image](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api)