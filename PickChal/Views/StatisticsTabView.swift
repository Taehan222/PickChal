//
//  StatisticsTabView.swift
//  SampleApp03
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI

struct StatItem: View {
    let number: String
    let label: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(number)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Theme.Colors.primary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Theme.Colors.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.lightGray)
        .cornerRadius(12)
    }
}

struct StatisticsTabView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Text("나의 챌린지 통계")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Theme.Colors.text)
            DatePicker("", selection: .constant(Date()), displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                .accentColor(Theme.Colors.primary)
                .frame(maxHeight: 300)
            HStack(spacing: Theme.Spacing.sm) {
                StatItem(number: "15", label: "완료한 챌린지")
                StatItem(number: "7", label: "연속 달성일")
                StatItem(number: "85%", label: "달성률")
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.background)
    }
}
