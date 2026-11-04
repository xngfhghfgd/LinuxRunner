import SwiftUI

// Guided setup: Welcome → Distribution → Install Linux → (restart into it) →
// Account → Desktop → Finish → Open Desktop. Uses the verified installers, the
// native account setup (password hashed in the app; tools installed if absent)
// and the same desktop-profile repair as Open Desktop. It opens by itself only
// when no Linux environment exists; existing environments, homes and accounts
// are never modified, and an existing account can be used as it is.
enum SetupStep: String { case welcome, distribution, install, relaunch, account, desktop, done }

struct SetupWizardView: View {
    @ObservedObject var manager: EnvironmentManager
    var openDesktop: () -> Void
    @Environment(\.dismiss) private var dismiss
    @AppStorage("LinuxRunnerSetup.step") private var stepRaw = SetupStep.welcome.rawValue
    @AppStorage("LinuxRunnerSetup.distribution") private var distribution = "debian"
    @AppStorage("LinuxRunnerSetup.root") private var setupRoot = ""
    @StateObject private var debian = DebianInstaller()
    @StateObject private var arch = ArchInstaller()
    @State private var username = ""
    @State private var password = ""
    @State private var confirmation = ""
    @State private var administrator = true
    @State private var working: String?
    @State private var problem: String?
    @State private var desktopReady = false
    private var step: SetupStep { SetupStep(rawValue: stepRaw) ?? .welcome }

    var body: some View {
        NavigationView {
            Form { content }
                .navigationTitle(title)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button(step == .done ? "关闭" : "稍后") { dismiss() }.disabled(working != nil || debian.running || arch.running || manager.busy) } }
        }
        .navigationViewStyle(.stack)
        .overlay(alignment: .bottom) { InstallProgressCard() }
        .interactiveDismissDisabled(working != nil || debian.running || arch.running || manager.busy)
        .onAppear(perform: resume)
    }

    private var title: String {
        switch step {
        case .welcome: return "欢迎"; case .distribution: return "选择 Linux"; case .install: return "安装 Linux"
        case .relaunch: return "重启 LinuxRunner"; case .account: return "你的账户"; case .desktop: return "桌面"; case .done: return "就绪"
        }
    }

    @ViewBuilder private var content: some View {
        switch step {
        case .welcome:
            Section { Text("LinuxRunner 通过内置的自定义解释器在本设备上运行真实的 ARM64 Linux 程序 — 无需虚拟机。")
                Text("安装流程会安装 Linux、创建你的账户并准备图形桌面。之后可在设置中随时修改。").foregroundStyle(.secondary) }
            if !manager.environments.isEmpty { Section { Text("可配置已有环境或安装另一个发行版。你的文件与账户都会被保留。").font(.footnote) } }
            Section { Button("继续") { stepRaw = SetupStep.distribution.rawValue } }
        case .distribution:
            Section(footer: Text("推荐使用 Debian。Arch Linux ARM 提供滚动发布、pacman 与实验性 X11 桌面。Alpine 小巧，主要用于终端。不支持 Wayland。")) {
                Picker("发行版", selection: $distribution) { Text("Debian GNU/Linux 13 (ARM64) — 推荐").tag("debian"); Text("Arch Linux ARM (ARM64) — 实验性").tag("arch"); Text("Alpine Linux 3.24 (ARM64)").tag("alpine") }.pickerStyle(.inline).labelsHidden()
            }
            let installed = manager.environments.filter { ($0.distributionID ?? "alpine") == distribution }
            if !installed.isEmpty {
                Section("已安装") {
                    ForEach(installed) { environment in
                        Button("配置 " + environment.name) { configureExisting(environment) }
                    }
                    Text("使用现有环境、账户与文件。切换环境在重启后生效。").font(.footnote).foregroundStyle(.secondary)
                }
            }
            Section { Button(installed.isEmpty ? "继续" : "安装另一个环境") { stepRaw = SetupStep.install.rawValue } }
        case .install: install
        case .relaunch:
            Section { Text("Linux 已安装并选定。请完全关闭 LinuxRunner（在应用切换器中上滑移除）并重新打开 — 安装将在此处继续你的账户设置。") }
            Section { Text("iOS 每次启动应用只允许一个 Linux 运行时，因此需要重启一次。").font(.footnote).foregroundStyle(.secondary) }
        case .account: account
        case .desktop: desktop
        case .done:
            Section { Label("Linux 已就绪", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                Text("可随时从 包 › 应用目录 添加应用。").font(.footnote).foregroundStyle(.secondary) }
            Section { Button { stepRaw = SetupStep.welcome.rawValue; setupRoot = ""; dismiss(); openDesktop() } label: { Label("打开桌面", systemImage: "desktopcomputer").font(.headline) }.disabled(!LRRuntimeBridge.isRunning()) }
        }
        if let working { Section { HStack(spacing: 12) { ProgressView(); Text(working) } } }
        if let problem { Section { Text(problem).foregroundStyle(.red) } }
    }

    @ViewBuilder private var install: some View {
        let free = (try? LRRuntimeBridge.managedStorageURL().resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage) ?? 0
        let manifest = try? DebianManifest.load()
        let alpineBytes = Int64((try? Bundle.main.url(forResource: "root", withExtension: "tar.gz")?.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
        let download = distribution == "debian" ? (manifest?.downloadBytes ?? 0) : 0
        let installed = distribution == "debian" ? (manifest?.installedBytes ?? 0) : alpineBytes * 3
        Section("存储") {
            row("下载", distribution == "arch" ? "由签名包选择结果计算" : distribution == "debian" ? ByteCountFormatter.string(fromByteCount: download, countStyle: .file) : "无（已内置于应用中）")
            row(distribution == "debian" ? "已安装大小" : "已安装大小（估计）", distribution == "arch" ? "基础安装至少需要 1.5 GB 可用空间" : ByteCountFormatter.string(fromByteCount: installed, countStyle: .file))
            row("可用", ByteCountFormatter.string(fromByteCount: free, countStyle: .file))
        }
        if distribution == "debian" {
            Section {
                if debian.running { Text(debian.message); ProgressView(value: debian.fraction); Button("取消", role: .destructive) { debian.cancel() } }
                else { Button("安装 Debian") { startInstall() }.disabled(free < max(Int64(1 << 30), download + installed)) }
                if let failure = debian.failure { Text(failure).foregroundStyle(.red); Button("重试") { startInstall() } }
            } footer: { Text("官方 Debian 包，经 Debian 签名索引校验。桌面、声音与账户工具将在后续步骤安装。") }
        } else if distribution == "arch" {
            Section {
                if arch.running { Text(arch.message); ProgressView(value: arch.fraction); Button("取消", role: .destructive) { arch.cancel() } }
                else { Button("安装 Arch Linux ARM") { startInstall() }.disabled(free < Int64(1_500_000_000)) }
                if let failure = arch.failure { Text(failure).foregroundStyle(.red); Button("重试") { startInstall() } }
            } footer: { Text("官方签名 Arch Linux ARM 包。已验证的下载会保留以供重试。首次启动配置完成前才会安装桌面包。") }
        } else {
            Section { if manager.busy { ProgressView("正在解包 Alpine Linux…") } else { Button("安装 Alpine") { startInstall() } }
                if let error = manager.error { Text(error).foregroundStyle(.red) } }
        }
    }

    @ViewBuilder private var account: some View {
        if !LRRuntimeBridge.isRunning() || (!setupRoot.isEmpty && LRRuntimeBridge.activeRootName() != setupRoot) {
            Section { Text("请完全关闭 LinuxRunner 并重新打开以继续。") }
        } else {
            let existing = LRRuntimeBridge.linuxAccounts().filter { $0["name"] != "root" && ($0["uid"].flatMap(Int.init) ?? 0) >= 1000 }
            if !existing.isEmpty {
                Section("使用已有账户") {
                    ForEach(existing, id: \.self) { account in Button(account["name"] ?? "") { useAccount(account["name"] ?? "") }.disabled(working != nil) }
                }
            }
            Section(existing.isEmpty ? "创建你的账户" : "或创建新账户") {
                TextField("用户名", text: $username).textInputAutocapitalization(.never).autocorrectionDisabled().textContentType(.username)
                SecureField("密码", text: $password).textContentType(.newPassword)
                SecureField("确认密码", text: $confirmation).textContentType(.newPassword)
                Toggle("管理员（可使用 sudo）", isOn: $administrator)
                Button("创建账户") { createAccount() }.disabled(working != nil || username.isEmpty || password.isEmpty || password != confirmation)
                if !confirmation.isEmpty && password != confirmation { Text("两次输入的密码不一致。").font(.footnote).foregroundStyle(.orange) }
            }
            Section { Text("允许小写字母、数字、- 与 _。LinuxRunner 只存储 Linux 自身的密码哈希，从不保存密码明文。").font(.footnote).foregroundStyle(.secondary) }
        }
    }

    @ViewBuilder private var desktop: some View {
        Section(footer: Text("一次性安装显示、窗口管理器、面板、文件管理器与声音（需要网络）。已有设置会保留。")) {
            HStack { Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor); Text(LRRuntimeBridge.activeEnvironmentIsArch() ? "LinuxRunner 桌面（Openbox、LXQt 面板、PCManFM-Qt）" : "LinuxRunner 桌面（Openbox、面板、文件管理器）") }
            HStack { Image(systemName: "circle").foregroundStyle(.secondary); VStack(alignment: .leading) { Text("KDE Plasma"); Text(LRRuntimeBridge.activeEnvironmentIsArch() ? "不可用：当前 Arch Plasma 需要 Wayland；请使用上方 X11 桌面。" : "实验性 · 之后可在 设置 › 桌面环境 中安装").font(.caption).foregroundStyle(.secondary) } }
        }
        Section {
            if desktopReady { Label("桌面组件已安装", systemImage: "checkmark") ; Button("继续") { stepRaw = SetupStep.done.rawValue } }
            else { Button("安装桌面组件") { prepareDesktop() }.disabled(working != nil) }
        }
    }

    private func row(_ title: String, _ value: String) -> some View { HStack { Text(title); Spacer(); Text(value).foregroundStyle(.secondary) } }

    private func resume() {
        if step == .relaunch, LRRuntimeBridge.isRunning(), LRRuntimeBridge.activeRootName() == setupRoot { stepRaw = SetupStep.account.rawValue }
    }

    private func configureExisting(_ environment: LinuxEnvironment) {
        problem = nil; desktopReady = false
        setupRoot = environment.rootfsName
        distribution = environment.distributionID ?? "alpine"
        LRRuntimeBridge.setNextRootName(environment.rootfsName)
        stepRaw = manager.active(environment) ? SetupStep.account.rawValue : SetupStep.relaunch.rawValue
    }

    private func startInstall() {
        guard !debian.running, !arch.running, !manager.busy else { return }
        problem = nil
        let known = Set(manager.environments.map(\.rootfsName))
        let finish: (String) -> Void = { root in
            setupRoot = root; LRRuntimeBridge.setNextRootName(root)
            stepRaw = (LRRuntimeBridge.isRunning() && LRRuntimeBridge.activeRootName() == root) ? SetupStep.account.rawValue : SetupStep.relaunch.rawValue
        }
        if distribution == "debian" {
            debian.install { environment in manager.acceptInstalled(environment); finish(environment.rootfsName) }
        } else if distribution == "arch" {
            arch.install { environment in manager.acceptInstalled(environment); finish(environment.rootfsName) }
        } else {
            manager.error = nil; manager.create(name: "Alpine Linux")
            Task { @MainActor in
                while manager.busy { try? await Task.sleep(nanoseconds: 300_000_000) }
                if let created = manager.environments.first(where: { !known.contains($0.rootfsName) }) { finish(created.rootfsName) }
            }
        }
    }

    private func createAccount() {
        problem = nil; working = "准备中"
        LRRuntimeBridge.createLinuxUser(username, password: password, administrator: administrator, progress: { working = $0 }) { error in
            working = nil
            if let error { problem = error.localizedDescription; return }
            password = ""; confirmation = ""
            useAccount(username)
        }
    }

    private func useAccount(_ name: String) {
        do { try LRRuntimeBridge.setDefaultLinuxUser(name); problem = nil; stepRaw = SetupStep.desktop.rawValue }
        catch { problem = error.localizedDescription }
    }

    private func prepareDesktop() {
        problem = nil; working = "正在启动"
        LRRuntimeBridge.prepareDesktopProfile({ working = $0 }) { error in
            working = nil
            if let error { problem = error.localizedDescription } else { desktopReady = true }
        }
    }
}
