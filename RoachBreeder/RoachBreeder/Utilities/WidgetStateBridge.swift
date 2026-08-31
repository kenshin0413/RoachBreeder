import Foundation
import WidgetKit

enum WidgetStateBridge {
    static func migrateLegacyStorageIfNeeded() {
        guard let shared = UserDefaults(suiteName: RoachWidgetConstants.appGroupIdentifier) else { return }
        let standard = UserDefaults.standard

        if !shared.bool(forKey: RoachWidgetConstants.migrationKey) {
            if shared.data(forKey: RoachWidgetConstants.colonyKey) == nil,
               let data = standard.data(forKey: RoachWidgetConstants.colonyKey) {
                shared.set(data, forKey: RoachWidgetConstants.colonyKey)
            }
            if shared.data(forKey: RoachWidgetConstants.memoryKey) == nil,
               let data = standard.data(forKey: RoachWidgetConstants.memoryKey) {
                shared.set(data, forKey: RoachWidgetConstants.memoryKey)
            }
            if shared.object(forKey: RoachWidgetConstants.lastSavedAtKey) == nil,
               let date = standard.object(forKey: RoachWidgetConstants.lastSavedAtKey) {
                shared.set(date, forKey: RoachWidgetConstants.lastSavedAtKey)
            }
            shared.set(true, forKey: RoachWidgetConstants.migrationKey)
            shared.synchronize()
        }
    }

    static func loadColony() -> ColonyState? {
        migrateLegacyStorageIfNeeded()
        let shared = UserDefaults(suiteName: RoachWidgetConstants.appGroupIdentifier)
        let data = shared?.data(forKey: RoachWidgetConstants.colonyKey)
            ?? UserDefaults.standard.data(forKey: RoachWidgetConstants.colonyKey)
        guard let data else { return nil }
        return try? JSONDecoder().decode(ColonyState.self, from: data)
    }

    static func loadMemory() -> ColonyMemory? {
        migrateLegacyStorageIfNeeded()
        let shared = UserDefaults(suiteName: RoachWidgetConstants.appGroupIdentifier)
        let data = shared?.data(forKey: RoachWidgetConstants.memoryKey)
            ?? UserDefaults.standard.data(forKey: RoachWidgetConstants.memoryKey)
        guard let data else { return nil }
        return try? JSONDecoder().decode(ColonyMemory.self, from: data)
    }

    static func loadLastSavedAt() -> Date? {
        migrateLegacyStorageIfNeeded()
        return UserDefaults(suiteName: RoachWidgetConstants.appGroupIdentifier)?
            .object(forKey: RoachWidgetConstants.lastSavedAtKey) as? Date
            ?? UserDefaults.standard.object(forKey: RoachWidgetConstants.lastSavedAtKey) as? Date
    }

    static func persist(
        colony: ColonyState,
        memory: ColonyMemory,
        at date: Date = Date(),
        requestTimelineReload: Bool = false
    ) {
        guard let shared = UserDefaults(suiteName: RoachWidgetConstants.appGroupIdentifier),
              let colonyData = try? JSONEncoder().encode(colony),
              let memoryData = try? JSONEncoder().encode(memory)
        else { return }

        shared.set(colonyData, forKey: RoachWidgetConstants.colonyKey)
        shared.set(memoryData, forKey: RoachWidgetConstants.memoryKey)
        shared.set(date, forKey: RoachWidgetConstants.lastSavedAtKey)

        let usage = colony.careUsage ?? .current()
        let lastActionAt = memory.lastCareDates.values.max()
        let snapshot = RoachWidgetSnapshot(
            generatedAt: date,
            lastUserActionAt: lastActionAt,
            totalCount: colony.totalCount,
            maleCount: colony.maleCount,
            femaleCount: colony.femaleCount,
            eggCaseCount: colony.eggCases.count,
            breedingProgress: colony.breedingProgress,
            water: colony.water,
            safety: colony.safety,
            foodDoneToday: usage.dayIdentifier == DailyCareUsage.currentDayIdentifier() && usage.foodUsed > 0,
            waterDoneToday: usage.dayIdentifier == DailyCareUsage.currentDayIdentifier() && usage.waterUsed > 0,
            lightDoneToday: usage.dayIdentifier == DailyCareUsage.currentDayIdentifier() && usage.lightUsed > 0
        )
        guard let snapshotData = try? JSONEncoder().encode(snapshot) else { return }
        shared.set(snapshotData, forKey: RoachWidgetConstants.snapshotKey)

        // Complete all shared writes before asking WidgetKit to read the suite.
        shared.synchronize()

        let lastReload = shared.object(forKey: RoachWidgetConstants.lastTimelineReloadKey) as? Date
        let periodicReloadDue = date.timeIntervalSince(lastReload ?? .distantPast) >= 15 * 60
        if requestTimelineReload || periodicReloadDue {
            shared.set(date, forKey: RoachWidgetConstants.lastTimelineReloadKey)
            shared.synchronize()
            WidgetCenter.shared.reloadTimelines(ofKind: RoachWidgetConstants.widgetKind)
        }
    }
}
