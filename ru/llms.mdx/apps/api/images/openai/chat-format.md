# Генерация изображений в диалоге

## Описание интерфейса

`POST /v1/responses` объявляет image\_generation в tools\: основная модель с поддержкой инструмента создает изображение с учетом ввода. Основной model — диалоговая модель. Настройки графической модели инструмента должны соответствовать текущей официальной поддержке.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $API_KEY`. Прямой OpenAI — `https://api.openai.com`; также Bearer, но нужен ключ OpenAI. Выберите доступную модель с поддержкой требуемой функции.

Нативная диалоговая генерация OpenAI использует image\_generation в Responses, а не соглашение о Markdown-ссылках обычного Chat Completions. Если совместимый провайдер возвращает ссылки через Chat, это его расширение, не стандарт OpenAI.

## Параметры запроса

| Поле                                 | Тип             | Обязателен | Описание                                                                                                                     |
| ------------------------------------ | --------------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------- |
| model                                | string          | Да         | Основная модель Responses с поддержкой image\_generation.                                                                    |
| input                                | string / array  | Да         | Текстовая инструкция; для правки возможен input\_image.                                                                      |
| tools\[].type                        | string          | Да         | image\_generation.                                                                                                           |
| tools\[].output\_format              | string          | Нет        | png, jpeg, webp; в примере png.                                                                                              |
| tools\[].size / quality / background | string          | Нет        | Размер, качество и фон, поддерживаемые инструментом.                                                                         |
| tool\_choice                         | string / object | Нет        | auto оставляет выбор модели; принудительный вызов задается форматом, поддерживаемым инструментом.                            |
| previous\_response\_id               | string          | Нет        | Продолжает сохраненный вышестоящий ответ с доступным в том же сервисе контекстом; универсального API получения на шлюзе нет. |
| stream                               | boolean         | Нет        | true включает события Responses.                                                                                             |

### Пример запроса

```json
{
  "model": "gpt-5.5",
  "input": "生成一张小机器人在图书馆阅读的水彩插画，浅蓝色背景，不要文字。",
  "tools": [
    {
      "type": "image_generation",
      "model": "gpt-image-2",
      "output_format": "png"
    }
  ],
  "stream": false
}
```

## Ответ

| Поле                        | Тип           | Описание                                                                                         |
| --------------------------- | ------------- | ------------------------------------------------------------------------------------------------ |
| id / status                 | string        | ID и итоговый статус; полный ответ завершен только при completed.                                |
| output\[].type              | string        | Изображение возвращается элементом image\_generation\_call; также возможен message.              |
| output\[].id / status       | string        | ID графического вызова и статус инструмента.                                                     |
| output\[].result            | string        | Base64 итогового изображения; не data\[].b64\_json.                                              |
| output\[].revised\_prompt   | string        | Переработанный запрос графического инструмента, если поддерживается.                             |
| output\[].content\[].text   | string        | Необязательные пояснения в элементе message.                                                     |
| usage                       | object        | Потребление основной модели; стоимость графического инструмента не сводится к текстовым токенам. |
| error / incomplete\_details | object / null | Причины ошибки и неполного результата.                                                           |

```json
{
  "id": "resp_image_example",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "id": "ig_example",
      "type": "image_generation_call",
      "status": "completed",
      "result": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "error": null,
  "incomplete_details": null
}
```

Base64 — структурный пример минимального PNG. Для правки отправьте изображение как input\_image с новой инструкцией либо используйте previous\_response\_id в сервисе с поддержкой и сохраненным контекстом. Произвольный ID ответа не является межканальным файловым ресурсом.

## Примеры вызова

Укажите `API_URL` и `API_KEY` в начале кода; в примерах используется `gpt-5.5` как основная модель и `gpt-image-2` как модель инструмента изображений. `API_URL` — полный URL запроса, по умолчанию адрес шлюза `https://api.dwchainless.com`. Примеры используют только стандартные библиотеки, отправляют один запрос и выводят полученный JSON; изображение автоматически не сохраняется.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/responses"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "gpt-5.5",
      "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
      "tools": [
        {
          "type": "image_generation",
          "model": "gpt-image-2"
        }
      ]
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
    const API_URL = 'https://api.dwchainless.com/v1/responses';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-5.5',
        input: '生成一张小机器人在图书馆阅读的水彩插画，不要文字。',
        tools: [
          {
            type: 'image_generation',
            model: 'gpt-image-2'
          }
        ]
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/responses"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-5.5",
        "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
        "tools": [
          {
            "type": "image_generation",
            "model": "gpt-image-2"
          }
        ]
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/responses"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-5.5",
            "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
            "tools": [
                {
                    "type": "image_generation",
                    "model": "gpt-image-2"
                }
            ]
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

## Коды ошибок

| Статус HTTP | Значение или тип ошибки провайдера       | Действие                                                                          |
| ----------- | ---------------------------------------- | --------------------------------------------------------------------------------- |
| 400         | Неверный запрос                          | Проверьте обязательные поля, JSON, параметры модели и длину контекста.            |
| 401         | Ошибка аутентификации                    | Проверьте наличие, действительность и принадлежность ключа.                       |
| 403 / 404   | Нет доступа / ресурс не найден           | Проверьте права модели, ID ресурса и URL.                                         |
| 429         | Ограничение частоты или квоты            | Различайте лимит скорости и нехватку квоты по ответу; повтор не восполняет квоту. |
| 500 / 503   | Ошибка сервиса / временная недоступность | Сохраните ID и ограниченно повторите временные сбои с задержкой.                  |

Ошибка OpenAI обычно содержит `error.message`, `error.type`, `error.param`, `error.code`; `param` и `code` могут быть `null`; эти поля необязательны и могут отличаться от HTTP-статуса. Шлюз может отказать до обращения к провайдеру. completed без image\_generation\_call.result может означать только текстовый ответ. Проверяйте выбор инструмента и элементы результата; нельзя выдумывать изображение.

## Официальные материалы

* [OpenAI\: генерация изображений в диалоге](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI\: обработка ошибок](https\://developers.openai.com/api/docs/guides/error-codes)