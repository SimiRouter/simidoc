# 模型列表

模型列表是接入配置的入口：先取得模型 ID，再根据厂商能力文档选择聊天、视觉、图片、音频或工具接口。可见不等于可调用，模型列表也不代表实时健康检查。

## 概览

| 你要确认的事   | 在哪里看           | 说明                |
| -------- | -------------- | ----------------- |
| 有哪些模型 ID | 本节的列表接口        | 只返回当前凭据可见的模型      |
| 能不能真正调用  | 模型与价格 + 一次真实请求 | 可见、可路由、有额度是三件不同的事 |
| 支持哪些输入输出 | 模型能力说明         | 列表元数据通常不完整        |
| 什么时候下线   | 厂商发布的弃用或停用公告   | 弃用不等于立即不可用，但不应新接入 |

## 核心概念

* **模型 ID**：请求体中使用的唯一标识，通常区分大小写，必须完整复制，不要自行缩写。展示名、别名和实际请求 ID 可能不同。
* **可见与可调用**：列表只反映权限范围内的模型，渠道未配置、余额不足或限流时仍会失败。
* **上下文窗口**：输入加输出的 Token 上限，按模型区分；列表接口经常不返回该值。
* **计费单位**：文本模型多按 Token，图片模型可按张或按 Token，视频模型常按秒或按次；同一模型族内也可能不同。
* **下线日期**：表示厂商计划停止服务的日期，迁移应在到期前完成，而不是到期后才发现。

## 查询接口

| 文档                    | 请求                 | 返回结构                            |
| --------------------- | ------------------ | ------------------------------- |
| [OpenAI 格式](/simidoc/zh/apps/api/models/openai) | GET /v1/models     | data\[].id，适合 OpenAI 兼容客户端。     |
| [Gemini 格式](/simidoc/zh/apps/api/models/gemini) | GET /v1beta/models | models\[].name，适合 Gemini 协议客户端。 |

## 调用方式

列表查询为同步 JSON 请求，不支持 SSE，也不是异步任务。多个账户可分别并行查询，但凭据和结果不能混用。列表缓存应设有效期，发现模型不再可用时重新读取；不要为刷新列表发送真实生成请求。

## 模拟调用

查询使用 GET，无需请求体。以下是 SimiRouter 网关的示意返回：

```bash
curl "https://api.dwchainless.com/v1/models" \
  -H "Authorization: Bearer $SIMIROUTER_API_KEY"
```

```json
{
  "object": "list",
  "success": true,
  "data": [
    {
      "id": "MODEL_ID",
      "object": "model",
      "created": 1626777600,
      "owned_by": "custom",
      "context_length": 1048576,
      "supported_endpoint_types": ["openai"]
    }
  ]
}
```

网关会返回上下文长度和接口类型。上下文长度可能是平台默认值，价格、输入输出模态和工具支持仍应查阅模型说明。列表为空通常表示当前凭据没有可见模型。

## 元数据边界

OpenAI 模型对象包含 id、object、created、owned\_by；Google 原生模型对象可包含方法与 Token 限制。网关可以只返回精简元数据，因此不能根据缺失字段臆测上下文上限、模态或工具支持。

## 官方参考

* [OpenAI Models API](https\://developers.openai.com/api/reference/resources/models/methods/list)
* [Google Models API](https\://ai.google.dev/api/models)