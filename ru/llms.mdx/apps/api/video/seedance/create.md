# Создать видеозадачу Seedance

## Описание интерфейса

`POST https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks`, `Authorization: Bearer $ARK_API_KEY`, тело JSON. Ниже приведен официальный протокол прямого доступа, **не** гарантирующий совместимость с SimiRouter `/v1/video/generations`.

## Параметры запроса

| Поле                      | Тип       | Обязателен  | Описание                                                                                                                                                            |
| ------------------------- | --------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                     | string    | Да          | ID активированной модели Seedance или точки инференса.                                                                                                              |
| content                   | object\[] | Да          | Текст и поддерживаемые моделью изображения/видео/аудио.                                                                                                             |
| content\[].type           | string    | Да          | text, image\_url, video\_url, audio\_url, draft\_task по возможностям модели.                                                                                       |
| content\[].draft\_task.id | string    | При условии | ID задачи черновика при type=draft\_task\: используется для создания финального видео по черновику.                                                                 |
| content\[].text           | string    | При условии | Инструкция для type=text.                                                                                                                                           |
| content\[].image\_url.url | string    | При условии | Доступное изображение или разрешённый моделью data URL.                                                                                                             |
| content\[].role           | string    | Нет         | Например first\_frame, last\_frame, reference\_image по модели и типу материала.                                                                                    |
| resolution                | string    | Нет         | Допустимое разрешение\: 480p, 720p, 1080p или 4k в зависимости от модели; черновики поддерживают только 480p.                                                       |
| ratio                     | string    | Нет         | Например 16\:9, 9\:16, 1\:1, adaptive; точную поддержку см. в таблице модели.                                                                                       |
| duration                  | integer   | Нет         | Длительность в пределах модели; -1 для моделей с автоматической длительностью.                                                                                      |
| frames                    | integer   | Нет         | Число кадров только для совместимых моделей; при одновременной передаче с duration приоритет у frames.                                                              |
| generate\_audio           | boolean   | Нет         | Генерировать ли звук, только для звуковых моделей.                                                                                                                  |
| watermark                 | boolean   | Нет         | Видимый водяной знак; соблюдайте маркировку синтетического контента.                                                                                                |
| seed                      | integer   | Нет         | Начальное значение генератора случайных чисел; не гарантия воспроизведения по пикселям.                                                                             |
| return\_last\_frame       | boolean   | Нет         | Запрашивает изображение последнего кадра.                                                                                                                           |
| callback\_url             | string    | Нет         | Адрес уведомлений; получатель обрабатывает дубли и нарушение порядка.                                                                                               |
| execution\_expires\_after | integer   | Нет         | Истечение задачи в секундах\: 172800 по умолчанию, диапазон 3600–259200.                                                                                            |
| service\_tier             | string    | Нет         | default / flex по поддержке модели.                                                                                                                                 |
| draft                     | boolean   | Нет         | Создает черновик видео; по умолчанию false, поддерживаемые модели принимают только 480p. Для финального видео по черновику используйте `content[].type=draft_task`. |
| priority                  | integer   | Нет         | Приоритет очереди для поддерживаемых моделей/уровней сервиса, не всех вызовов.                                                                                      |

Пример выбирает Seedance 2.5, текст и короткое видео. Для 1.0 pro / 2.0 адаптируйте поля к версии, не предполагая поддержку всех мультимодальных образцов, аудио и черновиков.

## Ответ

Успешное создание возвращает `id`, не готовое видео. Сохраните ID, затем используйте [Метод получения](/simidoc/ru/apps/api/video/seedance/status).

```json
{"id":"cgt-example"}
```

Тайм-аут не доказывает, что сервер не принял запрос; избегайте неограниченного автоповтора создания. Callback должен идемпотентно обновлять состояние по ID.

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

Укажите официальный `ARK_API_KEY`; вызов создаёт потенциально платную задачу.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks'
    headers = {'Authorization': 'Bearer ' + os.environ['ARK_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'doubao-seedance-2-5-260628', 'content': [{'type': 'text', 'text': '海边日落时，一艘白色帆船缓缓驶过，镜头平稳。'}], 'duration': 5, 'ratio': '16:9', 'generate_audio': True, 'watermark': True}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks";
      const headers = { "Authorization": "Bearer " + process.env.ARK_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
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
    curl "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $ARK_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "doubao-seedance-2-5-260628",
        "content": [
          {
            "type": "text",
            "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
          }
        ],
        "duration": 5,
        "ratio": "16:9",
        "generate_audio": true,
        "watermark": true
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
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
    }`)
      req, err := http.NewRequest("POST", "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("ARK_API_KEY"))
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

| Статус HTTP           | Значение и действие                                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| 400 / 422             | Неверные поля, формат файла или параметры модели\: исправьте запрос.                                                                       |
| 401                   | Ключ API отсутствует, недействителен или просрочен.                                                                                        |
| 403                   | Нет прав проекта или модели.                                                                                                               |
| 404                   | Модель, маршрут или задача не найдены\: проверьте адрес и владельца ресурса.                                                               |
| 413 / 415             | Файл слишком велик или тип данных не поддерживается.                                                                                       |
| 429                   | Лимит частоты или квоты\: отличайте нехватку средств от временного ограничения с повторами.                                                |
| 500 / 502 / 503 / 504 | Ошибка сервиса или провайдера\: сохраните ID запроса; при тайм-ауте создания сначала проверьте прием задачи, чтобы не повторить генерацию. |

Объект ошибки Volcengine использует `error.code`, `error.message`; сохраните ID запроса. Ошибку выполнения проверяйте опросом\: HTTP создания не доказывает окончательный успех.

Ошибки Volcengine содержат `error.code`, `error.message` и ID запроса; ошибки генерации также читают из error результата опроса.

## Официальные материалы

[Создание задачи Volcengine Ark](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh), [Официальное руководство вызова](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh).