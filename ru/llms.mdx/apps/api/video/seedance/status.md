# Проверить видеозадачу Seedance

## Описание интерфейса

`GET https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/{id}`, авторизация `Authorization: Bearer $ARK_API_KEY`. Здесь официальный протокол Ark, не общий статус видео шлюза.

## Параметры запроса

| Поле      | Тип    | Обязателен | Описание                                    |
| --------- | ------ | ---------- | ------------------------------------------- |
| id (путь) | string | Да         | ID cgt- из создания, тот же аккаунт/регион. |

JSON-тела нет. Обычно ID действует 7 дней; часть новых Draft имеет отдельный срок. Интерфейс задач не подходит для постоянного архива.

## Ответ

| Поле                                                    | Описание                                                   |
| ------------------------------------------------------- | ---------------------------------------------------------- |
| `id` / `model`                                          | ID задачи и версия модели.                                 |
| `status`                                                | queued, running, succeeded, failed, expired, cancelled.    |
| `content.video_url`                                     | Ссылка после успеха, обычно на 24 часа; сохраните вовремя. |
| `content.last_frame_url`                                | URL последнего кадра, если запрошен и поддерживается.      |
| `error.code` / `error.message`                          | Причина ошибки, может отсутствовать.                       |
| `created_at` / `updated_at`                             | Unix в секундах.                                           |
| `usage`                                                 | Использование задачи согласно модели.                      |
| `duration` / `ratio` / `resolution` / `framespersecond` | Реальные характеристики видео.                             |
| `seed` / `service_tier` / `execution_expires_after`     | Настройки выполнения и данные для воспроизведения.         |

```json
{"id":"cgt-example","model":"doubao-seedance-2-5-260628","status":"succeeded","content":{"video_url":"https://example.com/video.mp4"},"error":null,"created_at":1780000000,"updated_at":1780000120}
```

Скачивайте только при succeeded и непустом video\_url; немедленно прекратите опрос при failed, expired, cancelled. URL лишь иллюстрирует поля.

## Примеры вызова

Задайте `ARK_API_KEY` и `TASK_ID`; `TASK_ID` должен быть настоящим ID создания. Python 3, Node.js 18+ и Go используют только стандартные библиотеки; curl дополнительно требует Python 3 для безопасного пути. Рекомендуется интервал 5–10 секунд с общим лимитом приложения; пример опрашивает один раз.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    key = os.environ.get("ARK_API_KEY")
    task_id = os.environ.get("TASK_ID")
    if not key or not task_id or not task_id.strip():
        raise SystemExit("请设置 ARK_API_KEY 和 TASK_ID")
    url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + urllib.parse.quote(task_id, safe="")
    request = urllib.request.Request(url, headers={"Authorization": "Bearer " + key}, method="GET")
    try:
        with urllib.request.urlopen(request, timeout=180) as response:
            print(json.dumps(json.load(response), ensure_ascii=False, indent=2))
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const key = process.env.ARK_API_KEY;
      const taskId = process.env.TASK_ID;
      if (!key || !taskId?.trim()) throw new Error("请设置 ARK_API_KEY 和 TASK_ID");
      const url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + encodeURIComponent(taskId);
      const response = await fetch(url, {
        method: "GET", headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(180000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${ARK_API_KEY:?请设置 ARK_API_KEY}"
    : "${TASK_ID:?请设置 TASK_ID 为创建接口返回的真实任务 ID}"
    TASK_PATH=$(python3 - <<'PY_TASK'
    import os, urllib.parse
    task_id = os.environ["TASK_ID"]
    if not task_id.strip():
        raise SystemExit("TASK_ID 不能为空白")
    print(urllib.parse.quote(task_id, safe=""))
    PY_TASK
    )
    curl "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/${TASK_PATH}" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      --header "Authorization: Bearer $ARK_API_KEY"
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
    	"strings"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func main() {
    	key, taskID := os.Getenv("ARK_API_KEY"), os.Getenv("TASK_ID")
    	if key == "" || strings.TrimSpace(taskID) == "" {
    		log.Fatal("请设置 ARK_API_KEY 和 TASK_ID")
    	}
    	endpoint := "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + url.PathEscape(taskID)
    	req, err := http.NewRequest("GET", endpoint, nil)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	client := &http.Client{Timeout: 180 * time.Second}
    	response, err := client.Do(req)
    	check(err)
    	defer response.Body.Close()
    	data, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, data)
    	}
    	fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## Коды ошибок

| Статус HTTP           | Значение и действие                                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| 400 / 422             | Неверные поля, формат файла или параметры модели\: исправьте запрос.                                                                       |
| 401                   | Ключ API отсутствует, недействителен или просрочен.                                                                                        |
| 403                   | Нет прав проекта или модели.                                                                                                               |
| 404                   | Модель, маршрут или задача не найдены\: проверьте адрес и владельца ресурса.                                                               |
| 413 / 415             | Файл слишком велик или тип данных не поддерживается.                                                                                       |
| 429                   | Лимит частоты или квоты\: отличайте нехватку средств от временного ограничения с повторами.                                                |
| 500 / 502 / 503 / 504 | Ошибка сервиса или провайдера\: сохраните ID запроса; при тайм-ауте создания сначала проверьте прием задачи, чтобы не повторить генерацию. |

Объект ошибки Volcengine использует `error.code`, `error.message`; сохраните ID запроса. Даже успешный HTTP опроса требует проверки status и error задачи.

## Официальные материалы

[Опрос задачи Volcengine Ark](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh).