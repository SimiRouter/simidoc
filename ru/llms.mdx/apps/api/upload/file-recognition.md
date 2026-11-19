# Распознавание содержимого файлов

## Описание интерфейса

`POST /v1/responses` позволяет передавать файл поддерживаемой модели через элемент input\_file. Распознавание не является файловым хранилищем и не гарантирует полноту или точность OCR.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $SIMIROUTER_API_KEY`. Прямой OpenAI — `https://api.openai.com`; также Bearer, но нужен ключ OpenAI. Выберите доступную модель с поддержкой требуемой функции.

На шлюзе конечные точки `/v1/files` для загрузки, получения и удаления не реализованы. Здесь PDF передается встроенным Base64 без Files API. При прямом доступе можно сначала загрузить файл и сослаться на file\_id, но официальный file\_id не обязательно доступен шлюзу.

## Параметры запроса

| Поле                     | Тип     | Обязателен  | Описание                                                                                                                                                                                          |
| ------------------------ | ------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                    | string  | Да          | ID модели с поддержкой PDF и необходимых визуальных возможностей.                                                                                                                                 |
| input\[].role            | string  | Да          | Здесь user.                                                                                                                                                                                       |
| input\[].content\[].type | string  | Да          | input\_text для вопроса; input\_file для файла.                                                                                                                                                   |
| input\_text.text         | string  | Да          | Задача по файлу\: резюме, извлечение полей или ответы на вопросы.                                                                                                                                 |
| input\_file.filename     | string  | При условии | Имя встроенного файла с настоящим расширением.                                                                                                                                                    |
| input\_file.file\_data   | string  | При условии | Base64-данные PDF; код на странице использует префикс data\:application/pdf;base64,... . Официальная спецификация требует только Base64 — уберите префикс data\:..., если канал его не принимает. |
| input\_file.file\_id     | string  | При условии | ID после официальной загрузки; требует поддержки Files в соответствующем сервисе.                                                                                                                 |
| input\_file.file\_url    | string  | При условии | Доступный провайдеру URL; выберите его или встроенные данные.                                                                                                                                     |
| max\_output\_tokens      | integer | Нет         | Лимит вывода модели.                                                                                                                                                                              |
| stream                   | boolean | Нет         | true включает SSE Responses.                                                                                                                                                                      |

Не передавайте локальный путь как file\_url и не заполняйте одновременно file\_data, file\_id и file\_url. Размер запроса должен соответствовать ограничениям шлюза и провайдера. Base64 больше исходного файла, а изображения страниц PDF дополнительно расходуют входные токены.

### Структура запроса

BASE64\_PDF\_BYTES — Base64 исходного PDF; примеры четырех языков читают PDF\_PATH и подставляют данные.

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

## Ответ

Файловый ввод не возвращает отдельный ID задачи обработки; ответ — стандартный объект Responses.

| Поле                                                 | Тип              | Описание                                                                                                                      |
| ---------------------------------------------------- | ---------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| id / object                                          | string           | ID ответа; object=response.                                                                                                   |
| created\_at / model                                  | integer / string | Время Unix в секундах и модель.                                                                                               |
| status                                               | string           | completed, incomplete, failed, queued, in\_progress или cancelled; эти состояния возможны и в потоковых, и в фоновых ответах. |
| output\[]                                            | array            | Типизированные message, reasoning, function\_call, web\_search\_call и другие\: нельзя фиксировать output\[0].                |
| output\[].type / id / status                         | string           | Тип элемента, ID и статус при наличии.                                                                                        |
| output\[].role                                       | string           | У сообщения обычно assistant.                                                                                                 |
| output\[].content\[]                                 | array            | Содержимое сообщения\: текст output\_text, отказ refusal.                                                                     |
| output\[].content\[].text / annotations              | string / array   | Текст и аннотации, включая ссылки.                                                                                            |
| output\[].call\_id / name / arguments                | string           | ID связи, имя функции и JSON-строка аргументов function\_call.                                                                |
| error                                                | object / null    | Ошибка; при успехе обычно null.                                                                                               |
| incomplete\_details                                  | object / null    | Причина неполноты, например max\_output\_tokens; не считать полным успехом.                                                   |
| usage.input\_tokens / output\_tokens / total\_tokens | integer          | Входные, выходные и общие токены.                                                                                             |
| usage.\*\_tokens\_details                            | object           | Необязательные детали кеша и рассуждений.                                                                                     |

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

Chat Completions также поддерживает PDF-ввод через `type=file` с вложенными file.filename/file\_data, но это не структура input\_file Responses. Произвольные TXT, таблицы и архивы в Base64 поддерживаются не всеми API. Текст можно декодировать в приложении и отправить как текст; остальные типы сначала сверяйте с возможностями провайдера и модели.

## Примеры вызова

Задайте `SIMIROUTER_API_KEY`, `SIMIROUTER_FILE_MODEL`; `SIMIROUTER_BASE_URL` переопределяет адрес шлюза по умолчанию; не добавляйте в конец `/v1`. `PDF_PATH` указывает на существующий локальный файл. Python 3, Node.js 18+ и Go используют стандартную библиотеку; curl формирует JSON через Python 3.

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

## Коды ошибок

| Статус HTTP | Значение или тип ошибки провайдера       | Действие                                                                          |
| ----------- | ---------------------------------------- | --------------------------------------------------------------------------------- |
| 400         | Неверный запрос                          | Проверьте обязательные поля, JSON, параметры модели и длину контекста.            |
| 401         | Ошибка аутентификации                    | Проверьте наличие, действительность и принадлежность ключа.                       |
| 403 / 404   | Нет доступа / ресурс не найден           | Проверьте права модели, ID ресурса и URL.                                         |
| 429         | Ограничение частоты или квоты            | Различайте лимит скорости и нехватку квоты по ответу; повтор не восполняет квоту. |
| 500 / 503   | Ошибка сервиса / временная недоступность | Сохраните ID и ограниченно повторите временные сбои с задержкой.                  |

Ошибка OpenAI обычно содержит `error.message`, `error.type`, `error.param`, `error.code`; `param` и `code` могут быть `null`; эти поля необязательны и могут отличаться от HTTP-статуса. Шлюз может вернуть ошибку до провайдера. Поврежденный, защищенный паролем, слишком большой или неподдерживаемый файл необходимо исправить. Не повторяйте тот же ошибочный файл и не выдавайте результат за успешное распознавание.

## Официальные материалы

* [OpenAI\: файловый ввод](https\://developers.openai.com/api/docs/guides/file-inputs)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [OpenAI\: обработка ошибок](https\://developers.openai.com/api/docs/guides/error-codes)