//
//  ChallengeSaveViewModel.swift
//  PickChal
//
//  Created by 조수원 on 5/25/25.
//

import Foundation
import SwiftUI

// 새로운 챌린지 coredata에 저장하는 VM
final class ChallengeSaveViewModel: ObservableObject {

    func saveChallenge(from recommendation: RecommendationModel) {
        let context = CoreDataManager.shared.container.viewContext
        let newChallenge = Challenge(context: context)
        newChallenge.id = recommendation.id
        newChallenge.title = recommendation.title
        newChallenge.subTitle = ""
        newChallenge.descriptionText = recommendation.description
        newChallenge.category = ""
        newChallenge.startDate = Date()
        newChallenge.endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        newChallenge.totalCount = 7
        newChallenge.createdAt = Date()
        newChallenge.alarmTime = Date() // 알림 시간은 기본 값으로 설정해뒀어요
        newChallenge.isCompleted = false

        do {
            try context.save()
            print("추천 챌린지 CoreData 저장 완료")
        } catch {
            print("추천 챌린지 저장 실패: \(error.localizedDescription)")
        }
    }
}
