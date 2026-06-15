//
//  NotificationManager.swift
//  GlobalSportsTracker
//
//  Created by Selcuk Albut on 9.06.2026.
//

import Foundation
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

final class NotificationManager {

    static let shared = NotificationManager()
    private let notificationDelegate = NotificationDelegate()

    private init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    func requestPermission() async -> Bool {

        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(
                    options: [.alert, .badge, .sound]
                )

            print("Notification permission: \(granted)")
            return granted

        } catch {

            print("Notification error: \(error.localizedDescription)")
            return false
        }
    }

    func scheduleTestNotification() {

        let content = UNMutableNotificationContent()

        content.title = "🌍 Global Sports Tracker"
        content.body = "The notification system is working correctly."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 10,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Test notification could not be scheduled: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled for 10 seconds later.")
            }
        }
    }

    func scheduleMatchReminder(
        matchID: String,
        homeTeam: String,
        awayTeam: String,
        timeInterval: TimeInterval = 10
    ) {
        let content = UNMutableNotificationContent()
        content.title = "⚽ Match Reminder"
        content.body = "\(homeTeam) vs \(awayTeam) match is coming up."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "match-reminder-\(matchID)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Match notification could not be scheduled: \(error.localizedDescription)")
            } else {
                print("Match notification scheduled: \(homeTeam) vs \(awayTeam)")
            }
        }
    }

    func cancelMatchReminder(matchID: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["match-reminder-\(matchID)"]
        )
        print("Match notification cancelled: \(matchID)")
    }
    
    func scheduleMatchReminder(
        matchID: String,
        homeTeam: String,
        awayTeam: String,
        reminderDate: Date
    ) {
        let content = UNMutableNotificationContent()
        content.title = "⚽ Match Reminder"
        content.body = "\(homeTeam) vs \(awayTeam) starts in 1 hour."
        content.sound = .default

        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "match-reminder-\(matchID)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Match notification could not be scheduled: \(error.localizedDescription)")
            } else {
                print("Match notification scheduled for the actual date: \(homeTeam) vs \(awayTeam) - \(reminderDate)")
            }
        }
    }
    
}
