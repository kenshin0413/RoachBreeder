//
//  StatPill.swift
//  RoachBreeder
//

import SwiftUI

struct StatPill: View {
    let title: String
    let value: Int
    var suffix: String = ""
    let tint: Color

    var body: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(tint)
                .frame(width: 7, height: 7)
            Text("\(value)\(suffix)")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Color(red: 0.16, green: 0.16, blue: 0.12))
            Text(title)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.40, green: 0.40, blue: 0.32))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [.white.opacity(0.72), tint.opacity(0.20)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(tint.opacity(0.22), lineWidth: 1)
        }
    }
}
