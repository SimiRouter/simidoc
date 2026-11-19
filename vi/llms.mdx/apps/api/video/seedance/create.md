# Tạo tác vụ Seedance

## Tổng quan API

`POST https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks`, `Authorization: Bearer $ARK_API_KEY`, thân JSON. Dưới giao thức hãng trực tiếp, **không phải** SimiRouter `/v1/video/generations` bảo đảm ánh xạ.

## Tham số yêu cầu

| Trường                    | Kiểu      | Bắt buộc     | Mô tả                                                                                                                                |
| ------------------------- | --------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| model                     | string    | Có           | ID mô hình Seedance/điểm suy luận đã mở.                                                                                             |
| content                   | object\[] | Có           | Chữ và mục ảnh/video/âm thanh mô hình hỗ trợ.                                                                                        |
| content\[].type           | string    | Có           | text, image\_url, video\_url, audio\_url, draft\_task theo khả năng.                                                                 |
| content\[].draft\_task.id | string    | Có điều kiện | ID tác vụ nháp khi type=draft\_task, dùng để tạo video chính thức từ bản nháp.                                                       |
| content\[].text           | string    | Có điều kiện | Lời nhắc type=text.                                                                                                                  |
| content\[].image\_url.url | string    | Có điều kiện | Ảnh truy cập được/data URL mô hình cho phép.                                                                                         |
| content\[].role           | string    | Không        | Như first\_frame, last\_frame, reference\_image theo mô hình/tài nguyên.                                                             |
| resolution                | string    | Không        | Độ phân giải theo mô hình\: 480p, 720p, 1080p hoặc 4k; bản nháp chỉ hỗ trợ 480p.                                                     |
| ratio                     | string    | Không        | Như 16\:9, 9\:16, 1\:1 hoặc adaptive, theo bảng khả năng.                                                                            |
| duration                  | integer   | Không        | Thời lượng tùy mô hình; -1 khi hỗ trợ tự chọn.                                                                                       |
| frames                    | integer   | Không        | Số khung khi hỗ trợ; nếu gửi cùng duration, frames được ưu tiên.                                                                     |
| generate\_audio           | boolean   | Không        | Có sinh âm thanh không, chỉ mô hình có tiếng.                                                                                        |
| watermark                 | boolean   | Không        | Watermark hiển thị theo yêu cầu gắn nhãn tổng hợp.                                                                                   |
| seed                      | integer   | Không        | Hạt giống không đảm bảo lặp từng pixel.                                                                                              |
| return\_last\_frame       | boolean   | Không        | Yêu cầu ảnh khung cuối.                                                                                                              |
| callback\_url             | string    | Không        | URL báo thay đổi trạng thái, nhận phải xử lý trùng/sai thứ tự.                                                                       |
| execution\_expires\_after | integer   | Không        | Hết hạn giây, mặc định 172800, 3600–259200.                                                                                          |
| service\_tier             | string    | Không        | default / flex theo mô hình.                                                                                                         |
| draft                     | boolean   | Không        | Tạo video nháp; mặc định false, mô hình hỗ trợ chỉ nhận 480p. Để tạo video chính thức từ bản nháp, dùng `content[].type=draft_task`. |
| priority                  | integer   | Không        | Ưu tiên hàng đợi theo mô hình/cấp dịch vụ, không mọi lệnh.                                                                           |

Ví dụ Seedance 2.5 chữ thuần, video ngắn. Chuyển 1.0 pro / 2.0 cần chỉnh trường theo bản; không mặc định tham chiếu đa phương thức, tiếng, nháp đều có.

## Phản hồi

Tạo thành công trả `id`, không video xong. Lưu ID rồi dùng [API truy vấn](/simidoc/vi/apps/api/video/seedance/status).

```json
{"id":"cgt-example"}
```

Timeout không chứng minh máy chủ chưa nhận; tránh gửi lại vô hạn. Callback cập nhật idempotent theo ID.

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

Đặt chính thức `ARK_API_KEY`; tạo tác vụ có thể tính phí.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks'
    headers = {'Authorization': 'Bearer ' + os.environ['ARK_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'doubao-seedance-2-5-260628', 'content': [{'type': 'text', 'text': '海边日落时，一艘白色帆船缓缓驶过，镜头平稳。'}], 'duration': 5, 'ratio': '16:9', 'generate_audio': True, 'watermark': True}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks";
      const headers = { "Authorization": "Bearer " + process.env.ARK_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $ARK_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "doubao-seedance-2-5-260628",
        "content": [
          {
            "type": "text",
            "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
          }
        ],
        "duration": 5,
        "ratio": "16:9",
        "generate_audio": true,
        "watermark": true
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
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
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
    }`)
      req, err := http.NewRequest("POST", "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("ARK_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## Mã lỗi

| Trạng thái HTTP       | Ý nghĩa và xử lý                                                                                            |
| --------------------- | ----------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Trường, định dạng tệp hoặc tham số không hợp lệ; sửa rồi gửi lại.                                           |
| 401                   | Khóa API thiếu, không hợp lệ hoặc hết hạn.                                                                  |
| 403                   | Không có quyền dự án hoặc mô hình.                                                                          |
| 404                   | Mô hình, tuyến hoặc tác vụ không tồn tại; kiểm tra địa chỉ và sở hữu tài nguyên.                            |
| 413 / 415             | Tệp quá lớn hoặc loại phương tiện không hỗ trợ.                                                             |
| 429                   | Giới hạn tốc độ/hạn mức; phân biệt thiếu số dư với giới hạn có thể thử lại.                                 |
| 500 / 502 / 503 / 504 | Lỗi dịch vụ/thượng nguồn. Giữ ID yêu cầu; nếu tạo tác vụ hết hạn, kiểm tra đã nhận chưa để tránh tạo trùng. |

Lỗi Volcengine dùng `error.code`, `error.message`, giữ ID. Lỗi sinh cần đọc truy vấn, HTTP tạo không chứng minh cuối thành công.

Lỗi Volcengine dùng `error.code`, `error.message` và ID; lỗi sinh còn đọc error truy vấn.

## Tham khảo chính thức

[Ark tạo tác vụ](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh), [Hướng dẫn gọi chính thức](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh).