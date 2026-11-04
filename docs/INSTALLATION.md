# 安装 LinuxRunner

安装 LinuxRunner 与在其中安装 Linux 是两个独立步骤。先从 IPA 开始，然后按[安装 Linux](GETTING_STARTED.md)操作。

## 系统要求

- ARM64 的 iPhone 或 iPad。应用部署目标为 iOS/iPadOS 15.0；这不代表每个机型或系统版本都经过验证。
- 供发行版与应用使用的存储空间，以及下载包所需的网络连接。设置界面会显示可用空间与安装估计。
- 一种兼容的 IPA 签名/侧载方式。LinuxRunner 的正常发布版不需要越狱或 JIT。

维护者已在实体 iPhone 上测试 build 897，并确认了实体 iPad 测试。此前报告的 iPhone 11/iOS 17 启动黑屏问题仍未解决。

## 下载、签名并打开

1. 打开 [GitHub Releases](https://github.com/mxhm11cr/LinuxRunner/releases/latest)，从**资源**中下载 IPA。
2. 签名前，请将其文件大小与 SHA-256 同该发布公布值比对。
3. 使用你偏好的兼容工具安装，例如 [Sideloadly](https://sideloadly.io/) 或 [AltStore Classic](https://altstore.io/)。
4. 打开 LinuxRunner，按[快速上手 — 在 LinuxRunner 中安装 Linux](GETTING_STARTED.md)继续。

v1.0.1 构建脚本的**未签名**模式指的是*没有 Apple 签名身份/描述文件*。它会添加 ad-hoc 代码签名和标准 ZIP 布局，供工具替换或处理。仅 ad-hoc 签名不足以授权在实体设备上正常安装。签名要求、更新周期与工具兼容性取决于所选方式与账户。没有任何侧载服务保证可用。

App Group 访问是可选的。提供该授权时应用使用 `group.dev.linuxrunner.app`，否则使用私有应用存储。正常 **LinuxRunner** scheme 不需要 JIT 授权。不要把可选的开发者执行引擎实验与普通发布要求混淆。

## 校验下载

使用该 release 公布的、对应实际下载文件名的校验和：

```sh
shasum -a 256 "$IPA_FILE"
```

这里 `IPA_FILE` 是包含已下载 IPA 路径的本地变量。在 Windows PowerShell 中，对该文件使用 `Get-FileHash -Algorithm SHA256`。签名会修改文件，所以请先比对原始下载。

配合对应的源码检出与 Python 3，还可以检查其包结构：

```sh
python3 scripts/validate-ipa.py "$IPA_FILE" --expect-sha256 "$PUBLISHED_SHA256"
```

这些检查能发现存档/哈希问题；但不能证明每个安装器或设备都会接受。

## 更新时不丢失环境

备份重要 Linux 文件，保留旧版 IPA，并保持相同的 bundle identifier 与 App Group 配置。改变应用的签名方式可能改变可访问的存储容器。不要通过删除应用来排查环境缺失。在相同应用身份上重装可能保留数据，但身份或描述文件/容器变化可能导致无法访问。

若安装器报告 ZIP/IPA 无效或找不到中央目录结尾记录，请先校验下载再更换签名工具。[故障排查](TROUBLESHOOTING.md#安装器提示-ipa-无效)
