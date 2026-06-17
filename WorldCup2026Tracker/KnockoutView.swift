import SwiftUI

struct KnockoutView: View {
    let teams: [Team]
    let matches: [Match]
    
    @State private var roundOf32Matches: [KnockoutMatch] = []
    @State private var roundOf16Matches: [KnockoutMatch] = []
    @State private var quarterFinalMatches: [KnockoutMatch] = []
    @State private var semiFinalMatches: [KnockoutMatch] = []
    @State private var thirdPlaceMatches: [KnockoutMatch] = []
    @State private var finalMatches: [KnockoutMatch] = []
    @AppStorage("savedKnockoutMatches") private var savedKnockoutData: Data = Data()
    @State private var selectedMobileRound: KnockoutRound = .roundOf32
    @State private var isSimulatingKnockout = false
    
    private let matchCardHeight: CGFloat = 92
    private let baseMatchSpacing: CGFloat = 14
    
    var body: some View {
#if os(iOS)
        mobileKnockoutView
#else
        desktopKnockoutView
#endif
    }

    private var desktopKnockoutView: some View {
        ScrollView([.vertical, .horizontal]) {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.16, blue: 0.36),
                        Color(red: 0.06, green: 0.28, blue: 0.58),
                        Color(red: 0.02, green: 0.10, blue: 0.26)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    headerBar
                    bracketBoard
                }
                .padding(28)
            }
            .frame(minWidth: 1500, minHeight: 900)
        }
        .navigationTitle("Knockout Stage")
        .onAppear {
            loadKnockoutMatches()
        }
        .onChange(of: roundOf32Matches) { _, _ in
            guard !isSimulatingKnockout else { return }
            updateRoundOf16()
            saveKnockoutMatches()
        }
        .onChange(of: roundOf16Matches) { _, _ in
            guard !isSimulatingKnockout else { return }
            updateQuarterFinals()
            saveKnockoutMatches()
        }
        .onChange(of: quarterFinalMatches) { _, _ in
            guard !isSimulatingKnockout else { return }
            updateSemiFinals()
            saveKnockoutMatches()
        }
        .onChange(of: semiFinalMatches) { _, _ in
            guard !isSimulatingKnockout else { return }
            updateFinal()
            updateThirdPlace()
            saveKnockoutMatches()
        }
        .onChange(of: finalMatches) { _, _ in
            guard !isSimulatingKnockout else { return }
            saveKnockoutMatches()
        }
        .onChange(of: thirdPlaceMatches) { _, _ in
            guard !isSimulatingKnockout else { return }
            saveKnockoutMatches()
        }
    }

    private var mobileKnockoutView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                mobileHeader
                mobileBracketBoard
                mobileChampionSection
            }
            
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.98, blue: 1.00),
                    Color(red: 0.86, green: 0.95, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Knockout")
        .modifier(KnockoutInlineNavigationTitleIfAvailable())
        .onAppear {
            loadKnockoutMatches()
        }
        .onChange(of: roundOf32Matches) { _, _ in
            guard !isSimulatingKnockout else { return }
            updateRoundOf16()
            saveKnockoutMatches()
        }
        .onChange(of: roundOf16Matches) { _, _ in
            guard !isSimulatingKnockout else { return }
            updateQuarterFinals()
            saveKnockoutMatches()
        }
        .onChange(of: quarterFinalMatches) { _, _ in
            guard !isSimulatingKnockout else { return }
            updateSemiFinals()
            saveKnockoutMatches()
        }
        .onChange(of: semiFinalMatches) { _, _ in
            guard !isSimulatingKnockout else { return }
            updateFinal()
            updateThirdPlace()
            saveKnockoutMatches()
        }
        .onChange(of: finalMatches) { _, _ in
            guard !isSimulatingKnockout else { return }
            saveKnockoutMatches()
        }
        .onChange(of: thirdPlaceMatches) { _, _ in
            guard !isSimulatingKnockout else { return }
            saveKnockoutMatches()
        }
    }
    
    private var mobileHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🏆 Knockout Stage")
                        .font(.largeTitle)
                        .fontWeight(.black)
                    
                    Text("Mobile knockout stage view")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button {
                        simulateKnockoutTournament()
                    } label: {
                        Image(systemName: "dice.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        resetKnockoutTournament()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            
            HStack(spacing: 10) {
                mobileInfoBox(value: "32", title: "Team")
                mobileInfoBox(value: "6", title: "Rounds")
                mobileInfoBox(value: finalMatches.first?.winner == nil ? "Pending" : "Ready", title: "Champion")
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.75), lineWidth: 1.2)
        )
        .shadow(color: Color.blue.opacity(0.12), radius: 8, x: 0, y: 4)
    }
    
    private var mobileRoundSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(mobileRounds, id: \.round) { item in
                    Button {
                        selectedMobileRound = item.round
                    } label: {
                        Text(item.title)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(selectedMobileRound == item.round ? .white : Color(red: 0.03, green: 0.12, blue: 0.24))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(selectedMobileRound == item.round ? Color.blue : Color.white.opacity(0.70))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    private var mobileSelectedRoundList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(mobileRoundTitle(for: selectedMobileRound))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(mobileMatches(for: selectedMobileRound).count) match")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.80))
                    .clipShape(Capsule())
            }
            
            if mobileMatches(for: selectedMobileRound).isEmpty {
                mobileWaitingCard
            } else {
                ForEach(mobileBindings(for: selectedMobileRound)) { binding in
                    mobileKnockoutMatchCard(match: binding)
                }
            }
        }
    }
    
    private var mobileChampionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("🏆 Tournament Podium")
                .font(.title2)
                .fontWeight(.black)

            if let champion = finalMatches.first?.winner {
                podiumRow(icon: "🥇", title: "Champion", team: champion)
            } else {
                Text("No champion has been determined yet. You can progress by simulating the knockout stage or entering match scores.")
                    .foregroundStyle(.secondary)
            }

            if let runnerUp = finalMatches.first?.loser {
                podiumRow(icon: "🥈", title: "Runner-Up", team: runnerUp)
            }

            if let thirdPlace = thirdPlaceMatches.first?.winner {
                podiumRow(icon: "🥉", title: "Third Place", team: thirdPlace)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.yellow.opacity(0.35), lineWidth: 1.2)
        )
    }

    private func podiumRow(icon: String, title: String, team: Team) -> some View {
        HStack(spacing: 14) {
            Text(icon)
                .font(.largeTitle)

            Text(team.flag)
                .font(.title)

            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
    
    private var mobileWaitingCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "hourglass")
                .font(.title)
                .foregroundStyle(.secondary)
            Text("Matches for this round have not been generated yet.")
                .font(.headline)
            Text("This section will be populated automatically as winners from previous rounds are determined.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func mobileKnockoutMatchCard(match: Binding<KnockoutMatch>) -> some View {
        VStack(spacing: 12) {
            mobileTeamScoreRow(team: match.wrappedValue.homeTeam, score: match.homeScore)
            Divider()
            mobileTeamScoreRow(team: match.wrappedValue.awayTeam, score: match.awayScore)
            
            if let winner = match.wrappedValue.winner {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Text("Winner: \(winner.flag) \(winner.name)")
                        .font(.caption)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.top, 2)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.85),
                    Color(red: 0.78, green: 0.93, blue: 0.98).opacity(0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.80), lineWidth: 1.2)
        )
        .shadow(color: Color.blue.opacity(0.10), radius: 8, x: 0, y: 4)
    }
    
    private func mobileTeamScoreRow(team: Team?, score: Binding<Int?>) -> some View {
        HStack(spacing: 10) {
            if let team {
                Text(team.flag)
                    .font(.title2)
                Text(team.name)
                    .font(.headline)
                    .lineLimit(1)
            } else {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(.secondary)
                Text("Pending")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            TextField("0", value: score, format: .number)
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(width: 52)
                .textFieldStyle(.roundedBorder)
                .disabled(team == nil)
        }
    }
    
    private func mobileInfoBox(value: String, title: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.black)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.blue.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var mobileRounds: [(title: String, round: KnockoutRound)] {
        [
            ("Round of 32", .roundOf32),
            ("Round of 16", .roundOf16),
            ("Quarter-Finals", .quarterFinal),
            ("Semi-Finals", .semiFinal),
            ("Final", .final)
        ]
    }
    
    private func mobileRoundTitle(for round: KnockoutRound) -> String {
        switch round {
        case .roundOf32: return "Last 32"
        case .roundOf16: return "Last 16"
        case .quarterFinal: return "Quarter-Finals"
        case .semiFinal: return "Semi-Finals"
        case .thirdPlace: return "Third Place"
        case .final: return "Finals"
        }
    }
    
    private func mobileMatches(for round: KnockoutRound) -> [KnockoutMatch] {
        switch round {
        case .roundOf32: return roundOf32Matches
        case .roundOf16: return roundOf16Matches
        case .quarterFinal: return quarterFinalMatches
        case .semiFinal: return semiFinalMatches
        case .thirdPlace: return thirdPlaceMatches
        case .final: return finalMatches
        }
    }
    
    private func mobileBindings(for round: KnockoutRound) -> [Binding<KnockoutMatch>] {
        switch round {
        case .roundOf32:
            return roundOf32Matches.indices.map { $roundOf32Matches[$0] }
        case .roundOf16:
            return roundOf16Matches.indices.map { $roundOf16Matches[$0] }
        case .quarterFinal:
            return quarterFinalMatches.indices.map { $quarterFinalMatches[$0] }
        case .semiFinal:
            return semiFinalMatches.indices.map { $semiFinalMatches[$0] }
        case .thirdPlace:
            return thirdPlaceMatches.indices.map { $thirdPlaceMatches[$0] }
        case .final:
            return finalMatches.indices.map { $finalMatches[$0] }
        }
    }
    
    // Bracket board for mobile
    private var mobileBracketBoard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Official Tournament Bracket")
                    .font(.title2)
                    .fontWeight(.black)

                Spacer()

                Text("R32 → Final")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.85))
                    .clipShape(Capsule())
            }

            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .top, spacing: 10) {
                    mobileBracketColumn(title: "ROUND OF 32", shortTitle: "R32", matches: roundOf32Matches, accent: .green, level: 0)
                    mobileBracketConnector(fromCount: roundOf32Matches.count, toCount: roundOf16Matches.count, fromLevel: 0, color: .green)

                    mobileBracketColumn(title: "ROUND OF 16", shortTitle: "R16", matches: roundOf16Matches, accent: .green, level: 1)
                    mobileBracketConnector(fromCount: roundOf16Matches.count, toCount: quarterFinalMatches.count, fromLevel: 1, color: .red)

                    mobileBracketColumn(title: "QUARTER-FINALS", shortTitle: "QF", matches: quarterFinalMatches, accent: .red, level: 2)
                    mobileBracketConnector(fromCount: quarterFinalMatches.count, toCount: semiFinalMatches.count, fromLevel: 2, color: .orange)

                    mobileBracketColumn(title: "SEMI-FINALS", shortTitle: "SF", matches: semiFinalMatches, accent: .orange, level: 3)
                    mobileBracketConnector(fromCount: semiFinalMatches.count, toCount: finalMatches.count, fromLevel: 3, color: .yellow)
                    mobileBracketFinalColumn
                    mobileBracketColumn(title: "THIRD PLACE", shortTitle: "3P", matches: thirdPlaceMatches, accent: .purple, level: 3)
                }
                .padding(14)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.08, green: 0.20, blue: 0.38),
                            Color(red: 0.12, green: 0.32, blue: 0.56),
                            Color(red: 0.06, green: 0.18, blue: 0.34)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.yellow.opacity(0.28), lineWidth: 1.2)
                )
            }
        }
    }

    private func mobileBracketConnector(fromCount: Int, toCount: Int, fromLevel: Int, color: Color) -> some View {
        let safeFromCount = max(fromCount, 1)
        let safeToCount = max(toCount, 1)
        let cardHeight: CGFloat = 96
        let fromSpacing = mobileBracketCardSpacing(level: fromLevel)
        let connectorTopPadding = mobileBracketTopPadding(level: fromLevel)
        let headerHeight: CGFloat = 32
        let topGap: CGFloat = 10
        let totalHeight = headerHeight + topGap + connectorTopPadding + CGFloat(safeFromCount) * cardHeight + CGFloat(max(safeFromCount - 1, 0)) * fromSpacing

        return ZStack(alignment: .topLeading) {
            ForEach(0..<safeToCount, id: \.self) { index in
                mobileBracketConnectorPath(
                    fromTopIndex: min(index * 2, safeFromCount - 1),
                    fromBottomIndex: min(index * 2 + 1, safeFromCount - 1),
                    toIndex: index,
                    fromLevel: fromLevel,
                    color: color
                )
            }
        }
        .frame(width: 38, height: totalHeight)
    }

    private func mobileBracketConnectorPath(
        fromTopIndex: Int,
        fromBottomIndex: Int,
        toIndex: Int,
        fromLevel: Int,
        color: Color
    ) -> some View {
        let cardHeight: CGFloat = 96
        let headerHeight: CGFloat = 32
        let topGap: CGFloat = 10
        let fromSpacing = mobileBracketCardSpacing(level: fromLevel)
        let toSpacing = mobileBracketCardSpacing(level: fromLevel + 1)
        let fromTopPadding = mobileBracketTopPadding(level: fromLevel)
        let toTopPadding = mobileBracketTopPadding(level: fromLevel + 1)
        let yOffset = headerHeight + topGap

        let fromTopY = yOffset + fromTopPadding + CGFloat(fromTopIndex) * (cardHeight + fromSpacing) + cardHeight / 2
        let fromBottomY = yOffset + fromTopPadding + CGFloat(fromBottomIndex) * (cardHeight + fromSpacing) + cardHeight / 2
        let toY = yOffset + toTopPadding + CGFloat(toIndex) * (cardHeight + toSpacing) + cardHeight / 2
        let midX: CGFloat = 18
        let width: CGFloat = 38

        return Path { path in
            path.move(to: CGPoint(x: 0, y: fromTopY))
            path.addLine(to: CGPoint(x: midX, y: fromTopY))
            path.addLine(to: CGPoint(x: midX, y: fromBottomY))
            path.addLine(to: CGPoint(x: 0, y: fromBottomY))

            path.move(to: CGPoint(x: midX, y: (fromTopY + fromBottomY) / 2))
            path.addLine(to: CGPoint(x: width, y: toY))
        }
        .stroke(
            color.opacity(0.75),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
        .shadow(color: color.opacity(0.35), radius: 4)
    }

    private func mobileBracketTopPadding(level: Int) -> CGFloat {
        let cardHeight: CGFloat = 96
        let baseSpacing: CGFloat = 10
        let step = cardHeight + baseSpacing
        return (pow(2.0, Double(level)) - 1) * step / 2
    }

    private func mobileBracketCardSpacing(level: Int) -> CGFloat {
        let cardHeight: CGFloat = 96
        let baseSpacing: CGFloat = 10
        let step = cardHeight + baseSpacing
        return pow(2.0, Double(level)) * step - cardHeight
    }
    
    private func mobileBracketColumn(title: String, shortTitle: String, matches: [KnockoutMatch], accent: Color, level: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(.white)
                .frame(width: 190)
                .padding(.vertical, 8)
                .background(accent.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(spacing: mobileBracketCardSpacing(level: level)) {
                if matches.isEmpty {
                    mobileBracketPendingCard()
                } else {
                    ForEach(Array(matches.enumerated()), id: \.offset) { index, match in
                        mobileBracketMiniMatchCard(match: match, matchLabel: "\(shortTitle) \(index + 1)", accent: accent)
                    }
                }
            }
            .padding(.top, mobileBracketTopPadding(level: level))
        }
        .frame(width: 190, alignment: .top)
    }

    private var mobileBracketFinalColumn: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FINAL")
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(Color(red: 0.03, green: 0.07, blue: 0.12))
                .frame(width: 210)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.90))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            if let finalMatch = finalMatches.first {
                mobileBracketMiniMatchCard(match: finalMatch, matchLabel: "FINAL", accent: .yellow)
            } else {
                mobileBracketPendingCard(width: 210)
            }

            VStack(spacing: 10) {
                Text("🏆")
                    .font(.system(size: 58))

                if let champion = finalMatches.first?.winner {
                    Text("CHAMPION")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(.yellow)

                    Text("\(champion.flag) \(champion.name)")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                } else {
                    Text("CHAMPION")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(.yellow.opacity(0.7))

                    Text("Pending")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.65))
                }

                if let runnerUp = finalMatches.first?.loser {
                    Divider().background(Color.white.opacity(0.35))
                    Text("🥈 Runner-Up")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.75))
                    Text("\(runnerUp.flag) \(runnerUp.name)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }

                if let thirdPlace = thirdPlaceMatches.first?.winner {
                    Divider().background(Color.white.opacity(0.35))
                    Text("🥉 Third Place")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.75))
                    Text("\(thirdPlace.flag) \(thirdPlace.name)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 210)
            .padding(.vertical, 16)
            .background(Color.yellow.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.45), lineWidth: 1)
            )

        }
        .frame(width: 210, alignment: .top)
        .padding(.top, mobileBracketTopPadding(level: 4))
    }

    private func mobileBracketMiniMatchCard(match: KnockoutMatch, matchLabel: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(matchLabel)
                .font(.caption2)
                .fontWeight(.black)
                .foregroundStyle(.white.opacity(0.72))

            mobileBracketTeamLine(team: match.homeTeam, score: match.homeScore, winner: match.winner?.id == match.homeTeam?.id)
            mobileBracketTeamLine(team: match.awayTeam, score: match.awayScore, winner: match.winner?.id == match.awayTeam?.id)

            if let winner = match.winner {
                Text("Winner: \(winner.flag) \(winner.name)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                    .lineLimit(1)
            }
        }
        .padding(9)
        .frame(width: accent == .yellow ? 210 : 190, height: 96, alignment: .leading)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accent.opacity(0.65), lineWidth: 1)
        )
    }

    private func mobileBracketTeamLine(team: Team?, score: Int?, winner: Bool) -> some View {
        HStack(spacing: 6) {
            Text(team?.flag ?? "❔")
            Text(team?.name ?? "Pending")
                .font(.caption)
                .fontWeight(winner ? .black : .semibold)
                .foregroundStyle(winner ? .white : .white.opacity(0.82))
                .lineLimit(1)

            Spacer()

            Text(score.map { String($0) } ?? "-")
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(.white)
        }
    }

    private func mobileBracketPendingCard(width: CGFloat = 190) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "hourglass")
                .foregroundStyle(.white.opacity(0.55))
            Text("Pending")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white.opacity(0.65))
        }
        .frame(width: width, height: 72)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
    }
    
    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Knockout Stage")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("Tournament Bracket")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.65))
            }
            
            Spacer()
            
            Button {
                simulateKnockoutTournament()
            } label: {
                Label("Simulate Knockout Stage", systemImage: "dice.fill")
            }
            .buttonStyle(.borderedProminent)
            
            Image(systemName: "trophy.fill")
                .font(.largeTitle)
                .foregroundStyle(.yellow)
        }
    }
    
    private var bracketBoard: some View {
        HStack(alignment: .top, spacing: 28) {
            leftBracket
            centerTrophyArea
            rightBracket
        }
    }
    
    private var leftBracket: some View {
        HStack(alignment: .top, spacing: 0) {
            bracketColumn(title: "Last 32", matches: $roundOf32Matches, indices: firstHalfIndices(roundOf32Matches), side: .left)
            bracketColumn(title: "Last 16", matches: $roundOf16Matches, indices: firstHalfIndices(roundOf16Matches), side: .left)
            bracketColumn(title: "Quarter-Finals", matches: $quarterFinalMatches, indices: firstHalfIndices(quarterFinalMatches), side: .left)
            bracketColumn(title: "Semi-Finals", matches: $semiFinalMatches, indices: firstHalfIndices(semiFinalMatches), side: .left)
        }
    }
    
    private var rightBracket: some View {
        HStack(alignment: .top, spacing: 0) {
            bracketColumn(title: "Semi-Finals", matches: $semiFinalMatches, indices: secondHalfIndices(semiFinalMatches), side: .right)
            bracketColumn(title: "Quarter-Finals", matches: $quarterFinalMatches, indices: secondHalfIndices(quarterFinalMatches), side: .right)
            bracketColumn(title: "Last 16", matches: $roundOf16Matches, indices: secondHalfIndices(roundOf16Matches), side: .right)
            bracketColumn(title: "Last 32", matches: $roundOf32Matches, indices: secondHalfIndices(roundOf32Matches), side: .right)
        }
    }
    
    private var centerTrophyArea: some View {
        VStack(spacing: 18) {
            Text("Tournament")
                .font(.system(size: 54, weight: .black))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(.white.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            
            Text("🏆")
                .font(.system(size: 150))
                .shadow(color: .yellow.opacity(0.55), radius: 22)
            
            VStack(spacing: 10) {
                Text("FINAL")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(.yellow)
                
                if let finalMatch = finalMatches.first {
                    finalMatchCard(finalMatch)
                } else {
                    emptyFinalCard
                }
                
                if let champion = finalMatches.first?.winner {
                    championCard(champion)
                }
            }
        }
        .frame(width: 260)
        .padding(.horizontal, 8)
        .padding(.top, 62)
    }
    
    private func bracketColumn(title: String, matches: Binding<[KnockoutMatch]>, indices: [Int], side: BracketSide) -> some View {
        VStack(spacing: 14) {
            Text(title.uppercased())
                .font(.headline)
                .fontWeight(.black)
                .foregroundStyle(title == "Last 32" ? .white : .yellow)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .frame(width: 190)
                .background(title == "Last 32" ? Color.red : Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            
            if indices.isEmpty {
                waitingBracketCard()
                    .padding(.top, topPadding(for: title))
            } else {
                VStack(spacing: verticalSpacing(for: title)) {
                    ForEach(Array(indices.enumerated()), id: \.element) { position, index in
                        if matches.wrappedValue.indices.contains(index) {
                            HStack(spacing: 0) {
                                if side == .right {
                                    connectorLine(title: title, position: position, side: side)
                                }
                                
                                knockoutMatchCard(match: matches[index])
                                
                                if side == .left {
                                    connectorLine(title: title, position: position, side: side)
                                }
                            }
                        }
                    }
                }
                .padding(.top, topPadding(for: title))
            }
        }
    }
    
    private func knockoutMatchCard(match: Binding<KnockoutMatch>) -> some View {
        VStack(spacing: 0) {
            teamScoreRow(team: match.wrappedValue.homeTeam, score: match.homeScore)
            Divider().background(Color(red: 0.03, green: 0.12, blue: 0.24).opacity(0.22))
            teamScoreRow(team: match.wrappedValue.awayTeam, score: match.awayScore)
            
            if let winner = match.wrappedValue.winner {
                Text("Winner: \(winner.flag) \(winner.name)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(red: 0.00, green: 0.35, blue: 0.22))
                    .padding(.top, 6)
            } else if match.wrappedValue.isCompleted {
                Text("A winner cannot be determined from a draw")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                    .padding(.top, 6)
            }
        }
        .padding(8)
        .frame(width: 210, height: matchCardHeight)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.72, green: 0.94, blue: 0.96),
                            Color(red: 0.48, green: 0.82, blue: 0.90)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.65), lineWidth: 1.2)
        )
    }
    
    private func teamScoreRow(team: Team?, score: Binding<Int?>) -> some View {
        HStack(spacing: 8) {
            if let team {
                Text(team.flag)
                Text(team.name)
                    .lineLimit(1)
                    .foregroundStyle(Color(red: 0.03, green: 0.12, blue: 0.24))
            } else {
                Text("Pending")
                    .foregroundStyle(Color(red: 0.03, green: 0.12, blue: 0.24).opacity(0.55))
            }
            
            Spacer()
            
            TextField("0", value: score, format: .number)
                .frame(width: 42)
                .textFieldStyle(.roundedBorder)
                .disabled(team == nil)
        }
        .frame(height: 28)
    }
    

    private func connectorLine(title: String, position: Int, side: BracketSide) -> some View {
        let width: CGFloat = 60
        let height = matchCardHeight
        let centerY = height / 2
        let branchY = position.isMultiple(of: 2) ? height * 0.82 : height * 0.18
        
        return Path { path in
            let startX: CGFloat = side == .left ? 0 : width
            let middleX: CGFloat = width / 2
            let endX: CGFloat = side == .left ? width : 0
            
            path.move(to: CGPoint(x: startX, y: centerY))
            path.addLine(to: CGPoint(x: middleX, y: centerY))
            path.addLine(to: CGPoint(x: middleX, y: branchY))
            path.addLine(to: CGPoint(x: endX, y: branchY))
        }
        .stroke(
            LinearGradient(
                colors: [.white.opacity(0.96), .yellow.opacity(0.78)],
                startPoint: side == .left ? .leading : .trailing,
                endPoint: side == .left ? .trailing : .leading
            ),
            style: StrokeStyle(lineWidth: 3.2, lineCap: .round, lineJoin: .round)
        )
        .frame(width: width, height: height)
        .shadow(color: .yellow.opacity(0.22), radius: 3)
    }
    
    private func roundLevel(for title: String) -> Int {
        switch title {
        case "Last 32": return 0
        case "Last 16": return 1
        case "Quarter-Finals": return 2
        case "Semi-Finals": return 3
        default: return 0
        }
    }
    
    private func topPadding(for title: String) -> CGFloat {
        let level = roundLevel(for: title)
        let step = matchCardHeight + baseMatchSpacing
        let multiplier = pow(2.0, Double(level)) - 1
        return CGFloat(multiplier) * step / 2
    }
    
    private func verticalSpacing(for title: String) -> CGFloat {
        let level = roundLevel(for: title)
        let step = matchCardHeight + baseMatchSpacing
        let multiplier = pow(2.0, Double(level))
        return CGFloat(multiplier) * step - matchCardHeight
    }
    
    private func waitingBracketCard() -> some View {
        Text("Pending")
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.55))
            .frame(width: 210, height: matchCardHeight)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
    }
    
    private var emptyFinalCard: some View {
        HStack {
            Text("-")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.65))
            Divider().background(.white.opacity(0.35))
            Text("-")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.65))
        }
        .frame(width: 170, height: 62)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.20), lineWidth: 1)
        )
    }
    
    private func finalMatchCard(_ match: KnockoutMatch) -> some View {
        VStack(spacing: 6) {
            Text(match.homeTeam.map { "\($0.flag) \($0.name)" } ?? "-")
                .foregroundStyle(.white)
                .lineLimit(1)
            Text("vs")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
            Text(match.awayTeam.map { "\($0.flag) \($0.name)" } ?? "-")
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(10)
        .frame(width: 210)
        .background(Color.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.45), lineWidth: 1)
        )
    }
    
    private func championCard(_ team: Team) -> some View {
        VStack(spacing: 6) {
            Text("CHAMPION")
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(.yellow)
            Text("\(team.flag) \(team.name)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .padding()
        .frame(width: 230)
        .background(Color.yellow.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.yellow.opacity(0.60), lineWidth: 1)
        )
    }
    
    private func firstHalfIndices<T>(_ array: [T]) -> [Int] {
        guard !array.isEmpty else { return [] }
        return Array(0..<(array.count / 2))
    }
    
    private func secondHalfIndices<T>(_ array: [T]) -> [Int] {
        guard !array.isEmpty else { return [] }
        return Array((array.count / 2)..<array.count)
    }
    
    private func updateRoundOf16() {
        guard roundOf32Matches.count >= 16 else {
            roundOf16Matches = []
            return
        }

        let officialPairings = [
            (0, 2),   // Winner Match 73 vs Winner Match 75
            (1, 4),   // Winner Match 74 vs Winner Match 77
            (3, 5),   // Winner Match 76 vs Winner Match 78
            (6, 7),   // Winner Match 79 vs Winner Match 80
            (10, 11), // Winner Match 83 vs Winner Match 84
            (8, 9),   // Winner Match 81 vs Winner Match 82
            (13, 15), // Winner Match 86 vs Winner Match 88
            (12, 14)  // Winner Match 85 vs Winner Match 87
        ]

        let generatedMatches = officialPairings.compactMap { firstIndex, secondIndex -> KnockoutMatch? in
            guard let firstWinner = roundOf32Matches[firstIndex].winner,
                  let secondWinner = roundOf32Matches[secondIndex].winner else {
                return nil
            }

            return KnockoutMatch(round: .roundOf16, homeTeam: firstWinner, awayTeam: secondWinner)
        }

        roundOf16Matches = preserveScores(
            oldMatches: roundOf16Matches,
            newMatches: generatedMatches
        )
    }
    
    private func updateQuarterFinals() {
        guard roundOf16Matches.count >= 8 else {
            quarterFinalMatches = []
            return
        }

        let officialPairings = [
            (0, 1), // Winner Match 89 vs Winner Match 90
            (4, 5), // Winner Match 93 vs Winner Match 94
            (2, 3), // Winner Match 91 vs Winner Match 92
            (6, 7)  // Winner Match 95 vs Winner Match 96
        ]

        let generatedMatches = officialPairings.compactMap { firstIndex, secondIndex -> KnockoutMatch? in
            guard let firstWinner = roundOf16Matches[firstIndex].winner,
                  let secondWinner = roundOf16Matches[secondIndex].winner else {
                return nil
            }

            return KnockoutMatch(round: .quarterFinal, homeTeam: firstWinner, awayTeam: secondWinner)
        }

        quarterFinalMatches = preserveScores(
            oldMatches: quarterFinalMatches,
            newMatches: generatedMatches
        )
    }
    
    private func updateSemiFinals() {
        let winners = quarterFinalMatches.compactMap { $0.winner }
        semiFinalMatches = preserveScores(
            oldMatches: semiFinalMatches,
            newMatches: createMatches(from: winners, round: .semiFinal)
        )
    }
    
    private func updateFinal() {
        let winners = semiFinalMatches.compactMap { $0.winner }
        finalMatches = preserveScores(
            oldMatches: finalMatches,
            newMatches: createMatches(from: winners, round: .final)
        )
    }
    private func updateThirdPlace() {
        guard semiFinalMatches.count >= 2 else {
            thirdPlaceMatches = []
            return
        }

        let semiFinalLosers = semiFinalMatches.compactMap { $0.loser }
        thirdPlaceMatches = preserveScores(
            oldMatches: thirdPlaceMatches,
            newMatches: createMatches(from: semiFinalLosers, round: .thirdPlace)
        )
    }
    
    private func preserveScores(oldMatches: [KnockoutMatch], newMatches: [KnockoutMatch]) -> [KnockoutMatch] {
        var result: [KnockoutMatch] = []
        
        for newMatch in newMatches {
            if let existingMatch = oldMatches.first(where: {
                $0.homeTeam?.id == newMatch.homeTeam?.id &&
                $0.awayTeam?.id == newMatch.awayTeam?.id &&
                $0.round == newMatch.round
            }) {
                result.append(existingMatch)
            } else {
                result.append(newMatch)
            }
        }
        
        return result
    }
    
    private func createMatches(from teams: [Team], round: KnockoutRound) -> [KnockoutMatch] {
        var result: [KnockoutMatch] = []
        
        for index in stride(from: 0, to: teams.count, by: 2) {
            guard index + 1 < teams.count else { continue }
            result.append(KnockoutMatch(round: round, homeTeam: teams[index], awayTeam: teams[index + 1]))
        }
        
        return result
    }
    
    private func createRoundOf32Matches() -> [KnockoutMatch] {
        let groupOrder = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"]
        let standingsByGroup = Dictionary(
            uniqueKeysWithValues: groupOrder.map { group in
                (group, calculateStandings(for: group))
            }
        )

        let thirdPlacedTeams = groupOrder.compactMap { group -> Standing? in
            guard let standings = standingsByGroup[group], standings.indices.contains(2) else {
                return nil
            }
            return standings[2]
        }

        var availableThirdPlacedTeams = Array(
            thirdPlacedTeams
                .sorted {
                    if $0.points != $1.points { return $0.points > $1.points }
                    if $0.goalDifference != $1.goalDifference { return $0.goalDifference > $1.goalDifference }
                    if $0.goalsFor != $1.goalsFor { return $0.goalsFor > $1.goalsFor }
                    return $0.team.name < $1.team.name
                }
                .prefix(8)
        )

        func team(group: String, position: Int) -> Team? {
            guard let standings = standingsByGroup[group], standings.indices.contains(position - 1) else {
                return nil
            }
            return standings[position - 1].team
        }

        func takeBestThird(from eligibleGroups: [String]) -> Team? {
            if let eligibleIndex = availableThirdPlacedTeams.firstIndex(where: { eligibleGroups.contains($0.team.group) }) {
                return availableThirdPlacedTeams.remove(at: eligibleIndex).team
            }

            // Fallback for partial group-stage data in the simulator:
            // If no remaining best-third team belongs to the official eligible pool,
            // use the next best available third-placed team so the Round of 32 is always complete.
            guard !availableThirdPlacedTeams.isEmpty else {
                return nil
            }

            return availableThirdPlacedTeams.removeFirst().team
        }

        func makeMatch(homeTeam: Team?, awayTeam: Team?) -> KnockoutMatch {
            KnockoutMatch(round: .roundOf32, homeTeam: homeTeam, awayTeam: awayTeam)
        }

        return [
            makeMatch(homeTeam: team(group: "A", position: 2), awayTeam: team(group: "B", position: 2)),
            makeMatch(homeTeam: team(group: "E", position: 1), awayTeam: takeBestThird(from: ["A", "B", "C", "D", "F"])),
            makeMatch(homeTeam: team(group: "F", position: 1), awayTeam: team(group: "C", position: 2)),
            makeMatch(homeTeam: team(group: "C", position: 1), awayTeam: team(group: "F", position: 2)),
            makeMatch(homeTeam: team(group: "I", position: 1), awayTeam: takeBestThird(from: ["C", "D", "F", "G", "H"])),
            makeMatch(homeTeam: team(group: "E", position: 2), awayTeam: team(group: "I", position: 2)),
            makeMatch(homeTeam: team(group: "A", position: 1), awayTeam: takeBestThird(from: ["C", "E", "F", "H", "I"])),
            makeMatch(homeTeam: team(group: "L", position: 1), awayTeam: takeBestThird(from: ["E", "H", "I", "J", "K"])),
            makeMatch(homeTeam: team(group: "D", position: 1), awayTeam: takeBestThird(from: ["B", "E", "F", "I", "J"])),
            makeMatch(homeTeam: team(group: "G", position: 1), awayTeam: takeBestThird(from: ["A", "E", "H", "I", "J"])),
            makeMatch(homeTeam: team(group: "K", position: 2), awayTeam: team(group: "L", position: 2)),
            makeMatch(homeTeam: team(group: "H", position: 1), awayTeam: team(group: "J", position: 2)),
            makeMatch(homeTeam: team(group: "B", position: 1), awayTeam: takeBestThird(from: ["E", "F", "G", "I", "J"])),
            makeMatch(homeTeam: team(group: "D", position: 2), awayTeam: team(group: "G", position: 2)),
            makeMatch(homeTeam: team(group: "J", position: 1), awayTeam: team(group: "H", position: 2)),
            makeMatch(homeTeam: team(group: "K", position: 1), awayTeam: takeBestThird(from: ["D", "E", "I", "J", "L"]))
        ]
    }
    
    private func resetKnockoutTournament() {
        roundOf32Matches = createRoundOf32Matches()
        roundOf16Matches = []
        quarterFinalMatches = []
        semiFinalMatches = []
        thirdPlaceMatches = []
        finalMatches = []
        selectedMobileRound = .roundOf32
        savedKnockoutData = Data()
    }

    private func simulateKnockoutTournament() {
        isSimulatingKnockout = true

        var simulatedRoundOf32 = roundOf32Matches.isEmpty ? createRoundOf32Matches() : roundOf32Matches
        simulateMatches(&simulatedRoundOf32)

        let roundOf16Pairings = [
            (0, 2),
            (1, 4),
            (3, 5),
            (6, 7),
            (10, 11),
            (8, 9),
            (13, 15),
            (12, 14)
        ]

        var simulatedRoundOf16 = roundOf16Pairings.compactMap { firstIndex, secondIndex -> KnockoutMatch? in
            guard simulatedRoundOf32.indices.contains(firstIndex),
                  simulatedRoundOf32.indices.contains(secondIndex),
                  let firstWinner = simulatedRoundOf32[firstIndex].winner,
                  let secondWinner = simulatedRoundOf32[secondIndex].winner else {
                return nil
            }

            return KnockoutMatch(round: .roundOf16, homeTeam: firstWinner, awayTeam: secondWinner)
        }
        simulateMatches(&simulatedRoundOf16)

        let quarterFinalPairings = [
            (0, 1),
            (4, 5),
            (2, 3),
            (6, 7)
        ]

        var simulatedQuarterFinals = quarterFinalPairings.compactMap { firstIndex, secondIndex -> KnockoutMatch? in
            guard simulatedRoundOf16.indices.contains(firstIndex),
                  simulatedRoundOf16.indices.contains(secondIndex),
                  let firstWinner = simulatedRoundOf16[firstIndex].winner,
                  let secondWinner = simulatedRoundOf16[secondIndex].winner else {
                return nil
            }

            return KnockoutMatch(round: .quarterFinal, homeTeam: firstWinner, awayTeam: secondWinner)
        }
        simulateMatches(&simulatedQuarterFinals)

        var simulatedSemiFinals = createMatches(
            from: simulatedQuarterFinals.compactMap { $0.winner },
            round: .semiFinal
        )
        simulateMatches(&simulatedSemiFinals)

        var simulatedThirdPlaceMatches = createMatches(
            from: simulatedSemiFinals.compactMap { $0.loser },
            round: .thirdPlace
        )
        simulateMatches(&simulatedThirdPlaceMatches)

        var simulatedFinals = createMatches(
            from: simulatedSemiFinals.compactMap { $0.winner },
            round: .final
        )
        simulateMatches(&simulatedFinals)

        print("========== Knockout Simulation Debug ==========")
        print("Round of 32: \(simulatedRoundOf32.count) matches, winners: \(simulatedRoundOf32.compactMap { $0.winner }.count)")
        print("Round of 16: \(simulatedRoundOf16.count) matches, winners: \(simulatedRoundOf16.compactMap { $0.winner }.count)")
        print("Quarter-Finals: \(simulatedQuarterFinals.count) matches, winners: \(simulatedQuarterFinals.compactMap { $0.winner }.count)")
        print("Semi-Finals: \(simulatedSemiFinals.count) matches, winners: \(simulatedSemiFinals.compactMap { $0.winner }.count)")
        print("Third Place: \(simulatedThirdPlaceMatches.count) matches, winners: \(simulatedThirdPlaceMatches.compactMap { $0.winner }.count)")
        print("Finals: \(simulatedFinals.count) matches, winners: \(simulatedFinals.compactMap { $0.winner }.count)")
        print("===============================================")

        roundOf32Matches = simulatedRoundOf32
        roundOf16Matches = simulatedRoundOf16
        quarterFinalMatches = simulatedQuarterFinals
        semiFinalMatches = simulatedSemiFinals
        thirdPlaceMatches = simulatedThirdPlaceMatches
        finalMatches = simulatedFinals
        saveKnockoutMatches()

        DispatchQueue.main.async {
            isSimulatingKnockout = false
        }
    }
    
    private func simulateMatches(_ matches: inout [KnockoutMatch]) {
        for index in matches.indices {
            if matches[index].homeTeam != nil &&
                matches[index].awayTeam != nil &&
                matches[index].winner == nil {
                var homeScore = Int.random(in: 0...4)
                var awayScore = Int.random(in: 0...4)
                
                while homeScore == awayScore {
                    homeScore = Int.random(in: 0...4)
                    awayScore = Int.random(in: 0...4)
                }
                
                matches[index].homeScore = homeScore
                matches[index].awayScore = awayScore
            }
        }
    }
    
    private func calculateStandings(for group: String) -> [Standing] {
        let groupTeams = teams.filter { $0.group == group }
        let groupMatches = matches.filter { $0.group == group }
        var table = groupTeams.map { Standing(team: $0) }
        
        for match in groupMatches {
            guard let homeScore = match.homeScore,
                  let awayScore = match.awayScore,
                  let homeIndex = table.firstIndex(where: { $0.team.id == match.homeTeam.id }),
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
            if $0.points != $1.points { return $0.points > $1.points }
            if $0.goalDifference != $1.goalDifference { return $0.goalDifference > $1.goalDifference }
            if $0.goalsFor != $1.goalsFor { return $0.goalsFor > $1.goalsFor }
            return $0.team.name < $1.team.name
        }
    }
    
    private func saveKnockoutMatches() {
        let allRounds = SavedKnockoutData(
            roundOf32: roundOf32Matches,
            roundOf16: roundOf16Matches,
            quarterFinal: quarterFinalMatches,
            semiFinal: semiFinalMatches,
            thirdPlace: thirdPlaceMatches,
            final: finalMatches
        )
        
        do {
            savedKnockoutData = try JSONEncoder().encode(allRounds)
        } catch {
            print("Knockout stage data could not be saved.")
        }
    }

    private func loadKnockoutMatches() {
        guard !savedKnockoutData.isEmpty else {
            roundOf32Matches = createRoundOf32Matches()
            return
        }
        
        do {
            let saved = try JSONDecoder().decode(SavedKnockoutData.self, from: savedKnockoutData)
            roundOf32Matches = saved.roundOf32
            roundOf16Matches = saved.roundOf16
            quarterFinalMatches = saved.quarterFinal
            semiFinalMatches = saved.semiFinal
            thirdPlaceMatches = saved.thirdPlace
            finalMatches = saved.final
        } catch {
            roundOf32Matches = createRoundOf32Matches()
        }
    }
}

private struct KnockoutInlineNavigationTitleIfAvailable: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        content.navigationBarTitleDisplayMode(.inline)
        #else
        content
        #endif
    }
}

private enum BracketSide {
    case left
    case right
}

struct SavedKnockoutData: Codable {
    let roundOf32: [KnockoutMatch]
    let roundOf16: [KnockoutMatch]
    let quarterFinal: [KnockoutMatch]
    let semiFinal: [KnockoutMatch]
    let thirdPlace: [KnockoutMatch]
    let final: [KnockoutMatch]
}


