# Эмбеддинги OpenAI

**SimiRouter пока не поддерживает этот интерфейс. Ниже — справка по прямому официальному OpenAI API.**

## Описание интерфейса

`POST https://api.openai.com/v1/embeddings`, `Content-Type: application/json`, `Authorization: Bearer $OPENAI_API_KEY`. Один запрос возвращает полные векторы, без SSE.

## Параметры запроса

| Поле             | Тип                                 | Обязателен | Описание                                                                                                |
| ---------------- | ----------------------------------- | ---------- | ------------------------------------------------------------------------------------------------------- |
| model            | string                              | Да         | text-embedding-3-small, text-embedding-3-large или другая доступная аккаунту модель эмбеддингов.        |
| input            | string / string\[] / массив токенов | Да         | Непустой текст или токены; до 2048 элементов, 8192 токенов на вход и 300000 токенов суммарно на запрос. |
| dimensions       | integer                             | Нет        | Положительное целое\: сокращает размерность для text-embedding-3 и последующих совместимых моделей.     |
| encoding\_format | string                              | Нет        | float (по умолчанию) возвращает массив чисел, base64 — закодированную строку.                           |
| user             | string                              | Нет        | Идентификатор конечного пользователя без открытых персональных данных.                                  |

## Ответ

| Поле                                         | Описание                                                              |
| -------------------------------------------- | --------------------------------------------------------------------- |
| `object`                                     | list.                                                                 |
| `data[].object`                              | embedding.                                                            |
| `data[].index`                               | Позиция во входном массиве.                                           |
| `data[].embedding`                           | Векторный массив или Base64-строка в зависимости от encoding\_format. |
| `model`                                      | Использованная модель.                                                |
| `usage.prompt_tokens` / `usage.total_tokens` | Статистика токенов.                                                   |

Средние элементы вектора опущены; показана лишь структура\:

```json
{"object":"list","data":[{"object":"embedding","index":0,"embedding":[0.01,-0.02]}],"model":"text-embedding-3-small","usage":{"prompt_tokens":3,"total_tokens":3}}
```

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

Задайте `OPENAI_API_KEY`. Пример передаёт синхронный пакет; index связывает результаты с двумя входами.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/embeddings'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'text-embedding-3-small', 'input': ['语义搜索', '文档检索'], 'encoding_format': 'float'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/embeddings";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
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
    curl "https://api.openai.com/v1/embeddings" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "text-embedding-3-small",
        "input": [
          "语义搜索",
          "文档检索"
        ],
        "encoding_format": "float"
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
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/embeddings", body); check(err)
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

| Статус HTTP           | Значение и действие                                                                                                                         |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| 400                   | Неверные поля запроса или параметры модели\: исправьте запрос и повторите отправку.                                                         |
| 401                   | Ключ API отсутствует, недействителен или просрочен.                                                                                         |
| 403                   | Нет прав проекта или модели.                                                                                                                |
| 404                   | Модель или маршрут не найдены\: проверьте адрес и идентификатор модели.                                                                     |
| 429                   | Лимит частоты или квоты\: отличайте нехватку средств от временного ограничения с повторами.                                                 |
| 500 / 502 / 503 / 504 | Ошибка сервиса или провайдера. Сохраните ID запроса и сделайте паузу перед повтором; не повторяйте один и тот же платный запрос бесконечно. |

Поля `error.message`, `error.type` и `error.code` в теле ошибки точнее описывают причину, чем HTTP-статус. Этот интерфейс синхронный\: идентификатора задачи и этапа опроса нет. Никогда не считайте текст ошибки результатом эмбеддинга.

## Официальные материалы

[OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings/methods/create), [Embeddings guide](https\://developers.openai.com/api/docs/guides/embeddings).