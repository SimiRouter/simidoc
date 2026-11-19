# Hiểu video Dots

## Tổng quan API

`dots3-note-prev` hỗ trợ video, ảnh và câu hỏi chung mảng nội dung. Giao thức video dùng `POST https://note3-prev-api.askdiandian.com/v1/chat/completions`, header dùng `api-key: $DOTS_API_KEY`, không Bearer.

Ví dụ trực tiếp **dịch vụ Dots chính thức**. Không Gemini `input/steps` hay tác vụ sinh video bất đồng bộ. Qua SimiRouter cần xác nhận truyền mở rộng video của mô hình/kênh, không chỉ đổi miền/khóa.

* `stream: false`\: chờ JSON đầy đủ, đáp án tại `choices[].message.content`.
* `stream: true`\: nhận chữ tăng dần SSE, xử lý video tăng thời gian token đầu; đủ timeout.
* Video phải URL tệp hãng đọc được. Ví dụ hãng không nêu Base64, `ms://`, tốc độ lấy khung, thời lượng tối đa hay dung lượng cố định; không coi đã hỗ trợ.

## Tham số yêu cầu

Thân là `application/json`.

| Trường                                 | Kiểu                     | Bắt buộc           | Mô tả                                                                       |
| -------------------------------------- | ------------------------ | ------------------ | --------------------------------------------------------------------------- |
| `model`                                | string                   | Có                 | Mô hình ví dụ chính thức `dots3-note-prev`.                                 |
| `messages`                             | array                    | Có                 | Gửi lịch sử đúng thứ tự.                                                    |
| `messages[].role`                      | string                   | Có                 | Video/câu hỏi đặt trong `user`; có thể thêm chỉ dẫn `system`.               |
| `messages[].content`                   | array                    | Có                 | Yêu cầu video dùng mảng, không chuỗi đã tuần tự.                            |
| `content[].type`                       | string                   | Có                 | `video_url` là video, `text` là câu hỏi, có thể thêm `image_url` ảnh.       |
| `content[].video_url.url`              | string                   | Bắt buộc mục video | URL tệp dịch vụ đọc được, không đường dẫn máy/trang chia sẻ.                |
| `content[].text`                       | string                   | Bắt buộc mục chữ   | Tác vụ phân tích cần.                                                       |
| `stream`                               | boolean                  | Không              | Ví dụ dùng `false`, `true`; nếu bật giá trị này, chuyển sang phân tích SSE. |
| `max_tokens`                           | integer                  | Không              | Giới hạn 4096 đầu ra ví dụ; tổng với đầu vào không quá 524288 ngữ cảnh.     |
| `chat_template_kwargs.enable_thinking` | boolean                  | Không              | Mặc định `true`; `false` tắt suy nghĩ sâu; ví dụ bật rõ.                    |
| `stop`                                 | string\[]                | Không              | Mảng chuỗi dừng, khớp thì dừng.                                             |
| `tools` / `tool_choice`                | array / string or object | Không              | Định nghĩa/chọn công cụ; ví dụ chỉ phân tích, không gọi.                    |

Dots tải link công khai. Dùng URL có quyền chia sẻ, URL ký đủ hạn không chứa đăng nhập. Trang Xiaohongshu chia sẻ không là link tệp trực tiếp.

## Phản hồi

HTTP 200 trả Chat JSON; nội dung, ID, mức dùng dưới chỉ cấu trúc, không đo thật.

| Trường                                           | Kiểu             | Mô tả                                                                                  |
| ------------------------------------------------ | ---------------- | -------------------------------------------------------------------------------------- |
| `id` / `object`                                  | string           | ID yêu cầu, không luồng `object` là `chat.completion`.                                 |
| `created` / `model`                              | integer / string | Thời gian Unix giây và mô hình phản hồi.                                               |
| `choices[].index`                                | integer          | Chỉ số ứng viên.                                                                       |
| `choices[].message.role`                         | string           | Tin assistant là `assistant`.                                                          |
| `choices[].message.content`                      | string           | Đáp án chữ cuối.                                                                       |
| `choices[].message.reasoning_content`            | string, tùy chọn | Suy luận khi bật, tách khỏi đáp án cuối.                                               |
| `choices[].finish_reason`                        | string           | `stop` kết thúc thường; `length` nghĩa bị cắt; `tool_calls` cần ứng dụng chạy công cụ. |
| `usage.prompt_tokens`                            | integer          | Token vào, video tính theo quy tắc đa phương thức dịch vụ.                             |
| `usage.completion_tokens` / `usage.total_tokens` | integer          | Mức sinh và tổng.                                                                      |
| `system_fingerprint`                             | string, tùy chọn | ID hệ thống máy chủ có thể chuỗi rỗng.                                                 |

```json
{
  "id": "dots_video_example",
  "object": "chat.completion",
  "created": 1793500000,
  "model": "dots3-note-prev",
  "choices": [{
    "index": 0,
    "message": {"role": "assistant", "content": "视频先展示室外场景，随后人物走入画面。"},
    "finish_reason": "stop"
  }],
  "usage": {"prompt_tokens": 1200, "completion_tokens": 100, "total_tokens": 1300}
}
```

Luồng dùng Chat delta, chữ đọc `choices[].delta.content`, suy nghĩ tích lũy riêng. Xử lý ranh SSE, trạng thái cuối, kết thúc; một lần đọc mạng không là một sự kiện. Đứt hoặc `length` không là đáp án đầy đủ.

## Ví dụ mã

Đặt `DOTS_API_KEY` và `VIDEO_URL`. `VIDEO_URL` phải HTTP(S) tệp dịch vụ đọc trực tiếp; bốn ví dụ không tải về máy trước. `DOTS_BASE_URL` tùy chọn, mặc định `https://note3-prev-api.askdiandian.com`, gốc không có `/v1`; chỉ đổi khi proxy gốc có phép/kiểm thử máy.

Python 3, Node.js 18+, Go chuẩn; curl cần Python 3 mã JSON/kiểm kết quả. Tối đa 300 giây, không tự thử lại. Chỉ xuất khi `finish_reason=stop` và đáp án không rỗng.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, urllib.error, urllib.parse, urllib.request
    key, video = os.environ.get("DOTS_API_KEY"), os.environ.get("VIDEO_URL")
    if not key or not video: raise SystemExit("请设置 DOTS_API_KEY 和 VIDEO_URL")
    url = urllib.parse.urlsplit(video)
    if url.scheme not in ("http", "https") or not url.hostname or url.username is not None or url.password is not None:
        raise SystemExit("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址")
    body = {"model": "dots3-note-prev", "messages": [{"role": "user", "content": [
        {"type": "video_url", "video_url": {"url": video}},
        {"type": "text", "text": "概括视频内容，并按顺序列出关键事件。"}
    ]}], "stream": False, "max_tokens": 4096, "chat_template_kwargs": {"enable_thinking": True}}
    base = os.environ.get("DOTS_BASE_URL", "https://note3-prev-api.askdiandian.com").rstrip("/")
    request = urllib.request.Request(base + "/v1/chat/completions", data=json.dumps(body).encode(),
        headers={"api-key": key, "Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=300) as response: result = json.load(response)
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop": raise RuntimeError("视频分析未正常完成")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip(): raise RuntimeError("响应没有最终文字答案")
    print(answer)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const key = process.env.DOTS_API_KEY, video = process.env.VIDEO_URL;
      if (!key || !video) throw new Error("请设置 DOTS_API_KEY 和 VIDEO_URL");
      const url = new URL(video);
      if (!["http:", "https:"].includes(url.protocol) || !url.hostname || url.username || url.password)
        throw new Error("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址");
      const body = {model:"dots3-note-prev",messages:[{role:"user",content:[
        {type:"video_url",video_url:{url:video}},
        {type:"text",text:"概括视频内容，并按顺序列出关键事件。"}
      ]}],stream:false,max_tokens:4096,chat_template_kwargs:{enable_thinking:true}};
      const base = (process.env.DOTS_BASE_URL || "https://note3-prev-api.askdiandian.com").replace(/\/$/, "");
      const response = await fetch(base + "/v1/chat/completions", {method:"POST",
        headers:{"api-key":key,"Content-Type":"application/json"},body:JSON.stringify(body),signal:AbortSignal.timeout(300000)});
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json(), choice = result.choices?.[0];
      if (choice?.finish_reason !== "stop") throw new Error("视频分析未正常完成");
      const answer = choice.message?.content;
      if (typeof answer !== "string" || !answer.trim()) throw new Error("响应没有最终文字答案");
      console.log(answer);
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${DOTS_API_KEY:?请设置 DOTS_API_KEY}"
    : "${VIDEO_URL:?请设置 VIDEO_URL}"
    request=$(mktemp)
    response=$(mktemp)
    trap 'rm -f "$request" "$response"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import json, os, urllib.parse
    video = os.environ["VIDEO_URL"]
    url = urllib.parse.urlsplit(video)
    if url.scheme not in ("http", "https") or not url.hostname or url.username is not None or url.password is not None:
        raise SystemExit("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址")
    print(json.dumps({"model":"dots3-note-prev","messages":[{"role":"user","content":[
        {"type":"video_url","video_url":{"url":video}},
        {"type":"text","text":"概括视频内容，并按顺序列出关键事件。"}
    ]}],"stream":False,"max_tokens":4096,"chat_template_kwargs":{"enable_thinking":True}}))
    PY_BODY
    base="${DOTS_BASE_URL:-https://note3-prev-api.askdiandian.com}"
    curl "${base%/}/v1/chat/completions" \
      --fail-with-body \
      --connect-timeout 20 \
      --max-time 300 \
      -H "api-key: $DOTS_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "@$request" \
      --output "$response"
    python3 - "$response" <<'PY_ANSWER'
    import json, sys
    with open(sys.argv[1]) as source: result = json.load(source)
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop": raise RuntimeError("视频分析未正常完成")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip(): raise RuntimeError("响应没有最终文字答案")
    print(answer)
    PY_ANSWER
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import ("bytes"; "encoding/json"; "fmt"; "io"; "net/http"; "net/url"; "os"; "strings"; "time")
    func check(err error) { if err != nil { panic(err) } }
    func main() {
     key,video:=os.Getenv("DOTS_API_KEY"),os.Getenv("VIDEO_URL")
     if key=="" || video=="" {panic("请设置 DOTS_API_KEY 和 VIDEO_URL")}
     parsed,err:=url.Parse(video);check(err)
     if (parsed.Scheme!="http" && parsed.Scheme!="https") || parsed.Hostname()=="" || parsed.User!=nil {panic("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址")}
     body:=map[string]any{"model":"dots3-note-prev","messages":[]any{map[string]any{"role":"user","content":[]any{
     map[string]any{"type":"video_url","video_url":map[string]string{"url":video}},
     map[string]string{"type":"text","text":"概括视频内容，并按顺序列出关键事件。"},
     }}},"stream":false,"max_tokens":4096,"chat_template_kwargs":map[string]bool{"enable_thinking":true}}
     data,err:=json.Marshal(body);check(err)
     base:=os.Getenv("DOTS_BASE_URL");if base=="" {base="https://note3-prev-api.askdiandian.com"}
     req,err:=http.NewRequest("POST",strings.TrimRight(base,"/")+"/v1/chat/completions",bytes.NewReader(data));check(err)
     req.Header.Set("api-key",key);req.Header.Set("Content-Type","application/json")
     res,err:=(&http.Client{Timeout:300*time.Second}).Do(req);check(err);defer res.Body.Close()
     raw,err:=io.ReadAll(res.Body);check(err)
     if res.StatusCode<200 || res.StatusCode>=300 {panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw))}
     var result struct {Choices []struct {Finish string `json:"finish_reason"`;Message struct {Content string `json:"content"`} `json:"message"`} `json:"choices"`}
     check(json.Unmarshal(raw,&result))
     if len(result.Choices)==0 || result.Choices[0].Finish!="stop" {panic("视频分析未正常完成")}
     answer:=result.Choices[0].Message.Content;if strings.TrimSpace(answer)=="" {panic("响应没有最终文字答案")};fmt.Println(answer)
    }
    ```
  </Tab>
</Tabs>

## Mã lỗi

| Trạng thái HTTP | Ý nghĩa chính thức          | Xử lý                                                   |
| --------------- | --------------------------- | ------------------------------------------------------- |
| 400             | Sai tham số/JSON            | Kiểm mảng đa phương thức, link video, mô hình, ngữ cảnh |
| 401             | Thiếu/khóa không hợp lệ     | Kiểm khóa Dots và `api-key` header                      |
| 403             | Khóa không quyền tài nguyên | Kiểm quyền nền tảng                                     |
| 429             | Quá nhiều yêu cầu           | Giảm đồng thời, lùi có giới hạn                         |
| 500             | Lỗi nội bộ                  | Giữ lỗi đã che nhạy cảm và ID, tránh vô hạn             |

HTTP 200 chưa chắc đầy đủ; kiểm `finish_reason` cùng đáp án chữ. URL hết hạn, tải/giải lỗi cần theo thân thật, không nhầm xác thực. Timeout máy không đảm bảo dịch vụ chưa chạy; tránh dùng trùng.

## Tham khảo chính thức

[Dots API\: đầu vào video](https\://dots.ai/platform/docs#video-input), [Tham số yêu cầu](https\://dots.ai/platform/docs#request-parameters), [Xác thực](https\://dots.ai/platform/docs#authentication) và [Trạng thái phản hồi](https\://dots.ai/platform/docs#error-codes).