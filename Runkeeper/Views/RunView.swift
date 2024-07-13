import SwiftUI
import SwiftData

struct RunView: View {
    @ObservedObject var viewModel: RunManagerViewModel
    let run: Run
    
    @State private var isRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var currentSegmentIndex = 0
    @State private var gradientColors: [Color] = RunView.generateRandomColors()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                animatedGradientBackground
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    progressCircle(geometry: geometry)
                    
                    controlButtons
                    
                    Spacer()
                }
            }
        }
        .navigationTitle("Week \(run.week), Run \(run.runNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear(perform: stopRun)
    }
    
    private var animatedGradientBackground: some View {
        LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
            .animation(.linear(duration: run.totalDuration).repeatForever(autoreverses: false), value: elapsedTime)
            .offset(x: -UIScreen.main.bounds.width * CGFloat(elapsedTime / run.totalDuration))
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
    
    private func progressCircle(geometry: GeometryProxy) -> some View {
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
                .foregroundColor(currentSegment.type == .run ? .green : .blue)
                .rotationEffect(Angle(degrees: 270.0))
            
            VStack {
                Text(currentSegment.type == .run ? "RUN" : "WALK")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(timeString(time: currentSegmentTimeRemaining))
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(timeString(time: totalTimeRemaining))
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(width: min(geometry.size.width, geometry.size.height) * 0.8)
        .padding()
    }
    
    private static func generateRandomColors() -> [Color] {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
        return (0..<5).map { _ in colors.randomElement()! }
    }
    
    private var currentSegment: Segment {
        run.segments[currentSegmentIndex]
    }
    
    private var currentSegmentTimeRemaining: TimeInterval {
        let segmentStartTime = run.segments[0..<currentSegmentIndex].reduce(0) { $0 + $1.duration }
        return max(0, currentSegment.duration - (elapsedTime - segmentStartTime))
    }
    
    private var totalTimeRemaining: TimeInterval {
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
        viewModel.markRunAsIncomplete(run)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if elapsedTime < run.totalDuration {
                elapsedTime += 1
                updateCurrentSegment()
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
    
    private func updateCurrentSegment() {
        let segmentEndTime = run.segments[0...currentSegmentIndex].reduce(0) { $0 + $1.duration }
        if elapsedTime >= segmentEndTime && currentSegmentIndex < run.segments.count - 1 {
            currentSegmentIndex += 1
        }
    }
    
    private func completeRun() {
        stopRun()
        viewModel.markRunAsCompleted(run)
    }
    
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    RunView(viewModel: RunManagerViewModel(modelContext: ModelContext(try! ModelContainer(for: Run.self, RunManager.self))),
            run: Run(week: 1, runNumber: 1, totalDuration: 1200, segments: [
                Segment(type: .run, duration: 60),
                Segment(type: .walk, duration: 120)
            ]))
}
