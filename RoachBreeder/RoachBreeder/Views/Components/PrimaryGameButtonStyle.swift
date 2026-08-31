//
//  PrimaryGameButtonStyle.swift
//  RoachBreeder
//

import SwiftUI

struct PrimaryGameButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .background(tint.opacity(configuration.isPressed ? 0.55 : 0.82), in: RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
