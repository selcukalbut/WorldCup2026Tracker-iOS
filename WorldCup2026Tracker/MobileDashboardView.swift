//
//  MobileDashboardView.swift
//  GlobalSportsTracker
//
//  Created by Selcuk Albut on 8.06.2026.
//

import SwiftUI

struct MobileDashboardView: View {
    @StateObject private var apiService = APIService.shared
    @State private var remoteMatches: [RemoteMatch] = []
    @AppStorage("favoriteTeamID") private var favoriteTeamID: String = ""
    @AppStorage("favoriteMatchIDs") private var favoriteMatchIDs: String = ""

    var favoriteTeam: Team? {
        sampleTeams.first { $0.id == favoriteTeamID }
    }

    var upcomingMatches: [RemoteMatch] {
        remoteMatches
            .filter { ($0.matchDate ?? .distantFuture) >= Date() }
            .sorted { ($0.matchDate ?? .distantFuture) < ($1.matchDate ?? .distantFuture) }
    }

    var favoriteMatchIDSet: Set<String> {
        Set(favoriteMatchIDs.split(separator: ",").map { String($0) })
    }

    var trackedMatches: [Match] {
        sampleMatches.filter { favoriteMatchIDSet.contains($0.id.uuidString) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    dashboardHeader

                    tournamentStatusMiniCard

                    liveDataMiniCard

                    todayMatchesMiniCard

                    favoriteTeamMiniCard

                    trackedMatchesMiniCard

                    testNotificationButton

                    quickAccessGrid
                }
                .padding()
            }
            .modifier(HideMobileNavigationBar())
            .task {
                await loadRemoteMatches()
            }
        }
    }

    private var dashboardHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("🌍 Global Sports Tracker")
                    .font(.largeTitle)
                    .fontWeight(.black)
                
                Text("⚽ International Football 2026")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.top, 8)
    }

    private var tournamentStatusMiniCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🏆 Tournament Status")
                .font(.title2)
                .fontWeight(.bold)

            Text("Live scores, standings and tournament tracking")
                .foregroundStyle(.secondary)

            HStack {
                infoBox("48", "Teams")
                infoBox("104", "Match")
                infoBox("16", "Stadiums")
            }
        }
        .dashboardCardStyle()
    }

    private var todayMatchesMiniCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📅 Upcoming Matches")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button {
                    Task { await loadRemoteMatches() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline)
                }
            }

            if upcomingMatches.isEmpty {
                Text("Match data has not been loaded yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(upcomingMatches.prefix(3)) { match in
                    upcomingMatchRow(match)
                }
            }
        }
        .dashboardCardStyle()
    }

    private var favoriteTeamMiniCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("⭐ Favorite Team")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }

            if let team = favoriteTeam {
                HStack(spacing: 14) {
                    Text(team.flag)
                        .font(.largeTitle)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(team.name)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("Group \(team.group) • Rating \(team.rating)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No match data loaded yet.")
                        .foregroundStyle(.secondary)
                    
                    Text("You can select your favorite team using the star icon on the Groups screen.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .dashboardCardStyle()
    }

    private var trackedMatchesMiniCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("❤️ Followed Matches")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Text("\(trackedMatches.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Color.red.opacity(0.75))
                    .clipShape(Capsule())
            }

            if trackedMatches.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No tracked matches yet.")
                        .foregroundStyle(.secondary)

                    Text("Open a match from the Matches screen and use the Follow option in Match Center.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(trackedMatches.prefix(3)) { match in
                    trackedMatchRow(match)
                }

                if trackedMatches.count > 3 {
                    Text("+\(trackedMatches.count - 3) more matches being tracked")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .dashboardCardStyle()
    }

    private func trackedMatchRow(_ match: Match) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text("\(match.homeTeam.flag) \(match.homeTeam.name)")
                    .font(.headline)
                    .lineLimit(1)

                Text("\(match.awayTeam.flag) \(match.awayTeam.name)")
                    .font(.headline)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(localScoreText(for: match))
                    .font(.headline)
                    .fontWeight(.black)

                Text(match.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .background(Color.red.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func localScoreText(for match: Match) -> String {
        if let homeScore = match.homeScore,
           let awayScore = match.awayScore {
            return "\(homeScore) - \(awayScore)"
        }

        return "VS"
    }

    private var liveDataMiniCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🌐 Live Data Center")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    Task { await loadRemoteMatches() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline)
                }
            }

            Text(apiService.statusMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                infoBox("\(apiService.lastFetchedMatchCount)", "Loaded Matches")
                infoBox(apiService.isLoading ? "Active" : "Ready", "Status")
            }
        }
        .dashboardCardStyle()
    }

    private func upcomingMatchRow(_ match: RemoteMatch) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(flag(for: match.homeTeam)) \(match.homeTeam)")
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(flag(for: match.awayTeam)) \(match.awayTeam)")
                    .font(.headline)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(scoreText(for: match))
                    .font(.headline)
                    .fontWeight(.black)
                
                if let date = match.matchDate {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color.blue.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func scoreText(for match: RemoteMatch) -> String {
        if let homeScore = match.homeScore,
           let awayScore = match.awayScore {
            return "\(homeScore) - \(awayScore)"
        }
        
        return "VS"
    }
    
    private func flag(for teamName: String) -> String {
        let normalizedName = teamName.lowercased()
        
        if let localTeam = sampleTeams.first(where: { $0.name.lowercased() == normalizedName }) {
            return localTeam.flag
        }
        
        let aliases: [String: String] = [
            "usa": "🇺🇸",
            "united states": "🇺🇸",
            "mexico": "🇲🇽",
            "canada": "🇨🇦",
            "brazil": "🇧🇷",
            "france": "🇫🇷",
            "spain": "🇪🇸",
            "argentina": "🇦🇷",
            "england": "🏴",
            "germany": "🇩🇪",
            "portugal": "🇵🇹",
            "netherlands": "🇳🇱",
            "belgium": "🇧🇪",
            "morocco": "🇲🇦",
            "japan": "🇯🇵",
            "switzerland": "🇨🇭",
            "uruguay": "🇺🇾",
            "croatia": "🇭🇷",
            "colombia": "🇨🇴",
            "turkiye": "🇹🇷",
            "türkiye": "🇹🇷",
            "australia": "🇦🇺",
            "ghana": "🇬🇭",
            "senegal": "🇸🇳",
            "egypt": "🇪🇬",
            "iran": "🇮🇷",
            "new zealand": "🇳🇿",
            "korea republic": "🇰🇷",
            "south korea": "🇰🇷",
            "saudi arabia": "🇸🇦",
            "south africa": "🇿🇦"
        ]
        
        return aliases[normalizedName] ?? "🏳️"
    }

    private var testNotificationButton: some View {
        Button {
            NotificationManager.shared.scheduleTestNotification()
        } label: {
            Label(
                "🔔 Send Test Notification",
                systemImage: "bell.badge.fill"
            )
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
    
    private var quickAccessGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
            quickAccessCard("Groups", icon: "person.3.fill")
            quickAccessCard("Matches", icon: "sportscourt.fill")
            quickAccessCard("Standings", icon: "list.number")
            quickAccessCard("Live", icon: "dot.radiowaves.left.and.right")
        }
    }

    private func quickAccessCard(_ title: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func infoBox(_ value: String, _ title: String) -> some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.black)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.blue.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func loadRemoteMatches() async {
        do {
            remoteMatches = try await apiService.fetchMatches()
        } catch {
            print(error.localizedDescription)
        }
    }
}

private struct HideMobileNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .modifier(InlineNavigationBarTitleIfAvailable())
            .toolbar(.hidden, for: .navigationBar)
        #else
        content
        #endif
    }
}

private struct InlineNavigationBarTitleIfAvailable: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        content.navigationBarTitleDisplayMode(.inline)
        #else
        content
        #endif
    }
}

extension View {
    func dashboardCardStyle() -> some View {
        self
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    MobileDashboardView()
}
