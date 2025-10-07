
import SwiftUI

struct RecordingView: View {
    @StateObject var viewModel = RecordingViewModel()

    var body: some View {
        VStack {
            Text("Audio Recording")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)

            Text(String(format: "%.0f seconds", viewModel.recordingTime))
                .font(.title)
                .padding()

            // Placeholder for waveform animation
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(height: 100)
                .cornerRadius(10)
                .padding(.horizontal)

            HStack {
                Button(action: {
                    if viewModel.isRecording {
                        viewModel.stopRecording()
                    } else {
                        viewModel.startRecording()
                    }
                }) {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "record.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(viewModel.isRecording ? .red : .green)
                }
            }
            .padding(.top, 30)

            if !viewModel.transcription.isEmpty {
                Text("Transcription:")
                    .font(.headline)
                    .padding(.top, 20)
                ScrollView {
                    Text(viewModel.transcription)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .frame(maxHeight: 200)
                .padding(.horizontal)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }

            Spacer()
        }
        .navigationTitle("Record Audio")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecordingView()
        }
    }
}


