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
        
        // 기본 정보 설정
        newChallenge.id = recommendation.id
        newChallenge.title = recommendation.title
        newChallenge.subTitle = ""
        newChallenge.descriptionText = recommendation.descriptionText
        newChallenge.category = recommendation.category
        newChallenge.startDate = Date()
        
        // 챌린지 기간 계산
        let dayCount = getDayCount(from: recommendation.descriptionText)
        newChallenge.endDate = Calendar.current.date(byAdding: .day, value: dayCount - 1, to: Date()) ?? Date()
        newChallenge.totalCount = Int16(dayCount)
        
        // 생성일 및 알림 시간
        newChallenge.createdAt = Date()
        newChallenge.alarmTime = recommendation.alarmTime ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!// 알림 시간 없으면 오전 9시기본값
        newChallenge.isCompleted = false

        do {
            try context.save()
            print("추천 챌린지 CoreData 저장 완료")
            
            // 저장 후, 날짜별로 ChallengeLog 저장
            saveChallengeLogs(for: newChallenge)
            let challengeModel = convertToModel(from: newChallenge)
            NotificationManager.shared.removeChallenge(challengeModel.id)
            NotificationManager.shared.scheduleChallenge(challengeModel,notificationsEnabled: true)

        } catch {
            print("추천 챌린지 저장 실패: \(error.localizedDescription)")
        }
    }

    // descriptionText에서 "/"로 나눠서, 날짜별로 ChallengeLog를 저장
    private func saveChallengeLogs(for challenge: Challenge) {
        guard let descriptionText = challenge.descriptionText else {
            print("챌린지 설명이 비어있습니다.")
            return
        }
        
        let descriptions = descriptionText
            .components(separatedBy: "/")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let calendar = Calendar.current

        for (index, desc) in descriptions.enumerated() {
            let log = ChallengeLog(context: CoreDataManager.shared.container.viewContext)
            log.id = UUID()
            
            if let startDate = challenge.startDate {
                log.date = calendar.date(byAdding: .day, value: index, to: startDate) ?? startDate
            } else {
                log.date = Date()
            }

            log.completed = false
            log.challenge = challenge
            log.descriptionText = desc
        }

        do {
            try CoreDataManager.shared.container.viewContext.save()
            print("날짜별 챌린지 로그 저장 완료")
        } catch {
            print("챌린지 로그 저장 실패: \(error.localizedDescription)")
        }
    }

    // descriptionText를 "/"로 나눠서 며칠짜리 챌린지인지 계산
    private func getDayCount(from descriptionText: String) -> Int {
        descriptionText.components(separatedBy: "/").count
    }
    private func convertToModel(from challenge: Challenge) -> ChallengeModel {
        return ChallengeModel(
            id: challenge.id ?? UUID(),
            title: challenge.title ?? "",
            subTitle: challenge.subTitle ?? "",
            descriptionText: challenge.descriptionText ?? "",
            category: challenge.category ?? "",
            startDate: challenge.startDate ?? Date(),
            endDate: challenge.endDate ?? Date(),
            totalCount: Int(challenge.totalCount),
            createdAt: challenge.createdAt ?? Date(),
            alarmTime: challenge.alarmTime ?? Date(),
            isCompleted: challenge.isCompleted
        )
    }

}
