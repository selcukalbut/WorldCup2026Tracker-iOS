//
//  TournamentSelectionView.swift
//  WorldCup2026Tracker
//
//  Created by Selcuk Albut on 14.06.2026.
//

import SwiftUI

struct TournamentSelectionView: View {
    @AppStorage("selectedTournament") private var selectedTournament: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection

                    tournamentCard(
                        icon: "⚽",
                        title: "International Football 2026",
                        subtitle: "Live scores, fixtures, standings, knockout stage and tournament analytics.",
                        buttonTitle: "Open Tournament",
                        statusText: "Available",
                        isEnabled: true
                    ) {
                        selectedTournament = "football2026"
                    }

                    tournamentCard(
                        icon: "🏀 🏐 ⚽",
                        title: "Future Sports Tournaments",
                        subtitle: "Basketball, volleyball and other international sporting events will be added in future versions.",
                        buttonTitle: "Coming Soon",
                        statusText: "Planned",
                        isEnabled: false
                    ) { }
                }
                .padding(24)
            }
            .navigationTitle("Choose Tournament")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🌍 Global Sports Tracker")
                .font(.largeTitle)
                .fontWeight(.black)

            Text("Choose your tournament")
                .font(.title2)
                .fontWeight(.bold)

            Text("Track live scores, fixtures, standings and tournament analytics across global sports events.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private func tournamentCard(
        icon: String,
        title: String,
        subtitle: String,
        buttonTitle: String,
        statusText: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Text(icon)
                    .font(.system(size: 44))

                Spacer()

                Text(statusText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isEnabled ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                    .foregroundStyle(isEnabled ? .green : .orange)
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: action) {
                Text(buttonTitle)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isEnabled)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.14),
                    Color.cyan.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(isEnabled ? Color.cyan.opacity(0.35) : Color.gray.opacity(0.25), lineWidth: 1)
        )
    }
}
