# Генерация музыки Google Lyria

Страницы ниже описывают официальный Google API. SimiRouter пока не открыл эту возможность; все примеры напрямую подключаются к Gemini API Google AI Studio через `https://generativelanguage.googleapis.com` с ключом Google API. Для Vertex AI требуется отдельный протокол, не проверенный на этой странице; не подменяйте адрес напрямую.

## Описание интерфейса

`POST https://generativelanguage.googleapis.com/v1beta/interactions`, аутентификация — `x-goog-api-key: $GEMINI_API_KEY`. Lyria использует Interactions, а не generateContent и не `/audio/speech`.

| Модель                 | Назначение                               | Длительность и результат                                                                  |
| ---------------------- | ---------------------------------------- | ----------------------------------------------------------------------------------------- |
| `lyria-3-clip-preview` | Фрагменты, циклы и быстрое прослушивание | Фиксированные 30 секунд; по умолчанию MP3.                                                |
| `lyria-3.5`            | Песни с куплетами, припевами и бриджем   | Длительность в несколько минут задается в запросе; по умолчанию MP3, можно запросить WAV. |

## Параметры запроса

| Поле                       | Тип            | Обязателен  | Описание                                                                        |
| -------------------------- | -------------- | ----------- | ------------------------------------------------------------------------------- |
| model                      | string         | Да          | Одна из указанных моделей Lyria.                                                |
| input                      | string / array | Да          | Описание музыки или массив мультимодальных элементов text/image.                |
| input\[].text              | string         | При условии | Стиль, темп, настроение, инструменты, слова и структура.                        |
| input\[].mime\_type / data | string         | При условии | Изображение передается элементом image с корректным MIME и данными Base64.      |
| response\_format           | object         | Нет         | \{"type"\:"audio"} позволяет запросить WAV; ориентируйтесь на фактический MIME. |

Указанная длительность не является точной гарантией. Описывать стиль и инструменты безопаснее, чем требовать имитации конкретного исполнителя.

## Ответ

| Поле                                        | Описание                                                                          |
| ------------------------------------------- | --------------------------------------------------------------------------------- |
| `id` / `status`                             | Идентификатор Interaction и статус обработки.                                     |
| `steps[].content[]`                         | model\_output содержит аудио, слова и структуру песни; разбирайте каждый элемент. |
| Элемент аудио `type` / `mime_type` / `data` | type=audio; data содержит Base64, а не URL.                                       |
| Текстовый элемент `text`                    | Слова, структура или другой текст.                                                |

Свойство SDK `output_audio` / `output_text` — вспомогательное. Для сложного чередующегося вывода перебирайте steps\: получение только последнего фрагмента может привести к потере данных. Ниже приведен фрагмент структуры ответа\:

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"[Instrumental]"},{"type":"audio","mime_type":"audio/mpeg","data":"<Base64音频>"}]}]}
```

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

Задайте `GEMINI_API_KEY`. Пример возвращает JSON; декодируйте data элемента audio и сохраните MP3. Для полной песни замените model на `lyria-3.5`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY'], 'Api-Revision': '2026-05-20'}
    response = requests.request('POST', url, headers=headers, json={'model': 'lyria-3-clip-preview', 'input': '30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY, "Api-Revision": "2026-05-20" };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "lyria-3-clip-preview",
      "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
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
    curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Api-Revision: 2026-05-20" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "lyria-3-clip-preview",
        "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
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
      "model": "lyria-3-clip-preview",
      "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
    }`)
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/interactions", body); check(err)
      req.Header.Set("x-goog-api-key", "" + os.Getenv("GEMINI_API_KEY"))
      req.Header.Set("Api-Revision", "2026-05-20")
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

| Статус HTTP           | Значение и действие                                                                                                                         |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| 400                   | Неверные поля запроса или параметры модели\: исправьте запрос и повторите отправку.                                                         |
| 401                   | Ключ API отсутствует, недействителен или просрочен.                                                                                         |
| 403                   | Нет прав проекта или модели.                                                                                                                |
| 404                   | Модель или маршрут не найдены\: проверьте адрес и идентификатор модели.                                                                     |
| 429                   | Лимит частоты или квоты\: отличайте нехватку средств от временного ограничения с повторами.                                                 |
| 500 / 502 / 503 / 504 | Ошибка сервиса или провайдера. Сохраните ID запроса и сделайте паузу перед повтором; не повторяйте один и тот же платный запрос бесконечно. |

Объект ошибки Google содержит `error.code`, `error.status` и `error.message`; не определяйте источник только по номеру HTTP. Этот интерфейс синхронный\: идентификатора задачи и этапа опроса нет. Никогда не декодируйте текст ошибки как аудиоданные.

## Официальные материалы

[Генерация музыки Google Lyria](https\://ai.google.dev/gemini-api/docs/music-generation), [Interactions](https\://ai.google.dev/gemini-api/docs/interactions).