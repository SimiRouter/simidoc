# Tạo tinh chỉnh

Gửi tập dữ liệu, mô hình nền để tạo tác vụ bất đồng bộ OpenAI.

**SimiRouter chưa hỗ trợ. Tham khảo OpenAI chính thức tại `api.openai.com`, cần khóa dự án OpenAI, không SimiRouter.**

OpenAI đang dừng tinh chỉnh tự phục vụ\: người dùng mới không thể tạo tác vụ, còn người dùng hiện hữu đủ điều kiện chỉ có thể tạo đến **ngày 6 tháng 1 năm 2027**, trừ khi mô hình nền ngừng sớm hơn. Hãy xem [lịch chính thức](https\://developers.openai.com/api/docs/deprecations) trước khi gửi.

## Tổng quan API

* **Phương thức**\: `POST`
* **Địa chỉ API**\: `/v1/fine_tuning/jobs`
* **Xác thực**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Loại yêu cầu**\: `application/json`.

Tạo trả đối tượng, huấn luyện chạy máy chủ sau đó. `200` hoặc `queued` không nghĩa là huấn luyện thành công; dùng [Lấy chi tiết tác vụ](/simidoc/vi/apps/api/pending/fine-tuning/retrieve) để xem cuối `status`, dùng [Lấy sự kiện](/simidoc/vi/apps/api/pending/fine-tuning/events) để xem tiến độ. Đường dẫn `/v1/fine_tuning/jobs`, không cũ `/v1/fine-tunes`.

## Tham số yêu cầu

| Tham số                             | Kiểu               | Bắt buộc | Mô tả                                                                                                         |
| ----------------------------------- | ------------------ | -------- | ------------------------------------------------------------------------------------------------------------- |
| `model`                             | string             | Có       | ID mô hình nền hỗ trợ phương pháp tương ứng.                                                                  |
| `training_file`                     | string             | Có       | với `purpose=fine-tune` là ID JSONL huấn luyện đã tải.                                                        |
| `validation_file`                   | string / null      | Không    | ID tệp kiểm định riêng, không trùng dữ liệu huấn luyện.                                                       |
| `method`                            | object             | Không    | `type` là `supervised`, `dpo` hoặc `reinforcement` và cấu hình cùng tên; phương pháp phải khớp mô hình.       |
| `method.supervised.hyperparameters` | object             | Không    | `batch_size`\: auto hoặc 1–256; `learning_rate_multiplier`\: auto hoặc số dương; `n_epochs`\: auto hoặc 1–50. |
| `method.dpo.hyperparameters`        | object             | Không    | Siêu tham số DPO gồm `beta`; không dùng nguyên định dạng giám sát.                                            |
| `method.reinforcement`              | object             | Không    | Cấu hình tinh chỉnh tăng cường gồm `grader` và siêu tham số phương pháp.                                      |
| `suffix`                            | string / null      | Không    | Hậu tố tên mô hình, tối đa 64 ký tự.                                                                          |
| `seed`                              | integer / null     | Không    | Hạt giống, giống nhau không bảo đảm lặp chính xác.                                                            |
| `metadata`                          | object / null      | Không    | Tối đa 16 cặp, khóa 64 ký tự, giá trị 512.                                                                    |
| `integrations`                      | array / null       | Không    | Tích hợp chỉ số ngoài, như `wandb` với tên dự án.                                                             |
| `hyperparameters`                   | object, đã bỏ dùng | Không    | Cách cấp đầu cũ; cấu hình mới đặt trong `method`.                                                             |

Mô hình và ID tệp ví dụ chỉ cấu trúc, lệnh thật dùng tài nguyên đúng dự án.

```json
{
  "model": "selected-base-model",
  "training_file": "file-training",
  "method": {
    "type": "supervised",
    "supervised": {
      "hyperparameters": {
        "n_epochs": 2
      }
    }
  }
}
```

## Phản hồi

| Trường             | Kiểu                     | Mô tả                                                                                                 |
| ------------------ | ------------------------ | ----------------------------------------------------------------------------------------------------- |
| `id` / `object`    | string                   | ID tác vụ, loại đối tượng luôn `fine_tuning.job`.                                                     |
| `model`            | string                   | Mô hình nền huấn luyện.                                                                               |
| `status`           | string                   | `validating_files`, `queued`, `running`, `pausing`, `paused`, `succeeded`, `failed` hoặc `cancelled`. |
| `created_at`       | integer                  | Thời gian tạo Unix giây.                                                                              |
| `finished_at`      | integer / null           | Thời gian xong, rỗng nếu chưa kết thúc.                                                               |
| `estimated_finish` | integer / null, tùy chọn | Ước tính xong, không bảo đảm.                                                                         |
| `fine_tuned_model` | string / null            | ID mô hình sinh ra, chưa có thì rỗng.                                                                 |
| `training_file`    | string                   | ID tệp huấn luyện.                                                                                    |
| `validation_file`  | string / null            | ID kiểm định, không đặt thì rỗng.                                                                     |
| `result_files`     | string\[]                | ID kết quả tải qua Files API chính thức.                                                              |
| `trained_tokens`   | integer / null           | Token huấn luyện tính phí, đang chạy có thể rỗng.                                                     |
| `error`            | object / null            | Chi tiết lỗi gồm `code`, `message`, `param`; lỗi không tham số có `param` có thể rỗng.                |
| `organization_id`  | string                   | Tổ chức sở hữu.                                                                                       |
| `seed`             | integer / null           | Hạt giống dùng lần huấn luyện.                                                                        |
| `method`           | object / null, tùy chọn  | Phương pháp tinh chỉnh và cấu hình.                                                                   |
| `hyperparameters`  | object / null, tùy chọn  | Trường tương thích siêu tham số giám sát.                                                             |
| `integrations`     | array / null, tùy chọn   | Tích hợp chỉ số ngoài đã bật.                                                                         |
| `metadata`         | object / null, tùy chọn  | Metadata khóa/giá trị tùy chỉnh.                                                                      |

Ví dụ trường chính, không tác vụ thật\:

```json
{
  "id": "ftjob-demo",
  "object": "fine_tuning.job",
  "model": "selected-base-model",
  "created_at": 1793491200,
  "finished_at": null,
  "fine_tuned_model": null,
  "status": "queued",
  "training_file": "file-training",
  "validation_file": null,
  "result_files": [],
  "trained_tokens": null,
  "error": null,
  "organization_id": "org-demo",
  "seed": null,
  "method": {
    "type": "supervised"
  },
  "metadata": {}
}
```

## Ví dụ mã

Yêu cầu Python 3, Node.js 20+, curl hoặc Go 1.20+. Lưu ví dụ thành `.py`, `.cjs`, `.sh`, `.go` rồi chạy.

Đặt `OPENAI_API_KEY`, `OPENAI_FINE_TUNING_MODEL` và `OPENAI_TRAINING_FILE_ID`. curl dùng Python 3 tạo JSON. Mô hình phải mở tinh chỉnh trong dự án. Huấn luyện tính phí, chỉ chạy khi rõ dữ liệu, cách, ngân sách; không tạo tác vụ thử kết nối.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    def required(name):
        value = os.environ.get(name)
        if not value:
            raise SystemExit(f"请设置 {name}")
        return value

    key = required("OPENAI_API_KEY")
    model = required("OPENAI_FINE_TUNING_MODEL")
    training_file = required("OPENAI_TRAINING_FILE_ID")
    payload = {"model": model, "training_file": training_file}
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        "https://api.openai.com/v1/fine_tuning/jobs",
        method="POST",
        data=data,
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = response.read()
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    print(json.dumps(json.loads(result), ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    function required(name) {
      const value = process.env[name];
      if (!value) throw new Error(`请设置 ${name}`);
      return value;
    }
    async function main() {
      const key = required("OPENAI_API_KEY");
      const model = required("OPENAI_FINE_TUNING_MODEL");
      const training_file = required("OPENAI_TRAINING_FILE_ID");
      const body = JSON.stringify({"model": model, "training_file": training_file});
      const response = await fetch("https://api.openai.com/v1/fine_tuning/jobs", {
        method: "POST",
        headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
        body,
        signal: AbortSignal.timeout(120000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(JSON.stringify(await response.json(), null, 2));
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${OPENAI_API_KEY:?请设置 OPENAI_API_KEY}"
    : "${OPENAI_FINE_TUNING_MODEL:?请设置 OPENAI_FINE_TUNING_MODEL}"
    : "${OPENAI_TRAINING_FILE_ID:?请设置 OPENAI_TRAINING_FILE_ID}"
    payload=$(python3 - <<'JSON'
    import json, os
    print(json.dumps({"model": os.environ["OPENAI_FINE_TUNING_MODEL"], "training_file": os.environ["OPENAI_TRAINING_FILE_ID"]}))
    JSON
    )

    curl "https://api.openai.com/v1/fine_tuning/jobs" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request POST \
      --header "Authorization: Bearer $OPENAI_API_KEY" \
      --header "Content-Type: application/json" \
      --data "$payload"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"bytes"
    	"encoding/json"
    	"fmt"
    	"io"
    	"log"
    	"net/http"
    	"os"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func required(name string) string {
    	value := os.Getenv(name)
    	if value == "" {
    		log.Fatal("请设置 " + name)
    	}
    	return value
    }
    func main() {
    	key := required("OPENAI_API_KEY")
    	model := required("OPENAI_FINE_TUNING_MODEL")
    	training_file := required("OPENAI_TRAINING_FILE_ID")
    	payload, err := json.Marshal(map[string]any{"model": model, "training_file": training_file})
    	check(err)
    	req, err := http.NewRequest("POST", "https://api.openai.com/v1/fine_tuning/jobs", bytes.NewReader(payload))
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	req.Header.Set("Content-Type", "application/json")
    	client := &http.Client{Timeout: 120 * time.Second}
    	response, err := client.Do(req)
    	check(err)
    	defer response.Body.Close()
    	result, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, result)
    	}
    	fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Mã lỗi

Lỗi HTTP thường của OpenAI trực tiếp, không là trạng thái hỗ trợ SimiRouter.

| Mã HTTP       | Ý nghĩa                                   | Cách xử lý                                                                       |
| ------------- | ----------------------------------------- | -------------------------------------------------------------------------------- |
| `400`         | Tham số, mục đích tệp hoặc trạng thái sai | Đọc `error.message` và `error.param`, sửa trước gửi lại.                         |
| `401`         | Khóa thiếu hoặc không hợp lệ              | Kiểm khóa OpenAI và dự án.                                                       |
| `403`         | Không quyền dự án/tài nguyên              | Kiểm dự án, tổ chức, vai trò.                                                    |
| `404`         | Tệp, tác vụ, mô hình không có             | Kiểm ID và dùng khóa dự án sở hữu.                                               |
| `429`         | Giới hạn tốc độ/thiếu hạn mức             | Phân biệt tốc độ và hạn mức; lùi khi tốc độ, không gửi lặp nếu thiếu hạn mức.    |
| `500` / `503` | Lỗi máy chủ/tạm không có                  | Giữ ID; trước lặp ghi, xem đã tạo tài nguyên chưa để tránh tải/huấn luyện trùng. |

Lỗi thường có `error.message`, `error.type`, `error.param` và `error.code` ; trường có thể rỗng.

## Tham khảo chính thức

* [OpenAI tạo tinh chỉnh](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/create)
* [Hướng dẫn tối ưu mô hình OpenAI](https\://developers.openai.com/api/docs/guides/model-optimization)
* [Mã lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)