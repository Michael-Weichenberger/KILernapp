import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 30) {
                    Text("Settings")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    // MARK: - Profile Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Profile")
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack {
                            Text("Name:")
                                .foregroundColor(.gray)
                            Spacer()
                            TextField("Name", text: $viewModel.userName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.white)
                        }

                        HStack {
                            Text("Email:")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(viewModel.userEmail)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // MARK: - API Key Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("API Keys")
                            .font(.headline)
                            .foregroundColor(.white)

                        TextField("OpenAI API Key", text: $viewModel.openAIApiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .foregroundColor(.white)

                        Button("Save Settings") {
                            viewModel.saveSettings()
                        }
                        .buttonStyle(PrimaryButtonStyle(color: Color.green))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // MARK: - Logout Section
                    VStack {
                        Button("Logout") {
                            authViewModel.logout()
                        }
                        .buttonStyle(PrimaryButtonStyle(color: .red))
                    }
                    .padding(.horizontal)

                    // MARK: - Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.loadUserSettings()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .environmentObject(AuthViewModel())
        }
        .preferredColorScheme(.dark)
    }
}
