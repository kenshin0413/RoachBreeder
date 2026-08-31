//
//  GameEntities.swift
//  RoachBreeder
//

import CoreGraphics
import Foundation

struct Roach: Identifiable, Codable {
    var id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var angle: CGFloat
    var activity: RoachActivity
    var stage: RoachStage
    var sex: RoachSex
    var size: CGFloat
    var decisionTimer: Double
    var age: Double
    var matureDuration: Double
    var foodEaten: Double
    var waterDrunk: Double
    var unfedWhileFoodAvailable: Double
    var criticalWithoutFoodTimer: Double
    var condition: RoachCondition
    var lengthCm: Double
    var lengthGrowthPoints: Double
    var speedMultiplier: Double
    var variant: RoachVariant
    var name: String?

    init(
        id: UUID = UUID(),
        position: CGPoint,
        velocity: CGVector,
        angle: CGFloat,
        activity: RoachActivity,
        stage: RoachStage,
        sex: RoachSex,
        size: CGFloat,
        decisionTimer: Double,
        age: Double,
        matureDuration: Double,
        foodEaten: Double = 0,
        waterDrunk: Double = 0,
        unfedWhileFoodAvailable: Double = 0,
        criticalWithoutFoodTimer: Double = 0,
        condition: RoachCondition = .healthy,
        lengthCm: Double,
        lengthGrowthPoints: Double = 0,
        speedMultiplier: Double = Double.random(in: 0.82...1.22),
        variant: RoachVariant = .normal,
        name: String? = nil
    ) {
        self.id = id
        self.position = position
        self.velocity = velocity
        self.angle = angle
        self.activity = activity
        self.stage = stage
        self.sex = sex
        self.size = size
        self.decisionTimer = decisionTimer
        self.age = age
        self.matureDuration = matureDuration
        self.foodEaten = foodEaten
        self.waterDrunk = waterDrunk
        self.unfedWhileFoodAvailable = unfedWhileFoodAvailable
        self.criticalWithoutFoodTimer = criticalWithoutFoodTimer
        self.condition = condition
        self.lengthCm = lengthCm
        self.lengthGrowthPoints = lengthGrowthPoints
        self.speedMultiplier = speedMultiplier
        self.variant = variant
        self.name = name
    }

    static func random(stage: RoachStage, sex: RoachSex = .random(), variant: RoachVariant = .normal, in size: CGSize) -> Roach {
        let width = max(size.width, 120)
        let height = max(size.height, 160)
        let angle = CGFloat.random(in: 0...(2 * .pi))

        let lengthCm: Double
        switch variant {
        case .silverBack:
            lengthCm = stage == .adult ? Double.random(in: 1.1...1.3) : 0.3
        default:
            lengthCm = stage == .adult ? Double.random(in: 0.8...1.1) : 0.2
        }

        let speedMultiplier = Double.random(in: variant.speedMultiplierRange)

        return Roach(
            position: CGPoint(
                x: CGFloat.random(in: 34...(width - 34)),
                y: CGFloat.random(in: 46...(height - 46))
            ),
            velocity: .zero,
            angle: angle,
            activity: .idle,
            stage: stage,
            sex: sex,
            size: Self.renderSize(for: lengthCm),
            decisionTimer: Double.random(in: 0.4...2.2),
            age: 0,
            matureDuration: 36 * 24 * 60 * 60,
            foodEaten: 0,
            waterDrunk: 0,
            unfedWhileFoodAvailable: 0,
            criticalWithoutFoodTimer: 0,
            condition: .healthy,
            lengthCm: lengthCm,
            speedMultiplier: speedMultiplier,
            variant: variant
        )
    }

    static func renderSize(for lengthCm: Double) -> CGFloat {
        CGFloat(20 + min(2.0, max(0.2, lengthCm)) * 26)
    }

    var nutritionScore: Double {
        foodEaten * 0.8 + waterDrunk * 0.45
    }

    var adultSizeTier: Int {
        guard stage == .adult else { return 0 }
        switch nutritionScore {
        case 420...:
            return 3
        case 220...:
            return 2
        case 80...:
            return 1
        default:
            return 0
        }
    }

    var targetAdultSize: CGFloat {
        let sexBonus: CGFloat = sex == .female ? 2 : 0
        switch adultSizeTier {
        case 3:
            return 68 + sexBonus
        case 2:
            return 59 + sexBonus
        case 1:
            return 51 + sexBonus
        default:
            return 43 + sexBonus
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case position
        case velocity
        case angle
        case activity
        case stage
        case sex
        case size
        case decisionTimer
        case age
        case matureDuration
        case foodEaten
        case waterDrunk
        case unfedWhileFoodAvailable
        case criticalWithoutFoodTimer
        case condition
        case lengthCm
        case lengthGrowthPoints
        case speedMultiplier
        case variant
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        position = try container.decode(CGPoint.self, forKey: .position)
        velocity = try container.decode(CGVector.self, forKey: .velocity)
        angle = try container.decode(CGFloat.self, forKey: .angle)
        activity = try container.decode(RoachActivity.self, forKey: .activity)
        stage = try container.decode(RoachStage.self, forKey: .stage)
        sex = try container.decodeIfPresent(RoachSex.self, forKey: .sex) ?? .random()
        size = try container.decode(CGFloat.self, forKey: .size)
        decisionTimer = try container.decode(Double.self, forKey: .decisionTimer)
        age = try container.decode(Double.self, forKey: .age)
        matureDuration = try container.decode(Double.self, forKey: .matureDuration)
        foodEaten = try container.decodeIfPresent(Double.self, forKey: .foodEaten) ?? 0
        waterDrunk = try container.decodeIfPresent(Double.self, forKey: .waterDrunk) ?? 0
        unfedWhileFoodAvailable = try container.decodeIfPresent(Double.self, forKey: .unfedWhileFoodAvailable) ?? 0
        criticalWithoutFoodTimer = try container.decodeIfPresent(Double.self, forKey: .criticalWithoutFoodTimer) ?? 0
        condition = try container.decodeIfPresent(RoachCondition.self, forKey: .condition) ?? .healthy
        lengthCm = try container.decodeIfPresent(Double.self, forKey: .lengthCm)
            ?? (stage == .adult ? max(0.7, min(1.2, Double(size) / 54.0)) : 0.2)
        lengthGrowthPoints = try container.decodeIfPresent(Double.self, forKey: .lengthGrowthPoints) ?? 0
        variant = try container.decodeIfPresent(RoachVariant.self, forKey: .variant) ?? .normal
        speedMultiplier = try container.decodeIfPresent(Double.self, forKey: .speedMultiplier)
            ?? Double.random(in: variant.speedMultiplierRange)
        speedMultiplier = variant.clampedSpeedMultiplier(speedMultiplier)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        size = Self.renderSize(for: lengthCm)
    }
}

enum RoachActivity: Codable {
    case idle
    case walking
    case eating
    case resting
    case fleeing
}

enum RoachStage: Codable {
    case adult
    case nymph
}

enum RoachSex: Codable {
    case male
    case female

    static func random() -> RoachSex {
        Bool.random() ? .male : .female
    }
}

enum RoachCondition: Codable {
    case healthy
    case critical
    case dead
}

struct Food: Identifiable, Codable {
    var id = UUID()
    var position: CGPoint
    var amount: Double
}

struct WaterSpot: Identifiable, Codable {
    var id = UUID()
    var position: CGPoint
    var amount: Double
}

struct EggCase: Identifiable, Codable {
    var id = UUID()
    var position: CGPoint
    var progress: Double = 0
    var hatchDuration: Double = 10 * 24 * 60 * 60
    var variant: RoachVariant? = nil
}

struct Hideout: Identifiable, Codable {
    var id = UUID()
    var position: CGPoint
    var size: CGSize
    var kind: HideoutKind = .paper

    private enum CodingKeys: String, CodingKey {
        case id
        case position
        case size
        case kind
    }

    init(id: UUID = UUID(), position: CGPoint, size: CGSize, kind: HideoutKind = .paper) {
        self.id = id
        self.position = position
        self.size = size
        self.kind = kind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        position = try container.decode(CGPoint.self, forKey: .position)
        size = try container.decode(CGSize.self, forKey: .size)
        kind = try container.decodeIfPresent(HideoutKind.self, forKey: .kind) ?? .paper
    }
}

enum CareTool: String, Codable, CaseIterable {
    case food
    case water
    case light

    var title: String {
        switch self {
        case .food:
            return String(localized: "餌")
        case .water:
            return String(localized: "水")
        case .light:
            return String(localized: "光")
        }
    }
}

struct DailyCareUsage: Codable {
    static let baseUsesPerDay = 1
    static let maxBonusUsesPerDay = 1

    var dayIdentifier: String
    var foodUsed: Int
    var waterUsed: Int
    var lightUsed: Int
    var bonusFoodUses: Int
    var bonusWaterUses: Int
    var bonusLightUses: Int

    static func current() -> DailyCareUsage {
        DailyCareUsage(
            dayIdentifier: Self.currentDayIdentifier(),
            foodUsed: 0,
            waterUsed: 0,
            lightUsed: 0,
            bonusFoodUses: 0,
            bonusWaterUses: 0,
            bonusLightUses: 0
        )
    }

    static func currentDayIdentifier() -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }

    mutating func resetIfNeeded() {
        let today = Self.currentDayIdentifier()
        guard dayIdentifier != today else { return }
        dayIdentifier = today
        foodUsed = 0
        waterUsed = 0
        lightUsed = 0
        bonusFoodUses = 0
        bonusWaterUses = 0
        bonusLightUses = 0
    }

    func remainingUses(for tool: CareTool) -> Int {
        let allowance = Self.baseUsesPerDay + bonusUses(for: tool)
        return max(0, allowance - usedCount(for: tool))
    }

    mutating func consume(_ tool: CareTool) -> Bool {
        resetIfNeeded()
        guard remainingUses(for: tool) > 0 else { return false }
        switch tool {
        case .food:
            foodUsed += 1
        case .water:
            waterUsed += 1
        case .light:
            lightUsed += 1
        }
        return true
    }

    mutating func grantBonusUse(for tool: CareTool) {
        resetIfNeeded()
        guard canGrantBonusUse(for: tool) else { return }
        switch tool {
        case .food:
            bonusFoodUses = min(Self.maxBonusUsesPerDay, bonusFoodUses + 1)
        case .water:
            bonusWaterUses = min(Self.maxBonusUsesPerDay, bonusWaterUses + 1)
        case .light:
            bonusLightUses = min(Self.maxBonusUsesPerDay, bonusLightUses + 1)
        }
    }

    func canGrantBonusUse(for tool: CareTool) -> Bool {
        var copy = self
        copy.resetIfNeeded()
        return copy.bonusUses(for: tool) < Self.maxBonusUsesPerDay
    }

    private func usedCount(for tool: CareTool) -> Int {
        switch tool {
        case .food:
            return foodUsed
        case .water:
            return waterUsed
        case .light:
            return lightUsed
        }
    }

    private func bonusUses(for tool: CareTool) -> Int {
        switch tool {
        case .food:
            return bonusFoodUses
        case .water:
            return bonusWaterUses
        case .light:
            return bonusLightUses
        }
    }
}
