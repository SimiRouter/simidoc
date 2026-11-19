# OpenAI Realtime API

## 介面說明

Realtime 提供有狀態、低延遲的語音與文字互動，用戶端持續傳送事件，伺服器端持續輸出音訊、文字和工具呼叫事件。它獨立於 [TTS](/simidoc/zh-Hant/apps/api/audio/speech)、[檔案轉錄](/simidoc/zh-Hant/apps/api/audio/transcriptions) 和 [檔案翻譯](/simidoc/zh-Hant/apps/api/audio/translations)。

| 場景             | 官方串接                                                      | 身分驗證                        |
| -------------- | --------------------------------------------------------- | --------------------------- |
| 伺服器端 WebSocket | `wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1` | OpenAI API Key Bearer       |
| 瀏覽器 WebRTC     | `/v1/realtime/calls`，先在伺服器建立臨時憑證                          | 短期 client secret，不能暴露標準 Key |
| 持續轉錄           | Realtime transcription 專用工作階段設定                           | 使用對應 intent/config，不等同於普通對話 |

本頁範例直連 OpenAI；SimiRouter 是否提供 WebSocket 升級、事件透傳和模型權限需確認專用管道。不能把普通 HTTP GET 結果當作即時連接成功。GA 通訊協定不使用舊 `OpenAI-Beta: realtime=v1`。

## 請求參數

| 欄位                           | 型別             | 必填 | 說明                                                   |
| ---------------------------- | -------------- | -- | ---------------------------------------------------- |
| model（連接query）               | string         | 條件 | 建立工作階段的模型，例 gpt-realtime-2.1；加入既有 call 時使用 call\_id。 |
| call\_id（連接query）            | string         | 條件 | 加入已建立通話，不能與建立新工作階段模型混淆。                              |
| session.type                 | string         | 是  | 工作階段更新使用 realtime，轉錄使用獨立設定。                          |
| session.instructions         | string         | 否  | 系統級風格與行為指令。                                          |
| session.output\_modalities   | string\[]      | 否  | text 或 audio，按目前 Realtime 工作階段設定。                    |
| session.audio                | object         | 否  | 輸入/輸出音訊格式、聲音與語音偵測設定；必須匹配採集/播放編碼。                     |
| session.tools / tool\_choice | array / string | 否  | 工具定義與選擇；工具參數需在業務端驗證。                                 |
| event\_id                    | string         | 否  | 用戶端追蹤 ID，便於對應錯誤事件。                                   |

### 常用用戶端事件

| 事件                          | 用途                                               |
| --------------------------- | ------------------------------------------------ |
| `session.update`            | 更新工作階段設定，等待 session.updated 讀取實際設定。              |
| `conversation.item.create`  | 向工作階段新增文字或其他允許的內容項。                              |
| `input_audio_buffer.append` | 音訊 Base64 塊，編碼必須與 session.audio.input.format 一致。 |
| `input_audio_buffer.commit` | 提交緩衝；只提交不等於自動建立回覆。                               |
| `input_audio_buffer.clear`  | 丟棄未提交的輸入。                                        |
| `response.create`           | 請求生成回覆。                                          |
| `response.cancel`           | 取消正在生成的回覆；播放端還需處理已緩衝音訊。                          |

持續麥克風應按真實取樣率分塊送入，VAD 決定何時自動提交/生成。打斷時還需按官方通訊協定清理播放緩衝或截斷工作階段項，不能只停止揚聲器。

## 回傳值

| 伺服器端事件                                   | 關鍵欄位/意義                                      |
| ---------------------------------------- | -------------------------------------------- |
| `session.created` / `session.updated`    | 工作階段識別碼與實際設定。                                |
| `response.output_text.delta`             | delta 文字增量。                                  |
| `response.output_audio.delta`            | delta 是 Base64 音訊增量，需解碼。                     |
| `response.output_audio_transcript.delta` | 語音對應文字，不代替音訊本身。                              |
| `response.done`                          | response.status 與 usage；只有 completed 才是正常完成。 |
| `error`                                  | error.type、code、message、event\_id 等。         |

Realtime 是雙向 WebSocket 事件，不是 `data:` SSE。斷開連接或得到部分音訊不能當作完整成功，也不能由文字長度推算最終計費。

## 程式碼範例

設定官方 `OPENAI_API_KEY`。Python 需 `python3 -m pip install websockets`；Node.js 需 `npm install ws`；Go 需 `go get github.com/gorilla/websocket`。以下傳送一輪**文字**以驗證完整事件流程，不是麥克風/揚聲器整合，最多等待 60 秒。

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

## 錯誤碼

握手階段按 HTTP 400/401/403/404/429 判斷參數、驗證、權限、模型和配額。連接建立後必須處理 error 事件、response.done 中的失敗狀態與 WebSocket close code/reason。異常斷連或逾時需報告未完成；應用重連後重新建立狀態，不能盲目重放已觸發的工具或有副作用操作。

## 官方參考

[Realtime connect](https\://developers.openai.com/api/reference/python/resources/realtime/methods/connect)、[用戶端事件](https\://developers.openai.com/api/reference/resources/realtime/client-events)、[伺服器端事件](https\://developers.openai.com/api/reference/resources/realtime/server-events)、[Realtime 指南](https\://developers.openai.com/api/docs/guides/realtime)。