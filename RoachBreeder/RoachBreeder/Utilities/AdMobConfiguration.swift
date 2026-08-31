//
//  AdMobConfiguration.swift
//  RoachBreeder
//

import Foundation

enum AdMobConfiguration {
    static var usesTestAds: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    static var rewardedAdUnitID: String {
        #if DEBUG
        // Google official iOS rewarded test ad unit. Do not replace in Debug.
        return "ca-app-pub-3940256099942544/1712485313"
        #else
        return "ca-app-pub-2277987033120510/3648844819"
        #endif
    }
}
