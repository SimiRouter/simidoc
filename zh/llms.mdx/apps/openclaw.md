# OpenClaw 配置

## 准备工作

1. OpenClaw 已安装并可正常启动。
2. 在 SimiRouter 控制台已创建可用 API Key。
3. CC Switch 已安装。

<Callout type="info" title="">
  如果尚未安装 CC Switch，请先阅读 [CC Switch 安装与导入指南](/simidoc/zh/apps/cc-switch)。
</Callout>

## 在 CC Switch 配置 OpenClaw

1. 打开 CC Switch，在左侧应用列表中选择 **OpenClaw**；旧版本使用顶部页签。

![CC Switch 顶部切到 OpenClaw](/simidoc/assets/cc/cc1.png)

2. 点击 **添加**，新增自定义供应商。

![点击添加并填写供应商参数](/simidoc/assets/cc/cc2.png)

3. 保存后，确认供应商已启用。在终端运行 `openclaw onboard`，按提示完成 OpenClaw 的初始配置与配对。

![保存并启用供应商](/simidoc/assets/cc/cc4.png)

4. 发送一条简短消息，确认收到正常回复，再到 SimiRouter 控制台核对对应的调用记录。仅看到配置界面或截图中的红框，不能证明模型接入成功。
   ![保存并启用供应商](/simidoc/assets/cc/cc3.png)

## 常见问题

* `baseUrl` 未带 `/v1`：最常见导致模型列表不返回的原因。
* 模型 ID 不一致：模型名需与实际暴露模型完全匹配。
* 仍报鉴权/不可用：确认 API Key 与供应商绑定环境一致。
* 想看更详细日志：可使用前台运行方式 `openclaw gateway --port 18789` 查看启动日志。

## 官方参考

[CC Switch 官方项目](https\://github.com/farion1231/cc-switch)。