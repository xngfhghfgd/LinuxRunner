# 第三方声明

LinuxRunner 派生自 iSH（Theodore Dubois 及贡献者），经由 ios-linuxkit（Rui Carmo 及贡献者）。请保留 [LICENSE.md](LICENSE.md)、[LICENSE.IOS](LICENSE.IOS)、[完整 GPL 文本](licenses/)、所有源码版权声明以及应用内的"声明与致谢"。合并后的应用整体受 GPL-3.0 约束；上游贡献特定的 GPL-2.0 条款予以保留，但不会扩展覆盖到 LinuxRunner 的每一处新增。

## 应用内的组件

| 组件 | 保留源码 / 声明位置 | 条款 |
| --- | --- | --- |
| libarchive | `deps/libarchive`，固定版本记录于 `SOURCE_ORIGIN.txt` | BSD 风格；逐文件条款见 COPYING |
| glslang | `deps/glslang` 与 `GUISupport.bundle/shader-compiler-notices.txt` | 多许可证（含 BSD 与 Apache-2.0）；请保留完整 LICENSE.txt |
| SPIRV-Cross | `deps/spirv-cross` 与 shader-compiler-notices.txt | Apache-2.0；保留声明 |
| hterm / libapps | `deps/libapps` | BSD-3-Clause 与组件特定条款 |
| xterm.js 及其插件 | `app/terminal/xterm-vendor/LICENSES.md`、VENDORED.txt | MIT；包版本随捆绑记录 |
| Ghostty Web | `app/terminal/ghostty-web-VENDORED.txt`、terminal-notices.txt | MIT；vendor 记录描述本地 WKWebView 补丁 |
| Fira Code 与 JetBrains Mono Nerd Fonts | 字体 VENDORED.txt 文件与 terminal-notices.txt | SIL OFL-1.1 及相关 Nerd Fonts 声明 |
| LZMA API 头文件 | `deps/lzma-api/COPYING`、provenance.json | 头文件特定的公有域声明；系统 liblzma 单独链接 |
| SQLite 与 Apple 系统库 | 平台库 | 各自的上游/平台条款 |
| Mesa 演示源码 | `tests/linuxrunner/gpu/mesa-demos`，校验和与逐文件声明 | 源码与 mesa-demos-notice.txt 中保留 MIT 风格声明 |
| LinuxRunner 客户端图形与工具二进制 | `graphics/`、GUI 捆绑源码与构建脚本 | 属于受 GPL 约束的衍生作品；gpu-bridge-notice.txt 与 gpu-glx-notice.txt |

应用捆绑了 `gpu-glx-notice.txt`、`gpu-bridge-notice.txt`、`mesa-demos-notice.txt`、`shader-compiler-notices.txt`、`terminal-notices.txt` 与 xterm 的 `LICENSES.md`。请在源码与打包应用中保留这些声明。

自定义的 LinuxRunner 壁纸与活动图标保留了生成脚本与原始 SVG 几何。继承的 iSH 备用图标保留其原始文件。截图中可见的 KDE 壁纸与应用美术资产归属各自项目。

## 捆绑的 Alpine minirootfs

IPA 包含 Alpine 3.24.2 aarch64，根存档 SHA-256 为 `9bf70a7f18ea44094cbb5f70c58f9af129c8214745743db0e68e5502cc2ce773`。各包保留其自身许可证。APK 数据库是权威的包/版本清单；发布审查单独记录。

受 GPL 覆盖的包组包括 BusyBox、apk-tools、alpine-baselayout 与 scanelf；musl-utils 含混合许可证部分。其他组件包括 musl（MIT）、OpenSSL（Apache-2.0）、zlib（Zlib）、Alpine 密钥/发布元数据（MIT）以及证书数据（MPL-2.0 / MIT）。该根存档是聚合，不是把 Alpine 包重新许可到应用许可证之下。

捆绑的 Alpine 组件保留其自身的源码分发要求。其包版本与许可证字段记录在根文件系统的 APK 数据库中。

rootfs 补丁捆绑包含 `wasm-polyfill.js` 与 `fetch-polyfill.js`。前者是对 llhttp 解析器的重新实现。上游 llhttp 的 MIT 声明保留在 `licenses/llhttp-MIT.txt` 作为解析器接口署名。LinuxRunner 的 polyfill 源码保留在 rootfs 补丁捆绑中。

## 下载的 Linux 软件

Debian 与 Arch Linux ARM 包以及额外的 Alpine 包由用户设备从发行版镜像下载。它们保留各自的许可证与声明（Debian 参见 `/usr/share/doc/<包>/copyright`）。KDE、Mesa、浏览器与其他已安装程序是独立项目。

## 源码可得性

应用源码、构建脚本与依赖版本保留在仓库中。[SOURCE_ORIGIN.txt](SOURCE_ORIGIN.txt) 记录发布谱系与确切的依赖提交。GitHub 的自动源码归档不包含子模块内容；从克隆构建时请初始化固定版本子模块。捆绑二进制的源码分发要求与用户之后下载的包许可证相互独立。v1.0.1 发布的源码资源包含当前应用快照、固定的构建依赖、匹配的 Alpine 包配方与经校验的源码输入，以及匹配的 Ghostty Web/Ghostty 源码。捆绑根文件系统与终端渲染器按这些输入校验。
