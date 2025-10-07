# LernApp - SwiftUI MVVM Lern-App

Dieses Projekt ist eine umfassende iOS-Lernanwendung, die mit SwiftUI erstellt wurde und dem MVVM-Architekturmuster (Model-View-ViewModel) folgt. Es integriert Firebase für Authentifizierung, Datenspeicherung und Dateispeicherung.

## 📱 Screenshots

<p align="center">
  <img src="Screens KI Lernapp/Welcomescreen.png" width="150"> 
  <img src="Screens KI Lernapp/Homescreen.png" width="150"> 
  <img src="Screens KI Lernapp/Recordscreen.png" width="150"> 
  <img src="Screens KI Lernapp/Scanscreen.png" width="150"> 
  <img src="Screens KI Lernapp/Cardscreen.png" width="150">
</p>

## ✨ Funktionen

-   **Onboarding & Authentifizierung:** Startbildschirm, Registrierung und Anmeldung mit Firebase Authentication.
-   **Home-Dashboard:** Zentrale Übersicht mit Navigation zu allen App-Bereichen.
-   **Audioaufnahme & Transkription:** Aufnahme von Audio, das zur Textumwandlung an einen Backend-Dienst gesendet wird.
-   **Dokumentenscan:** Scannen von Dokumenten und Texterkennung mittels OCR.
-   **Zusammenfassungen & Q&A:** Anzeige von KI-generierten Zusammenfassungen und Fragen zum gelernten Stoff.
-   **Karteikarten (Spaced Repetition):** Digitales Lernkartensystem, das den SM-2-Algorithmus zur Optimierung des Lernfortschritts nutzt.
-   **Einstellungen:** Verwaltung des Benutzerprofils und der API-Schlüssel.

## 🛠️ Technische Spezifikationen

-   **Sprache:** Swift
-   **UI-Framework:** SwiftUI
-   **Architektur:** MVVM (Model-View-ViewModel)
-   **Backend:** Firebase (Authentication, Firestore, Storage)
-   **Projektstruktur:** Klar getrennt in `Views`, `ViewModels`, `Services`, `Models`, etc.
-   **UI:** Saubere, minimalistische Benutzeroberfläche mit `NavigationStack` und `TabView`.

## 🚀 Einrichtung und Installation

1.  **Xcode-Projekt erstellen:** Erstelle ein neues SwiftUI-Projekt in Xcode.
2.  **Projektdateien kopieren:** Kopiere die Verzeichnisse (`App`, `Models`, `ViewModels`, `Views`, `Services` etc.) in dein neues Xcode-Projekt.
3.  **Firebase-Integration:** Richte ein Firebase-Projekt ein, registriere die App, füge die `GoogleService-Info.plist` hinzu und installiere die notwendigen SDKs.
4.  **Erstellen und Ausführen:** Sobald Firebase konfiguriert ist, baue und starte das Projekt.

## 🔮 Zukünftige Verbesserungen

-   [ ] Implementierung tatsächlicher API-Aufrufe für Whisper/OpenAI.
-   [ ] Integration von VisionKit für Echtzeit-Dokumentenscans.
-   [ ] Verbesserung der Benutzeroberfläche und User Experience.
-   [ ] Hinzufügen einer robusten Fehlerbehandlung.
-   [ ] Implementierung von Keychain für die sichere Speicherung von API-Schlüsseln.

## 👤 Autor

-   **Michael Weichenberger** - [GitHub-Profil](https://github.com/Michael-Weichenberger)

---
*Dieses Projekt ist als Eigenprojekt entstanden und dient als Portfolio-Stück.*
