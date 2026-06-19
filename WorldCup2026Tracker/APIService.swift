import Foundation
import Combine

@MainActor
final class APIService: ObservableObject {
    static let shared = APIService()

    @Published var isLoading = false
    @Published var lastUpdate: Date?
    @Published var statusMessage: String = "API Infrastructure Ready"
    @Published var lastFetchedMatchCount: Int = 0

    private let baseURL = "https://v3.football.api-sports.io"
    private let apiKey = "3d19bb7a1646a257e475a6f8ec4aa35c"

    private init() {}

    func fetchMatches() async throws -> [RemoteMatch] {
        isLoading = true
        statusMessage = "Loading match data..."
        lastFetchedMatchCount = 0

        defer {
            isLoading = false
            lastUpdate = Date()
        }

        guard let url = URL(string: "\(baseURL)/fixtures?league=1&season=2026") else {
            statusMessage = "Invalid API URL"
            return []
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey,
                         forHTTPHeaderField: "x-apisports-key")

        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
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

            let apiResponse = try decoder.decode(
                APIFootballResponse.self,
                from: data
            )

            let remoteMatches = apiResponse.response.map {
                $0.toRemoteMatch()
            }

            lastFetchedMatchCount = remoteMatches.count
            statusMessage = "\(remoteMatches.count) API-Football matches loaded"

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
        case "1H", "2H", "HT", "LIVE":
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

struct APIFootballResponse: Codable {
    let response: [APIFixture]
}

struct APIFixture: Codable {
    let fixture: APIFixtureInfo
    let teams: APITeams
    let goals: APIGoals

    func toRemoteMatch() -> RemoteMatch {
        RemoteMatch(
            id: fixture.id,
            homeTeam: teams.home.name,
            awayTeam: teams.away.name,
            homeScore: goals.home,
            awayScore: goals.away,
            venue: fixture.venue.name,
            city: fixture.venue.city,
            matchDate: fixture.date,
            status: fixture.status.short
        )
    }
}

struct APIFixtureInfo: Codable {
    let id: Int
    let date: Date
    let venue: APIVenue
    let status: APIStatus
}

struct APIVenue: Codable {
    let name: String?
    let city: String?
}

struct APIStatus: Codable {
    let short: String
}

struct APITeams: Codable {
    let home: APITeam
    let away: APITeam
}

struct APITeam: Codable {
    let name: String
}

struct APIGoals: Codable {
    let home: Int?
    let away: Int?
}

