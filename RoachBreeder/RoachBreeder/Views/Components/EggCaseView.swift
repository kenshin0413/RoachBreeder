//
//  EggCaseView.swift
//  RoachBreeder
//

import SwiftUI

struct EggCaseView: View {
    let eggCase: EggCase

    var body: some View {
        Image(eggCase.variant?.eggAssetName ?? "Ootheca")
            .resizable()
            .scaledToFit()
            .frame(width: eggCase.variant == nil ? 18 : 22, height: eggCase.variant == nil ? 38 : 44)
            .rotationEffect(.degrees(-82))
            .scaleEffect(0.92 + min(1, eggCase.progress) * 0.12)
            .brightness(min(1, eggCase.progress) * 0.05)
            .shadow(color: .black.opacity(0.30), radius: 2, x: 0, y: 1)
            .overlay {
                Capsule()
                    .fill(Color(red: 0.96, green: 0.72, blue: 0.32).opacity(0.10 * min(1, eggCase.progress)))
                    .frame(width: 26, height: 10)
                    .blur(radius: 4)
            }
    }
}
