# Отменить задачу дообучения

Запросить остановку указанной задачи OpenAI.

**SimiRouter пока не поддерживает интерфейс. Ниже — официальный OpenAI API с адресом `api.openai.com`; требуется ключ проекта OpenAI, не SimiRouter.**

## Описание интерфейса

* **Метод**\: `POST`
* **Адрес API**\: `/v1/fine_tuning/jobs/{fine_tuning_job_id}/cancel`
* **Аутентификация**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Тип запроса**\: без тела.

Возвращает объект задачи. Проверяйте результат по `status`; не отменяйте повторно уже успешную, неуспешную или отменённую задачу.

## Параметры запроса

| Параметры            | Тип          | Обязателен | Описание                                              |
| -------------------- | ------------ | ---------- | ----------------------------------------------------- |
| `fine_tuning_job_id` | string, путь | Да         | ID задачи, код читает из `OPENAI_FINE_TUNING_JOB_ID`. |

## Ответ

| Поле               | Тип                           | Описание                                                                                                     |
| ------------------ | ----------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `id` / `object`    | string                        | ID задачи; тип объекта всегда `fine_tuning.job`.                                                             |
| `model`            | string                        | Базовая модель обучения.                                                                                     |
| `status`           | string                        | `validating_files`, `queued`, `running`, `pausing`, `paused`, `succeeded`, `failed` или `cancelled`.         |
| `created_at`       | integer                       | Время создания, Unix в секундах.                                                                             |
| `finished_at`      | integer / null                | Время окончания; пусто до завершения.                                                                        |
| `estimated_finish` | integer / null, необязательно | Ожидаемое время окончания, не гарантия.                                                                      |
| `fine_tuned_model` | string / null                 | ID полученной модели; пусто до её появления.                                                                 |
| `training_file`    | string                        | ID обучающего файла.                                                                                         |
| `validation_file`  | string / null                 | ID файла валидации; пусто, если не задан.                                                                    |
| `result_files`     | string\[]                     | ID выходных файлов, скачиваемых официальным Files API.                                                       |
| `trained_tokens`   | integer / null                | Число оплачиваемых токенов обучения; в процессе может отсутствовать.                                         |
| `error`            | object / null                 | Подробности ошибки, включая `code`, `message`, `param`; для ошибки не в параметре `param` может быть пустым. |
| `organization_id`  | string                        | Организация задачи.                                                                                          |
| `seed`             | integer / null                | Начальное значение генератора случайных чисел обучения.                                                      |
| `method`           | object / null, необязательно  | Метод дообучения и его настройки.                                                                            |
| `hyperparameters`  | object / null, необязательно  | Совместимое поле гиперпараметров обучения с учителем.                                                        |
| `integrations`     | array / null, необязательно   | Включённые внешние интеграции метрик.                                                                        |
| `metadata`         | object / null, необязательно  | Пользовательские пары ключ-значение задачи.                                                                  |

Пример ответа (главные поля)\:

```json
{
  "id": "ftjob-demo",
  "object": "fine_tuning.job",
  "model": "selected-base-model",
  "created_at": 1793491200,
  "finished_at": 1793491800,
  "fine_tuned_model": null,
  "status": "cancelled",
  "training_file": "file-training",
  "validation_file": null,
  "result_files": [],
  "trained_tokens": null,
  "error": null,
  "organization_id": "org-demo",
  "seed": null,
  "method": {
    "type": "supervised"
  },
  "metadata": {}
}
```

## Примеры вызова

Требования\: Python 3, Node.js 20+, curl или Go 1.20+. Сохраните пример языка в файл `.py`, `.cjs`, `.sh`, `.go` и запустите.

Задайте `OPENAI_API_KEY` и `OPENAI_FINE_TUNING_JOB_ID`. Выполнение остановит настоящее обучение; сначала проверьте ID. Отмена не удаляет файлы и не отменяет уже израсходованное использование.

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
    job_id = required("OPENAI_FINE_TUNING_JOB_ID")
    job_id_encoded = urllib.parse.quote(job_id, safe="")
    request = urllib.request.Request(
        f"https://api.openai.com/v1/fine_tuning/jobs/{job_id_encoded}/cancel",
        method="POST",
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
      const job_id = required("OPENAI_FINE_TUNING_JOB_ID");
      const jobId = encodeURIComponent(job_id);
      const response = await fetch(`https://api.openai.com/v1/fine_tuning/jobs/${jobId}/cancel`, {
        method: "POST",
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
    : "${OPENAI_FINE_TUNING_JOB_ID:?请设置 OPENAI_FINE_TUNING_JOB_ID}"
    [[ "$OPENAI_FINE_TUNING_JOB_ID" =~ ^[A-Za-z0-9_:-]+$ ]] || { printf '%s\n' '资源 ID 格式错误' >&2; exit 1; }
    curl "https://api.openai.com/v1/fine_tuning/jobs/${OPENAI_FINE_TUNING_JOB_ID}/cancel" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request POST \
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
    	job_id := required("OPENAI_FINE_TUNING_JOB_ID")
    	target := fmt.Sprintf("https://api.openai.com/v1/fine_tuning/jobs/%s/cancel", url.PathEscape(job_id))
    	req, err := http.NewRequest("POST", target, nil)
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

* [Отмена дообучения OpenAI](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/cancel)
* [Коды ошибок OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)