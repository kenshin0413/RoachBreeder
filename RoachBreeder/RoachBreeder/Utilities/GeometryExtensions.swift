//
//  GeometryExtensions.swift
//  RoachBreeder
//

import CoreGraphics
import Foundation

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGVector) -> CGPoint {
        CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
    }

    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }

    func clamped(to size: CGSize, inset: CGFloat) -> CGPoint {
        CGPoint(
            x: min(max(inset, x), max(inset, size.width - inset)),
            y: min(max(inset, y), max(inset, size.height - inset))
        )
    }
}

extension CGVector {
    static let zero = CGVector(dx: 0, dy: 0)

    var angle: CGFloat {
        atan2(dy, dx)
    }

    func scaled(by value: CGFloat) -> CGVector {
        CGVector(dx: dx * value, dy: dy * value)
    }
}

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
}

extension Bool {
    static func random(probability: Double) -> Bool {
        Double.random(in: 0...1) < probability
    }
}

func unitVector(from start: CGPoint, to end: CGPoint) -> CGVector {
    let dx = end.x - start.x
    let dy = end.y - start.y
    let length = max(1, hypot(dx, dy))
    return CGVector(dx: dx / length, dy: dy / length)
}
