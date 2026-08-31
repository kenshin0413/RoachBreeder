//
//  AdMobLifecycleManager.swift
//  RoachBreeder
//

import AppTrackingTransparency
import Foundation
import GoogleMobileAds
import UIKit

@MainActor
final class AdMobLifecycleManager {
    static let shared = AdMobLifecycleManager()

    private var hasStartedMobileAds = false
    private var isPreparing = false
    private var preparationWaiters: [CheckedContinuation<Void, Never>] = []
    private var mayRequestTrackingAuthorization = false
    private var trackingAuthorizationGateWaiters: [CheckedContinuation<Void, Never>] = []

    private init() {}

    func allowTrackingAuthorizationRequest() {
        guard !mayRequestTrackingAuthorization else { return }
        mayRequestTrackingAuthorization = true
        let waiters = trackingAuthorizationGateWaiters
        trackingAuthorizationGateWaiters.removeAll()
        waiters.forEach { $0.resume() }
    }

    func prepareForAdLoading() async {
        guard !hasStartedMobileAds else { return }

        if isPreparing {
            await withCheckedContinuation { continuation in
                preparationWaiters.append(continuation)
            }
            return
        }

        isPreparing = true
        await requestTrackingAuthorizationIfNeeded()

        if !hasStartedMobileAds {
            hasStartedMobileAds = true
            await MobileAds.shared.start()
        }

        isPreparing = false
        let waiters = preparationWaiters
        preparationWaiters.removeAll()
        waiters.forEach { $0.resume() }
    }

    private func requestTrackingAuthorizationIfNeeded() async {
        guard #available(iOS 14, *) else {
            return
        }

        if !mayRequestTrackingAuthorization {
            await withCheckedContinuation { continuation in
                trackingAuthorizationGateWaiters.append(continuation)
            }
        }

        #if DEBUG
        print("[ATT] status before request: \(ATTrackingManager.trackingAuthorizationStatus.rawValue), app state: \(UIApplication.shared.applicationState.rawValue)")
        #endif

        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }

        for attempt in 0..<3 {
            for _ in 0..<50 where UIApplication.shared.applicationState != .active {
                try? await Task.sleep(for: .milliseconds(100))
            }

            if attempt > 0 {
                try? await Task.sleep(for: .milliseconds(750))
            }

            let status = await ATTrackingManager.requestTrackingAuthorization()

            #if DEBUG
            print("[ATT] status after request \(attempt + 1): \(status.rawValue), app state: \(UIApplication.shared.applicationState.rawValue)")
            #endif

            guard status == .notDetermined else { return }
        }
    }
}
