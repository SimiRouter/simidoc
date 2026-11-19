# Hermes 配置

## 准备工作

1. Hermes 已安装并可正常启动。
2. 在 SimiRouter 控制台已创建可用 API Key。
3. CC Switch 已安装。

<Callout type="info" title="">
  如果尚未安装 CC Switch，请先阅读 [CC Switch 安装与导入指南](/simidoc/zh/apps/cc-switch)。
</Callout>

## 在 CC Switch 配置 Hermes

1. 打开 CC Switch，在左侧应用列表中选择 **Hermes**；旧版本使用顶部页签。

![CC Switch 顶部切到 Hermes](/simidoc/assets/hermers/h1.png)

2. 点击 **添加**，新增自定义供应商后，返回 Hermes tab，选择启用。

![点击添加并填写供应商参数](/simidoc/assets/hermers/h2.png)

3. 打开终端，输入 `hermes desktop`，启动桌面应用，并发送简短消息测试。`--skip-build` 仅适用于已有桌面构建产物的开发环境，不用于首次启动。

![保存并启用供应商](/simidoc/assets/hermers/h4.png)

4. 也可在终端运行 `hermes --tui` 使用 TUI 模式。打开界面后发送一条简短消息，并在 SimiRouter 控制台核对对应的调用记录；仅显示 TUI 界面不能证明模型连接成功。

![保存并启用供应商](/simidoc/assets/hermers/h5.png)

## 常见问题

* `baseUrl` 未带 `/v1`：最常见导致模型列表不返回的原因。
* 模型 ID 不一致：模型名需与实际暴露模型完全匹配。
* 仍报鉴权/不可用：确认 API Key 与供应商绑定环境一致。

## 官方参考

[Hermes 桌面端 CLI 参考](https\://hermes-agent.nousresearch.com/docs/user-guide/desktop#cli-reference-hermes-desktop)。