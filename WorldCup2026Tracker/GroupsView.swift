//
//  GroupsView.swift
//  GlobalSportsTracker
//
//  Created by Selcuk Albut on 3.06.2026.
//

import SwiftUI

struct GroupsView: View {
    let teams: [Team]
    let matches: [Match]
    @Binding var favoriteTeamID: String
    
    var groupedTeams: [String: [Team]] {
        Dictionary(grouping: teams, by: { $0.group })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                infoCard
                groupGrid
            }
            .padding(24)
        }
        .navigationTitle("Groups")
    }
    
    private var infoCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.blue)
            
            Text("Tap a team name to view detailed statistics and match information. Use the star icon to select your favorite team.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
    
    private var groupGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 18)], spacing: 18) {
            ForEach(groupedTeams.keys.sorted(), id: \.self) { group in
                groupCard(group: group, teams: groupedTeams[group] ?? [])
            }
        }
    }
    
    private func groupCard(group: String, teams: [Team]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Group \(group)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("\(teams.count) Team")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.85))
            }
            
            VStack(spacing: 10) {
                ForEach(teams) { team in
                    teamTile(team)
                }
            }
        }
        .padding()
        .background(groupColor(group))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(radius: 4, y: 2)
    }
    
    private func teamTile(_ team: Team) -> some View {
        NavigationLink {
            TeamProfileView(
                team: team,
                matches: matches,
                favoriteTeamID: favoriteTeamID
            )
        } label: {
            HStack(spacing: 10) {
                Text(team.flag)
                    .font(.title2)
                
                Text(team.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    toggleFavorite(team)
                } label: {
                    Image(systemName: favoriteTeamID == team.id ? "star.fill" : "star")
                        .foregroundStyle(favoriteTeamID == team.id ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
    
    private func groupColor(_ group: String) -> Color {
        switch group {
        case "A": return .blue
        case "B": return .green
        case "C": return .orange
        case "D": return .red
        case "E": return .purple
        case "F": return .teal
        case "G": return .indigo
        case "H": return .pink
        case "I": return .cyan
        case "J": return .mint
        case "K": return .brown
        case "L": return .gray
        default: return .blue
        }
    }
    
    private func toggleFavorite(_ team: Team) {
        if favoriteTeamID == team.id {
            favoriteTeamID = ""
        } else {
            favoriteTeamID = team.id
        }
    }
}
