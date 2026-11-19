# Синтез речи Gemini

## Описание интерфейса

TTS Gemini точно озвучивает заданный текст и отличается от диалогового Live API. Примеры используют **официальный Google Interactions API**\: `POST https://generativelanguage.googleapis.com/v1beta/interactions`, аутентификация — `x-goog-api-key: $GEMINI_API_KEY`. Это не OpenAI `/audio/speech`; для шлюза недостаточно заменить домен и ключ.

`gemini-3.8-flash-tts` и `gemini-3.8-flash-lite-tts` используют эту структуру. Поддерживаемые Preview TTS Gemini 3.1 / 2.5 используют собственные настройки generateContent\: поколения протоколов нельзя смешивать. Наличие Interactions у прокси SimiRouter уточняйте по каналу.

## Параметры запроса

| Поле                              | Тип            | Обязателен  | Описание                                                                                |
| --------------------------------- | -------------- | ----------- | --------------------------------------------------------------------------------------- |
| model                             | string         | Да          | Например gemini-3.8-flash-tts.                                                          |
| input                             | string / array | Да          | Текст озвучки; для стилевых аннотаций используется user\_input/content.                 |
| input\[].content\[].text          | string         | Да          | Текст, который нужно прочитать дословно.                                                |
| annotations\[].type               | string         | При условии | Стилевые аннотации используют speech\_metadata.                                         |
| annotations\[].style              | string         | Нет         | Тон, акцент или темп текущей реплики.                                                   |
| annotations\[].speaker            | string         | При условии | Для нескольких говорящих соответствует speaker в конфигурации.                          |
| response\_format                  | object         | Нет         | В примере \{"type"\:"audio"}; формат определяется MIME ответа.                          |
| generation\_config.speech\_config | array / object | Да          | Для одного голоса \[\{"voice"\:"Kore"}]; для нескольких — объект speakers.              |
| stream                            | boolean        | Нет         | При поддержке модели true возвращает события; текст SSE нельзя сохранять как аудиофайл. |

Для нескольких говорящих используйте `{"speakers":[{"speaker":"Joe","voice":"Kore"},{"speaker":"Jane","voice":"Puck"}]}`. Аннотация speech\_metadata.speaker каждой реплики ссылается на Joe или Jane; недостаточно объединить реплики без меток. Дизайн и клонирование требуют соответствующего voice ID и разрешения на голос.

## Ответ

REST возвращает Interaction; аудио находится в `steps[]` в `type=model_output` с поддержкой `content[]`; элемент аудио `type=audio`, `data` содержит Base64, а `mime_type` указывает формат. Поле SDK `output_audio` является удобным свойством, а не обязательным корневым полем REST. WAV можно декодировать и сохранить без добавления заголовка вручную.

```json
{"steps":[{"type":"model_output","content":[{"type":"audio","mime_type":"audio/wav","data":"<Base64音频>"}]}]}
```

## Примеры вызова

Задайте официальный ключ Google `GEMINI_API_KEY`. Python 3, Node.js 18+ и Go используют стандартную библиотеку; curl требует Python 3 для разбора. По умолчанию прямое подключение Google; `GEMINI_BASE_URL` позволяет локальное тестирование или разрешенный прокси собственного протокола, без `/v1beta`.

Пример проверяет `status=completed`, затем декодирует все элементы аудио и сохраняет `speech-1.wav` и последующие файлы без перезаписи. Другой MIME обрабатывайте по реальному формату, не меняйте только расширение.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import base64, json, os, urllib.request
    key = os.environ["GEMINI_API_KEY"]
    base = os.environ.get("GEMINI_BASE_URL", "https://generativelanguage.googleapis.com").rstrip("/")
    body = json.loads(r'''{
      "model": "gemini-3.8-flash-tts",
      "input": [
        {
          "type": "user_input",
          "content": [
            {
              "type": "text",
              "text": "祝你今天过得愉快。",
              "annotations": [
                {
                  "type": "speech_metadata",
                  "style": "温暖自然"
                }
              ]
            }
          ]
        }
      ],
      "response_format": {
        "type": "audio"
      },
      "generation_config": {
        "speech_config": [
          {
            "voice": "Kore"
          }
        ]
      }
    }''')
    request = urllib.request.Request(base + "/v1beta/interactions", data=json.dumps(body).encode(),
        headers={"x-goog-api-key": key, "Content-Type": "application/json"}, method="POST")
    with urllib.request.urlopen(request, timeout=180) as response:
        result = json.load(response)
    if result.get("status") != "completed":
        raise RuntimeError("生成未完成: " + str(result.get("status")))
    audio = [part for step in result.get("steps", []) if step.get("type") == "model_output"
             for part in step.get("content", []) if part.get("type") == "audio"]
    if not audio: raise RuntimeError("响应没有音频")
    for i, part in enumerate(audio):
        if part.get("mime_type") not in ("audio/wav", "audio/x-wav", "audio/wave"):
            raise RuntimeError("响应不是 WAV: " + str(part.get("mime_type")))
        data = base64.b64decode(part["data"], validate=True)
        if not data: raise RuntimeError("音频为空")
        name = f"speech-{i + 1}.wav"
        with open(name, "xb") as output: output.write(data)
        print(name)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { writeFile } = require("node:fs/promises");
    async function main() {
      if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
      const base = (process.env.GEMINI_BASE_URL || "https://generativelanguage.googleapis.com").replace(/\/$/, "");
      const response = await fetch(base + "/v1beta/interactions", {
        method: "POST", headers: {"x-goog-api-key": process.env.GEMINI_API_KEY, "Content-Type": "application/json"},
        body: JSON.stringify({"model":"gemini-3.8-flash-tts","input":[{"type":"user_input","content":[{"type":"text","text":"祝你今天过得愉快。","annotations":[{"type":"speech_metadata","style":"温暖自然"}]}]}],"response_format":{"type":"audio"},"generation_config":{"speech_config":[{"voice":"Kore"}]}}), signal: AbortSignal.timeout(180000)
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.status !== "completed") throw new Error("生成未完成: " + result.status);
      const audio = (result.steps || []).filter(s => s.type === "model_output").flatMap(s => s.content || []).filter(p => p.type === "audio");
      if (!audio.length) throw new Error("响应没有音频");
      for (const [i, part] of audio.entries()) {
        if (!["audio/wav", "audio/x-wav", "audio/wave"].includes(part.mime_type)) throw new Error("响应不是 WAV");
        if (!part.data || !/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(part.data)) throw new Error("无效 Base64");
        const data = Buffer.from(part.data, "base64");
        const name = `speech-${i + 1}.wav`;
        await writeFile(name, data, {flag: "wx"}); console.log(name);
      }
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${GEMINI_API_KEY:?请设置 GEMINI_API_KEY}"
    base="${GEMINI_BASE_URL:-https://generativelanguage.googleapis.com}"
    response=$(mktemp)
    trap 'rm -f "$response"' EXIT
    curl "${base%/}/v1beta/interactions" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      --output "$response" \
      -d '{
        "model": "gemini-3.8-flash-tts",
        "input": [
          {
            "type": "user_input",
            "content": [
              {
                "type": "text",
                "text": "祝你今天过得愉快。",
                "annotations": [
                  {
                    "type": "speech_metadata",
                    "style": "温暖自然"
                  }
                ]
              }
            ]
          }
        ],
        "response_format": {
          "type": "audio"
        },
        "generation_config": {
          "speech_config": [
            {
              "voice": "Kore"
            }
          ]
        }
      }'
    python3 - "$response" <<'PY_AUDIO'
    import base64, json, sys
    with open(sys.argv[1]) as source: result = json.load(source)
    if result.get("status") != "completed": raise RuntimeError("生成未完成")
    audio = [part for step in result.get("steps", []) if step.get("type") == "model_output"
             for part in step.get("content", []) if part.get("type") == "audio"]
    if not audio: raise RuntimeError("响应没有音频")
    for i, part in enumerate(audio):
        if part.get("mime_type") not in ("audio/wav", "audio/x-wav", "audio/wave"): raise RuntimeError("响应不是 WAV")
        data = base64.b64decode(part["data"], validate=True)
        if not data: raise RuntimeError("音频为空")
        name = f"speech-{i + 1}.wav"
        with open(name, "xb") as output: output.write(data)
        print(name)
    PY_AUDIO
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import ("bytes"; "encoding/base64"; "encoding/json"; "fmt"; "io"; "net/http"; "os"; "time"; "strings")
    func check(err error) { if err != nil { panic(err) } }
    func main() {
     key:=os.Getenv("GEMINI_API_KEY"); if key=="" { panic("请设置 GEMINI_API_KEY") }
     base:=os.Getenv("GEMINI_BASE_URL"); if base=="" {base="https://generativelanguage.googleapis.com"}
     req,err:=http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1beta/interactions", bytes.NewBufferString(`{"model":"gemini-3.8-flash-tts","input":[{"type":"user_input","content":[{"type":"text","text":"祝你今天过得愉快。","annotations":[{"type":"speech_metadata","style":"温暖自然"}]}]}],"response_format":{"type":"audio"},"generation_config":{"speech_config":[{"voice":"Kore"}]}}`));check(err)
     req.Header.Set("x-goog-api-key",key);req.Header.Set("Content-Type","application/json")
     res,err:=(&http.Client{Timeout:180*time.Second}).Do(req);check(err);defer res.Body.Close()
     raw,err:=io.ReadAll(res.Body);check(err);if res.StatusCode>=300 {panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw))}
     var result struct {Status string `json:"status"`; Steps []struct {Type string `json:"type"`;Content []struct {Type string `json:"type"`;Mime string `json:"mime_type"`;Data string `json:"data"`} `json:"content"`} `json:"steps"`}
     check(json.Unmarshal(raw,&result));if result.Status!="completed" {panic("生成未完成")}
     count:=0
     for _,step:=range result.Steps { if step.Type!="model_output" {continue}; for _,part:=range step.Content {if part.Type!="audio" {continue}
     if part.Mime!="audio/wav" && part.Mime!="audio/x-wav" && part.Mime!="audio/wave" {panic("响应不是 WAV")}
     data,err:=base64.StdEncoding.Strict().DecodeString(part.Data);check(err);if len(data)==0 {panic("音频为空")}
     count++;name:=fmt.Sprintf("speech-%d.wav",count);out,err:=os.OpenFile(name,os.O_WRONLY|os.O_CREATE|os.O_EXCL,0600);check(err)
     _,err=out.Write(data);closeErr:=out.Close();check(err);check(closeErr);fmt.Println(name)
     }};if count==0 {panic("响应没有音频")}
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

Объект ошибки Google содержит `error.code`, `error.status` и `error.message`; не определяйте источник только по номеру HTTP. Этот интерфейс синхронный\: идентификатора задачи и этапа опроса нет. Никогда не декодируйте текст ошибки как аудиоданные.

## Официальные материалы

[Google Gemini TTS](https\://ai.google.dev/gemini-api/docs/speech-generation), [Interactions](https\://ai.google.dev/gemini-api/docs/interactions).