# Claude CLI 配置

Claude Code 通过环境变量接入 API 网关。配置步骤：先设置环境变量，再执行 `claude` 启动。

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

## 启动验证

环境变量设置完成后，在终端运行：

```bash
claude
```

发送简短消息后，到 SimiRouter 使用日志核对对应模型和请求。仅打开对话界面不能确认 API 接入。

## 官方参考

[Claude Code 网关接入文档](https\://code.claude.com/docs/en/llm-gateway)说明网关连接方式。`ANTHROPIC_BASE_URL` 是根地址，客户端会追加 `/v1/messages`；不要重复附加 `/v1`。模型映射须由当前渠道支持。