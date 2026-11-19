# Génération d’images xAI Grok

## Aperçu

L’interface de génération d’images de xAI Grok reprend le chemin et l’enveloppe de réponse d’OpenAI Images, mais ses paramètres de requête sont des champs natifs xAI \: `aspect_ratio` et `resolution` définissent le cadre, et non `size`. Le retour est synchrone par défaut, ou vous pouvez activer `deferred` puis interroger la tâche.

| Ce que vous voulez faire                           | Entrée                      | Sortie                           | Endpoint                                          |
| -------------------------------------------------- | --------------------------- | -------------------------------- | ------------------------------------------------- |
| Générer une image à partir de texte                | `prompt`                    | Nouvelle image                   | `POST https://api.x.ai/v1/images/generations`     |
| Générer plusieurs images en une fois               | `prompt` + `n` (1–10)       | Plusieurs images                 | Idem                                              |
| Générer en arrière-plan puis récupérer le résultat | `prompt` + `deferred: true` | `request_id`, puis interrogation | Idem, interrogation `GET /v1/images/{request_id}` |
| Modifier une image existante                       | `prompt` + image            | Image modifiée                   | `POST https://api.x.ai/v1/images/edits`           |

## Concepts clés

* **`aspect_ratio` remplace `size`** \: l’interface n’accepte pas `size` ni `style` d’OpenAI. Le cadre est contrôlé par `aspect_ratio`, avec notamment `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `2:3`, `3:2`, `21:9` et `auto`.
* **`resolution` contrôle le palier de résolution** \: `1k` ou `2k`, avec `1k` par défaut. C’est un palier, pas une valeur en pixels ; à palier égal, les dimensions réelles dépendent de `aspect_ratio`.
* **`quality` ne s’applique qu’aux modèles 2.0** \: valeurs possibles `low`, `medium`, `auto` ; `auto` est actuellement traité comme `low` à la génération et comme `medium` à l’édition.
* **Synchrone par défaut, asynchrone avec `deferred`** \: une requête synchrone renvoie directement `data[]` ; avec `deferred: true`, la réponse renvoie immédiatement un `request_id`, puis interrogez `GET /v1/images/{request_id}`. Les tâches différées ne prennent en charge que `response_format: "url"` et le résultat est conservé 24 heures.
* **Les URL sont temporaires** \: avec `response_format` à `url` (par défaut), l’adresse de l’image renvoyée expire ; téléchargez rapidement pour une conservation durable, ou utilisez `b64_json`.
* **Facturation à l’image** \: `n` désigne le nombre d’images générées par requête, de 1 à 10. `usage.cost_in_usd_ticks` dans la réponse donne les informations de coût de cette requête ; le règlement réel suit la facturation de ce site.

## Spécifications et capacités

| ID de modèle             | Palier de résolution | Rapport d’aspect                                                                                                           | Images de référence                                                                                   | Format de retour    |
| ------------------------ | -------------------- | -------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------- |
| `grok-imagine-image-2.0` | `1k`, `2k`           | `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `3:2`, `2:3`, `2:1`, `1:2`, `19.5:9`, `9:19.5`, `20:9`, `9:20`, `21:9`, `5:2`, `auto` | L’interface de génération n’accepte pas d’image de référence ; l’édition passe par `/v1/images/edits` | `url` ou `b64_json` |

`grok-2-image` est un ancien nom de modèle ; la documentation officielle actuelle utilise `grok-imagine-image-2.0`. Avant l’appel, confirmez dans [Modèles et prix](https://api.dwchainless.com/fr/pricing/) l’ID de modèle réellement fourni par le canal de ce site, sans reprendre directement les noms d’anciens tutoriels.

## Flux d’appel

1. **Préparer la clé** \: créez une clé dans la console xAI ; l’en-tête de requête utilise `Authorization: Bearer $XAI_API_KEY`.
2. **Vérifier le modèle** \: contrôlez `grok-imagine-image-2.0` ou le modèle équivalent du canal dans [Modèles et prix](https://api.dwchainless.com/fr/pricing/).
3. **Choisir le cadre** \: définissez `aspect_ratio` et `resolution` ; n’envoyez pas `size`.
4. **Envoyer la requête** \: soumettez un JSON à `/v1/images/generations`. Si une durée longue est attendue, ajoutez `deferred: true`.
5. **Lire le résultat** \: pour une réponse synchrone, prenez `data[].url` ou `data[].b64_json` ; pour une tâche différée, attendez `done` par interrogation avant de lire `data[]`.
6. **Enregistrer et vérifier** \: téléchargez l’image avant l’expiration de l’URL, vérifiez que le fichier s’ouvre, ses dimensions et son contenu, puis contrôlez le journal d’utilisation.

## Appel simulé

Les messages suivants sont indicatifs et ne proviennent pas d’un compte réel ; les URL et valeurs de coût sont tronquées ou données à titre d’exemple.

Requête synchrone \:

```json
{
  "model": "grok-imagine-image-2.0",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "n": 1,
  "aspect_ratio": "1:1",
  "resolution": "1k",
  "response_format": "url"
}
```

Réponse de succès synchrone \:

```json
{
  "data": [
    {
      "url": "https://imgen.x.ai/example/image.jpeg",
      "mime_type": "image/jpeg"
    }
  ],
  "usage": {
    "cost_in_usd_ticks": 40000
  }
}
```

Requête de tâche différée \:

```json
{
  "model": "grok-imagine-image-2.0",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "n": 1,
  "aspect_ratio": "1:1",
  "resolution": "1k",
  "deferred": true
}
```

Réponse indicative après soumission \:

```json
{
  "request_id": "req_example_01"
}
```

Réponse indicative une fois l’interrogation terminée (HTTP 200 ; 202 pendant le traitement, et `error.code` avec `error.message` en cas d’échec) \:

```json
{
  "data": [
    {
      "url": "https://imgen.x.ai/example/image.jpeg",
      "mime_type": "image/jpeg"
    }
  ],
  "usage": {
    "cost_in_usd_ticks": 40000
  }
}
```

## Accès et sessions

* **URL de base** \: `https://api.x.ai/v1`. Les endpoints de génération et d’édition sont respectivement `/v1/images/generations` et `/v1/images/edits`.
* **Authentification** \: `Authorization: Bearer $XAI_API_KEY`. Le SDK OpenAI peut réutiliser `base_url` défini sur `https://api.x.ai/v1`, mais les champs de requête suivent toujours la documentation xAI.
* **Différences avec OpenAI** \: le chemin et l’enveloppe `data[]` sont similaires, mais `size` et `style` ne sont pas pris en charge ; utilisez `aspect_ratio`, `resolution` et `quality`. La limite de `n` est 10.
* **Tâches différées** \: `deferred` ne prend en charge que la sortie URL ; après soumission, interrogez `GET /v1/images/{request_id}` ; le résultat est conservé 24 heures et doit être régénéré après expiration.
* **Appel via la passerelle de ce site** \: remplacez l’adresse par `https://api.dwchainless.com/v1/images/generations` et utilisez la clé de ce site ; la transmission de l’ID de modèle et des paramètres dépend du canal.
* **Délai d’expiration** \: une génération synchrone se termine généralement dans une requête, mais le client doit prévoir un délai suffisant ; pour une durée imprévisible ou une génération par lots, privilégiez `deferred` et ne renvoyez pas aveuglément après expiration.

## Références officielles

* [Capacité de génération d’images xAI](https\://docs.x.ai/developers/model-capabilities/images/generation)
* [Référence de l’API REST xAI Images](https\://docs.x.ai/developers/rest-api-reference/inference/images)