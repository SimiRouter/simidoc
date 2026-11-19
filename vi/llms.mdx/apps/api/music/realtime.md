# Nhạc Lyria RealTime

Các trang dưới đây theo API chính thức của Google. SimiRouter chưa mở khả năng này; mọi ví dụ kết nối trực tiếp Gemini API của Google AI Studio qua `https://generativelanguage.googleapis.com` bằng khóa Google API. Vertex AI cần giao thức riêng chưa được kiểm chứng trong trang này; không chỉ thay địa chỉ để gọi.

## Tổng quan API

Kết nối `wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateMusic?key=$GEMINI_API_KEY` với mô hình `models/lyria-realtime-exp`. WebSocket hai chiều có trạng thái, không HTTP POST, SSE hay Lyria 3.5 Interactions.

## Tham số yêu cầu

Mỗi tin một sự kiện cấp cao nhất. Sau kết nối gửi setup, chờ setupComplete rồi gửi lời nhắc và điều khiển phát.

| Trường                                                        | Kiểu             | Bắt buộc | Mô tả                                                       |
| ------------------------------------------------------------- | ---------------- | -------- | ----------------------------------------------------------- |
| setup.model                                                   | string           | Có       | models/lyria-realtime-exp, chỉ gửi trong tin đầu kết nối.   |
| clientContent.weightedPrompts                                 | object\[]        | Có       | Ít nhất một text/weight, trọng số không được tất cả bằng 0. |
| musicGenerationConfig.bpm                                     | integer          | Không    | 60–200, thay đổi cần RESET\_CONTEXT hoặc phát lại.          |
| musicGenerationConfig.guidance                                | number           | Không    | 0–6, mặc định 4.                                            |
| musicGenerationConfig.density / brightness                    | number           | Không    | 0–1, mật độ nốt và độ sáng.                                 |
| musicGenerationConfig.temperature / topK                      | number / integer | Không    | 0–3 / 1–1000.                                               |
| musicGenerationConfig.seed                                    | integer          | Không    | Hạt giống ngẫu nhiên.                                       |
| musicGenerationConfig.scale                                   | string           | Không    | Enum Scale chính thức, đổi âm giai cần đặt lại ngữ cảnh.    |
| musicGenerationConfig.muteBass / muteDrums / onlyBassAndDrums | boolean          | Không    | Điều khiển bass/trống.                                      |
| musicGenerationConfig.musicGenerationMode                     | string           | Không    | QUALITY, DIVERSITY hoặc chế độ thử nghiệm hỗ trợ.           |
| playbackControl                                               | string           | Có       | PLAY, PAUSE, STOP, RESET\_CONTEXT.                          |

## Phản hồi

* `setupComplete`\: có thể gửi tin tiếp theo.
* `serverContent.audioChunks[].data`\: khối âm thanh Base64 trong JSON, giải rồi nối mẫu thô.
* `audioChunks[].mimeType`\: loại âm thanh, không mặc định MP3/WAV.
* `filteredPrompt`\: lý do lọc lời nhắc; `warning` là cảnh báo, không nhất thiết dừng.

Thông số cố định là PCM stereo 16-bit, 48 kHz; `audioChunks[].mimeType` cho biết loại âm thanh phản hồi và không thay đổi tốc độ lấy mẫu. Sinh có thể nhanh hơn phát, ứng dụng phải đệm, chống vỡ tiếng và tự phát. Ví dụ lưu `music.pcm`, không giả là WAV có đầu.

## Ví dụ mã

Đặt Google `GEMINI_API_KEY`. Python cần `websockets`, Node.js cần `ws`, Go cần `github.com/gorilla/websocket` . Ví dụ kết nối tối đa 30 giây, có thể tính phí suy luận; không tích hợp thiết bị mic/phát.

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

## Mã lỗi

HTTP bắt tay 400/401/403 chỉ lỗi địa chỉ, khóa, quyền, mô hình; 429 là hạn mức/tốc độ. Sau kết nối đọc error, filteredPrompt, warning và close code/reason WebSocket. 1000 đóng thường; mất kết nối không bảo đảm hủy tác vụ/phí. Kết nối lại cần setup, không mặc định trạng thái cũ còn.

## Tham khảo chính thức

[Nhạc Google thời gian thực](https\://ai.google.dev/gemini-api/docs/realtime-music-generation), [Live Music WebSocket API](https\://ai.google.dev/api/live_music).