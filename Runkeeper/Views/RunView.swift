import SwiftUI
import SwiftData

struct RunView: View {
    @ObservedObject var viewModel: RunManagerViewModel
    let runRecord: RunRecord
    @State private var run: Run?
    
    @State private var isRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var currentSegmentIndex = 0
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                themeManager.backgroundGradient
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    if let run = run {
                        progressCircle(geometry: geometry, run: run)
                        controlButtons
                    } else {
                        Text("Loading run data...")
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationTitle("Week \(runRecord.week), Day \(runRecord.day)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadRunData)
        .onDisappear(perform: stopRun)
    }
    
    private var controlButtons: some View {
        HStack {
            Button(action: toggleRunning) {
                Text(isRunning ? "Pause" : "Start")
                    .font(.title)
                    .padding()
                    .frame(minWidth: 120)
                    .background(isRunning ? Color.orange : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: stopRun) {
                Text("Stop")
                    .font(.title)
                    .padding()
                    .frame(minWidth: 120)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(15)
    }
    
    private func progressCircle(geometry: GeometryProxy, run: Run) -> some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.5))
            
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(elapsedTime / run.totalDuration, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(currentSegment(run: run).segmentType == .run ? .green : .blue)
                .rotationEffect(Angle(degrees: 270.0))
            
            VStack {
                Text(currentSegment(run: run).segmentType == .run ? "RUN" : "WALK")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(timeString(time: currentSegmentTimeRemaining(run: run)))
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(timeString(time: totalTimeRemaining(run: run)))
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(width: min(geometry.size.width, geometry.size.height) * 0.8)
        .padding()
    }
    
    private func currentSegment(run: Run) -> RunSegment {
        run.segments[currentSegmentIndex]
    }
    
    private func currentSegmentTimeRemaining(run: Run) -> TimeInterval {
        let segmentStartTime = run.segments[0..<currentSegmentIndex].reduce(0) { $0 + $1.duration }
        return max(0, currentSegment(run: run).duration - (elapsedTime - segmentStartTime))
    }
    
    private func totalTimeRemaining(run: Run) -> TimeInterval {
        max(0, run.totalDuration - elapsedTime)
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
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let run = run, elapsedTime < run.totalDuration {
                elapsedTime += 1
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
}

extension Run {
    var totalDuration: TimeInterval {
        segments.reduce(0) { $0 + $1.duration }
    }
}
