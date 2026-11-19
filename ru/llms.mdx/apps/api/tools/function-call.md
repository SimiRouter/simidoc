# Вызов функций-инструментов

## Описание интерфейса

В `POST /v1/chat/completions` параметр tools сообщает модели доступные функции. Модель только генерирует имя и аргументы. Приложение проверяет параметры и права, выполняет функцию и передает результат сообщением tool, затем запрашивает итоговый ответ. Сам вызов функции не обращается к базе данных, не переводит деньги и не отправляет уведомления.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $SIMIROUTER_API_KEY`. Прямой OpenAI — `https://api.openai.com`; также Bearer, но нужен ключ OpenAI. Выберите доступную модель с поддержкой требуемой функции.

## Параметры запроса

| Поле                          | Тип             | Обязателен  | Описание                                                                                                   |
| ----------------------------- | --------------- | ----------- | ---------------------------------------------------------------------------------------------------------- |
| model / messages              | string / array  | Да          | Модель и сообщения; модель должна поддерживать функции-инструменты.                                        |
| tools\[].type                 | string          | Да          | Здесь function.                                                                                            |
| tools\[].function.name        | string          | Да          | Имя функции для диспетчеризации по белому списку приложения.                                               |
| tools\[].function.description | string          | Нет         | Описание назначения, ограничений ввода и побочных эффектов.                                                |
| tools\[].function.parameters  | object          | Да          | JSON Schema параметров функции.                                                                            |
| tools\[].function.strict      | boolean         | Нет         | true требует строгого соответствия поддерживаемому подмножеству Schema.                                    |
| tool\_choice                  | string / object | Нет         | auto — автоматический выбор; none — запрет; required — хотя бы один вызов; также можно задать имя функции. |
| parallel\_tool\_calls         | boolean         | Нет         | Разрешает несколько вызовов за раунд; false ограничивает число одним вызовом.                              |
| messages\[].tool\_call\_id    | string          | При условии | При возврате сообщения tool необходимо указать id соответствующего assistant tool\_calls.                  |
| messages\[].content           | string          | При условии | Результат выполнения в сообщении tool; рекомендуется JSON-текст.                                           |

При strict=true каждый объект должен иметь additionalProperties=false, а все поля properties — входить в required. Логически необязательное поле может допускать null. Неподдерживаемая Schema вызывает ошибку запроса.

### Первый запрос

```json
{
  "model": "MODEL_ID",
  "messages": [
    {
      "role": "user",
      "content": "请计算17乘以23。"
    }
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "multiply_numbers",
        "description": "将两个整数相乘。",
        "strict": true,
        "parameters": {
          "type": "object",
          "properties": {
            "a": {
              "type": "integer"
            },
            "b": {
              "type": "integer"
            }
          },
          "required": [
            "a",
            "b"
          ],
          "additionalProperties": false
        }
      }
    }
  ],
  "tool_choice": "auto",
  "parallel_tool_calls": false,
  "stream": false
}
```

## Ответ

| Поле                                 | Тип           | Описание                                                                                                   |
| ------------------------------------ | ------------- | ---------------------------------------------------------------------------------------------------------- |
| choices\[].message.tool\_calls\[].id | string        | ID вызова инструмента для последующего tool\_call\_id.                                                     |
| tool\_calls\[].type                  | string        | function.                                                                                                  |
| tool\_calls\[].function.name         | string        | Имя вызываемой функции; должно быть в белом списке приложения.                                             |
| tool\_calls\[].function.arguments    | string        | JSON-текст, а не разобранный объект; сначала разберите его, затем проверьте типы и значения.               |
| choices\[].message.content           | string / null | При вызове функции может быть null.                                                                        |
| choices\[].finish\_reason            | string        | tool\_calls означает необходимость выполнения инструментов; stop обычно означает итоговый текстовый ответ. |
| usage                                | object        | Каждый запрос к модели отдельно расходует токены.                                                          |

```json
{
  "id": "chatcmpl_tool_example",
  "object": "chat.completion",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": null,
        "tool_calls": [
          {
            "id": "call_example",
            "type": "function",
            "function": {
              "name": "multiply_numbers",
              "arguments": "{\"a\":17,\"b\":23}"
            }
          }
        ]
      },
      "finish_reason": "tool_calls"
    }
  ]
}
```

### Выполнение и возврат результата

Приложение проверяет name=multiply\_numbers и допустимость целых a и b, затем получает 391. Ниже дан полный второй запрос; замените call\_example реальным ID первого ответа. Статический ID нельзя повторно использовать для произвольных запросов.

```json
{
  "model": "MODEL_ID",
  "messages": [
    {
      "role": "user",
      "content": "请计算17乘以23。"
    },
    {
      "role": "assistant",
      "content": null,
      "tool_calls": [
        {
          "id": "call_example",
          "type": "function",
          "function": {
            "name": "multiply_numbers",
            "arguments": "{\"a\":17,\"b\":23}"
          }
        }
      ]
    },
    {
      "role": "tool",
      "tool_call_id": "call_example",
      "content": "391"
    }
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "multiply_numbers",
        "description": "将两个整数相乘。",
        "strict": true,
        "parameters": {
          "type": "object",
          "properties": {
            "a": {
              "type": "integer"
            },
            "b": {
              "type": "integer"
            }
          },
          "required": [
            "a",
            "b"
          ],
          "additionalProperties": false
        }
      }
    }
  ],
  "tool_choice": "none",
  "stream": false
}
```

Для каждого из нескольких tool\_calls нужен соответствующий результат. Не пропускайте вызовы и не смешивайте ID разных диалогов. Параллельно выполняйте только независимые и разрешенные инструменты. Для отправок, списаний и других эффектов требуется идемпотентность\: повторный запрос модели не разрешает повтор операции.

### Отличия Responses

В Responses определение функции содержит type, name, description, parameters, strict непосредственно в tools\[], без обертки function. Ответ содержит элемент type=function\_call; результат передается как `{"type":"function_call_output","call_id":"...","output":"391"}`. Не смешивайте tool\_call\_id из Chat с call\_id из Responses.

## Примеры вызова

Примеры четырех языков выполняют одно локальное умножение без побочных эффектов и возвращают результат. Не более двух запросов без бесконечного цикла. Задайте `SIMIROUTER_API_KEY`, `SIMIROUTER_MODEL`; `SIMIROUTER_BASE_URL` переопределяет адрес шлюза по умолчанию; не добавляйте в конец `/v1`. Примеры Python 3, Node.js 18+ и Go используют только стандартную библиотеку; JSON в примере curl безопасно формируется Python 3.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_MODEL"): raise RuntimeError("请设置 SIMIROUTER_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "请计算17乘以23。"
        }
      ],
      "tools": [
        {
          "type": "function",
          "function": {
            "name": "multiply_numbers",
            "description": "将两个整数相乘。",
            "strict": true,
            "parameters": {
              "type": "object",
              "properties": {
                "a": {
                  "type": "integer"
                },
                "b": {
                  "type": "integer"
                }
              },
              "required": [
                "a",
                "b"
              ],
              "additionalProperties": false
            }
          }
        }
      ],
      "tool_choice": "auto",
      "parallel_tool_calls": false,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/chat/completions'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    assistant = result["choices"][0]["message"]
    body["messages"].append(assistant)
    for call in assistant.get("tool_calls", []):
        if call.get("type") != "function" or call["function"]["name"] != "multiply_numbers":
            raise ValueError("未知函数")
        args = json.loads(call["function"]["arguments"])
        if set(args) != {"a", "b"} or any(type(args[k]) is not int or abs(args[k]) > 1000000 for k in ("a", "b")):
            raise ValueError("参数须为绝对值不超过1000000的两个整数")
        body["messages"].append({"role": "tool", "tool_call_id": call["id"], "content": str(args["a"] * args["b"])})
    if assistant.get("tool_calls"):
        body["tool_choice"] = "none"
        request.data = json.dumps(body).encode("utf-8")
        try:
            with urllib.request.urlopen(request, timeout=120) as response:
                result = json.load(response)
        except urllib.error.HTTPError as error:
            print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
            raise SystemExit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      if (!process.env.SIMIROUTER_MODEL) throw new Error("请设置 SIMIROUTER_MODEL");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const body = {
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "请计算17乘以23。"
        }
      ],
      "tools": [
        {
          "type": "function",
          "function": {
            "name": "multiply_numbers",
            "description": "将两个整数相乘。",
            "strict": true,
            "parameters": {
              "type": "object",
              "properties": {
                "a": {
                  "type": "integer"
                },
                "b": {
                  "type": "integer"
                }
              },
              "required": [
                "a",
                "b"
              ],
              "additionalProperties": false
            }
          }
        }
      ],
      "tool_choice": "auto",
      "parallel_tool_calls": false,
      "stream": false
    };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = "/v1/chat/completions";
      const response = await fetch(base + endpoint, { method: "POST",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000) });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      let parsed = JSON.parse(result);
      const assistant = parsed.choices[0].message;
      body.messages.push(assistant);
      for (const call of assistant.tool_calls || []) {
        if (call.type !== "function" || call.function.name !== "multiply_numbers") throw new Error("未知函数");
        const args = JSON.parse(call.function.arguments);
        if (Object.keys(args).sort().join(",") !== "a,b" || ![args.a, args.b].every(x => Number.isSafeInteger(x) && Math.abs(x) <= 1000000)) throw new Error("函数参数超出范围");
        body.messages.push({ role: "tool", tool_call_id: call.id, content: String(args.a * args.b) });
      }
      if (assistant.tool_calls?.length) {
        body.tool_choice = "none";
        const final = await fetch(base + endpoint, { method: "POST", headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" }, body: JSON.stringify(body), signal: AbortSignal.timeout(120000) });
        const text = await final.text();
        if (!final.ok) throw new Error(`HTTP ${final.status}: ${text}`);
        parsed = JSON.parse(text);
      }
      console.log(JSON.stringify(parsed, null, 2));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "请计算17乘以23。"
        }
      ],
      "tools": [
        {
          "type": "function",
          "function": {
            "name": "multiply_numbers",
            "description": "将两个整数相乘。",
            "strict": true,
            "parameters": {
              "type": "object",
              "properties": {
                "a": {
                  "type": "integer"
                },
                "b": {
                  "type": "integer"
                }
              },
              "required": [
                "a",
                "b"
              ],
              "additionalProperties": false
            }
          }
        }
      ],
      "tool_choice": "auto",
      "parallel_tool_calls": false,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    WORK_DIR=$(mktemp -d)
    trap 'rm -rf "$WORK_DIR"' EXIT
    printf '%s' "$BODY" > "$WORK_DIR/request.json"
    curl "${BASE_URL%/}/v1/chat/completions" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "$BODY" \
      --output "$WORK_DIR/response.json"
    python3 - "$WORK_DIR" <<'PYTOOL'
    import json, sys
    from pathlib import Path
    folder = Path(sys.argv[1])
    body = json.loads((folder / "request.json").read_text())
    result = json.loads((folder / "response.json").read_text())
    assistant = result["choices"][0]["message"]
    body["messages"].append(assistant)
    for call in assistant.get("tool_calls", []):
        if call.get("type") != "function" or call["function"]["name"] != "multiply_numbers":
            raise ValueError("未知函数")
        args = json.loads(call["function"]["arguments"])
        if set(args) != {"a", "b"} or any(type(args[k]) is not int or abs(args[k]) > 1000000 for k in ("a", "b")):
            raise ValueError("函数参数超出范围")
        body["messages"].append({"role": "tool", "tool_call_id": call["id"], "content": str(args["a"] * args["b"])})
    if assistant.get("tool_calls"):
        body["tool_choice"] = "none"
        (folder / "follow-up.json").write_text(json.dumps(body, ensure_ascii=False))
    else:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    PYTOOL
    if [ -f "$WORK_DIR/follow-up.json" ]; then
      curl "${BASE_URL%/}/v1/chat/completions" \
        --fail-with-body \
        --max-time 120 \
        -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
        -H "Content-Type: application/json" \
        --data-binary "@$WORK_DIR/follow-up.json"
    fi
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "math"
      "bytes"
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
      "encoding/json"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "请计算17乘以23。"
        }
      ],
      "tools": [
        {
          "type": "function",
          "function": {
            "name": "multiply_numbers",
            "description": "将两个整数相乘。",
            "strict": true,
            "parameters": {
              "type": "object",
              "properties": {
                "a": {
                  "type": "integer"
                },
                "b": {
                  "type": "integer"
                }
              },
              "required": [
                "a",
                "b"
              ],
              "additionalProperties": false
            }
          }
        }
      ],
      "tool_choice": "auto",
      "parallel_tool_calls": false,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/chat/completions"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
      var parsed struct { Choices []struct { Message map[string]any `json:"message"` } `json:"choices"` }
      if err := json.Unmarshal(result, &parsed); err != nil { log.Fatal(err) }
      if len(parsed.Choices) == 0 { log.Fatal("响应没有候选消息") }
      assistant := parsed.Choices[0].Message
      messages := body["messages"].([]any)
      messages = append(messages, assistant)
      calls, _ := assistant["tool_calls"].([]any)
      for _, raw := range calls {
        call, ok := raw.(map[string]any); if !ok { log.Fatal("无效调用") }
        function, ok := call["function"].(map[string]any); if !ok || call["type"] != "function" || function["name"] != "multiply_numbers" { log.Fatal("未知函数") }
        arguments, ok := function["arguments"].(string); if !ok { log.Fatal("参数不是JSON文本") }
        var args map[string]any; if err := json.Unmarshal([]byte(arguments), &args); err != nil { log.Fatal(err) }
        a, aOK := args["a"].(float64); b, bOK := args["b"].(float64)
        if len(args) != 2 || !aOK || !bOK || math.Trunc(a) != a || math.Trunc(b) != b || math.Abs(a) > 1000000 || math.Abs(b) > 1000000 { log.Fatal("函数参数超出范围") }
        id, ok := call["id"].(string); if !ok || id == "" { log.Fatal("缺少调用ID") }
        messages = append(messages, map[string]any{"role":"tool", "tool_call_id":id, "content":fmt.Sprintf("%.0f", a*b)})
      }
      if len(calls) > 0 {
        body["messages"] = messages; body["tool_choice"] = "none"
        payload, err = json.Marshal(body); if err != nil { log.Fatal(err) }
        req, err = http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
        req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
        final, err := client.Do(req); if err != nil { log.Fatal(err) }; defer final.Body.Close()
        result, err = io.ReadAll(final.Body); if err != nil { log.Fatal(err) }
        if final.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", final.StatusCode, result) }
      }
      fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Коды ошибок

| Статус HTTP | Значение или тип ошибки провайдера       | Действие                                                                          |
| ----------- | ---------------------------------------- | --------------------------------------------------------------------------------- |
| 400         | Неверный запрос                          | Проверьте обязательные поля, JSON, параметры модели и длину контекста.            |
| 401         | Ошибка аутентификации                    | Проверьте наличие, действительность и принадлежность ключа.                       |
| 403 / 404   | Нет доступа / ресурс не найден           | Проверьте права модели, ID ресурса и URL.                                         |
| 429         | Ограничение частоты или квоты            | Различайте лимит скорости и нехватку квоты по ответу; повтор не восполняет квоту. |
| 500 / 503   | Ошибка сервиса / временная недоступность | Сохраните ID и ограниченно повторите временные сбои с задержкой.                  |

Ошибка OpenAI обычно содержит `error.message`, `error.type`, `error.param`, `error.code`; `param` и `code` могут быть `null`; эти поля необязательны и могут отличаться от HTTP-статуса. Шлюз может отказать до обращения к провайдеру. Ошибка разбора arguments, неизвестная функция или сбой выполнения относятся к приложению\: нельзя выдавать их за успешный вызов. Успешный HTTP-ответ может лишь запрашивать инструмент, не завершая задачу пользователя.

## Официальные материалы

* [OpenAI\: вызов функций](https\://developers.openai.com/api/docs/guides/function-calling)
* [OpenAI Chat Completions](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI Responses](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI\: обработка ошибок](https\://developers.openai.com/api/docs/guides/error-codes)