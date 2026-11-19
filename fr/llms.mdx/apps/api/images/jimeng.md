# Jimeng / génération d’images Volcengine Ark

## Aperçu

L’interface de génération d’images de Volcengine Ark utilise la série Seedream (`doubao-seedream-*`) pour produire des images à partir de texte ou d’images de référence. Une requête est soumise une fois et renvoie `data[]` de façon synchrone ; certains modèles prennent aussi en charge la génération en flux ou par lots.

| Ce que vous voulez faire                     | Entrée                                       | Sortie           | Endpoint                                                           |
| -------------------------------------------- | -------------------------------------------- | ---------------- | ------------------------------------------------------------------ |
| Générer une image à partir de texte          | `prompt`                                     | Nouvelle image   | `POST https://ark.cn-beijing.volces.com/api/v3/images/generations` |
| Générer ou modifier à partir d’une référence | `prompt` + `image`                           | Nouvelle image   | Idem                                                               |
| Générer plusieurs images par lots            | `prompt` + paramètres de génération par lots | Plusieurs images | Idem                                                               |

## Concepts clés

* **`size` a deux écritures** \: un palier de résolution (par exemple `2K`) ou des pixels explicites (par exemple `2048x2048`). Le palier est un préréglage du modèle et ne correspond pas à une largeur et une hauteur fixes ; à palier égal, les dimensions réelles dépendent du modèle et de la description du cadre dans le prompt.
* **L’image de référence va dans `image`** \: il peut s’agir d’une URL HTTP(S) ou de `data:image/...;base64,...`. Un tableau active plusieurs références, dont la limite varie selon le modèle.
* **`watermark` est activé par défaut** \: avec `true` par défaut, une mention « Généré par IA » est ajoutée à l’image ; pour une sortie sans filigrane, passez explicitement `false` et vérifiez que l’usage respecte les exigences applicables d’identification du contenu synthétique.
* **Retour synchrone** \: une requête ordinaire attend directement `data[]`. `stream` n’est ouvert qu’à certains modèles comme Seedream 5.0 lite, 4.5 et 4.0 ; ajouter un paramètre de flux ne transforme pas les autres modèles en tâches asynchrones.
* **Facturation à l’image** \: la facturation dépend du nombre d’images générées. La sortie par lots de `sequential_image_generation` est cumulée selon le nombre réel d’images produites, et les échecs sont renvoyés séparément dans `data[].error`.

## Spécifications et capacités

| ID de modèle                      | Paliers `size` et limites                                            | Images de référence | Format de sortie                                                   |
| --------------------------------- | -------------------------------------------------------------------- | ------------------- | ------------------------------------------------------------------ |
| `doubao-seedream-5-5-261028`      | `1K`, `1.5K`, `2K` ou `WxH` ; pixels 921600–4624220, rapport 1/16–16 | 10 images au plus   | `url` / `b64_json` ; `png` par défaut, `jpeg` aussi pris en charge |
| `doubao-seedream-5-0-lite-260128` | `2K`, `3K`, `4K` ou `WxH` ; pixels 3686400–16777216, rapport 1/16–16 | 14 images au plus   | `url` / `b64_json` ; `png` / `jpeg`                                |
| `doubao-seedream-4-5-251128`      | `2K`, `4K` ou `WxH` ; pixels 3686400–16777216, rapport 1/16–16       | 14 images au plus   | `url` / `b64_json` ; `png` / `jpeg`                                |
| `doubao-seedream-4-0-250828`      | `1K`, `2K`, `4K` ou `WxH` ; pixels 921600–16777216, rapport 1/16–16  | 14 images au plus   | `url` / `b64_json` ; `png` / `jpeg`                                |

La limite de pixels s’entend en pixels totaux ; par exemple, 16777216 pixels correspondent à 4096×4096. Les ID de modèle évoluent avec les versions ; avant l’appel, référez-vous au catalogue de modèles Volcengine Ark et à [Modèles et prix](https://api.dwchainless.com/fr/pricing/) ; `model` peut aussi recevoir un ID de point d’accès d’inférence (`ep-...`).

## Flux d’appel

1. **Préparer la clé** \: créez une clé API dans la console Volcengine Ark ; l’en-tête de requête utilise `Authorization: Bearer $ARK_API_KEY`.
2. **Choisir le modèle et les dimensions** \: vérifiez les paliers `size` ou la plage de pixels acceptés par le modèle, et décidez si une image de référence est nécessaire.
3. **Envoyer une requête JSON** \: soumettez à `/api/v3/images/generations` `model` et `prompt`, en ajoutant selon les besoins `image`, `size`, `response_format` et `watermark`.
4. **Lire `data[]`** \: si `response_format` vaut `url`, prenez `data[].url` (valide 24 heures) ; s’il vaut `b64_json`, décodez `data[].b64_json`.
5. **Enregistrer et vérifier** \: vérifiez que le fichier s’ouvre, ainsi que ses dimensions et son contenu réels ; en génération par lots, contrôlez chaque `data[].error` au lieu de regarder seulement le statut HTTP.
6. **Vérifier le coût** \: confirmez le modèle, le nombre d’images et la facturation dans le journal d’utilisation ; une sortie par lots est comptée selon le nombre d’images réellement réussies.

## Appel simulé

Les messages suivants sont indicatifs et ne proviennent pas d’un compte réel ; les URL et le Base64 sont tronqués et les valeurs ne représentent pas les prix actuels.

Requête \:

```json
{
  "model": "doubao-seedream-5-5-261028",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "size": "2K",
  "response_format": "url",
  "watermark": true
}
```

Réponse de succès (synchrone) \:

```json
{
  "created": 1763366400,
  "model": "doubao-seedream-5-5-261028",
  "data": [
    {
      "url": "https://example.com/generated-image.png",
      "size": "2048x2048",
      "output_format": "png"
    }
  ]
}
```

En l’absence d’image générée, une `error` de premier niveau est renvoyée ; en génération par lots, si une image échoue, l’élément en échec est signalé dans `data[].error` avec `code` et `message`.

## Accès et sessions

* **URL de base** \: `https://ark.cn-beijing.volces.com/api/v3`.
* **Authentification** \: `Authorization: Bearer $ARK_API_KEY`. Placez la clé uniquement dans l’en-tête, jamais dans le prompt ni le code source.
* **Différences avec OpenAI Images** \: le chemin est `/api/v3/images/generations` et non `/v1/images/generations` ; il n’y a pas de paramètre `quality` ; `size` accepte directement les paliers `1K` et `2K` ; la réponse renvoie `data[].url` ou `data[].b64_json`.
* **Appel via la passerelle de ce site** \: remplacez l’adresse par `https://api.dwchainless.com/v1/images/generations` et utilisez la clé de ce site ; la transmission du corps de requête à l’identique et la disponibilité des ID de modèle dépendent du canal et de [Modèles et prix](https://api.dwchainless.com/fr/pricing/).
* **Délai d’expiration** \: une génération synchrone peut durer des dizaines de secondes ; le délai côté client doit être nettement supérieur à celui d’une requête textuelle ordinaire. Après expiration, consultez d’abord le journal d’appels pour savoir si une image et un coût ont été produits, avant de décider d’un nouvel essai.
* **Lots et flux** \: `sequential_image_generation` et `stream` ne sont pris en charge que par certains modèles ; avec les deux activés, validez sur l’événement de fin final ou sur `data[]` complet, car un résultat intermédiaire n’est pas une image terminée.

## Références officielles

* [API de génération d’images Volcengine Ark](https\://docs.volcengine.com/docs/82379/1541523)
* [URL de base et authentification Volcengine Ark](https\://docs.volcengine.com/docs/ark/base-url-and-authentication)
* [Génération et édition d’images de la série Seedream](https\://docs.volcengine.com/docs/lake-ai-service/image-generation-and-editing-doubao-seed-ream-series-models?lang=en)