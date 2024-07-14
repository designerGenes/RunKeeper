import SwiftUI

struct SettingsView: View {
    @AppStorage("useAIVoice") private var useAIVoice = false
    @AppStorage("allowWidget") private var allowWidget = true
    @AppStorage("themeColorString") private var themeColorString = "blue"
    #if DEBUG
    @AppStorage("debugModeEnabled") private var debugModeEnabled = false
    #endif
    @State private var showingAboutSheet = false
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var showSettings: Bool

    private let themeColors: [String: Color] = [
        "red": .red,
        "green": .green,
        "blue": .blue,
        "orange": .orange,
        "purple": .purple
    ]

    var body: some View {
        VStack {
            HStack {
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            
            Form {
                Section(header: Text("Preferences")) {
                    Toggle("Use AI Voice (coming soon!)", isOn: $useAIVoice)
                        .disabled(true)
                    Toggle("Allow Widget on Home Screen", isOn: $allowWidget)
                }

                Section {
                    themeSelector
                }

                #if DEBUG
                Section(header: Text("Debug Options")) {
                    Toggle("DEBUG MODE", isOn: $debugModeEnabled)
                }
                #endif

                Section {
                    Button("About") {
                        showingAboutSheet = true
                    }
                }
            }
        }
        .background(themeManager.backgroundGradient.ignoresSafeArea())
        .sheet(isPresented: $showingAboutSheet) {
            AboutView()
        }
    }

    private var themeSelector: some View {
        HStack {
            Text("Theme")
            Spacer()
            ForEach(Array(themeColors.keys.sorted()), id: \.self) { colorName in
                themeCircle(for: colorName)
            }
        }
    }

    private func themeCircle(for colorName: String) -> some View {
        Circle()
            .fill(themeColors[colorName] ?? .gray)
            .frame(width: 30, height: 30)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: themeColorString == colorName ? 2 : 0)
            )
            .onTapGesture {
                themeColorString = colorName
                themeManager.objectWillChange.send()
            }
    }
}

struct AboutView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "figure.run")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(themeManager.themeColor.lighten(by: 0.4))

                Text("Lace - a Zilch to 5K app")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Version 1.0")
                    .font(.subheadline)

                Text("Developed by DesignerGenes (Jaden Nation)")
                    .font(.headline)

                Text("This app helps you go from couch potato to 5K runner in weeks! More features will arrive over time, so please be patient. I made this app because charging users a monthly fee for a running app is exploitative and greedy. We should all be able to get healthier together and not pay a subscription for it. Thanks for using my app and please leave a review if you like it!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView(showSettings: .constant(true))
        .environmentObject(ThemeManager())
}
