# 画像呼び出し例はプロトコル別に整理されました

OpenAI Images だけに適用される共通スクリプトガイドは使用しません。実際のプロトコルを選んでください。各ページは「リクエスト形式とパラメータ → レスポンスパラメータ → 呼び出し例」の順で、仕様、4 言語コード、エージェントタスク、安全な保存を説明します。

* [OpenAI 形式](/simidoc/ja/apps/api/images/openai)：Images の生成・編集、Responses の対話型生成、画像理解。
* [Gemini ネイティブ形式](/simidoc/ja/apps/api/images/gemini)：GenerateContent のテキスト・画像 Part と Base64 保存。
* [Qwen ネイティブ形式](/simidoc/ja/apps/api/images/qwen)：公式リージョン URL、ネイティブメッセージ、結果 URL の保存。

API、効果、1K / 2K / 4K の比較は[画像 API の概要](/simidoc/ja/apps/api/images)を参照してください。旧リンクはここに残しますが、呼び出しは各プロトコルに従い、認証情報、パラメータ、レスポンスを混用しないでください。