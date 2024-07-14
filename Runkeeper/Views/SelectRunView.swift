import SwiftUI
import SwiftData

struct SelectRunView: View {
    @ObservedObject var viewModel: RunManagerViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var showSettings: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                HStack {
                    Text("Select a Run")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gear")
                            .font(.title)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Circle().fill(Color.secondary.opacity(0.2)))
                    }
                }
                .padding(.horizontal)
                
                Image("mountains")
                    .resizable()
                    .scaledToFit()
                    .frame(height: geometry.size.height * 0.25)
                    .clipped()
                
                Text("Next Up: Week \(viewModel.getNextRun()?.week ?? 1), Day \(viewModel.getNextRun()?.day ?? 1)")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.runManager.runRecords.sorted { ($0.week * 10 + $0.day) < ($1.week * 10 + $1.day) }) { runRecord in
                            NavigationLink(destination: RunView(viewModel: viewModel, runRecord: runRecord).environmentObject(themeManager)) {
                                VStack {
                                    Circle()
                                        .fill(runRecord.completedDate != nil ? Color.black : Color.clear)
                                        .frame(width: 40, height: 40)
                                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                                    Text("Day \(runRecord.day)")
                                        .font(.caption)
                                    Text("Week \(runRecord.week)")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 100)
                
                Spacer()
                
                NavigationLink(destination: RunView(viewModel: viewModel, runRecord: viewModel.getNextRun() ?? viewModel.runManager.runRecords.first!).environmentObject(themeManager)) {
                    Text("Run")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Capsule().fill(Color.black))
                }
                .padding(.horizontal)
            }
            .background(themeManager.backgroundGradient.ignoresSafeArea())
        }
    }
}
