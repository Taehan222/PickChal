//
//  Theme.swift
//  SampleApp03
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r)/255,
            green: Double(g)/255,
            blue: Double(b)/255,
            opacity: Double(a)/255
        )
    }
}

struct Theme {
    struct Colors {
        static let primary = Color(hex: "#FF5252")
        static let secondary = Color(hex: "#FF7676")
        static let tertiary = Color(hex: "#FFE5E5")
        static let gold = Color(hex: "#B8860B")
        static let background = Color(UIColor.systemBackground)
        static let text = Color(hex: "#333333")
        static let border = Color(hex: "#FFEDED")
        static let success = Color(hex: "#4CD964")
        static let error = Color(hex: "#FF3B30")
        static let warning = Color(hex: "#FFCC00")
        static let inactive = Color(hex: "#C7C7CC")
        static let lightGray = Color(hex: "#F2F2F7")
        static let gray = Color(hex: "#8E8E93")
    }
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
    static let pixelSize: CGFloat = 8
}
