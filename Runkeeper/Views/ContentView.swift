import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var runManagers: [RunManager]
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            if let runManager = runManagers.first {
                SelectRunView(runManager: runManager)
                    .tabItem {
                        Label("Runs", systemImage: "list.bullet")
                    }
                    .tag(0)
            } else {
                ProgressView("Loading...")
                    .tabItem {
                        Label("Runs", systemImage: "list.bullet")
                    }
                    .tag(0)
            }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
        .onAppear(perform: initializeRunManager)
    }
    
    private func initializeRunManager() {
        if runManagers.isEmpty {
            let newManager = RunManager()
            modelContext.insert(newManager)
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Run.self, RunManager.self], inMemory: true)
}
