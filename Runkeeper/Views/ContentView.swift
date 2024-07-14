import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: RunManagerViewModel
    @StateObject private var themeManager = ThemeManager()
    @State private var showSettings = false
    
    init(modelContext: ModelContext) {
        let viewModel = RunManagerViewModel(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                SelectRunView(viewModel: viewModel, showSettings: $showSettings)
                    .environmentObject(themeManager)
                    .offset(x: showSettings ? -UIScreen.main.bounds.width * 0.8 : 0)
                
                SettingsView(showSettings: $showSettings)
                    .environmentObject(themeManager)
                    .offset(x: showSettings ? 0 : UIScreen.main.bounds.width)
            }
            .animation(.spring(), value: showSettings)
        }
        .environmentObject(themeManager)
    }
}
