# Lyria RealTime music

The pages below follow the official Google API. SimiRouter has not yet opened this capability, so all examples connect directly to the Google AI Studio Gemini API using `https://generativelanguage.googleapis.com` and a Google API key. Vertex AI requires a separate protocol that is not verified on this page; do not substitute its address directly.

## Endpoint overview

Connect to `wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic?key=$GEMINI_API_KEY` with model `models/lyria-realtime-exp`. This is a stateful bidirectional WebSocket, not HTTP POST, SSE, or Lyria 3.5 Interactions.

## Request parameters

Set only one top-level event per message. After connecting, send setup and wait for setupComplete before sending music prompts and playback controls.

| Field                                                         | Type             | Required | Description                                                             |
| ------------------------------------------------------------- | ---------------- | -------- | ----------------------------------------------------------------------- |
| setup.model                                                   | string           | Yes      | models/lyria-realtime-exp; send only in the connection’s first message. |
| clientContent.weightedPrompts                                 | object\[]        | Yes      | At least one text/weight pair; weights cannot all be zero.              |
| musicGenerationConfig.bpm                                     | integer          | No       | 60–200; changes require RESET\_CONTEXT or restarting playback.          |
| musicGenerationConfig.guidance                                | number           | No       | 0–6; default 4.                                                         |
| musicGenerationConfig.density / brightness                    | number           | No       | 0–1; note density and brightness.                                       |
| musicGenerationConfig.temperature / topK                      | number / integer | No       | 0–3 / 1–1000.                                                           |
| musicGenerationConfig.seed                                    | integer          | No       | Random seed.                                                            |
| musicGenerationConfig.scale                                   | string           | No       | An official Scale enum; changing scale requires resetting context.      |
| musicGenerationConfig.muteBass / muteDrums / onlyBassAndDrums | boolean          | No       | Bass/drum controls.                                                     |
| musicGenerationConfig.musicGenerationMode                     | string           | No       | QUALITY, DIVERSITY, or an experimentally supported mode.                |
| playbackControl                                               | string           | Yes      | PLAY, PAUSE, STOP, RESET\_CONTEXT.                                      |

## Response

* `setupComplete`\: subsequent messages can now be sent.
* `serverContent.audioChunks[].data`\: Base64 audio chunks in JSON; decode and concatenate raw samples.
* `audioChunks[].mimeType`\: the audio type; do not assume MP3/WAV.
* `filteredPrompt`\: why a prompt was filtered; `warning` is a warning and does not necessarily terminate the session.

The fixed specification is 16-bit, 48 kHz, stereo PCM; `audioChunks[].mimeType` identifies the response audio type and does not change the sample rate. Generation can be faster than playback, so applications must buffer, prevent clipping, and implement playback. The sample below saves `music.pcm` without pretending it is a WAV file with a header.

## Code examples

Set Google `GEMINI_API_KEY`. Python requires `websockets`, Node.js requires `ws`, and Go requires `github.com/gorilla/websocket`. Examples connect for at most 30 seconds and may incur inference charges; they do not integrate microphone or playback devices.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import asyncio
    import base64
    import json
    import os
    from pathlib import Path
    from websockets.asyncio.client import connect

    received_chunks = 0

    async def main():
        global received_chunks
        if not os.environ.get("GEMINI_API_KEY"):
            raise RuntimeError("请设置 GEMINI_API_KEY")
        if Path("music.pcm").exists():
            raise RuntimeError("music.pcm 已存在，请先选择新的输出文件名")
        url = "wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic?key=" + os.environ["GEMINI_API_KEY"]
        async with connect(url, open_timeout=20, max_size=None) as ws:
            await ws.send(json.dumps({"setup":{"model":"models/lyria-realtime-exp"}}))
            while True:
                event = json.loads(await ws.recv())
                if "error" in event:
                    raise RuntimeError(event["error"])
                if "setupComplete" in event:
                    break
            await ws.send(json.dumps({"clientContent":{"weightedPrompts":[{"text":"minimal techno","weight":1.0}]}}))
            await ws.send(json.dumps({"musicGenerationConfig":{"bpm":90}}))
            await ws.send(json.dumps({"playbackControl":"PLAY"}))
            with Path("music.pcm").open("xb") as output:
                while True:
                    event = json.loads(await ws.recv())
                    if "error" in event:
                        raise RuntimeError(event["error"])
                    if "filteredPrompt" in event:
                        raise RuntimeError(event["filteredPrompt"])
                    for chunk in event.get("serverContent",{}).get("audioChunks",[]):
                        print("MIME:", chunk.get("mimeType"))
                        decoded = base64.b64decode(chunk["data"], validate=True)
                        if decoded:
                            output.write(decoded)
                            received_chunks += 1

    try:
        asyncio.run(asyncio.wait_for(main(), 30))
    except TimeoutError:
        if received_chunks == 0:
            raise RuntimeError("采样窗口内未收到音频，会话未成功")
        print(f"30 秒采样结束，已保存 {received_chunks} 个音频块；这不是模型自然终态。")
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const WebSocket = require("ws");
    const { createWriteStream, existsSync } = require("node:fs");
    if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
    if (existsSync("music.pcm")) throw new Error("music.pcm 已存在，请先选择新的输出文件名");
    const output = createWriteStream("music.pcm", {flags:"wx"});
    let receivedChunks = 0;
    const ws = new WebSocket("wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic?key=" + process.env.GEMINI_API_KEY);
    let ready = false;
    const timer = setTimeout(() => { ws.close(); output.end(); }, 30000);
    ws.on("open", () => ws.send(JSON.stringify({setup:{model:"models/lyria-realtime-exp"}})));
    ws.on("message", raw => {
      try {
        const event = JSON.parse(raw.toString());
        if (event.error || event.filteredPrompt) throw new Error(JSON.stringify(event.error || event.filteredPrompt));
        if (event.setupComplete && !ready) {
          ready = true;
          ws.send(JSON.stringify({clientContent:{weightedPrompts:[{text:"minimal techno",weight:1}]}}));
          ws.send(JSON.stringify({musicGenerationConfig:{bpm:90}}));
          ws.send(JSON.stringify({playbackControl:"PLAY"}));
        }
        for (const chunk of event.serverContent?.audioChunks || []) {
          console.log("MIME:", chunk.mimeType);
          const data = Buffer.from(chunk.data,"base64");
          if (data.length) { output.write(data); receivedChunks++; }
        }
      } catch (error) { console.error(error); process.exitCode=1; ws.close(); }
    });
    ws.on("error", error => { console.error(error); process.exitCode=1; });
    ws.on("close", () => {
      clearTimeout(timer); output.end();
      if (!receivedChunks) { console.error("会话关闭前未收到音频"); process.exitCode=1; }
    });
    output.on("error", error => { console.error(error); process.exitCode=1; ws.close(); });
    ```
  </Tab>

  <Tab value="curl">
    ```text
    cURL 命令行不能完成持续的双向 WebSocket 音乐会话。
    请使用本页 Python、Node.js 或 Go 示例，不要用普通 POST 伪造音乐流。
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import (
      "encoding/base64"
      "encoding/json"
      "fmt"
      "net/url"
      "os"
      "time"
      "github.com/gorilla/websocket"
    )
    func check(err error) { if err!=nil {panic(err)} }
    func main() {
      if os.Getenv("GEMINI_API_KEY")=="" {panic("请设置 GEMINI_API_KEY")}
      endpoint := "wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic?key="+url.QueryEscape(os.Getenv("GEMINI_API_KEY"))
      dialer:=websocket.Dialer{HandshakeTimeout:20*time.Second}
      ws,_,err:=dialer.Dial(endpoint,nil);check(err);defer ws.Close()
      check(ws.SetReadDeadline(time.Now().Add(30*time.Second)))
      check(ws.WriteJSON(map[string]any{"setup":map[string]string{"model":"models/lyria-realtime-exp"}}))
      file,err:=os.OpenFile("music.pcm",os.O_CREATE|os.O_EXCL|os.O_WRONLY,0600);check(err);defer file.Close()
      receivedChunks:=0
      ready:=false
      for {
        _,raw,err:=ws.ReadMessage(); if err!=nil {
          if networkErr,ok:=err.(interface{Timeout()bool});ok&&networkErr.Timeout()&&receivedChunks>0 {fmt.Println("采样窗口结束，已收到音频块",receivedChunks);return};panic(err)
        }
        var event map[string]json.RawMessage;check(json.Unmarshal(raw,&event))
        if value,ok:=event["error"];ok {panic(string(value))}
        if value,ok:=event["filteredPrompt"];ok {panic(string(value))}
        if _,ok:=event["setupComplete"];ok&&!ready {
          ready=true
          check(ws.WriteJSON(map[string]any{"clientContent":map[string]any{"weightedPrompts":[]any{map[string]any{"text":"minimal techno","weight":1}}}}))
          check(ws.WriteJSON(map[string]any{"musicGenerationConfig":map[string]any{"bpm":90}}))
          check(ws.WriteJSON(map[string]any{"playbackControl":"PLAY"}))
        }
        if value,ok:=event["serverContent"];ok {
          var content struct {AudioChunks []struct {Data string `json:"data"`; MIME string `json:"mimeType"`} `json:"audioChunks"`}
          check(json.Unmarshal(value,&content))
          for _,chunk:=range content.AudioChunks {data,err:=base64.StdEncoding.DecodeString(chunk.Data);check(err);_,err=file.Write(data);check(err);if len(data)>0 {receivedChunks++};fmt.Println(chunk.MIME)}
        }
      }
    }
    ```
  </Tab>
</Tabs>

## Errors

Handshake HTTP 400/401/403 indicates URL, key, permission, or model issues; 429 indicates quota/rate limits. After connection, errors appear in error, filteredPrompt, warning, and WebSocket close codes/reasons. 1000 is a normal close; an abnormal disconnect does not guarantee cancellation or billing cessation. Reconnecting requires setup again; do not assume the previous session remains.

## Official reference

[Google realtime music](https\://ai.google.dev/gemini-api/docs/realtime-music-generation), [Live Music WebSocket API](https\://ai.google.dev/api/live_music).