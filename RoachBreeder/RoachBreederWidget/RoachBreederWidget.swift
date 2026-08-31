import SwiftUI
import WidgetKit

struct RoachWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: RoachWidgetSnapshot
}

struct RoachWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> RoachWidgetEntry {
        RoachWidgetEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (RoachWidgetEntry) -> Void) {
        completion(RoachWidgetEntry(date: Date(), snapshot: RoachWidgetSnapshotStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RoachWidgetEntry>) -> Void) {
        let now = Date()
        let snapshot = RoachWidgetSnapshotStore.load()
        let entry = RoachWidgetEntry(date: now, snapshot: snapshot)
        let refreshMinutes = snapshot.mood(at: now) == .urgent ? 15 : 30
        let refresh = Calendar.current.date(byAdding: .minute, value: refreshMinutes, to: now)
            ?? now.addingTimeInterval(Double(refreshMinutes * 60))
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct RoachBreederWidget: Widget {
    let kind = RoachWidgetConstants.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RoachWidgetProvider()) { entry in
            RoachWidgetRootView(entry: entry)
                .widgetURL(entry.snapshot.deepLinkURL())
                .containerBackground(for: .widget) {
                    RoachWidgetBackground(mood: entry.snapshot.mood(at: entry.date))
                }
        }
        .configurationDisplayName("すき間のコロニー")
        .description("繁殖・水分・安心と、コロニーの気分を確認できます。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct RoachBreederWidgetBundle: WidgetBundle {
    var body: some Widget {
        RoachBreederWidget()
    }
}

private struct RoachWidgetRootView: View {
    @Environment(\.widgetFamily) private var family
    let entry: RoachWidgetEntry

    var body: some View {
        switch family {
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(spacing: 6) {
            HStack(spacing: 7) {
                RoachMoodCharacter(mood: entry.snapshot.mood(at: entry.date))
                    .frame(width: 48, height: 50)
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(entry.snapshot.totalCount)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .monospacedDigit()
                    Text("匹のコロニー")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }

            Text(entry.snapshot.message(at: entry.date))
                .font(.system(size: 11, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                CompactMetric(title: "繁殖", value: entry.snapshot.breedingProgress * 100, tint: .green, isHighlighted: entry.snapshot.mostImportantNeed == .breeding)
                CompactMetric(title: "水分", value: entry.snapshot.water, tint: .cyan, isHighlighted: entry.snapshot.mostImportantNeed == .water)
                CompactMetric(title: "安心", value: entry.snapshot.safety, tint: .orange, isHighlighted: entry.snapshot.mostImportantNeed == .safety)
            }
        }
        .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.07))
    }

    private var mediumLayout: some View {
        HStack(spacing: 14) {
            VStack(spacing: 7) {
                RoachMoodCharacter(mood: entry.snapshot.mood(at: entry.date))
                    .frame(width: 82, height: 84)
                Text(entry.snapshot.message(at: entry.date))
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
            }
            .frame(width: 112)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(entry.snapshot.totalCount)")
                        .font(.system(size: 31, weight: .black, design: .rounded))
                        .monospacedDigit()
                    Text("匹")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                    Spacer()
                    Text("卵鞘 \(entry.snapshot.eggCaseCount)")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                WideMetric(title: "繁殖", value: entry.snapshot.breedingProgress * 100, tint: .green, isHighlighted: entry.snapshot.mostImportantNeed == .breeding)
                WideMetric(title: "水分", value: entry.snapshot.water, tint: .cyan, isHighlighted: entry.snapshot.mostImportantNeed == .water)
                WideMetric(title: "安心", value: entry.snapshot.safety, tint: .orange, isHighlighted: entry.snapshot.mostImportantNeed == .safety)
            }
        }
        .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.07))
    }
}

private struct CompactMetric: View {
    let title: String
    let value: Double
    let tint: Color
    let isHighlighted: Bool

    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
            Text("\(Int(value.rounded()))%")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .monospacedDigit()
            GeometryReader { proxy in
                Capsule()
                    .fill(.black.opacity(0.10))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(tint)
                            .frame(width: proxy.size.width * min(1, max(0, value / 100)))
                    }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(isHighlighted ? tint.opacity(0.25) : .white.opacity(0.50), in: RoundedRectangle(cornerRadius: 9))
        .overlay {
            if isHighlighted {
                RoundedRectangle(cornerRadius: 9).stroke(tint, lineWidth: 2)
            }
        }
    }
}

private struct WideMetric: View {
    let title: String
    let value: Double
    let tint: Color
    let isHighlighted: Bool

    var body: some View {
        HStack(spacing: 7) {
            Text(title)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .frame(width: 28, alignment: .leading)
            GeometryReader { proxy in
                Capsule()
                    .fill(.black.opacity(0.10))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(tint)
                            .frame(width: proxy.size.width * min(1, max(0, value / 100)))
                    }
            }
            .frame(height: 7)
            Text("\(Int(value.rounded()))%")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .monospacedDigit()
                .frame(width: 34, alignment: .trailing)
        }
        .padding(.horizontal, isHighlighted ? 5 : 0)
        .padding(.vertical, isHighlighted ? 3 : 0)
        .background(isHighlighted ? tint.opacity(0.18) : .clear, in: RoundedRectangle(cornerRadius: 7))
    }
}

private struct RoachMoodCharacter: View {
    let mood: RoachWidgetMood

    var body: some View {
        ZStack {
            antennae
            RoundedRectangle(cornerRadius: 28)
                .fill(shellColor)
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color(red: 1.0, green: 0.78, blue: 0.23), lineWidth: 3)
                }
                .padding(.top, 10)
            VStack(spacing: 7) {
                HStack(spacing: 17) {
                    eye
                    eye
                }
                mouth
            }
            .padding(.top, 13)
        }
        .accessibilityHidden(true)
    }

    private var antennae: some View {
        HStack(spacing: 17) {
            Capsule().fill(shellColor).frame(width: 5, height: 30).rotationEffect(.degrees(-28))
            Capsule().fill(shellColor).frame(width: 5, height: 30).rotationEffect(.degrees(28))
        }
        .offset(y: -18)
    }

    private var eye: some View {
        Group {
            if mood == .urgent {
                Capsule().fill(.white).frame(width: 8, height: 14)
            } else if mood == .grateful {
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(.white)
            } else {
                Circle().fill(.white).frame(width: 9, height: 9)
            }
        }
    }

    @ViewBuilder private var mouth: some View {
        switch mood {
        case .grateful:
            Image(systemName: "mouth.fill")
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(Color(red: 1.0, green: 0.76, blue: 0.33))
        case .urgent:
            Circle().fill(.white).frame(width: 12, height: 15)
        case .unhappy:
            Capsule().fill(.white).frame(width: 19, height: 4).rotationEffect(.degrees(-8))
        case .waiting:
            Capsule().fill(.white).frame(width: 17, height: 4)
        case .normal:
            Image(systemName: "chevron.up")
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(.white)
        }
    }

    private var shellColor: Color {
        switch mood {
        case .urgent: return Color(red: 0.50, green: 0.08, blue: 0.04)
        case .unhappy: return Color(red: 0.22, green: 0.10, blue: 0.07)
        case .waiting: return Color(red: 0.30, green: 0.16, blue: 0.09)
        case .normal, .grateful: return Color(red: 0.18, green: 0.10, blue: 0.06)
        }
    }
}

private struct RoachWidgetBackground: View {
    let mood: RoachWidgetMood

    var body: some View {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                Circle()
                    .fill(.white.opacity(0.13))
                    .blur(radius: 24)
                    .offset(x: 70, y: -50)
            }
    }

    private var colors: [Color] {
        switch mood {
        case .grateful: return [Color(red: 0.98, green: 0.86, blue: 0.42), Color(red: 0.55, green: 0.75, blue: 0.34)]
        case .urgent: return [Color(red: 0.95, green: 0.46, blue: 0.20), Color(red: 0.42, green: 0.07, blue: 0.04)]
        case .unhappy: return [Color(red: 0.74, green: 0.45, blue: 0.22), Color(red: 0.25, green: 0.12, blue: 0.08)]
        case .waiting: return [Color(red: 0.92, green: 0.67, blue: 0.27), Color(red: 0.46, green: 0.28, blue: 0.12)]
        case .normal: return [Color(red: 0.97, green: 0.78, blue: 0.25), Color(red: 0.64, green: 0.79, blue: 0.39)]
        }
    }
}
