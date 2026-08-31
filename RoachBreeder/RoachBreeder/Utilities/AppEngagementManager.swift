//
//  AppEngagementManager.swift
//  RoachBreeder
//

import Combine
import Foundation
import StoreKit
import UIKit

@MainActor
final class AppUpdateManager: ObservableObject {
    struct RequiredUpdate: Identifiable {
        let version: String
        let storeURL: URL

        var id: String { version }
    }

    @Published private(set) var requiredUpdate: RequiredUpdate?

    private struct LookupResponse: Decodable {
        let results: [AppInfo]
    }

    private struct AppInfo: Decodable {
        let version: String
        let trackViewUrl: URL
    }

    func check() async {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-ForceUpdateAlert"),
           let url = URL(string: "https://apps.apple.com/") {
            requiredUpdate = RequiredUpdate(version: String(localized: "テスト版"), storeURL: url)
            return
        }
        #endif

        guard
            let bundleID = Bundle.main.bundleIdentifier,
            let installedVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            var components = URLComponents(string: "https://itunes.apple.com/lookup")
        else { return }

        components.queryItems = [
            URLQueryItem(name: "bundleId", value: bundleID),
            URLQueryItem(name: "country", value: "jp")
        ]
        guard let url = components.url else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else { return }
            let app = try JSONDecoder().decode(LookupResponse.self, from: data).results.first
            guard let app, app.version.isNewer(than: installedVersion) else {
                requiredUpdate = nil
                return
            }
            requiredUpdate = RequiredUpdate(version: app.version, storeURL: app.trackViewUrl)
        } catch {
            // Network failures must not block users when update availability cannot be verified.
        }
    }

    func openStore() {
        guard let url = requiredUpdate?.storeURL else { return }
        UIApplication.shared.open(url)
    }
}

@MainActor
final class ReviewPromptManager: ObservableObject {
    @Published var isPromptPresented = false

    private static let firstLaunchKey = "RoachBreeder.Review.FirstLaunch.v1"
    private static let sessionCountKey = "RoachBreeder.Review.SessionCount.v1"
    private static let lastPromptDateKey = "RoachBreeder.Review.LastPromptDate.v1"
    private static let cooldown: TimeInterval = 15 * 24 * 60 * 60

    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Self.firstLaunchKey) == nil {
            defaults.set(Date(), forKey: Self.firstLaunchKey)
        }
        defaults.set(defaults.integer(forKey: Self.sessionCountKey) + 1, forKey: Self.sessionCountKey)
    }

    func evaluate(memory: ColonyMemory) {
        guard !isPromptPresented, cooldownHasElapsed else { return }

        let gachaDraws = memory.gachaHistory.count
        let careActions = memory.journalEntries.filter { $0.kind == .care }.count
        let collectionCount = memory.discoveredHideouts.count
            + memory.discoveredRoachVariants.count
            + memory.unlockedRoomSkins.count
        let sessionCount = UserDefaults.standard.integer(forKey: Self.sessionCountKey)

        let signals = [
            gachaDraws >= 3,
            careActions >= 8,
            collectionCount >= 4,
            memory.maxColonyCount >= 20,
            !memory.namedHistory.isEmpty,
            sessionCount >= 4
        ]

        // A single repeated action is not enough; require two distinct engagement signals.
        guard signals.filter({ $0 }).count >= 2 else { return }
        UserDefaults.standard.set(Date(), forKey: Self.lastPromptDateKey)
        isPromptPresented = true
    }

    func requestReview() {
        isPromptPresented = false
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else { return }
        AppStore.requestReview(in: scene)
    }

    private var cooldownHasElapsed: Bool {
        guard let lastDate = UserDefaults.standard.object(forKey: Self.lastPromptDateKey) as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastDate) >= Self.cooldown
    }
}

private extension String {
    func isNewer(than otherVersion: String) -> Bool {
        compare(otherVersion, options: .numeric) == .orderedDescending
    }
}
