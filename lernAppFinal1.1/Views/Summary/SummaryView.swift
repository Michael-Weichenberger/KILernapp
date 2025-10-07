import SwiftUI

struct SummaryView: View {
    @StateObject var viewModel = SummaryViewModel()
    @State var inputText: String   // <- neu, Text wird von DocumentScanView übergeben

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    Text("Summaries & Q&A")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    // Text Editor mit vorgefülltem OCR Text
                    VStack(alignment: .leading) {
                        Text("Text für die KI:")
                            .foregroundColor(.gray)
                        TextEditor(text: $inputText)
                            .frame(minHeight: 120)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)

                    // Generate Button
                    Button("Generate Summary & Questions") {
                        viewModel.generateSummariesAndQuestions(text: inputText)
                    }
                    .buttonStyle(PrimaryButtonStyle(color: .purple))
                    .padding(.horizontal)

                    // Ergebnisse anzeigen
                    VStack(alignment: .leading, spacing: 20) {
                        if !viewModel.shortSummary.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Short Summary:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(viewModel.shortSummary)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }
                        }

                        if !viewModel.longSummary.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Long Summary:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(viewModel.longSummary)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }
                        }

                        if !viewModel.generatedQuestions.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Generated Questions:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                ForEach(viewModel.generatedQuestions, id: \.self) { question in
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(question)
                                            .foregroundColor(.white)
                                        TextField("Your answer", text: .constant(""))
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationTitle("Summaries")
        .navigationBarTitleDisplayMode(.inline)
    }
}
struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SummaryView(inputText: "Dies ist ein Beispieltext für die Vorschau.")
        }
        .preferredColorScheme(.dark)
    }
}
