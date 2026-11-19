# Claude CLI 設定

Claude Code 透過環境變數串接 API 閘道。設定步驟：先設定環境變數，再執行 `claude` 啟動。

## Linux / macOS

```bash
export ANTHROPIC_AUTH_TOKEN="PASTE_API_KEY_HERE"
export ANTHROPIC_BASE_URL="https://api.dwchainless.com"

# 可选：自定义默认模型映射（不配置也可正常使用）
export ANTHROPIC_DEFAULT_OPUS_MODEL="gpt-6-astra"
export ANTHROPIC_DEFAULT_SONNET_MODEL="gpt-5.6-terra"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5.6-luna"
```

## Windows CMD

```cmd
set ANTHROPIC_AUTH_TOKEN=PASTE_API_KEY_HERE
set ANTHROPIC_BASE_URL=https://api.dwchainless.com

:: 可选：自定义默认模型映射（不配置也可正常使用）
set ANTHROPIC_DEFAULT_OPUS_MODEL=gpt-6-astra
set ANTHROPIC_DEFAULT_SONNET_MODEL=gpt-5.6-terra
set ANTHROPIC_DEFAULT_HAIKU_MODEL=gpt-5.6-luna
```

## Windows PowerShell

```powershell
$env:ANTHROPIC_AUTH_TOKEN="PASTE_API_KEY_HERE"
$env:ANTHROPIC_BASE_URL="https://api.dwchainless.com"

# 可选：自定义默认模型映射（不配置也可正常使用）
$env:ANTHROPIC_DEFAULT_OPUS_MODEL="gpt-6-astra"
$env:ANTHROPIC_DEFAULT_SONNET_MODEL="gpt-5.6-terra"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5.6-luna"
```

## 啟動驗證

環境變數設定完成後，在終端機執行：

```bash
claude
```

傳送簡短訊息後，到 SimiRouter 使用記錄核對對應模型和請求。僅打開對話介面不能確認 API 串接。

## 官方參考

[Claude Code 閘道串接文件](https\://code.claude.com/docs/en/llm-gateway)說明閘道連接方式。`ANTHROPIC_BASE_URL` 是根位址，用戶端會追加 `/v1/messages`；不要重複附加 `/v1`。模型對應須由目前管道支援。