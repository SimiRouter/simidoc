# Compréhension vidéo Dots

## Description de l’interface

`dots3-note-prev` accepte la vidéo ; placez vidéo, images et question dans le même tableau de contenu pour obtenir une analyse textuelle. Le protocole officiel vidéo est `POST https://note3-prev-api.askdiandian.com/v1/chat/completions`, avec l’en-tête `api-key: $DOTS_API_KEY`, sans authentification Bearer.

Les exemples appellent directement **le service officiel Dots**. Ce n’est ni le protocole Gemini `input/steps` ni une tâche asynchrone de génération vidéo. Avec SimiRouter, confirmez que modèle et canal relaient cette extension vidéo ; remplacer domaine et clé ne suffit pas.

* `stream: false` \: attend un JSON complet ; la réponse finale se trouve dans `choices[].message.content`.
* `stream: true` \: reçoit les ajouts textuels via SSE ; le traitement vidéo peut allonger l’attente du premier token, prévoyez un délai client suffisant.
* La vidéo doit être une URL de fichier lisible par le service du modèle. L’exemple officiel ne documente ni Base64, `ms://`, fréquence d’échantillonnage des trames, durée maximale ni taille fixe ; cette page ne les considère pas comme pris en charge.

## Paramètres de requête

Le corps de requête est `application/json`.

| Champ                                  | Type                     | Obligatoire               | Description                                                                                                    |
| -------------------------------------- | ------------------------ | ------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `model`                                | string                   | Oui                       | Le modèle de l’exemple officiel est `dots3-note-prev`.                                                         |
| `messages`                             | array                    | Oui                       | Transmettez l’historique dans l’ordre.                                                                         |
| `messages[].role`                      | string                   | Oui                       | Placez vidéo et question dans `user` ; vous pouvez aussi définir `system` comme instructions.                  |
| `messages[].content`                   | array                    | Oui                       | Une requête vidéo utilise un tableau de contenu ; ne le sérialisez pas en une seule chaîne.                    |
| `content[].type`                       | string                   | Oui                       | `video_url` pour la vidéo et `text` pour la question ; des images `image_url` peuvent être ajoutées.           |
| `content[].video_url.url`              | string                   | Obligatoire pour la vidéo | URL de fichier vidéo accessible au modèle, pas un chemin local ni une page de partage.                         |
| `content[].text`                       | string                   | Obligatoire pour le texte | Tâche d’analyse à effectuer.                                                                                   |
| `stream`                               | boolean                  | Non                       | L’exemple utilise `false`, `true` demande une analyse SSE.                                                     |
| `max_tokens`                           | integer                  | Non                       | Limite de sortie, 4096 tokens ici. Entrée et limite de sortie doivent tenir dans le contexte de 524288 tokens. |
| `chat_template_kwargs.enable_thinking` | boolean                  | Non                       | Par défaut, `true` ; `false` désactive le raisonnement approfondi ; l’exemple l’active explicitement.          |
| `stop`                                 | string\[]                | Non                       | Tableau de séquences d’arrêt mettant fin à la génération en cas de correspondance.                             |
| `tools` / `tool_choice`                | array / string or object | Non                       | Définitions de fonctions et sélection d’outils ; l’exemple analyse seulement la vidéo, sans outil.             |

L’URL publique est transmise à Dots pour téléchargement. Utilisez une adresse que vous avez le droit de rendre lisible au service ; prévoyez une durée suffisante pour une URL signée et n’y incluez pas d’identifiants de connexion. Une page de partage Xiaohongshu n’est pas un lien direct vers un fichier vidéo.

## Valeur de retour

HTTP 200 renvoie un JSON Chat Completions. La structure suivante est illustrative ; contenu, ID et utilisation ne sont pas des résultats de test.

| Champ                                            | Type               | Description                                                                                                                     |
| ------------------------------------------------ | ------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| `id` / `object`                                  | string             | Identifiant de requête ; sans streaming, `object` vaut `chat.completion`.                                                       |
| `created` / `model`                              | integer / string   | Heure Unix en secondes et modèle de réponse.                                                                                    |
| `choices[].index`                                | integer            | Index du candidat.                                                                                                              |
| `choices[].message.role`                         | string             | Le message assistant est `assistant`.                                                                                           |
| `choices[].message.content`                      | string             | Réponse textuelle finale.                                                                                                       |
| `choices[].message.reasoning_content`            | string, facultatif | Contenu de raisonnement éventuellement renvoyé lorsqu’il est activé ; à traiter séparément de la réponse finale.                |
| `choices[].finish_reason`                        | string             | `stop` indique une fin normale ; `length` indique une troncature ; `tool_calls` demande l’exécution d’outils par l’application. |
| `usage.prompt_tokens`                            | integer            | Tokens d’entrée, la vidéo étant comptée selon les règles multimodales du service.                                               |
| `usage.completion_tokens` / `usage.total_tokens` | integer            | Utilisation générée et totale.                                                                                                  |
| `system_fingerprint`                             | string, facultatif | Identifiant système du serveur, éventuellement chaîne vide.                                                                     |

```json
{
  "id": "dots_video_example",
  "object": "chat.completion",
  "created": 1793500000,
  "model": "dots3-note-prev",
  "choices": [{
    "index": 0,
    "message": {"role": "assistant", "content": "视频先展示室外场景，随后人物走入画面。"},
    "finish_reason": "stop"
  }],
  "usage": {"prompt_tokens": 1200, "completion_tokens": 100, "total_tokens": 1300}
}
```

Le streaming utilise les ajouts Chat Completions ; lisez le texte dans `choices[].delta.content` et cumulez le raisonnement séparément. Gérez séparation des événements SSE, état final et fin du flux ; une lecture réseau ne correspond pas forcément à un événement complet. Une interruption ou `length` ne constitue pas une réponse complète.

## Exemples de code

Définissez `DOTS_API_KEY` et `VIDEO_URL`. `VIDEO_URL` doit être une URL HTTP(S) de fichier vidéo directement lisible par le modèle ; aucun des quatre exemples ne télécharge d’abord la vidéo localement. `DOTS_BASE_URL` est facultatif, par défaut `https://note3-prev-api.askdiandian.com`, sans `/v1` dans la racine ; modifiez-le uniquement pour un proxy natif autorisé ou un test local.

Python 3, Node.js 18+ et Go utilisent leurs bibliothèques standard ; curl nécessite Python 3 pour produire le JSON de manière sûre et vérifier la réponse. Attente maximale de 300 secondes, sans nouvelle tentative automatique. Les exemples n’affichent le texte que si `finish_reason=stop` et si la réponse n’est pas vide.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, urllib.error, urllib.parse, urllib.request
    key, video = os.environ.get("DOTS_API_KEY"), os.environ.get("VIDEO_URL")
    if not key or not video: raise SystemExit("请设置 DOTS_API_KEY 和 VIDEO_URL")
    url = urllib.parse.urlsplit(video)
    if url.scheme not in ("http", "https") or not url.hostname or url.username is not None or url.password is not None:
        raise SystemExit("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址")
    body = {"model": "dots3-note-prev", "messages": [{"role": "user", "content": [
        {"type": "video_url", "video_url": {"url": video}},
        {"type": "text", "text": "概括视频内容，并按顺序列出关键事件。"}
    ]}], "stream": False, "max_tokens": 4096, "chat_template_kwargs": {"enable_thinking": True}}
    base = os.environ.get("DOTS_BASE_URL", "https://note3-prev-api.askdiandian.com").rstrip("/")
    request = urllib.request.Request(base + "/v1/chat/completions", data=json.dumps(body).encode(),
        headers={"api-key": key, "Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=300) as response: result = json.load(response)
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop": raise RuntimeError("视频分析未正常完成")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip(): raise RuntimeError("响应没有最终文字答案")
    print(answer)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const key = process.env.DOTS_API_KEY, video = process.env.VIDEO_URL;
      if (!key || !video) throw new Error("请设置 DOTS_API_KEY 和 VIDEO_URL");
      const url = new URL(video);
      if (!["http:", "https:"].includes(url.protocol) || !url.hostname || url.username || url.password)
        throw new Error("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址");
      const body = {model:"dots3-note-prev",messages:[{role:"user",content:[
        {type:"video_url",video_url:{url:video}},
        {type:"text",text:"概括视频内容，并按顺序列出关键事件。"}
      ]}],stream:false,max_tokens:4096,chat_template_kwargs:{enable_thinking:true}};
      const base = (process.env.DOTS_BASE_URL || "https://note3-prev-api.askdiandian.com").replace(/\/$/, "");
      const response = await fetch(base + "/v1/chat/completions", {method:"POST",
        headers:{"api-key":key,"Content-Type":"application/json"},body:JSON.stringify(body),signal:AbortSignal.timeout(300000)});
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json(), choice = result.choices?.[0];
      if (choice?.finish_reason !== "stop") throw new Error("视频分析未正常完成");
      const answer = choice.message?.content;
      if (typeof answer !== "string" || !answer.trim()) throw new Error("响应没有最终文字答案");
      console.log(answer);
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${DOTS_API_KEY:?请设置 DOTS_API_KEY}"
    : "${VIDEO_URL:?请设置 VIDEO_URL}"
    request=$(mktemp)
    response=$(mktemp)
    trap 'rm -f "$request" "$response"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import json, os, urllib.parse
    video = os.environ["VIDEO_URL"]
    url = urllib.parse.urlsplit(video)
    if url.scheme not in ("http", "https") or not url.hostname or url.username is not None or url.password is not None:
        raise SystemExit("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址")
    print(json.dumps({"model":"dots3-note-prev","messages":[{"role":"user","content":[
        {"type":"video_url","video_url":{"url":video}},
        {"type":"text","text":"概括视频内容，并按顺序列出关键事件。"}
    ]}],"stream":False,"max_tokens":4096,"chat_template_kwargs":{"enable_thinking":True}}))
    PY_BODY
    base="${DOTS_BASE_URL:-https://note3-prev-api.askdiandian.com}"
    curl "${base%/}/v1/chat/completions" \
      --fail-with-body \
      --connect-timeout 20 \
      --max-time 300 \
      -H "api-key: $DOTS_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "@$request" \
      --output "$response"
    python3 - "$response" <<'PY_ANSWER'
    import json, sys
    with open(sys.argv[1]) as source: result = json.load(source)
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop": raise RuntimeError("视频分析未正常完成")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip(): raise RuntimeError("响应没有最终文字答案")
    print(answer)
    PY_ANSWER
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import ("bytes"; "encoding/json"; "fmt"; "io"; "net/http"; "net/url"; "os"; "strings"; "time")
    func check(err error) { if err != nil { panic(err) } }
    func main() {
     key,video:=os.Getenv("DOTS_API_KEY"),os.Getenv("VIDEO_URL")
     if key=="" || video=="" {panic("请设置 DOTS_API_KEY 和 VIDEO_URL")}
     parsed,err:=url.Parse(video);check(err)
     if (parsed.Scheme!="http" && parsed.Scheme!="https") || parsed.Hostname()=="" || parsed.User!=nil {panic("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址")}
     body:=map[string]any{"model":"dots3-note-prev","messages":[]any{map[string]any{"role":"user","content":[]any{
     map[string]any{"type":"video_url","video_url":map[string]string{"url":video}},
     map[string]string{"type":"text","text":"概括视频内容，并按顺序列出关键事件。"},
     }}},"stream":false,"max_tokens":4096,"chat_template_kwargs":map[string]bool{"enable_thinking":true}}
     data,err:=json.Marshal(body);check(err)
     base:=os.Getenv("DOTS_BASE_URL");if base=="" {base="https://note3-prev-api.askdiandian.com"}
     req,err:=http.NewRequest("POST",strings.TrimRight(base,"/")+"/v1/chat/completions",bytes.NewReader(data));check(err)
     req.Header.Set("api-key",key);req.Header.Set("Content-Type","application/json")
     res,err:=(&http.Client{Timeout:300*time.Second}).Do(req);check(err);defer res.Body.Close()
     raw,err:=io.ReadAll(res.Body);check(err)
     if res.StatusCode<200 || res.StatusCode>=300 {panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw))}
     var result struct {Choices []struct {Finish string `json:"finish_reason"`;Message struct {Content string `json:"content"`} `json:"message"`} `json:"choices"`}
     check(json.Unmarshal(raw,&result))
     if len(result.Choices)==0 || result.Choices[0].Finish!="stop" {panic("视频分析未正常完成")}
     answer:=result.Choices[0].Message.Content;if strings.TrimSpace(answer)=="" {panic("响应没有最终文字答案")};fmt.Println(answer)
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

| Statut HTTP | Signification officielle                   | Traitement                                                                                  |
| ----------- | ------------------------------------------ | ------------------------------------------------------------------------------------------- |
| 400         | Paramètres ou JSON incorrects              | Vérifiez tableau multimodal, URL vidéo, modèle et longueur du contexte                      |
| 401         | Clé API absente ou invalide                | Vérifiez la clé Dots et `api-key` comme en-tête                                             |
| 403         | Clé non autorisée à accéder à la ressource | Vérifiez les autorisations de la plateforme                                                 |
| 429         | Requêtes trop fréquentes                   | Réduisez la concurrence et limitez les tentatives avec attente progressive                  |
| 500         | Erreur interne du service                  | Conservez le corps d’erreur expurgé et l’identifiant de réponse, sans tentatives illimitées |

HTTP 200 ne garantit pas un résultat complet ; vérifiez encore `finish_reason` et la réponse textuelle. Pour une URL expirée ou un échec de téléchargement/décodage, diagnostiquez le corps d’erreur réel sans conclure à tort à un échec d’authentification. Un délai client dépassé ne garantit pas l’absence d’exécution ; évitez une consommation doublée avant de soumettre à nouveau.

## Références officielles

[Dots API \: entrée vidéo](https\://dots.ai/platform/docs#video-input), [Paramètres de requête](https\://dots.ai/platform/docs#request-parameters), [Authentification](https\://dots.ai/platform/docs#authentication) et [États de réponse](https\://dots.ai/platform/docs#error-codes).