//
//  ColonyControlsView.swift
//  RoachBreeder
//

import SwiftUI

struct ColonyControlsView: View {
    @Binding var selectedTool: CareTool?
    var isCompact: Bool = false
    var remainingUses: (CareTool) -> Int = { _ in 1 }
    var canWatchAdForBonusUse: (CareTool) -> Bool = { _ in false }
    var onWatchAdForBonusUse: (CareTool) -> Void = { _ in }

    @MainActor private var selectedSpec: ToolSpec? {
        selectedTool.map(ToolSpec.spec(for:))
    }

    private var selectedRemainingUses: Int {
        selectedTool.map(remainingUses) ?? 0
    }

    var body: some View {
        VStack(spacing: isCompact ? 4 : 9) {
            HStack(spacing: 8) {
                Image(systemName: selectedSpec?.cursorImage ?? "hand.tap.fill")
                    .font(.system(size: isCompact ? 10 : 11, weight: .black))
                    .foregroundStyle(selectedSpec.map { selectedRemainingUses > 0 ? $0.tint : disabledTint } ?? Color(red: 0.45, green: 0.54, blue: 0.34))
                    .frame(width: isCompact ? 19 : 22, height: isCompact ? 19 : 22)
                    .background((selectedSpec.map { selectedRemainingUses > 0 ? $0.tint : disabledTint } ?? Color(red: 0.45, green: 0.54, blue: 0.34)).opacity(0.15), in: Circle())

                Text(modeText)
                    .font(.system(size: isCompact ? 10 : 12, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.20, green: 0.20, blue: 0.15))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 8)

                if selectedTool != nil {
                    Button {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.78)) {
                            selectedTool = nil
                        }
                    } label: {
                        Text(String(localized: "選択解除"))
                            .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, isCompact ? 8 : 9)
                            .padding(.vertical, isCompact ? 4 : 5)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.92, green: 0.28, blue: 0.20),
                                        Color(red: 0.66, green: 0.12, blue: 0.10)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: Capsule()
                            )
                            .overlay {
                                Capsule()
                                    .stroke(.white.opacity(0.42), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(String(localized: "観察中"))
                        .font(.system(size: isCompact ? 8 : 9, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.45, green: 0.54, blue: 0.34))
                        .padding(.horizontal, isCompact ? 8 : 9)
                        .padding(.vertical, isCompact ? 4 : 5)
                        .background(.white.opacity(0.46), in: Capsule())
                }
            }
            .padding(.horizontal, 13)
            .padding(.top, isCompact ? 7 : 12)

            HStack(spacing: isCompact ? 7 : 9) {
                ToolBeltButton(
                    spec: .food,
                    selectedTool: $selectedTool,
                    isCompact: isCompact,
                    remainingUses: remainingUses(.food),
                    canWatchAdForBonusUse: canWatchAdForBonusUse(.food),
                    onWatchAdForBonusUse: onWatchAdForBonusUse
                )

                ToolBeltButton(
                    spec: .water,
                    selectedTool: $selectedTool,
                    isCompact: isCompact,
                    remainingUses: remainingUses(.water),
                    canWatchAdForBonusUse: canWatchAdForBonusUse(.water),
                    onWatchAdForBonusUse: onWatchAdForBonusUse
                )

                ToolBeltButton(
                    spec: .light,
                    selectedTool: $selectedTool,
                    isCompact: isCompact,
                    remainingUses: remainingUses(.light),
                    canWatchAdForBonusUse: canWatchAdForBonusUse(.light),
                    onWatchAdForBonusUse: onWatchAdForBonusUse
                )
            }
            .padding(.horizontal, isCompact ? 8 : 10)
            .padding(.top, isCompact ? 5 : 6)
            .padding(.bottom, isCompact ? 2 : 5)
        }
        .background {
            RoundedRectangle(cornerRadius: isCompact ? 24 : 28)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.97, green: 0.96, blue: 0.82).opacity(0.92),
                            Color(red: 0.80, green: 0.88, blue: 0.64).opacity(0.76),
                            Color(red: 0.42, green: 0.50, blue: 0.34).opacity(0.36)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.20), radius: 18, x: 0, y: 9)
        }
        .overlay {
            RoundedRectangle(cornerRadius: isCompact ? 24 : 28)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.82),
                            Color(red: 0.76, green: 0.84, blue: 0.51).opacity(0.50),
                            .black.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.4
                )
        }
    }

    private var disabledTint: Color {
        Color(red: 0.48, green: 0.50, blue: 0.46)
    }

    private var modeText: String {
        guard let selectedSpec, let selectedTool else {
            return String(localized: "ゴキブリをタップで個体ステータスを見る")
        }
        return selectedRemainingUses > 0 ? selectedSpec.modeText : String(localized: "\(ToolSpec.spec(for: selectedTool).title)は本日終了")
    }
}

private struct ToolBeltButton: View {
    let spec: ToolSpec
    @Binding var selectedTool: CareTool?
    let isCompact: Bool
    let remainingUses: Int
    let canWatchAdForBonusUse: Bool
    let onWatchAdForBonusUse: (CareTool) -> Void

    private var isSelected: Bool {
        selectedTool == spec.tool
    }

    private var isEnabled: Bool {
        remainingUses > 0
    }

    private var isAdAvailable: Bool {
        !isEnabled && canWatchAdForBonusUse
    }

    private var isInteractive: Bool {
        isEnabled || isAdAvailable
    }

    private var activeTint: Color {
        isInteractive ? spec.tint : Color(red: 0.48, green: 0.50, blue: 0.46)
    }

    var body: some View {
        Button {
            guard isEnabled else {
                if canWatchAdForBonusUse {
                    onWatchAdForBonusUse(spec.tool)
                }
                return
            }
            withAnimation(.spring(response: 0.28, dampingFraction: 0.70)) {
                selectedTool = isSelected ? nil : spec.tool
            }
        } label: {
            VStack(spacing: isCompact ? 5 : 6) {
                ZStack {
                    Circle()
                        .fill(activeTint.opacity(isSelected ? 0.20 : 0.10))
                        .frame(width: isCompact ? 40 : 54, height: isCompact ? 40 : 54)
                        .blur(radius: isSelected ? 0 : 2)
                        .offset(y: isSelected ? 0 : 2)

                    Image(systemName: spec.systemImage)
                        .font(.system(size: isCompact ? 20 : 26, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: isCompact ? 39 : 49, height: isCompact ? 39 : 49)
                        .background(
                            LinearGradient(
                                colors: [
                                    activeTint.lighter(by: isInteractive ? 0.13 : 0.06),
                                    activeTint
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: isCompact ? 14 : 16)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: isCompact ? 14 : 16)
                                .stroke(.white.opacity(0.48), lineWidth: 1)
                        }
                        .shadow(color: spec.tint.opacity(isSelected ? 0.38 : 0.20), radius: isSelected ? 11 : 6, y: isSelected ? 7 : 4)
                }

                Text(spec.title)
                    .font(.system(size: isCompact ? 18 : 24, weight: .black, design: .rounded))
                    .foregroundStyle(isInteractive ? Color(red: 0.14, green: 0.14, blue: 0.10) : Color(red: 0.34, green: 0.35, blue: 0.32))
                    .lineLimit(1)

                Text(statusText)
                    .font(.system(size: isCompact ? 14 : 17, weight: .black, design: .rounded))
                    .tracking(0.35)
                    .foregroundStyle(isAdAvailable ? spec.tint.lighter(by: 0.02) : activeTint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .padding(.horizontal, isCompact ? 5 : 7)
            .padding(.top, isCompact ? 6 : 9)
            .padding(.bottom, isCompact ? 5 : 8)
            .frame(maxWidth: .infinity)
            .frame(height: isCompact ? 86 : 116)
            .background {
                RoundedRectangle(cornerRadius: isCompact ? 18 : 21)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(isEnabled ? (isSelected ? 0.98 : 0.64) : (isAdAvailable ? 0.78 : 0.34)),
                                activeTint.opacity(isEnabled ? (isSelected ? 0.22 : 0.08) : (isAdAvailable ? 0.34 : 0.12)),
                                .black.opacity(isInteractive ? (isSelected ? 0.00 : 0.05) : 0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay(alignment: .topTrailing) {
                if isSelected || !isEnabled {
                    Image(systemName: isEnabled ? "location.fill" : (canWatchAdForBonusUse ? "play.rectangle.fill" : "lock.fill"))
                        .font(.system(size: isCompact ? 11 : 12, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: isCompact ? 26 : 28, height: isCompact ? 26 : 28)
                        .background(activeTint, in: Circle())
                        .overlay {
                            Circle().stroke(.white.opacity(0.78), lineWidth: 1.4)
                        }
                        .shadow(color: spec.tint.opacity(0.30), radius: 7, y: 4)
                        .offset(x: 5, y: -5)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: isCompact ? 18 : 21)
                    .stroke(
                        isSelected && isEnabled ? spec.tint.opacity(0.55) : .white.opacity(isInteractive ? 0.40 : 0.20),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
            .opacity(isInteractive ? 1 : 0.70)
            .saturation(isAdAvailable ? 1.18 : (isInteractive ? 1 : 0.18))
            .offset(y: isSelected && isEnabled ? -5 : 0)
            .scaleEffect(isSelected && isEnabled ? 1.03 : 1.0)
        }
        .buttonStyle(ToolBeltButtonStyle())
        .disabled(!isEnabled && !canWatchAdForBonusUse)
    }

    private var statusText: String {
        if isEnabled {
            return spec.effect
        }
        return canWatchAdForBonusUse ? String(localized: "広告で+1回") : String(localized: "今日は終了")
    }
}

private struct ToolBeltButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .brightness(configuration.isPressed ? -0.03 : 0)
            .animation(.spring(response: 0.18, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

private struct ToolSpec {
    let tool: CareTool
    let title: String
    let effect: String
    let modeText: String
    let systemImage: String
    let cursorImage: String
    let tint: Color

    static let food = ToolSpec(
        tool: .food,
        title: String(localized: "餌"),
        effect: String(localized: "腹を満たす"),
        modeText: String(localized: "ゴキブリのいるスペースにタップで餌をおく"),
        systemImage: "takeoutbag.and.cup.and.straw.fill",
        cursorImage: "fork.knife.circle.fill",
        tint: Color(red: 0.96, green: 0.49, blue: 0.14)
    )

    static let water = ToolSpec(
        tool: .water,
        title: String(localized: "水"),
        effect: String(localized: "水を補給"),
        modeText: String(localized: "ゴキブリのいるスペースにタップで水をおく"),
        systemImage: "drop.fill",
        cursorImage: "drop.circle.fill",
        tint: Color(red: 0.10, green: 0.61, blue: 0.80)
    )

    static let light = ToolSpec(
        tool: .light,
        title: String(localized: "光"),
        effect: String(localized: "一気に散らす"),
        modeText: String(localized: "ゴキブリのいるスペースにタップで光を当てる"),
        systemImage: "flashlight.on.fill",
        cursorImage: "scope",
        tint: Color(red: 0.78, green: 0.66, blue: 0.20)
    )

    static func spec(for tool: CareTool) -> ToolSpec {
        switch tool {
        case .food:
            return .food
        case .water:
            return .water
        case .light:
            return .light
        }
    }
}

private extension Color {
    func lighter(by amount: Double) -> Color {
        let clamped = min(max(amount, 0), 1)
        return mix(with: .white, amount: clamped)
    }

    func mix(with color: Color, amount: Double) -> Color {
        let clamped = min(max(amount, 0), 1)
        return Color(
            UIColor(self).resolvedColor(with: .init(userInterfaceStyle: .light))
                .mixed(with: UIColor(color).resolvedColor(with: .init(userInterfaceStyle: .light)), amount: clamped)
        )
    }
}

private extension UIColor {
    func mixed(with color: UIColor, amount: Double) -> UIColor {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0
        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0

        getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        let inverse = 1 - CGFloat(amount)
        let amount = CGFloat(amount)

        return UIColor(
            red: red1 * inverse + red2 * amount,
            green: green1 * inverse + green2 * amount,
            blue: blue1 * inverse + blue2 * amount,
            alpha: alpha1 * inverse + alpha2 * amount
        )
    }
}
