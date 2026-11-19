# Annuler une tâche d’ajustement fin

Demander l’arrêt d’une tâche d’ajustement fin OpenAI.

**SimiRouter ne prend pas encore en charge cette interface. Référence de l’API officielle OpenAI ; adresse d’appel \: `api.openai.com`, avec une clé du projet OpenAI, pas une clé SimiRouter.**

## Description de l’interface

* **Méthode** \: `POST`
* **Adresse API** \: `/v1/fine_tuning/jobs/{fine_tuning_job_id}/cancel`
* **Authentification** \: `Authorization: Bearer $OPENAI_API_KEY`
* **Type de requête** \: sans corps.

Renvoie l’objet tâche. Vérifiez le champ `status` renvoyé ; ne répétez pas l’annulation d’une tâche déjà réussie, échouée ou annulée.

## Paramètres de requête

| Paramètres           | Type           | Obligatoire | Description                                                  |
| -------------------- | -------------- | ----------- | ------------------------------------------------------------ |
| `fine_tuning_job_id` | string, chemin | Oui         | ID de tâche lu par le code dans `OPENAI_FINE_TUNING_JOB_ID`. |

## Valeur de retour

| Champ              | Type                       | Description                                                                                                               |
| ------------------ | -------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `id` / `object`    | string                     | ID de tâche ; type d’objet fixé à `fine_tuning.job`.                                                                      |
| `model`            | string                     | Modèle de base utilisé pour l’entraînement.                                                                               |
| `status`           | string                     | `validating_files`, `queued`, `running`, `pausing`, `paused`, `succeeded`, `failed` ou `cancelled`.                       |
| `created_at`       | integer                    | Date de création, horodatage Unix en secondes.                                                                            |
| `finished_at`      | integer / null             | Date de fin ; vide si la tâche continue.                                                                                  |
| `estimated_finish` | integer / null, facultatif | Fin estimée, sans garantie.                                                                                               |
| `fine_tuned_model` | string / null              | ID du modèle produit ; vide tant qu’il n’existe pas.                                                                      |
| `training_file`    | string                     | ID du fichier d’entraînement.                                                                                             |
| `validation_file`  | string / null              | ID du jeu de validation ; vide si absent.                                                                                 |
| `result_files`     | string\[]                  | ID des résultats, téléchargeables via Files API officielle.                                                               |
| `trained_tokens`   | integer / null             | Tokens facturables traités pendant l’entraînement ; peut être vide en cours.                                              |
| `error`            | object / null              | Détails d’échec, comprenant `code`, `message`, `param` ; pour une erreur non liée à un paramètre, `param` peut être vide. |
| `organization_id`  | string                     | Organisation propriétaire de la tâche.                                                                                    |
| `seed`             | integer / null             | Graine aléatoire de cet entraînement.                                                                                     |
| `method`           | object / null, facultatif  | Méthode d’ajustement fin et configuration.                                                                                |
| `hyperparameters`  | object / null, facultatif  | Champ de compatibilité des hyperparamètres supervisés.                                                                    |
| `integrations`     | array / null, facultatif   | Intégrations de métriques externes activées.                                                                              |
| `metadata`         | object / null, facultatif  | Paires clé-valeur personnalisées de la tâche.                                                                             |

Exemple de réponse (champs principaux) \:

```json
{
  "id": "ftjob-demo",
  "object": "fine_tuning.job",
  "model": "selected-base-model",
  "created_at": 1793491200,
  "finished_at": 1793491800,
  "fine_tuned_model": null,
  "status": "cancelled",
  "training_file": "file-training",
  "validation_file": null,
  "result_files": [],
  "trained_tokens": null,
  "error": null,
  "organization_id": "org-demo",
  "seed": null,
  "method": {
    "type": "supervised"
  },
  "metadata": {}
}
```

## Exemples de code

Prérequis \: Python 3, Node.js 20+, curl ou Go 1.20+. Enregistrez chaque exemple dans son fichier `.py`, `.cjs`, `.sh`, `.go` puis exécutez-le.

Définissez `OPENAI_API_KEY` et `OPENAI_FINE_TUNING_JOB_ID`. L’exécution arrête un véritable entraînement ; vérifiez d’abord l’ID. Annuler ne supprime pas les fichiers et n’annule pas l’utilisation déjà consommée.

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
        f"https://api.openai.com/v1/fine_tuning/jobs/{job_id_encoded}/cancel",
        method="POST",
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
      const response = await fetch(`https://api.openai.com/v1/fine_tuning/jobs/${jobId}/cancel`, {
        method: "POST",
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
    curl "https://api.openai.com/v1/fine_tuning/jobs/${OPENAI_FINE_TUNING_JOB_ID}/cancel" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request POST \
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
    	target := fmt.Sprintf("https://api.openai.com/v1/fine_tuning/jobs/%s/cancel", url.PathEscape(job_id))
    	req, err := http.NewRequest("POST", target, nil)
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

* [Annuler une tâche d’ajustement fin OpenAI](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/cancel)
* [Codes d’erreur OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)