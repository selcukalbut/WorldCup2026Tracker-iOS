//
//  QualificationTrackerView.swift
//  WorldCup2026Tracker
//
//  Created by Selcuk Albut on 18.06.2026.
//

import SwiftUI

struct QualificationTrackerView: View {

    let teams: [Team]
    let matches: [Match]

    @AppStorage("savedLocalMatches") private var savedLocalMatchesData: Data = Data()

    private var effectiveMatches: [Match] {

        guard !savedLocalMatchesData.isEmpty,
              let decoded = try? JSONDecoder().decode([Match].self, from: savedLocalMatchesData),
              !decoded.isEmpty else {
            return matches
        }

        let currentPlayedCount = matches.filter {
            $0.homeScore != nil && $0.awayScore != nil
        }.count

        let savedPlayedCount = decoded.filter {
            $0.homeScore != nil && $0.awayScore != nil
        }.count

        return savedPlayedCount > currentPlayedCount ? decoded : matches
    }

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 24) {

                Text("🏆 Qualification Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                qualificationSummaryCard

                groupQualificationCard

                thirdPlacedTeamsCard

                roundOf32PreviewCard

                roundOf32MatchupsCard
            }
            .padding()
        }
        .navigationTitle("Qualification")
    }

    private var qualificationSummaryCard: some View {

        HStack(spacing: 8) {

            summaryCard(
                title: "Groups",
                value: "\(groupNames.count)",
                icon: "square.grid.3x3.fill"
            )

            summaryCard(
                title: "Top 2",
                value: "\(topTwoQualifiedTeams.count)",
                icon: "checkmark.seal.fill"
            )

            summaryCard(
                title: "Best 3rd",
                value: "8",
                icon: "3.circle.fill"
            )
        }
    }

    private var groupQualificationCard: some View {

        VStack(alignment: .leading, spacing: 14) {

            Text("✅ Top Two Qualified Teams")
                .font(.title2)
                .fontWeight(.bold)

            ForEach(groupNames, id: \.self) { group in

                let standings = calculateStandings(for: group)

                let first =
                    standings.indices.contains(0)
                    ? standings[0]
                    : nil

                let second =
                    standings.indices.contains(1)
                    ? standings[1]
                    : nil

                VStack(alignment: .leading, spacing: 8) {

                    Text("Group \(group)")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    if let first {
                        compactQualifiedRow(
                            rank: 1,
                            standing: first
                        )
                    }

                    if let second {
                        compactQualifiedRow(
                            rank: 2,
                            standing: second
                        )
                    }
                }

                if group != groupNames.last {
                    Divider()
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var thirdPlacedTeamsCard: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("🟢 Ranking of Third-Placed Teams")
                .font(.title2)
                .fontWeight(.bold)

            tableHeader

            ForEach(Array(thirdPlacedTeams.enumerated()), id: \.offset) {
                index,
                standing in

                thirdPlacedRow(
                    index: index,
                    standing: standing
                )

                if index == 7 {
                    qualifiedZoneDivider
                } else if index != thirdPlacedTeams.count - 1 {
                    Divider()
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var roundOf32PreviewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏁 Round of 32 Qualified Teams")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 10) {
                statisticRow(title: "Group Winners", value: "\(groupWinners.count)")
                statisticRow(title: "Group Runners-Up", value: "\(groupRunnersUp.count)")
                statisticRow(title: "Best Third-Placed", value: "\(bestThirdPlacedTeams.count)")
                statisticRow(title: "Projected Qualified Teams", value: "\(projectedRoundOf32Teams.count)")
            }

            Divider()

            qualifiedTeamsSection(
                title: "🥇 Group Winners",
                teams: groupWinners,
                color: .blue
            )

            qualifiedTeamsSection(
                title: "🥈 Group Runners-Up",
                teams: groupRunnersUp,
                color: .green
            )

            qualifiedTeamsSection(
                title: "🟢 Best Third-Placed Teams",
                teams: bestThirdPlacedTeams,
                color: .orange
            )
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var roundOf32MatchupsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("🥊 Projected Round of 32 Matchups")
                .font(.title2)
                .fontWeight(.bold)

            Text("If the group stage ended now, these would be the projected Round of 32 matchups based on current qualification ranking.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(Array(projectedRoundOf32Matchups.enumerated()), id: \.offset) { index, matchup in
                projectedMatchupRow(
                    index: index + 1,
                    home: matchup.home,
                    away: matchup.away
                )

                if index != projectedRoundOf32Matchups.count - 1 {
                    Divider()
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func projectedMatchupRow(index: Int, home: Standing, away: Standing) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Match \(index)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                HStack(spacing: 7) {
                    Text(home.team.flag)
                    Text(home.team.name)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("vs")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.12))
                    .clipShape(Capsule())

                HStack(spacing: 7) {
                    Text(away.team.flag)
                    Text(away.team.name)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func qualifiedTeamsSection(title: String, teams: [Standing], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                ForEach(Array(teams.enumerated()), id: \.element.team.id) { index, standing in
                    HStack(spacing: 8) {
                        Text("\(index + 1).")
                            .font(.caption)
                            .fontWeight(.black)
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 24)
                            .background(color.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 6))

                        Text(standing.team.flag)

                        Text(standing.team.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 8)
                    .background(color.opacity(0.08))
                    .clipShape(Capsule())
                }
            }
        }
    }

    private var tableHeader: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Text("#")
                    .fontWeight(.bold)
                    .frame(width: 34, alignment: .leading)

                Text("TEAM")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("PTS")
                    .fontWeight(.bold)
                    .frame(width: 42, alignment: .trailing)
            }

            HStack {
                Spacer()
                Text("MP   W   D   L     G      GD")
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var qualifiedZoneDivider: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.green.opacity(0.45))
                .frame(height: 1)

            Text("Qualified Zone")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.green)
                .lineLimit(1)

            Rectangle()
                .fill(Color.green.opacity(0.45))
                .frame(height: 1)
        }
        .padding(.vertical, 6)
    }

    private func thirdPlacedRow(index: Int, standing: Standing) -> some View {
        let isQualified = index < 8

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("\(index + 1).")
                    .fontWeight(.bold)
                    .foregroundStyle(isQualified ? .white : .secondary)
                    .frame(width: 36, height: 30)
                    .background(isQualified ? Color.blue : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 7))

                Text(standing.team.flag)
                    .font(.headline)

                Text(standing.team.name)
                    .font(.subheadline)
                    .fontWeight(index == 0 ? .bold : .semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: 8)

                Text("\(standing.points)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(width: 34, alignment: .trailing)
            }

            HStack(spacing: 10) {
                Spacer()

                statMini(label: "MP", value: "\(standing.played)")
                statMini(label: "W", value: "\(standing.won)")
                statMini(label: "D", value: "\(standing.drawn)")
                statMini(label: "L", value: "\(standing.lost)")
                statMini(label: "G", value: "\(standing.goalsFor):\(standing.goalsAgainst)")
                statMini(label: "GD", value: "\(standing.goalDifference)")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 9)
        .background(isQualified ? Color.green.opacity(0.06) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func statMini(label: String, value: String) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
    }

    private func compactQualifiedRow(rank: Int, standing: Standing) -> some View {
        HStack(spacing: 8) {
            Text("\(rank).")
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 28, height: 26)
                .background(rank == 1 ? Color.blue : Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(standing.team.flag)

            Text(standing.team.name)
                .fontWeight(.semibold)
                .lineLimit(1)

            Spacer()

            Text("\(standing.points) pts")
                .fontWeight(.bold)
        }
        .font(.subheadline)
    }

    private func summaryCard(title: String, value: String, icon: String) -> some View {
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

    private func statisticRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }

    private var thirdPlacedTeams: [Standing] {
        groupNames.compactMap { group in
            let standings = calculateStandings(for: group)
            return standings.indices.contains(2) ? standings[2] : nil
        }
        .sorted(by: qualificationSort)
    }

    private var bestThirdPlacedTeams: [Standing] {
        Array(thirdPlacedTeams.prefix(8))
    }

    private var groupWinners: [Standing] {
        groupNames.compactMap { group in
            let standings = calculateStandings(for: group)
            return standings.indices.contains(0) ? standings[0] : nil
        }
    }

    private var groupRunnersUp: [Standing] {
        groupNames.compactMap { group in
            let standings = calculateStandings(for: group)
            return standings.indices.contains(1) ? standings[1] : nil
        }
    }

    private var topTwoQualifiedTeams: [Standing] {
        groupWinners + groupRunnersUp
    }

    private var projectedRoundOf32Teams: [Standing] {
        (topTwoQualifiedTeams + bestThirdPlacedTeams).sorted(by: qualificationSort)
    }

    private var projectedRoundOf32Matchups: [(home: Standing, away: Standing)] {
        let teams = projectedRoundOf32Teams
        guard teams.count >= 2 else { return [] }

        var matchups: [(home: Standing, away: Standing)] = []
        var left = 0
        var right = teams.count - 1

        while left < right {
            matchups.append((home: teams[left], away: teams[right]))
            left += 1
            right -= 1
        }

        return matchups
    }

    private var groupNames: [String] {
        Array(Set(teams.map { $0.group })).sorted()
    }

    private func qualificationSort(_ lhs: Standing, _ rhs: Standing) -> Bool {
        if lhs.points != rhs.points {
            return lhs.points > rhs.points
        }

        if lhs.goalDifference != rhs.goalDifference {
            return lhs.goalDifference > rhs.goalDifference
        }

        if lhs.goalsFor != rhs.goalsFor {
            return lhs.goalsFor > rhs.goalsFor
        }

        return lhs.team.name < rhs.team.name
    }

    private func calculateStandings(for group: String) -> [Standing] {
        var standings = teams
            .filter { $0.group == group }
            .map { Standing(team: $0) }

        let groupMatches = effectiveMatches.filter { $0.group == group }

        for match in groupMatches {
            guard let homeScore = match.homeScore,
                  let awayScore = match.awayScore else {
                continue
            }

            if let homeIndex = standings.firstIndex(where: { $0.team.id == match.homeTeam.id }) {
                standings[homeIndex].played += 1
                standings[homeIndex].goalsFor += homeScore
                standings[homeIndex].goalsAgainst += awayScore

                if homeScore > awayScore {
                    standings[homeIndex].won += 1
                } else if homeScore < awayScore {
                    standings[homeIndex].lost += 1
                } else {
                    standings[homeIndex].drawn += 1
                }
            }

            if let awayIndex = standings.firstIndex(where: { $0.team.id == match.awayTeam.id }) {
                standings[awayIndex].played += 1
                standings[awayIndex].goalsFor += awayScore
                standings[awayIndex].goalsAgainst += homeScore

                if awayScore > homeScore {
                    standings[awayIndex].won += 1
                } else if awayScore < homeScore {
                    standings[awayIndex].lost += 1
                } else {
                    standings[awayIndex].drawn += 1
                }
            }
        }

        return standings.sorted(by: qualificationSort)
    }
}
