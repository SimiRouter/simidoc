# Транскрипция аудио

## Описание интерфейса

`POST /v1/audio/transcriptions`, аутентификация — `Authorization: Bearer $SIMIROUTER_API_KEY`. Загрузка использует `multipart/form-data`; HTTP-библиотека сама формирует boundary, не задавайте вручную Content-Type без boundary.

Интерфейс сохраняет язык записи и не переводит китайский на английский. Форматы\: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, webm. Размер и длительность дополнительно ограничиваются моделью и каналом.

<Callout type="warn" title="Часть моделей отключается 2027-02-26">
  `whisper-1`, `gpt-4o-transcribe` и `gpt-4o-mini-transcribe` (включая датированные версии) объявлены устаревшими и отключаются 2027-02-26. Предпочтите `gpt-transcribe`; для потокового аудио используйте `gpt-live-transcribe`, для разделения говорящих — `gpt-4o-transcribe-diarize`.
</Callout>

## Параметры запроса

| Поле                          | Тип             | Обязателен  | Описание                                                                                             |
| ----------------------------- | --------------- | ----------- | ---------------------------------------------------------------------------------------------------- |
| file                          | file            | Да          | Сам аудиофайл, а не строка пути или обычный URL.                                                     |
| model                         | string          | Да          | Например gpt-transcribe, gpt-4o-transcribe, gpt-4o-mini-transcribe, whisper-1 или модель диаризации. |
| language                      | string          | Нет         | Код исходного языка ISO-639-1, например zh или en.                                                   |
| languages\[]                  | string\[]       | Нет         | Список предполагаемых языков, только для поддерживающих моделей.                                     |
| prompt                        | string          | Нет         | Подсказка терминов и контекста на языке записи; модели diarize не поддерживают.                      |
| keywords\[]                   | string\[]       | Нет         | Терминологическая подсказка, только gpt-transcribe.                                                  |
| response\_format              | string          | Нет         | По умолчанию json; text, srt, vtt, verbose\_json, diarized\_json доступны в зависимости от модели.   |
| temperature                   | number          | Нет         | 0–1, по умолчанию 0.                                                                                 |
| stream                        | boolean         | Нет         | true возвращает SSE; whisper-1 не поддерживает.                                                      |
| include\[]                    | string\[]       | Нет         | logprobs только для поддерживающих моделей при response\_format=json.                                |
| timestamp\_granularities\[]   | string\[]       | Нет         | word / segment\: нужен verbose\_json и поддерживаемая модель; не для diarize.                        |
| chunking\_strategy            | string / object | При условии | auto или server\_vad; обязательно для diarize при записи длиннее 30 секунд.                          |
| known\_speaker\_names\[]      | string\[]       | Нет         | Короткие имена до 4 известных говорящих, соответствующие образцам.                                   |
| known\_speaker\_references\[] | string\[]       | Нет         | Audio data URL длительностью 2–10 секунд, по одному на имя, для поддерживающих моделей.              |

`gpt-4o-transcribe` и `gpt-4o-mini-transcribe` возвращают JSON; `whisper-1` поддерживает text, srt, vtt, verbose\_json и другие форматы. Для меток говорящих нужны модель diarize и `diarized_json`; не навязывайте параметр обычным моделям.

## Ответ

| Поле                     | Описание                                                                          |
| ------------------------ | --------------------------------------------------------------------------------- |
| `text`                   | Полный текст транскрипции.                                                        |
| `usage`                  | Расход, предоставленный моделью; поля зависят от модели.                          |
| `logprobs`               | Вероятности токенов, если запрошены и поддерживаются.                             |
| `language` / `duration`  | Язык и длительность в секундах в verbose\_json.                                   |
| `words[]` / `segments[]` | Сегменты для форматов временных меток или говорящих; доступны не в каждом ответе. |

```json
{"text":"欢迎参加今天的会议。"}
```

`stream=true` возвращает дельты и завершение транскрипции по SSE при поддержке модели; поток нужно читать непрерывно. Сначала все равно загружается файл\: это не двусторонний микрофонный Realtime.

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

Подготовьте в текущем каталоге `speech.wav` и задайте `SIMIROUTER_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.dwchainless.com/v1/audio/transcriptions'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'gpt-4o-mini-transcribe', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/transcriptions";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "gpt-4o-mini-transcribe");
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
    curl "https://api.dwchainless.com/v1/audio/transcriptions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=gpt-4o-mini-transcribe" \
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
      check(writer.WriteField("model", "gpt-4o-mini-transcribe"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/transcriptions", &buffer); check(err)
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

[OpenAI Create transcription](https\://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create).