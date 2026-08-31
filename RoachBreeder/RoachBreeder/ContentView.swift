//
//  ContentView.swift
//  RoachBreeder
//
//  Created by miyamotokenshin on R 8/06/14.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingLaunchExperience = true
    @State private var deepLinkTarget: String?
    @State private var didScheduleFallback = false
    @State private var didStartAdServices = false

    var body: some View {
        ZStack {
            GameScreenView(deepLinkTarget: $deepLinkTarget)

            if isShowingLaunchExperience {
                LaunchExperienceView {
                    completeLaunch(animatedDelay: true)
                }
                .zIndex(200)
            }
        }
        .onAppear {
            AppServicesBootstrapper.scheduleAfterFirstFrame()
            guard !didScheduleFallback else { return }
            didScheduleFallback = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                // Independent fallback in case the launch view's async choreography is cancelled.
                if isShowingLaunchExperience {
                    completeLaunch(animatedDelay: false)
                }
            }
        }
        .onOpenURL { url in
            guard url.scheme?.lowercased() == "roachbreeder" else { return }
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            deepLinkTarget = components?.queryItems?.first(where: { $0.name == "target" })?.value ?? "colony"
            // A widget cold launch must never wait for the splash choreography.
            isShowingLaunchExperience = false
            startAdServices(after: 0.65)
        }
    }

    private func completeLaunch(animatedDelay: Bool) {
        isShowingLaunchExperience = false
        startAdServices(after: animatedDelay ? 0.35 : 0.0)
    }

    private func startAdServices(after delay: Double) {
        guard !didStartAdServices else { return }
        didStartAdServices = true
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            Task { @MainActor in
                AdMobLifecycleManager.shared.allowTrackingAuthorizationRequest()
                await AdMobLifecycleManager.shared.prepareForAdLoading()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
