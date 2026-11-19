# Grok CLI 配置

Grok CLI 的模型列表地址与推理地址分别配置。`[endpoints].models_base_url` 既是模型列表的来源，也是推理请求的默认基址；具体模型的 `base_url` 可以覆盖它。只设置其中一处时，另一处可能仍指向官方地址，需要分别核对。

配置文件路径：

* **Linux / macOS**：`~/.grok/config.toml`
* **Windows**：`%USERPROFILE%\.grok\config.toml`

## 安装 / 更新

Linux / macOS：

```bash
curl -fsSL https://x.ai/cli/install.sh | bash
grok update
grok --version
```

Windows（PowerShell）：

```powershell
irm https://x.ai/cli/install.ps1 | iex
```

通过 WinGet 安装的版本请用 `winget upgrade` 更新，不要依赖 `grok update`。

<Callout type="warn" title="启动时需要 XAI_API_KEY">
  Grok CLI 启动阶段拉取模型列表只读取环境变量 `XAI_API_KEY`，未设置会直接报错，与配置文件里的 `api_key` 无关。使用 SimiRouter 时把同一个 Key 同时写入环境变量：

  ```bash
  export XAI_API_KEY="PASTE_API_KEY_HERE"
  ```

  不要把密钥写进会提交到 Git 的文件；长期使用可放进权限为 `600` 的环境文件后再 `source`。
</Callout>

## 写入配置文件

将以下内容写入 `~/.grok/config.toml`，并将 `api_key` 替换为自己的 API 密钥：

```toml
[models]
default = "grok-4.5"

[endpoints]
models_base_url = "https://api.dwchainless.com/v1"

[model."grok-4.5"]
base_url = "https://api.dwchainless.com/v1"
model = "grok-4.5"
name = "Grok 4.5"
api_key = "PASTE_API_KEY_HERE"
api_backend = "responses"
context_window = 500000
supports_backend_search = true

[session]
# 可选：官方默认值为 85；80 会更早触发自动压缩
auto_compact_threshold_percent = 80

[ui]
max_thoughts_width = 120
yolo = false
compact_mode = false
# permission_mode = "always-approve"  # enable only in trusted environments
```

上述 UI 配置只调整界面：思考内容最大宽度为 120、不启用紧凑界面；示例保留默认确认策略，不自动批准工具调用。

<Callout type="warn" title="">
  示例关闭 `yolo`，并注释掉 `permission_mode = "always-approve"`。启用它们会让 Grok 无需确认即可修改文件和执行命令，**只应在可信项目与可信运行环境中使用**。
</Callout>

<Callout type="info" title="">
  `api_key` 必须填写本站提供的 SimiRouter Key，不能填写 grok.com OAuth `refresh_token`。内联 Key 以明文保存，Linux / macOS 请执行 `chmod 600 ~/.grok/config.toml`。共享机器建议改用官方支持的 `env_key` 方式。
</Callout>

## 验证配置

```bash
grok inspect
grok models
grok --model grok-4.5 --output-format json -p '只输出 YAI_GROK_OK'
```

## 官方参考

* [xAI Grok CLI：自定义模型](https\://docs.x.ai/build/overview)
* [xAI Grok CLI：配置参考](https\://docs.x.ai/build/settings)