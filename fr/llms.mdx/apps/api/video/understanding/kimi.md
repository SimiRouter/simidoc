# Compréhension vidéo Kimi

## Description de l’interface

`kimi-k3` accepte nativement la compréhension vidéo pour résumer, répondre sur les scènes ou analyser des événements. Le résultat est textuel, sans génération vidéo ni promesse de reconnaissance trame par trame ou d’alignement temporel précis.

**Adresse API** \: `POST https://api.moonshot.cn/v1/chat/completions`. Utilisez une clé API Moonshot du site chinois avec l’authentification `Authorization: Bearer $MOONSHOT_API_KEY`. Le site international utilise `https://api.moonshot.ai` et sa propre clé ; comptes et clés des deux sites ne sont pas interchangeables.

L’exemple utilise **Accès direct officiel Moonshot**. La capacité vidéo du modèle ne prouve pas que SimiRouter offre le même modèle, les mêmes entrées multimédias ou le même stockage ; ne transférez pas directement un ID de fichier `ms://` vers un autre fournisseur ou une passerelle.

* **Sans streaming** \: `stream: false`, la même requête HTTP attend un JSON complet.
* **Streaming** \: `stream: true`, la même connexion renvoie progressivement raisonnement et texte via SSE ; ce n’est pas une tâche asynchrone de génération vidéo.
* **Références de fichiers** \: téléversez d’abord le fichier, puis utilisez `ms://<file_id>` dans la conversation ; le téléversement ne remplace pas la requête au modèle.

## Paramètres de requête

Le type de contenu est `application/json`.

| Champ                          | Type                     | Obligatoire  | Description                                                                                                                     |
| ------------------------------ | ------------------------ | ------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| `model`                        | string                   | Oui          | Cette page utilise `kimi-k3`, pas le nom affiché dans une interface ni une abréviation.                                         |
| `messages`                     | array                    | Oui          | Liste de messages ; le message utilisateur vidéo utilise un tableau de contenu.                                                 |
| `messages[].role`              | string                   | Oui          | Placez vidéo et question dans le message `user` ; une instruction système peut être placée dans un message `system`.            |
| `messages[].content`           | array                    | Oui          | Contient un élément vidéo `video_url` et une question `text` ; ne sérialisez pas le tableau en chaîne.                          |
| `content[].type`               | string                   | Oui          | Pour la vidéo, `video_url` ; pour le texte, `text`.                                                                             |
| `content[].video_url.url`      | string                   | Conditionnel | `data:video/mp4;base64,...` ou autre data URL correspondant au MIME réel, ou une référence Moonshot `ms://<file_id>`.           |
| `content[].text`               | string                   | Conditionnel | Analyse demandée \: résumé, séquence d’événements ou questions sur une plage temporelle.                                        |
| `reasoning_effort`             | string                   | Non          | K3 active toujours le raisonnement ; utilisez au premier niveau `low`, `high` ou `max`, par défaut `max`.                       |
| `max_completion_tokens`        | integer                  | Non          | Limite de génération avec un budget suffisant pour raisonnement et réponse finale ; à la limite, `finish_reason` vaut `length`. |
| `stream`                       | boolean                  | Non          | Par défaut, `false` ; `true` renvoie SSE.                                                                                       |
| `stream_options.include_usage` | boolean                  | Non          | Avec le streaming, obtient le bloc d’utilisation avant la fin.                                                                  |
| `response_format`              | object                   | Non          | Format structuré accepté ; pour JSON, suivez JSON Mode ou JSON Schema officiels.                                                |
| `tools` / `tool_choice`        | array / string or object | Non          | Appels d’outils possibles ; les exemples d’analyse vidéo ne les activent pas.                                                   |

K3 n’utilise pas l’option K2.x `thinking`. `temperature` est fixé à `1.0`, `top_p` est fixé à `0.95`, `n` est fixé à `1`, la pénalité de répétition est fixée à `0` ; omettez de préférence ces champs, car les autres valeurs provoquent une erreur. `max_tokens` est l’ancien paramètre ; utilisez `max_completion_tokens`.

### Limites d’entrée vidéo

La page visuelle officielle indique MP4, MPEG, MOV, AVI, FLV, MPG, WebM, WMV et 3GPP et recommande une résolution maximale de 1080p. Le corps doit respecter la limite officielle de 100M ; Base64 l’agrandit, donc la taille vidéo originale n’est pas la taille du JSON.

Les exemples adoptent prudemment **une limite locale de 20 Mio** \: protection de l’exemple, pas capacité ou durée maximale promise du modèle. Pour les vidéos plus grandes ou réutilisées, suivez le téléversement officiel. N’insérez pas de page Web ordinaire, partage Xiaohongshu ou chemin local dans `video_url.url` ; cette page utilise les deux méthodes confirmées, Base64 et `ms://`.

### Utiliser une vidéo déjà téléversée

Appelez l’interface Moonshot `POST /v1/files` et envoyez en multipart `file` et `purpose=video` ; lisez le `id` renvoyé puis utilisez `{"type":"video_url","video_url":{"url":"ms://<file_id>"}}` dans l’élément vidéo. Il n’est pas nécessaire de relire le contenu d’extraction textuelle du fichier.

La référence officielle de téléversement indique 100 Mio par fichier ; avec le nouveau protocole, respectez ses exigences `kimi-api-version`, sans appliquer ses en-têtes de version à Chat Completions. Les ressources doivent être accessibles depuis la même plateforme et le même compte ; supprimez-les ensuite selon les règles de conservation.

## Valeur de retour

Une réussite sans streaming renvoie HTTP 200 JSON dans la structure Chat Completions.

| Champ                                 | Type    | Description                                                                                                                              |
| ------------------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `id`                                  | string  | Identifiant de cette complétion.                                                                                                         |
| `object`                              | string  | Sans streaming, `chat.completion`.                                                                                                       |
| `created`                             | integer | Heure de création, en secondes Unix.                                                                                                     |
| `model`                               | string  | Identifiant du modèle de réponse.                                                                                                        |
| `choices[].index`                     | integer | Position du candidat.                                                                                                                    |
| `choices[].message.role`              | string  | Le message assistant est `assistant`.                                                                                                    |
| `choices[].message.content`           | string  | Analyse vidéo finale.                                                                                                                    |
| `choices[].message.reasoning_content` | string  | Raisonnement éventuellement renvoyé ; pas la réponse finale, à ne pas mélanger avec `content`.                                           |
| `choices[].finish_reason`             | string  | `stop` indique une fin normale ; `length` indique la limite de génération ; `tool_calls` demande l’exécution d’outils par l’application. |
| `usage.prompt_tokens`                 | integer | Utilisation d’entrée, incluant la vidéo selon le modèle.                                                                                 |
| `usage.completion_tokens`             | integer | Utilisation générée.                                                                                                                     |
| `usage.total_tokens`                  | integer | Utilisation totale, avec détails de cache et raisonnement éventuels.                                                                     |

ID, dates et utilisation ci-dessous illustrent seulement la structure, sans résultat de test \:

```json
{
  "id": "chatcmpl_example",
  "object": "chat.completion",
  "created": 1793500000,
  "model": "kimi-k3",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "视频先展示产品外观，随后演示操作步骤，最后对比使用前后的结果。"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 1200,
    "completion_tokens": 300,
    "total_tokens": 1500
  }
}
```

### Analyse du flux

Dans le JSON `data:` des SSE, `choices[].delta.reasoning_content` contient les ajouts de raisonnement et `choices[].delta.content` ceux du texte ; ajoutez-les séparément sans les écraser. Vérifiez le `finish_reason` final et attendez `data: [DONE]`. Si l’utilisation est activée, le bloc peut avoir `choices: []` ; lisez-la au premier niveau `usage`, sans accéder systématiquement à `choices[0]`.

En conversation, conservez le message assistant complet, notamment `reasoning_content` ; joignez encore le contexte vidéo et les questions nécessaires au tour suivant. Une interruption ou `length` ne constitue pas une réponse complète.

## Exemples de code

Définissez d’abord `MOONSHOT_API_KEY` et `VIDEO_FILE`, ce dernier étant une vraie vidéo locale que vous êtes autorisé à téléverser. `VIDEO_MIME` est facultatif, par défaut `video/mp4`, correspondant au fichier réel ; l’exemple ne convertit pas un fichier quelconque en MP4. `MOONSHOT_BASE_URL` est facultatif, par défaut `https://api.moonshot.cn`, sans `/v1`, pour un proxy autorisé ou un test mock local.

Python 3, Node.js 18+ et Go utilisent leurs bibliothèques standard ; curl nécessite Python 3 pour encoder et analyser le JSON. Les quatre exemples limitent la vidéo à 20 Mio, fixent un délai, refusent les résultats incomplets et ne réessaient pas automatiquement les requêtes facturables.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import base64
    import json
    import os
    import urllib.error
    import urllib.request
    from pathlib import Path

    key = os.environ.get("MOONSHOT_API_KEY")
    filename = os.environ.get("VIDEO_FILE")
    if not key or not filename:
        raise SystemExit("请设置 MOONSHOT_API_KEY 和 VIDEO_FILE")
    path = Path(filename)
    if not path.is_file() or not 0 < path.stat().st_size <= 20 * 1024 * 1024:
        raise SystemExit("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件")
    mime = os.environ.get("VIDEO_MIME", "video/mp4")
    allowed = {"video/mp4", "video/mpeg", "video/mov", "video/avi", "video/x-flv",
               "video/mpg", "video/webm", "video/wmv", "video/3gpp"}
    if mime not in allowed:
        raise SystemExit("VIDEO_MIME 不在本页列出的格式范围内")
    video = base64.b64encode(path.read_bytes()).decode("ascii")
    body = {
        "model": "kimi-k3",
        "messages": [{"role": "user", "content": [
            {"type": "video_url", "video_url": {"url": f"data:{mime};base64,{video}"}},
            {"type": "text", "text": "概括视频内容，并按顺序列出关键事件。"},
        ]}],
        "reasoning_effort": "low",
        "max_completion_tokens": 4096,
        "stream": False,
    }
    base = os.environ.get("MOONSHOT_BASE_URL", "https://api.moonshot.cn").rstrip("/")
    request = urllib.request.Request(
        base + "/v1/chat/completions", data=json.dumps(body).encode("utf-8"),
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=300) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop":
        raise RuntimeError("视频分析未正常完成，请检查 finish_reason 与错误信息")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip():
        raise RuntimeError("响应没有最终文字答案")
    print(answer)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile, stat } = require("node:fs/promises");

    async function main() {
      const key = process.env.MOONSHOT_API_KEY;
      const filename = process.env.VIDEO_FILE;
      if (!key || !filename) throw new Error("请设置 MOONSHOT_API_KEY 和 VIDEO_FILE");
      const info = await stat(filename);
      if (!info.isFile() || info.size <= 0 || info.size > 20 * 1024 * 1024)
        throw new Error("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件");
      const mime = process.env.VIDEO_MIME || "video/mp4";
      const allowed = ["video/mp4", "video/mpeg", "video/mov", "video/avi", "video/x-flv",
        "video/mpg", "video/webm", "video/wmv", "video/3gpp"];
      if (!allowed.includes(mime)) throw new Error("不支持的 VIDEO_MIME");
      const video = (await readFile(filename)).toString("base64");
      const body = {
        model: "kimi-k3",
        messages: [{ role: "user", content: [
          { type: "video_url", video_url: { url: `data:${mime};base64,${video}` } },
          { type: "text", text: "概括视频内容，并按顺序列出关键事件。" },
        ] }],
        reasoning_effort: "low", max_completion_tokens: 4096, stream: false,
      };
      const base = (process.env.MOONSHOT_BASE_URL || "https://api.moonshot.cn").replace(/\/+$/, "");
      const response = await fetch(base + "/v1/chat/completions", {
        method: "POST",
        headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
        body: JSON.stringify(body), signal: AbortSignal.timeout(300000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      const choice = result.choices?.[0];
      if (choice?.finish_reason !== "stop") throw new Error("视频分析未正常完成");
      const answer = choice.message?.content;
      if (typeof answer !== "string" || !answer.trim()) throw new Error("响应没有最终文字答案");
      console.log(answer);
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${MOONSHOT_API_KEY:?请设置 MOONSHOT_API_KEY}"
    : "${VIDEO_FILE:?请设置 VIDEO_FILE}"
    base="${MOONSHOT_BASE_URL:-https://api.moonshot.cn}"
    request=$(mktemp)
    response=$(mktemp)
    trap 'rm -f "$request" "$response"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json, os
    from pathlib import Path
    path = Path(os.environ["VIDEO_FILE"])
    if not path.is_file() or not 0 < path.stat().st_size <= 20 * 1024 * 1024:
        raise SystemExit("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件")
    mime = os.environ.get("VIDEO_MIME", "video/mp4")
    allowed = {"video/mp4", "video/mpeg", "video/mov", "video/avi", "video/x-flv",
               "video/mpg", "video/webm", "video/wmv", "video/3gpp"}
    if mime not in allowed: raise SystemExit("不支持的 VIDEO_MIME")
    video = base64.b64encode(path.read_bytes()).decode("ascii")
    print(json.dumps({
        "model": "kimi-k3",
        "messages": [{"role": "user", "content": [
            {"type": "video_url", "video_url": {"url": f"data:{mime};base64,{video}"}},
            {"type": "text", "text": "概括视频内容，并按顺序列出关键事件。"},
        ]}],
        "reasoning_effort": "low", "max_completion_tokens": 4096, "stream": False,
    }, ensure_ascii=False))
    PY_BODY
    if curl --fail-with-body --connect-timeout 15 --max-time 300 \
      "${base%/}/v1/chat/completions" \
      -H "Authorization: Bearer $MOONSHOT_API_KEY" \
      -H "Content-Type: application/json" --data-binary "@$request" --output "$response"; then
      python3 - "$response" <<'PY_RESULT'
    import json, sys
    with open(sys.argv[1], encoding="utf-8") as source: result = json.load(source)
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop":
        raise RuntimeError("视频分析未正常完成")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip(): raise RuntimeError("响应没有最终文字答案")
    print(answer)
    PY_RESULT
    else
      status=$?
      cat "$response" >&2
      exit "$status"
    fi
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
        "bytes"
        "encoding/base64"
        "encoding/json"
        "fmt"
        "io"
        "net/http"
        "os"
        "strings"
        "time"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
        key, filename := os.Getenv("MOONSHOT_API_KEY"), os.Getenv("VIDEO_FILE")
        if key == "" || filename == "" { panic("请设置 MOONSHOT_API_KEY 和 VIDEO_FILE") }
        info, err := os.Stat(filename); check(err)
        if !info.Mode().IsRegular() || info.Size() <= 0 || info.Size() > 20*1024*1024 {
            panic("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件")
        }
        mime := os.Getenv("VIDEO_MIME"); if mime == "" { mime = "video/mp4" }
        allowed := map[string]bool{"video/mp4":true, "video/mpeg":true, "video/mov":true,
            "video/avi":true, "video/x-flv":true, "video/mpg":true, "video/webm":true,
            "video/wmv":true, "video/3gpp":true}
        if !allowed[mime] { panic("不支持的 VIDEO_MIME") }
        video, err := os.ReadFile(filename); check(err)
        body := map[string]any{
            "model":"kimi-k3",
            "messages":[]any{map[string]any{"role":"user", "content":[]any{
                map[string]any{"type":"video_url", "video_url":map[string]string{
                    "url":"data:"+mime+";base64,"+base64.StdEncoding.EncodeToString(video)}},
                map[string]string{"type":"text", "text":"概括视频内容，并按顺序列出关键事件。"},
            }}},
            "reasoning_effort":"low", "max_completion_tokens":4096, "stream":false,
        }
        payload, err := json.Marshal(body); check(err)
        base := os.Getenv("MOONSHOT_BASE_URL"); if base == "" { base = "https://api.moonshot.cn" }
        req, err := http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1/chat/completions", bytes.NewReader(payload)); check(err)
        req.Header.Set("Authorization","Bearer "+key); req.Header.Set("Content-Type","application/json")
        res, err := (&http.Client{Timeout:300*time.Second}).Do(req); check(err); defer res.Body.Close()
        raw, err := io.ReadAll(res.Body); check(err)
        if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw)) }
        var result struct { Choices []struct {
            Finish string `json:"finish_reason"`
            Message struct { Content string `json:"content"` } `json:"message"`
        } `json:"choices"` }
        check(json.Unmarshal(raw,&result))
        if len(result.Choices)==0 || result.Choices[0].Finish!="stop" { panic("视频分析未正常完成") }
        answer := result.Choices[0].Message.Content
        if strings.TrimSpace(answer)=="" { panic("响应没有最终文字答案") }
        fmt.Println(answer)
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

| Statut HTTP           | Types d’erreurs courants                                                              | Traitement                                                                                                                            |
| --------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| 400                   | `invalid_request_error`, `content_filter`                                             | Vérifiez tableau de contenu, Base64/MIME, taille du corps, paramètres fixes et contexte ; adaptez l’entrée aux exigences de sécurité. |
| 401                   | `invalid_authentication_error`, `incorrect_api_key_error`                             | Vérifiez la clé et le site du point d’accès ; ne mélangez pas clés chinoise, internationale ou SimiRouter.                            |
| 403                   | `permission_denied_error`                                                             | Vérifiez droits du modèle, liste d’autorisation de l’organisation et périmètre des fonctions ouvertes.                                |
| 404                   | `resource_not_found_error`                                                            | Vérifiez ID de modèle, fichier et propriété de la ressource.                                                                          |
| 429                   | `engine_overloaded_error`, `exceeded_current_quota_error`, `rate_limit_reached_error` | Distinguez capacité, solde et débit ; répéter les requêtes ne résout pas un quota insuffisant.                                        |
| 499 / 500 / 503 / 504 | `client_closed_request`, `server_error`, etc.                                         | Conservez l’ID de requête et vérifiez connexion et service ; préférez SSE pour les requêtes longues.                                  |

Les erreurs contiennent généralement `error.type` et `error.message` ; certaines réponses ajoutent `error.code`. Un délai dépassé ne prouve pas l’absence d’exécution \: vérifiez l’utilisation avant de réessayer ; ne journalisez ni clé ni Base64 vidéo complet.

## Références officielles

* [Kimi K3 \: modèle et exemple de fichier vidéo](https\://platform.kimi.com/docs/guide/kimi-k3-quickstart)
* [Entrées visuelles Kimi \: formats vidéo et limites](https\://platform.kimi.com/docs/guide/use-kimi-vision-model)
* [API Chat Completions Kimi \: data URL vidéo, requêtes et réponses](https\://platform.kimi.com/docs/api/chat)
* [Référence des paramètres de modèles Kimi](https\://platform.kimi.com/docs/api/models-overview)
* [Streaming Kimi](https\://platform.kimi.com/docs/guide/utilize-the-streaming-output-feature-of-kimi-api)
* [Téléversement de fichiers Moonshot](https\://platform.kimi.com/docs/api/files-upload)
* [Codes d’erreur Kimi](https\://platform.kimi.com/docs/api/errors)