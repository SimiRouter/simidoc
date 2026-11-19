# OpenCode CLI 配置

OpenCode 使用全局配置文件：

* **Linux / macOS**：`~/.config/opencode/opencode.jsonc`
* **Windows**：`%USERPROFILE%\.config\opencode\opencode.jsonc`

使用顺序：先将 API 密钥写入配置文件的 `apiKey`，再运行验证命令。此示例没有引用环境变量，无需设置额外的环境变量。请保护包含密钥的配置文件，并保留 OpenCode 默认权限确认。

## 配置文件（V1 兼容格式）

将以下内容写入配置文件，并将 `apiKey` 替换为自己的 API 密钥：

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "openai/gpt-6-astra",
  "small_model": "openai/gpt-6-astra",
  "provider": {
    "openai": {
      "options": {
        "baseURL": "https://api.dwchainless.com/v1",
        "apiKey": "PASTE_API_KEY_HERE"
      },
      "models": {
        "gpt-6-astra": {
          "headers": {
            "originator": "opencode"
          }
        }
      }
    }
  },
  "agent": {
    "title": {
      "options": {
        "reasoningEffort": "none"
      }
    },
    "build": {
      "variant": "xhigh",
      "options": {
        "reasoningSummary": "detailed",
        "textVerbosity": "high"
      }
    },
    "plan": {
      "variant": "xhigh",
      "options": {
        "reasoningSummary": "detailed",
        "textVerbosity": "high"
      }
    }
  }
}
```

## 验证配置

### Linux / macOS

```bash
opencode debug config
opencode run "你好"
```

### Windows CMD

```cmd
opencode debug config
opencode run "你好"
```

### Windows PowerShell

```powershell
opencode debug config
opencode run "你好"
```

<Callout type="info" title="">
  `opencode debug config` 可验证配置是否正确加载；`opencode run "你好"` 用于测试模型是否正常响应。
</Callout>

## 官方参考

[OpenCode 配置文档](https\://opencode.ai/docs/config/)介绍配置文件位置与当前格式。本文保留兼容的 V1 格式；升级时应按对应版本的迁移说明处理，不要整份覆盖现有配置。