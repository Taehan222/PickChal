//
//  ChallengeCardView.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI

struct ChallengeCardView: View {
    let title: String
    let subtitle: String
    let progress: CGFloat
    let countText: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Theme.Colors.primary)
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.text)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: Theme.Spacing.xs)
                    .frame(height: 6)
                    .foregroundColor(Theme.Colors.tertiary)
                RoundedRectangle(cornerRadius: Theme.Spacing.xs)
                    .frame(width: progress * UIScreen.main.bounds.width * 0.8, height: 6)
                    .foregroundColor(Color.yellow)
            }

            Text(countText)
                .font(.system(size: 12))
                .foregroundColor(Theme.Colors.gray)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.background)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
    }
}
