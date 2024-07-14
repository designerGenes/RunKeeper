import SwiftUI

struct RunSegmentDetailsView: View {
    let segments: [RunSegment]
    @Binding var currentSegmentIndex: Int
    let onSegmentTap: (Int) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(segments.indices, id: \.self) { index in
                            segmentRow(for: segments[index], at: index, width: geometry.size.width)
                                .id(index)
                                .onTapGesture {
                                    onSegmentTap(index)
                                }
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: currentSegmentIndex) { newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .top)
                    }
                }
            }
        }
        .frame(height: 200)
    }
    
    private func segmentRow(for segment: RunSegment, at index: Int, width: CGFloat) -> some View {
        let isActive = index == currentSegmentIndex
        
        return Text(segmentDescription(for: segment, index: index))
            .font(isActive ? .headline : .subheadline)
            .fontWeight(isActive ? .bold : .regular)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            .scaleEffect(isActive ? 1.0 : 0.95, anchor: .leading)
            .opacity(isActive ? 1.0 : 0.7)
            .frame(width: width - 40)  // Subtracting padding to ensure it fits
    }
    
    private func segmentDescription(for segment: RunSegment, index: Int) -> String {
        let action: String
        switch segment.segmentType {
        case .warmUp:
            action = "Warm up"
        case .coolDown:
            action = "Cool down"
        case .run:
            action = "Run"
        case .walk:
            action = "Walk"
        }
        
        let duration = Int(segment.duration)
        let minutes = duration / 60
        let seconds = duration % 60
        let timeString: String
        if minutes > 0 {
            timeString = seconds > 0 ? "\(minutes) minute(s) and \(seconds) second(s)" : "\(minutes) minute(s)"
        } else {
            timeString = "\(seconds) second(s)"
        }
        
        let prefix = index == 0 ? "" : "then "
        return "\(prefix)\(action) for \(timeString)"
    }
}
