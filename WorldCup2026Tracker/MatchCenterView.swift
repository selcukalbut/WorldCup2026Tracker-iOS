//
//  MatchCenterView.swift
//  GlobalSportsTracker
//
//  Created by Selcuk Albut on 8.06.2026.
//

import SwiftUI

struct MatchCenterView: View {
    @Binding var match: Match
    let favoriteTeamID: String
    @AppStorage("favoriteMatchIDs") private var favoriteMatchIDs: String = ""

    private var prediction: (homeWin: Int, draw: Int, awayWin: Int) {
        matchPrediction(for: match)
    }

    private var isFavoriteMatch: Bool {
        match.homeTeam.id == favoriteTeamID || match.awayTeam.id == favoriteTeamID
    }

    private var ratingGap: Int {
        abs(match.homeTeam.rating - match.awayTeam.rating)
    }

    private var isMatchOfTheDay: Bool {
        match.homeTeam.rating + match.awayTeam.rating >= 175 && ratingGap <= 8
    }

    private var isUpsetAlert: Bool {
        ratingGap >= 10 && min(prediction.homeWin, prediction.awayWin) >= 18
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                heroCard
                stadiumPhotoCard
                matchInfoCard
                scoreCard
                predictionCard
                aiConfidenceCard
                matchStatsCard
                matchImportanceCard
                worldRankingCard
                formStatusCard
                teamPowerCard
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.98, blue: 1.0),
                    Color(red: 0.86, green: 0.94, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Match Center")
        .modifier(MatchCenterInlineNavigationTitleIfAvailable())
    }

    private var heroCard: some View {
        VStack(spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🏟 Match Center")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundStyle(.white)

                    Text("Group \(match.group) Match")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    matchStatusBadge
                    favoriteMatchButton
                }
                
            }

            HStack(spacing: 12) {
                teamBlock(match.homeTeam)

                VStack(spacing: 6) {
                    Text(scoreSummary)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text("VS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.70))
                }
                .frame(width: 96)

                teamBlock(match.awayTeam)
            }

            HStack(spacing: 8) {
                if isFavoriteMatch {
                    matchBadge("⭐ Favorite Team Match", color: .yellow)
                }

                if isMatchOfTheDay {
                    matchBadge("🔥 Match of the Day", color: .orange)
                }

                if isUpsetAlert {
                    matchBadge("⚠️ Upset Alert", color: .red)
                }
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
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color.blue.opacity(0.18), radius: 10, x: 0, y: 6)
    }

    private var stadiumPhotoCard: some View {
        ZStack(alignment: .bottomLeading) {
            Image(stadiumImageName())
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, minHeight: 185, maxHeight: 185)
                .clipped()
            
            LinearGradient(
                colors: [
                    Color.black.opacity(0.02),
                    Color.black.opacity(0.62)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text("🏟 Stadium")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.82))
                
                Text(match.venue.isEmpty ? "Stadium information unavailable" : match.venue)
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                
                Text("Tournament Match Venue")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding()
        }
        .frame(height: 185)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.65), lineWidth: 1.1)
        )
        .shadow(color: Color.blue.opacity(0.14), radius: 10, x: 0, y: 5)
    }

    private func stadiumImageName() -> String {
        let venue = match.venue.lowercased()

        if venue.contains("guadalajara") {
            return "guadalajara_stadium"
        }

        if venue.contains("mexico city") {
            return "mexico_city_stadium"
        }

        if venue.contains("monterrey") {
            return "monterrey_stadium"
        }

        if venue.contains("atlanta") {
            return "atlanta_stadium"
        }

        if venue.contains("boston") {
            return "boston_stadium"
        }

        if venue.contains("dallas") {
            return "dallas_stadium"
        }

        if venue.contains("houston") {
            return "houston_stadium"
        }

        if venue.contains("kansas") {
            return "kansas_city_stadium"
        }

        if venue.contains("los angeles") {
            return "los_angeles_stadium"
        }

        if venue.contains("miami") {
            return "miami_stadium"
        }

        if venue.contains("new york") || venue.contains("new jersey") {
            return "new_york_new_jersey_stadium"
        }

        if venue.contains("philadelphia") {
            return "philadelphia_stadium"
        }

        if venue.contains("san francisco") || venue.contains("bay area") {
            return "san_francisco_bay_area_stadium"
        }

        if venue.contains("seattle") {
            return "seattle_stadium"
        }

        if venue.contains("toronto") {
            return "toronto_stadium"
        }

        if venue.contains("vancouver") {
            return "vancouver_stadium"
        }

        return "app_logo"
    }

    private func teamBlock(_ team: Team) -> some View {
        VStack(spacing: 8) {
            Text(team.flag)
                .font(.system(size: 52))

            Text(team.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            Text("Rating \(team.rating)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
    }

    private var matchStatusBadge: some View {
        Text(match.homeScore != nil && match.awayScore != nil ? "Completed" : "Scheduled")
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                (match.homeScore != nil && match.awayScore != nil ? Color.green : Color.white)
                    .opacity(match.homeScore != nil && match.awayScore != nil ? 0.82 : 0.20)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
            )
            .clipShape(Capsule())
    }

    private var isTrackedMatch: Bool {
        favoriteMatchIDSet.contains(match.id.uuidString)
    }

    private var favoriteMatchIDSet: Set<String> {
        Set(favoriteMatchIDs.split(separator: ",").map { String($0) })
    }

    private var favoriteMatchButton: some View {
        Button {
            toggleFavoriteMatch()
        } label: {
            Label(
                isTrackedMatch ? "Following" : "Follow Match",
                systemImage: isTrackedMatch ? "heart.fill" : "heart"
            )
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background((isTrackedMatch ? Color.red : Color.white).opacity(isTrackedMatch ? 0.82 : 0.20))
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func toggleFavoriteMatch() {
        var ids = favoriteMatchIDSet
        let currentMatchID = match.id.uuidString

        if ids.contains(currentMatchID) {
            ids.remove(currentMatchID)
            NotificationManager.shared.cancelMatchReminder(matchID: currentMatchID)
        } else {
            ids.insert(currentMatchID)

            if let reminderDate = reminderDateForMatch() {
                NotificationManager.shared.scheduleMatchReminder(
                    matchID: currentMatchID,
                    homeTeam: match.homeTeam.name,
                    awayTeam: match.awayTeam.name,
                    reminderDate: reminderDate
                )
            } else {
                NotificationManager.shared.scheduleMatchReminder(
                    matchID: currentMatchID,
                    homeTeam: match.homeTeam.name,
                    awayTeam: match.awayTeam.name,
                    timeInterval: 10
                )
            }
        }

        favoriteMatchIDs = ids
            .sorted()
            .joined(separator: ",")
    }

    private func reminderDateForMatch() -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMMM yyyy"

        guard let matchDate = formatter.date(from: match.date) else {
            return nil
        }

        return Calendar.current.date(
            byAdding: .hour,
            value: -1,
            to: matchDate
        )
    }

    private func matchBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(color.opacity(0.82))
            .clipShape(Capsule())
    }

    private var matchInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📍 Match Information")
                .font(.title2)
                .fontWeight(.bold)

            infoRow(icon: "calendar", title: "Date", value: match.date)
            infoRow(icon: "mappin.and.ellipse", title: "Stadium", value: match.venue.isEmpty ? "Stadium information unavailable" : match.venue)
            infoRow(icon: "square.grid.2x2.fill", title: "Group", value: "Group \(match.group)")
        }
        .matchCenterCardStyle()
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 22)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
    }

    private var scoreCard: some View {
        VStack(spacing: 14) {
            Text("⚽ Score Entry")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 18) {
                VStack(spacing: 6) {
                    Text(match.homeTeam.flag)
                    TextField("0", value: $match.homeScore, format: .number)
                        .font(.title)
                        .fontWeight(.black)
                        .multilineTextAlignment(.center)
                        .frame(width: 76)
                        .textFieldStyle(.roundedBorder)
                }

                Text(":")
                    .font(.largeTitle)
                    .fontWeight(.black)

                VStack(spacing: 6) {
                    Text(match.awayTeam.flag)
                    TextField("0", value: $match.awayScore, format: .number)
                        .font(.title)
                        .fontWeight(.black)
                        .multilineTextAlignment(.center)
                        .frame(width: 76)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
        .matchCenterCardStyle()
    }

    private var matchImportanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("🔥 Match Importance")
                .font(.title2)
                .fontWeight(.bold)

            importanceRow(
                icon: "trophy.fill",
                title: "Tournament Impact",
                value: "May directly affect the group standings"
            )

            importanceRow(
                icon: "house.fill",
                title: "Home Advantage",
                value: isHostNation(match.homeTeam) || isHostNation(match.awayTeam)
                    ? "The home team has a psychological advantage"
                    : "Neutral venue match"
            )

            importanceRow(
                icon: "star.fill",
                title: "Favorite Team",
                value: isFavoriteMatch
                    ? "Your favorite team is playing in this match"
                    : "Regular match"
            )
        }
        .matchCenterCardStyle()
    }

    private func importanceRow(
        icon: String,
        title: String,
        value: String
    ) -> some View {

        HStack(alignment: .top, spacing: 12) {

            Image(systemName: icon)
                .foregroundStyle(.orange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)

                Text(value)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var worldRankingCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("🌍 Team Strength Ranking")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Estimated")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.75))
                    .clipShape(Capsule())
            }
            
            Text("Rankings are estimated based on current team rating scores.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            rankingTeamRow(team: match.homeTeam)
            rankingTeamRow(team: match.awayTeam)
        }
        .matchCenterCardStyle()
    }
    
    private func rankingTeamRow(team: Team) -> some View {
        HStack(spacing: 12) {
            Text(team.flag)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text("Rating \(team.rating)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text("#\(estimatedTeamRank(for: team))")
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundStyle(rankColor(for: team))
                
                Text(rankTier(for: team))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func estimatedTeamRank(for team: Team) -> Int {
        let sortedTeams = sampleTeams.sorted { $0.rating > $1.rating }
        return (sortedTeams.firstIndex { $0.id == team.id } ?? 0) + 1
    }
    
    private func rankTier(for team: Team) -> String {
        let rank = estimatedTeamRank(for: team)
        
        if rank <= 5 {
            return "Elite"
        }
        
        if rank <= 15 {
            return "Strong"
        }
        
        if rank <= 32 {
            return "Competitive"
        }
        
        return "Challenger"
    }
    
    private func rankColor(for team: Team) -> Color {
        let rank = estimatedTeamRank(for: team)
        
        if rank <= 5 {
            return .green
        }
        
        if rank <= 15 {
            return .blue
        }
        
        if rank <= 32 {
            return .orange
        }
        
        return .red
    }

    private var formStatusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("📈 Form Status")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Recent form is estimated based on team rating values.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            formTeamRow(team: match.homeTeam)
            formTeamRow(team: match.awayTeam)
        }
        .matchCenterCardStyle()
    }
    
    private func formTeamRow(team: Team) -> some View {
        HStack(spacing: 12) {
            Text(team.flag)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(team.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                HStack(spacing: 5) {
                    ForEach(formSequence(for: team), id: \.self) { result in
                        formBadge(result)
                    }
                }
            }
            
            Spacer()
            
            Text(formLabel(for: team))
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(formColor(for: team).opacity(0.82))
                .clipShape(Capsule())
        }
        .padding(10)
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func formBadge(_ result: String) -> some View {
        let color: Color
        
        switch result {
        case "W":
            color = .green
        case "D":
            color = .orange
        default:
            color = .red
        }
        
        return Text(result)
            .font(.caption2)
            .fontWeight(.black)
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .background(color.opacity(0.85))
            .clipShape(Circle())
    }
    
    private func formSequence(for team: Team) -> [String] {
        if team.rating >= 88 {
            return ["W", "W", "D", "W", "W"]
        }
        
        if team.rating >= 82 {
            return ["W", "D", "W", "L", "W"]
        }
        
        if team.rating >= 74 {
            return ["D", "W", "L", "D", "W"]
        }
        
        return ["L", "D", "W", "L", "D"]
    }
    
    private func formLabel(for team: Team) -> String {
        if team.rating >= 88 {
            return "Exellent"
        }
        
        if team.rating >= 82 {
            return "Good"
        }
        
        if team.rating >= 74 {
            return "Average"
        }
        
        return "Inconsistent"
    }
    
    private func formColor(for team: Team) -> Color {
        if team.rating >= 88 {
            return .green
        }
        
        if team.rating >= 82 {
            return .blue
        }
        
        if team.rating >= 74 {
            return .orange
        }
        
        return .red
    }
    
    private var predictionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("🤖 AI Prediction")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Text("Rating Based")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.cyan)
            }

            Text("Predictions are generated based on team ratings, home advantage and rating differences.")
                .font(.caption)
                .foregroundStyle(.secondary)

            predictionRow(title: match.homeTeam.name, value: prediction.homeWin, color: .green)
            predictionRow(title: "Draw", value: prediction.draw, color: .orange)
            predictionRow(title: match.awayTeam.name, value: prediction.awayWin, color: .blue)
        }
        .matchCenterCardStyle()
    }

    private func predictionRow(title: String, value: Int, color: Color) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.caption)
                .lineLimit(1)
                .frame(width: 96, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.16))

                    Capsule()
                        .fill(color.opacity(0.78))
                        .frame(width: geometry.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 9)

            Text("\(value)%")
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 42, alignment: .trailing)
        }
    }

    private var aiConfidenceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("🤖 AI Confidence Level")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(aiConfidenceLabel)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(aiConfidenceColor.opacity(0.82))
                    .clipShape(Capsule())
            }
            
            Text("This value is estimated based on the prediction distribution and the rating gap between the teams.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Confidence")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("%\(aiConfidenceScore)")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundStyle(aiConfidenceColor)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.16))
                        
                        Capsule()
                            .fill(aiConfidenceColor.opacity(0.80))
                            .frame(width: geometry.size.width * CGFloat(aiConfidenceScore) / 100)
                    }
                }
                .frame(height: 12)
            }
            
            HStack(spacing: 8) {
                confidenceFactorBadge("Rating Gap: \(ratingGap)")
                confidenceFactorBadge(confidenceFactorText)
            }
        }
        .matchCenterCardStyle()
    }
    
    private var aiConfidenceScore: Int {
        let values = [prediction.homeWin, prediction.draw, prediction.awayWin].sorted(by: >)
        let leadMargin = values[0] - values[1]
        
        var score = 50 + leadMargin + min(20, ratingGap)
        
        if isMatchOfTheDay {
            score -= 6
        }
        
        if isUpsetAlert {
            score -= 8
        }
        
        return max(45, min(92, score))
    }
    
    private var aiConfidenceLabel: String {
        if aiConfidenceScore >= 78 {
            return "High"
        }
        
        if aiConfidenceScore >= 62 {
            return "Medium"
        }
        
        return "Cautious"
    }
    
    private var aiConfidenceColor: Color {
        if aiConfidenceScore >= 78 {
            return .green
        }
        
        if aiConfidenceScore >= 62 {
            return .blue
        }
        
        return .orange
    }
    
    private var confidenceFactorText: String {
        let values = [prediction.homeWin, prediction.draw, prediction.awayWin].sorted(by: >)
        let leadMargin = values[0] - values[1]
        
        if leadMargin >= 25 {
            return "Clear Favorite"
        }
        
        if leadMargin >= 12 {
            return "Advantage"
        }
        
        return "Balanced Match"
    }
    
    private func confidenceFactorBadge(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.blue.opacity(0.06))
            .clipShape(Capsule())
    }

    private var matchStatsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("📊 Match Statistics")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Text("Simulated")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.purple.opacity(0.75))
                    .clipShape(Capsule())
            }

            Text("Statistics are estimated based on team ratings and match predictions.")
                .font(.caption)
                .foregroundStyle(.secondary)

            statComparisonRow(
                title: "Possession",
                homeValue: possessionStats.home,
                awayValue: possessionStats.away,
                suffix: "%"
            )

            statComparisonRow(
                title: "Shots",
                homeValue: shotStats.home,
                awayValue: shotStats.away,
                suffix: ""
            )

            statComparisonRow(
                title: "Shots on Target",
                homeValue: shotsOnTargetStats.home,
                awayValue: shotsOnTargetStats.away,
                suffix: ""
            )

            statComparisonRow(
                title: "Corner",
                homeValue: cornerStats.home,
                awayValue: cornerStats.away,
                suffix: ""
            )

            statComparisonRow(
                title: "Fouls",
                homeValue: foulStats.home,
                awayValue: foulStats.away,
                suffix: ""
            )
        }
        .matchCenterCardStyle()
    }

    private func statComparisonRow(title: String, homeValue: Int, awayValue: Int, suffix: String) -> some View {
        VStack(spacing: 7) {
            HStack {
                Text("\(homeValue)\(suffix)")
                    .font(.caption)
                    .fontWeight(.black)
                    .frame(width: 48, alignment: .leading)

                Spacer()

                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(awayValue)\(suffix)")
                    .font(.caption)
                    .fontWeight(.black)
                    .frame(width: 48, alignment: .trailing)
            }

            HStack(spacing: 6) {
                GeometryReader { geometry in
                    ZStack(alignment: .trailing) {
                        Capsule()
                            .fill(Color.gray.opacity(0.15))

                        Capsule()
                            .fill(Color.green.opacity(0.78))
                            .frame(width: geometry.size.width * statBarRatio(homeValue: homeValue, awayValue: awayValue, isHome: true))
                    }
                }
                .frame(height: 9)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.15))

                        Capsule()
                            .fill(Color.blue.opacity(0.78))
                            .frame(width: geometry.size.width * statBarRatio(homeValue: homeValue, awayValue: awayValue, isHome: false))
                    }
                }
                .frame(height: 9)
            }
        }
        .padding(10)
        .background(Color.blue.opacity(0.045))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statBarRatio(homeValue: Int, awayValue: Int, isHome: Bool) -> CGFloat {
        let total = max(1, homeValue + awayValue)
        let value = isHome ? homeValue : awayValue
        return CGFloat(value) / CGFloat(total)
    }

    private var possessionStats: (home: Int, away: Int) {
        let home = max(35, min(65, 50 + (match.homeTeam.rating - match.awayTeam.rating)))
        return (home, 100 - home)
    }

    private var shotStats: (home: Int, away: Int) {
        let home = max(6, min(19, 11 + (match.homeTeam.rating - match.awayTeam.rating) / 2))
        let away = max(6, min(19, 11 + (match.awayTeam.rating - match.homeTeam.rating) / 2))
        return (home, away)
    }

    private var shotsOnTargetStats: (home: Int, away: Int) {
        let home = max(2, min(10, shotStats.home / 2 + (prediction.homeWin > prediction.awayWin ? 1 : 0)))
        let away = max(2, min(10, shotStats.away / 2 + (prediction.awayWin > prediction.homeWin ? 1 : 0)))
        return (home, away)
    }

    private var cornerStats: (home: Int, away: Int) {
        let home = max(2, min(9, 5 + (match.homeTeam.rating - match.awayTeam.rating) / 4))
        let away = max(2, min(9, 5 + (match.awayTeam.rating - match.homeTeam.rating) / 4))
        return (home, away)
    }

    private var foulStats: (home: Int, away: Int) {
        let home = max(7, min(17, 12 - (match.homeTeam.rating - match.awayTeam.rating) / 5))
        let away = max(7, min(17, 12 - (match.awayTeam.rating - match.homeTeam.rating) / 5))
        return (home, away)
    }

    private var teamPowerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("📊 Team Strength Comparison")
                .font(.title2)
                .fontWeight(.bold)

            powerRow(title: "Overall Rating", home: match.homeTeam.rating, away: match.awayTeam.rating)
            powerRow(title: "Attack Strength", home: attackPower(match.homeTeam), away: attackPower(match.awayTeam))
            powerRow(title: "Defensive Balance", home: defensePower(match.homeTeam), away: defensePower(match.awayTeam))
            powerRow(title: "Tournament Experience", home: experiencePower(match.homeTeam), away: experiencePower(match.awayTeam))
        }
        .matchCenterCardStyle()
    }

    private func powerRow(title: String, home: Int, away: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(home) - \(away)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                ProgressView(value: Double(home), total: 100)
                    .tint(.green)
                ProgressView(value: Double(away), total: 100)
                    .tint(.blue)
            }
        }
    }

    private var scoreSummary: String {
        if let homeScore = match.homeScore,
           let awayScore = match.awayScore {
            return "\(homeScore) : \(awayScore)"
        }

        return "0 : 0"
    }

    private func matchPrediction(for match: Match) -> (homeWin: Int, draw: Int, awayWin: Int) {
        var homeRating = match.homeTeam.rating
        var awayRating = match.awayTeam.rating

        if isHostNation(match.homeTeam) { homeRating += 3 }
        if isHostNation(match.awayTeam) { awayRating += 3 }

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

    private func attackPower(_ team: Team) -> Int {
        min(100, max(45, team.rating + 6))
    }

    private func defensePower(_ team: Team) -> Int {
        min(100, max(45, team.rating + 2))
    }

    private func experiencePower(_ team: Team) -> Int {
        let eliteTeams = ["Brazil", "Argentina", "France", "Germany", "Spain", "England", "Netherlands", "Portugal", "Italy"]
        return eliteTeams.contains(team.name) ? min(100, team.rating + 8) : max(45, team.rating - 4)
    }

    private func isHostNation(_ team: Team) -> Bool {
        ["United States", "USA", "Mexico", "Canada"].contains(team.name)
    }
}

private struct MatchCenterInlineNavigationTitleIfAvailable: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        content.navigationBarTitleDisplayMode(.inline)
        #else
        content
        #endif
    }
}

private extension View {
    func matchCenterCardStyle() -> some View {
        self
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.75), lineWidth: 1.1)
            )
            .shadow(color: Color.blue.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    MatchCenterView(
        match: .constant(sampleMatches[0]),
        favoriteTeamID: ""
    )
}
