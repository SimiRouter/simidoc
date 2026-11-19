# FluentRead の設定

<Callout type="info" title="">
  🌊
  FluentRead は、母語のような読み心地を目指すオープンソースのブラウザー翻訳拡張です。
</Callout>

* プロジェクト：[https\://github.com/FluentRead/FluentRead](https\://github.com/FluentRead/FluentRead)

## 主な機能

### AI 翻訳エンジン

* **複数エンジンに対応**：さまざまな翻訳エンジンを利用可能
* **従来型の翻訳**：Microsoft 翻訳、Google 翻訳、DeepL など
* **大規模 AI モデル**：OpenAI、DeepSeek、Kimi、Ollama など
* **カスタムエンジン**：独自の翻訳サービス設定に対応

### 没入型の読書体験

* **対訳表示**：原文と訳文を並べて表示し、読みやすく
* **選択テキストの翻訳**：テキストを選択してすぐに翻訳結果を取得
* **ワンクリックコピー**：訳文を素早くコピーし、読書を効率化
* **ページ全体の翻訳**：フローティングボタンでページ全体を翻訳。再読み込みは不要

### プライバシーとカスタマイズ

* **データとプライバシー**：オンライン翻訳やクラウドモデルでは、翻訳対象の内容が設定先のサービスに送信されます。サービスのデータ処理方針を確認し、機密情報を信頼できないプロバイダーへ送信しないでください。
* **柔軟なカスタマイズ**：さまざまな場面に合わせた豊富な設定項目
* **完全無料**：オープンソースかつ無料の非商用プロジェクト

## インストール方法

| ブラウザー       | インストール方法                                                                                                                                                                                                                                        |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Chrome**  | [Chrome ウェブストア](https\://chromewebstore.google.com/detail/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/djnlaiohfaaifbibleebjggkghlmcpcj?hl=zh-CN\&authuser=0) \| [中国国内向けミラー](https\://www.crxsoso.com/webstore/detail/djnlaiohfaaifbibleebjggkghlmcpcj) |
| **Edge**    | [Edge アドオンストア](https\://microsoftedge.microsoft.com/addons/detail/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/kakgmllfpjldjhcnkghpplmlbnmcoflp?hl=zh-CN)                                                                                               |
| **Firefox** | [Firefox アドオンストア](https\://addons.mozilla.org/zh-CN/firefox/addon/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/)                                                                                                                                        |

## 設定方法

### FluentRead で手動設定

対象の [API Key 管理](https://api.dwchainless.com/keys)ページで Key をコピーし、FluentRead の設定を開いて入力します。

| 設定項目           | 内容                                          |
| -------------- | ------------------------------------------- |
| 翻訳サービス         | New API                                     |
| アクセストークン       | コピーした SimiRouter API Key                    |
| NewAPI エンドポイント | `https://api.dwchainless.com`（`/v1` は含めません） |
| モデル            | アカウントで利用可能な完全なモデル ID を選択または入力               |

保存後、短い非機密テキストを翻訳し、SimiRouter の使用ログで呼び出しを確認します。オンライン翻訳は、設定先のサービスに翻訳対象の内容を送信します。