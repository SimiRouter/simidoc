# Текст в речь

## Описание интерфейса

`POST /v1/audio/speech` преобразует `input` в речь. Адрес SimiRouter — `https://api.dwchainless.com`, аутентификация — `Authorization: Bearer $SIMIROUTER_API_KEY`, тело — `application/json`. Страница основана на официальном Speech API; передача полей и доступные модели зависят от канала.

<Callout type="warn" title="Модели отключаются 2027-01-06">
  `gpt-4o-mini-tts`, `tts-1` и `tts-1-hd` объявлены OpenAI устаревшими и отключаются 2027-01-06. Официальная замена — `gpt-realtime-2.1-mini` в Realtime API, который не поддерживает `/v1/audio/speech`; переходите через `/v1/realtime`. В примерах по-прежнему используется доступная сейчас модель; перед вызовом проверьте, предоставляет ли канал замену.
</Callout>

## Параметры запроса

| Поле             | Тип             | Обязателен | Описание                                                                        |
| ---------------- | --------------- | ---------- | ------------------------------------------------------------------------------- |
| model            | string          | Да         | Доступная TTS-модель, например gpt-4o-mini-tts, не модель транскрипции.         |
| input            | string          | Да         | Текст озвучки, до 4096 символов.                                                |
| voice            | string / object | Да         | Имя встроенного голоса либо разрешенный пользовательский \{"id"\:"voice\_..."}. |
| instructions     | string          | Нет        | Инструкция по тону и стилю, до 4096 символов; tts-1/tts-1-hd не поддерживают.   |
| response\_format | string          | Нет        | mp3 (по умолчанию), opus, aac, flac, wav, pcm.                                  |
| speed            | number          | Нет        | 0.25–4.0, по умолчанию 1.                                                       |
| stream\_format   | string          | Нет        | audio (по умолчанию) или sse; tts-1/tts-1-hd не поддерживают sse.               |

Встроенные голоса включают `alloy`, `ash`, `ballad`, `coral`, `echo`, `fable`, `onyx`, `nova`, `sage`, `shimmer`, `verse`, `marin`, `cedar`; конкретная модель может поддерживать лишь часть. Имя голоса не задает фиксированный язык.

## Ответ

При успехе возвращаются аудиобайты, а не JSON с URL. Расширение файла должно соответствовать `response_format`; PCM — сырые семплы без контейнера, для воспроизведения нужны правильные параметры. Аудио можно читать чанками для снижения задержки.

`stream_format: "sse"` использует события; разбирайте их и декодируйте аудиодельты, не сохраняйте текст SSE как MP3. Доступность SSE зависит от канала.

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

Сначала задайте `SIMIROUTER_API_KEY`. Выбран MP3; при HTTP-ошибке выполнение останавливается, чтобы не сохранить JSON ошибки как звук.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'https://api.dwchainless.com/v1/audio/speech'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gpt-4o-mini-tts', 'input': '你好，欢迎使用语音合成。', 'voice': 'alloy', 'response_format': 'mp3'}, timeout=180)
    response.raise_for_status()
    Path('speech.mp3').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/speech";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("speech.mp3", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "speech.mp3" ] || { printf '%s\n' "目标文件已存在：speech.mp3" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X POST "https://api.dwchainless.com/v1/audio/speech" \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary '{
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    }' \
      --output "$temporary"; then
      mv "$temporary" "speech.mp3"
    else
      status=$?
      cat "$temporary" >&2
      exit "$status"
    fi
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
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    }`)
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/speech", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("SIMIROUTER_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("speech.mp3", data, 0600))
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

Поля `error.message`, `error.type` и `error.code` в теле ошибки точнее описывают причину, чем HTTP-статус. Этот интерфейс синхронный\: идентификатора задачи и этапа опроса нет. Никогда не сохраняйте текст ошибки как аудиофайл.

## Официальные материалы

[OpenAI Create speech](https\://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create).