# Скачать содержимое Sora (официальный интерфейс закрыт)

**Официальные Sora 2 и Videos API OpenAI закрыты 24 сентября 2026 года.** Ниже лишь архив структуры, не рабочая инструкция. Если SimiRouter предлагает одноимённую модель или стороннюю совместимую реализацию, отдельно проверьте источник, возможности и протокол; нельзя называть это прямым официальным OpenAI API.

## Описание интерфейса

`GET https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content` — прежняя официальная форма с ключом Bearer OpenAI; новые производственные запросы отправлять не следует.

## Параметры запроса

| Поле             | Тип    | Обязателен | Описание                                             |
| ---------------- | ------ | ---------- | ---------------------------------------------------- |
| video\_id (путь) | string | Да         | Прежний ID созданной задачи.                         |
| variant (query)  | string | Нет        | Прежние типы video, thumbnail, spritesheet и другие. |

## Ответ

Раньше успешный ответ содержал бинарный MP4 и другое, не JSON с URL; до завершения скачивание невозможно. Сейчас официальный сервис закрыт.

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

**Архивный пример не доказывает доступность интерфейса.** Ниже структура прежних HTTP-вызовов; не тестируйте новые задачи с реальным ключом.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('GET', url, headers=headers, timeout=180)
    response.raise_for_status()
    Path('video.mp4').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      const response = await fetch(url, { method: "GET", headers, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("video.mp4", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "video.mp4" ] || { printf '%s\n' "目标文件已存在：video.mp4" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X GET "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      --output "$temporary"; then
      mv "$temporary" "video.mp4"
    else
      status=$?
      cat "$temporary" >&2
      exit "$status"
    fi
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
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
        req, err := http.NewRequest("GET", "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content", nil); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("video.mp4", data, 0600))
    }
    ```
  </Tab>
</Tabs>

## Коды ошибок

После закрытия нельзя обещать успешный ответ. Раньше HTTP 401/403 разделяли авторизацию и права, 404 — отсутствие ресурса, 429 — частоту; ошибки генерации содержали error.code/message. Не повторяйте отключённые вызовы бесконечно и не сохраняйте ошибку как MP4.

## Официальные материалы

[Уведомление OpenAI об отключении](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create).