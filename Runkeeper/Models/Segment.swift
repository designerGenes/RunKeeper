import Foundation
import SwiftData

enum SegmentType: String, Codable {
    case run
    case walk
}

@Model
final class Segment {
    let type: SegmentType
    let duration: TimeInterval
    
    init(type: SegmentType, duration: TimeInterval) {
        self.type = type
        self.duration = duration
    }
}

extension Segment {
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var activityVerb: String {
        switch type {
        case .run:
            return "Run"
        case .walk:
            return "Walk"
        }
    }
}
