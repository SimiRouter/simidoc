# Генерация изображений Gemini

## Описание интерфейса

`POST /v1beta/models/{model}:generateContent` использует модель Gemini с выводом изображений; результат может чередовать текст и картинки.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $API_KEY`. Официальный Google доступен по `https://generativelanguage.googleapis.com`, обычно с `x-goog-api-key: $GEMINI_API_KEY`, а не Bearer-ключом шлюза. Выберите доступную модель с нужными возможностями.

Здесь используется REST GenerateContent. У Google есть графические сценарии Interactions API, но input, steps и response\_format отличаются от contents, candidates и generationConfig. Структуры нельзя смешивать.

## Параметры запроса

| Поле                                     | Тип    | Обязателен | Описание                                                                                                                |
| ---------------------------------------- | ------ | ---------- | ----------------------------------------------------------------------------------------------------------------------- |
| model (в пути)                           | string | Да         | Модель Gemini с поддержкой generateContent и вывода изображений; чисто текстовая модель не подходит.                    |
| contents                                 | array  | Да         | Список сообщений; для генерации по тексту обычно достаточно одного user.                                                |
| contents\[].role                         | string | Нет        | user; для ответов модели в истории используется model.                                                                  |
| contents\[].parts\[].text                | string | Да         | Описание изображения или инструкция редактирования.                                                                     |
| generationConfig.responseModalities      | array  | Нет        | Например, \["TEXT","IMAGE"] для текста и изображений; допустимые сочетания зависят от модели.                           |
| generationConfig.imageConfig.aspectRatio | string | Нет        | Если поддерживается, доступны соотношения 1\:1, 16\:9, 9\:16 и другие.                                                  |
| generationConfig.imageConfig.imageSize   | string | Нет        | Если поддерживается\: 1K, 2K, 4K и другие значения выбранной модели. Не все графические модели принимают этот параметр. |

Не передавайте ненужные настройки. Добавление imageConfig к текстовой модели не дает ей графических возможностей. Новая конфигурация вывода нативного generateContent может поддерживаться не теми же моделями, что старые настройки. Здесь сохранен наглядный пример с responseModalities.

### Характеристики изображений\: 1K, 2K и 4K

K — распространённое обозначение разрешения, а не размера файла или параметра качества. Фактические размеры зависят от модели и пропорций. При одинаковых пропорциях удвоение обеих сторон увеличивает число пикселей вчетверо. Примеры объясняют термины, но не являются допустимыми размерами для всех моделей.

Если модель поддерживает эти настройки, Gemini использует `generationConfig.imageConfig.imageSize` для выбора `1K`, `2K` или `4K`, а `generationConfig.imageConfig.aspectRatio` — для пропорций. Фактические размеры уточняйте для выбранной модели.

| Обозначение разрешения | Типичные размеры в пикселях (без гарантии поддержки моделью)    |
| ---------------------- | --------------------------------------------------------------- |
| 1K                     | 1024×1024 · Около тысячи пикселей по стороне                    |
| 2K                     | 2048×2048 · Около двух тысяч пикселей по стороне                |
| 4K                     | 4096×4096 / 3840×2160 · Около четырёх тысяч пикселей по стороне |

Тарифные категории сайта за изображение определяются отдельно; эти примеры разрешений не задают правила оплаты. [Характеристики и правила тарификации](/simidoc/ru/apps/api/images).

### Пример запроса

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "生成一张小机器人在图书馆阅读的水彩插画，浅蓝色背景，不要文字。"
        }
      ]
    }
  ],
  "generationConfig": {
    "responseModalities": [
      "TEXT",
      "IMAGE"
    ]
  }
}
```

## Ответ

| Поле                           | Тип     | Описание                                                                                                                    |
| ------------------------------ | ------- | --------------------------------------------------------------------------------------------------------------------------- |
| candidates\[]                  | array   | Список кандидатов; при фильтрации может быть пустым.                                                                        |
| candidates\[].content.parts\[] | array   | Упорядоченные фрагменты текста, изображений и размышлений; не читайте только первый.                                        |
| parts\[].text                  | string  | Поясняющий текст; его наличие решает модель.                                                                                |
| parts\[].inlineData.mimeType   | string  | Фактический MIME изображения, например image/png или image/jpeg.                                                            |
| parts\[].inlineData.data       | string  | Чистый Base64 изображения без префикса data\:.                                                                              |
| parts\[].thought               | boolean | Необязательный признак фрагмента размышления. Промежуточную картинку thought=true нельзя считать итоговой.                  |
| parts\[].thoughtSignature      | string  | Необязательная непрозрачная подпись. При итеративном редактировании сохраняйте без изменений, не создавайте самостоятельно. |
| candidates\[].finishReason     | string  | STOP — нормальное завершение; MAX\_TOKENS, SAFETY и другие причины обрабатывайте отдельно.                                  |
| promptFeedback                 | object  | Необязательные сведения о блокировке ввода.                                                                                 |
| usageMetadata                  | object  | Токены ввода, кандидатов, размышлений и общий объем; набор полей зависит от модели.                                         |

Base64 ниже — минимальный PNG для демонстрации структуры, не реальный результат указанного запроса.

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "已根据描述生成图片。"
          },
          {
            "inlineData": {
              "mimeType": "image/png",
              "data": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
            }
          }
        ]
      },
      "finishReason": "STOP"
    }
  ]
}
```

Перебирайте parts по порядку, выбирайте inlineData без thought и определяйте расширение по mimeType. Нельзя считать parts\[0] картинкой. Если есть только текст или результат отфильтрован, сообщайте, что изображение не создано.

### Поток и пакетная обработка

Модели с потоковым выводом могут использовать streamGenerateContent?alt=sse, но фрагменты изображения не всегда являются самостоятельными файлами. Следуйте формату событий выбранной модели. generateContent синхронен и не возвращает задачу для опроса. Официальный Google Batch API — отдельный асинхронный сервис, не конечная точка генерации шлюза.

## Примеры вызова

Укажите `API_URL` и `API_KEY` в начале кода; в примерах используется `gemini-3-pro-image`. `API_URL` — полный URL запроса, по умолчанию адрес шлюза `https://api.dwchainless.com`. Примеры используют только стандартные библиотеки, отправляют один запрос и выводят полученный JSON; изображение автоматически не сохраняется.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
            }
          ]
        }
      ],
      "generationConfig": {
        "responseModalities": [
          "TEXT",
          "IMAGE"
        ]
      }
    }
    request = urllib.request.Request(
        API_URL,
        data=json.dumps(body).encode(),
        method="POST",
        headers={
            "Authorization": "Bearer " + API_KEY,
            "Content-Type": "application/json",
        },
    )
    print(urllib.request.urlopen(request).read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const API_URL = 'https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '生成一张小机器人在图书馆阅读的水彩插画，不要文字。'
              }
            ]
          }
        ],
        generationConfig: {
          responseModalities: [
            'TEXT',
            'IMAGE'
          ]
        }
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
              }
            ]
          }
        ],
        "generationConfig": {
          "responseModalities": [
            "TEXT",
            "IMAGE"
          ]
        }
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "contents": [
                {
                    "role": "user",
                    "parts": [
                        {
                            "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
                        }
                    ]
                }
            ],
            "generationConfig": {
                "responseModalities": [
                    "TEXT",
                    "IMAGE"
                ]
            }
        }`)
        request, _ := http.NewRequest("POST", apiURL, bytes.NewReader(body))
        request.Header.Set("Authorization", "Bearer "+apiKey)
        request.Header.Set("Content-Type", "application/json")
        response, _ := http.DefaultClient.Do(request)
        defer response.Body.Close()
        result, _ := io.ReadAll(response.Body)
        fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Демо вызова через агента

Передайте это задание агенту с инструментами локального выполнения и проверки ответа. Сначала задайте переменные среды по [настройке этого протокола](/simidoc/ru/apps/api/images/gemini). Не вставляйте ключ в задание.

```text
Read this Gemini protocol page and the GenerateContent image generation reference first.
Use the configured SimiRouter request URL in API_URL (default gateway
https://api.dwchainless.com) and MODEL. Set API_KEY directly in the example; never
print, paste, commit, or store it in source files. For this one approved task, call POST
/v1beta/models/{model}:generateContent once, non-streaming, Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. with a text Part describing a calm blue library with a small robot reading,
watercolor, no lettering. Request one image; use imageConfig aspectRatio=1:1 and
imageSize=1K only if the model supports them. Do not invent an n parameter or mix
Interactions fields into GenerateContent. After the response, read only completed,
non-thought inlineData from parts; decode the Base64 in memory and report any unmet
requirement; do not write an image file. Do not switch providers/models/billing groups,
increase size/count, write files, install remote skills, or retry an ambiguous failure
without approval. Report a redacted error instead of false success.
```

## Коды ошибок

| Статус HTTP | Значение или тип ошибки провайдера | Действие                                                                    |
| ----------- | ---------------------------------- | --------------------------------------------------------------------------- |
| 400         | `INVALID_ARGUMENT` и другие        | Проверьте JSON, параметры модели, MIME и длину ввода.                       |
| 403         | `PERMISSION_DENIED`                | Проверьте ключ, права проекта, регион и платежные ограничения.              |
| 404         | `NOT_FOUND`                        | Проверьте имя модели и версию API.                                          |
| 429         | `RESOURCE_EXHAUSTED`               | Проверьте частоту и квоту; для повторяемых ошибок ограничьте число попыток. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`         | Сохраните ID запроса и повторите ограниченно либо позже.                    |

Ошибка Google содержит `error.code` (HTTP-число), `error.status` (имя перечисления), `error.message`; возможны также `details`. Шлюз может вернуть ошибку до провайдера. Не определяйте источник только по HTTP-коду. При HTTP 200 без итогового изображения (не thought) текстовый ответ нельзя считать успешной генерацией картинки.

## Официальные материалы

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google\: генерация и редактирование изображений](https\://ai.google.dev/gemini-api/docs/image-generation)
* [Каталог моделей Google](https\://ai.google.dev/gemini-api/docs/models)
* [Google\: диагностика ошибок](https\://ai.google.dev/gemini-api/docs/troubleshooting)