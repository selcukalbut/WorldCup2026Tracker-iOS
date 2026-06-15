//
//  GlobalSportsTrackerApp.swift
//  GlobalSportsTracker
//
//  Created by Selcuk Albut on 3.06.2026.
//

import SwiftUI

@main
struct WorldCup2026TrackerApp: App {
    var body: some Scene {
        WindowGroup {            
#if os(iOS)
    MainTabView()
#else
    ContentView()
#endif
        }
    }
}
