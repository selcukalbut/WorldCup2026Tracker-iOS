import SwiftUI

struct StandingsView: View {
    let teams: [Team]
    let matches: [Match]
    let favoriteTeamID: String
    
    @StateObject private var apiService = APIService.shared
    
    private var groups: [String] {
        Array(Set(teams.map { $0.group })).sorted()
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 340), spacing: 16)],
                spacing: 16
            ) {
                ForEach(groups, id: \.self) { group in
                    groupStandingCard(group: group)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
        }
        .navigationTitle("Standings")
        .task {
            await apiService.fetchStandings()
        }
    }
    
    private func groupStandingCard(group: String) -> some View {
        let standings = apiStandingsForGroup(group)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Group \(group)", systemImage: "soccerball")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("Top 2 advance")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
            }
            
            VStack(spacing: 0) {
                standingHeader
                
                ForEach(Array(standings.enumerated()), id: \.element.id) { index, standing in
                    standingRow(index: index, standing: standing)
                    
                    if index < standings.count - 1 {
                        Divider()
                    }
                }
            }
            .background(Color.white.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.cyan.opacity(0.55), lineWidth: 1.2)
            )
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.32, blue: 0.72),
                    Color(red: 0.08, green: 0.24, blue: 0.56)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    private var standingHeader: some View {
        HStack(spacing: 4) {
            Text("#")
                .frame(width: 24, alignment: .center)
            
            Text("Team")
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
            
            Text("O").frame(width: 24)
            Text("G").frame(width: 24)
            Text("B").frame(width: 24)
            Text("M").frame(width: 24)
            Text("AV").frame(width: 30)
            Text("P").frame(width: 30)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.white.opacity(0.92))
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.12))
    }
    
    private func standingRow(index: Int, standing: Standing) -> some View {
        HStack(spacing: 4) {
            HStack(spacing: 2) {
                if index == 0 {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }

                Text("\(index + 1)")
                    .fontWeight(.bold)
            }
            .frame(width: 24, alignment: .center)
            
            HStack(spacing: 5) {
                Text(standing.team.flag)
                    .font(.caption)
                Text(standing.team.name)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                    .font(.caption)
                    .fontWeight(index < 2 || standing.team.id == favoriteTeamID ? .semibold : .regular)
                
                if standing.team.id == favoriteTeamID {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("\(standing.played)").frame(width: 24)
            Text("\(standing.won)").frame(width: 24)
            Text("\(standing.drawn)").frame(width: 24)
            Text("\(standing.lost)").frame(width: 24)
            Text("\(standing.goalDifference)").frame(width: 30)
            Text("\(standing.points)")
                .fontWeight(.bold)
                .frame(width: 30)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(rowBackground(index: index, standing: standing))
    }
    
    private func rowBackground(index: Int, standing: Standing) -> Color {
        if standing.team.id == favoriteTeamID {
            return Color.yellow.opacity(0.30)
        }

        switch index {
        case 0:
            return Color(red: 0.82, green: 0.68, blue: 0.18).opacity(0.35) // Gold
        case 1:
            return Color(red: 0.72, green: 0.76, blue: 0.82).opacity(0.30) // Silver
        case 2:
            return Color(red: 0.80, green: 0.50, blue: 0.25).opacity(0.25) // Bronze
        default:
            return Color.white.opacity(0.04)
        }
    }
    
    private func apiStandingsForGroup(_ group: String) -> [Standing] {
        let apiGroupName = "Group \(group)"

        let apiRows = apiService.standings(for: apiGroupName)

        if apiRows.isEmpty {
            return calculateStandings(for: group)
        }

        return apiRows.compactMap { row in
            guard let team = teams.first(where: {
                $0.name == row.team.name ||
                ($0.name == "Korea Republic" && row.team.name == "South Korea") ||
                ($0.name == "United States" && row.team.name == "USA") ||
                ($0.name == "Bosnia and Herzegovina" && row.team.name == "Bosnia & Herzegovina") ||
                ($0.name == "Cape Verde" && row.team.name == "Cape Verde Islands") ||
                ($0.name == "DR Congo" && row.team.name == "Congo DR") ||
                ($0.name == "Côte d'Ivoire" && row.team.name == "Ivory Coast")
            }) else {
                return nil
            }

            var standing = Standing(team: team)
            standing.played = row.all.played
            standing.won = row.all.win
            standing.drawn = row.all.draw
            standing.lost = row.all.lose
            standing.goalsFor = row.all.goals.for
            standing.goalsAgainst = row.all.goals.against
            return standing
        }
    }
    
    private func calculateStandings(for group: String) -> [Standing] {
        let groupTeams = teams.filter { $0.group == group }
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
}
