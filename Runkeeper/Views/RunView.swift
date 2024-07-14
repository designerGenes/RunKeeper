import SwiftUI
import SwiftData

struct RunView: View {
    @ObservedObject var viewModel: RunManagerViewModel
    @Environment(\.presentationMode) var presentationMode
    let runRecord: RunRecord
    @State private var run: Run?
    
    @State private var isRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var currentSegmentIndex = 0
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var showingStopAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                RunProgressBar(segments: run?.segments ?? [], totalDuration: run?.totalDuration ?? 0, elapsedTime: elapsedTime)
                    .frame(height: 120)
                    .padding(.top)
                
                VStack(spacing: 10) {
                    Text(segmentTypeString(for: currentSegment(run: run)?.segmentType ?? .walk))
                        .font(.system(size: 48, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Text(timeString(time: currentSegmentTimeRemaining(run: run)))
                        .font(.system(size: 36, weight: .semibold))
                    
                    Text(timeString(time: totalTimeRemaining(run: run)))
                        .font(.system(size: 24))
                }
                .padding(.vertical)
                
                RunSegmentDetailsView(
                    segments: run?.segments ?? [],
                    currentSegmentIndex: $currentSegmentIndex,
                    onSegmentTap: { tappedIndex in
                        jumpToSegment(run: run, index: tappedIndex)
                    }
                )
                .frame(height: geometry.size.height * 0.3)
                
                Spacer()
                
                controlButtons
                    .padding(.bottom)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(themeManager.backgroundGradient.ignoresSafeArea())
        }
        .navigationTitle("Week \(runRecord.week), Day \(runRecord.day)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadRunData)
        .onDisappear(perform: pauseRun)
        .alert(isPresented: $showingStopAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("Stopping the run will reset your progress with this run."),
                primaryButton: .destructive(Text("Yes")) {
                    stopRun()
                    viewModel.markRunAsIncomplete(runRecord)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 50) {
            Button(action: toggleRunning) {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.primary)
            }
            
            Button(action: {
                showingStopAlert = true
            }) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func segmentTypeString(for segmentType: SegmentType?) -> String {
        guard let segmentType = segmentType else { return "READY" }
        switch segmentType {
        case .warmUp:
            return "WARM UP"
        case .coolDown:
            return "COOL DOWN"
        case .run:
            return "RUN"
        case .walk:
            return "WALK"
        }
    }
    
    private func currentSegment(run: Run?) -> RunSegment? {
        guard let run = run, currentSegmentIndex < run.segments.count else { return nil }
        return run.segments[currentSegmentIndex]
    }
    
    private func currentSegmentTimeRemaining(run: Run?) -> TimeInterval {
        guard let run = run, let currentSegment = currentSegment(run: run) else { return 0 }
        let segmentStartTime = run.segments[0..<currentSegmentIndex].reduce(0) { $0 + $1.duration }
        return max(0, currentSegment.duration - (elapsedTime - segmentStartTime))
    }
    
    private func totalTimeRemaining(run: Run?) -> TimeInterval {
        guard let run = run else { return 0 }
        return max(0, run.totalDuration - elapsedTime)
    }
    
    private func toggleRunning() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        isRunning = true
        viewModel.markRunAsIncomplete(runRecord)
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let run = run, elapsedTime < run.totalDuration {
                elapsedTime += 0.1
                updateCurrentSegment(run: run)
            } else {
                completeRun()
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func stopRun() {
        pauseTimer()
        elapsedTime = 0
        currentSegmentIndex = 0
    }
    
    private func pauseRun() {
        pauseTimer()
    }
    
    private func updateCurrentSegment(run: Run) {
        let segmentEndTime = run.segments[0...currentSegmentIndex].reduce(0) { $0 + $1.duration }
        if elapsedTime >= segmentEndTime && currentSegmentIndex < run.segments.count - 1 {
            currentSegmentIndex += 1
        }
    }
    
    private func completeRun() {
        stopRun()
        viewModel.markRunAsCompleted(runRecord)
    }
    
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func loadRunData() {
        run = viewModel.getPredefinedRun(for: runRecord)
    }
    
    private func jumpToSegment(run: Run?, index: Int) {
        guard let run = run, index < run.segments.count else { return }
        currentSegmentIndex = index
        elapsedTime = run.segments[0..<index].reduce(0) { $0 + $1.duration }
    }
}

extension Run {
    var totalDuration: TimeInterval {
        segments.reduce(0) { $0 + $1.duration }
    }
}
