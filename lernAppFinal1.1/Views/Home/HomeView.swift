
import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(viewModel.welcomeMessage)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                Button("Neue Sitzung starten") {
                    // Action for starting new session
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("Gespeicherte Sitzungen ansehen") {
                    // Action for viewing saved sessions
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("Karteikarten lernen") {
                    // Action for learning flashcards
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("Einstellungen") {
                    // Action for settings
                }
                .buttonStyle(PrimaryButtonStyle())

                Spacer()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}


