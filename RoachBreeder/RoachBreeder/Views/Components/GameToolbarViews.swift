//
//  GameToolbarViews.swift
//  RoachBreeder
//

import SwiftUI

struct GameUtilityBar: View {
    let isCompact: Bool
    let canDrawGacha: Bool
    let onGachaTap: () -> Void
    let onJournalTap: () -> Void
    let onGuideTap: () -> Void
    let onShareTap: () -> Void
    let onSettingsTap: () -> Void

    var body: some View {
        HStack(spacing: isCompact ? 6 : 8) {
            utilityButton(
                title: String(localized: "Gガチャ"),
                systemImage: canDrawGacha ? "sparkles" : "clock.fill",
                isFeatured: canDrawGacha,
                action: onGachaTap
            )
            utilityButton(title: String(localized: "日記"), systemImage: "note.text", action: onJournalTap)
            utilityButton(title: String(localized: "図鑑"), systemImage: "book.closed.fill", action: onGuideTap)
            utilityButton(title: String(localized: "共有"), systemImage: "square.and.arrow.up.fill", action: onShareTap)
            utilityButton(title: String(localized: "設定"), systemImage: "gearshape.fill", action: onSettingsTap)
        }
        .frame(maxWidth: .infinity)
        .frame(height: isCompact ? 36 : 40)
    }

    private func utilityButton(
        title: String,
        systemImage: String,
        isFeatured: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: isCompact ? 10 : 11, weight: .black))
                Text(title)
                    .font(.system(size: isCompact ? 11 : 12, weight: .black, design: .rounded))
            }
            .foregroundStyle(Color(red: 0.16, green: 0.15, blue: 0.11))
            .frame(maxWidth: .infinity)
            .frame(height: isCompact ? 34 : 38)
            .background(
                LinearGradient(
                    colors: isFeatured
                        ? [Color(red: 1.0, green: 0.82, blue: 0.25), Color(red: 0.77, green: 0.94, blue: 0.42)]
                        : [Color(red: 1.0, green: 0.95, blue: 0.72), Color(red: 0.78, green: 0.88, blue: 0.58)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: isCompact ? 18 : 21)
            )
            .overlay {
                RoundedRectangle(cornerRadius: isCompact ? 18 : 21)
                    .stroke(.white.opacity(0.66), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.13), radius: 7, y: 4)
        }
        .buttonStyle(UtilityBarButtonStyle())
    }
}

struct HideoutPlacementBar: View {
    let inventory: [HideoutKind: Int]
    @Binding var selectedKind: HideoutKind?
    @Binding var isEditing: Bool
    let onBeginEditing: () -> Void
    let onFinishEditing: () -> Void
    let isCompact: Bool

    private var entries: [(kind: HideoutKind, count: Int)] {
        HideoutKind.allCases.compactMap { kind in
            guard let count = inventory[kind], count > 0 else { return nil }
            return (kind, count)
        }
    }

    var body: some View {
        Group {
            if isEditing {
                HStack(spacing: 7) {
                    Label(String(localized: "配置編集"), systemImage: "square.and.pencil")
                        .font(.system(size: isCompact ? 10 : 11, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.16, green: 0.15, blue: 0.10))
                        .padding(.leading, 9)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            if entries.isEmpty {
                                Text(String(localized: "隠れ家をタップで移動"))
                                    .font(.system(size: isCompact ? 9 : 10, weight: .black, design: .rounded))
                                    .foregroundStyle(Color(red: 0.28, green: 0.27, blue: 0.21))
                            } else {
                                ForEach(entries, id: \.kind) { entry in
                                    placementChip(kind: entry.kind, count: entry.count)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }

                    Button(action: onFinishEditing) {
                        Text(String(localized: "完了"))
                            .font(.system(size: isCompact ? 10 : 11, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .frame(height: isCompact ? 32 : 36)
                            .background(Color(red: 0.20, green: 0.48, blue: 0.25), in: Capsule())
                    }
                    .buttonStyle(UtilityBarButtonStyle())
                    .padding(.trailing, 7)
                }
            } else {
                Button(action: onBeginEditing) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: isCompact ? 12 : 13, weight: .black))
                        Text(String(localized: "レイアウト編集"))
                            .font(.system(size: isCompact ? 11 : 12, weight: .black, design: .rounded))
                        Spacer()
                    }
                    .foregroundStyle(Color(red: 0.16, green: 0.15, blue: 0.10))
                    .padding(.leading, 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: isCompact ? 38 : 44)
                }
                .buttonStyle(UtilityBarButtonStyle())
            }
        }
        .frame(height: isCompact ? 44 : 50)
        .background(
            LinearGradient(
                colors: isEditing
                    ? [Color(red: 1.0, green: 0.91, blue: 0.46), Color(red: 0.73, green: 0.90, blue: 0.50)]
                    : [Color(red: 0.97, green: 0.94, blue: 0.72), Color(red: 0.82, green: 0.90, blue: 0.63)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: isCompact ? 18 : 21)
        )
        .overlay {
            RoundedRectangle(cornerRadius: isCompact ? 18 : 21)
                .stroke(Color.white.opacity(0.70), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.14), radius: 7, y: 4)
    }

    private func placementChip(kind: HideoutKind, count: Int) -> some View {
        let isSelected = selectedKind == kind
        return Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.78)) {
                selectedKind = isSelected ? nil : kind
            }
        } label: {
            HStack(spacing: 5) {
                Image(kind.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: isCompact ? 30 : 34, height: isCompact ? 24 : 28)
                    .shadow(color: .black.opacity(0.22), radius: 2, y: 1)
                Text("x\(count)")
                    .font(.system(size: isCompact ? 10 : 11, weight: .black, design: .rounded))
            }
            .foregroundStyle(Color(red: 0.15, green: 0.13, blue: 0.09))
            .padding(.horizontal, 8)
            .frame(height: isCompact ? 32 : 36)
            .background(
                isSelected ? Color(red: 1.0, green: 0.84, blue: 0.27) : Color.white.opacity(0.58),
                in: RoundedRectangle(cornerRadius: isCompact ? 14 : 16)
            )
            .overlay {
                RoundedRectangle(cornerRadius: isCompact ? 14 : 16)
                    .stroke(isSelected ? Color(red: 0.18, green: 0.15, blue: 0.08).opacity(0.28) : .white.opacity(0.42), lineWidth: 1)
            }
        }
        .buttonStyle(UtilityBarButtonStyle())
        .accessibilityLabel(String(localized: "\(kind.title) \(count)個"))
    }
}

struct UtilityBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(.spring(response: 0.18, dampingFraction: 0.74), value: configuration.isPressed)
    }
}
