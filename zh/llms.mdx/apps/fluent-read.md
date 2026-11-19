# FluentRead配置

<Callout type="info" title="">
  🌊
  流畅阅读（FluentRead）是一款开源浏览器翻译插件，致力于提供母语般的阅读体验。
</Callout>

* 项目地址：[https\://github.com/FluentRead/FluentRead](https\://github.com/FluentRead/FluentRead)

## 核心特性

### 智能翻译引擎

* **多引擎支持**：支持多种翻译引擎
* **传统翻译**：微软翻译、谷歌翻译、DeepL翻译等
* **AI 大模型**：OpenAI、DeepSeek、Kimi、Ollama等
* **自定义引擎**：支持自定义翻译服务配置

### 沉浸式阅读体验

* **双语对照**：原文与译文并列显示，阅读更轻松
* **划词翻译**：选中任意文本，即时获得翻译结果
* **一键复制**：快速复制译文，提高阅读效率
* **全文翻译**：悬浮球一键翻译整个网页，无需刷新页面

### 隐私与定制

* **数据与隐私**：使用在线翻译或云端模型时，待翻译内容会发送到您配置的服务。请核对该服务的数据处理规则，不要将敏感信息发送给未经信任的提供商。
* **高度定制**：丰富的自定义选项，满足不同场景需求
* **完全免费**：开源免费，非商业化项目

## 安装方式

| 浏览器         | 安装方式                                                                                                                                                                                                                                     |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Chrome**  | [Chrome 应用商店](https\://chromewebstore.google.com/detail/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/djnlaiohfaaifbibleebjggkghlmcpcj?hl=zh-CN\&authuser=0) \| [国内镜像](https\://www.crxsoso.com/webstore/detail/djnlaiohfaaifbibleebjggkghlmcpcj) |
| **Edge**    | [Edge 应用商店](https\://microsoftedge.microsoft.com/addons/detail/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/kakgmllfpjldjhcnkghpplmlbnmcoflp?hl=zh-CN)                                                                                           |
| **Firefox** | [Firefox 附加组件商店](https\://addons.mozilla.org/zh-CN/firefox/addon/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/)                                                                                                                                  |

## 配置方法

### 在流畅阅读中手动填写配置

在 [API 密钥管理](https://api.dwchainless.com/keys)页面复制密钥，打开流畅阅读的设置并填写：

| 配置项       | 内容                                      |
| --------- | --------------------------------------- |
| 翻译服务      | New API                                 |
| 访问令牌      | 刚复制的 SimiRouter API 密钥                  |
| NewAPI 接口 | `https://api.dwchainless.com`（不带 `/v1`） |
| 模型        | 选择或填写账户可用的完整模型 ID                       |

保存后先翻译一小段非敏感文本，再到 SimiRouter 使用日志核对调用记录。在线翻译会向所配置服务发送待翻译内容。