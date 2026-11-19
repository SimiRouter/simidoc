# API изображений в формате OpenAI

Раздел использует формат OpenAI и различает генерацию, редактирование, генерацию в диалоге и понимание изображений. Сначала выполните один вызов для одной картинки, затем увеличивайте количество или подключайте агента. Модель должна поддерживать нужную графическую возможность.

## Порядок вызова

1. **Подготовьте настройки**\: создайте ключ в разделе [Управление API-ключами](https://api.dwchainless.com/keys) и скопируйте поддерживаемый полный ID модели из [Моделей и цен](https://api.dwchainless.com/ru/pricing/); адрес запроса — шлюз `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $API_KEY`.
2. **Выберите эндпоинт**\: `POST /v1/images/generations` для текста в изображение, `POST /v1/images/edits` для редактирования и изображения в изображение, `POST /v1/responses` для генерации в диалоге, `POST /v1/chat/completions` для понимания изображений.
3. **Сначала минимальный запрос**\: запросите одно изображение без потоковой передачи; убедитесь, что аутентификация, модель и параметры верны, прежде чем увеличивать количество, размер или подключать агента.
4. **Прочитайте и проверьте**\: декодируйте Base64 из `data[]` или скачайте URL, проверьте, что файл открывается, а размеры и содержимое соответствуют требованиям, затем сверьте журналы использования.

Полные параметры, примеры и обработка ошибок — на страницах протоколов ниже; для первого вызова начните с [генерации](/simidoc/ru/apps/api/images/openai/generations).

## Формат и параметры запроса

| API                                        | Формат запроса                                     | Основные параметры                                                     | Подробная документация                                       |
| ------------------------------------------ | -------------------------------------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------ |
| Текст в изображение                        | `POST /v1/images/generations`, JSON                | `model`, `prompt`; по возможностям модели — `n`, `size`, `quality`     | [Параметры генерации и код на четырёх языках](/simidoc/ru/apps/api/images/openai/generations) |
| Редактирование / изображение в изображение | `POST /v1/images/edits`, либо JSON, либо multipart | `model`, `prompt`, `images[]` или файл `image`; при поддержке — `mask` | [Параметры редактирования и код на четырёх языках](/simidoc/ru/apps/api/images/openai/edits)  |
| Генерация в диалоге                        | `POST /v1/responses`, JSON                         | `input`, инструмент генерации изображений и настройки модели           | [Генерация в диалоге](/simidoc/ru/apps/api/images/openai/chat-format)                         |
| Понимание изображения                      | `POST /v1/chat/completions`, JSON                  | В `messages` — текст и элементы `image_url`                            | [Понимание изображения](/simidoc/ru/apps/api/images/openai/vision)                            |

В промпте редактирования отдельно укажите, что сохранить и что изменить. Смена стиля, замена фона, добавление и удаление объектов — цели редактирования, а не другие API. Маски, несколько референсов и прозрачность требуют поддержки модели; сохранение людей, товаров и текста пиксель в пиксель не гарантируется.

### Параметры изображения

`size` задаёт ширину и высоту в пикселях, например `1024x1024`, а не универсальное перечисление `1K` / `2K` / `4K`; допустимые размеры зависят от модели. `quality` регулирует качество, `output_format` — кодирование PNG/JPEG/WebP, но не заменяет разрешение. Для прозрачности нужны поддержка `background: transparent` и PNG или WebP.

Три способа записи size, таблица 14 пропорций и тарифные категории 1K/2K/4K за изображение собраны в [обзоре размеров и тарификации](/simidoc/ru/apps/api/images). Таблица тарификации применяется только к моделям, для которых это правило явно указано в разделе [Модели и цены](https://api.dwchainless.com/ru/pricing/), и не гарантирует поддержку всех примеров размеров.

## Поля ответа

| Поле / событие                                        | Значение и обработка                                                                                                          |
| ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Images `data[].b64_json`                              | Base64 изображения GPT Image; декодируйте в двоичный файл, не переименовывайте JSON в PNG.                                    |
| Images `data[].url`                                   | Может возвращаться старыми или совместимыми моделями с URL-выводом; скачайте вовремя, не считайте обязательным для GPT Image. |
| Images `usage`                                        | Необязательные данные использования; наличие поля не означает оплату в токенах.                                               |
| `image_generation.completed` / `image_edit.completed` | Финальные события потоковой генерации / редактирования Images; `partial_image` — только промежуточное превью.                 |
| Responses `output[]`                                  | Обрабатывайте результаты графического инструмента в диалоге, не копируя структуру Images `data[]`.                            |
| Chat `choices[].message.content`                      | Понимание возвращает текстовый анализ, не новое изображение.                                                                  |

## Примеры вызова

### Подготовка конфигурации

Создайте ключ в разделе [Управление API-ключами](https://api.dwchainless.com/keys), скопируйте полный ID доступной ему графической модели из [Моделей и цен](https://api.dwchainless.com/ru/pricing/), проверьте права, группу и баланс. Заполните эти поля в примере\:

| Переменная  | Назначение                                                                                            |
| ----------- | ----------------------------------------------------------------------------------------------------- |
| `API_KEY`   | Обязательна; указать непосредственно в примере, не вставлять в промпты, исходники, скриншоты или Git. |
| `MODEL`     | Обязательна; отдельно проверьте поддержку эндпоинтов генерации и редактирования.                      |
| `API_URL`   | Полный URL запроса; в примерах используется шлюз `https://api.dwchainless.com`.                       |
| `IMAGE_URL` | HTTPS-URL, используемый примером редактирования; сервер должен иметь доступ к PNG, JPEG или WebP.     |

[Примеры генерации](/simidoc/ru/apps/api/images/openai/generations) и [редактирования](/simidoc/ru/apps/api/images/openai/edits) содержат Python, Node.js, curl и Go. Выберите один язык и запросите одну картинку без потока. Примеры Python 3.8+ и Node.js 20+ используют стандартные библиотеки. Сохраните генерацию в `generate.py` или `generate.mjs`, редактирование — в `edit.py` или `edit.mjs`; запустите нужный файл, например `python3 generate.py` или `node generate.mjs`. Примеры редактирования на Python и Node.js используют JSON `images[].image_url` и не используют multipart.

### Демо генерации с агентом

Агент должен уметь выполнять локальные скрипты, читать разрешённые изображения и проверять ответы. Страница не устанавливает Skill и не добавляет инструменты текстовому клиенту. Сохраните существующее подключение, не меняйте сервис самовольно.

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

### Демо редактирования с агентом

Проверьте право обработки референса, персональные данные и коммерческие секреты; разрешите только необходимые файлы. «Сохранить» в промпте — цель, а не гарантия совпадения пикселей.

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

## Сохранение и критерии завершения

* Перед сохранением проверьте HTTP-статус, финальное поле изображения, декодирование и фактический формат. Смена расширения не конвертирует файл. При ошибке удаляйте только созданный этим вызовом некорректный вывод, не прежние файлы.
* Начните с одной картинки без потока. В потоке дождитесь соответствующего `completed`, несколько изображений обрабатывайте по индексу. Без финального события превью не считается результатом. Стандартный Images — не универсальная асинхронная очередь с ID задачи для опроса.
* Проверьте существование, открытие, размер и содержимое файла, затем журнал использования. Успешный HTTP или слова агента «готово» не означают сохранённое изображение.

## Ошибки, повторы и стоимость

При 400 проверьте модель и параметры; 401 — ключ; 403/404 — права, ID и путь; 429 — баланс и лимиты. После 5xx, тайм-аута или разрыва потока сначала проверьте логи и существующие результаты. Не отправляйте запрос автоматически повторно, чтобы избежать повторной генерации и списания. Сообщайте только обезличенную ошибку и идентификатор запроса, не ключ, полный Base64 или приватное содержимое.

Реальные генерация и редактирование могут оплачиваться. До вызова подтвердите модель, размер, количество и путь вывода. Увеличение `n`, переход на более высокий уровень, смена модели и повтор требуют нового подтверждения. У параллельных запросов отдельные лимиты, тайм-ауты и стоимость; `n` — количество в одном запросе, не степень параллелизма. Итог определяется текущими ценами и журналом использования.

## Официальные источники

* [Руководство OpenAI по генерации изображений](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Images API](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [Визуальный ввод OpenAI](https\://developers.openai.com/api/docs/guides/images-vision)