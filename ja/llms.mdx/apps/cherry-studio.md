# Cherry Studio の設定

Cherry Studio は複数のモデルプロバイダーに対応するデスクトップ AI クライアントです。以下では SimiRouter API Key で接続します。

* 公式サイト：[https\://cherry-ai.com](https\://cherry-ai.com/)
* ダウンロード：[https\://cherry-ai.com/download](https\://cherry-ai.com/download)
* 公式ドキュメント：[https\://docs.cherry-ai.com](https\://docs.cherry-ai.com)

## SimiRouter に接続

### 方法 1：Key ページから開く

1. Cherry Studio をインストールして起動し、SimiRouter の [API Key 管理](https://api.dwchainless.com/keys)ページで使用する Key を見つけます。
2. Key の右側の **…** をクリックして、**Cherry Studio** をクリックし、ブラウザーから確認されたらアプリを開くことを許可します。
3. Cherry Studio でインポートされた API アドレス、Key、モデルを確認します。API アドレスは `https://api.dwchainless.com` です。保存後、アカウントで利用可能なモデルを選択します。

### 方法 2：手動設定

1. 対象の [API Key 管理](https://api.dwchainless.com/keys)ページで API Key をコピーします。Key 右側の **…** 内にある「接続情報をコピー」からアドレスを取得することもできます。
2. Cherry Studio の **設定 → モデルサービス** を開き、**New API** を選択します。API アドレスに `https://api.dwchainless.com` を入力し、コピーした API Key を貼り付けます。
3. 「管理」で現在のアカウントが利用できるモデルを追加または選択します。プロバイダーを有効にし、チャット画面に戻って使用します。

![Cherry Studio の API アドレスと Key の設定例](/simidoc/assets/cherry_studio/simirouter-provider.png)

<Callout type="warn" title="Key の保護">
  API Key を公開スクリーンショットに載せたり、信頼できないアプリと共有したりしないでください。短いテストメッセージを送信した後、SimiRouter の使用ログでモデルと呼び出し記録を確認できます。
</Callout>

## Cherry Studio で画像を生成

1. 現在のアカウントで利用でき、Cherry Studio が API 形式に対応する画像生成モデルを追加
   ![Cherry Studio で画像生成モデルを追加する設定ページ](/simidoc/assets/cherry_studio/add_paint_models.png)

2. 画像生成ページでモデルを選択し、プロンプトを入力して、生成後の結果を確認します。
   ![Cherry Studio の画像生成ページとプロンプト入力領域](/simidoc/assets/cherry_studio/paint.png)