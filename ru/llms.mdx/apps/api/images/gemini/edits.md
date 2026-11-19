# Редактирование Gemini и изображение по изображению

## Описание интерфейса

`POST /v1beta/models/{model}:generateContent` принимает в parts инструкции и референсы для редактирования, генерации по изображению, переноса стиля, замены фона и объединения изображений. Отдельного нативного пути `/images/edits` у Gemini нет.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $API_KEY`. Официальный Google доступен по `https://generativelanguage.googleapis.com`, обычно с `x-goog-api-key: $GEMINI_API_KEY`, а не Bearer-ключом шлюза. Выберите доступную модель с нужными возможностями.

Загружайте только изображения, которые вправе обрабатывать. Редактирование не гарантирует попиксельное сохранение лица, текста, знаков и товара; важные детали проверяйте вручную.

## Параметры запроса

| Поле                                     | Тип    | Обязателен               | Описание                                                                                                                |
| ---------------------------------------- | ------ | ------------------------ | ----------------------------------------------------------------------------------------------------------------------- |
| model (в пути)                           | string | Да                       | Модель Gemini с поддержкой generateContent и вывода изображений; чисто текстовая модель не подходит.                    |
| contents                                 | array  | Да                       | Список сообщений; для генерации по тексту обычно достаточно одного user.                                                |
| contents\[].role                         | string | Нет                      | user; для ответов модели в истории используется model.                                                                  |
| contents\[].parts\[].text                | string | Да                       | Описание изображения или инструкция редактирования.                                                                     |
| generationConfig.responseModalities      | array  | Нет                      | Например, \["TEXT","IMAGE"] для текста и изображений; допустимые сочетания зависят от модели.                           |
| generationConfig.imageConfig.aspectRatio | string | Нет                      | Если поддерживается, доступны соотношения 1\:1, 16\:9, 9\:16 и другие.                                                  |
| generationConfig.imageConfig.imageSize   | string | Нет                      | Если поддерживается\: 1K, 2K, 4K и другие значения выбранной модели. Не все графические модели принимают этот параметр. |
| contents\[].parts\[].inlineData          | object | Да (встроенный референс) | Отдельный от text элемент Part с mimeType и data.                                                                       |
| inlineData.mimeType                      | string | Да                       | Фактический MIME референса\: image/png, image/jpeg или image/webp.                                                      |
| inlineData.data                          | string | Да                       | Чистый Base64 файла без префикса data\:.                                                                                |
| contents\[].parts\[].fileData            | object | При условии              | Альтернатива встроенным данным\: разрешенные fileUri/mimeType, доступные провайдеру.                                    |

Одно изображение — один Part. Для нескольких добавьте соответствующие Part и объясните назначение каждого. Число изображений, разрешение и согласованность итераций зависят от модели; единый предел для всех Gemini некорректен.

### Характеристики изображений\: 1K, 2K и 4K

K — распространённое обозначение разрешения, а не размера файла или параметра качества. Фактические размеры зависят от модели и пропорций. При одинаковых пропорциях удвоение обеих сторон увеличивает число пикселей вчетверо. Примеры объясняют термины, но не являются допустимыми размерами для всех моделей.

Если модель поддерживает эти настройки, Gemini использует `generationConfig.imageConfig.imageSize` для выбора `1K`, `2K` или `4K`, а `generationConfig.imageConfig.aspectRatio` — для пропорций. Фактические размеры уточняйте для выбранной модели.

| Обозначение разрешения | Типичные размеры в пикселях (без гарантии поддержки моделью)    |
| ---------------------- | --------------------------------------------------------------- |
| 1K                     | 1024×1024 · Около тысячи пикселей по стороне                    |
| 2K                     | 2048×2048 · Около двух тысяч пикселей по стороне                |
| 4K                     | 4096×4096 / 3840×2160 · Около четырёх тысяч пикселей по стороне |

Тарифные категории сайта за изображение определяются отдельно; эти примеры разрешений не задают правила оплаты. [Характеристики и правила тарификации](/simidoc/ru/apps/api/images).

### Структура запроса

Замените `BASE64_IMAGE_BYTES` на чистый Base64 авторизованного изображения.

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "保留主体形状和布局，将图片改成水彩插画，背景改为浅蓝色。"
        },
        {
          "inlineData": {
            "mimeType": "image/png",
            "data": "BASE64_IMAGE_BYTES"
          }
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

Base64 выше иллюстрирует структуру. Сохраняйте результат по фактическому MIME. Для следующей правки добавьте в историю полный model content предыдущего ответа с thoughtSignature и другими непрозрачными полями, затем новый user-запрос. Не ограничивайтесь копированием байтов картинки и не теряйте обязательные подписи; не изменяйте их.

Нативное редактирование Gemini задает область естественным языком. OpenAI mask не является универсальным параметром этого API. Для точного ограничения области проверьте входы выбранной модели; одинаковое имя поля не доказывает совместимость.

## Примеры вызова

Укажите `API_URL` и `API_KEY` в начале кода; в примерах используется `gemini-3-pro-image`; замените `BASE64_IMAGE_BYTES` на чистый Base64 разрешённого изображения (без префикса data\:). `API_URL` — полный URL запроса, по умолчанию адрес шлюза `https://api.dwchainless.com`. Примеры используют только стандартные библиотеки, отправляют один запрос и выводят полученный JSON; изображение автоматически не сохраняется.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY = "PASTE_API_KEY_HERE"
    IMAGE_BASE64 = "BASE64_IMAGE_BYTES"
    body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "保留主体和构图，将背景改为浅蓝色。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": IMAGE_BASE64
              }
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
    const IMAGE_BASE64 = 'BASE64_IMAGE_BYTES';
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
                text: '保留主体和构图，将背景改为浅蓝色。'
              },
              {
                inlineData: {
                  mimeType: 'image/png',
                  data: IMAGE_BASE64
                }
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
    IMAGE_BASE64="BASE64_IMAGE_BYTES"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary @- <<JSON
      {
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": "保留主体和构图，将背景改为浅蓝色。"
              },
              {
                "inlineData": {
                  "mimeType": "image/png",
                  "data": "$IMAGE_BASE64"
                }
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
    JSON
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
                            "text": "保留主体和构图，将背景改为浅蓝色。"
                        },
                        {
                            "inlineData": {
                                "mimeType": "image/png",
                                "data": "BASE64_IMAGE_BYTES"
                            }
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
Read this Gemini protocol page and its image editing reference first. Use the existing
API_KEY, MODEL and configured SimiRouter request URL; never reveal credentials or change
the existing connection. Read only the authorized local image, encode it as pure Base64,
and put it in IMAGE_BASE64. Submit its inlineData Part alongside the text instruction
through POST /v1beta/models/{model}:generateContent. Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. Keep the subject and layout; change only the background to pale blue. Request one
image, non-streaming; use aspectRatio=1:1 and imageSize=1K only if supported. Do not use
OpenAI multipart or mask fields. After the response, read only completed, non-thought
inlineData from parts; decode the Base64 in memory and report any unmet requirement; do
not write an image file. Preserve opaque signatures for later turns. Do not upload
unrelated files, overwrite results, change model/size/count/provider, install remote
skills, or retry automatically. Ask before any additional paid request.
```

## Коды ошибок

| Статус HTTP | Значение или тип ошибки провайдера | Действие                                                                    |
| ----------- | ---------------------------------- | --------------------------------------------------------------------------- |
| 400         | `INVALID_ARGUMENT` и другие        | Проверьте JSON, параметры модели, MIME и длину ввода.                       |
| 403         | `PERMISSION_DENIED`                | Проверьте ключ, права проекта, регион и платежные ограничения.              |
| 404         | `NOT_FOUND`                        | Проверьте имя модели и версию API.                                          |
| 429         | `RESOURCE_EXHAUSTED`               | Проверьте частоту и квоту; для повторяемых ошибок ограничьте число попыток. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`         | Сохраните ID запроса и повторите ограниченно либо позже.                    |

Ошибка Google содержит `error.code` (HTTP-число), `error.status` (имя перечисления), `error.message`; возможны также `details`. Шлюз может вернуть ошибку аутентификации, маршрута или квоты до провайдера. Не определяйте источник ошибки только по HTTP-коду. Отказ модели, отсутствие картинки, завершение не STOP и HTTP-ошибка — разные случаи. Входное изображение нельзя выдавать за результат редактирования.

## Официальные материалы

* [Google\: генерация и редактирование изображений](https\://ai.google.dev/gemini-api/docs/image-generation)
* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google\: понимание изображений и медиа-ввод](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Google\: диагностика ошибок](https\://ai.google.dev/gemini-api/docs/troubleshooting)