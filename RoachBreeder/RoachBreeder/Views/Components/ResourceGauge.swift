//
//  ResourceGauge.swift
//  RoachBreeder
//

import SwiftUI

struct ResourceGauge: View {
    let title: String
    let value: Double
    let tint: Color
    var trailingText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.33, green: 0.36, blue: 0.28))
                Spacer()
                Text(trailingText)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color(red: 0.22, green: 0.24, blue: 0.18))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color(red: 0.70, green: 0.72, blue: 0.58).opacity(0.32))
                        .overlay(alignment: .top) {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(.white.opacity(0.34))
                                .frame(height: 3)
                        }
                    RoundedRectangle(cornerRadius: 7)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.36), tint.opacity(0.86), tint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * min(1, max(0, value)))
                        .shadow(color: tint.opacity(0.36), radius: 6, y: 0)
                }
            }
            .frame(height: 7)
        }
        .padding(9)
        .background(.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.black.opacity(0.06), lineWidth: 1)
        }
    }
}
