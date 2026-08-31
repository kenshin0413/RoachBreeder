//
//  RoachBreederApp.swift
//  RoachBreeder
//
//  Created by miyamotokenshin on R 8/06/14.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }
}

@MainActor
enum AppServicesBootstrapper {
    private static var didSchedule = false
    private static var didStart = false

    static func scheduleAfterFirstFrame() {
        guard !didSchedule else { return }
        didSchedule = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            startIfNeeded()
        }
    }

    private static func startIfNeeded() {
        guard !didStart else { return }
        didStart = true
        FirebaseApp.configure()
        FirebaseApp.app()?.isDataCollectionDefaultEnabled = true
        Analytics.setAnalyticsCollectionEnabled(true)

        #if DEBUG
        Analytics.logEvent("debug_app_launch", parameters: ["source": "after_first_frame"])
        #endif
    }
}

@main
struct RoachBreederApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
