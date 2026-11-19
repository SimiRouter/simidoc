# Hermes の設定

## 事前準備

1. Hermes がインストール済みで、正常に起動できること。
2. SimiRouter コンソールで有効な API Key を作成済みであること。
3. CC Switch がインストール済みであること。

<Callout type="info" title="">
  未インストールの場合は、先に [CC Switch のインストールとインポートガイド](/simidoc/ja/apps/cc-switch) を参照してください。
</Callout>

## CC Switch で Hermes を設定

1. CC Switch を開き、左のアプリ一覧で **Hermes** を選びます。旧バージョンでは上部タブを使用します。

![CC Switch 上部で Hermes に切り替え](/simidoc/assets/hermers/h1.png)

2. クリックする項目は **追加**をクリックし、カスタムプロバイダーを追加して Hermes タブに戻り、有効にします。

![追加をクリックしてプロバイダーのパラメーターを入力](/simidoc/assets/hermers/h2.png)

3. ターミナルで `hermes desktop` を入力してデスクトップアプリを起動し、短いメッセージでテストします。`--skip-build` はデスクトップのビルド成果物が存在する開発環境用であり、初回起動用ではありません。

![プロバイダーを保存して有効化](/simidoc/assets/hermers/h4.png)

4. ターミナルで `hermes --tui` を実行して TUI モードを使用することもできます。画面が開いたら短いメッセージを送信し、SimiRouter コンソールで呼び出し記録を確認します。TUI が表示されるだけではモデルへの接続成功は証明できません。

![プロバイダーを保存して有効化](/simidoc/assets/hermers/h5.png)

## よくある質問

* `baseUrl` に `/v1` がない：モデル一覧が返らない典型的な原因です。
* モデル ID が一致しない：実際に公開されるモデル名と完全に一致させてください。
* 認証／利用不可エラーが続く：API Key とプロバイダーに紐づく環境を確認してください。

## 公式資料

[Hermes デスクトップ版 CLI リファレンス](https\://hermes-agent.nousresearch.com/docs/user-guide/desktop#cli-reference-hermes-desktop)。