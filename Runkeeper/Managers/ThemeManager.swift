import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("themeColorString") private var themeColorString = "blue"
    
    var themeColor: Color {
        switch themeColorString {
        case "blue": return .blue
        case "green": return .green
        case "red": return .red
        case "purple": return .purple
        case "orange": return .orange
        default: return .blue
        }
    }
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                themeColor.opacity(0.6),
                themeColor.opacity(0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
