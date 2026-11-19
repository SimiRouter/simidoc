# Gọi công cụ

Gọi công cụ kết nối mô hình với dữ liệu, tính toán và dịch vụ bên ngoài. Mô hình chịu trách nhiệm chọn công cụ và tổ chức tham số, ứng dụng hoặc dịch vụ công cụ của hãng chịu trách nhiệm thực thi; giá trị trả về của công cụ và câu trả lời ngôn ngữ tự nhiên cuối cùng là hai giai đoạn khác nhau.

## Tổng quan

| Năng lực              | Ai thực thi          | Kết quả bạn thấy                          | Kịch bản điển hình                                  |
| --------------------- | -------------------- | ----------------------------------------- | --------------------------------------------------- |
| Hàm phía máy khách    | Chương trình của bạn | Ý định gọi + kết quả thực thi bạn gửi lại | Truy vấn cơ sở dữ liệu, gọi API nội bộ, trừ tồn kho |
| Tìm kiếm phía máy chủ | Hãng                 | Câu trả lời cuối cùng và nguồn trích dẫn  | Tra cứu thông tin mới nhất, xác minh sự thật        |

## Khái niệm cốt lõi

* **Định nghĩa công cụ**\: tên, mô tả mục đích và JSON Schema của tham số. Mô tả càng rõ ràng thì xác suất mô hình chọn sai công cụ hoặc bịa tham số càng thấp.
* **Ý định gọi**\: mô hình không thực thi mã, chỉ trả về `tool_calls`, trong đó `arguments` là chuỗi JSON. Trong phản hồi phát trực tuyến nó có thể đến thành nhiều mảnh, phải thu đủ rồi mới phân tích.
* **Thực thi và gửi lại**\: chương trình của bạn xác thực tham số, thực thi hàm, rồi gửi kết quả lại dưới dạng tin nhắn có `role` là `tool` và cùng `tool_call_id`, khi đó mô hình mới có thể tiếp tục.
* **Công cụ phía máy chủ**\: việc truy xuất do hãng thực hiện, bạn chỉ nhận câu trả lời và trích dẫn, không kiểm soát được quá trình trung gian và cũng không thể áp dụng cách dùng hàm phía máy khách vào đây.

## Mô phỏng cuộc gọi

Hình thức các trường của một yêu cầu hàm phía máy khách, phản hồi của mô hình và kết quả gửi lại như sau (nội dung chỉ mang tính minh họa)\:

```json
{
  "model": "gpt-5.5",
  "messages": [{ "role": "user", "content": "上海今天多少度？" }],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "查询指定城市的实时天气",
        "parameters": {
          "type": "object",
          "properties": { "city": { "type": "string" } },
          "required": ["city"]
        }
      }
    }
  ]
}
```

Mô hình trả về ý định gọi chứ không phải nhiệt độ\:

```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": null,
        "tool_calls": [
          {
            "id": "call_abc",
            "type": "function",
            "function": {
              "name": "get_weather",
              "arguments": "{\"city\":\"上海\"}"
            }
          }
        ]
      },
      "finish_reason": "tool_calls"
    }
  ]
}
```

Sau khi thực thi hàm, thêm kết quả làm tin nhắn mới và gửi yêu cầu lại\:

```json
{
  "role": "tool",
  "tool_call_id": "call_abc",
  "content": "{\"temp_c\": 18}"
}
```

Phản hồi thứ ba mới là câu trả lời ngôn ngữ tự nhiên dành cho người dùng. Trong toàn bộ chuỗi này, mô hình chưa từng thực sự truy cập dịch vụ thời tiết; chương trình của bạn mới là bên thực thi.

### Tìm kiếm phía máy chủ

Công cụ phía máy chủ chỉ cần một vòng\: bạn khai báo công cụ, nhà cung cấp thực hiện tìm kiếm, và một phản hồi chứa cả bản ghi tìm kiếm lẫn câu trả lời cuối cùng.

```json
{
  "model": "gpt-5.5",
  "input": "查找 OpenAI 官方文档中关于 Responses API 的说明，并提供来源链接。",
  "tools": [{ "type": "web_search" }],
  "stream": false
}
```

`output[]` trả về thường xuất hiện hành động tìm kiếm trước, sau đó là thông điệp cuối cùng kèm trích dẫn\:

```json
{
  "status": "completed",
  "output": [
    {
      "type": "web_search_call",
      "status": "completed",
      "action": { "type": "search", "query": "site:developers.openai.com Responses API" }
    },
    {
      "type": "message",
      "role": "assistant",
      "content": [
        {
          "type": "output_text",
          "text": "Responses API 用于生成模型响应……",
          "annotations": [
            {
              "type": "url_citation",
              "url": "https://developers.openai.com/api/docs/guides/text",
              "title": "OpenAI text generation"
            }
          ]
        }
      ]
    }
  ]
}
```

Câu trả lời chỉ dùng được khi `status` là `completed` và có `message`; chỉ thấy `web_search_call` nghĩa là giai đoạn tìm kiếm đã xong, không có nghĩa câu trả lời đã đầy đủ. Trích dẫn đến từ `annotations[]`, ứng dụng nên hiển thị nguyên văn, không tự viết lại URL nguồn.

## Loại công cụ

| Tài liệu                     | Yêu cầu                                                | Bên thực thi                                                                |
| ---------------------------- | ------------------------------------------------------ | --------------------------------------------------------------------------- |
| [Gọi hàm](/simidoc/vi/apps/api/tools/function-call)   | POST /v1/chat/completions; cũng có định dạng Responses | Ứng dụng định nghĩa JSON Schema, xác thực tham số và thực thi hàm của mình. |
| [Tìm kiếm web](/simidoc/vi/apps/api/tools/web-search) | POST /v1/responses + web\_search                       | Hãng thực hiện truy xuất, trả về nguồn trang web và trích dẫn.              |

## Đồng bộ, phát trực tuyến và song song

* **Đồng bộ**\: một yêu cầu trả về cuộc gọi công cụ đầy đủ hoặc câu trả lời cuối cùng; hàm tùy chỉnh thường cần ứng dụng thực thi rồi mới gửi lượt yêu cầu tiếp theo.
* **Phát trực tuyến**\: tên công cụ hoặc tham số xuất hiện thành từng mảnh, phải phân tích sau khi thu đủ tham số, không được thực thi JSON dở dang.
* **Bất đồng bộ**\: công cụ nghiệp vụ tốn thời gian có thể do ứng dụng tạo tác vụ nền, nhưng phải tự cung cấp trạng thái tác vụ và liên kết kết quả; khai báo tools không tự động tạo dịch vụ bất đồng bộ.
* **Song song**\: parallel\_tool\_calls cho phép mô hình đề xuất nhiều cuộc gọi hàm trong cùng một lượt; ứng dụng chỉ nên thực thi song song các thao tác đã được cấp quyền và độc lập với nhau. Nó không tự động nâng hạn mức giới hạn tốc độ, cũng không có nghĩa là nhiều yêu cầu HTTP.

## Ranh giới an toàn

Cố định danh sách trắng công cụ, xác thực kiểu và phạm vi nghiệp vụ, tách quyền đọc và quyền ghi. Các tác dụng phụ như gửi ra ngoài, thanh toán, xóa và thay đổi quyền cần có xác nhận và kiểm soát idempotent. Đầu ra của công cụ có thể chứa văn bản không đáng tin cậy, không được coi đó là chỉ thị hệ thống mới.

## Tham khảo chính thức

* [Gọi hàm OpenAI](https\://developers.openai.com/api/docs/guides/function-calling)
* [Tìm kiếm web OpenAI](https\://developers.openai.com/api/docs/guides/tools-web-search)