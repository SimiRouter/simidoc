# Удалить файл

Удалить файл из проекта OpenAI и связанных векторных хранилищ.

**SimiRouter пока не поддерживает интерфейс. Ниже — официальный OpenAI API с адресом `api.openai.com`; требуется ключ проекта OpenAI, не SimiRouter.**

## Описание интерфейса

* **Метод**\: `DELETE`
* **Адрес API**\: `/v1/files/{file_id}`
* **Аутентификация**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Тип запроса**\: без тела.

Синхронно возвращает результат удаления. Операция необратима; не используйте её для проверки соединения.

## Параметры запроса

| Параметры | Тип          | Обязателен | Описание                   |
| --------- | ------------ | ---------- | -------------------------- |
| `file_id` | string, путь | Да         | ID файла в проекте OpenAI. |

## Ответ

| Поле      | Тип     | Описание             |
| --------- | ------- | -------------------- |
| `id`      | string  | ID удаляемого файла. |
| `object`  | string  | Всегда `file`.       |
| `deleted` | boolean | Результат удаления.  |

```json
{
  "id": "file-demo",
  "object": "file",
  "deleted": true
}
```

## Примеры вызова

Требования\: Python 3, Node.js 20+, curl или Go 1.20+. Сохраните пример языка в файл `.py`, `.cjs`, `.sh`, `.go` и запустите.

Задайте `OPENAI_API_KEY` и `OPENAI_FILE_ID`. Выполнение действительно удалит файл; заранее сохраните нужную копию и проверьте зависимости.

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
    file_id = required("OPENAI_FILE_ID")
    file_id_encoded = urllib.parse.quote(file_id, safe="")
    request = urllib.request.Request(
        f"https://api.openai.com/v1/files/{file_id_encoded}",
        method="DELETE",
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
      const file_id = required("OPENAI_FILE_ID");
      const fileId = encodeURIComponent(file_id);
      const response = await fetch(`https://api.openai.com/v1/files/${fileId}`, {
        method: "DELETE",
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
    : "${OPENAI_FILE_ID:?请设置 OPENAI_FILE_ID}"
    [[ "$OPENAI_FILE_ID" =~ ^[A-Za-z0-9_:-]+$ ]] || { printf '%s\n' '资源 ID 格式错误' >&2; exit 1; }
    curl "https://api.openai.com/v1/files/${OPENAI_FILE_ID}" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request DELETE \
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
    	"net/url"
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
    	file_id := required("OPENAI_FILE_ID")
    	target := fmt.Sprintf("https://api.openai.com/v1/files/%s", url.PathEscape(file_id))
    	req, err := http.NewRequest("DELETE", target, nil)
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

* [Удаление файла OpenAI](https\://developers.openai.com/api/reference/resources/files/methods/delete)
* [Коды ошибок OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)