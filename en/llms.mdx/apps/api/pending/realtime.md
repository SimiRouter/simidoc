# OpenAI Realtime API

## Endpoint overview

Realtime provides stateful, low-latency voice and text interaction. Clients continuously send events while the server produces audio, text, and tool-call events. It is separate from [TTS](/simidoc/en/apps/api/audio/speech), [file transcription](/simidoc/en/apps/api/audio/transcriptions) and [file translation](/simidoc/en/apps/api/audio/translations).

| Scenario                 | Official integration                                                   | Authentication                                                               |
| ------------------------ | ---------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| Server-side WebSocket    | `wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1`              | OpenAI API Key Bearer                                                        |
| Browser WebRTC           | `/v1/realtime/calls`; first create ephemeral credentials on the server | Short-lived client secret; never expose a standard key                       |
| Continuous transcription | Dedicated Realtime transcription session configuration                 | Use the corresponding intent/config; not equivalent to ordinary conversation |

Examples connect directly to OpenAI. SimiRouter WebSocket upgrades, event passthrough, and model permissions require a dedicated channel check. An ordinary HTTP GET response does not establish a successful realtime connection. The GA protocol does not use the old `OpenAI-Beta: realtime=v1`.

## Request parameters

| Field                        | Type           | Required    | Description                                                                                            |
| ---------------------------- | -------------- | ----------- | ------------------------------------------------------------------------------------------------------ |
| model (connection query)     | string         | Conditional | Model for creating a session, such as gpt-realtime-2.1; use call\_id to join an existing call.         |
| call\_id (connection query)  | string         | Conditional | Join an established call; do not confuse this with a model for creating a new session.                 |
| session.type                 | string         | Yes         | Use realtime for session updates; transcription requires separate configuration.                       |
| session.instructions         | string         | No          | System-level style and behavior instructions.                                                          |
| session.output\_modalities   | string\[]      | No          | text or audio, according to current Realtime session configuration.                                    |
| session.audio                | object         | No          | Input/output audio formats, voice, and voice-activity detection; must match capture/playback encoding. |
| session.tools / tool\_choice | array / string | No          | Tool definitions and selection; validate arguments in application logic.                               |
| event\_id                    | string         | No          | A client tracking ID for correlating error events.                                                     |

### Common client events

| Event                       | Purpose                                                                             |
| --------------------------- | ----------------------------------------------------------------------------------- |
| `session.update`            | Update session configuration; read session.updated for the actual settings.         |
| `conversation.item.create`  | Add text or other permitted content items to the session.                           |
| `input_audio_buffer.append` | Base64 audio chunks encoded to match session.audio.input.format.                    |
| `input_audio_buffer.commit` | Commit the buffer; committing alone does not automatically create a reply.          |
| `input_audio_buffer.clear`  | Discard uncommitted input.                                                          |
| `response.create`           | Request response generation.                                                        |
| `response.cancel`           | Cancel a response in progress; the playback client must also handle buffered audio. |

For a continuous microphone, stream chunks at the actual sample rate. VAD determines automatic commits/generation. Interruptions also require clearing playback buffers or truncating conversation items according to the official protocol; stopping the speaker alone is insufficient.

## Response

| Server events                            | Key fields / meaning                                                   |
| ---------------------------------------- | ---------------------------------------------------------------------- |
| `session.created` / `session.updated`    | Session identifier and actual configuration.                           |
| `response.output_text.delta`             | Incremental delta text.                                                |
| `response.output_audio.delta`            | delta is Base64 audio that must be decoded.                            |
| `response.output_audio_transcript.delta` | Text corresponding to speech; not a substitute for the audio.          |
| `response.done`                          | response.status and usage; only completed indicates normal completion. |
| `error`                                  | error.type, code, message, event\_id, and others.                      |

Realtime uses bidirectional WebSocket events, not `data:` SSE. A disconnect or partial audio is not complete success, and text length cannot determine final charges.

## Code examples

Set the official `OPENAI_API_KEY`. Python requires `python3 -m pip install websockets`; Node.js requires `npm install ws`; Go requires `go get github.com/gorilla/websocket`. The following sends one turn of **text** to verify the complete event flow, not microphone/speaker integration, with a 60-second maximum wait.

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

## Errors

During the handshake, HTTP 400/401/403/404/429 indicate parameter, authentication, permission, model, or quota issues. Once connected, handle error events, failure status in response.done, and WebSocket close codes/reasons. Report abnormal disconnects or timeouts as incomplete. Reestablish state after reconnecting; do not blindly replay tools or side-effecting operations already triggered.

## Official reference

[Realtime connect](https\://developers.openai.com/api/reference/python/resources/realtime/methods/connect), [Client events](https\://developers.openai.com/api/reference/resources/realtime/client-events), [Server events](https\://developers.openai.com/api/reference/resources/realtime/server-events), [Realtime guide](https\://developers.openai.com/api/docs/guides/realtime).