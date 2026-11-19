# Создать задачу дообучения

Передать данные и настройки базовой модели для асинхронного дообучения OpenAI.

**SimiRouter пока не поддерживает интерфейс. Ниже — официальный OpenAI API с адресом `api.openai.com`; требуется ключ проекта OpenAI, не SimiRouter.**

OpenAI прекращает самообслуживание дообучения\: новые пользователи не могут создавать задачи, а имеющие право действующие пользователи — только до **6 января 2027 года**, если базовая модель не будет отключена раньше. Перед отправкой проверьте [официальный график](https\://developers.openai.com/api/docs/deprecations).

## Описание интерфейса

* **Метод**\: `POST`
* **Адрес API**\: `/v1/fine_tuning/jobs`
* **Аутентификация**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Тип запроса**\: `application/json`.

Создание возвращает объект задачи, затем обучение выполняется на сервере. `200` или `queued` не означает успеха обучения; используйте [Получить сведения о задаче](/simidoc/ru/apps/api/pending/fine-tuning/retrieve) для проверки конечного `status`, а [Получить события](/simidoc/ru/apps/api/pending/fine-tuning/events) — для прогресса. Путь `/v1/fine_tuning/jobs`, не старый `/v1/fine-tunes`.

## Параметры запроса

| Параметры                           | Тип              | Обязателен | Описание                                                                                                                       |
| ----------------------------------- | ---------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `model`                             | string           | Да         | ID базовой модели, поддерживающей выбранный метод.                                                                             |
| `training_file`                     | string           | Да         | ID JSONL обучающего файла, загруженного с `purpose=fine-tune`.                                                                 |
| `validation_file`                   | string / null    | Нет        | ID отдельного валидационного файла, без совпадений с обучающим набором.                                                        |
| `method`                            | object           | Нет        | `type` имеет значение `supervised`, `dpo` или `reinforcement`, с одноимённым объектом настроек; метод должен подходить модели. |
| `method.supervised.hyperparameters` | object           | Нет        | `batch_size`\: auto или 1–256; `learning_rate_multiplier`\: auto или положительное число; `n_epochs`\: auto или 1–50.          |
| `method.dpo.hyperparameters`        | object           | Нет        | Гиперпараметры DPO, включая `beta`; не переносите напрямую формат данных обучения с учителем.                                  |
| `method.reinforcement`              | object           | Нет        | Настройки дообучения с подкреплением, включая `grader` и гиперпараметры метода.                                                |
| `suffix`                            | string / null    | Нет        | Суффикс имени итоговой модели, до 64 символов.                                                                                 |
| `seed`                              | integer / null   | Нет        | Начальное значение генератора случайных чисел; одинаковое зерно не гарантирует точную воспроизводимость.                       |
| `metadata`                          | object / null    | Нет        | До 16 пар\: ключи до 64, значения до 512 символов.                                                                             |
| `integrations`                      | array / null     | Нет        | Внешние метрики, например настройки `wandb` с названием проекта.                                                               |
| `hyperparameters`                   | object, устарело | Нет        | Старая запись верхнего уровня; новые настройки размещайте в `method`.                                                          |

Модель и ID файлов в теле показаны для структуры; используйте ресурсы нужного проекта.

```json
{
  "model": "selected-base-model",
  "training_file": "file-training",
  "method": {
    "type": "supervised",
    "supervised": {
      "hyperparameters": {
        "n_epochs": 2
      }
    }
  }
}
```

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

Пример ответа (основные поля, не настоящая задача)\:

```json
{
  "id": "ftjob-demo",
  "object": "fine_tuning.job",
  "model": "selected-base-model",
  "created_at": 1793491200,
  "finished_at": null,
  "fine_tuned_model": null,
  "status": "queued",
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

Задайте `OPENAI_API_KEY`, `OPENAI_FINE_TUNING_MODEL` и `OPENAI_TRAINING_FILE_ID`. curl использует Python 3 для JSON. Дообучение базовой модели должно быть открыто в официальном проекте. Обучение платное\: запускайте после проверки данных, метода и бюджета, не как тест соединения.

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
    model = required("OPENAI_FINE_TUNING_MODEL")
    training_file = required("OPENAI_TRAINING_FILE_ID")
    payload = {"model": model, "training_file": training_file}
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        "https://api.openai.com/v1/fine_tuning/jobs",
        method="POST",
        data=data,
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"},
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
      const model = required("OPENAI_FINE_TUNING_MODEL");
      const training_file = required("OPENAI_TRAINING_FILE_ID");
      const body = JSON.stringify({"model": model, "training_file": training_file});
      const response = await fetch("https://api.openai.com/v1/fine_tuning/jobs", {
        method: "POST",
        headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
        body,
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
    : "${OPENAI_FINE_TUNING_MODEL:?请设置 OPENAI_FINE_TUNING_MODEL}"
    : "${OPENAI_TRAINING_FILE_ID:?请设置 OPENAI_TRAINING_FILE_ID}"
    payload=$(python3 - <<'JSON'
    import json, os
    print(json.dumps({"model": os.environ["OPENAI_FINE_TUNING_MODEL"], "training_file": os.environ["OPENAI_TRAINING_FILE_ID"]}))
    JSON
    )

    curl "https://api.openai.com/v1/fine_tuning/jobs" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request POST \
      --header "Authorization: Bearer $OPENAI_API_KEY" \
      --header "Content-Type: application/json" \
      --data "$payload"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"bytes"
    	"encoding/json"
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
    	model := required("OPENAI_FINE_TUNING_MODEL")
    	training_file := required("OPENAI_TRAINING_FILE_ID")
    	payload, err := json.Marshal(map[string]any{"model": model, "training_file": training_file})
    	check(err)
    	req, err := http.NewRequest("POST", "https://api.openai.com/v1/fine_tuning/jobs", bytes.NewReader(payload))
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	req.Header.Set("Content-Type", "application/json")
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

* [Создание дообучения OpenAI](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/create)
* [Руководство OpenAI по оптимизации моделей](https\://developers.openai.com/api/docs/guides/model-optimization)
* [Коды ошибок OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)