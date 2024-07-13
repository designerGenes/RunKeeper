import SwiftUI
import SwiftData

@main
struct RunkeeperApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SelectRunView(viewModel: RunManagerViewModel(modelContext: ModelContext(try! ModelContainer(for: Run.self, RunManager.self))))
            }
        }
    }
}
