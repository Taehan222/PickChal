//
//  StatsViewModel.swift
//  PickChal
//
//  Created by 조수원 on 5/27/25.
//

import Foundation
import Foundation
import CoreData

final class StatisticsViewModel: ObservableObject {
    private let context = CoreDataManager.shared.container.viewContext
    
    @Published var completedCount: Int = 0
    @Published var totalCount: Int = 0
    @Published var categorySummary: [String: Int] = [:] // 카테고리별로 몇 개의 챌린지가 있는지
    @Published var durationByChallenge: [(title: String, days: Int)] = [] // 며칠짜리 챌린지인지
    @Published var weekdaySummary: [String: Int] = [:] // 요일별로 시작한 챌린지 개수
    
    func loadStatistics() {
        do {
            // 사용자가 저장한 챌린지 정보
            let challenges: [Challenge] = try context.fetch(Challenge.fetchRequest())
            // 실제로 사용자가 날짜별로 완료한 로그
            let logs: [ChallengeLog] = try context.fetch(ChallengeLog.fetchRequest())
            
            totalCount = logs.count
            completedCount = logs.filter { $0.completed }.count
            
            // 카테고리별 개수
            let groupedByCategory = Dictionary(grouping: challenges) { $0.category ?? "기타" }
            categorySummary = groupedByCategory.mapValues { $0.count }
            
            // 챌린지별 기간
            durationByChallenge = challenges.map {
                let days = Calendar.current.dateComponents([.day], from: $0.startDate ?? Date(), to: $0.endDate ?? Date()).day ?? 0
                return (title: $0.title ?? "", days: max(days, 0))
            }
            
            // 요일별 시작 횟수
            let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
            let groupedByWeekday = Dictionary(grouping: challenges) { challenge in
                let weekday = Calendar.current.component(.weekday, from: challenge.startDate ?? Date())
                return weekdays[weekday - 1]
            }
            weekdaySummary = groupedByWeekday.mapValues { $0.count }
        } catch {
            print("통계 로드 실패: \(error.localizedDescription)")
        }
    }
}
