# Gemini CLI 設定

透過設定環境變數，將 Gemini CLI 指向 SimiRouter 平台。

## macOS / Linux

**臨時生效（目前終端機工作階段）：**

```bash
export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
export GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**持久生效（追加到 Shell 設定檔）：**

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
  金鑰保存在權限為 `600` 的 `~/.config/simiroouter.env`，不寫進每次登入都會執行的 Shell 設定檔。把 `source ~/.config/simiroouter.env` 加入 `~/.bashrc` 或 `~/.zshrc` 即可持久生效；多使用者機器上不要讓他人讀取該檔案。
</Callout>

## Windows PowerShell

**臨時生效：**

```powershell
$env:GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
$env:GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**持久生效（追加到 PowerShell 設定檔）：**

```powershell
Add-Content $PROFILE 'Set-Item -Path Env:GOOGLE_GEMINI_BASE_URL -Value "https://api.dwchainless.com"'
Add-Content $PROFILE 'Set-Item -Path Env:GEMINI_API_KEY -Value "PASTE_API_KEY_HERE"'
```

## Windows CMD

**臨時生效：**

```cmd
set GOOGLE_GEMINI_BASE_URL=https://api.dwchainless.com
set GEMINI_API_KEY=PASTE_API_KEY_HERE
```

**持久生效（目前使用者）：**

1. 按 `Win + R`，輸入 `sysdm.cpl`，回車
2. 點擊「高級」→「環境變數」
3. 在「使用者變數」中點「新建」，分別新增 `GOOGLE_GEMINI_BASE_URL` 和 `GEMINI_API_KEY`
4. 重新啟動終端機使變數生效

## 啟動驗證

```bash
gemini
```

啟動後選擇 API Key 驗證並傳送簡短訊息，再到 SimiRouter 使用記錄核對呼叫。能打開用戶端不代表介面已連線。

## 常見問題

**提示 `GEMINI_API_KEY` 未設定？**

* 檢查變數名拼字是否正確
* Windows 使用者設定系統變數後需重新啟動終端機

**連接逾時或發生錯誤？**

* 確認 `GOOGLE_GEMINI_BASE_URL` 末尾沒有多餘的 `/`
* 檢查網路連接是否正常
* 確認 API Key 有效且未過期

## 官方參考

[Gemini CLI 設定參考](https\://geminicli.com/docs/reference/configuration/)中的 `GOOGLE_GEMINI_BASE_URL` 用於覆蓋服務根位址，SDK 另行追加 API 版本和模型路徑，因此此處不附加 `/v1`。