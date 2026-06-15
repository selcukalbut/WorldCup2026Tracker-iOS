//
//  MatchesView.swift
//  GlobalSportsTracker
//
//  Created by Selcuk Albut on 3.06.2026.
//

import SwiftUI

struct MatchesView: View {
    @Binding var matches: [Match]
    let favoriteTeamID: String

    @State private var selectedFilter = "All"

    private var availableFilters: [String] {
        ["All", "⭐ Favorite Team", "✅ Completed", "⏳ Not Played"] + Array(Set(matches.map { $0.group })).sorted().map { "Group \($0)" }
    }

    private var filteredIndices: [Int] {
        if selectedFilter == "All" {
            return Array(matches.indices)
        }

        if selectedFilter == "⭐ Favorite Team" {
            return matches.indices.filter {
                matches[$0].homeTeam.id == favoriteTeamID ||
                matches[$0].awayTeam.id == favoriteTeamID
            }
        }

        if selectedFilter == "✅ Completed" {
            return matches.indices.filter {
                matches[$0].homeScore != nil && matches[$0].awayScore != nil
            }
        }

        if selectedFilter == "⏳ Not Played" {
            return matches.indices.filter {
                matches[$0].homeScore == nil || matches[$0].awayScore == nil
            }
        }

        let group = selectedFilter.replacingOccurrences(of: "Group ", with: "")

        return matches.indices.filter {
            matches[$0].group == group
        }
    }

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(availableFilters, id: \.self) { filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            Text(filter)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(selectedFilter == filter ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedFilter == filter ? Color.blue : Color.gray.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }

            List {
                ForEach(filteredIndices, id: \.self) { index in
                    let binding = $matches[index]
                    let isFavoriteMatch = binding.wrappedValue.homeTeam.id == favoriteTeamID || binding.wrappedValue.awayTeam.id == favoriteTeamID

                    NavigationLink {
                        MatchCenterView(
                            match: binding,
                            favoriteTeamID: favoriteTeamID
                        )
                    } label: {
                        
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 8) {
                            Text("Group \(binding.wrappedValue.group)")
                                .font(.caption)
                                .fontWeight(.semibold)

                            if isFavoriteMatch {
                                Text("⭐ Favorite Team Match")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.yellow)
                            }

                            Spacer()

                            if binding.wrappedValue.homeScore != nil && binding.wrappedValue.awayScore != nil {
                                Text("✅ Completed")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.green)
                            } else {
                                Text("⏳ Not Played")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.orange)
                            }

                            VStack(alignment: .trailing, spacing: 3) {
                                Text(binding.wrappedValue.date)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                if !binding.wrappedValue.venue.isEmpty {
                                    Text(binding.wrappedValue.venue)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.trailing)
                                        .lineLimit(2)
                                }
                            }
                            .frame(maxWidth: 150, alignment: .trailing)
                            Text("⚽ Match Center →")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.08))
                                .clipShape(Capsule())
                        }

                        Text("\(binding.wrappedValue.homeTeam.flag) \(binding.wrappedValue.homeTeam.name)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 14) {
                            Spacer()
                            
                            TextField("0", value: binding.homeScore, format: .number)
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(width: 72)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.center)

                            Text(":")
                                .font(.title2)
                                .fontWeight(.black)

                            TextField("0", value: binding.awayScore, format: .number)
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(width: 72)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)

                        Text("\(binding.wrappedValue.awayTeam.flag) \(binding.wrappedValue.awayTeam.name)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)

                        predictionPanel(for: binding.wrappedValue)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .background(isFavoriteMatch ? Color.yellow.opacity(0.12) : Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                }
                
                Color.clear
                    .frame(height: 90)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
        }
        .navigationTitle("Matches")
    }
    
    private func predictionPanel(for match: Match) -> some View {
        let prediction = matchPrediction(for: match)
        let insight = predictionInsight(for: match, prediction: prediction)
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Match Prediction", systemImage: "chart.bar.fill")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("AI Prediction")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.cyan)
            }
            HStack(spacing: 8) {
                predictionBadge(text: insight.primaryBadge, color: insight.primaryColor)
                
                if let secondaryBadge = insight.secondaryBadge {
                    predictionBadge(text: secondaryBadge, color: .orange)
                }
            }
            
            predictionRow(label: match.homeTeam.name, value: prediction.homeWin, color: .green)
            predictionRow(label: "Draw", value: prediction.draw, color: .orange)
            predictionRow(label: match.awayTeam.name, value: prediction.awayWin, color: .blue)
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.20, blue: 0.45),
                    Color(red: 0.05, green: 0.14, blue: 0.32)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cyan.opacity(0.35), lineWidth: 1.2)
        )
    }
    
    private func predictionBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.heavy)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(color.opacity(0.78))
            .clipShape(Capsule())
    }
    
    private func predictionInsight(
        for match: Match,
        prediction: (homeWin: Int, draw: Int, awayWin: Int)
    ) -> (primaryBadge: String, primaryColor: Color, secondaryBadge: String?) {
        let highest = max(prediction.homeWin, prediction.draw, prediction.awayWin)
        let ratingGap = abs(match.homeTeam.rating - match.awayTeam.rating)
        
        let primaryBadge: String
        let primaryColor: Color
        
        if prediction.homeWin == highest {
            primaryBadge = "Win Probability: \(match.homeTeam.name)"
            primaryColor = .green
        } else if prediction.awayWin == highest {
            primaryBadge = "Win Probability: \(match.awayTeam.name)"
            primaryColor = .blue
        } else {
            primaryBadge = "Draw Probability"
            primaryColor = .orange
        }
        
        let combinedRating = match.homeTeam.rating + match.awayTeam.rating
        let isMatchOfTheDay = combinedRating >= 175 && ratingGap <= 8
        let isUpsetAlert = ratingGap >= 10 && min(prediction.homeWin, prediction.awayWin) >= 18
        
        if isMatchOfTheDay {
            return (primaryBadge, primaryColor, "🔥 Match of the Day")
        }
        
        if isUpsetAlert {
            return (primaryBadge, primaryColor, "⚠️ Upset Alert")
        }
        
        return (primaryBadge, primaryColor, nil)
    }
    
    private func predictionRow(label: String, value: Int, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(width: 95, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                    
                    Capsule()
                        .fill(color.opacity(0.75))
                        .frame(width: geometry.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 8)
            
            Text("\(value)%")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                .frame(width: 38, alignment: .trailing)
        }
    }
    
    private func matchPrediction(for match: Match) -> (homeWin: Int, draw: Int, awayWin: Int) {
        var homeRating = match.homeTeam.rating
        var awayRating = match.awayTeam.rating
        
        if isHostNation(match.homeTeam) {
            homeRating += 3
        }
        
        if isHostNation(match.awayTeam) {
            awayRating += 3
        }
        
        let difference = homeRating - awayRating
        
        var homeWin = 40 + difference
        var awayWin = 40 - difference
        var draw = 20
        
        if abs(difference) <= 4 {
            draw = 28
            homeWin = 36 + difference
            awayWin = 36 - difference
        } else if abs(difference) >= 15 {
            draw = 12
            if difference > 0 {
                homeWin = 76
                awayWin = 12
            } else {
                homeWin = 12
                awayWin = 76
            }
        } else if abs(difference) >= 8 {
            draw = 16
            if difference > 0 {
                homeWin = 62
                awayWin = 22
            } else {
                homeWin = 22
                awayWin = 62
            }
        }
        
        homeWin = max(5, min(85, homeWin))
        awayWin = max(5, min(85, awayWin))
        draw = max(8, min(35, draw))
        
        let total = homeWin + draw + awayWin
        let normalizedHome = Int(round(Double(homeWin) * 100.0 / Double(total)))
        let normalizedDraw = Int(round(Double(draw) * 100.0 / Double(total)))
        let normalizedAway = max(0, 100 - normalizedHome - normalizedDraw)
        
        return (normalizedHome, normalizedDraw, normalizedAway)
    }
    
    private func isHostNation(_ team: Team) -> Bool {
        ["United States", "USA", "Mexico", "Canada"].contains(team.name)
    }
}
