# Créer une tâche d’ajustement fin

Soumettre jeu d’entraînement et modèle de base pour créer une tâche asynchrone OpenAI.

**SimiRouter ne prend pas encore en charge cette interface. Référence de l’API officielle OpenAI ; adresse d’appel \: `api.openai.com`, avec une clé du projet OpenAI, pas une clé SimiRouter.**

OpenAI met fin à l’ajustement fin en libre-service \: les nouveaux utilisateurs ne peuvent pas créer de tâche et les utilisateurs existants éligibles ne le peuvent que jusqu’au **6 janvier 2027**, sauf retrait anticipé du modèle de base. Consultez la [chronologie officielle](https\://developers.openai.com/api/docs/deprecations) avant l’envoi.

## Description de l’interface

* **Méthode** \: `POST`
* **Adresse API** \: `/v1/fine_tuning/jobs`
* **Authentification** \: `Authorization: Bearer $OPENAI_API_KEY`
* **Type de requête** \: `application/json`.

La création renvoie un objet tâche ; l’entraînement s’exécute ensuite sur le serveur. `200` ou `queued` ne prouve pas la réussite de l’entraînement ; utilisez [Obtenir les détails de la tâche](/simidoc/fr/apps/api/pending/fine-tuning/retrieve) pour consulter son état final `status` et [Obtenir les événements](/simidoc/fr/apps/api/pending/fine-tuning/events) pour suivre la progression. Le chemin est `/v1/fine_tuning/jobs`, pas l’ancien `/v1/fine-tunes`.

## Paramètres de requête

| Paramètres                          | Type             | Obligatoire | Description                                                                                                                                      |
| ----------------------------------- | ---------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `model`                             | string           | Oui         | ID du modèle de base acceptant la méthode d’ajustement fin choisie.                                                                              |
| `training_file`                     | string           | Oui         | ID du jeu d’entraînement JSONL téléversé avec `purpose=fine-tune`.                                                                               |
| `validation_file`                   | string / null    | Non         | ID d’un jeu de validation indépendant, sans duplication des données d’entraînement.                                                              |
| `method`                            | object           | Non         | `type` vaut `supervised`, `dpo` ou `reinforcement`, avec un objet de configuration du même nom ; la méthode doit être compatible avec le modèle. |
| `method.supervised.hyperparameters` | object           | Non         | `batch_size` \: auto ou 1–256 ; `learning_rate_multiplier` \: auto ou nombre positif ; `n_epochs` \: auto ou 1–50.                               |
| `method.dpo.hyperparameters`        | object           | Non         | Hyperparamètres DPO, comprenant `beta` ; ne réutilisez pas directement le format des données supervisées.                                        |
| `method.reinforcement`              | object           | Non         | Configuration d’ajustement par renforcement, comprenant `grader` et les hyperparamètres de cette méthode.                                        |
| `suffix`                            | string / null    | Non         | Suffixe personnalisé du nom de modèle produit, 64 caractères maximum.                                                                            |
| `seed`                              | integer / null   | Non         | Graine aléatoire ; une graine identique ne garantit pas une reproductibilité parfaite.                                                           |
| `metadata`                          | object / null    | Non         | Au maximum 16 paires ; clés de 64 caractères et valeurs de 512 caractères maximum.                                                               |
| `integrations`                      | array / null     | Non         | Intégration de métriques externes, par exemple une configuration `wandb` avec nom de projet.                                                     |
| `hyperparameters`                   | object, obsolète | Non         | Ancienne écriture de premier niveau ; placez les nouveaux réglages dans `method`.                                                                |

Modèle et ID de fichier du corps illustrent la structure ; utilisez les ressources du projet concerné pour un appel réel.

```json
{
  "model": "selected-base-model",
  "training_file": "file-training",
  "method": {
    "type": "supervised",
    "supervised": {
      "hyperparameters": {
        "n_epochs": 2
      }
    }
  }
}
```

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

Exemple de réponse (champs principaux uniquement, pas une tâche réelle) \:

```json
{
  "id": "ftjob-demo",
  "object": "fine_tuning.job",
  "model": "selected-base-model",
  "created_at": 1793491200,
  "finished_at": null,
  "fine_tuned_model": null,
  "status": "queued",
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

Définissez `OPENAI_API_KEY`, `OPENAI_FINE_TUNING_MODEL` et `OPENAI_TRAINING_FILE_ID`. L’exemple curl utilise Python 3 pour produire le JSON. L’ajustement fin du modèle de base doit être ouvert dans le projet officiel. L’entraînement entraîne des frais ; exécutez-le seulement après validation des données, de la méthode et du budget, jamais comme test de connectivité.

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
    model = required("OPENAI_FINE_TUNING_MODEL")
    training_file = required("OPENAI_TRAINING_FILE_ID")
    payload = {"model": model, "training_file": training_file}
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        "https://api.openai.com/v1/fine_tuning/jobs",
        method="POST",
        data=data,
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"},
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
      const model = required("OPENAI_FINE_TUNING_MODEL");
      const training_file = required("OPENAI_TRAINING_FILE_ID");
      const body = JSON.stringify({"model": model, "training_file": training_file});
      const response = await fetch("https://api.openai.com/v1/fine_tuning/jobs", {
        method: "POST",
        headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
        body,
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
    : "${OPENAI_FINE_TUNING_MODEL:?请设置 OPENAI_FINE_TUNING_MODEL}"
    : "${OPENAI_TRAINING_FILE_ID:?请设置 OPENAI_TRAINING_FILE_ID}"
    payload=$(python3 - <<'JSON'
    import json, os
    print(json.dumps({"model": os.environ["OPENAI_FINE_TUNING_MODEL"], "training_file": os.environ["OPENAI_TRAINING_FILE_ID"]}))
    JSON
    )

    curl "https://api.openai.com/v1/fine_tuning/jobs" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request POST \
      --header "Authorization: Bearer $OPENAI_API_KEY" \
      --header "Content-Type: application/json" \
      --data "$payload"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"bytes"
    	"encoding/json"
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
    	model := required("OPENAI_FINE_TUNING_MODEL")
    	training_file := required("OPENAI_TRAINING_FILE_ID")
    	payload, err := json.Marshal(map[string]any{"model": model, "training_file": training_file})
    	check(err)
    	req, err := http.NewRequest("POST", "https://api.openai.com/v1/fine_tuning/jobs", bytes.NewReader(payload))
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	req.Header.Set("Content-Type", "application/json")
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

* [Créer une tâche d’ajustement fin OpenAI](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/create)
* [Guide OpenAI d’optimisation des modèles](https\://developers.openai.com/api/docs/guides/model-optimization)
* [Codes d’erreur OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)