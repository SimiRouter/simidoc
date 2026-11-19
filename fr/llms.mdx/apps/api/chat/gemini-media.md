# Compréhension des médias Gemini

## Description de l’interface

`POST /v1beta/models/{model}:generateContent` combine texte et médias dans parts ; le modèle renvoie une description, une transcription ou une analyse. La compréhension des médias ne génère ni ne modifie d’images.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $SIMIROUTER_API_KEY`. L’API directe officielle Google est `https://generativelanguage.googleapis.com`. Authentification \: généralement `x-goog-api-key: $GEMINI_API_KEY`, pas la clé Bearer de la passerelle. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

L’exemple lit un fichier local et l’envoie en données intégrées, sans URL externe ni Files API ; les scripts associent les extensions courantes d’image, d’audio, de vidéo et de PDF aux types MIME. Pour l’audio, la vidéo et les PDF, utilisez le MIME adapté et un modèle acceptant cette modalité ; ne vous contentez pas de changer l’extension en extension d’image.

## Démarrage rapide

1. **Préparer la configuration** \: créez une clé dans Gestion des clés API et copiez depuis Modèles et prix un ID de modèle complet compatible avec le média ciblé.
2. **Préparer le média** \: choisissez une image, un audio, une vidéo ou un PDF autorisé et confirmez son vrai type MIME.
3. **Envoyer une requête minimale** \: encodez les octets du fichier en Base64 brut dans `inlineData.data` et placez la question texte dans les mêmes `parts` ; validez d’abord avec une seule image.
4. **Lire le résultat** \: la requête réussit uniquement si HTTP est 2xx et `candidates[]` est non vide ; l’analyse se trouve dans `candidates[0].content.parts[].text`.
5. **Valider** \: contrôlez `finishReason` et les éléments qui fondent la conclusion ; les cas sensibles exigent une relecture humaine.

L’image doit d’abord être encodée en Base64 ; voir la section « Exemples de code » ci-dessous pour un script minimal, et ne composez pas de longues chaînes Base64 à la main.

## Paramètres de requête

| Champ                              | Type           | Obligatoire  | Description                                                                                                                |
| ---------------------------------- | -------------- | ------------ | -------------------------------------------------------------------------------------------------------------------------- |
| model (chemin)                     | string         | Oui          | ID d’un modèle acceptant le média voulu.                                                                                   |
| contents\[].parts\[].text          | string         | Conditionnel | Question envoyée avec le média.                                                                                            |
| contents\[].parts\[].inlineData    | object         | Conditionnel | Média intégré contenant mimeType et data ; ne pas le combiner avec text/fileData dans le même Part.                        |
| inlineData.mimeType                | string         | Oui          | MIME réel, par exemple image/png, image/jpeg, audio/mpeg, video/mp4 ou application/pdf.                                    |
| inlineData.data                    | string         | Oui          | Octets du fichier en Base64 pur, sans préfixe data\: ; ce n’est pas un chemin local.                                       |
| contents\[].parts\[].fileData      | object         | Conditionnel | Autre source de média contenant mimeType et fileUri ; utilisez uniquement une URI autorisée et lisible par le fournisseur. |
| contents\[].role                   | string         | Non          | Généralement user pour un échange unique.                                                                                  |
| generationConfig.maxOutputTokens   | integer        | Non          | Nombre maximal de tokens de sortie.                                                                                        |
| systemInstruction / safetySettings | object / array | Non          | Instructions système et paramètres de sécurité.                                                                            |

Un Part ne contient qu’un seul type de contenu. Pour les gros fichiers, utilisez une méthode d’entrée officiellement prise en charge ; ne supposez pas que la passerelle fournit le téléversement et l’interrogation Files de Google. Base64 augmente la taille du corps ; respectez les limites de la passerelle, du fournisseur et du modèle.

### Structure de la requête

BASE64\_MEDIA\_BYTES ci-dessous représente les octets encodés ; les exemples dans les quatre langages produisent ce champ depuis un fichier local.

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "描述这份素材的主要内容，并指出不确定之处。"
        },
        {
          "inlineData": {
            "mimeType": "image/png",
            "data": "BASE64_MEDIA_BYTES"
          }
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 512
  }
}
```

## Valeur de retour

| Champ                                 | Type           | Description                                                                                                                     |
| ------------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| candidates\[]                         | array          | Résultats candidats ; peuvent être absents en cas de blocage.                                                                   |
| candidates\[].index                   | integer        | Position du candidat.                                                                                                           |
| candidates\[].content.role / parts\[] | string / array | Rôle et fragments de sortie ; le texte se trouve généralement dans parts\[].text.                                               |
| candidates\[].finishReason            | string         | STOP indique une fin normale ; MAX\_TOKENS une limite atteinte ; SAFETY, RECITATION, etc. nécessitent un traitement spécifique. |
| candidates\[].safetyRatings           | array          | Évaluation de sécurité facultative.                                                                                             |
| candidates\[].groundingMetadata       | object         | Sources et citations lors de l’utilisation d’outils de grounding comme la recherche.                                            |
| promptFeedback.blockReason            | string         | Raison du blocage de l’entrée ; il peut ne pas y avoir de candidat.                                                             |
| usageMetadata.promptTokenCount        | integer        | Tokens d’entrée.                                                                                                                |
| usageMetadata.candidatesTokenCount    | integer        | Tokens de sortie des candidats.                                                                                                 |
| usageMetadata.thoughtsTokenCount      | integer        | Tokens de raisonnement facultatifs ; ce ne sont pas des éléments de texte directement affichables.                              |
| usageMetadata.totalTokenCount         | integer        | Total des tokens de la requête, pouvant inclure outils, raisonnement et autres éléments.                                        |
| modelVersion / responseId             | string         | Version du modèle et identifiant de réponse facultatifs.                                                                        |

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "图片中可见一张桌子和一个杯子；杯中内容无法确定。"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 280,
    "candidatesTokenCount": 30,
    "totalTokenCount": 310
  }
}
```

Pour le streaming, utilisez streamGenerateContent?alt=sse et et fusionnez les résultats par index de candidat ; ne supposez pas que chaque part est du texte. L’interprétation du modèle peut être erronée ; les conclusions sensibles concernant la santé, l’identité ou les pièces d’identité doivent être vérifiées par une personne.

## Exemples de code

Définissez `SIMIROUTER_API_KEY`, `SIMIROUTER_GEMINI_MODEL` ; `SIMIROUTER_BASE_URL` permet de remplacer l’adresse de la passerelle par défaut ; n’y ajoutez pas `/v1`. `MEDIA_PATH` doit désigner un fichier local existant. Python 3, Node.js 18+ et Go utilisent uniquement leurs bibliothèques standard ; le JSON de l’exemple curl est encodé de manière sûre par Python 3.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error, urllib.parse
    import base64
    from pathlib import Path
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_GEMINI_MODEL"): raise RuntimeError("请设置 SIMIROUTER_GEMINI_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }''')
    p = Path(os.environ["MEDIA_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.mp3': 'audio/mpeg', '.wav': 'audio/wav', '.m4a': 'audio/mp4', '.flac': 'audio/flac', '.ogg': 'audio/ogg', '.mp4': 'video/mp4', '.mov': 'video/quicktime', '.webm': 'video/webm', '.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["contents"][0]["parts"][1]["inlineData"] = {"mimeType": mime, "data": encoded}
    path = "/v1beta/models/" + urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe="") + ":generateContent"
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
      const fs = require('node:fs');
      const path = require('node:path');
      if (!process.env.SIMIROUTER_API_KEY) throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_GEMINI_MODEL)
        throw new Error('请设置 SIMIROUTER_GEMINI_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '描述这份素材的主要内容，并指出不确定之处。',
              },
              {
                inlineData: {
                  mimeType: 'image/png',
                  data: 'BASE64_MEDIA_BYTES',
                },
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 512,
        },
      };
      const filename = process.env.MEDIA_PATH;
      if (!filename) throw new Error('请设置 MEDIA_PATH');
      const mime = {
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.webp': 'image/webp',
        '.mp3': 'audio/mpeg',
        '.wav': 'audio/wav',
        '.m4a': 'audio/mp4',
        '.flac': 'audio/flac',
        '.ogg': 'audio/ogg',
        '.mp4': 'video/mp4',
        '.mov': 'video/quicktime',
        '.webm': 'video/webm',
        '.pdf': 'application/pdf',
      }[path.extname(filename).toLowerCase()];
      if (!mime) throw new Error('不支持的文件扩展名');
      const data = fs.readFileSync(filename);
      if (!data.length) throw new Error('输入文件为空');
      const encoded = data.toString('base64');
      body.contents[0].parts[1].inlineData = { mimeType: mime, data: encoded };
      const endpoint = `/v1beta/models/${encodeURIComponent(process.env.SIMIROUTER_GEMINI_MODEL)}:generateContent`;
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000),
      });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_GEMINI_MODEL:?请设置 SIMIROUTER_GEMINI_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    import base64
    from pathlib import Path
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }''')
    p = Path(os.environ["MEDIA_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.mp3': 'audio/mpeg', '.wav': 'audio/wav', '.m4a': 'audio/mp4', '.flac': 'audio/flac', '.ogg': 'audio/ogg', '.mp4': 'video/mp4', '.mov': 'video/quicktime', '.webm': 'video/webm', '.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["contents"][0]["parts"][1]["inlineData"] = {"mimeType": mime, "data": encoded}
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    MODEL_PATH=$(python3 -c 'import os, urllib.parse; print(urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe=""))')
    curl "${BASE_URL%/}/v1beta/models/${MODEL_PATH}:generateContent" \
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
      model := os.Getenv("SIMIROUTER_GEMINI_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_GEMINI_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }`), &body); err != nil { log.Fatal(err) }
      filename := os.Getenv("MEDIA_PATH"); if filename == "" { log.Fatal("请设置 MEDIA_PATH") }
      mime := map[string]string{".png":"image/png",".jpg":"image/jpeg",".jpeg":"image/jpeg",".webp":"image/webp",".mp3":"audio/mpeg",".wav":"audio/wav",".m4a":"audio/mp4",".flac":"audio/flac",".ogg":"audio/ogg",".mp4":"video/mp4",".mov":"video/quicktime",".webm":"video/webm",".pdf":"application/pdf"}[strings.ToLower(filepath.Ext(filename))]
      if mime == "" { log.Fatal("不支持的文件扩展名") }
      data, err := os.ReadFile(filename); if err != nil { log.Fatal(err) }; if len(data) == 0 { log.Fatal("输入文件为空") }
      encoded := base64.StdEncoding.EncodeToString(data)
      body["contents"].([]any)[0].(map[string]any)["parts"].([]any)[1].(map[string]any)["inlineData"] = map[string]any{"mimeType": mime, "data": encoded}
      endpoint := "/v1beta/models/" + model + ":generateContent"
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

| Statut HTTP | Signification ou type d’erreur du fournisseur | Traitement                                                                                                                                 |
| ----------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| 400         | `INVALID_ARGUMENT`, etc.                      | Vérifiez le JSON, les paramètres du modèle, le MIME et la longueur des entrées.                                                            |
| 403         | `PERMISSION_DENIED`                           | Vérifiez la clé, les autorisations du projet, la région et les restrictions de facturation.                                                |
| 404         | `NOT_FOUND`                                   | Vérifiez le nom du modèle et la version de l’API.                                                                                          |
| 429         | `RESOURCE_EXHAUSTED`                          | Vérifiez les limites de débit et quotas ; pour les erreurs récupérables, utilisez un nombre limité de tentatives avec attente progressive. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`                    | Conservez l’identifiant de requête ; réessayez un nombre limité de fois ou ultérieurement.                                                 |

L’objet d’erreur natif Google contient `error.code` (code HTTP numérique), `error.status` (nom de l’énumération), `error.message` et éventuellement `details`. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont.

Les réponses longues et les requêtes en streaming peuvent durer de plusieurs dizaines de secondes à plusieurs minutes ; configurez un délai d’attente suffisant et, en cas de coupure, jugez à partir des deltas reçus et du motif d’arrêt plutôt que de renvoyer automatiquement. Pour 429 et 5xx, examinez d’abord le corps de la réponse et les journaux d’utilisation ; en cas de refus par la politique de contenu, modifiez le prompt ou l’entrée au lieu de réessayer à l’identique.

## Références officielles

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Compréhension d’images Google](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Compréhension audio Google](https\://ai.google.dev/gemini-api/docs/audio)
* [Compréhension vidéo Google](https\://ai.google.dev/gemini-api/docs/video-understanding)
* [Compréhension des PDF Google](https\://ai.google.dev/gemini-api/docs/document-processing)
* [Dépannage Google](https\://ai.google.dev/gemini-api/docs/troubleshooting)