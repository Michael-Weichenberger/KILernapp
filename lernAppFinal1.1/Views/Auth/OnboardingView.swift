
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "book.closed.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.accentColor)
                Text("Welcome to LernApp!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                Text("Your ultimate learning companion.")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                Spacer()

                NavigationLink {
                    LoginView()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                HStack {
                    Text("Don't have an account?")
                    NavigationLink {
                        RegistrationView()
                    } label: {
                        Text("Sign Up")
                            .fontWeight(.bold)
                    }
                }
                .padding(.bottom, 50)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AuthViewModel())
    }
}


