# Редактирование и генерация по изображению

## Описание интерфейса

`POST /v1/images/edits` принимает референсы и инструкции, возвращая измененное изображение. Поддерживаемые задачи включают фон, стиль, добавление/удаление элементов и комбинацию нескольких референсов.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $API_KEY`. Прямой OpenAI — `https://api.openai.com`; также Bearer, но нужен ключ OpenAI. Выберите доступную модель с поддержкой требуемой функции.

Поддерживаются ссылки images\[] в JSON и загрузка multipart. Примеры передают доступный серверу HTTPS-URL изображения через JSON `images[].image_url`; multipart не используется.

## Быстрый старт

1. **Подготовьте настройки**\: создайте ключ в разделе [Управление API-ключами](https://api.dwchainless.com/keys) и скопируйте из [Моделей и цен](https://api.dwchainless.com/ru/pricing/) ID графической модели с поддержкой редактирования.
2. **Подготовьте референсы**\: используйте доступные серверу HTTPS-URL или загрузите локальные файлы через multipart; не смешивайте оба способа в одном запросе.
3. **Отправьте запрос**\: отправьте в `https://api.dwchainless.com/v1/images/edits` JSON с `model`, `prompt` и ссылками на изображения; используйте заголовок `Authorization: Bearer $API_KEY`.
4. **Прочитайте и проверьте**\: успех требует HTTP 2xx и непустого `data[]`; декодируйте `data[].b64_json` или скачайте `data[].url`, затем проверьте файл, размеры и содержимое.

Для первого вызова отредактируйте одно изображение без потоковой передачи; когда всё заработает, добавьте референсы или включите поток.

## Параметры запроса

| Поле                 | Тип     | Обязателен     | Описание                                                                                                                                                                                 |
| -------------------- | ------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                | string  | Да (шлюз)      | Явно выберите графическую модель с редактированием, не полагайтесь на значение провайдера по умолчанию.                                                                                  |
| images               | array   | Да (JSON)      | Список ссылок на изображения\: нативный GPT Image — до 16; модель может иметь более строгий предел.                                                                                      |
| images\[].image\_url | string  | При условии    | HTTPS URL изображения или data\:image/...;base64,...; в примере используется HTTPS URL.                                                                                                  |
| images\[].file\_id   | string  | При условии    | ID ресурса официального Files, альтернатива image\_url. Нельзя считать доступным на шлюзе без проверки.                                                                                  |
| prompt               | string  | Да             | Явно опишите, что изменить и что сохранить.                                                                                                                                              |
| mask                 | object  | Нет            | В JSON ссылка mask.image\_url или mask.file\_id; правила маски зависят от модели.                                                                                                        |
| image / image\[]     | file    | Да (multipart) | Одно или несколько полей изображения multipart; не смешивайте с JSON images.                                                                                                             |
| mask (multipart)     | file    | Нет            | PNG-маска\: прозрачные области задают редактирование. Размеры и формат должны соответствовать исходнику и требованиям модели.                                                            |
| input\_fidelity      | string  | Нет            | Только для поддерживающих моделей; не все поколения GPT Image принимают параметр.                                                                                                        |
| n                    | integer | Нет            | Количество изображений\: нативный диапазон OpenAI GPT Image 1–10; в примере 1.                                                                                                           |
| size                 | string  | Нет            | Нативный формат OpenAI — WIDTHxHEIGHT (ширина и высота кратны 16, пропорции от 1\:3 до 3\:1) или auto; SimiRouter также принимает пропорции с resolution, ограничения зависят от модели. |
| resolution           | string  | Нет            | Расширение SimiRouter\: уровень 1k, 2k или 4k вместе с пропорциями, не значение в пикселях; в нативном API OpenAI такого поля нет.                                                       |
| aspect\_ratio        | string  | Нет            | Расширение SimiRouter\: отдельные пропорции, например 3\:4; пропорции в size имеют приоритет.                                                                                            |
| quality              | string  | Нет            | auto, low, medium, high; некоторые новые модели также xhigh, max.                                                                                                                        |
| output\_format       | string  | Нет            | png, jpeg (в примерах) или webp; официальная схема также допускает gif и svg при поддержке модели и проекта.                                                                             |
| output\_compression  | integer | Нет            | Качество сжатия JPEG/WebP 0–100; не применяется к PNG.                                                                                                                                   |
| background           | string  | Нет            | auto, opaque, transparent; прозрачность требует подходящей модели и PNG/WebP.                                                                                                            |
| moderation           | string  | Нет            | auto или поддерживаемый low; не гарантирует прохождение правил контента.                                                                                                                 |
| response\_format     | string  | Нет            | Некоторые совместимые модели принимают url или b64\_json; нативный GPT Image его не использует.                                                                                          |
| stream               | boolean | Нет            | true включает графические SSE-события.                                                                                                                                                   |
| partial\_images      | integer | Нет            | При stream=true запрашивает 0–3 промежуточные картинки; все равно нужно ждать итогового события.                                                                                         |

Выберите JSON или multipart. Для multipart клиент должен автоматически формировать Content-Type с boundary. Маска не гарантирует попиксельную точность; итог проверяется человеком.

## Выбор способа передачи изображений

Референс можно передать четырьмя способами; выберите один по условиям окружения и не смешивайте их в одном запросе\:

| Способ         | Поле                              | Когда использовать                                                      |
| -------------- | --------------------------------- | ----------------------------------------------------------------------- |
| URL в JSON     | `images[].image_url`              | Изображение доступно серверу по публичному URL                          |
| Base64 в JSON  | `images[].image_url` как data URL | Изображение небольшое и публичный URL нежелателен                       |
| файл multipart | `image` или `image[]`             | Локальные файлы, загружаемые клиентом                                   |
| ID Files       | `images[].file_id`                | Изображение уже загружено через официальный Files, шлюз поддерживает ID |

JSON-запросы используют `Content-Type: application/json`; для multipart клиент должен сформировать boundary в `Content-Type`, не указывайте его вручную.

### Структура JSON-запроса

Пример JSON использует доступный серверу HTTPS URL изображения.

```json
{
  "model": "gpt-image-2",
  "images": [
    {
      "image_url": "https://example.com/reference.png"
    }
  ],
  "prompt": "保留主体形状和布局，将图片改成水彩插画，背景改为浅蓝色。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

### Структура multipart-запроса

Для одного локального референса используйте поле `image`; для нескольких — `image[]`, описывая назначение каждого изображения по порядку\:

```bash
API_URL="https://api.dwchainless.com/v1/images/edits"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -F "model=gpt-image-2" \
  -F "prompt=保留主体和构图，将背景改为浅蓝色。" \
  -F "image=@reference.png" \
  -F "size=1024x1024" \
  -F "n=1"
```

## Как писать запрос на редактирование

Запрос должен одновременно указывать, что сохранить и что изменить; фраза «сделай акварелью» может заставить модель перерисовать всю сцену. Стройте его по схеме «сохранить + изменить + ограничение»\:

| Сценарий                             | Акцент запроса                                                              | Пример                                                                          |
| ------------------------------------ | --------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| Сохранить человека или товар         | Указать, что субъект, поза, композиция и текст не меняются                  | Сохраните позу и одежду человека, измените только фон на светло-синий.          |
| Смена стиля                          | Указать целевой стиль и сохраняемую компоновку                              | Сделайте акварельной иллюстрацией, сохранив композицию и положение субъекта.    |
| Локальная правка                     | Назвать область; при поддержке модели использовать `mask`                   | Измените только чашку в левом нижнем углу, остальное оставьте без изменений.    |
| Композиция из нескольких изображений | Описать роль каждого изображения, отношения субъектов и итоговую компоновку | Первое изображение — человек, второе — сцена; поместите человека в центр сцены. |

«Сохранить» — цель, а не попиксельная гарантия; детали людей, товаров и текста могут измениться, а контент, связанный с личностью или брендом, нужно проверять вручную. Прозрачность требует поддержки `background: transparent` и вывода PNG или WebP.

## Размер и формат

`size` задаёт поддерживаемые моделью размеры в пикселях, например `1024x1024`; `quality` управляет качеством, а `output_format` — кодированием PNG/JPEG/WebP. Размер результата правки определяется `size` (по умолчанию `auto` — выбирает модель) и не обязан совпадать с референсом.

Тарифные категории сайта 1K, 2K и 4K за изображение и обозначения разрешения провайдеров — разные правила; три способа записи size, таблица 14 пропорций и границы тарификации см. в [характеристиках и тарификации изображений](/simidoc/ru/apps/api/images).

## Ответ

| Поле                                                 | Тип     | Описание                                                                                        |
| ---------------------------------------------------- | ------- | ----------------------------------------------------------------------------------------------- |
| created                                              | integer | Время создания в секундах Unix.                                                                 |
| data\[]                                              | array   | Список результатов; наличие первого элемента не гарантируется.                                  |
| data\[].b64\_json                                    | string  | Base64 бинарных данных; GPT Image использует этот формат.                                       |
| data\[].url                                          | string  | Появляется лишь у совместимых моделей с URL-выводом; не обязательное поле GPT Image.            |
| data\[].revised\_prompt                              | string  | Переработанный запрос некоторых старых или совместимых моделей; не обязательное поле GPT Image. |
| output\_format / size / quality / background         | string  | Необязательная фактическая конфигурация вывода.                                                 |
| usage                                                | object  | Необязательные данные потребления; наличие и детализация зависят от модели и сервиса.           |
| usage.input\_tokens / output\_tokens / total\_tokens | integer | Если возвращаются\: входные, выходные и общие токены.                                           |
| usage.input\_tokens\_details                         | object  | Необязательные image\_tokens, text\_tokens и другая детализация.                                |
| X-Request-Id                                         | string  | Заголовок ответа, не поле JSON; сохраняйте его для поддержки и диагностики.                     |

```json
{
  "created": 1760000000,
  "data": [
    {
      "b64_json": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "output_format": "png"
}
```

Base64 — минимальный PNG для демонстрации полей. Возвращённый data\[].url может истечь; не добавляйте ключ API при скачивании изображения. Потоковая правка использует image\_edit.partial\_image и image\_edit.completed; только итоговое событие означает завершение. Генерация по изображению не гарантирует попиксельного сохранения человека, товара и текста.

## Примеры вызова

Укажите `API_URL` и `API_KEY` в начале кода; в примерах используется `gpt-image-2`. `API_URL` — полный URL запроса, по умолчанию адрес шлюза `https://api.dwchainless.com`. `IMAGE_URL` — HTTPS-URL изображения, доступный серверу. Примеры используют только стандартные библиотеки, отправляют один запрос и выводят полученный JSON; изображение автоматически не сохраняется.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "images": [{"image_url": "https://example.com/reference.png"}],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
        "size": "1024x1024",
        "n": 1,
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
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        images: [
          {
            image_url: 'https://example.com/reference.png',
          },
        ],
        prompt: '保留主体和构图，将背景改为浅蓝色。',
        size: '1024x1024',
        n: 1,
      }),
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
        "model": "gpt-image-2",
        "images": [
          {
            "image_url": "https://example.com/reference.png"
          }
        ],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
        "size": "1024x1024",
        "n": 1
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
            "model": "gpt-image-2",
            "images": [
                {
                    "image_url": "https://example.com/reference.png"
                }
            ],
            "prompt": "保留主体和构图，将背景改为浅蓝色。",
            "size": "1024x1024",
            "n": 1
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

Передайте это задание агенту с инструментами локального выполнения и проверки ответа. Сначала задайте переменные среды по [настройке этого протокола](/simidoc/ru/apps/api/images/openai). Не вставляйте ключ в задание.

```text
Read this OpenAI image protocol page and its editing reference first. Set API_KEY,
MODEL, and API_URL directly in the example; use the configured SimiRouter request URL;
never reveal the key or change the existing connection. Use only the authorized HTTPS
image URL in IMAGE_URL. Use POST /v1/images/edits with JSON images[]; do not set
multipart Content-Type or send local files. Keep the subject and layout; change only the
background to pale blue. Request one PNG at 1024x1024 with stream=false only if the
selected model supports it. Print the returned JSON and inspect data[].b64_json; do not
write an image file. Confirm that data[].b64_json contains non-empty Base64 data and
report any unmet requirement. Do not upload unrelated files, change
size/count/model/provider, install remote skills, or retry automatically after an error
or timeout. Ask before another paid request.
```

## Коды ошибок

| Статус HTTP     | Значение или тип ошибки провайдера                                | Действие                                                                              |
| --------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| 400             | Неверный запрос                                                   | Проверьте обязательные поля, JSON, параметры модели и длину контекста.                |
| 401             | Ошибка аутентификации                                             | Проверьте наличие, действительность и принадлежность ключа.                           |
| 403 / 404       | Нет доступа / ресурс не найден                                    | Проверьте права модели, ID ресурса и URL.                                             |
| 413             | Слишком большое тело запроса или изображение                      | Предпочитайте URL изображений; уменьшите размер Base64 или сами изображения.          |
| 429             | Ограничение частоты или квоты                                     | Различайте лимит скорости и нехватку квоты по ответу; повтор не восполняет квоту.     |
| 500 / 502 / 503 | Ошибка сервиса / перегруженный upstream / временная недоступность | Сохраните ID запроса и ограниченно повторяйте временные сбои с нарастающей задержкой. |

Ошибка OpenAI обычно содержит `error.message`, `error.type`, `error.param`, `error.code`; `param` и `code` могут быть `null`; эти поля необязательны и могут отличаться от HTTP-статуса. Шлюз может отказать до провайдера. Некорректное изображение, MIME, размеры маски или неподдерживаемый параметр — ошибки ввода. Сначала исправьте их, не отправляйте повторно без изменений.

Правка может занимать от десятков секунд до нескольких минут; задайте достаточный таймаут клиента, поскольку зависший запрос не равен ошибке. После таймаута, разрыва потока или 5xx сначала проверьте, не был ли запрос уже выполнен, и только потом повторяйте — чтобы избежать двойной генерации и повторной оплаты. При отказе по политике контента (обычно 400) измените запрос или референс, а не повторяйте без изменений.

## Официальные материалы

* [OpenAI Create image edit](https\://developers.openai.com/api/reference/resources/images/methods/edit)
* [OpenAI\: генерация и редактирование изображений](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI\: обработка ошибок](https\://developers.openai.com/api/docs/guides/error-codes)