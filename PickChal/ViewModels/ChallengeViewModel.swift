//
//  ChallengeViewModel.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI
import Combine

class ChallengeViewModel: ObservableObject {
    @Published var challenges: [ChallengeModel] = []

    init() {
        loadSampleData()
    }

    func loadSampleData() {
        challenges = [
            ChallengeModel(id: UUID(), title: "Morning Run", subtitle: "매일 아침 30분 달리기", totalCount: 30, completedCount: 5),
            ChallengeModel(id: UUID(), title: "물 마시기", subtitle: "하루 2L 물 마시기", totalCount: 7, completedCount: 1),
            ChallengeModel(id: UUID(), title: "독서", subtitle: "하루 30페이지 읽기", totalCount: 30, completedCount: 15)
        ]
    }
}
