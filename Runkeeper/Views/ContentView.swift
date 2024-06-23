import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var runManagers: [RunManager]
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SelectRunView(runManager: runManagers.first ?? RunManager())
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
        .onAppear {
            if runManagers.isEmpty {
                let newManager = RunManager()
                modelContext.insert(newManager)
            }
        }
    }
}
