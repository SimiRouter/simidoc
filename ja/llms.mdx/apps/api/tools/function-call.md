# 関数ツール呼び出し

## API の説明

`POST /v1/chat/completions` の tools は利用可能な関数をモデルに知らせます。モデルが生成するのは関数名と引数だけで、アプリが検証、認可、実行を行い、tool メッセージで結果を返して最終回答を要求します。関数呼び出し自体がデータベースへ接続したり、送金や通知を行うわけではありません。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $SIMIROUTER_API_KEY` です。OpenAI への公式直接接続先は `https://api.openai.com` で、同じ Bearer 認証でも OpenAI のキーに置き換える必要があります。アクセス可能で目的の機能に対応するモデルを選択してください。

## リクエストパラメータ

| フィールド                         | 型               | 必須   | 説明                                                     |
| ----------------------------- | --------------- | ---- | ------------------------------------------------------ |
| model / messages              | string / array  | はい   | モデルと会話。モデルは関数ツールに対応する必要があります。                          |
| tools\[].type                 | string          | はい   | ここでは function。                                         |
| tools\[].function.name        | string          | はい   | アプリの許可リストで振り分ける関数名。                                    |
| tools\[].function.description | string          | いいえ  | 用途、入力範囲、副作用の説明。                                        |
| tools\[].function.parameters  | object          | はい   | 関数引数の JSON Schema。                                     |
| tools\[].function.strict      | boolean         | いいえ  | true では対応する Schema サブセットへの厳密一致を要求。                     |
| tool\_choice                  | string / object | いいえ  | auto は自動選択、none は無効、required は最低1つ。関数名の指定も可能。          |
| parallel\_tool\_calls         | boolean         | いいえ  | 同一ターンの複数呼び出しを許可。false なら最大1つ。                          |
| messages\[].tool\_call\_id    | string          | 条件付き | tool メッセージで返す場合は assistant の tool\_calls の id に対応させます。 |
| messages\[].content           | string          | 条件付き | tool メッセージの実行結果。JSON テキストへの変換を推奨。                      |

strict=true では各オブジェクトに additionalProperties=false を指定し、properties の全フィールドを required に含めます。論理上任意なら null を許容します。未対応の Schema はエラーになります。

### 最初のリクエスト

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

## 戻り値

| フィールド                                | 型             | 説明                                     |
| ------------------------------------ | ------------- | -------------------------------------- |
| choices\[].message.tool\_calls\[].id | string        | 後続 tool\_call\_id に使うツール呼び出し ID。       |
| tool\_calls\[].type                  | string        | function。                              |
| tool\_calls\[].function.name         | string        | 呼び出す関数名。アプリの許可リストとの一致が必要。              |
| tool\_calls\[].function.arguments    | string        | 解析済みオブジェクトではなく JSON テキスト。解析後に型と値を検証。   |
| choices\[].message.content           | string / null | 関数呼び出し時は null の場合があります。                |
| choices\[].finish\_reason            | string        | tool\_calls はツール実行要求、stop は通常最終自然言語回答。 |
| usage                                | object        | 各ターンのモデルリクエストに別々の Token 用量が発生。         |

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

### 実行と結果返却

アプリは name=multiply\_numbers と a、b が許容範囲の整数であることを検証し、391 を計算します。以下は第2ターンの完全なリクエストで、call\_example は最初に受信した実 ID に置換します。固定 ID を他の呼び出しに再利用しないでください。

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

複数 tool\_calls にはそれぞれ結果を返し、別会話の ID を混用しないでください。並列実行は依存がなく認可済みのツールだけに限定します。送信・課金などは独立した冪等制御が必要で、モデルが再要求しても重複実行しないでください。

### Responses との形式差

Responses の関数定義は tools\[] 直下の type、name、description、parameters、strict で、function には包みません。type=function\_call の出力に対して `{"type":"function_call_output","call_id":"...","output":"391"}` を返します。Chat の tool\_call\_id と Responses の call\_id を混用しないでください。

## コード例

4 言語の例は副作用のないローカル乗算を一度実行して結果を返し、リクエストは最大2回で無限ループしません。次を設定します：`SIMIROUTER_API_KEY`、`SIMIROUTER_MODEL`；`SIMIROUTER_BASE_URL` で既定のゲートウェイアドレスを変更できます。末尾に `/v1` を追加しないでください。Python 3、Node.js 18+、Go は標準ライブラリのみを使用します。curl 例の JSON は Python 3 で安全にエンコードします。

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

## エラーコード

| HTTP ステータス | 意味または各社のエラー型   | 対処                                      |
| ---------- | -------------- | --------------------------------------- |
| 400        | 無効なリクエスト       | 必須項目、JSON、モデルパラメータ、文脈長を確認。              |
| 401        | 認証失敗           | キーの存在、有効性、所属を確認。                        |
| 403 / 404  | アクセス拒否／リソースなし  | モデル権限、リソース ID、URL を確認。                  |
| 429        | レートまたは割り当て制限   | 応答本文でレート制限と残高不足を区別します。残高不足は再試行では解消しません。 |
| 500 / 503  | サービスエラー／一時利用不可 | リクエスト識別子を保持し、一時障害のみ回数制限付きでバックオフ。        |

OpenAI のネイティブエラーには通常 `error.message`、`error.type`、`error.param`、`error.code` が含まれます。`param`、`code` は `null` の場合があり、常に存在することや HTTP 状態との一致を仮定しないでください。ゲートウェイが提供元到達前に認証、ルート、残高エラーを返す場合もあります。arguments の解析失敗、未知関数、業務失敗はアプリ側エラーで、成功を偽装しません。HTTP 成功でもツール要求段階で、ユーザーのタスクが完了していない場合があります。

## 公式資料

* [OpenAI 関数呼び出し](https\://developers.openai.com/api/docs/guides/function-calling)
* [OpenAI Chat Completions](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI Responses](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI エラー処理](https\://developers.openai.com/api/docs/guides/error-codes)