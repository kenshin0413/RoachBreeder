//
//  ColonyArenaView.swift
//  RoachBreeder
//

import SwiftUI

struct ColonyArenaView: View {
    let colony: ColonyState
    let roomSkin: RoomSkin
    let height: CGFloat
    let zoom: CGFloat
    let selectedTool: CareTool?
    let selectedHideout: Hideout?
    let isLightFlashing: Bool
    let lightPoint: CGPoint?
    let onTapLocation: (CGPoint) -> Void
    let onCancelHideoutEdit: () -> Void
    let onDeleteHideout: () -> Void
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void
    let onAppear: (CGSize) -> Void
    let onSizeChange: (CGSize) -> Void

    var body: some View {
        GeometryReader { proxy in
            let viewportSize = proxy.size
            let worldZoom = max(zoom, 1.0)
            let worldSize = zoom < 1 ? CGSize(width: viewportSize.width / zoom, height: viewportSize.height / zoom) : viewportSize
            let worldCenter = CGPoint(x: worldSize.width / 2, y: worldSize.height / 2)
            let viewportCenter = CGPoint(x: viewportSize.width / 2, y: viewportSize.height / 2)

            ZStack {
                NestWorldView(colony: colony, roomSkin: roomSkin, selectedHideoutID: selectedHideout?.id)
                .frame(width: worldSize.width, height: worldSize.height)
                .scaleEffect(zoom < 1 ? zoom : worldZoom)
                .position(viewportCenter)
                .animation(.spring(response: 0.25, dampingFraction: 0.85), value: zoom)

                ArenaTapLayer(
                    viewportSize: viewportSize,
                    zoom: zoom,
                    worldSize: worldSize,
                    worldCenter: worldCenter,
                    viewportCenter: viewportCenter,
                    onTapLocation: onTapLocation
                )

                ArenaTopRightControls(
                    zoom: zoom,
                    onZoomIn: onZoomIn,
                    onZoomOut: onZoomOut
                )
                    .position(x: viewportSize.width - 56, y: 27)
                    .zIndex(9)

                if let selectedHideout {
                    HideoutEditOverlay(
                        hideout: selectedHideout,
                        onCancel: onCancelHideoutEdit,
                        onDelete: onDeleteHideout
                    )
                    .zIndex(8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                DustMoteOverlay()
                    .zIndex(6)

                if isLightFlashing {
                    LightFlashOverlay(lightPoint: lightPoint, worldSize: worldSize, zoom: zoom)
                        .zIndex(7)
                        .transition(.opacity)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(red: 0.96, green: 0.86, blue: 0.56),
                                Color(red: 0.28, green: 0.42, blue: 0.28).opacity(0.55),
                                .black.opacity(0.28)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
            .shadow(color: .black.opacity(0.24), radius: 18, x: 0, y: 10)
            .onAppear {
                onAppear(worldSize)
            }
            .onChange(of: proxy.size) { _, _ in
                onSizeChange(worldSize)
            }
            .onChange(of: zoom) { _, _ in
                onSizeChange(worldSize)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }

}

struct ColonyRoomSnapshotView: View {
    let colony: ColonyState
    let roomSkin: RoomSkin

    var body: some View {
        ZStack {
            NestWorldView(colony: colony, roomSkin: roomSkin, showsMagnifierBadge: false)
            DustMoteOverlay()
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.96, green: 0.86, blue: 0.56),
                            Color(red: 0.28, green: 0.42, blue: 0.28).opacity(0.55),
                            .black.opacity(0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        }
    }
}

private struct NestWorldView: View {
    let colony: ColonyState
    var roomSkin: RoomSkin = .deskGap
    var showsMagnifierBadge: Bool = true
    var selectedHideoutID: UUID? = nil

    var body: some View {
        ZStack {
            NestBackground(skin: roomSkin)

            RoomGapGameOverlay(showsBadge: showsMagnifierBadge)
                .allowsHitTesting(false)
                .zIndex(1)

            ForEach(colony.waterSpots) { spot in
                WaterSpotView(spot: spot)
                    .position(spot.position)
                    .zIndex(1.1)
            }

            ForEach(colony.hides) { hide in
                HideoutView(kind: hide.kind)
                    .frame(width: hide.size.width, height: hide.size.height)
                    .position(hide.position)
                    .zIndex(hide.kind == .tape ? 1.02 : 1.25)
            }

            if let selectedHideout = colony.hides.first(where: { $0.id == selectedHideoutID }) {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(red: 1.0, green: 0.84, blue: 0.26), style: StrokeStyle(lineWidth: 2.2, dash: [6, 4]))
                    .frame(width: selectedHideout.size.width + 14, height: selectedHideout.size.height + 14)
                    .position(selectedHideout.position)
                    .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.26).opacity(0.42), radius: 6)
                    .zIndex(5)
            }

            ForEach(colony.foods) { food in
                FoodView(amount: food.amount)
                    .position(food.position)
                    .zIndex(1.45)
            }

            ForEach(colony.eggCases) { eggCase in
                EggCaseView(eggCase: eggCase)
                    .position(eggCase.position)
                    .zIndex(1.55)
            }

            ForEach(colony.roaches) { roach in
                RoachView(roach: roach)
                    .position(roach.position)
                    .zIndex(roach.stage == .adult ? 3 : 2)
            }

            ForEach(colony.hides) { hide in
                HideoutCoverView(kind: hide.kind)
                    .frame(width: hide.size.width, height: hide.size.height)
                    .position(hide.position)
                    .zIndex(4)
            }
        }
    }
}

private struct HideoutEditOverlay: View {
    let hideout: Hideout
    let onCancel: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Image(hideout.kind.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 28)
                    .shadow(color: .black.opacity(0.24), radius: 2, y: 1)

                VStack(alignment: .leading, spacing: 2) {
                    Text(hideout.kind.title)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(String(localized: "移動先をタップ"))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.76))
                }

                Spacer(minLength: 4)

                Button(action: onDelete) {
                    Label(String(localized: "削除"), systemImage: "trash.fill")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .frame(height: 32)
                        .background(Color(red: 0.80, green: 0.18, blue: 0.16), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(ArenaPressButtonStyle())

                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(Color(red: 0.18, green: 0.16, blue: 0.12))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.62), in: Circle())
                }
                .buttonStyle(ArenaPressButtonStyle())
            }
            .padding(.leading, 10)
            .padding(.trailing, 7)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.74), in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.34), lineWidth: 1)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }
}

private struct ArenaPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(.spring(response: 0.18, dampingFraction: 0.74), value: configuration.isPressed)
    }
}

private struct ArenaTapLayer: View {
    let viewportSize: CGSize
    let zoom: CGFloat
    let worldSize: CGSize
    let worldCenter: CGPoint
    let viewportCenter: CGPoint
    let onTapLocation: (CGPoint) -> Void

    var body: some View {
        tapRegion(
            origin: .zero,
            width: viewportSize.width,
            height: viewportSize.height
        )
    }

    private func tapRegion(origin: CGPoint, width: CGFloat, height: CGFloat) -> some View {
        Color.clear
            .frame(width: width, height: height)
            .contentShape(Rectangle())
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        let viewportPoint = CGPoint(
                            x: origin.x + value.location.x,
                            y: origin.y + value.location.y
                        )
                        let modelPoint = CGPoint(
                            x: worldCenter.x + (viewportPoint.x - viewportCenter.x) / zoom,
                            y: worldCenter.y + (viewportPoint.y - viewportCenter.y) / zoom
                        )
                        onTapLocation(modelPoint.clamped(to: worldSize, inset: 26))
                    }
            )
    }
}

private struct ArenaTopRightControls: View {
    let zoom: CGFloat
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void

    var body: some View {
        ZoomControl(zoom: zoom, onZoomIn: onZoomIn, onZoomOut: onZoomOut)
    }
}

private struct LightFlashOverlay: View {
    let lightPoint: CGPoint?
    let worldSize: CGSize
    let zoom: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let point = lightPoint ?? CGPoint(x: worldSize.width * 0.82, y: worldSize.height * 0.18)
            let viewportPoint = CGPoint(
                x: proxy.size.width / 2 + (point.x - worldSize.width / 2) * zoom,
                y: proxy.size.height / 2 + (point.y - worldSize.height / 2) * zoom
            )

            ZStack {
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.96, blue: 0.62).opacity(0.58),
                        Color(red: 1.0, green: 0.86, blue: 0.32).opacity(0.18),
                        .clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 250
                )
                .frame(width: 520, height: 520)
                .position(viewportPoint)

                Circle()
                    .fill(Color(red: 1.0, green: 0.96, blue: 0.62).opacity(0.32))
                    .frame(width: 70, height: 70)
                    .blur(radius: 8)
                    .position(viewportPoint)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct DustMoteOverlay: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(arenaDustMotes) { mote in
                    Circle()
                        .fill(Color(red: 0.84, green: 0.76, blue: 0.58).opacity(mote.opacity))
                        .frame(width: mote.size, height: mote.size)
                        .blur(radius: mote.blur)
                        .position(x: mote.xRatio * proxy.size.width, y: mote.yRatio * proxy.size.height)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct RoomGapGameOverlay: View {
    var showsBadge: Bool = true

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                magnifiedGapShade

                if showsBadge {
                    VStack {
                        HStack(alignment: .top) {
                            gapBadge
                            Spacer()
                        }
                        .padding(12)
                        Spacer()
                    }
                }
            }
        }
    }

    private var gapBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "scope")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(Color(red: 0.54, green: 0.78, blue: 0.34))
            Text(String(localized: "すき間を拡大中"))
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.18, green: 0.20, blue: 0.14))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white.opacity(0.76), in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.50), lineWidth: 1)
        }
    }

    private var magnifiedGapShade: some View {
        ZStack {
            LinearGradient(
                colors: [.black.opacity(0.15), .clear, .black.opacity(0.23)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .allowsHitTesting(false)

            RadialGradient(
                colors: [.clear, .black.opacity(0.25)],
                center: .center,
                startRadius: 170,
                endRadius: 520
            )
            .allowsHitTesting(false)
        }
    }
}

private struct ZoomControl: View {
    let zoom: CGFloat
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Button(action: onZoomOut) {
                Image(systemName: "minus")
                    .frame(width: 19, height: 24)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())

            Text("\(Int(zoom * 100))%")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .monospacedDigit()
                .frame(width: 34)

            Button(action: onZoomIn) {
                Image(systemName: "plus")
                    .frame(width: 19, height: 24)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
        .font(.system(size: 10, weight: .black))
        .foregroundStyle(Color(red: 0.18, green: 0.20, blue: 0.14))
        .frame(width: 88, height: 30)
        .background(.white.opacity(0.78), in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.50), lineWidth: 1)
        }
    }
}

private struct ZoomHitControl: View {
    let zoom: CGFloat
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void

    var body: some View {
        ZoomControl(zoom: zoom, onZoomIn: onZoomIn, onZoomOut: onZoomOut)
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .allowsHitTesting(true)
    }
}

private struct ArenaDustMote: Identifiable {
    let id = UUID()
    let xRatio: CGFloat
    let yRatio: CGFloat
    let size: CGFloat
    let opacity: Double
    let blur: CGFloat
}

private let arenaDustMotes: [ArenaDustMote] = [
    ArenaDustMote(xRatio: 0.12, yRatio: 0.18, size: 3, opacity: 0.20, blur: 0.5),
    ArenaDustMote(xRatio: 0.28, yRatio: 0.34, size: 2, opacity: 0.16, blur: 0.4),
    ArenaDustMote(xRatio: 0.43, yRatio: 0.20, size: 4, opacity: 0.12, blur: 1.0),
    ArenaDustMote(xRatio: 0.63, yRatio: 0.31, size: 2, opacity: 0.18, blur: 0.4),
    ArenaDustMote(xRatio: 0.79, yRatio: 0.16, size: 3, opacity: 0.15, blur: 0.7),
    ArenaDustMote(xRatio: 0.86, yRatio: 0.46, size: 2, opacity: 0.20, blur: 0.5),
    ArenaDustMote(xRatio: 0.18, yRatio: 0.58, size: 4, opacity: 0.11, blur: 1.1),
    ArenaDustMote(xRatio: 0.36, yRatio: 0.70, size: 2, opacity: 0.18, blur: 0.4),
    ArenaDustMote(xRatio: 0.54, yRatio: 0.55, size: 3, opacity: 0.15, blur: 0.7),
    ArenaDustMote(xRatio: 0.72, yRatio: 0.76, size: 2, opacity: 0.16, blur: 0.4),
    ArenaDustMote(xRatio: 0.91, yRatio: 0.84, size: 4, opacity: 0.10, blur: 1.0)
]
