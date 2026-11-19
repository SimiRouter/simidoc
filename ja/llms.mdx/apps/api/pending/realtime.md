# OpenAI Realtime API

## API の説明

Realtime は状態を持つ低遅延の音声・テキスト対話です。クライアントがイベントを送り続け、サーバーが音声、テキスト、ツールイベントを返します。次の機能とは独立しています：[TTS](/simidoc/ja/apps/api/audio/speech)、[ファイル文字起こし](/simidoc/ja/apps/api/audio/transcriptions) と [ファイル翻訳](/simidoc/ja/apps/api/audio/translations)。

| 用途              | 公式接続                                                      | 認証                                  |
| --------------- | --------------------------------------------------------- | ----------------------------------- |
| サーバー側 WebSocket | `wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1` | OpenAI API Key Bearer               |
| ブラウザー WebRTC    | `/v1/realtime/calls`。先にサーバーで一時認証情報を作成                     | 短期 client secret。標準 Key を公開しないでください |
| 継続文字起こし         | Realtime transcription 専用会話設定                             | 対応する intent/config を使用。通常会話とは別      |

例は OpenAI へ直接接続します。SimiRouter の WebSocket アップグレード、イベント透過、モデル権限は専用チャネルの確認が必要です。HTTP GET だけで接続成功と判断しないでください。GA は旧 `OpenAI-Beta: realtime=v1` ヘッダーを使用しません。

## リクエストパラメータ

| フィールド                        | 型              | 必須   | 説明                                                  |
| ---------------------------- | -------------- | ---- | --------------------------------------------------- |
| model（接続クエリ）                 | string         | 条件付き | 新規会話モデル。例：gpt-realtime-2.1。既存 call には call\_id を使用。 |
| call\_id（接続クエリ）              | string         | 条件付き | 確立済み通話に参加。新規作成モデルと混同しないでください。                       |
| session.type                 | string         | はい   | 会話更新は realtime、文字起こしは別設定。                           |
| session.instructions         | string         | いいえ  | システムレベルのスタイル・動作指示。                                  |
| session.output\_modalities   | string\[]      | いいえ  | text または audio。現在の Realtime 設定に従います。                |
| session.audio                | object         | いいえ  | 入出力音声形式、声、音声検出。収録・再生コーデックと一致が必要。                    |
| session.tools / tool\_choice | array / string | いいえ  | ツール定義と選択。引数は業務側で検証。                                 |
| event\_id                    | string         | いいえ  | エラー対応付け用クライアント追跡 ID。                                |

### 主なクライアントイベント

| イベント                        | 用途                                                |
| --------------------------- | ------------------------------------------------- |
| `session.update`            | 会話設定を更新し、session.updated で実設定を確認。                 |
| `conversation.item.create`  | 会話にテキストなど許可された内容を追加。                              |
| `input_audio_buffer.append` | 音声 Base64 チャンク。session.audio.input.format と一致が必要。 |
| `input_audio_buffer.commit` | バッファを確定。確定だけでは自動応答生成とは限りません。                      |
| `input_audio_buffer.clear`  | 未確定入力を破棄。                                         |
| `response.create`           | 応答生成を要求。                                          |
| `response.cancel`           | 生成中の応答をキャンセル。再生側はバッファ済み音声も処理。                     |

継続マイク入力は実際のサンプルレートで分割送信し、VAD が自動確定・生成を決めます。割り込み時は再生バッファの消去や会話項目の切り詰めも必要で、スピーカー停止だけでは不十分です。

## 戻り値

| サーバーイベント                                 | 主要フィールド／意味                                |
| ---------------------------------------- | ----------------------------------------- |
| `session.created` / `session.updated`    | 会話識別子と実際の設定。                              |
| `response.output_text.delta`             | delta はテキスト増分。                            |
| `response.output_audio.delta`            | delta は Base64 音声増分。デコードが必要。              |
| `response.output_audio_transcript.delta` | 音声に対応する文字。音声自体の代わりではありません。                |
| `response.done`                          | response.status と usage。completed のみ正常完了。 |
| `error`                                  | error.type、code、message、event\_id など。     |

Realtime は双方向 WebSocket イベントであり、`data:` SSE ではありません。切断や部分音声を完全成功とせず、文字数から最終料金を推測しないでください。

## コード例

公式の `OPENAI_API_KEY` を設定します。Python は `python3 -m pip install websockets`、Node.js は `npm install ws`、Go は `go get github.com/gorilla/websocket` が必要です。以下は 1 ターンの**テキスト**で完全なイベントフローを確認します。マイク・スピーカー連携ではなく、待機上限は 60 秒です。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import asyncio
    import json
    import os
    from websockets.asyncio.client import connect

    async def main():
        url = "wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1"
        async with connect(url, additional_headers={"Authorization":"Bearer " + os.environ["OPENAI_API_KEY"]}, open_timeout=20) as ws:
            await ws.send(json.dumps({"type":"session.update","session":{"type":"realtime","output_modalities":["text"]}}))
            await ws.send(json.dumps({"type":"conversation.item.create","item":{"type":"message","role":"user","content":[{"type":"input_text","text":"请用一句话介绍你自己。"}]}}))
            await ws.send(json.dumps({"type":"response.create"}))
            async for raw in ws:
                event = json.loads(raw)
                if event["type"] == "error":
                    raise RuntimeError(event["error"])
                if event["type"] == "response.output_text.delta":
                    print(event["delta"], end="", flush=True)
                if event["type"] == "response.done":
                    if event["response"]["status"] != "completed":
                        raise RuntimeError(event["response"])
                    print()
                    return
            raise RuntimeError("连接在 response.done 前关闭")
    asyncio.run(asyncio.wait_for(main(), 60))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const WebSocket = require("ws");
    const ws = new WebSocket("wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1", {
      headers:{Authorization:"Bearer " + process.env.OPENAI_API_KEY}
    });
    let completed = false;
    const timer = setTimeout(() => { console.error("会话超时"); process.exitCode=1; ws.terminate(); }, 60000);
    ws.on("open", () => {
      ws.send(JSON.stringify({type:"session.update",session:{type:"realtime",output_modalities:["text"]}}));
      ws.send(JSON.stringify({type:"conversation.item.create",item:{type:"message",role:"user",content:[{type:"input_text",text:"请用一句话介绍你自己。"}]}}));
      ws.send(JSON.stringify({type:"response.create"}));
    });
    ws.on("message", raw => {
      try {
        const event = JSON.parse(raw.toString());
        if(event.type === "error") throw new Error(JSON.stringify(event.error));
        if(event.type === "response.output_text.delta") process.stdout.write(event.delta);
        if(event.type === "response.done") {
          if(event.response.status !== "completed") throw new Error(JSON.stringify(event.response));
          completed = true; console.log(); ws.close();
        }
      } catch(error) { console.error(error); process.exitCode=1; ws.close(); }
    });
    ws.on("error", error => { console.error(error); process.exitCode=1; });
    ws.on("close", () => { clearTimeout(timer); if(!completed) {console.error("连接未正常完成"); process.exitCode=1;} });
    ```
  </Tab>

  <Tab value="curl">
    ```text
    cURL 单条 HTTP 命令不能完成双向实时语音会话。
    不要把 GET /v1/realtime 或 HTTP 101 握手当成完整调用。
    请使用本页 WebSocket 示例，浏览器使用官方 WebRTC 流程。
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import (
      "encoding/json"
      "fmt"
      "net/http"
      "os"
      "time"
      "github.com/gorilla/websocket"
    )
    func check(err error) {if err!=nil {panic(err)}}
    func main() {
      header:=http.Header{"Authorization":[]string{"Bearer "+os.Getenv("OPENAI_API_KEY")}}
      dialer:=websocket.Dialer{HandshakeTimeout:20*time.Second}
      ws,_,err:=dialer.Dial("wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1",header);check(err);defer ws.Close()
      check(ws.SetReadDeadline(time.Now().Add(60*time.Second)))
      check(ws.WriteJSON(map[string]any{"type":"session.update","session":map[string]any{"type":"realtime","output_modalities":[]string{"text"}}}))
      check(ws.WriteJSON(map[string]any{"type":"conversation.item.create","item":map[string]any{"type":"message","role":"user","content":[]any{map[string]any{"type":"input_text","text":"请用一句话介绍你自己。"}}}}))
      check(ws.WriteJSON(map[string]string{"type":"response.create"}))
      for {
        _,raw,err:=ws.ReadMessage();check(err)
        var event struct {Type string `json:"type"`;Delta string `json:"delta"`;Error json.RawMessage `json:"error"`;Response struct{Status string `json:"status"`} `json:"response"`}
        check(json.Unmarshal(raw,&event))
        switch event.Type {
        case "error":panic(string(event.Error))
        case "response.output_text.delta":fmt.Print(event.Delta)
        case "response.done":if event.Response.Status!="completed" {panic(event.Response.Status)};fmt.Println();return
        }
      }
    }
    ```
  </Tab>
</Tabs>

## エラーコード

ハンドシェイクでは HTTP 400/401/403/404/429 で引数、認証、権限、モデル、割り当てを判断します。接続後は error、response.done の失敗状態、WebSocket close code/reason を処理します。異常切断・タイムアウトは未完了を報告し、再接続時に状態を再構築します。実行済みツールや副作用のある操作を無条件に再送しないでください。

## 公式資料

[Realtime connect](https\://developers.openai.com/api/reference/python/resources/realtime/methods/connect)、[クライアントイベント](https\://developers.openai.com/api/reference/resources/realtime/client-events)、[サーバーイベント](https\://developers.openai.com/api/reference/resources/realtime/server-events)、[Realtime ガイド](https\://developers.openai.com/api/docs/guides/realtime)。