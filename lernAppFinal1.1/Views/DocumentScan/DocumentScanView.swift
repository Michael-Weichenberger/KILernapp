import SwiftUI
import Vision
import VisionKit
import PhotosUI

struct DocumentScanView: View {
    @StateObject var viewModel: DocumentScanViewModel
    @State private var showingScanner = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotos: [UIImage] = []

    let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund wie HomeView
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Text("Dokumente scannen / importieren")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        // Scanner & Foto Import Buttons
                        LazyVGrid(columns: gridColumns, spacing: 15) {
                            Button(action: { showingScanner = true }) {
                                DashboardCard(
                                    title: "Scanner",
                                    count: 0,
                                    gradient: [Color.orange, Color.pink]
                                )
                            }

                            Button(action: { showingPhotoPicker = true }) {
                                DashboardCard(
                                    title: "Foto importieren",
                                    count: 0,
                                    gradient: [Color.blue, Color.green]
                                )
                            }
                        }
                        .padding(.horizontal)

                        // Gespeicherte Seiten anzeigen
                        if !viewModel.pages.isEmpty {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Gesammelte Seiten")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                ForEach(viewModel.pages) { page in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Image(uiImage: page.image)
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(12)
                                            .shadow(radius: 4)

                                        Text(page.text)
                                            .padding()
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(10)
                                            .foregroundColor(.white)
                                    }
                                }

                                // Weiter-Button zur SummaryView
                                NavigationLink(
                                    destination: SummaryView(inputText: viewModel.combinedText())
                                ) {
                                    Text("Weiter zur Zusammenfassung")
                                        .font(.headline)
                                }
                                .buttonStyle(PrimaryButtonStyle(color: .purple))
                                .padding(.top, 20)
                            }
                            .padding(.horizontal)
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }

                        Spacer()
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                DocumentCameraWrapper { images in
                    if let first = images.first {
                        viewModel.processImage(first)
                    }
                    showingScanner = false
                }
            }
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPickerWrapper(selectedImages: $selectedPhotos) { images in
                    if let first = images.first {
                        viewModel.processImage(first)
                    }
                    showingPhotoPicker = false
                }
            }
            .navigationTitle("Dokumenten-Scanner")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Scanner Wrapper
struct DocumentCameraWrapper: UIViewControllerRepresentable {
    var completion: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentCameraWrapper
        init(_ parent: DocumentCameraWrapper) { self.parent = parent }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var images: [UIImage] = []
            for i in 0..<scan.pageCount { images.append(scan.imageOfPage(at: i)) }
            parent.completion(images)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) { parent.completion([]) }
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) { parent.completion([]) }
    }
}

// MARK: - Photo Picker Wrapper
struct PhotoPickerWrapper: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var completion: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 5

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPickerWrapper
        init(_ parent: PhotoPickerWrapper) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            var images: [UIImage] = []
            let group = DispatchGroup()

            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, _ in
                    defer { group.leave() }
                    if let image = reading as? UIImage { images.append(image) }
                }
            }

            group.notify(queue: .main) {
                self.parent.selectedImages = images
                self.parent.completion(images)
            }
        }
    }
}
// MARK: - Preview
struct DocumentScanView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = DocumentScanViewModel()
        NavigationStack {
            DocumentScanView(viewModel: vm)
        }
    }
}
