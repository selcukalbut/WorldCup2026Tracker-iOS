import SwiftUI

struct KnockoutView: View {
    let teams: [Team]
    let matches: [Match]
    
    @State private var roundOf32Matches: [KnockoutMatch] = []
    @State private var roundOf16Matches: [KnockoutMatch] = []
    @State private var quarterFinalMatches: [KnockoutMatch] = []
    @State private var semiFinalMatches: [KnockoutMatch] = []
    @State private var finalMatches: [KnockoutMatch] = []
    @AppStorage("savedKnockoutMatches") private var savedKnockoutData: Data = Data()
    @State private var selectedMobileRound: KnockoutRound = .roundOf32
    
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
            updateRoundOf16()
            saveKnockoutMatches()
        }
        .onChange(of: roundOf16Matches) { _, _ in
            updateQuarterFinals()
            saveKnockoutMatches()
        }
        .onChange(of: quarterFinalMatches) { _, _ in
            updateSemiFinals()
            saveKnockoutMatches()
        }
        .onChange(of: semiFinalMatches) { _, _ in
            updateFinal()
            saveKnockoutMatches()
        }
        .onChange(of: finalMatches) { _, _ in
            saveKnockoutMatches()
        }
    }

    private var mobileKnockoutView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                mobileHeader
                mobileRoundSelector
                mobileSelectedRoundList
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
            updateRoundOf16()
            saveKnockoutMatches()
        }
        .onChange(of: roundOf16Matches) { _, _ in
            updateQuarterFinals()
            saveKnockoutMatches()
        }
        .onChange(of: quarterFinalMatches) { _, _ in
            updateSemiFinals()
            saveKnockoutMatches()
        }
        .onChange(of: semiFinalMatches) { _, _ in
            updateFinal()
            saveKnockoutMatches()
        }
        .onChange(of: finalMatches) { _, _ in
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
                mobileInfoBox(value: "5", title: "Rounds")
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
        VStack(alignment: .leading, spacing: 12) {
            Text("🏅 Champion")
                .font(.title2)
                .fontWeight(.bold)
            
            if let champion = finalMatches.first?.winner {
                HStack(spacing: 14) {
                    Text(champion.flag)
                        .font(.largeTitle)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(champion.name)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Tournament Champion")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            } else {
                Text("No champion has been determined yet. You can progress by simulating the knockout stage or entering match scores.")
                    .foregroundStyle(.secondary)
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
        case .final: return "Finals"
        }
    }
    
    private func mobileMatches(for round: KnockoutRound) -> [KnockoutMatch] {
        switch round {
        case .roundOf32: return roundOf32Matches
        case .roundOf16: return roundOf16Matches
        case .quarterFinal: return quarterFinalMatches
        case .semiFinal: return semiFinalMatches
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
        case .final:
            return finalMatches.indices.map { $finalMatches[$0] }
        }
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
        .background(Color.white.opacity(0.08))
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
        let winners = roundOf32Matches.compactMap { $0.winner }
        roundOf16Matches = preserveScores(
            oldMatches: roundOf16Matches,
            newMatches: createMatches(from: winners, round: .roundOf16)
        )
    }
    
    private func updateQuarterFinals() {
        let winners = roundOf16Matches.compactMap { $0.winner }
        quarterFinalMatches = preserveScores(
            oldMatches: quarterFinalMatches,
            newMatches: createMatches(from: winners, round: .quarterFinal)
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
        let groupOrder = Array(Set(teams.map { $0.group })).sorted()
        var groupWinners: [Team] = []
        var groupRunnersUp: [Team] = []
        var thirdPlacedTeams: [Standing] = []
        
        for group in groupOrder {
            let standings = calculateStandings(for: group)
            
            if standings.count >= 3 {
                groupWinners.append(standings[0].team)
                groupRunnersUp.append(standings[1].team)
                thirdPlacedTeams.append(standings[2])
            }
        }
        
        let bestThirdPlacedTeams = thirdPlacedTeams
            .sorted {
                if $0.points != $1.points { return $0.points > $1.points }
                if $0.goalDifference != $1.goalDifference { return $0.goalDifference > $1.goalDifference }
                if $0.goalsFor != $1.goalsFor { return $0.goalsFor > $1.goalsFor }
                return $0.team.name < $1.team.name
            }
            .prefix(8)
            .map { $0.team }
        
        let qualifiedTeams = groupWinners + groupRunnersUp + bestThirdPlacedTeams
        var result: [KnockoutMatch] = []
        
        for index in stride(from: 0, to: qualifiedTeams.count, by: 2) {
            guard index + 1 < qualifiedTeams.count else { continue }
            result.append(KnockoutMatch(round: .roundOf32, homeTeam: qualifiedTeams[index], awayTeam: qualifiedTeams[index + 1]))
        }
        
        return result
    }
    
    private func resetKnockoutTournament() {
        roundOf32Matches = createRoundOf32Matches()
        roundOf16Matches = []
        quarterFinalMatches = []
        semiFinalMatches = []
        finalMatches = []
        selectedMobileRound = .roundOf32
        savedKnockoutData = Data()
    }

    private func simulateKnockoutTournament() {
        if roundOf32Matches.isEmpty {
            roundOf32Matches = createRoundOf32Matches()
        }
        
        simulateMatches(&roundOf32Matches)
        updateRoundOf16()
        simulateMatches(&roundOf16Matches)
        updateQuarterFinals()
        simulateMatches(&quarterFinalMatches)
        updateSemiFinals()
        simulateMatches(&semiFinalMatches)
        updateFinal()
        simulateMatches(&finalMatches)
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
    let final: [KnockoutMatch]
}
