//
//  UIColor+Convenience.swift
//  Lace
//
//  Created by Jaden Nation on 7/14/24.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    static func fromHex(hex: String) -> UIColor? {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }

        guard hexString.count == 6 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension Color {
    func lighten(by percentage: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        red = min(red + (1.0 - red) * percentage, 1.0)
        green = min(green + (1.0 - green) * percentage, 1.0)
        blue = min(blue + (1.0 - blue) * percentage, 1.0)
        
        return Color(red: red, green: green, blue: blue, opacity: Double(alpha))
    }
}
