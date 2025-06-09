//
//  StatsViewModel.swift
//  PickChal
//
//  Created by 조수원 on 5/27/25.
//

import Foundation
import CoreData

final class StatisticsViewModel: ObservableObject {
    private let context = CoreDataManager.shared.container.viewContext
    
    @Published var allChallenges: [Challenge] = []
    @Published var allLogs: [ChallengeLog] = []
    @Published var challengeModels: [ChallengeModel] = []
    @Published var completedCount: Int = 0
    @Published var totalCount: Int = 0
    @Published var categorySummary: [String: Int] = [:]
    @Published var durationByChallenge: [(title: String, days: Int)] = []
    @Published var weekdaySummary: [String: Int] = [:]
    @Published var user: UserModel? = nil
    
    var ongoingChallenges: [ChallengeModel] {
        challengeModels.filter { !$0.isCompleted }
    }
    func loadStatistics() {
        do {
            // CoreData에서 불러오기
            allChallenges = try context.fetch(Challenge.fetchRequest())
            allLogs = try context.fetch(ChallengeLog.fetchRequest())
            
            // 통계 뷰에서 쓸 수 있도록 ChallengeModel 변환
            challengeModels = allChallenges.map { challenge in
                ChallengeModel(
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
            
            totalCount = allLogs.count
            completedCount = allLogs.filter { $0.completed }.count
            
            // 카테고리별 개수
            let groupedByCategory = Dictionary(grouping: allChallenges) { $0.category ?? "기타" }
            categorySummary = groupedByCategory.mapValues { $0.count }
            
            // 챌린지별 기간
            durationByChallenge = allChallenges.map {
                let days = Calendar.current.dateComponents([.day], from: $0.startDate ?? Date(), to: $0.endDate ?? Date()).day ?? 0
                return (title: $0.title ?? "", days: max(days, 0))
            }
            
            // 요일별 시작 횟수
            let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
            let groupedByWeekday = Dictionary(grouping: allChallenges) { challenge in
                let weekday = Calendar.current.component(.weekday, from: challenge.startDate ?? Date())
                return weekdays[weekday - 1]
            }
            weekdaySummary = groupedByWeekday.mapValues { $0.count }
            
        } catch {
            print("통계 로드 실패: \(error.localizedDescription)")
        }
    }
    
    // 유저 데이터 불러오기
    func loadUserProfile() {
        do {
            if let fetched = try CoreDataManager.shared.fetchUserProfile() {
                user = UserModel(
                    year: Int(fetched.year),
                    mbti: MBTIType(rawValue: fetched.mbti ?? "") ?? .INTJ,
                    priority: .시간관리,
                    goal: fetched.goal ?? "",
                    isOnboardingCompleted: fetched.onboardingCompleted
                )
            } else {
                print("유저 프로필이 없습니다.")
            }
        } catch {
            print("유저 프로필 불러오기 실패: \(error.localizedDescription)")
        }
    }
    func registerNotificationsIfNeeded() {
        if UserDefaults.standard.bool(forKey: "notificationsEnabled") {
            for challenge in ongoingChallenges {
                let todayKey = "skipAlarm_\(challenge.id.uuidString)_\(Date().todayString)"
                let skipToday = UserDefaults.standard.bool(forKey: todayKey)

                if !skipToday {
                    NotificationManager.shared.removeChallenge(challenge.id)
                    NotificationManager.shared.scheduleChallenge(challenge, notificationsEnabled: true, increaseBadge: false)
                } else {
                    print("\(challenge.title) → 오늘은 완료됨 → 알림 등록 생략")
                }
            }
        }
    }

}
