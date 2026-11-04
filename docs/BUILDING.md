# 构建 LinuxRunner

普通安装使用可下载的 IPA。本指南用于从源码构建 **LinuxRunner** 发布 scheme；开发者执行引擎实验使用单独目标。

## 系统要求

使用 macOS、完整 Xcode 及其 iOS SDK，并在 `PATH` 中提供 Git、Python 3、Meson、Ninja、CMake 与 `ld.lld`。客户端 ARM64 vDSO 需要 LLVM 的 ELF 链接器；若无法构建，发布构建会失败。系统工具还包括 `curl`、`tar`、`file`、`shasum`、`ditto`、`codesign` 以及 Info-ZIP `zip`。

当前准备构建使用了 Xcode 27.1 / iOS SDK 27.1、Meson 1.12.1、Ninja 1.13.2 与 CMake 4.4.4。其他工具链版本未经本任务验证。部署目标为 iOS/iPadOS 15.0。

## 获取源码与固定版本依赖

```sh
git clone https://github.com/mxhm11cr/LinuxRunner.git
cd LinuxRunner
git submodule update --init --recursive --checkout -- deps/libapps deps/libarchive deps/glslang deps/spirv-cross
```

这四个子模块提供终端资源、存档支持与着色器编译。`deps/linux` 是继承的可选内核构建 gitlink；应用发布版不使用也不启动它。前置检查器只检查四个生效依赖，而不要求那个未使用的检出。

复现该发布版时请选择 `v1.0.1` 标签。切换版本前先保护好自己未提交的改动。

## 检查与构建

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
scripts/bootstrap-macos.sh
scripts/build-ipa.sh --unsigned
python3 scripts/verify-ipa.py build/releases
```

归档会生成 `build/releases/LinuxRunner.ipa`、保留的 `.xcarchive`/符号、签名状态、SHA-256、源码指纹与验证报告。`RELEASE_DIR` 与 `ARTIFACT_NAME` 可以选择不同的输出目录/名称。验证重命名产物时使用相同的 `ARTIFACT_NAME`。

**未签名**模式创建的是 ad-hoc 签名，而非 Apple 描述文件应用。设备安装授权需由兼容的签名/侧载工具提供。构建会校验 rootfs 校验和、GUI 资源清单、包结构与内嵌 vDSO。`verify-ipa.py` 还会把 IPA 可执行文件与保留归档比对、审计设备 Mach-O 映像并匹配符号。实体设备运行是另一项检查。

Alpine 3.24.2 aarch64 以固定 SHA-256 下载。`ROOTFS_CACHE` 可指向缓存归档；同样执行哈希校验。常规工具通过 `PATH` 解析。可选的 `LINUXRUNNER_TOOLCHAIN_ROOT` 支持继承的捆绑工具链布局；不需要维护者专用目录。

## 为你自己的构建签名

在 Xcode 中配置你自己的 Apple 账户、证书与描述文件，然后运行：

```sh
TEAM_ID=YOUR_TEAM_ID scripts/build-ipa.sh
```

不要提交证书、私钥或描述文件。默认 bundle identifier 是 `dev.linuxrunner.app`。由于支持私有容器存储，对 `group.dev.linuxrunner.app` 的 App Group 访问是可选的。更新已有安装时请保持应用身份与容器配置一致。

## 发布配置

`app/AppARM64.xcconfig` 设置版本 **1.0.1**、build **897**、ARM64 与部署目标 **15.0**。`app/iOS.xcconfig` 选择设备族 **1,2**。`app/Info.plist` 声明 iPhone 的竖屏/双横屏与 iPad 的四种方向。发布版使用 Asbestos 解释器，JIT 与动态发射均已禁用。仅 build 编号不足以区分每个开发候选版本；请同时记录源码版本与 IPA 校验和。

## 客户端工具与开发者运行时

IPA 会把保留的 Linux ARM64 工具二进制打包进 `app/LinuxRunner/GUISupport.bundle`；普通应用构建不会重建每个客户端工具。其源码/编译配方映射在 [bundled-guest-source-map.json](../licenses/bundled-guest-source-map.json)。分发时请保留相应声明与源码。

图形工具构建使用 `scripts/build-guest-mesa-metal.sh` 与 `scripts/build-guest-gles1.sh`，配合一次性 Debian ARM64 夹具、所需的 X11/OpenGL/EGL/GLES 开发包，以及 `GPU_ROOTFS` / `GPU_EXCHANGE`。只有在你确实要替换打包资源并重新生成其清单时才设置 `GPU_PACKAGE_ASSETS=1`。

命令行运行时：

```sh
meson setup build/host -Dengine=asbestos -Dguest_arch=arm64 -Djit=false -Djit_emit=false -Dcli_aot=
ninja -C build/host ish
python3 scripts/generate-gui-support-manifest.py --check
```

破坏性测试请使用一次性夹具。参见[架构](ARCHITECTURE.md)、[贡献指南](../CONTRIBUTING.md)与[第三方声明](../THIRD_PARTY_NOTICES.md)。GitHub 自动源码归档不包含子模块内容；请初始化固定版本或使用单独提供的完整源码归档。
