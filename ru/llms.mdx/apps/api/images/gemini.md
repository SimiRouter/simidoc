# API изображений Gemini

Раздел использует собственный формат Gemini GenerateContent `contents/parts`. Для генерации и редактирования нужна модель с выводом изображений; параметры не добавляют такую возможность обычной текстовой модели. Сначала выполните одну задачу для одной картинки, затем увеличивайте количество или подключайте агента.

## Формат и параметры запроса

| API                                        | Формат запроса                                      | Основные параметры                                                                        | Подробная документация                                      |
| ------------------------------------------ | --------------------------------------------------- | ----------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| Текст в изображение                        | `POST /v1beta/models/{model}:generateContent`, JSON | `contents[].parts[].text`, `generationConfig`                                             | [Параметры генерации и код на четырёх языках](/simidoc/ru/apps/api/images/gemini/generate)   |
| Редактирование / изображение в изображение | Тот же эндпоинт `generateContent`                   | `text` и отдельный Part изображения\: `inlineData` либо поддерживаемый моделью `fileData` | [Параметры редактирования и код на четырёх языках](/simidoc/ru/apps/api/images/gemini/edits) |
| Понимание изображения                      | Тот же эндпоинт `generateContent`                   | Изображение и вопрос; цель — текстовый анализ, не вывод картинки                          | [Понимание медиа Gemini](/simidoc/ru/apps/api/chat/gemini-media)           |

Для генерации нужен только текст; для редактирования добавьте референсы и отдельно опишите, что сохранить и изменить. Смена стиля, фона и композиция из нескольких изображений — цели редактирования, а не отдельный путь `/images/edits`. Поля GenerateContent `contents`, `candidates` отличаются от Interactions `input`, `steps`, `response_format`; не смешивайте их.

### Параметры изображения

При поддержке протоколом и моделью задайте пропорции через `generationConfig.imageConfig.aspectRatio`, например `1:1`, а разрешение — через `generationConfig.imageConfig.imageSize`, используя допустимые значения вроде `1K`, `2K`, `4K`. Они доступны не всем графическим моделям Gemini и не заменяются параметром OpenAI `size`. Фактические пиксели и пропорции зависят от версии модели; формат определяйте по реальному MIME.

| Три поштучных тарифа сайта | Длинная сторона запроса  | Пример в пикселях |
| -------------------------- | ------------------------ | ----------------- |
| 1K                         | ≤ 1024 пикселей          | 1024×1024         |
| 2K                         | > 1024 и ≤ 2048 пикселей | 1536×1024         |
| 4K                         | > 2048 пикселей          | 2560×1440         |

Таблица описывает тарификацию отдельных моделей сайта, а не универсальное определение разрешений Google. Она применяется лишь при явном указании правил в разделе [Модели и цены](https://api.dwchainless.com/ru/pricing/), не для оплаты в токенах или других тарифов. Более высокое разрешение не гарантирует точных надписей и деталей. Неподдерживаемые параметры должны вызывать ошибку, а не молчаливое понижение уровня. См. [обзор размеров и тарификации](/simidoc/ru/apps/api/images).

## Поля ответа

| Поле                                           | Значение и обработка                                                                                                |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `candidates[]`                                 | Список кандидатов; при фильтрации или ошибке полезных изображений может не быть.                                    |
| `candidates[].content.parts[]`                 | Последовательно обходите текст и изображения; первый элемент не обязательно картинка.                               |
| `parts[].inlineData.mimeType` / `.data`        | Фактический MIME и чистый Base64; выберите расширение по MIME и декодируйте.                                        |
| `parts[].thought` / `.thoughtSignature`        | Промежуточные изображения рассуждения не являются финальными; сохраняйте непрозрачные подписи для следующих правок. |
| `candidates[].finishReason` / `promptFeedback` | Проверьте нормальное завершение и фильтрацию; HTTP 200 недостаточно для объявления успеха.                          |
| `usageMetadata`                                | Необязательные данные использования; стоимость определяется применимыми тарифами и логами.                          |

## Примеры вызова

### Подготовка конфигурации

Создайте ключ в разделе [Управление API-ключами](https://api.dwchainless.com/keys), скопируйте из [Моделей и цен](https://api.dwchainless.com/ru/pricing/) полный ID доступной модели с выводом изображений GenerateContent, проверьте группу, баланс и поддержку редактирования. Заполните эти поля в примере\:

| Переменная     | Назначение                                                                                                                           |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `API_KEY`      | Обязательна; указать непосредственно в примере, не помещать в промпты, код, скриншоты или Git.                                       |
| `MODEL`        | Обязательна; выбранная графическая модель Gemini, имя которой подставляется в путь.                                                  |
| `API_URL`      | Полный URL запроса; в примерах используется шлюз `https://api.dwchainless.com`.                                                      |
| `IMAGE_BASE64` | Замените на чистый Base64 разрешённого изображения (без префикса `data:`); формат и размеры должны соответствовать выбранной модели. |

[Примеры генерации](/simidoc/ru/apps/api/images/gemini/generate) и [редактирования](/simidoc/ru/apps/api/images/gemini/edits) содержат Python, Node.js, curl и Go. Выберите язык и выполните один непотоковый вызов. Сохраните Python в `generate.py` или `edit.py`, запустите `python3 generate.py` или `python3 edit.py`. Примеры Node.js используют await верхнего уровня (ESM)\: сохраните их в `generate.mjs` или `edit.mjs`, запустите `node generate.mjs` или `node edit.mjs`.

### Демо генерации с агентом

Агент должен выполнять локальные скрипты и проверять ответы. Процесс не устанавливает удалённые Skill и не меняет существующее подключение; чисто текстовый клиент не может выполнить его напрямую.

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

### Демо редактирования с агентом

Читайте только разрешённые референсы, предварительно проверьте персональные данные и коммерческие секреты. Для последовательных правок нужен полный контекст ответа модели; не отбрасывайте подписи произвольно. Требование сохранения не гарантирует совпадения пикселей.

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

## Сохранение и критерии завершения

* Проверьте HTTP-статус, `finishReason` и изображение. Только текст, фильтрация, отсутствие финальной картинки или несовпадение формата означают незавершённую задачу; не сохраняйте весь JSON как изображение.
* Строго декодируйте Base64, сверьте формат и MIME, проверьте открытие, размер и содержание файла. Сохраняйте прежние файлы; при ошибке удаляйте только новый некорректный вывод.
* Поток `streamGenerateContent?alt=sse` используйте лишь при поддержке моделью; произвольный фрагмент не равен финальному изображению. `generateContent` синхронно возвращает полный результат без универсального ID для опроса; Google Batch — отдельный сервис.
* Каждое изображение сохраняйте отдельно по элементам содержимого и сверяйте завершённое количество. Промпт «одна картинка» не гарантирует ровно одну у любой модели. Без разрешения не вызывайте API снова для восполнения количества.

## Ошибки, повторы и стоимость

При 400 проверьте модель, поля и референс; 401/403 — права ключа; 404 — модель и путь; 429 — баланс и ограничения. После тайм-аута, 5xx или отсутствия полного финального результата сначала проверьте логи и файлы, не отправляйте запрос автоматически повторно. Сообщайте только обезличенную ошибку и ID запроса, не ключ, полный Base64 или приватное содержимое.

Реальные генерация и редактирование могут оплачиваться. До вызова подтвердите модель, параметры, количество и путь вывода. Более высокий уровень, больше картинок, другая модель или повтор требуют нового подтверждения. Параллельные запросы отдельно ограничиваются по скорости, времени и стоимости; наличие данных использования не означает оплату в токенах. Итог определяется текущими ценами и логами.

## Официальные источники

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Генерация и редактирование изображений Google](https\://ai.google.dev/gemini-api/docs/image-generation)