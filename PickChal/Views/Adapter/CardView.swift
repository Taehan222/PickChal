//
//  CardView.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI

struct CardView: View {
    var title: String
    var subtitle: String
    var iconName: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(Theme.Colors.primary)
            }
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.gray)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.background)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
    }
}
