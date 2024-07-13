import Foundation
import SwiftData

@Model
final class RunManager {
    @Relationship(deleteRule: .cascade) var runs: [Run]
    
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
        let totalDuration: TimeInterval = 30 * 60 // 30 minutes
        var segments: [Segment] = []
        
        switch week {
        case 1...2:
            segments = createSegments(runDuration: 60, walkDuration: 90, count: 8)
        case 3...4:
            segments = createSegments(runDuration: 90, walkDuration: 90, count: 6)
        case 5...6:
            segments = createSegments(runDuration: 180, walkDuration: 60, count: 5)
        case 7:
            segments = [Segment(type: .run, duration: totalDuration)]
        default:
            break
        }
        
        return Run(week: week, runNumber: runNumber, totalDuration: totalDuration, segments: segments)
    }
    
    static func createSegments(runDuration: TimeInterval, walkDuration: TimeInterval, count: Int) -> [Segment] {
        var segments: [Segment] = []
        for _ in 1...count {
            segments.append(Segment(type: .run, duration: runDuration))
            segments.append(Segment(type: .walk, duration: walkDuration))
        }
        return segments
    }
}
