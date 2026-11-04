# 安全政策

## 安全模型

LinuxRunner 在一个 iOS/iPadOS 应用内运行 Linux 程序。**平台沙箱才是安全边界。** Linux 账户、权限与客户端内存映射不能将恶意程序与应用本身或彼此隔离。

共享文件夹有目的地授予选定的文件访问权限；Linux 程序可以通过兼容层使用设备网络。实验性图形桥接受客户端渲染请求。不要把环境当作不受信任软件或敏感机密的安全容器。

发行版安装器使用经签名校验的包数据与 TLS。请保持这些检查开启。包修复会调用真实的包工具与维护者脚本；元数据检查点不提供完整回滚。

## 私密报告漏洞

请使用 [GitHub 的私有漏洞报告表单](https://github.com/mxhm11cr/LinuxRunner/security/advisories/new)。公共仓库已启用私有报告；若表单不可用，请勿在普通 issue 中发布利用细节、凭据或私有数据。

请附上应用的版本/build、已知时的源码/产物身份、设备/系统、发行版与最小复现。不承诺响应时限。普通崩溃与兼容性问题可通过 [Issues](https://github.com/mxhm11cr/LinuxRunner/issues) 报告。

## 诊断隐私

报告会使用有界日志与脱敏，但导出的文件名、应用输出与截图仍可能包含个人信息。分享前请审阅文件。切勿发布密码、签名材料、令牌或私人消息。

## 上游

LinuxRunner 派生自 [iSH](https://github.com/ish-app/ish)，经由 [ios-linuxkit](https://github.com/rcarmo/ios-linuxkit)。它们的上游安全政策与保留的源码声明继续适用于其各自组件。
