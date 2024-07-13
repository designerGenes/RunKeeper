import SwiftUI
import SwiftData

struct SelectRunView: View {
    @ObservedObject var viewModel: RunManagerViewModel
    @State private var scrollProxy: ScrollViewProxy?
    @State private var nextRunId: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                encouragingMessage
                
                Spacer()
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 15) {
                            ForEach(viewModel.runManager.runs.sorted { ($0.week * 10 + $0.runNumber) < ($1.week * 10 + $1.runNumber) }) { run in
                                NavigationLink(destination: RunView(viewModel: viewModel, run: run)) {
                                    RunSquare(run: run)
                                }
                                .id("\(run.week)-\(run.runNumber)")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: geometry.size.height * 0.2)
                    .padding(.bottom, geometry.size.height * 0.05)
                    .onAppear {
                        scrollProxy = proxy
                        scrollToNextRun()
                    }
                }
            }
        }
        .background(backgroundGradient)
        .navigationTitle("Select a Run")
        .onAppear(perform: scrollToNextRun)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
    
    private var encouragingMessage: some View {
        Text(getEncouragingMessage())
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    private func getEncouragingMessage() -> String {
        if let nextRun = viewModel.getNextRun() {
            return "Next up: Week \(nextRun.week), Day \(nextRun.runNumber)\nYou've got this!"
        } else {
            return "Congratulations! You've completed all runs!"
        }
    }
    
    private func scrollToNextRun() {
        if let nextRun = viewModel.getNextRun() {
            nextRunId = "\(nextRun.week)-\(nextRun.runNumber)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    scrollProxy?.scrollTo(nextRunId, anchor: .leading)
                }
            }
        }
    }
}

struct RunSquare: View {
    let run: Run
    
    var body: some View {
        VStack {
            Text("Week \(run.week)")
                .font(.headline)
            Text("Day \(run.runNumber)")
                .font(.subheadline)
            
            if run.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .frame(width: 80, height: 80)
        .background(run.isCompleted ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationView {
        SelectRunView(viewModel: RunManagerViewModel(modelContext: ModelContext(try! ModelContainer(for: Run.self, RunManager.self))))
    }
}
