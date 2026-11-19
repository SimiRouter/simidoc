# Lister les fichiers

Consulter par pages les fichiers accessibles du projet OpenAI courant.

**SimiRouter ne prend pas encore en charge cette interface. Référence de l’API officielle OpenAI ; adresse d’appel \: `api.openai.com`, avec une clé du projet OpenAI, pas une clé SimiRouter.**

## Description de l’interface

* **Méthode** \: `GET`
* **Adresse API** \: `/v1/files`
* **Authentification** \: `Authorization: Bearer $OPENAI_API_KEY`
* **Type de requête** \: sans corps.

Renvoie le JSON de la page courante de manière synchrone ; lorsque `has_more=true`, une requête de pagination supplémentaire est nécessaire. Un appel ne renvoie pas automatiquement tous les fichiers.

## Paramètres de requête

| Paramètres | Type                          | Obligatoire | Description                                                        |
| ---------- | ----------------------------- | ----------- | ------------------------------------------------------------------ |
| `after`    | string, paramètre de requête  | Non         | ID du dernier fichier de la page précédente.                       |
| `limit`    | integer, paramètre de requête | Non         | 1 à 10000 éléments par page, 10000 par défaut ; 20 dans l’exemple. |
| `order`    | string, paramètre de requête  | Non         | Tri par date de création \: `asc` ou `desc`, par défaut `desc`.    |
| `purpose`  | string, paramètre de requête  | Non         | Ne renvoie que les fichiers de l’usage indiqué.                    |

## Valeur de retour

| Champ                  | Type          | Description                                               |
| ---------------------- | ------------- | --------------------------------------------------------- |
| `object`               | string        | Type de liste, généralement `list`.                       |
| `data`                 | FileObject\[] | Fichiers de la page courante ; champs décrits ci-dessous. |
| `first_id` / `last_id` | string        | ID des premier et dernier fichiers de la page.            |
| `has_more`             | boolean       | Indique la présence d’une page suivante.                  |

| Champ            | Type                                | Description                                                                                                                              |
| ---------------- | ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `id`             | string                              | ID du fichier pour les requêtes ultérieures.                                                                                             |
| `object`         | string                              | Fixé à `file`.                                                                                                                           |
| `bytes`          | integer / null                      | Taille en octets ; peut être null si pas encore connue.                                                                                  |
| `created_at`     | integer                             | Date de création, horodatage Unix en secondes.                                                                                           |
| `filename`       | string                              | Nom du fichier au téléversement.                                                                                                         |
| `purpose`        | string                              | Usage du fichier, par exemple `fine-tune`, `user_data` ; les résultats générés peuvent utiliser `fine-tune-results` ou d’autres valeurs. |
| `expires_at`     | integer / null, facultatif          | Date d’expiration en secondes Unix ; peut être vide sans politique d’expiration.                                                         |
| `status`         | string, obsolète                    | Ancien champ d’état \: `uploaded`, `processed` ou `error`. Ne remplace pas l’état de traitement du point d’accès consommateur.           |
| `status_details` | string / null, facultatif, obsolète | Ancienne description d’état ; pour les erreurs de validation d’ajustement fin, lisez le champ de tâche `error`.                          |

```json
{
  "object": "list",
  "data": [
    {
      "id": "file-demo",
      "object": "file",
      "bytes": 4096,
      "created_at": 1793491200,
      "filename": "training.jsonl",
      "purpose": "fine-tune",
      "expires_at": null
    }
  ],
  "first_id": "file-demo",
  "last_id": "file-demo",
  "has_more": false
}
```

## Exemples de code

Prérequis \: Python 3, Node.js 20+, curl ou Go 1.20+. Enregistrez chaque exemple dans son fichier `.py`, `.cjs`, `.sh`, `.go` puis exécutez-le.

Définissez `OPENAI_API_KEY`. L’exemple lit les 20 premiers fichiers ; pour la page suivante, passez le `last_id` précédent dans le paramètre `after`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    def required(name):
        value = os.environ.get(name)
        if not value:
            raise SystemExit(f"请设置 {name}")
        return value

    key = required("OPENAI_API_KEY")

    request = urllib.request.Request(
        "https://api.openai.com/v1/files?limit=20&order=desc",
        method="GET",
        data=None,
        headers={"Authorization": "Bearer " + key},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = response.read()
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    print(json.dumps(json.loads(result), ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    function required(name) {
      const value = process.env[name];
      if (!value) throw new Error(`请设置 ${name}`);
      return value;
    }
    async function main() {
      const key = required("OPENAI_API_KEY");

      const response = await fetch("https://api.openai.com/v1/files?limit=20&order=desc", {
        method: "GET",
        headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(120000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(JSON.stringify(await response.json(), null, 2));
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${OPENAI_API_KEY:?请设置 OPENAI_API_KEY}"

    curl "https://api.openai.com/v1/files?limit=20&order=desc" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request GET \
      --header "Authorization: Bearer $OPENAI_API_KEY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"fmt"
    	"io"
    	"log"
    	"net/http"
    	"os"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func required(name string) string {
    	value := os.Getenv(name)
    	if value == "" {
    		log.Fatal("请设置 " + name)
    	}
    	return value
    }
    func main() {
    	key := required("OPENAI_API_KEY")

    	req, err := http.NewRequest("GET", "https://api.openai.com/v1/files?limit=20&order=desc", nil)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	client := &http.Client{Timeout: 120 * time.Second}
    	response, err := client.Do(req)
    	check(err)
    	defer response.Body.Close()
    	result, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, result)
    	}
    	fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

Voici les erreurs HTTP courantes de l’accès direct officiel OpenAI, pas l’état de prise en charge SimiRouter.

| Code HTTP     | Signification                                              | Traitement                                                                                                                                             |
| ------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `400`         | Paramètre, usage de fichier ou état de ressource incorrect | Lisez `error.message` et `error.param`, corrigez puis soumettez de nouveau.                                                                            |
| `401`         | Clé invalide ou absente                                    | Vérifiez la clé OpenAI et son projet.                                                                                                                  |
| `403`         | Accès au projet ou à la ressource interdit                 | Vérifiez les autorisations du projet, de l’organisation et du rôle.                                                                                    |
| `404`         | Fichier, tâche ou modèle introuvable                       | Vérifiez l’ID et utilisez la clé du projet propriétaire.                                                                                               |
| `429`         | Limitation de débit ou crédit insuffisant                  | Distinguez débit et crédit ; attendez progressivement pour le débit et ne répétez pas les soumissions en cas de crédit insuffisant.                    |
| `500` / `503` | Erreur serveur ou indisponibilité temporaire               | Conservez l’ID de requête ; avant de répéter une écriture, vérifiez si la ressource existe déjà pour éviter téléversements ou entraînements en double. |

Les réponses d’échec contiennent généralement `error.message`, `error.type`, `error.param` et `error.code` ; certains champs peuvent être vides.

## Références officielles

* [Liste de fichiers OpenAI](https\://developers.openai.com/api/reference/resources/files/methods/list)
* [Codes d’erreur OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)