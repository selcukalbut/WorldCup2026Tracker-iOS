//
//  MainTabView.swift
//  GlobalSportsTracker
//
//  Created by Selcuk Albut on 8.06.2026.
//
import SwiftUI

struct MainTabView: View {
    @State private var matches: [Match] = sampleMatches
    @AppStorage("favoriteTeamID") private var favoriteTeamID: String = ""

    var body: some View {

        TabView {

            MobileDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            NavigationStack {
                MatchesView(matches: $matches, favoriteTeamID: favoriteTeamID)
            }
            .tabItem {
                Label("Matches", systemImage: "sportscourt.fill")
            }

            StandingsView(teams: sampleTeams, matches: matches, favoriteTeamID: favoriteTeamID)
                .tabItem {
                    Label("Standings", systemImage: "list.number")
                }

            // MainTabView.swift

            RemoteMatchesView(localMatches: $matches)
                .tabItem {
                    Label("Live", systemImage: "dot.radiowaves.left.and.right")
                }
            
            MoreView(matches: $matches, favoriteTeamID: $favoriteTeamID)
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
        }
        
        .task {

            let granted = await NotificationManager.shared.requestPermission()
            print("Favorite Team ID = \(favoriteTeamID)")

            if granted {

                NotificationManager.shared.scheduleFavoriteTeamReminders(
                    matches: matches,
                    favoriteTeamID: favoriteTeamID
                )
            }
        }
        .onChange(of: favoriteTeamID) { _, newValue in

            print("Favorite Team changed: \(newValue)")

            NotificationManager.shared.scheduleFavoriteTeamReminders(
                matches: matches,
                favoriteTeamID: newValue
            )
        }
    }
}

#Preview {
    MainTabView()
}
