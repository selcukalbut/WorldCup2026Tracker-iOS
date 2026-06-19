//
//  StatisticsView.swift
//  GlobalSportsTracker
//
//  Created by Selcuk Albut on 4.06.2026.
//

import SwiftUI

struct StatisticsView: View {
    let teams: [Team]
    let matches: [Match]

    @AppStorage("savedKnockoutMatches") private var savedKnockoutData: Data = Data()
    @AppStorage("savedLocalMatches") private var savedLocalMatchesData: Data = Data()

    private var effectiveMatches: [Match] {
        guard !savedLocalMatchesData.isEmpty,
              let decoded = try? JSONDecoder().decode([Match].self, from: savedLocalMatchesData),
              !decoded.isEmpty else {
            return matches
        }

        let currentPlayedCount = matches.filter { $0.homeScore != nil && $0.awayScore != nil }.count
        let savedPlayedCount = decoded.filter { $0.homeScore != nil && $0.awayScore != nil }.count

        return savedPlayedCount > currentPlayedCount ? decoded : matches
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("📈 Tournament Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    statCard(title: "Played", value: "\(playedMatches.count)", icon: "sportscourt.fill")
                    statCard(title: "Goals", value: "\(totalGoals)", icon: "soccerball")
                    statCard(title: "Avg Goals", value:
                             averageGoals, icon: "chart.bar.fill")
                    statCard(title: "Teams", value: "\(teams.count)", icon: "person.3.fill")
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("🏅 Team Statistics")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    statisticRow(title: "Highest Scoring Team", value: topScoringTeam)
                    statisticRow(title: "Best Goal Difference", value: bestGoalDifferenceTeam)
                    statisticRow(title: "Most Wins", value: mostWinsTeam)
                    statisticRow(title: "Best Defense", value: bestDefenseTeam)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 12) {

                    Text("🏆 Tournament Summary")
                        .font(.title2)
                        .fontWeight(.bold)

                    statisticRow(
                        title: "Champion",
                        value: championTeam
                    )

                    statisticRow(
                        title: "Runner-Up",
                        value: runnerUpTeam
                    )

                    statisticRow(
                        title: "Third Place",
                        value: thirdPlaceTeam
                    )
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 12) {
                    Text("⭐ Top Teams")
                        .font(.title2)
                        .fontWeight(.bold)

                    rankingSection(title: "Highest Scoring Teams", rows: topScoringTeams)
                    rankingSection(title: "Most Wins", rows: mostWinsTeams)
                    rankingSection(title: "Best Goal Difference", rows: bestGoalDifferenceTeams)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 12) {
                    Text("🌍 Group Rankings")
                        .font(.title2)
                        .fontWeight(.bold)

                    rankingSection(title: "Most Goals by Group", rows: topGoalGroups)
                    rankingSection(title: "Most Competitive Groups", rows: mostCompetitiveGroups)
                    rankingSection(title: "Best Defensive Groups", rows: bestDefensiveGroups)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 12) {
                    Text("⚔️ Attack & Defense Rankings")
                        .font(.title2)
                        .fontWeight(.bold)

                    rankingSection(title: "Best Attacks", rows: bestAttacks)
                    rankingSection(title: "Best Defenses", rows: bestDefenses)
                    rankingSection(title: "Unbeaten Teams", rows: unbeatenTeams)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 12) {
                    Text("🏅 Tournament Awards")
                        .font(.title2)
                        .fontWeight(.bold)

                    statisticRow(title: "Golden Boot Team", value: topScoringTeam)
                    statisticRow(title: "Best Defense", value: bestDefenseTeam)
                    statisticRow(title: "Most Wins", value: mostWinsTeam)
                    statisticRow(title: "Champion", value: championTeam)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 12) {
                    Text("🥊 Knockout Statistics")
                        .font(.title2)
                        .fontWeight(.bold)

                    statisticRow(title: "Round of 32", value: "\(savedKnockoutResults?.roundOf32.count ?? 0) matches")
                    statisticRow(title: "Round of 16", value: "\(savedKnockoutResults?.roundOf16.count ?? 0) matches")
                    statisticRow(title: "Quarter Finals", value: "\(savedKnockoutResults?.quarterFinal.count ?? 0) matches")
                    statisticRow(title: "Semi Finals", value: "\(savedKnockoutResults?.semiFinal.count ?? 0) matches")
                    statisticRow(title: "Final", value: "\(savedKnockoutResults?.final.count ?? 0) match")
                    statisticRow(title: "Third Place", value: "\(savedKnockoutResults?.thirdPlace.count ?? 0) match")
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("📊 Match Outcomes")
                        .font(.title2)
                        .fontWeight(.bold)

                    statisticRow(title: "Home Wins", value: "\(homeWins)")
                    statisticRow(title: "Away Wins", value: "\(awayWins)")
                    statisticRow(title: "Draws", value: "\(drawMatches)")
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 12) {
                    Text("⚽ Goal Distribution")
                        .font(.title2)
                        .fontWeight(.bold)

                    statisticRow(title: "0–1 Goals", value: "\(lowScoringMatches)")
                    statisticRow(title: "2–3 Goals", value: "\(mediumScoringMatches)")
                    statisticRow(title: "4+ Goals", value: "\(highScoringMatches)")
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("🔥 Tournament Highlights")
                        .font(.title2)
                        .fontWeight(.bold)

                    statisticRow(title: "Highest Scoring Match", value: highestScoringMatch)
                    statisticRow(title: "Biggest Win", value: biggestWin)
                    statisticRow(title: "Most Goals by One Team", value: mostGoalsByOneTeam)
                    statisticRow(title: "Clean Sheets", value: cleanSheetsLeader)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
            }
            .padding()
        }
        .navigationTitle("Statistics")
    }
    
    private func statCard(title: String, value: String, icon: String) -> some View {
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
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func statisticRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 6)
    }

    private func rankingSection(title: String, rows: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)

            if rows.isEmpty {
                Text("No data yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    HStack {
                        Text("\(index + 1).")
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .frame(width: 28, alignment: .leading)

                        Text(row)
                            .font(.subheadline)
                            .fontWeight(index == 0 ? .bold : .regular)

                        Spacer()
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
    
    private var playedMatches: [Match] {
        effectiveMatches.filter { $0.homeScore != nil && $0.awayScore != nil }
    }
    
    private var totalGoals: Int {
        playedMatches.reduce(0) {
            $0 + ($1.homeScore ?? 0) + ($1.awayScore ?? 0)
        }
    }

    private var averageGoals: String {
        guard !playedMatches.isEmpty else { return "0.0" }
        let avg = Double(totalGoals) / Double(playedMatches.count)
        return String(format: "%.1f", avg)
    }
    
    private var allStandings: [Standing] {
        let groups = Array(Set(teams.map { $0.group })).sorted()
        return groups.flatMap { calculateStandings(for: $0) }
    }
    
    private var topScoringTeam: String {
        guard let team = allStandings.max(by: { $0.goalsFor < $1.goalsFor }) else {
            return "-"
        }
        return "\(team.team.flag) \(team.team.name) - \(team.goalsFor) goals"
    }
    
    private var bestGoalDifferenceTeam: String {
        guard let team = allStandings.max(by: { $0.goalDifference < $1.goalDifference }) else {
            return "-"
        }
        return "\(team.team.flag) \(team.team.name) - AV \(team.goalDifference)"
    }
    
    private var mostWinsTeam: String {
        guard let team = allStandings.max(by: { $0.won < $1.won }) else {
            return "-"
        }
        return "\(team.team.flag) \(team.team.name) - \(team.won) wins"
    }
    
    private var bestDefenseTeam: String {
        guard let team = allStandings.min(by: { $0.goalsAgainst < $1.goalsAgainst }) else {
            return "-"
        }
        return "\(team.team.flag) \(team.team.name) - \(team.goalsAgainst) goals conceded"
    }

    private var topScoringTeams: [String] {
        Array(
            allStandings
                .sorted {
                    if $0.goalsFor != $1.goalsFor {
                        return $0.goalsFor > $1.goalsFor
                    }
                    return $0.goalDifference > $1.goalDifference
                }
                .prefix(5)
        )
        .map { "\($0.team.flag) \($0.team.name) - \($0.goalsFor) goals" }
    }

    private var mostWinsTeams: [String] {
        Array(
            allStandings
                .sorted {
                    if $0.won != $1.won {
                        return $0.won > $1.won
                    }
                    return $0.goalDifference > $1.goalDifference
                }
                .prefix(5)
        )
        .map { "\($0.team.flag) \($0.team.name) - \($0.won) wins" }
    }

    private var bestGoalDifferenceTeams: [String] {
        Array(
            allStandings
                .sorted {
                    if $0.goalDifference != $1.goalDifference {
                        return $0.goalDifference > $1.goalDifference
                    }
                    return $0.goalsFor > $1.goalsFor
                }
                .prefix(5)
        )
        .map { "\($0.team.flag) \($0.team.name) - AV \($0.goalDifference)" }
    }

    private var groupSummaries: [(group: String, goals: Int, goalsAgainst: Int, played: Int, avgGoals: Double, drawRate: Double)] {
        let groups = Array(Set(teams.map { $0.group })).sorted()

        return groups.map { group in
            let groupMatches = effectiveMatches.filter { $0.group == group && $0.homeScore != nil && $0.awayScore != nil }
            let goals = groupMatches.reduce(0) { total, match in
                total + (match.homeScore ?? 0) + (match.awayScore ?? 0)
            }
            let draws = groupMatches.filter { ($0.homeScore ?? 0) == ($0.awayScore ?? 0) }.count
            let drawRate = groupMatches.isEmpty ? 0.0 : Double(draws) / Double(groupMatches.count)
            let avgGoals = groupMatches.isEmpty ? 0.0 : Double(goals) / Double(groupMatches.count)

            return (
                group: group,
                goals: goals,
                goalsAgainst: goals,
                played: groupMatches.count,
                avgGoals: avgGoals,
                drawRate: drawRate
            )
        }
    }

    private var topGoalGroups: [String] {
        Array(
            groupSummaries
                .sorted {
                    if $0.goals != $1.goals {
                        return $0.goals > $1.goals
                    }
                    return $0.avgGoals > $1.avgGoals
                }
                .prefix(5)
        )
        .map { "Group \($0.group) - \($0.goals) goals" }
    }

    private var mostCompetitiveGroups: [String] {
        Array(
            groupSummaries
                .filter { $0.played > 0 }
                .sorted {
                    if $0.drawRate != $1.drawRate {
                        return $0.drawRate > $1.drawRate
                    }
                    return $0.avgGoals < $1.avgGoals
                }
                .prefix(5)
        )
        .map { "Group \($0.group) - \(Int($0.drawRate * 100))% draws" }
    }

    private var bestDefensiveGroups: [String] {
        Array(
            groupSummaries
                .filter { $0.played > 0 }
                .sorted {
                    let lhsAvg = Double($0.goalsAgainst) / Double(max($0.played, 1))
                    let rhsAvg = Double($1.goalsAgainst) / Double(max($1.played, 1))
                    return lhsAvg < rhsAvg
                }
                .prefix(5)
        )
        .map {
            let avg = Double($0.goalsAgainst) / Double(max($0.played, 1))
            return "Group \($0.group) - \(String(format: "%.1f", avg)) goals/match"
        }
    }

    private var bestAttacks: [String] {
        Array(
            allStandings
                .sorted {
                    if $0.goalsFor != $1.goalsFor {
                        return $0.goalsFor > $1.goalsFor
                    }
                    return $0.goalDifference > $1.goalDifference
                }
                .prefix(5)
        )
        .map { "\($0.team.flag) \($0.team.name) - \($0.goalsFor) goals" }
    }

    private var bestDefenses: [String] {
        Array(
            allStandings
                .filter { $0.played > 0 }
                .sorted {
                    if $0.goalsAgainst != $1.goalsAgainst {
                        return $0.goalsAgainst < $1.goalsAgainst
                    }
                    return $0.goalDifference > $1.goalDifference
                }
                .prefix(5)
        )
        .map { "\($0.team.flag) \($0.team.name) - \($0.goalsAgainst) conceded" }
    }

    private var unbeatenTeams: [String] {
        Array(
            allStandings
                .filter { $0.played > 0 && $0.lost == 0 }
                .sorted {
                    if $0.points != $1.points {
                        return $0.points > $1.points
                    }
                    return $0.goalDifference > $1.goalDifference
                }
                .prefix(5)
        )
        .map { "\($0.team.flag) \($0.team.name) - unbeaten" }
    }
    
    private var highestScoringMatch: String {
        guard let match = playedMatches.max(by: {
            (($0.homeScore ?? 0) + ($0.awayScore ?? 0)) < (($1.homeScore ?? 0) + ($1.awayScore ?? 0))
        }) else { return "-" }

        let goals = (match.homeScore ?? 0) + (match.awayScore ?? 0)
        return "\(match.homeTeam.flag) \(match.homeTeam.name) \(match.homeScore ?? 0)-\(match.awayScore ?? 0) \(match.awayTeam.flag) \(match.awayTeam.name) (\(goals) goals)"
    }

    private var biggestWin: String {
        guard let match = playedMatches.max(by: {
            abs(($0.homeScore ?? 0) - ($0.awayScore ?? 0)) < abs(($1.homeScore ?? 0) - ($1.awayScore ?? 0))
        }) else { return "-" }

        let margin = abs((match.homeScore ?? 0) - (match.awayScore ?? 0))
        return "\(match.homeTeam.flag) \(match.homeTeam.name) \(match.homeScore ?? 0)-\(match.awayScore ?? 0) \(match.awayTeam.flag) \(match.awayTeam.name) (Margin \(margin))"
    }

    private var mostGoalsByOneTeam: String {
        guard let match = playedMatches.max(by: {
            max($0.homeScore ?? 0, $0.awayScore ?? 0) < max($1.homeScore ?? 0, $1.awayScore ?? 0)
        }) else { return "-" }

        let homeScore = match.homeScore ?? 0
        let awayScore = match.awayScore ?? 0

        if homeScore >= awayScore {
            return "\(match.homeTeam.flag) \(match.homeTeam.name) - \(homeScore) goals"
        } else {
            return "\(match.awayTeam.flag) \(match.awayTeam.name) - \(awayScore) goals"
        }
    }

    private var cleanSheetsLeader: String {
        var cleanSheets: [String: (team: Team, count: Int)] = [:]

        for match in playedMatches {
            let homeScore = match.homeScore ?? 0
            let awayScore = match.awayScore ?? 0

            if awayScore == 0 {
                cleanSheets[match.homeTeam.id, default: (match.homeTeam, 0)].count += 1
            }

            if homeScore == 0 {
                cleanSheets[match.awayTeam.id, default: (match.awayTeam, 0)].count += 1
            }
        }

        guard let best = cleanSheets.values.max(by: { $0.count < $1.count }) else {
            return "-"
        }

        return "\(best.team.flag) \(best.team.name) - \(best.count)"
    }
    
    private var savedKnockoutResults: SavedKnockoutData? {
        guard !savedKnockoutData.isEmpty else { return nil }
        return try? JSONDecoder().decode(SavedKnockoutData.self, from: savedKnockoutData)
    }

    private var championTeam: String {
        guard let champion = savedKnockoutResults?.final.first?.winner else {
            return "-"
        }
        return "\(champion.flag) \(champion.name)"
    }

    private var runnerUpTeam: String {
        guard let runnerUp = savedKnockoutResults?.final.first?.loser else {
            return "-"
        }
        return "\(runnerUp.flag) \(runnerUp.name)"
    }

    private var thirdPlaceTeam: String {
        guard let thirdPlace = savedKnockoutResults?.thirdPlace.first?.winner else {
            return "-"
        }
        return "\(thirdPlace.flag) \(thirdPlace.name)"
    }
    
    private var homeWins: Int {
        playedMatches.filter {
            ($0.homeScore ?? 0) > ($0.awayScore ?? 0)
        }.count
    }

    private var awayWins: Int {
        playedMatches.filter {
            ($0.awayScore ?? 0) > ($0.homeScore ?? 0)
        }.count
    }

    private var drawMatches: Int {
        playedMatches.filter {
            ($0.homeScore ?? 0) == ($0.awayScore ?? 0)
        }.count
    }

    private var lowScoringMatches: Int {
        playedMatches.filter {
            (($0.homeScore ?? 0) + ($0.awayScore ?? 0)) <= 1
        }.count
    }

    private var mediumScoringMatches: Int {
        playedMatches.filter {
            let total = ($0.homeScore ?? 0) + ($0.awayScore ?? 0)
            return total >= 2 && total <= 3
        }.count
    }

    private var highScoringMatches: Int {
        playedMatches.filter {
            (($0.homeScore ?? 0) + ($0.awayScore ?? 0)) >= 4
        }.count
    }
    
    
    private func calculateStandings(for group: String) -> [Standing] {
        let groupTeams = teams.filter { $0.group == group }
        let groupMatches = effectiveMatches.filter { $0.group == group }
        
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
        
        return table
    }
}
