import SwiftUI
import WidgetKit

@MainActor
enum WidgetGuideCoordinator {
    static func shouldPresentAutomatically() async -> Bool {
        guard !UserDefaults.standard.bool(forKey: RoachWidgetConstants.guideDismissedKey) else {
            return false
        }
        return !(await isWidgetInstalled())
    }

    static func markDismissed() {
        UserDefaults.standard.set(true, forKey: RoachWidgetConstants.guideDismissedKey)
    }

    static func isWidgetInstalled() async -> Bool {
        await withCheckedContinuation { continuation in
            WidgetCenter.shared.getCurrentConfigurations { result in
                let isInstalled = (try? result.get())?
                    .contains { $0.kind == RoachWidgetConstants.widgetKind } ?? false
                continuation.resume(returning: isInstalled)
            }
        }
    }
}

struct AppSettingsSheet: View {
    let isBGMPlaying: Bool
    let onOpenBGM: () -> Void
    let onOpenWidgetGuide: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.15, green: 0.09, blue: 0.055), Color(red: 0.38, green: 0.20, blue: 0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 14) {
                    settingsButton(
                        title: "ホーム画面ウィジェット",
                        detail: "繁殖・水分・安心をいつでも確認",
                        systemImage: "rectangle.3.group.fill",
                        tint: Color(red: 0.96, green: 0.55, blue: 0.16),
                        action: onOpenWidgetGuide
                    )
                    settingsButton(
                        title: "BGMプレイヤー",
                        detail: isBGMPlaying ? "再生中" : "巣の音楽を選ぶ",
                        systemImage: isBGMPlaying ? "waveform" : "music.note",
                        tint: Color(red: 0.52, green: 0.72, blue: 0.36),
                        action: onOpenBGM
                    )
                    Spacer()
                    Text("ウィジェットをタップすると、必要な世話を選んだ状態でアプリが開きます。")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.64))
                        .multilineTextAlignment(.center)
                }
                .padding(20)
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                        .fontWeight(.black)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func settingsButton(
        title: String,
        detail: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 23, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(tint, in: RoundedRectangle(cornerRadius: 17))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                    Text(detail)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .fontWeight(.black)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(Color(red: 0.16, green: 0.13, blue: 0.09))
            .padding(14)
            .background(Color(red: 0.97, green: 0.93, blue: 0.76), in: RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
    }
}

struct WidgetGuideSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    guidePreview
                    Text("ホーム画面でコロニーを見守る")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text("繁殖・水分・安心と、ゴキブリの気分をアプリを開かず確認できます。")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 12) {
                        guideStep(number: 1, text: "ホーム画面の何もない場所を長押し")
                        guideStep(number: 2, text: "「編集」から「ウィジェットを追加」を選ぶ")
                        guideStep(number: 3, text: "「ゴキブリ増殖計画」を検索する")
                        guideStep(number: 4, text: "小または中サイズを選んで追加")
                    }

                    Text("表示が更新されないときは、まずアプリを再起動し、次に端末を再起動、それでも直らない場合だけウィジェットを追加し直してください。")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(14)
                        .background(.black.opacity(0.06), in: RoundedRectangle(cornerRadius: 15))
                }
                .padding(20)
            }
            .background(Color(red: 0.96, green: 0.91, blue: 0.72))
            .navigationTitle("ウィジェット追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                        .fontWeight(.black)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private var guidePreview: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.98, green: 0.76, blue: 0.25), Color(red: 0.54, green: 0.72, blue: 0.33)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                VStack(spacing: 5) {
                    Image(systemName: "ant.fill")
                        .font(.system(size: 37, weight: .black))
                        .foregroundStyle(Color(red: 0.20, green: 0.10, blue: 0.05))
                    Text("12匹")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                    Text("繁殖 64%  水分 68%  安心 74%")
                        .font(.system(size: 7, weight: .black, design: .rounded))
                }
            }
            .frame(width: 138, height: 138)
            VStack(alignment: .leading, spacing: 8) {
                Label("毎日の状態", systemImage: "chart.bar.fill")
                Label("感情の変化", systemImage: "face.smiling.fill")
                Label("タップで世話", systemImage: "hand.tap.fill")
            }
            .font(.system(size: 12, weight: .black, design: .rounded))
        }
    }

    private func guideStep(number: Int, text: String) -> some View {
        HStack(spacing: 13) {
            Text("\(number)")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color(red: 0.69, green: 0.28, blue: 0.10), in: Circle())
            Text(text)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 17))
    }
}
