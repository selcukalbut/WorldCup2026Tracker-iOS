import SwiftUI

struct RemoteMatchesView: View {
    @StateObject private var apiService = APIService.shared
    @Binding private var localMatches: [Match]
    @State private var matches: [RemoteMatch] = []
    @State private var searchText = ""

    init(localMatches: Binding<[Match]> = .constant([])) {
        self._localMatches = localMatches
    }

    private var filteredMatches: [RemoteMatch] {
        guard !searchText.isEmpty else { return matches }
        return matches.filter {
            $0.homeTeam.localizedCaseInsensitiveContains(searchText) ||
            $0.awayTeam.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedMatches: [(date: Date, matches: [RemoteMatch])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredMatches) { match in
            calendar.startOfDay(for: match.matchDate ?? Date.distantFuture)
        }

        return grouped
            .map { item in
                (
                    date: item.key,
                    matches: item.value.sorted {
                        ($0.matchDate ?? Date.distantFuture) < ($1.matchDate ?? Date.distantFuture)
                    }
                )
            }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard

                TextField("Search team name...", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(groupedMatches, id: \.date) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            dateHeader(for: group.date, matchCount: group.matches.count)

                            LazyVStack(spacing: 12) {
                                ForEach(group.matches) { match in
                                    matchCard(match)
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("Live Match Data")
        .task {
            await loadMatches()
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("🌐 Live Scores")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("football-data.org live data")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    Task {
                        await loadMatches()
                    }
                } label: {
                    Label(apiService.isLoading ? "Loading..." : "Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
                .disabled(apiService.isLoading)
            }

            HStack(spacing: 8) {
                summaryCard("Total", value: "\(matches.count)", icon: "sportscourt.fill")
                summaryCard("Filtered", value: "\(filteredMatches.count)", icon: "line.3.horizontal.decrease.circle")
                summaryCard("Status", value: apiService.isLoading ? "Active" : "Ready", icon: "antenna.radiowaves.left.and.right")
            }

            Text(apiService.statusMessage)
                .font(.subheadline)
                .foregroundStyle(apiService.isLoading ? .orange : .secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    private func dateHeader(for date: Date, matchCount: Int) -> some View {
        HStack {
            Label(dateTitle(for: date), systemImage: "calendar")
                .font(.title3)
                .fontWeight(.bold)

            Spacer()

            Text("\(matchCount) match")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.blue.opacity(0.75))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.cyan.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func dateTitle(for date: Date) -> String {
        if date == Date.distantFuture {
            return "Unscheduled Matches"
        }

        return date.formatted(date: .complete, time: .omitted)
    }

    private func matchCard(_ match: RemoteMatch) -> some View {
        VStack(spacing: 12) {
            HStack {
                statusBadge(for: match)

                Spacer()

                if let date = match.matchDate {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.03, green: 0.12, blue: 0.24).opacity(0.70))
                }
            }

            HStack(spacing: 14) {
                remoteTeamName(match.homeTeam)

                Text(scoreText(for: match))
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                    .frame(width: 94, height: 44)
                    .background(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.90), Color.cyan.opacity(0.70)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                remoteTeamName(match.awayTeam)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.78),
                    Color(red: 0.76, green: 0.92, blue: 0.98).opacity(0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.75), lineWidth: 1.4)
        )
        .shadow(color: Color.blue.opacity(0.12), radius: 8, x: 0, y: 4)
    }
    private func remoteTeamName(_ name: String) -> some View {
        VStack(spacing: 6) {
            Text(flag(for: name))
                .font(.title2)

            Text(name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color(red: 0.03, green: 0.12, blue: 0.24))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
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
            "new zealand": "🇳🇿"
        ]

        return aliases[normalizedName] ?? "🏳️"
    }

    private func statusBadge(for match: RemoteMatch) -> some View {
        let status = match.status ?? "UNKNOWN"
        let text: String
        let color: Color
        let icon: String

        switch status {
        case "LIVE", "IN_PLAY":
            text = "Live"
            color = .green
            icon = "livephoto"
        case "SCHEDULED", "TIMED":
            text = "Scheduled"
            color = .blue
            icon = "calendar"
        case "FINISHED":
            text = "Completed"
            color = .black
            icon = "checkmark.circle.fill"
        case "PAUSED":
            text = "Half Time"
            color = .orange
            icon = "pause.circle.fill"
        case "POSTPONED":
            text = "Postponed"
            color = .orange
            icon = "exclamationmark.triangle.fill"
        default:
            text = status
            color = .gray
            icon = "questionmark.circle.fill"
        }

        return HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
            
            Text(text)
                .font(.caption2)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(color.opacity(0.82))
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }

    private func scoreText(for match: RemoteMatch) -> String {
        if let homeScore = match.homeScore,
           let awayScore = match.awayScore {
            return "\(homeScore) - \(awayScore)"
        }

        return "VS"
    }

    private func summaryCard(_ title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {

            Image(systemName: icon)
                .font(.title3)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .padding(8)
        .background(Color.cyan.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func loadMatches() async {
        do {
            matches = try await apiService.fetchMatches()
            syncRemoteMatchesToLocalMatches(matches)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func syncRemoteMatchesToLocalMatches(_ remoteMatches: [RemoteMatch]) {
        var didUpdate = false
        var matchedCount = 0
        var unmatchedCount = 0

        print("========== Remote Match Sync Started ==========")
        print("Remote matches received: \(remoteMatches.count)")
        print("Local matches available: \(localMatches.count)")

        for remoteMatch in remoteMatches {
            print("REMOTE: \(remoteMatch.homeTeam) - \(remoteMatch.awayTeam) | Score: \(remoteMatch.scoreText) | Status: \(remoteMatch.statusText)")

            guard isSyncableRemoteMatch(remoteMatch),
                  let remoteHomeScore = remoteMatch.homeScore,
                  let remoteAwayScore = remoteMatch.awayScore else {
                print("SKIPPED: No completed/live score available for \(remoteMatch.homeTeam) - \(remoteMatch.awayTeam)")
                continue
            }

            guard let matchIndex = localMatchIndex(for: remoteMatch) else {
                unmatchedCount += 1
                print("NO LOCAL MATCH FOUND: \(remoteMatch.homeTeam) - \(remoteMatch.awayTeam)")
                continue
            }

            matchedCount += 1
            let localMatch = localMatches[matchIndex]
            print("MATCH FOUND: \(localMatch.homeTeam.name) - \(localMatch.awayTeam.name)")

            let isReversed = isReversedMatch(local: localMatches[matchIndex], remote: remoteMatch)
            let newHomeScore = isReversed ? remoteAwayScore : remoteHomeScore
            let newAwayScore = isReversed ? remoteHomeScore : remoteAwayScore

            if localMatches[matchIndex].homeScore != newHomeScore ||
                localMatches[matchIndex].awayScore != newAwayScore {
                localMatches[matchIndex].homeScore = newHomeScore
                localMatches[matchIndex].awayScore = newAwayScore
                didUpdate = true
                print("UPDATED LOCAL SCORE: \(localMatches[matchIndex].homeTeam.name) \(newHomeScore) - \(newAwayScore) \(localMatches[matchIndex].awayTeam.name)")
            } else {
                print("NO SCORE CHANGE NEEDED")
            }
        }

        print("Matched remote matches: \(matchedCount)")
        print("Unmatched remote matches: \(unmatchedCount)")
        print("Did update local matches: \(didUpdate)")
        print("========== Remote Match Sync Finished ==========")
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
        localMatches.firstIndex { localMatch in
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
}

#Preview {
    RemoteMatchesView()
}
