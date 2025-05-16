//
//  HomeTabView.swift
//  PickChal
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
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(Color.white)
        .cornerRadius(12)
    }
}


struct HomeTabView: View {
    let challenges: [ChallengeModel] = [
        ChallengeModel(id: UUID(), title: "Morning Run", subtitle: "매일 아침 30분 달리기", totalCount: 30, completedCount: 5),
        ChallengeModel(id: UUID(), title: "물 마시기", subtitle: "하루 2L 물 마시기", totalCount: 7, completedCount: 1),
        ChallengeModel(id: UUID(), title: "독서", subtitle: "하루 30페이지 읽기", totalCount: 30, completedCount: 15)
    ]

    @State private var selectedDate = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pickchal")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Theme.Colors.primary)
                
                DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding(.horizontal)
                
                Text("통계")
                    .font(.title.bold())
                    .padding(.horizontal)
                HStack {
                    StatItem(number: "3", label: "완료한 챌린지")
                    StatItem(number: "7", label: "연속 달성일")
                    StatItem(number: "85%", label: "달성률")
                }
                .padding(.horizontal)
                
                Divider()
                
                Text("나의 챌린지")
                    .font(.title.bold())
                    .padding(.horizontal)

                ForEach(challenges) { challenge in
                    VStack {
                        ChallengeCardView(
                            title: challenge.title,
                            subtitle: challenge.subtitle,
                            progress: challenge.progress,
                            countText: "\(challenge.completedCount)/\(challenge.totalCount) 완료"
                        )

                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
    }
}
