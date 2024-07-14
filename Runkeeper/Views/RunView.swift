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
            ZStack {
                themeManager.backgroundGradient
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    if let run = run {
                        progressCircle(geometry: geometry, run: run)
                        controlButtons
                        segmentDescriptionText(run: run)
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
        HStack {
            Button(action: toggleRunning) {
                Text(isRunning ? "Pause" : "Start")
                    .font(.title)
                    .padding()
                    .frame(minWidth: 40)
                    .background(isRunning ? Color.orange : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                showingStopAlert = true
            }) {
                Text("Stop")
                    .font(.title)
                    .padding()
                    .frame(minWidth: 40)
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
                .foregroundColor(segmentColor(for: currentSegment(run: run).segmentType))
                .rotationEffect(Angle(degrees: 270.0))
            
            VStack {
                Text(segmentTypeString(for: currentSegment(run: run).segmentType))
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
    
    private func segmentDescriptionText(run: Run) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(run.segments.indices, id: \.self) { index in
                let segment = run.segments[index]
                Text(segmentDescription(for: segment, index: index))
                    .font(index == currentSegmentIndex ? .headline : .body)
                    .fontWeight(index == currentSegmentIndex ? .bold : .regular)
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
        .padding()
    }
    
    private func segmentDescription(for segment: RunSegment, index: Int) -> String {
        let action: String
        switch segment.segmentType {
        case .warmUp:
            action = "Warm up"
        case .coolDown:
            action = "Cool down"
        case .run:
            action = "Run"
        case .walk:
            action = "Walk"
        }
        
        let duration = Int(segment.duration)
        let minutes = duration / 60
        let seconds = duration % 60
        let timeString: String
        if minutes > 0 {
            timeString = seconds > 0 ? "\(minutes) minute(s) and \(seconds) second(s)" : "\(minutes) minute(s)"
        } else {
            timeString = "\(seconds) second(s)"
        }
        
        let prefix = index == 0 ? "" : "Then "
        return "\(prefix)\(action) for \(timeString)"
    }
    
    private func segmentColor(for segmentType: SegmentType) -> Color {
        switch segmentType {
        case .warmUp, .coolDown:
            return .yellow
        case .run:
            return .green
        case .walk:
            return .blue
        }
    }
    
    private func segmentTypeString(for segmentType: SegmentType) -> String {
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
}

extension Run {
    var totalDuration: TimeInterval {
        segments.reduce(0) { $0 + $1.duration }
    }
}
