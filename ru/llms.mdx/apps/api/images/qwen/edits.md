# Редактирование изображений Qwen

## Описание интерфейса

`POST /v1/images/edits`, тело — JSON. В примерах используется шлюз сайта `https://api.dwchainless.com`, а `API_KEY` — ключ сайта; тело запроса сохраняет нативную структуру Qwen `model`, `input.messages`, `parameters`, ответ унифицирован как `data[]`.

При редактировании в content помещаются элемент image и одна текстовая инструкция; multipart-поле file не используется.

## Параметры запроса

| Поле                               | Тип       | Обязателен | Описание                                                                                                                                             |
| ---------------------------------- | --------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                              | string    | Да         | qwen-image-2.0-pro или конкретная версия, поддерживаемая каналом сайта.                                                                              |
| input.messages                     | object\[] | Да         | Ровно одно сообщение user для одного обмена.                                                                                                         |
| input.messages\[].role             | string    | Да         | Всегда user.                                                                                                                                         |
| input.messages\[].content\[].text  | string    | Да         | Инструкция на китайском или английском; один элемент text за ход.                                                                                    |
| input.messages\[].content\[].image | string    | Да         | Доступный URL / data URL одного или нескольких референсных изображений. Число входных изображений и пиксельные ограничения зависят от версии модели. |
| parameters.size                    | string    | Нет        | Ширина × высота, например 2048 × 2048; для серии 2.0 суммарное число пикселей — от 512×512 до 2048×2048.                                             |
| parameters.n                       | integer   | Нет        | По умолчанию 1; серия 2.0 поддерживает 1–6.                                                                                                          |
| parameters.negative\_prompt        | string    | Нет        | Нежелательное содержимое, до 500 символов.                                                                                                           |
| parameters.prompt\_extend          | boolean   | Нет        | По умолчанию true\: автоматически расширяет положительную инструкцию.                                                                                |
| parameters.watermark               | boolean   | Нет        | Добавлять ли видимый водяной знак; соблюдайте применимые требования к маркировке синтетического контента.                                            |

### Характеристики изображений\: 1K, 2K и 4K

K — распространённое сокращение разрешения, а не размера файла и не параметра качества. Фактические ширина и высота зависят от модели и пропорций; при одинаковых пропорциях удвоение обеих сторон увеличивает число пикселей вчетверо. Ниже приведено лишь пояснение терминов, а не допустимые размеры для всех моделей.

Qwen указывает допустимые моделью ширину и высоту в `parameters.size` в формате вроде `2048*2048`, а не строкой `2K`. У серии 2.0 также есть ограничение общего числа пикселей; приведённый ниже пример квадрата 4K не означает, что такой размер можно отправить.

| Обозначение разрешения | Типичные размеры в пикселях (без гарантии поддержки моделью) |
| ---------------------- | ------------------------------------------------------------ |
| 1K                     | Обе стороны ≤ 1024 пикселей; например 1024×1024.             |
| 2K                     | Длинная сторона > 1024 и ≤ 2048 пикселей; например 1280×720. |
| 4K                     | Любая сторона > 2048 пикселей; например 2560×1440.           |

Тарифные категории сайта за изображение определяются отдельно; эти примеры разрешений нельзя напрямую использовать как тарифные правила. [Характеристики и правила тарификации](/simidoc/ru/apps/api/images).

## Ответ

| Поле                    | Описание                                                                                                 |
| ----------------------- | -------------------------------------------------------------------------------------------------------- |
| `created`               | Временная метка создания ответа.                                                                         |
| `data[].url`            | URL сгенерированного изображения; срок действия определяется каналом, скачивайте или сохраняйте вовремя. |
| `data[].b64_json`       | Некоторые каналы возвращают чистый Base64; при наличии можно сразу декодировать и сохранить.             |
| `data[].revised_prompt` | Переписанный каналом промпт; может отсутствовать.                                                        |
| `error` / `message`     | Код и описание ошибки при неудаче.                                                                       |

```json
{"created":1760000000,"data":[{"url":"https://example.com/edited.png","b64_json":null,"revised_prompt":"..."}]}
```

## Вызов из кода

В начале кода укажите `API_URL` и `API_KEY`. `API_URL` — адрес шлюза сайта `https://api.dwchainless.com/v1/images/edits`, `API_KEY` — ключ сайта. Пример использует только стандартные библиотеки, отправляет один запрос и печатает полученный JSON; изображение автоматически не скачивается и не сохраняется.

Задайте `IMAGE_URL` как реальный HTTP(S)-адрес изображения, на который есть разрешение и который доступен из облака. Код проверяет только форму URL и не подтверждает, что изображение можно скачать или что оно удовлетворяет ограничениям формата канала; не используйте локальный путь, localhost, страницу с авторизацией или фиктивную ссылку.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "qwen-image-2.0-pro",
      "input": {
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "image": "https://example.com/reference.png"
              },
              {
                "text": "保留主体和构图，将背景改为浅蓝色。"
              }
            ]
          }
        ]
      },
      "parameters": {
        "size": "1024*1024",
        "n": 1
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
    const API_URL = 'https://api.dwchainless.com/v1/images/edits';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'qwen-image-2.0-pro',
        input: {
          messages: [
            {
              role: 'user',
              content: [
                {
                  image: 'https://example.com/reference.png'
                },
                {
                  text: '保留主体和构图，将背景改为浅蓝色。'
                }
              ]
            }
          ]
        },
        parameters: {
          size: '1024*1024',
          n: 1
        }
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/images/edits"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "qwen-image-2.0-pro",
        "input": {
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "image": "https://example.com/reference.png"
                },
                {
                  "text": "保留主体和构图，将背景改为浅蓝色。"
                }
              ]
            }
          ]
        },
        "parameters": {
          "size": "1024*1024",
          "n": 1
        }
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/images/edits"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "qwen-image-2.0-pro",
            "input": {
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "image": "https://example.com/reference.png"
                            },
                            {
                                "text": "保留主体和构图，将背景改为浅蓝色。"
                            }
                        ]
                    }
                ]
            },
            "parameters": {
                "size": "1024*1024",
                "n": 1
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

Скопируйте задание ниже агенту с возможностями локального выполнения и проверки возвращённых результатов; сначала по [настройке этого протокола](/simidoc/ru/apps/api/images/qwen) укажите API\_URL и API\_KEY прямо в примере кода и проверьте имя model. Не вставляйте ключ в промпт.

```text
Read this Qwen image protocol page and its editing reference first. Use the existing
API_KEY and API_URL from this site's gateway; never reveal the key or switch the
existing connection. Verify qwen-image-2.0-pro supports the edit. Use only the
authorized cloud-readable image in IMAGE_URL; do not upload unrelated local files or
publish a file. POST once to /v1/images/edits with the native Qwen body: one user
message containing that image item and one text instruction: keep the subject and
layout; change only the background to pale blue. Set parameters.n=1 and size=1024*1024
only if supported. Do not use OpenAI multipart or mask fields. Check the completed
business result, inspect data[].url or data[].b64_json without forwarding the API key,
and report it. Do not write files, change model/size/count/provider, install remote
skills, or retry automatically. If any step fails or the requested edit is not met,
report a redacted error instead of claiming success.
```

## Коды ошибок

| Ошибка                 | Обработка                                                                                                  |
| ---------------------- | ---------------------------------------------------------------------------------------------------------- |
| 400 / InvalidParameter | Проверьте структуру content, характеристики изображения, выходной size и поддерживаемые моделью параметры. |
| 401                    | Проверьте, существует ли ключ API сайта, действителен ли он и принадлежит ли правильно.                    |
| 403 / 404              | Проверьте права на модель, канал и наличие ресурса.                                                        |
| 429                    | Лимит частоты или нехватка средств; выясните причину и повторите с задержкой.                              |
| 5xx                    | Сбой сервиса; сохраните идентификатор запроса и избегайте неограниченных повторов генерации.               |

## Официальные материалы

[Редактирование Qwen-Image](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api), [Коды ошибок Model Studio](https\://www.alibabacloud.com/help/en/model-studio/error-code).