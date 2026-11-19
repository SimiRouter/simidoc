# OpenClaw の設定

## 事前準備

1. OpenClaw がインストール済みで、正常に起動できること。
2. SimiRouter コンソールで有効な API Key を作成済みであること。
3. CC Switch がインストール済みであること。

<Callout type="info" title="">
  未インストールの場合は、先に [CC Switch のインストールとインポートガイド](/simidoc/ja/apps/cc-switch)。
</Callout>

## CC Switch で OpenClaw を設定

1. CC Switch を開き、左のアプリ一覧で **OpenClaw** を選びます。旧バージョンでは上部タブを使用します。

![CC Switch 上部で OpenClaw に切り替え](/simidoc/assets/cc/cc1.png)

2. クリックする項目は **追加**を選択し、カスタムプロバイダーを追加します。

![追加をクリックしてプロバイダーのパラメーターを入力](/simidoc/assets/cc/cc2.png)

3. 保存後、プロバイダーが有効であることを確認し、ターミナルで `openclaw onboard` を実行します。指示に従い、OpenClaw の初期設定とペアリングを行います。

![プロバイダーを保存して有効化](/simidoc/assets/cc/cc4.png)

4. 短いメッセージを送信して正常な応答を確認し、SimiRouter コンソールで呼び出し記録を照合します。設定画面やスクリーンショットの赤枠が見えるだけでは、モデルへの接続成功は証明できません。
   ![プロバイダーを保存して有効化](/simidoc/assets/cc/cc3.png)

## よくある質問

* `baseUrl` に `/v1` がない：モデル一覧が返らない典型的な原因です。
* モデル ID が一致しない：実際に公開されるモデル名と完全に一致させてください。
* 認証／利用不可エラーが続く：API Key とプロバイダーに紐づく環境を確認してください。
* 詳細なログを見るには、フォアグラウンド実行の `openclaw gateway --port 18789` で起動ログを確認できます。

## 公式資料

[CC Switch 公式プロジェクト](https\://github.com/farion1231/cc-switch)。