# Перевод аудио

## Описание интерфейса

`POST /v1/audio/translations` принимает запись и выводит **английский текст**, без произвольного параметра языка назначения. Аутентификация\: `Authorization: Bearer $SIMIROUTER_API_KEY`, тело — `multipart/form-data`. Основано на официальном Audio Translations OpenAI; учетная запись должна иметь доступный канал модели.

<Callout type="warn" title="Эндпоинт и модель отключаются 2027-02-26">
  OpenAI объявил устаревшими `/v1/audio/translations` и `whisper-1`; они отключаются 2027-02-26. Замена — Realtime API `/v1/realtime/translations` с `gpt-realtime-translate`, что требует отдельной интеграции. Страница сохранена только как справка перед миграцией.
</Callout>

## Параметры запроса

| Поле             | Тип    | Обязателен | Описание                                                             |
| ---------------- | ------ | ---------- | -------------------------------------------------------------------- |
| file             | file   | Да         | Сам файл\: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, webm.          |
| model            | string | Да         | Этот маршрут использует whisper-1, а не обычную модель транскрипции. |
| prompt           | string | Нет        | Подсказка английских терминов или контекста.                         |
| response\_format | string | Нет        | json (по умолчанию), text, srt, verbose\_json, vtt.                  |
| temperature      | number | Нет        | 0–1, по умолчанию 0.                                                 |

## Ответ

JSON возвращает `text` с английским переводом. `verbose_json` дополнительно содержит `duration` (секунды), `language` (english), `segments[]`. Субтитры возвращаются текстом, не JSON. Это один файловый запрос без stream; Realtime-перевод использует отдельный сеанс.

```json
{"text":"Welcome to today's meeting."}
```

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

Подготовьте `speech.wav` и задайте `SIMIROUTER_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.dwchainless.com/v1/audio/translations'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'whisper-1', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/translations";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "whisper-1");
      form.append("response_format", "json");
      const body = form;
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.dwchainless.com/v1/audio/translations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=whisper-1" \
      -F "response_format=json"
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
      "bytes"
      "mime/multipart"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      var buffer bytes.Buffer
      writer := multipart.NewWriter(&buffer)
      source, err := os.Open("speech.wav"); check(err)
      part, err := writer.CreateFormFile("file", "speech.wav"); check(err)
      _, err = io.Copy(part, source); source.Close(); check(err)
      check(writer.WriteField("model", "whisper-1"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/translations", &buffer); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("SIMIROUTER_API_KEY"))
      req.Header.Set("Content-Type", writer.FormDataContentType())
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
| 413                   | Файл превышает лимит загрузки\: сожмите его или отправьте файл меньшего размера.                                                            |
| 429                   | Лимит частоты или квоты\: отличайте нехватку средств от временного ограничения с повторами.                                                 |
| 500 / 502 / 503 / 504 | Ошибка сервиса или провайдера. Сохраните ID запроса и сделайте паузу перед повтором; не повторяйте один и тот же платный запрос бесконечно. |

Поля `error.message`, `error.type` и `error.code` в теле ошибки точнее описывают причину, чем HTTP-статус. Этот интерфейс синхронный\: идентификатора задачи и этапа опроса нет. Никогда не сохраняйте текст ошибки как расшифровку.

## Официальные материалы

[OpenAI Create translation](https\://developers.openai.com/api/reference/resources/audio/subresources/translations/methods/create).