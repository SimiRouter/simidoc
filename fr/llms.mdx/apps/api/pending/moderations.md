# Modération

## Description de l’interface

`POST https://api.openai.com/v1/moderations` évalue de manière synchrone les catégories de sécurité du texte ou des images avec `Authorization: Bearer $OPENAI_API_KEY`. Routage, modèle et autorisations SimiRouter doivent être confirmés séparément ; les exemples ci-dessous utilisent directement OpenAI officiel.

Les résultats sont des signaux de risque, pas une conclusion de conformité juridique ni une garantie d’absence de faux négatifs. Les catégories prises en charge peuvent différer entre images et texte \: examinez category\_applied\_input\_types et ne déduisez pas l’innocuité d’une entrée non prise en charge.

## Paramètres de requête

| Champ                   | Type                           | Obligatoire  | Description                                                                                               |
| ----------------------- | ------------------------------ | ------------ | --------------------------------------------------------------------------------------------------------- |
| model                   | string                         | Non          | Par exemple omni-moderation-latest ; fixer un modèle précis peut réduire l’effet des changements d’alias. |
| input                   | string / string\[] / object\[] | Oui          | Texte ou éléments de contenu multimodal.                                                                  |
| input\[].type           | string                         | Conditionnel | text ou image\_url.                                                                                       |
| input\[].text           | string                         | Conditionnel | Texte à modérer.                                                                                          |
| input\[].image\_url.url | string                         | Conditionnel | URL d’image ou data URL respectant les exigences d’entrée du modèle.                                      |

## Valeur de retour

| Champ                                    | Description                                                                |
| ---------------------------------------- | -------------------------------------------------------------------------- |
| `id` / `model`                           | Identifiant de requête et modèle de modération.                            |
| `results[].flagged`                      | Indique si au moins une catégorie signale un risque.                       |
| `results[].categories`                   | Booléens par catégorie.                                                    |
| `results[].category_scores`              | Scores de catégorie ; ni jugement humain ni seuil invariant entre modèles. |
| `results[].category_applied_input_types` | Types d’entrée applicables à chaque catégorie.                             |

```json
{"id":"modr_example","model":"omni-moderation-latest","results":[{"flagged":false,"categories":{},"category_scores":{},"category_applied_input_types":{}}]}
```

L’exemple omet les clés de catégorie ; la réponse réelle contient leur détail. Conservez les éléments de preuve nécessaires, sans stocker indéfiniment tous les textes originaux des utilisateurs.

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

Définissez `OPENAI_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/moderations'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'omni-moderation-latest', 'input': '这是一段需要进行安全审核的示例文本。'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/moderations";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.openai.com/v1/moderations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "omni-moderation-latest",
        "input": "这是一段需要进行安全审核的示例文本。"
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/moderations", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

| Statut HTTP           | Sens et traitement                                                                                                    |
| --------------------- | --------------------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Champs, média ou paramètres de modèle invalides ; corrigez avant de soumettre.                                        |
| 401                   | Clé API absente, invalide ou expirée.                                                                                 |
| 403                   | Projet ou modèle non autorisé.                                                                                        |
| 404                   | Modèle ou route introuvable ; vérifiez l’adresse et le projet propriétaire.                                           |
| 413 / 415             | Fichier trop volumineux ou type de média non pris en charge.                                                          |
| 429                   | Limite de débit ou de quota ; distinguez le manque de crédit d’une limitation temporaire.                             |
| 500 / 502 / 503 / 504 | Erreur du service ou de l’amont \: conservez l’ID, examinez le corps de la réponse, puis décidez s’il faut réessayer. |

Dans le corps d’erreur, `error.message`, `error.type`, `error.code` précisent mieux la cause que le statut HTTP. Ne prenez pas le corps d’erreur pour un résultat de modération.

## Références officielles

[OpenAI Create moderation](https\://developers.openai.com/api/reference/resources/moderations/methods/create).