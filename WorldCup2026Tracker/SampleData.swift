//
//  SampleData.swift
//  GlobalSportsTracker
//
//  Created by Selcuk Albut on 3.06.2026.
//

import Foundation

let sampleTeams: [Team] = [
    // Group A
    Team(name: "Mexico", group: "A", flag: "🇲🇽", rating: 82),
    Team(name: "South Africa", group: "A", flag: "🇿🇦", rating: 75),
    Team(name: "Korea Republic", group: "A", flag: "🇰🇷", rating: 83),
    Team(name: "Czechia", group: "A", flag: "🇨🇿", rating: 82),

    // Group B
    Team(name: "Canada", group: "B", flag: "🇨🇦", rating: 81),
    Team(name: "Bosnia and Herzegovina", group: "B", flag: "🇧🇦", rating: 78),
    Team(name: "Qatar", group: "B", flag: "🇶🇦", rating: 77),
    Team(name: "Switzerland", group: "B", flag: "🇨🇭", rating: 85),

    // Group C
    Team(name: "Brazil", group: "C", flag: "🇧🇷", rating: 92),
    Team(name: "Morocco", group: "C", flag: "🇲🇦", rating: 88),
    Team(name: "Haiti", group: "C", flag: "🇭🇹", rating: 72),
    Team(name: "Scotland", group: "C", flag: "🏴", rating: 82),

    // Group D
    Team(name: "United States", group: "D", flag: "🇺🇸", rating: 83),
    Team(name: "Paraguay", group: "D", flag: "🇵🇾", rating: 81),
    Team(name: "Australia", group: "D", flag: "🇦🇺", rating: 80),
    Team(name: "Türkiye", group: "D", flag: "🇹🇷", rating: 85),

    // Group E
    Team(name: "Germany", group: "E", flag: "🇩🇪", rating: 89),
    Team(name: "Curaçao", group: "E", flag: "🇨🇼", rating: 72),
    Team(name: "Côte d'Ivoire", group: "E", flag: "🇨🇮", rating: 81),
    Team(name: "Ecuador", group: "E", flag: "🇪🇨", rating: 84),

    // Group F
    Team(name: "Netherlands", group: "F", flag: "🇳🇱", rating: 91),
    Team(name: "Japan", group: "F", flag: "🇯🇵", rating: 86),
    Team(name: "Sweden", group: "F", flag: "🇸🇪", rating: 82),
    Team(name: "Tunisia", group: "F", flag: "🇹🇳", rating: 79),

    // Group G
    Team(name: "Belgium", group: "G", flag: "🇧🇪", rating: 87),
    Team(name: "Egypt", group: "G", flag: "🇪🇬", rating: 82),
    Team(name: "Iran", group: "G", flag: "🇮🇷", rating: 82),
    Team(name: "New Zealand", group: "G", flag: "🇳🇿", rating: 73),

    // Group H
    Team(name: "Spain", group: "H", flag: "🇪🇸", rating: 95),
    Team(name: "Cape Verde", group: "H", flag: "🇨🇻", rating: 76),
    Team(name: "Saudi Arabia", group: "H", flag: "🇸🇦", rating: 77),
    Team(name: "Uruguay", group: "H", flag: "🇺🇾", rating: 88),

    // Group I
    Team(name: "France", group: "I", flag: "🇫🇷", rating: 95),
    Team(name: "Senegal", group: "I", flag: "🇸🇳", rating: 84),
    Team(name: "Iraq", group: "I", flag: "🇮🇶", rating: 75),
    Team(name: "Norway", group: "I", flag: "🇳🇴", rating: 84),

    // Group J
    Team(name: "Argentina", group: "J", flag: "🇦🇷", rating: 94),
    Team(name: "Algeria", group: "J", flag: "🇩🇿", rating: 82),
    Team(name: "Austria", group: "J", flag: "🇦🇹", rating: 84),
    Team(name: "Jordan", group: "J", flag: "🇯🇴", rating: 74),

    // Group K
    Team(name: "Portugal", group: "K", flag: "🇵🇹", rating: 92),
    Team(name: "DR Congo", group: "K", flag: "🇨🇩", rating: 77),
    Team(name: "Uzbekistan", group: "K", flag: "🇺🇿", rating: 76),
    Team(name: "Colombia", group: "K", flag: "🇨🇴", rating: 87),

    // Group L
    Team(name: "England", group: "L", flag: "🏴", rating: 93),
    Team(name: "Croatia", group: "L", flag: "🇭🇷", rating: 87),
    Team(name: "Ghana", group: "L", flag: "🇬🇭", rating: 80),
    Team(name: "Panama", group: "L", flag: "🇵🇦", rating: 76)
]

let sampleMatches: [Match] = createGroupStageMatches(from: sampleTeams)

private func createGroupStageMatches(from teams: [Team]) -> [Match] {
    let groupedTeams = Dictionary(grouping: teams, by: { $0.group })
    var matches: [Match] = []

    func addMatch(group: String, teams groupTeams: [Team], homeIndex: Int, awayIndex: Int, date: String, venue: String) {
        matches.append(
            Match(
                group: group,
                homeTeam: groupTeams[homeIndex],
                awayTeam: groupTeams[awayIndex],
                date: date,
                venue: venue
            )
        )
    }

    for group in groupedTeams.keys.sorted() {
        guard let groupTeams = groupedTeams[group], groupTeams.count == 4 else {
            continue
        }

        switch group {
        case "A":
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "11 June 2026", venue: "Mexico City Stadium, Mexico City")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "12 June 2026", venue: "Guadalajara Stadium, Zapopan")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "18 June 2026", venue: "Atlanta Stadium, Atlanta")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "19 June 2026", venue: "Guadalajara Stadium, Zapopan")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "25 June 2026", venue: "Monterrey Stadium, Guadalupe")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "25 June 2026", venue: "Mexico City Stadium, Mexico City")

        case "B":
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "12 June 2026", venue: "Toronto Stadium, Toronto")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "13 June 2026", venue: "San Francisco Bay Area Stadium, Santa Clara")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "18 June 2026", venue: "Los Angeles Stadium, Los Angeles")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "18 June 2026", venue: "Vancouver Stadium, Vancouver")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "24 June 2026", venue: "Vancouver Stadium, Vancouver")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "24 June 2026", venue: "Seattle Stadium, Seattle")

        case "C":
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "13 June 2026", venue: "New York New Jersey Stadium, East Rutherford")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "14 June 2026", venue: "Boston Stadium, Foxborough")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "19 June 2026", venue: "Boston Stadium, Foxborough")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "20 June 2026", venue: "Philadelphia Stadium, Philadelphia")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "24 June 2026", venue: "Atlanta Stadium, Atlanta")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "24 June 2026", venue: "Miami Stadium, Miami")

        case "D":
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "13 June 2026", venue: "Los Angeles Stadium, Los Angeles")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "14 June 2026", venue: "Vancouver Stadium, Vancouver")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "19 June 2026", venue: "Seattle Stadium, Seattle")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "20 June 2026", venue: "San Francisco Bay Area Stadium, Santa Clara")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "26 June 2026", venue: "Los Angeles Stadium, Los Angeles")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "26 June 2026", venue: "San Francisco Bay Area Stadium, Santa Clara")

        case "E":
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "14 June 2026", venue: "Houston Stadium, Houston")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "15 June 2026", venue: "Philadelphia Stadium, Philadelphia")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "20 June 2026", venue: "Toronto Stadium, Toronto")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "21 June 2026", venue: "Kansas City Stadium, Kansas City")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "25 June 2026", venue: "Philadelphia Stadium, Philadelphia")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "25 June 2026", venue: "New York New Jersey Stadium, East Rutherford")

        case "F":
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "14 June 2026", venue: "Dallas Stadium, Arlington")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "15 June 2026", venue: "Monterrey Stadium, Guadalupe")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "20 June 2026", venue: "Houston Stadium, Houston")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "21 June 2026", venue: "Monterrey Stadium, Guadalupe")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "26 June 2026", venue: "Kansas City Stadium, Kansas City")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "26 June 2026", venue: "Dallas Stadium, Arlington")

        case "G":
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "15 June 2026", venue: "Seattle Stadium, Seattle")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "16 June 2026", venue: "Los Angeles Stadium, Los Angeles")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "21 June 2026", venue: "Los Angeles Stadium, Los Angeles")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "22 June 2026", venue: "Vancouver Stadium, Vancouver")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "27 June 2026", venue: "Vancouver Stadium, Vancouver")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "27 June 2026", venue: "Seattle Stadium, Seattle")

        case "H":
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "15 June 2026", venue: "Atlanta Stadium, Atlanta")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "15 June 2026", venue: "Miami Stadium, Miami")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "21 June 2026", venue: "Atlanta Stadium, Atlanta")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "21 June 2026", venue: "Miami Stadium, Miami")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "27 June 2026", venue: "Houston Stadium, Houston")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "27 June 2026", venue: "Guadalajara Stadium, Zapopan")

        case "I":
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "16 June 2026", venue: "New York New Jersey Stadium, East Rutherford")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "16 June 2026", venue: "Boston Stadium, Foxborough")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "22 June 2026", venue: "Philadelphia Stadium, Philadelphia")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "23 June 2026", venue: "Toronto Stadium, Toronto")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "26 June 2026", venue: "Boston Stadium, Foxborough")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "26 June 2026", venue: "Toronto Stadium, Toronto")

        case "J":
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "17 June 2026", venue: "Kansas City Stadium, Kansas City")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "17 June 2026", venue: "San Francisco Bay Area Stadium, Santa Clara")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "22 June 2026", venue: "Dallas Stadium, Arlington")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "23 June 2026", venue: "San Francisco Bay Area Stadium, Santa Clara")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "28 June 2026", venue: "Kansas City Stadium, Kansas City")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "28 June 2026", venue: "Dallas Stadium, Arlington")

        case "K":
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "17 June 2026", venue: "Houston Stadium, Houston")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "18 June 2026", venue: "Mexico City Stadium, Mexico City")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "23 June 2026", venue: "Houston Stadium, Houston")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "24 June 2026", venue: "Guadalajara Stadium, Zapopan")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "28 June 2026", venue: "Miami Stadium, Miami")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "28 June 2026", venue: "Atlanta Stadium, Atlanta")

        case "L":
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "17 June 2026", venue: "Dallas Stadium, Arlington")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "18 June 2026", venue: "Toronto Stadium, Toronto")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "23 June 2026", venue: "Boston Stadium, Foxborough")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "24 June 2026", venue: "Boston Stadium, Foxborough")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "27 June 2026", venue: "New York New Jersey Stadium, East Rutherford")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "27 June 2026", venue: "Philadelphia Stadium, Philadelphia")

        default:
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 1, date: "Matchday 1", venue: "TBD")
            addMatch(group: group, teams: groupTeams, homeIndex: 2, awayIndex: 3, date: "Matchday 1", venue: "TBD")
            addMatch(group: group, teams: groupTeams, homeIndex: 0, awayIndex: 2, date: "Matchday 2", venue: "TBD")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 1, date: "Matchday 2", venue: "TBD")
            addMatch(group: group, teams: groupTeams, homeIndex: 3, awayIndex: 0, date: "Matchday 3", venue: "TBD")
            addMatch(group: group, teams: groupTeams, homeIndex: 1, awayIndex: 2, date: "Matchday 3", venue: "TBD")
        }
    }

    return matches
}
