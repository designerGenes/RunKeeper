import SwiftUI
import SwiftData

@main
struct RunkeeperApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([RunRecord.self, RunManager.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: container.mainContext)
        }
        .modelContainer(container)
    }
}
