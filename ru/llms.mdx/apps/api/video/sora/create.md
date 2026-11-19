# Создать видео Sora (официальный интерфейс закрыт)

**Официальные Sora 2 и Videos API OpenAI закрыты 24 сентября 2026 года.** Ниже лишь архив структуры, не рабочая инструкция. Если SimiRouter предлагает одноимённую модель или стороннюю совместимую реализацию, отдельно проверьте источник, возможности и протокол; нельзя называть это прямым официальным OpenAI API.

## Описание интерфейса

`POST https://api.openai.com/v1/videos` — прежняя официальная форма с ключом Bearer OpenAI; новые производственные запросы отправлять не следует.

## Параметры запроса

| Поле             | Тип    | Обязателен | Описание                                                          |
| ---------------- | ------ | ---------- | ----------------------------------------------------------------- |
| prompt           | string | Да         | Текстовое описание видео.                                         |
| model            | string | Нет        | Прежние sora-2 / sora-2-pro, ныне закрыты.                        |
| seconds          | string | Нет        | Прежние длительности, например 4, 8, 12; сохранены как структура. |
| size             | string | Нет        | Прежние разрешения, например 1280x720.                            |
| input\_reference | object | Нет        | Объект образца\: image\_url или file\_id на выбор.                |

## Ответ

Раньше создание возвращало id, object, status, progress, model, created\_at, seconds, size. queued / in\_progress не означали завершения.

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

**Архивный пример не доказывает доступность интерфейса.** Ниже структура прежних HTTP-вызовов; не тестируйте новые задачи с реальным ключом.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/videos'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'sora-2', 'prompt': '海边日落，平稳镜头。', 'seconds': '4', 'size': '1280x720'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "sora-2",
      "prompt": "海边日落，平稳镜头。",
      "seconds": "4",
      "size": "1280x720"
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
    curl "https://api.openai.com/v1/videos" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "sora-2",
        "prompt": "海边日落，平稳镜头。",
        "seconds": "4",
        "size": "1280x720"
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "sora-2",
      "prompt": "海边日落，平稳镜头。",
      "seconds": "4",
      "size": "1280x720"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/videos", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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

После закрытия нельзя обещать успешный ответ. Раньше HTTP 401/403 разделяли авторизацию и права, 404 — отсутствие ресурса, 429 — частоту; ошибки генерации содержали error.code/message. Не повторяйте отключённые вызовы бесконечно и не сохраняйте ошибку как MP4.

## Официальные материалы

[Уведомление OpenAI об отключении](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create).