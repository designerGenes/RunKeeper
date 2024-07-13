import Foundation

struct Run: Codable, Identifiable {
    let id: UUID
    let week: Int
    let day: Int
    let segments: [RunSegment]

    enum CodingKeys: String, CodingKey {
        case segments
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        segments = try container.decode([RunSegment].self, forKey: .segments)
        
        // Generate id, week, and day since they're not in the JSON
        id = UUID()
        week = 0  // These will be set later
        day = 0   // These will be set later
    }

    init(week: Int, day: Int, segments: [RunSegment]) {
        self.id = UUID()
        self.week = week
        self.day = day
        self.segments = segments
    }
}

struct RunSegment: Codable {
    let segmentType: SegmentType
    let duration: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case segmentType = "type"
        case duration
    }
}

enum SegmentType: String, Codable {
    case run
    case walk
}
