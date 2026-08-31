//
//  ColonyHeaderView.swift
//  RoachBreeder
//

import SwiftUI

struct ColonyHeaderView: View {
    let colony: ColonyState
    var isCompact: Bool = false

    var body: some View {
        VStack(spacing: isCompact ? 6 : 8) {
            HStack(spacing: isCompact ? 9 : 12) {
                VStack(alignment: .leading, spacing: isCompact ? 5 : 7) {
                    Text(String(localized: "ゴキブリ育成"))
                        .font(.system(size: isCompact ? 22 : 27, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.16, green: 0.16, blue: 0.12))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                    HStack(spacing: 6) {
                        SexBadge(label: String(localized: "オス"), count: colony.maleCount, tint: Color(red: 0.24, green: 0.52, blue: 0.82))
                        SexBadge(label: String(localized: "メス"), count: colony.femaleCount, tint: Color(red: 0.82, green: 0.36, blue: 0.52))
                    }
                }

                Spacer()

                VStack(spacing: 0) {
                    Text("\(colony.totalCount)")
                        .font(.system(size: isCompact ? 30 : 36, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color(red: 0.12, green: 0.18, blue: 0.13))
                    Text(String(localized: "匹"))
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.45, green: 0.50, blue: 0.40).opacity(0.84))
                }
                .frame(width: isCompact ? 66 : 78, height: isCompact ? 56 : 64)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.90, blue: 0.50),
                            Color(red: 0.64, green: 0.82, blue: 0.46)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.70), lineWidth: 1)
                }
            }

            HStack(spacing: 8) {
                ResourceGauge(
                    title: String(localized: "繁殖"),
                    value: colony.breedingProgress,
                    tint: Color(red: 0.38, green: 0.70, blue: 0.35),
                    trailingText: "\(Int(colony.breedingPoints))/\(Int(ColonyState.breedingThreshold))"
                )
                ResourceGauge(
                    title: String(localized: "水分"),
                    value: colony.water / 100,
                    tint: Color(red: 0.18, green: 0.64, blue: 0.82),
                    trailingText: "\(Int(colony.water))%"
                )
                ResourceGauge(
                    title: String(localized: "安心"),
                    value: colony.safety / 100,
                    tint: Color(red: 0.95, green: 0.57, blue: 0.20),
                    trailingText: "\(Int(colony.safety))%"
                )
            }
        }
        .padding(.horizontal, isCompact ? 9 : 13)
        .padding(.vertical, isCompact ? 8 : 11)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.95, blue: 0.82),
                    Color(red: 0.86, green: 0.90, blue: 0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(red: 0.34, green: 0.40, blue: 0.26).opacity(0.22), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.16), radius: 14, y: 8)
    }
}

private struct SexBadge: View {
    let label: String
    let count: Int
    let tint: Color

    var body: some View {
        HStack(spacing: 3) {
            Text(label)
            Text("\(count)")
                .monospacedDigit()
        }
        .font(.system(size: 9, weight: .black, design: .rounded))
        .foregroundStyle(tint)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(.white.opacity(0.45), in: Capsule())
        .overlay {
            Capsule()
                .stroke(tint.opacity(0.22), lineWidth: 1)
        }
    }
}
