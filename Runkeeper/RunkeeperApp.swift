import SwiftUI
import SwiftData

@main
struct RunkeeperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Run.self, RunManager.self, Segment.self])
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Run.self, RunManager.self, Segment.self], inMemory: true)
}
