import SwiftUI

struct GradientGenerator {
    static func generate(from color: Color) -> LinearGradient {
        let lighterColor = color.opacity(0.6)
        let darkerColor = color.opacity(0.8)
        
        return LinearGradient(
            gradient: Gradient(colors: [lighterColor, darkerColor]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
