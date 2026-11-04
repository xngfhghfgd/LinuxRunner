import Foundation
import CryptoKit
import SwiftUI

struct DebianPackage: Decodable {
    let Package: String
    let Version: String
    let Architecture: String
    let Filename: String
    let Size: String
    let SHA256: String
}
struct DebianManifest: Decodable {
    let schema: Int
    let id: String
    let name: String
    let version: String
    let architecture: String
    let repository: String
    let downloadBytes: Int64
    let installedBytes: Int64
    let packages: [DebianPackage]
    static func load() throws -> Self {
        guard let bundle = Bundle.main.url(forResource: "DebianSupport", withExtension: "bundle") else { throw DebianInstallError.failure("捆绑的经认证的 Debian 清单缺失。") }
        let data = try Data(contentsOf: bundle.appendingPathComponent("manifest.json"))
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        let pin = try String(contentsOf: bundle.appendingPathComponent("manifest.sha256")).trimmingCharacters(in: .whitespacesAndNewlines)
        guard digest == pin else { throw DebianInstallError.failure("Debian 清单完整性校验不一致。") }
        let manifest = try JSONDecoder().decode(Self.self, from: data)
        guard manifest.schema == 1, manifest.architecture == "arm64", manifest.repository == "https://deb.debian.org/debian/", !manifest.packages.isEmpty,
              manifest.packages.allSatisfy({ $0.Filename.hasPrefix("pool/") && !$0.Filename.split(separator: "/").contains("..") && ["arm64", "all"].contains($0.Architecture) && $0.SHA256.count == 64 && Int64($0.Size) != nil && $0.Package.range(of: "^[a-z0-9][a-z0-9+.-]+$", options: .regularExpression) != nil }) else { throw DebianInstallError.failure("不支持的 Debian 清单。") }
        return manifest
    }
}
enum DebianInstallError: LocalizedError {
    case failure(String)
    var errorDescription: String? { switch self { case .failure(let text): return text } }
}
private final class InstallCancellation: @unchecked Sendable {
    private let lock = NSLock(); private var stopped = false
    func cancel() { lock.lock(); stopped = true; lock.unlock() }
    func check() -> Bool { lock.lock(); defer { lock.unlock() }; return stopped }
}
@MainActor final class DebianInstaller: ObservableObject {
    @Published var message = "Debian 13.7 ARM64 · 经认证的官方包"
    @Published var fraction = 0.0
    @Published var running = false { didSet { if running != oldValue { running ? LRRuntimeBridge.beginAwake("debian-install") : LRRuntimeBridge.endAwake("debian-install") } } }
    @Published var failure: String?
    private var operation: Task<Void, Never>?
    private var cancellation = InstallCancellation()
    func cancel() { cancellation.cancel(); operation?.cancel() }
    func install(completion: @escaping (LinuxEnvironment) -> Void) {
        guard !running else { return }; running = true; failure = nil; cancellation = InstallCancellation()
        let token = cancellation
        UserDefaults.standard.set(true, forKey: "InstallerActive")
        operation = Task {
            defer { running = false; UserDefaults.standard.set(false, forKey: "InstallerActive") }
            do {
                let manifest = try DebianManifest.load()
                let base = LRRuntimeBridge.managedStorageURL()
                let available = try base.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage ?? 0
                let required = max(Int64(1024 * 1024 * 1024), manifest.downloadBytes + manifest.installedBytes * 4)
                DiagnosticCenter.installer(2, message: "stage=space_check available_bytes=\(available) required_bytes=\(required) host_page=\(getpagesize()) guest_page=4096 cancelled=\(token.check())")
                guard available >= required else { throw DebianInstallError.failure("至少需要 \(ByteCountFormatter.string(fromByteCount: required, countStyle: .file)) 可用存储空间。") }
                let cache = base.appendingPathComponent("downloads/debian-trixie-arm64", isDirectory: true)
                let temporary = base.appendingPathComponent("installer-temporary", isDirectory: true)
                try FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true)
                try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: true)
                let caseSensitive = try? temporary.resourceValues(forKeys: [.volumeSupportsCaseSensitiveNamesKey]).volumeSupportsCaseSensitiveNames
                DiagnosticCenter.installer(2, message: "stage=paths cache=\(cache.path) output_directory=\(temporary.path) host_case_sensitive=\(String(describing: caseSensitive)) extraction=guest_tar_not_host_paths")
                let root = UUID().uuidString.lowercased()
                let archive = temporary.appendingPathComponent("\(root).tar.gz")
                defer { try? FileManager.default.removeItem(at: archive) }
                var paths: [String] = []
                for (index, package) in manifest.packages.enumerated() {
                    try Task.checkCancellation(); if token.check() { throw CancellationError() }
                    message = "下载/校验 \(package.Package) (\(index + 1)/\(manifest.packages.count))"
                    fraction = Double(index) / Double(manifest.packages.count) * 0.55
                    let destination = cache.appendingPathComponent(package.Package + ".deb")
                    let cached = try? Self.verification(destination, package: package)
                    let valid = cached?.valid == true
                    DiagnosticCenter.installer(2, message: "stage=cache package=\(package.Package) index=\(index) source=\(manifest.repository) filename=\(package.Filename) expected_size=\(package.Size) expected_sha256=\(package.SHA256) valid=\(valid) actual_size=\(cached?.size ?? -1) actual_sha256=\(cached?.sha ?? "unavailable")")
                    if !valid {
                        let url = URL(string: manifest.repository + package.Filename)!
                        DiagnosticCenter.installer(2, message: "stage=download package=\(package.Package) index=\(index) URL=\(url.absoluteString) filename=\(package.Filename) cancelled=\(token.check())")
                        let download: URL; let response: URLResponse
                        do { (download, response) = try await URLSession.shared.download(from: url) }
                        catch { DiagnosticCenter.installer(0, message: "stage=download package=\(package.Package) index=\(index) cancelled=\(token.check()) error=\(error.localizedDescription)"); throw error }
                        defer { try? FileManager.default.removeItem(at: download) }
                        let http = (response as? HTTPURLResponse)?.statusCode ?? -1
                        DiagnosticCenter.installer(2, message: "stage=http package=\(package.Package) index=\(index) status=\(http) received_file=\(download.path)")
                        guard http == 200 else { throw DebianInstallError.failure("\(package.Package) 下载失败：HTTP \(http)。") }
                        let checked = try Self.verification(download, package: package)
                        DiagnosticCenter.installer(checked.valid ? 2 : 0, message: "stage=verification package=\(package.Package) index=\(index) expected_size=\(package.Size) actual_size=\(checked.size) expected_sha256=\(package.SHA256) actual_sha256=\(checked.sha) result=\(checked.valid ? "PASS" : "FAIL")")
                        guard checked.valid else { throw DebianInstallError.failure("\(package.Package) 完整性校验失败: expected \(package.Size) bytes, received \(checked.size); SHA-256 \(checked.sha == package.SHA256 ? "matches" : "mismatch").") }
                        do {
                            try? FileManager.default.removeItem(at: destination)
                            try FileManager.default.moveItem(at: download, to: destination)
                        } catch { DiagnosticCenter.installer(0, message: "stage=cache_publish package=\(package.Package) destination=\(destination.path) error=\(error.localizedDescription)"); throw error }
                    }
                    paths.append(destination.path)
                }
                message = "正在组装已校验的 Debian 包"
                let assemblySpace = try temporary.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage ?? 0
                DiagnosticCenter.installer(2, message: "stage=assemble package_count=\(paths.count) output=\(archive.path) available_bytes=\(assemblySpace) cancelled=\(token.check())")
                try await Task.detached(priority: .utility) {
                    try LRRuntimeBridge.assembleDebianPackages(paths, toArchive: archive, progress: { value in Task { @MainActor in self.fraction = 0.55 + value * 0.2 } }, cancel: { token.check() })
                }.value
                if token.check() { throw CancellationError() }
                message = "正在导入隔离的 Debian 文件系统"
                DiagnosticCenter.installer(2, message: "stage=fakefs_import root=\(root) output=\(archive.path) cancelled=\(token.check())")
                let sha = try Self.sha256(archive)
                try await Task.detached(priority: .utility) {
                    try LRRuntimeBridge.importVerifiedEnvironment(archive, root: root, sha256: sha, progress: { value, _ in Task { @MainActor in self.fraction = 0.75 + value * 0.25 } }, cancel: { token.check() })
                }.value
                // Root remains isolated; the running Alpine environment is untouched.
                var environment = LinuxEnvironment(name: "Debian GNU/Linux", rootfsName: root)
                environment.distribution = "Debian GNU/Linux"; environment.distributionID = "debian"; environment.packageManager = "apt"
                environment.rootfsVersion = manifest.version; environment.defaultShell = "/bin/bash"
                environment.installationState = "Imported; package configuration runs on first boot"
                environment.guiAvailability = "Not installed"; environment.desktopAvailability = "Not installed"
                completion(environment)
                message = "已导入。下次启动时选择 Debian；包配置将自动运行。"
                fraction = 1
                // Only authenticated, completed installer downloads are removed.
                try? FileManager.default.removeItem(at: cache)
                LRRuntimeBridge.logCategory("INSTALL", event: "Debian verified package import completed")
            } catch {
                failure = error is CancellationError || token.check() ? "Installation cancelled. Verified downloads are retained for retry." : error.localizedDescription
                let ns = error as NSError
                DiagnosticCenter.installer(0, message: "stage=installer_failure domain=\(ns.domain) code=\(ns.code) cancelled=\(token.check()) reason=\(failure ?? error.localizedDescription)")
                DiagnosticCenter.flush()
                LRRuntimeBridge.logCategory("INSTALL", event: failure ?? "Installation failed")
            }
        }
    }
    nonisolated static func sha256(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url); defer { try? handle.close() }
        var hash = SHA256()
        while let data = try handle.read(upToCount: 65536), !data.isEmpty { hash.update(data: data) }
        return hash.finalize().map { String(format: "%02x", $0) }.joined()
    }
    nonisolated static func verification(_ url: URL, package: DebianPackage) throws -> (valid: Bool, size: Int64, sha: String) {
        let info = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
        let size = Int64(info.fileSize ?? -1)
        guard info.isRegularFile == true, info.isSymbolicLink != true else { return (false, size, "not-regular-file") }
        let hash = try sha256(url)
        return (size == Int64(package.Size) && hash == package.SHA256, size, hash)
    }
}
struct DebianInstallerView: View {
    @StateObject private var installer = DebianInstaller()
    let completion: (LinuxEnvironment) -> Void
    var body: some View {
        List {
            Text("Debian GNU/Linux 13.7 (trixie) · ARM64")
            Text("从捆绑清单下载官方 Debian 包，该清单基于 Debian 的签名发布与 SHA-256 包索引进行认证。至少需要 1 GB 可用空间。Alpine 仍保持已安装状态。").font(.footnote)
            Text(installer.message)
            if installer.running { ProgressView(value: installer.fraction); Button("取消安装") { installer.cancel() } }
            else { Button("安装 Debian ARM64") { installer.install(completion: completion) } }
            if let failure = installer.failure { Text(failure).foregroundColor(.red) }
            NavigationLink("导出安装器诊断", destination: DeveloperDiagnosticsView())
            Text("请在诊断中选择"导出完整诊断包"。其中包含有界的 Debian 安装器日志。DEBUG 可启用逐条目的归档跟踪。").font(.footnote)
        }.navigationTitle("安装 Debian")
    }
}
