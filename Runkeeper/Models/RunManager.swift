//
//  RunManager.swift
//  Runkeeper
//
//  Created by Jaden Nation on 6/23/24.
//

import Foundation
import SwiftData

@Model
class RunManager: ObservableObject {
    var runs: [Run]
    
    init() {
        self.runs = RunManager.createInitialRuns()
    }
    
    static func createInitialRuns() -> [Run] {
        var allRuns: [Run] = []
        
        for week in 1...7 {
            for runNumber in 1...4 {
                let run = createRun(for: week, runNumber: runNumber)
                allRuns.append(run)
            }
        }
        
        return allRuns
    }
    
    static func createRun(for week: Int, runNumber: Int) -> Run {
        // This is a simplified version. You may want to adjust the difficulty progression.
        let totalDuration: TimeInterval = 20 * 60 // 20 minutes
        var segments: [Segment] = []
        
        switch week {
        case 1:
            // Week 1: 1 minute run, 2 minutes walk
            for _ in 1...7 {
                segments.append(Segment(type: .run, duration: 60))
                segments.append(Segment(type: .walk, duration: 120))
            }
        case 2:
            // Week 2: 1.5 minutes run, 2 minutes walk
            for _ in 1...6 {
                segments.append(Segment(type: .run, duration: 90))
                segments.append(Segment(type: .walk, duration: 120))
            }
        case 3:
            // Week 3: 2 minutes run, 1.5 minutes walk
            for _ in 1...6 {
                segments.append(Segment(type: .run, duration: 120))
                segments.append(Segment(type: .walk, duration: 90))
            }
        case 4:
            // Week 4: 3 minutes run, 1.5 minutes walk
            for _ in 1...5 {
                segments.append(Segment(type: .run, duration: 180))
                segments.append(Segment(type: .walk, duration: 90))
            }
        case 5:
            // Week 5: 5 minutes run, 1 minute walk
            for _ in 1...4 {
                segments.append(Segment(type: .run, duration: 300))
                segments.append(Segment(type: .walk, duration: 60))
            }
        case 6:
            // Week 6: 8 minutes run, 1 minute walk
            for _ in 1...3 {
                segments.append(Segment(type: .run, duration: 480))
                segments.append(Segment(type: .walk, duration: 60))
            }
        case 7:
            // Week 7: 20 minutes continuous run
            segments.append(Segment(type: .run, duration: 1200))
        default:
            break
        }
        
        return Run(week: week, runNumber: runNumber, totalDuration: totalDuration, segments: segments)
    }
    
    func getNextRun() -> Run? {
        return runs.first { !$0.isCompleted }
    }
    
    func markRunAsCompleted(_ run: Run) {
        if let index = runs.firstIndex(where: { $0.week == run.week && $0.runNumber == run.runNumber }) {
            runs[index].isCompleted = true
        }
    }
}
