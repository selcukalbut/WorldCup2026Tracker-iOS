//
//  Models.swift
//  GlobalSportsTracker
//

import Foundation

struct Team: Identifiable, Hashable, Codable, Equatable {
    var id: String {
        "\(group)-\(name)"
    }

    let name: String
    let group: String
    let flag: String
    let rating: Int
    
    init(name: String, group: String, flag: String, rating: Int = 80) {
        self.name = name
        self.group = group
        self.flag = flag
        self.rating = rating
    }
}

struct Match: Identifiable, Codable, Equatable {
    let id: UUID
    let group: String
    let homeTeam: Team
    let awayTeam: Team
    var homeScore: Int?
    var awayScore: Int?
    let date: String
    let venue: String
    
    init(
        id: UUID = UUID(),
        group: String,
        homeTeam: Team,
        awayTeam: Team,
        homeScore: Int? = nil,
        awayScore: Int? = nil,
        date: String,
        venue: String = ""
    ) {
        self.id = id
        self.group = group
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.date = date
        self.venue = venue
    }
}

struct Standing: Identifiable, Codable, Equatable {
    var id: String {
        team.id
    }

    let team: Team
    var played: Int = 0
    var won: Int = 0
    var drawn: Int = 0
    var lost: Int = 0
    var goalsFor: Int = 0
    var goalsAgainst: Int = 0

    var goalDifference: Int {
        goalsFor - goalsAgainst
    }

    var points: Int {
        won * 3 + drawn
    }
}

enum KnockoutRound: String, Codable, CaseIterable {
    case roundOf32 = "Round of 32"
    case roundOf16 = "Round of 16"
    case quarterFinal = "Quarter_Final"
    case semiFinal = "Semi-Final"
    case thirdPlace = "Third Place"
    case final = "Final"
}

struct KnockoutMatch: Identifiable, Codable, Equatable {
    let id: UUID
    let round: KnockoutRound
    let homeTeam: Team?
    let awayTeam: Team?
    var homeScore: Int?
    var awayScore: Int?
    
    init(
        id: UUID = UUID(),
        round: KnockoutRound,
        homeTeam: Team?,
        awayTeam: Team?,
        homeScore: Int? = nil,
        awayScore: Int? = nil
    ) {
        self.id = id
        self.round = round
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeScore = homeScore
        self.awayScore = awayScore
    }
    
    var isCompleted: Bool {
        homeScore != nil && awayScore != nil
    }
    
    var winner: Team? {
        guard let homeScore,
              let awayScore,
              let homeTeam,
              let awayTeam else {
            return nil
        }
        
        if homeScore > awayScore {
            return homeTeam
        } else if awayScore > homeScore {
            return awayTeam
        } else {
            return nil
        }
    }
    var loser: Team? {
        guard let homeScore, let awayScore else { return nil }
        if homeScore < awayScore { return homeTeam }
        if awayScore < homeScore { return awayTeam }
        return nil
    }
    
}
