import Foundation
import SwiftData

@Model
final class Run {
    var week: Int
    var runNumber: Int
    var totalDuration: TimeInterval
    var segments: [Segment]
    var isCompleted: Bool
    var startDate: Date?
    var endDate: Date?
    
    init(week: Int, runNumber: Int, totalDuration: TimeInterval, segments: [Segment], isCompleted: Bool = false) {
        self.week = week
        self.runNumber = runNumber
        self.totalDuration = totalDuration
        self.segments = segments
        self.isCompleted = isCompleted
        self.startDate = nil
        self.endDate = nil
    }
}

extension Run {
    var formattedDuration: String {
        let minutes = Int(totalDuration) / 60
        let seconds = Int(totalDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var progressPercentage: Double {
        guard let startDate = startDate, !isCompleted else { return isCompleted ? 1.0 : 0.0 }
        let elapsedTime = Date().timeIntervalSince(startDate)
        return min(elapsedTime / totalDuration, 1.0)
    }
}
