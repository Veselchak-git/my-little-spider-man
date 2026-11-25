import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english
    case russian

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .system: return "language.system"
        case .english: return "language.english"
        case .russian: return "language.russian"
        }
    }

    var title: String { L10n.tr(titleKey) }

    /// Concrete language code used for string lookup.
    var resolvedCode: String {
        switch self {
        case .english:
            return "en"
        case .russian:
            return "ru"
        case .system:
            let preferred = Locale.preferredLanguages.map { String($0.prefix(2)).lowercased() }
            if preferred.contains("ru") { return "ru" }
            return "en"
        }
    }
}

enum L10n {
    private final class CacheBox: @unchecked Sendable {
        var tables: [String: [String: String]] = [:]
        let lock = NSLock()
    }

    private static let cacheBox = CacheBox()

    static func tr(_ key: String) -> String {
        let code = currentLanguageCode()
        if let value = table(for: code)[key] {
            return value
        }
        return table(for: "en")[key] ?? key
    }

    static func resetCache() {
        let box = cacheBox
        box.lock.lock()
        box.tables.removeAll()
        box.lock.unlock()
    }

    private static func currentLanguageCode() -> String {
        let raw = UserDefaults.standard.string(forKey: AppSettings.Key.language) ?? AppLanguage.system.rawValue
        let language = AppLanguage(rawValue: raw) ?? .system
        return language.resolvedCode
    }

    private static func table(for code: String) -> [String: String] {
        let box = cacheBox
        box.lock.lock()
        defer { box.lock.unlock() }

        if let cached = box.tables[code] {
            return cached
        }

        let loaded = loadTable(for: code) ?? loadTable(for: "en") ?? [:]
        box.tables[code] = loaded
        return loaded
    }

    private static func loadTable(for code: String) -> [String: String]? {
        let candidates: [URL?] = [
            Bundle.main.resourceURL?
                .appendingPathComponent("\(code).lproj", isDirectory: true)
                .appendingPathComponent("Localizable.strings"),
            URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("resources/\(code).lproj/Localizable.strings")
        ]

        for case let url? in candidates where FileManager.default.fileExists(atPath: url.path) {
            if let dict = NSDictionary(contentsOf: url) as? [String: String] {
                return dict
            }
        }
        return nil
    }
}
