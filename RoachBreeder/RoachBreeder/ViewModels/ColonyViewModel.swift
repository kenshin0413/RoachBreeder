//
//  ColonyViewModel.swift
//  RoachBreeder
//

import Combine
import CoreGraphics
import Foundation

final class ColonyViewModel: ObservableObject {
    @Published private(set) var colony: ColonyState
    @Published private(set) var memory: ColonyMemory
    @Published private(set) var arenaSize: CGSize = .zero
    @Published private(set) var isDailyTicketRewardPending: Bool

    private static let storageKey = RoachWidgetConstants.colonyKey
    private static let lastSavedAtKey = RoachWidgetConstants.lastSavedAtKey
    private static let memoryStorageKey = RoachWidgetConstants.memoryKey
    private static let legacyDirectGachaMigrationKey = "RoachBreeder.LegacyDirectGachaRemoved.v1"
    private var saveTimer: Double = 0

    init(colony: ColonyState? = nil) {
        WidgetStateBridge.migrateLegacyStorageIfNeeded()
        var loadedColony = colony ?? Self.loadSavedColony() ?? .bootstrap()
        var loadedMemory = Self.loadMemory() ?? ColonyMemory.bootstrap(for: loadedColony)
        let didGrantDailyTicket = loadedMemory.grantDailyGachaTicketIfNeeded()
        loadedColony.migrateToCurrentTimingRules()
        if colony == nil, !UserDefaults.standard.bool(forKey: Self.legacyDirectGachaMigrationKey) {
            loadedColony.removeLegacyDirectGachaRoaches()
            loadedMemory.removeLegacyRareRoachRecords()
            UserDefaults.standard.set(true, forKey: Self.legacyDirectGachaMigrationKey)
        }
        if colony == nil, let lastSavedAt = Self.loadLastSavedAt() {
            loadedColony.advanceOffline(delta: Date().timeIntervalSince(lastSavedAt))
        }
        loadedColony.reconcileCountsWithVisibleRoaches()
        loadedMemory.refreshRecords(with: loadedColony)
        self.colony = loadedColony
        self.memory = loadedMemory
        self.isDailyTicketRewardPending = didGrantDailyTicket
        save(requestWidgetReload: true)
    }

    func advance(delta: Double) {
        colony.advance(in: arenaSize, delta: delta)
        memory.refreshRecords(with: colony)
        saveTimer += delta
        if saveTimer >= 2.0 {
            saveTimer = 0
            if memory.grantDailyGachaTicketIfNeeded() {
                isDailyTicketRewardPending = true
            }
            save()
        }
    }

    @discardableResult
    func placeFood() -> Bool {
        let didUse = colony.placeFood(in: arenaSize)
        if didUse {
            memory.recordCare(tool: .food)
            memory.refreshRecords(with: colony)
        }
        save(requestWidgetReload: didUse)
        return didUse
    }

    @discardableResult
    func placeFood(at position: CGPoint) -> Bool {
        let didUse = colony.placeFood(at: position, in: arenaSize)
        if didUse {
            memory.recordCare(tool: .food)
            memory.refreshRecords(with: colony)
        }
        save(requestWidgetReload: didUse)
        return didUse
    }

    @discardableResult
    func addWater() -> Bool {
        let didUse = colony.addWater()
        if didUse {
            memory.recordCare(tool: .water)
            memory.refreshRecords(with: colony)
        }
        save(requestWidgetReload: didUse)
        return didUse
    }

    @discardableResult
    func addWater(at position: CGPoint) -> Bool {
        let didUse = colony.addWater(at: position, in: arenaSize)
        if didUse {
            memory.recordCare(tool: .water)
            memory.refreshRecords(with: colony)
        }
        save(requestWidgetReload: didUse)
        return didUse
    }

    @discardableResult
    func shineLight() -> Bool {
        let didUse = colony.scatterRoaches()
        if didUse {
            memory.recordCare(tool: .light)
            memory.refreshRecords(with: colony)
        }
        save(requestWidgetReload: didUse)
        return didUse
    }

    @discardableResult
    func shineLight(at position: CGPoint) -> Bool {
        let didUse = colony.scatterRoaches(from: position)
        if didUse {
            memory.recordCare(tool: .light)
            memory.refreshRecords(with: colony)
        }
        save(requestWidgetReload: didUse)
        return didUse
    }

    @discardableResult
    func nameRoach(id: UUID, name: String) -> Bool {
        let didName = colony.nameRoach(id: id, name: name)
        if didName {
            memory.syncFavorite(with: colony)
            memory.refreshRecords(with: colony)
        }
        save()
        return didName
    }

    func drawGacha(count: Int) -> [GachaReward]? {
        guard memory.consumeGachaCost(count: count) else { return nil }
        return applyGachaDraw(count: count)
    }

    func canGrantBonusCareUse(for tool: CareTool) -> Bool {
        colony.canGrantBonusCareUse(for: tool)
    }

    func grantBonusCareUse(for tool: CareTool) {
        colony.grantBonusCareUse(for: tool)
        memory.addEntry(
            title: String(localized: "広告リワード"),
            detail: String(localized: "\(tool.title)を今日もう1回使えるようになった。"),
            kind: .care
        )
        save()
    }

    func grantRewardedGachaTicket() {
        memory.grantRewardedGachaTicket()
        save()
    }

    private func applyGachaDraw(count: Int) -> [GachaReward] {
        let rewards = (0..<count).map { _ in GachaCatalog.draw() }
        let size = arenaSize.width > 20 && arenaSize.height > 20
            ? arenaSize
            : CGSize(width: 360, height: 440)
        for reward in rewards where reward.category != .hideout {
            colony.applyGachaReward(reward, in: size)
        }
        memory.recordGachaRewards(rewards)
        memory.refreshRecords(with: colony)
        save()
        return rewards
    }

    func acknowledgeDailyTicketReward() {
        isDailyTicketRewardPending = false
    }

    @discardableResult
    func placeStoredHideout(_ kind: HideoutKind, at position: CGPoint) -> Bool {
        guard (memory.hideoutInventory[kind] ?? 0) > 0 else { return false }
        let size = arenaSize.width > 20 && arenaSize.height > 20
            ? arenaSize
            : CGSize(width: 360, height: 440)
        guard colony.placeHideout(kind: kind, at: position, in: size) else {
            save()
            return false
        }
        _ = memory.consumeHideout(kind)
        memory.addEntry(
            title: String(localized: "隠れ家を配置"),
            detail: String(localized: "部屋に「\(kind.title)」を置いた。"),
            kind: .care
        )
        memory.refreshRecords(with: colony)
        save()
        return true
    }

    @discardableResult
    func moveHideout(id: UUID, to position: CGPoint) -> Bool {
        let size = arenaSize.width > 20 && arenaSize.height > 20
            ? arenaSize
            : CGSize(width: 360, height: 440)
        let didMove = colony.moveHideout(id: id, to: position, in: size)
        if didMove {
            memory.addEntry(title: String(localized: "隠れ家を移動"), detail: String(localized: "部屋の中の隠れ家を別の場所へ動かした。"), kind: .care)
            memory.refreshRecords(with: colony)
        }
        save()
        return didMove
    }

    @discardableResult
    func deleteHideout(id: UUID) -> Bool {
        let didDelete = colony.deleteHideout(id: id)
        if didDelete {
            memory.addEntry(title: String(localized: "隠れ家を削除"), detail: String(localized: "部屋から隠れ家を取り除いた。"), kind: .care)
            memory.refreshRecords(with: colony)
        }
        save()
        return didDelete
    }

    func selectRoomSkin(_ skin: RoomSkin) {
        guard memory.unlockedRoomSkins.contains(skin) else { return }
        memory.activeRoomSkin = skin
        memory.addEntry(
            title: String(localized: "すき間を変更"),
            detail: String(localized: "部屋を「\(skin.title)」に切り替えた。"),
            kind: .record
        )
        save()
    }

    @discardableResult
    func clearNamedRoach() -> Bool {
        let didClear = colony.clearNamedRoach()
        save()
        return didClear
    }

    func arenaDidAppear(size: CGSize) {
        arenaSize = size
        colony.fitInitialPositions(in: size)
    }

    func arenaSizeDidChange(to size: CGSize) {
        arenaSize = size
        colony.clampEverything(in: size)
        save()
    }

    func save(requestWidgetReload: Bool = false) {
        guard let data = try? JSONEncoder().encode(colony) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
        let savedAt = Date()
        UserDefaults.standard.set(savedAt, forKey: Self.lastSavedAtKey)
        if let memoryData = try? JSONEncoder().encode(memory) {
            UserDefaults.standard.set(memoryData, forKey: Self.memoryStorageKey)
        }
        WidgetStateBridge.persist(
            colony: colony,
            memory: memory,
            at: savedAt,
            requestTimelineReload: requestWidgetReload
        )
    }

    private static func loadSavedColony() -> ColonyState? {
        var colony = WidgetStateBridge.loadColony()
        colony?.migrateToCurrentTimingRules()
        colony?.reconcileCountsWithVisibleRoaches()
        return colony
    }

    private static func loadLastSavedAt() -> Date? {
        WidgetStateBridge.loadLastSavedAt()
    }

    private static func loadMemory() -> ColonyMemory? {
        WidgetStateBridge.loadMemory()
    }
}
