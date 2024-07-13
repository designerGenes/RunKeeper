import Foundation

struct Run: Codable, Identifiable {
    let id: UUID
    let week: Int
    let day: Int
    var segments: [RunSegment]

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

        // Add warm-up and cool-down segments
        segments.insert(RunSegment(segmentType: .warmUp, duration: 300), at: 0)
        segments.append(RunSegment(segmentType: .coolDown, duration: 300))
    }

    init(week: Int, day: Int, segments: [RunSegment]) {
        self.id = UUID()
        self.week = week
        self.day = day
        self.segments = segments

        // Add warm-up and cool-down segments
        self.segments.insert(RunSegment(segmentType: .warmUp, duration: 300), at: 0)
        self.segments.append(RunSegment(segmentType: .coolDown, duration: 300))
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
    case warmUp
    case run
    case walk
    case coolDown
}
