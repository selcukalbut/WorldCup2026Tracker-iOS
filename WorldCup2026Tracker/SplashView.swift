import SwiftUI

struct SplashView: View {
    @State private var showMainView = false
    @State private var scale = 0.85
    @State private var opacity = 0.0
    @AppStorage("selectedTournament") private var selectedTournament: String = ""

    var body: some View {
        if showMainView {
            if selectedTournament == "football2026" {
                MainTabView()
            } else {
                TournamentSelectionView()
            }
        } else {
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

                VStack(spacing: 22) {
                    ZStack {
                        Circle()
                            .fill(.cyan.opacity(0.18))
                            .frame(width: 260, height: 260)
                            .blur(radius: 60)

                        Image(systemName: "globe.europe.africa.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .foregroundStyle(.cyan.opacity(0.85))
                            .shadow(color: .cyan.opacity(0.35), radius: 25)
                    }

                    VStack(spacing: 4) {
                        Text("GLOBAL SPORTS")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .tracking(2)
                            .foregroundStyle(.white)

                        Text("TRACKER")
                            .font(.title2)
                            .fontWeight(.bold)
                            .tracking(8)
                            .foregroundStyle(.yellow)
                    }

                    Text("Track the Road to Glory.")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.78))
                }
                .scaleEffect(scale)
                .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    scale = 1.0
                    opacity = 1.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showMainView = true
                    }
                }
            }
        }
    }
}
