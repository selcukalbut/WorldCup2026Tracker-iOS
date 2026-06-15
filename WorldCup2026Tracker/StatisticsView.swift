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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("📈 Tournament Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    statCard(title: "Matches", value: "\(playedMatches.count)", icon: "sportscourt.fill")
                    statCard(title: "Goals", value: "\(totalGoals)", icon: "soccerball")
                    statCard(title: "Teams", value: "\(teams.count)", icon: "person.3.fill")
                    statCard(title: "Groups", value: "\(Set(teams.map { $0.group }).count)", icon: "square.grid.2x2.fill")
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
    
    private var playedMatches: [Match] {
        matches.filter { $0.homeScore != nil && $0.awayScore != nil }
    }
    
    private var totalGoals: Int {
        playedMatches.reduce(0) {
            $0 + ($1.homeScore ?? 0) + ($1.awayScore ?? 0)
        }
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
        
        return table
    }
}
