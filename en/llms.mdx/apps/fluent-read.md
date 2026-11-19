# FluentRead configuration

<Callout type="info" title="">
  🌊 FluentRead is an open-source browser translation plugin dedicated to
  providing a native-like reading experience.
</Callout>

* Project Address\: [https\://github.com/FluentRead/FluentRead](https\://github.com/FluentRead/FluentRead)

## Core Features

### Smart Translation Engine

* **Multi-Engine Support**\: supports multiple translation engines
* **Traditional Translation**\: Microsoft Translate, Google Translate, DeepL Translate, etc.
* **AI Large Models**\: OpenAI, DeepSeek, Kimi, Ollama, etc.
* **Custom Engine**\: Supports custom translation service configuration

### Immersive Reading Experience

* **Bilingual Comparison**\: Original and translated text displayed side-by-side for easier reading
* **Selection Translation**\: Select any text to get instant translation results
* **One-Click Copy**\: Quickly copy translated text to improve reading efficiency
* **Full-Page Translation**\: One-click translation of the entire webpage with a floating button, no page refresh required

### Privacy and Customization

* **Data and privacy**\: Online translation and cloud models send the text to be translated to your configured service. Review that service’s data handling policy, and do not send sensitive information to an untrusted provider.
* **High Customization**\: Rich customization options to meet different scenario needs
* **Completely Free**\: Open-source and free, non-commercial project

## Installation Methods

| Browser     | Installation Method                                                                                                                                                                                                                                      |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Chrome**  | [Chrome Web Store](https\://chromewebstore.google.com/detail/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/djnlaiohfaaifbibleebjggkghlmcpcj?hl=zh-CN\&authuser=0) \| [Domestic Mirror](https\://www.crxsoso.com/webstore/detail/djnlaiohfaaifbibleebjggkghlmcpcj) |
| **Edge**    | [Edge Add-ons Store](https\://microsoftedge.microsoft.com/addons/detail/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/kakgmllfpjldjhcnkghpplmlbnmcoflp?hl=zh-CN)                                                                                                  |
| **Firefox** | [Firefox Add-ons Store](https\://addons.mozilla.org/zh-CN/firefox/addon/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/)                                                                                                                                           |

## Configuration Methods

### Manually Fill in Configuration in FluentRead

Open [API key management](https://api.dwchainless.com/keys) to copy the key, then open FluentRead settings and enter\:

| Configuration Item  | Content                                                     |
| ------------------- | ----------------------------------------------------------- |
| Translation Service | New API                                                     |
| Access Token        | The SimiRouter API key you copied                           |
| NewAPI endpoint     | `https://api.dwchainless.com`(without `/v1`)                |
| Model               | Select or enter an exact model ID available to your account |

Save and translate a short, non-sensitive passage, then check SimiRouter usage logs. Online translation sends the source text to the configured service.