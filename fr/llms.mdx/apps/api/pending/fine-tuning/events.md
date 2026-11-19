# Obtenir les événements d’ajustement fin

Lire par pages les messages de journal et métriques d’entraînement.

**SimiRouter ne prend pas encore en charge cette interface. Référence de l’API officielle OpenAI ; adresse d’appel \: `api.openai.com`, avec une clé du projet OpenAI, pas une clé SimiRouter.**

## Description de l’interface

* **Méthode** \: `GET`
* **Adresse API** \: `/v1/fine_tuning/jobs/{fine_tuning_job_id}/events`
* **Authentification** \: `Authorization: Bearer $OPENAI_API_KEY`
* **Type de requête** \: sans corps.

Renvoie une liste JSON paginée ordinaire, pas un abonnement SSE. Les événements servent au diagnostic ; vérifiez la réussite finale dans [les détails de la tâche](/simidoc/fr/apps/api/pending/fine-tuning/retrieve), champ `status`.

## Paramètres de requête

| Paramètres           | Type           | Obligatoire | Description                                                  |
| -------------------- | -------------- | ----------- | ------------------------------------------------------------ |
| `fine_tuning_job_id` | string, chemin | Oui         | ID de tâche lu par le code dans `OPENAI_FINE_TUNING_JOB_ID`. |

| Paramètres | Type                          | Obligatoire | Description                                    |
| ---------- | ----------------------------- | ----------- | ---------------------------------------------- |
| `after`    | string, paramètre de requête  | Non         | ID du dernier événement de la page précédente. |
| `limit`    | integer, paramètre de requête | Non         | Nombre d’événements par page, 20 par défaut.   |

## Valeur de retour

| Champ               | Type                      | Description                                                                      |
| ------------------- | ------------------------- | -------------------------------------------------------------------------------- |
| `object`            | string                    | Fixé à `list`.                                                                   |
| `has_more`          | boolean                   | Indique une page suivante.                                                       |
| `data`              | array                     | Événements de la page courante.                                                  |
| `data[].id`         | string                    | ID d’événement utilisé pour la pagination.                                       |
| `data[].object`     | string                    | Fixé à `fine_tuning.job.event`.                                                  |
| `data[].created_at` | integer                   | Date de l’événement, horodatage Unix en secondes.                                |
| `data[].level`      | string                    | `info`, `warn` ou `error`.                                                       |
| `data[].message`    | string                    | Description lisible de l’événement.                                              |
| `data[].type`       | string, facultatif        | `message` ou `metrics`.                                                          |
| `data[].data`       | object / null, facultatif | Données supplémentaires ; les champs de métriques dépendent du type d’événement. |

```json
{
  "object": "list",
  "data": [{
    "id": "ft-event-demo",
    "object": "fine_tuning.job.event",
    "created_at": 1793491200,
    "level": "info",
    "message": "Training started",
    "type": "message",
    "data": null
  }],
  "has_more": false
}
```

## Exemples de code

Prérequis \: Python 3, Node.js 20+, curl ou Go 1.20+. Enregistrez chaque exemple dans son fichier `.py`, `.cjs`, `.sh`, `.go` puis exécutez-le.

Définissez `OPENAI_API_KEY` et `OPENAI_FINE_TUNING_JOB_ID`. Pour la page suivante, utilisez l’ID du dernier événement courant comme `after`.

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
    job_id = required("OPENAI_FINE_TUNING_JOB_ID")
    job_id_encoded = urllib.parse.quote(job_id, safe="")
    request = urllib.request.Request(
        f"https://api.openai.com/v1/fine_tuning/jobs/{job_id_encoded}/events?limit=20",
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
      const job_id = required("OPENAI_FINE_TUNING_JOB_ID");
      const jobId = encodeURIComponent(job_id);
      const response = await fetch(`https://api.openai.com/v1/fine_tuning/jobs/${jobId}/events?limit=20`, {
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
    : "${OPENAI_FINE_TUNING_JOB_ID:?请设置 OPENAI_FINE_TUNING_JOB_ID}"
    [[ "$OPENAI_FINE_TUNING_JOB_ID" =~ ^[A-Za-z0-9_:-]+$ ]] || { printf '%s\n' '资源 ID 格式错误' >&2; exit 1; }
    curl "https://api.openai.com/v1/fine_tuning/jobs/${OPENAI_FINE_TUNING_JOB_ID}/events?limit=20" \
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
    	"net/url"
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
    	job_id := required("OPENAI_FINE_TUNING_JOB_ID")
    	target := fmt.Sprintf("https://api.openai.com/v1/fine_tuning/jobs/%s/events?limit=20", url.PathEscape(job_id))
    	req, err := http.NewRequest("GET", target, nil)
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

* [Événements de tâches d’ajustement fin OpenAI](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/list_events)
* [Codes d’erreur OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)