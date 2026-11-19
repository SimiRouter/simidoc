# Понимание медиа Gemini

## Описание интерфейса

`POST /v1beta/models/{model}:generateContent` сочетает текст и медиа в parts и возвращает описание, транскрипцию или анализ. Понимание медиа не генерирует и не редактирует изображения.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $SIMIROUTER_API_KEY`. Официальный Google доступен по `https://generativelanguage.googleapis.com`, обычно с `x-goog-api-key: $GEMINI_API_KEY`, а не Bearer-ключом шлюза. Выберите доступную модель с нужными возможностями.

Пример читает локальный файл и отправляет встроенные данные без сторонних URL и Files API; скрипты сопоставляют распространенные расширения изображений, аудио, видео и PDF с MIME-типами. Аудио, видео и PDF требуют правильного MIME и поддерживающей модели; недостаточно переименовать расширение в картинку.

## Быстрый старт

1. **Подготовьте конфигурацию**\: создайте ключ в разделе Управление API-ключами и скопируйте полный ID модели, поддерживающей нужный тип медиа, из раздела Модели и цены.
2. **Подготовьте материал**\: выберите разрешённое изображение, аудио, видео или PDF и определите реальный MIME-тип.
3. **Отправьте минимальный запрос**\: закодируйте байты файла в чистый Base64 в поле `inlineData.data`, а текстовый вопрос поместите в те же `parts`; сначала проверьте на одном изображении.
4. **Прочитайте результат**\: запрос успешен, только если HTTP 2xx и `candidates[]` не пуст; текст анализа находится в `candidates[0].content.parts[].text`.
5. **Проверьте**\: сверьте `finishReason` и основания вывода; в критичных случаях требуется ручная проверка.

Изображение нужно сначала закодировать в Base64; минимальный рабочий скрипт приведён в разделе «Примеры вызова» ниже, не собирайте длинные строки Base64 вручную.

## Параметры запроса

| Поле                               | Тип            | Обязателен  | Описание                                                                                |
| ---------------------------------- | -------------- | ----------- | --------------------------------------------------------------------------------------- |
| model (в пути)                     | string         | Да          | ID модели с поддержкой требуемого медиа.                                                |
| contents\[].parts\[].text          | string         | При условии | Вопрос вместе с медиа.                                                                  |
| contents\[].parts\[].inlineData    | object         | При условии | Встроенные данные с mimeType/data; один Part не может одновременно иметь text/fileData. |
| inlineData.mimeType                | string         | Да          | Реальный MIME\: image/png, image/jpeg, audio/mpeg, video/mp4 или application/pdf.       |
| inlineData.data                    | string         | Да          | Чистый Base64 файла без data\: и без локального пути.                                   |
| contents\[].parts\[].fileData      | object         | При условии | Альтернативный источник с mimeType/fileUri\: разрешенный и доступный провайдеру URI.    |
| contents\[].role                   | string         | Нет         | В одном запросе обычно user.                                                            |
| generationConfig.maxOutputTokens   | integer        | Нет         | Лимит выходных токенов.                                                                 |
| systemInstruction / safetySettings | object / array | Нет         | Системные инструкции и безопасность.                                                    |

В одном Part выбирайте один тип. Для больших файлов используйте официальный ввод файлов\: не предполагается, что шлюз реализует загрузку и опрос Google Files. Base64 увеличивает тело; соблюдайте ограничения шлюза, провайдера и модели.

### Структура запроса

BASE64\_MEDIA\_BYTES обозначает байты файла; примеры на четырех языках создают их из локального файла.

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

## Ответ

| Поле                                  | Тип            | Описание                                                                                            |
| ------------------------------------- | -------------- | --------------------------------------------------------------------------------------------------- |
| candidates\[]                         | array          | Кандидаты\: при блокировке могут отсутствовать.                                                     |
| candidates\[].index                   | integer        | Индекс кандидата.                                                                                   |
| candidates\[].content.role / parts\[] | string / array | Роль и части результата; текст обычно в parts\[].text.                                              |
| candidates\[].finishReason            | string         | STOP — завершение, MAX\_TOKENS — лимит; SAFETY, RECITATION и другие причины обрабатывайте отдельно. |
| candidates\[].safetyRatings           | array          | Необязательная оценка безопасности.                                                                 |
| candidates\[].groundingMetadata       | object         | Источники и ссылки при использовании grounding, например поиска.                                    |
| promptFeedback.blockReason            | string         | Причина блокировки ввода, кандидатов может не быть.                                                 |
| usageMetadata.promptTokenCount        | integer        | Входные токены.                                                                                     |
| usageMetadata.candidatesTokenCount    | integer        | Выходные токены кандидатов.                                                                         |
| usageMetadata.thoughtsTokenCount      | integer        | Необязательные токены рассуждений, не отображаемый текст.                                           |
| usageMetadata.totalTokenCount         | integer        | Всего токенов, включая возможные инструменты и рассуждения.                                         |
| modelVersion / responseId             | string         | Необязательные версия модели и ID ответа.                                                           |

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

Для потока используйте streamGenerateContent?alt=sse и объединяйте по индексам кандидатов. Не все parts являются текстом. Медицинские, идентификационные и другие высокорисковые выводы модели требуют ручной проверки.

## Примеры вызова

Задайте `SIMIROUTER_API_KEY`, `SIMIROUTER_GEMINI_MODEL`; `SIMIROUTER_BASE_URL` переопределяет адрес шлюза по умолчанию; не добавляйте в конец `/v1`. `MEDIA_PATH` указывает на существующий локальный файл. Python 3, Node.js 18+ и Go используют стандартную библиотеку; curl формирует JSON через Python 3.

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

## Коды ошибок

| Статус HTTP | Значение или тип ошибки провайдера | Действие                                                                    |
| ----------- | ---------------------------------- | --------------------------------------------------------------------------- |
| 400         | `INVALID_ARGUMENT` и другие        | Проверьте JSON, параметры модели, MIME и длину ввода.                       |
| 403         | `PERMISSION_DENIED`                | Проверьте ключ, права проекта, регион и платежные ограничения.              |
| 404         | `NOT_FOUND`                        | Проверьте имя модели и версию API.                                          |
| 429         | `RESOURCE_EXHAUSTED`               | Проверьте частоту и квоту; для повторяемых ошибок ограничьте число попыток. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`         | Сохраните ID запроса и повторите ограниченно либо позже.                    |

Ошибка Google содержит `error.code` (HTTP-число), `error.status` (имя перечисления), `error.message`; возможны также `details`. Шлюз может отклонить аутентификацию, маршрут или квоту до провайдера; одного HTTP-статуса недостаточно, чтобы считать ошибку вышестоящей.

Длинные ответы и потоковые запросы могут длиться от десятков секунд до нескольких минут; задайте достаточный тайм-аут клиента и при обрыве потока оценивайте полученные фрагменты и причину завершения, а не отправляйте запрос повторно автоматически. При 429 и 5xx сначала проверьте тело ответа и журнал использования; при отказе по политике содержимого измените запрос или входные данные, а не повторяйте запрос без изменений.

## Официальные материалы

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google\: понимание изображений](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Google\: понимание аудио](https\://ai.google.dev/gemini-api/docs/audio)
* [Google\: понимание видео](https\://ai.google.dev/gemini-api/docs/video-understanding)
* [Google\: понимание PDF](https\://ai.google.dev/gemini-api/docs/document-processing)
* [Google\: диагностика ошибок](https\://ai.google.dev/gemini-api/docs/troubleshooting)