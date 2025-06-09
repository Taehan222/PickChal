import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case lavender, skyBlue, mint, peach, rose

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lavender: return "Lavender"
        case .skyBlue: return "Sky Blue"
        case .mint: return "Mint"
        case .peach: return "Peach"
        case .rose: return "Rose"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .lavender: return Color(red: 0.90, green: 0.83, blue: 1.0)
        case .skyBlue: return Color(red: 0.83, green: 0.91, blue: 1.0)
        case .mint: return Color(red: 0.88, green: 0.98, blue: 0.96)
        case .peach: return Color(red: 1.0, green: 0.91, blue: 0.76)
        case .rose: return Color(red: 0.98, green: 0.86, blue: 0.85)
        }
    }

    var accentColor: Color {
        switch self {
        case .lavender: return Color.purple
        case .skyBlue: return Color.blue
        case .mint: return Color.teal
        case .peach: return Color.orange
        case .rose: return Color.red
        }
    }

    var font: Font {
        switch self {
        case .lavender: return .title3
        case .skyBlue: return .title3
        case .mint: return .title3
        case .peach: return .title3
        case .rose: return .title3
        }
    }
  
        static let `default`: AppTheme = .lavender
    }


