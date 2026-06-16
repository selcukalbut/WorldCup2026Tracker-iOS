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
    func scheduleFavoriteTeamReminders(matches: [Match], favoriteTeamID: String) {
                
        guard !favoriteTeamID.isEmpty else { return }

        let favoriteMatches = matches.filter {
            ($0.homeTeam.id == favoriteTeamID || $0.awayTeam.id == favoriteTeamID) &&
            $0.homeScore == nil &&
            $0.awayScore == nil
        }

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let favoriteReminderIDs = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix("favorite-match-") }

            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: favoriteReminderIDs)
        }

        for match in favoriteMatches {
            guard let matchDate = self.matchDate(from: match.date) else {
                continue
            }

            let reminderDate = matchDate.addingTimeInterval(-3600)

            guard reminderDate > Date() else {
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = "⭐ Favorite Team Match"
            content.body = "\(match.homeTeam.name) vs \(match.awayTeam.name) starts in 1 hour."
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
                identifier: "favorite-match-\(match.id.uuidString)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    print("Favorite team notification could not be scheduled: \(error.localizedDescription)")
                } else {
                    print("Favorite team notification scheduled: \(match.homeTeam.name) vs \(match.awayTeam.name)")
                }
            }
        }
    }

    private func matchDate(from text: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.date(from: text)
    }
}
