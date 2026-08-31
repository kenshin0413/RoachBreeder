//
//  MoisturePatchView.swift
//  RoachBreeder
//

import SwiftUI

struct MoisturePatchView: View {
    let water: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(moisturePatches) { patch in
                    Ellipse()
                        .fill(Color.cyan.opacity(patch.opacity * min(1, water / 100)))
                        .frame(width: patch.size.width, height: patch.size.height)
                        .rotationEffect(.degrees(patch.rotation))
                        .position(
                            x: patch.xRatio * proxy.size.width,
                            y: patch.yRatio * proxy.size.height
                        )
                        .blur(radius: 1.2)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct WaterSpotView: View {
    let spot: WaterSpot

    var body: some View {
        let scale = max(0.14, min(0.82, spot.amount / 100))

        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.38, green: 0.92, blue: 0.96).opacity(0.28),
                            Color(red: 0.10, green: 0.45, blue: 0.52).opacity(0.22),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 70 * scale, height: 26 * scale)
                .blur(radius: 1.3)

            Ellipse()
                .fill(.white.opacity(0.12))
                .frame(width: 28 * scale, height: 5 * scale)
                .rotationEffect(.degrees(-10))
                .offset(x: -10 * scale, y: -5 * scale)
                .blur(radius: 0.8)
        }
        .rotationEffect(.degrees(-12))
        .allowsHitTesting(false)
        .animation(.easeOut(duration: 0.20), value: spot.amount)
    }
}

private struct MoisturePatch: Identifiable {
    let id = UUID()
    let xRatio: CGFloat
    let yRatio: CGFloat
    let size: CGSize
    let rotation: Double
    let opacity: Double
}

private let moisturePatches: [MoisturePatch] = [
    MoisturePatch(xRatio: 0.18, yRatio: 0.50, size: CGSize(width: 76, height: 30), rotation: -20, opacity: 0.14),
    MoisturePatch(xRatio: 0.68, yRatio: 0.26, size: CGSize(width: 62, height: 24), rotation: 16, opacity: 0.12),
    MoisturePatch(xRatio: 0.80, yRatio: 0.82, size: CGSize(width: 86, height: 34), rotation: -8, opacity: 0.15)
]
