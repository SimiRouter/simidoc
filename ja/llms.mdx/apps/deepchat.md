# DeepChat の設定

DeepChat はクラウドとローカルのモデルに対応するオープンソース AI クライアントです。ツール呼び出しなどの拡張機能は、選択したモデルとプロバイダーが対応する必要があります。

* 公式サイト：[https\://deepchat.thinkinai.xyz](https\://deepchat.thinkinai.xyz)
* GitHub リポジトリ：[https\://github.com/ThinkInAIXYZ/deepchat](https\://github.com/ThinkInAIXYZ/deepchat)
* ダウンロード：[https\://deepchat.thinkinai.xyz/#/download](https\://deepchat.thinkinai.xyz/#/download)

## SimiRouter への手動接続

1. SimiRouter の [API Key 管理](https://api.dwchainless.com/keys)ページで使用する API Key をコピーします。

2. DeepChat の **設定 → プロバイダー設定**を開き、New API を選ぶか互換プロバイダーを追加します。**API URL に `https://api.dwchainless.com`** を入力し、コピーした API Key を貼り付けます。

   ![DeepChat に SimiRouter のアドレスと API Key を入力する例](/simidoc/assets/deepchat/simirouter-manual.png)

3. Key を検証し、モデルを更新または追加します。プロバイダーを有効化し、アカウントで利用可能なモデルを選択します。短いメッセージを送信した後、SimiRouter の使用ログで対応する呼び出しを確認できます。

<Callout type="warn" title="Key の保護">
  API Key を公開スクリーンショットに含めたり、信頼できないアプリと共有したりしないでください。クライアントの画面はバージョンにより変わる場合があります。実際のフィールドに従ってください。
</Callout>

## 関連リンク

* [DeepChat GitHub リポジトリ](https\://github.com/ThinkInAIXYZ/deepchat)
* [DeepChat ダウンロードページ](https\://deepchat.thinkinai.xyz/#/download)