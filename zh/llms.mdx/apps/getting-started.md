# 注册 SimiRouter Key

这篇指南介绍如何注册或登录 SimiRouter、创建 API Key，并完成第一次调用。已有账户可以直接登录，具体客户端操作和 API 参数分别放在对应文档中。

## 1. 注册或登录 SimiRouter

前往 [注册页面](https://api.dwchainless.com/sign-up) 创建账户；已有账户可直接 [登录](https://api.dwchainless.com/sign-in)。注册方式与是否开放注册以页面实际显示为准。

登录后打开 [钱包](https://api.dwchainless.com/wallet)，确认账户有可用额度，且所选模型在账户分组与密钥权限内。需要充值或使用兑换码时，按钱包页的提示操作；套餐、到账额度和有效期以当前页面为准，不要重复付款。

## 2. 创建 API 密钥

打开 [API 密钥管理](https://api.dwchainless.com/keys)，选择「创建密钥」。按需设置分组、模型权限、额度和有效期；不确定的选项先核对页面说明，再保存并复制密钥。

![API 密钥管理页面与创建入口](/simidoc/assets/start/start5.png)

<Callout type="warn" title="保护密钥">
  API 密钥代表调用权限。不要放进公开仓库、截图或日志，不要发给不可信的应用；怀疑泄露时立即撤销并重新创建。
</Callout>

## 3. 分清三项接入信息

| 信息                | 用途       | 注意                                         |
| ----------------- | -------- | ------------------------------------------ |
| API 地址 / Base URL | 决定请求发到哪里 | 按客户端教程填写；有的需要 `/v1`，有的需要根地址，不要重复追加路径。      |
| API Key           | 验证调用权限   | 使用刚创建的密钥，不是登录密码。                           |
| 模型名称              | 选择调用的模型  | 在 [模型广场](https://api.dwchainless.com/zh/pricing/) 复制完整模型 ID；名称、分组与权限需要匹配。 |

接口地址、密钥和模型名称是三个独立字段；不要把密钥拼进地址。

## 4. 选择正在使用的客户端

* [Codex 桌面端](/simidoc/zh/apps/codex-desktop)：桌面编码工作流。
* [Codex CLI](/simidoc/zh/apps/installation/codex-cli)：命令行安装与接入。
* [Claude Code](/simidoc/zh/apps/installation/claude-code)：安装、环境配置与使用。
* [WorkBuddy](/simidoc/zh/apps/workbuddy)：桌面自定义模型接入。
* [API 脚本](/simidoc/zh/apps/api-script)：通过请求示例集成自己的程序。

每个客户端的字段与协议不同，以对应教程为准；不能把一个客户端的配置文件直接套给另一个。

## 5. 发起小规模测试并核对记录

保存配置后，先发送一条简短请求。再打开 [使用日志](https://api.dwchainless.com/usage-logs/common)，核对请求时间、实际渠道、模型、状态和消耗。超级管理员可查看全局日志；管理员可查看自己的请求、充值、管理操作和错误日志；普通用户只能查看自己的请求、充值及管理操作相关日志，不能查看错误日志。需要汇总趋势时查看 [数据看板](https://api.dwchainless.com/dashboard)。

模型能回复，只能说明这次请求返回了结果；不能只凭回复内容确认实际路由。失败时，先核对地址、密钥、完整模型 ID 和分组权限，再根据具体错误与请求 ID 排查。向客服提供脱敏信息，不要附上密钥。