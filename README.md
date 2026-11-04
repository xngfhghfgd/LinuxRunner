<p align="center">
  <img src="assets/branding/linuxrunner-icon.svg" alt="LinuxRunner 应用图标" width="160">
</p>

<h1 align="center">LinuxRunner</h1>
<h3 align="center">在 iPhone 和 iPad 上运行 Linux。</h3>

<p align="center">在 iOS 和 iPadOS 上运行 ARM64 Linux 用户空间、终端与桌面应用程序。</p>

<p align="center">
  <img src="assets/branding/platform-badge.svg" alt="平台：iOS 和 iPadOS">
  <img src="assets/branding/architecture-badge.svg" alt="客户机架构：ARM64">
  <a href="LICENSE.md"><img src="assets/branding/license-badge.svg" alt="许可证：GPL-3.0"></a>
</p>

LinuxRunner 使用自定义的 ARM64 解释器和 Linux 兼容层来加载 Linux 程序、实现其系统调用，并在受支持的设备上将其连接到存储、网络和图形桌面。

**无需越狱。无需虚拟机。发布版构建不需要 JIT。**

[下载最新 release](https://github.com/mxhm11cr/LinuxRunner/releases/latest) · [安装 Linux](docs/GETTING_STARTED.md) · [故障排查](docs/TROUBLESHOOTING.md)

[![LinuxRunner 中的 KDE Plasma 与 Dolphin](assets/screenshots/linuxrunner-dolphin.png)](assets/screenshots/linuxrunner-dolphin.png)

**KDE Plasma** — 一个实验性的 Debian 桌面选项。

<table>
<tr>
<td align="center"><a href="assets/screenshots/linuxrunner-home.png"><img src="assets/screenshots/linuxrunner-home.png" alt="LinuxRunner 主页" width="220"></a><br><b>LinuxRunner</b></td>
<td align="center"><a href="assets/screenshots/linuxrunner-settings.png"><img src="assets/screenshots/linuxrunner-settings.png" alt="LinuxRunner 设置" width="220"></a><br><b>设置</b></td>
</tr>
<tr>
<td align="center"><a href="assets/screenshots/linuxrunner-firefox.png"><img src="assets/screenshots/linuxrunner-firefox.png" alt="显示 example.com 的 Firefox" width="420"></a><br><b>Firefox</b></td>
<td align="center"><a href="assets/screenshots/linuxrunner-blender-viewport.jpg"><img src="assets/screenshots/linuxrunner-blender-viewport.jpg" alt="Blender 视口" width="420"></a><br><b>Blender</b></td>
</tr>
</table>

LinuxRunner 在 iPhone 上的表现：KDE Plasma、Firefox、Blender 和 Arch Linux ARM。下面 Arch 的截图展示的是 Telegram Desktop。设置流程和 iPad 的截图将在提供后补充。

### Arch Linux ARM 上的 Telegram Desktop

<p align="center">
  <a href="assets/screenshots/arch-telegram-iphone.jpg"><img src="assets/screenshots/arch-telegram-iphone.jpg" alt="iPhone 上 LinuxRunner 中 Arch Linux ARM 的 Telegram Desktop 欢迎界面" width="360"></a>
</p>

**Telegram Desktop** — 已在 Arch Linux ARM 上测试：登录、发消息和通话。所附 iPhone 截图展示的是其欢迎界面。

## 亮点

- **三种 Linux 发行版：** Debian GNU/Linux ARM64、Arch Linux ARM 和 Alpine Linux ARM64，各自拥有独立的包与文件。
- **一个 Linux 终端：**  shells、标准用户账户、包管理器以及可用的 ARM64 命令行工具。
- **Linux 桌面与应用：** 带窗口、面板和文件管理的 X11 桌面；Debian 上为实验性 KDE Plasma。
- **触摸、键盘与指针输入：** 屏幕操作控件、硬件键盘转发以及支持的鼠标/触控板事件。
- **文件与网络：** 导入/导出、可选的共享文件夹，以及通过设备网络进行的 Linux socket 通信（受 iOS 限制约束）。
- **1.0.1 新增：** iPad 桌面适配、统一的发行版安装流程、Arch 包恢复以及桌面/会话改进。[更新日志](CHANGELOG.md)

## 支持的设备

| 设备 | 配置 | 验证情况 |
| --- | --- | --- |
| iPhone | ARM64；iOS 15.0 部署目标；竖屏及两种横屏方向 | 维护者报告 build 897 在一台实体 iPhone 上运行了 Arch、其图形桌面与图形应用。 |
| iPad | ARM64；iPadOS 15.0 部署目标；四种方向 | iPad 支持自 v1.0.1 起提供，并已在实体 iPad 上测试。 |

部署目标描述的是构建配置，并非对每台设备或每个系统版本的保证。可用的内存与存储会影响实际使用。此前报告的 iPhone 11/iOS 17 启动黑屏问题仍未解决。

### LinuxRunner 在 iPad 上

更大的屏幕为 Linux 窗口提供了更多空间。查看器会把新的**适配屏幕**会话调整为当前窗口大小，并提供**适配屏幕**、**实际大小**、触摸手势、硬件键盘转发和指针操作。桌面操作还支持 Control–Option–Command 快捷键。屏幕旋转和窗口大小由界面处理；修改 Linux 显示分辨率会在下次启动桌面时生效。iPad 支持已由维护者在实体设备上测试通过。[操作与快捷键](docs/GETTING_STARTED.md#11-launch-and-use-the-desktop)

## 支持的 Linux 发行版

| 发行版 | 终端 | 包管理器 | 桌面 | 状态 |
| --- | --- | --- | --- | --- |
| Debian GNU/Linux 13 ARM64 | 支持 | `apt` / `dpkg` | LinuxRunner 桌面；KDE Plasma 为实验性 | 推荐的起点 |
| Arch Linux ARM | 支持 | `pacman` | Openbox 配 LXQt 面板和 PCManFM-Qt | 实验性；维护者报告在 iPhone build 897 上桌面运行成功 |
| Alpine Linux 3.24 ARM64 | 支持 | `apk` | 桌面路径存在；兼容性仍为实验性 | 最适合较小的终端环境 |

Arch 使用的是部分 LXQt 组件，并非完整 LXQt 会话的承诺。当前 Arch 的 Plasma 和 Wayland 会话不可用。多个环境可以共存；每次启动应用只有一个运行时处于激活状态。

## 安装

1. 从 [GitHub Releases](https://github.com/mxhm11cr/LinuxRunner/releases/latest) 下载 LinuxRunner 的 IPA。
2. 使用你偏好的兼容 IPA 侧载工具安装，例如 [Sideloadly](https://sideloadly.io/) 或 [AltStore Classic](https://altstore.io/)。
3. 在 iPhone 或 iPad 上打开 LinuxRunner。
4. 按照**安装 Linux…**流程在应用内安装一个发行版。

签名与兼容性取决于所选方式。v1.0.1 的打包脚本生成的是经 ad-hoc 签名、不带 Apple 描述文件的 IPA；安装所需的签名/描述文件需由兼容工具提供。更新时请保持相同的应用身份与存储配置。[下载验证与签名](docs/INSTALLATION.md)

## 快速上手 — 在 LinuxRunner 中安装 Linux

安装 IPA 只是安装应用本体。**你还需要在其中安装或配置一个 Linux 发行版。**

打开**发行版 → 安装 Linux… → 继续**。选择 Debian、Arch 或 Alpine，然后继续到该发行版的安装按钮。按照提示重启应用，创建或选择一个 Linux 账户，需要时安装桌面组件。用**主页 → 终端**进入 shell，或用**打开桌面** / **恢复桌面**进入图形会话。

[分步指南](docs/GETTING_STARTED.md)涵盖已有环境、账户选项、安装进度、终端命令、包安装与桌面操作，使用当前应用中的实际标签文案。

## 桌面环境与应用程序

LinuxRunner 桌面是默认的轻量 X11 会话。在 Debian 上可以之后通过**设置 → 桌面环境**安装 KDE Plasma。在 Arch 上，请使用安装流程提供的 Openbox/LXQt 组件桌面。

通过**主页 → 应用管理器**或发行版自身的包管理器安装软件。通过**主页 → 应用程序**启动已发现的图形应用。日常工作请使用普通 Linux 用户；带管理员权限创建的账户可以使用 `sudo`。

**Telegram Desktop 已在 build 897 的 Arch Linux ARM 上完成测试，包括登录、发消息与通话。** 此前提供的截图还展示了 Dolphin、Firefox 和 Blender。[应用兼容性](docs/COMPATIBILITY.md)

## LinuxRunner 的工作原理

可执行加载器映射 ARM64 Linux ELF 程序及其动态库。解释器通过预编译的主机例程执行受支持的客户端指令。用户空间兼容层实现 Linux 系统调用、进程、线程、信号、内存映射与文件系统元数据。Linux socket 经由平台网络 API 连接。

图形应用使用 X11：Xvfb 与 x11vnc 为原生桌面查看器提供画面，查看器转发显示更新与输入事件。Mesa 提供软件 OpenGL；实验性的 Metal 桥接可加速部分渲染路径。这是带指令解释的用户空间兼容，而非全系统模拟或硬件虚拟化。LinuxRunner 不启动 Linux 内核，也不原生执行任意客户代码。[架构说明](docs/ARCHITECTURE.md)

## 兼容性与限制

- 仅支持 ARM64 Linux 程序；x86/x86-64 应用与 Linux 内核启动均不受支持。
- 系统调用与图形覆盖率不完整。包可用不代表应用兼容。
- Arch 桌面、Debian 的 KDE Plasma 与 Metal 加速均为实验性；资源占用大的程序可能较慢或超出设备内存限制。
- 不支持 Wayland 会话、以 systemd 作为 init、内核模块或常规 Linux 容器。
- iOS/iPadOS 可能挂起或终止应用。**完成**只在应用内部保留正在运行的桌面；应用被终止时不会保留正在运行的 Linux 进程。
- Linux 账户与权限不能将恶意软件与应用程序隔离开。平台沙箱才是安全边界。

参见[兼容性](docs/COMPATIBILITY.md)、[已知限制](docs/KNOWN_LIMITATIONS.md)与[安全政策](SECURITY.md)。

## 故障排查与问题报告

请先阅读[故障排查](docs/TROUBLESHOOTING.md)。应用管理器的**修复中心**提供诊断与包修复；**设置 → 高级 → 导出桌面报告**可收集启动/会话信息。分享前请先检查报告中是否含个人信息。

附上设备、系统、应用版本/build、发行版与复现步骤，[报告一个可复现的问题](https://github.com/mxhm11cr/LinuxRunner/issues/new/choose)。即使应用不完全兼容，启动报告也很有价值。

## 构建与贡献

多数用户直接安装 IPA。开发者可以在 `iSH.xcodeproj` 中构建 **LinuxRunner** scheme；工具要求、固定版本依赖与验证方法见[构建指南](docs/BUILDING.md)。[贡献指南](CONTRIBUTING.md)说明了聚焦型改动与有价值的兼容性报告。

## 许可证与致谢

由 **Leminos（[mxhm11cr](https://github.com/mxhm11cr)）** 维护。LinuxRunner 派生自 [iSH](https://github.com/ish-app/ish)（Theodore Dubois 及贡献者），经由 [ios-linuxkit](https://github.com/rcarmo/ios-linuxkit)（Rui Carmo 及贡献者）。

合并后的应用整体受 GPL-3.0 约束。请在 [LICENSE.md](LICENSE.md) 与 [LICENSE.IOS](LICENSE.IOS) 中保留上游贡献的特定条款、版权署名及 App Store 条款。第三方软件保留其自身许可证；参见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。Linux 发行版、桌面与应用属于各自项目的成果。
