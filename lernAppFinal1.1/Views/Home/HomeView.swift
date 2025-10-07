import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    @StateObject private var cardsViewModel = CardsViewModel()
    @StateObject private var recordingViewModel: RecordingViewModel

    init(viewModel: HomeViewModel = HomeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        let cardsVM = CardsViewModel()
        _cardsViewModel = StateObject(wrappedValue: cardsVM)
        _recordingViewModel = StateObject(wrappedValue: RecordingViewModel(cardsViewModel: cardsVM))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Glow-Kreise
                Circle()
                    .fill(Color.purple.opacity(0.25))
                    .frame(width: 280, height: 280)
                    .blur(radius: 80)
                    .offset(x: -150, y: -200)

                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .offset(x: 150, y: 250)

                ScrollView {
                    VStack(spacing: 25) {
                        // Header mit Avatar + Logout
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white.opacity(0.9))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Willkommen zurück,")
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.subheadline)

                                Text(authViewModel.email.isEmpty ? "Gast" : authViewModel.email)
                                    .foregroundColor(.white)
                                    .font(.headline.bold())
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }

                            Spacer()

                            Button(action: {
                                authViewModel.logout()
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.red.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Logout")
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        Spacer().frame(height: 20)

                        // Begrüßung / Titel
                        Text(viewModel.welcomeMessage)
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 30)

                        // Dashboard
                        VStack(spacing: 15) {
                            NavigationLink(destination: CardsView(viewModel: cardsViewModel, recordingVM: recordingViewModel)) {
                                DashboardCard(
                                    title: "Bevorstehende Karten",
                                    count: cardsViewModel.upcomingCount,
                                    gradient: [Color.orange, Color.pink],
                                )
                            }

                            NavigationLink(destination: SummaryView(inputText: "")) {
                                DashboardCard(
                                    title: "Letzte Sitzungen",
                                    count: viewModel.recentSessions.count,
                                    gradient: [Color.blue, Color.green],
                                )
                            }

                            NavigationLink(destination: RecordingView()) {
                                DashboardCard(
                                    title: "Neue Sitzung starten",
                                    count: 0,
                                    gradient: [Color.purple, Color.blue],
                                )
                            }
                        }

                        // ------------------------
                        // NEU: KI-Karten Vorschau
                        // ------------------------
                        if !cardsViewModel.generatedCardsForPreview.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Neue KI-Karten")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.top, 20)

                                ForEach(cardsViewModel.generatedCardsForPreview.prefix(3)) { card in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Front: \(card.front)")
                                            .foregroundColor(.white.opacity(0.9))
                                            .font(.subheadline.bold())
                                        Text("Back: \(card.back)")
                                            .foregroundColor(.white.opacity(0.8))
                                            .font(.subheadline)
                                    }
                                    .padding(8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                }

                                NavigationLink(destination: CardsView(viewModel: cardsViewModel, recordingVM: recordingViewModel)) {
                                    Text("Alle ansehen & bearbeiten")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.blue)
                                        .padding(.top, 5)
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                cardsViewModel.loadCards()
            }
        }
    }
}

// MARK: - DashboardCard
struct DashboardCard: View {
    let title: String
    let count: Int
    let gradient: [Color]
    let inputText: String? = nil // <-- Match the new initializer!

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                if count > 0 {
                    Text("\(count)")
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing)
        )
        .cornerRadius(15)
        .shadow(color: gradient.first?.opacity(0.4) ?? .black.opacity(0.4),
                radius: 10, x: 0, y: 5)
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let authVM = AuthViewModel()
        authVM.email = "michael@example.com"

        let homeVM = HomeViewModel()
        homeVM.upcomingCards = [
            Card(id: "1", userId: "1", front: "Front", back: "Back", easeFactor: 2.5, repetitions: 1, nextReviewDate: Date(), lastReviewDate: Date())
        ]
        homeVM.recentSessions = [
            Session(userId: "1", timestamp: Date())
        ]

        return HomeView(viewModel: homeVM)
            .environmentObject(authVM)
    }
}

