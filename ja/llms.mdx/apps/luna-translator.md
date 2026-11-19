# LunaTranslator の設定

<Callout type="info" title="">
  LunaTranslator
  は、母語で楽しむようなビジュアルノベル体験を目指す、無料のオープンソース GalGame 翻訳ソフトです。
</Callout>

* プロジェクト：[https\://github.com/HIllya51/LunaTranslator](https\://github.com/HIllya51/LunaTranslator)
* プロジェクトドキュメント：[https\://docs.lunatranslator.org](https\://docs.lunatranslator.org/zh/README.html)

## 対応機能

* **HOOK** 主に HOOK で対応するビジュアルノベルのテキストを抽出します。具体的な互換性は公式ドキュメントを参照

* **埋め込み翻訳** 一部のゲームは翻訳をゲーム内に直接埋め込み、没入型の体験を提供可能

* **エミュレーターの HOOK** 対応するエミュレーターとゲームから HOOK でテキストを読み取り

* **OCR** 高精度の OCR モデルを内蔵し、他の多くのオンライン／オフライン OCR エンジンにも対応。さまざまなテキストを柔軟に読み取り

* **豊富な翻訳 API** 複数の大規模言語モデルとオフライン翻訳 API を設定可能

* **言語学習** 日本語の形態素解析、ふりがな、AnkiConnect、Yomitan 拡張に対応

* **音声合成** 多くのオンライン／オフライン音声合成エンジンに対応

* **音声認識** Windows 10 と Windows 11 では Windows 音声認識を使用可能。

## インストール方法

対象の [LunaTranslator ドキュメント — ダウンロード・起動・更新](https\://docs.lunatranslator.org/zh/README.html) に従ってダウンロードし、インストールします。

## LunaTranslator から SimiRouter に手動接続

1. SimiRouter の [API Key 管理](https://api.dwchainless.com/keys)ページで使用する API Key をコピーします。
2. LunaTranslator の **設定 → 翻訳設定 → 大規模モデル**で追加を選び、「大規模モデル汎用 API」テンプレートをコピーして API を追加します。
3. 追加した API の設定を開き、**API アドレス**に `https://api.dwchainless.com`，**API Key** にコピーした Key を貼り付けます。モデル一覧を更新するか、アカウントで利用可能な完全なモデル ID を入力します。
4. 保存して API を有効にします。短い非機密テキストを翻訳し、SimiRouter の使用ログで呼び出しを確認してください。

Key を公開スクリーンショットに含めないでください。バージョンにより名称が多少異なる場合があります。詳細設定は [LunaTranslator 公式ドキュメント](https\://docs.lunatranslator.org/zh/guochandamoxing.html)。