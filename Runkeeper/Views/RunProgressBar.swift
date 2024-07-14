import SwiftUI

struct RunProgressBar: View {
    let segments: [RunSegment]
    let totalDuration: TimeInterval
    let elapsedTime: TimeInterval
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                
                HStack(spacing: 0) {
                    ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                        let segmentWidth = CGFloat(segment.duration / totalDuration) * geometry.size.width
                        let segmentElapsedTime = min(max(0, elapsedTime - segments[0..<index].reduce(0) { $0 + $1.duration }), segment.duration)
                        let fillWidth = (segmentElapsedTime / segment.duration) * segmentWidth
                        
                        Rectangle()
                            .fill(colorForSegment(segment.segmentType))
                            .frame(width: fillWidth)
                    }
                }
            }
        }
        .frame(height: 120)
    }
    
    private func colorForSegment(_ segmentType: SegmentType) -> Color {
        switch segmentType {
        case .warmUp, .coolDown:
            return Color(uiColor: UIColor.fromHex(hex: "#FFCC66")!)
        case .run:
            return Color(uiColor: UIColor.fromHex(hex: "#FF5733")!)
        case .walk:
            return Color(uiColor: UIColor.fromHex(hex: "#FF9966")!)
        }
    }
}
