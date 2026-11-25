import Foundation
import CoreGraphics

enum SpiderSkinID: String, CaseIterable, Identifiable {
    case miles
    case advanced
    case prowler
    case tech
    case crimson
    case uptown
    case programmable
    case future
    case hoodie
    case classic

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .miles: return "skin.miles"
        case .advanced: return "skin.advanced"
        case .prowler: return "skin.prowler"
        case .tech: return "skin.tech"
        case .crimson: return "skin.crimson"
        case .uptown: return "skin.uptown"
        case .programmable: return "skin.programmable"
        case .future: return "skin.future"
        case .hoodie: return "skin.hoodie"
        case .classic: return "skin.classic"
        }
    }

    var title: String { L10n.tr(titleKey) }
}

@MainActor
final class AppSettings {
    static let shared = AppSettings()

    static let didChangeNotification = Notification.Name("AppSettings.didChange")

    enum Key {
        static let hangDuration = "settings.hangDuration"
        static let appearDelay = "settings.appearDelay"
        static let webLength = "settings.webLength"
        static let spiderScale = "settings.spiderScale"
        static let skin = "settings.skin"
        static let webStyle = "settings.webStyle"
        static let language = "settings.language"
        static let emotionsEnabled = "settings.emotionsEnabled"
        static let emotionInterval = "settings.emotionInterval"
    }

    enum Default {
        static let hangDuration: Double = 10
        static let appearDelay: Double = 15
        static let webLength: Double = 56
        static let spiderScale: Double = 1.0
        static let skin = SpiderSkinID.miles.rawValue
        static let webStyle = WebStyleID.classic.rawValue
        static let language = AppLanguage.system.rawValue
        static let emotionsEnabled = true
        static let emotionInterval: Double = 8
    }

    enum Range {
        /// Time intervals are in seconds; max = 30 minutes.
        static let hangDuration = 3.0...1800.0
        static let appearDelay = 1.0...1800.0
        static let webLength = 24.0...160.0
        static let spiderScale = 0.5...2.0
        static let emotionInterval = 3.0...1800.0
    }

    private let defaults = UserDefaults.standard

    private init() {
        defaults.register(defaults: [
            Key.hangDuration: Default.hangDuration,
            Key.appearDelay: Default.appearDelay,
            Key.webLength: Default.webLength,
            Key.spiderScale: Default.spiderScale,
            Key.skin: Default.skin,
            Key.webStyle: Default.webStyle,
            Key.language: Default.language,
            Key.emotionsEnabled: Default.emotionsEnabled,
            Key.emotionInterval: Default.emotionInterval
        ])
    }

    var hangDuration: TimeInterval {
        get { clamped(defaults.double(forKey: Key.hangDuration), Range.hangDuration) }
        set {
            defaults.set(clamped(newValue, Range.hangDuration), forKey: Key.hangDuration)
            notify()
        }
    }

    var appearDelay: TimeInterval {
        get { clamped(defaults.double(forKey: Key.appearDelay), Range.appearDelay) }
        set {
            defaults.set(clamped(newValue, Range.appearDelay), forKey: Key.appearDelay)
            notify()
        }
    }

    var webLength: CGFloat {
        get { CGFloat(clamped(defaults.double(forKey: Key.webLength), Range.webLength)) }
        set {
            defaults.set(clamped(Double(newValue), Range.webLength), forKey: Key.webLength)
            notify()
        }
    }

    var spiderScale: CGFloat {
        get { CGFloat(clamped(defaults.double(forKey: Key.spiderScale), Range.spiderScale)) }
        set {
            defaults.set(clamped(Double(newValue), Range.spiderScale), forKey: Key.spiderScale)
            notify()
        }
    }

    var spiderScalePercent: Int {
        get { Int((spiderScale * 100).rounded()) }
        set { spiderScale = CGFloat(newValue) / 100 }
    }

    var skinID: SpiderSkinID {
        get {
            let raw = defaults.string(forKey: Key.skin) ?? Default.skin
            return SpiderSkinID(rawValue: raw) ?? .miles
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.skin)
            notify()
        }
    }

    var webStyleID: WebStyleID {
        get {
            let raw = defaults.string(forKey: Key.webStyle) ?? Default.webStyle
            return WebStyleID(rawValue: raw) ?? .classic
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.webStyle)
            notify()
        }
    }

    var language: AppLanguage {
        get {
            let raw = defaults.string(forKey: Key.language) ?? Default.language
            return AppLanguage(rawValue: raw) ?? .system
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.language)
            L10n.resetCache()
            notify()
        }
    }

    var emotionsEnabled: Bool {
        get { defaults.object(forKey: Key.emotionsEnabled) as? Bool ?? Default.emotionsEnabled }
        set {
            defaults.set(newValue, forKey: Key.emotionsEnabled)
            notify()
        }
    }

    var emotionInterval: TimeInterval {
        get { clamped(defaults.double(forKey: Key.emotionInterval), Range.emotionInterval) }
        set {
            defaults.set(clamped(newValue, Range.emotionInterval), forKey: Key.emotionInterval)
            notify()
        }
    }

    private func clamped(_ value: Double, _ range: ClosedRange<Double>) -> Double {
        min(range.upperBound, max(range.lowerBound, value))
    }

    private func notify() {
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }
}
