//
//  HomeTabViewModel.swift
//  PickChal
//
//  Created by 조수원 on 5/25/25.
//

import SwiftUI

class HomeTabViewModel: ObservableObject {
    @Published var selectedChallengeID: UUID?
    @Published var showAlert = false
    
    // 챌린지 완료 알림
    func showCompletionAlert(for id: UUID) {
        selectedChallengeID = id
        showAlert = true
    }
    
    // 챌린지 완료 처리
    func completeChallenge(in viewModel: ChallengeViewModel) {
        if let id = selectedChallengeID {
            viewModel.completeChallenge(id: id)
            showAlert = false
        }
    }
}
