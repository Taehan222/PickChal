//
//  Recommendation.swift
//  SampleApp03
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI

struct RecommendationTabView: View {
    let recommendations = [
        RecommendationModel(title: "새로운 걷기 루트", description: "한강변을 따라 산책해보세요", iconName: "map"),
        RecommendationModel(title: "독서 챌린지", description: "한 달에 두 권 읽기 목표", iconName: "book"),
        RecommendationModel(title: "코딩 연습", description: "알고리즘 문제 5개 풀기", iconName: "chevron.left.slash.chevron.right")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.md) {
                ForEach(recommendations) { rec in
                    CardView(title: rec.title, subtitle: rec.description, iconName: rec.iconName)
                }
            }
            .padding(.top, Theme.Spacing.md)
        }
        .background(Theme.Colors.background)
    }
}
