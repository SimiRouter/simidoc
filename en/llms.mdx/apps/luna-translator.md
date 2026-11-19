# LunaTranslator configuration

<Callout type="info" title="">
  LunaTranslator is a free, open-source visual novel translator designed for natural reading.
</Callout>

* Project Address\: [https\://github.com/HIllya51/LunaTranslator](https\://github.com/HIllya51/LunaTranslator)
* Project documentation\: [https\://docs.lunatranslator.org](https\://docs.lunatranslator.org/zh/README.html)

## Capabilities

* **HOOK** Primarily extracts text through HOOK for supported visual novels; see official compatibility information.

* **Embedded translation** Some games can display translated text directly in-game.

* **Emulator HOOK** Reads text from supported emulators and games through HOOK.

* **OCR** Includes OCR and supports other online and offline engines for flexible text capture.

* **Translation interfaces** Configure multiple language model and offline translation interfaces.

* **Language learning** Supports Japanese segmentation and readings, AnkiConnect, and Yomitan.

* **Speech synthesis** Supports multiple online and offline speech engines.

* **Speech recognition** Windows speech recognition is available on Windows 10 and 11.

## Installation Method

Follow [LunaTranslator documentation\: download, launch, and update](https\://docs.lunatranslator.org/zh/README.html) to download and install.

## Connect LunaTranslator to SimiRouter manually

1. In SimiRouter, open [API key management](https://api.dwchainless.com/keys) page to copy the intended API key.
2. In LunaTranslator **Settings → Translation settings → Language models**, add an interface by copying the General language model interface template.
3. Open the added interface settings. Set **API endpoint address** to `https://api.dwchainless.com`, paste the copied key into **API Key**. Refresh models or enter an exact available model ID.
4. Save and enable the interface. Translate a short, non-sensitive passage, then verify the call in SimiRouter logs.

Do not expose keys in public screenshots. Labels vary by version; see the [LunaTranslator official documentation](https\://docs.lunatranslator.org/zh/guochandamoxing.html).