# 为 LinuxRunner 贡献代码

LinuxRunner 派生自 iSH，经由 ios-linuxkit。请保留现有的[许可证](LICENSE.md)、[App Store 条款](LICENSE.IOS)、版权声明与[第三方署名](THIRD_PARTY_NOTICES.md)。

## 报告 bug 或兼容性结果

请使用 [GitHub Issues](https://github.com/mxhm11cr/LinuxRunner/issues/new/choose)。附上设备型号、iOS/iPadOS 版本、LinuxRunner 版本/build（设置 → 关于 LinuxRunner）、发行版、包版本与桌面/图形模式。描述可复现的步骤、预期行为与首个相关错误。

请区分"成功启动"、"基础交互"与更长的功能测试。有用时附上诊断报告；[故障排查](docs/TROUBLESHOOTING.md#收集日志并报告问题)说明了导出入口。分享前请审阅日志与截图中的消息、账户标识、地址、令牌与私密路径。漏洞请通过[私有安全渠道](SECURITY.md)报告，而不是公开 issue。

## 提出改动

先阅读[架构](docs/ARCHITECTURE.md)与[构建](docs/BUILDING.md)。保持每个 pull request 聚焦，保留已有发行版，并说明改动的行为与验证方式。运行时改动请使用有实际意义的测试并说明真实测试环境；不要把开发环境测试包装成实体设备结论。

遵循周边 C、Objective-C、Swift 与 shell 风格。不要提交签名凭据、描述文件、私有日志、个人数据或无关二进制。对第三方代码做许可证检查，并保留其首选源码/构建说明与声明。

## 文档与截图

请对照当前界面核对说明。[截图交接清单](assets/screenshots/README.md)列出缺失截图及其放置位置。使用真实的应用截图、准确的来源与简短的软件说明。不要伪造截图，也不要声称通用的设备/应用支持。
