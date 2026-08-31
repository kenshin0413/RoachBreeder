//
//  RewardedAdManager.swift
//  RoachBreeder
//

import Combine
import Foundation
import GoogleMobileAds
import UIKit

@MainActor
final class RewardedAdManager: NSObject, ObservableObject {
    @Published private(set) var isReady = false
    @Published private(set) var isLoading = false
    @Published private(set) var isShowing = false
    @Published var lastErrorMessage: String?

    private var rewardedAd: RewardedAd?
    private var pendingRewardAction: (@MainActor () -> Void)?
    private var retryTask: Task<Void, Never>?
    private var retryAttempt = 0

    deinit {
        retryTask?.cancel()
    }

    func loadAdIfNeeded() async {
        guard !isReady, !isLoading else { return }

        await AdMobLifecycleManager.shared.prepareForAdLoading()
        isLoading = true
        lastErrorMessage = nil

        do {
            let ad = try await RewardedAd.load(
                with: AdMobConfiguration.rewardedAdUnitID,
                request: Request()
            )
            ad.fullScreenContentDelegate = self
            rewardedAd = ad
            isReady = true
            retryAttempt = 0
            retryTask?.cancel()
            retryTask = nil
        } catch {
            rewardedAd = nil
            isReady = false
            let nsError = error as NSError
            lastErrorMessage = String(localized: "広告の読み込みに失敗しました")
            print(
                "Rewarded ad failed to load "
                    + "(domain: \(nsError.domain), code: \(nsError.code), "
                    + "unit: \(AdMobConfiguration.usesTestAds ? "test" : "production")): "
                    + nsError.localizedDescription
            )
        }

        isLoading = false

        if isReady, pendingRewardAction != nil {
            presentLoadedAd()
        } else if !isReady {
            scheduleRetry()
        }
    }

    func showAd(onReward: @escaping @MainActor () -> Void) {
        guard !isShowing, pendingRewardAction == nil else { return }

        pendingRewardAction = onReward

        guard rewardedAd != nil else {
            isReady = false
            lastErrorMessage = String(localized: "広告を準備中です")
            Task { await loadAdIfNeeded() }
            return
        }

        presentLoadedAd()
    }

    private func presentLoadedAd() {
        guard !isShowing,
              let ad = rewardedAd,
              let onReward = pendingRewardAction else { return }

        guard let presenter = UIApplication.shared.rewardedAdPresenter else {
            lastErrorMessage = String(localized: "広告を表示できませんでした")
            schedulePresentationRetry()
            return
        }

        pendingRewardAction = nil
        rewardedAd = nil
        isReady = false
        isShowing = true
        lastErrorMessage = nil

        ad.present(from: presenter) {
            Task { @MainActor in
                onReward()
            }
        }
    }

    private func scheduleRetry() {
        guard retryTask == nil else { return }
        let delays: [UInt64] = [2, 5, 10, 20]
        let delay = delays[min(retryAttempt, delays.count - 1)]
        retryAttempt += 1

        retryTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled, let self else { return }
            self.retryTask = nil
            await self.loadAdIfNeeded()
        }
    }

    private func schedulePresentationRetry() {
        guard retryTask == nil else { return }
        retryTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled, let self else { return }
            self.retryTask = nil
            self.presentLoadedAd()
        }
    }
}

private extension UIApplication {
    var rewardedAdPresenter: UIViewController? {
        let root = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController

        return root?.topmostPresentedViewController
    }
}

private extension UIViewController {
    var topmostPresentedViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.topmostPresentedViewController
        }
        if let navigationController = self as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return visibleViewController.topmostPresentedViewController
        }
        if let tabBarController = self as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.topmostPresentedViewController
        }
        return self
    }
}

extension RewardedAdManager: FullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            isShowing = false
            await loadAdIfNeeded()
        }
    }

    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            isShowing = false
            lastErrorMessage = String(localized: "広告を表示できませんでした")
            await loadAdIfNeeded()
        }
    }
}
