# Hiểu video Kimi

## Tổng quan API

`kimi-k3` hỗ trợ video gốc cho tóm tắt, hỏi cảnh, sự kiện. Trả chữ, không sinh video hay hứa nhận từng khung/căn thời gian chính xác.

**Địa chỉ API**\: `POST https://api.moonshot.cn/v1/chat/completions`. Dùng khóa Moonshot Trung Quốc qua `Authorization: Bearer $MOONSHOT_API_KEY`. Quốc tế dùng `https://api.moonshot.ai` và khóa quốc tế; không trộn tài khoản/khóa hai nơi.

Ví dụ dùng **Moonshot chính thức trực tiếp**. Khả năng mô hình không chứng minh SimiRouter mở cùng mô hình, phương tiện, lưu trữ. Không chuyển `ms://` ID sang hãng/cổng khác.

* **Không luồng**\: `stream: false`, cùng HTTP chờ JSON đầy đủ.
* **Truyền luồng**\: `stream: true`, cùng kết nối SSE suy luận/chữ, không tạo video bất đồng bộ.
* **Tham chiếu tệp**\: tải tệp trước rồi chat dùng `ms://<file_id>`, tải không thay chat.

## Tham số yêu cầu

Loại nội dung là `application/json`.

| Trường                         | Kiểu                     | Bắt buộc     | Mô tả                                                                                        |
| ------------------------------ | ------------------------ | ------------ | -------------------------------------------------------------------------------------------- |
| `model`                        | string                   | Có           | Trang dùng `kimi-k3`, không tên hiển thị hay tên rút gọn.                                    |
| `messages`                     | array                    | Có           | Danh sách tin, user video dùng mảng.                                                         |
| `messages[].role`              | string                   | Có           | Video và câu hỏi trong `user`; có thể thêm chỉ dẫn `system`.                                 |
| `messages[].content`           | array                    | Có           | Gồm `video_url` mục video và `text` mục câu hỏi, không tuần tự mảng thành chuỗi.             |
| `content[].type`               | string                   | Có           | Video dùng `video_url`, chữ dùng `text`.                                                     |
| `content[].video_url.url`      | string                   | Có điều kiện | `data:video/mp4;base64,...` và data URL khớp MIME hoặc tham chiếu Moonshot `ms://<file_id>`. |
| `content[].text`               | string                   | Có điều kiện | Phân tích cần như tóm tắt, thứ tự sự kiện, hỏi khoảng thời gian.                             |
| `reasoning_effort`             | string                   | Không        | K3 luôn suy nghĩ, dùng cấp đầu `low`, `high` hoặc `max`, mặc định `max`.                     |
| `max_completion_tokens`        | integer                  | Không        | Giới hạn sinh đủ suy luận/đáp án cuối; chạm giới hạn thì `finish_reason` là `length`.        |
| `stream`                       | boolean                  | Không        | Mặc định `false`; `true` trả SSE.                                                            |
| `stream_options.include_usage` | boolean                  | Không        | Luồng lấy khối usage trước cuối.                                                             |
| `response_format`              | object                   | Không        | Đầu ra cấu trúc hỗ trợ, JSON theo JSON Mode/Schema chính thức.                               |
| `tools` / `tool_choice`        | array / string or object | Không        | Có công cụ, ví dụ video không bật.                                                           |

K3 không dùng công tắc của K2.x\: `thinking`. `temperature` luôn `1.0`, `top_p` luôn `0.95`, `n` luôn `1`, phạt lặp cố định `0`; nên bỏ trường, giá trị khác gây lỗi. `max_tokens` là tham số cũ, mới dùng `max_completion_tokens`.

### Giới hạn đầu vào video

Trang thị giác chính thức liệt kê MP4, MPEG, MOV, AVI, FLV, MPG, WebM, WMV, 3GPP; khuyên không quá 1080p. Thân theo giới hạn 100M; Base64 lớn hơn, không lấy dung lượng gốc làm JSON.

Ví dụ dùng bảo thủ hơn **giới hạn video máy 20 MiB**, là bảo vệ ví dụ không hứa trần mô hình/thời lượng. Lớn hoặc dùng lại nên tải chính thức. Không điền web, trang Xiaohongshu hay đường dẫn máy vào `video_url.url`; trang dùng Base64 và `ms://` đã xác nhận.

### Dùng video đã tải

Gọi Moonshot `POST /v1/files`, gửi multipart `file` và `purpose=video`, đọc trả về `id` rồi dùng `{"type":"video_url","video_url":{"url":"ms://<file_id>"}}` trong mục video. Không cần lấy văn bản trích tệp.

Tham khảo tải tệp tối đa 100 MiB; giao thức mới theo `kimi-api-version`, không áp header phiên bản tệp sang Chat Completions. Truy cập cùng nền tảng/tài khoản, xóa theo quy tắc lưu giữ khi xong.

## Phản hồi

HTTP 200 JSON không luồng theo Chat Completions.

| Trường                                | Kiểu    | Mô tả                                                                                             |
| ------------------------------------- | ------- | ------------------------------------------------------------------------------------------------- |
| `id`                                  | string  | ID lần bổ sung.                                                                                   |
| `object`                              | string  | Không luồng là `chat.completion`.                                                                 |
| `created`                             | integer | Thời gian tạo Unix giây.                                                                          |
| `model`                               | string  | ID mô hình phản hồi.                                                                              |
| `choices[].index`                     | integer | Vị trí ứng viên.                                                                                  |
| `choices[].message.role`              | string  | Tin assistant là `assistant`.                                                                     |
| `choices[].message.content`           | string  | Đáp án phân tích video cuối.                                                                      |
| `choices[].message.reasoning_content` | string  | Suy luận có thể trả, không đáp án cuối, không gộp với `content`.                                  |
| `choices[].finish_reason`             | string  | `stop` kết thúc thường; `length` chạm giới hạn sinh; `tool_calls` yêu cầu nghiệp vụ chạy công cụ. |
| `usage.prompt_tokens`                 | integer | Mức vào gồm video theo mô hình.                                                                   |
| `usage.completion_tokens`             | integer | Mức sinh.                                                                                         |
| `usage.total_tokens`                  | integer | Tổng, có thể thêm cache/suy luận.                                                                 |

ID, thời gian, mức dùng chỉ minh họa, không thực đo\:

```json
{
  "id": "chatcmpl_example",
  "object": "chat.completion",
  "created": 1793500000,
  "model": "kimi-k3",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "视频先展示产品外观，随后演示操作步骤，最后对比使用前后的结果。"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 1200,
    "completion_tokens": 300,
    "total_tokens": 1500
  }
}
```

### Phân tích luồng

Trong SSE `data:` JSON, `choices[].delta.reasoning_content` là suy luận tăng dần, `choices[].delta.content` là chữ đáp án; nối riêng, không ghi đè. Kiểm cuối `finish_reason` rồi chờ `data: [DONE]`. Bật usage thì khối thống kê có thể `choices: []`, đọc cấp đầu `usage`, không cố định truy cập `choices[0]`.

Nhiều lượt giữ toàn assistant gồm `reasoning_content`, gửi ngữ cảnh video/câu hỏi cần. Ngắt hoặc nhận `length` không là đáp án đủ.

## Ví dụ mã

Trước tiên đặt `MOONSHOT_API_KEY` và `VIDEO_FILE`; giá trị sau là video cục bộ thật có quyền tải. `VIDEO_MIME` tùy chọn, mặc định `video/mp4`, phải khớp tệp, ví dụ không chuyển tùy ý sang MP4. `MOONSHOT_BASE_URL` tùy chọn, mặc định `https://api.moonshot.cn`, gốc không có `/v1`, cho proxy có phép hoặc mock máy.

Python 3, Node.js 18+, Go dùng chuẩn; curl cần Python 3 mã/giải. Cả bốn giới hạn 20 MiB, có timeout, từ chối chưa đầy đủ, không tự thử lại tính phí.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import base64
    import json
    import os
    import urllib.error
    import urllib.request
    from pathlib import Path

    key = os.environ.get("MOONSHOT_API_KEY")
    filename = os.environ.get("VIDEO_FILE")
    if not key or not filename:
        raise SystemExit("请设置 MOONSHOT_API_KEY 和 VIDEO_FILE")
    path = Path(filename)
    if not path.is_file() or not 0 < path.stat().st_size <= 20 * 1024 * 1024:
        raise SystemExit("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件")
    mime = os.environ.get("VIDEO_MIME", "video/mp4")
    allowed = {"video/mp4", "video/mpeg", "video/mov", "video/avi", "video/x-flv",
               "video/mpg", "video/webm", "video/wmv", "video/3gpp"}
    if mime not in allowed:
        raise SystemExit("VIDEO_MIME 不在本页列出的格式范围内")
    video = base64.b64encode(path.read_bytes()).decode("ascii")
    body = {
        "model": "kimi-k3",
        "messages": [{"role": "user", "content": [
            {"type": "video_url", "video_url": {"url": f"data:{mime};base64,{video}"}},
            {"type": "text", "text": "概括视频内容，并按顺序列出关键事件。"},
        ]}],
        "reasoning_effort": "low",
        "max_completion_tokens": 4096,
        "stream": False,
    }
    base = os.environ.get("MOONSHOT_BASE_URL", "https://api.moonshot.cn").rstrip("/")
    request = urllib.request.Request(
        base + "/v1/chat/completions", data=json.dumps(body).encode("utf-8"),
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=300) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop":
        raise RuntimeError("视频分析未正常完成，请检查 finish_reason 与错误信息")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip():
        raise RuntimeError("响应没有最终文字答案")
    print(answer)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile, stat } = require("node:fs/promises");

    async function main() {
      const key = process.env.MOONSHOT_API_KEY;
      const filename = process.env.VIDEO_FILE;
      if (!key || !filename) throw new Error("请设置 MOONSHOT_API_KEY 和 VIDEO_FILE");
      const info = await stat(filename);
      if (!info.isFile() || info.size <= 0 || info.size > 20 * 1024 * 1024)
        throw new Error("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件");
      const mime = process.env.VIDEO_MIME || "video/mp4";
      const allowed = ["video/mp4", "video/mpeg", "video/mov", "video/avi", "video/x-flv",
        "video/mpg", "video/webm", "video/wmv", "video/3gpp"];
      if (!allowed.includes(mime)) throw new Error("不支持的 VIDEO_MIME");
      const video = (await readFile(filename)).toString("base64");
      const body = {
        model: "kimi-k3",
        messages: [{ role: "user", content: [
          { type: "video_url", video_url: { url: `data:${mime};base64,${video}` } },
          { type: "text", text: "概括视频内容，并按顺序列出关键事件。" },
        ] }],
        reasoning_effort: "low", max_completion_tokens: 4096, stream: false,
      };
      const base = (process.env.MOONSHOT_BASE_URL || "https://api.moonshot.cn").replace(/\/+$/, "");
      const response = await fetch(base + "/v1/chat/completions", {
        method: "POST",
        headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
        body: JSON.stringify(body), signal: AbortSignal.timeout(300000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      const choice = result.choices?.[0];
      if (choice?.finish_reason !== "stop") throw new Error("视频分析未正常完成");
      const answer = choice.message?.content;
      if (typeof answer !== "string" || !answer.trim()) throw new Error("响应没有最终文字答案");
      console.log(answer);
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${MOONSHOT_API_KEY:?请设置 MOONSHOT_API_KEY}"
    : "${VIDEO_FILE:?请设置 VIDEO_FILE}"
    base="${MOONSHOT_BASE_URL:-https://api.moonshot.cn}"
    request=$(mktemp)
    response=$(mktemp)
    trap 'rm -f "$request" "$response"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json, os
    from pathlib import Path
    path = Path(os.environ["VIDEO_FILE"])
    if not path.is_file() or not 0 < path.stat().st_size <= 20 * 1024 * 1024:
        raise SystemExit("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件")
    mime = os.environ.get("VIDEO_MIME", "video/mp4")
    allowed = {"video/mp4", "video/mpeg", "video/mov", "video/avi", "video/x-flv",
               "video/mpg", "video/webm", "video/wmv", "video/3gpp"}
    if mime not in allowed: raise SystemExit("不支持的 VIDEO_MIME")
    video = base64.b64encode(path.read_bytes()).decode("ascii")
    print(json.dumps({
        "model": "kimi-k3",
        "messages": [{"role": "user", "content": [
            {"type": "video_url", "video_url": {"url": f"data:{mime};base64,{video}"}},
            {"type": "text", "text": "概括视频内容，并按顺序列出关键事件。"},
        ]}],
        "reasoning_effort": "low", "max_completion_tokens": 4096, "stream": False,
    }, ensure_ascii=False))
    PY_BODY
    if curl --fail-with-body --connect-timeout 15 --max-time 300 \
      "${base%/}/v1/chat/completions" \
      -H "Authorization: Bearer $MOONSHOT_API_KEY" \
      -H "Content-Type: application/json" --data-binary "@$request" --output "$response"; then
      python3 - "$response" <<'PY_RESULT'
    import json, sys
    with open(sys.argv[1], encoding="utf-8") as source: result = json.load(source)
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop":
        raise RuntimeError("视频分析未正常完成")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip(): raise RuntimeError("响应没有最终文字答案")
    print(answer)
    PY_RESULT
    else
      status=$?
      cat "$response" >&2
      exit "$status"
    fi
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
        "bytes"
        "encoding/base64"
        "encoding/json"
        "fmt"
        "io"
        "net/http"
        "os"
        "strings"
        "time"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
        key, filename := os.Getenv("MOONSHOT_API_KEY"), os.Getenv("VIDEO_FILE")
        if key == "" || filename == "" { panic("请设置 MOONSHOT_API_KEY 和 VIDEO_FILE") }
        info, err := os.Stat(filename); check(err)
        if !info.Mode().IsRegular() || info.Size() <= 0 || info.Size() > 20*1024*1024 {
            panic("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件")
        }
        mime := os.Getenv("VIDEO_MIME"); if mime == "" { mime = "video/mp4" }
        allowed := map[string]bool{"video/mp4":true, "video/mpeg":true, "video/mov":true,
            "video/avi":true, "video/x-flv":true, "video/mpg":true, "video/webm":true,
            "video/wmv":true, "video/3gpp":true}
        if !allowed[mime] { panic("不支持的 VIDEO_MIME") }
        video, err := os.ReadFile(filename); check(err)
        body := map[string]any{
            "model":"kimi-k3",
            "messages":[]any{map[string]any{"role":"user", "content":[]any{
                map[string]any{"type":"video_url", "video_url":map[string]string{
                    "url":"data:"+mime+";base64,"+base64.StdEncoding.EncodeToString(video)}},
                map[string]string{"type":"text", "text":"概括视频内容，并按顺序列出关键事件。"},
            }}},
            "reasoning_effort":"low", "max_completion_tokens":4096, "stream":false,
        }
        payload, err := json.Marshal(body); check(err)
        base := os.Getenv("MOONSHOT_BASE_URL"); if base == "" { base = "https://api.moonshot.cn" }
        req, err := http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1/chat/completions", bytes.NewReader(payload)); check(err)
        req.Header.Set("Authorization","Bearer "+key); req.Header.Set("Content-Type","application/json")
        res, err := (&http.Client{Timeout:300*time.Second}).Do(req); check(err); defer res.Body.Close()
        raw, err := io.ReadAll(res.Body); check(err)
        if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw)) }
        var result struct { Choices []struct {
            Finish string `json:"finish_reason"`
            Message struct { Content string `json:"content"` } `json:"message"`
        } `json:"choices"` }
        check(json.Unmarshal(raw,&result))
        if len(result.Choices)==0 || result.Choices[0].Finish!="stop" { panic("视频分析未正常完成") }
        answer := result.Choices[0].Message.Content
        if strings.TrimSpace(answer)=="" { panic("响应没有最终文字答案") }
        fmt.Println(answer)
    }
    ```
  </Tab>
</Tabs>

## Mã lỗi

| Trạng thái HTTP       | Loại lỗi thường gặp                                                                   | Cách xử lý                                                                         |
| --------------------- | ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| 400                   | `invalid_request_error`, `content_filter`                                             | Kiểm mảng, Base64/MIME, kích thước, tham số cố định, ngữ cảnh; chỉnh theo an toàn. |
| 401                   | `invalid_authentication_error`, `incorrect_api_key_error`                             | Kiểm khóa đúng site, không trộn Trung Quốc, quốc tế, SimiRouter.                   |
| 403                   | `permission_denied_error`                                                             | Kiểm quyền mô hình, allowlist tổ chức, phạm vi mở.                                 |
| 404                   | `resource_not_found_error`                                                            | Kiểm ID mô hình/tệp và sở hữu.                                                     |
| 429                   | `engine_overloaded_error`, `exceeded_current_quota_error`, `rate_limit_reached_error` | Phân biệt dung lượng, số dư, tốc độ; thử lặp không giải thiếu hạn mức.             |
| 499 / 500 / 503 / 504 | `client_closed_request`, `server_error` và lỗi tương tự                               | Giữ ID, kiểm kết nối/dịch vụ; yêu cầu dài có thể SSE.                              |

Lỗi thường có `error.type` và `error.message`, vài phản hồi thêm `error.code`. Timeout không chứng minh chưa chạy; kiểm mức dùng trước thử, không ghi khóa hay Base64 video đầy đủ.

## Tham khảo chính thức

* [Kimi K3\: mô hình và ví dụ tệp video](https\://platform.kimi.com/docs/guide/kimi-k3-quickstart)
* [Kimi thị giác\: loại video và giới hạn](https\://platform.kimi.com/docs/guide/use-kimi-vision-model)
* [Kimi Chat Completions API\: video data URL, yêu cầu, phản hồi](https\://platform.kimi.com/docs/api/chat)
* [Tham khảo tham số Kimi](https\://platform.kimi.com/docs/api/models-overview)
* [Luồng Kimi](https\://platform.kimi.com/docs/guide/utilize-the-streaming-output-feature-of-kimi-api)
* [Tải tệp Moonshot](https\://platform.kimi.com/docs/api/files-upload)
* [Mã lỗi Kimi](https\://platform.kimi.com/docs/api/errors)