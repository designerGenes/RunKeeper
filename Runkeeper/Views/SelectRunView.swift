import SwiftUI
import SwiftData

struct SelectRunView: View {
    @ObservedObject var viewModel: RunManagerViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var scrollProxy: ScrollViewProxy?
    @State private var nextRunId: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                themeManager.backgroundGradient
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    encouragingMessage
                    
                    Spacer()
                    
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 15) {
                                ForEach(viewModel.runManager.runRecords.sorted { ($0.week * 10 + $0.day) < ($1.week * 10 + $1.day) }) { runRecord in
                                    NavigationLink(destination: RunView(viewModel: viewModel, runRecord: runRecord)) {
                                        RunSquare(runRecord: runRecord, isNextUp: isNextUp(runRecord))
                                    }
                                    .id("\(runRecord.week)-\(runRecord.day)")
                                    .overlay(
                                        Group {
                                            if isNextUp(runRecord) {
                                                Image(systemName: "arrow.down.circle.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 24))
                                                    .offset(y: -64)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 40) // Add some top padding for the arrow
                        }
                        .frame(height: geometry.size.height * 0.3) // Increased height to accommodate the arrow
                        .padding(.bottom, geometry.size.height * 0.05)
                        .onAppear {
                            scrollProxy = proxy
                            scrollToNextRun()
                        }
                    }
                }
            }
        }
        .navigationTitle("Select a Run")
        .onAppear {
            print("SelectRunView appeared with \(viewModel.runManager.runRecords.count) run records")
            scrollToNextRun()
        }
    }
    
    private var encouragingMessage: some View {
        Text(getEncouragingMessage())
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding()
            .foregroundColor(.white)
    }
    
    private func getEncouragingMessage() -> String {
        if let nextRun = viewModel.getNextRun() {
            return "Next up: Week \(nextRun.week), Day \(nextRun.day)\nYou've got this!"
        } else {
            return "Great job! You've completed all runs.\nFeel free to repeat any run."
        }
    }
    
    private func scrollToNextRun() {
        if let nextRun = viewModel.getNextRun() {
            nextRunId = "\(nextRun.week)-\(nextRun.day)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    scrollProxy?.scrollTo(nextRunId, anchor: .center)
                }
            }
        }
    }
    
    private func isNextUp(_ runRecord: RunRecord) -> Bool {
        viewModel.getNextRun()?.id == runRecord.id
    }
}

struct RunSquare: View {
    let runRecord: RunRecord
    let isNextUp: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack {
            Text("Week \(runRecord.week)")
                .font(.headline)
            Text("Day \(runRecord.day)")
                .font(.subheadline)
            
            if runRecord.completedDate != nil {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .frame(width: 80, height: 80)
        .background(backgroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isNextUp ? Color.white : Color.clear, lineWidth: 3)
        )
        .foregroundColor(.white)
    }
    
    private var backgroundColor: Color {
        if runRecord.completedDate != nil {
            return Color.green.opacity(0.3)
        } else if isNextUp {
            return themeManager.themeColor.opacity(0.5)
        } else {
            return themeManager.themeColor.opacity(0.2)
        }
    }
}

#Preview {
    SelectRunView(viewModel: RunManagerViewModel(modelContext: ModelContext(try! ModelContainer(for: RunRecord.self, RunManager.self))))
        .environmentObject(ThemeManager())
}
