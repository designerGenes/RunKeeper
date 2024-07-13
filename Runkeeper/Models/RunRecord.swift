import Foundation
import SwiftData

@Model
final class RunRecord {
    let week: Int
    let day: Int
    var completedDate: Date?

    init(week: Int, day: Int, completedDate: Date? = nil) {
        self.week = week
        self.day = day
        self.completedDate = completedDate
    }
}
