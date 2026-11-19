# Lyria RealTime 即時音樂

以下頁面依 Google 官方 API 整理。SimiRouter 尚未開放此能力，範例均直接連接 Google AI Studio Gemini API，使用 `https://generativelanguage.googleapis.com` 與 Google API 金鑰。Vertex AI 需要獨立通訊協定，本頁尚未驗證，請勿直接替換位址呼叫。

## 介面說明

連接 `wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic?key=$GEMINI_API_KEY`，模型為 `models/lyria-realtime-exp`。它是有狀態的雙向 WebSocket，不是 HTTP POST、SSE 或 Lyria 3.5 Interactions。

## 請求參數

每條訊息只設定一種頂層事件，連接後先傳送 setup，並等待 setupComplete，再傳送音樂提示和播放控制。

| 欄位                                                            | 型別               | 必填 | 說明                                      |
| ------------------------------------------------------------- | ---------------- | -- | --------------------------------------- |
| setup.model                                                   | string           | 是  | models/lyria-realtime-exp，只在連接的第一條訊息傳送。 |
| clientContent.weightedPrompts                                 | object\[]        | 是  | 至少一個 text/weight，權重不能全為 0。              |
| musicGenerationConfig.bpm                                     | integer          | 否  | 60–200，改變後需 RESET\_CONTEXT 或重新播放。       |
| musicGenerationConfig.guidance                                | number           | 否  | 0–6，預設 4。                               |
| musicGenerationConfig.density / brightness                    | number           | 否  | 0–1，音符密度與亮度。                            |
| musicGenerationConfig.temperature / topK                      | number / integer | 否  | 0–3 / 1–1000。                           |
| musicGenerationConfig.seed                                    | integer          | 否  | 隨機種子。                                   |
| musicGenerationConfig.scale                                   | string           | 否  | 官方 Scale 枚舉，改變調式需重置上下文。                 |
| musicGenerationConfig.muteBass / muteDrums / onlyBassAndDrums | boolean          | 否  | 低音/鼓聲控制。                                |
| musicGenerationConfig.musicGenerationMode                     | string           | 否  | QUALITY、DIVERSITY 或實驗支援的模式。             |
| playbackControl                                               | string           | 是  | PLAY、PAUSE、STOP、RESET\_CONTEXT。         |

## 回傳值

* `setupComplete`：可開始傳送後續訊息。
* `serverContent.audioChunks[].data`：JSON 中是 Base64 音訊塊；解碼後串接原始取樣。
* `audioChunks[].mimeType`：音訊型別；不要預設當 MP3/WAV。
* `filteredPrompt`：提示被過濾的原因；`warning` 是警告，不一定終止。

固定技術規格為 16-bit、48 kHz、立體聲 PCM；`audioChunks[].mimeType` 用於識別回應音訊類型，不會改變取樣率。生成速度可快於播放速度，應用必須緩衝、防止爆音並自行處理播放。以下取樣範例儲存 `music.pcm`，不偽裝成帶頭 WAV。

## 程式碼範例

設定 Google `GEMINI_API_KEY`。Python 需 `websockets`，Node.js 需 `ws`，Go 需 `github.com/gorilla/websocket`。範例最多連接 30 秒，可能發生推理計費；它們不提供麥克風/播放設備整合。

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

## 錯誤碼

握手 HTTP 400/401/403 表示位址、Key、權限或模型問題；429 表示配額/限流。連接後的錯誤由 error、filteredPrompt、warning 和 WebSocket close code/reason 提供。1000 為正常關閉；異常斷連不保證任務或計費已取消。重連需要重新 setup，不能把舊工作階段狀態預設為仍在。

## 官方參考

[Google 即時音樂](https\://ai.google.dev/gemini-api/docs/realtime-music-generation)、[Live Music WebSocket API](https\://ai.google.dev/api/live_music)。