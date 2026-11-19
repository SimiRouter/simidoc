# OpenCode CLI 設定

OpenCode 使用全域設定檔：

* **Linux / macOS**：`~/.config/opencode/opencode.jsonc`
* **Windows**：`%USERPROFILE%\.config\opencode\opencode.jsonc`

使用順序：先將 API 金鑰寫入設定檔的 `apiKey`，再執行驗證指令。此範例沒有引用環境變數，無需設定額外的環境變數。請保護包含金鑰的設定檔，並保留 OpenCode 預設權限確認。

## 設定檔（V1 相容格式）

將以下內容寫入設定檔，並將 `apiKey` 替換為自己的 API 金鑰：

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

## 驗證設定

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
  `opencode debug config` 可驗證設定是否正確載入；`opencode run "你好"` 用於測試模型是否正常回應。
</Callout>

## 官方參考

[OpenCode 設定文件](https\://opencode.ai/docs/config/)介紹設定檔位置與目前格式。本文保留相容的 V1 格式；升級時應按對應版本的遷移說明處理，不要整份覆蓋現有設定。