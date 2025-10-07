
import SwiftUI

struct SummaryView: View {
    @StateObject var viewModel = SummaryViewModel()
    @State private var inputText: String = "" // For testing purposes

    var body: some View {
        VStack {
            Text("Summaries & Q&A")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)

            TextField("Enter text to summarize", text: $inputText, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(5)
                .padding(.horizontal)
                .padding(.bottom, 10)

            Button("Generate Summary & Questions") {
                viewModel.generateSummariesAndQuestions(text: inputText)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if !viewModel.shortSummary.isEmpty {
                        Text("Short Summary:")
                            .font(.headline)
                        Text(viewModel.shortSummary)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }

                    if !viewModel.longSummary.isEmpty {
                        Text("Long Summary:")
                            .font(.headline)
                        Text(viewModel.longSummary)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }

                    if !viewModel.generatedQuestions.isEmpty {
                        Text("Generated Questions:")
                            .font(.headline)
                        ForEach(viewModel.generatedQuestions, id: \.self) {
                            question in
                            VStack(alignment: .leading) {
                                Text(question)
                                    .padding(.bottom, 2)
                                TextField("Your answer", text: .constant("")) // Placeholder for answer field
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding(.vertical, 5)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }

            Spacer()
        }
        .navigationTitle("Summaries")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SummaryView()
        }
    }
}


