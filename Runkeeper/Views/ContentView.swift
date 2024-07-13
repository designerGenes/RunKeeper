import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                SelectRunView(viewModel: RunManagerViewModel(modelContext: modelContext))
            }
            .tabItem {
                Label("Runs", systemImage: "list.bullet")
            }
            .tag(0)
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(1)
        }
        .environmentObject(themeManager)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [RunRecord.self, RunManager.self], inMemory: true)
}
