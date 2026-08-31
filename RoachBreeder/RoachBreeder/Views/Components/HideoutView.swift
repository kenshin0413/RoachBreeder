//
//  HideoutView.swift
//  RoachBreeder
//

import SwiftUI

struct HideoutView: View {
    var kind: HideoutKind = .paper

    var body: some View {
        HideoutAssetImage(kind: kind, layer: .base)
    }
}

struct HideoutCoverView: View {
    var kind: HideoutKind = .paper

    @ViewBuilder
    var body: some View {
        if kind.hasCoverLayer {
            HideoutAssetImage(kind: kind, layer: .cover)
        }
    }
}

private struct HideoutAssetImage: View {
    enum Layer {
        case base
        case cover
    }

    let kind: HideoutKind
    let layer: Layer

    var body: some View {
        Image(kind.assetName)
            .resizable()
            .scaledToFit()
            .opacity(layer == .base ? kind.baseOpacity : kind.coverOpacity)
            .saturation(0.94)
            .brightness(kind.brightness)
            .contrast(1.04)
            .background(alignment: .bottom) {
                if layer == .base {
                    Ellipse()
                        .fill(.black.opacity(kind.groundShadowOpacity))
                        .frame(width: kind.shadowScale.width, height: kind.shadowScale.height)
                        .blur(radius: 8)
                        .offset(y: kind.shadowYOffset)
                }
            }
            .shadow(color: .black.opacity(layer == .base ? 0.18 : 0.34), radius: layer == .base ? 5 : 8, x: 0, y: layer == .base ? 3 : 5)
            .rotationEffect(.degrees(kind.imageRotation))
    }
}

private extension HideoutKind {
    var imageRotation: Double {
        switch self {
        case .paper:
            return -4
        case .receipt:
            return 3
        case .woodChip:
            return -10
        case .cloth:
            return -7
        case .cable:
            return 5
        case .darkBox:
            return -2
        case .foil:
            return -13
        case .bottleCap:
            return 0
        case .tape:
            return 4
        case .matchbox:
            return -3
        case .snackWrapper:
            return -8
        case .roachTrap:
            return -1
        case .plasticShard:
            return 6
        case .dustPocket:
            return 8
        case .drainPipe:
            return -4
        }
    }

    var baseOpacity: Double {
        switch self {
        case .cable, .drainPipe:
            return 0.34
        case .plasticShard:
            return 0.38
        case .bottleCap:
            return 0.40
        default:
            return 0.44
        }
    }

    var coverOpacity: Double {
        switch self {
        case .foil:
            return 0.86
        case .plasticShard:
            return 0.88
        case .cable, .drainPipe:
            return 0.92
        default:
            return 0.94
        }
    }

    var brightness: Double {
        switch self {
        case .foil:
            return -0.05
        case .plasticShard:
            return -0.12
        case .roachTrap:
            return -0.07
        case .darkBox, .cable, .drainPipe:
            return -0.10
        default:
            return -0.03
        }
    }

    var groundShadowOpacity: Double {
        switch self {
        case .darkBox, .roachTrap:
            return 0.36
        case .cable, .drainPipe:
            return 0.22
        case .foil:
            return 0.16
        default:
            return 0.24
        }
    }

    var shadowScale: CGSize {
        switch self {
        case .bottleCap:
            return CGSize(width: 74, height: 30)
        case .roachTrap:
            return CGSize(width: 66, height: 24)
        case .cable, .drainPipe:
            return CGSize(width: 160, height: 22)
        default:
            return CGSize(width: 130, height: 34)
        }
    }

    var shadowYOffset: CGFloat {
        switch self {
        case .cable, .drainPipe:
            return 2
        default:
            return 5
        }
    }

    var hasCoverLayer: Bool {
        switch self {
        case .tape:
            return false
        default:
            return true
        }
    }
}
