# 第三方插件配置（VS Code Roo）

Roo Code 支持自定义 OpenAI 兼容提供商。通过 SimiRouter 接入时，只需配置服务地址、API Key 和模型 ID，不需要在本地部署模型。

## 配置 Roo Code

1. 安装 Roo Code，打开扩展设置。
2. 将 **API Provider** 设为 **OpenAI Compatible**。
3. 填写以下信息：

| 字段       | 内容                                 |
| -------- | ---------------------------------- |
| Base URL | `https://api.dwchainless.com/v1`   |
| API Key  | SimiRouter [API 密钥管理](https://api.dwchainless.com/keys)中创建的密钥 |
| Model ID | 从[模型广场](https://api.dwchainless.com/zh/pricing/)复制完整模型 ID，区分大小写   |

4. 按模型实际能力设置上下文窗口、输出上限与图片输入等实际存在的字段，不要套用其他模型的固定数值。Roo Code 固定使用原生工具调用，没有单独的开关。
5. 保存后发送简短消息，并在 SimiRouter [使用日志](https://api.dwchainless.com/usage-logs/common)核对调用。

## 接口测试

客户端之外的完整 Python、Node.js、curl 和 Go 测试示例见 [API 脚本接入](/simidoc/zh/apps/api-script)。测试和插件必须使用同一个模型 ID 与密钥权限；一次文本请求成功不代表工具或图片功能已经联调通过。

## 常见错误

* **401**：检查密钥是否完整、有效且无多余空格。
* **404**：检查最终请求地址是否重复出现 `/v1`，并核对模型 ID。
* **模型不可用**：检查模型、分组和密钥权限，结合响应错误体排查。
* **参数不支持**：关闭不适用于当前模型的参数，尤其是采样、推理强度和输出长度配置。

保留插件默认的工具审批设置。不要向不可信项目开放自动执行权限，也不要公开含密钥的设置截图。

## 官方参考

[Roo Code：OpenAI Compatible 提供商](https\://roocodeinc.github.io/Roo-Code/providers/openai-compatible/)。