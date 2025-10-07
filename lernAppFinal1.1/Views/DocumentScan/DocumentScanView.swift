
import SwiftUI

struct DocumentScanView: View {
    @StateObject var viewModel = DocumentScanViewModel()
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? // Placeholder for scanned image

    var body: some View {
        VStack {
            Text("Document Scan")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)

            Button("Scan Document (Placeholder)") {
                // In a real app, this would integrate with VisionKit
                // For now, we'll simulate an image scan
                showingImagePicker = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)

            if let image = inputImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .padding()
            }

            if !viewModel.scannedText.isEmpty {
                Text("Scanned Text:")
                    .font(.headline)
                    .padding(.top, 20)
                ScrollView {
                    Text(viewModel.scannedText)
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
        .navigationTitle("Scan Document")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingImagePicker) {
            // This is a placeholder. In a real app, you'd use ImagePicker or DocumentCameraViewController
            Text("Imagine a document scanner here. Tap to simulate scan.")
                .onTapGesture {
                    // Simulate a scanned image and process it
                    if let dummyImageData = UIImage(systemName: "doc.text.viewfinder")?.pngData() {
                        viewModel.processScannedImage(imageData: dummyImageData)
                        inputImage = UIImage(systemName: "doc.text.viewfinder")
                    }
                    showingImagePicker = false
                }
        }
    }
}

struct DocumentScanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DocumentScanView()
        }
    }
}


