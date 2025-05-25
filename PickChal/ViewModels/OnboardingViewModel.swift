//
//  OnboardingViewModel.swift
//  PickChal
//
//  Created by 조수원 on 5/25/25.
//

import Foundation

final class OnboardingVM: ObservableObject {
    @Published var year: Int = 2000 // 기본 값 2000년도
    @Published var mbti: MBTIType? 
    @Published var goal: String = ""

    func saveUserProfile() {
        guard let selectedMBTI = mbti else {
            return
        }
        let user = UserModel(
            year: year,
            mbti: selectedMBTI,
            priority: .운동,
            goal: goal,
            isOnboardingCompleted: false
        )

        do {
            try CoreDataManager.shared.saveUserProfile(input: user)
            print("사용자 정보 저장 완료")
        } catch {
            print("사용자 정보 저장 실패: \(error.localizedDescription)")
        }
    }
}
