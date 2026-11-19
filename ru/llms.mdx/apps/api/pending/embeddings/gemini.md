# Эмбеддинги Gemini

**SimiRouter пока не поддерживает этот интерфейс. Ниже — справка по прямому официальному Google API.** В примерах используется ключ Gemini API из Google AI Studio. Для Vertex AI используйте пути запросов, настройки проекта и способ аутентификации из документации Google Cloud.

## Описание интерфейса

`POST https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent`, с `x-goog-api-key: $GEMINI_API_KEY`. Пример использует текст; Gemini Embedding 2 также обрабатывает мультимодальные данные, разрешённые моделью, но эти возможности нельзя переносить на старые текстовые модели.

## Параметры запроса

| Поле                                    | Тип       | Обязателен | Описание                                                                                |
| --------------------------------------- | --------- | ---------- | --------------------------------------------------------------------------------------- |
| model (в пути)                          | string    | Да         | models/gemini-embedding-2; нужна доступная модель эмбеддингов.                          |
| content                                 | object    | Да         | Объект Content для преобразования; текст в parts\[].text.                               |
| content.parts                           | object\[] | Да         | Текстовый элемент или поддерживаемый моделью мультимодальный inline\_data / file\_data. |
| embedContentConfig                      | object    | Нет        | Настройки эмбеддинга согласно версии модели и API Reference.                            |
| embedContentConfig.outputDimensionality | integer   | Нет        | Поддерживаемая размерность выхода; одинаковая у индекса и запроса.                      |

`gemini-embedding-2` не поддерживает `embedContentConfig.taskType` и `title`. Для поиска используйте префиксы в тексте\:

* Запрос\: `task: search result | query: {content}`
* Документ\: `title: {title} | text: {content}`; без заголовка — `title: none`
* Симметричная задача\: `task: {task} | query: {content}`

`taskType` и `title` применимы только к `gemini-embedding-001`. `gemini-embedding-2` не поддерживает эти поля; вместо них используйте указанные выше префиксы и не полагайтесь на неопределённую обработку полей. Векторные пространства embedding-2 и embedding-001 несовместимы\: индекс и запрос должны использовать одну модель.

Поля верхнего уровня `taskType`, `title`, `outputDimensionality` — устаревшие настройки; SDK использует объект config, не смешивайте snake\_case и camelCase HTTP JSON.

## Ответ

Один синхронный вызов возвращает `embedding.values` — массив чисел с плавающей точкой. `batchEmbedContents` принимает массив requests и возвращает `embeddings[]` в порядке входных элементов. Асинхронный `asyncBatchEmbedContent` возвращает ресурс длительной задачи; состоянием и выходными файлами управляют отдельно. Это не синхронный запрос этой страницы.

```json
{"embedding":{"values":[0.01,-0.02,0.03]}}
```

Показан фрагмент вектора. При сокращении размерности следуйте рекомендациям нормализации; первые три компонента не являются полным вектором.

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

Сначала задайте `GEMINI_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent'
    headers = {'x-goog-api-key': os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'models/gemini-embedding-2', 'content': {'parts': [{'text': 'task: search result | query: 如何让文档检索理解语义？'}]}}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent";
      const headers = { "x-goog-api-key": process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
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
    curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "models/gemini-embedding-2",
        "content": {
          "parts": [
            {
              "text": "task: search result | query: 如何让文档检索理解语义？"
            }
          ]
        }
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
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
    }`)
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent", body); check(err)
      req.Header.Set("x-goog-api-key", os.Getenv("GEMINI_API_KEY"))
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

Объект ошибки Google содержит `error.code`, `error.status` и `error.message`; не определяйте источник только по номеру HTTP. Этот интерфейс синхронный\: идентификатора задачи и этапа опроса нет. Никогда не считайте текст ошибки результатом эмбеддинга.

## Официальные материалы

[Google Embeddings guide](https\://ai.google.dev/gemini-api/docs/embeddings), [Embedding API](https\://ai.google.dev/api/embeddings).