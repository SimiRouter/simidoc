# Список файлов

Постранично получить доступные файлы текущего проекта OpenAI.

**SimiRouter пока не поддерживает интерфейс. Ниже — официальный OpenAI API с адресом `api.openai.com`; требуется ключ проекта OpenAI, не SimiRouter.**

## Описание интерфейса

* **Метод**\: `GET`
* **Адрес API**\: `/v1/files`
* **Аутентификация**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Тип запроса**\: без тела.

Синхронно возвращает JSON текущей страницы; при `has_more=true` нужны следующие запросы. Один вызов не возвращает автоматически все файлы.

## Параметры запроса

| Параметры | Тип                       | Обязателен | Описание                                                        |
| --------- | ------------------------- | ---------- | --------------------------------------------------------------- |
| `after`   | string, параметр запроса  | Нет        | ID последнего файла предыдущей страницы.                        |
| `limit`   | integer, параметр запроса | Нет        | 1–10000 файлов на страницу, по умолчанию 10000; в примере 20.   |
| `order`   | string, параметр запроса  | Нет        | Сортировка по созданию\: `asc` или `desc`, по умолчанию `desc`. |
| `purpose` | string, параметр запроса  | Нет        | Только файлы заданного назначения.                              |

## Ответ

| Поле                   | Тип           | Описание                                   |
| ---------------------- | ------------- | ------------------------------------------ |
| `object`               | string        | Тип списка, обычно `list`.                 |
| `data`                 | FileObject\[] | Файлы текущей страницы; поля описаны ниже. |
| `first_id` / `last_id` | string        | ID первого и последнего файлов страницы.   |
| `has_more`             | boolean       | Есть ли следующая страница.                |

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

```json
{
  "object": "list",
  "data": [
    {
      "id": "file-demo",
      "object": "file",
      "bytes": 4096,
      "created_at": 1793491200,
      "filename": "training.jsonl",
      "purpose": "fine-tune",
      "expires_at": null
    }
  ],
  "first_id": "file-demo",
  "last_id": "file-demo",
  "has_more": false
}
```

## Примеры вызова

Требования\: Python 3, Node.js 20+, curl или Go 1.20+. Сохраните пример языка в файл `.py`, `.cjs`, `.sh`, `.go` и запустите.

Задайте `OPENAI_API_KEY`. Пример получает первые 20; для следующей страницы передайте предыдущий `last_id` как `after` в параметрах запроса.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    def required(name):
        value = os.environ.get(name)
        if not value:
            raise SystemExit(f"请设置 {name}")
        return value

    key = required("OPENAI_API_KEY")

    request = urllib.request.Request(
        "https://api.openai.com/v1/files?limit=20&order=desc",
        method="GET",
        data=None,
        headers={"Authorization": "Bearer " + key},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = response.read()
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    print(json.dumps(json.loads(result), ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    function required(name) {
      const value = process.env[name];
      if (!value) throw new Error(`请设置 ${name}`);
      return value;
    }
    async function main() {
      const key = required("OPENAI_API_KEY");

      const response = await fetch("https://api.openai.com/v1/files?limit=20&order=desc", {
        method: "GET",
        headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(120000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(JSON.stringify(await response.json(), null, 2));
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${OPENAI_API_KEY:?请设置 OPENAI_API_KEY}"

    curl "https://api.openai.com/v1/files?limit=20&order=desc" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request GET \
      --header "Authorization: Bearer $OPENAI_API_KEY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"fmt"
    	"io"
    	"log"
    	"net/http"
    	"os"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func required(name string) string {
    	value := os.Getenv(name)
    	if value == "" {
    		log.Fatal("请设置 " + name)
    	}
    	return value
    }
    func main() {
    	key := required("OPENAI_API_KEY")

    	req, err := http.NewRequest("GET", "https://api.openai.com/v1/files?limit=20&order=desc", nil)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	client := &http.Client{Timeout: 120 * time.Second}
    	response, err := client.Do(req)
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

* [Список файлов OpenAI](https\://developers.openai.com/api/reference/resources/files/methods/list)
* [Коды ошибок OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)