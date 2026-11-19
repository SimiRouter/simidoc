# Téléverser un fichier

Téléverser un fichier local et obtenir un ID pour les autres interfaces OpenAI.

**SimiRouter ne prend pas encore en charge cette interface. Référence de l’API officielle OpenAI ; adresse d’appel \: `api.openai.com`, avec une clé du projet OpenAI, pas une clé SimiRouter.**

## Description de l’interface

* **Méthode** \: `POST`
* **Adresse API** \: `/v1/files`
* **Authentification** \: `Authorization: Bearer $OPENAI_API_KEY`
* **Type de requête** \: `multipart/form-data`.

La requête HTTP renvoie un objet fichier, pas l’achèvement des entraînements, lots ou indexations associés. Maximum de 512 Mo par fichier ; les entrées Batch sont limitées à 200 Mo et l’ajustement fin exige JSONL. Laissez le client générer la boundary multipart.

## Paramètres de requête

| Paramètres      | Type   | Obligatoire | Description                                                                                                                                                                                                  |
| --------------- | ------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `file`          | binary | Oui         | Le fichier lui-même, pas une chaîne de nom.                                                                                                                                                                  |
| `purpose`       | string | Oui         | Usage \: `assistants`, `batch`, `fine-tune`, `vision`, `user_data` ou `evals`.                                                                                                                               |
| `expires_after` | object | Non         | Politique d’expiration ; `anchor` est fixé à `created_at`, `seconds` est entre 3600 et 2592000. Sans réglage, les fichiers batch expirent après 30 jours et les autres restent jusqu’à suppression manuelle. |

## Valeur de retour

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

Exemple de réponse (ID et dates illustratifs) \:

```json
{
  "id": "file-demo",
  "object": "file",
  "bytes": 4096,
  "created_at": 1793491200,
  "filename": "training.jsonl",
  "purpose": "fine-tune",
  "expires_at": null
}
```

## Exemples de code

Prérequis \: Python 3, Node.js 20+, curl ou Go 1.20+. Enregistrez chaque exemple dans son fichier `.py`, `.cjs`, `.sh`, `.go` puis exécutez-le.

L’exemple téléverse un JSONL pour ajustement fin. Définissez d’abord `OPENAI_API_KEY` et `INPUT_FILE` ; le jeu doit respecter le format de la méthode choisie. Le téléversement seul ne lance pas l’entraînement.

Pour montrer clairement le multipart, l’exemple charge le fichier en mémoire ; préférez un téléversement en flux pour un gros fichier.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.request
    import uuid
    from pathlib import Path

    key = os.environ.get("OPENAI_API_KEY")
    source = os.environ.get("INPUT_FILE")
    if not key or not source:
        raise SystemExit("请设置 OPENAI_API_KEY 和 INPUT_FILE")
    path = Path(source)
    if not path.is_file() or path.stat().st_size == 0:
        raise SystemExit("INPUT_FILE 必须是非空的本地文件")
    boundary = "upload-" + uuid.uuid4().hex
    body = (
        f'--{boundary}\r\nContent-Disposition: form-data; name="purpose"\r\n\r\nfine-tune\r\n'
        f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="training.jsonl"\r\n'
        'Content-Type: application/jsonl\r\n\r\n'
    ).encode() + path.read_bytes() + f"\r\n--{boundary}--\r\n".encode()
    request = urllib.request.Request(
        "https://api.openai.com/v1/files", method="POST", data=body,
        headers={"Authorization": "Bearer " + key,
                 "Content-Type": "multipart/form-data; boundary=" + boundary},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            print(json.dumps(json.load(response), ensure_ascii=False, indent=2))
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile, stat } = require("node:fs/promises");
    const { basename } = require("node:path");
    async function main() {
      const key = process.env.OPENAI_API_KEY;
      const path = process.env.INPUT_FILE;
      if (!key || !path) throw new Error("请设置 OPENAI_API_KEY 和 INPUT_FILE");
      const info = await stat(path);
      if (!info.isFile() || info.size === 0) throw new Error("INPUT_FILE 必须是非空的本地文件");
      const form = new FormData();
      form.append("purpose", "fine-tune");
      form.append("file", new Blob([await readFile(path)], { type: "application/jsonl" }), basename(path));
      const response = await fetch("https://api.openai.com/v1/files", {
        method: "POST", headers: { Authorization: `Bearer ${key}` }, body: form,
        signal: AbortSignal.timeout(120000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.json());
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${OPENAI_API_KEY:?请设置 OPENAI_API_KEY}"
    : "${INPUT_FILE:?请设置 INPUT_FILE 为训练集的本地路径}"
    [[ -f "$INPUT_FILE" && -s "$INPUT_FILE" ]] || { printf '%s\n' 'INPUT_FILE 必须是非空的本地文件' >&2; exit 1; }
    curl --fail-with-body --connect-timeout 15 --max-time 120 --request POST \
      "https://api.openai.com/v1/files" \
      --header "Authorization: Bearer $OPENAI_API_KEY" \
      --form "purpose=fine-tune" \
      --form "file=@${INPUT_FILE};type=application/jsonl"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"bytes"
    	"fmt"
    	"io"
    	"log"
    	"mime/multipart"
    	"net/http"
    	"os"
    	"path/filepath"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func main() {
    	key, path := os.Getenv("OPENAI_API_KEY"), os.Getenv("INPUT_FILE")
    	if key == "" || path == "" {
    		log.Fatal("请设置 OPENAI_API_KEY 和 INPUT_FILE")
    	}
    	file, err := os.Open(path)
    	check(err)
    	defer file.Close()
    	info, err := file.Stat()
    	check(err)
    	if !info.Mode().IsRegular() || info.Size() == 0 {
    		log.Fatal("INPUT_FILE 必须是非空的本地文件")
    	}
    	var body bytes.Buffer
    	form := multipart.NewWriter(&body)
    	check(form.WriteField("purpose", "fine-tune"))
    	part, err := form.CreateFormFile("file", filepath.Base(path))
    	check(err)
    	_, err = io.Copy(part, file)
    	check(err)
    	check(form.Close())
    	req, err := http.NewRequest("POST", "https://api.openai.com/v1/files", &body)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	req.Header.Set("Content-Type", form.FormDataContentType())
    	response, err := (&http.Client{Timeout: 120 * time.Second}).Do(req)
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

* [Téléversement de fichiers OpenAI](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [Codes d’erreur OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)