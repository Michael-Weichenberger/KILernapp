
import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)

            Form {
                Section(header: Text("Profile")) {
                    HStack {
                        Text("Name:")
                        Spacer()
                        Text(viewModel.userName)
                    }
                    HStack {
                        Text("Email:")
                        Spacer()
                        Text(viewModel.userEmail)
                    }
                }

                Section(header: Text("API Keys")) {
                    TextField("OpenAI API Key", text: $viewModel.openAIApiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    Button("Save API Key") {
                        viewModel.saveOpenAIApiKey()
                    }
                }

                Section {
                    Button("Logout") {
                        authViewModel.logout()
                    }
                    .foregroundColor(.red)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }

            Spacer()
        }
        .onAppear(perform: viewModel.loadUserSettings)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(AuthViewModel())
        }
    }
}


