# Генерация изображений

## Описание интерфейса

`POST /v1/images/generations` создает одно или несколько изображений по prompt.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $API_KEY`. Прямой OpenAI — `https://api.openai.com`; также Bearer, но нужен ключ OpenAI. Выберите доступную модель с поддержкой требуемой функции.

Здесь используются параметры GPT Image. Совместимые графические модели разных провайдеров могут иметь иные размеры, качество и форматы ответа; это не единый официальный стандарт.

## Быстрый старт

1. **Подготовьте настройки**\: создайте ключ в разделе [Управление API-ключами](https://api.dwchainless.com/keys) и скопируйте из [Моделей и цен](https://api.dwchainless.com/ru/pricing/) ID модели с поддержкой Images API.
2. **Отправьте запрос**\: отправьте JSON на `https://api.dwchainless.com/v1/images/generations` с заголовком `Authorization: Bearer $API_KEY`; тело должно содержать как минимум `model` и `prompt`.
3. **Прочитайте результат**\: успех требует HTTP 2xx и непустого `data[]`; декодируйте и сохраните `data[].b64_json` от GPT Image.
4. **Подтвердите завершение**\: проверьте, что файл открывается и соответствует нужным размерам, затем изучите журнал использования.

Минимальный запрос ниже; когда он заработает, измените количество, размер или включите потоковую передачу\:

```bash
API_URL="https://api.dwchainless.com/v1/images/generations"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
    "n": 1,
    "size": "1024x1024",
    "output_format": "png"
  }'
```

## Параметры запроса

Тело запроса — JSON.

| Поле                | Тип     | Обязателен | Описание                                                                                                                                                                                 |
| ------------------- | ------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model               | string  | Да         | ID графической модели с поддержкой Images API.                                                                                                                                           |
| prompt              | string  | Да         | Точное описание объекта, композиции, стиля и надписей.                                                                                                                                   |
| n                   | integer | Нет        | Количество изображений\: нативный диапазон OpenAI GPT Image 1–10; в примере 1.                                                                                                           |
| size                | string  | Нет        | Нативный формат OpenAI — WIDTHxHEIGHT (ширина и высота кратны 16, пропорции от 1\:3 до 3\:1) или auto; SimiRouter также принимает пропорции с resolution, ограничения зависят от модели. |
| resolution          | string  | Нет        | Расширение SimiRouter\: уровень 1k, 2k или 4k вместе с пропорциями, не значение в пикселях; в нативном API OpenAI такого поля нет.                                                       |
| aspect\_ratio       | string  | Нет        | Расширение SimiRouter\: отдельные пропорции, например 3\:4; пропорции в size имеют приоритет.                                                                                            |
| quality             | string  | Нет        | auto, low, medium, high; некоторые новые модели также xhigh, max.                                                                                                                        |
| output\_format      | string  | Нет        | png, jpeg (в примерах) или webp; официальная схема также допускает gif и svg при поддержке модели и проекта.                                                                             |
| output\_compression | integer | Нет        | Качество сжатия JPEG/WebP 0–100; не применяется к PNG.                                                                                                                                   |
| background          | string  | Нет        | auto, opaque, transparent; прозрачность требует подходящей модели и PNG/WebP.                                                                                                            |
| moderation          | string  | Нет        | auto или поддерживаемый low; не гарантирует прохождение правил контента.                                                                                                                 |
| response\_format    | string  | Нет        | Некоторые совместимые модели принимают url или b64\_json; нативный GPT Image его не использует.                                                                                          |
| stream              | boolean | Нет        | true включает графические SSE-события.                                                                                                                                                   |
| partial\_images     | integer | Нет        | При stream=true запрашивает 0–3 промежуточные картинки; все равно нужно ждать итогового события.                                                                                         |

GPT Image возвращает Base64 напрямую\: не полагайтесь на устаревший response\_format=url/b64\_json. Некоторые совместимые модели могут использовать это поле для выбора URL или Base64 — в зависимости от документации модели и фактического ответа. style=vivid/natural также не подходит; стиль задается в prompt.

### Пример запроса

```json
{
  "model": "gpt-image-2",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，柔和蓝金色调，不要文字。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

## Размер и формат

K — распространённое обозначение разрешения, а не размера файла или параметра качества. Фактические размеры зависят от модели и пропорций. При одинаковых пропорциях удвоение обеих сторон увеличивает число пикселей вчетверо. Примеры объясняют термины, но не являются допустимыми размерами для всех моделей.

В OpenAI параметр `size` задаёт поддерживаемые размеры, например `1024x1024`, а не строку `1K`; `quality` и `output_format` отдельно задают качество и формат.

| Обозначение разрешения | Типичные размеры в пикселях (без гарантии поддержки моделью)    |
| ---------------------- | --------------------------------------------------------------- |
| 1K                     | 1024×1024 · Около тысячи пикселей по стороне                    |
| 2K                     | 2048×2048 · Около двух тысяч пикселей по стороне                |
| 4K                     | 4096×4096 / 3840×2160 · Около четырёх тысяч пикселей по стороне |

Тарифные категории сайта за изображение определяются отдельно; эти примеры разрешений не задают правила оплаты. [Характеристики и правила тарификации](/simidoc/ru/apps/api/images).

### Три способа указать size

Некоторые OpenAI-совместимые шлюзы также принимают пропорции с разрешением или автоматический размер; применение зависит от модели и шлюза. При отсутствии поддержки используйте явные пиксели.

| Форма                         | Фрагмент запроса                   | Примечания                                                               |
| ----------------------------- | ---------------------------------- | ------------------------------------------------------------------------ |
| Явные пиксели (рекомендуется) | `{"size":"1536x2048"}`             | Нагляднее всего; исключает расхождения пресетов.                         |
| Пропорции + разрешение        | `{"size":"3:4","resolution":"2k"}` | Использует пресет 2K, 3\:4; resolution принимает только 1k, 2k, 4k.      |
| Автоматический размер         | `{"size":"auto"}`                  | Модель выбирает ширину и высоту; фиксированные пиксели не гарантируются. |

* Пропорции в size имеют приоритет над отдельным aspect\_ratio; явные пиксели или auto — над пресетами пропорций.
* Уровень указывайте в resolution; не отправляйте size=2k. Разделитель размеров — строчная x.
* Для gpt-image-2 официальный предел произвольных размеров — 3840×2160; более крупные комбинации, например 4096×4096, обычно возвращают ошибку параметра. Строка 4K показывает уровень, а не гарантированный размер.
* Краткий справочник 14 популярных пропорций в 1K, 2K и 4K см. в разделе [Характеристики и правила тарификации](/simidoc/ru/apps/api/images).

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

Возвращенный data\[].url может истечь; не добавляйте ключ API при скачивании изображения. Base64 ниже — структурный пример минимального PNG, не реальная генерация по запросу выше.

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

### Потоковая генерация

Поддерживаемая модель принимает stream=true. image\_generation.partial\_image содержит превью, image\_generation.completed — итог и потребление. Частичная картинка не является итогом. Без completed при обрыве нельзя отмечать завершение. Универсальный ID фоновой задачи для опроса не возвращается.

## Примеры вызова

Укажите `API_URL` и `API_KEY` в начале кода; в примерах используется `gpt-image-2`. `API_URL` — полный URL запроса, по умолчанию адрес шлюза `https://api.dwchainless.com`. Примеры используют только стандартные библиотеки, отправляют один запрос и выводят полученный JSON; изображение автоматически не сохраняется.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/generations"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
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
    const API_URL = 'https://api.dwchainless.com/v1/images/generations';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        prompt: '一只小机器人在图书馆阅读，水彩插画，不要文字。',
        size: '1024x1024',
        n: 1,
      }),
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/images/generations"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
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
        apiURL := "https://api.dwchainless.com/v1/images/generations"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-image-2",
            "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
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
Read this OpenAI image protocol page and its generation reference first. Use the
SimiRouter request URL in API_URL (default gateway https://api.dwchainless.com) and the
image model in MODEL. Set API_KEY directly in the example; never print, paste, commit,
or store it in source files. For this one approved request, use POST
/v1/images/generations with n=1, size=1024x1024, stream=false and output_format=png only
after verifying the model supports these parameters. Image brief: a calm blue library
with a small robot reading, watercolor illustration, no lettering. Print the returned
JSON and inspect data[].b64_json; do not write an image file. Confirm that
data[].b64_json contains non-empty Base64 data before reporting completion. Do not
install remote skills, switch providers/models/billing groups, increase size/count,
write files, or retry after timeout or ambiguous failure without approval. If the
request or validation fails, report a redacted error, not success.
```

## Коды ошибок

| Статус HTTP     | Значение или тип ошибки провайдера                                | Действие                                                                          |
| --------------- | ----------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| 400             | Неверный запрос                                                   | Проверьте обязательные поля, JSON, параметры модели и длину контекста.            |
| 401             | Ошибка аутентификации                                             | Проверьте наличие, действительность и принадлежность ключа.                       |
| 403 / 404       | Нет доступа / ресурс не найден                                    | Проверьте права модели, ID ресурса и URL.                                         |
| 413             | Тело запроса или изображение слишком велики                       | Предпочитайте URL изображений; уменьшите Base64 или размеры.                      |
| 429             | Ограничение частоты или квоты                                     | Различайте лимит скорости и нехватку квоты по ответу; повтор не восполняет квоту. |
| 500 / 502 / 503 | Ошибка сервиса / перегруженный upstream / временная недоступность | Сохраните ID и ограниченно повторите временные сбои с задержкой.                  |

Ошибка OpenAI обычно содержит `error.message`, `error.type`, `error.param`, `error.code`; `param` и `code` могут быть `null`; эти поля необязательны и могут отличаться от HTTP-статуса. Шлюз может отказать до провайдера. Пустой data, отсутствие картинки или одно превью не означают завершения, даже при HTTP 200.

Генерация и редактирование могут занимать от десятков секунд до нескольких минут; задайте достаточный клиентский таймаут, поскольку зависший запрос не равен ошибке. После таймаута, обрыва потока или 5xx сначала выясните, не был ли запрос уже выполнен, и только затем повторяйте, чтобы избежать двойной генерации и списаний. При отказе по правилам контента (обычно 400) измените запрос или референсное изображение, а не повторяйте его без изменений.

## Официальные материалы

* [OpenAI Create image](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [OpenAI\: руководство по генерации изображений](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI\: обработка ошибок](https\://developers.openai.com/api/docs/guides/error-codes)