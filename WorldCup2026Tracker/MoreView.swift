import SwiftUI

struct MoreView: View {
    @Binding var matches: [Match]
    @Binding var favoriteTeamID: String
    @AppStorage("selectedTournament") private var selectedTournament: String = ""

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("👥 Groups") {
                    GroupsView(teams: sampleTeams, matches: matches, favoriteTeamID: $favoriteTeamID)
                }

                NavigationLink("🏆 Knockout Stage") {
                    KnockoutView(teams: sampleTeams, matches: matches)
                }
                
                NavigationLink("📊 Statistics") {
                    StatisticsView(teams: sampleTeams, matches: matches)
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
    MoreView(matches: .constant(sampleMatches), favoriteTeamID: .constant(""))
}
