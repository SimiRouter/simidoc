# Kiểm duyệt nội dung

## Tổng quan API

`POST https://api.openai.com/v1/moderations` đánh giá phân loại an toàn đồng bộ bằng `Authorization: Bearer $OPENAI_API_KEY`. Tuyến, mô hình và quyền SimiRouter cần xác nhận riêng; ví dụ trực tiếp OpenAI.

Kết quả kiểm duyệt là tín hiệu rủi ro, không kết luận pháp lý hay bảo đảm không bỏ sót. Loại hỗ trợ ảnh/chữ có thể khác; xem category\_applied\_input\_types, không suy an toàn từ đầu vào chưa hỗ trợ.

## Tham số yêu cầu

| Trường                  | Kiểu                           | Bắt buộc     | Mô tả                                                                     |
| ----------------------- | ------------------------------ | ------------ | ------------------------------------------------------------------------- |
| model                   | string                         | Không        | Ví dụ omni-moderation-latest; cố định mô hình giảm ảnh hưởng đổi bí danh. |
| input                   | string / string\[] / object\[] | Có           | Văn bản hoặc mục đa phương thức.                                          |
| input\[].type           | string                         | Có điều kiện | text hoặc image\_url.                                                     |
| input\[].text           | string                         | Có điều kiện | Văn bản kiểm duyệt.                                                       |
| input\[].image\_url.url | string                         | Có điều kiện | URL ảnh/data URL đáp ứng mô hình.                                         |

## Phản hồi

| Trường                                   | Mô tả                                                                  |
| ---------------------------------------- | ---------------------------------------------------------------------- |
| `id` / `model`                           | ID yêu cầu và mô hình kiểm duyệt.                                      |
| `results[].flagged`                      | Có phân loại nào bị đánh dấu rủi ro không.                             |
| `results[].categories`                   | Giá trị boolean từng phân loại.                                        |
| `results[].category_scores`              | Điểm phân loại, không phán đoán người hay ngưỡng cố định giữa mô hình. |
| `results[].category_applied_input_types` | Loại đầu vào áp dụng từng phân loại.                                   |

```json
{"id":"modr_example","model":"omni-moderation-latest","results":[{"flagged":false,"categories":{},"category_scores":{},"category_applied_input_types":{}}]}
```

Ví dụ bỏ khóa phân loại, phản hồi thật có chi tiết. Giữ bằng chứng rủi ro cần thiết thay vì nguyên văn người dùng vô thời hạn.

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

Đặt `OPENAI_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/moderations'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'omni-moderation-latest', 'input': '这是一段需要进行安全审核的示例文本。'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/moderations";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
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
    curl "https://api.openai.com/v1/moderations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "omni-moderation-latest",
        "input": "这是一段需要进行安全审核的示例文本。"
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
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/moderations", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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

| Trạng thái HTTP       | Ý nghĩa và xử lý                                                                                              |
| --------------------- | ------------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Trường, định dạng tệp hoặc tham số không hợp lệ; sửa rồi gửi lại.                                             |
| 401                   | Khóa API thiếu, không hợp lệ hoặc hết hạn.                                                                    |
| 403                   | Không có quyền dự án hoặc mô hình.                                                                            |
| 404                   | Mô hình hoặc tuyến không tồn tại; kiểm tra địa chỉ và dự án sở hữu.                                           |
| 413 / 415             | Tệp quá lớn hoặc loại phương tiện không hỗ trợ.                                                               |
| 429                   | Giới hạn tốc độ/hạn mức; phân biệt thiếu số dư với giới hạn có thể thử lại.                                   |
| 500 / 502 / 503 / 504 | Lỗi dịch vụ/thượng nguồn. Giữ ID yêu cầu, kiểm tra nội dung phản hồi rồi mới quyết định có thử lại hay không. |

Trong lỗi, `error.message`, `error.type`, `error.code` nêu nguyên nhân cụ thể hơn HTTP. Không coi nội dung lỗi là kết quả kiểm duyệt.

## Tham khảo chính thức

[OpenAI Create moderation](https\://developers.openai.com/api/reference/resources/moderations/methods/create).