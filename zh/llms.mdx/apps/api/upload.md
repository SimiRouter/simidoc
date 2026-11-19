# 文件与内容识别

文件相关流程有两层：上传 API 管理文件资源，模型输入 API 读取文件内容并生成答案。把文件附加到生成请求不等于将它保存为可复用的文件资源。

## 概览

| 你要做的事      | 输入方式                 | 文件去哪     | 是否需要先上传         |
| ---------- | -------------------- | -------- | --------------- |
| 让模型读一份 PDF | 请求内联 Base64 或可访问 URL | 只存在于本次请求 | 否               |
| 在多轮请求中复用文件 | file\_id 或厂商文件引用     | 厂商文件资源   | 是（官方 Files API） |
| 批量或超长文件预处理 | 上传后等待处理完成            | 厂商文件资源   | 是，且有生命周期        |

## 核心概念

* **内联输入**：文件编码进请求体随消息发送，请求结束即结束，没有 file\_id，也没有后续删除步骤。
* **文件资源**：先上传取得 id，再在多次请求中引用；资源有归属、有效期和配额，需要显式删除。
* **生命周期**：上传完成不等于文本抽取完成，也不等于模型已经理解；轮询到可处理状态后才能推理。
* **大小与格式**：限制按文件大小、页数、时长分别设定；压缩图片不会转换文件类型，扫描版 PDF 还需要 OCR 能力。
* **数据保留**：各厂商对文件内容与识别结果的保留策略不同，敏感材料先确认授权与删除方式。

## 请求与能力

| 用途                                  | 请求                                            | 边界                                 |
| ----------------------------------- | --------------------------------------------- | ---------------------------------- |
| [PDF 内容识别](/simidoc/zh/apps/api/upload/file-recognition)      | POST /v1/responses + input\_file              | 内联 Base64，无需 Files API。            |
| Chat PDF 输入                         | POST /v1/chat/completions + type=file         | 使用 Chat 的 file 对象，不是 Responses 结构。 |
| [Files API](/simidoc/zh/apps/api/pending/files)       | /v1/files                                     | 网关未实现；官方原生上传能力不代表本站开放。             |
| [Gemini 媒体理解](/simidoc/zh/apps/api/chat/gemini-media) | POST /v1beta/models/\{model}\:generateContent | inlineData 或适用的 fileData。          |

## 调用方式

内联识别可同步返回 JSON，也可流式返回文本事件；均属于一次模型请求。官方某些上传或文件预处理流程需要等待资源可用，属于资源生命周期，不等于模型自动后台执行。多文件可以在一个支持的请求里提交，也可以分成并行请求；两种方式的上下文、费用和总大小限制不同。

上传敏感文件前确认处理授权与服务商数据政策。大型文档宜按任务选择相关页或片段，不要为追求一次完成无限增加输入。识别输出必须保留不确定性，关键金额、编号与法律医疗结论应人工复核。

## 模拟调用

内联识别一次请求即可完成，文件以 Base64 放在 `input_file` 里：

```json
{
  "model": "gpt-5.5",
  "input": [
    {
      "role": "user",
      "content": [
        { "type": "input_text", "text": "总结这份合同的付款条款。" },
        { "type": "input_file", "filename": "contract.pdf", "file_data": "data:application/pdf;base64,JVBERi0xLjQK..." }
      ]
    }
  ]
}
```

响应是普通的模型消息，识别结果在 `output_text` 中：

```json
{
  "status": "completed",
  "output": [
    {
      "type": "message",
      "content": [
        { "type": "output_text", "text": "（示意）合同约定分三期付款……" }
      ]
    }
  ]
}
```

整个过程中没有上传步骤，也没有可复用的 file\_id；同一个文件要再问一次，需要重新提交 Base64 或改用官方文件资源。

## 官方参考

* [OpenAI 文件输入](https\://developers.openai.com/api/docs/guides/file-inputs)
* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [Google 文件输入](https\://ai.google.dev/gemini-api/docs/file-input-methods)