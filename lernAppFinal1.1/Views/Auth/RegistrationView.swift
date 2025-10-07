import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
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

            VStack(spacing: 25) {
                Text("Register")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                TextField("Email", text: $authViewModel.email)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal)

                SecureField("Password", text: $authViewModel.password)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }

                Button(action: {
                    authViewModel.register()
                }) {
                    Text("Register")
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
                .padding(.top, 10)

                Spacer()
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        RegistrationView()
            .environmentObject(AuthViewModel())
    }
}
