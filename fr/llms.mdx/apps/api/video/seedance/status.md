# Consulter une tâche vidéo Seedance

## Description de l’interface

`GET https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/{id}`, authentification `Authorization: Bearer $ARK_API_KEY`. Cette page décrit le protocole officiel Ark, distinct de l’état vidéo général de passerelle.

## Paramètres de requête

| Champ       | Type   | Obligatoire | Description                                                        |
| ----------- | ------ | ----------- | ------------------------------------------------------------------ |
| id (chemin) | string | Oui         | ID cgt- reçu à la création, dans le même compte et la même région. |

Pas de corps JSON. L’ID reste généralement valable 7 jours ; certains nouveaux Draft ont leur propre validité. L’interface de tâches n’est pas une archive permanente.

## Valeur de retour

| Champ                                                   | Description                                                                   |
| ------------------------------------------------------- | ----------------------------------------------------------------------------- |
| `id` / `model`                                          | ID de tâche et version du modèle.                                             |
| `status`                                                | queued, running, succeeded, failed, expired, cancelled.                       |
| `content.video_url`                                     | Lien après réussite, généralement valable 24 heures ; enregistrez rapidement. |
| `content.last_frame_url`                                | URL de dernière trame si demandée et prise en charge.                         |
| `error.code` / `error.message`                          | Motif d’échec, éventuellement vide.                                           |
| `created_at` / `updated_at`                             | Horodatage Unix en secondes.                                                  |
| `usage`                                                 | Comptabilisation de la tâche selon le modèle.                                 |
| `duration` / `ratio` / `resolution` / `framespersecond` | Caractéristiques réelles de la vidéo.                                         |
| `seed` / `service_tier` / `execution_expires_after`     | Configuration d’exécution et indices de reproduction.                         |

```json
{"id":"cgt-example","model":"doubao-seedance-2-5-260628","status":"succeeded","content":{"video_url":"https://example.com/video.mp4"},"error":null,"created_at":1780000000,"updated_at":1780000120}
```

Téléchargez seulement avec succeeded et video\_url non vide ; arrêtez immédiatement pour failed, expired et cancelled. L’URL illustrée explique seulement les champs.

## Exemples de code

Définissez `ARK_API_KEY` et `TASK_ID` ; `TASK_ID` doit être l’ID réel de création. Python 3, Node.js 18+ et Go utilisent uniquement leurs bibliothèques standard ; curl nécessite aussi Python 3 pour encoder le chemin de manière sûre. Interrogez idéalement toutes les 5–10 secondes avec une durée maximale côté application ; l’exemple ne consulte qu’une fois.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    key = os.environ.get("ARK_API_KEY")
    task_id = os.environ.get("TASK_ID")
    if not key or not task_id or not task_id.strip():
        raise SystemExit("请设置 ARK_API_KEY 和 TASK_ID")
    url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + urllib.parse.quote(task_id, safe="")
    request = urllib.request.Request(url, headers={"Authorization": "Bearer " + key}, method="GET")
    try:
        with urllib.request.urlopen(request, timeout=180) as response:
            print(json.dumps(json.load(response), ensure_ascii=False, indent=2))
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const key = process.env.ARK_API_KEY;
      const taskId = process.env.TASK_ID;
      if (!key || !taskId?.trim()) throw new Error("请设置 ARK_API_KEY 和 TASK_ID");
      const url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + encodeURIComponent(taskId);
      const response = await fetch(url, {
        method: "GET", headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(180000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${ARK_API_KEY:?请设置 ARK_API_KEY}"
    : "${TASK_ID:?请设置 TASK_ID 为创建接口返回的真实任务 ID}"
    TASK_PATH=$(python3 - <<'PY_TASK'
    import os, urllib.parse
    task_id = os.environ["TASK_ID"]
    if not task_id.strip():
        raise SystemExit("TASK_ID 不能为空白")
    print(urllib.parse.quote(task_id, safe=""))
    PY_TASK
    )
    curl "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/${TASK_PATH}" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      --header "Authorization: Bearer $ARK_API_KEY"
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
    	"strings"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func main() {
    	key, taskID := os.Getenv("ARK_API_KEY"), os.Getenv("TASK_ID")
    	if key == "" || strings.TrimSpace(taskID) == "" {
    		log.Fatal("请设置 ARK_API_KEY 和 TASK_ID")
    	}
    	endpoint := "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + url.PathEscape(taskID)
    	req, err := http.NewRequest("GET", endpoint, nil)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	client := &http.Client{Timeout: 180 * time.Second}
    	response, err := client.Do(req)
    	check(err)
    	defer response.Body.Close()
    	data, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, data)
    	}
    	fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

| Statut HTTP           | Sens et traitement                                                                                                                                   |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Champs, média ou paramètres de modèle invalides ; corrigez avant de soumettre.                                                                       |
| 401                   | Clé API absente, invalide ou expirée.                                                                                                                |
| 403                   | Projet ou modèle non autorisé.                                                                                                                       |
| 404                   | Modèle, route ou tâche introuvable ; vérifiez l’adresse et le propriétaire.                                                                          |
| 413 / 415             | Fichier trop volumineux ou type de média non pris en charge.                                                                                         |
| 429                   | Limite de débit ou de quota ; distinguez le manque de crédit d’une limitation temporaire.                                                            |
| 500 / 502 / 503 / 504 | Erreur du service ou de l’amont \: conservez l’ID. Après expiration d’une création, vérifiez l’acceptation avant de relancer pour éviter un doublon. |

L’objet d’erreur Volcengine utilise `error.code`, `error.message` ; conservez aussi l’ID de requête. Même si HTTP réussit, vérifiez status et error de la tâche.

## Références officielles

[Consultation de tâche Volcengine Ark](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh).