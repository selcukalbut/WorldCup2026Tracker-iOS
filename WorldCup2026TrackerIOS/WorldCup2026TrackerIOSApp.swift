//
//  GlobalSportsTrackerIOSApp.swift
//  GlobalSportsTrackerIOS
//
//  Created by Selcuk Albut on 8.06.2026.
//

import SwiftUI

@main
struct WorldCup2026TrackerIOSApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
                .task {
                    _ = await NotificationManager.shared.requestPermission()
                }
        }
    }
}
