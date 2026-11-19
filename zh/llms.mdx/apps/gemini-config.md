# Gemini CLI 配置

通过设置环境变量，将 Gemini CLI 指向 SimiRouter 平台。

## macOS / Linux

**临时生效（当前终端会话）：**

```bash
export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
export GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**持久生效（追加到 Shell 配置文件）：**

```bash
install -d -m 700 ~/.config
umask 077
printf '%s\n' \
  'export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"' \
  'export GEMINI_API_KEY="PASTE_API_KEY_HERE"' > ~/.config/simiroouter.env
chmod 600 ~/.config/simiroouter.env
# Add this line to ~/.zshrc or ~/.bashrc: source ~/.config/simiroouter.env
source ~/.config/simiroouter.env
```

<Callout type="info" title="">
  密钥保存在权限为 `600` 的 `~/.config/simiroouter.env`，不写进每次登录都会执行的 Shell 配置文件。把 `source ~/.config/simiroouter.env` 加入 `~/.bashrc` 或 `~/.zshrc` 即可持久生效；多用户机器上不要让他人读取该文件。
</Callout>

## Windows PowerShell

**临时生效：**

```powershell
$env:GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
$env:GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**持久生效（追加到 PowerShell 配置文件）：**

```powershell
Add-Content $PROFILE 'Set-Item -Path Env:GOOGLE_GEMINI_BASE_URL -Value "https://api.dwchainless.com"'
Add-Content $PROFILE 'Set-Item -Path Env:GEMINI_API_KEY -Value "PASTE_API_KEY_HERE"'
```

## Windows CMD

**临时生效：**

```cmd
set GOOGLE_GEMINI_BASE_URL=https://api.dwchainless.com
set GEMINI_API_KEY=PASTE_API_KEY_HERE
```

**持久生效（当前用户）：**

1. 按 `Win + R`，输入 `sysdm.cpl`，回车
2. 点击「高级」→「环境变量」
3. 在「用户变量」中点「新建」，分别添加 `GOOGLE_GEMINI_BASE_URL` 和 `GEMINI_API_KEY`
4. 重启终端使变量生效

## 启动验证

```bash
gemini
```

启动后选择 API Key 认证并发送简短消息，再到 SimiRouter 使用日志核对调用。能打开客户端不代表接口已连通。

## 常见问题

**提示 `GEMINI_API_KEY` 未设置？**

* 检查变量名拼写是否正确
* Windows 用户设置系统变量后需重启终端

**连接超时或报错？**

* 确认 `GOOGLE_GEMINI_BASE_URL` 末尾没有多余的 `/`
* 检查网络连接是否正常
* 确认 API Key 有效且未过期

## 官方参考

[Gemini CLI 配置参考](https\://geminicli.com/docs/reference/configuration/)中的 `GOOGLE_GEMINI_BASE_URL` 用于覆盖服务根地址，SDK 另行追加 API 版本和模型路径，因此此处不附加 `/v1`。