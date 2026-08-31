import Foundation

enum RoachWidgetConstants {
    static let appGroupIdentifier = "group.com.kenshin.RoachBreeder"
    static let widgetKind = "com.kenshin.RoachBreeder.colony-status.v1"
    static let snapshotKey = "RoachBreeder.WidgetSnapshot.v1"
    static let colonyKey = "RoachBreeder.ColonyState.v1"
    static let memoryKey = "RoachBreeder.ColonyMemory.v1"
    static let lastSavedAtKey = "RoachBreeder.LastSavedAt.v1"
    static let migrationKey = "RoachBreeder.AppGroupMigration.v1"
    static let guideDismissedKey = "RoachBreeder.WidgetGuideDismissed.v1"
    static let lastTimelineReloadKey = "RoachBreeder.WidgetLastTimelineReload.v1"
}

enum RoachWidgetNeed: String, Codable, CaseIterable {
    case food
    case water
    case safety
    case breeding
    case complete
}

enum RoachWidgetMood: String, Codable {
    case normal
    case waiting
    case unhappy
    case urgent
    case grateful
}

struct RoachWidgetSnapshot: Codable, Equatable {
    var generatedAt: Date
    var lastUserActionAt: Date?
    var totalCount: Int
    var maleCount: Int
    var femaleCount: Int
    var eggCaseCount: Int
    var breedingProgress: Double
    var water: Double
    var safety: Double
    var foodDoneToday: Bool
    var waterDoneToday: Bool
    var lightDoneToday: Bool

    static let placeholder = RoachWidgetSnapshot(
        generatedAt: Date(),
        lastUserActionAt: Date().addingTimeInterval(-2 * 60 * 60),
        totalCount: 12,
        maleCount: 6,
        femaleCount: 6,
        eggCaseCount: 2,
        breedingProgress: 0.64,
        water: 68,
        safety: 74,
        foodDoneToday: true,
        waterDoneToday: false,
        lightDoneToday: false
    )

    var allCareCompletedToday: Bool {
        foodDoneToday && waterDoneToday && lightDoneToday
    }

    var mostImportantNeed: RoachWidgetNeed {
        if allCareCompletedToday { return .complete }
        if water < 30 { return .water }
        if safety < 30 { return .safety }
        if !foodDoneToday { return .food }
        if !waterDoneToday { return .water }
        if !lightDoneToday { return .safety }
        return .breeding
    }

    func mood(at date: Date) -> RoachWidgetMood {
        if allCareCompletedToday { return .grateful }
        if water < 18 || safety < 18 { return .urgent }
        let idle = date.timeIntervalSince(lastUserActionAt ?? generatedAt)
        if idle >= 36 * 60 * 60 { return .urgent }
        if idle >= 18 * 60 * 60 { return .unhappy }
        if idle >= 6 * 60 * 60 { return .waiting }
        return .normal
    }

    func message(at date: Date) -> String {
        if allCareCompletedToday {
            return "今日の世話、ありがとう！"
        }

        let didAnythingToday = foodDoneToday || waterDoneToday || lightDoneToday
        let prefix = didAnythingToday ? "ありがとう。" : ""
        switch mostImportantNeed {
        case .food:
            return "\(prefix)次は餌が必要"
        case .water:
            return "\(prefix)次は水が必要"
        case .safety:
            return "\(prefix)次は光で様子を見て"
        case .breeding:
            return "コロニーは成長中"
        case .complete:
            return "今日の世話、ありがとう！"
        }
    }

    func deepLinkURL() -> URL {
        let target: String
        switch mostImportantNeed {
        case .food: target = "food"
        case .water: target = "water"
        case .safety: target = "light"
        case .breeding, .complete: target = "colony"
        }
        return URL(string: "roachbreeder://colony?target=\(target)")!
    }
}

enum RoachWidgetSnapshotStore {
    static func load() -> RoachWidgetSnapshot {
        guard let defaults = UserDefaults(suiteName: RoachWidgetConstants.appGroupIdentifier),
              let data = defaults.data(forKey: RoachWidgetConstants.snapshotKey),
              let snapshot = try? JSONDecoder().decode(RoachWidgetSnapshot.self, from: data)
        else {
            return .placeholder
        }
        return snapshot
    }

    @discardableResult
    static func save(_ snapshot: RoachWidgetSnapshot) -> Bool {
        guard let defaults = UserDefaults(suiteName: RoachWidgetConstants.appGroupIdentifier),
              let data = try? JSONEncoder().encode(snapshot)
        else {
            return false
        }
        defaults.set(data, forKey: RoachWidgetConstants.snapshotKey)
        return defaults.synchronize()
    }
}
