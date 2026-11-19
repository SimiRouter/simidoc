# OpenAI Realtime API

## 接口说明

Realtime 提供有状态、低延迟的语音与文字交互，客户端持续发送事件，服务端持续输出音频、文字和工具调用事件。它独立于 [TTS](/simidoc/zh/apps/api/audio/speech)、[文件转录](/simidoc/zh/apps/api/audio/transcriptions) 和 [文件翻译](/simidoc/zh/apps/api/audio/translations)。

| 场景            | 官方接入                                                      | 鉴权                          |
| ------------- | --------------------------------------------------------- | --------------------------- |
| 服务端 WebSocket | `wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1` | OpenAI API Key Bearer       |
| 浏览器 WebRTC    | `/v1/realtime/calls`，先在服务器创建临时凭证                          | 短期 client secret，不能暴露标准 Key |
| 持续转录          | Realtime transcription 专用会话配置                             | 使用对应 intent/config，不等同于普通对话 |

本页示例直连 OpenAI；SimiRouter 是否提供 WebSocket 升级、事件透传和模型权限需确认专用渠道。不能把普通 HTTP GET 结果当作实时连接成功。GA 协议不使用旧 `OpenAI-Beta: realtime=v1`。

## 请求参数

| 字段                           | 类型             | 必填 | 说明                                                 |
| ---------------------------- | -------------- | -- | -------------------------------------------------- |
| model（连接query）               | string         | 条件 | 创建会话的模型，例 gpt-realtime-2.1；加入既有 call 时使用 call\_id。 |
| call\_id（连接query）            | string         | 条件 | 加入已建立通话，不能与创建新会话模型混淆。                              |
| session.type                 | string         | 是  | 会话更新使用 realtime，转录使用独立配置。                          |
| session.instructions         | string         | 否  | 系统级风格与行为指令。                                        |
| session.output\_modalities   | string\[]      | 否  | text 或 audio，按当前 Realtime 会话配置。                    |
| session.audio                | object         | 否  | 输入/输出音频格式、声音与语音检测配置；必须匹配采集/播放编码。                   |
| session.tools / tool\_choice | array / string | 否  | 工具定义与选择；工具参数需在业务端校验。                               |
| event\_id                    | string         | 否  | 客户端追踪 ID，便于对应错误事件。                                 |

### 常用客户端事件

| 事件                          | 用途                                               |
| --------------------------- | ------------------------------------------------ |
| `session.update`            | 更新会话配置，等待 session.updated 读取实际配置。                |
| `conversation.item.create`  | 向会话添加文字或其他允许的内容项。                                |
| `input_audio_buffer.append` | 音频 Base64 块，编码必须与 session.audio.input.format 一致。 |
| `input_audio_buffer.commit` | 提交缓冲；只提交不等于自动创建回复。                               |
| `input_audio_buffer.clear`  | 丢弃未提交的输入。                                        |
| `response.create`           | 请求生成回复。                                          |
| `response.cancel`           | 取消正在生成的回复；播放端还需处理已缓冲音频。                          |

持续麦克风应按真实采样率分块送入，VAD 决定何时自动提交/生成。打断时还需按官方协议清理播放缓冲或截断会话项，不能只停止扬声器。

## 返回值

| 服务端事件                                    | 关键字段/意义                                      |
| ---------------------------------------- | -------------------------------------------- |
| `session.created` / `session.updated`    | 会话标识与实际配置。                                   |
| `response.output_text.delta`             | delta 文本增量。                                  |
| `response.output_audio.delta`            | delta 是 Base64 音频增量，需解码。                     |
| `response.output_audio_transcript.delta` | 语音对应文字，不代替音频本身。                              |
| `response.done`                          | response.status 与 usage；只有 completed 才是正常完成。 |
| `error`                                  | error.type、code、message、event\_id 等。         |

Realtime 是双向 WebSocket 事件，不是 `data:` SSE。断开连接或得到部分音频不能当作完整成功，也不能由文字长度推算最终计费。

## 代码调用

设置官方 `OPENAI_API_KEY`。Python 需 `python3 -m pip install websockets`；Node.js 需 `npm install ws`；Go 需 `go get github.com/gorilla/websocket`。以下发送一轮**文字**以验证完整事件流程，不是麦克风/扬声器集成，最多等待 60 秒。

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

## 错误码

握手阶段按 HTTP 400/401/403/404/429 判断参数、认证、权限、模型和配额。连接建立后必须处理 error 事件、response.done 中的失败状态与 WebSocket close code/reason。异常断连或超时需报告未完成；应用重连后重新建立状态，不能盲目重放已触发的工具或有副作用操作。

## 官方参考

[Realtime connect](https\://developers.openai.com/api/reference/python/resources/realtime/methods/connect)、[客户端事件](https\://developers.openai.com/api/reference/resources/realtime/client-events)、[服务端事件](https\://developers.openai.com/api/reference/resources/realtime/server-events)、[Realtime 指南](https\://developers.openai.com/api/docs/guides/realtime)。