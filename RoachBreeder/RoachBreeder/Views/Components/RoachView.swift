//
//  RoachView.swift
//  RoachBreeder
//

import SwiftUI

private let roachAnimationFrames = [
    "RoachFrame01",
    "RoachFrame02",
    "RoachFrame03",
    "RoachFrame04",
    "RoachFrame05",
    "RoachFrame06",
    "RoachFrame07",
    "RoachFrame08"
]

struct RoachView: View {
    let roach: Roach

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 18.0)) { timeline in
            ZStack {
                Image(frameName(at: timeline.date))
                    .resizable()
                    .scaledToFit()
                    .frame(width: roach.size, height: roach.size)
                    .rotationEffect(.radians(roach.angle + .pi / 2))
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .saturation(saturation)
                    .brightness(brightness)
                    .hueRotation(hueRotation)
                    .overlay {
                        if roach.variant.roachAnimationAssetNames == nil, variantOverlay.opacity > 0 {
                            Image(frameName(at: timeline.date))
                                .resizable()
                                .scaledToFit()
                                .frame(width: roach.size, height: roach.size)
                                .rotationEffect(.radians(roach.angle + .pi / 2))
                                .foregroundStyle(variantOverlay.color.opacity(variantOverlay.opacity))
                                .blendMode(variantOverlay.blendMode)
                        }
                    }
                    .shadow(color: shadowColor, radius: 2.5, x: 0, y: 1.2)

                if let name = roach.name, !name.isEmpty {
                    NamedRoachTag(name: name, roachSize: roach.size)
                        .offset(y: -roach.size * 0.74)
                }
            }
            .animation(.linear(duration: 1.0 / 60.0), value: roach.position)
            .animation(.linear(duration: 1.0 / 60.0), value: roach.angle)
        }
    }

    private func frameName(at date: Date) -> String {
        let frames = roach.variant.roachAnimationAssetNames ?? roachAnimationFrames
        let phase = abs(roach.id.hashValue % frames.count)

        switch roach.activity {
        case .idle, .resting:
            return frames[0]
        case .eating:
            let index = Int(date.timeIntervalSinceReferenceDate * 4) + phase
            return frames[index % frames.count]
        case .walking:
            let index = Int(date.timeIntervalSinceReferenceDate * 10) + phase
            return frames[index % frames.count]
        case .fleeing:
            let index = Int(date.timeIntervalSinceReferenceDate * 16) + phase
            return frames[index % frames.count]
        }
    }

    private var scale: CGSize {
        if roach.condition == .critical {
            return CGSize(width: 0.88, height: 0.82)
        }

        switch roach.activity {
        case .idle, .resting:
            return CGSize(width: 1, height: 1)
        case .walking:
            return CGSize(width: 1.04, height: 0.97)
        case .eating:
            return CGSize(width: 0.96, height: 1.05)
        case .fleeing:
            return CGSize(width: 1.10, height: 0.92)
        }
    }

    private var opacity: Double {
        roach.condition == .critical ? 0.58 : (roach.stage == .adult ? 0.96 : 0.82)
    }

    private var saturation: Double {
        if roach.condition == .critical {
            return 0.35
        }
        if roach.variant.roachAnimationAssetNames != nil {
            return roach.stage == .adult ? 1 : 0.72
        }
        switch roach.variant {
        case .golden, .redCopper:
            return 1.25
        case .albino:
            return 0.20
        case .jetBlack:
            return 0.72
        default:
            return roach.stage == .adult ? 0.95 : 0.65
        }
    }

    private var brightness: Double {
        if roach.condition == .critical {
            return -0.18
        }
        if roach.variant.roachAnimationAssetNames != nil {
            return roach.stage == .nymph ? 0.06 : 0
        }
        switch roach.variant {
        case .golden:
            return 0.22
        case .albino:
            return 0.32
        case .jetBlack:
            return -0.18
        case .redCopper:
            return 0.08
        default:
            break
        }
        return roach.stage == .nymph ? 0.10 : 0
    }

    private var shadowColor: Color {
        if roach.condition == .critical {
            return .red.opacity(0.24)
        }
        switch roach.variant {
        case .golden:
            return Color(red: 1.0, green: 0.78, blue: 0.20).opacity(0.34)
        case .albino:
            return .white.opacity(0.30)
        default:
            return .black.opacity(0.24)
        }
    }

    private var hueRotation: Angle {
        guard roach.variant.roachAnimationAssetNames == nil else { return .zero }
        switch roach.variant {
        case .redCopper:
            return .degrees(10)
        case .golden:
            return .degrees(24)
        case .albino:
            return .degrees(-18)
        default:
            return .zero
        }
    }

    private var variantOverlay: (color: Color, opacity: Double, blendMode: BlendMode) {
        guard roach.variant.roachAnimationAssetNames == nil else { return (.clear, 0, .normal) }
        switch roach.variant {
        case .golden:
            return (Color(red: 1.0, green: 0.82, blue: 0.22), 0.28, .plusLighter)
        case .albino:
            return (.white, 0.32, .screen)
        case .jetBlack:
            return (.black, 0.22, .multiply)
        case .scarredBlack:
            return (Color(red: 0.92, green: 0.45, blue: 0.16), 0.12, .plusLighter)
        case .silverBack:
            return (Color(red: 0.30, green: 0.12, blue: 0.06), 0.16, .multiply)
        case .redCopper:
            return (Color(red: 0.94, green: 0.45, blue: 0.12), 0.14, .plusLighter)
        case .normal:
            return (.clear, 0, .normal)
        case .oilSlick:
            return (.clear, 0, .normal)
        }
    }
}

private struct NamedRoachTag: View {
    let name: String
    let roachSize: CGFloat

    var body: some View {
        VStack(spacing: 2) {
            Text(name)
                .font(.system(size: tagFontSize, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 1.0, green: 0.94, blue: 0.66))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.15, blue: 0.10).opacity(0.94),
                            Color(red: 0.36, green: 0.28, blue: 0.14).opacity(0.90)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Capsule()
                )
                .overlay {
                    Capsule()
                        .stroke(Color(red: 1.0, green: 0.88, blue: 0.42).opacity(0.62), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.45), radius: 5, y: 2)

            Capsule()
                .fill(Color(red: 1.0, green: 0.86, blue: 0.38).opacity(0.70))
                .frame(width: 2, height: max(4, roachSize * 0.10))
                .shadow(color: .black.opacity(0.32), radius: 2, y: 1)
        }
        .allowsHitTesting(false)
    }

    private var tagFontSize: CGFloat {
        min(11, max(8, roachSize * 0.22))
    }
}
