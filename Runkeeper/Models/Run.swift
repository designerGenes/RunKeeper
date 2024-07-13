import Foundation
import SwiftData

@Model
final class Run {
    var week: Int
    var runNumber: Int
    var totalDuration: TimeInterval
    var segments: [Segment]
    var completedDate: Date?
    
    var isCompleted: Bool {
        completedDate != nil
    }
    
    init(week: Int, runNumber: Int, totalDuration: TimeInterval, segments: [Segment], completedDate: Date? = nil) {
        self.week = week
        self.runNumber = runNumber
        self.totalDuration = totalDuration
        self.segments = segments
        self.completedDate = completedDate
    }
}
