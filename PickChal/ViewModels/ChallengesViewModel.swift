//
//  ChallengesViewModel.swift
//  PickChal
//
//  Created by 조수원 on 5/24/25.
//

import Foundation

class ChallengeViewModel: ObservableObject {
    @Published var challenges: [ChallengeModel] = []
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()),
              let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date()) else {
            return
        }
        
        challenges = [
            ChallengeModel(
                id: UUID(),
                title: "챌린지 1",
                subTitle: "챌린지입니다",
                description: "설명입니다",
                category: "공부",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
                totalCount: 30,
                createdAt: Date(),
                alarmTime: Date()
            ),
            ChallengeModel(
                id: UUID(),
                title: "챌린지 2",
                subTitle: "챌린지입니다",
                description: "설명입니다",
                category: "운동",
                startDate: yesterday,
                endDate: Calendar.current.date(byAdding: .day, value: 30, to: yesterday)!,
                totalCount: 7,
                createdAt: yesterday,
                alarmTime: yesterday
            ),
            ChallengeModel(
                id: UUID(),
                title: "챌린지 3",
                subTitle: "챌린지입니다",
                description: "설명입니다",
                category: "자기계발",
                startDate: twoDaysAgo,
                endDate: Calendar.current.date(byAdding: .day, value: 30, to: twoDaysAgo)!,
                totalCount: 30,
                createdAt: twoDaysAgo,
                alarmTime: twoDaysAgo
            ),
            ChallengeModel(
                id: UUID(),
                title: "챌린지 4",
                subTitle: "챌린지입니다",
                description: "설명입니다",
                category: "독서",
                startDate: twoDaysAgo,
                endDate: Calendar.current.date(byAdding: .day, value: 30, to: twoDaysAgo)!,
                totalCount: 30,
                createdAt: twoDaysAgo,
                alarmTime: twoDaysAgo
            ),
            ChallengeModel(
                id: UUID(),
                title: "챌린지 5",
                subTitle: "챌린지입니다",
                description: "설명입니다",
                category: "시간관리",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
                totalCount: 15,
                createdAt: Date(),
                alarmTime: Date()
            )
        ]
    }

    // 진행 중인 챌린지 목록
    var goingChallenges: [ChallengeModel] {
        challenges.filter { !$0.isCompleted }
    }
    
    // 완료된 챌린지 목록
    var completedChallenges: [ChallengeModel] {
        challenges.filter { $0.isCompleted }
    }

    // 진행중인 챌린지를 완료 상태로
    func completeChallenge(id: UUID) {
        if let index = challenges.firstIndex(where: { $0.id == id }) {
            challenges[index].isCompleted = true
        }
    }

    // 완료된 챌린지를 다시 진행중으로
    func goingChallenge(id: UUID) {
        if let index = challenges.firstIndex(where: { $0.id == id }) {
            challenges[index].isCompleted = false
        }
    }
}
