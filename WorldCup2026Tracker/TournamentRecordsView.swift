//
//  TournamentRecordsView.swift
//  WorldCup2026Tracker
//
//  Created by Selcuk Albut on 18.06.2026.
//

import SwiftUI

struct TournamentRecordsView: View {
    let teams: [Team]
    let matches: [Match]

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
                Text("🏆 Tournament Records")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack(spacing: 8) {
                    recordSummaryCard(title: "Played", value: "\(playedMatches.count)", icon: "sportscourt.fill")
                    recordSummaryCard(title: "Goals", value: "\(totalGoals)", icon: "soccerball")
                    recordSummaryCard(title: "Avg", value: averageGoals, icon: "chart.bar.fill")
                }

                recordsCard(title: "⭐ Team Records") {
                    recordRow(title: "Highest Scoring Team", value: highestScoringTeam)
                    recordRow(title: "Most Wins", value: mostWinsTeam)
                    recordRow(title: "Best Defense", value: bestDefenseTeam)
                    recordRow(title: "Best Goal Difference", value: bestGoalDifferenceTeam)
                }

                recordsCard(title: "⚽ Match Records") {
                    recordRow(title: "Highest Scoring Match", value: highestScoringMatch)
                    recordRow(title: "Biggest Win", value: biggestWin)
                    recordRow(title: "Most Goals by One Team", value: mostGoalsByOneTeam)
                }

                recordsCard(title: "📊 Tournament Progress") {
                    recordRow(title: "Total Matches", value: "\(effectiveMatches.count)")
                    recordRow(title: "Matches Played", value: "\(playedMatches.count)")
                    recordRow(title: "Remaining Matches", value: "\(remainingMatches.count)")
                    recordRow(title: "Total Goals", value: "\(totalGoals)")
                    recordRow(title: "Average Goals / Match", value: averageGoals)
                }
            }
            .padding()
        }
        .onAppear {
            let currentPlayedCount = matches.filter { $0.homeScore != nil && $0.awayScore != nil }.count
            let savedPlayedCount: Int

            if !savedLocalMatchesData.isEmpty,
               let decoded = try? JSONDecoder().decode([Match].self, from: savedLocalMatchesData) {
                savedPlayedCount = decoded.filter { $0.homeScore != nil && $0.awayScore != nil }.count
            } else {
                savedPlayedCount = -1
            }

            print("===== RECORDS DEBUG =====")
            print("Input matches: \(matches.count)")
            print("Input played matches: \(currentPlayedCount)")
            print("Saved data bytes: \(savedLocalMatchesData.count)")
            print("Saved played matches: \(savedPlayedCount)")
            print("Effective matches: \(effectiveMatches.count)")
            print("Effective played matches: \(playedMatches.count)")

            if let firstPlayed = playedMatches.first {
                print("First played:")
                print("\(firstPlayed.homeTeam.name) \(firstPlayed.homeScore ?? -1)-\(firstPlayed.awayScore ?? -1) \(firstPlayed.awayTeam.name)")
            }

            print("=========================")
        }
        .navigationTitle("Records")
    }

    private func recordSummaryCard(title: String, value: String, icon: String) -> some View {
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
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func recordsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            content()
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        )
    }

    private func recordRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer(minLength: 12)

            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 6)
    }

    private var playedMatches: [Match] {
        effectiveMatches.filter { $0.homeScore != nil && $0.awayScore != nil }
    }

    private var remainingMatches: [Match] {
        effectiveMatches.filter { $0.homeScore == nil || $0.awayScore == nil }
    }

    private var totalGoals: Int {
        playedMatches.reduce(0) {
            $0 + ($1.homeScore ?? 0) + ($1.awayScore ?? 0)
        }
    }

    private var averageGoals: String {
        guard !playedMatches.isEmpty else { return "0.0" }
        let average = Double(totalGoals) / Double(playedMatches.count)
        return String(format: "%.1f", average)
    }

    private var allStandings: [Standing] {
        let groups = Array(Set(teams.map { $0.group })).sorted()
        return groups.flatMap { calculateStandings(for: $0) }
    }

    private var highestScoringTeam: String {
        guard let team = allStandings.max(by: { $0.goalsFor < $1.goalsFor }) else {
            return "-"
        }
        return "\(team.team.flag) \(team.team.name) - \(team.goalsFor) goals"
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
        return "\(team.team.flag) \(team.team.name) - \(team.goalsAgainst) conceded"
    }

    private var bestGoalDifferenceTeam: String {
        guard let team = allStandings.max(by: { $0.goalDifference < $1.goalDifference }) else {
            return "-"
        }
        return "\(team.team.flag) \(team.team.name) - AV \(team.goalDifference)"
    }

    private var highestScoringMatch: String {
        guard let match = playedMatches.max(by: {
            (($0.homeScore ?? 0) + ($0.awayScore ?? 0)) < (($1.homeScore ?? 0) + ($1.awayScore ?? 0))
        }) else {
            return "-"
        }

        let goals = (match.homeScore ?? 0) + (match.awayScore ?? 0)
        return "\(match.homeTeam.flag) \(match.homeTeam.name) \(match.homeScore ?? 0)-\(match.awayScore ?? 0) \(match.awayTeam.flag) \(match.awayTeam.name) (\(goals) goals)"
    }

    private var biggestWin: String {
        guard let match = playedMatches.max(by: {
            abs(($0.homeScore ?? 0) - ($0.awayScore ?? 0)) < abs(($1.homeScore ?? 0) - ($1.awayScore ?? 0))
        }) else {
            return "-"
        }

        let margin = abs((match.homeScore ?? 0) - (match.awayScore ?? 0))
        return "\(match.homeTeam.flag) \(match.homeTeam.name) \(match.homeScore ?? 0)-\(match.awayScore ?? 0) \(match.awayTeam.flag) \(match.awayTeam.name) (Margin \(margin))"
    }

    private var mostGoalsByOneTeam: String {
        guard let match = playedMatches.max(by: {
            max($0.homeScore ?? 0, $0.awayScore ?? 0) < max($1.homeScore ?? 0, $1.awayScore ?? 0)
        }) else {
            return "-"
        }

        let homeScore = match.homeScore ?? 0
        let awayScore = match.awayScore ?? 0

        if homeScore >= awayScore {
            return "\(match.homeTeam.flag) \(match.homeTeam.name) - \(homeScore) goals"
        } else {
            return "\(match.awayTeam.flag) \(match.awayTeam.name) - \(awayScore) goals"
        }
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
