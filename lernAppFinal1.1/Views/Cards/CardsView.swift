
import SwiftUI

struct CardsView: View {
    @StateObject var viewModel = CardsViewModel()
    @State private var newCardFront: String = ""
    @State private var newCardBack: String = ""

    var body: some View {
        VStack {
            Text("Flashcards")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            if let card = viewModel.currentCard {
                VStack {
                    Text(viewModel.showBack ? card.back : card.front)
                        .font(.title2)
                        .padding(50)
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(15)
                        .onTapGesture {
                            viewModel.flipCard()
                        }

                    if viewModel.showBack {
                        HStack {
                            ForEach(0..<6) { difficulty in
                                Button("\(difficulty)") {
                                    viewModel.recordReview(difficulty: difficulty)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(.horizontal)
            } else {
                Text("No cards to review. Add some!")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()
            }

            Spacer()

            VStack {
                TextField("New Card Front", text: $newCardFront)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("New Card Back", text: $newCardBack)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add New Card") {
                    viewModel.addCard(front: newCardFront, back: newCardBack)
                    newCardFront = ""
                    newCardBack = ""
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
        }
        .onAppear(perform: viewModel.loadCards)
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardsView()
        }
    }
}


