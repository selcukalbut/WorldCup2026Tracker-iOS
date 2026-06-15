//
//  HostCitiesView.swift
//  GlobalSportsTracker
//
//  Created by Selcuk Albut on 5.06.2026.
//

import SwiftUI

struct HostCitiesView: View {
    let matches: [Match]
    @State private var expandedStadiums: Set<String> = []
    @State private var selectedCountryFilter: String = "All"
    @State private var searchText: String = ""
    
    private let hostCities: [HostCity] = [
        HostCity(countryFlag: "🇲🇽", city: "Mexico City", stadium: "Mexico City Stadium", realStadiumName: "Estadio Azteca", capacity: "83,000", imageName: "mexico_city_stadium", specialEvent: "🎉 Opening Match"),
        HostCity(countryFlag: "🇲🇽", city: "Guadalajara / Zapopan", stadium: "Guadalajara Stadium", realStadiumName: "Estadio Akron", capacity: "48,071", imageName: "guadalajara_stadium"),
        HostCity(countryFlag: "🇲🇽", city: "Monterrey / Guadalupe", stadium: "Monterrey Stadium", realStadiumName: "Estadio BBVA", capacity: "53,500", imageName: "monterrey_stadium"),
        
        HostCity(countryFlag: "🇨🇦", city: "Toronto", stadium: "Toronto Stadium", realStadiumName: "BMO Field", capacity: "45,736", imageName: "toronto_stadium"),
        HostCity(countryFlag: "🇨🇦", city: "Vancouver", stadium: "Vancouver Stadium", realStadiumName: "BC Place", capacity: "54,500", imageName: "vancouver_stadium"),
        
        HostCity(countryFlag: "🇺🇸", city: "Atlanta", stadium: "Atlanta Stadium", realStadiumName: "Mercedes-Benz Stadium", capacity: "75,000", imageName: "atlanta_stadium", specialEvent: "🥇 Semi-Final"),
        HostCity(countryFlag: "🇺🇸", city: "Boston / Foxborough", stadium: "Boston Stadium", realStadiumName: "Gillette Stadium", capacity: "65,878", imageName: "boston_stadium"),
        HostCity(countryFlag: "🇺🇸", city: "Dallas / Arlington", stadium: "Dallas Stadium", realStadiumName: "AT&T Stadium", capacity: "94,000", imageName: "dallas_stadium", specialEvent: "🥇 Semi-Final"),
        HostCity(countryFlag: "🇺🇸", city: "Houston", stadium: "Houston Stadium", realStadiumName: "NRG Stadium", capacity: "72,220", imageName: "houston_stadium"),
        HostCity(countryFlag: "🇺🇸", city: "Kansas City", stadium: "Kansas City Stadium", realStadiumName: "Arrowhead Stadium", capacity: "73,000", imageName: "kansas_city_stadium", specialEvent: "🏅 Quarter-Final"),
        HostCity(countryFlag: "🇺🇸", city: "Los Angeles / Inglewood", stadium: "Los Angeles Stadium", realStadiumName: "SoFi Stadium", capacity: "70,240", imageName: "los_angeles_stadium", specialEvent: "🏅 Quarter-Final"),
        HostCity(countryFlag: "🇺🇸", city: "Miami", stadium: "Miami Stadium", realStadiumName: "Hard Rock Stadium", capacity: "64,767", imageName: "miami_stadium", specialEvent: "🥉 Third Place Match"),
        HostCity(countryFlag: "🇺🇸", city: "New York / New Jersey", stadium: "New York New Jersey Stadium", realStadiumName: "MetLife Stadium", capacity: "82,500", imageName: "new_york_new_jersey_stadium", specialEvent: "🏆 Final"),
        HostCity(countryFlag: "🇺🇸", city: "Philadelphia", stadium: "Philadelphia Stadium", realStadiumName: "Lincoln Financial Field", capacity: "69,796", imageName: "philadelphia_stadium"),
        HostCity(countryFlag: "🇺🇸", city: "San Francisco Bay Area / Santa Clara", stadium: "San Francisco Bay Area Stadium", realStadiumName: "Levi's Stadium", capacity: "68,500", imageName: "san_francisco_bay_area_stadium"),
        HostCity(countryFlag: "🇺🇸", city: "Seattle", stadium: "Seattle Stadium", realStadiumName: "Lumen Field", capacity: "69,000", imageName: "seattle_stadium")
    ]
    
    private var countryFilters: [String] {
        ["All", "🇨🇦 Canada", "🇲🇽 Mexico", "🇺🇸 United States"]
    }
    
    private var filteredHostCities: [HostCity] {
        let countryFiltered: [HostCity]

        switch selectedCountryFilter {
        case "🇨🇦 Canada":
            countryFiltered = hostCities.filter { $0.countryFlag == "🇨🇦" }
        case "🇲🇽 Mexico":
            countryFiltered = hostCities.filter { $0.countryFlag == "🇲🇽" }
        case "🇺🇸 United States":
            countryFiltered = hostCities.filter { $0.countryFlag == "🇺🇸" }
        default:
            countryFiltered = hostCities
        }

        guard !searchText.isEmpty else {
            return countryFiltered
        }

        return countryFiltered.filter {
            $0.city.localizedCaseInsensitiveContains(searchText) ||
            $0.stadium.localizedCaseInsensitiveContains(searchText) ||
            $0.realStadiumName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerView
                summaryCards
                countryFilterPicker
                searchBar
                hostCityGrid
            }
            .padding(32)
        }
        .navigationTitle("Host Cities")
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🏟️ Host Cities & Stadiums")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("This section presents host cities and venues for international sports tournaments.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
    
    private var summaryCards: some View {
        HStack(spacing: 10) {
            infoCard(title: "Country", value: "3", icon: "globe.americas.fill")
                .frame(maxWidth: .infinity)

            infoCard(title: "Cities", value: "16", icon: "building.2.fill")
                .frame(maxWidth: .infinity)

            infoCard(title: "Stadium", value: "16", icon: "sportscourt.fill")
                .frame(maxWidth: .infinity)
        }
    }
    
    private var countryFilterPicker: some View {
        Picker("Country", selection: $selectedCountryFilter) {
            ForEach(countryFilters, id: \.self) { filter in
                Text(filter).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var searchBar: some View {
        TextField("Search city or stadium...", text: $searchText)
            .textFieldStyle(.roundedBorder)
    }
    
    private func infoCard(title: String, value: String, icon: String) -> some View {
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
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
    
    private func stadiumImage(for hostCity: HostCity) -> some View {
        ZStack {
            Image(hostCity.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.45), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            
            VStack {
                Spacer()
                HStack {
                    Text(hostCity.stadium)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .shadow(radius: 3)
                    
                    Spacer()
                }
                .padding(12)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private var hostCityGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
            ForEach(filteredHostCities) { hostCity in
                hostCityCard(hostCity)
            }
        }
    }
    
    private func hostCityCard(_ hostCity: HostCity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            stadiumImage(for: hostCity)
            HStack(alignment: .top) {
                Text(hostCity.countryFlag)
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(hostCity.city)
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    
                    Text(hostCity.stadium)
                        .font(.headline)
                }
                
                Spacer()
            }
            
            if let specialEvent = hostCity.specialEvent {
                Text(specialEvent)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(badgeColor(for: specialEvent))
                    .clipShape(Capsule())
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                Label(hostCity.realStadiumName, systemImage: "mappin.and.ellipse")
                Label("Capasity: \(hostCity.capacity)", systemImage: "person.3.fill")
                Label("Matches: \(matchCount(for: hostCity))", systemImage: "calendar")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            
            if matchCount(for: hostCity) > 0 {
                Button {
                    toggleExpanded(hostCity)
                } label: {
                    Label(
                        isExpanded(hostCity) ? "Hide Matches" : "Show Matches",
                        systemImage: isExpanded(hostCity) ? "chevron.up.circle" : "chevron.down.circle"
                    )
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
                
                if isExpanded(hostCity) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(matchesForHostCity(hostCity)) { match in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(match.homeTeam.flag) \(match.homeTeam.name) vs \(match.awayTeam.flag) \(match.awayTeam.name)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                                
                                Text(match.date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                            
                            if match.id != matchesForHostCity(hostCity).last?.id {
                                Divider()
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
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
    
    private func badgeColor(for event: String) -> Color {
        if event.contains("Final") {
            return .yellow
        } else if event.contains("Openning") {
            return .blue
        } else if event.contains("Semi-Final") {
            return .purple
        } else if event.contains("Quarter-Final") {
            return .green
        } else if event.contains("Third Place") {
            return .orange
        } else {
            return .gray
        }
    }

    private func isExpanded(_ hostCity: HostCity) -> Bool {
        expandedStadiums.contains(hostCity.stadium)
    }
    
    private func toggleExpanded(_ hostCity: HostCity) {
        if expandedStadiums.contains(hostCity.stadium) {
            expandedStadiums.remove(hostCity.stadium)
        } else {
            expandedStadiums.insert(hostCity.stadium)
        }
    }
    
    private func matchesForHostCity(_ hostCity: HostCity) -> [Match] {
        matches.filter {
            $0.venue == hostCity.stadium || $0.venue.contains(hostCity.stadium)
        }
    }
    
    private func matchCount(for hostCity: HostCity) -> Int {
        matchesForHostCity(hostCity).count
    }
}

struct HostCity: Identifiable {
    let id = UUID()
    let countryFlag: String
    let city: String
    let stadium: String
    let realStadiumName: String
    let capacity: String
    let imageName: String
    let specialEvent: String?
    
    init(
        countryFlag: String,
        city: String,
        stadium: String,
        realStadiumName: String,
        capacity: String,
        imageName: String = "stadium_placeholder",
        specialEvent: String? = nil
    ) {
        self.countryFlag = countryFlag
        self.city = city
        self.stadium = stadium
        self.realStadiumName = realStadiumName
        self.capacity = capacity
        self.imageName = imageName
        self.specialEvent = specialEvent
    }
}
