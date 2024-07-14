import SwiftUI
import SwiftData

@main
struct LaceApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([RunRecord.self, RunManager.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            for fontFamilyName in UIFont.familyNames{
                for fontName in UIFont.fontNames(forFamilyName: fontFamilyName){
                    print("Family: \(fontFamilyName)     Font: \(fontName)")
                }
            }
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
