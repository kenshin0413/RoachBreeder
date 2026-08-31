//
//  FoodView.swift
//  RoachBreeder
//

import SwiftUI

struct FoodView: View {
    let amount: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.72, green: 0.43, blue: 0.16))
                .frame(width: 28, height: 28)
            ForEach(foodCrumbs) { crumb in
                Circle()
                    .fill(Color(red: 0.98, green: 0.68, blue: 0.25))
                    .frame(width: crumb.size, height: crumb.size)
                    .offset(x: crumb.offset.dx, y: crumb.offset.dy)
            }
        }
        .scaleEffect(max(0.45, amount / 100))
        .shadow(color: .black.opacity(0.24), radius: 3, y: 2)
    }

    private var foodCrumbs: [FoodCrumb] {
        [
            FoodCrumb(offset: CGVector(dx: -7, dy: -3), size: 5),
            FoodCrumb(offset: CGVector(dx: 6, dy: -5), size: 7),
            FoodCrumb(offset: CGVector(dx: 2, dy: 5), size: 6),
            FoodCrumb(offset: CGVector(dx: -3, dy: 7), size: 4),
            FoodCrumb(offset: CGVector(dx: 8, dy: 4), size: 5)
        ]
    }
}

private struct FoodCrumb: Identifiable {
    let id = UUID()
    let offset: CGVector
    let size: CGFloat
}
