# Trò chuyện và sinh nội dung

API trò chuyện đổi một cuộc hội thoại hoặc một chỉ dẫn thành đầu ra của mô hình. Nó có thể chỉ trả lời bằng văn bản, đọc được hình ảnh, âm thanh, tệp, hoặc gọi công cụ bên ngoài rồi tiếp tục trả lời. Giao thức quyết định hình dạng của yêu cầu và phản hồi; mô hình quyết định phương thức đầu vào khả dụng, độ dài ngữ cảnh và khả năng công cụ.

## Tổng quan

| Bạn muốn làm gì                                         | Lựa chọn                                  | Điểm chính                                       |
| ------------------------------------------------------- | ----------------------------------------- | ------------------------------------------------ |
| Hỏi đáp thông thường, viết, tóm tắt                     | [Chat Completions](/simidoc/vi/apps/api/chat/openai-chat)         | Phổ biến nhất, được client hỗ trợ rộng nhất      |
| Để mô hình tra cứu, gọi hàm, trả về dữ liệu có cấu trúc | [Responses](/simidoc/vi/apps/api/chat/openai-responses)           | Đầu vào và đầu ra có kiểu cùng công cụ tích hợp  |
| Di chuyển client Claude hiện có                         | [Claude Messages](/simidoc/vi/apps/api/chat/claude)               | Khối nội dung và giao thức công cụ của Anthropic |
| Di chuyển client Gemini hiện có                         | [Gemini generateContent](/simidoc/vi/apps/api/chat/gemini-text)   | Đầu vào đa phương thức dạng parts                |
| Duy trì tích hợp completions cũ                         | [Completions](/simidoc/vi/apps/api/chat/openai-completions)       | Chỉ prompt văn bản, đang bị loại bỏ dần          |
| Để mô hình xem ảnh, nghe âm thanh, xem video hoặc PDF   | [Hiểu phương tiện Gemini](/simidoc/vi/apps/api/chat/gemini-media) | Đầu vào là phương tiện, đầu ra vẫn là văn bản    |

Mọi giao thức dùng chung một cách xác thực gateway\: địa chỉ gốc `https://api.dwchainless.com`, tiêu đề yêu cầu `Authorization: Bearer $SIMIROUTER_API_KEY`. Đổi giao thức không cần đổi Key, nhưng khi đổi mô hình phải xác nhận mô hình mới hỗ trợ phương thức đầu vào và tham số bạn cần.

## Khái niệm cốt lõi

Hãy hiểu rõ vài thuật ngữ này trước, mọi tham số phía sau đều dựa trên chúng.

* **Token (đơn vị từ)**\: đơn vị tính phí nhỏ nhất cho văn bản mà mô hình đọc và ghi. Tiếng Anh khoảng 4 ký tự, tiếng Trung khoảng 1 đến 2 chữ được tính là 1 Token, cụ thể tùy theo tokenizer của mô hình. Token đầu vào và Token đầu ra được tính giá riêng.
* **Cửa sổ ngữ cảnh (context window)**\: tổng giới hạn Token của đầu vào cộng đầu ra trong một yêu cầu. Lịch sử càng dài thì không gian dành cho câu trả lời càng nhỏ; khi vượt giới hạn, yêu cầu có thể bị từ chối, hoặc bị cắt và trả về `finish_reason` là `length`.
* **Vai trò tin nhắn (role)**\: `system` hoặc `developer` đặt ranh giới hành vi, `user` là đầu vào của người dùng, `assistant` là đầu ra của mô hình, `tool` trả lại kết quả thực thi công cụ. Thứ tự vai trò chính là lịch sử hội thoại.
* **Không trạng thái**\: máy chủ không lưu cuộc hội thoại của bạn. Mỗi yêu cầu phải gửi lại lịch sử cần thiết, lịch sử càng dài chi phí càng cao.
* **Truyền luồng (streaming)**\: máy chủ dùng SSE trả về từng phần tăng dần, client vừa nhận vừa hiển thị. Nó giảm thời gian chờ ký tự đầu tiên, không thay đổi tổng thời gian và tổng chi phí, và cũng không phải tác vụ bất đồng bộ.
* **Gọi công cụ (tool calling)**\: mô hình không trực tiếp thực thi hàm mà trả về ý định gọi có cấu trúc; chương trình của bạn thực thi rồi gửi kết quả lại mô hình dưới dạng tin nhắn mới, mô hình tiếp tục trả lời.

## Thông số kỹ thuật và khả năng

| Chỉ số                  | Mô tả                                                                                                         |
| ----------------------- | ------------------------------------------------------------------------------------------------------------- |
| Phương thức đầu vào     | Văn bản; hình ảnh, âm thanh, PDF, video tùy thuộc mô hình                                                     |
| Phương thức đầu ra      | Văn bản; một số mô hình hỗ trợ JSON có cấu trúc hoặc hình ảnh                                                 |
| Độ dài ngữ cảnh         | Khác nhau theo mô hình, thường từ 8K đến 1M Token                                                             |
| Giới hạn đầu ra mỗi lần | Chat dùng `max_completion_tokens`, Responses dùng `max_output_tokens`, và chịu ràng buộc của giới hạn mô hình |
| Đồng thời               | Do hạn mức và giới hạn tốc độ kênh của bạn quyết định, không liên quan đến `n` và `parallel_tool_calls`       |
| Tính phí                | Tính riêng Token đầu vào và đầu ra; Token công cụ và suy luận có thể tính thêm                                |

Tham số không phải càng nhiều càng tốt\: `temperature`, `top_p`, `reasoning_effort` và các tham số lấy mẫu, suy luận khác được hỗ trợ ở mức độ khác nhau trên từng mô hình. Gateway chuyển tiếp chúng tới kênh; khi kênh không hỗ trợ, chúng có thể gây lỗi hoặc bị bỏ qua. Hãy gửi yêu cầu tối thiểu trước, rồi thêm từng tham số một.

## Quy trình gọi

1. **Chuẩn bị cấu hình**\: tạo khóa tại Quản lý khóa API, sao chép ID mô hình đầy đủ từ Mô hình và giá.
2. **Chọn giao diện**\: dùng Chat Completions cho tình huống thông thường; dùng Responses khi cần công cụ, đầu ra có cấu trúc hoặc chế độ nền; dùng giao thức gốc tương ứng khi di chuyển client.
3. **Gửi yêu cầu không truyền luồng trước**\: chỉ yêu cầu một câu trả lời, xác nhận xác thực, mô hình và tham số hợp lệ, rồi mới bật truyền luồng hoặc tích hợp công cụ.
4. **Đọc và nghiệm thu**\: kiểm tra trạng thái HTTP, `finish_reason`, thông tin từ chối và nội dung thực tế, sau đó đối chiếu nhật ký sử dụng và chi phí.

## Mô phỏng lệnh gọi

Dưới đây là một yêu cầu tối thiểu minh họa ba dạng\: thân yêu cầu, phản hồi đầy đủ và phản hồi truyền luồng. Các giá trị và nội dung đều là ví dụ, không phải phản hồi từ tài khoản thật.

**Yêu cầu**

```json
{
  "model": "gpt-5.5",
  "messages": [
    { "role": "system", "content": "You are a concise technical documentation assistant." },
    { "role": "user", "content": "Explain what a token is in three sentences." }
  ],
  "max_completion_tokens": 300,
  "stream": false
}
```

**Phản hồi đầy đủ (không truyền luồng)**

```json
{
  "id": "chatcmpl_demo_0001",
  "object": "chat.completion",
  "model": "gpt-5.5",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "A token is a small unit of text processed by the model. It is not always a word or character, because tokenizers split text into pieces. Input and output tokens are billed separately."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 42,
    "completion_tokens": 58,
    "total_tokens": 100
  }
}
```

**Phản hồi truyền luồng (`"stream": true`)**

Máy chủ đẩy từng phần tăng dần theo SSE, client nối lần lượt `delta.content` và kết thúc khi nhận được `[DONE]`\:

```text
data: {"choices":[{"index":0,"delta":{"role":"assistant"},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":"Token"},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":" is a small unit of text processed by the model."},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":" It is not always a word or character, because tokenizers split text into pieces. Input and output tokens are billed separately."},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

Tiêu chí thành công không phải là "đã nhận được dữ liệu", mà là\: trạng thái HTTP là 2xx, `finish_reason` cuối cùng hợp lý, văn bản sau khi nối đầy đủ. Khi luồng bị đứt giữa chừng, hãy kết thúc với nội dung đã nhận, đừng tự động gửi lại cùng một yêu cầu tính phí.

## Gọi công cụ

Gọi công cụ có hai loại, dùng lẫn lộn là nguồn lỗi phổ biến\:

* **Hàm phía client (function calling)**\: bạn khai báo chữ ký hàm, mô hình trả về ý định gọi, chương trình của bạn thực thi rồi gửi kết quả lại mô hình. Dữ liệu và thực thi đều ở phía bạn.
* **Công cụ phía máy chủ (server-side tools)**\: được thực thi trực tiếp ở phía mô hình, ví dụ tìm kiếm web tích hợp của Responses. Bạn chỉ thấy câu trả lời cuối cùng và trích dẫn, không thấy quá trình thu thập trung gian.

Một vòng khứ hồi đầy đủ của hàm phía client như sau\:

```text
1. Request: declare get_weather in tools and ask, "What is the weather in Paris today?"
2. Response: finish_reason = "tool_calls"
   tool_calls[0] = { id: "call_abc", function: { name: "get_weather", arguments: "{\"city\":\"Paris\"}" } }
3. Your program runs get_weather("Paris") and receives {"temp_c": 18}
4. Send another request with the assistant tool_calls message and role = "tool", tool_call_id = "call_abc", content = "{\"temp_c\": 18}"
5. Response: the model produces its final natural-language answer from the tool result
```

Điểm chính\: `arguments` là chuỗi JSON chứ không phải đối tượng; kết quả công cụ phải mang theo `tool_call_id` tương ứng; một lượt có thể có nhiều lệnh gọi công cụ, `parallel_tool_calls` kiểm soát việc có yêu cầu song song hay không. Gọi công cụ tiêu tốn thêm Token, thử lại sau lỗi cũng có thể bị tính phí lặp.

## Phương thức gọi

* **Đồng bộ không truyền luồng**\: kết nối được giữ đến khi sinh xong, nhận một lần toàn bộ JSON. Phù hợp với câu trả lời ngắn và xử lý lô phía máy chủ.
* **Truyền luồng**\: cùng một yêu cầu trả về sự kiện tăng dần qua SSE. Phải xử lý lý do kết thúc và việc đứt luồng giữa chừng.
* **Tác vụ nền bất đồng bộ**\: trước tiên lấy ID tác vụ hoặc phản hồi, rồi thu kết quả qua truy vấn hoặc Webhook. Responses gốc của OpenAI cung cấp quy trình background, nhưng gateway của trang này không có endpoint truy vấn và hủy tương ứng, nên không nên chỉ thêm tham số `background`.
* **Yêu cầu song song**\: client gửi đồng thời nhiều yêu cầu HTTP độc lập, xử lý riêng thành công, giới hạn tốc độ và chi phí. `n` là số ứng viên, `parallel_tool_calls` là nhiều lệnh gọi công cụ trong cùng một lượt; cả hai đều không tương đương với đồng thời HTTP.

## Kết nối và phiên

Các endpoint tin nhắn thông thường là không trạng thái, mỗi lần phải gửi kèm lịch sử cần thiết; ID phản hồi có trạng thái cũng chịu giới hạn định tuyến và lưu giữ dữ liệu phía thượng nguồn. Kết nối trực tiếp với nhà cung cấp phải đổi cả tên miền và thông tin xác thực, không thể chỉ thay tên mô hình.

## Tham khảo chính thức

* [Tạo văn bản OpenAI](https\://developers.openai.com/api/docs/guides/text)
* [Chế độ nền OpenAI](https\://developers.openai.com/api/docs/guides/background)
* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)