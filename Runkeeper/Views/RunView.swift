//
//  RunView.swift
//  Runkeeper
//
//  Created by Jaden Nation on 6/23/24.
//

import SwiftUI
import SwiftData

struct RunView: View {
    @ObservedObject var runManager: RunManager
    let run: Run
    
    @State private var isRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var currentSegmentIndex = 0
    @State private var backgroundImageName: String
    
    private let backgroundImageWidth: CGFloat = UIScreen.main.bounds.width * 3
    
    init(runManager: RunManager, run: Run) {
        self.runManager = runManager
        self.run = run
        _backgroundImageName = State(initialValue: RunView.generateBackgroundImageName())
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                Image(backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: backgroundImageWidth, height: geometry.size.height)
                    .offset(x: -calculateImageOffset(geometry))
                    .clipped()
                
                VStack {
                    ZStack {
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
                            
                            Text(timeString(time: currentSegmentTimeRemaining))
                                .font(.title)
                                .fontWeight(.semibold)
                            
                            Text(timeString(time: totalTimeRemaining))
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .padding()
                    
                    HStack {
                        Button(action: {
                            if isRunning {
                                pauseTimer()
                            } else {
                                startTimer()
                            }
                        }) {
                            Text(isRunning ? "Pause" : "Start")
                                .font(.title)
                                .padding()
                                .background(isRunning ? Color.orange : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            stopRun()
                        }) {
                            Text("Stop")
                                .font(.title)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Week \(run.week), Run \(run.runNumber)")
        .onDisappear {
            stopRun()
        }
    }
    
    private static func generateBackgroundImageName() -> String {
        let isDayTime = isDaytime()
        let timeOfDay = isDayTime ? "day" : "night"
        let imageNumber = String(format: "%02d", Int.random(in: 0...15))
        return "\(timeOfDay)_\(imageNumber)"
    }
    
    private static func isDaytime() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 6 && hour < 18 // Assuming daytime is from 6 AM to 6 PM
    }
    
    private func calculateImageOffset(_ geometry: GeometryProxy) -> CGFloat {
        let totalOffset = backgroundImageWidth - geometry.size.width
        let progress = CGFloat(elapsedTime / run.totalDuration)
        return totalOffset * progress
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
    
    private func startTimer() {
        isRunning = true
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
            // Here you would trigger any audio cues for segment changes
        }
    }
    
    private func completeRun() {
        stopRun()
        runManager.markRunAsCompleted(run)
        // Here you would show a completion message or navigate back to the run list
    }
    
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
