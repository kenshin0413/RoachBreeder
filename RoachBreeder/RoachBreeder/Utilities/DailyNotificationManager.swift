//
//  DailyNotificationManager.swift
//  RoachBreeder
//

import Foundation
import UserNotifications

enum DailyNotificationManager {
    private static let reminderIdentifier = "RoachBreeder.dailyCareReminder"

    static func configureDailyCareReminder() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            guard granted else { return }
            scheduleDailyCareReminder()
        }
    }

    private static func scheduleDailyCareReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = String(localized: "すき間の巣")
        content.body = String(localized: "餌をあげてください。今夜も奥で動いています。")
        content.sound = .default

        var date = DateComponents()
        date.hour = 21
        date.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        center.add(request)
    }
}
