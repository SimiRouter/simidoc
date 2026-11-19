# Понимание видео Dots

## Описание интерфейса

`dots3-note-prev` принимает видео; видео, изображения и вопрос можно объединить в массиве содержимого одного сообщения. Официальный видеопротокол — `POST https://note3-prev-api.askdiandian.com/v1/chat/completions`, заголовок — `api-key: $DOTS_API_KEY`, не авторизация Bearer.

Примеры обращаются напрямую к **официальному сервису Dots**. Это не протокол Gemini `input/steps` и не асинхронная генерация видео. Через SimiRouter проверьте передачу расширения моделью и каналом; замены домена и ключа недостаточно.

* `stream: false`\: ожидание полного JSON; финальный ответ в `choices[].message.content`.
* `stream: true`\: получение текста через SSE. Обработка видео может задерживать первый токен; задайте достаточный тайм-аут клиента.
* Видео должно быть URL файла, читаемым моделью. Официальный пример не указывает Base64, `ms://`, частоту кадров, максимальную длительность или фиксированный объём; эти способы здесь не считаются подтверждёнными.

## Параметры запроса

Тело запроса `application/json`.

| Поле                                   | Тип                      | Обязателен             | Описание                                                                                                    |
| -------------------------------------- | ------------------------ | ---------------------- | ----------------------------------------------------------------------------------------------------------- |
| `model`                                | string                   | Да                     | Модель официального примера `dots3-note-prev`.                                                              |
| `messages`                             | array                    | Да                     | Передавайте историю по порядку.                                                                             |
| `messages[].role`                      | string                   | Да                     | Видео и вопрос помещаются в `user`; отдельно допустима инструкция `system`.                                 |
| `messages[].content`                   | array                    | Да                     | Используйте массив содержимого, не сериализуйте в одну строку.                                              |
| `content[].type`                       | string                   | Да                     | `video_url` — видео, `text` — вопрос; можно также добавить изображения `image_url`.                         |
| `content[].video_url.url`              | string                   | Обязательно для видео  | URL файла, доступного модели, не локальный путь или страница сайта.                                         |
| `content[].text`                       | string                   | Обязательно для текста | Задача анализа.                                                                                             |
| `stream`                               | boolean                  | Нет                    | Пример использует `false`, `true` требует разбора SSE.                                                      |
| `max_tokens`                           | integer                  | Нет                    | Максимум выхода, здесь 4096 токенов. Вход и этот предел вместе не должны превышать контекст 524288 токенов. |
| `chat_template_kwargs.enable_thinking` | boolean                  | Нет                    | По умолчанию `true`; `false` отключает глубокое рассуждение; пример явно включает его.                      |
| `stop`                                 | string\[]                | Нет                    | Массив последовательностей остановки.                                                                       |
| `tools` / `tool_choice`                | array / string or object | Нет                    | Функции и выбор инструментов; пример только анализирует видео.                                              |

Публичный URL передаётся Dots для скачивания. Используйте разрешённый для чтения моделью адрес; подписанная ссылка должна действовать достаточно долго и не содержать данные входа. Страница Xiaohongshu не является прямой ссылкой на видеофайл.

## Ответ

HTTP 200 возвращает Chat Completions JSON. Ниже структура, не реальные результаты, ID или использование.

| Поле                                             | Тип                   | Описание                                                                                                      |
| ------------------------------------------------ | --------------------- | ------------------------------------------------------------------------------------------------------------- |
| `id` / `object`                                  | string                | ID запроса; без потока `object` имеет значение `chat.completion`.                                             |
| `created` / `model`                              | integer / string      | Unix в секундах и модель ответа.                                                                              |
| `choices[].index`                                | integer               | Индекс кандидата.                                                                                             |
| `choices[].message.role`                         | string                | Сообщение помощника — `assistant`.                                                                            |
| `choices[].message.content`                      | string                | Итоговый текстовый ответ.                                                                                     |
| `choices[].message.reasoning_content`            | string, необязательно | Возможное рассуждение при включённом режиме; обрабатывайте отдельно.                                          |
| `choices[].finish_reason`                        | string                | `stop` — нормальное завершение; `length` — обрезка; `tool_calls` требует выполнения инструментов приложением. |
| `usage.prompt_tokens`                            | integer               | Входные токены, включая видео по мультимодальным правилам сервиса.                                            |
| `usage.completion_tokens` / `usage.total_tokens` | integer               | Сгенерированные и общие токены.                                                                               |
| `system_fingerprint`                             | string, необязательно | Системный идентификатор сервера, может быть пустой строкой.                                                   |

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

Поток использует приращения Chat Completions; текст читают из `choices[].delta.content`, рассуждение накапливают отдельно. Обрабатывайте границы SSE, конечное состояние и окончание; одно чтение сети не равно событию. Обрыв или `length` не являются полным ответом.

## Примеры вызова

Задайте `DOTS_API_KEY` и `VIDEO_URL`. `VIDEO_URL` должен быть HTTP(S)-файлом видео, читаемым моделью; ни один из четырёх примеров не скачивает видео предварительно локально. `DOTS_BASE_URL` необязателен, по умолчанию `https://note3-prev-api.askdiandian.com`; корень без `/v1`; меняйте только для разрешённого прокси нативного протокола или локального теста.

Python 3, Node.js 18+ и Go используют стандартные библиотеки; curl требует Python 3 для безопасного JSON и проверки результата. До 300 секунд, без автоповтора. Текст выводится только при `finish_reason=stop` и непустом ответе.

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

## Коды ошибок

| Статус HTTP | Официальное значение                   | Обработка                                                           |
| ----------- | -------------------------------------- | ------------------------------------------------------------------- |
| 400         | Ошибка параметров или JSON             | Проверьте мультимодальный массив, URL видео, модель и контекст      |
| 401         | API Key отсутствует или недействителен | Проверьте ключ Dots и `api-key` в заголовке                         |
| 403         | Ключ не имеет доступа к ресурсу        | Проверьте разрешения платформы                                      |
| 429         | Слишком частые запросы                 | Снизьте параллельность, повторяйте ограниченно с задержкой          |
| 500         | Внутренняя ошибка сервиса              | Сохраните обезличенные ошибку и ID ответа, без бесконечных повторов |

HTTP 200 не гарантирует полноты; проверьте `finish_reason` и текст. При истёкшей ссылке, ошибке скачивания или разбора исследуйте реальное тело ошибки, не считайте её ошибкой авторизации. Тайм-аут клиента не гарантирует отсутствие выполнения; учитывайте повторный расход.

## Официальные материалы

[Dots API\: входное видео](https\://dots.ai/platform/docs#video-input), [Параметры запроса](https\://dots.ai/platform/docs#request-parameters), [Аутентификация](https\://dots.ai/platform/docs#authentication) и [Состояния ответа](https\://dots.ai/platform/docs#error-codes).