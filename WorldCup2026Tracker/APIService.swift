import Foundation
import Combine

@MainActor
final class APIService: ObservableObject {
    static let shared = APIService()

    @Published var isLoading = false
    @Published var lastUpdate: Date?
    @Published var statusMessage: String = "API Infrastructure Ready"
    @Published var lastFetchedMatchCount: Int = 0

    private let baseURL = "https://api.football-data.org/v4"
    private let apiToken = "3a5a9eef4bde44a0b599535bd09fa889"

    private init() {}

    func fetchMatches() async throws -> [RemoteMatch] {
        isLoading = true
        statusMessage = "Loading match data..."
        lastFetchedMatchCount = 0

        defer {
            isLoading = false
            lastUpdate = Date()
        }

        guard let url = URL(string: "\(baseURL)/competitions/WC/matches") else {
            statusMessage = "Invalid API URL"
            return []
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiToken, forHTTPHeaderField: "X-Auth-Token")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                statusMessage = "Unable to read API response"
                return []
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                statusMessage = "API Error: HTTP \(httpResponse.statusCode)"
                return []
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let apiResponse = try decoder.decode(FootballDataMatchesResponse.self, from: data)
            let remoteMatches = apiResponse.matches.map { $0.toRemoteMatch() }

            lastFetchedMatchCount = remoteMatches.count
            statusMessage = "\(remoteMatches.count) match records loaded"

            return remoteMatches
        } catch {
            statusMessage = "Connection/API Error: \(error.localizedDescription)"
            return []
        }
    }
}

struct RemoteMatch: Codable, Identifiable {
    let id: Int
    let homeTeam: String
    let awayTeam: String
    let homeScore: Int?
    let awayScore: Int?
    let venue: String?
    let city: String?
    let matchDate: Date?
    let status: String?
    var statusText: String {
        status ?? "UNKNOWN"
    }

    var statusBadge: String {
        switch statusText {
        case "LIVE", "IN_PLAY":
            return "🟢 LIVE"
        case "PAUSED":
            return "🟠 PAUSED"
        case "FINISHED":
            return "⚫ FINISHED"
        case "SCHEDULED", "TIMED":
            return "🔵 SCHEDULED"
        default:
            return "⚪ \(statusText)"
        }
    }

    var scoreText: String {
        if let homeScore = homeScore,
           let awayScore = awayScore {
            return "\(homeScore) - \(awayScore)"
        }
        return "VS"
    }
}

struct FootballDataMatchesResponse: Codable {
    let matches: [FootballDataMatch]
}

struct FootballDataMatch: Codable {
    let id: Int
    let utcDate: Date?
    let status: String?
    let homeTeam: FootballDataTeamRef
    let awayTeam: FootballDataTeamRef
    let score: FootballDataScore?

    func toRemoteMatch() -> RemoteMatch {
        RemoteMatch(
            id: id,
            homeTeam: homeTeam.name ?? "Unknown Home Team",
            awayTeam: awayTeam.name ?? "Unknown Away Team",
            homeScore: score?.fullTime?.home,
            awayScore: score?.fullTime?.away,
            venue: nil,
            city: nil,
            matchDate: utcDate,
            status: status
        )
    }
}

struct FootballDataTeamRef: Codable {
    let name: String?
}

struct FootballDataScore: Codable {
    let fullTime: FootballDataScoreLine?
}

struct FootballDataScoreLine: Codable {
    let home: Int?
    let away: Int?
}
