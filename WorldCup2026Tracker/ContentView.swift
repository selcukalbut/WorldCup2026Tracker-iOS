//
//  ContentView.swift
//  GlobalSportsTracker
//
//  Created by Selcuk Albut on 3.06.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("savedMatches") private var savedMatchesData: Data = Data()
    @AppStorage("favoriteTeamID") private var favoriteTeamID: String = ""
    @State private var matches: [Match] = []
    @State private var dashboardRemoteMatches: [RemoteMatch] = []
    @StateObject private var apiService = APIService.shared
    
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink("Home") {
                    dashboardView
                }
                
                NavigationLink("Groups") {
                    GroupsView(teams: sampleTeams, matches: matches, favoriteTeamID: $favoriteTeamID)
                }
                
                NavigationLink("Matches") {
                    MatchesView(matches: $matches, favoriteTeamID: favoriteTeamID)
                }
                
                NavigationLink("Standings") {
                    StandingsView(teams: sampleTeams, matches: matches, favoriteTeamID: favoriteTeamID)
                }
                
                NavigationLink("Knockout Stage") {
                    KnockoutView(teams: sampleTeams, matches: matches)
                }
                
                NavigationLink("Statistics") {
                    StatisticsView(teams: sampleTeams, matches: matches)
                }
                
                NavigationLink("Host Cities") {
                    HostCitiesView(matches: matches)
                }
                
                NavigationLink("🌐 Live Match Data") {
                    RemoteMatchesView()
                }
            }
            .navigationTitle("Global Sports Tracker")
        } detail: {
            dashboardView
        }
        .onAppear {
            loadMatches()
            Task {
                await loadDashboardRemoteMatchesIfNeeded()
            }
        }
        
        .onChange(of: matches) { _, _ in
            saveMatches()
        }
    }

    private var dashboardView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🌍 Global Sports Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("⚽ International Football 2026")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 160), spacing: 16)],
                    spacing: 16
                ) {
                    dashboardCard(title: "Teams", value: "\(sampleTeams.count)", icon: "person.3.fill")
                    dashboardCard(title: "Groups", value: "\(Set(sampleTeams.map { $0.group }).count)", icon: "square.grid.2x2.fill")
                    dashboardCard(title: "Scored Matches", value: "\(playedMatchCount)", icon: "sportscourt.fill")
                    dashboardCard(title: "Total Goals", value: "\(totalGoals)", icon: "soccerball")
                }
            
                
                tournamentStatusCard
                todayMatchesCard
                favoriteTeamCard
                liveDataCard
                tournamentFavoritesCard
                groupLeadersCard
                resetScoresCard
                
                Text("You can view groups, matches and standings from the side menu.")
                    .foregroundStyle(.secondary)
            }
            .padding(32)
        }
    }
    private var tournamentStatusCard: some View {
        TimelineView(.periodic(from: Date(), by: 60)) { timeline in
            let now = timeline.date
            let remaining = countdownComponents(from: now)
            let hasStarted = now >= worldCupStartDate
            let hasFinished = now > worldCupEndDate
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tournamentStatusTitle(hasStarted: hasStarted, hasFinished: hasFinished))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text(tournamentStatusSubtitle(hasStarted: hasStarted, hasFinished: hasFinished))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    
                    Spacer()
                    
                    Image(systemName: tournamentStatusIcon(hasStarted: hasStarted, hasFinished: hasFinished))
                        .font(.largeTitle)
                        .foregroundStyle(.yellow)
                }
                
                if !hasStarted {
                    HStack(spacing: 14) {
                        countdownMetric(value: "\(remaining.days)", title: "Days")
                        countdownMetric(value: "\(remaining.hours)", title: "Hours")
                        countdownMetric(value: "\(remaining.minutes)", title: "Minutes")
                    }
                    
                    Text("Opening date: June 11, 2026")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.78))
                } else if hasFinished {
                    HStack(spacing: 14) {
                        tournamentInfoMetric(value: "104", title: "Total Matches")
                        tournamentInfoMetric(value: "48", title: "Teams")
                        tournamentInfoMetric(value: "16", title: "Cities/Stadiums")
                    }
                    
                    Text("The tournament has finished. Results and statistics can be viewed in the relevant sections.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.78))
                } else {
                    HStack(spacing: 14) {
                        tournamentInfoMetric(value: "In Progress", title: "Status")
                        tournamentInfoMetric(value: "104", title: "Total Matches")
                        tournamentInfoMetric(value: "16", title: "Stadiums")
                    }
                    
                    Text("Use the Live Match Data screen for live matches and updated fixtures.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.78))
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.16, blue: 0.36),
                        Color(red: 0.06, green: 0.28, blue: 0.58)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.cyan.opacity(0.35), lineWidth: 1.2)
            )
            .shadow(color: Color.blue.opacity(0.18), radius: 8, x: 0, y: 4)
        }
    }

    private func countdownMetric(value: String, title: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.78))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func tournamentInfoMetric(value: String, title: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.78))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var worldCupStartDate: Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 11
        components.hour = 0
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    private var worldCupEndDate: Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = 19
        components.hour = 23
        components.minute = 59
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private func tournamentStatusTitle(hasStarted: Bool, hasFinished: Bool) -> String {
        if hasFinished {
            return "🏆 Tournament Finished"
        }
        
        if hasStarted {
            return "🏆 Tournament In Progress"
        }
        
        return "⏳ Tournament Starting Soon..."
    }
    
    private func tournamentStatusSubtitle(hasStarted: Bool, hasFinished: Bool) -> String {
        if hasFinished {
            return "International tournament results and statistics"
        }
        
        if hasStarted {
            return "Live fixtures, scores and tournament updates"
        }
        
        return "Next major tournament countdown"
    }
    
    private func tournamentStatusIcon(hasStarted: Bool, hasFinished: Bool) -> String {
        if hasFinished {
            return "checkmark.seal.fill"
        }
        
        if hasStarted {
            return "sportscourt.fill"
        }
        
        return "trophy.fill"
    }

    private func countdownComponents(from currentDate: Date) -> (days: Int, hours: Int, minutes: Int) {
        guard currentDate < worldCupStartDate else {
            return (0, 0, 0)
        }
        
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: currentDate, to: worldCupStartDate)
        return (
            max(0, components.day ?? 0),
            max(0, components.hour ?? 0),
            max(0, components.minute ?? 0)
        )
    }

    private var todayMatchesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("📅 Today's Matches")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(todayMatchesSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    Task {
                        await loadDashboardRemoteMatches()
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .disabled(apiService.isLoading)
            }
            
            if apiService.isLoading && dashboardRemoteMatches.isEmpty {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Loading match data...")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            } else if !todayRemoteMatches.isEmpty {
                LazyVStack(spacing: 10) {
                    ForEach(todayRemoteMatches.prefix(4)) { match in
                        dashboardRemoteMatchRow(match)
                    }
                }
            } else if !upcomingRemoteMatches.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("No matches today. Upcoming matches will appear soon.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    ForEach(upcomingRemoteMatches.prefix(3)) { match in
                        dashboardRemoteMatchRow(match)
                    }
                }
            } else {
                Text("No live match data available yet. Data can be refreshed from the Live Data Center.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cyan.opacity(0.25), lineWidth: 1)
        )
    }

    private var todayRemoteMatches: [RemoteMatch] {
        dashboardRemoteMatches
            .filter { match in
                guard let date = match.matchDate else { return false }
                return Calendar.current.isDate(date, inSameDayAs: Date())
            }
            .sorted { ($0.matchDate ?? .distantFuture) < ($1.matchDate ?? .distantFuture) }
    }

    private var upcomingRemoteMatches: [RemoteMatch] {
        dashboardRemoteMatches
            .filter { match in
                guard let date = match.matchDate else { return false }
                return date >= Date()
            }
            .sorted { ($0.matchDate ?? .distantFuture) < ($1.matchDate ?? .distantFuture) }
    }

    private var todayMatchesSubtitle: String {
        if !todayRemoteMatches.isEmpty {
            return "\(todayRemoteMatches.count) matches scheduled today"
        }
        
        if !upcomingRemoteMatches.isEmpty {
            return "No matches today. Showing upcoming matches."
        }
        
        return "Live fixture data"
    }

    private func dashboardRemoteMatchRow(_ match: RemoteMatch) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(flag(forRemoteTeam: match.homeTeam)) \(match.homeTeam)")
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(flag(forRemoteTeam: match.awayTeam)) \(match.awayTeam)")
                    .font(.headline)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(dashboardScoreText(for: match))
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
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func dashboardScoreText(for match: RemoteMatch) -> String {
        if let homeScore = match.homeScore,
           let awayScore = match.awayScore {
            return "\(homeScore) - \(awayScore)"
        }
        
        return "VS"
    }

    private func flag(forRemoteTeam teamName: String) -> String {
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

    private func loadDashboardRemoteMatchesIfNeeded() async {
        guard dashboardRemoteMatches.isEmpty else { return }
        await loadDashboardRemoteMatches()
    }

    private func loadDashboardRemoteMatches() async {
        do {
            dashboardRemoteMatches = try await apiService.fetchMatches()
            syncRemoteMatchesToLocalMatches(dashboardRemoteMatches)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func syncRemoteMatchesToLocalMatches(_ remoteMatches: [RemoteMatch]) {
        var didUpdate = false

        for remoteMatch in remoteMatches {
            guard isSyncableRemoteMatch(remoteMatch),
                  let remoteHomeScore = remoteMatch.homeScore,
                  let remoteAwayScore = remoteMatch.awayScore,
                  let matchIndex = localMatchIndex(for: remoteMatch) else {
                continue
            }

            let isReversed = isReversedMatch(local: matches[matchIndex], remote: remoteMatch)
            let newHomeScore = isReversed ? remoteAwayScore : remoteHomeScore
            let newAwayScore = isReversed ? remoteHomeScore : remoteAwayScore

            if matches[matchIndex].homeScore != newHomeScore ||
                matches[matchIndex].awayScore != newAwayScore {
                matches[matchIndex].homeScore = newHomeScore
                matches[matchIndex].awayScore = newAwayScore
                didUpdate = true
            }
        }

        if didUpdate {
            saveMatches()
        }
    }

    private func isSyncableRemoteMatch(_ remoteMatch: RemoteMatch) -> Bool {
        guard remoteMatch.homeScore != nil,
              remoteMatch.awayScore != nil else {
            return false
        }

        let status = remoteMatch.statusText.uppercased()
        return ["LIVE", "IN_PLAY", "PAUSED", "FINISHED"].contains(status)
    }

    private func localMatchIndex(for remoteMatch: RemoteMatch) -> Int? {
        matches.firstIndex { localMatch in
            isSameMatch(local: localMatch, remote: remoteMatch) ||
            isReversedMatch(local: localMatch, remote: remoteMatch)
        }
    }

    private func isSameMatch(local: Match, remote: RemoteMatch) -> Bool {
        canonicalTeamName(local.homeTeam.name) == canonicalTeamName(remote.homeTeam) &&
        canonicalTeamName(local.awayTeam.name) == canonicalTeamName(remote.awayTeam)
    }

    private func isReversedMatch(local: Match, remote: RemoteMatch) -> Bool {
        canonicalTeamName(local.homeTeam.name) == canonicalTeamName(remote.awayTeam) &&
        canonicalTeamName(local.awayTeam.name) == canonicalTeamName(remote.homeTeam)
    }

    private func canonicalTeamName(_ name: String) -> String {
        let normalizedName = normalizeTeamName(name)
        let aliases: [String: String] = [
            "usa": "unitedstates",
            "unitedstates": "unitedstates",
            "korearepublic": "southkorea",
            "southkorea": "southkorea",
            "turkey": "turkiye",
            "turkiye": "turkiye",
            "bosniaherzegovina": "bosniaandherzegovina",
            "bosniaandherzegovina": "bosniaandherzegovina",
            "czechrepublic": "czechia",
            "czechia": "czechia",
            "ivorycoast": "cotedivoire",
            "cotedivoire": "cotedivoire",
            "curacao": "curacao"
        ]

        return aliases[normalizedName] ?? normalizedName
    }

    private func normalizeTeamName(_ name: String) -> String {
        name
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "’", with: "")
    }

    private var liveDataCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("🔄 Live Data Center")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Text("football-data.org")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.cyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.cyan.opacity(0.12))
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                Image(systemName: apiService.isLoading ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(apiService.isLoading ? .orange : .green)

                VStack(alignment: .leading, spacing: 4) {
                    Text(apiService.statusMessage)
                        .font(.headline)
                        .foregroundStyle(apiService.isLoading ? .orange : .green)

                    if let lastUpdate = apiService.lastUpdate {
                        Text("Last Update: \(lastUpdate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("🔄 Live Data Center")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            HStack(spacing: 14) {
                liveDataMetricCard(title: "Loaded Matches", value: "\(apiService.lastFetchedMatchCount)", icon: "sportscourt.fill")
                liveDataMetricCard(title: "Status", value: apiService.isLoading ? "Active" : "Ready", icon: "antenna.radiowaves.left.and.right")
            }

            Button {
                Task {
                    await loadDashboardRemoteMatches()
                }
            } label: {
                Label(apiService.isLoading ? "Updating..." : "Update Data", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .disabled(apiService.isLoading)

            NavigationLink {
                RemoteMatchesView()
            } label: {
                Label("View Live Matches", systemImage: "globe")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        )
    }

    private func liveDataMetricCard(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    
    private func dashboardCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
    
    private var favoriteTeamCard: some View {
        let favoriteTeam = sampleTeams.first { $0.id == favoriteTeamID }
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("⭐ Favorite Team")
                .font(.title2)
                .fontWeight(.bold)
            
            if let favoriteTeam {
                HStack {
                    Text("\(favoriteTeam.flag) \(favoriteTeam.name)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("Group \(favoriteTeam.group)")
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("No favorite team selected yet. You can star a team from the Groups screen.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        )
    }

    private var tournamentFavoritesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🏆 Tournament Favorites")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Rating")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text("Favorites are estimated based on team ratings and overall tournament strength.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
                ForEach(Array(tournamentFavorites.enumerated()), id: \.element.id) { index, team in
                    HStack(spacing: 10) {
                        Text("\(index + 1)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: 28)
                        
                        Text(team.flag)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(team.name)
                                .font(.headline)
                                .lineLimit(1)
                            
                            Text("Group \(team.group)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(team.rating)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.yellow)
                    }
                    .padding()
                    .background(index == 0 ? Color.yellow.opacity(0.18) : Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(index == 0 ? Color.yellow.opacity(0.45) : Color.white.opacity(0.10), lineWidth: 1)
                    )
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
    
    private var tournamentFavorites: [Team] {
        sampleTeams
            .sorted {
                if $0.rating != $1.rating {
                    return $0.rating > $1.rating
                }
                return $0.name < $1.name
            }
            .prefix(6)
            .map { $0 }
    }

    private var resetScoresCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🧹 Data Management")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("You can delete all test match scores. Your favorite team selection will be preserved.")
                .foregroundStyle(.secondary)
            
            Button(role: .destructive) {
                resetScores()
            } label: {
                Label("Reset All Scores", systemImage: "trash")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                simulateGroupMatches()
            } label: {
                Label("Simulate Group Matches", systemImage: "dice.fill")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        )
    }

    private var groupLeadersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏅 Group Leaders")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                ForEach(groupLeaders, id: \.group) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Group \(item.group)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("\(item.team.flag) \(item.team.name)")
                                .font(.headline)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Text("\(item.points) pts")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
    
    private var groupLeaders: [(group: String, team: Team, points: Int)] {
        let groups = Array(Set(sampleTeams.map { $0.group })).sorted()
        
        return groups.compactMap { group in
            guard let leader = calculateStandings(for: group).first else {
                return nil
            }
            
            return (group: group, team: leader.team, points: leader.points)
        }
    }
    
    private func calculateStandings(for group: String) -> [Standing] {
        let groupTeams = sampleTeams.filter { $0.group == group }
        let groupMatches = matches.filter { $0.group == group }
        
        var table = groupTeams.map { Standing(team: $0) }
        
        for match in groupMatches {
            guard let homeScore = match.homeScore,
                  let awayScore = match.awayScore else {
                continue
            }
            
            guard let homeIndex = table.firstIndex(where: { $0.team.id == match.homeTeam.id }),
                  let awayIndex = table.firstIndex(where: { $0.team.id == match.awayTeam.id }) else {
                continue
            }
            
            table[homeIndex].played += 1
            table[awayIndex].played += 1
            
            table[homeIndex].goalsFor += homeScore
            table[homeIndex].goalsAgainst += awayScore
            
            table[awayIndex].goalsFor += awayScore
            table[awayIndex].goalsAgainst += homeScore
            
            if homeScore > awayScore {
                table[homeIndex].won += 1
                table[awayIndex].lost += 1
            } else if homeScore < awayScore {
                table[awayIndex].won += 1
                table[homeIndex].lost += 1
            } else {
                table[homeIndex].drawn += 1
                table[awayIndex].drawn += 1
            }
        }
        
        return table.sorted {
            if $0.points != $1.points {
                return $0.points > $1.points
            }
            
            if $0.goalDifference != $1.goalDifference {
                return $0.goalDifference > $1.goalDifference
            }
            
            if $0.goalsFor != $1.goalsFor {
                return $0.goalsFor > $1.goalsFor
            }
            
            return $0.team.name < $1.team.name
        }
    }
    
    private var playedMatchCount: Int {
        matches.filter { $0.homeScore != nil && $0.awayScore != nil }.count
    }
    
    private var totalGoals: Int {
        matches.reduce(0) { partialResult, match in
            partialResult + (match.homeScore ?? 0) + (match.awayScore ?? 0)
        }
    }
    
    private func resetScores() {
        matches = sampleMatches
        saveMatches()
    }
    
    private func simulateGroupMatches() {
        for index in matches.indices {
            guard matches[index].homeScore == nil,
                  matches[index].awayScore == nil else {
                continue
            }

            var homeRating = matches[index].homeTeam.rating
            var awayRating = matches[index].awayTeam.rating

            if isHostNation(matches[index].homeTeam) {
                homeRating += 3
            }

            if isHostNation(matches[index].awayTeam) {
                awayRating += 3
            }

            let simulatedScore = simulateScore(homeRating: homeRating, awayRating: awayRating)
            matches[index].homeScore = simulatedScore.home
            matches[index].awayScore = simulatedScore.away
        }

        saveMatches()
    }

    private func isHostNation(_ team: Team) -> Bool {
        ["United States", "USA", "Mexico", "Canada"].contains(team.name)
    }

    private func simulateScore(homeRating: Int, awayRating: Int) -> (home: Int, away: Int) {
        let difference = homeRating - awayRating
        let surpriseRoll = Int.random(in: 1...100)

        if abs(difference) <= 4 {
            if surpriseRoll <= 35 {
                let drawScore = Int.random(in: 0...2)
                return (drawScore, drawScore)
            }
            return closeMatchScore()
        }

        if difference >= 15 {
            if surpriseRoll <= 5 {
                return upsetScore(favoriteIsHome: true)
            }
            return (Int.random(in: 2...5), Int.random(in: 0...1))
        }

        if difference >= 8 {
            if surpriseRoll <= 8 {
                return upsetScore(favoriteIsHome: true)
            }
            return (Int.random(in: 1...4), Int.random(in: 0...2))
        }

        if difference <= -15 {
            if surpriseRoll <= 5 {
                return upsetScore(favoriteIsHome: false)
            }
            return (Int.random(in: 0...1), Int.random(in: 2...5))
        }

        if difference <= -8 {
            if surpriseRoll <= 8 {
                return upsetScore(favoriteIsHome: false)
            }
            return (Int.random(in: 0...2), Int.random(in: 1...4))
        }

        if surpriseRoll <= 25 {
            let drawScore = Int.random(in: 0...2)
            return (drawScore, drawScore)
        }

        return closeMatchScore()
    }

    private func closeMatchScore() -> (home: Int, away: Int) {
        let home = Int.random(in: 0...3)
        let away = Int.random(in: 0...3)
        return (home, away)
    }

    private func upsetScore(favoriteIsHome: Bool) -> (home: Int, away: Int) {
        if favoriteIsHome {
            return (Int.random(in: 0...1), Int.random(in: 1...3))
        } else {
            return (Int.random(in: 1...3), Int.random(in: 0...1))
        }
    }

    private func loadMatches() {
        guard !savedMatchesData.isEmpty else {
            matches = sampleMatches
            return
        }

        do {
            matches = try JSONDecoder().decode([Match].self, from: savedMatchesData)
        } catch {
            matches = sampleMatches
        }
    }

    private func saveMatches() {
        do {
            savedMatchesData = try JSONEncoder().encode(matches)
        } catch {
            print("Match scores could not be saved.")
        }
    }
}
