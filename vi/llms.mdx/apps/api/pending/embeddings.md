# Nhúng (không hỗ trợ)

**SimiRouter chưa hỗ trợ API nhúng.** Mục giải thích giao thức hãng; ví dụ cần tài khoản, khóa tương ứng kết nối trực tiếp.

## Tổng quan

Nhúng ánh xạ văn bản hoặc các đầu vào khác mà mô hình cho phép thành vector có độ dài cố định, dùng cho truy xuất ngữ nghĩa, phân cụm và phân tích độ tương đồng. Nó không trả về câu trả lời trò chuyện và cũng không trực tiếp thực hiện tìm kiếm; quy trình truy xuất thường gồm ba đoạn "nhúng để thu hồi ứng viên + xếp hạng lại để tinh xếp + mô hình sinh câu trả lời". Chi tiết điểm cuối xem tại [Nhúng OpenAI](/simidoc/vi/apps/api/pending/embeddings/openai) và [Nhúng Gemini](/simidoc/vi/apps/api/pending/embeddings/gemini).

| Việc bạn cần làm                            | Đầu vào                                   | Đầu ra                                    | Điểm cuối                                                                       |
| ------------------------------------------- | ----------------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------- |
| Tạo vector văn bản                          | Một hoặc nhiều đoạn văn bản               | Mảng số thực có độ dài cố định            | OpenAI `POST /v1/embeddings`; Google `POST /v1beta/models/{model}:embedContent` |
| Tạo vector cho hình ảnh và phương tiện khác | Nội dung đa phương thức mà mô hình hỗ trợ | Mảng số thực trong cùng không gian vector | Chỉ các mô hình hỗ trợ đa phương thức như `gemini-embedding-2`                  |
| Lập chỉ mục hàng loạt                       | Nhiều đoạn văn bản                        | Danh sách vector căn theo thứ tự đầu vào  | `batchEmbedContents` hoặc Batch API, tác vụ lô bất đồng bộ tách riêng           |

## Khái niệm cốt lõi

* **Chiều**\: OpenAI `text-embedding-3-small` mặc định 1536 chiều, `text-embedding-3-large` mặc định 3072 chiều; Gemini Embedding 2 hỗ trợ 128–3072 chiều (khuyến nghị 768, 1536 hoặc 3072), còn `gemini-embedding-001` mặc định 3072 chiều. Có thể giảm trong phạm vi mô hình nhưng không vượt giới hạn; cả hai hãng đều gắn trực tiếp chi phí lưu trữ và truy xuất của cơ sở dữ liệu vector vào số chiều.
* **Chuẩn hóa và độ tương đồng**\: OpenAI trả về vector có độ dài 1, tích vô hướng chính là độ tương đồng cosine; Gemini cần chuẩn hóa lại khi không phải 3072 chiều (`gemini-embedding-2` xử lý tự động, `gemini-embedding-001` cần thủ công). Cơ sở dữ liệu vector phải cố định một cách đo.
* **Chỉ mục và truy vấn phải đồng cấu**\: cùng một lô tài liệu và truy vấn phải dùng cùng mô hình, cùng chiều, cùng cấu hình tác vụ. Sau khi đổi mô hình hoặc đổi số chiều, chỉ mục cũ và vector mới không thể so sánh, cần xây dựng lại.
* **`index` không phải xếp hạng**\: `index` trong phản hồi chỉ cho biết vector tương ứng với đầu vào thứ mấy, dùng để căn với văn bản gốc; sắp xếp mức liên quan là nhiệm vụ của xếp hạng lại, xem [Xếp hạng lại](/simidoc/vi/apps/api/pending/rerank).
* **Đồng bộ và hàng loạt**\: nhúng là yêu cầu đồng bộ, không có SSE; lô lớn dùng Batch API hoặc `batchEmbedContents`, đừng dùng vòng lặp gọi từng yêu cầu để ghép lại.

## Mô phỏng lệnh gọi

Ví dụ yêu cầu và phản hồi khi kết nối trực tiếp OpenAI. Dùng khóa dự án `$OPENAI_API_KEY` để gửi yêu cầu.

```json
{
  "model": "text-embedding-3-small",
  "input": ["文档检索的第一段文本", "如何计算两段文本的相似度"]
}
```

```json
{
  "object": "list",
  "data": [
    { "object": "embedding", "index": 0, "embedding": [0.0023, -0.0119, 0.0044] },
    { "object": "embedding", "index": 1, "embedding": [0.0011, 0.0087, -0.0026] }
  ],
  "model": "text-embedding-3-small",
  "usage": { "prompt_tokens": 12, "total_tokens": 12 }
}
```

Vector thực tế có 1536 số thực, ở đây chỉ giữ ba số đầu; `usage` được tính phí theo Token đầu vào, không liên quan đến độ dài đầu ra.

## Điểm cần lưu ý khi truy xuất

Hai bộ phản hồi này không cùng cấu trúc, không thể chỉ thay tên mô hình. Thông thường không có SSE hoặc Realtime; tác vụ lô bất đồng bộ cũng không phải luồng vector thời gian thực. Tài liệu và truy vấn của cùng một cơ sở dữ liệu vector nên dùng cùng mô hình, số chiều và chiến lược chuẩn hóa; sau khi đổi mô hình thường phải xây dựng lại chỉ mục.

## Tham khảo chính thức

* [OpenAI Embeddings](https\://developers.openai.com/api/docs/guides/embeddings)
* [OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings)
* [Google Embeddings](https\://ai.google.dev/gemini-api/docs/embeddings)