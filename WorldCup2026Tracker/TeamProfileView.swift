//
//  TeamProfileView.swift
//  GlobalSportsTracker
//
//  Created by Selcuk Albut on 5.06.2026.
//

import SwiftUI

struct TeamProfileView: View {
    let team: Team
    let matches: [Match]
    let favoriteTeamID: String
    
    private var teamStanding: Standing {
        var standing = Standing(team: team)
        
        for match in teamMatches {
            guard let homeScore = match.homeScore,
                  let awayScore = match.awayScore else {
                continue
            }

            let normalizedTeamName = normalizeTeamName(team.name)
            let isHomeTeam = normalizeTeamName(match.homeTeam.name) == normalizedTeamName
            let isAwayTeam = normalizeTeamName(match.awayTeam.name) == normalizedTeamName

            guard isHomeTeam || isAwayTeam else {
                continue
            }

            standing.played += 1

            if isHomeTeam {
                standing.goalsFor += homeScore
                standing.goalsAgainst += awayScore

                if homeScore > awayScore {
                    standing.won += 1
                } else if homeScore < awayScore {
                    standing.lost += 1
                } else {
                    standing.drawn += 1
                }
            } else if isAwayTeam {
                standing.goalsFor += awayScore
                standing.goalsAgainst += homeScore

                if awayScore > homeScore {
                    standing.won += 1
                } else if awayScore < homeScore {
                    standing.lost += 1
                } else {
                    standing.drawn += 1
                }
            }
        }
        
        return standing
    }
    
    private var teamMatches: [Match] {
        let normalizedTeamName = normalizeTeamName(team.name)

        let filtered = matches.filter { match in
            normalizeTeamName(match.homeTeam.name) == normalizedTeamName ||
            normalizeTeamName(match.awayTeam.name) == normalizedTeamName
        }

        return filtered
    }

    private func normalizeTeamName(_ name: String) -> String {
        name
            .lowercased()
            .replacingOccurrences(of: "türkiye", with: "turkey")
            .replacingOccurrences(of: "south korea", with: "korea republic")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var completedMatches: [Match] {
        teamMatches.filter { $0.homeScore != nil && $0.awayScore != nil }
    }
    
    private var upcomingMatches: [Match] {
        teamMatches.filter { $0.homeScore == nil || $0.awayScore == nil }
    }
    
    private var isFavorite: Bool {
        team.id == favoriteTeamID
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerCard
                statisticsGrid
                matchesSection(title: "Completed Matches", matches: completedMatches)
                matchesSection(title: "Upcoming Matches", matches: upcomingMatches)
            }
            .padding(32)
        }
        .navigationTitle(team.name)
        .onAppear {
            print("========== Team Profile Debug ==========")
            print("Selected team: \(team.name) | ID: \(team.id)")
            print("Total matches received by TeamProfileView: \(matches.count)")
            print("Team matches found: \(teamMatches.count)")
            print("Completed team matches found: \(completedMatches.count)")
            for match in teamMatches {
                let homeScoreText = match.homeScore != nil ? String(match.homeScore!) : "nil"
                let awayScoreText = match.awayScore != nil ? String(match.awayScore!) : "nil"

                print("PROFILE MATCH: \(match.homeTeam.name) \(homeScoreText) - \(awayScoreText) \(match.awayTeam.name)")
            }
            print("Standing calculated: P=\(teamStanding.played), W=\(teamStanding.won), D=\(teamStanding.drawn), L=\(teamStanding.lost), GF=\(teamStanding.goalsFor), GA=\(teamStanding.goalsAgainst), Pts=\(teamStanding.points)")
            print("========================================")
        }
    }
    
    private var headerCard: some View {
        HStack(spacing: 20) {
            Text(team.flag)
                .font(.system(size: 72))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(team.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.title2)
                    }
                }
                
                Text("Group \(team.group)")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                Text(isFavorite ? "Favorite Team" : "Team Profile")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isFavorite ? Color.yellow.opacity(0.22) : Color.blue.opacity(0.16))
                    .clipShape(Capsule())
            }
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
    
    private var statisticsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
            statCard(title: "Played", value: "\(teamStanding.played)", icon: "sportscourt.fill")
            statCard(title: "Wins", value: "\(teamStanding.won)", icon: "checkmark.circle.fill")
            statCard(title: "Draws", value: "\(teamStanding.drawn)", icon: "minus.circle.fill")
            statCard(title: "Losses", value: "\(teamStanding.lost)", icon: "xmark.circle.fill")
            statCard(title: "Goal Scored", value: "\(teamStanding.goalsFor)", icon: "soccerball")
            statCard(title: "Goal Conceded", value: "\(teamStanding.goalsAgainst)", icon: "shield.fill")
            statCard(title: "Goal Difference", value: "\(teamStanding.goalDifference)", icon: "plus.forwardslash.minus")
            statCard(title: "Points", value: "\(teamStanding.points)", icon: "star.circle.fill")
        }
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
    
    private func matchesSection(title: String, matches: [Match]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            if matches.isEmpty {
                Text("No matches to display.")
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                ForEach(matches) { match in
                    matchRow(match)
                }
            }
        }
    }
    
    private func matchRow(_ match: Match) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(match.homeTeam.flag) \(match.homeTeam.name)")
                    .fontWeight(normalizeTeamName(match.homeTeam.name) == normalizeTeamName(team.name) ? .bold : .regular)
                
                Spacer()
                
                if let homeScore = match.homeScore,
                   let awayScore = match.awayScore {
                    Text("\(homeScore) - \(awayScore)")
                        .font(.headline)
                        .fontWeight(.bold)
                } else {
                    Text("vs")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(match.awayTeam.flag) \(match.awayTeam.name)")
                    .fontWeight(normalizeTeamName(match.awayTeam.name) == normalizeTeamName(team.name) ? .bold : .regular)
            }
            
            HStack {
                Text(match.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if !match.venue.isEmpty {
                    Text(match.venue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
}
