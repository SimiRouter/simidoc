# Понимание видео Kimi

## Описание интерфейса

`kimi-k3` нативно понимает видео\: резюмирует, отвечает о сценах и анализирует события. Выход текстовый, без генерации видео, гарантии покадрового распознавания или точного временного выравнивания.

**Адрес API**\: `POST https://api.moonshot.cn/v1/chat/completions`. Используйте ключ Moonshot китайского сайта через `Authorization: Bearer $MOONSHOT_API_KEY`. Международный сайт использует `https://api.moonshot.ai` и международный ключ; аккаунты и ключи нельзя смешивать.

Пример использует **прямой официальный Moonshot API**. Наличие видео у модели не доказывает ту же модель, медиавходы или хранение в SimiRouter; нельзя напрямую переносить ID `ms://` к другому поставщику или шлюзу.

* **Без потока**\: `stream: false`, один HTTP ждёт полного JSON.
* **Поток**\: `stream: true`, то же соединение передаёт SSE с рассуждением и текстом; это не асинхронная генерация видео.
* **Ссылки файлов**\: сначала загрузите файл, затем используйте `ms://<file_id>` в чате; загрузка не заменяет запрос чата.

## Параметры запроса

Тип содержимого — `application/json`.

| Поле                           | Тип                      | Обязателен  | Описание                                                                                                           |
| ------------------------------ | ------------------------ | ----------- | ------------------------------------------------------------------------------------------------------------------ |
| `model`                        | string                   | Да          | Здесь `kimi-k3`, не отображаемое имя или сокращение.                                                               |
| `messages`                     | array                    | Да          | Список сообщений. Пользовательское видео передаётся массивом содержимого.                                          |
| `messages[].role`              | string                   | Да          | Видео и вопрос — в сообщении `user`; отдельно можно задать сообщение `system`.                                     |
| `messages[].content`           | array                    | Да          | Содержит видеоэлемент `video_url` и вопрос `text`; массив нельзя сериализовать строкой.                            |
| `content[].type`               | string                   | Да          | Для видео `video_url`, для текста `text`.                                                                          |
| `content[].video_url.url`      | string                   | При условии | `data:video/mp4;base64,...` или иной data URL с правильным MIME, либо ссылка Moonshot `ms://<file_id>`.            |
| `content[].text`               | string                   | При условии | Нужный анализ\: резюме, порядок событий или вопросы по временному отрезку.                                         |
| `reasoning_effort`             | string                   | Нет         | K3 всегда использует рассуждение; верхнеуровневый `low`, `high` или `max`, по умолчанию `max`.                     |
| `max_completion_tokens`        | integer                  | Нет         | Лимит генерации с бюджетом на рассуждение и ответ; при достижении предела `finish_reason` имеет значение `length`. |
| `stream`                       | boolean                  | Нет         | По умолчанию `false`; `true` возвращает SSE.                                                                       |
| `stream_options.include_usage` | boolean                  | Нет         | Запрашивает статистику до завершения потокового ответа.                                                            |
| `response_format`              | object                   | Нет         | Поддерживаемый структурированный выход; для JSON настройте официальный JSON Mode или JSON Schema.                  |
| `tools` / `tool_choice`        | array / string or object | Нет         | Инструменты допустимы, но в примере видео не включены.                                                             |

K3 не использует параметр K2.x `thinking`. `temperature` всегда `1.0`, `top_p` всегда `0.95`, `n` всегда `1`, штраф повторения фиксирован `0`; лучше опустить поля\: другие значения вызовут ошибку. `max_tokens` — старый параметр; используйте `max_completion_tokens`.

### Ограничения видео

Официальная страница указывает MP4, MPEG, MOV, AVI, FLV, MPG, WebM, WMV, 3GPP и рекомендует не выше 1080p. Тело ограничено официальными 100M; Base64 увеличивает размер, поэтому исходный файл не равен размеру JSON.

Пример использует более осторожный **локальный предел 20 МиБ** — защиту примера, не максимум модели или длительности. Для больших или повторных видео используйте официальный процесс загрузки. Не вписывайте обычную страницу, Xiaohongshu или локальный путь в `video_url.url`; здесь два подтверждённых способа\: Base64 и `ms://`.

### Использование загруженного видео

Вызовите Moonshot `POST /v1/files` с multipart `file` и `purpose=video`, прочитайте возвращённый `id`, затем используйте `{"type":"video_url","video_url":{"url":"ms://<file_id>"}}` в видеоэлементе. Извлечённый текст файла дополнительно читать не требуется.

Официальная загрузка указывает 100 МиБ на файл; для нового протокола следуйте `kimi-api-version`, не переносите его версионные заголовки на Chat Completions. Доступ к ресурсу — с той же платформы и аккаунта; удалите по правилам хранения.

## Ответ

Успех без потока — HTTP 200 JSON структуры Chat Completions.

| Поле                                  | Тип     | Описание                                                                                                              |
| ------------------------------------- | ------- | --------------------------------------------------------------------------------------------------------------------- |
| `id`                                  | string  | Идентификатор завершения.                                                                                             |
| `object`                              | string  | Без потока `chat.completion`.                                                                                         |
| `created`                             | integer | Время создания в секундах Unix.                                                                                       |
| `model`                               | string  | Идентификатор модели ответа.                                                                                          |
| `choices[].index`                     | integer | Индекс кандидата.                                                                                                     |
| `choices[].message.role`              | string  | Сообщение помощника — `assistant`.                                                                                    |
| `choices[].message.content`           | string  | Итоговый анализ видео.                                                                                                |
| `choices[].message.reasoning_content` | string  | Возможное рассуждение, не финальный ответ; не смешивайте с `content`.                                                 |
| `choices[].finish_reason`             | string  | `stop` — нормальное завершение; `length` — предел генерации; `tool_calls` требует выполнения инструмента приложением. |
| `usage.prompt_tokens`                 | integer | Входные токены, включая видео по правилам модели.                                                                     |
| `usage.completion_tokens`             | integer | Выходные токены генерации.                                                                                            |
| `usage.total_tokens`                  | integer | Общее число токенов; возможна детализация кеша и рассуждений.                                                         |

ID, время и использование ниже лишь иллюстрируют структуру, не замеры\:

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

### Разбор потока

В JSON из SSE-строк `data:` `choices[].delta.reasoning_content` — приращение рассуждения, `choices[].delta.content` — текста; дописывайте отдельно, не перезаписывайте. Проверьте финальный `finish_reason` и дождитесь `data: [DONE]`. Со статистикой блок может иметь `choices: []`; читайте верхнеуровневый `usage`, не обращайтесь всегда к `choices[0]`.

Для нескольких ходов сохраняйте полное сообщение assistant, включая `reasoning_content`; в следующем ходе передавайте нужный контекст видео и вопроса. Обрыв или `length` не считаются полным ответом.

## Примеры вызова

Сначала задайте `MOONSHOT_API_KEY` и `VIDEO_FILE`; последнее — реальное локальное видео, разрешённое к загрузке. `VIDEO_MIME` необязателен, по умолчанию `video/mp4`, в соответствии с файлом; пример не преобразует любой файл в MP4. `MOONSHOT_BASE_URL` необязателен, по умолчанию `https://api.moonshot.cn`; корень без `/v1`, для разрешённого прокси или локального mock-теста.

Python 3, Node.js 18+ и Go используют стандартные библиотеки; curl требует Python 3 для JSON и ответа. Все четыре примера ограничивают видео 20 МиБ, задают тайм-аут, отвергают неполные результаты и не повторяют платные запросы автоматически.

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

## Коды ошибок

| Статус HTTP           | Распространённые ошибки                                                               | Действие                                                                                                                |
| --------------------- | ------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 400                   | `invalid_request_error`, `content_filter`                                             | Проверьте массив, Base64/MIME, размер, фиксированные параметры и контекст; адаптируйте вход к требованиям безопасности. |
| 401                   | `invalid_authentication_error`, `incorrect_api_key_error`                             | Проверьте сайт ключа и точки; не смешивайте китайский, международный или SimiRouter Key.                                |
| 403                   | `permission_denied_error`                                                             | Проверьте права модели, список допуска организации и доступность функции.                                               |
| 404                   | `resource_not_found_error`                                                            | Проверьте ID модели, файла и принадлежность ресурса.                                                                    |
| 429                   | `engine_overloaded_error`, `exceeded_current_quota_error`, `rate_limit_reached_error` | Различайте перегрузку сервиса, баланс и ограничение частоты; недостаток средств не устраняется повторами.               |
| 499 / 500 / 503 / 504 | `client_closed_request`, `server_error` и другие                                      | Сохраните ID запроса, проверьте связь и сервис; для долгих запросов возможен SSE.                                       |

Ошибки обычно содержат `error.type` и `error.message`; часть ответов добавляет `error.code`. Тайм-аут не доказывает отсутствия выполнения\: перед повтором проверьте расход; не журналируйте ключ или полный Base64 видео.

## Официальные материалы

* [Kimi K3\: модель и пример видеофайла](https\://platform.kimi.com/docs/guide/kimi-k3-quickstart)
* [Визуальный вход Kimi\: типы видео и ограничения](https\://platform.kimi.com/docs/guide/use-kimi-vision-model)
* [Kimi Chat Completions API\: data URL видео, запрос и ответ](https\://platform.kimi.com/docs/api/chat)
* [Параметры моделей Kimi](https\://platform.kimi.com/docs/api/models-overview)
* [Потоковый вывод Kimi](https\://platform.kimi.com/docs/guide/utilize-the-streaming-output-feature-of-kimi-api)
* [Загрузка файлов Moonshot](https\://platform.kimi.com/docs/api/files-upload)
* [Коды ошибок Kimi](https\://platform.kimi.com/docs/api/errors)