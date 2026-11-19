# Проверить задачу Kling изображения в видео

## Описание интерфейса

`GET https://api-singapore.klingai.com/tasks`, с `Authorization: Bearer $KLING_API_KEY`. Новые задачи Kling текста/изображения в видео используют единый опрос без добавления `/v1/videos/.../{id}`.

## Параметры запроса

| Поле                        | Тип    | Обязателен | Описание                                                                   |
| --------------------------- | ------ | ---------- | -------------------------------------------------------------------------- |
| task\_ids (query)           | string | На выбор   | Системный ID; несколько через запятую.                                     |
| external\_task\_ids (query) | string | На выбор   | Значение options.external\_task\_id при создании; несколько через запятую. |

Параметры нельзя передавать одновременно; JSON-тела нет. Задайте `TASK_ID` равным полученному при создании `data.id`.

## Ответ

| Поле                              | Описание                                                                  |
| --------------------------------- | ------------------------------------------------------------------------- |
| `code` / `message` / `request_id` | Бизнес-состояние и ID отслеживания; разбирайте data только при code=0.    |
| `data[]`                          | Массив соответствующих условиям задач.                                    |
| `data[].id` / `external_id`       | Системный и пользовательский ID.                                          |
| `data[].status`                   | submitted, processing, succeeded, failed.                                 |
| `data[].message`                  | Причина ошибки.                                                           |
| `data[].outputs[]`                | Результаты video/image/audio различаются по type; не старый task\_result. |
| `outputs[].url` / `watermark_url` | URL результата video и доступной версии с водяным знаком.                 |
| `outputs[].duration`              | Длительность видео в секундах.                                            |
| `create_time` / `update_time`     | Unix в миллисекундах.                                                     |
| `billing[]`                       | Информация о списанных единицах и другое.                                 |

```json
{"code":0,"message":"Success","request_id":"request_example","data":[{"id":"task_example","status":"succeeded","outputs":[{"type":"video","url":"https://example.com/video.mp4","duration":"5"}]}]}
```

Скачивайте лишь при status=succeeded и действительном выходе type=video. Ссылки имеют защиту/срок хранения; сохраните вовремя. При ошибке прекратите опрос. Успешный HTTP с data=\[] требует проверки ID и аккаунта, а не объявления успеха генерации.

## Примеры вызова

Задайте `KLING_API_KEY` и `TASK_ID`; `TASK_ID` должен быть настоящим ID создания. Python 3, Node.js 18+ и Go используют только стандартные библиотеки. curl использует `--data-urlencode` для кодирования параметров. Рекомендуется интервал 5–10 секунд и общий лимит ожидания приложения; пример опрашивает один раз.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    key = os.environ.get("KLING_API_KEY")
    task_id = os.environ.get("TASK_ID")
    if not key or not task_id or not task_id.strip():
        raise SystemExit("请设置 KLING_API_KEY 和 TASK_ID")
    url = "https://api-singapore.klingai.com/tasks?" + urllib.parse.urlencode({"task_ids": task_id})
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
      const key = process.env.KLING_API_KEY;
      const taskId = process.env.TASK_ID;
      if (!key || !taskId?.trim()) throw new Error("请设置 KLING_API_KEY 和 TASK_ID");
      const url = new URL("https://api-singapore.klingai.com/tasks");
      url.searchParams.set("task_ids", taskId);
      const response = await fetch(url, {
        method: "GET", headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(180000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.code !== 0) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${KLING_API_KEY:?请设置 KLING_API_KEY}"
    : "${TASK_ID:?请设置 TASK_ID 为创建接口返回的真实任务 ID}"
    [[ "$TASK_ID" =~ [^[:space:]] ]] || { printf '%s\n' 'TASK_ID 不能为空白' >&2; exit 1; }
    curl "https://api-singapore.klingai.com/tasks" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      --get \
      --data-urlencode "task_ids=$TASK_ID" \
      --header "Authorization: Bearer $KLING_API_KEY"
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
    	key, taskID := os.Getenv("KLING_API_KEY"), os.Getenv("TASK_ID")
    	if key == "" || strings.TrimSpace(taskID) == "" {
    		log.Fatal("请设置 KLING_API_KEY 和 TASK_ID")
    	}
    	query := url.Values{"task_ids": []string{taskID}}
    	endpoint := "https://api-singapore.klingai.com/tasks?" + query.Encode()
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

| HTTP / бизнес-код                  | Описание                                                                          |
| ---------------------------------- | --------------------------------------------------------------------------------- |
| 200 / 0                            | Запрос успешен; завершение генерации определяется status задачи.                  |
| 400 / 1201                         | Некорректные параметры, читайте message.                                          |
| 404 / 1202, 1203                   | Неверный метод или нет модели/ресурса.                                            |
| 401                                | Недействителен API Key или старый JWT.                                            |
| 400 / 1300, 1301                   | Ограничение политики или безопасности\: исправьте контент, не повторяйте вслепую. |
| 429 / 1302, 1303, 1304             | Ограничение частоты, конкуренции или IP-политики.                                 |
| 500 / 5000; 503 / 5001; 504 / 5002 | Ошибка сервиса или тайм-аут; сохраните request\_id.                               |

HTTP 200 не означает бизнес-успех; сначала code=0, затем data.

## Официальные материалы

[Официальный опрос задач Kling](https\://kling.ai/document-api/apiReference/model/imageToVideo).