# LunaTranslator配置

<Callout type="info" title="">
  LunaTranslator
  是一款开源免费的视觉小说（GalGame）翻译器，致力于提供母语级别的视觉小说游玩体验。
</Callout>

* 项目地址：[https\://github.com/HIllya51/LunaTranslator](https\://github.com/HIllya51/LunaTranslator)
* 项目文档：[https\://docs.lunatranslator.org](https\://docs.lunatranslator.org/zh/README.html)

## 功能支持

* **HOOK** 主要使用HOOK提取游戏文本，用于支持的视觉小说；具体兼容情况见官方文档

* **内嵌翻译** 部分游戏还可以直接内嵌翻译到游戏中，以获取沉浸式体验

* **HOOK模拟器** 对支持的模拟器和游戏，通过 HOOK 读取游戏文本

* **OCR** 内置较高精度的OCR模型，并支持许多其他在线&离线OCR引擎，以便灵活的读取任意文本

* **丰富的翻译接口** 可配置多种大语言模型与离线翻译接口

* **语言学习** 支持日语分词及假名注音，支持AnkiConnect，支持Yomitan插件

* **语音合成** 支持大量在线&离线语音合成引擎

* **语音识别** 在Windows 10和Windows 11上，可以使用Windows语音识别。

## 安装方式

在 [LunaTranslator 文档- 下载 & 启动 & 更新](https\://docs.lunatranslator.org/zh/README.html) 进行下载安装

## 在 LunaTranslator 手动接入 SimiRouter

1. 在 SimiRouter [API 密钥管理](https://api.dwchainless.com/keys)页面复制要使用的 API Key。
2. 在 LunaTranslator 的 **设置 → 翻译设置 → 大模型**中选择添加，复制「大模型通用接口」模板并新增接口。
3. 打开新增接口的设置，**API 接口地址**填写 `https://api.dwchainless.com`，**API Key** 粘贴复制的密钥；刷新模型列表或输入账户可用的完整模型 ID。
4. 保存并启用该接口。先翻译一小段非敏感文本，再到 SimiRouter 使用日志核对调用记录。

不要将密钥放在公开截图中。不同版本的选项名称可能略有差异；详细设置参见 [LunaTranslator 官方文档](https\://docs.lunatranslator.org/zh/guochandamoxing.html)。