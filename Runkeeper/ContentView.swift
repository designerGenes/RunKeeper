import SwiftUI
import SwiftData

@main
struct RunningApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Run.self)
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SelectRunView()
                .tabItem {
                    Label("Runs", systemImage: "list.bullet")
                }
                .tag(0)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
    }
}

struct SelectRunView: View {
    var body: some View {
        Text("Select Run View")
        // We'll implement this view later
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings View")
        // We'll implement this view later
    }
}
