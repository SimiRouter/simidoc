# Модерация

## Описание интерфейса

`POST https://api.openai.com/v1/moderations` выполняет синхронную классификацию безопасности текста и изображений с заголовком `Authorization: Bearer $OPENAI_API_KEY`. Маршрут, модель и права SimiRouter нужно проверить отдельно. Ниже приведен прямой вызов OpenAI.

Результат модерации — сигнал риска, не юридическое заключение и не гарантия отсутствия пропусков. Набор категорий для текста и изображений может различаться. Проверяйте category\_applied\_input\_types\: неподдерживаемый тип ввода не доказывает безопасность.

## Параметры запроса

| Поле                    | Тип                            | Обязателен  | Описание                                                                                      |
| ----------------------- | ------------------------------ | ----------- | --------------------------------------------------------------------------------------------- |
| model                   | string                         | Нет         | Например, omni-moderation-latest. Фиксированная версия снижает влияние обновлений псевдонима. |
| input                   | string / string\[] / object\[] | Да          | Текст или мультимодальные элементы.                                                           |
| input\[].type           | string                         | При условии | text либо image\_url.                                                                         |
| input\[].text           | string                         | При условии | Текст для модерации.                                                                          |
| input\[].image\_url.url | string                         | При условии | URL изображения или data URL, соответствующий требованиям модели.                             |

## Ответ

| Поле                                     | Описание                                                                    |
| ---------------------------------------- | --------------------------------------------------------------------------- |
| `id` / `model`                           | Идентификатор запроса и модель модерации.                                   |
| `results[].flagged`                      | Наличие риска хотя бы в одной категории.                                    |
| `results[].categories`                   | Булево значение для каждой категории.                                       |
| `results[].category_scores`              | Оценка категории, не экспертное решение и не постоянный межмодельный порог. |
| `results[].category_applied_input_types` | Типы ввода, применимые к каждой категории.                                  |

```json
{"id":"modr_example","model":"omni-moderation-latest","results":[{"flagged":false,"categories":{},"category_scores":{},"category_applied_input_types":{}}]}
```

В примере ключи категорий опущены; реальный ответ содержит детализацию. Сохраняйте необходимые свидетельства риска, а не весь пользовательский текст бессрочно.

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

Задайте `OPENAI_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/moderations'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'omni-moderation-latest', 'input': '这是一段需要进行安全审核的示例文本。'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/moderations";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
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
    curl "https://api.openai.com/v1/moderations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "omni-moderation-latest",
        "input": "这是一段需要进行安全审核的示例文本。"
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
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/moderations", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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

| Статус HTTP           | Значение и действие                                                                                                    |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Неверные поля, формат файла или параметры модели\: исправьте запрос.                                                   |
| 401                   | Ключ API отсутствует, недействителен или просрочен.                                                                    |
| 403                   | Нет прав проекта или модели.                                                                                           |
| 404                   | Модель или маршрут не найдены\: проверьте адрес и проект-владелец.                                                     |
| 413 / 415             | Файл слишком велик или тип данных не поддерживается.                                                                   |
| 429                   | Лимит частоты или квоты\: отличайте нехватку средств от временного ограничения с повторами.                            |
| 500 / 502 / 503 / 504 | Ошибка сервиса или провайдера\: сохраните ID запроса, изучите тело ответа и только затем решайте, повторять ли запрос. |

В теле ошибки поля `error.message`, `error.type`, `error.code` уточняют причину по сравнению со статусом HTTP. Не принимайте тело ошибки за результат модерации.

## Официальные материалы

[OpenAI Create moderation](https\://developers.openai.com/api/reference/resources/moderations/methods/create).