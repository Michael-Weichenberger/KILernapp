import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Dunkler Hintergrund
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

                VStack(spacing: 25) {
                    Spacer()

                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .purple.opacity(0.6), radius: 20, x: 0, y: 8)

                    Text("Welcome to LernApp")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)

                    Text("Your ultimate learning companion.")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    Spacer()

                    // Get Started Button
                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white.opacity(0.7))

                        NavigationLink {
                            RegistrationView()
                        } label: {
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthViewModel())
}
