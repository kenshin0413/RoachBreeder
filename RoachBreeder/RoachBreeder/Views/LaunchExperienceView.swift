//
//  LaunchExperienceView.swift
//  RoachBreeder
//

import SwiftUI
import UIKit

struct LaunchExperienceView: View {
    let onComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasStarted = false
    @State private var titleVisible = false
    @State private var heroVisible = false
    @State private var swarmReleased = false
    @State private var planActivated = false
    @State private var displayCount = 1
    @State private var exitScale: CGFloat = 1
    @State private var exitOpacity = 1.0

    private let crawlers = SplashCrawlerSeed.all

    var body: some View {
        GeometryReader { proxy in
            let compactScale = min(1, max(0.80, proxy.size.height / 820))

            ZStack {
                splashBackground

                crawlerLayer(in: proxy.size)

                VStack(spacing: 0) {
                    Spacer(minLength: 46)

                    statusBadge
                        .opacity(titleVisible ? 1 : 0)
                        .offset(y: titleVisible ? 0 : -14)

                    Spacer().frame(height: 22)

                    heroRoach

                    Spacer().frame(height: 16)

                    titleLockup

                    Spacer().frame(height: 24)

                    colonyCounter

                    Spacer()

                    phaseHint
                        .padding(.bottom, max(proxy.safeAreaInsets.bottom, 18) + 12)
                }
                .padding(.horizontal, 24)
                .scaleEffect(compactScale)

                Color.white
                    .opacity(planActivated ? 0.11 : 0)
                    .allowsHitTesting(false)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .scaleEffect(exitScale)
        .opacity(exitOpacity)
        .task {
            guard !hasStarted else { return }
            hasStarted = true
            await runChoreography()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "ゴキブリ増殖計画、起動中"))
        .accessibilityAddTraits(.isStaticText)
    }

    private var splashBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.74, blue: 0.04),
                    Color(red: 1.0, green: 0.55, blue: 0.01),
                    Color(red: 0.48, green: 0.19, blue: 0.015)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(planActivated ? 0.38 : 0.14),
                    Color.clear
                ],
                center: .center,
                startRadius: 12,
                endRadius: 340
            )
            .scaleEffect(planActivated ? 1.45 : 0.74)
            .animation(.easeOut(duration: 0.55), value: planActivated)

            LinearGradient(
                colors: [.clear, .black.opacity(0.42)],
                startPoint: .center,
                endPoint: .bottom
            )
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(planActivated ? Color(red: 0.60, green: 0.96, blue: 0.24) : .red)
                .frame(width: 8, height: 8)
                .shadow(color: planActivated ? .green.opacity(0.8) : .red.opacity(0.8), radius: 6)
            Text(planActivated ? "PROJECT ACTIVE" : "CONFIDENTIAL PROJECT")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.4)
        }
        .foregroundStyle(.black.opacity(0.78))
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.white.opacity(0.72), in: Capsule())
        .overlay {
            Capsule().stroke(.black.opacity(0.16), lineWidth: 1)
        }
    }

    private var heroRoach: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(.white.opacity(0.30 - Double(index) * 0.07), lineWidth: index == 0 ? 3 : 1)
                    .frame(width: CGFloat(188 + index * 42), height: CGFloat(188 + index * 42))
                    .scaleEffect(heroVisible ? 1 : 0.34)
                    .opacity(heroVisible ? 1 : 0)
                    .animation(
                        .spring(response: 0.66, dampingFraction: 0.64)
                            .delay(Double(index) * 0.07),
                        value: heroVisible
                    )
            }

            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.96), Color(red: 1.0, green: 0.88, blue: 0.54)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 184, height: 184)
                .shadow(color: .black.opacity(0.28), radius: 20, y: 12)

            SplashRoachSprite(size: 154, speed: 8)
                .rotationEffect(.degrees(planActivated ? 8 : -4))
                .scaleEffect(heroVisible ? 1 : 0.12)
                .opacity(heroVisible ? 1 : 0)
                .animation(.spring(response: 0.62, dampingFraction: 0.58), value: heroVisible)
                .animation(.spring(response: 0.30, dampingFraction: 0.48), value: planActivated)
        }
        .frame(height: 270)
    }

    private var titleLockup: some View {
        VStack(spacing: 7) {
            Text(String(localized: "ゴキブリ"))
                .foregroundStyle(.black)
            HStack(spacing: 6) {
                Text(String(localized: "増殖"))
                    .foregroundStyle(Color(red: 0.92, green: 0.10, blue: 0.03))
                Text(String(localized: "計画"))
                    .foregroundStyle(.black)
            }
        }
        .font(.system(size: 46, weight: .black, design: .rounded))
        .minimumScaleFactor(0.76)
        .lineLimit(1)
        .padding(.horizontal, 21)
        .padding(.vertical, 12)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(.black.opacity(0.82), lineWidth: 3)
        }
        .shadow(color: .black.opacity(0.30), radius: 0, x: 7, y: 8)
        .rotationEffect(.degrees(titleVisible ? -1.6 : -8))
        .scaleEffect(titleVisible ? 1 : 0.72)
        .opacity(titleVisible ? 1 : 0)
        .animation(.spring(response: 0.52, dampingFraction: 0.62), value: titleVisible)
    }

    private var colonyCounter: some View {
        VStack(spacing: 6) {
            Text(planActivated ? String(localized: "目指せ！") : String(localized: "推定コロニー数"))
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(.white.opacity(0.72))

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(displayCount.formatted())
                    .contentTransition(.numericText(value: Double(displayCount)))
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                Text(String(localized: "匹"))
                    .font(.system(size: 17, weight: .black, design: .rounded))
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.42), radius: 8, y: 4)
        }
        .opacity(swarmReleased ? 1 : 0)
        .scaleEffect(swarmReleased ? 1 : 0.78)
        .animation(.spring(response: 0.36, dampingFraction: 0.70), value: swarmReleased)
    }

    private var phaseHint: some View {
        Text(String(localized: "増殖フェーズ開始"))
            .font(.system(size: 12, weight: .black, design: .rounded))
            .tracking(1.2)
            .foregroundStyle(.white.opacity(0.72))
            .opacity(titleVisible ? 1 : 0)
            .animation(.easeIn(duration: 0.25), value: titleVisible)
    }

    private func crawlerLayer(in size: CGSize) -> some View {
        ZStack {
            ForEach(crawlers) { crawler in
                SplashRoachSprite(size: crawler.size, speed: crawler.speed)
                    .rotationEffect(.degrees(crawler.rotation))
                    .position(
                        x: (swarmReleased ? crawler.end.x : crawler.start.x) * size.width,
                        y: (swarmReleased ? crawler.end.y : crawler.start.y) * size.height
                    )
                    .opacity(swarmReleased ? crawler.endOpacity : 0)
                    .animation(
                        .easeOut(duration: crawler.duration).delay(crawler.delay),
                        value: swarmReleased
                    )
            }
        }
        .allowsHitTesting(false)
    }

    @MainActor
    private func runChoreography() async {
        if reduceMotion {
            titleVisible = true
            heroVisible = true
            swarmReleased = true
            displayCount = 999
            planActivated = true
            try? await Task.sleep(for: .milliseconds(2_420))
            finish(duration: 0.28)
            return
        }

        try? await Task.sleep(for: .milliseconds(100))
        withAnimation(.easeOut(duration: 0.28)) { titleVisible = true }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        try? await Task.sleep(for: .milliseconds(250))
        heroVisible = true

        try? await Task.sleep(for: .milliseconds(350))
        swarmReleased = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        for count in [2, 4, 8, 16, 32, 64, 128, 256, 512, 999] {
            try? await Task.sleep(for: .milliseconds(65))
            withAnimation(.snappy(duration: 0.12)) { displayCount = count }
        }

        try? await Task.sleep(for: .milliseconds(300))
        withAnimation(.spring(response: 0.34, dampingFraction: 0.60)) {
            planActivated = true
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        try? await Task.sleep(for: .milliseconds(700))
        finish(duration: 0.35)
    }

    private func finish(duration: Double = 0.34) {
        guard exitOpacity > 0 else { return }
        withAnimation(.easeIn(duration: duration)) {
            exitScale = 1.10
            exitOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            onComplete()
        }
    }
}

private struct SplashRoachSprite: View {
    let size: CGFloat
    let speed: Double

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 12.0)) { timeline in
            let frame = (Int(timeline.date.timeIntervalSinceReferenceDate * speed) % 8) + 1
            Image(String(format: "RoachFrame%02d", frame))
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.36), radius: 5, y: 3)
        }
    }
}

private struct SplashCrawlerSeed: Identifiable {
    let id: Int
    let start: CGPoint
    let end: CGPoint
    let size: CGFloat
    let rotation: Double
    let speed: Double
    let delay: Double
    let duration: Double
    let endOpacity: Double

    static let all: [SplashCrawlerSeed] = [
        .init(id: 0, start: CGPoint(x: -0.12, y: 0.18), end: CGPoint(x: 0.09, y: 0.24), size: 66, rotation: 118, speed: 11, delay: 0.02, duration: 0.62, endOpacity: 0.78),
        .init(id: 1, start: CGPoint(x: 1.14, y: 0.23), end: CGPoint(x: 0.91, y: 0.30), size: 54, rotation: -112, speed: 13, delay: 0.12, duration: 0.58, endOpacity: 0.72),
        .init(id: 2, start: CGPoint(x: -0.10, y: 0.72), end: CGPoint(x: 0.10, y: 0.67), size: 49, rotation: 78, speed: 12, delay: 0.23, duration: 0.56, endOpacity: 0.64),
        .init(id: 3, start: CGPoint(x: 1.12, y: 0.76), end: CGPoint(x: 0.88, y: 0.72), size: 62, rotation: -76, speed: 10, delay: 0.07, duration: 0.70, endOpacity: 0.76),
        .init(id: 4, start: CGPoint(x: 0.22, y: 1.10), end: CGPoint(x: 0.26, y: 0.91), size: 43, rotation: -8, speed: 14, delay: 0.31, duration: 0.50, endOpacity: 0.58),
        .init(id: 5, start: CGPoint(x: 0.77, y: 1.12), end: CGPoint(x: 0.73, y: 0.89), size: 52, rotation: 14, speed: 11, delay: 0.18, duration: 0.64, endOpacity: 0.68),
        .init(id: 6, start: CGPoint(x: 0.45, y: -0.12), end: CGPoint(x: 0.38, y: 0.08), size: 38, rotation: 174, speed: 15, delay: 0.28, duration: 0.52, endOpacity: 0.50),
        .init(id: 7, start: CGPoint(x: 0.70, y: -0.10), end: CGPoint(x: 0.75, y: 0.12), size: 46, rotation: 188, speed: 12, delay: 0.38, duration: 0.62, endOpacity: 0.56),
        .init(id: 8, start: CGPoint(x: -0.14, y: 0.36), end: CGPoint(x: 0.13, y: 0.39), size: 40, rotation: 96, speed: 14, delay: 0.04, duration: 0.54, endOpacity: 0.62),
        .init(id: 9, start: CGPoint(x: 1.13, y: 0.42), end: CGPoint(x: 0.84, y: 0.43), size: 45, rotation: -92, speed: 15, delay: 0.17, duration: 0.48, endOpacity: 0.60),
        .init(id: 10, start: CGPoint(x: -0.13, y: 0.52), end: CGPoint(x: 0.16, y: 0.54), size: 58, rotation: 86, speed: 10, delay: 0.28, duration: 0.66, endOpacity: 0.74),
        .init(id: 11, start: CGPoint(x: 1.15, y: 0.57), end: CGPoint(x: 0.87, y: 0.56), size: 34, rotation: -88, speed: 16, delay: 0.05, duration: 0.45, endOpacity: 0.55),
        .init(id: 12, start: CGPoint(x: -0.12, y: 0.85), end: CGPoint(x: 0.14, y: 0.82), size: 52, rotation: 72, speed: 12, delay: 0.36, duration: 0.61, endOpacity: 0.66),
        .init(id: 13, start: CGPoint(x: 1.14, y: 0.88), end: CGPoint(x: 0.84, y: 0.83), size: 69, rotation: -70, speed: 9, delay: 0.24, duration: 0.72, endOpacity: 0.78),
        .init(id: 14, start: CGPoint(x: 0.10, y: -0.12), end: CGPoint(x: 0.18, y: 0.10), size: 33, rotation: 164, speed: 16, delay: 0.10, duration: 0.46, endOpacity: 0.52),
        .init(id: 15, start: CGPoint(x: 0.88, y: -0.14), end: CGPoint(x: 0.84, y: 0.16), size: 56, rotation: 198, speed: 11, delay: 0.21, duration: 0.68, endOpacity: 0.68),
        .init(id: 16, start: CGPoint(x: 0.05, y: 1.12), end: CGPoint(x: 0.12, y: 0.94), size: 36, rotation: -18, speed: 15, delay: 0.14, duration: 0.47, endOpacity: 0.54),
        .init(id: 17, start: CGPoint(x: 0.42, y: 1.14), end: CGPoint(x: 0.43, y: 0.93), size: 61, rotation: 4, speed: 10, delay: 0.33, duration: 0.65, endOpacity: 0.72),
        .init(id: 18, start: CGPoint(x: 0.60, y: 1.13), end: CGPoint(x: 0.58, y: 0.90), size: 31, rotation: 8, speed: 17, delay: 0.06, duration: 0.43, endOpacity: 0.50),
        .init(id: 19, start: CGPoint(x: 0.94, y: 1.15), end: CGPoint(x: 0.88, y: 0.96), size: 47, rotation: 22, speed: 13, delay: 0.27, duration: 0.56, endOpacity: 0.61),
        .init(id: 20, start: CGPoint(x: -0.15, y: 0.63), end: CGPoint(x: 0.23, y: 0.61), size: 29, rotation: 92, speed: 18, delay: 0.41, duration: 0.51, endOpacity: 0.48),
        .init(id: 21, start: CGPoint(x: 1.16, y: 0.66), end: CGPoint(x: 0.78, y: 0.64), size: 38, rotation: -94, speed: 15, delay: 0.31, duration: 0.55, endOpacity: 0.56),
        .init(id: 22, start: CGPoint(x: 0.28, y: -0.13), end: CGPoint(x: 0.30, y: 0.17), size: 27, rotation: 179, speed: 18, delay: 0.44, duration: 0.46, endOpacity: 0.46),
        .init(id: 23, start: CGPoint(x: 0.58, y: -0.14), end: CGPoint(x: 0.61, y: 0.09), size: 35, rotation: 184, speed: 16, delay: 0.02, duration: 0.52, endOpacity: 0.54)
    ]
}
