# Consulter une tâche Kling texte vers vidéo

## Description de l’interface

`GET https://api-singapore.klingai.com/tasks`. Authentification \: `Authorization: Bearer $KLING_API_KEY`. Les nouvelles créations Kling texte/image vers vidéo partagent la consultation de tâches, sans ajouter `/v1/videos/.../{id}`.

## Paramètres de requête

| Champ                       | Type   | Obligatoire | Description                                                                          |
| --------------------------- | ------ | ----------- | ------------------------------------------------------------------------------------ |
| task\_ids (query)           | string | Au choix    | ID système de tâche ; plusieurs séparés par des virgules.                            |
| external\_task\_ids (query) | string | Au choix    | Valeur options.external\_task\_id de création ; plusieurs séparées par des virgules. |

Ne combinez pas les deux paramètres ; pas de corps JSON. Définissez `TASK_ID` sur le `data.id`.

## Valeur de retour

| Champ                             | Description                                                                         |
| --------------------------------- | ----------------------------------------------------------------------------------- |
| `code` / `message` / `request_id` | État métier et identifiant de suivi ; analysez data seulement si code=0.            |
| `data[]`                          | Tableau de tâches correspondant aux critères.                                       |
| `data[].id` / `external_id`       | ID système et personnalisé.                                                         |
| `data[].status`                   | submitted, processing, succeeded, failed.                                           |
| `data[].message`                  | Motif d’échec.                                                                      |
| `data[].outputs[]`                | Éléments distingués par type \: video/image/audio, etc., pas l’ancien task\_result. |
| `outputs[].url` / `watermark_url` | URL du résultat video et version filigranée disponible.                             |
| `outputs[].duration`              | Durée vidéo en secondes.                                                            |
| `create_time` / `update_time`     | Horodatage Unix en millisecondes.                                                   |
| `billing[]`                       | Informations renvoyées sur la facturation, notamment ses unités.                    |

```json
{"code":0,"message":"Success","request_id":"request_example","data":[{"id":"task_example","status":"succeeded","outputs":[{"type":"video","url":"https://example.com/video.mp4","duration":"5"}]}]}
```

Téléchargez uniquement avec status=succeeded et une sortie valide type=video. Les liens ont des restrictions d’accès ou de conservation \: enregistrez rapidement. Arrêtez l’interrogation en cas d’échec. HTTP réussi avec data=\[] exige de vérifier ID et compte, pas de déclarer une génération réussie.

## Exemples de code

Définissez `KLING_API_KEY` et `TASK_ID` ; `TASK_ID` doit être l’ID réel reçu à la création. Python 3, Node.js 18+ et Go utilisent uniquement leurs bibliothèques standard. curl utilise `--data-urlencode` pour encoder les paramètres. Interrogez idéalement toutes les 5–10 secondes avec une durée maximale côté application ; l’exemple ne consulte qu’une fois.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    key = os.environ.get("KLING_API_KEY")
    task_id = os.environ.get("TASK_ID")
    if not key or not task_id or not task_id.strip():
        raise SystemExit("请设置 KLING_API_KEY 和 TASK_ID")
    url = "https://api-singapore.klingai.com/tasks?" + urllib.parse.urlencode({"task_ids": task_id})
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
      const key = process.env.KLING_API_KEY;
      const taskId = process.env.TASK_ID;
      if (!key || !taskId?.trim()) throw new Error("请设置 KLING_API_KEY 和 TASK_ID");
      const url = new URL("https://api-singapore.klingai.com/tasks");
      url.searchParams.set("task_ids", taskId);
      const response = await fetch(url, {
        method: "GET", headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(180000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.code !== 0) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${KLING_API_KEY:?请设置 KLING_API_KEY}"
    : "${TASK_ID:?请设置 TASK_ID 为创建接口返回的真实任务 ID}"
    [[ "$TASK_ID" =~ [^[:space:]] ]] || { printf '%s\n' 'TASK_ID 不能为空白' >&2; exit 1; }
    curl "https://api-singapore.klingai.com/tasks" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      --get \
      --data-urlencode "task_ids=$TASK_ID" \
      --header "Authorization: Bearer $KLING_API_KEY"
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
    	key, taskID := os.Getenv("KLING_API_KEY"), os.Getenv("TASK_ID")
    	if key == "" || strings.TrimSpace(taskID) == "" {
    		log.Fatal("请设置 KLING_API_KEY 和 TASK_ID")
    	}
    	query := url.Values{"task_ids": []string{taskID}}
    	endpoint := "https://api-singapore.klingai.com/tasks?" + query.Encode()
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

| HTTP / code métier                   | Description                                                                               |
| ------------------------------------ | ----------------------------------------------------------------------------------------- |
| 200 / 0                              | Requête réussie ; vérifiez status de la tâche pour la fin de génération.                  |
| 400 / 1201                           | Paramètres incorrects ; lisez message.                                                    |
| 404 / 1202, 1203                     | Méthode incorrecte ou modèle/ressource introuvable.                                       |
| 401                                  | Clé API ou ancien JWT invalide.                                                           |
| 400 / 1300, 1301                     | Restriction de politique ou de sécurité ; corrigez le contenu sans réessayer aveuglément. |
| 429 / 1302, 1303, 1304               | Limite de débit, concurrence ou politique IP.                                             |
| 500 / 5000 ; 503 / 5001 ; 504 / 5002 | Erreur de service ou délai dépassé ; conservez request\_id.                               |

HTTP 200 n’est pas une réussite métier ; vérifiez code=0 avant de lire data.

## Références officielles

[Consultation officielle des tâches Kling](https\://kling.ai/document-api/apiReference/model/textToVideo).