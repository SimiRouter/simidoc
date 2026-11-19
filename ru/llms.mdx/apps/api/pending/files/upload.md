# Загрузить файл

Загрузить локальный файл и получить ID для других интерфейсов OpenAI.

**SimiRouter пока не поддерживает интерфейс. Ниже — официальный OpenAI API с адресом `api.openai.com`; требуется ключ проекта OpenAI, не SimiRouter.**

## Описание интерфейса

* **Метод**\: `POST`
* **Адрес API**\: `/v1/files`
* **Аутентификация**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Тип запроса**\: `multipart/form-data`.

HTTP возвращает объект файла, не завершение зависимых обучения, пакета или индексации. До 512 МБ на файл; вход Batch ограничен 200 МБ, данные дообучения должны быть JSONL. Пусть клиент сам создаёт multipart boundary.

## Параметры запроса

| Параметры       | Тип    | Обязателен | Описание                                                                                                                                                                       |
| --------------- | ------ | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `file`          | binary | Да         | Сам файл, не строка с именем.                                                                                                                                                  |
| `purpose`       | string | Да         | Назначение\: `assistants`, `batch`, `fine-tune`, `vision`, `user_data` или `evals`.                                                                                            |
| `expires_after` | object | Нет        | Политика истечения; `anchor` всегда `created_at`, `seconds` — от 3600 до 2592000. Без настройки batch-файлы истекают через 30 дней, остальные сохраняются до ручного удаления. |

## Ответ

| Поле             | Тип                                    | Описание                                                                                                                      |
| ---------------- | -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `id`             | string                                 | ID файла для дальнейших обращений.                                                                                            |
| `object`         | string                                 | Всегда `file`.                                                                                                                |
| `bytes`          | integer / null                         | Размер в байтах; может быть null, если ещё неизвестен.                                                                        |
| `created_at`     | integer                                | Время создания, Unix в секундах.                                                                                              |
| `filename`       | string                                 | Имя при загрузке.                                                                                                             |
| `purpose`        | string                                 | Назначение файла, например `fine-tune`, `user_data`; выходные файлы могут использовать `fine-tune-results` и другие значения. |
| `expires_at`     | integer / null, необязательно          | Время истечения, Unix в секундах; может отсутствовать без политики срока хранения.                                            |
| `status`         | string, устарело                       | Старое поле состояния\: `uploaded`, `processed` или `error`. Не заменяет состояние обработки потребляющей точки.              |
| `status_details` | string / null, необязательно, устарело | Старое описание состояния; ошибки проверки данных дообучения читайте в поле задачи `error`.                                   |

Пример ответа (ID и время лишь иллюстрируют структуру)\:

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

## Примеры вызова

Требования\: Python 3, Node.js 20+, curl или Go 1.20+. Сохраните пример языка в файл `.py`, `.cjs`, `.sh`, `.go` и запустите.

Пример загружает JSONL для дообучения. Сначала задайте `OPENAI_API_KEY` и `INPUT_FILE`; данные должны соответствовать методу дообучения. Сама загрузка не запускает обучение.

Для наглядного multipart пример читает файл в память; большие файлы загружайте потоком.

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

## Коды ошибок

Ниже приведены распространённые HTTP-ошибки прямого официального OpenAI API, не состояние поддержки SimiRouter.

| HTTP-статус   | Значение                                                      | Действие                                                                                                                  |
| ------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `400`         | Некорректный параметр, назначение файла или состояние ресурса | Прочитайте `error.message` и `error.param`, исправьте и отправьте повторно.                                               |
| `401`         | Ключ отсутствует или недействителен                           | Проверьте ключ OpenAI и его проект.                                                                                       |
| `403`         | Нет доступа к проекту или ресурсу                             | Проверьте права проекта, организации и роли.                                                                              |
| `404`         | Файл, задача или модель не найдены                            | Проверьте ID и используйте ключ проекта-владельца ресурса.                                                                |
| `429`         | Лимит частоты или нехватка средств                            | Различайте частоту и средства\: при ограничении частоты ждите, при нехватке средств не повторяйте отправку.               |
| `500` / `503` | Сбой сервера или временная недоступность                      | Сохраните ID запроса; перед повторной записью проверьте, не создан ли ресурс, чтобы не дублировать загрузку или обучение. |

Неуспешные ответы обычно содержат `error.message`, `error.type`, `error.param` и `error.code`; поля могут быть пустыми.

## Официальные материалы

* [Загрузка файлов OpenAI](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [Коды ошибок OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)