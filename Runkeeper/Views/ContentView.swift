import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
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
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Run.self, RunManager.self], inMemory: true)
}
