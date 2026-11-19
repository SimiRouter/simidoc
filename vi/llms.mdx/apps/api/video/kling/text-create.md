# Kling chữ thành video

## Tổng quan API

`POST https://api-singapore.klingai.com/text-to-video/kling-3.0`, xác thực `Authorization: Bearer $KLING_API_KEY`, thân JSON. Ví dụ phiên bản mới Kling, không SimiRouter `/kling/v1/videos/...` ánh xạ cũ.

## Tham số yêu cầu

| Trường                          | Kiểu    | Bắt buộc | Mô tả                                                                      |
| ------------------------------- | ------- | -------- | -------------------------------------------------------------------------- |
| prompt                          | string  | Có       | Tối đa 3072 ký tự, khuyên dưới 2500; có mô tả dương/âm.                    |
| settings.resolution             | string  | Không    | 720p (mặc định), 1080p, 4k theo quyền mô hình.                             |
| settings.duration               | integer | Không    | Mặc định 5 giây; 3.0 hiện tham khảo 3–15 giây.                             |
| settings.audio                  | string  | Không    | off (mặc định) hoặc native tạo âm thanh gốc.                               |
| settings.multi\_shot            | boolean | Không    | Mặc định true; ví dụ false cho một cảnh.                                   |
| settings.aspect\_ratio          | string  | Không    | 16\:9 (mặc định), 9\:16, 1\:1.                                             |
| options.callback\_url           | string  | Không    | Callback trạng thái; tự xử lý nhận an toàn/idempotency.                    |
| options.external\_task\_id      | string  | Không    | ID tùy chỉnh duy nhất trong tài khoản để truy vấn, không thay ID hệ thống. |
| options.watermark\_info.enabled | boolean | Không    | Có thêm bản watermark không; không watermark tùy chỉnh.                    |

Không suy khả năng chỉ từ trường. Nhiều cảnh theo shot chính thức, tổng thời lượng cảnh bằng tổng. Khung đầu/cuối, số phần tử, định dạng theo mô hình hiện tại.

## Phản hồi

```json
{"code":0,"message":"Success","request_id":"request_example","data":{"id":"task_example","status":"submitted","create_time":1780000000000,"update_time":1780000000000}}
```

`data.id` là ID hệ thống truy vấn, `data.status` là submitted, processing, succeeded, failed; thời gian mili giây. Tạo chưa có video thành phẩm, không đọc cũ `data.task_id` hoặc `task_status`.

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

Đặt Kling chính thức `KLING_API_KEY`. Tạo tác vụ tính phí, sau đó xem [Truy vấn tác vụ](/simidoc/vi/apps/api/video/kling/text-status).

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api-singapore.klingai.com/text-to-video/kling-3.0'
    headers = {'Authorization': 'Bearer ' + os.environ['KLING_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'prompt': '日落时的海边灯塔，海浪缓缓拍岸，镜头平稳向前。', 'settings': {'resolution': '720p', 'duration': 5, 'audio': 'off', 'multi_shot': False, 'aspect_ratio': '16:9'}}, timeout=180)
    response.raise_for_status()
    result = response.json()
    if result.get("code") != 0:
        raise RuntimeError(result)
    print(result)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api-singapore.klingai.com/text-to-video/kling-3.0";
      const headers = { "Authorization": "Bearer " + process.env.KLING_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "prompt": "日落时的海边灯塔，海浪缓缓拍岸，镜头平稳向前。",
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false,
        "aspect_ratio": "16:9"
      }
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.code !== 0) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    response=$(mktemp)
    trap 'rm -f "$response"' EXIT
    curl "https://api-singapore.klingai.com/text-to-video/kling-3.0" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $KLING_API_KEY" \
      -H "Content-Type: application/json" \
      --output "$response" \
      -d '{
        "prompt": "日落时的海边灯塔，海浪缓缓拍岸，镜头平稳向前。",
        "settings": {
          "resolution": "720p",
          "duration": 5,
          "audio": "off",
          "multi_shot": false,
          "aspect_ratio": "16:9"
        }
      }'
    python3 - "$response" <<'PY_CHECK'
    import json, sys
    from pathlib import Path
    result = json.loads(Path(sys.argv[1]).read_text())
    if result.get("code") != 0:
        raise SystemExit(json.dumps(result, ensure_ascii=False))
    print(json.dumps(result, ensure_ascii=False))
    PY_CHECK
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "encoding/json"
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "prompt": "日落时的海边灯塔，海浪缓缓拍岸，镜头平稳向前。",
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false,
        "aspect_ratio": "16:9"
      }
    }`)
      req, err := http.NewRequest("POST", "https://api-singapore.klingai.com/text-to-video/kling-3.0", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("KLING_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      var result struct { Code int `json:"code"` }
      check(json.Unmarshal(data, &result))
      if result.Code != 0 { panic(string(data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## Mã lỗi

| HTTP / mã nghiệp vụ                | Mô tả                                           |
| ---------------------------------- | ----------------------------------------------- |
| 200 / 0                            | Yêu cầu thành công; video hoàn tất theo status. |
| 400 / 1201                         | Sai tham số, đọc message.                       |
| 404 / 1202, 1203                   | Sai phương thức hoặc thiếu mô hình/tài nguyên.  |
| 401                                | Khóa hoặc JWT cũ không hợp lệ.                  |
| 400 / 1300, 1301                   | Chính sách/an toàn, sửa nội dung không lặp mù.  |
| 429 / 1302, 1303, 1304             | Giới hạn tốc độ, đồng thời hoặc IP.             |
| 500 / 5000; 503 / 5001; 504 / 5002 | Lỗi/timeout, giữ request\_id.                   |

HTTP 200 không là nghiệp vụ thành công; kiểm code=0 rồi data.

## Tham khảo chính thức

[API Kling chính thức](https\://kling.ai/document-api/apiReference/model/textToVideo), [Xác thực](https\://kling.ai/document-api/api/get-started/authentication), [Mã lỗi](https\://kling.ai/document-api/api/get-started/error-codes).