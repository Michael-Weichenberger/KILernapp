//
//  lernAppFinal1_1App.swift
//  lernAppFinal1.1
//
//  Created by Kasi  on 04.09.25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct LernApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(authViewModel)
        }
    }
}

struct MainTabView: View {
    @StateObject private var cardsViewModel = CardsViewModel()
    @StateObject private var recordingViewModel: RecordingViewModel
    @StateObject private var documentScanViewModel = DocumentScanViewModel()

    init() {
        let cardsVM = CardsViewModel()
        _cardsViewModel = StateObject(wrappedValue: cardsVM)
        _recordingViewModel = StateObject(wrappedValue: RecordingViewModel(cardsViewModel: cardsVM))
        _documentScanViewModel = StateObject(wrappedValue: DocumentScanViewModel())
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            RecordingView()
                .tabItem {
                    Label("Record", systemImage: "mic.fill")
                }
            DocumentScanView(viewModel: documentScanViewModel)
                .tabItem {
                    Label("Scan", systemImage: "doc.text.viewfinder")
                }
            SummaryView(inputText: "")
                .tabItem {
                    Label("Summary", systemImage: "text.book.closed.fill")
                }
            CardsView(viewModel: cardsViewModel, recordingVM: recordingViewModel)
                .tabItem {
                    Label("Cards", systemImage: "square.stack.3d.up.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}
