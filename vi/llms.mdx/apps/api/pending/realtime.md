# OpenAI Realtime API

## Tổng quan API

Realtime cho tương tác chữ/giọng độ trễ thấp có trạng thái. Ứng dụng liên tục gửi sự kiện, máy chủ trả âm thanh, chữ, công cụ. Độc lập với [TTS](/simidoc/vi/apps/api/audio/speech), [chép tệp](/simidoc/vi/apps/api/audio/transcriptions) và [dịch tệp](/simidoc/vi/apps/api/audio/translations).

| Tình huống         | Kết nối chính thức                                                  | Xác thực                                                 |
| ------------------ | ------------------------------------------------------------------- | -------------------------------------------------------- |
| WebSocket máy chủ  | `wss://api.openai.com/v1/realtime?model=gpt-realtime-2.1`           | OpenAI API Key Bearer                                    |
| WebRTC trình duyệt | `/v1/realtime/calls`, tạo thông tin xác thực tạm trên máy chủ trước | client secret ngắn hạn, không để lộ khóa chuẩn           |
| Chép liên tục      | Cấu hình phiên Realtime transcription riêng                         | Dùng intent/config tương ứng, không như hội thoại thường |

Ví dụ trực tiếp OpenAI; WebSocket upgrade, truyền sự kiện và quyền SimiRouter cần kênh chuyên dụng. HTTP GET thường không chứng minh kết nối thời gian thực. GA không dùng cũ `OpenAI-Beta: realtime=v1`.

## Tham số yêu cầu

| Trường                       | Kiểu           | Bắt buộc     | Mô tả                                                                    |
| ---------------------------- | -------------- | ------------ | ------------------------------------------------------------------------ |
| model (query kết nối)        | string         | Có điều kiện | Mô hình tạo phiên, như gpt-realtime-2.1; vào call cũ dùng call\_id.      |
| call\_id (query kết nối)     | string         | Có điều kiện | Vào cuộc gọi đã có, khác tạo phiên mô hình mới.                          |
| session.type                 | string         | Có           | Cập nhật phiên dùng realtime, chép lời cấu hình riêng.                   |
| session.instructions         | string         | Không        | Chỉ dẫn phong cách và hành vi hệ thống.                                  |
| session.output\_modalities   | string\[]      | Không        | text hoặc audio theo phiên Realtime hiện tại.                            |
| session.audio                | object         | Không        | Định dạng vào/ra, giọng, phát hiện tiếng nói; phải khớp mã hóa thu/phát. |
| session.tools / tool\_choice | array / string | Không        | Định nghĩa/chọn công cụ; kiểm tra tham số trong nghiệp vụ.               |
| event\_id                    | string         | Không        | ID theo dõi ứng dụng để ghép lỗi.                                        |

### Sự kiện ứng dụng thường dùng

| Sự kiện                     | Mục đích                                                      |
| --------------------------- | ------------------------------------------------------------- |
| `session.update`            | Cập nhật phiên; chờ session.updated để đọc cấu hình thực.     |
| `conversation.item.create`  | Thêm chữ hoặc nội dung cho phép vào phiên.                    |
| `input_audio_buffer.append` | Khối âm thanh Base64, mã hóa khớp session.audio.input.format. |
| `input_audio_buffer.commit` | Gửi bộ đệm; chỉ gửi chưa tự tạo trả lời.                      |
| `input_audio_buffer.clear`  | Bỏ đầu vào chưa gửi.                                          |
| `response.create`           | Yêu cầu sinh trả lời.                                         |
| `response.cancel`           | Hủy trả lời đang sinh; bên phát còn phải xử lý âm thanh đệm.  |

Mic liên tục gửi khối theo tần số thực, VAD quyết định tự gửi/sinh. Ngắt còn phải xóa đệm phát hoặc cắt mục hội thoại theo giao thức, không chỉ tắt loa.

## Phản hồi

| Sự kiện máy chủ                          | Trường chính / ý nghĩa                                      |
| ---------------------------------------- | ----------------------------------------------------------- |
| `session.created` / `session.updated`    | ID phiên và cấu hình thực.                                  |
| `response.output_text.delta`             | Văn bản delta tăng dần.                                     |
| `response.output_audio.delta`            | delta là âm thanh Base64, phải giải mã.                     |
| `response.output_audio_transcript.delta` | Chữ tương ứng giọng, không thay âm thanh.                   |
| `response.done`                          | response.status và usage; chỉ completed là hoàn tất thường. |
| `error`                                  | error.type, code, message, event\_id và khác.               |

Realtime là sự kiện WebSocket hai chiều, không phải `data:` SSE. Ngắt kết nối hay âm thanh một phần không là thành công đầy đủ, không suy phí từ độ dài chữ.

## Ví dụ mã

Đặt chính thức `OPENAI_API_KEY`. Python cần `python3 -m pip install websockets`; Node.js cần `npm install ws`; Go cần `go get github.com/gorilla/websocket`. Dưới gửi một lượt \*\*văn bản \*\*để xác minh toàn luồng sự kiện, không tích hợp mic/loa; chờ tối đa 60 giây.

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

## Mã lỗi

Bắt tay HTTP 400/401/403/404/429 chẩn đoán tham số, xác thực, quyền, mô hình, hạn mức. Khi nối, xử lý error, trạng thái lỗi response.done, close code/reason. Ngắt bất thường/timeout báo chưa xong. Kết nối lại phải dựng trạng thái; không phát lại mù công cụ hoặc thao tác có tác dụng phụ.

## Tham khảo chính thức

[Realtime connect](https\://developers.openai.com/api/reference/python/resources/realtime/methods/connect), [Sự kiện ứng dụng](https\://developers.openai.com/api/reference/resources/realtime/client-events), [Sự kiện máy chủ](https\://developers.openai.com/api/reference/resources/realtime/server-events), [Hướng dẫn Realtime](https\://developers.openai.com/api/docs/guides/realtime).