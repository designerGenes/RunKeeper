import SwiftUI

struct SettingsView: View {
    @AppStorage("useMetricSystem") private var useMetricSystem = true
    @AppStorage("useAIVoice") private var useAIVoice = false
    @AppStorage("allowWidget") private var allowWidget = true
    @AppStorage("themeColorString") private var themeColorString = "blue"
    @State private var showingAboutSheet = false
    @EnvironmentObject private var themeManager: ThemeManager

    private let themeColors = ["blue", "green", "red", "purple", "orange"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preferences")) {
                    Toggle("Use Metric System (km)", isOn: $useMetricSystem)
                    Toggle("Use AI Voice Encouragement", isOn: $useAIVoice)
                    Toggle("Allow Widget on Home Screen", isOn: $allowWidget)
                }

                Section(header: Text("Theme")) {
                    Picker("Choose theme color", selection: $themeColorString) {
                        ForEach(themeColors, id: \.self) { colorString in
                            HStack {
                                Circle()
                                    .fill(Color(colorString))
                                    .frame(width: 20, height: 20)
                                Text(colorString.capitalized)
                            }
                            .tag(colorString)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: themeColorString) { _ in
                        // Trigger UI update
                        themeManager.objectWillChange.send()
                    }
                }

                Section {
                    Button("Upgrade to Premium") {
                        // Implement upgrade logic here
                    }
                    .foregroundColor(.blue)
                }

                Section {
                    Button("About") {
                        showingAboutSheet = true
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingAboutSheet) {
            AboutView()
        }
    }
}

struct AboutView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "figure.run")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)

                Text("Couch to 5K")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Version 1.0")
                    .font(.subheadline)

                Text("Developed by YourCompanyName")
                    .font(.headline)

                Text("This app helps you go from couch potato to 5K runner in just 7 weeks!")
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
    SettingsView()
        .environmentObject(ThemeManager())
}
