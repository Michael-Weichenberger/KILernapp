import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Dunkler Hintergrund mit Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Dezente Glow-Kreise im Hintergrund
            Circle()
                .fill(Color.purple.opacity(0.2))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: -140, y: -180)
            
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 250, height: 250)
                .blur(radius: 70)
                .offset(x: 130, y: 200)
            
            VStack(spacing: 25) {
                Text("Welcome Back 👋")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                // Glas-Container für Inputs
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.white.opacity(0.7))
                        TextField("Email", text: $authViewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .foregroundColor(.white)
                            .placeholder(when: authViewModel.email.isEmpty) {
                                Text("Email").foregroundColor(.white.opacity(0.4))
                            }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.white.opacity(0.7))
                        SecureField("Password", text: $authViewModel.password)
                            .foregroundColor(.white)
                            .placeholder(when: authViewModel.password.isEmpty) {
                                Text("Password").foregroundColor(.white.opacity(0.4))
                            }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.top, 5)
                }
                
                // Login Button
                Button(action: {
                    authViewModel.login()
                }) {
                    Text("Login")
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
            .padding(.top, 100)
        }
        .navigationBarHidden(true)
    }
}

// Helper-Modifier für Placeholder Farbe
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow { placeholder() }
            self
        }
    }
}

#Preview {
    NavigationView {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
