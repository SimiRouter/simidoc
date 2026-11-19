# Понимание видео Gemini

## Описание интерфейса

Понимание получает существующее видео и возвращает текст, не генерирует новое. Ниже используется **официальный Google Interactions**\: `POST https://generativelanguage.googleapis.com/v1beta/interactions`, аутентификация — `x-goog-api-key: $GEMINI_API_KEY`. Это не создание Seedance/Kling и не доказательство поддержки всех медиа Google в SimiRouter.

## Параметры запроса

| Поле                | Тип     | Обязателен  | Описание                                                                                   |
| ------------------- | ------- | ----------- | ------------------------------------------------------------------------------------------ |
| model               | string  | Да          | Модель с видео, например gemini-3.8-flash.                                                 |
| input               | array   | Да          | Материал video и вопрос text.                                                              |
| input\[].type       | string  | Да          | video или text.                                                                            |
| input\[].data       | string  | При условии | Base64 короткого видео, на выбор с uri.                                                    |
| input\[].mime\_type | string  | При условии | Например video/mp4, с реальным кодированием.                                               |
| input\[].uri        | string  | При условии | URI загруженного Google-файла в ACTIVE либо поддерживаемый моделью публичный адрес.        |
| input\[].text       | string  | При условии | Резюме, вопрос или конкретный временной диапазон.                                          |
| stream / background | boolean | Нет         | Для длительного анализа возможны поток или фон с соответствующей обработкой событий/задач. |

Пример осторожно использует короткий MP4 с суммарным запросом до 20 МБ. Для больших или повторных видео предпочтителен Google Files API; после загрузки дождитесь ACTIVE, при FAILED остановитесь, без бесконечного опроса. Публичный URL, Cloud Storage и встроенные данные — разные пути, не взаимозаменяемые произвольно.

## Ответ

Поле Interactions `steps[]` содержит model\_output; текстовые элементы — `content[].type=text` и `text`. output\_text SDK — удобное свойство. Временные отметки интерпретирует модель\: сверяйте с оригиналом, не считайте точной экспертизой или покадровой разметкой.

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"00:10 出现海面上的帆船，随后镜头向右移动。"}]}]}
```

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

Подготовьте короткое видео `video.mp4` и задайте официальный Google `GEMINI_API_KEY`. Пример не запускает платную генерацию или управление файлами, но сам инференс может оплачиваться.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")}]}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": (await readFile("video.mp4")).toString("base64")
        }
      ]
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
      --fail-with-body \
      --max-time 180 \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "@$request"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "encoding/base64"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      media, err := os.ReadFile("video.mp4"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/interactions", body); check(err)
      req.Header.Set("x-goog-api-key", "" + os.Getenv("GEMINI_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## Коды ошибок

| Статус HTTP           | Значение и действие                                                                                                                                                          |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Неверные поля, формат файла или параметры модели\: исправьте запрос.                                                                                                         |
| 401                   | Ключ API отсутствует, недействителен или просрочен.                                                                                                                          |
| 403                   | Нет прав проекта или модели.                                                                                                                                                 |
| 404                   | Модель, маршрут или входной ресурс не найдены\: проверьте адрес, ID модели и состояние файла.                                                                                |
| 413 / 415             | Файл слишком велик или тип данных не поддерживается.                                                                                                                         |
| 429                   | Лимит частоты или квоты\: отличайте нехватку средств от временного ограничения с повторами.                                                                                  |
| 500 / 502 / 503 / 504 | Ошибка сервиса или провайдера\: сохраните ID запроса; после тайм-аута синхронного запроса проверьте журнал или состояние перед повтором, чтобы не получить двойное списание. |

Ошибка Google содержит `error.code`, `error.status`, `error.message`; не принимайте тело ошибки за обычный результат анализа.

## Официальные материалы

[Google\: понимание видео](https\://ai.google.dev/gemini-api/docs/video-understanding), [Files](https\://ai.google.dev/gemini-api/docs/files).