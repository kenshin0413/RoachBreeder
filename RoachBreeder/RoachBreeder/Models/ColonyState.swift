//
//  ColonyState.swift
//  RoachBreeder
//

import CoreGraphics
import Foundation

struct ColonyState: Codable {
    static let breedingThreshold: Double = 480
    static let eggHatchDuration: Double = 10 * 24 * 60 * 60
    static let fastestMatureDuration: Double = 36 * 24 * 60 * 60
    static let eggCaseFillDurationAtBest: Double = 24 * 24 * 60 * 60
    static let maxRoachCount: Int = 60
    static let criticalFoodMissDuration: Double = 3 * 24 * 60 * 60
    static let deathAfterCriticalDuration: Double = 24 * 60 * 60
    static let maxLengthCm: Double = 2.0
    static let minLengthCm: Double = 0.2
    static let lengthStepCm: Double = 0.1
    static let lengthGrowthPointsPerStep: Double = 14

    var adultCount: Int
    var nymphCount: Int
    var breedingPoints: Double
    var water: Double
    var safety: Double
    var nestSpace: Int
    var roaches: [Roach]
    var foods: [Food]
    var waterSpots: [WaterSpot]
    var eggCases: [EggCase]
    var hides: [Hideout]
    var passiveEggTimer: Double
    var nymphGrowthTimer: Double
    var careUsage: DailyCareUsage?
    var maxRecordedLengthCm: Double?
    var maxRecordedRoachSex: RoachSex?

    var totalCount: Int {
        roaches.count
    }

    var maleCount: Int {
        roaches.filter { $0.sex == .male }.count
    }

    var femaleCount: Int {
        roaches.filter { $0.sex == .female }.count
    }

    var adultMaleCount: Int {
        roaches.filter { $0.stage == .adult && $0.sex == .male }.count
    }

    var adultFemaleCount: Int {
        roaches.filter { $0.stage == .adult && $0.sex == .female }.count
    }

    var breedingProgress: Double {
        min(1, breedingPoints / Self.breedingThreshold)
    }

    var visibleCountLimit: Int {
        min(24, max(12, nestSpace / 3))
    }

    var namedRoach: Roach? {
        roaches.first { ($0.name?.isEmpty == false) }
    }

    var bestRecordedLengthCm: Double {
        maxRecordedLengthCm ?? roaches.map(\.lengthCm).max() ?? Self.minLengthCm
    }

    var bestRecordedRoachSex: RoachSex {
        maxRecordedRoachSex ?? roaches.max { $0.lengthCm < $1.lengthCm }?.sex ?? .female
    }

    mutating func migrateToCurrentTimingRules() {
        ensureDailyCareUsage()
        ensureSingleNamedRoach()

        for index in eggCases.indices {
            let wasLegacyTiming = eggCases[index].hatchDuration < Self.eggHatchDuration
            eggCases[index].hatchDuration = Self.eggHatchDuration
            if wasLegacyTiming {
                eggCases[index].progress = min(eggCases[index].progress, 0.01)
            }
        }

        for index in roaches.indices where roaches[index].stage == .nymph {
            let wasLegacyTiming = roaches[index].matureDuration < Self.fastestMatureDuration
            roaches[index].matureDuration = Self.fastestMatureDuration
            if wasLegacyTiming {
                roaches[index].age = min(roaches[index].age, Self.fastestMatureDuration * 0.01)
            }
        }
        reconcileCountsWithVisibleRoaches()
        updateMaxRecordedLength()
    }

    static func bootstrap() -> ColonyState {
        let hides = [
            Hideout(position: CGPoint(x: 108, y: 96), size: CGSize(width: 132, height: 64)),
            Hideout(position: CGPoint(x: 310, y: 354), size: CGSize(width: 156, height: 72)),
            Hideout(position: CGPoint(x: 74, y: 356), size: CGSize(width: 92, height: 52))
        ]

        return ColonyState(
            adultCount: 2,
            nymphCount: 0,
            breedingPoints: 0,
            water: 70,
            safety: 74,
            nestSpace: 42,
            roaches: [
                Roach.random(stage: .adult, sex: .male, in: CGSize(width: 360, height: 440)),
                Roach.random(stage: .adult, sex: .female, in: CGSize(width: 360, height: 440))
            ],
            foods: [],
            waterSpots: [],
            eggCases: [],
            hides: hides,
            passiveEggTimer: 0,
            nymphGrowthTimer: 0,
            careUsage: .current(),
            maxRecordedLengthCm: nil,
            maxRecordedRoachSex: nil
        )
    }

    mutating func fitInitialPositions(in size: CGSize) {
        guard size.width > 20, size.height > 20 else { return }
        reconcileCountsWithVisibleRoaches()
        roaches = roaches.map { roach in
            var copy = roach
            copy.position = copy.position.clamped(to: size, inset: 28)
            return copy
        }
    }

    mutating func advance(in size: CGSize, delta: Double) {
        guard size.width > 20, size.height > 20 else { return }
        reconcileCountsWithVisibleRoaches()

        nymphGrowthTimer += delta
        let environmentMultiplier = max(0.35, (water / 100) * (safety / 100))
        breedingPoints += breedingPointGainPerSecond * environmentMultiplier * delta
        water = max(0, water - 0.025 * delta)

        let foodAvailableAtTick = foods.contains { $0.amount > 0 }
        for index in roaches.indices {
            updateRoach(at: index, in: size, delta: delta, foodAvailableAtTick: foodAvailableAtTick)
        }
        removeDeadRoaches()

        foods.removeAll { $0.amount <= 0 }
        for index in waterSpots.indices {
            waterSpots[index].amount -= 0.40 * delta
        }
        waterSpots.removeAll { $0.amount <= 2 }

        for index in eggCases.indices {
            eggCases[index].hatchDuration = Self.eggHatchDuration
            eggCases[index].progress += delta / eggCases[index].hatchDuration
        }

        hatchReadyEggCases(in: size)

        matureVisibleNymphs(delta: delta)

        if breedingPoints >= Self.breedingThreshold && canLayEggCase {
            layEggCase(in: size)
            breedingPoints = max(0, breedingPoints - Self.breedingThreshold)
        }

        reconcileCountsWithVisibleRoaches()
    }

    mutating func removeLegacyDirectGachaRoaches() {
        roaches.removeAll { $0.variant != .normal }
        reconcileCountsWithVisibleRoaches()
    }

    mutating func advanceOffline(delta: Double) {
        guard delta > 1 else { return }

        let simulationSize = CGSize(width: 360, height: 440)
        var remaining = min(delta, 180 * 24 * 60 * 60)
        while remaining > 0 {
            let step = min(60 * 60, remaining)
            advanceOfflineStep(in: simulationSize, delta: step)
            remaining -= step
        }
    }

    @discardableResult
    mutating func placeFood(in size: CGSize) -> Bool {
        guard size.width > 20, size.height > 20 else { return false }
        guard consumeCareUse(.food) else { return false }
        let position = CGPoint(
            x: CGFloat.random(in: 42...(size.width - 42)),
            y: CGFloat.random(in: 52...(size.height - 52))
        )
        foods.append(Food(position: position, amount: 100))
        return true
    }

    @discardableResult
    mutating func placeFood(at position: CGPoint, in size: CGSize) -> Bool {
        guard size.width > 20, size.height > 20 else { return false }
        guard consumeCareUse(.food) else { return false }
        foods.append(Food(position: position, amount: 100))
        return true
    }

    @discardableResult
    mutating func addWater() -> Bool {
        guard consumeCareUse(.water) else { return false }
        water = min(100, water + 12)
        breedingPoints += 2.5
        return true
    }

    @discardableResult
    mutating func addWater(at position: CGPoint, in size: CGSize) -> Bool {
        guard size.width > 20, size.height > 20 else { return false }
        guard consumeCareUse(.water) else { return false }
        waterSpots.append(WaterSpot(position: position.clamped(to: size, inset: 34), amount: 100))
        water = min(100, water + 12)
        breedingPoints += 2.5
        return true
    }

    @discardableResult
    mutating func scatterRoaches() -> Bool {
        guard consumeCareUse(.light) else { return false }
        performScatterRoaches(from: nil)
        return true
    }

    @discardableResult
    mutating func scatterRoaches(from lightPosition: CGPoint?) -> Bool {
        guard consumeCareUse(.light) else { return false }
        performScatterRoaches(from: lightPosition)
        return true
    }

    private mutating func performScatterRoaches(from lightPosition: CGPoint?) {
        for index in roaches.indices {
            let direction: CGVector
            if let lightPosition {
                direction = unitVector(from: lightPosition, to: roaches[index].position)
            } else {
                let angle = CGFloat.random(in: 0...(2 * .pi))
                direction = CGVector(dx: cos(angle), dy: sin(angle))
            }
            let speed = CGFloat.random(in: roaches[index].stage == .adult ? 76...118 : 52...86) * speedFactor(for: roaches[index])
            roaches[index].activity = .fleeing
            roaches[index].velocity = direction.scaled(by: speed)
            roaches[index].decisionTimer = Double.random(in: 0.75...1.35)
        }
        safety = max(0, safety - 2.5)
    }

    func remainingCareUses(for tool: CareTool) -> Int {
        var usage = careUsage ?? .current()
        usage.resetIfNeeded()
        return usage.remainingUses(for: tool)
    }

    mutating func grantBonusCareUse(for tool: CareTool) {
        ensureDailyCareUsage()
        careUsage?.grantBonusUse(for: tool)
    }

    func canGrantBonusCareUse(for tool: CareTool) -> Bool {
        var usage = careUsage ?? .current()
        usage.resetIfNeeded()
        return usage.canGrantBonusUse(for: tool)
    }

    mutating func applyGachaReward(_ reward: GachaReward, in size: CGSize) {
        switch reward.category {
        case .rareRoach:
            guard let variant = reward.roachVariant,
                  roaches.count + eggCases.count < Self.maxRoachCount else { return }
            eggCases.append(
                EggCase(
                    position: gachaEggPosition(in: size),
                    progress: 0,
                    hatchDuration: Self.eggHatchDuration,
                    variant: variant
                )
            )
        case .roomSkin:
            break
        case .hideout:
            break
        }
        reconcileCountsWithVisibleRoaches()
    }

    mutating func placeHideout(kind: HideoutKind, at position: CGPoint, in size: CGSize) -> Bool {
        guard size.width > 20, size.height > 20 else { return false }
        let hideoutSize = Self.hideoutSize(for: kind)
        let inset = max(26, min(hideoutSize.width, hideoutSize.height) * 0.45)
        let finalPosition = position.clamped(to: size, inset: inset)
        guard canPlaceHideout(at: finalPosition, size: hideoutSize, excluding: nil) else {
            return false
        }
        hides.append(Hideout(position: finalPosition, size: hideoutSize, kind: kind))
        return true
    }

    mutating func moveHideout(id: UUID, to position: CGPoint, in size: CGSize) -> Bool {
        guard let index = hides.firstIndex(where: { $0.id == id }), size.width > 20, size.height > 20 else {
            return false
        }
        let hideoutSize = hides[index].size
        let inset = max(26, min(hideoutSize.width, hideoutSize.height) * 0.45)
        let finalPosition = position.clamped(to: size, inset: inset)
        guard canPlaceHideout(at: finalPosition, size: hideoutSize, excluding: id) else {
            return false
        }
        hides[index].position = finalPosition
        return true
    }

    mutating func deleteHideout(id: UUID) -> Bool {
        guard let index = hides.firstIndex(where: { $0.id == id }) else { return false }
        hides.remove(at: index)
        return true
    }

    @discardableResult
    mutating func nameRoach(id: UUID, name: String) -> Bool {
        let trimmedName = String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(8))
        guard !trimmedName.isEmpty, roaches.contains(where: { $0.id == id }) else { return false }
        if let namedRoach, namedRoach.id != id {
            return false
        }
        for index in roaches.indices {
            roaches[index].name = roaches[index].id == id ? trimmedName : nil
        }
        return true
    }

    @discardableResult
    mutating func clearNamedRoach() -> Bool {
        false
    }

    mutating func clampEverything(in size: CGSize) {
        guard size.width > 20, size.height > 20 else { return }
        for index in roaches.indices {
            roaches[index].position = roaches[index].position.clamped(to: size, inset: 24)
        }
        for index in foods.indices {
            foods[index].position = foods[index].position.clamped(to: size, inset: 24)
        }
        for index in waterSpots.indices {
            waterSpots[index].position = waterSpots[index].position.clamped(to: size, inset: 24)
        }
        for index in eggCases.indices {
            eggCases[index].position = eggCases[index].position.clamped(to: size, inset: 24)
        }
    }

    private mutating func updateRoach(at index: Int, in size: CGSize, delta: Double, foodAvailableAtTick: Bool) {
        var roach = roaches[index]
        let foodBefore = roach.foodEaten
        roach.decisionTimer -= delta

        let targetFoodIndex = nearestFoodIndex(to: roach.position)
        let targetWaterIndex = nearestWaterIndex(to: roach.position)

        if let waterIndex = targetWaterIndex, waterSpots[waterIndex].amount > 0, water < 95 {
            let waterPosition = waterSpots[waterIndex].position
            let distance = roach.position.distance(to: waterPosition)

            if distance < 24 {
                roach.activity = .eating
                roach.velocity = .zero
                let drinkAmount = (roach.stage == .adult ? 5.0 : 2.8) * delta
                waterSpots[waterIndex].amount -= drinkAmount
                roach.waterDrunk += drinkAmount
                Self.growLength(for: &roach, foodAmount: 0, waterAmount: drinkAmount)
                water = min(100, water + 0.55 * delta)
                breedingPoints += 0.035 * delta
            } else if roach.decisionTimer <= 0 || roach.activity == .idle {
                roach.activity = .walking
                roach.velocity = unitVector(from: roach.position, to: waterPosition)
                    .scaled(by: CGFloat.random(in: roach.stage == .adult ? 30...52 : 22...38) * speedFactor(for: roach))
                roach.decisionTimer = Double.random(in: 0.7...1.5)
            }
        } else if let foodIndex = targetFoodIndex, foods[foodIndex].amount > 0 {
            let foodPosition = foods[foodIndex].position
            let distance = roach.position.distance(to: foodPosition)

            if distance < 22 {
                roach.activity = .eating
                roach.velocity = .zero
                let eatAmount = (roach.stage == .adult ? 4.4 : 2.6) * delta
                foods[foodIndex].amount -= eatAmount
                roach.foodEaten += eatAmount
                Self.growLength(for: &roach, foodAmount: eatAmount, waterAmount: 0)
                breedingPoints += (roach.stage == .adult ? 0.20 : 0.07) * delta
                water = max(0, water - 0.08 * delta)
            } else if roach.decisionTimer <= 0 || roach.activity == .idle {
                roach.activity = .walking
                roach.velocity = unitVector(from: roach.position, to: foodPosition)
                    .scaled(by: CGFloat.random(in: roach.stage == .adult ? 34...58 : 24...42) * speedFactor(for: roach))
                roach.decisionTimer = Double.random(in: 0.8...1.8)
            }
        } else if roach.decisionTimer <= 0 {
            chooseWanderMotion(for: &roach)
        }

        if roach.activity == .walking || roach.activity == .fleeing {
            roach.position = roach.position + roach.velocity.scaled(by: CGFloat(delta))
            roach.angle = roach.velocity.angle
        }

        if Bool.random(probability: 0.048 * delta) {
            roach.activity = .resting
            roach.velocity = .zero
            roach.decisionTimer = Double.random(in: 0.7...2.2)
        }

        roach.position = roach.position.clamped(to: size, inset: 24)
        if roach.position.x <= 25 || roach.position.x >= size.width - 25 {
            roach.velocity.dx *= -1
        }
        if roach.position.y <= 25 || roach.position.y >= size.height - 25 {
            roach.velocity.dy *= -1
        }

        updateCondition(
            for: &roach,
            foodAvailable: foodAvailableAtTick,
            ateFood: roach.foodEaten > foodBefore,
            delta: delta
        )
        roaches[index] = roach
        updateMaxRecordedLength()
    }

    private mutating func chooseWanderMotion(for roach: inout Roach) {
        if Bool.random(probability: 0.42) {
            roach.activity = .idle
            roach.velocity = .zero
            roach.decisionTimer = Double.random(in: 0.8...2.6)
            return
        }

        if Bool.random(probability: 0.18), let hide = hides.randomElement() {
            roach.activity = .walking
            roach.velocity = unitVector(from: roach.position, to: hide.position)
                .scaled(by: CGFloat.random(in: 24...46) * speedFactor(for: roach))
            roach.decisionTimer = Double.random(in: 1.0...2.2)
            return
        }

        let angle = CGFloat.random(in: 0...(2 * .pi))
        let speed = CGFloat.random(in: roach.stage == .adult ? 16...62 : 12...42) * speedFactor(for: roach)
        roach.activity = Bool.random(probability: 0.045) ? .fleeing : .walking
        roach.velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
        roach.decisionTimer = Double.random(in: 0.7...2.0)
    }

    private func speedFactor(for roach: Roach) -> CGFloat {
        CGFloat(roach.variant.clampedSpeedMultiplier(roach.speedMultiplier))
    }

    private func nearestFoodIndex(to position: CGPoint) -> Int? {
        foods.indices
            .filter { foods[$0].amount > 0 }
            .min { foods[$0].position.distance(to: position) < foods[$1].position.distance(to: position) }
    }

    private func nearestWaterIndex(to position: CGPoint) -> Int? {
        waterSpots.indices
            .filter { waterSpots[$0].amount > 0 }
            .min { waterSpots[$0].position.distance(to: position) < waterSpots[$1].position.distance(to: position) }
    }

    private mutating func ensureDailyCareUsage() {
        if careUsage == nil {
            careUsage = .current()
        }
        careUsage?.resetIfNeeded()
    }

    private mutating func consumeCareUse(_ tool: CareTool) -> Bool {
        ensureDailyCareUsage()
        return careUsage?.consume(tool) ?? false
    }

    mutating func reconcileCountsWithVisibleRoaches() {
        ensureDailyCareUsage()
        for index in roaches.indices where roaches[index].stage == .nymph {
            roaches[index].matureDuration = max(roaches[index].matureDuration, Self.fastestMatureDuration)
        }
        for index in roaches.indices {
            roaches[index].lengthCm = Self.roundedLength(roaches[index].lengthCm)
            roaches[index].lengthCm = min(Self.maxLengthCm, max(Self.minLengthCm, roaches[index].lengthCm))
            roaches[index].speedMultiplier = roaches[index].variant.clampedSpeedMultiplier(roaches[index].speedMultiplier)
            roaches[index].size = Roach.renderSize(for: roaches[index].lengthCm)
        }
        for index in eggCases.indices {
            eggCases[index].hatchDuration = Self.eggHatchDuration
        }
        ensureSingleNamedRoach()
        removeDeadRoaches()
        updateMaxRecordedLength()
        adultCount = roaches.filter { $0.stage == .adult }.count
        nymphCount = roaches.filter { $0.stage == .nymph }.count
    }

    private mutating func matureVisibleNymphs(delta: Double) {
        let growthMultiplier = nymphGrowthMultiplier
        for index in roaches.indices where roaches[index].stage == .nymph {
            roaches[index].matureDuration = Self.fastestMatureDuration
            roaches[index].age += delta * growthMultiplier
            if roaches[index].age > roaches[index].matureDuration {
                roaches[index].stage = .adult
                roaches[index].size = Roach.renderSize(for: roaches[index].lengthCm)
            }
        }
        reconcileCountsWithVisibleRoaches()
    }

    private var nymphGrowthMultiplier: Double {
        let waterScore = min(1, max(0, water / 100))
        let foodScore = min(1, foods.reduce(0.0) { $0 + $1.amount } / 240)
        return max(0.25, (waterScore * 0.45) + (foodScore * 0.55))
    }

    private mutating func advanceOfflineStep(in size: CGSize, delta: Double) {
        reconcileCountsWithVisibleRoaches()

        nymphGrowthTimer += delta
        let environmentMultiplier = max(0.35, (water / 100) * (safety / 100))
        breedingPoints += breedingPointGainPerSecond * environmentMultiplier * delta
        water = max(0, water - 0.025 * delta)

        for index in waterSpots.indices {
            waterSpots[index].amount -= 0.40 * delta
        }
        waterSpots.removeAll { $0.amount <= 2 }

        let ateOfflineFood = distributeOfflineFood(delta: delta)
        if !ateOfflineFood {
            ageUnfedRoachesOffline(delta: delta)
        }

        for index in eggCases.indices {
            eggCases[index].hatchDuration = Self.eggHatchDuration
            eggCases[index].progress += delta / eggCases[index].hatchDuration
        }

        hatchReadyEggCases(in: size)

        matureVisibleNymphs(delta: delta)

        while breedingPoints >= Self.breedingThreshold && canLayEggCase {
            layEggCase(in: size)
            breedingPoints -= Self.breedingThreshold
        }

        reconcileCountsWithVisibleRoaches()
    }

    private mutating func distributeOfflineFood(delta: Double) -> Bool {
        guard !foods.isEmpty, !roaches.isEmpty else { return false }

        var remainingConsumption = min(
            foods.reduce(0.0) { $0 + $1.amount },
            Double(roaches.count) * 10.0 * delta / (24 * 60 * 60)
        )
        let plannedConsumption = remainingConsumption

        for foodIndex in foods.indices {
            guard remainingConsumption > 0 else { break }
            let consumed = min(foods[foodIndex].amount, remainingConsumption)
            foods[foodIndex].amount -= consumed
            remainingConsumption -= consumed

            let perRoach = consumed / Double(roaches.count)
            for roachIndex in roaches.indices {
                roaches[roachIndex].foodEaten += perRoach
                Self.growLength(for: &roaches[roachIndex], foodAmount: perRoach, waterAmount: 0)
                roaches[roachIndex].unfedWhileFoodAvailable = 0
                roaches[roachIndex].criticalWithoutFoodTimer = 0
                roaches[roachIndex].condition = .healthy
            }
        }
        foods.removeAll { $0.amount <= 0 }
        return plannedConsumption > 0
    }

    private static func growLength(for roach: inout Roach, foodAmount: Double, waterAmount: Double) {
        guard roach.lengthCm < Self.maxLengthCm else {
            roach.size = Roach.renderSize(for: Self.maxLengthCm)
            return
        }

        roach.lengthGrowthPoints += foodAmount * 0.15 + waterAmount * 0.08
        while roach.lengthGrowthPoints >= Self.lengthGrowthPointsPerStep && roach.lengthCm < Self.maxLengthCm {
            roach.lengthGrowthPoints -= Self.lengthGrowthPointsPerStep
            roach.lengthCm = min(Self.maxLengthCm, roundedLength(roach.lengthCm + Self.lengthStepCm))
        }
        roach.size = Roach.renderSize(for: roach.lengthCm)
    }

    private static func roundedLength(_ value: Double) -> Double {
        (value * 10).rounded() / 10
    }

    private func updateCondition(for roach: inout Roach, foodAvailable: Bool, ateFood: Bool, delta: Double) {
        if ateFood {
            roach.unfedWhileFoodAvailable = 0
            roach.criticalWithoutFoodTimer = 0
            roach.condition = .healthy
            return
        }

        if foodAvailable {
            roach.unfedWhileFoodAvailable += delta
            if roach.unfedWhileFoodAvailable >= Self.criticalFoodMissDuration {
                roach.condition = .critical
            }
        }

        if roach.condition == .critical {
            roach.criticalWithoutFoodTimer += delta
            if roach.criticalWithoutFoodTimer >= Self.deathAfterCriticalDuration {
                roach.condition = .dead
            }
        }
    }

    private mutating func ageUnfedRoachesOffline(delta: Double) {
        let foodAvailable = foods.contains { $0.amount > 0 }
        guard foodAvailable else { return }

        for index in roaches.indices {
            updateCondition(for: &roaches[index], foodAvailable: true, ateFood: false, delta: delta)
        }
        removeDeadRoaches()
    }

    private mutating func removeDeadRoaches() {
        roaches.removeAll { $0.condition == .dead }
        ensureSingleNamedRoach()
    }

    private mutating func ensureSingleNamedRoach() {
        var didKeepName = false
        for index in roaches.indices {
            guard roaches[index].name?.isEmpty == false else {
                roaches[index].name = nil
                continue
            }

            if didKeepName {
                roaches[index].name = nil
            } else {
                didKeepName = true
                roaches[index].name = String(roaches[index].name?.prefix(8) ?? "")
            }
        }
    }

    private mutating func updateMaxRecordedLength() {
        guard let biggest = roaches.max(by: { $0.lengthCm < $1.lengthCm }) else { return }
        if biggest.lengthCm > (maxRecordedLengthCm ?? 0) {
            maxRecordedLengthCm = biggest.lengthCm
            maxRecordedRoachSex = biggest.sex
        }
    }

    private var breedingPointGainPerSecond: Double {
        guard adultMaleCount > 0, adultFemaleCount > 0, roaches.count < Self.maxRoachCount else {
            return 0
        }

        let adultTotal = max(1, adultCount)
        let femaleRatio = Double(adultFemaleCount) / Double(adultTotal)
        let femaleRatioBoost = 0.75 + femaleRatio
        let maleCoverage = min(1.0, Double(adultMaleCount) / max(1.0, Double(adultFemaleCount) * 0.5))
        return Self.breedingThreshold
            * Double(adultFemaleCount)
            * femaleRatioBoost
            * maleCoverage
            / Self.eggCaseFillDurationAtBest
    }

    private var canLayEggCase: Bool {
        adultMaleCount > 0
            && adultFemaleCount > 0
            && roaches.count + eggCases.count < Self.maxRoachCount
    }

    private mutating func layEggCase(in size: CGSize) {
        guard canLayEggCase else { return }
        let anchor = hides.randomElement()?.position ?? CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        let offset = CGVector(
            dx: CGFloat.random(in: -56...56),
            dy: CGFloat.random(in: -42...42)
        )
        eggCases.append(EggCase(position: (anchor + offset).clamped(to: size, inset: 28)))
    }

    private mutating func hatchReadyEggCases(in size: CGSize) {
        let readyEggs = eggCases.filter { $0.progress >= 1 }
        guard !readyEggs.isEmpty else { return }
        eggCases.removeAll { $0.progress >= 1 }

        for egg in readyEggs where roaches.count < Self.maxRoachCount {
            if let variant = egg.variant {
                addRoaches(stage: .nymph, count: 1, variant: variant, in: size)
            } else {
                addRoaches(stage: .nymph, count: Int.random(in: 1...2), in: size)
            }
        }
    }

    private func gachaEggPosition(in size: CGSize) -> CGPoint {
        let safeSize = CGSize(width: max(size.width, 120), height: max(size.height, 160))
        for _ in 0..<24 {
            let anchor = hides.randomElement()?.position ?? CGPoint(
                x: CGFloat.random(in: 34...(safeSize.width - 34)),
                y: CGFloat.random(in: 44...(safeSize.height - 44))
            )
            let candidate = CGPoint(
                x: anchor.x + CGFloat.random(in: -64...64),
                y: anchor.y + CGFloat.random(in: -48...48)
            ).clamped(to: safeSize, inset: 30)
            if eggCases.allSatisfy({ $0.position.distance(to: candidate) >= 34 }) {
                return candidate
            }
        }
        return CGPoint(x: safeSize.width * 0.5, y: safeSize.height * 0.5)
    }

    static func hideoutSize(for kind: HideoutKind) -> CGSize {
        switch kind {
        case .paper:
            return CGSize(width: 120, height: 58)
        case .receipt:
            return CGSize(width: 138, height: 48)
        case .woodChip:
            return CGSize(width: 132, height: 40)
        case .cloth:
            return CGSize(width: 126, height: 70)
        case .cable:
            return CGSize(width: 296, height: 68)
        case .darkBox:
            return CGSize(width: 142, height: 86)
        case .foil:
            return CGSize(width: 118, height: 42)
        case .bottleCap:
            return CGSize(width: 68, height: 68)
        case .tape:
            return CGSize(width: 132, height: 34)
        case .matchbox:
            return CGSize(width: 148, height: 64)
        case .snackWrapper:
            return CGSize(width: 132, height: 74)
        case .roachTrap:
            return CGSize(width: 148, height: 64)
        case .plasticShard:
            return CGSize(width: 106, height: 58)
        case .dustPocket:
            return CGSize(width: 136, height: 54)
        case .drainPipe:
            return CGSize(width: 164, height: 52)
        }
    }

    private mutating func addGachaHideout(kind: HideoutKind, in size: CGSize) {
        let position = CGPoint(
            x: CGFloat.random(in: 44...(max(88, size.width - 44))),
            y: CGFloat.random(in: 58...(max(116, size.height - 58)))
        )
        _ = placeHideout(kind: kind, at: position, in: size)
    }

    private func canPlaceHideout(at position: CGPoint, size: CGSize, excluding excludedID: UUID?) -> Bool {
        let proposed = CGRect(center: position, size: size).insetBy(
            dx: size.width * 0.36,
            dy: size.height * 0.36
        )
        return hides.allSatisfy { hide in
            if hide.id == excludedID {
                return true
            }
            let existing = CGRect(center: hide.position, size: hide.size).insetBy(
                dx: hide.size.width * 0.36,
                dy: hide.size.height * 0.36
            )
            return !proposed.intersects(existing)
        }
    }

    private mutating func addRoaches(
        stage: RoachStage,
        count: Int,
        variant: RoachVariant = .normal,
        in size: CGSize
    ) {
        let addCount = min(count, max(0, Self.maxRoachCount - roaches.count))
        for _ in 0..<addCount {
            roaches.append(Roach.random(stage: stage, sex: .random(), variant: variant, in: size))
        }
        reconcileCountsWithVisibleRoaches()
    }
}
