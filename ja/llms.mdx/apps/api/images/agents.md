# エージェントの画像呼び出しは各プロトコルへ統合されました

エージェントタスクは 3 つのプロトコルに分けました。各ページに生成・編集テンプレート、設定、保存、失敗処理があり、OpenAI Images に偏った独立ガイドは維持しません。

* [OpenAI 形式のエージェント呼び出し](/simidoc/ja/apps/api/images/openai)：Images 生成、JSON 編集、最終イベントの確認。
* [Gemini ネイティブ形式のエージェント呼び出し](/simidoc/ja/apps/api/images/gemini)：GenerateContent の画像 Part、MIME、複数ターンの文脈。
* [Qwen ネイティブ形式のエージェント呼び出し](/simidoc/ja/apps/api/images/qwen)：公式リージョン設定、同期呼び出し、画像 URL のダウンロード。

エージェントにはローカル実行とレスポンス確認の能力が必要です。この文書はリモート Skill をインストールしません。実際の呼び出しは有料の場合があるため、モデル、仕様、枚数、保存先を確認し、Key を漏らさず、上書きや自動再試行をしないでください。API、効果、仕様の比較は[画像 API の概要](/simidoc/ja/apps/api/images)を参照してください。