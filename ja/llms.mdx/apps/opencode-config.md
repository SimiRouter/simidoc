# OpenCode CLI の設定

OpenCode はグローバル設定ファイルを使用します。

* **Linux / macOS**：`~/.config/opencode/opencode.jsonc`
* **Windows**：`%USERPROFILE%\.config\opencode\opencode.jsonc`

まず API Key を設定ファイルの `apiKey` に記入し、次に検証コマンドを実行します。この例は環境変数を参照しないため、追加の環境変数を設定する必要はありません。Key を含む設定ファイルを保護し、OpenCode のデフォルトの権限確認を維持してください。

## 設定ファイル（V1 互換形式）

以下を設定ファイルに記入し、`apiKey` を自分の API Key に置き換えます。

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

## 設定の検証

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
  `opencode debug config` で設定が正しく読み込まれたか確認できます。`opencode run "你好"` はモデルが正常に応答するかテストします。
</Callout>

## 公式資料

[OpenCode 設定ドキュメント](https\://opencode.ai/docs/config/)にファイルの場所と現在の形式が説明されています。本ページは互換性のある V1 形式を掲載します。更新時は対応バージョンの移行説明に従い、既存設定全体を上書きしないでください。