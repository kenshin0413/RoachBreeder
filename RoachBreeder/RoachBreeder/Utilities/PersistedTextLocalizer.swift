import Foundation

enum PersistedTextLocalizer {
    static func localize(_ source: String) -> String {
        let exact = Bundle.main.localizedString(forKey: source, value: source, table: nil)
        if exact != source {
            return exact
        }

        let patterns: [(String, String, ([String]) -> [CVarArg])] = [
            (#"^(\d+)匹から(\d+)匹になった。$"#, "%lld匹から%lld匹になった。", { [Int64($0[0]) ?? 0, Int64($0[1]) ?? 0] }),
            (#"^机と棚の奥で(\d+)匹が動きはじめた。$"#, "机と棚の奥で%lld匹が動きはじめた。", { [Int64($0[0]) ?? 0] }),
            (#"^(.+)cmの個体を確認。$"#, "%@cmの個体を確認。", { [$0[0]] }),
            (#"^(.+)を追跡対象にした。$"#, "%@を追跡対象にした。", { [localize($0[0])] }),
            (#"^(.+)の姿が見えなくなった。$"#, "%@の姿が見えなくなった。", { [localize($0[0])] }),
            (#"^(.+)を引いた$"#, "%@を引いた", { [localize($0[0])] }),
            (#"^(.+)「(.+)」を獲得。$"#, "%@「%@」を獲得。", { [localize($0[0]), localize($0[1])] }),
            (#"^10個獲得。最高レア度は(.+)。$"#, "10個獲得。最高レア度は%@。", { [localize($0[0])] }),
            (#"^(.+)を今日もう1回使えるようになった。$"#, "%@を今日もう1回使えるようになった。", { [localize($0[0])] }),
            (#"^部屋に「(.+)」を置いた。$"#, "部屋に「%@」を置いた。", { [localize($0[0])] }),
            (#"^部屋を「(.+)」に切り替えた。$"#, "部屋を「%@」に切り替えた。", { [localize($0[0])] })
        ]

        for (pattern, key, arguments) in patterns {
            guard let captures = captures(in: source, matching: pattern) else { continue }
            let format = Bundle.main.localizedString(forKey: key, value: key, table: nil)
            return String(format: format, locale: Locale.current, arguments: arguments(captures))
        }

        return source
    }

    private static func captures(in source: String, matching pattern: String) -> [String]? {
        guard let expression = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(source.startIndex..., in: source)
        guard let match = expression.firstMatch(in: source, range: range), match.range == range else { return nil }

        return (1..<match.numberOfRanges).compactMap { index in
            guard let range = Range(match.range(at: index), in: source) else { return nil }
            return String(source[range])
        }
    }
}
