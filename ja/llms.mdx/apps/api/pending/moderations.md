# コンテンツモデレーション

## API の説明

`POST https://api.openai.com/v1/moderations` はテキストまたは画像の安全性を同期評価し、認証に `Authorization: Bearer $OPENAI_API_KEY` を使用します。SimiRouter のルート、モデル、権限は別途確認が必要で、以下は OpenAI 公式への直接接続例です。

結果はリスクのシグナルであり、法令適合の結論でも見逃しなしの保証でもありません。画像とテキストで対応カテゴリが異なるため category\_applied\_input\_types を確認し、対象外入力を安全と解釈しないでください。

## リクエストパラメータ

| フィールド                   | 型                              | 必須   | 説明                                               |
| ----------------------- | ------------------------------ | ---- | ------------------------------------------------ |
| model                   | string                         | いいえ  | 例：omni-moderation-latest。モデルを固定すれば別名更新の影響を減らせます。 |
| input                   | string / string\[] / object\[] | はい   | テキストまたはマルチモーダル内容項目。                              |
| input\[].type           | string                         | 条件付き | text または image\_url。                             |
| input\[].text           | string                         | 条件付き | 審査対象のテキスト。                                       |
| input\[].image\_url.url | string                         | 条件付き | モデル要件を満たす画像 URL または data URL。                    |

## 戻り値

| フィールド                                    | 説明                           |
| ---------------------------------------- | ---------------------------- |
| `id` / `model`                           | リクエスト識別子と審査モデル。              |
| `results[].flagged`                      | いずれかの分類がリスク判定されたか。           |
| `results[].categories`                   | カテゴリ別の真偽値。                   |
| `results[].category_scores`              | 分類スコア。人の判断やモデル間共通の閾値ではありません。 |
| `results[].category_applied_input_types` | 各カテゴリに適用された入力種別。             |

```json
{"id":"modr_example","model":"omni-moderation-latest","results":[{"flagged":false,"categories":{},"category_scores":{},"category_applied_input_types":{}}]}
```

例では分類キーを省略していますが、実際には内訳が返ります。必要な証拠だけを保存し、ユーザー原文を無期限にすべて保存しないでください。

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

次を設定します：`OPENAI_API_KEY`。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/moderations'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'omni-moderation-latest', 'input': '这是一段需要进行安全审核的示例文本。'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/moderations";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.openai.com/v1/moderations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "omni-moderation-latest",
        "input": "这是一段需要进行安全审核的示例文本。"
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/moderations", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## エラーコード

| HTTP ステータス            | 意味と対処                                     |
| --------------------- | ----------------------------------------- |
| 400 / 422             | リクエスト項目、ファイル形式、モデルパラメータが不正。修正して再送。        |
| 401                   | API Key がない、無効、または期限切れ。                   |
| 403                   | 現在のプロジェクトまたはモデルへの権限がありません。                |
| 404                   | モデルまたはルートが存在しません。アドレスとプロジェクトを確認。          |
| 413 / 415             | アップロード過大、または未対応メディア型。                     |
| 429                   | レートまたは割り当て制限。残高不足とバックオフ可能な制限を区別。          |
| 500 / 502 / 503 / 504 | サービスまたは上流異常。ID を保持し、応答本文を確認してから再試行を判断します。 |

エラー本文の `error.message`、`error.type`、`error.code` は HTTP 状態より具体的な原因を示します。エラー本文をモデレーション結果として扱わないでください。

## 公式資料

[OpenAI Create moderation](https\://developers.openai.com/api/reference/resources/moderations/methods/create)。