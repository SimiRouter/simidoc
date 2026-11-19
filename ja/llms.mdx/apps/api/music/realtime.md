# Lyria RealTime リアルタイム音楽

以下のページは Google 公式 API に沿って整理しています。SimiRouter はこの機能をまだ提供していないため、例はすべて Google AI Studio Gemini API に直接接続し、`https://generativelanguage.googleapis.com` と Google API キーを使用します。Vertex AI には別のプロトコルが必要で、このページでは検証していないため、アドレスだけを直接置き換えないでください。

## API の説明

接続先は `wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic?key=$GEMINI_API_KEY`、モデルは `models/lyria-realtime-exp` です。状態を持つ双方向 WebSocket であり、HTTP POST、SSE、Lyria 3.5 Interactions とは異なります。

## リクエストパラメータ

各メッセージに設定するトップレベルイベントは 1 種類だけです。接続後は最初に setup を送信し、setupComplete を待ってから音楽のプロンプトと再生制御を送信します。

| フィールド                                                         | 型                | 必須  | 説明                                          |
| ------------------------------------------------------------- | ---------------- | --- | ------------------------------------------- |
| setup.model                                                   | string           | はい  | models/lyria-realtime-exp。接続の最初のメッセージでのみ送信。 |
| clientContent.weightedPrompts                                 | object\[]        | はい  | 少なくとも 1 組の text/weight。重みをすべて 0 にはできません。    |
| musicGenerationConfig.bpm                                     | integer          | いいえ | 60–200。変更後は RESET\_CONTEXT または再生のやり直しが必要。   |
| musicGenerationConfig.guidance                                | number           | いいえ | 0–6。デフォルトは 4。                               |
| musicGenerationConfig.density / brightness                    | number           | いいえ | 0–1。音符密度と明るさ。                               |
| musicGenerationConfig.temperature / topK                      | number / integer | いいえ | 0–3 / 1–1000。                               |
| musicGenerationConfig.seed                                    | integer          | いいえ | 乱数シード。                                      |
| musicGenerationConfig.scale                                   | string           | いいえ | 公式 Scale 列挙値。調を変更する場合はコンテキストのリセットが必要。       |
| musicGenerationConfig.muteBass / muteDrums / onlyBassAndDrums | boolean          | いいえ | ベース／ドラムの制御。                                 |
| musicGenerationConfig.musicGenerationMode                     | string           | いいえ | QUALITY、DIVERSITY、または試験的に対応するモード。           |
| playbackControl                                               | string           | はい  | PLAY、PAUSE、STOP、RESET\_CONTEXT。             |

## 戻り値

* `setupComplete`：後続メッセージの送信を開始できます。
* `serverContent.audioChunks[].data`：JSON 内には Base64 の音声チャンクが含まれます。デコード後、生サンプルを連結します。
* `audioChunks[].mimeType`：音声の種類。MP3/WAV と決めつけないでください。
* `filteredPrompt`：プロンプトがフィルタリングされた理由。`warning` は警告であり、必ずしも終了を意味しません。

固定の技術仕様は 16-bit、48 kHz、ステレオ PCM です。`audioChunks[].mimeType` はレスポンス音声の種類を示すもので、サンプリングレートを変更しません。生成速度は再生速度を上回る場合があります。アプリケーション側でバッファリング、ノイズ防止、再生処理を実装する必要があります。以下のサンプル取得例は `music.pcm` を保存します。ヘッダー付き WAV として偽装しません。

## コード例

Google の `GEMINI_API_KEY` を設定します。Python は `websockets`、Node.js には `ws`、Go には `github.com/gorilla/websocket` が必要です。接続は最長 30 秒で、推論料金が発生する可能性があります。これらの例にはマイク／再生デバイスとの統合は含まれません。

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

## エラーコード

ハンドシェイクの HTTP 400/401/403 は、アドレス、Key、権限、モデルの問題を示します。429 は割り当て／レート制限です。接続後のエラーは error、filteredPrompt、warning、WebSocket の close code/reason で通知されます。1000 は正常終了です。異常切断時にタスクや課金が取り消される保証はありません。再接続時は setup をやり直し、以前のセッション状態が残っていると想定しないでください。

## 公式資料

[Google リアルタイム音楽](https\://ai.google.dev/gemini-api/docs/realtime-music-generation)、[Live Music WebSocket API](https\://ai.google.dev/api/live_music)。