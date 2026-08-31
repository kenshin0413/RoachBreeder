//
//  GameScreenView.swift
//  RoachBreeder
//

import Combine
import SwiftUI
import UIKit

private struct RequiredUpdateOverlay: View {
    let version: String
    let onUpdate: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.84)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "arrow.down.app.fill")
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(Color(red: 1.0, green: 0.82, blue: 0.28))

                VStack(spacing: 7) {
                    Text(String(localized: "アップデートが必要です"))
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(String(localized: "最新版 \(version) に更新してから、飼育を続けてください。"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                }

                Button(action: onUpdate) {
                    Text(String(localized: "App Storeでアップデート"))
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.14, green: 0.12, blue: 0.08))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.86, blue: 0.34),
                                    Color(red: 0.72, green: 0.92, blue: 0.44)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 17)
                        )
                }
                .buttonStyle(UtilityBarButtonStyle())
            }
            .padding(24)
            .frame(maxWidth: 360)
            .background(
                Color(red: 0.13, green: 0.11, blue: 0.08),
                in: RoundedRectangle(cornerRadius: 28)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 28)
                    .stroke(.white.opacity(0.16), lineWidth: 1)
            }
            .padding(24)
        }
    }
}

private enum RewardedAdAction: Identifiable {
    case bonusCare(CareTool)
    case gachaTicket

    var id: String {
        switch self {
        case .bonusCare(let tool):
            return "bonus-care-\(tool.rawValue)"
        case .gachaTicket:
            return "gacha-ticket"
        }
    }

    var alertTitle: String {
        switch self {
        case .bonusCare(let tool):
            return String(localized: "広告を見て\(tool.title)を追加しますか？")
        case .gachaTicket:
            return String(localized: "広告を見てチケットを獲得しますか？")
        }
    }

    var alertMessage: String {
        switch self {
        case .bonusCare(let tool):
            return String(localized: "動画広告の視聴完了後、今日だけ\(tool.title)をもう1回使えるようになります。")
        case .gachaTicket:
            return String(localized: "動画広告の視聴完了後、Gガチャチケットを1枚受け取れます。")
        }
    }
}

private enum RewardedAdDisclosureStore {
    private static let acknowledgementKey = "RoachBreeder.RewardedAdDisclosureAcknowledged.v1"

    static var hasAcknowledged: Bool {
        UserDefaults.standard.bool(forKey: acknowledgementKey)
    }

    static func acknowledge() {
        UserDefaults.standard.set(true, forKey: acknowledgementKey)
    }
}

private struct RewardedAdDisclosureOverlay: View {
    let action: RewardedAdAction
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()
                .contentShape(Rectangle())

            VStack(spacing: 18) {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 38, weight: .black))
                    .foregroundStyle(Color(red: 1.0, green: 0.82, blue: 0.28))

                VStack(spacing: 8) {
                    Text(action.alertTitle)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text(action.alertMessage)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 10) {
                    Button(action: onCancel) {
                        Text(String(localized: "やめる"))
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                            .contentShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)

                    Button(action: onConfirm) {
                        Text(String(localized: "広告を見る"))
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 0.13, green: 0.11, blue: 0.08))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.84, blue: 0.30),
                                        Color(red: 0.68, green: 0.94, blue: 0.42)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(UtilityBarButtonStyle())
            }
            .padding(22)
            .frame(maxWidth: 350)
            .background(
                Color(red: 0.13, green: 0.11, blue: 0.08),
                in: RoundedRectangle(cornerRadius: 26)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 26)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            }
            .padding(24)
        }
        .ignoresSafeArea()
        .accessibilityAddTraits(.isModal)
    }
}

private struct RewardedAdSuccessOverlay: View {
    let action: RewardedAdAction
    let onDismiss: () -> Void

    @State private var isPresented = false

    private var title: String {
        switch action {
        case .bonusCare(let tool):
            return String(localized: "\(tool.title)を今日もう1回使えます")
        case .gachaTicket:
            return String(localized: "Gガチャチケット +1")
        }
    }

    private var message: String {
        switch action {
        case .bonusCare(.food):
            return String(localized: "ゴキブリのいるスペースにタップで餌をおく")
        case .bonusCare(.water):
            return String(localized: "ゴキブリのいるスペースにタップで水をおく")
        case .bonusCare(.light):
            return String(localized: "ゴキブリのいるスペースにタップで光を当てる")
        case .gachaTicket:
            return String(localized: "Gガチャチケットを1枚獲得しました")
        }
    }

    private var icon: String {
        switch action {
        case .bonusCare(.food): return "takeoutbag.and.cup.and.straw.fill"
        case .bonusCare(.water): return "drop.fill"
        case .bonusCare(.light): return "flashlight.on.fill"
        case .gachaTicket: return "ticket.fill"
        }
    }

    private var accent: Color {
        switch action {
        case .bonusCare(.food): return Color(red: 1.0, green: 0.48, blue: 0.12)
        case .bonusCare(.water): return Color(red: 0.16, green: 0.72, blue: 1.0)
        case .bonusCare(.light): return Color(red: 1.0, green: 0.84, blue: 0.22)
        case .gachaTicket: return Color(red: 0.76, green: 0.94, blue: 0.38)
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(isPresented ? 0.84 : 0)
                .ignoresSafeArea()

            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(index.isMultiple(of: 2) ? accent : .white)
                    .frame(width: index.isMultiple(of: 3) ? 8 : 5)
                    .offset(
                        x: CGFloat(cos(Double(index) * .pi / 6)) * (isPresented ? 145 : 20),
                        y: CGFloat(sin(Double(index) * .pi / 6)) * (isPresented ? 145 : 20)
                    )
                    .opacity(isPresented ? 0.88 : 0)
            }

            VStack(spacing: 18) {
                Text("AD REWARD")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .tracking(3.6)
                    .foregroundStyle(accent)

                ZStack {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(accent.opacity(0.34 - Double(index) * 0.08), lineWidth: 2)
                            .frame(width: CGFloat(116 + index * 42), height: CGFloat(116 + index * 42))
                            .scaleEffect(isPresented ? 1 : 0.35)
                    }

                    Circle()
                        .fill(RadialGradient(colors: [accent.opacity(0.72), .clear], center: .center, startRadius: 2, endRadius: 86))
                        .frame(width: 180, height: 180)

                    Image(systemName: icon)
                        .font(.system(size: 72, weight: .black))
                        .foregroundStyle(.white)
                        .scaleEffect(isPresented ? 1 : 0.15)
                        .rotationEffect(.degrees(isPresented ? -7 : -35))
                        .shadow(color: accent.opacity(0.9), radius: 26)
                }
                .frame(height: 194)

                VStack(spacing: 7) {
                    Text(title)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text(message)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.70))
                }

                Button {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    withAnimation(.easeOut(duration: 0.20)) { onDismiss() }
                } label: {
                    Text(String(localized: "受け取る"))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.12, green: 0.11, blue: 0.08))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(colors: [accent, accent.opacity(0.72)], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                }
                .buttonStyle(UtilityBarButtonStyle())
            }
            .padding(24)
            .frame(maxWidth: 360)
        }
        .ignoresSafeArea()
        .accessibilityAddTraits(.isModal)
        .onAppear {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.48, dampingFraction: 0.68)) {
                isPresented = true
            }
        }
    }
}

struct GameScreenView: View {
    @Binding private var deepLinkTarget: String?
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = ColonyViewModel()
    @StateObject private var updateManager = AppUpdateManager()
    @StateObject private var reviewManager = ReviewPromptManager()
    @StateObject private var rewardedAdManager = RewardedAdManager()
    @StateObject private var bgmPlayer = BGMPlayerManager()
    @State private var lastTickDate = Date()
    @State private var isLightFlashing = false
    @State private var lightPoint: CGPoint?
    @State private var observationLog: String?
    @State private var selectedTool: CareTool?
    @State private var zoom: CGFloat = 1.0
    @State private var isNameSheetPresented = false
    @State private var isGuidePresented = false
    @State private var isJournalPresented = false
    @State private var isGachaPresented = false
    @State private var isShareSheetPresented = false
    @State private var isBGMPlayerPresented = false
    @State private var isSettingsPresented = false
    @State private var isWidgetGuidePresented = false
    @State private var inspectedRoach: Roach?
    @State private var shareImage: UIImage?
    @State private var shareURL: URL?
    @State private var selectedStoredHideout: HideoutKind?
    @State private var selectedPlacedHideoutID: UUID?
    @State private var hasShownHideoutPlacementSlot = false
    @State private var isLayoutEditing = false
    @State private var pendingRewardedAdAction: RewardedAdAction?
    @State private var rewardedAdSuccess: RewardedAdAction?
    @State private var shouldResumeBGMAfterAd = false

    private let ticker = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()
    private let zoomLevels: [CGFloat] = [0.80, 1.0, 1.30]

    init(deepLinkTarget: Binding<String?> = .constant(nil)) {
        _deepLinkTarget = deepLinkTarget
    }

    var body: some View {
        GeometryReader { proxy in
            let isCompact = proxy.size.height < 900
            let isVeryCompact = proxy.size.height < 720
            let outerPadding: CGFloat = isCompact ? 10 : 16
            let verticalPadding = min(max(proxy.size.height * 0.012, 8), isCompact ? 11 : 15)
            let contentSpacing = min(max(proxy.size.height * 0.009, 6), isCompact ? 8 : 10)
            let headerReserve: CGFloat = isCompact ? 116 : 142
            let utilityReserve: CGFloat = isCompact ? 38 : 44
            let controlsReserve: CGFloat = isVeryCompact ? 128 : (isCompact ? 118 : 160)
            let topInset = verticalPadding
            let bottomInset = verticalPadding + (isVeryCompact ? 16 : (isCompact ? 18 : 22))
            let bottomBreathingRoom: CGFloat = isVeryCompact ? 16 : (isCompact ? 20 : 24)
            let usableHeight = proxy.size.height - topInset - bottomInset
            let showsHideoutPlacementSlot = hasShownHideoutPlacementSlot
                || !viewModel.memory.hideoutInventory.isEmpty
                || !viewModel.colony.hides.isEmpty
            let hideoutInventoryReserve: CGFloat = showsHideoutPlacementSlot ? (isCompact ? 48 : 54) : 0
            let stackGapCount: CGFloat = showsHideoutPlacementSlot ? 4 : 3
            let fixedContentHeight = headerReserve + utilityReserve + hideoutInventoryReserve + controlsReserve + contentSpacing * stackGapCount
            let arenaHeight = max(isCompact ? 276 : 336, usableHeight - fixedContentHeight - bottomBreathingRoom)

            ZStack {
                RoomGapBackdrop()

                VStack(spacing: contentSpacing) {
                    ColonyHeaderView(
                        colony: viewModel.colony,
                        isCompact: isCompact
                    )
                    GameUtilityBar(
                        isCompact: isCompact,
                        canDrawGacha: viewModel.memory.canDrawDailyGacha,
                        onGachaTap: { isGachaPresented = true },
                        onJournalTap: { isJournalPresented = true },
                        onGuideTap: { isGuidePresented = true },
                        onShareTap: prepareShareSnapshot,
                        onSettingsTap: { isSettingsPresented = true }
                    )
                    if showsHideoutPlacementSlot {
                        HideoutPlacementBar(
                            inventory: viewModel.memory.hideoutInventory,
                            selectedKind: $selectedStoredHideout,
                            isEditing: $isLayoutEditing,
                            onBeginEditing: beginLayoutEditing,
                            onFinishEditing: finishLayoutEditing,
                            isCompact: isCompact
                        )
                    }
                    ColonyArenaView(
                        colony: viewModel.colony,
                        roomSkin: viewModel.memory.activeRoomSkin,
                        height: arenaHeight,
                        zoom: zoom,
                        selectedTool: selectedTool,
                        selectedHideout: isLayoutEditing ? selectedPlacedHideout : nil,
                        isLightFlashing: isLightFlashing,
                        lightPoint: lightPoint,
                        onTapLocation: handleArenaTap(_:),
                        onCancelHideoutEdit: { selectedPlacedHideoutID = nil },
                        onDeleteHideout: deleteSelectedHideout,
                        onZoomIn: { zoom = nextZoomLevel(after: zoom) },
                        onZoomOut: { zoom = previousZoomLevel(before: zoom) },
                        onAppear: viewModel.arenaDidAppear(size:),
                        onSizeChange: viewModel.arenaSizeDidChange(to:)
                    )
                    ColonyControlsView(
                        selectedTool: $selectedTool,
                        isCompact: isCompact,
                        remainingUses: viewModel.colony.remainingCareUses(for:),
                        canWatchAdForBonusUse: { tool in
                            viewModel.colony.remainingCareUses(for: tool) == 0
                                && viewModel.canGrantBonusCareUse(for: tool)
                        },
                        onWatchAdForBonusUse: { tool in
                            requestRewardedAd(.bonusCare(tool))
                        }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, outerPadding)
                .padding(.top, topInset)
                .padding(.bottom, bottomInset)

                if let observationLog {
                    ObservationToast(text: observationLog)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 120)
                        .frame(maxHeight: .infinity, alignment: .top)
                }

                if viewModel.isDailyTicketRewardPending {
                    DailyTicketRewardOverlay(
                        ticketCount: viewModel.memory.gachaTickets,
                        onCollect: viewModel.acknowledgeDailyTicketReward
                    )
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
                    .zIndex(20)
                }

                if let update = updateManager.requiredUpdate {
                    RequiredUpdateOverlay(
                        version: update.version,
                        onUpdate: updateManager.openStore
                    )
                    .zIndex(100)
                }

                if let action = pendingRewardedAdAction {
                    RewardedAdDisclosureOverlay(
                        action: action,
                        onConfirm: {
                            RewardedAdDisclosureStore.acknowledge()
                            pendingRewardedAdAction = nil
                            DispatchQueue.main.async {
                                showRewardedAd(for: action)
                            }
                        },
                        onCancel: {
                            RewardedAdDisclosureStore.acknowledge()
                            pendingRewardedAdAction = nil
                        }
                    )
                    .zIndex(90)
                }

                if let action = rewardedAdSuccess {
                    RewardedAdSuccessOverlay(
                        action: action,
                        onDismiss: { rewardedAdSuccess = nil }
                    )
                    .transition(.opacity)
                    .zIndex(95)
                }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .preferredColorScheme(.dark)
        .onReceive(ticker) { tickDate in
            let delta = min(1.0 / 20.0, tickDate.timeIntervalSince(lastTickDate))
            lastTickDate = tickDate
            viewModel.advance(delta: delta)
            clearSelectedToolIfUsedUp()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                viewModel.save(requestWidgetReload: true)
                Task {
                    await updateManager.check()
                    if updateManager.requiredUpdate == nil {
                        reviewManager.evaluate(memory: viewModel.memory)
                    }
                }
            } else {
                viewModel.save()
            }
        }
        .onAppear {
            if !viewModel.memory.hideoutInventory.isEmpty {
                hasShownHideoutPlacementSlot = true
            }
            applyDeepLinkTargetIfNeeded()
        }
        .task {
            await rewardedAdManager.loadAdIfNeeded()
            await updateManager.check()
            if updateManager.requiredUpdate == nil {
                reviewManager.evaluate(memory: viewModel.memory)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled, !isWidgetGuidePresented,
                  await WidgetGuideCoordinator.shouldPresentAutomatically()
            else { return }
            isWidgetGuidePresented = true
        }
        .onChange(of: deepLinkTarget) { _, _ in
            applyDeepLinkTargetIfNeeded()
        }
        .onChange(of: viewModel.memory.hideoutInventory) { _, inventory in
            if !inventory.isEmpty {
                hasShownHideoutPlacementSlot = true
            }
        }
        .onChange(of: selectedTool) { _, tool in
            if tool != nil, isLayoutEditing {
                finishLayoutEditing()
            }
        }
        .onChange(of: updateManager.requiredUpdate?.version) { _, version in
            guard version != nil else { return }
            isNameSheetPresented = false
            isGuidePresented = false
            isJournalPresented = false
            isGachaPresented = false
            isShareSheetPresented = false
            isBGMPlayerPresented = false
            isSettingsPresented = false
            isWidgetGuidePresented = false
            inspectedRoach = nil
            reviewManager.isPromptPresented = false
        }
        .sheet(isPresented: $isNameSheetPresented) {
            NameRoachSheet(
                colony: viewModel.colony,
                memory: viewModel.memory,
                onSave: { id, name in
                    if viewModel.nameRoach(id: id, name: name) {
                        isNameSheetPresented = false
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isGuidePresented) {
            RoachGuideSheet(colony: viewModel.colony, memory: viewModel.memory)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isJournalPresented) {
            ObservationJournalSheet(
                memory: viewModel.memory,
                onEnableNotifications: {
                    DailyNotificationManager.configureDailyCareReminder()
                    showLog(String(localized: "毎日21時の通知を設定しました"))
                }
            )
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isGachaPresented) {
            GachaSheet(
                memory: viewModel.memory,
                onDraw: { count in
                    let rewards = viewModel.drawGacha(count: count)
                    reviewManager.evaluate(memory: viewModel.memory)
                    return rewards
                },
                rewardedAdManager: rewardedAdManager,
                onRewardedTicketEarned: {
                    viewModel.grantRewardedGachaTicket()
                },
                onSelectRoomSkin: { viewModel.selectRoomSkin($0) }
            )
            .presentationDetents([.height(640), .large])
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ShareSnapshotSheet(image: shareImage, shareURL: shareURL)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isBGMPlayerPresented) {
            BGMPlayerSheet(player: bgmPlayer)
                .presentationDetents([.height(720), .large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $isSettingsPresented) {
            AppSettingsSheet(
                isBGMPlaying: bgmPlayer.isPlaying,
                onOpenBGM: {
                    isSettingsPresented = false
                    DispatchQueue.main.async { isBGMPlayerPresented = true }
                },
                onOpenWidgetGuide: {
                    isSettingsPresented = false
                    DispatchQueue.main.async { isWidgetGuidePresented = true }
                }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isWidgetGuidePresented, onDismiss: WidgetGuideCoordinator.markDismissed) {
            WidgetGuideSheet()
                .presentationDetents([.large])
        }
        .sheet(item: $inspectedRoach) { roach in
            RoachStatusSheet(roach: roach)
                .presentationDetents([.height(530), .large])
        }
        .alert(String(localized: "飼育の手応え、どうですか？"), isPresented: $reviewManager.isPromptPresented) {
            Button(String(localized: "レビューする")) {
                reviewManager.requestReview()
            }
            Button(String(localized: "あとで"), role: .cancel) {}
        } message: {
            Text(String(localized: "今後のアップデートの参考に、感想を聞かせてください。"))
        }
        .onChange(of: rewardedAdManager.lastErrorMessage) { _, message in
            guard let message else { return }
            showLog(message)
        }
        .onChange(of: rewardedAdManager.isShowing) { _, isShowing in
            if isShowing {
                shouldResumeBGMAfterAd = bgmPlayer.isPlaying
                if shouldResumeBGMAfterAd {
                    bgmPlayer.pause()
                }
            } else if shouldResumeBGMAfterAd {
                shouldResumeBGMAfterAd = false
                bgmPlayer.play()
            }
        }
    }

    private func requestRewardedAd(_ action: RewardedAdAction) {
        if RewardedAdDisclosureStore.hasAcknowledged {
            showRewardedAd(for: action)
        } else {
            pendingRewardedAdAction = action
        }
    }

    private func applyDeepLinkTargetIfNeeded() {
        guard let target = deepLinkTarget else { return }
        deepLinkTarget = nil
        let tool: CareTool?
        switch target {
        case "food": tool = .food
        case "water": tool = .water
        case "light": tool = .light
        default: tool = nil
        }
        guard let tool else { return }
        if viewModel.colony.remainingCareUses(for: tool) > 0 {
            selectedTool = tool
            showLog(String(localized: "ウィジェットから\(tool.title)を選択しました"))
        } else {
            showLog(String(localized: "\(tool.title)は今日は完了しています"))
        }
    }

    private func showRewardedAd(for action: RewardedAdAction) {
        rewardedAdManager.showAd {
            switch action {
            case .bonusCare(let tool):
                viewModel.grantBonusCareUse(for: tool)
                withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                    selectedTool = tool
                }
            case .gachaTicket:
                viewModel.grantRewardedGachaTicket()
            }
            withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                rewardedAdSuccess = action
            }
        }
    }

    private func triggerLight() {
        if viewModel.shineLight() {
            showLightFeedback()
            clearSelectedToolIfUsedUp()
        }
    }

    private func triggerLight(at position: CGPoint) {
        if viewModel.shineLight(at: position) {
            showLightFeedback()
            clearSelectedToolIfUsedUp()
        }
    }

    private func showLightFeedback() {
        withAnimation(.easeOut(duration: 0.12)) {
            isLightFlashing = true
            observationLog = String(localized: "光に反応して散った")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
            withAnimation(.easeOut(duration: 0.28)) {
                isLightFlashing = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            withAnimation(.easeOut(duration: 0.25)) {
                observationLog = nil
            }
        }
    }

    private func handleArenaTap(_ position: CGPoint) {
        if isLayoutEditing {
            if let selectedStoredHideout {
                selectedPlacedHideoutID = nil
                if viewModel.placeStoredHideout(selectedStoredHideout, at: position) {
                    hasShownHideoutPlacementSlot = true
                    showLog(String(localized: "\(selectedStoredHideout.title)を置いた"))
                    if (viewModel.memory.hideoutInventory[selectedStoredHideout] ?? 0) == 0 {
                        self.selectedStoredHideout = nil
                    }
                } else {
                    showLog(String(localized: "ここは重なりすぎて置けない"))
                }
                return
            }

            if let selectedPlacedHideoutID {
                if viewModel.moveHideout(id: selectedPlacedHideoutID, to: position) {
                    showLog(String(localized: "隠れ家を移動した"))
                    self.selectedPlacedHideoutID = nil
                } else {
                    showLog(String(localized: "ここは重なりすぎて置けない"))
                }
                return
            }

            if let hideout = nearestHideout(to: position) {
                selectedStoredHideout = nil
                selectedPlacedHideoutID = hideout.id
                showLog(String(localized: "移動先をタップ。削除もできます"))
            } else {
                selectedPlacedHideoutID = nil
                showLog(String(localized: "移動する隠れ家をタップ"))
            }
            return
        }

        guard let selectedTool else {
            inspectRoach(near: position)
            return
        }
        guard viewModel.colony.remainingCareUses(for: selectedTool) > 0 else { return }

        switch selectedTool {
        case .food:
            if viewModel.placeFood(at: position) {
                showLog(String(localized: "餌を置いた"))
                clearSelectedToolIfUsedUp()
            }
        case .water:
            if viewModel.addWater(at: position) {
                showLog(String(localized: "水たまりを作った"))
                clearSelectedToolIfUsedUp()
            }
        case .light:
            lightPoint = position
            triggerLight(at: position)
        }
    }

    private func clearSelectedToolIfUsedUp() {
        guard let selectedTool, viewModel.colony.remainingCareUses(for: selectedTool) == 0 else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
            self.selectedTool = nil
        }
    }

    private func inspectRoach(near position: CGPoint) {
        guard let roach = nearestRoach(to: position) else {
            showLog(String(localized: "ゴキブリをタップで詳細を表示"))
            return
        }
        inspectedRoach = roach
    }

    private func nearestRoach(to position: CGPoint) -> Roach? {
        viewModel.colony.roaches
            .map { roach in
                (roach: roach, distance: roach.position.distance(to: position))
            }
            .filter { item in
                item.distance <= max(34, item.roach.size * 0.78)
            }
            .min { $0.distance < $1.distance }?
            .roach
    }

    private var selectedPlacedHideout: Hideout? {
        guard let selectedPlacedHideoutID else { return nil }
        return viewModel.colony.hides.first { $0.id == selectedPlacedHideoutID }
    }

    private func nearestHideout(to position: CGPoint) -> Hideout? {
        viewModel.colony.hides
            .map { hide in
                let hitRadius = max(34, max(hide.size.width, hide.size.height) * 0.45)
                return (hide: hide, distance: hide.position.distance(to: position), hitRadius: hitRadius)
            }
            .filter { item in
                item.distance <= item.hitRadius
            }
            .min { $0.distance < $1.distance }?
            .hide
    }

    private func deleteSelectedHideout() {
        guard isLayoutEditing, let selectedPlacedHideoutID else { return }
        if viewModel.deleteHideout(id: selectedPlacedHideoutID) {
            self.selectedPlacedHideoutID = nil
            showLog(String(localized: "隠れ家を削除した"))
        }
    }

    private func beginLayoutEditing() {
        selectedTool = nil
        inspectedRoach = nil
        selectedStoredHideout = nil
        selectedPlacedHideoutID = nil
        withAnimation(.spring(response: 0.26, dampingFraction: 0.82)) {
            isLayoutEditing = true
        }
        showLog(String(localized: "隠れ家をタップして移動・削除"))
    }

    private func finishLayoutEditing() {
        selectedStoredHideout = nil
        selectedPlacedHideoutID = nil
        withAnimation(.spring(response: 0.24, dampingFraction: 0.84)) {
            isLayoutEditing = false
        }
    }

    private func showLog(_ text: String) {
        withAnimation(.easeOut(duration: 0.16)) {
            observationLog = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
            withAnimation(.easeOut(duration: 0.25)) {
                observationLog = nil
            }
        }
    }

    private func nextZoomLevel(after currentZoom: CGFloat) -> CGFloat {
        normalizedZoomLevel(after: currentZoom, direction: 1)
    }

    private func previousZoomLevel(before currentZoom: CGFloat) -> CGFloat {
        normalizedZoomLevel(after: currentZoom, direction: -1)
    }

    private func normalizedZoomLevel(after currentZoom: CGFloat, direction: Int) -> CGFloat {
        let currentIndex = zoomLevels.enumerated().min { first, second in
            abs(first.element - currentZoom) < abs(second.element - currentZoom)
        }?.offset ?? 1
        let nextIndex = min(max(currentIndex + direction, 0), zoomLevels.count - 1)
        return zoomLevels[nextIndex]
    }

    private func prepareShareSnapshot() {
        let snapshotSize = viewModel.arenaSize.width > 20 && viewModel.arenaSize.height > 20
            ? viewModel.arenaSize
            : CGSize(width: 390, height: 620)
        let room = ColonyRoomSnapshotView(colony: viewModel.colony, roomSkin: viewModel.memory.activeRoomSkin)
            .frame(width: snapshotSize.width, height: snapshotSize.height)
        let renderer = ImageRenderer(content: room)
        renderer.scale = 3

        guard let image = renderer.uiImage,
              let data = image.pngData()
        else {
            showLog(String(localized: "共有画像を作れませんでした"))
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("sukima-no-su-\(UUID().uuidString).png")
        do {
            try data.write(to: url)
            shareImage = image
            shareURL = url
            isShareSheetPresented = true
        } catch {
            showLog(String(localized: "共有画像を保存できませんでした"))
        }
    }
}

private struct DailyTicketRewardOverlay: View {
    let ticketCount: Int
    let onCollect: () -> Void

    @State private var isPresented = false

    var body: some View {
        ZStack {
            Color.black.opacity(isPresented ? 0.82 : 0)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("DAILY BONUS")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .tracking(3.4)
                    .foregroundStyle(Color(red: 0.78, green: 0.94, blue: 0.42))

                ZStack {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color(red: 1.0, green: 0.84, blue: 0.26).opacity(0.30 - Double(index) * 0.07), lineWidth: 2)
                            .frame(width: CGFloat(118 + index * 42), height: CGFloat(118 + index * 42))
                            .scaleEffect(isPresented ? 1 : 0.54)
                    }

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(red: 1.0, green: 0.86, blue: 0.28).opacity(0.82), .clear],
                                center: .center,
                                startRadius: 4,
                                endRadius: 82
                            )
                        )
                        .frame(width: 170, height: 170)

                    Image(systemName: "ticket.fill")
                        .font(.system(size: 76, weight: .black))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            Color(red: 0.15, green: 0.13, blue: 0.08),
                            Color(red: 1.0, green: 0.86, blue: 0.30)
                        )
                        .rotationEffect(.degrees(isPresented ? -8 : -34))
                        .scaleEffect(isPresented ? 1 : 0.24)
                        .shadow(color: Color(red: 1.0, green: 0.72, blue: 0.16).opacity(0.76), radius: 24)
                }
                .frame(height: 190)

                VStack(spacing: 7) {
                    Text(String(localized: "Gガチャチケット +1"))
                        .font(.system(size: 27, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(String(localized: "毎日のログインで1枚受け取れます"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.66))
                }

                HStack(spacing: 7) {
                    Image(systemName: "ticket.fill")
                    Text(String(localized: "所持 \(ticketCount)枚"))
                }
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.09))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(red: 0.94, green: 0.90, blue: 0.64), in: Capsule())

                Button {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    withAnimation(.easeOut(duration: 0.24)) { onCollect() }
                } label: {
                    Text(String(localized: "受け取る"))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.14, green: 0.12, blue: 0.08))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.80, blue: 0.22), Color(red: 0.70, green: 0.94, blue: 0.40)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                }
                .buttonStyle(UtilityBarButtonStyle())
            }
            .padding(24)
            .frame(maxWidth: 360)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.20, green: 0.17, blue: 0.11), Color(red: 0.07, green: 0.065, blue: 0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 30)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(red: 1.0, green: 0.84, blue: 0.30).opacity(0.54), lineWidth: 1.4)
            }
            .padding(20)
            .scaleEffect(isPresented ? 1 : 0.78)
            .opacity(isPresented ? 1 : 0)
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.58, dampingFraction: 0.70)) {
                isPresented = true
            }
        }
    }
}

private struct GachaSheet: View {
    let memory: ColonyMemory
    let onDraw: (Int) -> [GachaReward]?
    @ObservedObject var rewardedAdManager: RewardedAdManager
    let onRewardedTicketEarned: () -> Void
    let onSelectRoomSkin: (RoomSkin) -> Void

    @State private var results: [GachaReward] = []
    @State private var queuedReward: GachaReward?
    @State private var isDrawing = false
    @State private var selectedTab: GachaTab = .draw
    @State private var drawPhase: GachaDrawPhase = .idle
    @State private var showsRewardedAdDisclosure = false
    @State private var rewardedAdStatusMessage: String?
    @State private var showsRewardedTicketSuccess = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    gachaHeader
                    tabSelector

                    switch selectedTab {
                    case .draw:
                        gachaMachine
                        drawButtons
                        rewardedTicketButton
                        if let rewardedAdStatusMessage {
                            Text(rewardedAdStatusMessage)
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(Color(red: 0.96, green: 0.82, blue: 0.36))
                                .frame(maxWidth: .infinity)
                                .transition(.opacity)
                        }
                        if results.count == 1, let result = results.first {
                            GachaResultCard(reward: result)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.72).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        } else if results.count == 10 {
                            GachaTenResultGrid(rewards: results)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.82).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                        catalogPreview
                    case .collection:
                        collectionView
                    case .history:
                        historyView
                    }
                }
                .padding(18)
            }

            if showsRewardedAdDisclosure {
                RewardedAdDisclosureOverlay(
                    action: .gachaTicket,
                    onConfirm: {
                        RewardedAdDisclosureStore.acknowledge()
                        showsRewardedAdDisclosure = false
                        DispatchQueue.main.async {
                            showRewardedTicketAd()
                        }
                    },
                    onCancel: {
                        RewardedAdDisclosureStore.acknowledge()
                        showsRewardedAdDisclosure = false
                    }
                )
                .zIndex(10)
            }

            if showsRewardedTicketSuccess {
                RewardedAdSuccessOverlay(
                    action: .gachaTicket,
                    onDismiss: { showsRewardedTicketSuccess = false }
                )
                .transition(.opacity)
                .zIndex(20)
            }
        }
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.21, green: 0.18, blue: 0.13),
                        Color(red: 0.08, green: 0.07, blue: 0.055)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Circle()
                    .fill(Color(red: 0.90, green: 0.72, blue: 0.22).opacity(0.18))
                    .frame(width: 260, height: 260)
                    .blur(radius: 38)
                    .offset(x: 140, y: -190)
            }
        )
        .interactiveDismissDisabled(isDrawing)
    }

    private var gachaHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "Gガチャ"))
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(String(localized: "この部屋の運命を、1回でひっくり返せ。"))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.76))
            }
            Spacer()
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "ticket.fill")
                        .font(.system(size: 13, weight: .black))
                    Text("\(memory.gachaTickets)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                }
                Text("TICKETS")
                    .font(.system(size: 9, weight: .black, design: .rounded))
            }
            .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.10))
            .frame(width: 68, height: 58)
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.92, blue: 0.48), Color(red: 0.70, green: 0.92, blue: 0.44)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(0.62), lineWidth: 1)
            }
        }
    }

    private var tabSelector: some View {
        HStack(spacing: 7) {
            ForEach(GachaTab.allCases, id: \.self) { tab in
                Button {
                    guard !isDrawing else { return }
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.78)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.title)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(selectedTab == tab ? Color(red: 0.12, green: 0.10, blue: 0.07) : .white.opacity(0.72))
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(
                            selectedTab == tab
                                ? Color(red: 0.94, green: 0.88, blue: 0.58)
                                : Color.white.opacity(0.08),
                            in: RoundedRectangle(cornerRadius: 17)
                        )
                }
                .buttonStyle(UtilityBarButtonStyle())
                .disabled(isDrawing)
            }
        }
        .padding(5)
        .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 22))
    }

    private var drawButtons: some View {
        HStack(spacing: 9) {
            drawButton(count: 1, title: String(localized: "1連"))
            drawButton(count: 10, title: String(localized: "10連"))
        }
    }

    private var rewardedTicketButton: some View {
        Button {
            guard !isDrawing else { return }
            if RewardedAdDisclosureStore.hasAcknowledged {
                showRewardedTicketAd()
            } else {
                showsRewardedAdDisclosure = true
            }
        } label: {
            HStack(spacing: 9) {
                Image(systemName: rewardedAdManager.isReady ? "play.rectangle.fill" : "arrow.clockwise")
                    .font(.system(size: 16, weight: .black))
                VStack(alignment: .leading, spacing: 2) {
                    Text(rewardedAdManager.isReady ? String(localized: "広告でチケット1枚") : String(localized: "広告を準備中"))
                        .font(.system(size: 15, weight: .black, design: .rounded))
                    Text(String(localized: "動画視聴後にGガチャチケットを受け取れます"))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .opacity(0.72)
                }
                Spacer()
                Image(systemName: "ticket.fill")
                    .font(.system(size: 18, weight: .black))
            }
            .foregroundStyle(Color(red: 0.13, green: 0.11, blue: 0.08))
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: rewardedAdManager.isReady
                        ? [Color(red: 0.95, green: 0.88, blue: 0.44), Color(red: 0.56, green: 0.86, blue: 0.50)]
                        : [Color(red: 0.82, green: 0.72, blue: 0.30), Color(red: 0.44, green: 0.62, blue: 0.34)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(rewardedAdManager.isReady ? 0.54 : 0.32), lineWidth: 1)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .disabled(isDrawing || rewardedAdManager.isShowing)
        .buttonStyle(UtilityBarButtonStyle())
    }

    private func showRewardedTicketAd() {
        rewardedAdStatusMessage = nil
        rewardedAdManager.showAd {
            onRewardedTicketEarned()
            withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                showsRewardedTicketSuccess = true
            }
        }
    }

    private func drawButton(count: Int, title: String) -> some View {
        let canDraw = memory.canAffordGacha(count: count)
        let cost = memory.gachaCost(for: count)
        return Button { performDraw(count: count) } label: {
            VStack(spacing: 3) {
                HStack(spacing: 5) {
                    Image(systemName: isDrawing ? "hourglass" : (count == 10 ? "sparkles.rectangle.stack.fill" : "sparkles"))
                    Text(isDrawing ? String(localized: "抽選中") : title)
                }
                .font(.system(size: 16, weight: .black, design: .rounded))

                if cost == 0 {
                    Text(String(localized: "初回無料"))
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .opacity(0.74)
                } else {
                    HStack(spacing: 3) {
                        Image(systemName: "ticket.fill")
                        Text(String(localized: "\(cost)枚"))
                    }
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .opacity(0.74)
                }
            }
            .foregroundStyle(Color(red: 0.14, green: 0.13, blue: 0.09))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                LinearGradient(
                    colors: canDraw
                        ? (count == 10
                            ? [Color(red: 0.92, green: 0.60, blue: 1.0), Color(red: 1.0, green: 0.78, blue: 0.22)]
                            : [Color(red: 1.0, green: 0.82, blue: 0.26), Color(red: 0.72, green: 0.92, blue: 0.44)])
                        : [Color(red: 0.64, green: 0.65, blue: 0.59), Color(red: 0.44, green: 0.47, blue: 0.42)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(canDraw ? 0.62 : 0.24), lineWidth: 1)
            }
        }
        .disabled(!canDraw || isDrawing)
        .buttonStyle(UtilityBarButtonStyle())
    }

    private var catalogPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "狙えるラインナップ"))
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(String(localized: "同じレア度は、カテゴリ内で同じ確率。"))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.58))

            GachaCatalogSection(
                title: String(localized: "隠れ家"),
                systemImage: "shippingbox.fill",
                items: GachaCatalog.items.filter { $0.category == .hideout }
            )
            GachaCatalogSection(
                title: String(localized: "ゴキブリ個体"),
                systemImage: "ant.fill",
                items: GachaCatalog.items.filter { $0.category == .rareRoach }
            )
            GachaCatalogSection(
                title: String(localized: "部屋スキン"),
                systemImage: "rectangle.3.group.fill",
                items: GachaCatalog.items.filter { $0.category == .roomSkin }
            )
        }
    }

    private var collectionView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "部屋スキン"))
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(String(localized: "当たったスキンはここから切り替え。共有スクショにも反映されます。"))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(RoomSkin.allCases, id: \.self) { skin in
                    let isUnlocked = memory.unlockedRoomSkins.contains(skin)
                    Button {
                        guard isUnlocked else { return }
                        onSelectRoomSkin(skin)
                    } label: {
                        RoomSkinCard(
                            skin: skin,
                            isUnlocked: isUnlocked,
                            isActive: memory.activeRoomSkin == skin
                        )
                    }
                    .disabled(!isUnlocked)
                    .buttonStyle(UtilityBarButtonStyle())
                }
            }

        }
    }

    private var historyView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "最近の結果"))
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            if memory.gachaHistory.isEmpty {
                Text(String(localized: "まだ結果はありません。今日の1回を引くとここに残ります。"))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.70))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
            } else {
                ForEach(memory.gachaHistory.suffix(12).reversed()) { reward in
                    GachaHistoryRow(reward: reward)
                }
            }
        }
    }

    private var gachaMachine: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    RadialGradient(
                        colors: [
                            machineTint.opacity(isDrawing ? 0.68 : 0.30),
                            Color(red: 0.23, green: 0.18, blue: 0.11),
                            Color.black.opacity(0.50)
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 190
                    )
                )

            GachaSparkField(
                isActive: isDrawing || drawPhase == .revealed,
                tint: machineTint,
                rarity: queuedReward?.rarity ?? .normal,
                phase: drawPhase
            )

            if drawPhase == .revealed, let queuedReward {
                GachaRevealVisual(reward: queuedReward)
                    .transition(.scale(scale: 0.18).combined(with: .opacity))
            } else {
                VStack(spacing: 9) {
                    GachaCapsuleCore(
                        phase: drawPhase,
                        tint: machineTint,
                        rarity: queuedReward?.rarity ?? .normal
                    )

                    Text(machineStatusTitle)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(machineStatusDetail)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.66))
                }
            }

            if drawPhase == .blackout {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.black.opacity(0.94))
                    .overlay {
                        Text("……")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .tracking(8)
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    .transition(.opacity)
                    .allowsHitTesting(false)
            } else if drawPhase == .flash {
                RoundedRectangle(cornerRadius: 24)
                    .fill(flashColor)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: 224)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(red: 1.0, green: 0.84, blue: 0.32).opacity(0.32), lineWidth: 1.4)
        }
        .animation(.spring(response: 0.24, dampingFraction: 0.68), value: isDrawing)
        .animation(.spring(response: 0.36, dampingFraction: 0.66), value: drawPhase)
    }

    private var machineTint: Color {
        guard drawPhase == .omen || drawPhase == .blackout || drawPhase == .flash || drawPhase == .revealed else {
            return Color(red: 1.0, green: 0.84, blue: 0.30)
        }
        return queuedReward?.rarity.tint ?? Color(red: 1.0, green: 0.84, blue: 0.30)
    }

    private var flashColor: Color {
        guard let rarity = queuedReward?.rarity else { return .white }
        switch rarity {
        case .normal: return rarity.tint.opacity(0.84)
        case .rare: return Color.white.opacity(0.94)
        case .superRare: return rarity.tint.opacity(0.96)
        case .legend: return Color(red: 1.0, green: 0.90, blue: 0.42)
        }
    }

    private var machineStatusTitle: String {
        switch drawPhase {
        case .idle: return String(localized: "何が出るかは、開くまで分からない")
        case .charging: return String(localized: "気配が集まっている")
        case .shaking: return String(localized: "中で何かが暴れている")
        case .omen: return omenTitle
        case .blackout: return ""
        case .flash: return String(localized: "解放")
        case .revealed: return ""
        }
    }

    private var machineStatusDetail: String {
        drawPhase == .idle ? String(localized: "隠れ家・個体・部屋スキン") : String(localized: "画面から目を離すな")
    }

    private var omenTitle: String {
        switch queuedReward?.rarity {
        case .normal, .none: return String(localized: "殻が開きはじめた")
        case .rare: return String(localized: "青い光が漏れている")
        case .superRare: return String(localized: "空気が歪んでいる")
        case .legend: return String(localized: "この気配は、普通じゃない")
        }
    }

    private func performDraw(count: Int) {
        performDraw(count: count, using: onDraw)
    }

    private func performDraw(count: Int, using draw: (Int) -> [GachaReward]?) {
        guard !isDrawing, let drawnRewards = draw(count), !drawnRewards.isEmpty,
              let reward = drawnRewards.max(by: { $0.rarity.rank < $1.rarity.rank }) else { return }
        queuedReward = reward
        results = []
        isDrawing = true

        let choreography = GachaChoreography(rarity: reward.rarity)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.easeInOut(duration: 0.28)) { drawPhase = .charging }

        DispatchQueue.main.asyncAfter(deadline: .now() + choreography.shakeAt) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.20, dampingFraction: 0.38)) { drawPhase = .shaking }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + choreography.omenAt) {
            UIImpactFeedbackGenerator(style: reward.rarity.impactStyle).impactOccurred(intensity: reward.rarity.impactIntensity)
            withAnimation(.easeInOut(duration: 0.20)) { drawPhase = .omen }
        }
        if let blackoutAt = choreography.blackoutAt {
            DispatchQueue.main.asyncAfter(deadline: .now() + blackoutAt) {
                withAnimation(.easeOut(duration: 0.16)) { drawPhase = .blackout }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + choreography.flashAt) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 1)
            withAnimation(.easeOut(duration: 0.10)) { drawPhase = .flash }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + choreography.revealAt) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.48, dampingFraction: 0.64)) {
                drawPhase = .revealed
                results = drawnRewards
                isDrawing = false
            }
        }
    }
}

private enum GachaDrawPhase {
    case idle
    case charging
    case shaking
    case omen
    case blackout
    case flash
    case revealed
}

private struct GachaChoreography {
    let shakeAt: Double
    let omenAt: Double
    let blackoutAt: Double?
    let flashAt: Double
    let revealAt: Double

    init(rarity: GachaRarity) {
        switch rarity {
        case .normal:
            (shakeAt, omenAt, blackoutAt, flashAt, revealAt) = (0.28, 0.72, nil, 1.02, 1.28)
        case .rare:
            (shakeAt, omenAt, blackoutAt, flashAt, revealAt) = (0.34, 0.90, nil, 1.36, 1.68)
        case .superRare:
            (shakeAt, omenAt, blackoutAt, flashAt, revealAt) = (0.38, 1.02, 1.58, 1.88, 2.20)
        case .legend:
            (shakeAt, omenAt, blackoutAt, flashAt, revealAt) = (0.42, 1.12, 1.92, 2.62, 3.02)
        }
    }
}

private enum GachaTab: CaseIterable {
    case draw
    case collection
    case history

    var title: String {
        switch self {
        case .draw:
            return String(localized: "引く")
        case .collection:
            return String(localized: "部屋")
        case .history:
            return String(localized: "履歴")
        }
    }
}

private struct GachaCatalogSection: View {
    let title: String
    let systemImage: String
    let items: [GachaCatalogItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 7) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .black))
                Text(title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                Spacer()
                Text(String(localized: "全\(items.count)種"))
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.54))
            }
            .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 7) {
                ForEach(items, id: \.title) { item in
                    GachaCatalogItemCard(item: item)
                }
            }
        }
        .padding(12)
        .background(.white.opacity(0.065), in: RoundedRectangle(cornerRadius: 19))
        .overlay {
            RoundedRectangle(cornerRadius: 19)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct GachaCatalogItemCard: View {
    let item: GachaCatalogItem

    var body: some View {
        HStack(spacing: 8) {
            catalogVisual
                .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.rarity.title)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(item.rarity.tint)
                Text(displayTitle)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .frame(height: 52)
        .background(
            LinearGradient(
                colors: [item.rarity.tint.opacity(0.16), Color.black.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay(alignment: .leading) {
            Capsule()
                .fill(item.rarity.tint)
                .frame(width: 3, height: 28)
                .padding(.leading, 3)
        }
    }

    @ViewBuilder
    private var catalogVisual: some View {
        if let variant = item.roachVariant {
            Image(variant.roachPortraitAssetName)
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(14))
                .shadow(color: item.rarity.tint.opacity(0.45), radius: 4)
        } else if let kind = item.hideoutKind {
            Image(kind.assetName)
                .resizable()
                .scaledToFit()
                .shadow(color: .black.opacity(0.30), radius: 3, y: 2)
        } else if let skin = item.roomSkin {
            RoundedRectangle(cornerRadius: 9)
                .fill(LinearGradient(colors: skin.previewColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay {
                    Image(systemName: "rectangle.3.group.fill")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(.white.opacity(0.72))
                }
        }
    }

    private var displayTitle: String {
        item.roachVariant?.title ?? item.title
    }
}

private struct GachaSparkField: View {
    let isActive: Bool
    let tint: Color
    let rarity: GachaRarity
    let phase: GachaDrawPhase

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let wave = CGFloat((time * rarity.waveSpeed).truncatingRemainder(dividingBy: 1))
            ZStack {
                if isActive, rarity == .superRare || rarity == .legend {
                    ForEach(0..<(rarity == .legend ? 3 : 2), id: \.self) { index in
                        let localWave = (wave + CGFloat(index) * 0.34).truncatingRemainder(dividingBy: 1)
                        Circle()
                            .stroke(tint.opacity(Double(1 - localWave) * 0.46), lineWidth: rarity == .legend ? 3 : 2)
                            .frame(width: 92, height: 92)
                            .scaleEffect(0.72 + localWave * (rarity == .legend ? 1.28 : 0.92))
                    }
                }

                ForEach(0..<rarity.particleCount, id: \.self) { index in
                    let angle = Double(index) * (.pi * 2 / Double(rarity.particleCount)) + time * (index.isMultiple(of: 2) ? rarity.particleSpeed : -rarity.particleSpeed * 0.72)
                    let radius = CGFloat(54 + (index % 5) * 17)
                    Image(systemName: index.isMultiple(of: 3) ? "sparkle" : "circle.fill")
                        .font(.system(size: index.isMultiple(of: 3) ? rarity.sparkSize : 4, weight: .black))
                        .foregroundStyle(tint.opacity(isActive ? rarity.particleOpacity : 0.14))
                        .offset(x: CGFloat(cos(angle)) * radius, y: CGFloat(sin(angle)) * radius * 0.62)
                        .scaleEffect(isActive ? (phase == .omen ? 1.24 : 1) : 0.56)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct GachaCapsuleCore: View {
    let phase: GachaDrawPhase
    let tint: Color
    let rarity: GachaRarity

    var body: some View {
        TimelineView(.animation(minimumInterval: phase == .idle ? 1 : 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let isActive = phase == .charging || phase == .shaking || phase == .omen
            let shake = phase == .shaking
                ? sin(time * rarity.shakeFrequency) * rarity.shakeAmplitude
                : (phase == .charging ? sin(time * 8) * 2.5 : 0)
            let pulse: Double = {
                switch phase {
                case .charging: return 1.10 + sin(time * 7) * 0.05
                case .shaking: return 1.05 + sin(time * 13) * rarity.pulseAmplitude
                case .omen: return 1.12 + sin(time * rarity.omenPulseFrequency) * rarity.omenPulseAmplitude
                default: return 1
                }
            }()

            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(tint.opacity(0.32 - Double(index) * 0.07), lineWidth: 2)
                        .frame(width: CGFloat(70 + index * 30), height: CGFloat(70 + index * 30))
                        .scaleEffect(isActive ? 1.12 + CGFloat(index) * 0.025 : 0.92)
                }

                Image("Ootheca")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(shake))
                    .scaleEffect(CGFloat(pulse))
                    .offset(x: phase == .shaking ? CGFloat(sin(time * 53)) * rarity.horizontalShake : 0)
                    .shadow(color: tint.opacity(0.76), radius: isActive ? rarity.glowRadius : 8)
            }
        }
        .frame(height: 132)
    }
}

private struct GachaRevealVisual: View {
    let reward: GachaReward

    var body: some View {
        VStack(spacing: 7) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(reward.rarity.tint.opacity(0.20))
                    .frame(width: 142, height: 142)
                    .blur(radius: 2)

                if let variant = reward.roachVariant {
                    Image(variant.roachPortraitAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 132, height: 132)
                        .rotationEffect(.degrees(14))
                        .shadow(color: reward.rarity.tint.opacity(0.72), radius: 18)

                    if let eggAsset = variant.eggAssetName {
                        Image(eggAsset)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 46, height: 46)
                            .padding(5)
                            .background(.black.opacity(0.68), in: Circle())
                            .overlay { Circle().stroke(reward.rarity.tint.opacity(0.72), lineWidth: 1.4) }
                    }
                } else {
                    GachaRewardVisual(reward: reward, size: 132, iconSize: 44)
                        .shadow(color: reward.rarity.tint.opacity(0.68), radius: 18)
                }
            }

            Text(reward.roachVariant?.title ?? reward.localizedTitle)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.68), radius: 5, y: 2)
            Text(reward.rarity.title.uppercased())
                .font(.system(size: 10, weight: .black, design: .rounded))
                .tracking(2.2)
                .foregroundStyle(reward.rarity.tint)
        }
    }
}

private struct GachaResultCard: View {
    let reward: GachaReward

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(reward.rarity.title)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(reward.rarity.tint, in: Capsule())
                Spacer()
                Text(reward.category.title)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.42, green: 0.36, blue: 0.22))
            }

            HStack(spacing: 13) {
                GachaRewardVisual(reward: reward, size: 64, iconSize: 28)

                VStack(alignment: .leading, spacing: 5) {
                    Text(reward.localizedTitle)
                        .font(.system(size: 23, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.14, green: 0.13, blue: 0.09))
                    Text(reward.localizedDetail)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.43, green: 0.38, blue: 0.28))
                }
            }

        }
        .padding(15)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.96, blue: 0.76),
                    reward.rarity.tint.opacity(0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(reward.rarity.tint.opacity(0.45), lineWidth: 1.4)
        }
    }

    private var iconName: String {
        switch reward.category {
        case .rareRoach:
            return "ant.fill"
        case .roomSkin:
            return "rectangle.3.group.fill"
        case .hideout:
            return "shippingbox.fill"
        }
    }
}

private struct GachaTenResultGrid: View {
    let rewards: [GachaReward]

    private var highestRarity: GachaRarity {
        rewards.max(by: { $0.rarity.rank < $1.rarity.rank })?.rarity ?? .normal
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "10連結果"))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                    Text(String(localized: "10個をまとめて獲得"))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.43, green: 0.38, blue: 0.28))
                }
                Spacer()
                Text(String(localized: "最高 \(highestRarity.title)"))
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(highestRarity.tint, in: Capsule())
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 5), spacing: 7) {
                ForEach(Array(rewards.enumerated()), id: \.offset) { _, reward in
                    VStack(spacing: 3) {
                        GachaRewardVisual(reward: reward, size: 42, iconSize: 17)
                        Text(reward.roachVariant?.title ?? reward.localizedTitle)
                            .font(.system(size: 8, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 0.17, green: 0.15, blue: 0.10))
                            .lineLimit(1)
                            .minimumScaleFactor(0.55)
                        Capsule()
                            .fill(reward.rarity.tint)
                            .frame(width: 18, height: 3)
                    }
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.42), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .foregroundStyle(Color(red: 0.14, green: 0.13, blue: 0.09))
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.96, blue: 0.76), highestRarity.tint.opacity(0.30)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(highestRarity.tint.opacity(0.52), lineWidth: 1.4)
        }
    }
}

private struct RoomSkinCard: View {
    let skin: RoomSkin
    let isUnlocked: Bool
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: isUnlocked ? skin.previewColors : [Color.gray.opacity(0.32), Color.black.opacity(0.28)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.black.opacity(isUnlocked ? 0.16 : 0.08))
                        .frame(width: CGFloat(48 + index * 12), height: 12)
                        .rotationEffect(.degrees(Double(index * 17 - 18)))
                        .offset(x: CGFloat(10 + index * 22), y: CGFloat(-12 - index * 7))
                }

                Text(isActive ? String(localized: "使用中") : (isUnlocked ? String(localized: "変更する") : String(localized: "未発見")))
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(isUnlocked ? Color(red: 0.15, green: 0.13, blue: 0.09) : .white.opacity(0.82))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(isUnlocked ? Color(red: 0.95, green: 0.88, blue: 0.48) : Color.black.opacity(0.34), in: Capsule())
                    .padding(8)
            }
            .frame(height: 74)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(skin.title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(isUnlocked ? .white : .white.opacity(0.42))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(9)
        .background(isActive ? Color.white.opacity(0.15) : Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(isActive ? Color(red: 0.98, green: 0.83, blue: 0.32) : .white.opacity(isUnlocked ? 0.16 : 0.06), lineWidth: isActive ? 1.6 : 1)
        }
        .opacity(isUnlocked ? 1 : 0.62)
    }
}

private struct GachaHistoryRow: View {
    let reward: GachaReward

    var body: some View {
        HStack(spacing: 10) {
            GachaRewardVisual(reward: reward, size: 38, iconSize: 15)

            VStack(alignment: .leading, spacing: 3) {
                Text(reward.localizedTitle)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                Text("\(reward.category.title) / \(reward.rarity.title)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.48, green: 0.42, blue: 0.31))
            }
            Spacer()
        }
        .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.10))
        .padding(11)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 15))
    }

    private var iconName: String {
        switch reward.category {
        case .rareRoach:
            return "ant.fill"
        case .roomSkin:
            return "rectangle.3.group.fill"
        case .hideout:
            return "shippingbox.fill"
        }
    }
}

private struct GachaRewardVisual: View {
    let reward: GachaReward
    let size: CGFloat
    let iconSize: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(reward.rarity.tint.opacity(reward.hideoutKind == nil ? 0.20 : 0.16))

            if let hideoutKind = reward.hideoutKind {
                Image(hideoutKind.assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.12)
                    .saturation(0.96)
                    .brightness(-0.03)
                    .shadow(color: .black.opacity(0.24), radius: size * 0.06, x: 0, y: size * 0.035)
            } else if let eggAssetName = reward.roachVariant?.eggAssetName {
                Image(eggAssetName)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.13)
                    .rotationEffect(.degrees(-12))
                    .shadow(color: .black.opacity(0.24), radius: size * 0.06, x: 0, y: size * 0.035)
            } else if let roomSkin = reward.roomSkin {
                RoundedRectangle(cornerRadius: size * 0.20)
                    .fill(LinearGradient(colors: roomSkin.previewColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .padding(size * 0.08)
                    .overlay {
                        Image(systemName: "rectangle.3.group.fill")
                            .font(.system(size: iconSize, weight: .black))
                            .foregroundStyle(.white.opacity(0.74))
                    }
                    .shadow(color: .black.opacity(0.24), radius: size * 0.06, x: 0, y: size * 0.035)
            } else {
                Image(systemName: iconName)
                    .font(.system(size: iconSize, weight: .black))
                    .foregroundStyle(reward.rarity.tint)
            }
        }
        .frame(width: size, height: size)
    }

    private var iconName: String {
        switch reward.category {
        case .rareRoach:
            return "ant.fill"
        case .roomSkin:
            return "rectangle.3.group.fill"
        case .hideout:
            return "shippingbox.fill"
        }
    }
}

private extension GachaRarity {
    var tint: Color {
        switch self {
        case .normal:
            return Color(red: 0.48, green: 0.54, blue: 0.46)
        case .rare:
            return Color(red: 0.22, green: 0.55, blue: 0.82)
        case .superRare:
            return Color(red: 0.78, green: 0.34, blue: 0.86)
        case .legend:
            return Color(red: 1.0, green: 0.66, blue: 0.12)
        }
    }

    var particleCount: Int {
        switch self {
        case .normal: return 8
        case .rare: return 14
        case .superRare: return 22
        case .legend: return 30
        }
    }

    var particleSpeed: Double {
        switch self {
        case .normal: return 0.46
        case .rare: return 0.72
        case .superRare: return 1.02
        case .legend: return 1.34
        }
    }

    var particleOpacity: Double {
        switch self {
        case .normal: return 0.48
        case .rare: return 0.68
        case .superRare: return 0.82
        case .legend: return 0.96
        }
    }

    var sparkSize: CGFloat {
        switch self {
        case .normal: return 8
        case .rare: return 10
        case .superRare: return 12
        case .legend: return 15
        }
    }

    var waveSpeed: Double {
        switch self {
        case .normal: return 0.45
        case .rare: return 0.62
        case .superRare: return 0.88
        case .legend: return 1.16
        }
    }

    var shakeAmplitude: Double {
        switch self {
        case .normal: return 6
        case .rare: return 8
        case .superRare: return 11
        case .legend: return 14
        }
    }

    var shakeFrequency: Double {
        switch self {
        case .normal: return 38
        case .rare: return 46
        case .superRare: return 54
        case .legend: return 62
        }
    }

    var horizontalShake: CGFloat {
        switch self {
        case .normal: return 2
        case .rare: return 4
        case .superRare: return 6
        case .legend: return 8
        }
    }

    var pulseAmplitude: Double {
        switch self {
        case .normal: return 0.015
        case .rare: return 0.025
        case .superRare: return 0.040
        case .legend: return 0.055
        }
    }

    var omenPulseFrequency: Double {
        switch self {
        case .normal: return 5
        case .rare: return 7
        case .superRare: return 10
        case .legend: return 13
        }
    }

    var omenPulseAmplitude: Double {
        switch self {
        case .normal: return 0.025
        case .rare: return 0.045
        case .superRare: return 0.075
        case .legend: return 0.11
        }
    }

    var glowRadius: CGFloat {
        switch self {
        case .normal: return 14
        case .rare: return 20
        case .superRare: return 28
        case .legend: return 38
        }
    }

    var impactStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .normal: return .light
        case .rare: return .medium
        case .superRare, .legend: return .heavy
        }
    }

    var impactIntensity: CGFloat {
        switch self {
        case .normal: return 0.45
        case .rare: return 0.65
        case .superRare: return 0.82
        case .legend: return 1
        }
    }
}

private extension RoomSkin {
    var previewColors: [Color] {
        switch self {
        case .deskGap:
            return [Color(red: 0.22, green: 0.16, blue: 0.10), Color(red: 0.07, green: 0.05, blue: 0.035)]
        case .fridgeBottom:
            return [Color(red: 0.14, green: 0.19, blue: 0.18), Color(red: 0.04, green: 0.06, blue: 0.055)]
        case .kitchenShelf:
            return [Color(red: 0.30, green: 0.22, blue: 0.12), Color(red: 0.10, green: 0.07, blue: 0.045)]
        case .tatamiEdge:
            return [Color(red: 0.30, green: 0.28, blue: 0.17), Color(red: 0.10, green: 0.09, blue: 0.055)]
        case .cardboardNest:
            return [Color(red: 0.36, green: 0.25, blue: 0.13), Color(red: 0.13, green: 0.08, blue: 0.04)]
        }
    }
}

private struct NameRoachSheet: View {
    let colony: ColonyState
    let memory: ColonyMemory
    let onSave: (UUID, String) -> Void

    @State private var selectedRoachID: UUID?
    @State private var nameText = ""

    private var lockedRoach: Roach? {
        colony.namedRoach
    }

    private var sortedRoaches: [Roach] {
        colony.roaches.sorted { first, second in
            if first.name != nil { return true }
            if second.name != nil { return false }
            return first.lengthCm > second.lengthCm
        }
    }

    private var canSave: Bool {
        guard let selectedRoachID else { return false }
        if let lockedRoach, lockedRoach.id != selectedRoachID {
            return false
        }
        return !nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(lockedRoach == nil ? String(localized: "推し個体を決める") : String(localized: "推し個体を追跡中"))
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(lockedRoach == nil ? String(localized: "名前を持てる個体は一匹だけ。成長と記録を追いかけます。") : String(localized: "この個体が死ぬまで、成長・食事・生存日数を記録します。"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if let lockedRoach {
                    FavoriteRoachTrackerCard(roach: lockedRoach, memory: memory)
                }

                TextField(String(localized: "名前を入力"), text: $nameText)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .foregroundStyle(Color(red: 0.12, green: 0.10, blue: 0.08))
                    .background(.white, in: RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 0.58, green: 0.48, blue: 0.28).opacity(0.30), lineWidth: 1.2)
                    }
                    .onChange(of: nameText) { _, value in
                        if value.count > 8 {
                            nameText = String(value.prefix(8))
                        }
                    }

                ScrollView {
                    LazyVStack(spacing: 9) {
                        ForEach(sortedRoaches) { roach in
                            let isLockedUnavailable = lockedRoach != nil && lockedRoach?.id != roach.id
                            Button {
                                guard !isLockedUnavailable else { return }
                                selectedRoachID = roach.id
                                if let name = roach.name {
                                    nameText = name
                                }
                            } label: {
                                RoachPickRow(
                                    roach: roach,
                                    isSelected: selectedRoachID == roach.id,
                                    isLockedUnavailable: isLockedUnavailable,
                                    statusText: roach.id == lockedRoach?.id ? String(localized: "現在の名前つき") : (isLockedUnavailable ? String(localized: "名前つきが生存中") : String(localized: "名前をつけられます"))
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(isLockedUnavailable)
                        }
                    }
                    .padding(.vertical, 2)
                }

                Button(lockedRoach == nil ? String(localized: "この個体に決める") : String(localized: "名前を更新")) {
                    guard let selectedRoachID else { return }
                    onSave(selectedRoachID, nameText)
                }
                .disabled(!canSave)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(canSave ? Color(red: 0.42, green: 0.62, blue: 0.28) : Color.gray, in: RoundedRectangle(cornerRadius: 15))
            }
            .padding(18)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.36, green: 0.33, blue: 0.24),
                        Color(red: 0.18, green: 0.16, blue: 0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .onAppear {
                selectedRoachID = colony.namedRoach?.id ?? sortedRoaches.first?.id
                nameText = colony.namedRoach?.name ?? ""
            }
        }
    }
}

private struct RoachPickRow: View {
    let roach: Roach
    let isSelected: Bool
    let isLockedUnavailable: Bool
    let statusText: String

    var body: some View {
        HStack(spacing: 10) {
            Image(roach.variant.roachPortraitAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
                .rotationEffect(.degrees(12))

            VStack(alignment: .leading, spacing: 3) {
                Text(roach.name ?? String(localized: "名なしの個体"))
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.10))
                Text("\(roach.sex == .male ? String(localized: "オス") : String(localized: "メス")) ・ \(roach.lengthCm.formatted(.number.precision(.fractionLength(1))))cm")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.44, green: 0.40, blue: 0.32))
                Text(statusText)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(isLockedUnavailable ? Color(red: 0.54, green: 0.52, blue: 0.47) : Color(red: 0.42, green: 0.62, blue: 0.28))
            }

            Spacer()

            Image(systemName: isLockedUnavailable ? "lock.fill" : (isSelected ? "checkmark.circle.fill" : "circle"))
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(isLockedUnavailable ? Color.gray.opacity(0.62) : (isSelected ? Color(red: 0.42, green: 0.62, blue: 0.28) : Color.gray.opacity(0.45)))
        }
        .padding(11)
        .background(isSelected ? Color(red: 1.0, green: 0.96, blue: 0.78) : .white.opacity(isLockedUnavailable ? 0.68 : 1), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color(red: 0.42, green: 0.62, blue: 0.28).opacity(0.85) : Color(red: 0.42, green: 0.35, blue: 0.22).opacity(0.12), lineWidth: 1.4)
        }
        .shadow(color: .black.opacity(isSelected ? 0.14 : 0.06), radius: isSelected ? 8 : 4, y: 3)
        .saturation(isLockedUnavailable ? 0.28 : 1)
    }
}

private struct FavoriteRoachTrackerCard: View {
    let roach: Roach
    let memory: ColonyMemory

    private var ageDays: Double {
        roach.age / (24 * 60 * 60)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 12) {
                Image(roach.variant.roachPortraitAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)
                    .rotationEffect(.degrees(16))
                    .padding(8)
                    .background(Color(red: 0.18, green: 0.14, blue: 0.10), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(roach.name ?? String(localized: "推し個体"))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.10))
                    Text(String(localized: "今日もすき間の奥で生存中"))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.45, green: 0.42, blue: 0.33))
                }

                Spacer()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                CompactRecordPill(title: String(localized: "生存"), value: String(localized: "\(ageDays.formatted(.number.precision(.fractionLength(1))))日"))
                CompactRecordPill(title: String(localized: "サイズ"), value: "\(roach.lengthCm.formatted(.number.precision(.fractionLength(1))))cm")
                CompactRecordPill(title: String(localized: "餌"), value: "\(Int(roach.foodEaten))")
                CompactRecordPill(title: String(localized: "水"), value: "\(Int(roach.waterDrunk))")
            }
        }
        .padding(13)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.72),
                    Color(red: 0.78, green: 0.88, blue: 0.60)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.58), lineWidth: 1)
        }
    }
}

private struct RoachGuideSheet: View {
    let colony: ColonyState
    let memory: ColonyMemory

    private var bestLength: Double {
        colony.bestRecordedLengthCm
    }

    private var actualSizePoints: CGFloat {
        min(132, max(14, CGFloat(bestLength) * 64))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(String(localized: "図鑑"))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 9) {
                    RecordStatCard(title: String(localized: "最大群れ"), value: String(localized: "\(max(memory.maxColonyCount, colony.totalCount))匹"))
                    RecordStatCard(title: String(localized: "卵鞘記録"), value: String(localized: "\(max(memory.maxEggCaseCount, colony.eggCases.count))個"))
                    RecordStatCard(title: String(localized: "最長生存"), value: String(localized: "\(memory.longestLivedDays.formatted(.number.precision(.fractionLength(1))))日"))
                    RecordStatCard(title: String(localized: "歴代最速"), value: String(localized: "\(fastestSpeed.formatted(.number.precision(.fractionLength(2))))倍"))
                }

                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(String(localized: "最大記録"))
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(Color(red: 0.39, green: 0.48, blue: 0.25))
                            Text("\(bestLength.formatted(.number.precision(.fractionLength(1))))cm")
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.10))
                        }

                        Spacer()

                        Text(colony.bestRecordedRoachSex == .male ? String(localized: "オス") : String(localized: "メス"))
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 0.42, green: 0.34, blue: 0.18))
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.45), in: Capsule())
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(red: 0.20, green: 0.17, blue: 0.12).opacity(0.94))
                            .overlay(alignment: .bottomLeading) {
                                RulerTicks()
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 13)
                            }

                        Image("RoachFrame01")
                            .resizable()
                            .scaledToFit()
                            .frame(width: actualSizePoints, height: actualSizePoints)
                            .rotationEffect(.degrees(18))
                            .shadow(color: .black.opacity(0.38), radius: 9, y: 5)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 172)
                }
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.96, blue: 0.78),
                            Color(red: 0.92, green: 0.86, blue: 0.64)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 22)
                )

            }
            .padding(18)
        }
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.13, green: 0.18, blue: 0.13),
                        Color(red: 0.045, green: 0.06, blue: 0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                ForEach(0..<7, id: \.self) { index in
                    Rectangle()
                        .fill(Color(red: 0.72, green: 0.86, blue: 0.48).opacity(0.08))
                        .frame(height: 1)
                        .offset(y: CGFloat(index * 42 - 118))
                }
                Circle()
                    .fill(Color(red: 0.58, green: 0.78, blue: 0.30).opacity(0.16))
                    .frame(width: 220, height: 220)
                    .blur(radius: 34)
                    .offset(x: 150, y: -180)
            }
        )
    }

    private var fastestSpeed: Double {
        max(memory.fastestRecordedSpeedMultiplier ?? 0, colony.roaches.map(\.speedMultiplier).max() ?? 0)
    }
}

private struct RoachStatusSheet: View {
    let roach: Roach

    private var ageDays: Double {
        roach.age / (24 * 60 * 60)
    }

    private var foodProgress: Double {
        min(1, roach.foodEaten / 260)
    }

    private var waterProgress: Double {
        min(1, roach.waterDrunk / 180)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.18, green: 0.15, blue: 0.10).opacity(0.92))
                            .frame(width: 88, height: 88)
                        Image(roach.variant.roachPortraitAssetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: min(76, max(36, roach.size * 1.16)), height: min(76, max(36, roach.size * 1.16)))
                            .rotationEffect(.degrees(16))
                            .opacity(roach.condition == .critical ? 0.60 : 0.96)
                            .saturation(roach.condition == .critical ? 0.35 : 1)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(roach.name ?? String(localized: "名なしの個体"))
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)

                        HStack(spacing: 6) {
                            StatusChip(text: roach.sex == .male ? String(localized: "オス") : String(localized: "メス"))
                            StatusChip(text: roach.stage == .adult ? String(localized: "成虫") : String(localized: "幼虫"))
                            StatusChip(text: conditionText)
                        }
                    }
                    .padding(.top, 3)
                }

                VStack(spacing: 10) {
                    StatusGauge(title: String(localized: "餌ゲージ"), value: foodProgress, detail: "\(Int(roach.foodEaten))", tint: Color(red: 0.96, green: 0.49, blue: 0.14))
                    StatusGauge(title: String(localized: "水ゲージ"), value: waterProgress, detail: "\(Int(roach.waterDrunk))", tint: Color(red: 0.10, green: 0.61, blue: 0.80))
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    StatusFact(title: String(localized: "生存"), value: String(localized: "\(ageDays.formatted(.number.precision(.fractionLength(1))))日"))
                    StatusFact(title: String(localized: "サイズ"), value: "\(roach.lengthCm.formatted(.number.precision(.fractionLength(1))))cm")
                    StatusFact(title: String(localized: "足の速さ"), value: String(localized: "\(roach.speedMultiplier.formatted(.number.precision(.fractionLength(2))))倍"))
                    StatusFact(title: String(localized: "成長"), value: roach.stage == .adult ? String(localized: "成虫") : "\(Int(roach.age / max(1, roach.matureDuration) * 100))%")
                    StatusFact(title: String(localized: "状態"), value: conditionText)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 26)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.36, green: 0.33, blue: 0.24),
                    Color(red: 0.18, green: 0.16, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var conditionText: String {
        switch roach.condition {
        case .healthy:
            return String(localized: "健康")
        case .critical:
            return String(localized: "瀕死")
        case .dead:
            return String(localized: "死亡")
        }
    }
}

private struct StatusChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(Color(red: 0.18, green: 0.16, blue: 0.12))
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Color(red: 1.0, green: 0.94, blue: 0.68), in: Capsule())
    }
}

private struct StatusGauge: View {
    let title: String
    let value: Double
    let detail: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(title)
                Spacer()
                Text(detail)
                    .monospacedDigit()
            }
            .font(.system(size: 12, weight: .black, design: .rounded))
            .foregroundStyle(Color(red: 0.18, green: 0.16, blue: 0.12))

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.10))
                    Capsule()
                        .fill(tint)
                        .frame(width: proxy.size.width * min(1, max(0, value)))
                }
            }
            .frame(height: 9)
        }
        .padding(13)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct StatusFact: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.48, green: 0.48, blue: 0.38))
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.10))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct CompactRecordPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.48, green: 0.47, blue: 0.36))
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.10))
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 13))
    }
}

private struct RecordStatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.90, green: 0.84, blue: 0.60))
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(Color.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.94, green: 0.84, blue: 0.48).opacity(0.24), lineWidth: 1)
        }
    }
}

private struct ObservationJournalSheet: View {
    let memory: ColonyMemory
    let onEnableNotifications: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(String(localized: "観察日記"))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(String(localized: "世話、繁殖、成長記録が自動で残ります。"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.74))
                }

                Button(action: onEnableNotifications) {
                    HStack(spacing: 10) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 15, weight: .black))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "毎日21時に世話通知"))
                                .font(.system(size: 14, weight: .black, design: .rounded))
                            Text(String(localized: "餌をあげるタイミングをバナーで知らせます"))
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        Spacer()
                    }
                    .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.10))
                    .padding(13)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.93, blue: 0.62),
                                Color(red: 0.74, green: 0.88, blue: 0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 17)
                    )
                }
                .buttonStyle(.plain)

                if memory.recentEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "まだ記録がありません"))
                            .font(.system(size: 18, weight: .black, design: .rounded))
                        Text(String(localized: "餌や水を置くと、ここに観察ログが残ります。"))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.10))
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 1.0, green: 0.96, blue: 0.78), in: RoundedRectangle(cornerRadius: 18))
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(memory.recentEntries) { entry in
                            JournalEntryRow(entry: entry)
                        }
                    }
                }
            }
            .padding(18)
        }
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.42, green: 0.35, blue: 0.23),
                        Color(red: 0.20, green: 0.14, blue: 0.09)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                ForEach(0..<9, id: \.self) { index in
                    Rectangle()
                        .fill(Color(red: 1.0, green: 0.92, blue: 0.62).opacity(0.10))
                        .frame(height: 1)
                        .offset(y: CGFloat(index * 34 - 130))
                }
                Rectangle()
                    .fill(Color(red: 0.18, green: 0.10, blue: 0.06).opacity(0.28))
                    .frame(width: 16)
                    .offset(x: -160)
            }
        )
    }
}

private struct JournalEntryRow: View {
    let entry: ObservationEntry

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(iconColor)
                .frame(width: 34, height: 34)
                .background(Color.black.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.localizedTitle)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                    Spacer()
                    Text(entry.date, format: .dateTime.month().day().hour().minute())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.50, green: 0.46, blue: 0.36))
                }
                Text(entry.localizedDetail)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.40, green: 0.36, blue: 0.27))
            }
        }
        .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.10))
        .padding(13)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 17))
    }

    private var systemImage: String {
        switch entry.kind {
        case .care:
            return "hand.tap.fill"
        case .growth:
            return "arrow.up.right.circle.fill"
        case .breeding:
            return "circle.grid.2x2.fill"
        case .record:
            return "star.fill"
        case .alert:
            return "exclamationmark.triangle.fill"
        }
    }

    private var iconColor: Color {
        switch entry.kind {
        case .care:
            return Color(red: 0.34, green: 0.60, blue: 0.30)
        case .growth:
            return Color(red: 0.90, green: 0.56, blue: 0.18)
        case .breeding:
            return Color(red: 0.60, green: 0.42, blue: 0.22)
        case .record:
            return Color(red: 0.78, green: 0.66, blue: 0.24)
        case .alert:
            return Color(red: 0.76, green: 0.24, blue: 0.18)
        }
    }
}

private struct ShareSnapshotSheet: View {
    let image: UIImage?
    let shareURL: URL?

    var body: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(String(localized: "共有用スクショ"))
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(String(localized: "今のゴキブリ部屋をそのまま画像にします。"))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.74))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.20), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.28), radius: 14, y: 8)
            }

            if let shareURL {
                ShareLink(item: shareURL) {
                    Text(String(localized: "画像を共有する"))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.10))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.91, blue: 0.46),
                                    Color(red: 0.68, green: 0.84, blue: 0.44)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 17)
                        )
                }
            }
        }
        .padding(18)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.07, green: 0.08, blue: 0.075),
                        Color(red: 0.02, green: 0.022, blue: 0.024)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Circle()
                    .stroke(Color(red: 0.88, green: 0.74, blue: 0.38).opacity(0.24), lineWidth: 18)
                    .frame(width: 260, height: 260)
                    .blur(radius: 2)
                    .offset(x: 130, y: -140)
                Circle()
                    .fill(Color(red: 0.95, green: 0.82, blue: 0.48).opacity(0.10))
                    .frame(width: 190, height: 190)
                    .blur(radius: 28)
                    .offset(x: 125, y: -135)
            }
        )
    }
}

private struct RulerTicks: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(0..<9, id: \.self) { index in
                Capsule()
                    .fill(Color(red: 0.96, green: 0.86, blue: 0.52).opacity(index.isMultiple(of: 4) ? 0.70 : 0.36))
                    .frame(width: 2, height: index.isMultiple(of: 4) ? 18 : 10)
                Spacer(minLength: 0)
            }
        }
        .frame(height: 20)
    }
}

private struct ObservationToast: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color(red: 0.80, green: 0.70, blue: 0.28))
            Text(text)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.18, green: 0.17, blue: 0.12))
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 9)
        .background(.white.opacity(0.82), in: Capsule())
        .overlay {
            Capsule()
                .stroke(Color(red: 0.80, green: 0.70, blue: 0.28).opacity(0.38), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.18), radius: 10, y: 6)
    }
}

private struct RoomGapBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.78, green: 0.76, blue: 0.66),
                    Color(red: 0.55, green: 0.58, blue: 0.48),
                    Color(red: 0.30, green: 0.34, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            floorBoards
            roomFurniture
            baseboardGap
            crumbsAndDust

            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [.clear, .black.opacity(0.34)],
                        center: .center,
                        startRadius: 140,
                        endRadius: 620
                    )
                )
        }
        .ignoresSafeArea()
    }

    private var floorBoards: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<8, id: \.self) { index in
                    Rectangle()
                        .fill(index.isMultiple(of: 2) ? .white.opacity(0.055) : .black.opacity(0.045))
                        .frame(width: proxy.size.width / 8)
                        .position(x: (CGFloat(index) + 0.5) * proxy.size.width / 8, y: proxy.size.height / 2)
                }

                Path { path in
                    var x: CGFloat = 0
                    while x < proxy.size.width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x + 22, y: proxy.size.height))
                        x += proxy.size.width / 8
                    }
                }
                .stroke(.black.opacity(0.12), lineWidth: 1)
            }
        }
    }

    private var roomFurniture: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.32, green: 0.22, blue: 0.14),
                                Color(red: 0.18, green: 0.12, blue: 0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: proxy.size.width * 0.48, height: proxy.size.height * 0.42)
                    .rotationEffect(.degrees(-5))
                    .position(x: proxy.size.width * 0.12, y: proxy.size.height * 0.78)
                    .shadow(color: .black.opacity(0.42), radius: 18, x: 8, y: 10)

                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.28, green: 0.23, blue: 0.17),
                                Color(red: 0.12, green: 0.10, blue: 0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: proxy.size.width * 0.38, height: proxy.size.height * 0.74)
                    .rotationEffect(.degrees(3))
                    .position(x: proxy.size.width * 0.92, y: proxy.size.height * 0.52)
                    .shadow(color: .black.opacity(0.46), radius: 22, x: -10, y: 12)

                Path { path in
                    path.move(to: CGPoint(x: proxy.size.width * 0.22, y: proxy.size.height * 0.24))
                    path.addLine(to: CGPoint(x: proxy.size.width * 0.74, y: proxy.size.height * 0.08))
                    path.addLine(to: CGPoint(x: proxy.size.width * 0.84, y: proxy.size.height * 0.90))
                    path.addLine(to: CGPoint(x: proxy.size.width * 0.26, y: proxy.size.height * 0.92))
                    path.closeSubpath()
                }
                .fill(.black.opacity(0.23))
                .blur(radius: 8)

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.07, green: 0.055, blue: 0.045).opacity(0.88))
                    .frame(width: proxy.size.width * 0.64, height: 46)
                    .rotationEffect(.degrees(-4))
                    .position(x: proxy.size.width * 0.52, y: proxy.size.height * 0.62)
                    .shadow(color: .black.opacity(0.45), radius: 18, y: 8)
            }
        }
    }

    private var baseboardGap: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle()
                    .fill(Color(red: 0.20, green: 0.18, blue: 0.13))
                    .frame(height: 34)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.28)
                    .shadow(color: .black.opacity(0.32), radius: 10, y: 7)

                Rectangle()
                    .fill(.black.opacity(0.58))
                    .frame(height: 11)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.30)

                Rectangle()
                    .fill(Color(red: 0.18, green: 0.12, blue: 0.08))
                    .frame(width: 28, height: proxy.size.height)
                    .rotationEffect(.degrees(2))
                    .position(x: proxy.size.width * 0.78, y: proxy.size.height * 0.50)
                    .shadow(color: .black.opacity(0.40), radius: 16, x: -8)
            }
        }
    }

    private var crumbsAndDust: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(roomDust) { dust in
                    Capsule()
                        .fill(Color(red: 0.77, green: 0.61, blue: 0.38).opacity(dust.opacity))
                        .frame(width: dust.size.width, height: dust.size.height)
                        .rotationEffect(.degrees(dust.rotation))
                        .position(x: dust.xRatio * proxy.size.width, y: dust.yRatio * proxy.size.height)
                }
            }
        }
    }
}

private struct RoomDust: Identifiable {
    let id = UUID()
    let xRatio: CGFloat
    let yRatio: CGFloat
    let size: CGSize
    let rotation: Double
    let opacity: Double
}

private let roomDust: [RoomDust] = [
    RoomDust(xRatio: 0.16, yRatio: 0.22, size: CGSize(width: 40, height: 3), rotation: -12, opacity: 0.24),
    RoomDust(xRatio: 0.30, yRatio: 0.58, size: CGSize(width: 18, height: 4), rotation: 18, opacity: 0.20),
    RoomDust(xRatio: 0.72, yRatio: 0.22, size: CGSize(width: 32, height: 3), rotation: 28, opacity: 0.22),
    RoomDust(xRatio: 0.82, yRatio: 0.74, size: CGSize(width: 24, height: 4), rotation: -22, opacity: 0.18),
    RoomDust(xRatio: 0.48, yRatio: 0.86, size: CGSize(width: 34, height: 3), rotation: 9, opacity: 0.20),
    RoomDust(xRatio: 0.11, yRatio: 0.82, size: CGSize(width: 22, height: 4), rotation: 35, opacity: 0.18)
]

struct GameScreenView_Previews: PreviewProvider {
    static var previews: some View {
        GameScreenView()
    }
}
