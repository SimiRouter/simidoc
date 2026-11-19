# Lyria RealTime 实时音乐

以下页面按 Google 官方接口整理。SimiRouter 尚未开放该能力，示例均按 Google AI Studio Gemini API 直连，使用 `https://generativelanguage.googleapis.com` 与 Google API Key。Vertex AI 需要独立协议，本页未验证，不要直接替换地址调用。

## 接口说明

连接 `wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic?key=$GEMINI_API_KEY`，模型为 `models/lyria-realtime-exp`。它是有状态的双向 WebSocket，不是 HTTP POST、SSE 或 Lyria 3.5 Interactions。

## 请求参数

每条消息只设置一种顶层事件，连接后先发送 setup，并等待 setupComplete，再发送音乐提示和播放控制。

| 字段                                                            | 类型               | 必填 | 说明                                      |
| ------------------------------------------------------------- | ---------------- | -- | --------------------------------------- |
| setup.model                                                   | string           | 是  | models/lyria-realtime-exp，只在连接的第一条消息发送。 |
| clientContent.weightedPrompts                                 | object\[]        | 是  | 至少一个 text/weight，权重不能全为 0。              |
| musicGenerationConfig.bpm                                     | integer          | 否  | 60–200，改变后需 RESET\_CONTEXT 或重新播放。       |
| musicGenerationConfig.guidance                                | number           | 否  | 0–6，默认 4。                               |
| musicGenerationConfig.density / brightness                    | number           | 否  | 0–1，音符密度与亮度。                            |
| musicGenerationConfig.temperature / topK                      | number / integer | 否  | 0–3 / 1–1000。                           |
| musicGenerationConfig.seed                                    | integer          | 否  | 随机种子。                                   |
| musicGenerationConfig.scale                                   | string           | 否  | 官方 Scale 枚举，改变调式需重置上下文。                 |
| musicGenerationConfig.muteBass / muteDrums / onlyBassAndDrums | boolean          | 否  | 低音/鼓声控制。                                |
| musicGenerationConfig.musicGenerationMode                     | string           | 否  | QUALITY、DIVERSITY 或实验支持的模式。             |
| playbackControl                                               | string           | 是  | PLAY、PAUSE、STOP、RESET\_CONTEXT。         |

## 返回值

* `setupComplete`：可开始发送后续消息。
* `serverContent.audioChunks[].data`：JSON 中是 Base64 音频块；解码后拼接原始采样。
* `audioChunks[].mimeType`：音频类型；不要默认当 MP3/WAV。
* `filteredPrompt`：提示被过滤的原因；`warning` 是警告，不一定终止。

固定技术规格为 16-bit、48 kHz、立体声 PCM；`audioChunks[].mimeType` 用于识别响应音频类型，不能据此改变采样率。生成速度可快于播放速度，应用必须缓冲、防止爆音并自行处理播放。以下采样示例保存 `music.pcm`，不伪装成带头 WAV。

## 代码调用

设置 Google `GEMINI_API_KEY`。Python 需 `websockets`，Node.js 需 `ws`，Go 需 `github.com/gorilla/websocket`。示例最多连接 30 秒，可能发生推理计费；它们不提供麦克风/播放设备集成。

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

## 错误码

握手 HTTP 400/401/403 表示地址、Key、权限或模型问题；429 表示配额/限流。连接后的错误由 error、filteredPrompt、warning 和 WebSocket close code/reason 提供。1000 为正常关闭；异常断连不保证任务或计费已取消。重连需要重新 setup，不能把旧会话状态默认为仍在。

## 官方参考

[Google 实时音乐](https\://ai.google.dev/gemini-api/docs/realtime-music-generation)、[Live Music WebSocket API](https\://ai.google.dev/api/live_music)。