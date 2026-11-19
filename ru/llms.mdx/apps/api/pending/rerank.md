# Реранжирование документов

## Описание интерфейса

Реранжирование сравнивает query со списком документов и возвращает отсортированные index и оценки. Оно не генерирует ответ и не возвращает векторы. Доступность маршрута SimiRouter `/v1/rerank` зависит от канала; ниже показан только **официальный API Cohere** `POST https://api.cohere.com/v2/rerank`, с `Authorization: Bearer $COHERE_API_KEY`.

## Параметры запроса

| Поле                  | Тип       | Обязателен | Описание                                                                                                                                   |
| --------------------- | --------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| model                 | string    | Да         | Например, rerank-v5.0-pro; выберите доступную вашей учетной записи модель.                                                                 |
| query                 | string    | Да         | Поисковый запрос.                                                                                                                          |
| documents             | string\[] | Да         | Массив текстов; официальная рекомендация — не более 1000 документов за запрос. Структурированные данные можно сериализовать в YAML-строки. |
| top\_n                | integer   | Нет        | Не менее 1; если не указан, возвращаются все результаты.                                                                                   |
| max\_tokens\_per\_doc | integer   | Нет        | По умолчанию 4096; длинные документы усекаются.                                                                                            |
| relevant\_spans       | object    | Нет        | Модели v5 и новее могут возвращать релевантные фрагменты текста.                                                                           |
| priority              | integer   | Нет        | 0–999; по умолчанию 0. Меньшее число означает более высокий приоритет.                                                                     |

В Cohere v2 documents — массив строк; неопределенные объекты недопустимы. Параметр `return_documents` относится к другой версии протокола и здесь не отправляется.

## Ответ

Массив `results[]` отсортирован по релевантности\: `index` указывает индекс исходного документа, `relevance_score` — оценку релевантности. При включенной поддержке возвращаются `relevant_spans[]`. Оценка не является точностью или общей вероятностью, сопоставимой между моделями. `meta.billed_units` отражает учет потребления.

```json
{"results":[{"index":1,"relevance_score":0.95},{"index":0,"relevance_score":0.12}],"id":"request_example","meta":{"api_version":{"version":"2"}}}
```

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

Укажите официальный ключ Cohere `COHERE_API_KEY`. В примере top\_n положителен; пустые query и документы не используются.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.cohere.com/v2/rerank'
    headers = {'Authorization': 'Bearer ' + os.environ['COHERE_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'rerank-v5.0-pro', 'query': '法国首都是哪里？', 'documents': ['柏林是德国首都。', '巴黎是法国首都。'], 'top_n': 2}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.cohere.com/v2/rerank";
      const headers = { "Authorization": "Bearer " + process.env.COHERE_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
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
    curl "https://api.cohere.com/v2/rerank" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $COHERE_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "rerank-v5.0-pro",
        "query": "法国首都是哪里？",
        "documents": [
          "柏林是德国首都。",
          "巴黎是法国首都。"
        ],
        "top_n": 2
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
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
    }`)
      req, err := http.NewRequest("POST", "https://api.cohere.com/v2/rerank", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("COHERE_API_KEY"))
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

| Статус HTTP           | Описание                                                                        |
| --------------------- | ------------------------------------------------------------------------------- |
| 400 / 422             | Недопустимые параметры или входные данные модели.                               |
| 401 / 498             | Ошибка аутентификации или недействительный токен.                               |
| 403 / 404             | Недостаточно прав либо ресурс отсутствует.                                      |
| 429                   | Ограничение частоты; проверьте квоту и применяйте ограниченный backoff.         |
| 499                   | Клиент закрыл запрос.                                                           |
| 500 / 501 / 503 / 504 | Внутренняя ошибка, нереализованная операция или тайм-аут; сохраните ID запроса. |

## Официальные материалы

[Cohere Rerank v2](https\://docs.cohere.com/reference/rerank).