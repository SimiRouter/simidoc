# Compréhension du contenu des fichiers

## Description de l’interface

`POST /v1/responses` accepte des fichiers via l’élément input\_file pour les modèles compatibles. Comprendre un fichier n’est pas un service de stockage et ne garantit pas un OCR complet et exact.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $SIMIROUTER_API_KEY`. L’API directe officielle OpenAI est `https://api.openai.com`. Authentification \: Bearer avec une clé OpenAI. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

Les points d’accès de la passerelle `/v1/files` pour téléverser, consulter et supprimer ne sont pas implémentés ; cette page utilise un PDF intégré en Base64, sans Files API. L’accès direct officiel peut téléverser puis référencer un file\_id, mais un file\_id officiel n’est pas automatiquement accessible via la passerelle.

## Paramètres de requête

| Champ                    | Type    | Obligatoire  | Description                                                                                                                                                                                                        |
| ------------------------ | ------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| model                    | string  | Oui          | ID d’un modèle acceptant les PDF et les capacités visuelles nécessaires.                                                                                                                                           |
| input\[].role            | string  | Oui          | Ici, user.                                                                                                                                                                                                         |
| input\[].content\[].type | string  | Oui          | input\_text pour la question, input\_file pour le fichier.                                                                                                                                                         |
| input\_text.text         | string  | Oui          | Tâche concernant le fichier \: résumé, extraction de champs ou questions-réponses.                                                                                                                                 |
| input\_file.filename     | string  | Conditionnel | Nom des données intégrées, avec leur vraie extension.                                                                                                                                                              |
| input\_file.file\_data   | string  | Conditionnel | Données Base64 du PDF ; le code de cette page utilise le préfixe data\:application/pdf;base64,... . La spécification officielle exige seulement du Base64 \: supprimez le préfixe data\:... si le canal le refuse. |
| input\_file.file\_id     | string  | Conditionnel | ID obtenu après téléversement officiel ; dépend de Files sur le service concerné.                                                                                                                                  |
| input\_file.file\_url    | string  | Conditionnel | URL accessible au fournisseur ; choisir cette source ou les données intégrées.                                                                                                                                     |
| max\_output\_tokens      | integer | Non          | Limite de sortie du modèle.                                                                                                                                                                                        |
| stream                   | boolean | Non          | true utilise les SSE Responses.                                                                                                                                                                                    |

N’envoyez pas un chemin local comme file\_url et ne renseignez pas simultanément file\_data, file\_id et file\_url. La taille doit respecter les limites de passerelle et d’entrée de fichiers officielles ; Base64 est plus volumineux que l’original et les images des pages PDF augmentent encore les tokens d’entrée.

### Structure de la requête

BASE64\_PDF\_BYTES représente le PDF original en Base64 ; les exemples lisent PDF\_PATH pour le remplir.

```json
{
  "model": "MODEL_ID",
  "input": [
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "请总结PDF的主要内容，并标注无法可靠读取的部分。"
        },
        {
          "type": "input_file",
          "filename": "document.pdf",
          "file_data": "data:application/pdf;base64,BASE64_PDF_BYTES"
        }
      ]
    }
  ],
  "max_output_tokens": 1024,
  "stream": false
}
```

## Valeur de retour

L’entrée de fichier ne crée pas d’ID de tâche de fichier indépendant ; elle renvoie un objet Responses standard.

| Champ                                                | Type             | Description                                                                                                                                     |
| ---------------------------------------------------- | ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| id / object                                          | string           | ID de réponse ; object=response.                                                                                                                |
| created\_at / model                                  | integer / string | Heure de création (secondes Unix) et modèle.                                                                                                    |
| status                                               | string           | completed, incomplete, failed, queued, in\_progress ou cancelled ; ces états peuvent apparaître en streaming comme en arrière-plan.             |
| output\[]                                            | array            | Éléments de sortie typés, pouvant mêler message, reasoning, function\_call, web\_search\_call, etc. ; ne lisez pas systématiquement output\[0]. |
| output\[].type / id / status                         | string           | Type, ID et état de l’élément de sortie, selon son type.                                                                                        |
| output\[].role                                       | string           | Le rôle de sortie d’un message est généralement assistant.                                                                                      |
| output\[].content\[]                                 | array            | Éléments de contenu \: type=output\_text pour le texte, type=refusal pour un refus.                                                             |
| output\[].content\[].text / annotations              | string / array   | Texte et annotations, notamment les citations.                                                                                                  |
| output\[].call\_id / name / arguments                | string           | ID de corrélation, nom de fonction et arguments sous forme de chaîne JSON de function\_call.                                                    |
| error                                                | object / null    | Informations d’échec ; généralement null en cas de réussite complète.                                                                           |
| incomplete\_details                                  | object / null    | Raison d’incomplétude, par exemple max\_output\_tokens ; ne pas assimiler à une réussite complète.                                              |
| usage.input\_tokens / output\_tokens / total\_tokens | integer          | Tokens d’entrée, de sortie et totaux.                                                                                                           |
| usage.\*\_tokens\_details                            | object           | Détails facultatifs d’utilisation, notamment cache et raisonnement.                                                                             |

```json
{
  "id": "resp_file_example",
  "object": "response",
  "status": "completed",
  "error": null,
  "incomplete_details": null,
  "output": [
    {
      "id": "msg_file_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "这份文档主要讨论项目背景、实施步骤和风险。部分扫描页较模糊，无法确认细小文字。",
          "annotations": []
        }
      ]
    }
  ],
  "usage": {
    "input_tokens": 1800,
    "output_tokens": 75,
    "total_tokens": 1875
  }
}
```

Chat Completions accepte aussi les PDF avec `type=file` et file.filename/file\_data imbriqués, mais sa structure diffère de input\_file dans Responses. Ne supposez pas que le Base64 de n’importe quel TXT, tableau ou archive soit accepté partout ; l’application peut décoder du texte et l’envoyer comme texte, tandis que les autres formats exigent une vérification des capacités du fournisseur et du modèle.

## Exemples de code

Définissez `SIMIROUTER_API_KEY`, `SIMIROUTER_FILE_MODEL` ; `SIMIROUTER_BASE_URL` permet de remplacer l’adresse de la passerelle par défaut ; n’y ajoutez pas `/v1`. `PDF_PATH` doit désigner un fichier local existant. Python 3, Node.js 18+ et Go utilisent uniquement leurs bibliothèques standard ; le JSON de l’exemple curl est encodé de manière sûre par Python 3.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    import base64
    from pathlib import Path
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_FILE_MODEL"): raise RuntimeError("请设置 SIMIROUTER_FILE_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "请总结PDF的主要内容，并标注无法可靠读取的部分。"
            },
            {
              "type": "input_file",
              "filename": "document.pdf",
              "file_data": "data:application/pdf;base64,BASE64_PDF_BYTES"
            }
          ]
        }
      ],
      "max_output_tokens": 1024,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_FILE_MODEL"]
    p = Path(os.environ["PDF_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["input"][0]["content"][1].update({"filename": p.name, "file_data": "data:" + mime + ";base64," + encoded})
    path = '/v1/responses'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const fs = require("node:fs");
      const path = require("node:path");
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      if (!process.env.SIMIROUTER_FILE_MODEL) throw new Error("请设置 SIMIROUTER_FILE_MODEL");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const body = {
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "请总结PDF的主要内容，并标注无法可靠读取的部分。"
            },
            {
              "type": "input_file",
              "filename": "document.pdf",
              "file_data": "data:application/pdf;base64,BASE64_PDF_BYTES"
            }
          ]
        }
      ],
      "max_output_tokens": 1024,
      "stream": false
    };
      body.model = process.env.SIMIROUTER_FILE_MODEL;
      const filename = process.env.PDF_PATH;
      if (!filename) throw new Error("请设置 PDF_PATH");
      const mime = {".pdf": "application/pdf"}[path.extname(filename).toLowerCase()];
      if (!mime) throw new Error("不支持的文件扩展名");
      const data = fs.readFileSync(filename);
      if (!data.length) throw new Error("输入文件为空");
      const encoded = data.toString("base64");
      Object.assign(body.input[0].content[1], { filename: path.basename(filename), file_data: `data:${mime};base64,${encoded}` });
      const endpoint = "/v1/responses";
      const response = await fetch(base + endpoint, { method: "POST",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000) });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_FILE_MODEL:?请设置 SIMIROUTER_FILE_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    import base64
    from pathlib import Path
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "请总结PDF的主要内容，并标注无法可靠读取的部分。"
            },
            {
              "type": "input_file",
              "filename": "document.pdf",
              "file_data": "data:application/pdf;base64,BASE64_PDF_BYTES"
            }
          ]
        }
      ],
      "max_output_tokens": 1024,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_FILE_MODEL"]
    p = Path(os.environ["PDF_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["input"][0]["content"][1].update({"filename": p.name, "file_data": "data:" + mime + ";base64," + encoded})
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/responses" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "$BODY"
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
      "net/http"
      "os"
      "strings"
      "time"
      "encoding/json"
      "encoding/base64"
      "path/filepath"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_FILE_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_FILE_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "请总结PDF的主要内容，并标注无法可靠读取的部分。"
            },
            {
              "type": "input_file",
              "filename": "document.pdf",
              "file_data": "data:application/pdf;base64,BASE64_PDF_BYTES"
            }
          ]
        }
      ],
      "max_output_tokens": 1024,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      filename := os.Getenv("PDF_PATH"); if filename == "" { log.Fatal("请设置 PDF_PATH") }
      mime := map[string]string{".pdf":"application/pdf"}[strings.ToLower(filepath.Ext(filename))]
      if mime == "" { log.Fatal("不支持的文件扩展名") }
      data, err := os.ReadFile(filename); if err != nil { log.Fatal(err) }; if len(data) == 0 { log.Fatal("输入文件为空") }
      encoded := base64.StdEncoding.EncodeToString(data)
      item := body["input"].([]any)[0].(map[string]any)["content"].([]any)[1].(map[string]any); item["filename"] = filepath.Base(filename); item["file_data"] = "data:" + mime + ";base64," + encoded
      endpoint := "/v1/responses"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
      fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

| Statut HTTP | Signification ou type d’erreur du fournisseur  | Traitement                                                                                                                       |
| ----------- | ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| 400         | Requête invalide                               | Vérifiez les champs obligatoires, le JSON, les paramètres du modèle et la longueur du contexte.                                  |
| 401         | Échec de l’authentification                    | Vérifiez que la clé est présente, valide et rattachée au bon compte.                                                             |
| 403 / 404   | Accès interdit / ressource introuvable         | Vérifiez les autorisations du modèle, l’ID de ressource et l’URL.                                                                |
| 429         | Limite de débit ou de quota                    | Distinguez limitation de débit et crédit insuffisant à l’aide du corps de réponse ; réessayer ne résout pas un manque de crédit. |
| 500 / 503   | Erreur de service / indisponibilité temporaire | Conservez l’identifiant de requête et limitez les nouvelles tentatives avec attente progressive aux erreurs temporaires.         |

Les erreurs natives OpenAI contiennent généralement `error.message`, `error.type`, `error.param`, `error.code` ; `param`, `code` peuvent être `null` ; ne supposez pas que ces champs existent toujours ou correspondent au code HTTP. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont. Si le fichier est endommagé, protégé, trop gros ou non accepté par le modèle, corrigez l’entrée ; ne répétez pas le même fichier erroné en simulant une reconnaissance réussie.

## Références officielles

* [Entrée de fichiers OpenAI](https\://developers.openai.com/api/docs/guides/file-inputs)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [Gestion des erreurs OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)