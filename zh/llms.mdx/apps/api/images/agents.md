# 智能体图片调用已合并到协议文档

智能体调用任务已分散到三个协议，每个协议均有生成和编辑模板、配置准备、结果保存与失败处理，不再单独维护一套偏向 OpenAI Images 的教程：

* [OpenAI 格式的智能体调用](/simidoc/zh/apps/api/images/openai)：Images 生成、JSON 编辑及最终事件检查。
* [Gemini 原生格式的智能体调用](/simidoc/zh/apps/api/images/gemini)：GenerateContent 图片 Part、MIME 与多轮上下文。
* [Qwen 原生格式的智能体调用](/simidoc/zh/apps/api/images/qwen)：百炼区域配置、原生同步调用和图片 URL 下载。

智能体仍须具备本地执行和返回结果检查能力；这些文档不会安装远程 Skill。真实请求可能收费，调用前确认模型、规格、数量和输出位置；不泄露密钥、不覆盖文件、不自动重试。接口、效果与规格比较见[图片 API 总览](/simidoc/zh/apps/api/images)。