//
//  GachaEntities.swift
//  RoachBreeder
//

import Foundation

enum GachaCategory: String, Codable {
    case rareRoach
    case roomSkin
    case hideout

    var title: String {
        switch self {
        case .rareRoach:
            return String(localized: "特殊な卵鞘")
        case .roomSkin:
            return String(localized: "部屋スキン")
        case .hideout:
            return String(localized: "隠れ家")
        }
    }
}

enum GachaRarity: String, Codable, CaseIterable {
    case normal
    case rare
    case superRare
    case legend

    var title: String {
        switch self {
        case .normal:
            return String(localized: "ノーマル")
        case .rare:
            return String(localized: "レア")
        case .superRare:
            return String(localized: "激レア")
        case .legend:
            return String(localized: "伝説")
        }
    }

    var rank: Int {
        switch self {
        case .normal: return 0
        case .rare: return 1
        case .superRare: return 2
        case .legend: return 3
        }
    }
}

enum RoomSkin: String, Codable, CaseIterable {
    case deskGap
    case fridgeBottom
    case kitchenShelf
    case tatamiEdge
    case cardboardNest

    var title: String {
        switch self {
        case .deskGap:
            return String(localized: "机と棚のすき間")
        case .fridgeBottom:
            return String(localized: "冷蔵庫下")
        case .kitchenShelf:
            return String(localized: "台所の棚裏")
        case .tatamiEdge:
            return String(localized: "畳の端")
        case .cardboardNest:
            return String(localized: "段ボール置き場")
        }
    }
}

enum HideoutKind: String, Codable, CaseIterable {
    case paper
    case receipt
    case woodChip
    case cloth
    case cable
    case darkBox
    case foil
    case bottleCap
    case tape
    case matchbox
    case snackWrapper
    case roachTrap
    case plasticShard
    case dustPocket
    case drainPipe

    var title: String {
        switch self {
        case .paper:
            return String(localized: "紙くず")
        case .receipt:
            return String(localized: "古いレシート")
        case .woodChip:
            return String(localized: "木片")
        case .cloth:
            return String(localized: "布切れ")
        case .cable:
            return String(localized: "切れた配線")
        case .darkBox:
            return String(localized: "黒い箱")
        case .foil:
            return String(localized: "銀紙")
        case .bottleCap:
            return String(localized: "ボトルキャップ")
        case .tape:
            return String(localized: "粘着テープ")
        case .matchbox:
            return String(localized: "空き箱")
        case .snackWrapper:
            return String(localized: "お菓子の袋の破片")
        case .roachTrap:
            return String(localized: "ゴキブリホイホイ")
        case .plasticShard:
            return String(localized: "プラスチックの破片")
        case .dustPocket:
            return String(localized: "埃だまり")
        case .drainPipe:
            return String(localized: "排水管の影")
        }
    }

    var assetName: String {
        switch self {
        case .paper:
            return "HideoutPaper"
        case .receipt:
            return "HideoutReceipt"
        case .woodChip:
            return "HideoutWoodChip"
        case .cloth:
            return "HideoutCloth"
        case .cable:
            return "HideoutCable"
        case .darkBox:
            return "HideoutDarkBox"
        case .foil:
            return "HideoutPaper"
        case .bottleCap:
            return "HideoutBottleCap"
        case .tape:
            return "HideoutTape"
        case .matchbox:
            return "HideoutMatchbox"
        case .snackWrapper:
            return "HideoutSnackWrapper"
        case .roachTrap:
            return "HideoutRoachTrap"
        case .plasticShard:
            return "HideoutPlasticShard"
        case .dustPocket:
            return "HideoutCloth"
        case .drainPipe:
            return "HideoutCable"
        }
    }
}

enum RoachVariant: String, Codable, CaseIterable {
    case normal
    case jetBlack = "glossyBlack"
    case redCopper = "amber"
    case golden = "gold"
    case albino = "ghost"
    case scarredBlack = "speedster"
    case silverBack = "giantBlood"
    case oilSlick

    var title: String {
        switch self {
        case .normal:
            return String(localized: "通常個体")
        case .jetBlack:
            return String(localized: "漆黒")
        case .redCopper:
            return String(localized: "赤銅")
        case .golden:
            return String(localized: "黄金")
        case .albino:
            return String(localized: "白化")
        case .scarredBlack:
            return String(localized: "傷黒")
        case .silverBack:
            return String(localized: "銀背")
        case .oilSlick:
            return String(localized: "油膜")
        }
    }

    var roachAnimationAssetNames: [String]? {
        switch self {
        case .normal:
            return nil
        case .jetBlack:
            return (1...6).map { String(format: "RoachJetBlackFrame%02d", $0) }
        case .redCopper:
            return (1...5).map { String(format: "RoachRedCopperFrame%02d", $0) }
        case .golden:
            return (1...6).map { String(format: "RoachGoldenFrame%02d", $0) }
        case .albino:
            return (1...6).map { String(format: "RoachAlbinoFrame%02d", $0) }
        case .scarredBlack:
            return (1...6).map { String(format: "RoachScarredBlackFrame%02d", $0) }
        case .silverBack:
            return (1...6).map { String(format: "RoachSilverBackFrame%02d", $0) }
        case .oilSlick:
            return (1...6).map { String(format: "RoachOilSlickFrame%02d", $0) }
        }
    }

    var roachPortraitAssetName: String {
        roachAnimationAssetNames?.first ?? "RoachFrame01"
    }

    var speedMultiplierRange: ClosedRange<Double> {
        switch self {
        case .normal:
            return 0.82...1.22
        case .redCopper, .jetBlack, .oilSlick:
            return 1.15...1.30
        case .scarredBlack, .silverBack, .albino:
            return 1.31...1.50
        case .golden:
            return 1.60...1.80
        }
    }

    func clampedSpeedMultiplier(_ value: Double) -> Double {
        min(speedMultiplierRange.upperBound, max(speedMultiplierRange.lowerBound, value))
    }

    var eggAssetName: String? {
        switch self {
        case .normal:
            return nil
        case .jetBlack:
            return "OothecaJetBlack"
        case .redCopper:
            return "OothecaRedCopper"
        case .golden:
            return "OothecaGolden"
        case .albino:
            return "OothecaAlbino"
        case .scarredBlack:
            return "OothecaScarredBlack"
        case .silverBack:
            return "OothecaSilverBack"
        case .oilSlick:
            return "OothecaOilSlick"
        }
    }
}

struct GachaReward: Identifiable, Codable {
    var id = UUID()
    var date = Date()
    var category: GachaCategory
    var rarity: GachaRarity
    var title: String
    var detail: String
    var roachVariant: RoachVariant?
    var roomSkin: RoomSkin?
    var hideoutKind: HideoutKind?

    var localizedTitle: String {
        GachaCatalog.item(matching: self)?.title ?? PersistedTextLocalizer.localize(title)
    }

    var localizedDetail: String {
        GachaCatalog.item(matching: self)?.detail ?? PersistedTextLocalizer.localize(detail)
    }
}

struct GachaCatalogItem {
    let category: GachaCategory
    let rarity: GachaRarity
    let title: String
    let detail: String
    let weight: Int
    let roachVariant: RoachVariant?
    let roomSkin: RoomSkin?
    let hideoutKind: HideoutKind?

    func reward() -> GachaReward {
        GachaReward(
            category: category,
            rarity: rarity,
            title: title,
            detail: detail,
            roachVariant: roachVariant,
            roomSkin: roomSkin,
            hideoutKind: hideoutKind
        )
    }
}

enum GachaCatalog {
    static let items: [GachaCatalogItem] = [
        .init(category: .hideout, rarity: .normal, title: String(localized: "紙くず"), detail: String(localized: "下に潜れる薄い隠れ家。"), weight: 20, roachVariant: nil, roomSkin: nil, hideoutKind: .paper),
        .init(category: .hideout, rarity: .rare, title: String(localized: "木片"), detail: String(localized: "暗い影ができて群れが落ち着く。"), weight: 10, roachVariant: nil, roomSkin: nil, hideoutKind: .woodChip),
        .init(category: .hideout, rarity: .normal, title: String(localized: "布切れ"), detail: String(localized: "埃っぽい影ができる、柔らかい隠れ家。"), weight: 20, roachVariant: nil, roomSkin: nil, hideoutKind: .cloth),
        .init(category: .hideout, rarity: .normal, title: String(localized: "古いレシート"), detail: String(localized: "生活感が強い薄型の隠れ家。"), weight: 20, roachVariant: nil, roomSkin: nil, hideoutKind: .receipt),
        .init(category: .hideout, rarity: .rare, title: String(localized: "ボトルキャップ"), detail: String(localized: "丸い影の中に潜れる隠れ家。"), weight: 10, roachVariant: nil, roomSkin: nil, hideoutKind: .bottleCap),
        .init(category: .hideout, rarity: .normal, title: String(localized: "粘着テープ"), detail: String(localized: "床に貼り付いた薄い障害物。"), weight: 20, roachVariant: nil, roomSkin: nil, hideoutKind: .tape),
        .init(category: .hideout, rarity: .rare, title: String(localized: "プラスチックの破片"), detail: String(localized: "白く濁った薄い破片。床の汚れに紛れて潜り込める。"), weight: 10, roachVariant: nil, roomSkin: nil, hideoutKind: .plasticShard),
        .init(category: .hideout, rarity: .rare, title: String(localized: "お菓子の袋の破片"), detail: String(localized: "油染みと甘い匂いが残る、群れが寄りやすい破片。"), weight: 10, roachVariant: nil, roomSkin: nil, hideoutKind: .snackWrapper),
        .init(category: .hideout, rarity: .rare, title: String(localized: "空き箱"), detail: String(localized: "奥行きがある暗い避難場所。"), weight: 10, roachVariant: nil, roomSkin: nil, hideoutKind: .matchbox),
        .init(category: .hideout, rarity: .superRare, title: String(localized: "切れた配線"), detail: String(localized: "壁際を走る個体が集まりやすい。"), weight: 5, roachVariant: nil, roomSkin: nil, hideoutKind: .cable),
        .init(category: .hideout, rarity: .legend, title: String(localized: "ゴキブリホイホイ"), detail: String(localized: "2センチほどの禁断の隠れ家。入った瞬間だけ部屋の空気が変わる。"), weight: 1, roachVariant: nil, roomSkin: nil, hideoutKind: .roachTrap),
        .init(category: .hideout, rarity: .rare, title: String(localized: "黒い箱"), detail: String(localized: "奥が見えない黒い隠れ家。"), weight: 10, roachVariant: nil, roomSkin: nil, hideoutKind: .darkBox),

        .init(category: .roomSkin, rarity: .rare, title: String(localized: "冷蔵庫下"), detail: String(localized: "湿った暗さが強い部屋スキン。"), weight: 10, roachVariant: nil, roomSkin: .fridgeBottom, hideoutKind: nil),
        .init(category: .roomSkin, rarity: .rare, title: String(localized: "台所の棚裏"), detail: String(localized: "食べかすが似合う部屋スキン。"), weight: 9, roachVariant: nil, roomSkin: .kitchenShelf, hideoutKind: nil),
        .init(category: .roomSkin, rarity: .superRare, title: String(localized: "畳の端"), detail: String(localized: "和室の端に棲みついた雰囲気。"), weight: 5, roachVariant: nil, roomSkin: .tatamiEdge, hideoutKind: nil),
        .init(category: .roomSkin, rarity: .legend, title: String(localized: "段ボール置き場"), detail: String(localized: "繁殖していそうな密度の高いスキン。"), weight: 1, roachVariant: nil, roomSkin: .cardboardNest, hideoutKind: nil),

        .init(category: .rareRoach, rarity: .rare, title: String(localized: "赤銅の卵鞘"), detail: String(localized: "深い赤茶色の個体が眠る卵鞘。"), weight: 4, roachVariant: .redCopper, roomSkin: nil, hideoutKind: nil),
        .init(category: .rareRoach, rarity: .superRare, title: String(localized: "傷黒の卵鞘"), detail: String(localized: "白い傷模様を持つ黒い個体が眠る。"), weight: 2, roachVariant: .scarredBlack, roomSkin: nil, hideoutKind: nil),
        .init(category: .rareRoach, rarity: .rare, title: String(localized: "漆黒の卵鞘"), detail: String(localized: "濡れたような黒い光沢を持つ血統。"), weight: 4, roachVariant: .jetBlack, roomSkin: nil, hideoutKind: nil),
        .init(category: .rareRoach, rarity: .superRare, title: String(localized: "銀背の卵鞘"), detail: String(localized: "銀灰色の羽を持つ個体が眠る。"), weight: 2, roachVariant: .silverBack, roomSkin: nil, hideoutKind: nil),
        .init(category: .rareRoach, rarity: .rare, title: String(localized: "油膜の卵鞘"), detail: String(localized: "黒い体に青紫の構造色が浮かぶ血統。"), weight: 4, roachVariant: .oilSlick, roomSkin: nil, hideoutKind: nil),
        .init(category: .rareRoach, rarity: .superRare, title: String(localized: "白化の卵鞘"), detail: String(localized: "乳白色の個体が眠る、異様に白い卵鞘。"), weight: 2, roachVariant: .albino, roomSkin: nil, hideoutKind: nil),
        .init(category: .rareRoach, rarity: .legend, title: String(localized: "黄金の卵鞘"), detail: String(localized: "全身が金色の伝説個体が眠る。"), weight: 1, roachVariant: .golden, roomSkin: nil, hideoutKind: nil)
    ]

    static func draw() -> GachaReward {
        let totalWeight = items.reduce(0) { $0 + $1.weight }
        var ticket = Int.random(in: 0..<max(1, totalWeight))
        for item in items {
            if ticket < item.weight {
                return item.reward()
            }
            ticket -= item.weight
        }
        return items[0].reward()
    }

    static func item(matching reward: GachaReward) -> GachaCatalogItem? {
        items.first { item in
            if let hideoutKind = reward.hideoutKind {
                return item.hideoutKind == hideoutKind
            }
            if let roomSkin = reward.roomSkin {
                return item.roomSkin == roomSkin
            }
            if let roachVariant = reward.roachVariant {
                return item.roachVariant == roachVariant
            }
            return false
        }
    }
}
