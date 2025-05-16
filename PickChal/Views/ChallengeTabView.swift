//
//  Challenge.swift
//  SampleApp03
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI

struct ChallengeTabView: View {
    @StateObject private var viewModel = ChallengeViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Pickchal")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Theme.Colors.primary)
                .padding(.bottom, Theme.Spacing.lg)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.challenges) { challenge in
                        ChallengeCardView(
                            title: challenge.title,
                            subtitle: challenge.subtitle,
                            progress: challenge.progress,
                            countText: "\(challenge.completedCount)/\(challenge.totalCount) 완료"
                        )
                    }
                }
                .padding(.top, Theme.Spacing.md)
                .background(Theme.Colors.background)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.background)
    }
}
