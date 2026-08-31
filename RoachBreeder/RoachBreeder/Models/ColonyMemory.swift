//
//  ColonyMemory.swift
//  RoachBreeder
//

import Foundation

struct ObservationEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var title: String
    var detail: String
    var kind: ObservationKind

    var localizedTitle: String {
        PersistedTextLocalizer.localize(title)
    }

    var localizedDetail: String {
        PersistedTextLocalizer.localize(detail)
    }
}

enum ObservationKind: String, Codable {
    case care
    case growth
    case breeding
    case record
    case alert
}

struct NamedRoachRecord: Identifiable, Codable {
    var id: UUID
    var name: String
    var firstSeenAt: Date
    var lastSeenAt: Date
    var bestLengthCm: Double
    var longestAge: Double
}

struct ColonyMemory: Codable {
    var favoriteRoachID: UUID? = nil
    var favoriteName: String? = nil
    var favoriteStartedAt: Date? = nil
    var journalEntries: [ObservationEntry] = []
    var namedHistory: [NamedRoachRecord] = []
    var maxColonyCount: Int = 0
    var maxEggCaseCount: Int = 0
    var longestLivedDays: Double = 0
    var fastestRecordedSpeedMultiplier: Double? = nil
    var lastGachaDate: Date? = nil
    var gachaHistory: [GachaReward] = []
    var gachaTickets: Int = 0
    var lastDailyTicketDayIdentifier: String? = nil
    var hasUsedFirstFreeGacha: Bool = false
    var unlockedRoomSkins: [RoomSkin] = [.deskGap]
    var activeRoomSkin: RoomSkin = .deskGap
    var discoveredHideouts: [HideoutKind] = []
    var hideoutInventory: [HideoutKind: Int] = [:]
    var discoveredRoachVariants: [RoachVariant] = []
    var lastLoggedTotalCount: Int = 0
    var lastLoggedEggCaseCount: Int = 0
    var lastLoggedMaxLengthCm: Double = 0
    var lastCareDates: [CareTool: Date] = [:]

    static func bootstrap(for colony: ColonyState) -> ColonyMemory {
        var memory = ColonyMemory()
        memory.maxColonyCount = colony.totalCount
        memory.maxEggCaseCount = colony.eggCases.count
        memory.fastestRecordedSpeedMultiplier = colony.roaches.map(\.speedMultiplier).max()
        memory.lastLoggedTotalCount = colony.totalCount
        memory.lastLoggedEggCaseCount = colony.eggCases.count
        memory.lastLoggedMaxLengthCm = colony.bestRecordedLengthCm
        memory.longestLivedDays = colony.roaches.map { $0.age / (24 * 60 * 60) }.max() ?? 0
        memory.syncFavorite(with: colony)
        memory.addEntry(
            title: String(localized: "すき間に群れを発見"),
            detail: String(localized: "机と棚の奥で\(colony.totalCount)匹が動きはじめた。"),
            kind: .record
        )
        return memory
    }

    private enum CodingKeys: String, CodingKey {
        case favoriteRoachID
        case favoriteName
        case favoriteStartedAt
        case journalEntries
        case namedHistory
        case maxColonyCount
        case maxEggCaseCount
        case longestLivedDays
        case lastLoggedTotalCount
        case lastLoggedEggCaseCount
        case lastLoggedMaxLengthCm
        case lastCareDates
        case fastestRecordedSpeedMultiplier
        case lastGachaDate
        case gachaHistory
        case gachaTickets
        case lastDailyTicketDayIdentifier
        case hasUsedFirstFreeGacha
        case unlockedRoomSkins
        case activeRoomSkin
        case discoveredHideouts
        case hideoutInventory
        case discoveredRoachVariants
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        favoriteRoachID = try container.decodeIfPresent(UUID.self, forKey: .favoriteRoachID)
        favoriteName = try container.decodeIfPresent(String.self, forKey: .favoriteName)
        favoriteStartedAt = try container.decodeIfPresent(Date.self, forKey: .favoriteStartedAt)
        journalEntries = try container.decodeIfPresent([ObservationEntry].self, forKey: .journalEntries) ?? []
        namedHistory = try container.decodeIfPresent([NamedRoachRecord].self, forKey: .namedHistory) ?? []
        maxColonyCount = try container.decodeIfPresent(Int.self, forKey: .maxColonyCount) ?? 0
        maxEggCaseCount = try container.decodeIfPresent(Int.self, forKey: .maxEggCaseCount) ?? 0
        longestLivedDays = try container.decodeIfPresent(Double.self, forKey: .longestLivedDays) ?? 0
        lastLoggedTotalCount = try container.decodeIfPresent(Int.self, forKey: .lastLoggedTotalCount) ?? 0
        lastLoggedEggCaseCount = try container.decodeIfPresent(Int.self, forKey: .lastLoggedEggCaseCount) ?? 0
        lastLoggedMaxLengthCm = try container.decodeIfPresent(Double.self, forKey: .lastLoggedMaxLengthCm) ?? 0
        lastCareDates = try container.decodeIfPresent([CareTool: Date].self, forKey: .lastCareDates) ?? [:]
        fastestRecordedSpeedMultiplier = try container.decodeIfPresent(Double.self, forKey: .fastestRecordedSpeedMultiplier)
        lastGachaDate = try container.decodeIfPresent(Date.self, forKey: .lastGachaDate)
        gachaHistory = try container.decodeIfPresent([GachaReward].self, forKey: .gachaHistory) ?? []
        gachaTickets = max(0, try container.decodeIfPresent(Int.self, forKey: .gachaTickets) ?? 0)
        lastDailyTicketDayIdentifier = try container.decodeIfPresent(String.self, forKey: .lastDailyTicketDayIdentifier)
        hasUsedFirstFreeGacha = try container.decodeIfPresent(Bool.self, forKey: .hasUsedFirstFreeGacha) ?? false
        unlockedRoomSkins = try container.decodeIfPresent([RoomSkin].self, forKey: .unlockedRoomSkins) ?? [.deskGap]
        if !unlockedRoomSkins.contains(.deskGap) {
            unlockedRoomSkins.append(.deskGap)
        }
        activeRoomSkin = try container.decodeIfPresent(RoomSkin.self, forKey: .activeRoomSkin) ?? .deskGap
        discoveredHideouts = try container.decodeIfPresent([HideoutKind].self, forKey: .discoveredHideouts) ?? []
        hideoutInventory = try container.decodeIfPresent([HideoutKind: Int].self, forKey: .hideoutInventory) ?? [:]
        hideoutInventory = hideoutInventory.filter { $0.value > 0 }
        discoveredRoachVariants = try container.decodeIfPresent([RoachVariant].self, forKey: .discoveredRoachVariants) ?? []
    }

    var recentEntries: [ObservationEntry] {
        journalEntries.sorted { $0.date > $1.date }
    }

    var favoriteRecord: NamedRoachRecord? {
        guard let favoriteRoachID else { return nil }
        return namedHistory.first { $0.id == favoriteRoachID }
    }

    mutating func syncFavorite(with colony: ColonyState) {
        if let named = colony.namedRoach {
            if favoriteRoachID != named.id {
                favoriteRoachID = named.id
                favoriteName = named.name
                favoriteStartedAt = Date()
                addEntry(
                    title: String(localized: "推し個体を記録"),
                    detail: String(localized: "\(named.name ?? String(localized: "名なし"))を追跡対象にした。"),
                    kind: .record
                )
            }
            updateNamedRecord(for: named)
            return
        }

        if favoriteRoachID != nil, favoriteName != nil {
            addEntry(
                title: String(localized: "推し個体の記録終了"),
                detail: String(localized: "\(favoriteName ?? String(localized: "名前つき個体"))の姿が見えなくなった。"),
                kind: .alert
            )
            self.favoriteRoachID = nil
            favoriteName = nil
            favoriteStartedAt = nil
        }
    }

    mutating func refreshRecords(with colony: ColonyState) {
        maxColonyCount = max(maxColonyCount, colony.totalCount)
        maxEggCaseCount = max(maxEggCaseCount, colony.eggCases.count)
        longestLivedDays = max(longestLivedDays, colony.roaches.map { $0.age / (24 * 60 * 60) }.max() ?? 0)
        fastestRecordedSpeedMultiplier = max(fastestRecordedSpeedMultiplier ?? 0, colony.roaches.map(\.speedMultiplier).max() ?? 0)

        if colony.totalCount > lastLoggedTotalCount {
            addEntry(
                title: String(localized: "群れが増えた"),
                detail: String(localized: "\(lastLoggedTotalCount)匹から\(colony.totalCount)匹になった。"),
                kind: .breeding
            )
        }

        if colony.eggCases.count > lastLoggedEggCaseCount {
            addEntry(
                title: String(localized: "卵鞘を発見"),
                detail: String(localized: "暗いすき間に新しい卵鞘が置かれている。"),
                kind: .breeding
            )
        }

        if colony.bestRecordedLengthCm > lastLoggedMaxLengthCm {
            addEntry(
                title: String(localized: "最大サイズ更新"),
                detail: String(localized: "\(colony.bestRecordedLengthCm.formatted(.number.precision(.fractionLength(1))))cmの個体を確認。"),
                kind: .growth
            )
        }

        lastLoggedTotalCount = colony.totalCount
        lastLoggedEggCaseCount = colony.eggCases.count
        lastLoggedMaxLengthCm = colony.bestRecordedLengthCm
        syncFavorite(with: colony)
        trimEntries()
    }

    mutating func recordCare(tool: CareTool) {
        lastCareDates[tool] = Date()
        switch tool {
        case .food:
            addEntry(title: String(localized: "餌を置いた"), detail: String(localized: "すき間の奥へ餌を差し入れた。"), kind: .care)
        case .water:
            addEntry(title: String(localized: "水を足した"), detail: String(localized: "床に小さな水たまりを作った。"), kind: .care)
        case .light:
            addEntry(title: String(localized: "光を当てた"), detail: String(localized: "群れが一斉に奥へ散った。"), kind: .care)
        }
    }

    var canDrawDailyGacha: Bool {
        canAffordGacha(count: 1) || canAffordGacha(count: 10)
    }

    mutating func recordGachaReward(_ reward: GachaReward) {
        recordGachaRewards([reward])
    }

    mutating func recordGachaRewards(_ rewards: [GachaReward]) {
        guard !rewards.isEmpty else { return }
        lastGachaDate = Date()
        gachaHistory.append(contentsOf: rewards)

        for reward in rewards {
            if let roomSkin = reward.roomSkin {
                if !unlockedRoomSkins.contains(roomSkin) {
                    unlockedRoomSkins.append(roomSkin)
                }
                activeRoomSkin = roomSkin
            }
            if let hideoutKind = reward.hideoutKind {
                if !discoveredHideouts.contains(hideoutKind) {
                    discoveredHideouts.append(hideoutKind)
                }
                hideoutInventory[hideoutKind, default: 0] += 1
            }
            if let roachVariant = reward.roachVariant, !discoveredRoachVariants.contains(roachVariant) {
                discoveredRoachVariants.append(roachVariant)
            }
        }

        if rewards.count == 1, let reward = rewards.first {
            addEntry(
                title: String(localized: "\(reward.rarity.title)を引いた"),
                detail: String(localized: "\(reward.category.title)「\(reward.title)」を獲得。"),
                kind: reward.rarity == .legend ? .record : .care
            )
        } else {
            let highest = rewards.max { $0.rarity.rank < $1.rarity.rank }
            addEntry(
                title: String(localized: "10連ガチャを引いた"),
                detail: String(localized: "10個獲得。最高レア度は\(highest?.rarity.title ?? String(localized: "ノーマル"))。"),
                kind: highest?.rarity == .legend ? .record : .care
            )
        }
        trimEntries()
    }

    mutating func grantDailyGachaTicketIfNeeded() -> Bool {
        let today = DailyCareUsage.currentDayIdentifier()
        guard lastDailyTicketDayIdentifier != today else { return false }
        lastDailyTicketDayIdentifier = today
        gachaTickets += 1
        addEntry(title: String(localized: "デイリーチケット"), detail: String(localized: "Gガチャチケットを1枚受け取った。"), kind: .care)
        return true
    }

    mutating func grantRewardedGachaTicket() {
        gachaTickets += 1
        addEntry(title: String(localized: "広告リワード"), detail: String(localized: "動画広告を見てGガチャチケットを1枚受け取った。"), kind: .care)
    }

    func gachaCost(for count: Int) -> Int {
        count == 1 && !hasUsedFirstFreeGacha ? 0 : count * 2
    }

    func canAffordGacha(count: Int) -> Bool {
        let cost = gachaCost(for: count)
        return count == 1 || count == 10 ? gachaTickets >= cost : false
    }

    mutating func consumeGachaCost(count: Int) -> Bool {
        guard canAffordGacha(count: count) else { return false }
        if count == 1, !hasUsedFirstFreeGacha {
            hasUsedFirstFreeGacha = true
            return true
        }
        gachaTickets -= count * 2
        return true
    }

    mutating func removeLegacyRareRoachRecords() {
        discoveredRoachVariants.removeAll()
        gachaHistory.removeAll { $0.category == .rareRoach }
    }

    mutating func consumeHideout(_ kind: HideoutKind) -> Bool {
        guard let count = hideoutInventory[kind], count > 0 else { return false }
        if count == 1 {
            hideoutInventory[kind] = nil
        } else {
            hideoutInventory[kind] = count - 1
        }
        return true
    }

    mutating func addEntry(title: String, detail: String, kind: ObservationKind) {
        journalEntries.append(ObservationEntry(date: Date(), title: title, detail: detail, kind: kind))
        trimEntries()
    }

    private mutating func updateNamedRecord(for roach: Roach) {
        guard let name = roach.name, !name.isEmpty else { return }
        if let index = namedHistory.firstIndex(where: { $0.id == roach.id }) {
            namedHistory[index].name = name
            namedHistory[index].lastSeenAt = Date()
            namedHistory[index].bestLengthCm = max(namedHistory[index].bestLengthCm, roach.lengthCm)
            namedHistory[index].longestAge = max(namedHistory[index].longestAge, roach.age)
        } else {
            namedHistory.append(
                NamedRoachRecord(
                    id: roach.id,
                    name: name,
                    firstSeenAt: Date(),
                    lastSeenAt: Date(),
                    bestLengthCm: roach.lengthCm,
                    longestAge: roach.age
                )
            )
        }
    }

    private mutating func trimEntries() {
        if journalEntries.count > 80 {
            journalEntries = Array(journalEntries.suffix(80))
        }
        if namedHistory.count > 20 {
            namedHistory = Array(namedHistory.suffix(20))
        }
        if gachaHistory.count > 40 {
            gachaHistory = Array(gachaHistory.suffix(40))
        }
    }
}
