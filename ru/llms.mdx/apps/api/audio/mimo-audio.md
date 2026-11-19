# Интеграция аудио MiMo

## Описание интерфейса

MiMo поддерживает синтез, транскрипцию, дизайн и клонирование голоса. Различайте два интерфейса\:

| Протокол                          | Адрес / маршрут                                                      | Аутентификация                                   | Вывод                       |
| --------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------ | --------------------------- |
| Отдельный совместимый аудиосервис | Адрес развертывания с `/v1/audio/speech`, `/v1/audio/transcriptions` | Bearer-ключ сервиса; также принимается x-api-key | Аудиобайты или транскрипция |
| Собственный протокол Xiaomi       | `https://api.xiaomimimo.com/v1/chat/completions`                     | Официальный MiMo api-key или Bearer              | Chat Completions JSON / SSE |

**Совместимый маршрут не является собственным адресом Xiaomi.** Примеры по умолчанию обращаются к отдельному сервису `http://127.0.0.1:8080`. Для другого размещения замените хост и порт. Наличие такого маршрута в публичном SimiRouter проверяется отдельно; ключ отдельного сервиса не переносится автоматически.

## Параметры запроса

### Синтез\: POST /v1/audio/speech

| Поле             | Тип             | Обязателен | Описание                                                                                                            |
| ---------------- | --------------- | ---------- | ------------------------------------------------------------------------------------------------------------------- |
| model            | string          | Да         | mimo-v2.5-tts, mimo-v2.5-tts-voicedesign, mimo-v2.5-tts-voiceclone.                                                 |
| input            | string          | Да         | Непустой текст; по умолчанию до 4096 символов, настраивается при развертывании.                                     |
| voice            | string / object | Да         | Готовый голос; для клонирования audio data URL или созданный сервисом \{"id"\:"voice\_..."}.                        |
| instructions     | string          | Нет        | Инструкция по тону и стилю, до 4096 символов.                                                                       |
| style            | string          | Нет        | Расширение совместимого сервиса с приоритетом над instructions; voicedesign использует его для описания тембра.     |
| speed            | number          | Нет        | 0.25–4, по умолчанию 1; преобразуется в стилевую инструкцию, не гарантирует точное изменение скорости по семплам.   |
| response\_format | string          | Нет        | wav, mp3, opus, aac, flac, pcm. MiMo по умолчанию wav; лучше указать явно.                                          |
| stream\_format   | string          | Нет        | Совместимый сервис принимает только audio; sse возвращает 400, поток синтеза с низкой задержкой не предоставляется. |

Соответствие голосов\: alloy→Bingtang, echo→Moli, fable→Baihua, onyx→Suda, nova→Mia, shimmer→Chloe, dean→Dean, milo→Milo. Это соответствие сервиса, не голоса OpenAI с теми же именами.

### Транскрипция\: POST /v1/audio/transcriptions

| Поле                        | Тип       | Обязателен | Описание                                                                                          |
| --------------------------- | --------- | ---------- | ------------------------------------------------------------------------------------------------- |
| file                        | file      | Да         | Multipart-файл; по умолчанию до 25 MiB, настраивается.                                            |
| model                       | string    | Да         | mimo-v2.5-asr.                                                                                    |
| language                    | string    | Нет        | auto (по умолчанию), zh, en.                                                                      |
| languages\[]                | string\[] | Нет        | Языки-кандидаты, несовместимо с language; несколько кандидатов сводятся к автоопределению.        |
| response\_format            | string    | Нет        | json (по умолчанию), text, verbose\_json, srt, vtt. diarized\_json не поддерживается.             |
| stream                      | boolean   | Нет        | SSE только после завершения транскрипции, не распознавание по мере прослушивания.                 |
| timestamp\_granularities\[] | string\[] | Нет        | Не поддерживается\: непустое значение дает 400, временные метки слов и сегментов не выдумываются. |

Сервис принимает mp3, wav, aac, flac, m4a, mp4, mpeg, mpga, oga, ogg, opus, webm; для форматов без нативной поддержки нужен конвертер. Собственный ASR Xiaomi принимает только MP3/WAV\: ограничения нельзя переносить между API.

## Ответ

* TTS возвращает аудиобинарные данные с соответствующим MIME после завершения синтеза; публичного task\_id нет.
* ASR JSON имеет вид `{"text":"识别文字"}`; text возвращает простой текст.
* verbose\_json содержит task, language, duration, text и пустые segments; **реальных временных меток сегментов нет**. SRT/VTT представляют всю запись, а не выравнивание слов.
* stream=true оборачивает только финальную транскрипцию в SSE и не доказывает Realtime-поддержку провайдера.

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

### Текст в речь

Задайте ключ отдельного сервиса `MIMO_AUDIO_API_KEY`. Пример создает `mimo-speech.wav`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'http://127.0.0.1:8080/v1/audio/speech'
    headers = {'Authorization': 'Bearer ' + os.environ['MIMO_AUDIO_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'mimo-v2.5-tts', 'input': '你好，欢迎使用 MiMo 语音。', 'voice': 'alloy', 'response_format': 'wav'}, timeout=180)
    response.raise_for_status()
    Path('mimo-speech.wav').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "http://127.0.0.1:8080/v1/audio/speech";
      const headers = { "Authorization": "Bearer " + process.env.MIMO_AUDIO_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("mimo-speech.wav", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "mimo-speech.wav" ] || { printf '%s\n' "目标文件已存在：mimo-speech.wav" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X POST "http://127.0.0.1:8080/v1/audio/speech" \
      -H "Authorization: Bearer $MIMO_AUDIO_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary '{
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    }' \
      --output "$temporary"; then
      mv "$temporary" "mimo-speech.wav"
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
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    }`)
      req, err := http.NewRequest("POST", "http://127.0.0.1:8080/v1/audio/speech", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("MIMO_AUDIO_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("mimo-speech.wav", data, 0600))
    }
    ```
  </Tab>
</Tabs>

### Речь в текст

Подготовьте `speech.wav`. Аутентификация по-прежнему ключом отдельного сервиса.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'http://127.0.0.1:8080/v1/audio/transcriptions'
    headers = {'Authorization': 'Bearer ' + os.environ['MIMO_AUDIO_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'mimo-v2.5-asr', 'language': 'auto', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "http://127.0.0.1:8080/v1/audio/transcriptions";
      const headers = { "Authorization": "Bearer " + process.env.MIMO_AUDIO_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "mimo-v2.5-asr");
      form.append("language", "auto");
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
    curl "http://127.0.0.1:8080/v1/audio/transcriptions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $MIMO_AUDIO_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=mimo-v2.5-asr" \
      -F "language=auto" \
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
      check(writer.WriteField("model", "mimo-v2.5-asr"))
      check(writer.WriteField("language", "auto"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "http://127.0.0.1:8080/v1/audio/transcriptions", &buffer); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("MIMO_AUDIO_API_KEY"))
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

### Дизайн и клонирование голоса

Для дизайна замените model на `mimo-v2.5-tts-voicedesign` и добавьте `style: "温暖低沉的成年男声，普通话清晰"`. Для клонирования задайте model `mimo-v2.5-tts-voiceclone`, а voice — `data:audio/wav;base64,<真实参考音频>`. Не отправляйте пустой Base64, файл с переименованным расширением или голос другого человека без разрешения.

```python
import base64
import os
from pathlib import Path
import requests
reference = base64.b64encode(Path("reference.wav").read_bytes()).decode("ascii")
response = requests.post("http://127.0.0.1:8080/v1/audio/speech",
    headers={"Authorization": "Bearer " + os.environ["MIMO_AUDIO_API_KEY"]},
    json={"model":"mimo-v2.5-tts-voiceclone","input":"这是一条授权声音示例。",
          "voice":"data:audio/wav;base64," + reference,"response_format":"wav"}, timeout=180)
response.raise_for_status()
Path("clone.wav").write_bytes(response.content)
```

### Собственный протокол Xiaomi

Официальный TTS использует `assistant` для текста озвучки, а `user` — для инструкции стиля. Это официальный JSON, его нельзя отправлять в `/audio/speech`\:

```json
{"model":"mimo-v2.5-tts","messages":[{"role":"user","content":"温暖自然"},{"role":"assistant","content":"你好，欢迎使用 MiMo。"}],"audio":{"format":"wav","voice":"mimo_default"},"stream":false}
```

Официальное аудио находится в `choices[0].message.audio.data` и требует Base64-декодирования. ASR передает звук через `messages[0].content`\:

```json
{"model":"mimo-v2.5-asr","messages":[{"role":"user","content":[{"type":"input_audio","input_audio":{"data":"data:audio/wav;base64,<真实Base64>"}}]}],"asr_options":{"language":"auto"},"stream":false}
```

Текст ASR находится в `choices[0].message.content`. При MIME в data URL поле format необязательно; для чистого Base64 укажите `format: "wav"` или `"mp3"`; если заданы оба значения, они должны совпадать.

## Коды ошибок

| HTTP / code                       | Значение                                                        |
| --------------------------------- | --------------------------------------------------------------- |
| 400 / unsupported\_audio\_format  | Неверный формат вывода TTS.                                     |
| 400 / speech\_sse\_not\_supported | Совместимый сервис не поддерживает TTS SSE.                     |
| 400 / diarization\_not\_supported | ASR не поддерживает формат разделения говорящих.                |
| 400 / timestamps\_not\_supported  | ASR не поддерживает гранулярность временных меток.              |
| 401 / 403                         | Неверный ключ или права отдельного сервиса.                     |
| 404 / voice\_not\_found           | Пользовательский голос не найден или принадлежит другому ключу. |
| 413 / input\_too\_large           | Текст или медиа превышают ограничение.                          |
| 415 / unsupported\_file\_type     | Расширение файла или MIME не поддерживаются.                    |
| 422 / invalid\_audio              | Не удалось декодировать медиа.                                  |
| 502 / invalid\_audio\_output      | Провайдер не вернул допустимое аудио.                           |
| 503 / audio\_failover\_exhausted  | Аудиосервис временно недоступен.                                |

Загрузка клонируемого голоса изменяет состояние\: не повторяйте ее вслепую после тайм-аута.

## Официальные материалы

[MiMo TTS](https\://mimo.mi.com/docs/en-US/api/audio/tts), [MiMo ASR](https\://mimo.mi.com/docs/en-US/api/audio/Speech-Recognition). Официальные страницы описывают собственный протокол, а не расширения совместимого сервиса.