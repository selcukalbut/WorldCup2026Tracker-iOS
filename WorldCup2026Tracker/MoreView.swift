import SwiftUI

struct MoreView: View {
    @Binding var matches: [Match]
    @Binding var favoriteTeamID: String
    @AppStorage("selectedTournament") private var selectedTournament: String = ""

    private var teamsFromMatches: [Team] {
        var seenIDs: Set<String> = []
        var result: [Team] = []

        for match in matches {
            if !seenIDs.contains(match.homeTeam.id) {
                result.append(match.homeTeam)
                seenIDs.insert(match.homeTeam.id)
            }

            if !seenIDs.contains(match.awayTeam.id) {
                result.append(match.awayTeam)
                seenIDs.insert(match.awayTeam.id)
            }
        }

        return result.sorted {
            if $0.group != $1.group {
                return $0.group < $1.group
            }
            return $0.name < $1.name
        }
    }

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("👥 Groups") {
                    GroupsView(teams: teamsFromMatches, matches: matches, favoriteTeamID: $favoriteTeamID)
                }

                NavigationLink("🏆 Knockout Stage") {
                    KnockoutView(teams: teamsFromMatches, matches: matches)
                }
                
                NavigationLink("📊 Statistics") {
                    StatisticsView(teams: teamsFromMatches, matches: matches)
                }

                NavigationLink("🏆 Qualification Tracker") {
                    QualificationTrackerView(
                        teams: teamsFromMatches, matches: matches)
                }
                
                NavigationLink("🏆 Tournament Records") {
                    TournamentRecordsView(teams: teamsFromMatches, matches: matches)
                }

                NavigationLink("🏟 Host Cities") {
                    HostCitiesView(matches: matches)
                }

                Section("Tournament") {
                    Button {
                        selectedTournament = ""
                    } label: {
                        Label("Change Tournament", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .foregroundStyle(.orange)
                }
            }
            .navigationTitle("More")
        }
    }
}

#Preview {
    MoreView(matches: .constant([]), favoriteTeamID: .constant(""))
}
