//
//  Color.swift
//  PickChal
//
//  Created by 윤태한 on 6/2/25.
//

import SwiftUI

extension Color {
    static func from(name: String?) -> Color {
        guard let name = name?.lowercased() else { return .primary }
        switch name {
            case "red": return .red
            case "orange": return .orange
            case "yellow": return .yellow
            case "green": return .green
            case "blue": return .blue
            case "indigo": return .indigo
            case "purple": return .purple
            case "pink": return .pink
            case "gray": return .gray
            default: return .primary
        }
    }
}

