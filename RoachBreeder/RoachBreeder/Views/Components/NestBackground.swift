//
//  NestBackground.swift
//  RoachBreeder
//

import SwiftUI

struct NestBackground: View {
    var skin: RoomSkin = .deskGap

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                floorBase
                substrateNoise(in: proxy.size)
                eggCrateRidges(in: proxy.size)
                skinSpecificTexture(in: proxy.size)
                wallEdges(in: proxy.size)
                cornerGaps(in: proxy.size)
                dampBloom(in: proxy.size)
                stains(in: proxy.size)
                cardboardScraps(in: proxy.size)
                fibers(in: proxy.size)
                cracks(in: proxy.size)
                vignette
            }
        }
    }

    private var floorBase: some View {
        LinearGradient(
            colors: skin.floorColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func substrateNoise(in size: CGSize) -> some View {
        ZStack {
            ForEach(substrateSpecks) { speck in
                Capsule()
                    .fill(speck.color)
                    .frame(width: speck.size.width, height: speck.size.height)
                    .rotationEffect(.degrees(speck.rotation))
                    .position(x: speck.xRatio * size.width, y: speck.yRatio * size.height)
            }
        }
        .blendMode(.plusLighter)
        .opacity(0.72)
    }

    @ViewBuilder
    private func skinSpecificTexture(in size: CGSize) -> some View {
        switch skin {
        case .deskGap:
            deskGapTexture(in: size)
        case .fridgeBottom:
            fridgeBottomTexture(in: size)
        case .kitchenShelf:
            kitchenShelfTexture(in: size)
        case .tatamiEdge:
            tatamiEdgeTexture(in: size)
        case .cardboardNest:
            cardboardNestTexture(in: size)
        }
    }

    private func deskGapTexture(in size: CGSize) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.16, green: 0.10, blue: 0.06).opacity(0.45))
                .frame(height: 26)
                .position(x: size.width * 0.50, y: size.height * 0.10)
            Rectangle()
                .fill(Color(red: 0.11, green: 0.07, blue: 0.04).opacity(0.52))
                .frame(width: 22)
                .position(x: size.width * 0.07, y: size.height * 0.54)
        }
    }

    private func fridgeBottomTexture(in size: CGSize) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Rectangle()
                    .fill(index.isMultiple(of: 2) ? Color.white.opacity(0.045) : Color.black.opacity(0.16))
                    .frame(height: 18)
                    .position(x: size.width / 2, y: CGFloat(index) * size.height / 5 + 36)
            }
            Rectangle()
                .fill(Color(red: 0.45, green: 0.52, blue: 0.48).opacity(0.18))
                .frame(height: 34)
                .position(x: size.width / 2, y: 28)
            ForEach(0..<6, id: \.self) { index in
                Ellipse()
                    .fill(Color(red: 0.26, green: 0.48, blue: 0.45).opacity(0.12))
                    .frame(width: CGFloat(42 + index * 9), height: CGFloat(16 + index * 2))
                    .rotationEffect(.degrees(Double(index * 21)))
                    .position(x: CGFloat(index + 1) * size.width / 7, y: size.height * CGFloat(index % 3 + 2) / 6)
            }
        }
    }

    private func kitchenShelfTexture(in size: CGSize) -> some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Rectangle()
                    .fill(Color(red: 0.09, green: 0.055, blue: 0.03).opacity(0.34))
                    .frame(height: 4)
                    .position(x: size.width / 2, y: CGFloat(index + 1) * size.height / 5)
            }
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(Color(red: 0.82, green: 0.54, blue: 0.23).opacity(0.16))
                    .frame(width: CGFloat(4 + index % 4), height: CGFloat(4 + index % 4))
                    .position(
                        x: CGFloat((index * 37) % 100) / 100 * size.width,
                        y: CGFloat((index * 61 + 15) % 100) / 100 * size.height
                    )
            }
            Ellipse()
                .fill(Color(red: 0.36, green: 0.22, blue: 0.08).opacity(0.18))
                .frame(width: size.width * 0.42, height: 70)
                .rotationEffect(.degrees(-12))
                .position(x: size.width * 0.72, y: size.height * 0.58)
        }
    }

    private func tatamiEdgeTexture(in size: CGSize) -> some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Rectangle()
                    .fill(Color(red: 0.48, green: 0.44, blue: 0.22).opacity(0.14))
                    .frame(width: 1.4)
                    .position(x: CGFloat(index) * size.width / 11, y: size.height / 2)
            }
            ForEach(0..<8, id: \.self) { index in
                Rectangle()
                    .fill(Color.black.opacity(index.isMultiple(of: 2) ? 0.12 : 0.06))
                    .frame(height: 2)
                    .position(x: size.width / 2, y: CGFloat(index + 1) * size.height / 9)
            }
            Rectangle()
                .fill(Color(red: 0.10, green: 0.08, blue: 0.04).opacity(0.48))
                .frame(width: 34)
                .position(x: size.width * 0.18, y: size.height / 2)
        }
    }

    private func cardboardNestTexture(in size: CGSize) -> some View {
        ZStack {
            ForEach(0..<7, id: \.self) { index in
                Rectangle()
                    .fill(index.isMultiple(of: 2) ? Color.black.opacity(0.12) : Color.white.opacity(0.035))
                    .frame(height: 12)
                    .rotationEffect(.degrees(-5))
                    .position(x: size.width / 2, y: CGFloat(index + 1) * size.height / 8)
            }
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.45, green: 0.26, blue: 0.12).opacity(0.20))
                    .frame(width: CGFloat(110 + index * 18), height: CGFloat(44 + index * 3))
                    .rotationEffect(.degrees(Double(index * 11 - 24)))
                    .position(x: CGFloat(index + 1) * size.width / 6, y: CGFloat((index * 2 + 2) % 7) * size.height / 7)
            }
        }
    }

    private func eggCrateRidges(in size: CGSize) -> some View {
        ZStack {
            ForEach(0..<6, id: \.self) { row in
                ForEach(0..<5, id: \.self) { column in
                    let x = (CGFloat(column) + 0.5) * size.width / 5
                    let y = (CGFloat(row) + 0.45) * size.height / 6
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            RadialGradient(
                                colors: [
                                    .black.opacity(0.00),
                                    .black.opacity(0.16),
                                    .black.opacity(0.03)
                                ],
                                center: .center,
                                startRadius: 8,
                                endRadius: 58
                            )
                        )
                        .frame(width: size.width / 4.8, height: size.height / 7.3)
                        .rotationEffect(.degrees((row + column).isMultiple(of: 2) ? -7 : 6))
                        .position(x: x, y: y)
                }
            }

            Path { path in
                let step = max(42, size.width / 7)
                var x = step * 0.55
                while x < size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addCurve(
                        to: CGPoint(x: x + 18, y: size.height),
                        control1: CGPoint(x: x - 14, y: size.height * 0.32),
                        control2: CGPoint(x: x + 36, y: size.height * 0.62)
                    )
                    x += step
                }
            }
            .stroke(.black.opacity(0.16), style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
        }
    }

    private func wallEdges(in size: CGSize) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.12, green: 0.075, blue: 0.045))
                .frame(height: 42)
                .position(x: size.width / 2, y: 21)
                .shadow(color: .black.opacity(0.55), radius: 12, y: 10)

            Rectangle()
                .fill(Color(red: 0.105, green: 0.066, blue: 0.042))
                .frame(width: 34)
                .position(x: 17, y: size.height / 2)
                .shadow(color: .black.opacity(0.48), radius: 10, x: 9)

            Rectangle()
                .fill(Color(red: 0.095, green: 0.060, blue: 0.038))
                .frame(width: 24)
                .position(x: size.width - 12, y: size.height / 2)
                .shadow(color: .black.opacity(0.42), radius: 9, x: -8)

            Rectangle()
                .fill(.black.opacity(0.35))
                .frame(height: 7)
                .position(x: size.width / 2, y: 45)

            Rectangle()
                .fill(.black.opacity(0.30))
                .frame(width: 7)
                .position(x: 32, y: size.height / 2)
        }
    }

    private func dampBloom(in size: CGSize) -> some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            skin.dampColor.opacity(0.16),
                            Color.black.opacity(0.07),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 130
                    )
                )
                .frame(width: 210, height: 126)
                .rotationEffect(.degrees(-18))
                .position(x: size.width * 0.68, y: size.height * 0.28)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            skin.dampColor.opacity(0.30),
                            Color.black.opacity(0.16),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 145
                    )
                )
                .frame(width: 260, height: 160)
                .rotationEffect(.degrees(24))
                .position(x: size.width * 0.28, y: size.height * 0.66)
        }
        .blur(radius: 1.2)
    }

    private func cornerGaps(in size: CGSize) -> some View {
        ZStack {
            CornerGap()
                .frame(width: 118, height: 118)
                .position(x: 58, y: 58)

            CornerGap()
                .rotationEffect(.degrees(90))
                .frame(width: 108, height: 108)
                .position(x: size.width - 54, y: 54)

            CornerGap()
                .rotationEffect(.degrees(-90))
                .frame(width: 124, height: 124)
                .position(x: 62, y: size.height - 62)

            CornerGap()
                .rotationEffect(.degrees(180))
                .frame(width: 112, height: 112)
                .position(x: size.width - 56, y: size.height - 56)
        }
    }

    private func stains(in size: CGSize) -> some View {
        ZStack {
            ForEach(backgroundStains) { stain in
                Ellipse()
                    .fill(.black.opacity(stain.opacity))
                    .frame(width: stain.size.width, height: stain.size.height)
                    .rotationEffect(.degrees(stain.rotation))
                    .position(
                        x: stain.xRatio * size.width,
                        y: stain.yRatio * size.height
                    )
            }
        }
    }

    private func cardboardScraps(in size: CGSize) -> some View {
        ZStack {
            Scrap(width: 100, height: 24, rotation: 10)
                .position(x: size.width * 0.22, y: size.height * 0.20)
            Scrap(width: 134, height: 26, rotation: -7)
                .position(x: size.width * 0.78, y: size.height * 0.78)
            Scrap(width: 74, height: 18, rotation: -18)
                .position(x: size.width * 0.18, y: size.height * 0.68)
            Scrap(width: 86, height: 20, rotation: 28)
                .position(x: size.width * 0.61, y: size.height * 0.52)
            Scrap(width: 62, height: 15, rotation: -33)
                .position(x: size.width * 0.42, y: size.height * 0.82)
        }
    }

    private func fibers(in size: CGSize) -> some View {
        ZStack {
            ForEach(backgroundFibers) { fiber in
                Capsule()
                    .fill(Color(red: 0.66, green: 0.46, blue: 0.25).opacity(fiber.opacity))
                    .frame(width: fiber.length, height: 1.15)
                    .rotationEffect(.degrees(fiber.rotation))
                    .position(x: fiber.xRatio * size.width, y: fiber.yRatio * size.height)
                    .shadow(color: .black.opacity(0.18), radius: 1, y: 1)
            }
        }
    }

    private func cracks(in size: CGSize) -> some View {
        ZStack {
            Crack(points: [
                CGPoint(x: size.width * 0.50, y: size.height * 0.08),
                CGPoint(x: size.width * 0.53, y: size.height * 0.19),
                CGPoint(x: size.width * 0.49, y: size.height * 0.30),
                CGPoint(x: size.width * 0.52, y: size.height * 0.42)
            ])
            Crack(points: [
                CGPoint(x: size.width * 0.86, y: size.height * 0.35),
                CGPoint(x: size.width * 0.80, y: size.height * 0.42),
                CGPoint(x: size.width * 0.82, y: size.height * 0.50)
            ])
            Crack(points: [
                CGPoint(x: size.width * 0.13, y: size.height * 0.46),
                CGPoint(x: size.width * 0.18, y: size.height * 0.51),
                CGPoint(x: size.width * 0.15, y: size.height * 0.57)
            ])
        }
    }

    private var vignette: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [.clear, .black.opacity(0.52)],
                    center: .center,
                    startRadius: 90,
                    endRadius: 460
                )
            )
            .allowsHitTesting(false)
    }
}

private struct CornerGap: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(.black.opacity(0.52))
                .frame(width: 108, height: 16)
                .offset(x: 4, y: 4)
            Rectangle()
                .fill(.black.opacity(0.52))
                .frame(width: 16, height: 108)
                .offset(x: 4, y: 4)
            Circle()
                .fill(.black.opacity(0.45))
                .frame(width: 46, height: 46)
                .blur(radius: 8)
                .offset(x: 8, y: 8)
        }
    }
}

private struct Scrap: View {
    let width: CGFloat
    let height: CGFloat
    let rotation: Double

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.54, green: 0.35, blue: 0.18).opacity(0.78),
                        Color(red: 0.28, green: 0.17, blue: 0.09).opacity(0.86)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: width, height: height)
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(.black.opacity(0.20), lineWidth: 1)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 2)
                .padding(.horizontal, 7)
                .padding(.top, 4)
        }
        .rotationEffect(.degrees(rotation))
        .shadow(color: .black.opacity(0.18), radius: 4, y: 2)
    }
}

private struct Crack: View {
    let points: [CGPoint]

    var body: some View {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
        .stroke(.black.opacity(0.28), style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))
    }
}

private struct BackgroundStain: Identifiable {
    let id = UUID()
    let xRatio: CGFloat
    let yRatio: CGFloat
    let size: CGSize
    let rotation: Double
    let opacity: Double
}

private struct SubstrateSpeck: Identifiable {
    let id = UUID()
    let xRatio: CGFloat
    let yRatio: CGFloat
    let size: CGSize
    let rotation: Double
    let color: Color
}

private struct BackgroundFiber: Identifiable {
    let id = UUID()
    let xRatio: CGFloat
    let yRatio: CGFloat
    let length: CGFloat
    let rotation: Double
    let opacity: Double
}

private let backgroundStains: [BackgroundStain] = [
    BackgroundStain(xRatio: 0.12, yRatio: 0.18, size: CGSize(width: 80, height: 38), rotation: -18, opacity: 0.14),
    BackgroundStain(xRatio: 0.28, yRatio: 0.48, size: CGSize(width: 54, height: 28), rotation: 22, opacity: 0.10),
    BackgroundStain(xRatio: 0.48, yRatio: 0.22, size: CGSize(width: 92, height: 42), rotation: 4, opacity: 0.08),
    BackgroundStain(xRatio: 0.62, yRatio: 0.62, size: CGSize(width: 70, height: 34), rotation: -8, opacity: 0.13),
    BackgroundStain(xRatio: 0.82, yRatio: 0.28, size: CGSize(width: 86, height: 40), rotation: 14, opacity: 0.10),
    BackgroundStain(xRatio: 0.76, yRatio: 0.84, size: CGSize(width: 60, height: 28), rotation: 28, opacity: 0.13),
    BackgroundStain(xRatio: 0.18, yRatio: 0.84, size: CGSize(width: 70, height: 32), rotation: -32, opacity: 0.11)
]

private let substrateSpecks: [SubstrateSpeck] = [
    SubstrateSpeck(xRatio: 0.10, yRatio: 0.12, size: CGSize(width: 14, height: 3), rotation: 18, color: Color(red: 0.56, green: 0.38, blue: 0.20).opacity(0.24)),
    SubstrateSpeck(xRatio: 0.19, yRatio: 0.34, size: CGSize(width: 6, height: 3), rotation: -12, color: Color(red: 0.88, green: 0.60, blue: 0.30).opacity(0.22)),
    SubstrateSpeck(xRatio: 0.30, yRatio: 0.17, size: CGSize(width: 9, height: 4), rotation: 45, color: Color.black.opacity(0.24)),
    SubstrateSpeck(xRatio: 0.43, yRatio: 0.26, size: CGSize(width: 16, height: 3), rotation: -22, color: Color(red: 0.60, green: 0.42, blue: 0.24).opacity(0.22)),
    SubstrateSpeck(xRatio: 0.56, yRatio: 0.15, size: CGSize(width: 5, height: 5), rotation: 0, color: Color.black.opacity(0.20)),
    SubstrateSpeck(xRatio: 0.70, yRatio: 0.20, size: CGSize(width: 12, height: 3), rotation: 12, color: Color(red: 0.74, green: 0.50, blue: 0.26).opacity(0.20)),
    SubstrateSpeck(xRatio: 0.84, yRatio: 0.12, size: CGSize(width: 8, height: 3), rotation: -8, color: Color.white.opacity(0.08)),
    SubstrateSpeck(xRatio: 0.91, yRatio: 0.34, size: CGSize(width: 15, height: 4), rotation: 28, color: Color(red: 0.50, green: 0.31, blue: 0.15).opacity(0.25)),
    SubstrateSpeck(xRatio: 0.14, yRatio: 0.56, size: CGSize(width: 10, height: 3), rotation: 32, color: Color(red: 0.68, green: 0.43, blue: 0.19).opacity(0.19)),
    SubstrateSpeck(xRatio: 0.26, yRatio: 0.74, size: CGSize(width: 18, height: 4), rotation: -16, color: Color.black.opacity(0.20)),
    SubstrateSpeck(xRatio: 0.38, yRatio: 0.57, size: CGSize(width: 7, height: 3), rotation: 8, color: Color.white.opacity(0.07)),
    SubstrateSpeck(xRatio: 0.48, yRatio: 0.83, size: CGSize(width: 12, height: 3), rotation: 24, color: Color(red: 0.72, green: 0.48, blue: 0.22).opacity(0.18)),
    SubstrateSpeck(xRatio: 0.58, yRatio: 0.70, size: CGSize(width: 9, height: 4), rotation: -34, color: Color.black.opacity(0.21)),
    SubstrateSpeck(xRatio: 0.73, yRatio: 0.62, size: CGSize(width: 16, height: 3), rotation: 7, color: Color(red: 0.86, green: 0.56, blue: 0.26).opacity(0.18)),
    SubstrateSpeck(xRatio: 0.88, yRatio: 0.82, size: CGSize(width: 11, height: 3), rotation: -18, color: Color.white.opacity(0.07)),
    SubstrateSpeck(xRatio: 0.07, yRatio: 0.88, size: CGSize(width: 5, height: 5), rotation: 0, color: Color.black.opacity(0.25)),
    SubstrateSpeck(xRatio: 0.52, yRatio: 0.45, size: CGSize(width: 5, height: 5), rotation: 0, color: Color(red: 0.94, green: 0.66, blue: 0.32).opacity(0.14)),
    SubstrateSpeck(xRatio: 0.64, yRatio: 0.38, size: CGSize(width: 13, height: 3), rotation: -4, color: Color.black.opacity(0.18))
]

private let backgroundFibers: [BackgroundFiber] = [
    BackgroundFiber(xRatio: 0.13, yRatio: 0.26, length: 34, rotation: -24, opacity: 0.20),
    BackgroundFiber(xRatio: 0.33, yRatio: 0.39, length: 48, rotation: 8, opacity: 0.14),
    BackgroundFiber(xRatio: 0.53, yRatio: 0.22, length: 28, rotation: 32, opacity: 0.18),
    BackgroundFiber(xRatio: 0.80, yRatio: 0.30, length: 42, rotation: -12, opacity: 0.16),
    BackgroundFiber(xRatio: 0.20, yRatio: 0.82, length: 54, rotation: 20, opacity: 0.16),
    BackgroundFiber(xRatio: 0.47, yRatio: 0.67, length: 32, rotation: -42, opacity: 0.15),
    BackgroundFiber(xRatio: 0.69, yRatio: 0.86, length: 46, rotation: 15, opacity: 0.15),
    BackgroundFiber(xRatio: 0.90, yRatio: 0.66, length: 30, rotation: -34, opacity: 0.18)
]

private extension RoomSkin {
    var floorColors: [Color] {
        switch self {
        case .deskGap:
            return [
                Color(red: 0.225, green: 0.160, blue: 0.105),
                Color(red: 0.130, green: 0.092, blue: 0.066),
                Color(red: 0.092, green: 0.068, blue: 0.058)
            ]
        case .fridgeBottom:
            return [
                Color(red: 0.18, green: 0.20, blue: 0.18),
                Color(red: 0.075, green: 0.095, blue: 0.090),
                Color(red: 0.045, green: 0.055, blue: 0.055)
            ]
        case .kitchenShelf:
            return [
                Color(red: 0.26, green: 0.18, blue: 0.10),
                Color(red: 0.16, green: 0.11, blue: 0.06),
                Color(red: 0.09, green: 0.06, blue: 0.04)
            ]
        case .tatamiEdge:
            return [
                Color(red: 0.28, green: 0.25, blue: 0.14),
                Color(red: 0.17, green: 0.16, blue: 0.09),
                Color(red: 0.10, green: 0.09, blue: 0.055)
            ]
        case .cardboardNest:
            return [
                Color(red: 0.34, green: 0.21, blue: 0.11),
                Color(red: 0.20, green: 0.12, blue: 0.065),
                Color(red: 0.10, green: 0.065, blue: 0.04)
            ]
        }
    }

    var dampColor: Color {
        switch self {
        case .fridgeBottom:
            return Color(red: 0.14, green: 0.34, blue: 0.34)
        case .tatamiEdge:
            return Color(red: 0.36, green: 0.30, blue: 0.12)
        case .cardboardNest:
            return Color(red: 0.44, green: 0.23, blue: 0.08)
        default:
            return Color(red: 0.38, green: 0.24, blue: 0.12)
        }
    }
}
