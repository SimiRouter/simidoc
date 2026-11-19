# Изображение в видео Kling

## Описание интерфейса

`POST https://api-singapore.klingai.com/image-to-video/kling-3.0`, авторизация `Authorization: Bearer $KLING_API_KEY`, тело JSON. Используется новый официальный Kling, не старое соответствие SimiRouter `/kling/v1/videos/...`.

## Параметры запроса

| Поле                            | Тип       | Обязателен  | Описание                                                                      |
| ------------------------------- | --------- | ----------- | ----------------------------------------------------------------------------- |
| contents                        | object\[] | Да          | Входы\: изображения, текст, элементы и прочее.                                |
| contents\[].type                | string    | Да          | Поддерживаемые типы prompt, first\_frame, last\_frame и другие.               |
| contents\[].text                | string    | При условии | Инструкции действия, камеры и содержания элемента prompt.                     |
| contents\[].url                 | string    | При условии | Доступный URL изображения first\_frame / last\_frame.                         |
| settings.resolution             | string    | Нет         | 720p (по умолчанию), 1080p, 4k — по правам модели.                            |
| settings.duration               | integer   | Нет         | По умолчанию 5 секунд; текущая справка 3.0 разрешает 3–15 секунд.             |
| settings.audio                  | string    | Нет         | off (по умолчанию) или native для собственной звуковой дорожки.               |
| settings.multi\_shot            | boolean   | Нет         | По умолчанию true; в примере false для одного плана.                          |
| options.callback\_url           | string    | Нет         | Callback состояния; безопасный приём и идемпотентность реализует приложение.  |
| options.external\_task\_id      | string    | Нет         | Уникальный в аккаунте пользовательский ID для опроса, не заменяет системный.  |
| options.watermark\_info.enabled | boolean   | Нет         | Предоставлять ли версию с водяным знаком; собственный знак не поддерживается. |

Нельзя выводить ограничения моделей только из наличия поля. Многоплановые инструкции следуют официальному синтаксису shot; сумма длительностей должна равняться общей. Первый/последний кадр, число элементов и форматы зависят от текущей модели.

## Ответ

```json
{"code":0,"message":"Success","request_id":"request_example","data":{"id":"task_example","status":"submitted","create_time":1780000000000,"update_time":1780000000000}}
```

`data.id` — системный ID для опроса, `data.status` принимает submitted, processing, succeeded, failed; время в миллисекундах. Создание не возвращает готовое видео. Не читайте старый `data.task_id` или `task_status`.

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

Задайте официальный ключ Kling `KLING_API_KEY`. Вызов создаёт оплачиваемую задачу. Затем см. [Опрос задачи](/simidoc/ru/apps/api/video/kling/image-status).

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api-singapore.klingai.com/image-to-video/kling-3.0'
    headers = {'Authorization': 'Bearer ' + os.environ['KLING_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'contents': [{'type': 'prompt', 'text': '镜头缓缓拉远，画面保持稳定。'}, {'type': 'first_frame', 'url': 'https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png'}], 'settings': {'resolution': '720p', 'duration': 5, 'audio': 'off', 'multi_shot': False}}, timeout=180)
    response.raise_for_status()
    result = response.json()
    if result.get("code") != 0:
        raise RuntimeError(result)
    print(result)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api-singapore.klingai.com/image-to-video/kling-3.0";
      const headers = { "Authorization": "Bearer " + process.env.KLING_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "contents": [
        {
          "type": "prompt",
          "text": "镜头缓缓拉远，画面保持稳定。"
        },
        {
          "type": "first_frame",
          "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
        }
      ],
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false
      }
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.code !== 0) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    response=$(mktemp)
    trap 'rm -f "$response"' EXIT
    curl "https://api-singapore.klingai.com/image-to-video/kling-3.0" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $KLING_API_KEY" \
      -H "Content-Type: application/json" \
      --output "$response" \
      -d '{
        "contents": [
          {
            "type": "prompt",
            "text": "镜头缓缓拉远，画面保持稳定。"
          },
          {
            "type": "first_frame",
            "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
          }
        ],
        "settings": {
          "resolution": "720p",
          "duration": 5,
          "audio": "off",
          "multi_shot": false
        }
      }'
    python3 - "$response" <<'PY_CHECK'
    import json, sys
    from pathlib import Path
    result = json.loads(Path(sys.argv[1]).read_text())
    if result.get("code") != 0:
        raise SystemExit(json.dumps(result, ensure_ascii=False))
    print(json.dumps(result, ensure_ascii=False))
    PY_CHECK
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "encoding/json"
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
      "contents": [
        {
          "type": "prompt",
          "text": "镜头缓缓拉远，画面保持稳定。"
        },
        {
          "type": "first_frame",
          "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
        }
      ],
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false
      }
    }`)
      req, err := http.NewRequest("POST", "https://api-singapore.klingai.com/image-to-video/kling-3.0", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("KLING_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      var result struct { Code int `json:"code"` }
      check(json.Unmarshal(data, &result))
      if result.Code != 0 { panic(string(data)) }
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

[Официальный интерфейс Kling](https\://kling.ai/document-api/apiReference/model/imageToVideo), [Аутентификация](https\://kling.ai/document-api/api/get-started/authentication), [Коды ошибок](https\://kling.ai/document-api/api/get-started/error-codes).